### Notes about bindings-making

### versioning

discuss/issue: https://github.com/tree-sitter/tree-sitter/pull/1956

in the makefile, there is 
  `VERSION := 0.6.3`
which is ABI versioning (some kind of low-level, linking-related interface) and 
```
# ABI versioning
SONAME_MAJOR := 0
SONAME_MINOR := 0
```

IS SONAME ABI versioning? At any rate, I need the lib name to be distinct and related to the api.h version.

Could the Makefile draw this from some authoritative record?

Also, it would be nice to have a function api_h_version that could report the header version in code.

Also, how about the leading '0'? Is there some other SONAME_ thing? 
SONAME_MAJOR := 0.x works, tho

=> for now, I have to edit each Makefile before I build [221114m-0855]





0.19.5 - present
- parser.h are identical, except AFTER 0.20.0 added:
  const TSStateId *primary_state_ids;

0.19.5, 0.20.0
#define TREE_SITTER_LANGUAGE_VERSION 13
#define TREE_SITTER_MIN_COMPATIBLE_LANGUAGE_VERSION 13

0.20.6, 0.20.7
#define TREE_SITTER_LANGUAGE_VERSION 14
#define TREE_SITTER_MIN_COMPATIBLE_LANGUAGE_VERSION 13

make lang vers from 0.50 and take tree-sitter minor to start (then allow it to vary as necessary), eg 0.50.6, 0.50.7

compile lang to liblang
  langrepo/Makefile
  langrepo/src/*.c
  langrepo/bindings/*
=> libdir/tree-sitter-lang/libtree-sitter-json.0.50.6

/usr/local/lib
  tree-sitter/ <- SHUNTLIB, hyphenated like the libs themselves
    libtree-sitter.0.20.0.a <- versioned lib, hyphenated
    libtree-sitter.0.20.6.a
    libtree-sitter.a
  tree-sitter-lang/ <- group directory for all lang libs
    libtree-sitter-json.0.50.0.a
    libtree-sitter-json.0.50.6.a
    libtree-sitter-json.a
    libtree-sitter-ruby.0.52.3.a
    libtree-sitter-ruby.a
    
/usr/local/include
  tree_sitter.0.20.0/ <- versioned SHUNTINCLUDE, underscored like tree_sitter/
    tree_sitter/
      api.h
      parser.h
  tree_sitter.20.6/
    tree_sitter/
      api.h
      parser.h

- hyphen vs underscore???
- package relpaths???

I don't know how pkginclude works or whether it might benefit from shunting/versioning, so I've left that section as is.

I don't know whether a symlink to a non-versioned name is actually useful but if so, the makefile should create it from the latest version, not just the most recently built, but I don't know how to code that in make.

