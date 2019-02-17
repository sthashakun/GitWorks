using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ExchangeRate
{
    public class BAL
    {

        public string GetRates()
        {
            string jstring = "";
            ExchangeRateDTO RateDto = new ExchangeRateDTO()
            {
                Data = new List<MIRSMap>(),
                Result = new Result()
            };

            try
            {
                DAL objDAL = new DAL();

                List<SqlDTO> lstRates = objDAL.GetRateRecords();
                List<MIRSMap> lstMirsMap = new List<MIRSMap>();

                objDAL.GetBranchCodes().ForEach(x => { lstMirsMap.Add(GetMirsMapRecord(lstRates, x)); });
             
                if (lstMirsMap != null && lstMirsMap.Any())
                {
                    RateDto.Data.AddRange(lstMirsMap);
                    RateDto.Result.Success = true;
                    RateDto.Result.Message = "Rates Found.";
                    RateDto.Result.Code = "00";                  
                }
                else
                {
                    RateDto.Result.Success = false;
                    RateDto.Result.Message = "Couldn't Fetch Rate. Contact Administrator.";
                    RateDto.Result.Code = "01";
                }
                
                Logger.LogInfo( string.Format("{0} {1}", "", RateDto.Result.Message));
                jstring = JsonConvert.SerializeObject(RateDto);

            }
            catch (Exception ex)
            {
                RateDto.Data = null;
                RateDto.Result.Success = false;
                RateDto.Result.Code = "99";
                RateDto.Result.Message = "Server Error. Contact Administrator.";
                Logger.LogError(ex.ToString());
                jstring = JsonConvert.SerializeObject(RateDto);
            }
            return jstring;
        }

        private MIRSMap GetMirsMapRecord(List<SqlDTO> lstRates, string branchCd)
        {
            MIRSMap map = new MIRSMap() { Rates = new List<RateRecord>() };

            lstRates.Where(x => x.sub_agent_cd == branchCd).ToList().ForEach(y =>
                {
                    map.BranchCode = y.sub_agent_cd;
                    map.BranchName = y.sub_agent_name;
                    map.Rates.Add(new RateRecord()
                    {
                        Country = y.country,
                        CurrencyCd = y.crncy_cd,
                        CurrencyName = y.crncy_name,
                        FlagName = y.flagName,
                        ModifiedDate = y.created_on,
                        Rate = y.counterRate,
                        Unit = y.unit
                    });
                });

            return map;
        }

    }
}