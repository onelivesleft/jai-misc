# Metaprogram

An upgraded version of Default_Metaprogram.  To use it install this module as you normally do, and then either use the `-meta` compiler argument, or replace the `modules/Default_Metaprogram.jai` file in the compiler.  Do so by replacing the `do_error_checking` line in it with:

```jai
            do_error_checking(message, check_bindings = check_bindings);

            {
                // This file is a copy of:
                // `Default_Metaprogram.jai` version `beta 0.0.099`
                // ... but with this block added.
                metaprogram :: #import "Metaprogram";
                metaprogram.check_message(message);
            }
```

If you're comfortable using `diff`, the `Default_Metaprogram.diff` file provided here can be used to automate the change.

You can then toggle the metaprogram features by editing the constants at the top of `Metaprogram.jai`
