#######################################################################################################################################
#######################################################################################################################################
## THIS SCRIPT CUSTOMIZES THE DSVM BY ADDING HADOOP AND YARN, INSTALLING R-PACKAGES, AND DOWNLOADING DATA-SETS FOR AI Immersion -
## Scaling R on Azure tutorial.
#######################################################################################################################################
#######################################################################################################################################

#!/bin/bash
source /etc/profile.d/hadoop.sh
#PATH=paste0(Sys.getenv("PATH"),":/opt/hadoop/current/bin:/dsvm/tools/spark/current/bin")

#######################################################################################################################################
## Setup autossh for hadoop service account
#######################################################################################################################################
#cat /opt/hadoop/.ssh/id_rsa.pub >> /opt/hadoop/.ssh/authorized_keys
#chmod 0600 /opt/hadoop/.ssh/authorized_keys
#chown hadoop /opt/hadoop/.ssh/authorized_keys
echo -e 'y\n' | ssh-keygen -t rsa -P '' -f ~hadoop/.ssh/id_rsa
cat ~hadoop/.ssh/id_rsa.pub >> ~hadoop/.ssh/authorized_keys
chmod 0600 ~hadoop/.ssh/authorized_keys
chown hadoop:hadoop ~hadoop/.ssh/id_rsa
chown hadoop:hadoop ~hadoop/.ssh/id_rsa.pub
chown hadoop:hadoop ~hadoop/.ssh/authorized_keys

#######################################################################################################################################
## Start up several services, yarn, hadoop, rstudio server
#######################################################################################################################################
systemctl start hadoop-namenode hadoop-datanode hadoop-yarn rstudio-server

#######################################################################################################################################
## MRS Deploy Setup
#######################################################################################################################################
cd /home/remoteuser
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/backend_appsettings.json
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/webapi_appsettings.json

mv backend_appsettings.json /usr/lib64/microsoft-deployr/9.0.1/Microsoft.DeployR.Server.BackEnd/appsettings.json
mv webapi_appsettings.json /usr/lib64/microsoft-deployr/9.0.1/Microsoft.DeployR.Server.WebAPI/appsettings.json

cp /usr/lib64/microsoft-deployr/9.0.1/Microsoft.DeployR.Server.WebAPI/autoStartScriptsLinux/*    /etc/systemd/system/.
cp /usr/lib64/microsoft-deployr/9.0.1/Microsoft.DeployR.Server.BackEnd/autoStartScriptsLinux/*   /etc/systemd/system/.
systemctl enable frontend
systemctl enable rserve
systemctl enable backend
systemctl start frontend
systemctl start rserve
systemctl start backend

#######################################################################################################################################
# Copy data and code to VM
#######################################################################################################################################

# Copy Spark configuration files & shell script
cd /home/remoteuser
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/spark-defaults.conf
mv spark-defaults.conf /dsvm/tools/spark/current/conf
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/log4j.properties
mv log4j.properties /dsvm/tools/spark/current/conf
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/DSVM_Customization_Script.sh

## DOWNLOAD ALL CODE FILES
cd /home/remoteuser
mkdir  Data Code
mkdir Code/MRS Code/sparklyr Code/SparkR Code/bigmemory Code/ff Code/UseCaseHTS Code/UseCaseLearningCurves

cd /home/remoteuser
cd Code/MRS
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Code/MRS/1-Clean-Join-Subset.r
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Code/MRS/2-Train-Test-Subset.r
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Code/MRS/3-Deploy-Score-mrsdeploy.r
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Code/MRS/SetComputeContext.r
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Code/MRS/logitModelSubset.RData



## DOWNLOAD ALL DATA FILES

# Airline data
wget http://cdspsparksamples.blob.core.windows.net/data/Airline/WeatherSubsetCsv.tar.gz
wget http://cdspsparksamples.blob.core.windows.net/data/Airline/AirlineSubsetCsv.tar.gz
gunzip WeatherSubsetCsv.tar.gz
gunzip AirlineSubsetCsv.tar.gz
tar -xvf WeatherSubsetCsv.tar
tar -xvf AirlineSubsetCsv.tar
rm WeatherSubsetCsv.tar AirlineSubsetCsv.tar

cd /home/remoteuser
cd Data
wget http://strata2017r.blob.core.windows.net/airline/airline_20MM.csv

## Copy data to HDFS
cd /home/remoteuser
cd Data

# Make hdfs directories and copy things over to HDFS
/opt/hadoop/current/bin/hadoop fs -mkdir /user/RevoShare/rserve2
/opt/hadoop/current/bin/hadoop fs -mkdir /user/RevoShare/rserve2/Predictions
/opt/hadoop/current/bin/hadoop fs -chmod -R 777 /user/RevoShare/rserve2

/opt/hadoop/current/bin/hadoop fs -mkdir /user/RevoShare/remoteuser
/opt/hadoop/current/bin/hadoop fs -mkdir /user/RevoShare/remoteuser/Data
/opt/hadoop/current/bin/hadoop fs -mkdir /user/RevoShare/remoteuser/Models
/opt/hadoop/current/bin/hadoop fs -copyFromLocal * /user/RevoShare/remoteuser/Data


#######################################################################################################################################
#######################################################################################################################################
# Install R packages
cd /home/remoteuser
wget https://raw.githubusercontent.com/Azure/Azure-MachineLearning-DataScience/master/Misc/StrataSanJose2017/Scripts/InstallPackages.R

cd /usr/bin
Revo64-9.0 --vanilla --quiet  <  /home/remoteuser/InstallPackages.R

#######################################################################################################################################
#######################################################################################################################################
## Change ownership of some of directories
cd /home/remoteuser 
chown -R remoteuser Code Data

su hadoop -c "/opt/hadoop/current/bin/hadoop fs -chown -R remoteuser /user/RevoShare/rserve2" 
su hadoop -c "/opt/hadoop/current/bin/hadoop fs -chown -R remoteuser /user/RevoShare/remoteuser" 

#######################################################################################################################################
#######################################################################################################################################
## END
#######################################################################################################################################
#######################################################################################################################################
