using Microsoft.AspNetCore.Mvc;
using ExpenseWiseApi.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IConfiguration _config;
    private readonly UserService _userService;

    public AuthController(IConfiguration config, UserService userService)
    {
        _config = config;
        _userService = userService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(UserDto userDto)
    {
        var existing = await _userService.GetByEmail(userDto.Email);
        if (existing != null)
            return BadRequest("User already exists");

        var user = new User
        {
            Username = userDto.Username,
            Email = userDto.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(userDto.Password)
        };

        await _userService.Create(user);
        return Ok("User registered");
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto login)
    {
        var user = await _userService.GetByEmail(login.Email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(login.Password, user.PasswordHash))
            return Unauthorized("Invalid credentials");

        var token = GenerateJwtToken(user);
        return Ok(new { token });
    }

    private string GenerateJwtToken(User user)
    {
        var key = Encoding.ASCII.GetBytes(_config["JwtSettings:Secret"]);
        var tokenHandler = new JwtSecurityTokenHandler();
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email)
            }),
            Expires = DateTime.UtcNow.AddDays(7),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}
