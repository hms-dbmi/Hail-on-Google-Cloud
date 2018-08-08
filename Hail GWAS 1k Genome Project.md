
# Hail overview 

### https://hail.is/docs/devel/tutorials-landing.html

Inès Krissaane 

### PHASE 1 - 1000 Genomes Project 

http://www.internationalgenome.org/

VCFs can be find in the public google bucket : 
https://console.cloud.google.com/storage/browser/genomics-public-data/1000-genomes/

### Hail environment and Python packages


```python
import hail as hl
import hail.expr.aggregators as agg
hl.init()
```

    /opt/conda/lib/python3.6/importlib/_bootstrap.py:219: RuntimeWarning: numpy.dtype size changed, may indicate binary incompatibility. Expected 96, got 88
      return f(*args, **kwds)
    /opt/conda/lib/python3.6/importlib/_bootstrap.py:219: RuntimeWarning: numpy.dtype size changed, may indicate binary incompatibility. Expected 96, got 88
      return f(*args, **kwds)
    Running on Apache Spark version 2.2.1
    SparkUI available at http://10.142.0.18:4040
    Welcome to
         __  __     <>__
        / /_/ /__  __/ /
       / __  / _ `/ / /
      /_/ /_/\_,_/_/_/   version devel-98f4d6a179b4
    NOTE: This is a beta version. Interfaces may change
      during the beta period. We recommend pulling
      the latest changes weekly.



```python
import numpy as np
import pandas as pd
from collections import Counter
from math import log, isnan
from pprint import pprint
from bokeh.io import show, output_notebook
from bokeh.plotting import figure
from bokeh.layouts import gridplot
from bokeh.models import Span
output_notebook()
import plotly
import time
import gcsfs
import csv
from bokeh.io import output_notebook, push_notebook, show
import seaborn as sb
import random
import gcsfs
fs = gcsfs.GCSFileSystem(project='avl-hail-ines')

