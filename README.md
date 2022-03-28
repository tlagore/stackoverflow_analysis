# Analyzing Programming Languages Used from StackOverflow post tags
This project takes a large set of StackOverflow Data and performs data cleaning and processing in order to perform analysis on the data.

To simulate big data projects where data cannot all be read into memory, the project uses only techniques that do not read the entire dataset into memory.

## StackOverflow Data Processing and Analysis
The data consists of

|file|size|
|-|-|
|posts.csv|4.13GB|
|poststags.csv|770MB|
|users.csv|152MB|
|languages.csv|1MB|

## Data Cleaning: Parse language tags into "Baskets"
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