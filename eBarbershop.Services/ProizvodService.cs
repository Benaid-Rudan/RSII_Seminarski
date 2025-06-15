using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace eBarbershop.Services
{
    public class ProizvodService : BaseCRUDService<Model.Proizvod, 
        Database.Proizvod, ProizvodSearchObject, 
        ProizvodInsertRequest, ProizvodUpdateRequest>, IProizvodService
    {
        public ProizvodService(EBarbershop1Context context, IMapper mapper) : base(context, mapper)
        {

        }
        public override IQueryable<Database.Proizvod> AddInclude(
            IQueryable<Database.Proizvod> entity, ProizvodSearchObject obj)
        {
            if (obj.IncludeVrstaProizvoda == true)
            {
                entity = entity.Include(x => x.VrstaProizvoda);
            }

            return entity;
        }
        public override async Task<Model.Proizvod> Delete(int id)
        {
            var entity = await _context.Proizvod.FindAsync(id);

            if (entity == null)
                throw new Exception("Proizvod nije pronađen");

            entity.IsDeleted = true;
            entity.Zalihe = 
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Proizvod>(entity);
        }
        public override IQueryable<Database.Proizvod> AddFilter(
            IQueryable<Database.Proizvod> entity, ProizvodSearchObject? obj = null)
        {
            entity = base.AddFilter(entity, obj);
            entity = entity.Where(x => !x.IsDeleted);
            if (obj.VrstaProizvodaID.HasValue)
            {
                entity = entity.Where(x => x.VrstaProizvodaId == obj.VrstaProizvodaID);
            }

            if (!string.IsNullOrWhiteSpace(obj.Naziv))
            {
                entity = entity.Where(x => x.Naziv.ToLower().Contains(obj.Naziv.ToLower()));
            }
            if (!string.IsNullOrWhiteSpace(obj.Opis))
            {
                entity = entity.Where(x => x.Opis.ToLower().Contains(obj.Opis.ToLower()));
            }
            return entity;
        }

        static MLContext mlContext = null;
        static object isLocked = new object();
        static ITransformer model = null;

        public List<Model.Proizvod> Recommend(int id)
        {
            lock(isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();
                    var tmpData = _context.Narudzba.Include("NarudzbaProizvodis").ToList();
                    var data = new List<ProductEntry>();    
                    foreach (var x in tmpData)
                    {
                        if (x.NarudzbaProizvodis.Count > 1)
                        {
                            var distinctItemId = x.NarudzbaProizvodis.Select(y => y.ProizvodId)
                                .ToList();
                            distinctItemId.ForEach(y =>
                            {
                                var relatedItems = x.NarudzbaProizvodis.Where(z => z.ProizvodId != y);
                                foreach(var z in relatedItems)
                                {
                                    data.Add(new ProductEntry()
                                    {
                                        ProductID = (uint)y,
                                        CoPurchaseProductID = (uint)z.ProizvodId
                                    });
                                }
                            });
                        }
                        var trainData = mlContext.Data.LoadFromEnumerable(data);

                        MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options();
                        options.MatrixColumnIndexColumnName = nameof(ProductEntry.ProductID);
                        options.MatrixRowIndexColumnName = nameof(ProductEntry.CoPurchaseProductID);
                        options.LabelColumnName = "Label";
                        options.LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass;
                        options.Alpha = 0.01;
                        options.Lambda = 0.025;
                        options.NumberOfIterations = 100;
                        options.C = 0.00001;

                        var est = mlContext.Recommendation().Trainers.MatrixFactorization(options);

                        model = est.Fit(trainData);
                    }
                }
            }
            var products = _context.Proizvod.Where(x => x.ProizvodId != id);
            var predictionResult = new List<Tuple<Database.Proizvod, float>>();
            foreach(var product  in products)
            {
                var predictionengine = mlContext.Model.CreatePredictionEngine<ProductEntry, Copurchase_prediction>(model);
                var prediction = predictionengine.Predict(
                                         new ProductEntry()
                                         {
                                             ProductID = (uint)id,
                                             CoPurchaseProductID = (uint)product.ProizvodId
                                         });
                predictionResult.Add(new Tuple<Database.Proizvod, float>(product, prediction.Score));
            }

            var finalResult = predictionResult.OrderByDescending(x => x.Item2).Select(x=>x.Item1).Take(3).ToList();
            return _mapper.Map<List<Model.Proizvod>>(finalResult);


        }

    }
    public class Copurchase_prediction
    {
        public float Score { get; set; }
    }

    public class ProductEntry
    {
        [KeyType(count: 10)]
        public uint ProductID { get; set; }

        [KeyType(count: 10)]
        public uint CoPurchaseProductID { get; set; }

        public float Label { get; set; }
    }
}