```



    <div class="bk-root">
        <a href="https://bokeh.pydata.org" target="_blank" class="bk-logo bk-logo-small bk-logo-notebook"></a>
        <span id="fc3f1739-1046-40b6-9d6d-4b2a574ce589">Loading BokehJS ...</span>
    </div>




    No module named 'dask'


### Import the Matrix Table Files

You need to use `import_vcf` and `write` functions to write an MT file with the VCFs. 


```python
# Phase 1 - 1k Genome Project
mt = hl.read_matrix_table("gs://1k-genome/1000-genomes/VDS-of-all/ALL.chr.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.mt")
print('MT size: ', mt.count())
```

    MT size:  (39706715, 1092)


The `cache` is used to optimize some of the downstream operations.


```python
mt = hl.variant_qc(mt).cache()
```


```python
mt.describe()
```

    ----------------------------------------
    Global fields:
        None
    ----------------------------------------
    Column fields:
        's': str 
    ----------------------------------------
    Row fields:
        'locus': locus<GRCh37> 
        'alleles': array<str> 
        'rsid': str 
        'qual': float64 
        'filters': set<str> 
        'info': struct {
            LDAF: float64, 
            AVGPOST: float64, 
            RSQ: float64, 
            ERATE: float64, 
            THETA: float64, 
            CIEND: array<int32>, 
            CIPOS: array<int32>, 
            END: int32, 
            HOMLEN: array<int32>, 
            HOMSEQ: array<str>, 
            SVLEN: int32, 
            SVTYPE: str, 
            AC: array<int32>, 
            AN: int32, 
            AA: str, 
            AF: array<float64>, 
            AMR_AF: float64, 
            ASN_AF: float64, 
            AFR_AF: float64, 
            EUR_AF: float64, 
            VT: str, 
            SNPSOURCE: array<str>
        } 
        'variant_qc': struct {
            AC: array<int32>, 
            AF: array<float64>, 
            AN: int32, 
            homozygote_count: array<int32>, 
            n_called: int64, 
            n_not_called: int64, 
            call_rate: float32, 
            n_het: int64, 
            n_non_ref: int64, 
            het_freq_hwe: float64, 
            p_value_hwe: float64
        } 
    ----------------------------------------
    Entry fields:
        'GT': call 
        'DS': float64 
        'GL': array<float64> 
        'PL': array<int32> 
    ----------------------------------------
    Column key: ['s']
    Row key: ['locus', 'alleles']
    Partition key: ['locus']
    ----------------------------------------



```python
hl.summarize_variants(mt)
```

    ==============================
    Number of variants: 39706715
    ==============================
    Alleles per variant
    -------------------
      2 alleles: 39706715 variants
    ==============================
    Variants per contig
    -------------------
       1: 3007196 variants
       2: 3307592 variants
       3: 2763454 variants
       4: 2736765 variants
       5: 2530217 variants
       6: 2424425 variants
       7: 2215231 variants
       8: 2183839 variants
       9: 1652388 variants
      10: 1882663 variants
      11: 1894908 variants
      12: 1828006 variants
      13: 1373000 variants
      14: 1258254 variants
      15: 1130554 variants
      16: 1210619 variants
      17: 1046733 variants
      18: 1088820 variants
      19: 816115 variants
      20: 855166 variants
      21: 518965 variants
      22: 494328 variants
       X: 1487477 variants
    ==============================
    Allele type distribution
    ------------------------
            SNP: 38248779 alternate alleles
       Deletion: 872267 alternate alleles
      Insertion: 577895 alternate alleles
       Symbolic: 5488 alternate alleles
        Complex: 2286 alternate alleles
    ==============================



```python
mt.entry.take(5)
```




    [Struct(GT=0|0, DS=0.2, GL=[-0.18, -0.47, -2.42], PL=None),
     Struct(GT=0|0, DS=0.15, GL=[-0.24, -0.44, -1.16], PL=None),
     Struct(GT=0|0, DS=0.15, GL=[-0.15, -0.54, -3.12], PL=None),
     Struct(GT=0|1, DS=0.6, GL=[-0.48, -0.48, -0.48], PL=None),
     Struct(GT=0|0, DS=0.55, GL=[-0.48, -0.48, -0.48], PL=None)]




```python
mt.entry.show()
```

    +---------------+------------+---------+------+-------------+---------------------+
    | locus         | alleles    | s       | GT   |          DS | GL                  |
    +---------------+------------+---------+------+-------------+---------------------+
    | locus<GRCh37> | array<str> | str     | call |     float64 | array<float64>      |
    +---------------+------------+---------+------+-------------+---------------------+
    | 1:10583       | ["G","A"]  | HG00096 | 0|0  | 2.00000e-01 | [-0.18,-0.47,-2.42] |
    | 1:10583       | ["G","A"]  | HG00097 | 0|0  | 1.50000e-01 | [-0.24,-0.44,-1.16] |
    | 1:10583       | ["G","A"]  | HG00099 | 0|0  | 1.50000e-01 | [-0.15,-0.54,-3.12] |
    | 1:10583       | ["G","A"]  | HG00100 | 0|1  | 6.00000e-01 | [-0.48,-0.48,-0.48] |
    | 1:10583       | ["G","A"]  | HG00101 | 0|0  | 5.50000e-01 | [-0.48,-0.48,-0.48] |
    | 1:10583       | ["G","A"]  | HG00102 | 0|1  | 9.50000e-01 | [-1.92,-0.01,-2.5]  |
    | 1:10583       | ["G","A"]  | HG00103 | 0|0  | 5.00000e-02 | [-0.05,-0.93,-5.0]  |
    | 1:10583       | ["G","A"]  | HG00104 | 0|0  | 1.00000e-01 | [-0.11,-0.66,-4.22] |
    | 1:10583       | ["G","A"]  | HG00106 | 0|1  | 5.50000e-01 | [-0.28,-0.43,-0.96] |
    | 1:10583       | ["G","A"]  | HG00108 | 0|0  | 4.50000e-01 | [-0.48,-0.48,-0.48] |
    +---------------+------------+---------+------+-------------+---------------------+
    
    +--------------+
    | PL           |
    +--------------+
    | array<int32> |
    +--------------+
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    | null         |
    +--------------+
    showing top 10 rows
    


### Annotation file : encode the label Super_population 


```python
# Import Annotation File as a hail.Table
table = (hl.import_table('gs://1k-genome/1000-genomes/other/sample_info/sample_info.csv', delimiter=',', missing='', quote='"').key_by('Sample'))
table.describe()
```

    ----------------------------------------
    Global fields:
        None
    ----------------------------------------
    Row fields:
        'Sample': str 
        'Family_ID': str 
        'Population': str 
        'Population_Description': str 
        'Gender': str 
        'Relationship': str 
        'Unexpected_Parent_Child': str 
        'Non_Paternity': str 
        'Siblings': str 
        'Grandparents': str 
        'Avuncular': str 
        'Half_Siblings': str 
        'Unknown_Second_Order': str 
        'Third_Order': str 
        'In_Low_Coverage_Pilot': str 
        'LC_Pilot_Platforms': str 
        'LC_Pilot_Centers': str 
        'In_High_Coverage_Pilot': str 
        'HC_Pilot_Platforms': str 
        'HC_Pilot_Centers': str 
        'In_Exon_Targetted_Pilot': str 
        'ET_Pilot_Platforms': str 
        'ET_Pilot_Centers': str 
        'Has_Sequence_in_Phase1': str 
        'Phase1_LC_Platform': str 
        'Phase1_LC_Centers': str 
        'Phase1_E_Platform': str 
        'Phase1_E_Centers': str 
        'In_Phase1_Integrated_Variant_Set': str 
        'Has_Phase1_chrY_SNPS': str 
        'Has_phase1_chrY_Deletions': str 
        'Has_phase1_chrMT_SNPs': str 
        'Main_project_LC_Centers': str 
        'Main_project_LC_platform': str 
        'Total_LC_Sequence': str 
        'LC_Non_Duplicated_Aligned_Coverage': str 
        'Main_Project_E_Centers': str 
        'Main_Project_E_Platform': str 
        'Total_Exome_Sequence': str 
        'X_Targets_Covered_to_20x_or_greater': str 
        'VerifyBam_E_Omni_Free': str 
        'VerifyBam_E_Affy_Free': str 
        'VerifyBam_E_Omni_Chip': str 
        'VerifyBam_E_Affy_Chip': str 
        'VerifyBam_LC_Omni_Free': str 
        'VerifyBam_LC_Affy_Free': str 
        'VerifyBam_LC_Omni_Chip': str 
        'VerifyBam_LC_Affy_Chip': str 
        'LC_Indel_Ratio': str 
        'E_Indel_Ratio': str 
        'LC_Passed_QC': str 
        'E_Passed_QC': str 
        'In_Final_Phase_Variant_Calling': str 
        'Has_Omni_Genotypes': str 
        'Has_Axiom_Genotypes': str 
        'Has_Affy_6_0_Genotypes': str 
        'Has_Exome_LOF_Genotypes': str 
        'EBV_Coverage': str 
        'DNA_Source_from_Coriell': str 
        'Has_Sequence_from_Blood_in_Index': str 
        'Super_Population': str 
        'Super_Population_Description': str 
    ----------------------------------------
    Key: ['Sample']
    ----------------------------------------


    2018-08-07 22:49:33 Hail: INFO: Reading table with no type imputation
      Loading column 'Sample' as type 'str' (type not specified)
      Loading column 'Family_ID' as type 'str' (type not specified)
      Loading column 'Population' as type 'str' (type not specified)
      Loading column 'Population_Description' as type 'str' (type not specified)
      Loading column 'Gender' as type 'str' (type not specified)
      Loading column 'Relationship' as type 'str' (type not specified)
      Loading column 'Unexpected_Parent_Child' as type 'str' (type not specified)
      Loading column 'Non_Paternity' as type 'str' (type not specified)
      Loading column 'Siblings' as type 'str' (type not specified)
      Loading column 'Grandparents' as type 'str' (type not specified)
      Loading column 'Avuncular' as type 'str' (type not specified)
      Loading column 'Half_Siblings' as type 'str' (type not specified)
      Loading column 'Unknown_Second_Order' as type 'str' (type not specified)
      Loading column 'Third_Order' as type 'str' (type not specified)
      Loading column 'In_Low_Coverage_Pilot' as type 'str' (type not specified)
      Loading column 'LC_Pilot_Platforms' as type 'str' (type not specified)
      Loading column 'LC_Pilot_Centers' as type 'str' (type not specified)
      Loading column 'In_High_Coverage_Pilot' as type 'str' (type not specified)
      Loading column 'HC_Pilot_Platforms' as type 'str' (type not specified)
      Loading column 'HC_Pilot_Centers' as type 'str' (type not specified)
      Loading column 'In_Exon_Targetted_Pilot' as type 'str' (type not specified)
      Loading column 'ET_Pilot_Platforms' as type 'str' (type not specified)
      Loading column 'ET_Pilot_Centers' as type 'str' (type not specified)
      Loading column 'Has_Sequence_in_Phase1' as type 'str' (type not specified)
      Loading column 'Phase1_LC_Platform' as type 'str' (type not specified)
      Loading column 'Phase1_LC_Centers' as type 'str' (type not specified)
      Loading column 'Phase1_E_Platform' as type 'str' (type not specified)
      Loading column 'Phase1_E_Centers' as type 'str' (type not specified)
      Loading column 'In_Phase1_Integrated_Variant_Set' as type 'str' (type not specified)
      Loading column 'Has_Phase1_chrY_SNPS' as type 'str' (type not specified)
      Loading column 'Has_phase1_chrY_Deletions' as type 'str' (type not specified)
      Loading column 'Has_phase1_chrMT_SNPs' as type 'str' (type not specified)
      Loading column 'Main_project_LC_Centers' as type 'str' (type not specified)
      Loading column 'Main_project_LC_platform' as type 'str' (type not specified)
      Loading column 'Total_LC_Sequence' as type 'str' (type not specified)
      Loading column 'LC_Non_Duplicated_Aligned_Coverage' as type 'str' (type not specified)
      Loading column 'Main_Project_E_Centers' as type 'str' (type not specified)
      Loading column 'Main_Project_E_Platform' as type 'str' (type not specified)
      Loading column 'Total_Exome_Sequence' as type 'str' (type not specified)
      Loading column 'X_Targets_Covered_to_20x_or_greater' as type 'str' (type not specified)
      Loading column 'VerifyBam_E_Omni_Free' as type 'str' (type not specified)
      Loading column 'VerifyBam_E_Affy_Free' as type 'str' (type not specified)
      Loading column 'VerifyBam_E_Omni_Chip' as type 'str' (type not specified)
      Loading column 'VerifyBam_E_Affy_Chip' as type 'str' (type not specified)
      Loading column 'VerifyBam_LC_Omni_Free' as type 'str' (type not specified)
      Loading column 'VerifyBam_LC_Affy_Free' as type 'str' (type not specified)
      Loading column 'VerifyBam_LC_Omni_Chip' as type 'str' (type not specified)
      Loading column 'VerifyBam_LC_Affy_Chip' as type 'str' (type not specified)
      Loading column 'LC_Indel_Ratio' as type 'str' (type not specified)
      Loading column 'E_Indel_Ratio' as type 'str' (type not specified)
      Loading column 'LC_Passed_QC' as type 'str' (type not specified)
      Loading column 'E_Passed_QC' as type 'str' (type not specified)
      Loading column 'In_Final_Phase_Variant_Calling' as type 'str' (type not specified)
      Loading column 'Has_Omni_Genotypes' as type 'str' (type not specified)
      Loading column 'Has_Axiom_Genotypes' as type 'str' (type not specified)
      Loading column 'Has_Affy_6_0_Genotypes' as type 'str' (type not specified)
      Loading column 'Has_Exome_LOF_Genotypes' as type 'str' (type not specified)
      Loading column 'EBV_Coverage' as type 'str' (type not specified)
      Loading column 'DNA_Source_from_Coriell' as type 'str' (type not specified)
      Loading column 'Has_Sequence_from_Blood_in_Index' as type 'str' (type not specified)
      Loading column 'Super_Population' as type 'str' (type not specified)
      Loading column 'Super_Population_Description' as type 'str' (type not specified)
    



```python
# Import Annotation File as a pandas.DataFrame
with fs.open('1k-genome/1000-genomes/other/sample_info/sample_info.csv',"rt") as f:
    data = pd.read_csv(f, na_values = str, header = 0)
