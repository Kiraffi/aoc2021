const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

pub fn day2(alloc: *std.mem.Allocator, comptime inputFile : []const u8) anyerror!void
{
    //const inputFile : []u8 = try std.fs.cwd().readFileAlloc(alloc, "input_day2.txt", std.math.maxInt(usize) );
    //defer alloc.free(file_string);

    var nums = std.ArrayList(i32).init(alloc);
    defer nums.deinit();

    var lines = std.mem.tokenize(u8, inputFile, "\r\n");

    var forward: i32 = 0;
    // depth becomes aim for 2-2
    var depth: i32 = 0;
    var depthFromAim: i32 = 0;
    while (lines.next()) |line|
    {
        var line_iter = std.mem.tokenize(u8, line, " ");
        const movementDir = line_iter.next().?;
        const number_iter = line_iter.next().?;
        const num:i32 = @intCast(i32, number_iter[0] - '0');
        if(std.mem.eql(u8, movementDir, "forward"))
        {
            forward += num;
            depthFromAim += depth * num;
        }
        if(std.mem.eql(u8, movementDir, "down"))
        {
            depth += num;
        }
        if(std.mem.eql(u8, movementDir, "up"))
        {
            depth -= num;
        }
    }
    print("day2-1: forward:{d}, depth:{d}, mul:{d}\n", .{forward, depth, forward * depth});
    print("day2-2: forward:{d}, depth:{d}, mul:{d}\n", .{forward, depthFromAim, forward * depthFromAim});
}
