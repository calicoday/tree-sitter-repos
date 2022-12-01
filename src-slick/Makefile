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

SHIM := lang
include ../../src/Make-shim-$(SHIM)
# include FULL_SHIM

PROJ_NAME := tree-sitter-$(LANG_NAME)
LIB_NAME := lib$(PROJ_NAME)
INCLUDE_NAME := $(subst -,_,$(PROJ_NAME))
# INCLUDE_NAME := tree_sitter_$(LANG_NAME)

RUNTIME_REPO_PATH := ../..
TMPLT_C_BINDS := $(RUNTIME_REPO_PATH)/src
SRC_C_BINDS := bindings/c

ifeq ($(wildcard $(SRC_C_BINDS)),)
# ifneq ($(wildcard bindings/c),)
	SRC_C_BINDS := $(SRC_DIR)
	# check whether there's anything in SRC_DIR that will get womped!!!
	
endif
# check whether the
# ifneq ($(wildcard ~/Dropbox/.*),)
#         @echo "Found ~/Dropbox."
# else
#         @echo "Did not find ~/Dropbox."
# endif


# pass version in env, eg `VERS_TAG='0.2.3' make ...`
ifndef VERS_TAG
VERS_TAG := $(shell git describe --tags )
GIT_VERS_TAG := $(VERS_TAG)
# assume the first \d+\.\d+\.\d+ is the vers tag we want
# sed is basic re, so \ parens and * not +
VERS_TAG := $(shell echo $(VERS_TAG) | \
	sed -e \
		"s/[^[:digit:]]*\([[:digit:]]*\)\.\([[:digit:]]*\)\.\([[:digit:]]*\).*/\1.\2.\3/")
endif

# collect C++ sources, and link if necessary
CPPSRC := $(wildcard $(SRC_DIR)/*.cc)

ifeq (, $(CPPSRC))
	ADD_LIBS := 
else
	ADD_LIBS := -lc++
endif

# collect sources
SRC := $(wildcard $(SRC_DIR)/*.c)
SRC += $(CPPSRC)
OBJ := $(addsuffix .o,$(basename $(SRC)))

CFLAGS ?= -O3 -Wall -Wextra -I$(SRC_DIR)
CXXFLAGS ?= -O3 -Wall -Wextra -I$(SRC_DIR)
override CFLAGS += -std=gnu99 -fPIC
override CXXFLAGS += -fPIC

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
  

VERS_WORDS := $(subst ., ,$(VERS_TAG))

VERS_MAJ := $(word 1, $(VERS_WORDS))
VERS_MIN := $(word 2, $(VERS_WORDS))
VERS_PATCH := $(word 3, $(VERS_WORDS))

VERS_MAJMIN := $(VERS_MAJ).$(VERS_MIN)
VERS_FULL := $(VERS_MAJ).$(VERS_MIN).$(VERS_PATCH)

C_BINDS := $(INCLUDE_NAME).h
C_BINDS_PKG := $(INCLUDE_NAME).$(VERS_FULL).pc
C_BINDS_PKG_SHORT := $(INCLUDE_NAME).pc

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
# all: libtree-sitter-$(LANG_NAME).a libtree-sitter-$(LANG_NAME).$(SOEXTVER) bindings/c/tree-sitter-$(LANG_NAME).pc

$(LIB_NAME).$(VERS_FULL).a: $(OBJ)
	@echo "@@@ SRC_C_BINDS: $(SRC_C_BINDS)//"
	$(AR) rcs $@ $^
	ln -sf $@ $(LIB_NAME).a

$(LIB_NAME).$(SOEXT_FULL): $(OBJ)
# 	@echo "VERS_TAG: $(VERS_TAG)//"
# 	@echo "VERS_MAJ: $(VERS_MAJ)//"
# 	@echo "VERS_MIN: $(VERS_MIN)//"
# 	@echo "VERS_PATCH: $(VERS_PATCH)//"
# 	@echo "VERS_FULL: $(VERS_FULL)//"
# 	@echo "LINKSHARED: $(LINKSHARED)//"
	$(CC) $(LDFLAGS) $(LINKSHARED) $^ $(LDLIBS) -o $@
	ln -sf $@ $(LIB_NAME).$(SOEXT)
	ln -sf $@ $(LIB_NAME).$(SOEXT_MAJ)
	ln -sf $@ $(LIB_NAME).$(SOEXT_MAJMIN)

# bindings/c/$(C_BINDS):
$(SRC_C_BINDS)/$(C_BINDS):
	sed -e 's|@UPPER_LANG_NAME@|$(UPPER_LANG_NAME)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		$(TMPLT_C_BINDS)/tree-sitter-lang.h.in > $@
# 		$(SRC_C_BINDS)/tree-sitter-lang.h.in > $@

# 		$(SRC_C_BINDS)/tree-sitter.h.in > $@
# when input goes underscore and lang-specific, ie tree_sitter_$(LANG_NAME).h.in:
# 		$(SRC_C_BINDS)/$(C_BINDS).in > $@

# bindings/c/$(C_BINDS_PKG):
$(SRC_C_BINDS)/$(C_BINDS_PKG):
	sed -e 's|@LIBDIR@|$(LIBDIR)|;s|@INCLUDEDIR@|$(INCLUDEDIR)|;s|@VERSION@|$(VERSION)|' \
		-e 's|=$(PREFIX)|=$${prefix}|' \
		-e 's|@PREFIX@|$(PREFIX)|' \
		-e 's|@ADD_LIBS@|$(ADD_LIBS)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		-e 's|@LANG_URL@|$(LANG_URL)|' \
		$(TMPLT_C_BINDS)/tree-sitter-lang.pc.in > $@
# 		$(SRC_C_BINDS)/tree-sitter-lang.pc.in > $@


# install: all
install: all $(SRC_C_BINDS)/$(C_BINDS) $(SRC_C_BINDS)/$(C_BINDS_PKG)
	install -d '$(DESTDIR)$(LIBDIR)'
	install -m755 $(LIB_NAME).$(VERS_FULL).a '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(VERS_FULL).a
	install -m755 $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_FULL)
# 	install -d '$(DESTDIR)$(INCLUDEDIR)'/tree_sitter
	install -d '$(DESTDIR)$(INCLUDEDIR)'
	install -m644 $(SRC_C_BINDS)/$(C_BINDS) '$(DESTDIR)$(INCLUDEDIR)'/$(C_BINDS)
	install -d '$(DESTDIR)$(PCLIBDIR)'
	install -m644 $(SRC_C_BINDS)/$(C_BINDS_PKG) '$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG)

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
