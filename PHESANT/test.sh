testDir="~/Documents/Github/PHESANT/testWAS/"
Rscript phenomeScan.r --phenofile="${testDir}data/phenotypes.csv" --traitofinterestfile="${testDir}data/exposure.csv" --variablelistfile="${testDir}variable-lists/outcome-info.tsv" --datacodingfile="${testDir}variable-lists/data-coding-ordinal-info.txt" --traitofinterest="exposure" --resDir="${testDir}results/" --userId="userId"