print ('Annotation File Size : ', data.shape)
```

    Annotation File Size :  (3500, 62)



```python
data = data.astype(str)
data[['In_Low_Coverage_Pilot', 'In_High_Coverage_Pilot', 'In_Exon_Targetted_Pilot', 'Has_Sequence_in_Phase1', 
      'In_Phase1_Integrated_Variant_Set',"Has_Phase1_chrY_SNPS",
        'Has_phase1_chrY_Deletions','Has_phase1_chrMT_SNPs', 'Total_LC_Sequence','LC_Non_Duplicated_Aligned_Coverage', 'Total_Exome_Sequence',
        'X_Targets_Covered_to_20x_or_greater','VerifyBam_E_Omni_Free','VerifyBam_E_Affy_Free','VerifyBam_E_Omni_Chip','VerifyBam_E_Affy_Chip','VerifyBam_LC_Omni_Free',                 
        'VerifyBam_LC_Affy_Free', 'VerifyBam_LC_Omni_Chip','VerifyBam_LC_Affy_Chip','LC_Indel_Ratio','E_Indel_Ratio',                          
        'LC_Passed_QC', 'E_Passed_QC', 'In_Final_Phase_Variant_Calling','Has_Omni_Genotypes','Has_Axiom_Genotypes','Has_Affy_6_0_Genotypes',                 
        'Has_Exome_LOF_Genotypes','EBV_Coverage', 
        'Has_Sequence_from_Blood_in_Index' ]] = data[['In_Low_Coverage_Pilot', 'In_High_Coverage_Pilot', 'In_Exon_Targetted_Pilot', 'Has_Sequence_in_Phase1', 'In_Phase1_Integrated_Variant_Set',"Has_Phase1_chrY_SNPS",
        'Has_phase1_chrY_Deletions','Has_phase1_chrMT_SNPs', 'Total_LC_Sequence','LC_Non_Duplicated_Aligned_Coverage', 'Total_Exome_Sequence',
        'X_Targets_Covered_to_20x_or_greater','VerifyBam_E_Omni_Free','VerifyBam_E_Affy_Free','VerifyBam_E_Omni_Chip','VerifyBam_E_Affy_Chip','VerifyBam_LC_Omni_Free',                 
        'VerifyBam_LC_Affy_Free',                 
        'VerifyBam_LC_Omni_Chip',                 
        'VerifyBam_LC_Affy_Chip',                 
        'LC_Indel_Ratio',                         
        'E_Indel_Ratio',                          
        'LC_Passed_QC',                           
        'E_Passed_QC',                            
        'In_Final_Phase_Variant_Calling',         
        'Has_Omni_Genotypes',                     
        'Has_Axiom_Genotypes',                    
        'Has_Affy_6_0_Genotypes',                 
        'Has_Exome_LOF_Genotypes',                
        'EBV_Coverage', 'Has_Sequence_from_Blood_in_Index' ]].astype(float)
