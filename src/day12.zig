const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const Connections = struct {
    conns: [7]u8,
    connCount: u8
};

const StartChar: u8 = 62;
const EndChar: u8 = 63;

fn getIndexFromChar(str: []const u8) u8
{
    if(std.mem.eql(u8, str, "start"))
        return StartChar
    else if(std.mem.eql(u8, str, "end"))
        return EndChar;
    const c: u8 = str[0];
    if(c >= 'a' and c <= 'z')
        return c - 'a';

    return c - 'A' + 32;
}

fn addConnection(con: *Connections, toIndex: u8) void
{
    var i:u8 = 0;
    while(i < con.connCount) :(i += 1)
    {
        if(con.conns[i] == toIndex)
            return;
    }
    if(con.connCount >= 7)
    {
        print("Failed to add connection, too many connections: {} \n", .{con.connCount});
        return;
    }
    con.conns[con.connCount] = @intCast(u6, toIndex);
    con.connCount += 1;
}

pub fn day12(_: *std.mem.Allocator, comptime inputFile: []const u8, printVals: bool) anyerror!void
{
    var conns = std.mem.zeroes([256]Connections);
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        while (lines.next()) |line|
        {
            var sidesIter = std.mem.tokenize(u8, line, "-");
            const left = sidesIter.next().?;
            const right = sidesIter.next().?;
            const lVal: u8 = getIndexFromChar(left);
            const rVal: u8 = getIndexFromChar(right);
            if(rVal != StartChar)
                addConnection(&conns[lVal], rVal);
            if(lVal != StartChar)
                addConnection(&conns[rVal], lVal);
        }
    }
    var resultA: u32 = checkConnection(&conns, @as(u64, 0), StartChar, 1);
    var resultB: u32 = checkConnection(&conns, @as(u64, 0), StartChar, 2);
    if(printVals)
    {
        print("Day12-1: Routes: {}\n", .{resultA});
        print("Day12-2: Routes: {}\n", .{resultB});
    }
}

fn visits(visited: u64, index: u8) u32
{
    const ind1 = @intCast(u6, index & 31) * 2;
    const visitAmount = (visited >> ind1) & 3;
    return @intCast(u32, visitAmount);
}

fn getIndex(index: u8) u64
{
    const ind1 = @intCast(u6, index & 31) * 2;
    return @as(u64, 1) << ind1;
}

fn checkConnection(conns: []const Connections, visited: u64, index: u8, maxVisits: u32) u32
{
    if(index == EndChar)
        return 1;
    var isCave: u8 = if(index < 32) @as(u8, 1) else @as(u8, 0);

    const visitAmount = isCave * visits(visited, index);
    if(visitAmount >= maxVisits)
        return 0;

    const newMaxVisit = maxVisits - visitAmount;

    const newVisited = visited + getIndex(index) * isCave;
    var paths: u32 = 0;
    var i:u8 = 0;

    while(i < conns[index].connCount) : (i += 1)
    {
        const count = checkConnection(conns, newVisited, conns[index].conns[i], newMaxVisit);
        paths += count;
    }

    return paths;
}