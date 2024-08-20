#!/bin/bash

# Input parameters
url_file="/scratch/project_2005092/amanda/mahti-tokenisation/testi.txt"  
output_path="/scratch/project_2005092/amanda/mahti-tokenisation/results"
probability_file=1.1             # Probability thresholds (0 to 1)
probability_row=0.01
mkdir -p temp
mkdir -p $output_path


# Function to process the file with a given probability
process_file() {
    input_file=$1
    output_path=$2
    probability_row=$3
    base_filename=$(basename "$input_file")
    output_file="${output_path}/sample_${base_filename}"
    
    # Generating a random number between 0 and 1
    rand=$(awk -v seed=$RANDOM 'BEGIN{srand(seed); print rand()}')
    
    
    zcat $input_file | while read line 
    do
        rand_file=$(awk -v seed=$RANDOM 'BEGIN{srand(seed); print rand()}')
        if (( $(echo "$rand_file < $probability_row" | bc -l) )); then
            echo "${line}" >> $output_file
        fi
    done

    gzip $output_file


}

# Main script logic
cat $url_file | while read line 
do
    rand_file=$(awk -v seed=$RANDOM 'BEGIN{srand(seed); print rand()}')
    if (( $(echo "$rand_file < $probability_file" | bc -l) )); then
        echo "in ${line}" # do something with $line here
        p=$(basename $line)
        #wget -O temp/$p $line 
        process_file "temp/${p}" "$output_path" "$probability_row"
        #rm -r temp/$p
    fi
done
exit 0


