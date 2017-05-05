setwd("/home/remoteuser/Code/ROnAzure")
source("SetComputeContext.r")

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))

library(SparkR)

sparkEnvir <- list(spark.executor.instances = '10',
                   spark.yarn.executor.memoryOverhead = '8000')

sc <- sparkR.init(
  sparkEnvir = sparkEnvir,
  sparkPackages = "com.databricks:spark-csv_2.10:1.3.0"
)

sqlContext <- sparkRSQL.init(sc)

airPath <- file.path(fullDataDir, "AirlineSubsetCsv")

# create a SparkR DataFrame for the airline data
airDF <- read.df(sqlContext, airPath, source = "com.databricks.spark.csv", 
                 header = "true", inferSchema = "true")

################################################
# Data Cleaning and Transformation
################################################

airDF <- SparkR::rename(airDF,
                        ArrDel15 = airDF$ARR_DEL15,
                        Year = airDF$YEAR,
                        Month = airDF$MONTH,
                        DayofMonth = airDF$DAY_OF_MONTH,
                        DayOfWeek = airDF$DAY_OF_WEEK,
                        Carrier = airDF$UNIQUE_CARRIER,
                        OriginAirportID = airDF$ORIGIN_AIRPORT_ID,
                        DestAirportID = airDF$DEST_AIRPORT_ID,
                        CRSDepTime = airDF$CRS_DEP_TIME,
                        CRSArrTime =  airDF$CRS_ARR_TIME
)

# Select desired columns from the flight data. 
varsToKeep <- c("ArrDel15", "Year", "Month", "DayofMonth", "DayOfWeek", "Carrier", "OriginAirportID", "DestAirportID", "CRSDepTime", "CRSArrTime")
airDF <- select(airDF, varsToKeep)

# Round down scheduled departure time to full hour.
airDF$CRSDepTime <- floor(airDF$CRSDepTime / 100)


################################################
# Output to CSV
################################################

# Increase numCSVs when working with larger data
# on a larger cluster
numCSVs <- 2 # write.df below will produce this many CSV files
airDF <- repartition(airDF, numCSVs)

# write result to directory of CSVs
write.df(airDF, file.path(fullDataDir, "airDFCsvSubset"), "com.databricks.spark.csv", "overwrite", header = "true")

# We can shut down the SparkR Spark context now
sparkR.stop()

# remove non-data files
if (is(rxOptions()$fileSystem, "RxHdfsFileSystem"))
{
  rxHadoopRemove(file.path(fullDataDir, "airDFCsvSubset/_SUCCESS"))
} else
{
  file.remove(Sys.glob(file.path(dataDir, "airDFCsvSubset/.*.crc")))
  file.remove(Sys.glob(file.path(dataDir, "airDFCsvSubset/_SUCCESS")))
}

################################################
# Import to compressed, binary XDF format
################################################

colInfo <- list(
  ArrDel15 = list(type="numeric"),
  Year = list(type="factor"),
  Month = list(type="factor"),
  DayofMonth = list(type="factor"),
  DayOfWeek = list(type="factor"),
  Carrier = list(type="factor"),
  OriginAirportID = list(type="factor"),
  DestAirportID = list(type="factor"),
  CRSDepTime = list(type="integer"),
  CRSArrTime = list(type="integer")
)

airDFTxt <- RxTextData(file.path(dataDir, "airDFCsvSubset"),
                       colInfo = colInfo)

finalData <- RxXdfData(file.path(dataDir, "airDFXDFSubset"))

# For local compute context, skip the following line
startRxSpark()

rxImport(inData = airDFTxt, finalData, overwrite = TRUE)

system('hadoop fs -ls /user/RevoShare/remoteuser/Data')

rxGetInfo(finalData, getVarInfo = T)
# File name: /user/RevoShare/remoteuser/Data/airDFXDFSubset 
# Number of composite data files: 2 
# Number of observations: 1900875 
# Number of variables: 10 
# Number of blocks: 4 
# Compression type: zlib 
# Variable information: 
#   Var 1: ArrDel15, Type: numeric, Low/High: (0.0000, 1.0000)
# Var 2: Year
# 2 factor levels: 2011 2012
# Var 3: Month
# 2 factor levels: 2 1
# Var 4: DayofMonth
# 31 factor levels: 13 17 21 25 1 ... 2 26 29 30 31
# Var 5: DayOfWeek
# 7 factor levels: 7 4 1 5 2 6 3
# Var 6: Carrier
# 17 factor levels: AA AS B6 CO DL ... US WN XE YV VX
# Var 7: OriginAirportID
# 295 factor levels: 12478 12892 13830 11298 12173 ... 11699 14955 13139 10728 10577
# Var 8: DestAirportID
# 295 factor levels: 12892 12478 11298 13830 14771 ... 15048 13139 10728 11699 14955
# Var 9: CRSDepTime, Type: integer, Low/High: (0, 23)
# Var 10: CRSArrTime, Type: integer, Low/High: (1, 2400)

# For local compute context, skip the following line
rxSparkDisconnect(rxGetComputeContext())
