#!/bin/sh

# Final Script - 13/08/2018 Ines Krissaane
echo "DEBUT"
count = 0
while read W; do
	while read N; do
			count=$((count+1))
			#echo $count n1-standard-4 $N $W
			sh ./function.sh $count n1-standard-4 $N $W &> output.csv
	done <nodes_google1.txt
done <machine_name_google2.txt
echo "FIN" 