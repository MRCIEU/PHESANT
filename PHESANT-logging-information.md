
# PHESANT logging files

PHESANT produces logging files to help users to understand how it has processed the data, and derived and tested each phenotype.
Each line pertains to a particular UK Biobank field.
Here are a set of examples to help you to understand these files.
Also, the diagram `biobank-PHESANT-figure.pdf` shows the 'routes' that PHESANT takes to process the data which may be helpful to refer to.

Please read the paper first, before trying to understand the logs.


## Example 1: continuous field to continuous data type

```bash
189_0|| CONTINUOUS MAIN || CONTINUOUS || IRNT || SUCCESS results-linear
```

Field 189 (instance 0), has the continuous field type ('CONTINUOUS MAIN' just indicates it is not an integer field that has been sent to the continuous route, when it has >=20 distinct values).
An inverse rank normal transformation (IRNT) is performed and the association is tested with linear regression.


## Example 2: integer field (via continuous) to ordered categorical data type

```bash
137_0|| INTEGER || CONTINUOUS || >20% IN ONE CATEGORY || cat N: 137702, 172449, 191628 || CAT-ORD || order: 0|1|2 || num categories: 3 || SUCCESS results-ordered-logistic
```

Field 137 is an integer field sent to the continuous route because >20% of the sample has the same value.
The values are binned into three categories, with 137702, 172449, and 191628 people in each category.
The association is tested with ordered logistic regression.

## Example 3: integer field to ordered logistic regression

```bash
398_0|| INTEGER || Inc(>=10): 4.5(480644) || Inc(>=10): 0(10882) || Inc(>=10): 0.5(632) || Inc(>=10): 1(336) || Inc(>=10): 2(1020) || Inc(>=10): 1.5(1709) || Inc(>=10): 3(1706) || Inc(>=10): 4(103) || Inc(>=10): 3.5(477) || Inc(>=10): 2.5(502) || 3-20 values || CAT-ORD || order: 0|0.5|1|1.5|2|2.5|3|3.5|4|4.5 || num categories: 10 || SUCCESS results-ordered-logistic
```

Field 398 is an integer field.
There are 10 values with >=10 people assigned to that value.
For example, 480644 participants have the value 4.5.
Since there are 3-20 values included then this field is assigned as categorical ordered, and the association is tested with ordered logistic regression.


## Example 4: categorical single field to ordered categorical data type

```bash
1190_0|| CAT-SINGLE || Inc(>=10): 2(192707) || Inc(>=10): 1(281150) || Inc(>=10): 3(26888) || ordered || CAT-ORD || order: 1|2|3 || num categories: 3 || SUCCESS results-ordered-logistic
```

Field 1190 is a categorical single field, with three values having >=10 participants.
It is assigned to the categorical ordered data type and tested with ordered logistic regression.


## Example 5: categorical single field with re-ordering, to ordered categorical data type

```bash
1757_0|| CAT-SINGLE || reorder 1|3|2 || Inc(>=10): 1(338766) || Inc(>=10): 2(108956) || Inc(>=10): 3(9611) || ordered || CAT-ORD || order: 1|3|2 || num categories: 3 || SUCCESS results-ordered-logistic
```

Field 1757 is a categorical single field with data code 100435 (as stated [here](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=1757)).
As specified in the data coding information file (`variable-info/data-coding-ordinal-info.txt`), this field is reordered to 1,3,2 so that the order is in terms of increasing age (see [here](http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100435)).
This field is assigned the categorical ordered data type and the association is tested with ordered logistic regression.


## Example 6: categorical single field to unordered categorical data type

```bash
1468_0|| CAT-SINGLE || Inc(>=10): 2(73008) || Inc(>=10): 5(80836) || Inc(>=10): 4(82933) || Inc(>=10): 3(105975) || Inc(>=10): 1(69399) || CAT-SINGLE-UNORDERED || reference: 3=105975 || SUCCESS results-notordered-logistic
```

Field 1468 is a categorical single field with data code 100393, as stated [here](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=1468).
There are 5 categories with >=10 participants assigned to it. 
As specified in the 'ordinal' column of the data coding information file, data code 100393 corresponds to an unordered set of values, so the field is assigned to the categorical unordered data type.
The largest category (value 3 with 105975 participants) is assigned as the baseline (reference) value.
The association is tested with multinomial logistic regression.


## Example 7: categorical single filed to binary data type

```bash
2030_0|| CAT-SINGLE || Inc(>=10): 1(140598) || Inc(>=10): 0(346639) || CAT-SINGLE-BINARY || sample 346639/140598(487237) || SUCCESS results-logistic-binary
```

Field 2030 is a categorical single field with data code 100349.
There are two values with >=10 participants assigned to it, so it is assigned to the binary data type.
There are 346639 and 140598 participants in each category (487237 in total).
The association is tested with logistic regression.


