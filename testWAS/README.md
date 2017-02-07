
## To run this test phenome scan do -

```bash
cd ../WAS/

testDir="../testWAS/"

Rscript phenomeScan.r \
--phenofile="${testDir}data/phenotypes.csv" \
--traitofinterestfile="${testDir}data/exposure.csv" \
--variablelistfile="${testDir}variable-lists/outcome-info.tsv" \
--datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" \
--traitofinterest="exposure" \
--resDir="${testDir}results/" \
--userId="userId"
```

Here is a shortcut to this test example:

```bash
cd ../WAS/
Rscript phenomeScan.r --test
```

Or to run part 1 of 3 parts use:

```bash
cd ../WAS/

testDir="../testWAS/"

Rscript phenomeScan.r \
--phenofile="${testDir}data/phenotypes.csv" \
--traitofinterestfile="${testDir}data/exposure.csv" \
--variablelistfile="${testDir}variable-lists/outcome-info.tsv" \
--datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" \
--traitofinterest="exposure" \
--resDir="${testDir}results/" \
--userId="userId" \
--partIdx=1 \
--numParts=3
```



## To run the results processing do -

```bash
cd ../resultsProcessing/

Rscript mainCombineResults.r \
--resDir="../testWAS/results/" \
--variablelistfile="../testWAS/variable-lists/outcome-info.tsv"
```

Or to perform results processing on parallel results do - 

```bash
cd ../resultsProcessing/

Rscript mainCombineResults.r \
--resDir="../testWAS/results/" \
--variablelistfile="../testWAS/variable-lists/outcome-info.tsv" \
--numParts=3
```

## To generate visualisation do - 

```bash

cd ../PHESANT-viz/bin/

java -cp .:../jar/json-simple-1.1\ 2.jar ResultsToJSON "../../testWAS/results/results-combined.txt" "../node-positions.csv" "../web/java-json.json"

```

This generates the JSON file containing the phenome scan results, in the PHESANT-viz/web directory.


