const grid_mod = @import("grid.zig");
const c = @import("const.zig");
const rl = @import("raylib");
const item_mod = @import("item.zig");

const COOLDOWN = 0.4;

const Directions = enum {
    UP,
    DOWN,
    RIGHT,
    LEFT,
    pub fn GetDirectionVec2(self: Directions) rl.Vector2 {
        const v = switch (self) {
            .UP => rl.Vector2{ .x = 0, .y = -1 },
            .DOWN => rl.Vector2{ .x = 0, .y = 1 },
            .RIGHT => rl.Vector2{ .x = 1, .y = 0 },
            else => rl.Vector2{ .x = -1, .y = 0 },
        };
        return v;
    }
};

pub const Snake = struct {
    Body: [c.ROWS * c.COLS]rl.Vector2 = undefined,
    _size: i32 = 1,
    Dir: Directions = Directions.RIGHT,
    IsAlive: bool = true,
    _coolDownTimer: f32 = 0,
    pub fn Create(grid: grid_mod.Grid) Snake {
        var snake = Snake{};
        snake.Body[0] = grid.Middle();
        snake.Body[1] = snake.Body[0].subtract(rl.Vector2{ .x = c.CELL_SIZE, .y = 0 });
        snake.Body[2] = snake.Body[1].subtract(rl.Vector2{ .x = c.CELL_SIZE, .y = 0 });
        snake._size = 3;
        return snake;
    }
    pub fn ReachedMaxSize(self: Snake) bool {
        return self.Body.len == self._size;
    }
    pub fn Update(self: *Snake, grid: grid_mod.Grid, item: *item_mod.Item) void {
        if (!self.IsAlive)
            return;
        var dir = self.Dir;
        if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right))
            dir = Directions.RIGHT;
        if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left))
            dir = Directions.LEFT;
        if (rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up))
            dir = Directions.UP;
        if (rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down))
            dir = Directions.DOWN;

        self.setDirection(dir);
        if (self.isBodyCollision(item.Pos)) {
            self.Grow();
            if (!self.ReachedMaxSize())
                item.ReSpawn(grid, &self.Body, self._size);
        }

        self._coolDownTimer -= rl.getFrameTime();
        if (self._coolDownTimer <= 0) {
            self._coolDownTimer += COOLDOWN;
            self.IsAlive = self.move(grid);
        }

        if (!grid.CheckInRange(self.Body[0])) {
            self.IsAlive = false;
        }
    }
    fn setDirection(self: *Snake, dir: Directions) void {
        //movement from body[1] to body[0](head)
        const posChange = rl.Vector2.subtract(self.Body[0], self.Body[1]);
        if (posChange.x > 0 and dir == Directions.LEFT)
            return;
        if (posChange.x < 0 and dir == Directions.RIGHT)
            return;
        if (posChange.y > 0 and dir == Directions.UP)
            return;
        if (posChange.y < 0 and dir == Directions.DOWN)
            return;
        self.Dir = dir;
    }
    fn move(self: *Snake, grid: grid_mod.Grid) bool {
        var i = self.Body.len - 1;
        const bodyNewPos = self.Body[0].add(self.Dir.GetDirectionVec2().scale(c.CELL_SIZE));
        if (self.isBodyCollision(bodyNewPos))
            return false;
        if (!grid.CheckInRange(bodyNewPos))
            return false;
        while (i > 0) : (i -= 1)
            self.Body[i] = self.Body[i - 1];
        self.Body[0] = bodyNewPos;
        return true;
    }
    fn isBodyCollision(self: Snake, pos: rl.Vector2) bool {
        for (0..@intCast(self._size)) |i| {
            if (self.Body[i].equals(pos)) {
                return true;
            }
        }
        return false;
    }
    pub fn Draw(self: Snake) void {
        for (0..@intCast(self._size)) |i| {
            const pos = self.Body[i].add(rl.Vector2{ .x = 5, .y = 5 });
            var color = c.SNAKE_BODY_ALIVE_COLOR;
            if (!self.IsAlive) {
                color = c.SNAKE_BODY_DEAD_COLOR;
            }
            if (i == 0) {
                color = c.SNAKE_HEAD_ALIVE_COLOR;
                if (!self.IsAlive) {
                    color = c.SNAKE_HEAD_DEAD_COLOR;
                }
            }
            rl.drawRectangleV(
                pos,
                rl.Vector2{
                    .x = c.CELL_SIZE - 10,
                    .y = c.CELL_SIZE - 10,
                },
                color,
            );
        }
    }
    pub fn Grow(self: *Snake) void {
        const size: usize = @intCast(self._size);
        if (self._size > 1) {
            const dir = self.Body[size - 1].subtract(self.Body[size - 2]);
            self.Body[size] = self.Body[size - 1].add(dir);
        }
        self._size += 1;
    }
};
