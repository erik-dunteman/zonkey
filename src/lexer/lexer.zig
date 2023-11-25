const token = @import("../token/token.zig");
const std = @import("std");
const print = std.debug.print;

test "lexer" {
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
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\  return true;
        \\} else {
        \\  return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
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
        .{ .type = token.TokenType.BANG, .literal = "!" },
        .{ .type = token.TokenType.MINUS, .literal = "-" },
        .{ .type = token.TokenType.SLASH, .literal = "/" },
        .{ .type = token.TokenType.ASTERISK, .literal = "*" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.LT, .literal = "<" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.GT, .literal = ">" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.IF, .literal = "if" },
        .{ .type = token.TokenType.LPAREN, .literal = "(" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.LT, .literal = "<" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.RETURN, .literal = "return" },
        .{ .type = token.TokenType.TRUE, .literal = "true" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.ELSE, .literal = "else" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.RETURN, .literal = "return" },
        .{ .type = token.TokenType.FALSE, .literal = "false" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.EQ, .literal = "==" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.NOT_EQ, .literal = "!=" },
        .{ .type = token.TokenType.INT, .literal = "9" },
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

    fn peekChar(self: *Lexer) ?u8 {
        if (self.position + 1 >= self.input.len) {
            return null;
        }
        return self.input[self.position + 1];
    }

    pub fn nextToken(self: *Lexer) ?token.Token {
        // handle end of file case
        if (self.position >= self.input.len) {
            return null;
        }

        // read character at position
        var ch: u8 = self.input[self.position];

        // it could be whitespace, if so keep reading and advancing position
        while (isWhitespace(ch)) {
            self.position += 1;
            if (self.position >= self.input.len) {
                return null;
            }
            ch = self.input[self.position];
        }

        var tok: token.Token = undefined;
        var token_len: usize = undefined;

        // switch on the character
        // and determine which token it represents
        switch (ch) {
            ';' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.SEMICOLON, .literal = self.input[self.position .. self.position + token_len] };
            },
            '{' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.LBRACE, .literal = self.input[self.position .. self.position + token_len] };
            },
            '}' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.RBRACE, .literal = self.input[self.position .. self.position + token_len] };
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
            '=' => {
                // could be ==, so peek ahead for that
                if (self.peekChar()) |nextChar| {
                    if (nextChar == '=') {
                        token_len = 2;
                        tok = token.Token{ .type = token.TokenType.EQ, .literal = self.input[self.position .. self.position + token_len] };
                        self.position += token_len;
                        return tok;
                    }
                }
                // is a simple =
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.ASSIGN, .literal = self.input[self.position .. self.position + token_len] };
            },
            '+' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.PLUS, .literal = self.input[self.position .. self.position + token_len] };
            },
            '-' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.MINUS, .literal = self.input[self.position .. self.position + token_len] };
            },
            '*' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.ASTERISK, .literal = self.input[self.position .. self.position + token_len] };
            },
            '/' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.SLASH, .literal = self.input[self.position .. self.position + token_len] };
            },
            '!' => {
                // could be !=, so peek ahead for that
                if (self.peekChar()) |nextChar| {
                    if (nextChar == '=') {
                        token_len = 2;
                        tok = token.Token{ .type = token.TokenType.NOT_EQ, .literal = self.input[self.position .. self.position + token_len] };
                        self.position += token_len;
                        return tok;
                    }
                }
                // is a simple !
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.BANG, .literal = self.input[self.position .. self.position + token_len] };
            },
            '<' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.LT, .literal = self.input[self.position .. self.position + token_len] };
            },
            '>' => {
                token_len = 1;
                tok = token.Token{ .type = token.TokenType.GT, .literal = self.input[self.position .. self.position + token_len] };
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

pub fn New(input: []const u8) Lexer {
    return .{
        .input = input,
    };
}
