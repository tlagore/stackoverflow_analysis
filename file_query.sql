.mode csv
.output data/baskets.txt

-- create temporary baskets.txt file (needs to be stripped of quotation marks)
SELECT userid, group_concat(language)
    FROM known_languages
    GROUP BY userid;

.output data/documents.txt

WITH joined AS (
    SELECT userid, cast(languageid AS TEXT) || ":1" AS language
    FROM known_languages
    ORDER BY languageid
)
SELECT userid, group_concat(language) AS language
    FROM joined
    GROUP BY userid;

.output stdout
.mode list