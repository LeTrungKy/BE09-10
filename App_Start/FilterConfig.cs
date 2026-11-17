using System.Web;
using System.Web.Mvc;
using _25DH110424_Lê_Trung_Kỳ_MyStore.Filters;

namespace _25DH110424_Lê_Trung_Kỳ_MyStore
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new SessionSyncAttribute());
        }
    }
}
