
# pheWAS results visualisation tool

## Overview

This directory contains the code used to produce a D3 visualisation that displays the results of a pheWAS, in the context of the hierarchical categorical structure UK Biobank has specified.

The Biobank category hierarchy is found [here](http://biobank.ctsu.ox.ac.uk/showcase/label.cgi)


## How the code works

The D3 visualisation code consists of:

1. a HTML page that includes the D3 javascript visualisation code (this doesn't change)
2. a JSON file containing the results data in a format that D3 can use to generate the visualisation (this is specific to your pheWAS)

This directory has 3 subdirectories:

1. src - contains the java source code that is used to generate the JSON. You won't need to go in here unless you
want to change the visualisation and need to amend the JSON that is used.
2. bin - java classes (compiled versions of the files in the src directory). These are used to generate the JSON files needed
for the visualisation.
3. web - html and json files for the D3 visualisation.

You'll notice that there is a file in this directory called node-positions.csv. This file is used in the Java code, to add pre-specified positions to structure nodes in the visualisation.

If you open the html file (in the web/ subdirectory) in a web browser you should see the visualisation for the test dataset included in this project (in WAS/testWAS/).

Generating the JSON for your own results will generate this visualisation for your own phewas.


## Running the java that generates the JSON for your own pheWAS

The main java files that generates the json is ResultsToJson.java.

This java class has two parameters:

1. File path of the results files from a pheWAS.
2. File path of the destination, where you would like the generated JSON to be stored.

For example, we can generate the JSON for the testWAS using:

```bash
cd bin/
java -cp .:../jar/json-simple-1.1\ 2.jar ResultsToJSON "../../WAS/testWAS/results/results-combined.txt" "../node-positions.csv" "../web/java-json.json"
```

NB: The name of the json file is reference on line 87 of the html code, so if you choose a different name then you will need to change the name here too.






