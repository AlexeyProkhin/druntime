# This makefile is designed to be run by gnu make.
# The default make program on FreeBSD 8.1 is not gnu make; to install gnu make:
#    pkg_add -r gmake
# and then run as gmake rather than make.

QUIET:=@

OS:=
uname_S:=$(shell uname -s)
ifeq (Darwin,$(uname_S))
	OS:=osx
endif
ifeq (Linux,$(uname_S))
	OS:=linux
endif
ifeq (FreeBSD,$(uname_S))
	OS:=freebsd
endif
ifeq (OpenBSD,$(uname_S))
	OS:=openbsd
endif
ifeq (Solaris,$(uname_S))
	OS:=solaris
endif
ifeq (SunOS,$(uname_S))
	OS:=solaris
endif
ifeq (,$(OS))
	$(error Unrecognized or unsupported OS for uname: $(uname_S))
endif

DMD?=dmd

DOCDIR=doc
IMPDIR=import

MODEL=32
override PIC:=$(if $(PIC),-fPIC,)

DFLAGS=-m$(MODEL) -O -release -inline -w -Isrc -Iimport -property $(PIC)
UDFLAGS=-m$(MODEL) -O -release -w -Isrc -Iimport -property $(PIC)
DDOCFLAGS=-m$(MODEL) -c -w -o- -Isrc -Iimport

CFLAGS=-m$(MODEL) -O $(PIC)

ifeq (osx,$(OS))
    ASMFLAGS =
else
    ASMFLAGS = -Wa,--noexecstack
endif

OBJDIR=obj/$(MODEL)
DRUNTIME_BASE=druntime-$(OS)$(MODEL)
DRUNTIME=lib/lib$(DRUNTIME_BASE).a

DOCFMT=-version=CoreDdoc

include ./MANIFEST
MANIFEST:=$(subst \,/,$(MANIFEST))

GC_MODULES = gc/gc gc/gcalloc gc/gcbits gc/gcstats gc/gcx

SRC_D_MODULES = \
	object_ \
	\
	core/atomic \
	core/bitop \
	core/cpuid \
	core/demangle \
	core/exception \
	core/math \
	core/memory \
	core/runtime \
	core/simd \
	core/thread \
	core/time \
	core/vararg \
	\
	core/stdc/config \
	core/stdc/ctype \
	core/stdc/errno \
	core/stdc/math \
	core/stdc/signal \
	core/stdc/stdarg \
	core/stdc/stdio \
	core/stdc/stdlib \
	core/stdc/stdint \
	core/stdc/stddef \
	core/stdc/string \
	core/stdc/time \
	core/stdc/wchar_ \
	\
	core/sys/freebsd/execinfo \
	core/sys/freebsd/sys/event \
	\
	core/sys/posix/signal \
	core/sys/posix/dirent \
	core/sys/posix/sys/select \
	core/sys/posix/sys/socket \
	core/sys/posix/sys/stat \
	core/sys/posix/sys/wait \
	core/sys/posix/netdb \
	core/sys/posix/sys/ioctl \
	core/sys/posix/sys/utsname \
	core/sys/posix/netinet/in_ \
	\
	core/sync/barrier \
	core/sync/condition \
	core/sync/config \
	core/sync/exception \
	core/sync/mutex \
	core/sync/rwmutex \
	core/sync/semaphore \
	\
	$(GC_MODULES) \
	\
	rt/aaA \
	rt/aApply \
	rt/aApplyR \
	rt/adi \
	rt/alloca \
	rt/arrayassign \
	rt/arraybyte \
	rt/arraycast \
	rt/arraycat \
	rt/arraydouble \
	rt/arrayfloat \
	rt/arrayint \
	rt/arrayreal \
	rt/arrayshort \
	rt/cast_ \
	rt/cmath2 \
	rt/cover \
	rt/critical_ \
	rt/deh2 \
	rt/dmain2 \
	rt/invariant \
	rt/invariant_ \
	rt/lifetime \
	rt/llmath \
	rt/memory \
	rt/memory_osx \
	rt/memset \
	rt/minfo \
	rt/monitor_ \
	rt/obj \
	rt/qsort \
	rt/switch_ \
	rt/tlsgc \
	rt/trace \
	\
	rt/util/console \
	rt/util/container \
	rt/util/hash \
	rt/util/string \
	rt/util/utf \
	\
	rt/typeinfo/ti_AC \
	rt/typeinfo/ti_Acdouble \
	rt/typeinfo/ti_Acfloat \
	rt/typeinfo/ti_Acreal \
	rt/typeinfo/ti_Adouble \
	rt/typeinfo/ti_Afloat \
	rt/typeinfo/ti_Ag \
	rt/typeinfo/ti_Aint \
	rt/typeinfo/ti_Along \
	rt/typeinfo/ti_Areal \
	rt/typeinfo/ti_Ashort \
	rt/typeinfo/ti_byte \
	rt/typeinfo/ti_C \
	rt/typeinfo/ti_cdouble \
	rt/typeinfo/ti_cfloat \
	rt/typeinfo/ti_char \
	rt/typeinfo/ti_creal \
	rt/typeinfo/ti_dchar \
	rt/typeinfo/ti_delegate \
	rt/typeinfo/ti_double \
	rt/typeinfo/ti_float \
	rt/typeinfo/ti_idouble \
	rt/typeinfo/ti_ifloat \
	rt/typeinfo/ti_int \
	rt/typeinfo/ti_ireal \
	rt/typeinfo/ti_long \
	rt/typeinfo/ti_ptr \
	rt/typeinfo/ti_real \
	rt/typeinfo/ti_short \
	rt/typeinfo/ti_ubyte \
	rt/typeinfo/ti_uint \
	rt/typeinfo/ti_ulong \
	rt/typeinfo/ti_ushort \
	rt/typeinfo/ti_void \
	rt/typeinfo/ti_wchar \
	\
	etc/linux/memoryerror

