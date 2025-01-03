using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisniciController : ControllerBase
    {
        IKorisniciService _service;
       
        public KorisniciController(IKorisniciService service) 
        {
            _service= service;
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<Korisnik> Insert([FromBody] KorisniciInsertRequest request)
        {
            return await _service.Insert(request);
        }

        [HttpPut("{id}/AddUloga")]
        [Authorize(Roles = "Administrator")]
        public Korisnik AddUloga(int id, [FromBody] KorisniciUlogaUpdateRequest request)
        {
            return ((IKorisniciService)_service).AddUloga(id, request);
        }

        [HttpPut("{id}/DeleteUloga")]
        [Authorize(Roles = "Administrator")]
        public Korisnik DeleteUloga(int id, [FromBody] KorisniciUlogaUpdateRequest request)
        {
            return ((IKorisniciService)_service).DeleteUloga(id, request);
        }
        [HttpGet()]
        public async Task<IEnumerable<Model.Korisnik>> Get([FromQuery] KorisnikSearchObject search = null)
        {
            return await _service.Get(search);
        }
        [HttpGet("{id}")]
        public async Task<Model.Korisnik> GetById(int id)
        {
            return await _service.GetById(id);
        }
        [HttpGet("Authenticate")]
        [AllowAnonymous]
        public IActionResult Authenticate()
        {
            try
            {
                // Dohvat Authorization header-a iz zahteva
                string authorization = HttpContext.Request.Headers["Authorization"];

                // Provera da li je zaglavlje prisutno
                if (string.IsNullOrEmpty(authorization) || !authorization.StartsWith("Basic "))
                {
                    return Unauthorized("Authorization header missing or invalid.");
                }

                // Izdvajanje korisničkog imena i lozinke iz Base64 kodiranog stringa
                string encodedHeader = authorization["Basic ".Length..].Trim();
                Encoding encoding = Encoding.GetEncoding("iso-8859-1");
                string usernamePassword = encoding.GetString(Convert.FromBase64String(encodedHeader));

                int seperatorIndex = usernamePassword.IndexOf(':');

                // Izdvajanje korisničkog imena i lozinke
                string username = usernamePassword.Substring(0, seperatorIndex);
                string password = usernamePassword.Substring(seperatorIndex + 1);

                // Pozivanje metode iz servisa za login
                var user = ((IKorisniciService)_service).Login(username, password);

                // Vraćanje korisničkog objekta kao JSON odgovora
                return Ok(user);
            }
            catch (Exception ex)
            {
                // U slučaju greške (npr. ako lozinka nije tačna ili korisnik ne postoji), vraćamo grešku
                return Unauthorized(new { message = ex.Message });
            }
        }
        [HttpDelete("{id}")]
        public virtual async Task<Korisnik> Delete(int id)
        {
            return await _service.Delete(id);
        }


    }
}
