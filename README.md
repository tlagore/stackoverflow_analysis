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

<div align="center" style="max-width:50%;">
    <b>Note that load_and_parse.sh expects a folder called data/ to be at the root of the script, with the necessary csv files within it</b>
</div>

<hr>


run `./load_and_parse.sh`

If you would like to keep the csvs in the sqlite3 database, then press `n` at the prompt.

Example output:

```
./load_and_parse.sh 
Would you like to delete the temporary sqlite3 database after creating baskets.csv? (y/n): n
'data/stackoverflowdb.db' already exists. Reimport? (y/n): y
Loading csvs into sqlite3 (loaddb.sql)...

real	3m14.333s
user	1m44.955s
sys	0m45.939s
Performing aggregation query (language_query.sql)...

real	3m36.301s
user	2m32.660s
sys	1m2.729s
Performing file generation query (file_query.sql)...

real	0m1.140s
user	0m1.041s
sys	0m0.082s
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

- see `language_query.sql`

i.e.
| userid | languageid | language |
|-|-|-|
|1|30|c#|
|1|108|java|
|1|110|javascript|
|...|...|

### 3. Query this populated table into two different files

- see `file_query.sql`

- baskets.txt, example:

`1,"c#,java,javascript,objective-c,php,sql"`

- documents.txt, example:

`1,"30:1,108:1,110:1,156:1,162:1,200:1"`

### 4. Finalize format by removing quotations and replacing commas (in the case of libsvm format for documents.txt)

- baskets.txt, example:

`1,c#,java,javascript,objective-c,php,sql`

- documents.txt, example:

`1 30:1 108:1 110:1 156:1 162:1 200:1`

# Analysis
### Basket Analysis

Run `run-baskets.sh` to run the basket analysis.

This will output a file to data/basket_results.txt with results of the basket analysis

### Topic Analysis

Run `run-topics.sh` to run the topic analysis

This will output a file to data/clusters.txt with results of the topic clustering

### NOTE ON RUNNING THE ABOVE:

An error may be thrown at the end, unrelated to the execution of the programs. To avoid this,

1. Run sbt package
2. For basket analysis
   1. `<path-to-spark>/bin/spark-submit --class stackoverflow.Baskets target/scala-2.13/stackoverflow_2.13-0.1.0-SNAPSHOT.jar data/baskets.txt`
3. For topic analysis:
   1. `<path-to-spark>/bin/spark-submit --class stackoverflow.Topics target/scala-2.13/stackoverflow_2.13-0.1.0-SNAPSHOT.jar data/documents.txt`