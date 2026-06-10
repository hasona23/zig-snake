const std = @import("std");

const grid_mod = @import("grid.zig");
const rl = @import("raylib");
const snake_mod = @import("snake.zig");
const item_mod = @import("item.zig");
const c = @import("const.zig");

const GameState = enum { WON, LOST, RUNNING, PAUSE };

pub const Game = struct {
    _width: i32,
    _height: i32,
    _title: [:0]const u8,
    _grid: grid_mod.Grid = undefined,
    _snake: snake_mod.Snake = undefined,
    _item: item_mod.Item = undefined,
    _score: u32 = 0,
    _state: GameState = .RUNNING,

    pub fn Create(width: i32, height: i32, title: [:0]const u8) Game {
        return Game{
            ._width = width,
            ._height = height,
            ._title = title,
        };
    }
    pub fn Title(self: Game) [:0]const u8 {
        return self._title;
    }
    pub fn Width(self: Game) i32 {
        return self._width;
    }
    pub fn Height(self: Game) i32 {
        return self._height;
    }
    fn Init(self: *Game) void {
        rl.initWindow(self.Width(), self.Height(), self.Title());

        rl.setTargetFPS(60);

        self._grid = grid_mod.Grid.Create(120, 0, c.CELL_SIZE, c.ROWS, c.COLS);
        self._snake = snake_mod.Snake.Create(self._grid);
        self._item = item_mod.Item{ .Pos = rl.Vector2{
            .x = 0,
            .y = 0,
        } };
        self._item.ReSpawn(self._grid, &self._snake.Body, self._snake._size);
    }
    fn Reset(self: *Game) void {
        self._grid = grid_mod.Grid.Create(120, 0, c.CELL_SIZE, c.ROWS, c.COLS);
        self._snake = snake_mod.Snake.Create(self._grid);
        self._item = item_mod.Item{ .Pos = rl.Vector2{
            .x = 0,
            .y = 0,
        } };
        self._item.ReSpawn(self._grid, &self._snake.Body, self._snake._size);
        self._state = .RUNNING;
    }
    fn Update(self: *Game) void {
        if (self._state == .RUNNING) {
            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                self._state = .PAUSE;
            }
            self._snake.Update(self._grid, &self._item);
            self._score = @intCast(self._snake._size - 3);
            const hasLost = !self._snake.IsAlive;
            if (hasLost) {
                self._state = .LOST;
            }
            const hasWon = self._snake.ReachedMaxSize();
            if (hasWon) {
                self._state = .WON;
            }
        } else {
            if (rl.isKeyPressed(rl.KeyboardKey.enter) or rl.isKeyPressed(rl.KeyboardKey.space)) {
                if (self._state == .LOST or self._state == .WON)
                    self.Reset();
                self._state = .RUNNING;
            }
        }
    }
    fn Draw(self: *Game) !void {
        rl.beginDrawing();
        {
            rl.clearBackground(c.BACKGROUND_COLOR);
            var buf: [16:0]u8 = undefined;
            const s = std.fmt.bufPrintZ(&buf, "SCORE: {d:0>3}", .{self._score}) catch unreachable;
            rl.drawText(s, 0, 20, 20, rl.Color.ray_white);
            rl.drawText("(SPACE) \nPAUSE", 0, 90, 20, rl.Color.ray_white);
            rl.drawText("(WASD)\nMOVEMENT", 0, 150, 20, rl.Color.ray_white);
            rl.drawText("(ARROWS)\nMOVEMENT", 0, 210, 20, rl.Color.ray_white);
            self._grid.Draw();
            self._snake.Draw();
            self._item.Draw();
            if (self._state != .RUNNING) {
                rl.drawRectangle(0, 0, c.WINDOW_WIDTH, c.WINDOW_HEIGHT, rl.colorAlpha(rl.Color.white, 0.2));
                const msg = switch (self._state) {
                    GameState.LOST => "YOU LOST!\nPress enter / space to continue",
                    GameState.WON => "YOU WON!\nPress enter / space to continue",
                    else => "PAUSE!",
                };
                const fontSize = 32;
                const size = rl.measureText(msg, fontSize);
                rl.drawText(msg, @divTrunc((c.WINDOW_WIDTH - size), 2), @divTrunc((c.WINDOW_HEIGHT - fontSize), 2), fontSize, rl.Color.orange);
            }
        }
        rl.endDrawing();
    }
    fn Destroy(self: *Game) void {
        rl.closeWindow();
        self._snake.Body = null;
    }
    pub fn Run(self: *Game) !void {
        self.Init();
        while (!rl.windowShouldClose()) {
            self.Update();
            try self.Draw();
        }
    }
};
