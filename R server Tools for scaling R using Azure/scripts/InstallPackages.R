install.packages("broom", repos='http://cran.us.r-project.org')
install.packages("AzureML", repos='http://cran.us.r-project.org')

install.packages("devtools")
library(devtools)
# install the doAzureParallel and rAzureBatch package
install_github(c("Azure/rAzureBatch", "Azure/doAzureParallel"))
