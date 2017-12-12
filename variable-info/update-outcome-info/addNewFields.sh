


# get new fields by comparing lists

newfields=`diff current-fields.txt latest-fields.txt | grep '>' | sed 's/> //g'`

# for each new field, get line from data dictionary and add to outcome-info.tsv, in correct format

while read -r newfield
do

	newline=`awk -F'\t' -v nfx=$newfield '($7==nfx) {print $0}' Data_Dictionary_Showcase.tsv`

	# note that rest string starts with a tab and first ends with a tab

	first=`echo -e "$newline" | awk -F'\t' '{for(i=1;i<=8;++i)printf("%s\t",$i)}'`
	rest=`echo -e "$newline" | awk -F'\t' '{for(i=9;i<=NF;++i)printf("\t%s",$i)}'`

	# our new line for the outcome-info.tsv
	nlF="${first}\t\t\t\t${rest}"

	echo -e "$nlF" >> ../outcome-info.tsv

done <<< "$newfields"

