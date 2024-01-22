const token = @import("token/token.zig");
const repl = @import("repl/repl.zig");

pub fn main() !void {
    repl.Start();
}
