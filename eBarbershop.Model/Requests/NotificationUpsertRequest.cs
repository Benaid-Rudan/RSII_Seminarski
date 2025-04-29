using System.ComponentModel.DataAnnotations;

namespace eBarbershop.Model.Requests;

public class NotificationUpsertRequest
{
    [Required(ErrorMessage = "Name is required", AllowEmptyStrings = false)]
    [MaxLength(32, ErrorMessage = "Name cannot exceed 255 characters")]
    public string Name { get; set; } = null!;
    
    [Required(ErrorMessage = "Description is required", AllowEmptyStrings = false)]
    [MaxLength(256, ErrorMessage = "Description cannot exceed 255 characters")]
    public string Description { get; set; } = null!;
    
    [Required(ErrorMessage = "Date of creation is required")]
    [DataType(DataType.Date)]
    public DateTime CreatedAt { get; set; } 
    
    [Required(ErrorMessage = "IsActive is required")]
    public bool IsActive { get; set; }
    
    public int UserId { get; set; }
}