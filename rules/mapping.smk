

REFERENCE = "hg19"

bwaIdx = config[REFERENCE]["idx"]["bwa"]

def getLib(wildcards):
        try:
                return sampleDF.loc[sampleDF["Raw"] == wildcards.raw, "Library"].to_list()[0]
        except:
                return sampleDF.loc[sampleDF["SampleName"] == wildcards.raw, "Library"].to_list()[0]



def getFastqs(wildcards):
        outputD = dict()
        lib = getLib(wildcards)
        if lib == "Single":
                outputD["U"] = f"links/{wildcards.raw}.U.fastq.gz"
        elif lib == "Paired":
                outputD["R1"] = f"links/{wildcards.raw}.R1.fastq.gz"
                outputD["R2"] = f"links/{wildcards.raw}.R2.fastq.gz"
        return outputD



rule MappingBWA:
        input:
                unpack(getFastqs)
        output:
                bam="results/mapping/raw/{raw}.bam"
        threads:
                32
        shell:
                """
                bwa mem -t {threads} {bwaIdx} {input} {params} | \
                samtools view -bS - > {output.bam}
                """


rule BamProcess:
        input:
                "results/mapping/raw/{raw}.bam"
        output:
                "results/mapping/processed/{raw}.coorsorted.bam"
        threads:
                32
        params:
                "-q 60"#"{config[PARAMS][BamProcess]}" # Note that you can add parameters as "-q 30 -F 1804"
        shell:
                """
                cat <(samtools view -H {input}) <(samtools view {params} {input}) | \
                samtools fixmate -m -@ {threads} - - | \
                samtools sort -@ {threads} -m 10G - | \
                samtools markdup -@ {threads} - {output}

                samtools index -c -@ {threads} {output}
                """



def getRepsToPool(wildcards):
        reps=sorted(set(sampleDF.loc[sampleDF["SampleName"] == wildcards.sampleName, "Replicate"].to_list()))
        return expand("results/mapping/processed/{{sampleName}}.{rep}.coorsorted.bam", rep=reps)


rule Pool:
        input:
                getRepsToPool
        output:
                "results/mapping/merged/{sampleName}.coorsorted.bam"
        threads:
                32
        shell:
                """
                samtools merge -O BAM -@ {threads} {output} {input}
                samtools index -@ {threads} {output}
                """

