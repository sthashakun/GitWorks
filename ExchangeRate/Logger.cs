using log4net;
using log4net.Appender;
using log4net.Layout;
using log4net.Repository.Hierarchy;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ExchangeRate
{
    public class Logger
    {

        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);


        public Logger()
        {
            log4net.Config.BasicConfigurator.Configure();
        }

        public static void LogInfo(string msg)
        {
            getlogger();
            log.Info(msg);
        }

        public static void LogError(string msg)
        {
            getlogger();
            log.Error(msg);

        }

        public static void getlogger()
        {
            //
            // TODO: Add constructor logic here
            //
            Hierarchy hierarchy = (Hierarchy)LogManager.GetRepository();
            hierarchy.Root.RemoveAllAppenders(); /*Remove any other appenders*/

            RollingFileAppender fileAppender = new RollingFileAppender();
            fileAppender.AppendToFile = true;
            fileAppender.RollingStyle = RollingFileAppender.RollingMode.Date;
            fileAppender.MaximumFileSize = "10000KB";
            fileAppender.DatePattern = "dd-MM-yyyy'.txt'";
            fileAppender.CountDirection = -1;
            fileAppender.MaxSizeRollBackups = 0;
            fileAppender.StaticLogFileName = false;

            //fileAppender.LockingModel = new FileAppender.MinimalLock();
            fileAppender.File = @"logs\";
            PatternLayout pl = new PatternLayout();
            pl.ConversionPattern = "%date [%thread] %-5level %logger  - %message%newline";
            pl.ActivateOptions();
            fileAppender.Layout = pl;
            fileAppender.ActivateOptions();


            log4net.Config.BasicConfigurator.Configure(fileAppender);
        }

        public static string GetOrginalIPAddress( HttpRequest request)
        {
            string ip;
            try
            {
                ip = request.ServerVariables["HTTP_X_FORWARDED_FOR"];
                if (!string.IsNullOrEmpty(ip))
                {
                    if (ip.IndexOf(",") > 0)
                    {
                        string[] ipRange = ip.Split(',');
                        int le = ipRange.Length - 1;
                        ip = ipRange[le];
                    }
                }
                else
                {
                    ip = request.UserHostAddress;
                }
            }
            catch { ip = "0.0.0.0"; }

            return ip;
        }
    }
}