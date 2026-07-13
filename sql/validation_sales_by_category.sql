/* Query: Product Matrix Validation
   Purpose: Validate sales by Product Category, Subcategory 
            and Product for the current month (June 2014) 
            and prior month (May 2014), cross-checked against 
            the Power BI Product Performance Matrix visual
   Source: AdventureWorks_Presentation
   Output: One row per Category showing current and prior 
           month sales side by side
   ============================================================ */

/* --------------------------------------------------------
   CTE 1: cte_sales
   Purpose: Calculate daily proportional sales allocation 
            at the product level, including Category and 
            Subcategory hierarchy from Product_Dim_Wide
            
   Logic: TotalDue (order level) is allocated to each 
          line item based on that line's share of the 
          order's total LineTotal — avoids double counting 
          TotalDue across multiple line items on same order

   Note: Product_Dim_Wide used here — ProductCategory and 
         ProductSubCategory already flattened into one 
         table, no additional category joins needed
-------------------------------------------------------- */
WITH cte_sales AS (
    SELECT
         [Date]
        ,[ProductSubCategory]
        ,[ProductCategory]
        ,[BaseProductName]
        ,ROUND(
            SUM([TotalDue] * ([LineTotal] / LTperOrder))
         , 3)                                AS "TotalDuePerProduct_Raw"
    FROM 
    (
        SELECT 
             [OrderQty]
            ,Prod_D.[BaseProductName]
            ,Prod_D.[ProductSubCategory]
            ,Prod_D.[ProductCategory]
            ,CAST([OrderDate] AS DATE)       AS [Date]
            ,[PurchaseOrderNumber]
            ,Prod_D.[ListPrice]
            ,[TotalDue]
            ,[LineTotal]
            -- Window function: sum LineTotal across all 
            -- line items within the same order — used as 
            -- the denominator for proportional allocation
            ,SUM([LineTotal]) OVER (
                PARTITION BY [SalesOID]
             )                               AS LTperOrder

        FROM [AdventureWorks_Presentation].[dbo].[SalesOrderDetail_Fact] AS SOD_F

        -- Join order header to get TotalDue, OrderDate
        -- SalesOrderID aliased as SalesOID for PARTITION BY
        LEFT JOIN (
            SELECT *, [SalesOrderID] AS [SalesOID] 
            FROM [AdventureWorks_Presentation].[dbo].[SalesOrderHeader_Fact]
        ) AS SOH_F
            ON SOD_F.[SalesOrderID] = SOH_F.[SalesOrderID]

        -- Join Product_Dim_Wide — replaces previous joins to 
        -- Product_Dim, ProductSubcategory_Dim and 
        -- Productcategory_Dim since all attributes are now 
        -- available in one flattened table
        LEFT JOIN (
            SELECT * 
            FROM [AdventureWorks_Presentation].[dbo].[Product_Dim_Wide]
        ) AS Prod_D
            ON SOD_F.[ProductID] = Prod_D.[ProductID]

    ) AS A

    -- Aggregate to one row per product per day
    -- Keeping both months here — filter applied in CTE 2
    GROUP BY [Date], [ProductSubCategory], [ProductCategory], [BaseProductName]
),

/* --------------------------------------------------------
   CTE 2: cte_monthly_totals
   Purpose: Roll up daily product sales into monthly totals 
            for both current (June 2014) and prior month 
            (May 2014) — keeping raw numeric for correct 
            ordering and pivoting in the final SELECT

   Note: Both months included here via IN clause so the 
         final SELECT can pivot them into side by side 
         columns using conditional aggregation
         
   Why keep numeric separate from formatted?
   Formatting a number converts it to a string — strings 
   sort alphabetically not numerically, which would break 
   ORDER BY. Raw numeric is kept here and formatting 
   applied in the final SELECT only
-------------------------------------------------------- */
cte_monthly_totals AS (
    SELECT 
         EOMONTH([Date])                     AS [MonthEnd]
        ,[ProductCategory]
        ,[ProductSubCategory]
        ,[BaseProductName]
        -- Raw numeric monthly total per product
        -- Kept as numeric for correct ORDER BY in final SELECT
        ,SUM("TotalDuePerProduct_Raw")       AS MonthlyTotal_Numeric
    FROM cte_sales
    -- Include both current and prior month for side by side 
    -- comparison in the final SELECT pivot
    WHERE EOMONTH([Date]) IN ('2014-06-30', '2014-05-31')
    GROUP BY 
         EOMONTH([Date])
        ,[ProductCategory]
        ,[ProductSubCategory]
        ,[BaseProductName]
)

