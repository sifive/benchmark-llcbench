#
# Do not touch this file...
#

SHELL		= /bin/sh

# ============================================================================
# Compiler override support
# ============================================================================
# Save command-line overrides BEFORE including sys.def
# Priority: Command line > Environment > sys.def > defaults
# ============================================================================

# Save CC and CFLAGS if provided from command line
OVERRIDE_CC := $(CC)
OVERRIDE_CFLAGS := $(CFLAGS)
OVERRIDE_MP_MPI_CC := $(MP_MPI_CC)
OVERRIDE_MP_CFLAGS := $(MP_CFLAGS)
OVERRIDE_MP_LDFLAGS := $(MP_LDFLAGS)
OVERRIDE_MP_LIBS := $(MP_LIBS)

include ../user.def
-include ../sys.def

# Set defaults if sys.def doesn't exist or doesn't define these
MP_MPI_CC ?= mpicc
MP_CFLAGS ?= -O2
MP_LDFLAGS ?= $(MP_CFLAGS)
MP_LIBS ?= -lrt

# Now apply overrides AFTER sys.def has been loaded
# MP_MPI_CC takes precedence, then CC, then default
ifneq ($(OVERRIDE_MP_MPI_CC),)
MP_MPI_CC := $(OVERRIDE_MP_MPI_CC)
else ifneq ($(OVERRIDE_CC),)
MP_MPI_CC := $(OVERRIDE_CC)
endif

# MP_CFLAGS takes precedence, then CFLAGS, then default
ifneq ($(OVERRIDE_MP_CFLAGS),)
MP_CFLAGS := $(OVERRIDE_MP_CFLAGS)
else ifneq ($(OVERRIDE_CFLAGS),)
MP_CFLAGS := $(OVERRIDE_CFLAGS)
endif

# MP_LDFLAGS override
ifneq ($(OVERRIDE_MP_LDFLAGS),)
MP_LDFLAGS := $(OVERRIDE_MP_LDFLAGS)
endif

# MP_LIBS override
ifneq ($(OVERRIDE_MP_LIBS),)
MP_LIBS := $(OVERRIDE_MP_LIBS)
endif

# Runtime options
MPOPTS = -i ${MP_Iterations} -e ${MP_RepeatCount} -m ${MP_Memsize} -x ${MP_Resolution}
MPIFULLRUNOPTS = $(MPIRUNOPTS)

all mpi: mpi_bench

doc:
	cd doc; $(MAKE)

test test-mpi: mpi_bench 
	@echo "Running latency with small values as a test."
	$(MPIRUNCMD) $(MPIFULLRUNOPTS) $(MPIRUNPROCS) 2 $(MPIRUNPOSTOPTS) -l -i 1 -e 1 -x 0 -m 16

results:
	@mkdir -p ../results
	-ln -s ../results results

run run-mpi: results latency roundtrip bandwidth bibw reduce broadcast allreduce alltoall script

script:
	@sh make_templates.sh results/${Result_Prefix}_mpi
	@echo ""; echo "Datafiles and GNUplot scripts are located in the results directory."; echo ""
	@cd results; tar cf ${Result_Prefix}-mpbench-datafiles.tar ${Result_Prefix}_mpi*.dat ${Result_Prefix}_mpi*.gp

graphs graph: 
	sh make_graphs.sh results/${Result_Prefix}_mpi
	@echo ""; echo "MPI performance graphs are located in the results directory."; echo ""
	@cd results; tar cf ${Result_Prefix}-mpbench-graphs.tar ${Result_Prefix}_mpi*.ps

latency: mpi
	@echo "Measuring Latency..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -l > results/${Result_Prefix}_mpi_$@.dat

roundtrip: mpi
	@echo "Measuring Roundtrip..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -r > results/${Result_Prefix}_mpi_$@.dat

bandwidth: mpi
	@echo "Measuring Bandwidth..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -b > results/${Result_Prefix}_mpi_$@.dat

alltoall: mpi
	@echo "Measuring All-to-all..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -a > results/${Result_Prefix}_mpi_$@.dat

bibw: mpi
	@echo "Measuring Bidirectional Bandwidth..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -d > results/${Result_Prefix}_mpi_$@.dat

broadcast: mpi
	@echo "Measuring Broadcast..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -c > results/${Result_Prefix}_mpi_$@.dat

reduce: mpi
	@echo "Measuring Reduce..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -y > results/${Result_Prefix}_mpi_$@.dat

allreduce: mpi
	@echo "Measuring Allreduce..."
	$(MPIRUNCMD) $(MPIRUNOPTS) $(MPIRUNPROCS) ${MP_Tasks} $(MPIRUNPOSTOPTS) $(MPOPTS) -z > results/${Result_Prefix}_mpi_$@.dat

mpi_bench: mpbench.o flushall.o timer.o
	$(MP_MPI_CC) $(MP_LDFLAGS) mpbench.o flushall.o timer.o -o $@ $(MPI_LIBS) $(MP_LIBS)

mpbench.o: mpbench.c
	$(MP_MPI_CC) $(MP_CFLAGS) $(MPI_INC) -DMPI -I.. -c mpbench.c -o $@

timer.o: ../timer.c
	$(MP_MPI_CC) -c -I.. ../timer.c -o $@

flushall.o: ../flushall.c
	$(MP_MPI_CC) -c -I.. ../flushall.c -o $@

clean:
	-rm -f PI* *.o *~ core */*~

clobber: clean
	-rm -f mpi_bench
