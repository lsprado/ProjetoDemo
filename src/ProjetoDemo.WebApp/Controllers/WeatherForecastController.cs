using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ProjetoDemo.WebApp.Models;
using System.Text.Json;

namespace ProjetoDemo.WebApp.Controllers
{
    public class WeatherForecastController : Controller
    {
        private readonly IHttpClientFactory httpClientFactory;
        private readonly ILogger<WeatherForecastController> logger;

        public WeatherForecastController(IHttpClientFactory httpClientFactory, ILogger<WeatherForecastController> logger)
        {
            this.httpClientFactory = httpClientFactory;
            this.logger = logger;
        }

        // GET: WeatherForecastController
        public async Task<ActionResult> Index()
        {
            try
            {
                logger.LogInformation($"Method = {this.Request.Method} Path = {this.Request.Path}");
                var client = httpClientFactory.CreateClient("ProjetoDemoApi");
                var response = await client.GetAsync("api/WeatherForecast");
                

                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    logger.LogDebug($"Result = {content}");

                    var options = new JsonSerializerOptions() { PropertyNameCaseInsensitive = true };
                    var result = JsonSerializer.Deserialize<IEnumerable<WeatherForecast>>(content, options);

                    return View(result);
                }
                else
                {
                    logger.LogError($"Error code = {response.StatusCode} Message = {response.RequestMessage}");
                    return Redirect("/Home/Error");
                }
            }
            catch (Exception ex)
            {
                logger.LogError(ex.ToString());
                return Redirect("/Home/Error");
            }
        }

        // GET: WeatherForecastController/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: WeatherForecastController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: WeatherForecastController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: WeatherForecastController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: WeatherForecastController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: WeatherForecastController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: WeatherForecastController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
