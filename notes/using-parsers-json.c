// sample from Using Parsers

// Here’s an example of a simple C program that uses the Tree-sitter JSON parser.
//
// This program uses the Tree-sitter C API, which is declared in the header file tree-sitter/api.h, so we need to add the tree-sitter/lib/include directory to the include path. We also need to link libtree-sitter.a into the binary. We compile the source code of the JSON language directly into the binary as well.
// 
// this one works for me:
/*
clang -v \
  using-parsers-json.c \
  /usr/local/lib/libtree-sitter.a \
  /usr/local/lib/libtree-sitter-ffi-lang.a \
  -o using-parsers-json
*/

/*
clang                                   \
  -I tree-sitter/lib/include            \
  using-parsers-json.c                    \
  tree-sitter-json/src/parser.c         \
  tree-sitter/libtree-sitter.a          \
  -o test-json-parser
*/

/*
clang -v \
  -I /usr/local/include \
  using-parsers-json.c \
  /usr/local/lib/libtree-sitter.a \
  /usr/local/lib/libtree-sitter-ffi-lang.a \
  -o using-parsers-json
*/

// wd be:
// -I /usr/local/include
// -L /usr/local/lib
/*
clang -v \
  using-parsers-json.c \
  -L/usr/local/lib \
  libtree-sitter.a \
  libtree-sitter-ffi-lang.a \
  -o using-parsers-json
*/

/*
clang -v \
  using-parsers-json.c \
  -L/usr/local/lib
  -llibtree-sitter.a \
  -llibtree-sitter-ffi-lang.a \
  -o using-parsers-json
*/

// 
// to run:
/*
./test-json-parser
*/


// Filename - test-json-parser.c

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <tree_sitter/api.h>

// Declare the `tree_sitter_json` function, which is
// implemented by the `tree-sitter-json` library.
TSLanguage *tree_sitter_json();

int main() {
  // Create a parser.
  TSParser *parser = ts_parser_new();

  // Set the parser's language (JSON in this case).
  ts_parser_set_language(parser, tree_sitter_json());

  // Build a syntax tree based on source code stored in a string.
  const char *source_code = "[1, null]";
  TSTree *tree = ts_parser_parse_string(
    parser,
    NULL,
    source_code,
    strlen(source_code)
  );

  // Get the root node of the syntax tree.
  TSNode root_node = ts_tree_root_node(tree);

  // Get some child nodes.
  TSNode array_node = ts_node_named_child(root_node, 0);
  TSNode number_node = ts_node_named_child(array_node, 0);

  // Check that the nodes have the expected types.
  assert(strcmp(ts_node_type(root_node), "document") == 0);
  assert(strcmp(ts_node_type(array_node), "array") == 0);
  assert(strcmp(ts_node_type(number_node), "number") == 0);

  // Check that the nodes have the expected child counts.
  assert(ts_node_child_count(root_node) == 1);
  assert(ts_node_child_count(array_node) == 5);
  assert(ts_node_named_child_count(array_node) == 2);
  assert(ts_node_child_count(number_node) == 0);

  // Print the syntax tree as an S-expression.
  char *string = ts_node_string(root_node);
  printf("Syntax tree: %s\n", string);

  // Free all of the heap-allocated memory.
  free(string);
  ts_tree_delete(tree);
  ts_parser_delete(parser);
  return 0;
}
