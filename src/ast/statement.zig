const std = @import("std");

pub const Statement = @This();

pub fn print(self: Statement) void {
    _ = self;
    std.debug.print("Nice Statement\n", .{});
}

test "test" {
    const expr = Statement{};
    expr.print();
}