# NOTE: trace.d and cover.d are not necessary for a successful build
#       as both are used for debugging features (profiling and coverage)
# NOTE: a pre-compiled minit.obj has been provided in dmd for Win32	 and
#       minit.asm is not used by dmd for Linux

OBJS= $(OBJDIR)/errno_c.o $(OBJDIR)/threadasm.o $(OBJDIR)/complex.o

DOCS=\
	$(DOCDIR)/object.html \
	$(DOCDIR)/core_atomic.html \
	$(DOCDIR)/core_bitop.html \
	$(DOCDIR)/core_cpuid.html \
	$(DOCDIR)/core_demangle.html \
	$(DOCDIR)/core_exception.html \
	$(DOCDIR)/core_math.html \
	$(DOCDIR)/core_memory.html \
	$(DOCDIR)/core_runtime.html \
	$(DOCDIR)/core_simd.html \
	$(DOCDIR)/core_thread.html \
	$(DOCDIR)/core_time.html \
	$(DOCDIR)/core_vararg.html \
	\
	$(DOCDIR)/core_sync_barrier.html \
	$(DOCDIR)/core_sync_condition.html \
	$(DOCDIR)/core_sync_config.html \
	$(DOCDIR)/core_sync_exception.html \
	$(DOCDIR)/core_sync_mutex.html \
	$(DOCDIR)/core_sync_rwmutex.html \
	$(DOCDIR)/core_sync_semaphore.html

IMPORTS=\
	$(IMPDIR)/core/sync/barrier.di \
	$(IMPDIR)/core/sync/condition.di \
	$(IMPDIR)/core/sync/config.di \
	$(IMPDIR)/core/sync/exception.di \
	$(IMPDIR)/core/sync/mutex.di \
	$(IMPDIR)/core/sync/rwmutex.di \
	$(IMPDIR)/core/sync/semaphore.di

