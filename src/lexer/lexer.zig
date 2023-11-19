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
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "five" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "ten" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "add" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.FUNCTION, .literal = "fn" },
        .{ .type = token.TokenType.LPAREN, .literal = "(" },
        .{ .type = token.TokenType.IDENT, .literal = "x" },
        .{ .type = token.TokenType.COMMA, .literal = "," },
        .{ .type = token.TokenType.IDENT, .literal = "y" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.IDENT, .literal = "x" },
        .{ .type = token.TokenType.PLUS, .literal = "+" },
        .{ .type = token.TokenType.IDENT, .literal = "y" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "result" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.IDENT, .literal = "add" },
        .{ .type = token.TokenType.LPAREN, .literal = "(" },
        .{ .type = token.TokenType.IDENT, .literal = "five" },
        .{ .type = token.TokenType.COMMA, .literal = "," },
        .{ .type = token.TokenType.IDENT, .literal = "ten" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
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

        var tok_len: usize = undefined;
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
            else => |c| {
                if (isLetter(c)) {
                    tok = token.Token{};
                    const lit = self.readIdentifier();
                    tok.literal = lit;
                    tok_len = lit.len;
                    return tok;
                } else {
                    tok = token.Token{ .type = token.TokenType.ILLEGAL };
                    return tok;
                }
            },
        }

        self.position += tok_len;
        return tok;
    }

    fn isLetter(ch: u8) bool {
        return (('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_');
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        var starting_position = self.position;

        while (isLetter(self.input[self.position])) {
            self.position += 1;
        }

        return self.input[starting_position..self.position];
    }
};

fn New(input: []const u8) Lexer {
    return .{
        .input = input,
    };
}
