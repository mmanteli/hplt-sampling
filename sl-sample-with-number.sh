#!/bin/bash
#SBATCH --job-name=sample
#SBATCH --account=project_2005092
#SBATCH --partition=medium
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=8
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

# Input parameters
START=$1
END=$2

if [[ $START -gt $END ]]
   then
       echo "Param START needs to be smaller than END"
       exit 1
fi

# change both of these for version
url_stem="https://data.hplt-project.org/one/monotext/cleaned/en/en_#.jsonl.zst"
output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_1_2"
probability_file=1.1          # Probability thresholds (0 to 1)
probability_row=0.01
mkdir -p temp
mkdir -p $output_path

echo "Loading module"
module load parallel

# Main script logic
for ((i=START;i<=END;i++)); do
    url=${url_stem/"#"/$i}
    echo "In ${url}"
    p=$(basename $url)    # for saving in temp
    bname="${p%.*}"     # for outfile without .zst
    if wget --no-verbose -O temp/$p $url; then
        echo "Download succeeded: $p $(date +"%T")"
    else
        echo "Download failed: $p $(date +"%T")"
        continue  # Skip to the next iteration if wget fails
    fi
    # process in parallel
    echo "processing temp/${p}"
    zstdcat "temp/$p" | parallel --pipe -j8 -k --block 10M python3 sample.py $probability_row | pigz > "${output_path}/${bname}.gz"
    echo "success with ${p} $(date +"%T")"
    rm temp/$p
done

cp logs/$SLURM_JOBID.out "logs/v_1_2_sample_${START}-${END}.out"
cp logs/$SLURM_JOBID.err "logs/v_1_2_sample_${START}-${END}.err"

exit 0


