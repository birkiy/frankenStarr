# starr-pipe
This project contains a Snakemake based STARR-seq analysis pipeline that easy-to-handle for larger scale samples. Importantly, a metadata `samples.tsv` that contains information of each sample is utilized with a python script `configPY.py` that ease the data manipulation and generation of job requests from Snakemake.

# Running
To run this code prepare a `sample.tsv` that contains following columns:

Column | Description
-----------|----------
Cell | Optional..
Treatment1 | Optional..
Treatment2 | Optional..
Replicate | Optional..
`Raw` | Name for each sample. That will be link(to) file name. (Preferably, different and informative name)
`Library` | Sequencing type. (Paired or Single)
RawSample | Optional..
`Link` | Sample location, link(from). Direct name from sequencing.

Next, configure your reference location and project path in `configPY.py` [script](./configPY.py).

Running this pipeline in an HPC cluster would ease the running and save time. Please check `run.snakemake.sh` [script](./run.snakemake.sh). Preferably, write a `--cluster-config` [JSON file](./code/cluster.json), and run on home node.
- Note that logs are saved to `logs` folder, create if not exist.
- Note that snakemake will send each jobs to slurm system according to your credentials in server.
