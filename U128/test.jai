#import "Basic";
#import "U128";

main :: () {
    foo := u128(65535, 0);
    bar := u128(65535);
    qux := foo | bar;
    print("Qux = %\n", format(qux, base=2, separator="_"));
}
/*

#import "Basic";
#import "U128";

main :: () {
    foo := u128(128);
    print("%\n", foo);

    bar := u128(10, 65515);
    print("%\n", bar);

    print("%\n", foo == bar);
    print("%\n", foo >= bar);
    print("%\n", foo > bar);
    print("%\n", foo < bar);
    print("%\n", foo <= bar);
    print("%\n", foo != bar);

    a := u128(1);
    for 0 .. 130 {
        print("%\n", format(a, fill=true, space=true));
        a >>>= 1;
    }
}
*/
