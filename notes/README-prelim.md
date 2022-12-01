

I've looked at the process for splitting out to a new repo and it seems straightforward but the set of git spells I use regularly is quite small and I'm not convinced I can be sure all necessary metadata is maintained. 

### Hyphen or Underscore

I can't find ANY reliable conventions. There are some tendencies within lang/sys/purpose communIties but nowhere are they rigorously kept to. I would like to have at least been able to find where hyphen or underscore is NOT permitted but accepting either is overwhelmingly common.

Rule of thumb for now:
- The Tree-sitter repo (and indeed, the project itself) is hyphenated, so hyphens for:
  - repo names
  
- within the repo lib/ and src/ directories
  - directories get skid
  - files get skid, with a few exceptions.
    - in `binding_web/`, files get dash, eg check-artifacts-fresh.js
    
    
  => skid for c source files and directories, including pkgconfig .in
  => dash for lib files and directories, including within pkgconfig and for group dirs, 
    eg tree-sitter, tree-sitter-lang
  => skid for include files and directories to mirror c source, including 
    shunt/group dirs, eg `tree_sitter_lang/tree_sitter_html.h`
    
Why version all the things? With the runtime, the api changes and obviously you need to match the lib with the right header. Langs repos may often get updated in ways that don't affect the use of the lib. But users of the lang lib don't need to know when versions do and don't matter, they can simply match the lib version with the repo version they're interested in. And of course, if lang lib version ever does matter, it's already handled.
    
I have left the pkgconfig entry ADDITIONALLIBS as is (I don't know which if any are fixed terms).
    
    
## General notes on improved resources for bindings-making

tree-sitter-cli should be in its own repo. Of course, it would take most of the test for the main tree-sitter with it, which will seem a little odd -- But it IS a little odd and 

'Tree-sitter is a parser generator tool and an incremental parsing library'

There needs to be a more clear division among the runtime, the rust and javascript bindings and the cli. These parts of the tree-sitter project should be moved out to their own repos:
  - tree-sitter-runtime
    - lib/include and lib/src
  - rust-tree-sitter
    - `lib/binding_rust` possibly bits from script/
  - javascript-tree-sitter
    - `lib/binding_web`, possibly bits from script/
  - I suspect highlight should also move out but I haven't been able to use it, myself
    
The cli, including all test support, would naturally need to refer to each of them. I can't tell whether there is any testing of the rust or javascript bindings themselves but the runtime is certainly only exercised by the cli through bindings. That's not great, frankly, but it definitely should be more obvious.

From Introduction, 'There are currently bindings that allow Tree-sitter to be used from the following languages' means specifically bindings to the runtime, does it not?

