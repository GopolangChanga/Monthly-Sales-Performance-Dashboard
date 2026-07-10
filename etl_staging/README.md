# ETL

Staging layer pipeline for the Sales Daily Report project — loads data from `AdventureWorks2022` into `AdventureWorks_Stage`, orchestrated via a SQL Server Agent job. Feeds the `SQL` and `DAX` layers elsewhere in this repo.

---

## Source

This project uses the official Microsoft AdventureWorks2022 sample database as the source system.

- Install/configure guide: https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms

Tables sourced from `AdventureWorks2022`:

- `Production.Product`
- `Production.ProductCategory`
- `Production.ProductSubcategory`
- `Person.Person`
- `Sales.Store`
- `Sales.SalesTerritory`
- `Sales.Customer`
- `Person.StateProvince` / `Person.Address` (joined for `Geography`)
- `Sales.SalesOrderHeader`
- `Sales.SalesOrderDetail`

---

## ETL

Scripts to run, **in this order**, against `AdventureWorks_Stage`:

| Order | File | Purpose |
|---|---|---|
| 1 | `01_alter_stage_tables_add_batch_columns.sql` | Adds `BatchID` + `LoadDateTime` tracking columns to every staging table |
| 2 | `02_updated_staging_procs.sql` | Creates/updates all 10 staging load procedures |
| 3 | `03_create_master_staging_job.sql` | Creates the SQL Server Agent job that runs all procs in dependency order on a schedule |

**Staging design principles used throughout:**

- Staging tables are a raw, unfiltered copy of the source — no business logic applied here
- Full reload every run (`TRUNCATE` + `INSERT`), since staging is disposable
- Every row is tagged with a `BatchID` (unique per run) and `LoadDateTime` (when it landed in staging), for traceability
- Each proc is wrapped in a transaction with `TRY/CATCH`, so a failure never leaves a table half-loaded
- All 10 procs run as ordered steps inside a single Agent job (`AdventureWorks - Full Staging Refresh`), not as 10 separate jobs, so load order and failure handling are controlled centrally

**Staging procs included:**

1. `usp_Load_StagingProductCategory`
2. `usp_Load_StagingProductSubcategory`
3. `usp_Load_StagingProduct`
4. `usp_Load_StagingPerson`
5. `usp_Load_store`
6. `usp_Load_salesterritory`
7. `usp_Load_StagingCustomer`
8. `usp_Load_geography`
9. `usp_Load_StagingSalesOrderHeader`
10. `usp_Load_StagingSalesOrderDetail`

---

## Validation

Run this after the job completes to confirm row counts landed across all staging tables:

```sql
SELECT 'Product' AS TableName, COUNT(*) AS [RowCount] FROM Product_Stage
UNION ALL SELECT 'ProductCategory', COUNT(*) FROM ProductCategory_Stage
UNION ALL SELECT 'ProductSubcategory', COUNT(*) FROM ProductSubcategory_Stage
UNION ALL SELECT 'Person', COUNT(*) FROM Person_Stage
UNION ALL SELECT 'Store', COUNT(*) FROM Store_Stage
UNION ALL SELECT 'SalesTerritory', COUNT(*) FROM SalesTerritory_Stage
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer_Stage
UNION ALL SELECT 'Geography', COUNT(*) FROM Geography_Stage
UNION ALL SELECT 'SalesOrderHeader', COUNT(*) FROM SalesOrderHeader_Stage
UNION ALL SELECT 'SalesOrderDetail', COUNT(*) FROM SalesOrderDetail_Stage;
```

To check the traceability of a specific run, query by `BatchID`:

```sql
SELECT BatchID, LoadDateTime, COUNT(*) AS RowsLoaded
FROM Product_Stage
GROUP BY BatchID, LoadDateTime
ORDER BY LoadDateTime DESC;
```

To confirm the Agent job itself ran successfully, check its history in SSMS:
`SQL Server Agent → Jobs → AdventureWorks - Full Staging Refresh → View History`

---

