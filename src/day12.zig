const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

// helper for building connections.
const Connections = struct {
    conns: [16]u32,
};

const StartChar: u8 = 30;
const EndChar: u8 = 31;

var connections: [32]Connections = undefined;

// for prefix sum connections.
var connCounts: [32]u8 = undefined;
var connStartIndex: [32]u8 = undefined;
var allConns: [64]u32 = undefined;

var minimumPaths: [128]u32 = undefined;
var minimumPathStartindex: [32]u8 = undefined;
var minimumPathCounts: [32]u8 = undefined;

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
    if(connCount >= 16)
    {
        print("Failed to add connection, too many connections: {} at index: {} \n", .{connCount, fromIndex});
        return;
    }
    con.conns[connCount] = @intCast(u6, toIndex);
    connCounts[fromIndex] += 1;
}

fn getIndexFromChar(remapTable: [][2]u8, str: []const u8) u8
{
    if(std.mem.eql(u8, str, "start"))
        return StartChar
    else if(std.mem.eql(u8, str, "end"))
        return EndChar
    else if(str.len != 2)
        return 0;
    var result: u8 = 0;
    var i: u8 = if(str[0] >= 'a' and str[0] <= 'z') 0 else 16;
    while(i < 32) : (i += 1)
    {
        const cmpTable: []const u8 = &remapTable[i];
        if(std.mem.eql(u8, cmpTable, str))
        {
            return i;
        }
        else if(std.mem.eql(u8, cmpTable, &std.mem.zeroes([2]u8)))
        {
            //print("Remapped: {s} to {}\n", .{str, i});
            std.mem.copy(u8, &remapTable[i], str);
            return i;
        }
    }
    return result;
}

