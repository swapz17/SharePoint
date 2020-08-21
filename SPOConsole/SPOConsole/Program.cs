using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint.Client;

namespace SPOConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            string URL = "";
            string username = ConfigurationManager.AppSettings.Get("username");
            string passtext = ConfigurationManager.AppSettings.Get("password");
            var password = new SecureString();
            foreach(var ch in passtext)
            {
                password.AppendChar(ch);
            }

            using (var context = new ClientContext(URL)) 
            {
                context.Credentials = new SharePointOnlineCredentials(username, password);
                Web web = context.Web;
                context.Load(web, w => w.Title);
                context.ExecuteQuery();
                Console.WriteLine(web.Title);
            }

            Console.ReadKey();
        }
    }
}
