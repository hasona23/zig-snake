const rl = @import("raylib");

pub const WINDOW_WIDTH = 800;
pub const WINDOW_HEIGHT = 600;
pub const WINDOW_TITLE = "Snake";

pub const BACKGROUND_COLOR = rl.Color.black;

pub const GRID_COLOR = rl.Color.ray_white;
pub const GRID_THICKNESS = 2;
pub const CELL_SIZE = 40;
pub const ROWS = 15;
pub const COLS = 17;

pub const SNAKE_HEAD_ALIVE_COLOR = rl.Color.sky_blue;
pub const SNAKE_BODY_ALIVE_COLOR = rl.Color.blue;
pub const SNAKE_HEAD_DEAD_COLOR = rl.Color.gray;
pub const SNAKE_BODY_DEAD_COLOR = rl.Color.dark_gray;
