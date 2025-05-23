﻿using eBarbershop.Model;
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
            _service = service;
        }

        [HttpPost]
        public async Task<Korisnik> Insert([FromBody] KorisniciInsertRequest request)
        {
            return await _service.Insert(request);
        }

        [HttpPut("{id}")]
        public async Task<Korisnik> Update(int id, [FromBody] KorisniciUpdateRequest request)
        {
            return await _service.Update(id, request);
        }

        [HttpPut("{id}/AddUloga")]
        [Authorize(Roles = "Admin")]
        public Korisnik AddUloga(int id, [FromBody] KorisniciUlogaUpdateRequest request)
        {
            return ((IKorisniciService)_service).AddUloga(id, request);
        }

        [HttpPut("{id}/DeleteUloga")]
        [Authorize(Roles = "Admin")]
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
                string authorization = HttpContext.Request.Headers["Authorization"];

                if (string.IsNullOrEmpty(authorization) || !authorization.StartsWith("Basic "))
                {
                    return Unauthorized("Authorization header missing or invalid.");
                }

                string encodedHeader = authorization["Basic ".Length..].Trim();
                Encoding encoding = Encoding.GetEncoding("iso-8859-1");
                string usernamePassword = encoding.GetString(Convert.FromBase64String(encodedHeader));

                int seperatorIndex = usernamePassword.IndexOf(':');

                string username = usernamePassword.Substring(0, seperatorIndex);
                string password = usernamePassword.Substring(seperatorIndex + 1);

                var user = ((IKorisniciService)_service).Login(username, password);

                return Ok(user);
            }
            catch (Exception ex)
            {
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
