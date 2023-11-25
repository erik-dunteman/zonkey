const token = @import("../token/token.zig");
const lexer = @import("../lexer/lexer.zig");
const std = @import("std");
const print = std.debug.print;

test "repl" {
    print("\n", .{});
    defer {
        print("\n", .{});
    }
    Start();
}

fn Start() void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());
    var r = buf.reader();
    var msg_buf: [4096]u8 = undefined;

    while (true) {
        print(">> ", .{});
        var msg = r.readUntilDelimiterOrEof(&msg_buf, '\n') catch {
            // ignore errors, because yolo
            return;
        };

        if (msg) |m| {
            var lex = lexer.New(m);
            while (lex.nextToken()) |tok| {
                if (tok.type == token.TokenType.ILLEGAL) {
                    print("Illegal token", .{});
                    break;
                }
                print("{s}\t{}\n", .{ tok.literal, tok.type });
            }
        } else {
            break;
        }
    }
}
