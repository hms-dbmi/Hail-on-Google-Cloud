#!/bin/bash

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
		--metadata=JAR=gs://hail-common/builds/0.2/jars/hail-0.2-d33e2d1c19b2-Spark-2.2.0.jar,ZIP=gs://hail-common/builds/0.2/python/hail-0.2-d33e2d1c19b2.zip,MINICONDA_VERSION=4.4.10 \
		--project=copd-genes \
		--num-workers=2 \
		--worker-machine-type=$W \
		--zone=us-east1-d \
		--image-version=1.2-deb9 \
		--num-preemptible-workers=$N \
    --network=ines-hail \
		--initialization-actions=gs://dataproc-initialization-actions/conda/bootstrap-conda.sh,gs://script-cluster/script.py


	#submit job (48hours max) timeout 172800s
  gcloud dataproc jobs submit pyspark gs://last-results/gwas-sex-1kgP1.py --cluster=hail$count --project=copd-genes

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

	echo "$count,$start,$(date +"%s"),$N,$W" >> final_conf_cluster-1KGphase1-sex.csv


	#gsutil cp conf_cluster.csv gs://ines-work/conf_cluster.csv;
}

test $1 $2 $3 $4
