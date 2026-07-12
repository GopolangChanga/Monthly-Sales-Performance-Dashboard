/* ============================================================
   Query: Top 10 Customers by Monthly Sales
   Purpose: Identify the top 10 customers by total sales 
            for a given reporting month (June 2014), using 
            a proportional allocation of TotalDue based on 
            each line item's share of the order's total 
            LineTotal. Results validated against the Power BI 
            Top 10 Customers table visual.
   Source: AdventureWorks_Presentation
   Output: Top 10 customers ranked by monthly sales (desc),
           with sales formatted as $M, $K or $ depending 
           on magnitude
   ============================================================ */

/* --------------------------------------------------------
   CTE 1: cte_sales
   Purpose: Calculate each customer's daily proportional 
            sales allocation at the line item level
            
   Logic: TotalDue (order level) is allocated to each 
          line item based on that line's share of the 
          order's total LineTotal. This avoids 
          double-counting TotalDue across multiple 
          line items on the same order.
          
   Proportional allocation formula:
   TotalDue × (LineTotal ÷ Sum of LineTotal per Order)
-------------------------------------------------------- */
WITH cte_sales AS (
    SELECT
         [Date]
        ,FullName
        ,ROUND(
            SUM([TotalDue] * ([LineTotal] / LTperOrder))
         , 3)                                AS "TotalDuePerProduct_Raw"
    FROM 
    (
        SELECT 
            [OrderQty]
           ,[BaseProductName]
           ,CAST([OrderDate] AS DATE)        AS [Date]      -- Strip time component from OrderDate
           ,FullName 
           ,[PurchaseOrderNumber]
           ,[ListPrice]
           ,[TotalDue]
           ,[LineTotal]
           -- Window function: sum LineTotal across all line items
           -- within the same order — used as the denominator
           -- for the proportional allocation above
           ,SUM([LineTotal]) OVER (
                PARTITION BY [SalesOID]
            )                                AS LTperOrder

        FROM [AdventureWorks_Presentation].[dbo].[SalesOrderDetail_Fact] AS SOD_F

        -- Join order header to get TotalDue, OrderDate, CustomerID
        -- SalesOrderID aliased as SalesOID for use in PARTITION BY
        LEFT JOIN (
            SELECT *, [SalesOrderID] AS [SalesOID] 
            FROM [AdventureWorks_Presentation].[dbo].[SalesOrderHeader_Fact]
        ) AS SOH_F 
            ON SOD_F.[SalesOrderID] = SOH_F.[SalesOrderID]

        -- Join product dimension to bring in BaseProductName, ListPrice
        LEFT JOIN (
            SELECT * 
            FROM [AdventureWorks_Presentation].[dbo].[Product_Dim]
        ) AS Prod_D 
            ON SOD_F.[ProductID] = Prod_D.[ProductID]

        -- Join customer dimension to bring in FullName
        -- FullName is constructed by concatenating FirstName and LastName
        LEFT JOIN (
            SELECT *, FirstName + ' ' + LastName AS FullName 
            FROM [AdventureWorks_Presentation].[dbo].[CustomerDetail_Dim]
        ) AS Cust_D 
            ON SOH_F.[CustomerID] = Cust_D.[CustomerID]

    ) AS A

    -- Aggregate to one row per customer per day
    GROUP BY [Date], FullName
),

/* --------------------------------------------------------
   CTE 2: cte_monthly_totals
   Purpose: Roll up daily customer sales into a single 
            monthly total per customer, keeping the result 
            as a raw numeric type so it can be safely used 
            for ORDER BY in the final SELECT.
            
   Note: Filtering to EOMONTH = '2014-06-30' isolates 
         the June 2014 reporting month. Update this value 
         to validate a different reporting month.
         
   Why EOMONTH? Grouping by EOMONTH([Date]) ensures all 
   days within June 2014 roll up to one row per customer 
   regardless of which specific days had transactions.
-------------------------------------------------------- */
cte_monthly_totals AS (
    SELECT 
         EOMONTH([Date])                     AS Monthend
        ,FullName
        -- Sum daily product totals into a raw numeric monthly total
        -- Kept as numeric here so ORDER BY works correctly
        -- Formatting applied in the final SELECT only
        ,SUM("TotalDuePerProduct_Raw")       AS MonthlyTotal_Numeric
    FROM cte_sales
    -- Filter to the June 2014 reporting month
    WHERE EOMONTH([Date]) = '2014-06-30'
    GROUP BY EOMONTH([Date]), FullName
)

/* --------------------------------------------------------
   Final SELECT: Top 10 customers for the reporting month
   
   Ordering: By MonthlyTotal_Numeric DESC (raw numeric) 
             to ensure correct ranking — not by the 
             formatted string which would sort alphabetically
             
   Tiebreaker: FullName ASC for consistent ordering when 
               two customers have equal sales

   Formatting logic:
   - Millions : value ÷ 1,000,000 → rounded up → displayed as $X.XXM
   - Thousands: value ÷ 1,000     → rounded up → displayed as $X.XXK
   - Below $1K: ceiling applied   → displayed as $X
   
   CEILING used instead of ROUND to always round up —
   avoids understating sales figures in the display
-------------------------------------------------------- */
SELECT TOP 10
     Monthend
    ,FullName
    ,CASE 
        -- Millions
        WHEN ABS(MonthlyTotal_Numeric) >= 1000000 
            THEN '$' + FORMAT(
                    CEILING((MonthlyTotal_Numeric / 1000000.0) * 100) / 100.0
                 , '#,##0.00') + 'M'
        -- Thousands
        WHEN ABS(MonthlyTotal_Numeric) >= 1000 
            THEN '$' + FORMAT(
                    CEILING((MonthlyTotal_Numeric / 1000.0) * 100) / 100.0
                 , '#,##0.00') + 'K'
        -- Hundreds and below
        ELSE '$' + FORMAT(
                CEILING(MonthlyTotal_Numeric)
             , '#,##0')
     END                                     AS "TotalDuePerProduct"

FROM cte_monthly_totals

-- Order by raw numeric to ensure correct ranking
-- Formatted string ordering would be alphabetical not numerical
ORDER BY MonthlyTotal_Numeric DESC, FullName ASC
;
