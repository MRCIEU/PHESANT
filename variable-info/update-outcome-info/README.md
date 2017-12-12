
# Updating outcomes-info.tsv with new fields


UK Biobank describes its fields in a data dictionary on their website. When new fields are added we update the `../outcome-info.tsv` file used by PHESANT, using the updated UK Biobank data dictionary.

The steps we take to do this are:

1. Retrieve latest version of data dictionary from UK Biobank.

```bash
wget http://biobank.ctsu.ox.ac.uk/%7Ebbdatan/Data_Dictionary_Showcase.csv
```


2. Create a list of fields currently available, and a list of fields in PHESANTs `../outcome-info.tsv`, for comparison.

```bash
awk -F'\t' '(NR>1) {print $7}' ../outcome-info.tsv | sort > current-fields.txt
awk -F'\t' '(NR>1) {print $7}' Data_Dictionary_Showcase.tsv | sort > latest-fields.txt
```


3. Summarise the number of fields we currently include, vs the total available.

```bash
wc -l current-fields.txt
wc -l latest-fields.txt 
```


4. Add new fields to `../outcome-info.tsv`.

```bash
sh addNewFields.sh
```

5. Clean up - remove temporary files.

```bash
rm current-fields.txt
rm latest-fields.txt
rm Data_Dictionary_Showcase.csv
rm Data_Dictionary_Showcase.tsv
```

6. Review fields and manually update PHESANT properties.

Fields with capitalized names in `../outcome-info.tsv` are additional PHESANT fields, used to process fields appropriately when running PHESANT.

We review each new field and assign values to these fields, where appropriate.




