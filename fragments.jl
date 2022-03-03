

using CSV, DataFrames

function readCount(file)
    """
    A function to parse and read .raw.count tile file and returns a dictionary
    where the keys are tile ids and values are the corresponding number of that tile in sample
    """
    tiles = Dict()
    for line in readlines(file)
        Chr, Start, End, c = split(strip(line), "\t")
        tile = Chr * ":" * Start * "-" * End
        tiles[tile] = parse(Int, c)
    end
    return tiles
end



PROJECTPATH="./"
v = "/v3"




TILEPATH=PROJECTPATH * "/results/tile"

samples = [
"CAP.input.rep1",
"LNAbl.input.rep1",
"LNAbl.input.rep2",
"LNCaP.input.rep1",
"LNAbl.Capture.DMSO.DHT.rep1",
"LNAbl.Capture.DMSO.DHT.rep2",
"LNAbl.Capture.DMSO.DHT.rep3",
"LNAbl.Capture.DMSO.EtOH.rep1",
"LNAbl.Capture.DMSO.EtOH.rep2",
"LNAbl.Capture.DMSO.EtOH.rep3",
"LNAbl.Capture.ENZA.EtOH.rep1",
"LNAbl.Capture.ENZA.EtOH.rep2",
"LNAbl.Capture.ENZA.EtOH.rep3",
"LNCaP.Capture.DMSO.DHT.rep1",
"LNCaP.Capture.DMSO.DHT.rep2",
"LNCaP.Capture.DMSO.DHT.rep3",
"LNCaP.Capture.DMSO.EtOH.rep1",
"LNCaP.Capture.DMSO.EtOH.rep2",
"LNCaP.Capture.DMSO.EtOH.rep3",
"LNCaP.Capture.ENZA.EtOH.rep1",
"LNCaP.Capture.ENZA.EtOH.rep2",
"LNCaP.Capture.ENZA.EtOH.rep3"];




# Read the count files
TILES = Dict()
for sample in samples
    TILES[sample] = readCount(TILEPATH * "/tile-" * sample * ".raw.count")
    println(sample)
end


# Generate TileCollection from input libnraries (tileUnion)

tileLib1 = keys(TILES["LNCaP.input.rep1"]);
tileLib2 = keys(TILES["LNAbl.input.rep1"]);
tileLib3 = keys(TILES["LNAbl.input.rep2"]);


tileUnion = union(
tileLib1,
tileLib2,
tileLib3)


# Store it as a "BED"ish format
tileCollection = []
for tile in tileUnion
    Chr, Pos = split(tile, ":")
    Start, End = split(Pos, "-")
    push!(tileCollection, (Chr, parse(Int, Start), parse(Int, End), tile))
end


sort!(tileCollection) # Sort

# Write TileCollection to a BED file
tileCollection_f = open(PROJECTPATH * v * "/TileCollection.bed", "w")
for (Chr, Start, End, tile) in tileCollection
    write(tileCollection_f, Chr * "\t" * string(Start) * "\t" * string(End) * "\t" * tile * "\n")
end
close(tileCollection_f)



tileTable = zeros(length(tileCollection), length(samples));
for (j, sample) in enumerate(samples)
    for (i, tile) in enumerate(getindex.(tileCollection, 4))
        tileTable[i, j] += get(TILES[sample], tile, 0)
    end
end


tileDF = DataFrame(tileTable, :auto)
rename!(tileDF, Symbol.(samples))


tileDF[:index] = getindex.(tileCollection, 4)


CSV.write(PROJECTPATH * v * "/TileDF.tsv", tileDF[["index", samples...]], delim="\t")



```
run this code

capture=./capture.bed
PROJECTPATH=./

bedtools intersect -a $PROJECTPATH/$v/TileCollection.bed -b $capture -wa -wb > $PROJECTPATH/$v/ontarget.bed
awk '{print $1"\t"$2"\t"$3"\t"$4","$8}' $PROJECTPATH/$v/ontarget.bed > $PROJECTPATH/$v/OnTargetMap.bed
```





