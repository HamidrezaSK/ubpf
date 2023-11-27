obj := .
src := .


DEBUGBPF = -DDEBUG
DEBUGFLAGS = -O0 -g -Wall
PFLAGS = $(DEBUGFLAGS)

INCLUDEFLAGS = -I$(obj)/lib/linux_includes \
	       -I..


always = lib/bpf/balancer.bpf.o
always += lib/bpf/healthchecking_ipip.o
always += lib/bpf/healthchecking.bpf.o
always += lib/bpf/xdp_pktcntr.o
always += lib/bpf/xdp_root.o

# HOSTCFLAGS += $(INCLUDEFLAGS) $(PFLAGS)
# HOSTCFLAGS_bpf_load.o += $(INCLUDEFLAGS) $(PFLAGS) -Wno-unused-variable


# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
LLC ?= llc
CLANG ?= clang-14

# Trick to allow make to be run from this directory
all: $(always)


clean:
	rm -f $(always) *~

$(obj)/lib/bpf/%.o: $(src)/lib/bpf/%.c
	$(CLANG) $(INCLUDEFLAGS) \
	$(DEBUGBPF) -D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
		-Wno-compare-distinct-pointer-types \
		-O2 -emit-llvm -c -g $< -o -| $(LLC) -march=bpf -filetype=obj -o $@