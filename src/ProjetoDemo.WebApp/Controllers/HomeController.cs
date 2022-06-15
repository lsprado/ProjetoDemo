using Microsoft.AspNetCore.Mvc;
using ProjetoDemo.WebApp.Models;
using System.Diagnostics;

namespace ProjetoDemo.WebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> logger;

        public HomeController(ILogger<HomeController> logger)
        {
            this.logger = logger;
        }

        public IActionResult Index()
        {
            logger.LogInformation($"Method = {this.Request.Method} Path = {this.Request.Path}");
            return View();
        }

        public IActionResult Privacy()
        {
            logger.LogInformation($"Method = {this.Request.Method} Path = {this.Request.Path}");
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            logger.LogInformation($"Method = {this.Request.Method} Path = {this.Request.Path}");
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}