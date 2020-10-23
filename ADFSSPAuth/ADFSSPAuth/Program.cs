using Microsoft.SharePoint.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADFSSPAuth
{
    class Program
    {
        static void Main(string[] args)
        {
            string samlSite = "https://www.uat.com/";

            OfficeDevPnP.Core.AuthenticationManager am = new OfficeDevPnP.Core.AuthenticationManager();
            ClientContext ctx = am.GetADFSUserNameMixedAuthenticatedContext(samlSite, "username", "password", "domain", "adfs url", "adfs identifier");

            var oList = ctx.Web.Lists.GetByTitle("BusinessBytes");

            CamlQuery camlQuery = new CamlQuery();
            camlQuery.ViewXml = "<View><RowLimit>10</RowLimit></View>";

            ListItemCollection collListItem = oList.GetItems(camlQuery);

            ctx.Load(collListItem,
            items => items.Include(
            item => item.Id,
            item => item["BusinessByteTitle"],
            item => item.HasUniqueRoleAssignments));

            ctx.ExecuteQuery();

            foreach (var item in collListItem)
            {
                Console.WriteLine("{0} - {1}", item.Id, item["BusinessByteTitle"]);
            }
        }
    }
}
