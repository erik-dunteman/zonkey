const std = @import("std");


const Interface: type = struct {
    // ptr is a pointer to the implementation
    // here we use the *anyopaque pointer type, which erases type info
    // we recast it to the proper type in the implementation
    ptr: *anyopaque,

    // vtable holds function (method) implementations
    vtable: *const VTable,

    // the VTable type expects certain function signatures
    // we use *anyopaque instead of self
    pub const VTable = struct {
        print: *const fn (ctx: *anyopaque) void,
        printTwice: *const fn (ctx: *anyopaque) void,
    };

    // implement calling via VTable lookup for each method
    fn print(self: Interface) void {
        return self.vtable.print(self.ptr);
    }

    fn printTwice(self: Interface) void {
        self.vtable.printTwice(self.ptr);
        return;
    }
};

// Type that implements interface
const Impl: type = struct {
    someValue: u8 = 0,

    // match interface methods print and printTwice
    // use ctx: *anyopaque instead of self, then cast to *Impl type
    pub fn print(ctx: *anyopaque) void {
        const self: *Impl = @ptrCast(@alignCast(ctx));
        _ = self;
        std.debug.print("\nHello from impl\n", .{});
    }

    pub fn printTwice(ctx: *anyopaque) void {
        const self: *Impl = @ptrCast(@alignCast(ctx));
        _ = self;
        std.debug.print("\n1 Hello from impl\n", .{});
        std.debug.print("2 Hello from impl\n", .{});
    }
};

test "interface2" {
    var impl = Impl{};

    var vtable = Interface.VTable{ .print = &Impl.print, .printTwice = &Impl.printTwice };

    const iFace = Interface{ .ptr = &impl, .vtable = &vtable };
    iFace.print();
}
