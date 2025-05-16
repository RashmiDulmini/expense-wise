using ExpenseWiseApi.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

public class UserService
{
    private readonly IMongoCollection<User> _users;

    public UserService(IConfiguration config)
    {
        var client = new MongoClient(config["MongoDB:ConnectionString"]);
        var database = client.GetDatabase(config["MongoDB:Database"]);
        _users = database.GetCollection<User>("Users");
    }

    public async Task<User> GetByEmail(string email) =>
        await _users.Find(u => u.Email == email).FirstOrDefaultAsync();

    public async Task Create(User user) =>
        await _users.InsertOneAsync(user);
}
