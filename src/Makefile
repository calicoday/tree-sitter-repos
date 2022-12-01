# better lang repo structure would be:
# proj/
#   lib/
#     include/
#       tree-sitter-#{lang}.h
#       tree-sitter-#{lang}.pc
#       [tree-sitter-lang.h.in] <- actu -lang, copied or refd from runtime repo
#       [tree-sitter-lang.pc.in] <- actu
#     src/
#       grammar.json
#       parser.h
#       scanner.cc
#   [Makefile] <- or refd from runtime

# This must be the first line Makefile -- note: includes trailing /
MAKINGS_DIR := $(dir $(firstword $(MAKEFILE_LIST)))
# take off training / for consistency
MAKINGS_DIR := $(shell echo $(MAKINGS_DIR) | sed -e 's/\(.*\)./\1/')
### why can't I get $ to work in these seds???!!! make is interpolating???
# MAKINGS_DIR := $(shell echo $(MAKINGS_DIR) | sed -e 's/.$//')
$(info %%% MAKINGS_DIR: $(MAKINGS_DIR))

### TMP!!!
RUNTIME_VERS := 0.20.0

CFLAG_INCLUDES := -Ilib/src -Ilib/include

# shared makefile for runtime and langs, get this repo's name from git
GIT_REPO_URL := $(shell git -C .git remote get-url origin )
# can we ensure https, not this form git@github.com:/youruser/somename.git?

REPO_URL := $(subst .git,,$(GIT_REPO_URL)) 
# => https://github.com/alemuller/tree-sitter-make

PROJ_NAME := $(shell basename $(REPO_URL))
# => tree-sitter-make
$(info "%%% PROJ_NAME: $(PROJ_NAME)+++")

# if it's not exactly 'tree-sitter', extract the lang name
ifneq (tree-sitter, $(PROJ_NAME))
	LANG_NAME := $(subst tree-sitter-,,$(PROJ_NAME))
	# => make
	UPPER_LANG_NAME := $(shell echo $(LANG_NAME) | tr a-z A-Z )
endif

LIB_NAME := lib$(PROJ_NAME)
INCLUDE_NAME := $(subst -,_,$(PROJ_NAME))

# This makefile is intended to be run from a repo dir, so get vers from git...

# We can always get a result including short commit with `git describe --all --long`
# but `git describe --tags` will return empty string if no tags at all, ie untagged repo
TAGGED := $(shell git describe --tags)
# BLAH := $(shell echo "@@@ TAGGED: $(TAGGED)+++") ### NOPE
# => some tag or empty string, if never tagged
LAST_TAG := $(shell git describe --all --long)
# => tags/v0.20.3-0-g0431a2c (tagged v0.20.3) or heads/main-0-ga4b9187 (never tagged)
COMMIT := $(shell echo $(LAST_TAG) | sed -e 's/.*\(.......\)/\1/')

ifeq (, $(TAGGED))
	VERS_TAG := untagged
else
	VERS_TAG := $(shell echo $(TAGGED) | sed -e \
		's/[^[:digit:]]*\([[:digit:]]*\)\.\([[:digit:]]*\)\.\([[:digit:]]*\).*/\1.\2.\3/')
endif

VERS_WORDS := $(subst ., ,$(VERS_TAG))

VERS_MAJ := $(word 1, $(VERS_WORDS))
VERS_MIN := $(word 2, $(VERS_WORDS))
VERS_PATCH := $(word 3, $(VERS_WORDS))

VERS_MAJMIN := $(VERS_MAJ).$(VERS_MIN)
VERS_FULL := $(VERS_MAJ).$(VERS_MIN).$(VERS_PATCH)

# collect sources
SRC_DIR := lib/src
CFLAG_INCLUDES := -Ilib/src -Ilib/include

