const std = @import("std");

pub const Statement = @This();

pub fn tokenLiteral(self: Statement) void {
    _ = self;
    std.debug.print("Nice Statement\n", .{});
}

test "test" {
    const statement = Statement{};
    statement.tokenLiteral();
}
