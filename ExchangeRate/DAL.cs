using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Dapper;

namespace ExchangeRate
{
    public class DAL
    {

        private static string Constr { get { return ConfigurationManager.ConnectionStrings["eRemitronConnectionString"].ToString(); } }

        public List<SqlDTO> GetRateRecords()
        {
            List<SqlDTO> lstResults = new List<SqlDTO>();
            using (IDbConnection db = new SqlConnection(Constr))
            {
                lstResults = db.Query<SqlDTO>("[dbo].p_get_Rate_ForApi_Dashboardv2", commandType: CommandType.StoredProcedure).ToList();
            }

            return lstResults;
        }


        public List<string> GetBranchCodes()
        {
            List<string> lstResults = new List<string>();
            using (IDbConnection db = new SqlConnection(Constr))
            {
                string sql = " SELECT sub_agent_cd FROM sub_agent_tag_dtl WHERE parent_agent_cd='MY0001'  and del_flag='N'";
                sql += " AND sub_AGENT_TAG_NO IN( SELECT t.tag_no FROM tag_mst t ";
                sql += " INNER JOIN (SELECT tag_no FROM sub_agent WHERE parent_agent_cd='MY0001' AND sub_agent_status = 'A' AND del_flag = 'N' GROUP BY tag_no) s";
                sql += " ON t.tag_no = s.tag_no";
                sql += " WHERE t.is_msb_agent='N' AND t.parent_agent_cd='MY0001' AND t.del_flag='N' ) --";
                lstResults = db.Query<string>(sql, commandType: CommandType.Text).ToList();
            }

            return lstResults;
        }

        public static Result IsValidBranchCode(string branch)
        {

            Result result = new Result() { Success = false };
            List<MIRSMap> dto = new List<MIRSMap>();
            try
            {
                using (SqlConnection myConnection = new SqlConnection(Constr))
                {
                    myConnection.Open();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.CommandType = CommandType.Text;
                    oCmd.CommandText = "SELECT COUNT(*) FROM sub_agent WHERE parent_agent_cd='MY0001' and sub_agent_cd =@BranchCD and sub_agent_status='A'";
                    oCmd.Connection = myConnection;
                    oCmd.Parameters.Add("@BranchCD", SqlDbType.VarChar);
                    oCmd.Parameters["@BranchCD"].Value = branch;

                    var count = (Int32)oCmd.ExecuteScalar();
                    result.Success = count == 1 ? true : false;
                    result.Message = result.Success ? "" : "Invalid Branchcode";
                    result.Code = "02";
                }
            }
            catch (SqlException ex)
            {
                result.Code = "04";
                result.Message = ex.Message.ToString();
            }
            catch (Exception ex)
            {
                result.Code = "03";
                result.Message = ex.Message.ToString();
            }

            return result;
        }
    }
}