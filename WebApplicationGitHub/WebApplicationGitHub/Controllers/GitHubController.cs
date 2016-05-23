using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApplicationGitHub.Controllers
{
    public class GitHubController : Controller
    {
        // GET: GitHub
        public ActionResult Index()
        {
            // Alteracao 1
            // Alteracao 2
            return View();
        }

        // GET: GitHub/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: GitHub/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: GitHub/Create
        [HttpPost]
        public ActionResult Create(FormCollection collection)
        {
            try
            {
                // TODO: Add insert logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: GitHub/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: GitHub/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add update logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: GitHub/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: GitHub/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add delete logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}