/* --------------------------------------------------------
   Final SELECT: Pivot monthly totals into side by side 
                 columns per Product Category
                 
   Conditional aggregation used to pivot:
   - CurrMonthSales = June 2014 sales per category
   - PrevMonthSales = May 2014 sales per category

   Formatting logic applied here on the final values:
   - Millions : value ÷ 1,000,000 → rounded up → $X.XXM
   - Thousands: value ÷ 1,000     → rounded up → $X.XXK
   - Below $1K: ceiling applied   → displayed as $X

   CEILING used instead of ROUND to always round up —
   avoids understating sales figures in the display

   ORDER BY uses raw numeric CurrMonth total — not the 
   formatted string — to ensure correct ranking
-------------------------------------------------------- */
SELECT
     [ProductCategory]
    --,[ProductSubCategory] ,[BaseProductName]

    -- Current month sales (June 2014) — formatted for display
    ,CASE
        WHEN ABS(MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
                     THEN MonthlyTotal_Numeric END)) >= 1000000
            THEN '$' + FORMAT(
                    CEILING(MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
                                THEN MonthlyTotal_Numeric END) 
                            / 1000000.0 * 100) / 100.0
                 , '#,##0.00') + 'M'
        WHEN ABS(MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
                     THEN MonthlyTotal_Numeric END)) >= 1000
            THEN '$' + FORMAT(
                    CEILING(MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
                                THEN MonthlyTotal_Numeric END) 
                            / 1000.0 * 100) / 100.0
                 , '#,##0.00') + 'K'
        ELSE '$' + FORMAT(
                CEILING(MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
                            THEN MonthlyTotal_Numeric END))
             , '#,##0')
     END                                     AS [CurrMonthSales]

    -- Prior month sales (May 2014) — formatted for display
    ,CASE
        WHEN ABS(MAX(CASE WHEN [MonthEnd] = '2014-05-31' 
                     THEN MonthlyTotal_Numeric END)) >= 1000000
            THEN '$' + FORMAT(
                    CEILING(MAX(CASE WHEN [MonthEnd] = '2014-05-31' 
                                THEN MonthlyTotal_Numeric END) 
                            / 1000000.0 * 100) / 100.0
                 , '#,##0.00') + 'M'
        WHEN ABS(MAX(CASE WHEN [MonthEnd] = '2014-05-31' 
                     THEN MonthlyTotal_Numeric END)) >= 1000
            THEN '$' + FORMAT(
                    CEILING(MAX(CASE WHEN [MonthEnd] = '2014-05-31' 
                                THEN MonthlyTotal_Numeric END) 
                            / 1000.0 * 100) / 100.0
                 , '#,##0.00') + 'K'
        ELSE '$' + FORMAT(
                CEILING(MAX(CASE WHEN [MonthEnd] = '2014-05-31' 
                            THEN MonthlyTotal_Numeric END))
             , '#,##0')
     END                                     AS [PrevMonthSales]

    -- Raw numeric current month for correct ORDER BY
    -- Not displayed — used for sorting only
    ,MAX(CASE WHEN [MonthEnd] = '2014-06-30' 
         THEN MonthlyTotal_Numeric END)      AS [CurrMonth_SortKey]

FROM cte_monthly_totals

GROUP BY [ProductCategory] --, [ProductSubCategory], [BaseProductName]

-- Order by raw numeric current month sales —
-- formatted string would sort alphabetically not numerically
ORDER BY [CurrMonth_SortKey] DESC
;
