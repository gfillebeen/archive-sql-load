--Delinquency codes:
--0 = 0-29 days; 11 = 30–59 days; 2 = 60–89; 3 = 90-119; 4 = 120-179; etc
--X = unknown

WITH vp AS 
(
	SELECT LOAN_IDENTIFIER, CURRENT_ACTUAL_UPB, LOAN_AGE,
	CASE WHEN (FORECLOSURE_DATE IS NOT NULL AND NET_SALE_PROCEEDS IS NOT NULL)
		THEN
		CURRENT_ACTUAL_UPB
		+(FORECLOSURE_COSTS+ISNULL(PROPERTY_PRESERVATION_AND_REPAIR_COSTS,0)+ISNULL(ASSET_RECOVERY_COSTS,0)+ISNULL(MISCELLANEOUS_HOLDING_EXPENSES_AND_CREDITS,0)+ISNULL(ASSOCIATED_TAXES_FOR_HOLDING_PROPERTY,0))
		-(NET_SALE_PROCEEDS+ISNULL(CREDIT_ENHANCEMENT_PROCEEDS,0)+ISNULL(REPURCHASE_MAKE_WHOLE_PROCEEDS,0)+ISNULL(OTHER_FORECLOSURE_PROCEEDS,0))
	END AS Liquidated_loss,
	CASE WHEN (FORECLOSURE_DATE IS NOT NULL AND NET_SALE_PROCEEDS IS NOT NULL)
		THEN
		CURRENT_ACTUAL_UPB
	END AS Liquidated_Balance,
	RANK() OVER (PARTITION BY LOAN_IDENTIFIER ORDER BY MONTHLY_REPORTING_PERIOD DESC) r,
	CASE WHEN (FORECLOSURE_DATE IS NOT NULL AND NET_SALE_PROCEEDS IS NOT NULL) THEN 1 ELSE 0 END AS IsLiquidated,
	1 AS IsDefaulted
	FROM dbo.View_Performance
	--FROM dbo.Performance_2017Q3
	WHERE (CURRENT_LOAN_DELINQUENCY_STATUS NOT IN ('X','0','1','2')) OR (FORECLOSURE_DATE IS NOT NULL)
)

SELECT PROPERTY_STATE AS 'State', CONVERT(INT,SUBSTRING(ORIGINATION_DATE,4,4)) AS 'Origination_Year', COUNT(*) AS 'Total_Loans',
SUM(CASE WHEN IsDefaulted=1
		THEN ORIGINAL_UPB / LOAN_AGE
	END)/SUM(ORIGINAL_UPB) AS DefaultRate,
AVG(CASE WHEN Isliquidated=1 AND Liquidated_Loss > 0
	THEN
	Liquidated_Loss/Liquidated_Balance
	END) AS LGD
FROM
(
	SELECT PROPERTY_STATE, ORIGINATION_DATE, ORIGINAL_UPB, vp2.* FROM dbo.View_Acquisition va	
	--SELECT PROPERTY_STATE, ORIGINATION_DATE, ORIGINAL_UPB, vp2.* FROM dbo.View_Acquisition va	
	LEFT JOIN 
	(
		SELECT * FROM vp WHERE r =1	
	) vp2
	ON va.LOAN_IDENTIFIER = vp2.LOAN_IDENTIFIER	
) t
GROUP BY PROPERTY_STATE, CONVERT(int,SUBSTRING(ORIGINATION_DATE,4,4))
ORDER BY PROPERTY_STATE ASC, 'Origination_Year' ASC


