SHELL = /bin/sh

# ============================================================================
# Compiler and flags override support
# ============================================================================
# Usage examples:
#   make cache-bench CC=clang CFLAGS="-O3 -march=native"
#   make cache-bench CB_CC=gcc-12 CB_CFLAGS="-O2 -g"
#   make blas-bench BB_CC=icc BB_CFLAGS="-O3 -xHost"
#   make mp-bench MP_MPI_CC=mpicc MP_CFLAGS="-O3"
#
# Override variables (will be passed to sub-makefiles):
#   CC, CFLAGS, LDFLAGS       - Override all C compilers and flags
#   CB_CC, CB_CFLAGS, CB_LDFLAGS - Override CacheBench compiler and flags
#   BB_CC, BB_CFLAGS, BB_LDFLAGS - Override BlasBench compiler and flags
#   MP_MPI_CC, MP_CFLAGS, MP_LDFLAGS - Override MPBench compiler and flags
# ============================================================================

# Collect override variables to pass to sub-makefiles
# ONLY pass variables that were explicitly set on command line or environment
MAKE_OVERRIDES =

# Global overrides (CC/CFLAGS/LDFLAGS apply to all benchmarks)
ifdef CC
MAKE_OVERRIDES += CC="$(CC)"
endif
ifdef CFLAGS
MAKE_OVERRIDES += CFLAGS="$(CFLAGS)"
endif
ifdef LDFLAGS
MAKE_OVERRIDES += LDFLAGS="$(LDFLAGS)"
endif

# CacheBench specific overrides
ifdef CB_CC
MAKE_OVERRIDES += CB_CC="$(CB_CC)"
endif
ifdef CB_CFLAGS
MAKE_OVERRIDES += CB_CFLAGS="$(CB_CFLAGS)"
endif
ifdef CB_LDFLAGS
MAKE_OVERRIDES += CB_LDFLAGS="$(CB_LDFLAGS)"
endif
ifdef CB_LIBS
MAKE_OVERRIDES += CB_LIBS="$(CB_LIBS)"
endif

# BlasBench specific overrides
ifdef BB_CC
MAKE_OVERRIDES += BB_CC="$(BB_CC)"
endif
ifdef BB_CFLAGS
MAKE_OVERRIDES += BB_CFLAGS="$(BB_CFLAGS)"
endif
ifdef BB_F77
MAKE_OVERRIDES += BB_F77="$(BB_F77)"
endif
ifdef BB_LD
MAKE_OVERRIDES += BB_LD="$(BB_LD)"
endif
ifdef BB_LDFLAGS
MAKE_OVERRIDES += BB_LDFLAGS="$(BB_LDFLAGS)"
endif
ifdef BB_LIBS
MAKE_OVERRIDES += BB_LIBS="$(BB_LIBS)"
endif

# MPBench specific overrides
ifdef MP_MPI_CC
MAKE_OVERRIDES += MP_MPI_CC="$(MP_MPI_CC)"
endif
ifdef MP_CFLAGS
MAKE_OVERRIDES += MP_CFLAGS="$(MP_CFLAGS)"
endif
ifdef MP_LDFLAGS
MAKE_OVERRIDES += MP_LDFLAGS="$(MP_LDFLAGS)"
endif
ifdef MP_LIBS
MAKE_OVERRIDES += MP_LIBS="$(MP_LIBS)"
endif

# Include sys.def AFTER collecting overrides
# This way sys.def values don't interfere with command-line detection
-include sys.def

dum:
	@echo "Please use one of the following targets:"
	@echo
	@echo "For all three : compile, run, script, graph, clean, clobber, reconfig"
	@echo "For BlasBench : blas-bench, blas-run, blas-script, blas-graph"
	@echo "For CacheBench: cache-bench, cache-run, cache-script, cache-graph"
	@echo "For MPBench   : mp-bench, mp-run, mp-script, mp-graph"
	@echo
	@echo "clean: removes object files and leaves result files"
	@echo "clobber: removes binary files and leaves result files"
	@echo "distclean: removes everything!"
	@echo
	@echo "Compiler Override Examples:"
	@echo "  make cache-bench CC=clang CFLAGS=\"-O3 -march=native\""
	@echo "  make cache-bench CB_CC=gcc-12 CB_CFLAGS=\"-O2 -g\""
	@echo "  make blas-bench BB_CC=icc BB_CFLAGS=\"-O3 -xHost\""
	@echo "  make mp-bench MP_MPI_CC=mpicc MP_CFLAGS=\"-O3\""

compile bench: blas-bench mp-bench cache-bench

run: blas-run cache-run mp-run

scripts script: blas-script cache-script mp-script

graphs graph: blas-graph cache-graph mp-graph

blas-bench:
	cd blasbench; $(MAKE) $(MAKE_OVERRIDES)
blas-run:
	cd blasbench; $(MAKE) run $(MAKE_OVERRIDES)
blas-script:
	cd blasbench; $(MAKE) script $(MAKE_OVERRIDES)
blas-graph:
	cd blasbench; $(MAKE) graph $(MAKE_OVERRIDES)
cache-bench:
	cd cachebench; $(MAKE) $(MAKE_OVERRIDES)
cache-run:
	cd cachebench; $(MAKE) run $(MAKE_OVERRIDES)
cache-script:
	cd cachebench; $(MAKE) script $(MAKE_OVERRIDES)
cache-graph:
	cd cachebench; $(MAKE) graph $(MAKE_OVERRIDES)
mp-bench:
	cd mpbench; $(MAKE) $(MAKE_OVERRIDES)
mp-run:
	cd mpbench; $(MAKE) run $(MAKE_OVERRIDES)
mp-script:
	cd mpbench; $(MAKE) script $(MAKE_OVERRIDES)
mp-graph:
	cd mpbench; $(MAKE) graph $(MAKE_OVERRIDES)

reconfig:
	-rm -f sys.def
	ln -s conf/sys.default sys.def

# Don't auto-create sys.def - allow building without it
# Users can explicitly run platform targets (e.g., make linux-riscv64) if needed
.PHONY: reconfig

clean:
	cd mpbench; make clean
	cd blasbench; make clean
	cd cachebench; make clean
	cd doc; make clean
	rm -f *~ */*~

clobber: 
	cd mpbench; make clobber
	cd blasbench; make clobber
	cd cachebench; make clobber
	cd doc; make clobber

distclean: clean clobber reconfig
	-rm -f *~ */*~ results/*
	rm -f mpbench/results blasbench/results cachebench/results

dist: distclean
	cd ..; rm llcbench.tar.gz; tar --exclude CVS -czvf llcbench.tar.gz llcbench
	mv ../llcbench.tar.gz .

install: 
	scp llcbench.tar.gz www/*.html ~/www-home/llcbench
	scp llcbench.tar.gz www/*.html /silk/homes/icl/projects/llcbench/