COPY=\
	$(IMPDIR)/object.di \
	$(IMPDIR)/core/atomic.d \
	$(IMPDIR)/core/bitop.d \
	$(IMPDIR)/core/cpuid.d \
	$(IMPDIR)/core/demangle.d \
	$(IMPDIR)/core/exception.d \
	$(IMPDIR)/core/math.d \
	$(IMPDIR)/core/memory.d \
	$(IMPDIR)/core/runtime.d \
	$(IMPDIR)/core/simd.d \
	$(IMPDIR)/core/thread.di \
	$(IMPDIR)/core/time.d \
	$(IMPDIR)/core/vararg.d \
	\
	$(IMPDIR)/core/stdc/complex.d \
	$(IMPDIR)/core/stdc/config.d \
	$(IMPDIR)/core/stdc/ctype.d \
	$(IMPDIR)/core/stdc/errno.d \
	$(IMPDIR)/core/stdc/fenv.d \
	$(IMPDIR)/core/stdc/float_.d \
	$(IMPDIR)/core/stdc/inttypes.d \
	$(IMPDIR)/core/stdc/limits.d \
	$(IMPDIR)/core/stdc/locale.d \
	$(IMPDIR)/core/stdc/math.d \
	$(IMPDIR)/core/stdc/signal.d \
	$(IMPDIR)/core/stdc/stdarg.d \
	$(IMPDIR)/core/stdc/stddef.d \
	$(IMPDIR)/core/stdc/stdint.d \
	$(IMPDIR)/core/stdc/stdio.d \
	$(IMPDIR)/core/stdc/stdlib.d \
	$(IMPDIR)/core/stdc/string.d \
	$(IMPDIR)/core/stdc/tgmath.d \
	$(IMPDIR)/core/stdc/time.d \
	$(IMPDIR)/core/stdc/wchar_.d \
	$(IMPDIR)/core/stdc/wctype.d \
	\
	$(IMPDIR)/core/sys/freebsd/dlfcn.d \
	$(IMPDIR)/core/sys/freebsd/execinfo.d \
	$(IMPDIR)/core/sys/freebsd/sys/event.d \
	\
	$(IMPDIR)/core/sys/linux/elf.d \
	$(IMPDIR)/core/sys/linux/epoll.d \
	$(IMPDIR)/core/sys/linux/execinfo.d \
	$(IMPDIR)/core/sys/linux/sys/signalfd.d \
	$(IMPDIR)/core/sys/linux/sys/xattr.d \
	\
	$(IMPDIR)/core/sys/osx/execinfo.d \
	$(IMPDIR)/core/sys/osx/pthread.d \
	$(IMPDIR)/core/sys/osx/mach/kern_return.d \
	$(IMPDIR)/core/sys/osx/mach/port.d \
	$(IMPDIR)/core/sys/osx/mach/semaphore.d \
	$(IMPDIR)/core/sys/osx/mach/thread_act.d \
	\
	$(IMPDIR)/core/sys/posix/arpa/inet.d \
	$(IMPDIR)/core/sys/posix/config.d \
	$(IMPDIR)/core/sys/posix/dirent.d \
	$(IMPDIR)/core/sys/posix/dlfcn.d \
	$(IMPDIR)/core/sys/posix/fcntl.d \
	$(IMPDIR)/core/sys/posix/grp.d \
	$(IMPDIR)/core/sys/posix/inttypes.d \
	$(IMPDIR)/core/sys/posix/netdb.d \
	$(IMPDIR)/core/sys/posix/poll.d \
	$(IMPDIR)/core/sys/posix/pthread.d \
	$(IMPDIR)/core/sys/posix/pwd.d \
	$(IMPDIR)/core/sys/posix/sched.d \
	$(IMPDIR)/core/sys/posix/semaphore.d \
	$(IMPDIR)/core/sys/posix/setjmp.d \
	$(IMPDIR)/core/sys/posix/signal.d \
	$(IMPDIR)/core/sys/posix/stdio.d \
	$(IMPDIR)/core/sys/posix/stdlib.d \
	$(IMPDIR)/core/sys/posix/termios.d \
	$(IMPDIR)/core/sys/posix/time.d \
	$(IMPDIR)/core/sys/posix/ucontext.d \
	$(IMPDIR)/core/sys/posix/unistd.d \
	$(IMPDIR)/core/sys/posix/utime.d \
	\
	$(IMPDIR)/core/sys/posix/net/if_.d \
	\
	$(IMPDIR)/core/sys/posix/netinet/in_.d \
	$(IMPDIR)/core/sys/posix/netinet/tcp.d \
	\
	$(IMPDIR)/core/sys/posix/sys/ioctl.d \
	$(IMPDIR)/core/sys/posix/sys/ipc.d \
	$(IMPDIR)/core/sys/posix/sys/mman.d \
	$(IMPDIR)/core/sys/posix/sys/select.d \
	$(IMPDIR)/core/sys/posix/sys/shm.d \
	$(IMPDIR)/core/sys/posix/sys/socket.d \
	$(IMPDIR)/core/sys/posix/sys/stat.d \
	$(IMPDIR)/core/sys/posix/sys/statvfs.d \
	$(IMPDIR)/core/sys/posix/sys/time.d \
	$(IMPDIR)/core/sys/posix/sys/types.d \
	$(IMPDIR)/core/sys/posix/sys/uio.d \
	$(IMPDIR)/core/sys/posix/sys/un.d \
	$(IMPDIR)/core/sys/posix/sys/wait.d \
	$(IMPDIR)/core/sys/posix/sys/utsname.d \
	\
	$(IMPDIR)/core/sys/windows/dbghelp.d \
	$(IMPDIR)/core/sys/windows/dll.d \
	$(IMPDIR)/core/sys/windows/stacktrace.d \
	$(IMPDIR)/core/sys/windows/threadaux.d \
	$(IMPDIR)/core/sys/windows/windows.d \
	\
	$(IMPDIR)/etc/linux/memoryerror.d

