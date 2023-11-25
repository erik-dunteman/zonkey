const std = @import("std");

pub const TokenType = enum {
    ILLEGAL,
    EOF,

    // identifiers and literals
    IDENT,
    INT,

    // operators
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    GT,
    EQ,
    NOT_EQ,

    // delimiters
    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    // keyword
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};

pub fn strCmp(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub fn lookupIdent(ident: []const u8) TokenType {
    const Keywords = struct {
        str: []const u8,
        token: TokenType,
    };

    const keywords = [_]Keywords{
        .{ .str = "fn", .token = TokenType.FUNCTION },
        .{ .str = "let", .token = TokenType.LET },
        .{ .str = "true", .token = TokenType.TRUE },
        .{ .str = "false", .token = TokenType.FALSE },
        .{ .str = "if", .token = TokenType.IF },
        .{ .str = "else", .token = TokenType.ELSE },
        .{ .str = "return", .token = TokenType.RETURN },
    };

    inline for (keywords) |kw| {
        if (strCmp(ident, kw.str)) {
            return kw.token;
        }
    }

    // Handle default case or unknown strings
    return TokenType.IDENT;
}

pub const Token: type = struct {
    type: TokenType = undefined,
    literal: []const u8 = undefined,
};

pub fn print() void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
