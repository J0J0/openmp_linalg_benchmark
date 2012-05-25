# vim: noet

.PHONY : all clean cleanall underscorify starter benchmark cleanbenchmark plotbenchmark benchmarkandplot

PROGRAMS = linalg

FC     = gfortran
GDEBUG = -g
FOTHER =
FFLAGS = $(GDEBUG) $(FOTHER) -fimplicit-none -fopenmp

all : $(PROGRAMS) underscorify starter


linalg: operations.o helpers.o linalg.o
	$(FC) $(FFLAGS) -o $@ $^

helpers.o: operations.o

%.o: %.F90 
	$(FC) $(FFLAGS) -c $<

starter:
	@echo "#!/bin/bash" > _start_linalg
	@echo '[[ -z "$${OMP_SCHEDULE}" ]] && export OMP_SCHEDULE=static' >> _start_linalg
	@echo 'exec ./_linalg "$$@"' >> _start_linalg
	@chmod u+x _start_linalg

benchmark: cleanbenchmark
	@echo -n "please wait ... "
	@./benchmark.sh
	@echo "done."

plotbenchmark:
	./plot_benchmark.gnuplot

benchmarkandplot: benchmark plotbenchmark

underscorify:
	@for f in $(PROGRAMS) ; do if test -e $$f; then echo mv $$f _$$f; mv $$f _$$f; fi; done

clean:
	rm -f *.o *.mod

cleanbenchmark:
	rm -rf benchmark/

cleanall: clean cleanbenchmark
	rm -f $(PROGRAMS)
	rm -f $(addprefix _,$(PROGRAMS))
	rm -f _start_linalg

