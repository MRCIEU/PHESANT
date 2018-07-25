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


# This script takes a mapping filename and a field ID, and adds the fieldsID - data code mapping to 
# the mapping file and stores the data coding tsv file with the data code values.

##
## args from processDataCodes script

map_filename=$1
fid=$2


##
## get webpage for field, from showcase

#fid=`echo $line | awk '{print $1}'`
webpage=`wget -q -O - http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=${fid}`


##
## get data code id

dc_id=`echo $webpage | grep -o -m1 -G 'coding\.cgi?id=[0-9]\+' | head -n 1 | sed 's/coding\.cgi?id=//g'`


if [ "$dc_id" != "" ]
then

	dcfilename="data_codes/datacode-${dc_id}.tsv"

	##
	## write line to file, mapping field to data code

	echo "${fid},${dc_id}" >> $map_filename


	##
	## only get the datacode if we haven't already downloaded it

	if [ ! -f $dcfilename ]
	then
		echo "Retrieving coding for data code: $dc_id"
	
		# get data coding tsv file
		dc_tsv=`wget -q http://biobank.ctsu.ox.ac.uk/showcase/codown.cgi?id=${dc_id}&btn_glow=Download`
		
		# rename file
		mv "codown.cgi?id=${dc_id}" $dcfilename

		# make sure all files are ASCII or this causes probs when we use it
		iconv -f ISO-8859-1 -t ASCII//TRANSLIT $dcfilename > tmp.txt
		mv tmp.txt $dcfilename
	
		sleep 2

	fi


else
	echo "Could not retrieve data code for field $fid"
fi
