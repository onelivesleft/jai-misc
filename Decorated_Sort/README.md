# Decorated_Sort

The standard library `Sort` library allows you to easily sort arrays in-place, by creating a function which generates an index value for each item in your array.  However, it calls this function repeatedly for each comparison, which may be inefficient if the function is non-trivial.

`Decorated_Sort` works by calling the function once on every item in the array, and then sorting these generated values separately, in a buffer.  The buffer can then be used to read the items in order.  Effectively this is a performance gain at the expense of space.

You may also wish to use `Decorated_Sort` if you want to have a sorted view of your array *without* mutating the array.  Decorating it lets you do so without copying it: if the items being sorted are large this could be useful.

There are two ways to use this module: with a buffer of `Typed_Decoration`, or with a buffer of `Decoration`.  As you would expect, the former is strongly typed, while the latter is not, but the latter does let you use a single buffer to sort any array, while the former requires each buffer to match the type of the array being sorted.

The module also includes an implementation of `quick_sort`, copied from `Sort` but with the `f` parameter removed.  Hopefully `Sort` will gain this form in future, for `quick_sort` as well as for the other sort algorithms it supports.


## Typed_Decoration

When you create a `Typed_Decoration` buffer you must specify the value type of the array items.  You can also specify the index type retuned by your indexing function: this defaults to `int`.

```jai
#import "Basic";
#import "Decorated_Sort";
#import "String";

letters := #run cast([]u8) "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
buffer : [1024] Typed_Decoration(u8);

main :: () {
    {
        index_of_letter :: (a: u8) -> int {
            return to_upper(a) * 2 + ifx is_lower(a) then 1 else 0;
        }

        decorated := decorate(letters, buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(decorated) {
            print("%", as_string(*it));
        }
    }
}

as_string :: (c: *u8) -> string {
    result := " ";
    result.data = c;
    return result;
}
```


## Decoration

You do not need to specify any types when using a buffer of `Decoration`.  This means you only need one buffer to all your sorts, but you do need to pass in the array you want to apply it to when you `undecorate`.


```jai
#import "Basic";
#import "Decorated_Sort";
#import "String";

letters := #run cast([]u8) "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
buffer : [1024] Decoration;

main :: () {
    {
        index_of_letter :: (a: u8) -> int {
            return to_upper(a) * 2 + ifx is_lower(a) then 1 else 0;
        }

        decorated := decorate(letters, buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(letters, decorated) {
            print("%", as_string(*it));
        }
    }
}

as_string :: (c: *u8) -> string {
    result := " ";
    result.data = c;
    return result;
}
```
