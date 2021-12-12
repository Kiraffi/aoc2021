const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

// helper for building connections.
const Connections = struct {
    conns: [8]u8,
};

const StartChar: u8 = 62;
const EndChar: u8 = 63;

// for prefix sum connections.
var connCounts: [64]u8 = undefined;
var connStartIndex: [64]u8 = undefined;
var allConns: [64]u8 = undefined;

var connections: [64]Connections = undefined;


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

fn addConnection(fromIndex: u8, toIndex: u8) void
{
    var connCount: u8 = connCounts[fromIndex];
    var con: *Connections = &connections[fromIndex];
    var i:u8 = 0;
    while(i < connCount) :(i += 1)
    {
        if(con.conns[i] == toIndex)
            return;
    }
    if(connCount >= 8)
    {
        print("Failed to add connection, too many connections: {} at index: {} \n", .{connCount, fromIndex});
        return;
    }
    con.conns[connCount] = @intCast(u6, toIndex);
    connCounts[fromIndex] += 1;
}

pub fn day12(_: *std.mem.Allocator, comptime inputFile: []const u8, printVals: bool) anyerror!void
{
    connections = std.mem.zeroes([64]Connections);
    connStartIndex = std.mem.zeroes([64]u8);
    connCounts = std.mem.zeroes([64]u8);
    allConns = std.mem.zeroes([64]u8);
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
                addConnection(lVal, rVal);
            if(lVal != StartChar)
                addConnection(rVal, lVal);
        }
    }
    {
        var i: u32 = 0;
        var ind: u8 = 0;
        while(i < 64) : (i += 1)
        {
            connStartIndex[i] = ind;
            var j: u32 = 0;
            while(j < connCounts[i]) : (j += 1)
            {
                allConns[ind + j] = connections[i].conns[j];
            }
            ind += connCounts[i];
        }
    }
    var resultA: u32 = checkConnection(@as(u64, 0), StartChar, 1);
    var resultB: u32 = checkConnection(@as(u64, 0), StartChar, 2);

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

fn checkConnection(visited: u64, index: u8, maxVisits: u8) u32
{
    if(index == EndChar)
        return 1;
    var isCave: bool = (index < 32);
    var caveMultiplier: u8 = if(isCave) 1 else 0;

    const visitAmount = visits(visited, index) * caveMultiplier;
    if(visitAmount >= maxVisits)
        return 0;

    const newMaxVisit = maxVisits - @intCast(u8, visitAmount);
    const newVisited = visited + getIndex(index) * caveMultiplier;

    var paths: u32 = 0;
    var i:u8 = connStartIndex[index];
    const connCount = i + connCounts[index];
    while(i < connCount) : (i += 1)
    {
        const count = checkConnection(newVisited, allConns[i], newMaxVisit);
        paths += count;
    }
    return paths;
}