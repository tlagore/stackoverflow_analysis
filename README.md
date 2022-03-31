# Analyzing Programming Languages Used from StackOverflow post tags
This project takes a large set of StackOverflow Data and performs data cleaning and processing in order to perform analysis on the data.

To simulate big data projects where data cannot all be read into memory, the project uses only techniques that do not read the entire dataset into memory.

# StackOverflow Data
The data consists of

|file|size|
|-|-|
|posts.csv|4.13GB|
|poststags.csv|770MB|
|users.csv|152MB|
|languages.csv|1MB|

# Data Cleaning
### Parse language tags into "Baskets"

The following requirements must be met for a user to "know" (or be learning) a language:

1. User must have more than 1 post referencing this language
2. Do not double count a user knowing a language if they answer their own post
3. Ignore any posts that have more than 1 language in the list of tags

Expected output:
**txt file** with each line being of the format

`<userid>,<language1>,<language2>,...<languagen>`

example:
```
1324763,c#,javascript
132475,php,sql
1324631,c,c++,java,matlab,postscript,python
...
```

## Performing the clean:
run `./load_and_parse.sh`

If you would like to keep the csvs in the sqlite3 database, then press `n` at the prompt.

Example output:

```
Would you like to delete the temporary sqlite3 database after creating baskets.csv? (y/n): n
Loading csvs into sqlite3 (loaddb.sql)...

real	2m17.187s
user	1m47.782s
sys	0m15.403s
Performing basket query to export to baskets.csv (basket_query.sql)...

real	11m3.389s
user	7m59.321s
sys	3m1.738s
Cleaning 'baskets.txt'...
Cleaning 'documents.txt'...
Did not delete temporary database 'data/stackoverflowdb.db'
Done
```

Expected running time ~5-10 minutes.

The script performs 4 steps:
### 1. Create the schema for the CSVs and the resultant output table and import the CSV data into their relevant tables

    - see `loaddb.sql`

### 2. Query the newly created tables to get data into the expected format

    - see `basket_query.sql`

i.e.
| userid | languageid | language |
|-|-|-|
|1|30|c#|
|1|108|java|
|1|110|javascript|
|...|...|

### 3. Query this populated table into two different files

- baskets.txt, example:

`1,"c#,java,javascript,objective-c,php,sql"`

- documents.txt, example:

`1,"30:1,108:1,110:1,156:1,162:1,200:1"`

### 4. Finalize format by removing quotations and replacing commas (in the case of libsvm format for documents.txt)

- baskets.txt, example:

`1,c#,java,javascript,objective-c,php,sql`

- documents.txt, example:

`1 30:1 108:1 110:1 156:1 162:1 200:1`