using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBarbershop.Services.Migrations
{
    /// <inheritdoc />
    public partial class rezervacijaupdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Rezervaci__Koris__3F466844",
                table: "Rezervacija");

            migrationBuilder.AddColumn<int>(
                name: "KlijentId",
                table: "Termin",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "KlijentId",
                table: "Rezervacija",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_KlijentId",
                table: "Rezervacija",
                column: "KlijentId");

            migrationBuilder.AddForeignKey(
                name: "FK__Rezervaci__Klijen__NOVI_CONSTRAINT",
                table: "Rezervacija",
                column: "KlijentId",
                principalTable: "Korisnik",
                principalColumn: "KorisnikId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK__Rezervaci__Koris__3F466844",
                table: "Rezervacija",
                column: "KorisnikId",
                principalTable: "Korisnik",
                principalColumn: "KorisnikId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Rezervaci__Klijen__NOVI_CONSTRAINT",
                table: "Rezervacija");

            migrationBuilder.DropForeignKey(
                name: "FK__Rezervaci__Koris__3F466844",
                table: "Rezervacija");

            migrationBuilder.DropIndex(
                name: "IX_Rezervacija_KlijentId",
                table: "Rezervacija");

            migrationBuilder.DropColumn(
                name: "KlijentId",
                table: "Termin");

            migrationBuilder.DropColumn(
                name: "KlijentId",
                table: "Rezervacija");

            migrationBuilder.AddForeignKey(
                name: "FK__Rezervaci__Koris__3F466844",
                table: "Rezervacija",
                column: "KorisnikId",
                principalTable: "Korisnik",
                principalColumn: "KorisnikId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
