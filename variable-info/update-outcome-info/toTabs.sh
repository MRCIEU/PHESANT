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


# replaced comma delimiters with tabs, in data dictionary file from UK Biobank,
# while being careful to ignore comma's within quotes (i.e. within text of fields).

while read -r newline
do

	# replace comma delimiters with a tab so that we don't confuse commas in strings with delimiters

	inQuotes=0
	strx=""
	while read -n1 charx; do
		if [ "$charx" == "\"" ] && [ $inQuotes == 0 ]; then
			inQuotes=1
		elif [ "$charx" == "\"" ] && [ $inQuotes == 1 ]; then
			inQuotes=0
		elif [ $inQuotes == 0 ] && [ "$charx" == "," ]; then
			strx=`echo -e "$strx\t"`
		elif [ "$charx" == "" ]; then
			strx=`echo -e "${strx} "`
		else
			strx=`echo -e "${strx}${charx}"`
		fi

	done <<< `echo -n "$newline"`

	echo -e "$strx" >> Data_Dictionary_Showcase.tsv

done < Data_Dictionary_Showcase.csv




