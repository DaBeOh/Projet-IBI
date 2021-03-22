#!/bin/bash

failed=0

for file in *.fq.gz; do
    md5=$(gunzip -c "$file" | openssl md5 | cut -f2 -d " ")
    gold=$(grep "${file/.gz/}" md5sums.txt | cut -f2)
    if [ "$md5" != "$gold" ]; then
        failed=$(($failed + 1))
        echo FAILED $file
    else
        echo SUCCESS $file
    fi
done

if [ $failed -gt 0 ]; then
    echo $failed downloads failed.
    exit 1
fi