# OptimalBranching_benchmark
Benchmark for the optimal branching package

# Init

The project is developed under Julia 1.11, please make sure you have it installed.

Then to initialize the project, enter the folder and run
```
$ make
```
and then all will be installed.

# How to run

To run the benchmark, enter the folder and run
```
$ bash run.sh
```
Multiple threads are supported, change the `threads` variable in the `run.sh` to the desired number.
The run may take a while (a few days with 128 threads), and the log is saved in the `log` folder.

# How to plot
To plot the figures, run
```
$ make plot
```
The figures will be saved in the `fig` folder.