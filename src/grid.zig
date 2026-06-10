const rl = @import("raylib");
const c = @import("const.zig");

pub const Grid = struct {
    Pos: rl.Vector2,
    CellSize: i32,
    Rows: i32,
    Cols: i32,
    pub fn Create(x: f32, y: f32, cellSize: i32, rows: i32, cols: i32) Grid {
        return Grid{ .Pos = rl.Vector2{ .x = x, .y = y }, .CellSize = cellSize, .Rows = rows, .Cols = cols };
    }
    pub fn CheckInRange(self: Grid, pos: rl.Vector2) bool {
        if (pos.x < self.Pos.x or pos.x > self.Pos.x + self.width() - c.CELL_SIZE)
            return false;

        if (pos.y < self.Pos.y or pos.y > self.Pos.y + self.height() - c.CELL_SIZE)
            return false;
        return true;
    }
    pub fn width(self: Grid) f32 {
        return @floatFromInt(self.CellSize * self.Cols);
    }
    pub fn height(self: Grid) f32 {
        return @floatFromInt(self.CellSize * self.Rows);
    }
    pub fn Middle(self: Grid) rl.Vector2 {
        return self.GetGridPos(rl.Vector2{
            .x = self.Pos.x + self.width() / 2,
            .y = self.Pos.y + self.height() / 2,
        });
    }
    pub fn GetGridPos(self: Grid, p: rl.Vector2) rl.Vector2 {
        var pos = p;
        const cellSize: f32 = @floatFromInt(self.CellSize);
        pos = rl.Vector2.clamp(
            pos,
            rl.Vector2{
                .x = self.Pos.x,
                .y = self.Pos.y,
            },
            rl.Vector2{
                .x = (@as(f32, @floatFromInt(self.Cols)) - 1.0) * cellSize + self.Pos.x,
                .y = (@as(f32, @floatFromInt(self.Rows)) - 1.0) * cellSize + self.Pos.y,
            },
        );
        pos.x -= self.Pos.x;
        pos.y -= self.Pos.y;

        pos = pos.scale(1.0 / cellSize);

        pos.x = @trunc(pos.x);
        pos.y = @trunc(pos.y);

        pos = pos.scale(cellSize);

        pos.x += self.Pos.x;
        pos.y += self.Pos.y;
        return pos;
    }

    pub fn Draw(self: Grid) void {
        const cellSize: f32 = @floatFromInt(self.CellSize);
        const cols: f32 = @floatFromInt(self.Cols);
        const rows: f32 = @floatFromInt(self.Rows);

        for (0..@intCast(self.Rows + 1)) |i| {
            const row: f32 = @floatFromInt(i);
            const start = rl.Vector2{
                .x = self.Pos.x,
                .y = self.Pos.y + row * cellSize,
            };
            const end = rl.Vector2{
                .x = self.Pos.x + cellSize * cols,
                .y = self.Pos.y + row * cellSize,
            };
            rl.drawLineEx(
                start,
                end,
                c.GRID_THICKNESS,
                c.GRID_COLOR,
            );
        }

        for (0..@intCast(self.Cols + 1)) |i| {
            const col: f32 = @floatFromInt(i);
            const start = rl.Vector2{
                .x = self.Pos.x + col * cellSize,
                .y = self.Pos.y,
            };

            const end = rl.Vector2{
                .x = self.Pos.x + col * cellSize,
                .y = self.Pos.y + cellSize * rows,
            };

            rl.drawLineEx(
                start,
                end,
                c.GRID_THICKNESS,
                c.GRID_COLOR,
            );
        }
    }
};
