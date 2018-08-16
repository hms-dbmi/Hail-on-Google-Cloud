# Hail-on-Google-Cloud

## Install SDK Google Cloud 

Google Cloud SDK is a set of tools that you can use to manage resources and applications hosted on Google Cloud Platform. It will be easier to launch and detete cluster though SDK.

Install the SDK cloud for your specific OS. Follow all the steps provided by Google on https://cloud.google.com/sdk/docs/#deb

For Mac or Linux User, it will be fully integrated in your terminal. For Windows user, you will have to use a new command prompt terminal. 

You will need to provide the name of your project and the region. 


## Deploy a Hail 0.2 cluster (https://hail.is/) in Google Cloud.

*Learn how to create a dataproc cluster with Hail 0.2 with Jupyter Notebook and all the packages that you will need. You can also submit a simple python job. And you will know how to delete it. *

### Prerequisites

- You can choose the machine instance type in
https://cloud.google.com/compute/docs/machine-types#standard_machine_types .
- If you want to create a cluster with the latest version of Hail 0.2, you have to retrieve the number from https://github.com/hail-is/hail. All the JAR and ZIP files are available via the command  ```gsutil ls -r gs://hail-common/builds/devel/jars ``` and ```gsutil ls -r gs://hail-common/builds/devel/python ``` Replace #version_number with the version that you want. 
- You need the init_notebook python script as one the initialization-actions. Put this file in a google bucket (you can change the port and the password in this script). 
- You need the name of your project and the region. 


### Instructions

Our advice in terms of cluster size which are the default settings given below:

- Choose a small machine for the master node that is not the machine that performs the tasks, for example *n1-standard-2*

- A number of worker nodes between 2 and 4 should be enough to start.

- For the worker nodes, the machine will be identical and it must be chosen according to your needs. You can choose the machine instance type in
https://cloud.google.com/compute/docs/machine-types#standard_machine_types To begin, you can use *n1-highmem-32* ($1.8944 per hour).

Always try to keep an eye on the price of machines with https://cloud.google.com/compute/pricing or https://cloud.google.com/products/calculator/

### An example step by step

1. Launch a Hail cluster 

Tap in your terminal (or in the SDK terminal for windows user).

```
gcloud dataproc clusters create *cluster-name* \
--project *your-project* \
--zone *your-zone* \
--master-machine-type n1-standard-2 \
--master-boot-disk-size 100 \
--num-workers 3 \
--worker-machine-type n1-highmem-32 \
--worker-boot-disk-size 75 \
--image-version=1.2  \
--metadata=JAR=gs://hail-common/builds/devel/jars/hail-devel-#version_number-Spark-2.2.0.jar,ZIP=gs://hail-common/builds/devel/python/hail-devel-#version_number.zip,MINICONDA_VERSION=4.4.10 \
--initialization-actions=gs://dataproc-initialization-actions/conda/bootstrap-conda.sh,gs://path_to/init_notebook.py
```

2. Connect to your cluster and open Jupyter Notebook

The url to have access to the Jupyter Notebook will be : http://ExternalIP:#port.

You can find the externalIP in the google API. The port is 8245 by default. The password is *hello-hail* by default. 

3. Submit a hail job with a python script 
```
gcloud dataproc jobs submit pyspark gs://path-to/python-script.py --cluster=*cluster-name* --project=*your-project*
```

4. Delete the cluster 
```
gcloud dataproc clusters delete *cluster-name*
```


