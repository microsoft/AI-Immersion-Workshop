setwd('/home/remoteuser/Code/ROnAzure/')

library(doAzureParallel)

# 1. Generate a pool configuration file.  
generateClusterConfig("pool_config.json")

# 2. Edit your pool configuration file.
# Enter your Azure Batch Account & Azure Storage keys/account-info and configure your pool settings.

# 3. Register the pool. This will create a new pool if your pool hasn't already been provisioned.
pool <- makeCluster("pool_config.json")

# 4. Register the pool as your parallel backend
registerDoAzureParallel(pool)

# Random forest model
library(randomForest)
x <- matrix(runif(500), 100) 
y <- gl(2, 50)

rf <- foreach(ntree=rep(100, 4), .combine=combine, .packages='randomForest') %dopar% {
  randomForest(x, y, ntree=ntree) 
}


# 5. Check that your parallel backend has been registered
getDoParWorkers()

stopCluster(pool)