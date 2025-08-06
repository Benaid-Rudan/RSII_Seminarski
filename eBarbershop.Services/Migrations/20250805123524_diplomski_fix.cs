using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBarbershop.Services.Migrations
{
    /// <inheritdoc />
    public partial class diplomski_fix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PredvidjanjeZauzetosti",
                columns: table => new
                {
                    PredvidjanjeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Datum = table.Column<DateTime>(type: "datetime2", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UkupnaZauzetost = table.Column<double>(type: "float", nullable: false),
                    PreporuceniTermini = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PredvidjanjeZauzetosti", x => x.PredvidjanjeId);
                });

            migrationBuilder.CreateTable(
                name: "PreporukaTermina",
                columns: table => new
                {
                    PreporukaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KlijentId = table.Column<int>(type: "int", nullable: false),
                    PreporuceniTermin = table.Column<DateTime>(type: "datetime2", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    SkorPovjerenja = table.Column<double>(type: "float", nullable: false),
                    RazlogPreporuke = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsAccepted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PreporukaTermina", x => x.PreporukaId);
                    table.ForeignKey(
                        name: "FK_PreporukaTermina_Korisnik_KlijentId",
                        column: x => x.KlijentId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PreporukaTermina_Korisnik_KorisnikId",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PreporukaTermina_Usluga_UslugaId",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ZauzetostPoSatu",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Sat = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Vrijednost = table.Column<double>(type: "float", nullable: false),
                    PredvidjanjeId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ZauzetostPoSatu", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ZauzetostPoSatu_PredvidjanjeZauzetosti_PredvidjanjeId",
                        column: x => x.PredvidjanjeId,
                        principalTable: "PredvidjanjeZauzetosti",
                        principalColumn: "PredvidjanjeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PreporukaTermina_KlijentId",
                table: "PreporukaTermina",
                column: "KlijentId");

            migrationBuilder.CreateIndex(
                name: "IX_PreporukaTermina_KorisnikId",
                table: "PreporukaTermina",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_PreporukaTermina_UslugaId",
                table: "PreporukaTermina",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_ZauzetostPoSatu_PredvidjanjeId",
                table: "ZauzetostPoSatu",
                column: "PredvidjanjeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PreporukaTermina");

            migrationBuilder.DropTable(
                name: "ZauzetostPoSatu");

            migrationBuilder.DropTable(
                name: "PredvidjanjeZauzetosti");
        }
    }
}