pub fn day12(_: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{
    connections = std.mem.zeroes([32]Connections);
    connStartIndex = std.mem.zeroes([32]u8);
    connCounts = std.mem.zeroes([32]u8);
    allConns = std.mem.zeroes([64]u32);

    {
        var remapTable = std.mem.zeroes([32][2]u8);




        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        while (lines.next()) |line|
        {
            var sidesIter = std.mem.tokenize(u8, line, "-");
            const left = sidesIter.next().?;
            const right = sidesIter.next().?;
            const lVal: u8 = getIndexFromChar(&remapTable, left);
            const rVal: u8 = getIndexFromChar(&remapTable, right);
            if(rVal != StartChar)
                addConnection(lVal, rVal);
            if(lVal != StartChar)
                addConnection(rVal, lVal);
            //print("l: {}, r: {}\n", .{lVal, rVal});
        }
        //print("rr\n", .{});
    }
    {
        // Find things like ab-CD ef-CD connections and remove the big rooms,
        // so that we can simply multiply the permutations.

        // so go through all caves from big rooms and check if the caves
        // connected to big rooms connect with each other.
//        var i: u32 = 16;
//        while(i < StartChar) : (i += 1)
//        {
//            var j: u32 = 0;
//            while(j < connCounts[i]) : (j += 1)
//            {
//                const connLeft = connections[i].conns[j] & 31;
//                if(connLeft >= 16)
//                    continue;
//
//                var k: u32 = j + 1;
//                while(k < connCounts[i]) : (k += 1)
//                {
//                    if(j == k)
//                        continue;
//
//                    const connRight = connections[i].conns[k] & 31;
//                    if(connRight >= 16)
//                        continue;
//
//                    var l: u32 = 0;
//                    while(l < connCounts[connLeft]) : (l += 1)
//                    {
//                        if(connections[connLeft].conns[l]  & 31 != connRight)
//                            continue;
//
//                        connections[connLeft].conns[l] += @as(u32, 1) << @intCast(u5, 5);
//                        //print("connection merged: {} to {} through: {}\n", .{connLeft, connRight, i});
//                    }
//                    l = 0;
//                    while(l < connCounts[connRight]) : (l += 1)
//                    {
//                        if(connections[connRight].conns[l] & 31 != connLeft)
//                            continue;
//
//                        connections[connRight].conns[l] += @as(u32, 1) << @intCast(u5, 5);
//                        //print("connection merged: {} to {} through: {}\n", .{connRight, connLeft, i});
//                    }
//
//                }
//            }
//        }




//        // need to add connection to self in order to merge big rooms.
//        i  = 16;
//        while(i < StartChar) : (i += 1)
//        {
//            var j: u32 = 0;
//            while(j < connCounts[i]) : (j += 1)
//            {
//                const connLeft = connections[i].conns[j] & 31;
//
//                if(connLeft >= 16)
//                    continue;
//
//                var foundSelf = false;
//                var k: u32 = 0;
//                while(k < connCounts[connLeft]) : (k += 1)
//                {
//                    if(connections[connLeft].conns[k] & 31 != connLeft)
//                        continue;
//
//                    //print("incrementing self pointing {} from: {}\n", .{connLeft, i});
//                    connections[connLeft].conns[k] += @as(u32, 1) << @intCast(u5, 5);
//                    foundSelf = true;
//                    break;
//                }
//                if(!foundSelf)
//                {
//                    connections[connLeft].conns[connCounts[connLeft]] = connLeft;
//                    connCounts[connLeft] += 1;
//                    //print("i: {} conns: {} from {} \n", .{connLeft, connCounts[connLeft], i});
//                }
//            }
//        }
//





        // also merge all the rooms connected to big room, that is connected to start.
        {
            var j:u32 = 0;
            while(j < connCounts[StartChar]) : (j+=1)
            {
                const connLeft = connections[StartChar].conns[j] & 31;

                // add connections to every room from big room if its connected to start.

                if(connLeft <= 16)
                    continue;

                var k: u32 = 0;
                while(k < connCounts[connLeft]) : (k += 1)
                {
                    const connRight = connections[connLeft].conns[k];
                    if(connRight == StartChar)
                        continue;
                    // check if already added.
                    var l: u32 = 0;
                    var found = false;
                    //print("adding to start: {}\n", .{connRight});
                    while(l < connCounts[StartChar]) : (l += 1)
                    {
                        if(connections[StartChar].conns[l] & 31 != connRight)
                            continue;

                        //print("incrementing start i: {} start conns: {} \n", .{connRight, connCounts[StartChar]});
                        connections[StartChar].conns[l] += @as(u32, 1) << @intCast(u5, 5);
                        found = true;
                        break;
                    }

                    if(!found)
                    {
                        //print("i: {} start conns: {} \n", .{connRight, connCounts[StartChar]});
                        connections[StartChar].conns[connCounts[StartChar]] = connRight;
                        connCounts[StartChar] += 1;

                    }
                }
            }
       }





    }
    {
        // Do prefix sum of connections, and
        // lay connections in array struct to increase
        // cache locality
        var i: u32 = 0;
        var ind: u8 = 0;
        while(i < 32) : (i += 1)
        {
            connStartIndex[i] = ind;
            var j: u32 = 0;
            while(j < connCounts[i]) : (j += 1)
            {
                var c: u32 = connections[i].conns[j];
                const index = c & 31;
                //if(!(index == EndChar or index < 16))
                if(i == StartChar and index >= 16)
                    continue;
                if(index < 16)
                    c |= @as(u32, 1) << @intCast(u5, 8 + index);
                allConns[ind] = c;
                ind += 1;

                //const multiplier = ((c >> 5) & 7) + 1;

                //print("connection: {} -> {}, multi: {}\n", .{i, c & 31, multiplier});
            }
            connCounts[i] = ind - connStartIndex[i];
        }



        // Build min needed paths
        {
            std.mem.set(u32, &minimumPaths, 0xffff_ffff);
            var sumOfPaths: u8 = 0;
            i = 0;
            while(i < 32) : (i += 1)
            {
                minimumPathStartindex[i] = sumOfPaths;
                minimumPathCounts[i] = 0;
                if(connCounts[i] == 0)
                    continue;
                var pathCount: u32 = 0;
                pathCount = buildMinimumPaths(EndChar, i, 0, minimumPaths[sumOfPaths..], pathCount);

                minimumPathCounts[i] = @intCast(u8, pathCount);
                sumOfPaths += minimumPathCounts[i];
                //print("ind: {}, start: {}, count: {}\n", .{i, minimumPathStartindex[i], minimumPathCounts[i]});
            }

            //i = 0;
            //while(i < 32) : (i += 1)
            //{
            //    var j: u32 = 0;
            //    print("ind: {}, valid paths cnt: {}\n", .{i, minimumPathCounts[i]});
            //    while(j < minimumPathCounts[i]) : (j += 1)
            //    {
            //        print("   Path: {}: ", .{j});
            //        const sInd = minimumPathStartindex[i];
            //        var k: u5 = 0;
            //        while(k < 16) : (k += 1)
            //        {
            //            if((minimumPaths[sInd + j] >> k) & 1 != 0)
            //            {
            //                print("{}, ", .{k} );
            //            }
            //        }
            //        print("\n", .{});
            //    }
            //}
        }
        //var nii = otherConns;

        //print("new conns: {}, {}\n",.{newInd, nii[0]});
    }
    var resultA = checkConnection(@as(u32, 0), StartChar, 1);
    var resultB = checkConnection(@as(u32, 0), StartChar, 2);

    //print("maximum remove: {}, total visits: {} \n", .{maxVisit, globalVisit});

    const res = try std.fmt.bufPrint(printBuffer, "Day12-1: Routes: {}\n", .{resultA.paths});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day12-2: Routes: {}\n", .{resultB.paths});
    return res.len + res2.len;
}

fn buildMinimumPaths(index: u32, searchIndex: u32, visited: u32, paths: []u32, pathAmount: u32) u32
{
    const ind = @as(u32, 1) << @intCast(u5, index & 31);
    if(visited & ind != 0)
        return pathAmount;
    var newPathAmount = pathAmount;

    if(index & 31 == searchIndex)
    {
        var newPath: u32 = visited & 0xffff;
        var i:u32 = 1;
        // avoid overflow when removing
        while(i <= newPathAmount) : (i += 1)
        {
            const p = paths[i - 1];
            const newPandP = newPath & p;
            // if smaller or equal already exists,
            // dont do anything
            if(newPandP == p)
            {
                //  print("found better: {}, new: {}, old: {}\n",.{i, newPath, p});
                return newPathAmount;
            }
            // if the path doesnt have less but still has
            // atleast same bits set, it must have more,
            // so remove it from the list.
            else if(newPandP == newPath)
            {
                //print("swapping: {} to {}\n",.{i - 1, newPathAmount - 1});
                paths[i - 1] = paths[newPathAmount - 1];
                newPathAmount -= 1;
                i -= 1;
            }
        }
        //print("adding: {}\n", .{newPath});
        paths[newPathAmount] = newPath;
        newPathAmount += 1;
        return newPathAmount;
    }

    var i:u8 = connStartIndex[index & 31];
    const connCount = i + connCounts[index & 31];

    const newVisited = visited | ind;

    while(i < connCount) : (i += 1)
    {
        if(allConns[i] & 31 == StartChar)
            continue;

        newPathAmount = buildMinimumPaths(allConns[i] & 31, searchIndex, newVisited, paths, newPathAmount);
    }
    return newPathAmount;
}


var globalVisit: u64 = 0;
//var maxVisit: u64 = 0;

const Pep = struct
{
    paths: u32,
    //visits: u64
};

fn checkConnection(visited: u32, index: u32, maxVisits: u8) Pep
{
    var pep = Pep {.paths = 0 };
    if(index == EndChar)
    {
        pep.paths = 1;
        return pep;
    }
    const ind = (index & 15);
    const ind1 = @intCast(u5, ind);

    const thisVisited = (index >> 8);
    const newVisited = visited | thisVisited;

    const visitAmount = (((thisVisited & visited) >> ind1) & 3);
    if(visitAmount >= maxVisits)
        return pep;

    const newMaxVisit = maxVisits - @intCast(u8, visitAmount);
        if((index & 31) < 16)
    {
        var i: u32 = minimumPathStartindex[index & 31];
        const loopEnd: u32 = minimumPathCounts[index & 31] + i;
        var canExit = false;
        while(i < loopEnd) : (i += 1)
        {
            const miniCheck = newVisited & minimumPaths[i];
            if(@popCount(u32, miniCheck) < newMaxVisit)
            {
                canExit = true;
                break;
            }
        }
        if(!canExit)
        {
            return pep;
        }
    }

    var i:u8 = connStartIndex[index & 31];
    const connCount = i + connCounts[index & 31];
    while(i < connCount) : (i += 1)
    {
        if(allConns[i] == StartChar)
            continue;

        const newPep = checkConnection(newVisited, allConns[i], newMaxVisit);
        pep.paths += newPep.paths;
        //if(pep.paths == 0)
        //    pep.visits += newPep.visits;
    }
//    if(pep.paths == 0)
//    {
//        pep.visits = globalVisit - startVisit;
//    }
//    else
//    {
//        if(pep.visits > 10)
//        maxVisit += pep.visits;
//        //print("pep visits: {}\n", .{pep.visits});
//        pep.visits = 0;
//    }
    const multiplier = ((index >> 5) & 7) + 1;
    pep.paths *= multiplier;
    return pep;
}

