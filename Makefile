.SUFFIXES: .f90, .o
FC = ftn # fortran wrapper (choose Cray compiler via 'module load')
FFLAGS=-O0 -Oscalar2 -Ovector2 -Oipa3 -Ofp2 -O cache0 -O fusion2 -O thread2 -h negmsgs -e o
# Note for Cray fortran compiler: -O n, where n = 0, 1, 2, or 3 (level of optimisation)
#Other FFLAGS options for Cray compiler:
#FFLAGS=-O0 # turn off all compiler optimisation
#FFLAGS=-O0 -Oscalar2 -Ovector2 -Oipa3 -Ofp2 -O cache2 -O fusion2 -O thread2 -h negmsgs -e o # turn on m
oderately aggressive automatic cache management (for comparison with manual cache blocking)
#FFLAGS=-02 # level 2 optimisation. Note - this will replace the code below with a library call to do the matrix multiplication

.o.f90:
	$(FC) -c $< 

matmult_blocked.o: matmult_blocked.f90
	$(FC) $(FFLAGS) -c $<

matmult_blocked.exe: matmult_blocked.o
	$(FC) -o $@ $^ $(LIBS)

matmult_nonblock.o: matmult_nonblock.f90
	$(FC) $(FFLAGS) -c $<

matmult_nonblock.exe: matmult_nonblock.o
	$(FC) -o $@ $^ $(LIBS)

# Tidy up
clean: 
	$(RM) *.o *.mod

allclean:  clean
	$(RM) *.exe


