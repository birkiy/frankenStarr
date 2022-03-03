


import pandas as pd



config = {
    "path" : "./",
    "hg19" :
        {
            "fasta" : "/groups/lackgrp/genomeAnnotations/hg19/hg19.fa",
            "idx" :
                {
                    "bwa" : "/groups/lackgrp/genomeAnnotations/hg19/hg19.bwa.idx"
                },
            "chrSize" : "/groups/lackgrp/genomeAnnotations/hg19/hg19.chrom.sizes",
            "blacklist" : "/groups/lackgrp/genomeAnnotations/hg19/hg19-blacklist.v2.bed"
        }
}


REFERENCE = "hg19"

bwaIdx = config[REFERENCE]["idx"]["bwa"]
blacklist = config[REFERENCE]["blacklist"]

################################################################################

on = "Raw"


sampleDF = pd.read_table(f"code/samples.tsv")


counts = [
    f"results/tile/tile-{raw}.raw.count"
    for raw in sampleDF[on]
]

desiredOutputList = bw

