module add languages/R-3.2.4-ATLAS

Rscript mainCombineResults.r --resDir="../../results/" --numParts=20 --variablelistfile="../../variable-lists/outcome-info-20160914.txt"