ifneq (, $(LANG_NAME))
	### TMP!!! currently, langs have src/ not lib/src/, lib/include/
	SRC_DIR := src
	CFLAG_INCLUDES := -Isrc
	# except the ones that don't: sexp, typescript; wasm has 2, wast/src/ and wat/src/
	
	# add the tree-sitter runtime, for parser.h
	### TMP!!! will version_roster but for now, if we haven't been passed RUNTIME_VERS, set
	RUNTIME_VERS ?= 0.20.6
	CFLAG_INCLUDES += -Itree_sitter.$(RUNTIME_VERS)
	
	# collect C++ sources, and link if necessary
	CPPSRC := $(wildcard $(SRC_DIR)/*.cc)
	CXXFLAGS ?= -O3 -Wall -Wextra 
	override CXXFLAGS += -fPIC  $(CFLAG_INCLUDES)
	
	ifeq (, $(CPPSRC))
		ADD_LIBS := 
	else
		ADD_LIBS := -lc++
	endif
	# add tree-sitter includes for parser.h???
	
	# collect sources
	SRC := $(wildcard $(SRC_DIR)/*.c)
	SRC += $(CPPSRC)
# 	OBJ := $(addsuffix .o,$(basename $(SRC)))

	# external headers and pkgconfig
	TMPLT_C_BINDS_PKG := tree-sitter-lang.pc.in
	TMPLT_C_BINDS := $(MAKINGS_DIR)/tree-sitter-lang.h.in
# 	TMPLT_C_BINDS := ../../tree-sitter-lang.h.in
	# TMPLT_C_BINDS := ../../Makings/tree-sitter-lang.h.in
	SRC_C_BINDS := bindings/c
	C_BINDS := $(INCLUDE_NAME).h
	
	C_BINDS_PKG := $(INCLUDE_NAME).$(VERS_FULL).pc
	C_BINDS_PKG_SHORT := $(INCLUDE_NAME).pc

else
	# collect sources
	ifneq ($(AMALGAMATED),1)
		SRC := $(wildcard $(SRC_DIR)/*.c)
		# do not double-include amalgamation
		SRC := $(filter-out $(SRC_DIR)/lib.c,$(SRC))
	else
		# use amalgamated build
		SRC := $(SRC_DIR)/lib.c
	endif
# 	OBJ := $(SRC:.c=.o)

	# external headers and pkgconfig
	# runtime .in in proj dir
	TMPLT_C_BINDS_PKG := $(PROJ_NAME).pc.in
	TMPLT_C_BINDS :=
	SRC_C_BINDS := lib/include
	C_BINDS := tree_sitter/*.h
# 	SRC_C_BINDS := lib/include/tree_sitter
# 	C_BINDS := *.h
	
	C_BINDS_PKG := $(INCLUDE_NAME).$(VERS_FULL).pc
	C_BINDS_PKG_SHORT := $(INCLUDE_NAME).pc
endif

OBJ := $(addsuffix .o,$(basename $(SRC)))

# choking on unused parameters, allow it for now
# CFLAGS ?= -O3 -Wall -Wextra -Werror
CFLAGS ?= -O3 -Wall -Wextra 
override CFLAGS += -std=gnu99 -fPIC $(CFLAG_INCLUDES)
# by this point we have set SRC,OBJ,CFLAGS,CXXFLAGS


ifeq (, $(LANG_NAME))
	INCLUDE_SHIM := /tree_sitter
endif


# I very much prefer compiling to a build/ (or other) subdir but, frankly,
# I'm tired and I don't want to have to test this whole thing again just now.

# Tidbits:
# - a symlink named with the short version, major.minor instead of major.minor.patch, 
#   seems a common choice but is it actually useful for this proj?
# - the symlinks ought always be to the latest version available, not just
#   the most recently built, but I don't know how to code that in make, so
#   I've made a separate target `install-and-symlink` for when you know you're
#   installing the best ever version (and I think I like that better anyway,
#   since it should happen rarely and intentionally)
# - move tree-sitter to 1.0.0
# - change tree-sitter tagging to just maj.min.patch, no 'v'


# The versioned SHUNTINCLUDE needs to be added to the linking include path, 
# then #include statements same, simple, relative paths as before. 

# Everything after this point is specific to the fixed install directory structure but
# not otherwise project-specific. Example target results for:
#
#   PROJ_NAME := one-example # <- hyphenated like tree-sitter
#   LIB_NAME := lib$(PROJ_NAME)
#   INCLUDE_NAME := one_example <- underscored like lib/tree_sitter/ 
#
#  called with:
# 
#   `VERS_TAG='0.2.3' make ...`
# 
# all: <- build only
#   proj_dir/ <- or proj_dir/build_dir/???
#     libone-example.0.2.3.dylib or libone-example.so.0.2.3
#     libone-example.0.2.3.a 
#     libone-example.0.2.dylib or libone-example.so.0.2 (symlink to 0.2.3)
#     libone-example.dylib or libone-example.so (symlink to 0.2.3)
#     libone-example.a (symlink to 0.2.3)
#   
# install: <- all, plus:
#   /usr/local/lib/
#     one-example/ <- shared by all lib versions
#       libone-example.0.2.3.dylib or libone-example.so.0.2.3
#       libone-example.0.2.3.a 
#       pkgconfig/ <- shared by all lib versions
#         one_example.0.2.3.pc <- (shd symlink to best version???)
#
#   /usr/local/include/
#     one_example.0.2.3/ <- versioned SHUNTINCLUDE
#       one_example/ <- eg #include <one_example/one_header.h>
#         one_header.h
#         another_header.h
# 
# install-and-symlink: <- install, plus:
#   /usr/local/lib/
#     one-example.0.2.3/
#       libone-example.0.2.dylib or libone-example.so.0.2 (symlink to 0.2.3)
#       libone-example.dylib or libone-example.so (symlink to 0.2.3)
#       libone-example.a (symlink to 0.2.3)
#       pkgconfig/
#         one_example.pc <- (symlink to 0.2.3) ???
  


SHUNTLIB ?= /$(PROJ_NAME)
SHUNTINCLUDE ?= /$(INCLUDE_NAME).$(VERS_FULL)

# install directory layout
PREFIX ?= /usr/local
INCLUDEDIR ?= $(PREFIX)/include$(SHUNTINCLUDE)
LIBDIR ?= $(PREFIX)/lib$(SHUNTLIB)
PCLIBDIR ?= $(LIBDIR)/pkgconfig

# OS-specific bits
ifeq ($(shell uname),Darwin)
	SOEXT = dylib
	SOEXT_FULL = $(VERS_FULL).dylib
	SOEXT_MAJMIN = $(VERS_MAJMIN).dylib
	SOEXT_MAJ = $(VERS_MAJ).dylib
	LINKSHARED := $(LINKSHARED)-dynamiclib -Wl,
	ifneq (, $(ADD_LIBS))
	LINKSHARED := $(LINKSHARED)$(ADD_LIBS),
	endif
	LINKSHARED := $(LINKSHARED)-install_name,$(LIBDIR)/$(LIB_NAME).$(VERS_FULL).dylib,-rpath,@executable_path/../Frameworks
# 	LINKSHARED := -dynamiclib -Wl,
# 	ifneq (, $(ADD_LIBS))
# 	LINKSHARED += $(ADD_LIBS),
# 	endif
# 	LINKSHARED := $(LINKSHARED)-install_name,$(LIBDIR)/$(LIB_NAME).$(VERS_FULL).dylib,-rpath,@executable_path/../Frameworks
# # 	LINKSHARED += -install_name,$(LIBDIR)/$(LIB_NAME).$(VERS_FULL).dylib,-rpath,@executable_path/../Frameworks
else
	SOEXT = so
	SOEXT_FULL = so.$(VERS_FULL)
	SOEXT_MAJMIN = so.$(VERS_MAJMIN)
	SOEXT_MAJ = so.$(VERS_MAJ)
	LINKSHARED = -shared -Wl,
	ifneq (, $(ADD_LIBS))
	LINKSHARED += $(ADD_LIBS),
	endif
	LINKSHARED += -soname,$(LIBDIR)/$(LIB_NAME).so.$(VERS_FULL)
endif
ifneq (,$(filter $(shell uname),FreeBSD NetBSD DragonFly))
	PCLIBDIR := $(PREFIX)/libdata/pkgconfig
endif

all: $(LIB_NAME).$(VERS_FULL).a $(LIB_NAME).$(SOEXT_FULL)

$(LIB_NAME).$(VERS_FULL).a: $(OBJ)
# 	@echo "@@@ OBJ: $(OBJ)+++"
	$(AR) rcs $@ $^
	ln -sf $@ $(LIB_NAME).a

$(LIB_NAME).$(SOEXT_FULL): $(OBJ)
	$(CC) $(LDFLAGS) $(LINKSHARED) $^ $(LDLIBS) -o $@
	ln -sf $@ $(LIB_NAME).$(SOEXT)
	ln -sf $@ $(LIB_NAME).$(SOEXT_MAJ)
	ln -sf $@ $(LIB_NAME).$(SOEXT_MAJMIN)

# bindings/c/$(C_BINDS):
$(SRC_C_BINDS)/$(C_BINDS):
	# shdnt run if .h exists, eg tree-sitter/lib/include/*.h
	@echo "@@@ build c_binds: $(SRC_C_BINDS)/  $(C_BINDS)+++"
	sed -e 's|@UPPER_LANG_NAME@|$(UPPER_LANG_NAME)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		$(TMPLT_C_BINDS) > $@


install: all $(SRC_C_BINDS)/$(C_BINDS)
	install -d '$(DESTDIR)$(LIBDIR)'
	install -m755 $(LIB_NAME).$(VERS_FULL).a '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(VERS_FULL).a
	install -m755 $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_FULL)
	# if it's the runtime, add the tree_sitter/ shim
# 	install -d '$(DESTDIR)$(INCLUDEDIR)'
# 	install -m644 $(SRC_C_BINDS)/$(C_BINDS) '$(DESTDIR)$(INCLUDEDIR)'
	@echo "@@@ INCLUDE_SHIM: $(INCLUDE_SHIM)+++"
	install -d '$(DESTDIR)$(INCLUDEDIR)'$(INCLUDE_SHIM)
	install -m644 $(SRC_C_BINDS)/$(C_BINDS) '$(DESTDIR)$(INCLUDEDIR)'$(INCLUDE_SHIM)
	install -d '$(DESTDIR)$(PCLIBDIR)'
	# not dep, do pkgconfig directly
	sed -e 's|@LIBDIR@|$(LIBDIR)|;s|@INCLUDEDIR@|$(INCLUDEDIR)|;s|@VERSION@|$(VERSION)|' \
		-e 's|=$(PREFIX)|=$${prefix}|' \
		-e 's|@PREFIX@|$(PREFIX)|' \
		-e 's|@ADD_LIBS@|$(ADD_LIBS)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		-e 's|@LANG_URL@|$(LANG_URL)|' \
		$(TMPLT_C_BINDS_PKG) > '$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG)

install-and-symlink: install
	@echo "$$$ install-and-symlink"
	install -d '$(DESTDIR)$(LIBDIR)'
	ln -sf $(LIB_NAME).$(VERS_FULL).a '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).a
	ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_MAJMIN)
	ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_MAJ)
	ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT)
	install -d '$(DESTDIR)$(PCLIBDIR)'
	ln -sf $(SRC_C_BINDS)/$(C_BINDS_PKG) '$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG_SHORT)

clean:
	rm -f lib/src/*.o $(LIB_NAME).a $(LIB_NAME).$(VERS_FULL).a \
	  $(LIB_NAME).$(SOEXT) $(LIB_NAME).$(SOEXT_MAJMIN) $(LIB_NAME).$(SOEXT_FULL)
	rm -f bindings/c/$(LANG_NAME).h bindings/c/tree-sitter-$(LANG_NAME).pc

.PHONY: all install install-and-symlink clean
