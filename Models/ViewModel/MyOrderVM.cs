using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace _25DH110424_Lê_Trung_Kỳ_MyStore.Models.ViewModel
{
    public class MyOrderVM
    {
        public string Tab { get; set; }

        public string SearchTerm { get; set; }

        public List<Order> Orders { get; set; }

        public Dictionary<string, int> StatusCounts { get; set; }

        public int TotalCount { get; set; }
    }
}
