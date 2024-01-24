const std = @import("std");

pub const Expression = @This();

pub fn tokenLiteral(self: Expression) void {
    _ = self;
    std.debug.print("Nice Expression\n", .{});
}

test "test" {
    const expr = Expression{};
    expr.tokenLiteral();
}
