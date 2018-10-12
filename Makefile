.SUFFIXES: .f90, .o
FC = ftn # fortran wrapper (ARCHER uses Cray compiler by default)
FFLAGS=-O0 -Oscalar2 -Ovector2 -Oipa3 -Ofp2 -O cache0 -O fusion2 -O thread2 -h negmsgs -e o

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


