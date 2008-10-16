# Makefile to build the D runtime library core components for Posix
# Designed to work with GNU make
# Targets:
#	make
#		Same as make all
#	make lib
#		Build the common library
#   make doc
#       Generate documentation
#	make clean
#		Delete unneeded files created by build process

LIB_TARGET=libdruntime-core.a
LIB_MASK=libdruntime-core*.a

CP=cp -f
RM=rm -f
MD=mkdir -p

ADD_CFLAGS=
ADD_DFLAGS=

CFLAGS=-O $(ADD_CFLAGS)
#CFLAGS=-g $(ADD_CFLAGS)

DFLAGS=-release -O -inline -w -nofloat -version=Posix $(ADD_DFLAGS)
#DFLAGS=-g -w -nofloat -version=Posix $(ADD_DFLAGS)

TFLAGS=-O -inline -w -nofloat -version=Posix $(ADD_DFLAGS)
#TFLAGS=-g -w -nofloat -version=Posix $(ADD_DFLAGS)

DOCFLAGS=-version=DDoc -version=Posix

CC=gcc
LC=$(AR) -qsv
DC=dmd

INC_DEST=../../import
LIB_DEST=../../lib
DOC_DEST=../../doc

.SUFFIXES: .s .S .c .cpp .d .html .o

.s.o:
	$(CC) -c $(CFLAGS) $< -o$@

.S.o:
	$(CC) -c $(CFLAGS) $< -o$@

.c.o:
	$(CC) -c $(CFLAGS) $< -o$@

.cpp.o:
	g++ -c $(CFLAGS) $< -o$@

.d.o:
	$(DC) -c $(DFLAGS) -Hf$*.di $< -of$@
#	$(DC) -c $(DFLAGS) $< -of$@

.d.html:
	$(DC) -c -o- $(DOCFLAGS) -Df$*.html $<

targets : lib doc
all     : lib doc
core    : lib
lib     : core.lib
doc     : core.doc

######################################################

OBJ_CORE= \
    core/bitmanip.o \
    core/exception.o \
    core/memory.o \
    core/runtime.o \
    core/thread.o

OBJ_STDC= \
    stdc/errno.o

ALL_OBJS= \
    $(OBJ_CORE) \
    $(OBJ_STDC)

######################################################

DOC_CORE= \
    core/bitmanip.html \
    core/exception.html \
    core/memory.html \
    core/runtime.html \
    core/thread.html


ALL_DOCS=

######################################################

core.lib : $(LIB_TARGET)

$(LIB_TARGET) : $(ALL_OBJS)
	$(RM) $@
	$(LC) $@ $(ALL_OBJS)

core.doc : $(ALL_DOCS)
	echo Documentation generated.

######################################################

### bitmanip

core/bitmanip.o : core/bitmanip.d
	$(DC) -c $(DFLAGS) bitmanip.d -of$@

### thread

core/thread.o : core/thread.d
	$(DC) -c $(DFLAGS) -d -Hf$*.di thread.d -of$@

######################################################

clean :
	find . -name "*.di" | xargs $(RM)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_DOCS)
	find . -name "$(LIB_MASK)" | xargs $(RM)

install :
	$(MD) $(INC_DEST)
	find . -name "*.di" -exec cp -f {} $(INC_DEST)/{} \;
	$(MD) $(DOC_DEST)
	find . -name "*.html" -exec cp -f {} $(DOC_DEST)/{} \;
	$(MD) $(LIB_DEST)
	find . -name "$(LIB_MASK)" -exec cp -f {} $(LIB_DEST)/{} \;