```

We use the *LabelEncoder* method  from `scikit-learn` to encode the label Super Population which contains 4 groups for phase 1.


```python
from sklearn.preprocessing import LabelEncoder
key = data['Super_Population'].values

#create Label encoder for Super_Population
le = LabelEncoder()
le.fit(['SAS', 'EUR', 'AFR', 'AMR', 'EAS'])

#append to the Dataframe
data["Super_Population_Classification"] = pd.Series(le.transform(key), index=data.index)
```

### Annotate the MT file


```python
#Add the label Super_Population_Classification 
table1 = hl.Table.to_pandas(table)
table1["Super_Population_Classification"] = pd.Series(le.transform(key).astype(float)) 
table1 = hl.Table.from_pandas(table1).key_by('Sample') 
```

    2018-08-07 22:49:34 Hail: INFO: Coerced sorted dataset


We use the `annotate_cols` method to join the table with the MatrixTable containing our dataset.


```python
#Annotate the MF file
mt = mt.annotate_cols(**table1[mt.s])
```

    2018-08-07 22:49:44 Hail: INFO: Coerced almost-sorted dataset
    2018-08-07 22:50:11 Hail: INFO: Ordering unsorted dataset with network shuffle


### Query functions and the Hail Expression Language

The `aggregate` method can be used to aggregate over rows of the table.
`counter` is an aggregation function that counts the number of occurrences of each unique element. We can use this to pull out the population distribution by passing in a Hail Expression for the field that we want to count by.


```python
pprint(table1.aggregate(agg.counter(table1.Super_Population)))
```

    2018-08-07 22:50:40 Hail: INFO: Coerced almost-sorted dataset
    2018-08-07 22:51:10 Hail: INFO: Ordering unsorted dataset with network shuffle


    {'AFR': 1018, 'AMR': 535, 'EAS': 617, 'EUR': 669, 'SAS': 661}



```python
snp_counts = mt.aggregate_rows(agg.counter(hl.Struct(ref=mt.alleles[0], alt=mt.alleles[1])))
```

We can list the counts in descending order using Python’s Counter class.
from collections import Counter
counts = Counter(snp_counts)
counts.most_common()
### Quality control

QC is entirely based on the ability to understand the properties of a dataset. In Hail, the `sample_qc` method produces a set of useful metrics and stores them in a column field.


```python
mt = hl.sample_qc(mt)
```


```python
p = hl.plot.histogram(mt.sample_qc.call_rate, range=(.88,1), legend='Call Rate')
show(p)
```








  <div class="bk-root" id="09a6f098-6fd6-4501-a848-76a16f15d08b"></div>





### GWAS

####  Logistic Regression


```python
# Filter for only 2 sub populations then do logistic regression
mt = mt.filter_cols(((mt.col.Super_Population_Classification == 0) | (mt.col.Super_Population_Classification == 1)))