## Example 8: categorical multiple field to binary data type, with 'NO_NAN' approach

```bash
6140_0|| CAT-MULTIPLE || reassignments: -7=100 ||  CAT-MUL-BINARY-VAR 1 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 1 but with missing value (<0) || sample 13661/158536(172197) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 3 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 3 but with missing value (<0) || sample 168156/4041(172197) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 2 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 2 but with missing value (<0) || sample 166411/5786(172197) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 100 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 100 but with missing value (<0) || sample 168976/3221(172197) || SUCCESS results-logistic-binary SKIP_val:-1 < 0 CAT-MUL-BINARY-VAR 5 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 5 but with missing value (<0) || sample 171173/1024(172197) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 6 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 6 but with missing value (<0) || sample 171544/653(172197) || SUCCESS results-logistic-binary SKIP_val:-3 < 0 CAT-MUL-BINARY-VAR 4 || NO_NAN Remove NA participants 329907 || Removed 537 examples != 4 but with missing value (<0) || sample 171688/509(172197) || SUCCESS results-logistic-binary
```

Field 6140 is a categorical multiple field, with data code 100289.
Value -7 is reassigned to value 100, as specified in the 'reassignments' column of the data coding information file.
This is so that the -7 is included as a value rather than being treated as a missing value.
For categorical multiple fields a binary variable is generated for each value.
For this example, a binary variable is first generated for value 1, indicated by the 'CAT-MUL-BINARY-VAR 1'.
In the outcome info file (outcome-info.tsv), the approach to assigning participants to the 'false' value (i.e. not having value 1) is specified in the 'CAT_MULT_INDICATOR_FIELDS' column as 'NO_NAN'.
This means that only participants with a value for this field (with the value being >=0) are included, i.e. all participants with no value are removed.
Thus, 329,907 participants with no value for this field are removed.
Then, 537 examples are removed with negative values, that are assumed to denote missingness (note this is why the -7 value was initially converted to a positive value).
This left 13,661 participants that are cases (having value 1 for this field) and 158,536 participants that are controls (in total 172,197 participants).
The association is tested with logistic regression.
This process is then repeated for each (positive) value in this field, until they have all been processed.



## Example 9: categorical multiple with indicator variable approach


```bash
20002_0|| CAT-MULTIPLE ||  CAT-MUL-BINARY-VAR 1398 || Indicator name x135_0_0 || Remove indicator var NAs: 862 || Remove indicator var <0: 0 || Removed 0 examples != 1398 but with missing value (<0) || sample 494870/6909(501779) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 1074 || Indicator name x135_0_0 || Remove indicator var NAs: 862 || Remove indicator var <0: 0 || Removed 0 examples != 1074 but with missing value (<0) || sample 485656/16123(501779) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 1111 || Indicator name x135_0_0 || Remove indicator var NAs: 862 || Remove indicator var <0: 0 || Removed 0 examples != 1111 but with missing value (<0) || sample 443486/58293(501779) || SUCCESS results-logistic-binary  CAT-MUL-BINARY-VAR 1226 || Indicator name x135_0_0 || Remove indicator var NAs: 862 || Remove indicator var <0: 0 || Removed 0 examples != 1226 but with missing value (<0) || sample 477534/24245(501779) || SUCCESS results-logistic-binary   ...
```

Field 20002 is a categorical multiple field with data code 6.
As for field 6140 above, a binary variable is generated in this field in turn.
So first it processes value 1398, indicated by 'CAT-MUL-BINARY-VAR 1398'.
The key difference is the approach used to assign the 'false' value of the binary variable.
Since this field does not include a 'none' value, if we were to use the 'NO_NAN' approach then the sample would only include those who had said they had at least one of these illnesses.
Instead, this field uses the indicator approach, where field 135 is used to determine who should be included in the sample.
This is specified in the CAT_MULT_INDICATOR_FIELDS column of the `outcome-info.tsv` file, and indicated in the logging by 'Indicator name x135_0_0'.
Field 135 contains the number of cancers entered, including the zero value for those who answered the question but did not report any cancers.
PHESANT assigns all participants who have a value in field 135 (and that value isn't <0 i.e. assumed to denote missingness), but did not state that they had pneumonia (value 1398) as the 'false' sample (i.e. the controls).
Thus, 6909 participants are cases (having had pneumonia) and 494870 participants are controls (501779 in total).


## Example 10: categorical single but only one value

```bash
10711_0|| CAT-SINGLE || Inc(>=10): 0(3431) || Removed 9: 5<10 examples || SKIP (only one value) ||
```

Field 10711 is a categorical single field with two values.
One value has <10 examples, so this field is skipped as there is only one value remaining.


## Example 11: messages where field was not be processed

This message indicates that field 5198 could not be found in the variable information file (`variable-info/outcome-info.tsv`).

```bash
5198_0 || Variable could not be found in pheno info file.
```





