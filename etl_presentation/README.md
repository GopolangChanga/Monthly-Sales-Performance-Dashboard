# Presentation Layer ETL

Dim and Fact tables and load procedures for the Sales Daily Report project. Reads from `AdventureWorks_Stage` and loads into `AdventureWorks_Presentation`.

---

## Setup order

Run these two files, in this order, against `AdventureWorks_Presentation`:

| Order | File | Purpose |
|---|---|---|
| 1 | `00_create_presentation_tables.sql` | Creates all 9 Dim tables + 2 Fact tables |
| 2 | `AdventureWorks_Presentation_Procs.sql` | Creates/updates all 11 load procedures |

Staging must already be loaded first (`AdventureWorks_Stage`) — these procs read from it.

---

## Tables

**Dim tables:**
- `Productcategory_Dim`
- `ProductSubcategory_Dim`
- `Product_Dim`
- `Person_Dim`
- `Store_Dim`
- `Territory_Dim`
- `Customer_Dim`
- `CustomerDetail_Dim` — joins `Person_Dim` + `Customer_Dim`

**Fact tables:**
- `SalesOrderHeader_Fact`
- `SalesOrderDetail_Fact`

**Key design decisions:**
- No surrogate keys — `ProductID`, `CustomerID`, etc. (the natural/business keys) are used directly as the shared keys between Dim and Fact tables. This is a Type 1, single-source, full-reload model with no history tracking.
- `'Unknown_Value'` is applied only to descriptive/label fields where blank genuinely means "we don't know this" (e.g. `ProductName`, `Class`, `Style`, `ProductLine`, `AccountNumber`). It is **not** applied to derived nulls (e.g. `Size` — null means "not applicable", not "missing") or to dates (null means "still active" / "not discontinued").

---

## Procedures

| Proc | Loads | Notes |
|---|---|---|
| `usp_Load_dimproductcategory` | `Productcategory_Dim` | Full reload |
| `usp_Load_dimproductsubcategory` | `ProductSubcategory_Dim` | Full reload |
| `usp_Load_dimproduct` | `Product_Dim` | Parses `Name` into `Size` / `BaseProductName`; full reload |
| `usp_Load_dimperson` | `Person_Dim` | Full reload |
| `usp_Load_dimstore` | `Store_Dim` | Full reload |
| `usp_Load_dimterritory` | `Territory_Dim` | Full reload |
| `usp_Load_dimcustomer` | `Customer_Dim` | Full reload |
| `usp_Load_dimcustomerdetail` | `CustomerDetail_Dim` | **Must run after** `usp_Load_dimperson` and `usp_Load_dimcustomer` — joins those two Dim tables directly, not staging |
| `usp_Load_dimgeography` | `Geography_Dim` | Straight passthrough from staging; full reload |
| `usp_Load_factsalesorderheader` | `SalesOrderHeader_Fact` | Incremental via date-scoped `DELETE` + insert; `@StartDate`/`@EndDate` default `NULL` (full load) |
| `usp_Load_factsalesorderdetail` | `SalesOrderDetail_Fact` | Same incremental pattern as above |

**Recommended run order** (respects the one hard dependency):

usp_Load_dimproductcategory
usp_Load_dimproductsubcategory
usp_Load_dimproduct
usp_Load_dimperson
usp_Load_dimstore
usp_Load_dimterritory
usp_Load_dimcustomer
usp_Load_dimcustomerdetail
usp_Load_dimgeography
usp_Load_factsalesorderheader
usp_Load_factsalesorderdetail


---

## Validation

Row counts across all Dim and Fact tables:


SELECT 'Productcategory_Dim' AS TableName, COUNT(*) AS [RowCount] FROM Productcategory_Dim
UNION ALL SELECT 'ProductSubcategory_Dim', COUNT(*) FROM ProductSubcategory_Dim
UNION ALL SELECT 'Product_Dim', COUNT(*) FROM Product_Dim
UNION ALL SELECT 'Person_Dim', COUNT(*) FROM Person_Dim
UNION ALL SELECT 'Store_Dim', COUNT(*) FROM Store_Dim
UNION ALL SELECT 'Territory_Dim', COUNT(*) FROM Territory_Dim
UNION ALL SELECT 'Customer_Dim', COUNT(*) FROM Customer_Dim
UNION ALL SELECT 'CustomerDetail_Dim', COUNT(*) FROM CustomerDetail_Dim
UNION ALL SELECT 'Geography_Dim', COUNT(*) FROM Geography_Dim
UNION ALL SELECT 'SalesOrderHeader_Fact', COUNT(*) FROM SalesOrderHeader_Fact
UNION ALL SELECT 'SalesOrderDetail_Fact', COUNT(*) FROM SalesOrderDetail_Fact;

