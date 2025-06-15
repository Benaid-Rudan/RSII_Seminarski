using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBarbershop.Services.Migrations
{
    /// <inheritdoc />
    public partial class editCascadeNarudzbaUplata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Uplata__Narudzba__5070F446",
                table: "Uplata");

            migrationBuilder.AddForeignKey(
                name: "FK__Uplata__Narudzba__5070F446",
                table: "Uplata",
                column: "NarudzbaId",
                principalTable: "Narudzba",
                principalColumn: "NarudzbaId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Uplata__Narudzba__5070F446",
                table: "Uplata");

            migrationBuilder.AddForeignKey(
                name: "FK__Uplata__Narudzba__5070F446",
                table: "Uplata",
                column: "NarudzbaId",
                principalTable: "Narudzba",
                principalColumn: "NarudzbaId");
        }
    }
}
