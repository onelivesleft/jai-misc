#import "Basic";
#import "Iter";

main :: () {
    values := int.[1, 2, 3, 4, 5];

    double :: (x: int) -> float {
        return x * 1.99;
    }

    for map(values, double)  print("%\n", it);
}
