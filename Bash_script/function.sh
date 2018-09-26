#!/bin/sh
# A simple script with a function...

test()
{
	count=$1
	M=$2
	N=$3
	W=$4
	start=$(date +"%s")
	

	#create cluster
	gcloud dataproc clusters create hail$count \
		--master-machine-type=$M \
		--metadata=JAR=gs://hail-common/builds/devel/jars/hail-devel-98f4d6a179b4-Spark-2.2.0.jar,ZIP=gs://hail-common/builds/devel/python/hail-devel-98f4d6a179b4.zip,MINICONDA_VERSION=4.4.10 \
		--project avl-hail-ines \
		--num-workers=$N \
		--worker-machine-type=$W \
		--zone=us-east1-b \
		--initialization-actions=gs://dataproc-initialization-actions/conda/bootstrap-conda.sh,gs://ines-python/creation-cluster/init_notebook3.py,gs://ines-python/creation-cluster/install_datadog.sh

	#submit job (48hours max)
	timeout 172800s gcloud dataproc jobs submit pyspark gs://ines-python/ines-project/Analysis/GWAS-Phase1-1kGenomes.py  --cluster=hail$count --project=avl-hail-ines
	
	#change the name file 
	# gsutil mv gs://ines-results/time.csv gs://ines-results/hail-time${count}.csv

	# #metrics extraction
	# 	#for the master node from datadog
	# python Datadog_extraction.py "$start" "$(date +"%s")" "hail${count}-m.c.avl-hail-ines.internal"

	# gsutil cp hail${count}-m.c.avl-hail-ines.internal.csv gs://ines-results/hail${count}-master-datadog.csv
	# 	#for the worker nodes do a for loop
	# for i in $(seq 0 $((${N}-1)));
	# do 
	# 	 python Datadog_extraction.py "$start" "$(date +"%s")" "hail${count}-w-$i.c.avl-hail-ines.internal"
	# 	 gsutil cp hail${count}-w-$i.c.avl-hail-ines.internal.csv gs://ines-results/hail$count-worker-$i-datadog.csv;
	# done

	#delete cluster
	gcloud dataproc clusters delete hail$count -q

	echo "$count,$start,$(date +"%s"),$N,$W" >> conf_cluster.csv

	gsutil cp conf_cluster.csv gs://ines-results/conf_cluster.csv;
}

test $1 $2 $3 $4



