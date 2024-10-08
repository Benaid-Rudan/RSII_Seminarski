namespace eBarbershop.Model
{
    public class Drzava
    {
        public int DrzavaId { get; set; }
        public string Naziv { get; set; }

        // Veza sa gradovima
        public ICollection<Grad> Gradovi { get; set; }
    }

}
