#!/bin/bash

name='frodo'

grep -vwFf stopwords.txt $name.txt | grep -oE '\b[A-Z][a-zA-Z]*\b' | awk 'length($0) > 3'  >> $name.small.txt
