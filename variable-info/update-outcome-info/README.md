
# Updating outcomes-info.tsv with new fields


## Retrieve latest version of data dictionary from UK Biobank

```bash
wget http://biobank.ctsu.ox.ac.uk/%7Ebbdatan/Data_Dictionary_Showcase.csv
```


## Compare fields in latest with fields in PHESANTs outcome-info.tsv

```bash
awk -F'\t' '(NR>1) {print $7}' ../outcome-info.tsv | sort > current-fields.txt
awk -F'\t' '(NR>1) {print $7}' Data_Dictionary_Showcase.tsv | sort > latest-fields.txt
```


## Summarise numbers in each

```bash
wc -l current-fields.txt
wc -l latest-fields.txt 
```


## Add new fields to `../outcome-info.tsv'

```bash
sh addNewFields.sh
```

## Clean up

```bash
rm current-fields.txt
rm latest-fields.txt
rm Data_Dictionary_Showcase.csv
rm Data_Dictionary_Showcase.tsv
```