print("After filtering for only 2 SupPopulations, %d/1092 samples remaining" % mt.count_cols())
print ("The SuperPopulations are: ", le.inverse_transform([0, 1]))
```

    After filtering for only 2 SupPopulations, 427/1092 samples remaining
    The SuperPopulations are:  ['AFR' 'AMR']


    /opt/conda/lib/python3.6/site-packages/sklearn/preprocessing/label.py:151: DeprecationWarning:
    
    The truth value of an empty array is ambiguous. Returning False, but in future this will result in an error. Use `array.size > 0` to check that an array is not empty.
    


The example above considers a model of the form
	``` Prob(population) = sigmoid(β0+β1gt+ε),ε∼N(0,σ2) ``` 
where sigmoid is the sigmoid function, the genotype gt is coded as 0 for HomRef, 1 for Het, and 2 for HomVar, and the covariate is.female is coded as for 1 for True (female) and 0 for False (male). The null model sets β1=0.



```python
#Logistic Regression
gwas_logistic = hl.logistic_regression(
           test='wald',
           y=mt.col.Super_Population_Classification,
           x=mt.GT.n_alt_alleles()
       )
gwas_logistic.row.describe()
gwas_logistic.describe()
```

    2018-08-07 23:00:00 Hail: INFO: logistic_regression: running wald on 427 samples for response variable y,
        with input variable x, intercept, and 0 additional covariates...


    --------------------------------------------------------
    Type:
        struct {
            locus: locus<GRCh37>, 
            alleles: array<str>, 
            rsid: str, 
            qual: float64, 
            filters: set<str>, 
            info: struct {
                LDAF: float64, 
                AVGPOST: float64, 
                RSQ: float64, 
                ERATE: float64, 
                THETA: float64, 
                CIEND: array<int32>, 
                CIPOS: array<int32>, 
                END: int32, 
                HOMLEN: array<int32>, 
                HOMSEQ: array<str>, 
                SVLEN: int32, 
                SVTYPE: str, 
                AC: array<int32>, 
                AN: int32, 
                AA: str, 
                AF: array<float64>, 
                AMR_AF: float64, 
                ASN_AF: float64, 
                AFR_AF: float64, 
                EUR_AF: float64, 
                VT: str, 
                SNPSOURCE: array<str>
            }, 
            variant_qc: struct {
                AC: array<int32>, 
                AF: array<float64>, 
                AN: int32, 
                homozygote_count: array<int32>, 
                n_called: int64, 
                n_not_called: int64, 
                call_rate: float32, 
                n_het: int64, 
                n_non_ref: int64, 
                het_freq_hwe: float64, 
                p_value_hwe: float64
            }, 
            logreg: struct {
                beta: float64, 
                standard_error: float64, 
                z_stat: float64, 
                p_value: float64, 
                fit: struct {
                    n_iterations: int32, 
                    converged: bool, 
                    exploded: bool
                }
            }
        }
    --------------------------------------------------------
    Source:
        <hail.matrixtable.MatrixTable object at 0x7fdb7e102b70>
    Index:
        ['row']
    --------------------------------------------------------
    ----------------------------------------
    Global fields:
        None
    ----------------------------------------
    Column fields:
        's': str 
        'Family_ID': str 
        'Population': str 
        'Population_Description': str 
        'Gender': str 
        'Relationship': str 
        'Unexpected_Parent_Child': str 
        'Non_Paternity': str 
        'Siblings': str 
        'Grandparents': str 
        'Avuncular': str 
        'Half_Siblings': str 
        'Unknown_Second_Order': str 
        'Third_Order': str 
        'In_Low_Coverage_Pilot': str 
        'LC_Pilot_Platforms': str 
        'LC_Pilot_Centers': str 
        'In_High_Coverage_Pilot': str 
        'HC_Pilot_Platforms': str 
        'HC_Pilot_Centers': str 
        'In_Exon_Targetted_Pilot': str 
        'ET_Pilot_Platforms': str 
        'ET_Pilot_Centers': str 
        'Has_Sequence_in_Phase1': str 
        'Phase1_LC_Platform': str 
        'Phase1_LC_Centers': str 
        'Phase1_E_Platform': str 
        'Phase1_E_Centers': str 
        'In_Phase1_Integrated_Variant_Set': str 
        'Has_Phase1_chrY_SNPS': str 
        'Has_phase1_chrY_Deletions': str 
        'Has_phase1_chrMT_SNPs': str 
        'Main_project_LC_Centers': str 
        'Main_project_LC_platform': str 
        'Total_LC_Sequence': str 
        'LC_Non_Duplicated_Aligned_Coverage': str 
        'Main_Project_E_Centers': str 
        'Main_Project_E_Platform': str 
        'Total_Exome_Sequence': str 
        'X_Targets_Covered_to_20x_or_greater': str 
        'VerifyBam_E_Omni_Free': str 
        'VerifyBam_E_Affy_Free': str 
        'VerifyBam_E_Omni_Chip': str 
        'VerifyBam_E_Affy_Chip': str 
        'VerifyBam_LC_Omni_Free': str 
        'VerifyBam_LC_Affy_Free': str 
        'VerifyBam_LC_Omni_Chip': str 
        'VerifyBam_LC_Affy_Chip': str 
        'LC_Indel_Ratio': str 
        'E_Indel_Ratio': str 
        'LC_Passed_QC': str 
        'E_Passed_QC': str 
        'In_Final_Phase_Variant_Calling': str 
        'Has_Omni_Genotypes': str 
        'Has_Axiom_Genotypes': str 
        'Has_Affy_6_0_Genotypes': str 
        'Has_Exome_LOF_Genotypes': str 
        'EBV_Coverage': str 
        'DNA_Source_from_Coriell': str 
        'Has_Sequence_from_Blood_in_Index': str 
        'Super_Population': str 
        'Super_Population_Description': str 
        'Super_Population_Classification': float64 
        'sample_qc': struct {
            call_rate: float64, 
            n_called: int64, 
            n_not_called: int64, 
            n_hom_ref: int64, 
            n_het: int64, 
            n_hom_var: int64, 
            n_non_ref: int64, 
            n_singleton: int64, 
            n_snp: int64, 
            n_insertion: int64, 
            n_deletion: int64, 
            n_transition: int64, 
            n_transversion: int64, 
            n_star: int64, 
            r_ti_tv: float64, 
            r_het_hom_var: float64, 
            r_insertion_deletion: float64
        } 
    ----------------------------------------
    Row fields:
        'locus': locus<GRCh37> 
        'alleles': array<str> 
        'rsid': str 
        'qual': float64 
        'filters': set<str> 
        'info': struct {
            LDAF: float64, 
            AVGPOST: float64, 
            RSQ: float64, 
            ERATE: float64, 
            THETA: float64, 
            CIEND: array<int32>, 
            CIPOS: array<int32>, 
            END: int32, 
            HOMLEN: array<int32>, 
            HOMSEQ: array<str>, 
            SVLEN: int32, 
            SVTYPE: str, 
            AC: array<int32>, 
            AN: int32, 
            AA: str, 
            AF: array<float64>, 
            AMR_AF: float64, 
            ASN_AF: float64, 
            AFR_AF: float64, 
            EUR_AF: float64, 
            VT: str, 
            SNPSOURCE: array<str>
        } 
        'variant_qc': struct {
            AC: array<int32>, 
            AF: array<float64>, 
            AN: int32, 
            homozygote_count: array<int32>, 
            n_called: int64, 
            n_not_called: int64, 
            call_rate: float32, 
            n_het: int64, 
            n_non_ref: int64, 
            het_freq_hwe: float64, 
            p_value_hwe: float64
        } 
        'logreg': struct {
            beta: float64, 
            standard_error: float64, 
            z_stat: float64, 
            p_value: float64, 
            fit: struct {
                n_iterations: int32, 
                converged: bool, 
                exploded: bool
            }
        } 
    ----------------------------------------
    Entry fields:
        'GT': call 
        'DS': float64 
        'GL': array<float64> 
        'PL': array<int32> 
    ----------------------------------------
    Column key: ['s']
    Row key: ['locus', 'alleles']
    Partition key: ['locus']
    ----------------------------------------



```python
def qqplot(pvals):
    spvals = sorted(filter(lambda x: x and not (isnan(x)), pvals))
    exp = [-log(float(i) / len(spvals), 10) for i in np.arange(1, len(spvals) + 1, 1)]
    obs = [-log(p, 10) for p in spvals]
    p = figure(title="Q Q Plot",
              x_axis_label = 'Expected P-Value (-log10 scale)',
              y_axis_label = 'Observe P-Value (-log10 scale)')
    p.scatter(x=exp, y=obs, color = 'black')
    bound = max(max(exp), max(obs)) * 1.1
    p.line([0, bound], [0, bound], color = 'red')
    show(p)
