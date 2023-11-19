const token = @import("../token/token.zig");
const std = @import("std");
const str = std.fmt.allocPrint;
const print = std.debug.print;

test "NextToken" {
    print("\n", .{});
    defer {
        print("\n", .{});
    }

    const input: []const u8 =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
    ;

    const expected = [_]token.Token{
        .{ .token = token.tokenType.LET, .literal = "let" },
        .{ .token = token.tokenType.IDENT, .literal = "five" },
        .{ .token = token.tokenType.ASSIGN, .literal = "=" },
        .{ .token = token.tokenType.INT, .literal = "5" },
        .{ .token = token.tokenType.SEMICOLON, .literal = ";" },
        .{ .token = token.tokenType.LET, .literal = "let" },
        .{ .token = token.tokenType.IDENT, .literal = "ten" },
        .{ .token = token.tokenType.ASSIGN, .literal = "=" },
        .{ .token = token.tokenType.INT, .literal = "10" },
        .{ .token = token.tokenType.SEMICOLON, .literal = ";" },
        .{ .token = token.tokenType.LET, .literal = "let" },
        .{ .token = token.tokenType.IDENT, .literal = "add" },
        .{ .token = token.tokenType.ASSIGN, .literal = "=" },
        .{ .token = token.tokenType.FUNCTION, .literal = "fn" },
        .{ .token = token.tokenType.LPAREN, .literal = "(" },
        .{ .token = token.tokenType.IDENT, .literal = "x" },
        .{ .token = token.tokenType.COMMA, .literal = "," },
        .{ .token = token.tokenType.IDENT, .literal = "y" },
        .{ .token = token.tokenType.RPAREN, .literal = ")" },
        .{ .token = token.tokenType.LBRACE, .literal = "{" },
        .{ .token = token.tokenType.IDENT, .literal = "x" },
        .{ .token = token.tokenType.PLUS, .literal = "+" },
        .{ .token = token.tokenType.IDENT, .literal = "y" },
        .{ .token = token.tokenType.SEMICOLON, .literal = ";" },
        .{ .token = token.tokenType.RBRACE, .literal = "}" },
        .{ .token = token.tokenType.SEMICOLON, .literal = ";" },
        .{ .token = token.tokenType.LET, .literal = "let" },
        .{ .token = token.tokenType.IDENT, .literal = "result" },
        .{ .token = token.tokenType.ASSIGN, .literal = "=" },
        .{ .token = token.tokenType.IDENT, .literal = "add" },
        .{ .token = token.tokenType.LPAREN, .literal = "(" },
        .{ .token = token.tokenType.IDENT, .literal = "five" },
        .{ .token = token.tokenType.COMMA, .literal = "," },
        .{ .token = token.tokenType.IDENT, .literal = "ten" },
        .{ .token = token.tokenType.RPAREN, .literal = ")" },
        .{ .token = token.tokenType.SEMICOLON, .literal = ";" },
    };

    var lex = New(input);
    var i: u8 = 0;
    while (lex.nextToken()) |tok| : (i += 1) {
        const expected_tok = expected[i];
        try std.testing.expectEqual(tok.type, expected_tok.type);
        try std.testing.expectEqual(tok.literal[0], expected_tok.literal[0]);
    }
}

const Lexer = struct {
    input: []const u8, // input buffer
    position: usize = 0,

    fn nextToken(self: *Lexer) ?token.Token {
        if (self.position >= self.input.len) {
            return null;
        }

        const ch = self.input[self.position];

        var tok_len: u8 = undefined;
        var tok: token.Token = undefined;

        // switch on ch
        switch (ch) {
            '=' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.ASSIGN, .literal = self.input[self.position .. self.position + tok_len] };
            },

            ';' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.SEMICOLON, .literal = self.input[self.position .. self.position + tok_len] };
            },
            '(' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.LPAREN, .literal = self.input[self.position .. self.position + tok_len] };
            },
            ')' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.RPAREN, .literal = self.input[self.position .. self.position + tok_len] };
            },
            ',' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.COMMA, .literal = self.input[self.position .. self.position + tok_len] };
            },
            '+' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.PLUS, .literal = self.input[self.position .. self.position + tok_len] };
            },
            '{' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.LBRACE, .literal = self.input[self.position .. self.position + tok_len] };
            },
            '}' => {
                tok_len = 1;
                tok = token.Token{ .type = token.TokenType.RBRACE, .literal = self.input[self.position .. self.position + tok_len] };
            },
            0 => {
                return null;
            },
            else => unreachable,
        }

        self.position += tok_len;
        return tok;
    }
};

fn New(input: []const u8) Lexer {
    return .{
        .input = input,
    };
}
