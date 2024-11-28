#!/bin/bash

mkdir -p log fig

threads=128

for i in 60 80 100 120 140 160; do
    make count_mis2_rr i=$i threads=$threads
done

for i in 60 80 100 120 140 160 180 200 220; do
    make count_xiao2013_rr i=$i threads=$threads
    make count_ip_rr i=$i threads=$threads
    make count_lp_xiao_rr i=$i threads=$threads
done

for i in 60 80 100 120 140 160 180 200; do
    make count_ip_er i=$i p=0.03 threads=$threads
    make count_lp_er i=$i p=0.03 threads=$threads
done

for m in 8 9 10 11 12 13 14; do
    make count_ip_ksg m=$m n=$m filling=0.8 threads=$threads
    make count_lp_ksg m=$m n=$m filling=0.8 threads=$threads
done

make plot