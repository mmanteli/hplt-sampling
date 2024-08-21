#!/bin/bash
#SBATCH --job-name=sample
#SBATCH --account=project_2005092
#SBATCH --partition=medium
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=8
#SBATCH -o logs/%x.out
#SBATCH -e logs/%x.err

# Input parameters
url_file="/scratch/project_2005092/amanda/en_map_v1_1.txt"  
output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results"
probability_file=1.1          # Probability thresholds (0 to 1)
probability_row=0.001
mkdir -p temp
mkdir -p $output_path

echo "Loading module"
module load parallel

# Main script logic
cat $url_file | while read line
do
    rand_file=$(awk -v seed=$RANDOM 'BEGIN{srand(seed); print rand()}')
    if (( $(echo "$rand_file < $probability_file" | bc -l) )); then
        echo "In ${line}"
        p=$(basename $line)    # for saving in temp
        basename="${p%.*}"     # for outfile without .zst
        if wget --no-verbose -O temp/$p $line; then
            echo "Download succeeded: $p $(date +"%T")"
        else
            echo "Download failed: $p $(date +"%T")"
            continue  # Skip to the next iteration if wget fails
        fi
        # process in parallel
        echo "processing temp/${p}"
        zstdcat "temp/$p" | parallel --pipe -j8 -k --block 10M python3 sample.py $probability_row | pigz > "${output_path}/${basename}.gz"
        echo "success with ${p}"
        rm temp/$p
    fi
done
exit 0


