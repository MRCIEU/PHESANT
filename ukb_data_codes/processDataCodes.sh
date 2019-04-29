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


# this script gets a list of all categorical field IDs and then calls getDataCodeForField for each, to retrive the
# data code ID, and data code values for each field.

##
## retrieve all field IDs for categorical single and categorical multiple fields

categoricalIds=`cat ../variable-info/outcome-info.tsv | awk -F'\t' '($10=="Categorical single") || ($10=="Categorical multiple") {print $1}'`

echo "Processing categorical (single) and categorical (multiple) data codes"


##
## start empty mapping file

map_filename="data_codes/fid_dcid_mapping.csv"
echo "fid,dc" > $map_filename


##
## loop each field and retrieve data code id and values

for line in $categoricalIds
do
	sh getDataCodeForField.sh $map_filename "$line"
done


