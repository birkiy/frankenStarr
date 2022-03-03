#!/bin/bash


# sacct --format=User,Account,JobID,Jobname,partition,state,time,start,end,elapsed,MaxRss,MaxVMSize,nnodes,ncpus,nodelis
# srun -A users -p long -c 64 --mem=720G --time 1:00:00 --pty bash

# snakemake version: 5.26.1
cluster=./code/cluster.json

snakemake \
  --snakefile Snakefile -n --unlock

snakemake \
  --snakefile Snakefile \
  -n --dag | dot -Tpdf > Procedure.pdf

snakemake \
  --snakefile Snakefile \
  -n --rulegraph | dot -Tpdf > SimplifiedProcedure.pdf


mkdir logs

snakemake \
  --snakefile Snakefile \
  -j100 \
  --cluster-config $cluster  \
  --rerun-incomplete \
  --use-conda \
  --cluster "sbatch \
      -A {cluster.partition} \
      -c {cluster.c} \
      -t {cluster.time} \
      --mem {cluster.mem} \
      -o logs/{rule}_{wildcards} \
      -e logs/{rule}_{wildcards} "

