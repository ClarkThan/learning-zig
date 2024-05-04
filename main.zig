const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const assert = std.debug.assert;
const testing = std.testing;
const User = @import("models/user.zig").User;
const arith = @import("arith");
// const calc = @import("calc");

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
    const c = '💯';
    print("type: {}\n", .{@TypeOf(c)});
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
    // std.heap.page_allocator;
    // std.heap.c_allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            expect(false) catch @panic("TEST FAIL");
        }
    }
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
    var buf: [4]u8 = undefined;
    // error: NoSpaceLeft
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

test "IntList: add" {
    var lst = try IntList.init(testing.allocator);
    defer lst.deinit();
    for (0..5) |i| {
        try lst.add(@intCast(i + 10));
    }
    try testing.expectEqual(@as(usize, 5), lst.pos);
    try testing.expectEqual(@as(i64, 10), lst.items[0]);
    try testing.expectEqual(@as(i64, 11), lst.items[1]);
    try testing.expectEqual(@as(i64, 12), lst.items[2]);
    try testing.expectEqual(@as(i64, 14), lst.items[4]);
}

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

fn List(comptime T: type) type {
    return struct {
        pos: usize = 0,
        items: []T,
        allocator: std.mem.Allocator,

        const Self = @This();

        fn init(allocator: std.mem.Allocator) !Self {
            return .{
                .items = try allocator.alloc(T, 4),
                .allocator = allocator,
            };
        }

        fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        fn add(self: *Self, value: T) !void {
            const len = self.items.len;
            if (self.pos == len) {
                var larger = try self.allocator.alloc(T, 2 * len);
                @memcpy(larger[0..len], self.items);
                self.allocator.free(self.items);
                self.items = larger;
            }
            self.items[self.pos] = value;
            self.pos += 1;
        }
    };
}

fn demo25() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = try List(u32).init(allocator);
    defer list.deinit();
    for (0..10) |i| {
        try list.add(@intCast(i + 100));
    }
    print("{d} {d} {any}\n", .{ list.pos, list.items.len, list.items[9] });
}

fn demo26() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var map = std.StringHashMap(User).init(allocator);
    defer map.deinit();

    const goku = User{ .name = "Goku", .power = 9001 };
    const hola = User{ .name = "Hola", .power = 9002 };
    try map.put(goku.name, goku);
    try map.put(hola.name, hola);

    var map_iter = map.iterator();
    while (map_iter.next()) |it| {
        const v = it.value_ptr;
        print("{s} -> {d}\n", .{ v.name, v.power });
    }

    var val_iter = map.valueIterator();
    while (val_iter.next()) |v| {
        print("{s} --> {d}\n", .{ v.name, v.power });
    }

    print("goku: {*}\nhola: {*}\n", .{ &goku.name, &hola.name });
    const entry = map.getPtr("Goku");
    if (entry) |user| {
        print("got[{*}]: {s}  {d}\n", .{ &user.name, user.name, user.power });
        if (map.remove(user.name)) {
            print("delete goku successful\n", .{});
            // user 指针失效
            // print("got: {s}  {d}\n", .{ user.name, user.power });
        }
    }

    const entry1 = map.get("Hola"); // copy
    if (entry1) |user| {
        print("got[{*}]: {s}  {d}\n", .{ &user.name, user.name, user.power });
        if (map.remove(user.name)) {
            print("delete hola successful\n", .{});
            print("got: {s}  {d}\n", .{ user.name, user.power });
        }
    }
}

fn demo27() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();
    try std.json.stringify(.{ .name = "Air", .number = 23 }, .{}, buf.writer());
    print("{s}\n", .{buf.items});
}

const Logger = struct {
    level: Level,
    const Level = enum {
        debug,
        info,
        warn,
        @"error",
        fatal,
    };

    fn info(logger: Logger, msg: []const u8, out: anytype) !void {
        if (@intFromEnum(logger.level) <= @intFromEnum(Level.info)) {
            try out.writeAll(msg);
        }
    }
};

fn demo28() !void {
    var l = Logger{ .level = .info };
    const stdout = std.io.getStdOut();
    try l.info("server started\n", stdout);
    // try l.info("server started\n", true);
}

fn userFactory(data: anytype) User {
    const T = @TypeOf(data);
    return .{
        .name = if (@hasField(T, "name")) data.name else "",
        .power = if (@hasField(T, "power")) data.power else 0,
    };
}

fn demo29() !void {
    _ = userFactory(.{});
    _ = userFactory(.{ .name = "Air" });
    print("arith.calc(23, 45) = {d}\n", .{arith.add(23, 45)});
    // print("calc.calc(23, 45) = {d}\n", .{calc.add(23, 45)});
}

fn demo30() void {
    const m: u8 = 8;
    assert(m +| 255 == 255);
    assert(m -| 9 == 0);

    var n: u8 = 0;
    n -%= 1;
    assert(n == 255);
}

const DemoErr = error{
    Err1,
    Err2,
};

fn produce(n: i32) DemoErr!?i32 {
    if (n == 0) {
        return null;
    }
    if (n < -100) {
        return DemoErr.Err1;
    }
    if (n < -10) {
        return DemoErr.Err2;
    }
    return n + 100;
}

