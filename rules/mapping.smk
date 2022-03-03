



def getLib(raw):
    return sampleDF.loc[sampleDF[on].str.find(raw) != -1, "Library"].unique()[0]

def getRef(raw):
    return sampleDF.loc[sampleDF[on].str.find(raw) != -1, "Reference"].to_list()[0]





def getLink(wildcards):
    link = sampleDF.loc[sampleDF[on] == wildcards.raw, "Link"].to_list()[0]
    return f"{link}_{wildcards.run}.fq.gz"


def ifLink(raw):
    link = sampleDF.loc[sampleDF[on] == raw, "Link"].to_list()[0]
    if link != "-":
        return True
    else:
        return False


rule Links:
    input:
        getLink
    output:
        "links/{raw}.{run}.fq.gz"
    shell:
        """
        ln -s {input} {output}
        """




def getFq(wildcards):
    raw = wildcards.raw
    lnk = ifLink(raw)
    lib = getLib(wildcards.raw)
    if lnk:
        pathfrom = "links/"
    else:
        pathfrom = "rawData/"
    if lib == "Single":
        return pathfrom + "{raw}.1.fq.gz"
    elif lib == "Paired":
        return pathfrom + "{raw}.1.fq.gz", pathfrom + "{raw}.2.fq.gz"





rule bwa_mem:
    input:
        getFq
    output:
        "results/mapping/{raw}.raw.bam"
    threads:
        32
    shell:
        """
        bwa mem -t {threads} \
            {bwaIdx} \
            {input} | \
            samtools view -bS - > {output}
        """


rule BamProcess:
        input:
                "results/mapping/{raw}.raw.bam"
        output:
                "results/mapping/{raw}.coorsorted.bam"
        threads:
                32
        params:
                "-q 30"#"{config[PARAMS][BamProcess]}" # Note that you can add parameters as "-q 30 -F 1804"
        shell:
                """
                cat <(samtools view -H {input}) <(samtools view {params} {input}) | \
                samtools fixmate -m -@ {threads} - - | \
                samtools sort -@ {threads} -m 10G - | \
                samtools markdup -@ {threads} - {output}

                samtools index -c -@ {threads} {output}
                """




#########################################################################################



#
# rule MappingBWA:
#         input:
#                 unpack(getFastqs)
#         output:
#                 bam="results/mapping/raw/{raw}.bam"
#         threads:
#                 32
#         shell:
#                 """
#                 bwa mem -t {threads} {bwaIdx} {input} {params} | \
#                 samtools view -bS - > {output.bam}
#                 """



# def getFastqs(wildcards):
#         outputD = dict()
#         lib = getLib(wildcards)
#         if lib == "Single":
#                 outputD["U"] = f"links/{wildcards.raw}.U.fastq.gz"
#         elif lib == "Paired":
#                 outputD["R1"] = f"links/{wildcards.raw}.R1.fastq.gz"
#                 outputD["R2"] = f"links/{wildcards.raw}.R2.fastq.gz"
#         return outputD

#
#
# def getRepsToPool(wildcards):
#         reps=sorted(set(sampleDF.loc[sampleDF[on] == wildcards.sampleName, "Replicate"].to_list()))
#         return expand("results/mapping/{{sampleName}}.{rep}.coorsorted.bam", rep=reps)
#
#
# rule Pool:
#         input:
#                 getRepsToPool
#         output:
#                 "results/mapping/merged/{sampleName}.coorsorted.bam"
#         threads:
#                 32
#         shell:
#                 """
#                 samtools merge -O BAM -@ {threads} {output} {input}
#                 samtools index -@ {threads} {output}
#                 """

