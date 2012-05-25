#!/bin/zsh

olevels=(0 3)
nthreads=(0 1) # 0 equals "let omp choose"
vec_sizes=(100 126 158 200 251 316 398 501 631 794 1000         \
           1259 1585 1995 2512 3162 3981 5012 6310 7943         \
           10000 12589 15849 19953 25119 31623 39811 50119      \
           63096 79433 100000 125893 158489 199526 251189       \
           316228 398107 501187 630957 794328 1000000 1258925   \
           1584893 1995262 2511886 3162278 3981072 5011872      \
           6309573 7943282 10000000 14125375 20000000)

mat_sizes=(100 126 158 200 251 316 398 501 631 794 1000 1150 1300 1500)

mkdir -p benchmark/

for i in $olevels; do
    make clean
    make GDEBUG= FOTHER="-O$i" linalg
    mv linalg benchmark/_linalg_O$i
done

cd benchmark/
export OMP_SCHEDULE="static"
./_linalg_O${i[1]} 0 0  >  num_threads_at_T0.txt

for i in $olevels; do
    for j in $nthreads; do
        if [[ $j == 0 ]]; then
            unset OMP_NUM_THREADS
        else
            export OMP_NUM_THREADS=$j
        fi

        : > vec_results_O${i}_T$j.csv
        for n in $vec_sizes; do
            nstr=$(printf "%8d" $n)
            ./_linalg_O$i $n 0 | sed -re 's/\|\|[^:]*:/'$nstr'   /; s/\|\|[^:]*://g' \
                >> vec_results_O${i}_T$j.csv
        done
        
        : > mat_results_O${i}_T$j.csv
        for n in $mat_sizes; do
            nstr=$(printf "%4d" $n)
            ./_linalg_O$i 0 $n | sed -re 's/\|\|[^:]*:/'$nstr'   /; s/\|\|[^:]*://g' \
                >> mat_results_O${i}_T$j.csv
        done
    done
done















