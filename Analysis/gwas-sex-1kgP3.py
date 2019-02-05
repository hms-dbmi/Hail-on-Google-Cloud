import time
t1 = time.time()

import numpy as np
from bokeh.plotting import figure, output_file, show, save
from pprint import pprint
from bokeh.io import output_notebook, show
from bokeh.layouts import gridplot
from bokeh.models import Span, ColumnDataSource

output_notebook()

from math import log, isnan, log10
from bokeh.models import *
from itertools import cycle
from hail.expr import aggregators
from hail.expr.expressions import *
from hail.expr.expressions import Expression
from hail.typecheck import *
from hail import Table
import hail

from google.cloud import storage
storage.Client()
client = storage.Client()
import gcsfs
fs = gcsfs.GCSFileSystem(project='copd-genes')
bucket = client.get_bucket('last-results')

import hail as hl
import hail.expr.aggregators as agg
hl.init()

#read mt file
mt = hl.read_matrix_table("gs://1k_genome/1000-genomes-phase-3/VDS-of-all/ALL.chr.phase3_shapeit2_mvncall_integrated_v2.20130502.genotypes.mt")
#print(mt.count()) (79481587, 2535)

#filter MAF
mt = hl.variant_qc(mt)
mt = mt.filter_rows(mt.variant_qc.AF[1] > 0.01)
#print(mt.count()) (13876997, 1886)

#filter only SNPs
mt=mt.filter_rows(hl.is_snp(mt.alleles[0], mt.alleles[1]))
#print(mt.count()) (12984204, 1886)


#annotate MT file
table = (hl.import_table('gs://ines-work/KG-annotation-with-sexencoder.csv', delimiter=',', missing='', quote='"',types={'Gender_Classification':hl.tfloat64}).key_by('Sample'))
mt = mt.annotate_cols(**table[mt.s])

#print(mt.aggregate_cols(agg.counter(mt.Gender_Classification))) '0.0': 1291, '1.0': 1244}

pca_eigenvalues, pca_scores, _ = hl.hwe_normalized_pca(mt.GT, k = 2)
mt = mt.annotate_cols(pca = pca_scores[mt.s])


x= pca_scores.scores[0]
y= pca_scores.scores[1]
label=mt.cols()[pca_scores.s].Super_Population
collect_all=nullable(bool)

if isinstance(x, Expression) and isinstance(y, Expression):
        agg_f = x._aggregation_method()
        if isinstance(label, Expression):
            if collect_all:
                res = hail.tuple([x, y, label]).collect()
                label = [point[2] for point in res]
            else:
                res = agg_f(aggregators.downsample(x, y, label=label, n_divisions=n_divisions))
                label = [point[2][0] for point in res]

            x = [point[0] for point in res]
            y = [point[1] for point in res]
        else:
            if collect_all:
                res = hail.tuple([x, y]).collect()
            else:
                res = agg_f(aggregators.downsample(x, y, n_divisions=n_divisions))

            x = [point[0] for point in res]
            y = [point[1] for point in res]


arg = list(set(label))
color=[]
for i in label :
    if i == arg[1]:
        color.append('red')
    elif i == arg[2] :
        color.append('black')
    elif i == arg[3] :
        color.append('yellow')
    elif i == arg[4] :
        color.append('purple')
    else :
        color.append('blue')


p = figure(title='PCA')
fields = dict(x=x, y= y, label=label, color=color)
source = ColumnDataSource(fields)
p.circle( x='x', y='y', legend='label', color = 'color', source=source)
#show(p)
p.legend.label_text_font_size = '15pt'
p.xaxis.axis_label_text_font_size = "25pt"
p.yaxis.axis_label_text_font_size = "25pt"
p.title.text_font_size = '25pt'

output_file ('pca-1KGP3-sex', title='pca-1KGP3-sex', mode='inline')
save(p)
blob = bucket.blob('pca-1KGP3-sex.html')
blob.upload_from_filename('pca-1KGP3-sex')

#logistic_regression
gwas = hl.logistic_regression_rows(
            test='wald',
            y=mt.Gender_Classification,
            x=mt.GT.n_alt_alleles(),
            covariates=[1, mt.pca.scores[0], mt.pca.scores[1]])



manhattan = hl.plot.manhattan(gwas.p_value)
#show(manhattan)
manhattan.xaxis.axis_label_text_font_size = "25pt"
manhattan.yaxis.axis_label_text_font_size = "25pt"


output_file ('manhattan-1KGP3-sex', title='manhattan-1KGP3-sex', mode='inline')
save(manhattan)
blob = bucket.blob('manhattan-1KGP3-sex.html')
blob.upload_from_filename('manhattan-1KGP3-sex')


t2= time.time()
print((t2-t1) / 60)