SRCS=$(addprefix src/,$(addsuffix .d,$(SRC_D_MODULES)))

######################## All of'em ##############################

target : import copy $(DRUNTIME) doc

######################## Doc .html file generation ##############################

doc: $(DOCS)

$(DOCDIR)/object.html : src/object_.d
	$(DMD) $(DDOCFLAGS) -Df$@ $(DOCFMT) $<

$(DOCDIR)/core_%.html : src/core/%.di
	$(DMD) $(DDOCFLAGS) -Df$@ $(DOCFMT) $<

$(DOCDIR)/core_%.html : src/core/%.d
	$(DMD) $(DDOCFLAGS) -Df$@ $(DOCFMT) $<

$(DOCDIR)/core_sync_%.html : src/core/sync/%.d
	$(DMD) $(DDOCFLAGS) -Df$@ $(DOCFMT) $<

######################## Header .di file generation ##############################

import: $(IMPORTS)

$(IMPDIR)/core/sync/%.di : src/core/sync/%.d
	@mkdir -p `dirname $@`
	$(DMD) -m$(MODEL) -c -o- -Isrc -Iimport -Hf$@ $<

######################## Header .di file copy ##############################

copy: $(COPY)

$(IMPDIR)/%.di : src/%.di
	@mkdir -p `dirname $@`
	cp $< $@

$(IMPDIR)/%.d : src/%.d
	@mkdir -p `dirname $@`
	cp $< $@

################### C/ASM Targets ############################

$(OBJDIR)/%.o : src/rt/%.c
	@mkdir -p `dirname $@`
	$(CC) -c $(CFLAGS) $< -o$@

$(OBJDIR)/errno_c.o : src/core/stdc/errno.c
	@mkdir -p `dirname $@`
	$(CC) -c $(CFLAGS) $< -o$@

$(OBJDIR)/threadasm.o : src/core/threadasm.S
	@mkdir -p $(OBJDIR)
	$(CC) $(ASMFLAGS) -c $(CFLAGS) $< -o$@

################### Library generation #########################

$(DRUNTIME): $(OBJS) $(SRCS)
	$(DMD) -lib -of$(DRUNTIME) -Xfdruntime.json $(DFLAGS) $(SRCS) $(OBJS)

unittest : $(addprefix $(OBJDIR)/,$(SRC_D_MODULES)) $(DRUNTIME) $(OBJDIR)/emptymain.d
	@echo done

ifeq ($(OS),freebsd)
DISABLED_TESTS =
else
DISABLED_TESTS =
endif

$(addprefix $(OBJDIR)/,$(DISABLED_TESTS)) :
	@echo $@ - disabled

$(OBJDIR)/% : src/%.d $(DRUNTIME) $(OBJDIR)/emptymain.d
	@echo Testing $@
	$(QUIET)$(DMD) $(UDFLAGS) -version=druntime_unittest -unittest -of$@ $(OBJDIR)/emptymain.d $< -L-Llib -debuglib=$(DRUNTIME_BASE) -defaultlib=$(DRUNTIME_BASE)
# make the file very old so it builds and runs again if it fails
	@touch -t 197001230123 $@
# run unittest in its own directory
	$(QUIET)$(RUN) $@
# succeeded, render the file new again
	@touch $@

$(OBJDIR)/emptymain.d :
	@mkdir -p $(OBJDIR)
	@echo 'void main(){}' >$@

detab:
	detab $(MANIFEST)
	tolf $(MANIFEST)

zip: druntime.zip

druntime.zip: $(MANIFEST) $(DOCS) $(IMPORTS)
	rm -rf $@
	zip $@ $^

install: druntime.zip
	unzip -o druntime.zip -d /dmd2/src/druntime

clean:
	rm -rf obj lib $(IMPDIR) $(DOCDIR) druntime.zip
