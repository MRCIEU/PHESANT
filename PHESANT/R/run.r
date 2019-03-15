run <- function(opt) {
    input <- initData(opt)
    print("LOADING DONE")
    
    #initilize package level variables, primarily for passing variables between functions and logging
    .initEnv(opt, input$data)
    
    currentVar <- ""
    currentVarShort <- ""
    first <- TRUE
    
    phenoIdx=0; # zero because then the idx is the position of the previous variable, i.e. the var in currentVar
    for (var in input$phenoVars) { 
        sink()
        sink(pkg.env$resLogFile, append=TRUE)
        
        varx <- gsub("^x", "", var)
        varx <- gsub("_[0-9]+$", "", varx)
        
        varxShort <- gsub("^x", "", var)
        varxShort <- gsub("_[0-9]+_[0-9]+$", "", varxShort)
        
        ## test this variable
        if (currentVar == varx) {
          thisCol <- input$data[,eval(var)]
          thisCol <- .replaceNaN(thisCol)
          currentVarValues <- cbind.data.frame(currentVarValues, thisCol)
        } else if (currentVarShort == varxShort) {
          ## different time point of this var so skip
        } else {
          ## new variable so run test for previous (we have collected all the columns now)
          if (first==FALSE) {
            thisdata <- makeTestDataFrame(input$data, input$confounders, currentVarValues)
            testAssociations(opt, input$vl, currentVar, currentVarShort, thisdata, input$phenoStartIdx)
          }
          first <- FALSE
          
          ## new variable so set values
          currentVar <- varx
          currentVarShort <- varxShort
          
          currentVarValues <- input$data[,eval(var)]
          currentVarValues <- .replaceNaN(currentVarValues)
        }
        phenoIdx <- phenoIdx + 1
    }
    
    if (phenoIdx>0){
        # last variable so test association
        thisdata = makeTestDataFrame(input$data, input$confounders, currentVarValues)
        testAssociations(opt, input$vl, currentVar, currentVarShort, thisdata, input$phenoStartIdx)
    }
    sink()
    
    # save counters of each path in variable flow
    saveCounts(opt)
    if (opt$save == TRUE) {
        write.table(pkg.env$derivedBinary, file=paste(opt$resDir,"data-binary-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
        write.table(pkg.env$derivedCont, file=paste(opt$resDir,"data-cont-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
        write.table(pkg.env$derivedCatOrd, file=paste(opt$resDir,"data-catord-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
        write.table(pkg.env$derivedCatUnord, file=paste(opt$resDir,"data-catunord-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
    }
  
}