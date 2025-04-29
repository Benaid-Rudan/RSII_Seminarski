public class NotificationUpsertDto
{
    public int? Id { get; set; }

    public string Title { get; set; } = null!;
    public string? Content { get; set; }
    public bool IsRead { get; set; } = false;

    public int UserId { get; set; }

}