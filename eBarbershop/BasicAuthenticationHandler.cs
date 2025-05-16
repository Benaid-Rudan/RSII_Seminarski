using eBarbershop.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using Microsoft.Identity.Client;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace eBarbershop
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        public IKorisniciService service { get; set; }
        public BasicAuthenticationHandler(IKorisniciService _service,IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock) : base(options, logger, encoder, clock)
        {
            service = _service;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                return AuthenticateResult.Fail("Missing Authorization header");
            }

            try
            {
                // Parsiranje Authorization header-a
                var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
                var credentialBytes = Convert.FromBase64String(authHeader.Parameter);
                var credentials = Encoding.UTF8.GetString(credentialBytes).Split(':');

                if (credentials.Length != 2)
                {
                    return AuthenticateResult.Fail("Invalid Authorization header format");
                }

                var username = credentials[0];
                var password = credentials[1];

                // Provera korisnika kroz servis
                var user = service.Login(username, password);

                if (user == null)
                {
                    return AuthenticateResult.Fail("Invalid username or password");
                }

                // Kreiranje claim-ova za korisnika
                var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.KorisnikId.ToString()),
            new Claim(ClaimTypes.Name, user.Ime ?? "Unknown")
        };

                if (user.KorisnikUlogas != null)
                {
                    foreach (var role in user.KorisnikUlogas)
                    {
                        claims.Add(new Claim(ClaimTypes.Role, role.Uloga.Naziv));
                    }
                }

                var identity = new ClaimsIdentity(claims, Scheme.Name);
                var principal = new ClaimsPrincipal(identity);
                var ticket = new AuthenticationTicket(principal, Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
            catch (FormatException)
            {
                return AuthenticateResult.Fail("Invalid Base64 format in Authorization header");
            }
            catch (Exception ex)
            {
                return AuthenticateResult.Fail($"An error occurred: {ex.Message}");
            }
        }
    }
}
