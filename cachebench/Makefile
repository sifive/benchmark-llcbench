SHELL	= /bin/sh
HOSTNAME = uname -n
FULLNAME = uname -smn

# ============================================================================
# Compiler override support
# ============================================================================
# Save command-line overrides BEFORE including sys.def
# Priority: Command line > Environment > sys.def > defaults
# ============================================================================

# Save CC and CFLAGS if provided from command line
OVERRIDE_CC := $(CC)
OVERRIDE_CFLAGS := $(CFLAGS)
OVERRIDE_CB_CC := $(CB_CC)
OVERRIDE_CB_CFLAGS := $(CB_CFLAGS)
OVERRIDE_CB_LDFLAGS := $(CB_LDFLAGS)
OVERRIDE_CB_LIBS := $(CB_LIBS)

include ../user.def
-include ../sys.def

# Set defaults if sys.def doesn't exist or doesn't define these
CB_CC ?= gcc
CB_CFLAGS ?= -O2
CB_LDFLAGS ?= $(CB_CFLAGS)
CB_LIBS ?= -lrt

# Now apply overrides AFTER sys.def has been loaded
# CB_CC takes precedence, then CC, then default
ifneq ($(OVERRIDE_CB_CC),)
CB_CC := $(OVERRIDE_CB_CC)
else ifneq ($(OVERRIDE_CC),)
CB_CC := $(OVERRIDE_CC)
endif

# CB_CFLAGS takes precedence, then CFLAGS, then default
ifneq ($(OVERRIDE_CB_CFLAGS),)
CB_CFLAGS := $(OVERRIDE_CB_CFLAGS)
else ifneq ($(OVERRIDE_CFLAGS),)
CB_CFLAGS := $(OVERRIDE_CFLAGS)
endif

# CB_LDFLAGS override
ifneq ($(OVERRIDE_CB_LDFLAGS),)
CB_LDFLAGS := $(OVERRIDE_CB_LDFLAGS)
endif

# CB_LIBS override
ifneq ($(OVERRIDE_CB_LIBS),)
CB_LIBS := $(OVERRIDE_CB_LIBS)
endif

# Runtime options
CBOPTS  = -m $(CB_Memsize) -e $(CB_RepeatCount) -x $(CB_Resolution) -d $(CB_SecondsPerIteration)
DATA	= $(CB_Datatype)
TAG	= ""

cachebench: cachebench.c flushall.o timer.o
	$(CB_CC) $(CB_CFLAGS) -DUSE_$(DATA) -I.. cachebench.c flushall.o timer.o $(CB_LIBS) -o $@

flushall.o: ../flushall.c
	$(CB_CC) -c -I.. ../flushall.c

timer.o: ../timer.c
	$(CB_CC) $(CB_CFLAGS) -c -I.. ../timer.c

results:
	@mkdir -p ../results
	-ln -s ../results results

run: results read.dat write.dat rmw.dat handread.dat handwrite.dat handrmw.dat memset.dat memcpy.dat script

script:
	@sed -e "s|TITLE|Memory Hierarchy Performance of ${Result_Prefix}|g" < cachegraph.gp > results/${Result_Prefix}_cache.gp; echo "plot \"${Result_Prefix}_cache_read.dat\" title 'read' with linespoints \\" >> results/${Result_Prefix}_cache.gp; for i in write rmw handread handwrite handrmw memset memcpy; do echo ", \"${Result_Prefix}_cache_$$i.dat\" title '$$i' with linespoints \\" >> results/${Result_Prefix}_cache.gp; done;
	@cd results; tar cf ${Result_Prefix}-cachebench-datafiles.tar ${Result_Prefix}_cache*.dat ${Result_Prefix}_cache.gp; echo ""; echo "Datafiles and GNUplot scripts are located in the results directory."; echo "";

graphs graph:
	@cd results; gnuplot <  ${Result_Prefix}_cache.gp > /dev/null
	cd results; gnuplot < ${Result_Prefix}_cache.gp > ${Result_Prefix}_cache.ps
	@echo ""; echo "Memory hierarchy graph is in results/${Result_Prefix}_cache.ps"
	@if command -v ps2pdf >/dev/null 2>&1; then \
		cd results; ps2pdf ${Result_Prefix}_cache.ps ${Result_Prefix}_cache.pdf; \
		echo "PDF version: results/${Result_Prefix}_cache.pdf"; \
	fi
	@if command -v convert >/dev/null 2>&1; then \
		cd results; convert -density 300 ${Result_Prefix}_cache.ps ${Result_Prefix}_cache.png; \
		echo "PNG version: results/${Result_Prefix}_cache.png"; \
	fi
	@echo ""
	@cd results; tar cf ${Result_Prefix}-cachebench-graphs.tar *.ps *.pdf *.png 2>/dev/null || tar cf ${Result_Prefix}-cachebench-graphs.tar *.ps; echo ""
clean:
	-rm -f *.o *~ core */*~

clobber: clean
	-rm -f cachebench

doc:
	cd doc; $(MAKE)

read.dat: cachebench 
	@echo "Measuring Read..."
	./cachebench  $(CBOPTS) -r > results/${Result_Prefix}_cache_$@
write.dat: cachebench 
	@echo "Measuring Write..."
	./cachebench  $(CBOPTS) -w > results/${Result_Prefix}_cache_$@
rmw.dat: cachebench 
	@echo "Measuring RMW..."
	./cachebench  $(CBOPTS) -b > results/${Result_Prefix}_cache_$@
handread.dat: cachebench 
	@echo "Measuring Tuned Read..."
	./cachebench  $(CBOPTS) -tr > results/${Result_Prefix}_cache_$@
handwrite.dat: cachebench 
	@echo "Measuring Tuned Write..."
	./cachebench  $(CBOPTS) -tw > results/${Result_Prefix}_cache_$@
handrmw.dat: cachebench 
	@echo "Measuring Tuned RMW..."
	./cachebench  $(CBOPTS) -tb > results/${Result_Prefix}_cache_$@
memset.dat: cachebench 
	@echo "Measuring memset()..."
	./cachebench  $(CBOPTS) -s > results/${Result_Prefix}_cache_$@
memcpy.dat: cachebench 
	@echo "Measuring memcpy()..."
	./cachebench  $(CBOPTS) -p > results/${Result_Prefix}_cache_$@

