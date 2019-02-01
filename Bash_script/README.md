# Pipeline to deploy, analyze WGS data and delete a Dataproc, Google Cloud Platform (GCP) cluster with one-line command. 

You can choose the different cluster configurations you want by editing the following text files :

- VM_google.txt (choose the virtual instance among https://cloud.google.com/compute/pricing) 
- nodes_google.txt (i.e number of preemptible nodes - if 0, you will have a cluster with 2 standard worker nodes)  

You have to choose the python file that you want to submit to your cluster and specify it in the shell script pipeline.sh by editing *your-python-file*. 
``` gcloud dataproc jobs submit pyspark gs://your-bucket/your-python-file.py --cluster=hail$count --project=your-project ```

You also have to edit in pipeline.sh the following :
- *your-bucket* : the google cloud bucket where the files can be found 
- *your-project* : the name of your project in GCP 
- *your-zone* : the region where you have enough credentials to spin up the cluster 
- *your-network* : the network on GCP (if you want to use the default one, remove this argument)

To launch the script, you just need to do the following command-line into a terminal : 
```./Final_shell_script.sh ```

It will instantiate the Dataproc cluster, submit your python script and delete the cluster automatically. 

In the pipeline.sh script, there is also the way to install datadog agent and collect metrics in each nodes if needed. 
