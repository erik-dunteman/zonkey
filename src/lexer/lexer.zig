const token = @import("../token/token.zig");
const std = @import("std");

const Lexer: type = struct {
    input: []const u8,
    position: u8 = 0,
    readPosition: u8 = 0,
    ch: u8 = 0,

    fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn NextToken(self: *Lexer) token.Token {
        var tok: token.Token = undefined;

        switch (self.ch) {
            '=' => {
                const literal = [_]u8{self.ch};
                tok = newToken(token.TokenType.ASSIGN, &literal);
            },
            ';' => {
                tok = newToken(token.TokenType.SEMICOLON, [_]u8{self.ch});
            },
            '(' => {
                tok = newToken(token.TokenType.LPAREN, [_]u8{self.ch});
            },
            ')' => {
                tok = newToken(token.TokenType.RPAREN, [_]u8{self.ch});
            },
            ',' => {
                tok = newToken(token.TokenType.COMMA, [_]u8{self.ch});
            },
            '+' => {
                tok = newToken(token.TokenType.PLUS, [_]u8{self.ch});
            },
            '{' => {
                tok = newToken(token.TokenType.LBRACE, [_]u8{self.ch});
            },
            '}' => {
                tok = newToken(token.TokenType.RBRACE, [_]u8{self.ch});
            },
            0 => {
                tok = newToken(token.TokenType.EOF, 0);
            },
            else => unreachable,
        }

        return tok;
    }

    fn newToken(tokenType: token.TokenType, ch: *const []u8) token.Token {
        return token.Token{ .Type = tokenType, .Literal = ch };
    }
};

fn New(input: []const u8) *Lexer {
    var lex = Lexer{ .input = input };
    lex.readChar();
    return &lex;
}

test "NextToken" {
    const input: []const u8 = "=+(){},;";

    const expected = [_]struct {
        Type: token.TokenType,
        Literal: []const u8,
    }{
        .{
            .Type = token.TokenType.ASSIGN,
            .Literal = "=",
        },
        .{
            .Type = token.TokenType.PLUS,
            .Literal = "+",
        },
        .{
            .Type = token.TokenType.LPAREN,
            .Literal = "(",
        },
        .{
            .Type = token.TokenType.RPAREN,
            .Literal = ")",
        },
        .{
            .Type = token.TokenType.LBRACE,
            .Literal = "{",
        },
        .{
            .Type = token.TokenType.RBRACE,
            .Literal = "}",
        },
        .{
            .Type = token.TokenType.COMMA,
            .Literal = ",",
        },
        .{
            .Type = token.TokenType.SEMICOLON,
            .Literal = ";",
        },
        .{
            .Type = token.TokenType.EOF,
            .Literal = "",
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
