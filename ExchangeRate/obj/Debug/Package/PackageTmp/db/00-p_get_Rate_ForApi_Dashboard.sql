
CREATE proc [dbo].p_get_Rate_ForApi_Dashboard
(
   @BranchCD varchar(10)
)
as
BEGIN

SET NOCOUNT ON 
--------------------------------------------
--@modified on: May 3, 2015
--Rework the proc to get counter rate for Rate Dashboard API
--Added fields curreny name and created_on
--exec [p_get_Rate_ForApi_Dashboard] 'MY0100001'
--------------------------------------------

            DECLARE @t table ( country varchar(20), cntry varchar(20), flagName varchar(30), unit varchar(5));

            INSERT INTO @t (country,cntry,flagName, unit) values('BANGLADESH' ,'Bangladesh' ,'Bangladesh.png','1'),
                                                                  ('CHINA' ,'China' ,'China.png','1'),
                                                                                            ('INDONESIA' ,'Indonesia' ,'Indonesia.png','1'),
                                                                                            ('INDIA' ,'India' ,'India.png','1'),
                                                                                            ('SRI LANKA' ,'Sri Lanka' ,'Sri Lanka.png','1'),
                                                                                            ('MYANMAR' ,'Myanmar' ,'Myanmar(Burma).png','1'),
                                                                                            ('NEPAL' ,'Nepal' ,'Nepal.png','1'),
                                                                                            ('PHILIPPINES' ,'Philippines' ,'Philippines.png','1'),
                                                                                            ('PAKISTAN' ,'Pakistan' ,'Pakistan.png','1'),
                                                                                            ('SINGAPORE' ,'Singapore' ,'Singapore.png','1'),
                                                                                            ('VIETNAM' ,'Vietnam' ,'Viet Nam.png','1');

; SELECT  temp.cntry as 'country', temp.flagName, final.Rate, curr.crncy_name, final.crncy_cd, temp.unit,  created_on
   FROM (
      SELECT  a.parent_agent_cd,(CFP.pExRate/CFC.cExRate) AS 'Rate',CFP.pCrncy AS 'crncy_cd',cntry.cntry_name as 'country', CFC.created_on,  
        ROW_NUMBER() OVER(partition by CFP.pCrncy order by CFC.created_on DESC) as row_num
          FROM  dbo.parent_agent a, ( 
   SELECT FP.pExRate,FP.PayingAgentCd, FP.CollectingAgentCd,FP.pCrncy 
  FROM (SELECT p.collecting_agent_cd AS CollectingAgentCd,p.ex_rate AS pExRate, p.agent_rate AS pAgRate,p.parent_agent_cd AS PayingAgentCd,
  p.to_crncy_cd AS pCrncy,ROW_NUMBER() OVER(partition BY p.parent_agent_cd ORDER BY p.created_on DESC) AS Row
   FROM dbo.forex_pay p WHERE  p.collecting_agent_cd = 'MY0001') FP    WHERE FP.Row = 1
   ) CFP, (
SELECT FC.cExRate,FC.forex_tag_no,FC.parent_agent_cd AS CollectingAgentCd, FC.paying_agent_cd AS PayingAgentCd, FC.created_on
FROM (
SELECT c.ex_rate AS cExRate, c.forex_tag_no,c.parent_agent_cd,c.paying_agent_cd, c.created_on,
ROW_NUMBER() OVER(partition BY c.forex_tag_no, c.paying_agent_cd ORDER BY c.created_on DESC) AS Row
  FROM dbo.forex_coll c WHERE c.parent_agent_cd = 'MY0001' and to_crncy_cd = 'MYR'
        and forex_tag_no =(SELECT TOP 1 forex_tag_no FROM dbo.sub_agent_tag_dtl WHERE parent_agent_cd ='MY0001' AND sub_agent_cd= @BranchCD order by created_on desc )
    ) FC WHERE FC.Row = 1
   ) CFC,dbo.country cntry    
      WHERE CFP.PayingAgentCd= CFC.PayingAgentCd and CFP.CollectingAgentCd= CFC.CollectingAgentCd and CFC.PayingAgentCd= a.parent_agent_cd AND
      cntry.cntry_cd = a.cntry_cd  ) final
        INNER JOIN @t temp on final.country= temp.country      
         INNER JOIN currency curr on final.crncy_cd= curr.crncy_cd WHERE final.row_num=1
        ORDER BY final.parent_agent_cd
   
  END
