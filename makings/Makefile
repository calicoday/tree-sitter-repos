# This must be the first line Makefile, then other makings files are relative to this
# note: includes trailing /
MAKINGS_DIR := $(dir $(firstword $(MAKEFILE_LIST)))
# take off trailing / for consistency
MAKINGS_DIR := $(shell echo $(MAKINGS_DIR) | sed -e 's/\(.*\)./\1/')
### why can't I get $ to work in these seds???!!! interpolating???
# MAKINGS_DIR := $(shell echo $(MAKINGS_DIR) | sed -e 's/.$//')
$(info %%% MAKINGS_DIR: $(MAKINGS_DIR))

### TMP!!!
RUNTIME_VERS := 0.20.0

CFLAG_INCLUDES := -Ilib/src -Ilib/include

# shared makefile for runtime and langs, get this repo's name from git
GIT_REPO_URL := $(shell git -C .git remote get-url origin )
# can we ensure https, not this form git@github.com:/youruser/somename.git???

REPO_URL := $(subst .git,,$(GIT_REPO_URL)) 
# => eg https://github.com/tree-sitter/tree-sitter-bash

PROJ_NAME := $(shell basename $(REPO_URL))
# => eg tree-sitter-bash
$(info "%%% PROJ_NAME: $(PROJ_NAME)+++")

# if it's not 'tree-sitter' exactly, extract the lang name
ifneq (tree-sitter, $(PROJ_NAME))
	LANG_NAME := $(subst tree-sitter-,,$(PROJ_NAME))
	# => eg bash
	UPPER_LANG_NAME := $(shell echo $(LANG_NAME) | tr a-z A-Z )
endif

LIB_NAME := lib$(PROJ_NAME)
INCLUDE_NAME := $(subst -,_,$(PROJ_NAME))

# We can always get a result including short commit with `git describe --all --long`
# but `git describe --tags` will return empty string if no tags at all, ie untagged repo
TAGGED := $(shell git describe --tags)
# => some tag or empty string, if never tagged
LAST_TAG := $(shell git describe --all --long)
# => eg tags/v0.20.3-0-g0431a2c (tagged v0.20.3) or heads/main-0-ga4b9187 (never tagged)
COMMIT := $(shell echo $(LAST_TAG) | sed -e 's/.*\(.......\)/\1/')

ifeq (, $(TAGGED))
	VERS_FULL := untagged
else
	VERS_TAG := $(shell echo $(TAGGED) | sed -e \
		's/[^[:digit:]]*\([[:digit:]]*\)\.\([[:digit:]]*\)\.\([[:digit:]]*\).*/\1.\2.\3/')
	VERS_WORDS := $(subst ., ,$(VERS_TAG))

	VERS_MAJ := $(word 1, $(VERS_WORDS))
	VERS_MIN := $(word 2, $(VERS_WORDS))
	VERS_PATCH := $(word 3, $(VERS_WORDS))

	VERS_MAJMIN := $(VERS_MAJ).$(VERS_MIN)
	VERS_FULL := $(VERS_MAJ).$(VERS_MIN).$(VERS_PATCH)
endif

# collect sources
SRC_DIR := lib/src
CFLAG_INCLUDES := -Ilib/src -Ilib/include

# must have trailing slash if not empty
# some langs HAVE a build/ dir of source material, so for now...
BUILD_DIR := made/

ifneq (, $(LANG_NAME))
	include $(MAKINGS_DIR)/Make-shim-lang
else
	include $(MAKINGS_DIR)/Make-shim-runtime
endif

OBJ := $(addsuffix .o,$(basename $(SRC)))

# choking on unused parameters, allow it for now
# CFLAGS ?= -O3 -Wall -Wextra -Werror
CFLAGS ?= -O3 -Wall -Wextra 
override CFLAGS += -std=gnu99 -fPIC $(CFLAG_INCLUDES)
# by this point we have set SRC,OBJ,CFLAGS,CXXFLAGS


ifeq (, $(LANG_NAME))
	# must have trailing slash if not empty
	INCLUDE_SUBDIR := tree_sitter/
endif

SHUNTLIB ?= /$(PROJ_NAME)
SHUNTINCLUDE ?= /$(INCLUDE_NAME).$(VERS_FULL)

# install directory layout
PREFIX ?= /usr/local
INCLUDEDIR ?= $(PREFIX)/include$(SHUNTINCLUDE)
LIBDIR ?= $(PREFIX)/lib$(SHUNTLIB)
PCLIBDIR ?= $(LIBDIR)/pkgconfig

# OS-specific fragments
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
else
	SOEXT = so
	SOEXT_FULL = so.$(VERS_FULL)
	SOEXT_MAJMIN = so.$(VERS_MAJMIN)
	SOEXT_MAJ = so.$(VERS_MAJ)
	LINKSHARED := $(LINKSHARED)-shared -Wl,
	ifneq (, $(ADD_LIBS))
		LINKSHARED := $(LINKSHARED)$(ADD_LIBS),
	endif
	LINKSHARED := $(LINKSHARED)-soname,$(LIBDIR)/$(LIB_NAME).so.$(VERS_FULL)