```
pvals = gwas_logistic.logreg.p_value.collect()
qqplot(pvals)
####  Linear Regression


```python
#Linear Regression
gwas_linear = hl.linear_regression(
           test='wald',
           y=mt.Super_Population_Classification,
           x=mt.GT.n_alt_alleles(),
       )
gwas_linear.row.describe()
```

    2018-08-08 02:09:22 Hail: INFO: linear_regression: running on 427 samples for 1 response variable y,
        with input variable x, intercept, and 0 additional covariates...


    --------------------------------------------------------
    Type:
        struct {
            locus: locus<GRCh37>, 
            alleles: array<str>, 
            rsid: str, 
            qual: float64, 
            filters: set<str>, 
            info: struct {
                LDAF: float64, 
                AVGPOST: float64, 
                RSQ: float64, 
                ERATE: float64, 
                THETA: float64, 
                CIEND: array<int32>, 
                CIPOS: array<int32>, 
                END: int32, 
                HOMLEN: array<int32>, 
                HOMSEQ: array<str>, 
                SVLEN: int32, 
                SVTYPE: str, 
                AC: array<int32>, 
                AN: int32, 
                AA: str, 
                AF: array<float64>, 
                AMR_AF: float64, 
                ASN_AF: float64, 
                AFR_AF: float64, 
                EUR_AF: float64, 
                VT: str, 
                SNPSOURCE: array<str>
            }, 
            variant_qc: struct {
                AC: array<int32>, 
                AF: array<float64>, 
                AN: int32, 
                homozygote_count: array<int32>, 
                n_called: int64, 
                n_not_called: int64, 
                call_rate: float32, 
                n_het: int64, 
                n_non_ref: int64, 
                het_freq_hwe: float64, 
                p_value_hwe: float64
            }, 
            linreg: struct {
                n: int32, 
                sum_x: float64, 
                y_transpose_x: float64, 
                beta: float64, 
                standard_error: float64, 
                t_stat: float64, 
                p_value: float64
            }
        }
    --------------------------------------------------------
    Source:
        <hail.matrixtable.MatrixTable object at 0x7fd9fd661080>
    Index:
        ['row']
    --------------------------------------------------------

p = hl.plot.qq(gwas_linear.linreg.p_value)
show(p)
### PCA

The linear_regression method can also take column fields to use as covariates. We already annotated our samples with reported ancestry, but it is good to be skeptical of these labels due to human error. Genomes don’t have that problem! Instead of using reported ancestry, we will use genetic ancestry by including computed principal components in our model.

The pca method produces eigenvalues as a list and sample PCs as a Table, and can also produce variant loadings when asked. The hwe_normalized_pca method does the same, using HWE-normalized genotypes for the PCA.


```python
eigenvalues, scores, loadings = hl.hwe_normalized_pca(mt.GT, k=5)
```

    2018-08-07 23:30:30 Hail: INFO: hwe_normalized_pca: running PCA using 31139327 variants.
    2018-08-07 23:31:06 Hail: INFO: pca: running PCA with 5 components...



```python
p = hl.plot.scatter(scores.scores[0], scores.scores[1],
                    label= mt.cols()[scores.s].Super_Population,
                    title='PCA', xlabel='PC1', ylabel='PC2')
