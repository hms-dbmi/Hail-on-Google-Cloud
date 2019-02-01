# Pipeline to deploy, analyze WGS data and delete a GCP cluster with one-line command. 

You can choose the different configuration you want by editing the text files :

- machine_names_google.txt
- nodes_google.txt 

You have to choose the python file that you want to submit to your cluster and specify it in the shell script function.sh 

``` gcloud dataproc jobs submit pyspark gs://bucket/your-python-file.py --cluster=hail$count --project=your-project ```

To launch the analysis, just need to do the following command-line into a terminal : 
```./Final_shell_script.sh ```
