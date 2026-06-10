const game_mod = @import("game.zig");
const c = @import("const.zig");
pub fn main() !void {
    var game = game_mod.Game.Create(c.WINDOW_WIDTH, c.WINDOW_HEIGHT, c.WINDOW_TITLE);
    try game.Run();
}
