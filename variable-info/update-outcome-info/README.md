
# Updating outcomes-info.tsv with new fields


UK Biobank describes its fields in a data dictionary on their website. When new fields are added we update the `../outcome-info.tsv` file used by PHESANT, using the updated UK Biobank data dictionary.

The steps we take to do this are:

1. Retrieve latest version of data dictionary from UK Biobank.

```bash
wget http://biobank.ctsu.ox.ac.uk/%7Ebbdatan/Data_Dictionary_Showcase.csv
```

2. Convert CSV to TSV

Convert data dictionary to tsv file (Data_Dictionary_Showcase.tsv), and you might need to fix the encoding format from windows to linux.


3. Make updated outcome info file, called `outcome-info-new.tsv`.

```bash
sh addNewFields.sh
```

This also makes a file `new-field-list.txt` which lists the new fields added to `outcome-info-new.tsv`


4. Clean up

```bash
rm Data_Dictionary_Showcase.csv
rm Data_Dictionary_Showcase.tsv
```


5. Review fields and manually update PHESANT properties.

Fields with X in the PHESANT-specific columns need to be manually review and values set in these columns as appropriate.

Fields with capitalized names in `../outcome-info.tsv` are additional PHESANT fields, used to process fields appropriately when running PHESANT.

And then move `outcome-info-new.tsv` to `../outcome-info.tsv`.



