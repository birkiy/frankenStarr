


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




sampleDF = pd.read_table(f"code/samples.tsv")


counts = [
    f"results/tile/tile-{raw}.raw.count"
    for raw in sampleDF["Raw"]
]

bw = [
    f"results/bigwig/{sampleName}.{type}.bw"
    for sampleName in  set(sampleDF.loc[sampleDF["SampleName"].str.find("input") == -1, "Raw"])
    for type in ["RPKM"]
] + [
    f"results/bigwig/{sampleName}.{type}.bamcov.bw"
    for sampleName in  set(sampleDF.loc[:,"Raw"])
    for type in ["RPKM"]
]


desiredOutputList = bw + counts

