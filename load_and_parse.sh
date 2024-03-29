response=""
reimport=""

if [ -d "data" ]
then
    #!/usr/bin/env bash
    read -n 1 -r -p "Would you like to delete the temporary sqlite3 database after creating baskets.csv? (y/n): " response
    echo ""

    if [ -f "data/stackoverflowdb.db" ]
    then
        read -n 1 -r -p "'data/stackoverflowdb.db' already exists. Reimport? (y/n): " reimport
        echo ""
    else
        reimport="y"
    fi

    if [ "$reimport" = "y" ]
    then
        echo -e "\e[1;32mLoading csvs into sqlite3 (loaddb.sql)...\e[0m"
        time sqlite3 data/stackoverflowdb.db < loaddb.sql
    fi
    
    echo -e "\e[1;32mPerforming aggregation query (language_query.sql)...\e[0m"
    time sqlite3 data/stackoverflowdb.db < language_query.sql

    echo -e "\e[1;32mPerforming file generation query (file_query.sql)...\e[0m"
    time sqlite3 data/stackoverflowdb.db < file_query.sql
    
    echo -e "\e[1;32mCleaning 'baskets.txt'...\e[0m"
    # sed script obtained from https://stackoverflow.com/a/38159593/4089216
    # remove quotations
    sed -i 's/\"//g' data/baskets.txt

    echo -e "\e[1;32mCleaning 'documents.txt'...\e[0m"
    # remove quotations
    sed -i 's/\"//g' data/documents.txt
    # replace comma with space
    sed -i 's/,/ /g' data/documents.txt
    

    if [ "$response" = "y" ]
    then
        echo -e "\e[1;33mDeleting temporary database 'data/stackoverflowdb.db'\e[0m"
        rm data/stackoverflowdb.db
    else
        echo -e "\e[1;33mDid not delete temporary database 'data/stackoverflowdb.db'\e[0m"
    fi
    echo "Done"
else
    echo -e "\e[31mCannot find directory 'data/'. Please ensure this directory exists at the root folder where you are running these scripts and has the stackoverflow csv files within it.\e[0m"
fi
