


rule Fragment:
        input:
                "results/mapping/{raw}.raw.bam"
        output:
                "results/tile/{raw}.bedpe"
        message:
                "Executing Fragments rule for {wildcards}"
        threads:
                10
        shell:
                """
                samtools view -b -@ {threads} -f2 -F2048 {input} | \
                bedtools bamtobed -bedpe -i - > {output}
                """


rule Filter:
        input:
                "results/tile/{raw}.bedpe"
        output:
                "results/tile/{raw}.bed"
        threads:
                32
        shell:
                """
                awk '{{if ($8 > 30) print $0}}' {input} | \
                cut -f 1,2,6,7 | \
                sort -k 1,1 -k 2,2n --parallel={threads} | \
                bedtools intersect -v -a - -b {blacklist} > {output}
                """


rule CountTile:
        input:
                "results/tile/{raw}.bed"
        output:
                "results/tile/tile-{raw}.raw.count"
        threads:
                32
        shell:
                """
                cut -f1-3 {input} | \
                uniq -c | \
                awk -F ' ' '{{print $2"\t"$3"\t"$4"\t"$1}}' | \
                sort -k 1,1 -k 2,2n  --parallel={threads} > {output}
                """

