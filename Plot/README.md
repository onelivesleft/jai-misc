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

### Control
* `plot_start`       displayed the window
* `plot_done`        waits until the user closes the window
* `plot_exit`        exits immediately
* `wait`             sleep for a short amount of time
* `wait_for_user`    sleep until the user clicks the mouse or hits a key

### Drawing
* `clear`
* `plot`
* `line`
* `box`
* `block`
* `circle`
* `disc`
