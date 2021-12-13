#import "Basic";
#import "Input";
#import "Math";
#import "Simp";
#import "Thread";
#import "Time";
#import "Windows";
Window_Creation :: #import "Window_Creation";


plot_is_running := false;

default_window_width : s32 : 1024;
default_window_height : s32 : 768;
default_color :: colors.white;

window: Window_Creation.Window_Type;

window_title : string;
window_width : s32;
window_height : s32;


plot_start :: (width := default_window_width, height := default_window_height, title := "Plot") {
    #if OS == .WINDOWS {
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows :: #import "Windows";
        Windows.timeBeginPeriod(1);
    }

    window_width = width;
    window_height = height;
    window_title = title;

    thread_init(*thread, thread_update);
    thread.data = *bitmap;
    thread_start(*thread);

    while !plot_is_running  wait();
}


wait :: () {
    sleep_milliseconds(10);
}


plot_done :: () {
    while plot_is_running  wait();
}


plot_exit :: () {
    plot_is_running = false;
}



clear :: () {
    memset(bitmap.data.data, 0, bitmap.width * bitmap.height * 3);
}


plot :: (x: $T, y: T, color := default_color) {
    index := (cast,trunc(s32)x + bitmap.width * cast,trunc(s32)y) * 3;
    if !bitmap.data || index >= bitmap.data.count  return;

    <<cast(*RGB)*bitmap.data[index] = color;
}

plot :: inline (p: Vector2, color := colors.white) {
    plot(p.x, p.y, color);
}


line :: (x0: $T, y0: T, x1: T, y1: T, color := default_color) {
    if x0 == x1 && y0 == y1 {
        plot(x0, y0, color);
        return;
    }

    dx := x1 - x0;
    dy := y1 - y0;
    if abs(dy) > abs(dx) {
        if dy < 0 {
            Swap(*x0, *x1);
            Swap(*y0, *y1);
            dy = -dy;
        }
        x : float = xx x0;
        sx := cast(float)dx / cast(float)dy;
        y := y0;
        while y <= y1 {
            plot(x, cast(float)y, color);
            x += sx;
            y += 1;
        }
    }
    else {
        if dx < 0 {
            Swap(*x0, *x1);
            Swap(*y0, *y1);
            dx = -dx;
        }
        y : float = xx y0;
        sy := cast(float)dy / cast(float)dx;
        x := x0;
        while x <= x1 {
            plot(cast(float)x, y, color);
            y += sy;
            x += 1;
        }
    }
}

line :: inline (p0: Vector2, p1: Vector2, color := colors.white) {
    line(p0.x, p0.y, p1.x, p1.y, color);
}


box :: (x0: $T, y0: T, x1: T, y1: T, color := default_color) {
    if x0 == x1 {
        vertical_line(x0, y0, y1, color);
        return;
    }
    else if y0 == y1 {
        horizontal_line(x0, x1, y0, color);
        return;
    }

    {
        if x0 > x1  Swap(*x0, *x1);
        x := x0;
        while x <= x1 {
            plot(x, y0, color);
            plot(x, y1, color);
            x += 1;
        }
    }

    {
        if y0 > y1  Swap(*y0, *y1);
        y := y0;
        while y <= y1 {
            plot(x0, y, color);
            plot(x1, y, color);
            y += 1;
        }
    }
}

box :: inline (p0: Vector2, p1: Vector2, color := colors.white) {
    box(p0.x, p0.y, p1.x, p1.y, color);
}



block :: (x0: $T, y0: T, x1: T, y1: T, color := default_color) {
    if x0 == x1 {
        vertical_line(x0, y0, y1, color);
        return;
    }
    else if y0 == y1 {
        horizontal_line(x0, x1, y0, color);
        return;
    }

    if y0 > y1  Swap(*y0, *y1);
    y := y0;
    while y <= y1 {
        horizontal_line(x0, x1, y, color);
        y += 1;
    }
}

block :: inline (p0: Vector2, p1: Vector2, color := colors.white) {
    block(p0.x, p0.y, p1.x, p1.y, color);
}


disc :: (x: $T, y: T, r: T, color := default_color) {
    r2 := r * r;
    for py: y - r .. y + r {
        for px: x - r .. x + r {
            dx := x - px;  dy := y - py;
            if dx * dx + dy * dy <= r2
                plot(px, py, color);
        }
    }
}

