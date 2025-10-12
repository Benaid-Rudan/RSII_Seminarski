using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IListaCekanjaService : ICRUDService<ListaCekanja,
        ListaCekanjaSearchObject, ListaCekanjaInsertRequest, 
        ListaCekanjaUpdateRequest>
    {
        Task<ListaCekanja> JoinWaitingList(ListaCekanjaInsertRequest request);
        Task<bool> RemoveFromWaitingList(int listaCekanjaId);
        Task<List<ListaCekanja>> GetWaitingListForBarber(int frizerId, DateTime? datum = null);
        Task<List<ListaCekanja>> GetMyWaitingList(int klijentId);
        Task ProcessAvailableSlot(int terminId);
        Task<bool> RespondToNotification(int notifikacijaId, bool accepted);
        Task ProcessExpiredNotifications();
        Task OptimizeWaitingListOrder();
        Task<List<NotifikacijaListeCekanja>> GetPendingNotifications(int klijentId);
        Task<WaitingListStats> GetWaitingListStats(int? frizerId = null);
    }

    public class WaitingListStats
    {
        public int TotalActivneStavke { get; set; }
        public int TotalNotifikacije { get; set; }
        public double ProsjekVrijemeCekanja { get; set; }
        public double StopaPrihvacanja { get; set; }
        public List<PopularTimeSlot> NajpopularnijiTermini { get; set; }
    }

    public class PopularTimeSlot
    {
        public int Sat { get; set; }
        public int BrojZahtjeva { get; set; }
        public double PostotakPrihvacanja { get; set; }
    }
}