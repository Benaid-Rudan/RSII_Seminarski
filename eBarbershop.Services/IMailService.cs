using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eBarbershop.Model;

namespace eBarbershop.Services
{
    public interface IMailService
    {
        Task startConnection(MailObject obj);
    }
}
