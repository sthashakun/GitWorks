CREATE PROC [dbo].p_get_Rate_ForApi_Dashboardv2  
AS  
BEGIN  
  
SET NOCOUNT OFF   
--------------------------------------------  
--@modified on: May 3, 2015  
--Rework the proc to get counter rate for Rate Dashboard API  
--Added fields curreny name and created_on  
--@modified on Oct 11, 2015
--Rework the proc to get Counter rate for all Branches
--@modified On JAN 04, 2015 @sthashakun
--Rework proc for countrywise changes
--EXEC [p_get_Rate_ForApi_Dashboardv2]
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
 
  --;WITH CTE_RATEBOARD(sub_agent_cd,  parent_agent_cd,  counterRate,  crncy_cd,country,  created_on,row_rank)
--AS
--( 
--SELECT sd.sub_agent_cd, final.parent_agent_cd, final.counterRate, final.crncy_cd,final.country, final.created_on ,RANK() OVER(partition by final.forex_tag_no, final.crncy_cd order by final.created_on DESC) as row_rank 
--   FROM (  
--         SELECT  a.parent_agent_cd,(CFP.pExRate/CFC.cExRate) AS 'counterRate',CFP.pCrncy AS 'crncy_cd',cntry.cntry_name as 'country',CFC.forex_tag_no, CFC.created_on   
--            -- RANK() OVER(partition by CFC.forex_tag_no order by CFC.created_on DESC) as row_num  
--         FROM  dbo.parent_agent a, 
--		 (   
--          SELECT FP.pExRate,FP.PayingAgentCd, FP.CollectingAgentCd,FP.pCrncy   
--          FROM (
--			   SELECT p.collecting_agent_cd AS CollectingAgentCd,p.ex_rate AS pExRate, p.agent_rate AS pAgRate,p.parent_agent_cd AS PayingAgentCd,  
--			   p.to_crncy_cd AS pCrncy,ROW_NUMBER() OVER(partition BY p.parent_agent_cd ORDER BY p.created_on DESC) AS Row  
--			   FROM dbo.forex_pay p WHERE  p.collecting_agent_cd = 'MY0001') FP  WHERE FP.Row = 1  
--               ) CFP,
--              (  
--				SELECT FC.cExRate,FC.forex_tag_no,FC.parent_agent_cd AS CollectingAgentCd, FC.paying_agent_cd AS PayingAgentCd, FC.created_on  
--				FROM (  
--					SELECT c.ex_rate AS cExRate, c.forex_tag_no,c.parent_agent_cd,c.paying_agent_cd, c.created_on,  
--					ROW_NUMBER() OVER(partition BY c.forex_tag_no, c.paying_agent_cd ORDER BY c.created_on DESC) AS Row  
--					FROM dbo.forex_coll c WHERE c.parent_agent_cd = 'MY0001' and to_crncy_cd = 'MYR'  and c.forex_tag_no IN (
--					 SELECT forex_tag_no FROM sub_agent_tag_dtl where parent_agent_cd='MY0001' 	
--					 AND sub_AGENT_TAG_NO IN (
--							   SELECT t.tag_no FROM tag_mst t 
--							   INNER JOIN (SELECT tag_no FROM sub_agent WHERE parent_agent_cd='MY0001' AND sub_agent_status = 'A' AND del_flag = 'N' 
--								GROUP BY tag_no) s ON t.tag_no = s.tag_no WHERE t.is_msb_agent='N' AND t.parent_agent_cd='MY0001' AND t.del_flag='N' ))
--											 ) FC WHERE FC.Row = 1  
--					 )CFC,dbo.country cntry      
--				  WHERE CFP.PayingAgentCd= CFC.PayingAgentCd AND CFP.CollectingAgentCd= CFC.CollectingAgentCd
--				  AND CFC.PayingAgentCd= a.parent_agent_cd AND    cntry.cntry_cd = a.cntry_cd  ) final    
--				  INNER JOIN sub_agent_tag_dtl sd on sd.forex_tag_no= final.forex_tag_no   
--	  )
--	  SELECT CTE_R.sub_agent_cd, s.sub_agent_name, CTE_R.parent_agent_cd,  CTE_R.counterRate, temp.country, temp.flagName,curr.crncy_name, CTE_R.crncy_cd, temp.unit, CTE_R.created_on
--	  FROM CTE_RATEBOARD CTE_R
--	  INNER JOIN @t temp on CTE_R.country= temp.country     	
--	  INNER JOIN currency curr on CTE_R.crncy_cd= curr.crncy_cd 
--	  INNER JOIN sub_agent s on s.sub_agent_cd= CTE_R.sub_agent_cd
--	  WHERE CTE_R.row_rank=1 
--	  ORDER BY  CTE_R.sub_agent_cd,CTE_R.parent_agent_cd
--	--  SELECT sub_agent_cd,  parent_agent_cd, country,flagName, Rate, crncy_name, crncy_cd, unit,  created_on
    

  ;WITH CTE_RATEBOARD( grp_cd, country, grp_name,crncy_cd, counterRate,agent_rate, sub_agent_cd,created_on,row_rank)
AS
( 
      SELECT     f1.grp_cd
			 ,c1.cntry_name [country]
			 ,pGrp.grp_name
			 ,f1.to_crncy_cd [crncy_cd]
			 ,f1.agent_rate 
			 ,f1.counter_rate [counterRate]
			 --,f1.col_agent_rate
			 --,f1.col_ex_rate
			 --,f1.pay_agent_rate
			 --,f1.pay_ex_rate
			 ,sAgent.sub_agent_cd
			-- ,f1.created_on
			 ,f1.modified_on [created_on]
			 ,ROW_NUMBER() OVER(partition BY  sub_agent_cd,  c1.cntry_name ORDER BY f1.modified_on DESC) AS row_rank
				FROM dbo.grp_forex f1
				INNER JOIN dbo.grp_paying_group pGrp ON f1.grp_cd = pGrp.grp_cd
				INNER JOIN dbo.country c1 ON pGrp.cntry_cd = c1.cntry_cd
				LEFT JOIN sub_agent_tag_dtl sAgent ON sAgent.forex_tag_no = f1.forex_tag_no
				WHERE f1.col_parent_agent_cd = 'MY0001'
				     AND sAgent.sub_agent_tag_no IN( SELECT t.tag_no FROM tag_mst t 
							   INNER JOIN (SELECT tag_no FROM sub_agent WHERE parent_agent_cd='MY0001' AND sub_agent_status = 'A' AND del_flag = 'N' 
								GROUP BY tag_no) s ON t.tag_no = s.tag_no WHERE t.is_msb_agent='N' AND t.parent_agent_cd='MY0001' AND t.del_flag='N' )
					AND f1.col_ex_rate > 0
					AND f1.pay_ex_rate > 0
					AND f1.col_agent_rate > 0
					AND f1.pay_agent_rate > 0
					
)      SELECT CTE_R.sub_agent_cd, s.sub_agent_name, CTE_R.grp_cd, CTE_R.grp_name,  CTE_R.counterRate, temp.country, temp.flagName,curr.crncy_name, CTE_R.crncy_cd, temp.unit, CTE_R.created_on
	  FROM CTE_RATEBOARD CTE_R
	  INNER JOIN @t temp on CTE_R.country= temp.country   
	  INNER JOIN sub_agent s on s.sub_agent_cd= CTE_R.sub_agent_cd
	  INNER JOIN currency curr on CTE_R.crncy_cd= curr.crncy_cd 
	  WHERE CTE_R.row_rank=1

  SET NOCOUNT ON      
  END 