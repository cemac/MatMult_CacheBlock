## Instructions for running a simple matrix-multiplication cache blocking code on ARCHER HPC

### C. Dearden, June 2018

These instructions were put together based on the ARCHER YouTube webinar: https://www.youtube.com/watch?v=9Fw0-5_xbd0

#### 1) Log on to ARCHER and check out a copy of the code by cloning this repository to your workspace:

   ```git clone https://github.com/cemac/MatMult_CacheBlock```

#### 2) Load CrayPAT modules:

   ```module load perftools-base```

   ```module load perftools```

#### 3) Change directory to `MatMult_CacheBlock`. Open the Makefile and familiarise yourself with the build process and the source code. 

Note in particular the `FFLAGS` settings, which by default are set to:

   ```FFLAGS=-O0 -Oscalar2 -Ovector2 -Oipa3 -Ofp2 -O cache0 -O fusion2 -O thread2 -h negmsgs -e o```

These settings are chosen to help optimise the code enough for it to run reasonably quickly, but not too aggressively that it overshadows the benefits of the cache blocking approach, which is the primary focus of this example. 

Some other FFLAGS options for Cray compiler:

To turn off level 2 optimisation: `FFLAGS=-O0`

Level 2 optimisation: `FFLAGS=-02` (Careful here - this will replace certain lines in the code with a library call to do the matrix multiplication!)

To turn on automatic cache managament (can be useful to compare with manual cache blocking approach):

   ```FFLAGS=-O0 -Oscalar2 -Ovector2 -Oipa3 -Ofp2 -O cache2 -O fusion2 -O thread2 -h negmsgs -e o```

#### 4) Build the executable

Currently the blocked and non-blocked versions of the code must be built and run as separate executables. Let's start by building the cache-blocked version:

   ```make allclean; make matmult_blocked.exe```

Note that in the fortran code, the block size is specified as the integer parameter `chunk_dim` (set to 128 by default). Feel free to experiment with different values.

### 5) Instrument the executable in preparation for performing a sampling experiment:

   ```pat_build ./matmult_blocked.exe```

This will produce an instrumented version of the executable, called `matmult_blocked.exe+pat`

#### 6) Submit the job to the serial nodes on ARCHER

The batch submission script is `cacheBlock_run.pbs`. You will need to edit this file to specify your own ARCHER budget code. When you have done this, submit the job using:

   ```qsub cacheBlock_run.pbs```

This should generate an .xf report file

#### 7) Examine the results of the sampling experiment using `pat_report`:

To do this, you must run the `pat_report` tool on the `.xf` file, e.g. 

   ```pat_report matmult_blocked.exe+pat+2344-2986s.xf > report```

This will save the output to the text file, `report`

#### 8) Once you have generated the pat report for the blocked version of the code, you can repeat the process using the non-blocked verison, i.e. repeat steps 4-7 using `matmult_nonblock.exe` instead, and then compare the cache metrics and wallclock times in both pat report files to quantify the performance benefit of using the cache blocking approach. 


