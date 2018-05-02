
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
#TRAIT_OF_INTEREST	EXCLUDED	CAT_MULT_INDICATOR_FIELDS	CAT_SINGLE_TO_CAT_MULT	DATA_CODING

IFS=$'\t'

# for each line in most up to date data dictionary, add our curated info columns if this field isn't new
while read Path Category FieldID Field Participants Items Stability ValueType Units ItemType Strata Sexed Instances Array Coding Notes Link; do

	# don't include field types PHESANT doesn't deal with
	if [ "$ValueType" == "Text" ] || [ "$ValueType" == "Bulk" ] || [ "$ValueType" == "Date" ] || [ "$ValueType" == "Time" ] || [ "$ValueType" == "Compound" ]; then
		continue
	else

		line="$Path\t$Category\t$Field\t$Participants\t$Items\t$Stability\t$ValueType\t$Units\t$ItemType\t$Strata\t$Sexed\t$Instances\t$Array\t$Coding\t$Notes\t$Link"
	
		# get line from old outcome-info file
		oldline=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $0}' ../outcome-info.tsv`		

		# if old line exists then set new with old setup
		if [ "$oldline" == "" ]; then
			newline="$FieldID\tX\tX\tX\tX\tX\t$line"
			echo $FieldID >> new-field-list.txt
		else
			# get each PHESANT information column from old outcome info file
			col1=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $9}' ../outcome-info.tsv`
			col2=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $10}' ../outcome-info.tsv`
			col3=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $11}' ../outcome-info.tsv`
			col4=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $12}' ../outcome-info.tsv`
			col5=`awk -F'\t' -v nfx=$FieldID '($7==nfx) {print $13}' ../outcome-info.tsv`

			# otherwise create empty columns with X to show we need to check and maybe complete them
			newline="$FieldID\t$col1\t$col2\t$col3\t$col4\t$col5\t$line"
		fi
		echo -e $newline  >> outcome-info-new.tsv	
	fi

done < "Data_Dictionary_Showcase.tsv"


