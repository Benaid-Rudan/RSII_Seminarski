﻿using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface INovostService : ICRUDService<Model.Novost, NovostSearchObject, NovostInsertRequest,NovostUpdateRequest>
    {
    }
}
