const std = @import("std");
const print = std.debug.print;

test "interfaces" {
    print("\n", .{});
    defer {
        print("\n", .{});
    }

    const impl = ImplExample{};
    const iface = InterfaceExample{ .impl = impl };
    iface.print();
}

const ImplExample: type = struct {
    pub fn print(self: ImplExample) void {
        _ = self;
        std.debug.print("What a banger impl\n", .{});
    }
};

const InterfaceExample = union(enum) {
    impl: ImplExample, // I want to make it so I don't need to explicitly declare the list of types that implement this

    // Thanks to 'inline else', we can think of this print() as
    // being an interface method.
    pub fn print(self: InterfaceExample) void {
        switch (self) {
            inline else => |case| return case.print(),
        }
    }
};
