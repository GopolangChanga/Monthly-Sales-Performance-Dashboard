/*
============================================================
    VALIDATION QUERY — Monthly Sale Trend
============================================================
    Purpose  : Validates the Monthly Sale Trend visual in 
               Power BI by aggregating total sales per month
               and formatting the output for readability.

    Logic    : Sales are weighted by each product's share  
               of the order line total (LineTotal / LTperOrder)
               to allocate the order's TotalDue proportionally
               per product line.

    Output   : One row per month end date with formatted
               sales value (e.g. $1.2M, $450.5K, $999)

    Author   : 
    Date     : 
    Database : AdventureWorks_Presentation
============================================================
*/

WITH cte_sales AS (
    /*
    --------------------------------------------------------
        STEP 1 — Product Level Sales Allocation
    --------------------------------------------------------
        - Joins Sales Order Detail, Header and Product tables
        - Calculates each product line's proportional share 
          of the order's TotalDue using:
          TotalDue × (LineTotal / SUM(LineTotal) per Order)
        - Result is rounded to 3 decimal places
    --------------------------------------------------------
    */
    SELECT
         [Date]
        ,ROUND(SUM([TotalDue] * ([LineTotal] / LTperOrder)), 3) AS TotalDuePerProduct
    FROM (
        SELECT 
             [OrderQty]
            ,[BaseProductName]
            ,CAST([OrderDate] AS DATE)                              AS [Date]
            ,[PurchaseOrderNumber]
            ,[ListPrice]
            ,[TotalDue]
            ,[LineTotal]
            -- Total line amount per order used as the denominator
            ,SUM([LineTotal]) OVER (PARTITION BY [SalesOID])        AS LTperOrder
        FROM [AdventureWorks_Presentation].[dbo].[SalesOrderDetail_Fact]    AS SOD_F

        -- Bring in order header for TotalDue and order metadata
        LEFT JOIN (
            SELECT *, [SalesOrderID] AS [SalesOID] 
            FROM [AdventureWorks_Presentation].[dbo].[SalesOrderHeader_Fact]
        ) AS SOH_F
            ON SOD_F.[SalesOrderID] = SOH_F.[SalesOrderID]

        -- Bring in product details
        LEFT JOIN (
            SELECT * 
            FROM [AdventureWorks_Presentation].[dbo].[Product_Dim]
        ) AS Prod_D
            ON SOD_F.[ProductID] = Prod_D.[ProductID]
    ) AS A
    -- Optional date filter for spot checking a specific month
    -- WHERE [Date] >= '2014-06-01' AND [Date] <= '2014-06-30'
    GROUP BY [Date]
)

/*
--------------------------------------------------------
    STEP 2 — Monthly Aggregation & Formatting
--------------------------------------------------------
    - Groups daily sales up to month end level
    - Formats the total using dynamic scaling:
        >= 1,000,000  → $X.XXM  (Millions)
        >= 1,000      → $X.XXK  (Thousands)
        < 1,000       → $X,XXX  (Hundreds and below)
    - CEILING() rounds up to nearest whole dollar
      before scaling to avoid underreporting
--------------------------------------------------------
*/
SELECT 
     EOMONTH([Date])                                                AS MonthEnd

    ,CASE 
        -- Millions
        WHEN ABS(CEILING(SUM(CAST(TotalDuePerProduct AS INT)))) >= 1000000
            THEN '$' + FORMAT(CEILING(SUM(CAST(TotalDuePerProduct AS INT))) / 1000000.0, '#,##0.00') + 'M'
        
        -- Thousands
        WHEN ABS(CEILING(SUM(CAST(TotalDuePerProduct AS INT)))) >= 1000
            THEN '$' + FORMAT(CEILING(SUM(CAST(TotalDuePerProduct AS INT))) / 1000.0, '#,##0.00') + 'K'
        
        -- Hundreds and below
        ELSE '$' + FORMAT(CEILING(SUM(CAST(TotalDuePerProduct AS INT))), '#,##0')
     END                                                            AS TotalDuePerProduct

FROM cte_sales
GROUP BY EOMONTH([Date])
ORDER BY MonthEnd DESC
