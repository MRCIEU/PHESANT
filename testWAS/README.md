
## To run this test pheWAS do -

```bash
cd ../WAS/

testDir="../testWAS/"

Rscript phewas.r \
--outcomefile="${testDir}data/phenotypes.csv" \
--exposurefile="${testDir}data/exposure.csv" \
--variablelistfile="${testDir}variable-lists/outcome-info.tsv" \
--datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" \
--exposurevariable="exposure" \
--resDir="${testDir}results/" \
--userId="userId"
```

Or to run part 1 of 3 parts use:

```bash
cd ../WAS/

testDir="../testWAS/"

Rscript phewas.r \
--outcomefile="${testDir}data/phenotypes.csv" \
--exposurefile="${testDir}data/exposure.csv" \
--variablelistfile="${testDir}variable-lists/outcome-info.tsv" \
--datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" \
--exposurevariable="exposure" \
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
--variablelistfile="../WAS/testWAS/variable-lists/outcome-info.tsv"
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

cd ../resultsVisualisation/bin/

java -cp .:../jar/json-simple-1.1\ 2.jar ResultsToJSON "../../testWAS/results/results-combined.txt" "../node-positions.csv" "../web/java-json.json"

```

This generates the json file containing the pheWAS results, in the resultsVisualisation/web directory.


