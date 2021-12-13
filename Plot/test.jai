#import "Plot";


width : s32 : 800;
height : s32 : 600;


main :: () {
    plot_start(width, height);

    block(100, 100, 700, 500, colors.red);
    disc(width/2, height/2, 100, colors.yellow);
    circle(width/2, height/2, 100, colors.cyan);

    plot_done();
}
