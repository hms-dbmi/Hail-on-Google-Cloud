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
		--project=your-project \
		--num-workers=2 \
		--worker-machine-type=$W \
		--zone=your-zone \
		--image-version=1.2-deb9 \
		--num-preemptible-workers=$N \
    		--network=your-network \
		--initialization-actions=gs://dataproc-initialization-actions/conda/bootstrap-conda.sh,gs://your-bucket/script.py, gs://your-bucket/install_datadog.sh 


	#submit job (48hours max) timeout 172800s
 	gcloud dataproc jobs submit pyspark gs://your-bucket/your-python-file.py --cluster=hail$count --project=your-project


	# #metrics extraction
	# 	#for the master node from datadog
	# python Datadog_extraction.py "$start" "$(date +"%s")" "hail${count}-m.c.your-project.internal"

	# gsutil cp hail${count}-m.c.your-project.internal.csv gs://your-bucket/hail${count}-master-datadog.csv
	# 	#for the worker nodes do a for loop
	# for i in $(seq 0 $((${N}-1)));
	# do
	# 	 python Datadog_extraction.py "$start" "$(date +"%s")" "hail${count}-w-$i.c.your-project.internal"
	# 	 gsutil cp hail${count}-w-$i.c.your-project.internal.csv gs://your-bucket/hail$count-worker-$i-datadog.csv;
	# done

	#delete cluster
  	gcloud dataproc clusters delete hail$count -q

	echo "$count,$start,$(date +"%s"),$N,$W" >> final_conf_cluster.csv

}

test $1 $2 $3 $4
