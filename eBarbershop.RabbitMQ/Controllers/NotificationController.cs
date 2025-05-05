using Microsoft.AspNetCore.Authorization;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using RabbitMQ.Client;
using Newtonsoft.Json;

namespace eBarbershop.RabbitMQ.Controllers;

[ApiController]
[Route("[controller]")]
public class NotificationController : ControllerBase
{
    private readonly string _hostname = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "127.0.0.1";
    private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
    private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
    private readonly string _virtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

    [Authorize]
    [HttpPost("SendNotification")]
    public Task<IActionResult> SendNotification(NotificationUpsertDto notification)
    {
        if (notification.Id != 0)
            return Task.FromResult<IActionResult>(BadRequest("Id must be 0"));

        if (notification.Title.Length == 0)
            return Task.FromResult<IActionResult>(BadRequest("Title is mandatory"));

        if (notification.UserId <= 0)
            return Task.FromResult<IActionResult>(BadRequest("UserId must be greater than 0"));

        var factory = new ConnectionFactory
        {
            HostName = _hostname,
            UserName = _username,
            Password = _password,
            VirtualHost = _virtualHost,
        };
        try
        {
            using var connection2 = factory.CreateConnection();
            Console.WriteLine("Connection successful");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to connect: {ex.Message}");
        }
        using var connection = factory.CreateConnection();

        using var channel = connection.CreateModel();

        channel.QueueDeclare(queue: "notification",
            durable: false,
            exclusive: false,
            autoDelete: true,
            arguments: null);


        var json = JsonConvert.SerializeObject(notification);

        var body = Encoding.UTF8.GetBytes(json);

        channel.BasicPublish(exchange: string.Empty,
            routingKey: "notification",

            body: body);

        return Task.FromResult<IActionResult>(Ok(notification));
    }
}
