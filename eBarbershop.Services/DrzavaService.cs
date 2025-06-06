﻿using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class DrzavaService : BaseCRUDService<Model.Drzava, Database.Drzava, DrzavaSearchObject , DrzavaInsertRequest, DrzavaUpdateRequest>, IDrzavaService 
    {
        
        public DrzavaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }

       
        
    }
}
