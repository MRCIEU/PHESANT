
## to run this test pheWAS do -

cd ..

testDir="testWAS/"

Rscript tests_phase1.r \
--outcomefile="${testDir}data/phenotypes.csv" \
--exposurefile="${testDir}data/exposure.csv" \
--variablelistfile="${testDir}variable-lists/outcome-info3.txt" \
--datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" \
--exposurevariable="exposure" \
--resDir="${testDir}results/" \
--userId="userId"
