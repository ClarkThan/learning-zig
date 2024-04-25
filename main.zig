const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const User = @import("modules/user.zig").User;

pub fn demo1() void {
    const user = User{
        .power = 9001,
        .name = "Goku",
    };

    print("{s}'s power is {d}\n", .{ user.name, user.power });
    print("{*}\n{*}\n", .{ &user, &user.name });
}

fn demo2() void {
    const a = [3:false]bool{ false, true, false };
    print("{any}\n", .{std.mem.asBytes(&a).*});
}

fn demo3() void {
    print("{any}\n", .{@TypeOf(.{ .year = 2024, .month = 4 })});
    print("{any}\n", .{@TypeOf(.{ 2024, 4 })});
}

fn demo4() void {
    const method = "GET";
    print("{any}\n", .{@TypeOf(std.mem.eql(u8, method, "GET"))});
    print("{any}\n", .{@TypeOf(std.ascii.eqlIgnoreCase(method, "get"))});
}

fn contains(ds: []const u32, needle: u32) bool {
    for (ds) |val| {
        if (val == needle) {
            return true;
        }
    }

    return false;
}

fn equal(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;

    for (a, b) |a_it, b_it| {
        if (a_it != b_it) {
            return false;
        }
    }
    return true;
}

fn ttl(minutes: u16, is_late: bool) []const u8 {
    switch (minutes) {
        0 => return "arrived",
        1, 2 => return "soon",
        3...10 => return "no more than 10 minutes", // [3, 10] 闭区间
        else => {
            if (!is_late) {
                return "sorry, it'll be a while";
            }
            return "never";
        },
    }
}

fn indexOf(ds: []const u32, needle: u32) ?usize {
    for (ds, 0..) |val, i| {
        if (val == needle) {
            return i;
        }
    }
    return null;
}

fn demo5() void {
    for (0..10) |i| { // [0, 10) 左闭右开
        print("{d}\n", .{i});
    }
}

fn countEscapeChars1(str: []const u8) usize {
    var i: usize = 0;
    var cnt: usize = 0;
    while (i < str.len) {
        if (str[i] == '\\') {
            cnt += 1;
            i += 2;
        } else {
            i += 1;
        }
    }
}

fn countEscapeChars2(str: []const u8) usize {
    var i: usize = 0;
    var cnt: usize = 0;
    while (i < str.len) : (i += 1) {
        if (str[i] == '\\') {
            cnt += 1;
            i += 1;
        }
    }
}

fn demo6() void {
    outer: for (1..10) |i| {
        for (i..10) |j| {
            if (i * j > (i + i + j + j)) continue :outer;
            print("{d} + {d} >= {d} * {d}\n", .{ i + i, j + j, i, j });
        }
    }
}

fn judgeLevel(n: u32) []const u8 {
    // const level = blk: {
    //     if (n >= 3) break :blk "gold";
    //     if (n == 1) break :blk "silver";
    //     break :blk "bronze";
    // };
    // return level;
    return blk: {
        if (n >= 3) break :blk "gold";
        if (n == 1) break :blk "silver";
        break :blk "bronze";
    };
}

fn demo7() void {
    print("level: {s}\n", .{judgeLevel(5)});
}

const Num = union {
    int: i64,
    float: f64,
    nan: void,
};

fn demo8() void {
    const n = Num{ .int = 23 };
    // const n1 = Num{ .nan = {}};
    print("{d}\n", .{n.int});
}

// const TS = enum { unix, datetime };
// const TimeStamp = union(TS) {
const TimeStamp = union(enum) {
    unix: i32,
    datetime: DateTime,

    const DateTime = struct {
        year: u16,
        month: u8,
        day: u8,
        hour: u8,
        minute: u8,
        second: u8,
    };

    fn seconds(self: TimeStamp) u16 {
        switch (self) {
            .datetime => |dt| return dt.second,
            .unix => |ts| {
                // const secs_since_midnight: i32 = @rem(ts, 86400);
                const secs_since_midnight: i32 = @mod(ts, 86400);
                return @intCast(@rem(secs_since_midnight, 60));
            },
        }
    }
};

fn demo9() void {
    const ts = TimeStamp{ .unix = 1693278411 };
    print("{d}\n", .{ts.seconds()});
}

fn demo10() void {
    var pseudo_uuid: [16]u8 = undefined;
    std.crypto.random.bytes(&pseudo_uuid);
    print("{any}\n", .{pseudo_uuid});
}

fn demo11() void {
    const home: ?[]const u8 = null;
    const h = home orelse return;
    print("home = {s}\n", .{h}); // 不会打印
}

fn action(status: u16) !void {
    switch (status) {
        1...399 => return,
        400 => return error.BadRequest,
        404 => return error.NotFound,
        431 => return error.BodyTooBig,
        500 => return error.ServerErr,
        501 => return error.BrokenPipe,
        502 => return error.ConnectionResetByPeer,
        else => return error.Unknown,
    }
}

