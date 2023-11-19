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
        print("{s}\t{}\n", .{ tok.literal, tok.type });
        const expected_tok = expected[i];
        try std.testing.expectEqual(
            expected_tok.type,
            tok.type,
        );
        try std.testing.expectEqual(
            expected_tok.literal[0],
            tok.literal[0],
        );
    }
}

const Lexer = struct {
    input: []const u8, // input buffer
    position: usize = 0,

    fn nextToken(self: *Lexer) ?token.Token {
        // handle end of file case
        if (self.position >= self.input.len) {
            return null;
        }

        // read character at position
        var ch: u8 = self.input[self.position];

        // it could be whitespace, if so keep reading and advancing position
        while (isWhitespace(ch)) {
            self.position += 1;
            ch = self.input[self.position];
        }

        var tok: token.Token = undefined;
        var token_len: usize = undefined;

        // switch on the character
        // and determine which token it represents
        switch (ch) {
            '=' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.ASSIGN, .literal = self.input[self.position .. self.position + token_len] };
            },
            ';' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.SEMICOLON, .literal = self.input[self.position .. self.position + token_len] };
            },
            '(' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.LPAREN, .literal = self.input[self.position .. self.position + token_len] };
            },
            ')' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.RPAREN, .literal = self.input[self.position .. self.position + token_len] };
            },
            ',' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.COMMA, .literal = self.input[self.position .. self.position + token_len] };
            },
            '+' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.PLUS, .literal = self.input[self.position .. self.position + token_len] };
            },
            '{' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.LBRACE, .literal = self.input[self.position .. self.position + token_len] };
            },
            '}' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.RBRACE, .literal = self.input[self.position .. self.position + token_len] };
            },
            0 => {
                return null;
            },

            // handle identifiers and multi-character tokens
            else => |c| {
                if (isLetter(c)) {
                    // could be a langauge keyword, or a user's variable name
                    const lit = self.readIdentifier();
                    tok = token.Token{
                        .type = token.lookupIdent(lit),
                        .literal = lit,
                    };
                    token_len = lit.len;
                    return tok;
                } else if (isDigit(c)) {
                    // could be a multi-digit number
                    const lit = self.readNumber();
                    tok = token.Token{
                        .type = token.TokenType.INT,
                        .literal = lit,
                    };
                    token_len = lit.len;
                    return tok;
                } else {
                    // final default case. If we haven't identified the token by now, it's illegal
                    tok = token.Token{ .type = token.TokenType.ILLEGAL };
                    return tok;
                }
            },
        }

        self.position += token_len;
        return tok;
    }

    fn isLetter(ch: u8) bool {
        return (('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_');
    }

    fn isDigit(ch: u8) bool {
        return ('0' <= ch and ch <= '9');
    }

    fn isWhitespace(ch: u8) bool {
        return (ch == ' ' or ch == ' ' or ch == '\n' or ch == '\t' or ch == '\r');
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        var starting_position = self.position;

        while (isLetter(self.input[self.position])) {
            self.position += 1;
        }

        return self.input[starting_position..self.position];
    }

    fn readNumber(self: *Lexer) []const u8 {
        var starting_position = self.position;

        while (isDigit(self.input[self.position])) {
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