fn demo31() void {
    const ret = produce(-23);
    if (ret) |v| {
        if (v) |val| {
            print("got value: {d}\n", .{val});
        } else {
            print("got null\n", .{});
        }
    } else |err| {
        switch (err) {
            DemoErr.Err1 => print("got err1: {any}!\n", .{err}),
            DemoErr.Err2 => print("got err2: {any}!\n", .{err}),
            else => unreachable,
        }
    }
}

const MyEnum = enum(u5) {
    var cnt: u32 = 0;
    B,
    C,
};

fn demo32() void {
    const arr = [_]u8{ 'a', 'b', 'c' };
    for (arr, 0..) |_, idx| {
        print("index: {d}\n", .{idx});
    }
    // @setRuntimeSafety(false);
    // var index: usize = 5;
    // index += 1;
    // _ = arr[index];
    // print("{}\n", .{arr[index]});

    MyEnum.cnt += 10;
    print("{} {}\n", .{ MyEnum.cnt, @intFromEnum(MyEnum.B) });
    assert(MyEnum.cnt == @intFromEnum(MyEnum.B) + 10);
}

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'A'...'Z' => x,
        'a'...'z' => x + 'A' - 'a',
        else => unreachable,
    };
}

const Tag = union(enum) {
    a: u8,
    b: f32,
    c: bool,
    none,
};

fn demo33() void {
    var value = Tag{ .a = 23 };
    // var value = Tag{ .b = 1.5 };
    // var value = Tag{ .c = false };
    // var value = Tag{ .none = {} };
    switch (value) {
        .a => |*int| {
            int.* += 10;
            print("got int: {}\n", .{int.*});
        },
        .b => |*float| {
            float.* *= 2;
            print("got float: {}\n", .{float.*});
        },
        .c => |*bin| {
            bin.* = !bin.*;
            print("got bool: {}\n", .{bin.*});
        },
        else => {
            print("got none\n", .{});
        },
    }
    assert(value.a == 33);
}

fn demo34() void {
    const a: u8 = 23;
    const b: u32 = a;
    print("{d}\n", .{b});
    const c: u16 = b;
    print("{d}\n", .{c});

    // TODO 如何将一个超过u8范围的u64数字转换成u8类型
}

fn fibonacci(n: u64) u64 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

fn demo35() void {
    const ret = comptime fibonacci(44);
    // zig build-exe main.zig && time ./main
    print("fibonacci(44) = {d}\n", .{ret});
}

fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

test "returning a type" {
    try expect(Matrix(f32, 4, 4) == [4][4]f32);
    const x: usize = 3;
    const y: i7 = 3;
    try expect(Matrix(i32, x, y) == [3][3]i32);
}

fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16) a + b else @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

fn demo36() void {
    print("{d}\n", .{addSmallInts(u16, 2, 45)});
}

fn genBiggerInt(comptime T: type) type {
    return @Type(.{ .Int = .{
        .bits = @typeInfo(T).Int.bits + 1,
        .signedness = @typeInfo(T).Int.signedness,
    } });
}

test "@Type" {
    try expect(genBiggerInt(u8) == u9);
}

fn demo38() void {
    const str = "abcd";
    assert(@TypeOf(str) == *const [4:0]u8);
    const x = @as(*const [5]u8, @ptrCast(str));
    assert(x[4] == 0);
}

fn demo39() void {
    const c_str: [*:0]const u8 = "hello";
    var arr: [5]u8 = undefined;
    var i: usize = 0;
    while (c_str[i] != 0) : (i += 1) {
        arr[i] = c_str[i];
    }
    print("{s}\n", .{arr});
    print("{s}\n", .{&arr});
    print("{s}\n", .{arr[0..]});
}

fn demo40() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const parsed = try std.json.parseFromSlice(User, allocator,
        \\{"name":"Air","power":23}
    , .{});
    const user = parsed.value;
    try expect(std.mem.eql(u8, user.name, "Air"));
    print("parsed power: {d}\n", .{user.power});
    std.time.sleep(2 * std.time.ns_per_s);
}

const C = @cImport({
    @cInclude("stdio.h");
});

fn demo41() void {
    const char_cnt = C.printf("Hello %s\n", "Be" ** 3);
    print("{}\n", .{@TypeOf(char_cnt)});
    print("{d}\n", .{char_cnt});
}

fn demo42() !void {
    const ret = try std.ChildProcess.run(.{ .allocator = std.heap.c_allocator, .argv = &[_][]const u8{
        "zig",
        "version",
    } });
    print("{s}\n", .{ret.stdout});
}

pub fn main() !void {
    try demo29();
    // return error.AccessDenied;
    // std.io.BufferedWriter(comptime buffer_size: usize, comptime WriterType: type)
}

// type noreturn:
// unreachable, {},

// type void:
// none

// .? == orelse unreachable
// Optional pointer and optional slice types do not take up any extra memory compared to non-optional ones.
// This is because internally they use the 0 value of the pointer for null.
