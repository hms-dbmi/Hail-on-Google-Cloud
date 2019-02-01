#!/bin/sh

# Final Script - 02/01/2019 
echo "DEBUT"
count = 0
while read W; do
	while read N; do
			count=$((count+1))
			#echo $count n1-standard-4 $N $W
			sh ./pipeline.sh $count n1-standard-4 $N $W &> output.csv
	done <nodes_google.txt
done <machine_name_google.txt
echo "FIN" 
