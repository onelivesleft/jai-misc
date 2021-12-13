# Plot

Opens a window and lets you draw on it with simple drawing commands.

```jai
#import "Plot";

width : s32 : 800;
height : s32 : 600;

main :: () {
    plot_start(width, height);

    block(100, 100, 700, 500, colors.red);
    circle(width/2, height/2, 100, colors.yellow);

    plot_done();
}
```


## Commands

* `plot`
* `line`
* `box`
* `block`
* `circle`
* `disc`
