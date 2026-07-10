# Monthly Sales Performance Dashboard — Power BI

An advanced monthly sales dashboard built on the AdventureWorks 2022 dataset, 
designed for the Head of Sales, Regional Sales Managers and Finance teams who 
need a comprehensive view of monthly performance across products, customers and territories.

All key figures were independently validated against raw T-SQL queries run 
directly against the source tables.

![Dashboard Overview](screenshots/dashboard_overview.png)

---

## 📌 Project Summary

This dashboard answers the following business questions:

- How did we perform this month vs last month and vs the same month last year?
- Which products and categories are driving revenue?
- Who are our top 10 customers and what is their revenue contribution?
- Which territories are performing above or below average?
- Are we on track to hit our monthly sales target?

---

## 🛠️ Tools Used

- **Power BI Desktop** — report design, DAX measures, data modelling
- **SQL Server (T-SQL)** — ETL process and validation queries
- **AdventureWorks 2022** — sample relational database (snowflake schema)
- **SVG & HTML DAX** — custom visuals built directly in DAX measures

---

## ✨ Key Features

- **Dynamic HTML Summary Card** — auto-generates a written summary sentence 
  showing MoM and YoY performance with colour coded % changes
- **KPI Cards** — Monthly Sales, Orders, AOV, MoM % Change, YoY % Change, 
  Unique Customers — all dynamic with up/down indicators
- **24-Month Sales Trend** — line chart with forecast line and average reference line
- **Sales vs Target Gauge** — dynamic target set at 110% of prior month sales,
  max at 150%, min at 50%
- **Top 10 Customers Table** — ranked with inline SVG progress bars showing % share
- **Sales by Category** — dual SVG progress bars comparing current vs prior month
  per product category
- **Product Performance Matrix** — drill down from Category → Subcategory → Product
  with conditional formatting (5 performance tiers)
- **Sales by Territory Treemap** — colour coded by region with performance tier
  (High/Medium/Low) shown on hover tooltip

---

## ✅ Data Validation

Every key figure on the dashboard was cross checked against equivalent SQL queries
run directly on the underlying fact and dimension tables. This included:

- Total monthly sales and order counts
- Top 10 customers by revenue and % share
- Sales by product category for current and prior month

See the [`/sql`](./sql) folder for all validation queries and 
[`/sql/README.md`](./sql/README.md) for notes on what each query validates.

---

## 📐 Key DAX Measures

Measures follow a consistent naming convention: `[Metric] - [Context/Qualifier]`

Highlights:
- **`Sales - Current Month`** — total sales filtered to the selected reporting month
- **`Sales - Prior Month`** — total sales for the month immediately before
- **`Sales - MoM % Change`** — month over month percentage change
- **`Sales - Same Month Last Year`** — sales for the equivalent month in the prior year
- **`Sales - YoY % Change`** — year over year percentage change
- **`Sales Target - Current Month`** — dynamic target set at Prior Month × 110%
- **`Sales Max - Current Month`** — dynamic max set at Prior Month × 150%
- **`Sales Min - Current Month`** — dynamic min set at Prior Month × 50%
- **`Average Order Value - Current Month`** — Sales ÷ Orders
- **`TerritoryPerformance`** — classifies each territory as High, Medium or Low
- **`SVG_Paragraph`** — outputs a dynamic HTML summary sentence
- **`CurrMShare%Bar`** — SVG progress bar for customer % share
- **`CategoryProgressBar`** — dual SVG progress bars for category comparison

Full measure documentation in [`/dax/measures.md`](./dax/measures.md)

---

## 🎨 Design System

The dashboard follows a consistent dark purple design system. Full colour palette,
typography scale and component specifications documented in 
[`/docs/design-system.md`](./docs/design-system.md)

---

## 📁 Repository Structure

```
Monthly-Sales-Performance-Dashboard/
├── README.md
├── powerbi/
│   └── Monthly_Sales_Dashboard.pbix
├── sql/
│   ├── validation_monthly_sales.sql
│   ├── validation_top10_customers.sql
│   ├── validation_sales_by_category.sql
│   └── README.md
├── dax/
│   └── measures.md
├── screenshots/
│   ├── dashboard_overview.png
│   ├── top10_customers.png
│   ├── treemap.png
│   ├── trend_chart.png
│   └── gauge.png
└── docs/
    └── design-system.md
```

---

## 🔭 Next Steps / Possible Improvements

- Fix custom visual rendering in Power BI Service
- Add drillthrough page for product category detail
- Add mobile layout view
- Add Row Level Security (RLS) for territory managers

---

## 📄 License

This project uses Microsoft's publicly available AdventureWorks 2022 sample 
dataset for educational and portfolio purposes.
