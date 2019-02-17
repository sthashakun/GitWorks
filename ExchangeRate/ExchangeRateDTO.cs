using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

namespace ExchangeRate
{
    [DataContract]
    public class ExchangeRateDTO
    {
        [DataMember]
        public Result Result { get; set; }

        [DataMember]
        public List<MIRSMap> Data { get; set; }

    }

    [DataContract]
    public class MIRSMap
    {
        [DataMember]
        public string BranchName { get; set; }

        [DataMember]
        public string BranchCode { get; set; }

        [DataMember]
        public List<RateRecord> Rates { get; set; }
    }

    [DataContract]
    public class RateRecord
    {
        [DataMember]
        public string Country { get; set; }

        [DataMember]
        public string Rate { get; set; }

        [DataMember]
        public string Unit { get; set; }

        [DataMember]
        public string CurrencyCd { get; set; }

        [DataMember]
        public string CurrencyName { get; set; }       

        [DataMember]
        public string FlagName { get; set; }

        [DataMember]
        public string ModifiedDate { get; set; }

    }

    [DataContract]
    public class Result
    {
        [DataMember]
        [DefaultValue(false)]
        public bool Success { get; set; }

        [DataMember]
        public string Code { get; set; }

        [DataMember]
        public string Message { get; set; }
      
    }

    public class SqlDTO
    {
        public string sub_agent_cd { get; set; }
        public string sub_agent_name { get; set; }
        public string country { get; set; }
        public string flagName { get; set; }
        public string crncy_cd { get; set; }
        public string crncy_name { get; set; }
        public string unit { get; set; }
        public string counterRate { get; set; }
        public string created_on { get; set; }
    }

}