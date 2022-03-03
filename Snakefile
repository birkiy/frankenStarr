

from configPY import *



rule all:
        input:
                expand("{desiredOutput}",
                desiredOutput=desiredOutputList)


include: "rules/mapping.smk"
include: "rules/tiles.smk"

