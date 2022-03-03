


def getInput(wildcards):
        meta = wildcards.raw.split(".")
        cell = meta[0]
        inp = sampleDF.loc[(sampleDF["Cell"] == cell) & (sampleDF["Treatment"] == "input"), "Raw"].to_list()[0]
        return f"results/mapping/processed/{inp}.coorsorted.bam"



def getParamsBamCom(wildcards):
        lib = sampleDF.loc[(sampleDF["Raw"] == wildcards.raw) , "Library"].to_list()[0]
        defaults = "--samFlagInclude 64 "
        if lib == "Single":
            return f"{defaults} --extendReads 150 "
        elif lib == "Paired":
            return f"{defaults} --extendReads "


rule BamCom:
        input:
                bam="results/mapping/processed/{raw}.coorsorted.bam",
                inp=getInput
        output:
                bw="results/bigwig/{raw}.{type}.bw"
        params:
                getParamsBamCom
        threads:
                64
        shell:
                """
                bamCompare -b1 {input.bam} -b2 {input.inp} -o {output.bw} \
                -p {threads} \
                --scaleFactorsMethod None --normalizeUsing {wildcards.type} \
                {params}
                """



rule BamCov:
        input:
                "results/mapping/processed/{raw}.coorsorted.bam"
        output:
                "results/bigwig/{raw}.{type}.bamcov.bw"
        threads:
                64
        params:
                getParamsBamCom
        shell:
                """
                bamCoverage --bam {input} -o {output} -p {threads} \
                --normalizeUsing {wildcards.type} \
                {params}
                """

