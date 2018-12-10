from datadog import api
from datadog import initialize
import csv
#from google.cloud import storage
#client = storage.Client()
#bucket = client.get_bucket('ines-results')
import sys
import os

args = sys.argv
start = args[1]
end   = args[2]
host  = args[3]

options = {
    'api_key': '', 
    'app_key': ''
}
initialize(**options)

start = start
end = end
host = host


def extract_dd(host, metric):
    ''' Extract a metric from an host 
        example : 
            host = "hail137-m.c.avl-hail-ines.internal"
            metric = "gcp.gce.instance.cpu.utilization"
    '''
    query = metric+"{host:"+ host +"}"
    results = api.Metric.query(start=start, end=end, query=query)
    return(results)

list_metrics = ["system.cpu.user","gcp.gce.instance.cpu.utilization", "system.mem.total", "system.mem.free", "system.mem.used", "gcp.gce.instance.disk.read_ops_count","gcp.gce.instance.disk.write_ops_count", "gcp.gce.instance.disk.write_bytes_count",  "gcp.gce.instance.disk.read_bytes_count", "gcp.gce.instance.network.sent_bytes_count", "gcp.gce.instance.network.received_bytes_count", 'system.cpu.iowait', 'system.load.1', 'system.load.5', 'system.load.15']

dir = "/home/krissaane_ines"
list = []
for i in list_metrics : 
   list.append(extract_dd(host, i))

with open(os.path.join(dir, host +'.csv'), "w") as f :
    wr = csv.writer(f, quoting=csv.QUOTE_ALL)
    wr.writerow(list)

   #with open(os.path.join(dir, host+"-"+i+'.csv'), "w") as f: 
   #with open('my_file.csv', 'w') as f:
        #[f.write('{0},{1}\n'.format(key, value)) for key, value in mydict.items()]
        
        #blob.upload_from_filename("my_file.csv") 