disc :: inline (p: Vector2, r: $T, color := default_color) {
    disc(p.x, p.y, xx r, color);
}


circle :: (x: $T, y: T, r: T, color := default_color) {
    r2 := r * r;
    inner_r2 := (r - 1) * (r - 1);
    for py: y - r .. y + r {
        for px: x - r .. x + r {
            dx := x - px;  dy := y - py;
            pr := dx * dx + dy * dy;
            if pr <= r2 && pr > inner_r2
                plot(px, py, color);
        }
    }
}

circle :: inline (p: Vector2, r: $T, color := default_color) {
    circle(p.x, p.y, xx r, color);
}



RGB :: struct {
    r, g, b: u8;
}

rgb :: (color: Vector3) -> RGB {
    result : RGB = ---;
    result.r = xx (color.x * 255);
    result.g = xx (color.y * 255);
    result.b = xx (color.z * 255);
}

rgb :: inline (color: Vector4) -> RGB {
    return rgb(color.xyz);
}


colors : struct {
    black   :: RGB.{0, 0, 0};
    red     :: RGB.{255, 0, 0};
    green   :: RGB.{0, 255, 0};
    blue    :: RGB.{0, 0, 255};
    cyan    :: RGB.{0, 255, 255};
    magenta :: RGB.{255, 0, 255};
    yellow  :: RGB.{255, 255, 0};
    white   :: RGB.{255, 255, 255};
    by_index :: RGB.[colors.black, colors.red, colors.green, colors.blue, colors.cyan, colors.magenta, colors.yellow, colors.white];
}



#scope_module



thread: Thread;
bitmap : Bitmap;
texture : Texture;

now : float64;
dt : float64;

window_style : u32 : xx (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX);


thread_update :: (thread: *Thread) -> s64 {
    window = Window_Creation.create_window(window_width, window_height, window_title, window_x = 200, window_y = 200, style = window_style);
    set_render_target(window);
    //init_fonts();  @TODO

    bitmap_alloc(*bitmap, window_width, window_height, .RGB8);

    plot_is_running = true;

    while plot_is_running {
        prev_time := now;
        now = get_time();
        dt = cast(float32) (now - prev_time);

        handle_window_events();
        draw_one_frame();

        sleep_milliseconds(10);
    }

    return 0;
}


handle_window_events :: () {
    update_window_events();

    for get_window_resizes() {
        update_window(window);  // Simp will do nothing if it doesn't care about this window.

        if it.window == window {
            //should_reinit := (it.width != window_width) || (it.height != window_height);

            window_width  = it.width;
            window_height = it.height;

            //if should_reinit my_init_fonts();  // Resize the font for the new window size.
        }
    }

    //mouse_x, mouse_y, mouse_ok = get_mouse_pointer_position(window, false);
    //mouse_y = height - mouse_y;

    for event: events_this_frame {
        if event.type == {
            case .QUIT;
            plot_is_running = false;

            case .KEYBOARD;
            if event.key_pressed {
                if event.key_code == {
                    case .ESCAPE;
                    plot_is_running = false;
                }
            }
        }
    }
}


draw_one_frame :: () {
    if !texture_load_from_bitmap(*texture, *bitmap)  return;

    set_shader_for_images(*texture);
    immediate_begin();

    immediate_quad(v2(0, 0), v2(window_width, 0), v2(window_width, window_height), v2(0, window_height));
    immediate_flush();

    swap_buffers(window);
}


v2 :: (x: s32, y: s32) -> Vector2 {
    result : Vector2 = ---;
    result.x = xx x;
    result.y = xx y;
    return result;
}


horizontal_line :: (x0: $T, x1: T, y: T, color := default_color) {
    if x0 == x1 {
        plot(x0, y);
        return;
    }

    if x0 > x1  Swap(*x0, *x1);
    x := x0;
    while x <= x1 {
        plot(x, y, color);
        x += 1;
    }
}


vertical_line :: (x: $T, y0: T, y1: T, color := default_color) {
    if y0 == y1 {
        plot(x, y0);
        return;
    }

    if y0 > y1  Swap(*y0, *y1);
    y := y0;
    while y <= y1 {
        plot(x, y, color);
        y += 1;
    }
}
