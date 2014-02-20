# Makefile
#
# This is the main Makefile for aydede.
#
# The default target of this Makefile is the `ay` binary, which is a completely
# self-contained, portable binary composed of elements of the LuaJIT runtime,
# the LPeg parsing grammar library, and the Aydede implementation of Scheme.
#
# Copyright (c) 2014, Joshua Ballanco.
#
# Licensed under the BSD 2-Clause License. See COPYING for full license details.
#


LJDESTDIR = $(CURDIR)/build
LJPREFIX = $(LJDESTDIR)/usr/local
LJSTATIC = $(LJPREFIX)/lib/libluajit-5.1.a
LJBIN = $(LJPREFIX)/bin/luajit

ifeq ($(strip $(shell uname)), Darwin)
  CC = clang
  CFLAGS = -pagezero_size 10000 -image_base 100000000 -Ibuild/usr/local/include
  PLATFORM = macosx
else
  CFLAGS = -Ibuild/usr/local/include
  PLATFORM = linux
  LJ_OPTS = -lm -ldl -lc
endif

slashtodots = $(addprefix build/,\
	      $(addsuffix $1,\
	      $(subst /,.,$(patsubst src/%.lua,%,$2))))
rwildcard = $(wildcard $1$2) \
	    $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

MAIN = src/main.c
LUA_SRC = $(call rwildcard,src/,*.lua)
LUA_OBJS = $(call slashtodots,.o,$(LUA_SRC))
BUILD_OBJS = $(wildcard build/*.o)
TESTS = $(call rwildcard,test/,*.lua)
LPEG = build/lpeg.o
LJ_A = build/libluajit-5.1.a


bin/ay: $(MAIN) $(LPEG) $(LUA_OBJS) $(LJ_A) | bin
	$(CC) $(CFLAGS) $(LDFLAGS) $(MAIN) $(BUILD_OBJS) $(LJ_A) $(LJ_OPTS) -o $@

build/luadeps.mk: | build
	$(foreach f,$(LUA_SRC),\
	  $(shell echo \
	  "$(call slashtodots,.lua,$(f)): $(f)\n\tcp $$< \$$@" >> build/luadeps.mk))

include build/luadeps.mk

build/%.lua: build/luadeps.mk
	rm -f $(CURDIR)/build/luadeps.mk
	$(MAKE) build/luadeps.mk
	$(MAKE) $@

%.o: %.lua $(LJBIN) | build
	LUA_PATH=";;$(LJPREFIX)/share/luajit-2.0.2/?.lua" $(LJBIN) -b $< $@

$(LPEG): $(LJBIN) | build
	LUADIR=$(LJPREFIX)/include/luajit-2.0/ $(MAKE) -C vendor/LPeg $(PLATFORM)
	ld -r vendor/LPeg/*.o -o $(CURDIR)/build/lpeg.o
	mv vendor/LPeg/lpeg.so $(CURDIR)/build/
	cp vendor/LPeg/re.lua $(CURDIR)/build/

$(LJBIN): | build
	DESTDIR=$(CURDIR)/build $(MAKE) -C vendor/LuaJIT install

$(LJ_A): $(LJBIN) | build
	cp $(LJSTATIC) $@

build bin:
	mkdir -p $@

.PHONY: clean test

test: $(LJBIN) $(LPEG)
	@ $(foreach t,$(TESTS),\
	  LUA_PATH=";;./src/?.lua;./test/?.lua;./vendor/luaunit/?.lua;./vendor/LPeg/?.lua" \
	  LUA_CPATH=";;./build/?.so"\
	  $(LJBIN) $(t))

clean:
	$(MAKE) clean -C vendor/lpeg
	$(MAKE) clean -C vendor/LuaJIT
	rm -rf build bin

# vim:nolist:ts=4:tw=80