# nicer form but I'm not confident of the =/+=/:= differences
# 	SOEXT = so
# 	SOEXT_FULL = so.$(VERS_FULL)
# 	SOEXT_MAJMIN = so.$(VERS_MAJMIN)
# 	SOEXT_MAJ = so.$(VERS_MAJ)
# 	LINKSHARED = -shared -Wl,
# 	ifneq (, $(ADD_LIBS))
# 		LINKSHARED += $(ADD_LIBS),
# 	endif
# 	LINKSHARED += -soname,$(LIBDIR)/$(LIB_NAME).so.$(VERS_FULL)
endif
ifneq (,$(filter $(shell uname),FreeBSD NetBSD DragonFly))
	PCLIBDIR := $(PREFIX)/libdata/pkgconfig
endif

# to be filled in after build generates the lang header
	HEADERS := 
	HFILES := 


all: build_dir \
	$(BUILD_DIR)$(LIB_NAME).$(VERS_FULL).a \
	$(BUILD_DIR)$(LIB_NAME).$(SOEXT_FULL) \
	$(SRC_C_BINDS)$(C_BINDS)
	# set up the headers list in case install
	$(eval HEADERS := $(wildcard $(SRC_C_BINDS)$(INCLUDE_SUBDIR)*.h))
	$(eval HFILES := $(notdir $(HEADERS)))

build_dir:
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)$(LIB_NAME).$(VERS_FULL).a: $(OBJ)
	$(AR) rcs $@ $^
	ln -sf $@ $(BUILD_DIR)$(LIB_NAME).a

$(BUILD_DIR)$(LIB_NAME).$(SOEXT_FULL): $(OBJ)
	$(CC) $(LDFLAGS) $(LINKSHARED) $^ $(LDLIBS) -o $@
	ln -sf $@ $(BUILD_DIR)$(LIB_NAME).$(SOEXT)
ifneq (untagged, $(VERS_FULL))
		# extra symlinks for lib that is not untagged
		ln -sf $@ $(BUILD_DIR)$(LIB_NAME).$(SOEXT_MAJ)
		ln -sf $@ $(BUILD_DIR)$(LIB_NAME).$(SOEXT_MAJMIN)
endif

$(SRC_C_BINDS)$(C_BINDS):
	# shdnt run if .h exists, eg tree-sitter/lib/include/*.h
	sed -e 's|@UPPER_LANG_NAME@|$(UPPER_LANG_NAME)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		$(TMPLT_C_BINDS) > $@

'$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(VERS_FULL).a:
	install -d '$(DESTDIR)$(LIBDIR)'
	install -m755 $(BUILD_DIR)$(LIB_NAME).$(VERS_FULL).a $@

'$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_FULL):
	install -d '$(DESTDIR)$(LIBDIR)'
	install -m755 $(BUILD_DIR)$(LIB_NAME).$(SOEXT_FULL) $@

'$(DESTDIR)$(INCLUDEDIR)'/$(INCLUDE_SUBDIR)$(HFILES):
	install -d '$(DESTDIR)$(INCLUDEDIR)'/$(INCLUDE_SUBDIR)
	install -m644 $(HEADERS) '$(DESTDIR)$(INCLUDEDIR)'/$(INCLUDE_SUBDIR)

'$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG):
	install -d '$(DESTDIR)$(PCLIBDIR)'
	sed -e 's|@LIBDIR@|$(LIBDIR)|;s|@INCLUDEDIR@|$(INCLUDEDIR)|;s|@VERSION@|$(VERSION)|' \
		-e 's|=$(PREFIX)|=$${prefix}|' \
		-e 's|@PREFIX@|$(PREFIX)|' \
		-e 's|@ADD_LIBS@|$(ADD_LIBS)|' \
		-e 's|@LANG_NAME@|$(LANG_NAME)|' \
		-e 's|@LANG_URL@|$(LANG_URL)|' \
		$(TMPLT_C_BINDS_PKG) > $@


install: all \
	'$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(VERS_FULL).a \
	'$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_FULL) \
	'$(DESTDIR)$(INCLUDEDIR)'/$(INCLUDE_SUBDIR)$(HFILES) \
	'$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG) 

# SRC_C_BINDS := lib/include
# C_BINDS := 
# lib/
#   include/
#     api.h
#     parser.h
# made/
#   [tree_sitter.pc]
#   tree_sitter_bash.h
#   
# local/include/
#   tree_sitter_bash.0.1.2/
#     tree_sitter_base.h
#   tree_sitter.0.3.4/
#     tree_sitter/
#       api.h
#       parser.h


install-and-symlink: install
	install -d '$(DESTDIR)$(LIBDIR)'
	ln -sf $(LIB_NAME).$(VERS_FULL).a '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).a
ifneq (untagged, $(VERS_FULL))
		# extra symlinks for lib that is not untagged
		ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_MAJMIN)
		ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT_MAJ)
endif
	ln -sf $(LIB_NAME).$(SOEXT_FULL) '$(DESTDIR)$(LIBDIR)'/$(LIB_NAME).$(SOEXT)
	install -d '$(DESTDIR)$(PCLIBDIR)'
	ln -sf $(SRC_C_BINDS)$(C_BINDS_PKG) '$(DESTDIR)$(PCLIBDIR)'/$(C_BINDS_PKG_SHORT)

clean:
	rm -f lib/src/*.o $(LIB_NAME).a $(LIB_NAME).$(VERS_FULL).a \
	  $(LIB_NAME).$(SOEXT) $(LIB_NAME).$(SOEXT_MAJMIN) $(LIB_NAME).$(SOEXT_FULL)
	rm -f bindings/c/$(LANG_NAME).h bindings/c/tree-sitter-$(LANG_NAME).pc

.PHONY: all build_dir install install-and-symlink clean
