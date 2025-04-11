# hplt-sampling
Dump for sampling scripts.

## Overall philosophy:

  1. HPLT data is in shards
  2. Download one shard, sample that, and delete it. This makes sure that we do not have the full 1T English data on the device at the same time.
  3. As some languages have many shards, there is the option to parallellize wrt. shards.
  4. I.e. run shards 1 to 20 and 21 to 40 at the same time, always having only 2 files in the memory at the same time.
  5. Makes multiple small files .gz which can just be concatenated later.

## Modifications that need to be done

- **Most output paths are harcoded** to my directories, so change them. A good way is to seard for "project_462000353/amanda", and change them to appropriate paths.
- These scripts are for "English only", but it is very easy to change the url based on the language:
  - e.g. line 50 in ``sl_sample-with-numbers.sh``, on line 50: ``url_stem="https://data.hplt-project.org/two/cleaned/eng_Latn/#.jsonl.zst"``
  - If you want to change this to French, visit [hplt site](https://hplt-project.org/datasets/v2.0), and see the url format there by clicking download, which takes you to a list of urls.
  - VERY LIKELY it is just a minor change, e.g. ``url_stem="https://data.hplt-project.org/two/cleaned/fra_Latn/#.jsonl.zst"``
  - Note that all HPLT versions have different urls!
- If you sample multiple langauges, remember to make the output path different for each language!
- Probablities are calculated to give 350B token samples, so 260B words. Adjust for your needs! See ``calculations.ipynb``.


## Quickstart

Try if ``wget`` works on your LUMI by running ``wget --help``, if it does not, refer to LUMI module documentation.

To sample, run 
```
sbatch sl-sample-with-number.sh {hplt version number, e.g. "2_0"} {shard start index} {shard end index}
```
This samples shards from start index to end index, end included, as an example:

```sbatch sl-sample-with-number.sh 2_0 1 3```

downloads these files:

  https://data.hplt-project.org/two/cleaned/eng_Latn/1.jsonl.zst
  https://data.hplt-project.org/two/cleaned/eng_Latn/2.jsonl.zst
  https://data.hplt-project.org/two/cleaned/eng_Latn/3.jsonl.zst

and samples them to location specified in ``sl-sample-with-number.sh``.

Options for HPLT versions are ``1_0, 1_1, 1_2, 2_0, 2_0dedup`` and ``2_0cleaned`` which is the same as ``2_0``. Number of shards that you can iterate over can also be found by visiting [hplt site](https://hplt-project.org/datasets/v2.0), clinking download, and seeing the number of shards.

## Predownload...?

LUMI is supposed to ``wget`` really fast, but sometimes it is very slow. You can use ``predownload.sh {hplt version number, e.g. "2_0"} {shard start index} {shard end index}`` to download files while the sampling is ongoing. This is a bit risky, as if you're not carefull you might accidentally override ongoing sampling. So, if you start sampling shards 1-10, and notice it is very slow, do not predownload 1-10, but 5-10 for example, so that you do not override results that already exist.

