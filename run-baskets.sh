#!/usr/bin/env bash
time (sbt --error 'set showSuccess := false' 'runMain stackoverflow.Baskets data/baskets.txt' > data/basket_results.txt)
cat data/basket_results.txt
