

from configPY import *



rule all:
        input:
                expand("{desiredOutput}",
                desiredOutput=desiredOutputList)


include: "rules/links.smk"
include: "rules/mapping.smk"
include: "rules/tiles.smk"
include: "rules/bigwig.smk"

