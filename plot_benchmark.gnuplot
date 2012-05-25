#!/usr/bin/gnuplot -p

set logscale
set autoscale y
set format xy "1e%L"
set format y2 "1e%L"
set y2tics 
set grid
set key top left

set pointsize 1.0
set term png size 1050,600

# ------------------------------------------------------------------------------------------------------

set xlabel 'vector size (n)'
set ylabel 'elapsed time [s]'
set xrange [0.85e2:2.25e7]

set title  'vec_add (c = a + b)'

set output 'benchmark/plot_vec_add_T1_elapsed.png'

plot 'benchmark/vec_results_O0_T1.csv' every 4::1 using 2:3 with points title "do loop, O0, T1", \
     'benchmark/vec_results_O0_T1.csv' every 4::2 using 2:3 with points title  "forall, O0, T1", \
     'benchmark/vec_results_O3_T1.csv' every 4::1 using 2:3 with points title "do loop, O3, T1", \
     'benchmark/vec_results_O3_T1.csv' every 4::2 using 2:3 with points title  "forall, O3, T1" 


set output 'benchmark/plot_vec_add_T0_elapsed.png'

plot 'benchmark/vec_results_O0_T0.csv' every 4::1 using 2:3 with points title "do loop, O0, T0", \
     'benchmark/vec_results_O0_T0.csv' every 4::2 using 2:3 with points title  "forall, O0, T0", \
     'benchmark/vec_results_O3_T0.csv' every 4::1 using 2:3 with points title "do loop, O3, T0", \
     'benchmark/vec_results_O3_T0.csv' every 4::2 using 2:3 with points title  "forall, O3, T0" 


set title  'DAYPX (y = a*y + x)'

set output 'benchmark/plot_daypx_T1_elapsed.png'

plot 'benchmark/vec_results_O0_T1.csv' every 4::3 using 2:3 with points title "do loop, O0, T1", \
     'benchmark/vec_results_O0_T1.csv' every 4::4 using 2:3 with points title  "forall, O0, T1", \
     'benchmark/vec_results_O3_T1.csv' every 4::3 using 2:3 with points title "do loop, O3, T1", \
     'benchmark/vec_results_O3_T1.csv' every 4::4 using 2:3 with points title  "forall, O3, T1" 


set output 'benchmark/plot_daypx_T0_elapsed.png'

plot 'benchmark/vec_results_O0_T0.csv' every 4::3 using 2:3 with points title "do loop, O0, T0", \
     'benchmark/vec_results_O0_T0.csv' every 4::4 using 2:3 with points title  "forall, O0, T0", \
     'benchmark/vec_results_O3_T0.csv' every 4::3 using 2:3 with points title "do loop, O3, T0", \
     'benchmark/vec_results_O3_T0.csv' every 4::4 using 2:3 with points title  "forall, O3, T0" 


set xlabel 'matrix size (n,n)'
set ylabel 'elapsed time [s]'
set xrange [0.95e2:1.6e3]
set xtics 100,2,2000
set format x "%g"

set title  'mat_mult (C = A * B)'

set output 'benchmark/plot_mat_mult_T1_elapsed.png'

plot 'benchmark/mat_results_O0_T1.csv' every 2::1 using 2:3 with points title "do loop, O0, T1", \
     'benchmark/mat_results_O0_T1.csv' every 2::2 using 2:3 with points title  "forall, O0, T1", \
     'benchmark/mat_results_O3_T1.csv' every 2::1 using 2:3 with points title "do loop, O3, T1", \
     'benchmark/mat_results_O3_T1.csv' every 2::2 using 2:3 with points title  "forall, O3, T1" 


set output 'benchmark/plot_mat_mult_T0_elapsed.png'

plot 'benchmark/mat_results_O0_T0.csv' every 2::1 using 2:3 with points title "do loop, O0, T0", \
     'benchmark/mat_results_O0_T0.csv' every 2::2 using 2:3 with points title  "forall, O0, T0", \
     'benchmark/mat_results_O3_T0.csv' every 2::1 using 2:3 with points title "do loop, O3, T0", \
     'benchmark/mat_results_O3_T0.csv' every 2::2 using 2:3 with points title  "forall, O3, T0" 


# ------------------------------------------------------------------------------------------------------

set xlabel 'vector size (n)'
set ylabel 'total cpu time / num (concurrent) threads [s]'
set xrange [0.85e2:2.25e7]
set xtics auto
set format x "1e%L"
set key left center

set title 'single threaded (T1) VS multi threaded (T0): vec_add (c = a + b)'

set output 'benchmark/plot_vec_add_T1_T0_cputime.png'

plot 'benchmark/vec_results_O3_T1.csv' every 4::1 using 2:5 with points title "do loop, O3, T1", \
     'benchmark/vec_results_O3_T0.csv' every 4::1 using 2:5 with points title "do loop, O3, T0", \
     '< paste benchmark/vec_results_O3_T1.csv benchmark/vec_results_O3_T0.csv' \
        every 4::1 using 2:($5/$9) with line title "efficiency"


set title 'single threaded (T1) VS multi threaded (T0): DAYPX (y = a*y + x)'

set output 'benchmark/plot_daypx_T1_T0_cputime.png'

plot 'benchmark/vec_results_O3_T1.csv' every 4::3 using 2:5 with points title "do loop, O3, T1", \
     'benchmark/vec_results_O3_T0.csv' every 4::3 using 2:5 with points title "do loop, O3, T0", \
     '< paste benchmark/vec_results_O3_T1.csv benchmark/vec_results_O3_T0.csv' \
        every 4::3 using 2:($5/$9) with line title "efficiency"


set xlabel 'matrix size (n,n)'
set ylabel 'total cpu time / num (concurrent) threads [s]'
set xrange [0.95e2:1.6e3]
set xtics 100,2,2000
set format x "%g"
set key left top

set title  'single threaded (T1) VS multi threaded (T0): mat_mult (C = A * B)'

set output 'benchmark/plot_mat_mult_T1_T0_cputime.png'

plot 'benchmark/mat_results_O3_T1.csv' every 2::1 using 2:5 with points title "do loop, O3, T1", \
     'benchmark/mat_results_O3_T0.csv' every 2::1 using 2:5 with points title "do loop, O3, T0", \
     '< paste benchmark/mat_results_O3_T1.csv benchmark/mat_results_O3_T0.csv' \
        every 2::1 using 2:($5/$9) with line title "efficiency"







