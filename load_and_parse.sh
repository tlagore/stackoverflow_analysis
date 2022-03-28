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
        if [ "$reimport" = "y" ]
        then
        echo -e "\e[1;32mLoading csvs into sqlite3 (loaddb.sql)...\e[0m"
        time sqlite3 data/stackoverflowdb.db < loaddb.sql
        fi
    fi

    echo -e "\e[1;32mPerforming basket query to export to baskets.csv (basket_query.sql)...\e[0m"
    time sqlite3 data/stackoverflowdb.db < basket_query.sql

    echo -e "\e[1;32mRemoving quotations from language column and renaming to 'baskets.txt'...\e[0m"
    # sed script obtained from https://stackoverflow.com/a/38159593/4089216
    time sed -i 's/\"//g' data/baskets.csv
    mv data/baskets.csv data/baskets.txt

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
