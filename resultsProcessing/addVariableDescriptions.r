# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


# add descriptions from the variable information field
# this is slightly more involved than just merging because each
# cat multiple field creates multiple binary results and we need to mark specific 
# results as exposure results for this (specified in the TRAIT_OF_INTEREST field of the variable information file
addVariableDescriptions <- function() {

	## add descriptions to rows
	varList=read.table(opt$variablelistfile, header=1, sep="\t", comment.char="",quote="");

	# create separate varID column, extracted from varName column
	resultsAll$varID <<- sapply(strsplit(resultsAll$varName,"[-#]", perl=TRUE), "[", 1)

	resultsAllx = merge(resultsAll, varList, by.x="varID", by.y="FieldID", all=FALSE, sort=FALSE);
	resultsAll <<- resultsAllx[, c("varID","varName","varType","n","beta","lower","upper","pvalue","resType","Field","TRAIT_OF_INTEREST","Category", "Path", "DATA_CODING")]
	names(resultsAll)[names(resultsAll)=="Field"] <<- "description"
	names(resultsAll)[names(resultsAll)=="TRAIT_OF_INTEREST"] <<- "isTraitOfInterest"

	resultsAll$description <<- as.character(resultsAll$description)

	## for each cat multiple field append the value to the description column
	cmIdxs = which(resultsAll$varType=="CAT-MUL")

	dccurrent=-1
	if(length(cmIdxs)>0) {
	for (ii in 1:length(cmIdxs)) {
		i = cmIdxs[ii]
		thisDC = resultsAll[i,"DATA_CODING"]
		dcVal = unlist(strsplit(resultsAll$varName[i],"#"))[2]

		# get data codes for this field
		if(dccurrent!=thisDC) {
			dcfile=paste('../ukb_data_codes/data_codes/datacode-',thisDC,'.tsv', sep='')
		}
		if (file.exists(dcfile)) {

			if(dccurrent!=thisDC) {
				dclist = read.table(dcfile, header=1, sep="\t", comment.char="",quote="")
			}

			# columns: coding	meaning
			ixx= which(dclist$coding == dcVal)

			if (length(ixx)>0) {
				meaning = dclist[ixx,"meaning"]
				newDescription = paste(resultsAll[i,"description"], ": ", meaning, sep="")
				resultsAll[i,"description"] <<- newDescription
			}
		}
		else {
			print("DC file does not exist (could not add value to cat multiple results):")
			print(dcfile)
		}
		dccurrent=thisDC
	}
	}


	# binary results from cat multiple need processing to set 'isExposure' using the list supplied in TRAIT_OF_INTEREST column in variable info file
	# (basically this is because 1 cat mult field generates multiple binary variables of which a subset may be denoting the exposure (e.g. a particular type of cancer))

	# get all cat mult fields with a value in TRAIT_OF_INTEREST
	catMultIdxs = which(varList$ValueType=="Categorical multiple" & !is.na(varList$TRAIT_OF_INTEREST) & varList$TRAIT_OF_INTEREST!="")
	resultsCatMult = resultsAll[catMultIdxs,]
	
	for (i in 1:nrow(resultsCatMult)) {

		thisVarID = resultsCatMult[i,"FieldID"]

		# first set all values of isExposure for this cat multiple to "" in resultsAll
		idx = which(resultsAll$varID==thisVarID)
		resultsAll[idx,"isTraitOfInterest"] <<- ""

		# then mark all the stated values as exposure values
		exposureValuesAll = as.character(resultsCatMult[i,"TRAIT_OF_INTEREST"])

		exposureValues = unlist(strsplit(exposureValuesAll,"\\|"))

		for (j in nrow(exposureValues)) {
			thisVal = exposureValues[j]
			varNameStr = paste(thisVarID, "#", thisVal)

			# result row for this particular value of this cat multiple field			
			idxInRes = which(resultsAll$varName == varNameStr)
			resultsAll$isTraitOfInterest[idxInRes] <<- "YES"
		}
	}

	# remove varId column - we don't need it anymore
	resultsAll <<- resultsAll[, c("varName","varType","n","beta","lower","upper","pvalue","resType","description","isTraitOfInterest","Category", "Path")]


	####
	#### add category structure for PHESANT-viz - first 3 category levels

	## load category hierarchy
        catHier = read.table("catbrowse.txt", header=1, sep="\t")

	## set category names
	resultsAll$Path <<- as.character(resultsAll$Path)
	resultsAll$Path <<- gsub("\"","", resultsAll$Path)
	resultsAll$Cat1_Title <<- ""
	resultsAll$Cat2_Title <<- ""
	resultsAll$Cat3_Title <<- ""


	## set category IDs
	resultsAll$Cat1_ID <<- NA
	resultsAll$Cat2_ID <<- NA
	resultsAll$Cat3_ID <<- NA

	for (i in 1:nrow(resultsAll)) {

		catnames = unlist(strsplit(resultsAll$Path[i], " > "))

		thispath = getCatIDPath(resultsAll$Category[i], catHier, c(resultsAll$Category[i]))
		numInPath = length(thispath)

		resultsAll$Cat1_ID[i] <<- thispath[1]
		resultsAll$Cat1_Title[i] <<- catnames[1]
                resultsAll$Cat2_ID[i] <<- thispath[2]
		resultsAll$Cat2_Title[i] <<- catnames[2]

		if (numInPath>=3) {
                        resultsAll$Cat3_ID[i] <<- thispath[3]
			resultsAll$Cat3_Title[i] <<- catnames[3]
                }
		else {
			resultsAll$Cat3_ID[i] <<- thispath[2]
                        resultsAll$Cat3_Title[i] <<- catnames[2]
		}
	}

	# specific order needed for PHESANT-viz
	resultsAll <<- resultsAll[, c("varName","varType","n","beta","lower","upper","pvalue","resType","description","isTraitOfInterest","Cat1_ID", "Cat1_Title", "Cat2_ID", "Cat2_Title", "Cat3_ID", "Cat3_Title", "Category", "Path")]

}


getCatIDPath <- function(categoryID, catHier, thishier) {

	idx = which(catHier$child_id == categoryID)

	# reached top of hierarchy
	if (length(idx)==0) {
		return(thishier)
	}

	pid = catHier$parent_id[idx]
	
	# add parent to path
	thishier = c(pid, thishier)

	# look for other ancestors in path
	return(getCatIDPath(pid, catHier, thishier))

}
