# Databricks notebook source
# MAGIC %md
# MAGIC ## Databricks Best Practices Links
# MAGIC
# MAGIC [Databricks on Azure Best Practices](https://learn.microsoft.com/en-us/azure/databricks/best-practices-index)
# MAGIC <br>
# MAGIC [Unity Catalog](https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/best-practices)
# MAGIC <br>
# MAGIC [Worspace Organization](https://www.databricks.com/blog/2022/03/10/functional-workspace-organization-on-databricks.html)
# MAGIC <br>
# MAGIC [Serving Up a Primer for Unity Catalog Onboarding](https://www.databricks.com/blog/2022/11/22/serving-primer-unity-catalog-onboarding.html)
# MAGIC <br>
# MAGIC [SCIM Provisioning](https://docs.databricks.com/administration-guide/users-groups/scim/aad.html)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pull some data from an online source for demo

# COMMAND ----------

import csv
import pandas as pd
import requests

url = "https://archive-api.open-meteo.com/v1/archive?latitude=52.52&longitude=13.41&start_date=2023-04-13&end_date=2023-04-27&hourly=temperature_2m&format=csv"

# Download the CSV file from the URL into variable
with requests.get(url) as response:
    response.raise_for_status()
    data = response.text

# Read the in-memory data into a pandas dataframe
rows = csv.DictReader(data.splitlines()[3:])
df = pd.DataFrame(data=rows)

# Convert from pandas dataframe to spark
df_final = spark.createDataFrame(df).withColumnRenamed('temperature_2m (°C)', 'temperature')
display(df_final)


# COMMAND ----------

# MAGIC %md
# MAGIC ## Create catalog, schema and table for new data

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC set db.catalog = ws_demo_01;
# MAGIC set db.schema = weather_bronze;
# MAGIC
# MAGIC -- change your managed location to reflect the abfss location of your external data store
# MAGIC CREATE CATALOG IF NOT EXISTS ${db.catalog} MANAGED LOCATION "abfss://data@devworkspacestg.dfs.core.windows.net";
# MAGIC ALTER CATALOG ${db.catalog} OWNER TO `IACWorkshopAdmins`;
# MAGIC
# MAGIC CREATE SCHEMA IF NOT EXISTS ${db.catalog}.${db.schema};
# MAGIC ALTER SCHEMA ${db.catalog}.${db.schema} OWNER TO `IACWorkshopAdmins`;
# MAGIC
# MAGIC -- USE ${db.catalog};
# MAGIC
# MAGIC CREATE TABLE IF NOT EXISTS ${db.catalog}.${db.schema}.temperature (
# MAGIC   time TIMESTAMP,
# MAGIC   temperature FLOAT
# MAGIC );
# MAGIC
# MAGIC ALTER TABLE ${db.catalog}.${db.schema}.temperature OWNER TO `IACWorkshopAdmins`;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Load the dataframe into a delta table

# COMMAND ----------

table_name = 'ws_demo_01.weather_bronze.temperature'

df = spark.read.table(table_name)
columns = df.columns
print(columns)

df_final.select(*columns) \
    .write \
    .format("delta") \
    .mode("overwrite") \
    .insertInto(table_name)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Query the data in the delta table using sql

# COMMAND ----------

# MAGIC %sql
# MAGIC select * from ws_demo_01.weather_bronze.temperature where temperature > 9.0

# COMMAND ----------

# MAGIC %md
# MAGIC ## Query the data in the delta table using spark.sql

# COMMAND ----------

display(spark.sql('select * from ws_demo_01.weather_bronze.temperature'))

# COMMAND ----------


