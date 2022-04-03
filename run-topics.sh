#!/usr/bin/env bash
sbt --error 'set showSuccess := false' 'runMain stackoverflow.Topics data/documents.txt' > data/clusters.txt

cat data/clusters.txt
