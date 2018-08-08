# Hail-on-Google-Cloud

Deploy a Hail cluster (https://hail.is/) in Google Cloud.

## Hail 0.2
*Learn how to create a dataproc cluster with Hail 0.2 with Jupyter Notebook and all the packages that you will need. You can also submit a simple job.*

1. Create a DataProc Cluster

- You can choose the machine instance type in
https://cloud.google.com/compute/docs/machine-types#standard_machine_types .
- If you want to create a cluster with the latest version of Hail 0.2, you have to retrieve the number from https://github.com/hail-is/hail. All the JAR and ZIP files are available via the command  ```gsutil ls -r gs://hail-common/builds/devel/jars ``` and ```gsutil ls -r gs://hail-common/builds/devel/python ``` Replace #version_number with the version that you want. 
- You need the init_notebook python script as one the initialization-actions. Put this file in a google bucket (you can change the port and the password in this script). 
- You need the name of your project and the region. 

Here you have the command to create the Hail google cloud cluster. 
```
gcloud dataproc clusters create *cluster-name* \
--project *your-project* \
--zone *your-zone* \
--master-machine-type n1-highmem-8 \
--master-boot-disk-size 100 \
--num-workers 2 \
--worker-machine-type n1-highmem-8 \
--worker-boot-disk-size 75 \
--image-version=1.2  \
--metadata=JAR=gs://hail-common/builds/devel/jars/hail-devel-#version_number-Spark-2.2.0.jar,ZIP=gs://hail-common/builds/devel/python/hail-devel-#version_number.zip,MINICONDA_VERSION=4.4.10 \
--initialization-actions=gs://dataproc-initialization-actions/conda/bootstrap-conda.sh,gs://path_to/init_notebook.py
```

2. Connect to your cluster and open Jupyter Notebook

- Connect by HTTP traffic
Open a firewall with the right port #port in Network -> VPC network -> Firewall rules
You can change the port in the init_notebook.py script. 
The url to have access to the Jupyter Notebook will be : http://ExternalIP:#port.

- Connect by SSH (for windows system)
```
gcloud compute ssh --project=*your-project* --zone=*your-zone* --ssh-flag="-D" --ssh-flag="10000" --ssh-flag="-N" "*cluster-name*-m"
```
The path is different for Mac or Linux system (see https://cloud.google.com/dataproc/docs/concepts/accessing/cluster-web-interfaces)
```
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "http://*cluster-name*-m:8123" \
--proxy-server="socks5://localhost:10000" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" --user-data-dir="C:/temp"
```

3. Submit a hail job with a python script 
```
gcloud dataproc jobs submit pyspark gs://path-to/python-script.py --cluster=*cluster-name* --project=*your-project*
```


## Hail 0.1
*Learn how to create a dataproc cluster with Hail 0.1 and how to submit python job to this cluster.*

1. Create a DataProc Cluster : 
```
gcloud dataproc clusters create *cluster-name* \
--zone *your-zone* \
--master-machine-type n1-highmem-8 \
--master-boot-disk-size 100 \
--num-workers 2 \
--worker-machine-type n1-highmem-8 \
--worker-boot-disk-size 75 \
--num-worker-local-ssds 1 \
--num-preemptible-workers 4 \
--image-version 1.1 \
--project *your-project* \
--properties "spark:spark.driver.extraJavaOptions=-Xss4M,spark:spark.executor.extraJavaOptions=-Xss4M,spark:spark.driver.memory=45g,spark:spark.driver.maxResultSize=30g,spark:spark.task.maxFailures=20,spark:spark.kryoserializer.buffer.max=1g,hdfs:dfs.replication=1" \
--initialization-actions gs://hail-common/hail-init.sh
```

2. Find out the Hail release Hash value by running, and copy the value
```
gsutil cat gs://hail-common/builds/0.1/latest-hash-spark-2.0.2.txt
```
Copy the Hash value that I will call #hash. 

3. Create a python script myscript.py 
example : 
```
from hail import *
hc = HailContext()
hc.read('gs://gnomad-public/legacy/exac_browser/ExAC.r1.sites.vds').count()
```
4. Submit a hail job to the cluster
```
gcloud dataproc jobs submit pyspark \
--cluster=*cluster-name* \
--files=gs://hail-common/builds/0.1/jars/hail-0.1-#hash-Spark-2.0.2.jar \
--py-files=gs://hail-common/builds/0.1/python/hail-0.1-#hash.zip \
--properties="spark.driver.extraClassPath=./hail-0.1-#hash-Spark-2.0.2.jar,spark.executor.extraClassPath=./hail-0.1-#hash-Spark-2.0.2.jar" *cluster-name*
--project=*your-project* \
myscript.py 
```


