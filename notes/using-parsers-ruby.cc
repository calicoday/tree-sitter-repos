// compile (ignoring clang: warning: treating 'c' input as 'c++' when in C++ mode, this behavior is deprecated [-Wdeprecated] because of parser.c) and run:
// 
// clang++ \
// 	-I ln-tree-sitter/lib/include \
// 	test-ruby-parser.cc \
// 	ln-ruby-src/parser.c \
// 	ln-ruby-src/scanner.cc \
// 	ln-tree-sitter/libtree-sitter.a \
// 	-o test-ruby-parser
// 
// ./test-ruby-parser
// which gives results:
// 
// Syntax tree: (program (array (integer) (nil)))

// Filename - test-ruby-parser.cc

#include <cassert> // was C headers
#include <cstring>
#include <cstdio>
#include <tree_sitter/api.h>

#ifdef __cplusplus
extern "C" { // was not extern "C"
#endif
// Declare the `tree_sitter_ruby` function, which is
// implemented by the `tree-sitter-ruby` library.
TSLanguage *tree_sitter_ruby();
#ifdef __cplusplus
}
#endif

int main() {
  // Create a parser.
  TSParser *parser = ts_parser_new();

  // Set the parser's language (Ruby in this case).
  ts_parser_set_language(parser, tree_sitter_ruby());

  // Build a syntax tree based on source code stored in a string.
  const char *source_code = "[1, nil]"; // was "[1, null]"
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
  assert(strcmp(ts_node_type(root_node), "program") == 0); // was "document"
  assert(strcmp(ts_node_type(array_node), "array") == 0);
  assert(strcmp(ts_node_type(number_node), "integer") == 0); // was "number"

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

/*
compile (ignoring clang: warning: treating 'c' input as 'c++' when in C++ mode, this behavior is deprecated [-Wdeprecated] because of parser.c) and run:

clang++ \
	-I ln-tree-sitter/lib/include \
	test-ruby-parser.cc \
	ln-ruby-src/parser.c \
	ln-ruby-src/scanner.cc \
	ln-tree-sitter/libtree-sitter.a \
	-o test-ruby-parser

./test-ruby-parser
*/

