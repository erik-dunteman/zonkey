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

// fn New(input: []u8) *Lexer {
//     const alloc = std.testing.allocator;
//     var lex = Lexer{ .input = input, .alloc = alloc };
//     lex.readChar();
//     print("lex: {}\n", .{lex});
//     return &lex;
// }

// const Lexer = struct {
//     input: []const u8, // input buffer
//     offset: usize,

//     fn nextToken(self: *Lexer) ?Token {
//         ...
//         return .{
//         .type = .Comma,
//         .literal = self.input[offset..offset + 1], // valid as long as input is valid
//         };

//         // hit end?
//         return null;
//     }
// };

// const Lexer: type = struct {
//     input: []u8,
//     position: u8 = 0,
//     readPosition: u8 = 0,
//     ch: u8 = 0,
//     alloc: std.mem.Allocator,

//     fn readChar(self: *Lexer) void {
//         print("pre readChar self {}\n", .{self});
//         if (self.readPosition >= self.input.len) {
//             self.ch = 0;
//         } else {
//             self.ch = self.input[self.readPosition];
//         }
//         self.position = self.readPosition;
//         self.readPosition += 1;
//         print("post readChar self {}\n", .{self});
//     }

//     fn NextToken(self: *Lexer) !token.Token {
//         var tok: token.Token = undefined;
//         print("next token self {}\n", .{self});
//         print("ch {}\n", .{self.ch});
//         switch (self.ch) {
//             '=' => {
//                 const literal = try str(self.alloc, "=", .{});
//                 tok = newToken(token.TokenType.ASSIGN, literal);
//             },
//             ';' => {
//                 const literal = try str(self.alloc, ";", .{});
//                 tok = newToken(token.TokenType.SEMICOLON, literal);
//             },
//             '(' => {
//                 const literal = try str(self.alloc, "(", .{});
//                 tok = newToken(token.TokenType.LPAREN, literal);
//             },
//             ')' => {
//                 const literal = try str(self.alloc, ")", .{});
//                 tok = newToken(token.TokenType.RPAREN, literal);
//             },
//             ',' => {
//                 const literal = try str(self.alloc, ",", .{});
//                 tok = newToken(token.TokenType.COMMA, literal);
//             },
//             '+' => {
//                 const literal = try str(self.alloc, "+", .{});
//                 tok = newToken(token.TokenType.PLUS, literal);
//             },
//             '{' => {
//                 const literal = try str(self.alloc, "{}", .{'{'});
//                 tok = newToken(token.TokenType.LBRACE, literal);
//             },
//             '}' => {
//                 const literal = try str(self.alloc, "{}", .{'}'});
//                 tok = newToken(token.TokenType.RBRACE, literal);
//             },
//             0 => {
//                 const literal = try str(self.alloc, "{}", .{0});
//                 tok = newToken(token.TokenType.EOF, literal);
//             },
//             else => unreachable,
//         }

//         self.readChar();
//         print("next token finish self {}\n", .{self});
//         return tok;
//     }

//     fn newToken(tokenType: token.TokenType, literal: []u8) token.Token {
//         return token.Token{ .Type = tokenType, .Literal = literal };
//     }
// };

// fn New(input: []u8) *Lexer {
//     const alloc = std.testing.allocator;
//     var lex = Lexer{ .input = input, .alloc = alloc };
//     lex.readChar();
//     print("lex: {}\n", .{lex});
//     return &lex;
// }

// test "NextToken" {
//     print("\n", .{});
//     // const input: []u8 = "=+(){},;";
//     const alloc = std.heap.page_allocator;
//     var input = try str(alloc, "{s}", .{"=+(){},;"});

//     print("input {s}\n", .{input});
//     for (input) |char| {
//         print("{}\n", .{char});
//     }

//     // some sanity checks I'm doing the strings correctly
//     try std.testing.expectEqual(input[0], '=');
//     try std.testing.expectEqual(input[1], '+');

//     const expected = [_]struct {
//         Type: token.TokenType,
//         Literal: []u8,
//     }{
//         .{
//             .Type = token.TokenType.ASSIGN,
//             .Literal = try std.fmt.allocPrint(alloc, "=", .{}),
//         },
//         .{
//             .Type = token.TokenType.PLUS,
//             .Literal = try std.fmt.allocPrint(alloc, "+", .{}),
//         },
//         .{
//             .Type = token.TokenType.LPAREN,
//             .Literal = try std.fmt.allocPrint(alloc, "(", .{}),
//         },
//         .{
//             .Type = token.TokenType.RPAREN,
//             .Literal = try std.fmt.allocPrint(alloc, ")", .{}),
//         },
//         .{
//             .Type = token.TokenType.LBRACE,
//             .Literal = try std.fmt.allocPrint(alloc, "{}", .{'{'}),
//         },
//         .{
//             .Type = token.TokenType.RBRACE,
//             .Literal = try std.fmt.allocPrint(alloc, "{}", .{'}'}),
//         },
//         .{
//             .Type = token.TokenType.COMMA,
//             .Literal = try std.fmt.allocPrint(alloc, ",", .{}),
//         },
//         .{
//             .Type = token.TokenType.SEMICOLON,
//             .Literal = try std.fmt.allocPrint(alloc, ";", .{}),
//         },
//         .{
//             .Type = token.TokenType.EOF,
//             .Literal = try std.fmt.allocPrint(alloc, "{}", .{0}),
//         },
//     };

//     const lex = New(input);
//     print("lex: {}\n", .{lex});

//     for (expected, 0..) |expect, i| {
//         print("\n\nexpect: {}\n", .{expect});
//         _ = i;
//         print("loop lex {}\n", .{lex});
//         const tok = try lex.NextToken();
//         print("tok: {}\n", .{tok});

//         // try std.testing.expectEqual(tok.Type, expect.Type);
//         // try std.testing.expectEqual(tok.Literal.len, expect.Literal.len);
//         // print("type match\n", .{});
//         // print("tok.Literal {s} {s} expect.Literal {s} {s}\n", .{ tok.Literal, tok.Literal, expect.Literal, expect.Literal });
//         // for (tok.Literal, 0..) |tok_lit, j| {
//         //     try std.testing.expectEqual(tok_lit, expect.Literal[j]);
//         // }
//     }
// }