show(p)
```

    2018-08-08 00:48:47 Hail: INFO: Coerced sorted dataset
    2018-08-08 00:48:48 Hail: INFO: Coerced sorted dataset









  <div class="bk-root" id="3fbbbda1-f0d4-4967-a05d-b888427535f7"></div>





Result of PCA phase 1 in 3D : 

<a href="https://plot.ly/~ineskris/238.embed">PCA Phase 1 </a>

Now we can rerun our linear regression, controlling by the first few principal components.


```python
#table for pca data 
pcatable = scores.select(Super_Population = mt.cols()[scores.s].Population,
                             PC1 = scores.scores[0],
                             PC2 = scores.scores[1]
                           )

pca_df = hl.Table.to_pandas(pcatable)
mt = mt.annotate_cols(pca = scores[mt.s])
```

    2018-08-08 01:58:45 Hail: INFO: Coerced sorted dataset
    2018-08-08 01:58:45 Hail: INFO: Coerced sorted dataset


### Adjust Linear Regression with PCA and Manhattan plot


```python
gwas_logistic2 = hl.logistic_regression(
           test='lrt',
           y=mt.col.Super_Population_Classification,
           x=mt.GT.n_alt_alleles(),
           covariates=[mt.pca.scores[0], mt.pca.scores[1], mt.pca.scores[2]])
