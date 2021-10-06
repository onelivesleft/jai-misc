#load "typed.jai";
#load "untyped.jai";


quick_sort :: (array: [] $T) {
    // This is a cutnpaste from Sort, with the f parameter removed

    quicksort_helper :: (a: *$T, n: s64) {
        if n < 2 return;

        p := a[n / 2];

        i := 0;
        j := n-1;

        while true {
            fp := p;
            while a[i] < fp  {i += 1;}
            while fp < a[j]  {j -= 1;}

            if i >= j break;

            t := a[i];
            a[i] = a[j];
            a[j] = t;

            i += 1;
            j -= 1;
        }

        quicksort_helper(a, i);
        quicksort_helper(a + i, n - i);
    }

    quicksort_helper(array.data, array.count);
}


#scope_file

#import "Basic";
