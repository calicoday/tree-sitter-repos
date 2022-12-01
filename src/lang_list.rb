### List of tree-sitter lang parser urls extracted from:
# https://github.com/tree-sitter/tree-sitter/blob/master/docs/index.md
# bbedit
#   find: \* \[[^\]]+\]\(([^)]+)-(\w+)\)[^\n]*
#   replace: \t\2: "\1-\2",
# then touch up symbols by hand: csharp, embedded_template, 
# [cd embedded_template be erb??? aliases erb, ejs???]
# note: erlang url has a '/' at the end!!!
# 
# Broken into rough groups of ~ 12, breaks chosen where the initials of the last lang in one group and the first lang of the next group consecutive, alphabetically (so the list of lang groups accounts for all possible initial letters and it won't look like a lib might be missing in a directory listing)

module LangList
  # from tree-sitter-ffi-lang src/pull_parsers.rb

  # replacement for pull_parsers to pull far more parsers, in groups

  # copy tree-sitter language parsers and generate a makefile to compile them.

  # orig langs list:
  # langs = {
  @lang_orig = {
    json: "https://github.com/tree-sitter/tree-sitter-json",
    bash: "https://github.com/tree-sitter/tree-sitter-bash",
    c: "https://github.com/tree-sitter/tree-sitter-c",
  # 	csharp: "https://github.com/tree-sitter/tree-sitter-c-sharp",
  # 	cpp: "https://github.com/tree-sitter/tree-sitter-cpp",
  # 	css: "https://github.com/tree-sitter/tree-sitter-css",
  # 	elm: "https://github.com/elm-tooling/tree-sitter-elm",
  # 	eno: "https://github.com/eno-lang/tree-sitter-eno",
    embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
  # 	fennel: "https://github.com/travonted/tree-sitter-fennel",
  # 	go: "https://github.com/tree-sitter/tree-sitter-go",
    html: "https://github.com/tree-sitter/tree-sitter-html",
    java: "https://github.com/tree-sitter/tree-sitter-java",
    javascript: "https://github.com/tree-sitter/tree-sitter-javascript",
  # 	lua: "https://github.com/Azganoth/tree-sitter-lua",
    make: "https://github.com/alemuller/tree-sitter-make",
    markdown: "https://github.com/ikatyang/tree-sitter-markdown",
  # 	ocaml: "https://github.com/tree-sitter/tree-sitter-ocaml",
  # 	php: "https://github.com/tree-sitter/tree-sitter-php",
    python: "https://github.com/tree-sitter/tree-sitter-python",
    ruby: "https://github.com/tree-sitter/tree-sitter-ruby",
    rust: "https://github.com/tree-sitter/tree-sitter-rust",
  # 	r: "https://github.com/r-lib/tree-sitter-r",
  # 	sexpressions: "https://github.com/AbstractMachinesLab/tree-sitter-sexp",
  # 	sparql: "https://github.com/BonaBeavis/tree-sitter-sparql",
  # 	systemrdl: "https://github.com/SystemRDL/tree-sitter-systemrdl",
  # 	svelte: "https://github.com/Himujjal/tree-sitter-svelte",
  # 	toml: "https://github.com/ikatyang/tree-sitter-toml",
  # 	turtle: "https://github.com/BonaBeavis/tree-sitter-turtle",
  # 	typescript: "https://github.com/tree-sitter/tree-sitter-typescript",
  # 	verilog: "https://github.com/tree-sitter/tree-sitter-verilog",
  # 	vhdl: "https://github.com/alemuller/tree-sitter-vhdl",
  # 	vue: "https://github.com/ikatyang/tree-sitter-vue",
  # 	yaml: "https://github.com/ikatyang/tree-sitter-yaml",
  # 	wasm: "https://github.com/wasm-lsp/tree-sitter-wasm",
    }


  ### Available Parsers

  # Parsers for these languages are fairly complete:

  @lang_AE = {
    bash: "https://github.com/tree-sitter/tree-sitter-bash",
    c: "https://github.com/tree-sitter/tree-sitter-c",
    csharp: "https://github.com/tree-sitter/tree-sitter-c-sharp",
    cpp: "https://github.com/tree-sitter/tree-sitter-cpp",
    commonlisp: "https://github.com/theHamsta/tree-sitter-commonlisp",
    css: "https://github.com/tree-sitter/tree-sitter-css",
    cuda: "https://github.com/theHamsta/tree-sitter-cuda",
    dot: "https://github.com/rydesun/tree-sitter-dot",
    elm: "https://github.com/elm-tooling/tree-sitter-elm",
    elisp: "https://github.com/Wilfred/tree-sitter-elisp",
    eno: "https://github.com/eno-lang/tree-sitter-eno",
    embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
  }

  @lang_FO = {
    fennel: "https://github.com/travonted/tree-sitter-fennel",
    glsl: "https://github.com/theHamsta/tree-sitter-glsl",
    go: "https://github.com/tree-sitter/tree-sitter-go",
    hcl: "https://github.com/MichaHoffmann/tree-sitter-hcl",
    html: "https://github.com/tree-sitter/tree-sitter-html",
    java: "https://github.com/tree-sitter/tree-sitter-java",
    javascript: "https://github.com/tree-sitter/tree-sitter-javascript",
    json: "https://github.com/tree-sitter/tree-sitter-json",
    lua: "https://github.com/Azganoth/tree-sitter-lua",
    make: "https://github.com/alemuller/tree-sitter-make",
    markdown: "https://github.com/ikatyang/tree-sitter-markdown",
    ocaml: "https://github.com/tree-sitter/tree-sitter-ocaml",
  }

  @lang_LS = {
    php: "https://github.com/tree-sitter/tree-sitter-php",
    python: "https://github.com/tree-sitter/tree-sitter-python",
    ruby: "https://github.com/tree-sitter/tree-sitter-ruby",
    rust: "https://github.com/tree-sitter/tree-sitter-rust",
    r: "https://github.com/r-lib/tree-sitter-r",
    sexp: "https://github.com/AbstractMachinesLab/tree-sitter-sexp",
    sparql: "https://github.com/BonaBeavis/tree-sitter-sparql",
    systemrdl: "https://github.com/SystemRDL/tree-sitter-systemrdl",
    svelte: "https://github.com/Himujjal/tree-sitter-svelte",
  }

  @lang_TZ = {
    toml: "https://github.com/ikatyang/tree-sitter-toml",
    turtle: "https://github.com/BonaBeavis/tree-sitter-turtle",
    typescript: "https://github.com/tree-sitter/tree-sitter-typescript",
    verilog: "https://github.com/tree-sitter/tree-sitter-verilog",
    vhdl: "https://github.com/alemuller/tree-sitter-vhdl",
    vue: "https://github.com/ikatyang/tree-sitter-vue",
    yaml: "https://github.com/ikatyang/tree-sitter-yaml",
    wasm: "https://github.com/wasm-lsp/tree-sitter-wasm",
    wgsl: "https://github.com/mehmetoguzderin/tree-sitter-wgsl",
  }

  # Parsers for these languages are in development:

  @lang_dev = {
    agda: "https://github.com/tree-sitter/tree-sitter-agda",
    elixir: "https://github.com/elixir-lang/tree-sitter-elixir",
    erlang: "https://github.com/AbstractMachinesLab/tree-sitter-erlang",
    dockerfile: "https://github.com/camdencheek/tree-sitter-dockerfile",
    mod: "https://github.com/camdencheek/tree-sitter-go-mod",
    hack: "https://github.com/slackhq/tree-sitter-hack",
    haskell: "https://github.com/tree-sitter/tree-sitter-haskell",
    julia: "https://github.com/tree-sitter/tree-sitter-julia",
    kotlin: "https://github.com/fwcd/tree-sitter-kotlin",
    nix: "https://github.com/cstrahan/tree-sitter-nix",
    objc: "https://github.com/jiyee/tree-sitter-objc",
    org: "https://github.com/milisims/tree-sitter-org",
    perl: "https://github.com/ganezdragon/tree-sitter-perl",
    proto: "https://github.com/mitchellh/tree-sitter-proto",
    scala: "https://github.com/tree-sitter/tree-sitter-scala",
    sourcepawn: "https://github.com/nilshelmig/tree-sitter-sourcepawn",
    swift: "https://github.com/tree-sitter/tree-sitter-swift",
    sql: "https://github.com/m-novikov/tree-sitter-sql",
  }

  # A utility pack of languages commonly used in projects for developer tasks, 
  # regardless of a project's main source language:
  # - Bash, C, C++, Javascript, JSON, Make, Markdown, Rust, S-expressions 
  #   (used in the tree-sitter repo itself)
  # - Ruby (for me)
  # - C# (VisualStudio project/package files)
  # - TypeScript and WASM (where javascript might be expected, sometimes it's 
  #   one of these)
  # - HTML, Embedded Template (used in the tree-sitter docs section 
  #   'Multi-language Documents' sample code)
  # 
  # Not included but maybe ought to be are Java, YAML.

  # prob don't need to pull these again, just make an additional??? FIXME!!!

  @lang_core = {
    bash: "https://github.com/tree-sitter/tree-sitter-bash",
    c: "https://github.com/tree-sitter/tree-sitter-c",
    csharp: "https://github.com/tree-sitter/tree-sitter-c-sharp",
    cpp: "https://github.com/tree-sitter/tree-sitter-cpp",
    javascript: "https://github.com/tree-sitter/tree-sitter-javascript",
    json: "https://github.com/tree-sitter/tree-sitter-json",
    make: "https://github.com/alemuller/tree-sitter-make",
    markdown: "https://github.com/ikatyang/tree-sitter-markdown",
    python: "https://github.com/tree-sitter/tree-sitter-python",
    ruby: "https://github.com/tree-sitter/tree-sitter-ruby",
    rust: "https://github.com/tree-sitter/tree-sitter-rust",
    sexp: "https://github.com/AbstractMachinesLab/tree-sitter-sexp",
    typescript: "https://github.com/tree-sitter/tree-sitter-typescript",
    wasm: "https://github.com/wasm-lsp/tree-sitter-wasm",
    embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
    html: "https://github.com/tree-sitter/tree-sitter-html",
  }

  # langs that were in my original set that aren't in the new core

  @lang_back = {
    java: "https://github.com/tree-sitter/tree-sitter-java",
  }

  # langs relevant to markup/configuration/output that aren't in the new core

  @lang_markup = {
    css: "https://github.com/tree-sitter/tree-sitter-css",
    dot: "https://github.com/rydesun/tree-sitter-dot",
    yaml: "https://github.com/ikatyang/tree-sitter-yaml",
  }
  
end
