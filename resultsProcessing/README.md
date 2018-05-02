




Update the catbrowse.txt file with the most recent UKBiobank category hierarchy:

This only needs to be run when updating the outcome-info.tsv file, because new fields might belong to new categories

```bash
wget -nd -O catbrowse.txt "biobank.ndph.ox.ac.uk/showcase/scdown.cgi?fmt=txt&id=13"
```
