
# this script checks the new data dictionary line by line, 
# looks for each field in our outcome-info.tsv file
# if field already exists then we add this to the new outcome-info file
# if field doesn't exist then we add a new line to the new outcome-info file.
# any new lines have X in the PHESANT columns to show that these need manually checking / updating before using this new outcome-info file with PHESANT.


# new empty outcome info file
> outcome-info-new.tsv

# new empty list of new fields, so we can see which are added
> new-field-list.txt

# add our custom fields
#TRAIT_OF_INTEREST	EXCLUDED	CAT_MULT_INDICATOR_FIELDS	CAT_SINGLE_TO_CAT_MULT	DATE_CONVERT	DATA_CODING

IFS=$'\t'

i=1

# for each line in most up to date data dictionary, add our curated info columns if this field isn't new
while read Path Category FieldID Field Participants Items Stability ValueType Units ItemType Strata Sexed Instances Array Coding Notes Link; do

	if [ $i -eq 1 ]; then
		newline="FieldID\tTRAIT_OF_INTEREST\tEXCLUDED\tCAT_MULT_INDICATOR_FIELDS\tCAT_SINGLE_TO_CAT_MULT\tDATE_CONVERT\tDATA_CODING\tPath\tCategory\tField\tValueType"
		echo -e $newline  >> outcome-info-new.tsv
	else

	# don't include field types PHESANT doesn't deal with
	if [ "$ValueType" == "Text" ] || [ "$ValueType" == "Bulk" ] || [ "$ValueType" == "Time" ] || [ "$ValueType" == "Compound" ]; then
		continue
	else

		#line="$Path\t$Category\t$Field\t$Participants\t$Items\t$Stability\t$ValueType\t$Units\t$ItemType\t$Strata\t$Sexed\t$Instances\t$Array\t$Coding\t$Notes\t$Link"
		line="$Path\t$Category\t$Field\t$ValueType"
	
		# get line from old outcome-info file
		oldline=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $0}' ../outcome-info.tsv`

		# if old line exists then set new with old setup
		if [ "$oldline" == "" ]; then
			newline="$FieldID\tX\t\t\t\t\t\t$line"
			echo $FieldID >> new-field-list.txt
		else
			# get each PHESANT information column from old outcome info file
			col1=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $2}' ../outcome-info.tsv`
			col2=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $3}' ../outcome-info.tsv`
			col3=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $4}' ../outcome-info.tsv`
			col4=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $5}' ../outcome-info.tsv`
			col5=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $6}' ../outcome-info.tsv`
			col6=`awk -F'\t' -v nfx=$FieldID '($1==nfx) {print $7}' ../outcome-info.tsv`

			# otherwise create empty columns with X to show we need to check and maybe complete them
			newline="$FieldID\t$col1\t$col2\t$col3\t$col4\t$col5\t$col6\t$line"
		fi
		echo -e $newline  >> outcome-info-new.tsv	
	fi
	fi


	i=$((i+1))

done < "Data_Dictionary_Showcase.tsv"


