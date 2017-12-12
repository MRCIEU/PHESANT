


## Retrieving categorical data codes

This directory contains the scripts to retrieve the data codes from UK Biobank.


The process is as follows:

1. Get list of categorical fields from our `outcome-info.tsv` file (i.e. all categorical (single) and categorical (multiple) fields).
2. Web scrape the data coding id from the fields webpage in the data showcase.
3. Web scrape the data coding TSV if it hasn't already been downloaded, and store in `data_codes` subdirectory.


Run this code with the following command:

```bash
sh processDataCodes.sh
```
