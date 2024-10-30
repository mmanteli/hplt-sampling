#!/bin/bash

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


case $version in
    1_0)
        url_stem="https://data.hplt-project.org/one/monotext/en/#.jsonl.zst"
        ;;
    1_1)
        url_stem="https://data.hplt-project.org/one/monotext/deduplicated/en/en_#.jsonl.zst"
        ;;
    1_2)
        url_stem="https://data.hplt-project.org/one/monotext/cleaned/en/en_#.jsonl.zst"
        ;;
    2_0 | 2_0cleaned)
        url_stem="https://data.hplt-project.org/two/cleaned/eng_Latn/#.jsonl.zst"
        ;;
    2_0dedup)
        url_stem="https://data.hplt-project.org/two/deduplicated/eng_Latn/#.jsonl.zst"
        ;;
    *)
    echo "Version number not given correctly"
    exit 1
    ;;
esac


mkdir -p temp_${version}_download
mkdir -p temp_${version}


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
        if wget -O temp_${version}_download/$p $url; then
            echo "Download succeeded: $p $(date +"%T")"
        else
            echo "Download failed: $p $(date +"%T")"
            continue  # Skip to the next iteration if wget fails
        fi
    fi
    
    #if [[ -f "temp_${version}/$p" ]]; then
    #    echo "moving from temp_${version}_download/${p} to temp_${version}/${p}"
    #    mv "temp_${version}_download/${p}" temp_${version}/
    #else
    #    echo "download already produced by sampling"
    #fi
done


exit 0


