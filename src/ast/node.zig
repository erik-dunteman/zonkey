const Statement = @import("statement.zig").Statement;
const Expression = @import("expression.zig").Expression;

const Node = union(enum) {
    // Node can be either statement or expression
    statement: Statement,
    expression: Expression,

    // Thanks to 'inline else', we can think of this tokenLiteral() as
    // being an interface method.
    pub fn tokenLiteral(self: Node) void {
        switch (self) {
            inline else => |case| return case.tokenLiteral(),
        }
    }
};

test "testBoth" {
    var node = Node{ .statement = Statement{} };
    node.tokenLiteral();
    node = Node{ .expression = Expression{} };
    node.tokenLiteral();
}
