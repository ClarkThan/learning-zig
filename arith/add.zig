pub fn add(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a + b;
}

const testing = @import("std").testing;

test "add" {
    const a: i32 = 1;
    const b: i32 = 2;
    const c: i32 = 3;

    try testing.expectEqual(a + b, add(a, b));
    try testing.expectEqual(a + c, add(a, c));
    try testing.expectEqual(@as(i32, 32), add(30, 2));
}
