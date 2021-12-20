# Misc Jai Modules

## Decorated_Sort

The standard `Sort` library allows you to easily sort arrays in-place, by creating a function which generates an index value for each item in your array.  However, it calls this function repeatedly for each comparison, which may be inefficient if the function is non-trivial.

`Decorated_Sort` works by calling the function once on every item in the array, and then sorting these generated values separately, in a buffer.  The buffer can then be used to read the items in order.  Effectively this is a performance gain at the expense of space.


## Error

Provides a print-like called `print_error` which outputs to stderr.


## File_For

Lets you read through a file inside a `for` loop, using a pre-allocated buffer (or by specifying a size and letting it set up the buffer for you).


## Iter

Provides tools for iteration


## Metaprogram

Replacement Default_Metaprogram with upgraded features.


## Plot

Shows a window and lets you draw in it with simple draw commands (`plot`, `line`, etc.)


## Struct

Utilities for working with structs


## U128

Provides a `U128` type that currently supports bitwise and comparison operators.
