#!/bin/bash

while [ true ]; do
for j in ./animation/*.txt; do
echo -e "$(<$j)";
sleep 0.1;
clear
done
done
