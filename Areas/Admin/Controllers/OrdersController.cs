using _25DH110424_Lê_Trung_Kỳ_MyStore.Filters;
using _25DH110424_Lê_Trung_Kỳ_MyStore.Models;
using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;

namespace _25DH110424_Lê_Trung_Kỳ_MyStore.Areas.Admin.Controllers
{
    [AdminAuthorize]
    public class OrdersController : Controller
    {
        private MyStoreEntities db = new MyStoreEntities();

        public ActionResult Index(string status, string customerName,
    string paymentStatus,
    DateTime? orderDate)
        {
            var orders = db.Orders
                   .Include(o => o.Customer)
                   .AsQueryable();

            if (!string.IsNullOrWhiteSpace(customerName))
            {
                orders = orders.Where(o =>
                    o.Customer.CustomerName.Contains(customerName));
            }

            if (!string.IsNullOrWhiteSpace(paymentStatus))
            {
                orders = orders.Where(o =>
                    o.PaymentStatus == paymentStatus);
            }

            if (orderDate.HasValue)
            {
                DateTime start = orderDate.Value.Date;
                DateTime end = start.AddDays(1);

                orders = orders.Where(o =>
                    o.OrderDate >= start &&
                    o.OrderDate < end);
            }

            ViewBag.CustomerName = customerName;
            ViewBag.PaymentStatus = paymentStatus;
            ViewBag.OrderDate = orderDate?.ToString("yyyy-MM-dd");

            ViewBag.PaymentStatuses = db.Orders
                .Select(o => o.PaymentStatus)
                .Distinct()
                .ToList();

            
            if (!string.IsNullOrEmpty(status))
            {
                orders = orders.Where(o => o.OrderStatus == status);
            }
            ViewBag.Status = status;
            return View(orders.OrderByDescending(o => o.OrderDate).ToList());
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}