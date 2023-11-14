const token = @import("../token/token.zig");
const std = @import("std");
const str = std.fmt.allocPrint;

const Lexer: type = struct {
    input: []u8,
    position: u8 = 0,
    readPosition: u8 = 0,
    ch: u8 = 0,
    alloc: std.mem.Allocator,

    fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn NextToken(self: *Lexer) !token.Token {
        var tok: token.Token = undefined;

        switch (self.ch) {
            '=' => {
                const literal = try str(self.alloc, "=", .{});
                tok = newToken(token.TokenType.ASSIGN, literal);
            },
            ';' => {
                const literal = try str(self.alloc, ";", .{});
                tok = newToken(token.TokenType.SEMICOLON, literal);
            },
            '(' => {
                const literal = try str(self.alloc, "()", .{});
                tok = newToken(token.TokenType.LPAREN, literal);
            },
            ')' => {
                const literal = try str(self.alloc, ")", .{});
                tok = newToken(token.TokenType.RPAREN, literal);
            },
            ',' => {
                const literal = try str(self.alloc, ",", .{});
                tok = newToken(token.TokenType.COMMA, literal);
            },
            '+' => {
                const literal = try str(self.alloc, "+", .{});
                tok = newToken(token.TokenType.PLUS, literal);
            },
            '{' => {
                const literal = try str(self.alloc, "{", .{});
                tok = newToken(token.TokenType.LBRACE, literal);
            },
            '}' => {
                const literal = try str(self.alloc, "}", .{});
                tok = newToken(token.TokenType.RBRACE, literal);
            },
            0 => {
                // ?
                tok = newToken(token.TokenType.EOF, literal);
            },
            else => unreachable,
        }

        return tok;
    }

    fn newToken(tokenType: token.TokenType, literal: []u8) token.Token {
        return token.Token{ .Type = tokenType, .Literal = literal };
    }
};

fn New(input: []const u8) *Lexer {
    const alloc = std.heap.page_allocator;
    var lex = Lexer{ .input = input, .alloc = alloc };
    lex.readChar();
    return &lex;
}

test "NextToken" {
    const input: []const u8 = "=+(){},;";
    const alloc = std.heap.page_allocator;

    const expected = [_]struct {
        Type: token.TokenType,
        Literal: []u8,
    }{
        .{
            .Type = token.TokenType.ASSIGN,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.PLUS,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.LPAREN,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.RPAREN,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.LBRACE,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.RBRACE,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.COMMA,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.SEMICOLON,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
        .{
            .Type = token.TokenType.EOF,
            .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
        },
    };

    const lex = New(input);

    for (expected, 0..) |expect, i| {
        _ = i;
        const tok = lex.NextToken();

        try std.testing.expectEqual(tok.Type, expect.Type);
        try std.testing.expectEqual(tok.Literal, expect.Literal);
    }
}
