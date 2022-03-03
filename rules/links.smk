





PATH = "/groups/lackgrp/projects/col-zwart-starrseq-frankenstar"
rule Links:
        output:
                linkTo="links/{concat}.fastq.gz"
        message:
                "Executing Links rule from {input} to {output.linkTo}"
        run:
                linkFrom = sampleDF.loc[sampleDF["Concat"] == wildcards.concat, "Links"].to_list()[0]

                shell("""
                ln -s {PATH}/{linkFrom} {output.linkTo}
                """)

