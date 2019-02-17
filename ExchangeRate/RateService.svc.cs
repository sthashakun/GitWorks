using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace ExchangeRate
{
    /// <summary>
    /// @modified on Oct 11, 2015
    /// @modified by SthaShakun
    /// <remarks>
    /// -JSON response
    /// -provide counter rate of MY branches
    /// -add new dbAccess
    /// -add logger
    /// </remarks>
    /// </summary>
    public class RateService : IRateService
    {
        public string GetBranchRates()
        {
            return new BAL().GetRates();

        }

    }
}