```

    2018-08-08 02:00:16 Hail: INFO: logistic_regression: running lrt on 427 samples for response variable y,
        with input variable x, intercept, and 3 additional covariates...

pvals = gwas_logistic2.logreg.p_value.collect()
qqplot(pvals)

```python
gwas_linear2 = hl.linear_regression(
           test='wald',
           y=mt.Super_Population_Classification,
           x=mt.GT.n_alt_alleles(),
           covariates=[mt.pca.scores[0], mt.pca.scores[1], mt.pca.scores[2]])

```

    2018-08-08 02:01:51 Hail: INFO: linear_regression: running on 427 samples for 1 response variable y,
        with input variable x, intercept, and 3 additional covariates...

p = hl.plot.qq(gwas_linear2.linreg.p_value)
show(p)

```python
## Manhattan plot
from bokeh.plotting import figure, output_file, show
filtered = gwas_linear2.filter_rows(gwas_linear2.row.linreg.p_value < .008, keep = True)
filtered.count()
```




    (737705, 427)




```python
x = hl.plot.manhattan(filtered.row.linreg.p_value, locus=filtered.row.locus, title="Practice", size=4, hover_fields=None)
show(x)
```








  <div class="bk-root" id="b960c0cf-ebcb-4194-9d1b-a9a9f7c20898"></div>




