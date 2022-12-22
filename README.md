# tree-sitter-repos

RepoRunner is a utility for cloning and building versioned shared/dynamic libraries of the [Tree-sitter](https://github.com/tree-sitter/tree-sitter) runtime and language parsers. 

As the Tree-sitter project is under active development, the external interface to its runtime changes. Any project using the runtime compiled as a shared/dynamic library needs to be able to distiguish different versions of the library and the corresponding header files. The same goes for compiled language parsers. RepoRunner manages cloning and building the libraries, giving versioned names to all resulting files and directories. Versions are taken from a repo's git tags (or 'untagged', if it has no tags yet) and appended to project name.

The RepoRunner project is at an early stage. The Tree-sitter repos are currently quite inconsistent in tagging and in project directory structures (see [Project Notes](#project-notes)). Obviously, more normalized repo practices would make things easier but RepoRunner does what it can with the repos as they are (accommodating ever more varied, as I get to it). See [To Do](#to-do) for a current list of runtime and lang versions known to work.

The RepoRunner `list_lang_repos` command will create json file, `lang_repos.json`, containing a list of known language parser repos by web scraping the Tree-sitter [Introduction: Available Parsers](https://tree-sitter.github.io/tree-sitter/#available-parsers) and calling `git -c` or `git ls-remote` to get the most recent version tag for each. This file (or another with portions copied from it) can then be passed to the `clone` command with the --json option and exactly what subset of the listed languages to process with the --lang-list option (eg --json='lang_repos.json' --lang-list='bash, rust, make'). The file `src/ref_lang_repos.json` is the `lang_repos.json` created the last time I called `list_lang_repos`.

The RepoRunner `clone` command creates and updates a file `repos/cloned_repos.json` with brief info about each repo cloned. Any tagged version of a repo will be cloned detached HEAD. Any untagged repo will simply clone the full, latest commit -- two different, untagged commits are not distinguished. The file `src/ref_cloned_repos.json` is the `cloned_repos.json` created the last time I cloned all core languages, for reference.

The RepoRunner `make` command uses a single Makefile, based on material in the Makefiles of the main tree-sitter repo and a couple of language parser repos. The Makefile cherry-picks the necessary source files from the listed runtime or language repos and builds libraries into a new `made/` directory (some language repos currently have a directory named `build/` containing source material).

For example, for version 0.1.2 of the `tree-sitter` runtime and version 3.4.5 of `tree-sitter-bash`, RepoRunner `clone` and `make` commands will result in:
```
tree-sitter-repos/
  repos/
    cloned_repos.json
    tree-sitter.0.1.2/
      tree-sitter/
        made/
          libtree-sitter.0.1.2.a
          libtree-sitter.0.1.2.dylib [or libtree-sitter.so.0.1.2]
          libtree-sitter.0.1.dylib [symlink to full .dylib or .so]
          libtree-sitter.0.dylib [symlink to full .dylib or .so]
          libtree-sitter.a [symlink to full .a]
          libtree-sitter.dylib [symlink to full .dylib or .so]
    tree-sitter-bash.3.4.5/
      tree-sitter-bash/
        made/
          libtree-sitter-bash.3.4.5.a
          libtree-sitter-bash.3.4.5.dylib [or libtree-sitter-bash.so.3.4.5]
          libtree-sitter.3.4.dylib [symlink to full .dylib or .so]
          libtree-sitter.3.dylib [symlink to full .dylib or .so]
          libtree-sitter.a [symlink to full .a]
          libtree-sitter.dylib [symlink to full .dylib or .so]
```
and will install (in the conventional system location for the platform, eg /usr/local for Mac):
```
/
  usr/
    local/
      include/
        tree_sitter.0.1.2/
          tree_sitter/
            api.h
            parser.h
        tree_sitter_bash.3.4.5/
          tree_sitter_bash.h
      lib/
        tree-sitter/
          libtree-sitter.0.1.2.a
          libtree-sitter.0.1.2.dylib [or libtree-sitter.so.0.1.2]
          pkgconfig/
            tree_sitter.0.1.2.pc
        tree-sitter-bash/
          libtree-sitter-bash.3.4.5.a
          libtree-sitter-bash.3.4.5.dylib [or libtree-sitter.so.3.4.5]
          pkgconfig/
            tree_sitter-bash.3.4.5.pc
```

## Usage

Clone this repo, then run from the repo directory:
```
ruby src/repo_runner.rb --help
```

which gives:
```
Runner of tree-sitter-repo scripts

Usage:
  repo_runner.rb [options] <command>

Options:
  -v, --version          
  -h, --help             
  -t, --tag-list=<s>     Tags (eg '0.20.7') of runtime versions to process,
                         comma-separated (default: )
  -j, --json=<s>         (clone) JSON lang info file with a list of repos and
                         versions, keyed by short name. See notes (default: )
  -l, --lang-list=<s>    Short names (eg 'bash' for 'tree-sitter-bash') of lang
                         repos to process, comma-separated. For clone, requires
                         --json. See notes
  -r, --repo-dirs=<s>    Versioned repo dirs, separated by comma (eg
                         'tree-sitter-bash.0.19.0') (default: )
  -c, --core-langs       Use the core lang list. For clone, requires --json.
                         See notes
  -w, --workdir=<s>      Working directory for cloned/built repos (default:
                         repos/)
  additional options for make:
  -d, --debug            Pass --debug option to make for verbose output
  -n, --noop             Pass --noop option to make for dry run
  -i, --install          Install lib in the conventional sys dir
  -a, --alias            Create a symlink to the installed lib with the simple,
                         non-versioned name (use rarely and deliberately)

Commands:
  list_lang_repos      Create 'src/lang_repos.json', listing each of the
                       language repos listed in the tree-sitter.github.io
                       section Introduction: Available Parsers
  clone                Git clone repos from github
  make                 Make cloned repos
  dev                  No-op for repo_runner.rb options testing

Notes:
  - The core langs are all langs mentioned in the main tree-sitter repo 
    itself (in tests, documentation or examples), currently: bash, c, 
    c_sharp, cpp, javascript, json, make, markdown, python, ruby, rust, 
    sexp, typescript, wasm, embedded_template, html.
  - Use the --lang_list option to specify by short name a subset of langs 
    in a supplied --json lang info file.
  - The --json lang info file must have the structure from the top:
      {
        'lang': {
          'url': 'https://github.com/org-name/tree-sitter-lang',
          'vers': '3.4.5'
        }
       }
    Other data intermingled will be ignored. The json file produced by 
    the list_lang_repos is suitable.
  - the --repo_dirs option takes a list of specific versioned repos in 
    the form repo_name.tag_version, eg 'tree-sitter.0.20.7' or 
    'tree-sitter-bash.0.19.0'

See https://github.com/calicoday/tree-sitter-repos for more information.
```

Other examples:
```
ruby src/repo_runner.rb list_lang_repos
```
Generates `lang_repos.json` by scraping the list of language parsers in [Introduction: Available Parsers](https://tree-sitter.github.io/tree-sitter/#available-parsers) and calls `git -c` or `git ls-remote` to get the most recent version tag.

```
ruby src/repo_runner.rb --tag-list='0.20.0' clone
```
Clones version 0.20.0 of the tree-sitter runtime to `repos/` and adds or updates an entry in `repos/cloned_repos.json`

```
ruby src/repo_runner.rb -t '0.20.7' --json='src/lang_repos.json' --lang-list='bash' clone
```
Clones version 0.20.7 of the runtime and the version listed in `lang_repos.json` for bash

```
ruby src/repo_runner.rb -t '0.20.7' -l 'bash' -i -d make
```
Makes with verbose output and installs to conventional locations for the platform version 0.20.7 of the runtime and the highest-tagged tree-sitter-bash version already cloned in repos/.

<!-- 
Oops, got deimplemented. FIXME!!!
```
ruby src/repo_runner.rb --repo-dirs='tree-sitter.0.20.0, tree-sitter-make.untagged' clone
ruby src/repo_runner.rb --repo-dirs='tree-sitter.0.20.0, tree-sitter-make.untagged' make
```
Clone or make specific repo versions. 
 -->
 
```
ruby src/repo_runner.rb -t '0.20.0, 0.20.6, 0.20.7' -j 'src/lang_repos.json' -l '' clone
```
Clone runtime versions 0.20.0, 0.20.6 and 0.20.7 and all languages listed in `src/lang_repos.json`. The whole megillah.

```
ruby src/repo_runner.rb -t '0.20.0, 0.20.6, 0.20.7' --core-langs -i make
```
Makes and installs runtime version 0.20.7 and the lastest cloned version of each of the RepoRunner core 'utility pack' of languages commonly used in projects for developer tasks, regardless of a project's main source language. These are:
- Bash, C, C++, Javascript, JSON, Make, Markdown, Python, Rust, S-expressions  (used in the main Tree-sitter repo itself)
- Ruby (for me)
- C# (VisualStudio project/package files)
- TypeScript and WASM (where javascript might be expected, sometimes it's one of these)
- HTML, Embedded Template (used in the Tree-sitter docs section 'Multi-language Documents' sample code)
- (not included but maybe ought to be are Java, YAML)


## To Do

- accomodate more repos. How things stand:
  - Runtime versions 0.20.0, 0.20.6, 0.20.7 work. I haven't tried any others.
  - Me, I use the 13 of the core langs that make properly: bash, c, c-sharp, cpp, embedded-template, html, javascript, json, make, markdown, python, ruby, rust (leaving out sexp, typescript and wasm, because parser.c is not at `src/parser.c` exactly)
  - Clone fails for elisp, sparql, swift, turtle, verilog and kotlin, because the `list_lang_repl` tag-to-version translation is too blunt.
- better docs
- add the C demos here to test linking [why aren't they in this repo, again?]
- the RepoRunner git clone tag handling is VERY blunt and fails for elisp, sparql, swift, turtle, verilog and kotlin, so they are skipped.
- the contents of the generated .pc files are almost certainly wrong. Will fix.
- fix Makefile to handle lang repos with parser.c somewhere other than `src/`, eg tree-sitter-wasm has `wast/src/parser.c` and `wat/src/parser.c`.
- calling the Makefile directly from a repo to be built, with `make -f` rather than through the `repo_runner.rb`, ought to work but I haven't tested it since I changed a bunch of things, so I assume it needs patching.
- the --repo_dirs option is not implemented for `clone`and disabled for `make`. :-/
- `Makefile` and `repo_runner.rb` need some DRYing up and more graceful error handling.
- add a roster listing which versions of langs work with which runtimes.
- better option vetting
- add automated tests
- something something other platforms. Argh.


## Project Notes

### Repo organization and versioning

The design of RepoRunner addresses an idealized repo structure, with kludges to handle the repos as they actually are (with varying degrees of success). My fantasy structure has:
```
repo_name/
  lib/
    include/
      [external headers]
    src/
      [source files]
```

The main tree-sitter repo has this structure, none of the language parser repos do. The external header for a lang, eg tree-sitter-bash.h, should be generated but probably into `repo_name/lib/include/` for local use.

I imagine a `makings/` directory at the top level of the main tree-sitter repo, containing the Makefile all runtime and lang libraries are made with, plus template files for lang header and pkgconfig:
```
makings/
  tree_sitter_runtime.pc.in
  tree_sitter_lang.pc.in
  tree_sitter_lang.h.in
  Makefile
```
and any language parser could be built with `make -f path-to-makings/Makefile` from its repo.

Each language repo should contain a single language parser. So for example, tree-sitter-wasm ought to be two repos, tree-sitter-wast and tree-sitter-wat. Most language repos will be very small -- that's ok, simple things should look simple, yet each will have a space for language variant-specific issues and discussions. The javascript and rust langs currently in the main tree-sitter repo should get their own repos (the cli and tests that use them can find them there). The runtime (and possibly cli, highlighter, etc) might be better off in its own repo, too.

There has been much discussion in the main tree-sitter repo about how repo versioning should work. For my purposes, what matters is that changes in the external interface (ie code changes in any external header, such as api.h or tree-sitter-bash.h) always prompts a tag change. I'm not convinced aligning runtime and lang version tags is beneficial (or indeed, entirely feasible without contortions) but in any case, the tag FORMAT should be standardized. I strongly favour simply digits.digits.digits, eg '0.20.7', no 'v' prefix or other.

