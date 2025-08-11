using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBarbershop.Services.Migrations
{
    /// <inheritdoc />
    public partial class listacekanja_diplomski : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ListaCekanja",
                columns: table => new
                {
                    ListaCekanjaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KlijentId = table.Column<int>(type: "int", nullable: false),
                    FrizerId = table.Column<int>(type: "int", nullable: false),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    ZeljeniDatum = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ZeljenoVrijeme = table.Column<TimeSpan>(type: "time", nullable: true),
                    Prioritet = table.Column<int>(type: "int", nullable: false),
                    DatumPrijave = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Status = table.Column<int>(type: "int", nullable: false, defaultValue: 1),
                    DatumNotifikacije = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DatumIsteka = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Napomena = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    MLSkor = table.Column<double>(type: "float", nullable: false),
                    NotifikacijaPoslana = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ListaCekanja", x => x.ListaCekanjaId);
                    table.ForeignKey(
                        name: "FK_ListaCekanja_Korisnik_FrizerId",
                        column: x => x.FrizerId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ListaCekanja_Korisnik_KlijentId",
                        column: x => x.KlijentId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ListaCekanja_Usluga_UslugaId",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "NotifikacijaListeCekanja",
                columns: table => new
                {
                    NotifikacijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ListaCekanjaId = table.Column<int>(type: "int", nullable: false),
                    TerminId = table.Column<int>(type: "int", nullable: false),
                    DatumNotifikacije = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    DatumIsteka = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Odgovoreno = table.Column<bool>(type: "bit", nullable: false),
                    Prihvaceno = table.Column<bool>(type: "bit", nullable: false),
                    PorukaNofitikacije = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotifikacijaListeCekanja", x => x.NotifikacijaId);
                    table.ForeignKey(
                        name: "FK_NotifikacijaListeCekanja_ListaCekanja_ListaCekanjaId",
                        column: x => x.ListaCekanjaId,
                        principalTable: "ListaCekanja",
                        principalColumn: "ListaCekanjaId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_NotifikacijaListeCekanja_Termin_TerminId",
                        column: x => x.TerminId,
                        principalTable: "Termin",
                        principalColumn: "TerminId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ListaCekanja_FrizerId",
                table: "ListaCekanja",
                column: "FrizerId");

            migrationBuilder.CreateIndex(
                name: "IX_ListaCekanja_KlijentId",
                table: "ListaCekanja",
                column: "KlijentId");

            migrationBuilder.CreateIndex(
                name: "IX_ListaCekanja_UslugaId",
                table: "ListaCekanja",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_NotifikacijaListeCekanja_ListaCekanjaId",
                table: "NotifikacijaListeCekanja",
                column: "ListaCekanjaId");

            migrationBuilder.CreateIndex(
                name: "IX_NotifikacijaListeCekanja_TerminId",
                table: "NotifikacijaListeCekanja",
                column: "TerminId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotifikacijaListeCekanja");

            migrationBuilder.DropTable(
                name: "ListaCekanja");
        }
    }
}
