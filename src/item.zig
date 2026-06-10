const rl = @import("raylib");
const std = @import("std");
const c = @import("const.zig");
const grid_mod = @import("grid.zig");

var rand = std.Random.DefaultPrng.init(93457493);
fn randomNum() f32 {
    return @as(f32, @floatFromInt(@abs(rand.random().int(i32))));
}
pub const Item = struct {
    Pos: rl.Vector2,

    pub fn ReSpawn(self: *Item, grid: grid_mod.Grid, reservedPositions: []rl.Vector2, size: i32) void {
        var pos: rl.Vector2 = undefined;
        var exist = true;
        while (exist) {
            const x = @rem(randomNum(), grid.width()) + grid.Pos.x;
            const y = @rem(randomNum(), grid.height()) + grid.Pos.y;
            pos = rl.Vector2{
                .x = x,
                .y = y,
            };
            pos = grid.GetGridPos(pos);
            exist = false;
            for (0..@intCast(size)) |i| {
                if (self.Pos.equals(reservedPositions[i])) {
                    exist = true;
                    break;
                }
            }
            self.Pos = pos;
        }
    }
    pub fn Draw(self: Item) void {
        const pos = self.Pos.add(rl.Vector2{
            .x = 10,
            .y = 10,
        });
        const size = rl.Vector2{
            .x = c.CELL_SIZE - 20,
            .y = c.CELL_SIZE - 20,
        };
        rl.drawRectangleV(pos, size, rl.Color.red);
    }
};
