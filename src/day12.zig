const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const Connections = struct {
    conns: [6]u8,
    index: u8,
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

pub fn day12(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{
    // cos of allocator
    var autoScores = std.ArrayList(u64).init(alloc);
    defer autoScores.deinit();

    var conns = std.mem.zeroes([256]Connections);
    {
        var i:u32 = 0;
        while(i < 256) : (i += 1)
        {
            conns[i]. index = @intCast(u8, i);
        }
    }
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
    var resultA: u32 = 0;
    var resultB: u32 = 0;
    if(true)
    {
        var t1: u32 = 0;
        var t2: u32 = 0;
        resultA = checkConnection(&conns, &t1, StartChar, 1);
        resultB = checkConnection(&conns, &t2, StartChar, 2);
    }
    else
    {
        var ones: [16]u8 = undefined;
        resultA = checkConnection1(&conns, StartChar, fillOnes(&ones), 0);
        resultB = checkConnection2(&conns, StartChar, fillOnes(&ones), 0);
    }
    print("Day12-1: Routes: {}\n", .{resultA});
    print("Day12-2: Routes: {}\n", .{resultB});
}

fn fillOnes(ones: []u8) []u8
{
    var i: u32 = 0;
    while(i < ones.len) : (i += 1)
        ones[i] = 255;
    return ones;
}

fn addConnection(con: *Connections, toIndex: u8) void
{
    var i:u8 = 0;
    while(i < con.connCount) :(i += 1)
    {
        if(con.conns[i] == toIndex)
            return;
    }
    if(con.connCount >= 6)
    {
        print("Failed to add connection, too many from: {} to: {} \n", .{con.index, toIndex});
        return;
    }
    con.conns[con.connCount] = toIndex;
    con.connCount += 1;
}

fn visits(visited: *u32, index: u8) u32
{
    const ind1 = @intCast(u5, index);
    const visitAmount = (visited.* >> ind1) & 1;
    return visitAmount;
}

fn setVisited(visited: *u32, index: u8) void
{
    const ind1 = @intCast(u5, index);
    visited.* |= (@as(u32, 1) << ind1);
}

fn removeVisited(visited: *u32, index: u8) void
{
    const ind1 = @intCast(u5, index);
    visited.* -= (@as(u32, 1) << ind1);
}

fn checkExisting(index: u8, visitTable: []const u8, depth: u32) bool
{
    var i:u32 = 0;
    while(i < depth) : (i += 1)
    {
        if(visitTable[i] == index)
            return true;
    }
    return false;
}

fn checkConnection1(conns: []const Connections, index: u8, visitTable: []u8, depth: u32) u32
{
    if(index == EndChar)
        return 1;

    var depthAdd: u32 = 0;
    const isCave = index < 32;
    if(isCave)
    {
        visitTable[depth] = index;
        depthAdd = 1;
        if (checkExisting(index, visitTable, depth))
            return 0;
    }

    var i:u8 = 0;
    var paths: u32 = 0;
    while(i < conns[index].connCount) : (i += 1)
    {
        const count = checkConnection1(conns, conns[index].conns[i], visitTable, depth + depthAdd);
        paths += count;
    }
    return paths;
}


fn checkConnection2(conns: []const Connections, index: u8, visitTable: []u8, depth: u32) u32
{
    if(index == EndChar)
        return 1;

    var useConn1 = false;
    var depthAdd: u32 = 0;
    const isCave = index < 32;

    if(isCave)
    {
        visitTable[depth] = index;
        useConn1 = checkExisting(index, visitTable, depth);
        depthAdd = 1;
    }

    var i:u8 = 0;
    var paths: u32 = 0;

    if(useConn1)
    {
        while(i < conns[index].connCount) : (i += 1)
        {
            const count = checkConnection1(conns, conns[index].conns[i], visitTable, depth + depthAdd);
            paths += count;
        }
    }
    else
    {
        while(i < conns[index].connCount) : (i += 1)
        {
            const count = checkConnection2(conns, conns[index].conns[i], visitTable, depth + depthAdd);
            paths += count;
        }
    }
    return paths;
}



fn checkConnection(conns: []const Connections, visited: *u32, index: u8, maxVisits: u32) u32
{
    if(index == EndChar)
        return 1;
    const isCave = index < 32;
    const visitAmount = if(isCave) visits(visited, index) else @as(u32, 0);
    if(visitAmount >= maxVisits)
        return 0;

    const newMaxVisit = maxVisits - visitAmount;
    const addAndRemoveVisit = visitAmount == 0 and isCave;
    if(addAndRemoveVisit)
        setVisited(visited, index);
    var paths: u32 = 0;
    var i:u8 = 0;

    while(i < conns[index].connCount) : (i += 1)
    {
        const count = checkConnection(conns, visited, conns[index].conns[i], newMaxVisit);
        paths += count;
    }

    if(addAndRemoveVisit)
        removeVisited(visited, index);

    return paths;
}