#!/bin/bash
#SBATCH --job-name=sample
#SBATCH --account=project_462000444   # for resource and queue efficiency
#SBATCH --partition=small
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=64
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

module load LUMI
module load wget
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
        output_path="/scratch/project_462000353/amanda/sampling/results/v_1_0"
        probability_row=0.0256  # these all have +0.002 so that we go over 300B tokens
        ;;
    1_1)
        url_stem="https://data.hplt-project.org/one/monotext/deduplicated/en/en_#.jsonl.zst"
        output_path="/scratch/project_462000353/amanda/sampling/results/v_1_1"
        probability_row=0.0918 
        ;;
    1_2)
        url_stem="https://data.hplt-project.org/one/monotext/cleaned/en/en_#.jsonl.zst"
        output_path="/scratch/project_462000353/amanda/sampling/results/v_1_2"
        probability_row=0.1139
        ;;
    2_0 | 2_0cleaned)
        url_stem="https://data.hplt-project.org/two/cleaned/eng_Latn/#.jsonl.zst"
        output_path="/scratch/project_462000353/amanda/sampling/results/v_2_0"   # basename of this added to logs
        probability_row=0.0919
        ;;
    2_0dedup)
        url_stem="https://data.hplt-project.org/two/deduplicated/eng_Latn/#.jsonl.zst"
        output_path="/scratch/project_462000353/amanda/sampling/results/v_2_0_dedup"
        probability_row=0.0701
        ;;
    *)
    echo "Version number not given correctly"
    exit 1
    ;;
esac


mkdir -p temp_${version}
mkdir -p $output_path

echo "Loading parallel module"
module load parallel

# Main script logic
for ((i=START;i<=END;i++)); do
    # get the url from which to download
    url=${url_stem/"#"/$i}
    echo "In ${url} $(date +"%T")"
    p=$(basename $url)    # for saving in temp => multiple jobs can run simultaneously if the files are called different
    bname="${p%.*}"     # for outfile without .zst => changing to .gz
    if [[ -f "temp_${version}/$p" ]]; then
        echo "File already exists in temp: $p, skipping download $(date +"%T")"
    else
        if wget --no-verbose -O temp_${version}/$p $url; then
            echo "Download succeeded: $p $(date +"%T")"
        else
            echo "Download failed: $p $(date +"%T")"
            continue  # Skip to the next iteration if wget fails
        fi
    fi
    # process in parallel
    echo "processing temp_${version}/${p}"
    zstdcat "temp_${version}/$p" | parallel --pipe -j64 --block 10M python3 sample.py $probability_row | pigz > "${output_path}/${bname}.gz"
    echo "success with ${p} $(date +"%T")"
    rm temp_${version}/$p
done


log_name=$(basename $output_path)
cp logs/$SLURM_JOBID.out "logs/${log_name}_sample_${START}-${END}.out"
cp logs/$SLURM_JOBID.err "logs/${log_name}_sample_${START}-${END}.err"

exit 0


