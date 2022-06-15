var builder = WebApplication.CreateBuilder(args);

// add http client
builder.Services.AddHttpClient("ProjetoDemoApi", config =>
{
    config.BaseAddress = new Uri(builder.Configuration["Services:Url"]);
});

// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}

app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
