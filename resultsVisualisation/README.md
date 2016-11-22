
# PHESANT-vis - a visualisation for phenome scans

## Overview

This directory contains the code used to produce a D3 visualisation that displays the results of a phenome scan, in the context of the hierarchical categorical structure that UK Biobank has specified.

See example for a MR-pheWAS of BMI (preliminary analysis) [here](www.datamining.org.uk/PHESANT/BMI-preliminary.html).

The visualisation is a tree structure, with the following node types:

A. Structure nodes:

1. Root node (pink, circle): The root of the tree, whose child nodes are the top level categories in UK Biobank.
2. Biobank category nodes (blue, circles): The Biobank category hierarchy found [here](http://biobank.ctsu.ox.ac.uk/showcase/label.cgi).
3. Biobank category multiple fields (purple, circles): Used to group the set of binary variables generated from a given category multiple fields.
4. Biobank subgroups of category multiple fields (light purple, circles): A subset of category multiple fields have a large number of results and also have a natural set of 
groupings across their categories (41201, 41202, 41204, 41200, 41210) and so we split these into these groups so they are easier to consider when viewing PHESANT-vis.

B. Results nodes:

5. Composite results nodes: These nodes collate the results in a particular subtree, so that there are a manageable number of nodes in the visualisation at once. The size of the node reflects the number of results in this subtree, of the following types:
 - Composite node for strong results (yellow, diamond)
 - Composite node for weak results (pale yellow, diamond)
 - Composite node for null results (grey, diamond)
6. Individual results nodes: These nodes represent a particular test performed in the phenome scan, divided into the following types:
 - Strong positive association (yellow, up triangle)
 - Strong negative association (yellow, down triangle)
 - Strong unordered association (yellow, circle)
 - Weak positive association (pale yellow, up triangle)
 - Weak negative association (pale yellow, down triangle)
 - Weak unordered association (pale yellow, circle)
 - Null result (grey, square)

The structure nodes can be clicked to display or hide the structure below this node in the tree.

## How the code works

The D3 visualisation code consists of:

1. A HTML page that includes the D3 Javascript visualisation code (this does not change).
2. A JSON file containing the results data in a format that D3 can use to generate the visualisation (this is specific to each particular phenome scan).

This directory has 3 subdirectories:

1. src - contains the Java source code that is used to generate the JSON. You will not need to go in here unless you want to change the visualisation and need to amend the JSON that is used.
2. bin - Java classes (compiled versions of the files in the src directory). These are used to generate the JSON files needed for the visualisation.
3. web - HTML and JSON files for the D3 visualisation.

Notice that there is a file in the current directory called node-positions.csv. This file is used in the Java code, to add pre-specified positions to structure nodes in the visualisation.

If you open the HTML file (in the `web/` subdirectory) in a web browser you should see the visualisation for the test dataset included in this project (in testWAS/).

Running this Java code to generate the JSON for your own results will generate this visualisation for your own phenome scan.

## Running the Java that generates the JSON for your own phenome scan

The main Java file that generates the JSON is ResultsToJson.java. This Java class has three parameters:

1. File path of the results files from a phenome scan.
2. File path to the location of the node position file (you should not need to change this).
3. File path of the destination, where you would like the generated JSON to be stored. 

Run the Java by moving into the bin directory and running the ResultsToJSON java class:

```bash
cd bin/
java -cp .:../jar/json-simple-1.1\ 2.jar ResultsToJSON <RESULTS_FILE_PATH> "../node-positions.csv" "../web/java-json.json"
```

See testWAS/README.md for an example with test data.

NB: The name of the JSON file is referenced on line 87 of the HTML code, so if you choose a different name then you will need to change the name here too.