// anytype!TYPE 并不等价于 !TYPE, anyerror 是全局错误集
fn demo12() void {
    action(431) catch |err| switch (err) {
        // 或者 error.BrokenPipe, error.ConnectionResetByPeer => {},
        error.BrokenPipe, error.ConnectionResetByPeer => return,
        error.BodyTooBig => print("too big", .{}),
        else => print("unknown", .{}),
    };
}

const Save = struct {
    lives: u8,
    level: u16,

    pub fn loadLast() !?Save {
        return null;
    }

    fn blank() Save {
        return .{
            .lives = 3,
            .level = 1,
        };
    }
};

fn demo13() void {
    const save = (try Save.loadLast()) orelse Save.blank();
    print("{any}\n", .{save});
}

fn getRandomCount() !u8 {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var random = std.rand.DefaultPrng.init(seed);
    return random.random().uintAtMost(u8, 5) + 5;
}

fn demo14() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const arr = try allocator.alloc(usize, try getRandomCount());
    // std.testing.expect(@TypeOf(arr) == []usize) catch unreachable;
    std.testing.expect(@TypeOf(arr) == []usize) catch {};
    defer allocator.free(arr);
    for (0..arr.len) |i| {
        arr[i] = i + 100;
    }
    print("{any}\n", .{arr});
}

fn toUpper(c: u8) u8 {
    return switch (c) {
        'A'...'Z' => c,
        'a'...'z' => c & 0b11011111,
        else => unreachable,
    };
}

fn toLower(c: u8) u8 {
    return switch (c) {
        'A'...'Z' => c | 0x20,
        'a'...'z' => c,
        else => unreachable,
    };
}

fn isUpperCase(c: u8) bool {
    return c & 0x20 == 0;
}

fn isLowerCase(c: u8) bool {
    return !isUpperCase(c);
}

fn demo15() void {
    print("{c}\n", .{toLower('M')});
    print("{c}\n", .{toUpper('m')});
    print("{}\n", .{isUpperCase('Z')});
    print("{}\n", .{isLowerCase('8')});
}

fn allocLower(allocator: std.mem.Allocator, str: []const u8) ![]const u8 {
    const dest = try allocator.alloc(u8, str.len);
    for (0..str.len) |i| {
        dest[i] = toLower(str[i]);
    }
    return dest;
}

fn demo16() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const dest = allocLower(allocator, "Hello") catch "";
    defer allocator.free(dest);
    try expect(std.mem.eql(u8, dest, "hello"));
    print("lower = {s}\n", .{dest});
}

fn demo17() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const u = try allocator.create(User);
    defer allocator.destroy(u);
    try expect(@TypeOf(u) == *User);
}

fn initUser(allocator: std.mem.Allocator, power: u64, name: []const u8) !*User {
    const user = try allocator.create(User);
    user.* = .{
        .power = power,
        .name = name,
    };
    return user;
}

fn demo18() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const user = try initUser(allocator, 23, "Air");
    print("{any}\n", .{user});
}

fn demo19() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const say = std.fmt.allocPrint(allocator, "Hi, {d} {s}", .{ 23, "Air" }) catch "";
    defer allocator.free(say);
    print("{s}\n", .{say});
}

fn demo20() !void {
    const name = "Leto";
    var buf: [128]u8 = undefined;
    const greeting = try std.fmt.bufPrint(&buf, "Hello {s}", .{name});
    print("{s}\n", .{greeting});
}

const IntList = struct {
    pos: usize = 0,
    items: []i64,
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) !Self {
        return .{
            .items = try allocator.alloc(i64, 4),
            .allocator = allocator,
        };
    }

    fn deinit(self: Self) void {
        self.allocator.free(self.items);
    }

    fn add(self: *Self, item: i64) !void {
        const len = self.items.len;
        if (self.pos == len) {
            var larger = try self.allocator.alloc(i64, len * 2);
            @memcpy(larger[0..len], self.items);
            self.allocator.free(self.items);
            self.items = larger;
        }
        self.items[self.pos] = item;
        self.pos += 1;
    }
};

fn demo21() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = try IntList.init(allocator);
    defer list.deinit();
    for (0..5) |i| {
        try list.add(@intCast(i + 100));
    }
    print("{d} {d} {any}\n", .{ list.pos, list.items.len, list.items[0..list.pos] });
}

fn demo22() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var arr1 = try allocator.alloc(u8, 16);
    var user = try allocator.create(User);
    print("{*}\n{*}\n", .{ &arr1, &user });
}

fn demo23() !void {
    var buf: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    defer fba.reset();

    const allocator = fba.allocator();
    const json = try std.json.stringifyAlloc(allocator, .{
        .position = "Shooting Guard",
        .number = 23,
        .is_goat = true,
        .old_numbers = [_]i8{ 9, 12, 45 },
    }, .{}); //, .{ .whitespace = .indent_2 });
    defer allocator.free(json);
    print("{s}\n", .{json});
}

fn demo24() !void {
    const out = std.io.getStdOut();
    try std.json.stringify(.{
        .position = "Shooting Guard",
        .number = 23,
        .is_goat = true,
        .old_numbers = [_]i8{ 9, 12, 45 },
    }, .{}, out.writer());
}

pub fn main() !void {
    // demo16();
    try demo24();
    // return error.AccessDenied;
}
