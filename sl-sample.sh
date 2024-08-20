#!/bin/bash
#SBATCH --job-name=sample
#SBATCH --account=project_2005092
#SBATCH --partition=test
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=8
#SBATCH -o logs/%x.out
#SBATCH -e logs/%x.err

# Input parameters
url_file="/scratch/project_2005092/amanda/mahti-tokenisation/testi.txt"  
output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results"
probability_file=1          # Probability thresholds (0 to 1)
probability_row=0.02
mkdir -p temp
mkdir -p $output_path

module load parallel

# Main script logic
cat $url_file | while read line 
do
    rand_file=$(awk -v seed=$RANDOM 'BEGIN{srand(seed); print rand()}')
    if (( $(echo "$rand_file < $probability_file" | bc -l) )); then
        p=$(basename $line)    # for saving in temp
        basename="${p%.*}"     # for outfile without .zst
        # try to download
        if wget -O temp/$p $line; then
            echo "Download succeeded: $p $(date +"%T")"
        else
            echo "Download failed: $p $(date +"%T")"
            continue  # Skip to the next iteration if wget fails
        fi
        # process in parallel
        srun zstdcat "temp/$p" | parallel --pipe -j8 python3 sample.py $probability_row | pigz > "${output_path}/${basename}.gz"
        rm temp/$p
    fi
done
exit 0


