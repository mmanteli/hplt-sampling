#!/bin/bash
#SBATCH --job-name=sample
#SBATCH --account=project_2005092
#SBATCH --partition=medium
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=64
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

# Input parameters
version=$1
START=$2
END=$3

if [[ $START -gt $END ]]
   then
       echo "Param START needs to be smaller than or equal to END"
       exit 1
fi

# CHANGE THESE
#url_stem="https://data.hplt-project.org/two/cleaned/eng_Latn/#.jsonl.zst"
#output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_2_0"   # basename of this added to logs
# Probability threshold (0 to 1)
#probability_row=0.0017          # probability to select a row


case $version in
    1_0)
        url_stem="https://data.hplt-project.org/one/monotext/en/#.jsonl.zst"
        output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_1_0"
        probability_row=0.023  # these all have +0.002 so that we go over 300B tokens
        ;;
    1_1)
        url_stem="https://data.hplt-project.org/one/monotext/deduplicated/en/en_#.jsonl.zst"
        output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_1_1"
        probability_row=0.078
        ;;
    1_2)
        url_stem="https://data.hplt-project.org/one/monotext/cleaned/en/en_#.jsonl.zst"
        output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_1_2"
        probability_row=0.098
        ;;
    2_0 | 2_0cleaned)
        url_stem="https://data.hplt-project.org/two/cleaned/eng_Latn/#.jsonl.zst"
        output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_2_0"   # basename of this added to logs
        probability_row=0.079
        ;;
    2_0dedup)
        url_stem="https://data.hplt-project.org/two/deduplicated/eng_Latn/#.jsonl.zst"
        output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results/v_2_0_dedup"
        probability_row=0.065
        ;;
    *)
    echo "Version number not given correctly"
    exit 1
    ;;
esac


mkdir -p temp
mkdir -p $output_path

echo "Loading module"
module load parallel

# Main script logic
for ((i=START;i<=END;i++)); do
    # get the url from which to download
    url=${url_stem/"#"/$i}
    echo "In ${url}"
    p=$(basename $url)    # for saving in temp => multiple jobs can run simultaneously if the files are called different
    bname="${p%.*}"     # for outfile without .zst => changing to .gz
    if wget --no-verbose -O temp/$p $url; then
        echo "Download succeeded: $p $(date +"%T")"
    else
        echo "Download failed: $p $(date +"%T")"
        continue  # Skip to the next iteration if wget fails
    fi
    # process in parallel
    echo "processing temp/${p}"
    zstdcat "temp/$p" | parallel --pipe -j64 -k --block 10M python3 sample.py $probability_row | pigz > "${output_path}/${bname}.gz"
    echo "success with ${p} $(date +"%T")"
    rm temp/$p
done


log_name=$(basename $output_path)
cp logs/$SLURM_JOBID.out "logs/${log_name}_sample_${START}-${END}.out"
cp logs/$SLURM_JOBID.err "logs/${log_name}_sample_${START}-${END}.err"

exit 0


