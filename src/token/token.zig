const std = @import("std");

pub const TokenType = enum {
    Illegal,
    EOF,

    // identifiers and literals
    IDENT,
    INT,

    // operators
    ASSIGN,
    PLUS,

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
};

pub const Token: type = struct {
    Type: TokenType,
    Literal: []u8,
};

pub fn print() void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
