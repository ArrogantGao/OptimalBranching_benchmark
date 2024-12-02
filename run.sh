#!/bin/bash

mkdir -p log fig data

threads=128

# make count_all_mis2_3rr threads=$threads

make count_all_opt_3rr threads=$threads
make count_all_opt_er threads=$threads
make count_all_opt_ksg threads=$threads

make count_all_xiao_3rr threads=$threads

make plot