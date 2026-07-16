# DAX Measures Documentation
## Monthly Sales Performance Dashboard — AdventureWorks

This document covers all DAX measures used in the Monthly Sales Performance Dashboard.
Measures follow a consistent naming convention: `[Metric] - [Context/Qualifier]`

> 💡 **Note:** Feel free to email with questions on any of the measures below.

---

## 📌 Table of Contents
1. [Dynamic Summary Card](#1-dynamic-summary-card)
2. [Month over Month Sales %](#2-month-over-month-sales-)
3. [Year over Year Sales %](#3-year-over-year-sales-)
4. [Current Month Sales](#4-current-month-sales)
5. [Current Month Orders](#5-current-month-orders)
6. [Average Order Value](#6-average-order-value)
7. [Current Month Customers](#7-current-month-customers)
8. [Total Sales Amount](#8-total-sales-amount)
9. [Gauge Visual Measures](#9-gauge-visual-measures)
10. [Product Matrix Visual](#10-product-matrix-visual)
11. [Top 10 Customers Visual](#11-top-10-customers-visual)
12. [Sales by Category Visual](#12-sales-by-category-visual)
13. [Sales by Territory Visual](#13-sales-by-territory-visual)
14. [Up Down Arrow Indicators](#14-up-down-arrow-indicators)

---

## 1. Dynamic Summary Card

The Dynamic Summary Card is an SVG-based HTML visual that auto-generates
a written performance summary sentence based on the selected reporting month.
It uses CSS classes for consistent colour styling across all dynamic text elements.

**Colour convention used in this visual:**
- `#9D8EC4` — dates and category names (muted purple)
- `#00f0ff` — numbers and percentages (cyan)

```dax
SVG_Paragraph = 
VAR MaxDate = FORMAT( [DynamicDate], "mmm yyyy") 

VAR CurrentValue = [DynamicSaleValue]
VAR CurrMonthSales =    SWITCH (
        TRUE (),
        // Special cases to force K and M in the sample report
        CurrentValue <= 1E3, Format( CurrentValue, "#,0.00" ),
        CurrentValue <= 1E6, Format( CurrentValue,"#,0,.0 K" ),
        CurrentValue <= 1E9, Format( CurrentValue,"#,0,,.0 M" ),
        CurrentValue <= 1E12, Format( CurrentValue,"#,0,,,.0 G" )
    )

VAR MoMCurrMIcon = FORMAT( [DynamicMoM%ChangeSalesIcon], "0.00%")
VAR PrevMonth = FORMAT( [DynamicDatePrevMonth], "mmm yyyy")
VAR CatergoryMaxSalesCurrMonth = [DynamicMaxMonthSalesCategory]
VAR MoMPrevYearIconHtml = FORMAT( [MoMPrevYear%ChangeSalesIcon], "0.00%")
VAR AboveBelowMoMText = [Above_Below_MoMText]
VAR AboveBelowMoMPrevYearText = [Above_Below_MoMPrevYearText]

RETURN

"data:image/svg+xml;utf8,
<svg viewBox='0 0 750 140' xmlns='http://w3.org'>
  <style>
    .paragraph-text {
      font-family: Arial, sans-serif;
      font-size: 16px;
      fill: #ffffff;
    }
    .date-highlight { 
      fill: #9D8EC4; 
      font-weight: bold; 
    }
    .num-highlight { 
      fill: #00f0ff; 
      font-weight: bold; 
    }
  </style>
  <rect width='100%' height='100%' fill='#24124A' rx='8' />
  
  <text x='40' y='50' class='paragraph-text'>
    <tspan x='40' dy='0'>Sales in <tspan class='date-highlight'>"& MaxDate &"</tspan> reached <tspan class='num-highlight'>
    "& CurrMonthSales &"</tspan>, which is <tspan class='num-highlight'>"& MoMCurrMIcon &"</tspan> "& AboveBelowMoMText &" <tspan class='date-highlight'>"& PrevMonth &"</tspan> and <tspan class='num-highlight'>"& MoMPrevYearIconHtml &"</tspan></tspan>
    <tspan x='40' dy='24'>"& AboveBelowMoMPrevYearText &" the same month last year.</tspan>
    <tspan x='40' dy='24'>Top performing category: <tspan class='date-highlight'>"& CatergoryMaxSalesCurrMonth &"</tspan>.</tspan>
  </text>

</svg>"
```

---

## 2. Month over Month Sales %

Calculates the percentage change in sales between the current
reporting month and the immediately preceding month.
A positive result means sales grew; negative means sales declined.

```dax
MoM%ChangeSales = 
Divide( ( [CurrMonthSales] - [PrevMonthSales] ), 
                        [PrevMonthSales], 0 
                   )
```

---

## 3. Year over Year Sales %

Calculates the percentage change in sales between the current
reporting month and the same month in the prior year.
Removes seasonal bias that MoM comparisons can introduce —
for example, comparing June 2014 to June 2013 rather than May 2014.

```dax
MoMPrevYear%ChangeSales = 
Divide( ( [CurrMonthSales] - [SameMonthLastYear] ), 
                        [SameMonthLastYear], 0 
      )
```

---

## 4. Current Month Sales

Total proportional sales for the current reporting month.
Uses `DATESMTD` to accumulate sales from the first day of the
selected month to the last visible date in context.
`COALESCE` ensures blanks return 0 rather than empty — 
prevents KPI cards from showing blank when no data exists.

```dax
CurrMonthSales = COALESCE( CALCULATE( [TotalDuePerProduct], DATESMTD((Date_Dim[Date]) )) , 0)
```

---

## 5. Current Month Orders

Total number of orders placed within the current reporting month.
Uses `DATESMTD` consistent with `CurrMonthSales` to ensure
the same date boundary is applied across both measures.

```dax
CurrMonthOrders = CALCULATE( [TotalOrders], DATESMTD((Date_Dim[Date]) ))
```

---

## 6. Average Order Value

Calculates the average revenue generated per order for the
current reporting month. Derived directly from validated
`CurrMonthSales` and `CurrMonthOrders` measures — no additional
filter context needed. `DIVIDE` with 0 as alternate result
prevents division by zero errors when no orders exist.

```dax
AvgPricePerUnitCurrMonth = Divide( [CurrMonthSales], [CurrMonthOrders], 0)
```

---

## 7. Current Month Customers

Total number of unique customers who placed at least one order
within the current reporting month. Uses `DATESMTD` consistent
with other current month measures.

```dax
CurrMonthCustomers = CALCULATE( [TotalCustomers], DATESMTD((Date_Dim[Date]) ))
```

---

## 8. Total Sales Amount

Base sales measure used to drive the 24-Month Trend line chart.
Calculates total sales by summing SubTotal, TaxAmt and Freight
from the order header — matching the TotalDue definition.
`COALESCE` applied to each component to handle NULLs gracefully
without dropping entire rows from the calculation.

```dax
TotalSalesAmount = 
SUMX('SalesOrderHeader_Fact', COALESCE([SubTotal], 0) + COALESCE([TaxAmt], 0) + COALESCE([Freight], 0)
)
```

**Power Query — Month-Year field**

Used as the X-axis label on the 24-Month Trend chart.
Formats dates as `Jun'14` style — short month name + 2-digit year.
Applied as a custom column in Power Query on the `Date_Dim` table.

```powerquery
= Table.AddColumn(#"Renamed Columns", "MonYear", 
    each Text.Start(Date.MonthName([Date]), 3) & "'" & 
    Text.End(Text.From(Date.Year([Date])), 2))
```

---

## 9. Gauge Visual Measures

The gauge shows current month sales against a dynamic target
and range — all derived from prior month sales so the gauge
adjusts automatically when the month slicer changes.

**Business Rules:**
| Measure | Formula | Meaning |
|---|---|---|
| Minimum | Prior Month × 50% | Lower bound — floor of expected performance |
| Target | Prior Month × 110% | Growth target — 10% above prior month |
| Maximum | Prior Month × 150% | Upper ceiling — exceptional performance |

---

### Minimum Value
Sets the lower boundary of the gauge needle range.

```dax
MinCurrMonthSalesGauge = [PrevMonthSales] * 0.50
```

---

### Maximum Value
Sets the upper boundary of the gauge needle range.

```dax
MaxMonthSalesGauge = [PrevMonthSales] * 1.50
```

---

### Target Value
Sets the target line on the gauge — 10% growth over prior month.

```dax
TargetCurrMonthSales = [PrevMonthSales] * 1.10
```

---

### Gauge Label
Displays current month sales vs the maximum sales value
in a formatted label below the gauge needle.
Uses a `SWITCH` pattern to intelligently format values
into K, M or G depending on magnitude.

```dax
Month_Gauge_Label = 

VAR _val = [CurrMonthSales]
VAR SalesFormatted = SWITCH (
        TRUE (),
        _val <= 1E3, FORMAT( _val, "#,0.00" ),
        _val <= 1E6, FORMAT( _val, "#,0,.0 K" ),
        _val <= 1E9, FORMAT( _val, "#,0,,.0 M" ),
        _val <= 1E12, FORMAT( _val, "#,0,,,.0 G" ),
        FORMAT( _val, "#,0.00" )
    )

VAR TargetSales = [PrevMonthSales] * 1.50
VAR TargetSalesFormatted = SWITCH (
        TRUE (),
        TargetSales <= 1E3, Format( TargetSales, "#,0.00" ),
        TargetSales <= 1E6, Format( TargetSales,"#,0,.0K" ),
        TargetSales <= 1E9, Format( TargetSales,"#,0,,.0M" ),
        TargetSales <= 1E12, Format( TargetSales,"#,0,,,.0G" ),
        FORMAT( _val, "#,0.00" )
    )

RETURN
SalesFormatted& " of " &TargetSalesFormatted& " target"
```

---

### Gauge Sub-Label
Displays whether current sales are above or below the maximum
target, with the formatted dollar difference.
Shows `~$X above target`, `~$X below target` or `On target`.

```dax
Month_Gauge_SubLabel = 

VAR _val = [CurrMonthSales]
VAR _max = [PrevMonthSales] * 1.50
VAR _diff = _val - _max
VAR _absDiff = ABS(_diff) 

VAR SalesFormatted = SWITCH (
        TRUE (),
        _absDiff <= 1E3, FORMAT( _absDiff, "#,0.00" ),
        _absDiff <= 1E6, FORMAT( _absDiff, "#,0,.0 K" ),
        _absDiff <= 1E9, FORMAT( _absDiff, "#,0,,.0 M" ),
        _absDiff <= 1E12, FORMAT( _absDiff, "#,0,,,.0 G" ),
        FORMAT( _diff, "#,0.00" )
    )

VAR TargetSales = [PrevMonthSales] * 1.10

RETURN
SWITCH(
    TRUE(),
    _diff > 0, "~"&SalesFormatted & " above target",
    _diff < 0, "~"&SalesFormatted & " below target",
    _diff = 0, "On target",
    "Undefined"
)
```

---

## 10. Product Matrix Visual

Calculates proportional sales at the line item level for use
in the Product Performance Matrix drill-down visual.
Allocates each order's TotalDue to individual line items based
on each line's share of the order's total LineTotal —
avoids double-counting TotalDue across multiple line items
on the same order.

Product Category and Month Name fields were added directly
to the matrix to enable the Category → Subcategory → Product
drill-down hierarchy.

```dax
TotalDuePerProduct = 
SUMX(
    'SalesOrderDetail_Fact',
    VAR CurrentLineTotal = 'SalesOrderDetail_Fact'[LineTotal]

    VAR OrderSubtotal = 
        CALCULATE(
            SUM('SalesOrderDetail_Fact'[LineTotal]),
            ALLEXCEPT('SalesOrderDetail_Fact', 'SalesOrderDetail_Fact'[SalesOrderID])
        )

    VAR OrderTotalDue = RELATED('SalesOrderHeader_Fact'[TotalDue])
    
    RETURN
        OrderTotalDue * DIVIDE(CurrentLineTotal, OrderSubtotal, 0)
)
```

---

## 11. Top 10 Customers Visual

### Customer Ranking
Ranks each customer by their current month sales in descending order.
`Skip` ranking means tied customers receive the same rank
and the next rank is skipped — e.g. two customers tied at rank 2
means no rank 3 is assigned.

```dax
RankCustomerBySale = 
    RANKX(
        All( CustomerDetail_Dim[FullName] ), 
            [CurrMonthSales],
                , 
                DESC, 
                Skip
        )
```

---

### SVG Progress Bar — % Share
Renders an inline SVG progress bar alongside each customer's
percentage share of total monthly sales.
Bar width scales proportionally to the highest % share customer —
the top customer always fills 80px width and all others scale accordingly.

```dax
Progress_barTop10Customers = 
VAR Pct = [CurrMCustomer%Share]
VAR MaxPct =
    MAXX(
        ALLSELECTED(CustomerDetail_Dim[FullName]),
        [CurrMCustomer%Share]
    )

VAR Width = DIVIDE(Pct, MaxPct) * 80

VAR PctText = FORMAT(Pct/100, "0.00%")

RETURN
"data:image/svg+xml;utf8," &
"<svg xmlns='http://www.w3.org/2000/svg' width='200' height='30'>
    <rect x='4' y='10' width='" & Width & "' height='10'
          rx='3' ry='3'
          fill='#C56AF7'/>
    <text x='" & (Width + 8) & "' y='26'
          font-family='Segoe UI'
          font-size='25'
          fill='#e879f9 '> "& PctText &
    "</text>
</svg>"
```

---

## 12. Sales by Category Visual

Renders a dual SVG progress bar for each product category —
one bar for current month sales (purple) and one for prior
month sales (amber). Bars scale proportionally to the highest
selling category so relative performance is visible at a glance.

**Colour convention:**
- `#8250C4` — Current month bar (purple)
- `#FFA500` — Prior month bar (amber)

> **Note:** `Productcategory_Dim` is used here as the category
> reference table. This will be updated to `Product_Dim_Wide`
> once the flattened dimension table is fully adopted.

```dax
CategoryProgressBar = 
VAR CategoryName = SELECTEDVALUE(Productcategory_Dim[ProductCategory], "Other")

VAR Pct1 = [CurrMonthSales]
VAR MaxPct1 = MAXX(ALLSELECTED(Productcategory_Dim[ProductCategory]), [CurrMonthSales])
VAR Width1 = MIN(380, ROUND(DIVIDE(Pct1, MaxPct1) * 380, 0))

VAR Pct2 = [PrevMonthSales]
VAR MaxPct2 = MAXX(ALLSELECTED(Productcategory_Dim[ProductCategory]), [PrevMonthSales])
VAR Width2 = MIN(380, ROUND(DIVIDE(Pct2, MaxPct2) * 380, 0))

VAR RectColor1 = "#8250C4"
VAR RectColor2 = "#FFA500"
VAR TrackColor = "#ffffff44"

VAR CurrLabel = "Current: $" & FORMAT([CurrMonthSales], "#,0")
VAR PrevLabel = "Prior: $" & FORMAT([PrevMonthSales], "#,0")

RETURN
"<div style='padding:10px; margin:0; display:inline-block;'>" &
"<svg width='400' height='170' viewBox='0 0 400 170' xmlns='http://www.w3.org/2000/svg'>" &

  "<text x='10' y='24' fill='#9D8EC4' font-family='sans-serif' font-size='20' font-weight='bold'>" & CategoryName & "</text>" &

  "<rect x='10' y='36' width='380' height='18' rx='4' fill='" & TrackColor & "'/>" &
  "<rect x='10' y='36' width='" & Width1 & "' height='18' rx='4' fill='" & RectColor1 & "'/>" &
  "<text x='10' y='76' fill='" & RectColor1 & "' font-family='sans-serif' font-size='16' font-weight='bold'>" & CurrLabel & "</text>" &

  "<rect x='10' y='96' width='380' height='18' rx='4' fill='" & TrackColor & "'/>" &
  "<rect x='10' y='96' width='" & Width2 & "' height='18' rx='4' fill='" & RectColor2 & "'/>" &
  "<text x='10' y='136' fill='" & RectColor2 & "' font-family='sans-serif' font-size='16' font-weight='bold'>" & PrevLabel & "</text>" &

"</svg>" &
"</div>"
```

---

## 13. Sales by Territory Visual

### Current Month Sales (Territory)
Base sales measure shared across multiple visuals including
the Treemap. Returns 0 instead of blank when no sales exist
for the selected period — prevents tiles from disappearing
from the Treemap when a month has no territory data.

```dax
CurrMonthSales = COALESCE( CALCULATE( [TotalDuePerProduct], DATESMTD((Date_Dim[Date]) )) , 0)
```

---

### Territory Performance Tier
Classifies each territory as High, Medium or Low based on
how its current month sales compare to the average sales
across all territories. Used as a tooltip field on the
Treemap visual — visible on hover without cluttering the tile.

**Business Rules:**
| Tier | Rule | Meaning |
|---|---|---|
| 🟢 High | Sales ≥ 120% of average | Significantly outperforming |
| 🟡 Medium | Sales 80% – 120% of average | On track |
| 🔴 Low | Sales < 80% of average | Underperforming |

```dax
TerritoryPerformance = 

VAR AvgTerritorySales = 
    AVERAGEX(
        ALL(Territory_Dim[TerritoryName]),
        CALCULATE([CurrMonthSales])
    )

VAR Ratio = DIVIDE([CurrMonthSales], AvgTerritorySales, 0)
RETURN
IF(Ratio >= 1.2, "🟢 High",
    IF(Ratio >= 0.8, "🟡 Medium",
        "🔴 Low"
    )
)
```

---

## 14. Up Down Arrow Indicators

Renders a Unicode arrow or circle indicator based on the
direction of any percentage change measure.
The `MoM` variable can be swapped for any measure that
returns a positive, negative or zero value — making this
pattern reusable across all KPI indicators on the dashboard.

**Unicode characters used:**
| Symbol | Unicode | Meaning |
|---|---|---|
| ▲ | `UNICHAR(9650)` | Positive / above prior period |
| ▼ | `UNICHAR(9660)` | Negative / below prior period |
| ○ | `UNICHAR(9711)` | Neutral / no change |

```dax
Up&DownArrowCircle_SalesMoM = 

VAR MoM = [MoM%ChangeSales]

RETURN
IF(MoM > 0,
    Unichar( 9650 ),
    
    IF(
        MoM < 0,
            Unichar( 9660 ),
                Unichar( 9711 )
    )
)
```

---

*Last updated: July 2026*
*Dashboard: Monthly Sales Performance Dashboard — AdventureWorks 2022*
