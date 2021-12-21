const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


const Coord = struct
{
    x: i32,
    y: i32,
    z: i32,
    length: i32,

};

const SimilarGeom = struct
{
    scannerId: u32,
    lineId1: u32,
    lineId2: u32,

    diff: Coord,

};

const Pair = struct
{
    first: usize,
    second: usize,
};

var scannerNumber: u32 = 0;
var scanners: [30][1024]Coord = undefined;
var knownLocs: [30]u32 = undefined;


pub fn day19(alloc: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{

    var similarGeoms = std.ArrayList(SimilarGeom).init(alloc);
    defer similarGeoms.deinit();

    var matches = std.ArrayList(Pair).init(alloc);
    defer matches.deinit();

    // Parse lines to strings....
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        while(lines.next()) |line|
        {
            if(line[0] == '-' and line[1] == '-')
            {
                var header = std.mem.tokenize(u8, line, " ");
                _ = header.next().?;
                _ = header.next().?;
                scannerNumber = try std.fmt.parseInt(u32, header.next().?, 10);
                knownLocs[scannerNumber] = 0;
            }
            else if(line.len > 1)
            {
                var numbers = std.mem.tokenize(u8, line, ",");
                var x = try std.fmt.parseInt(i32, numbers.next().?, 10);
                var y = try std.fmt.parseInt(i32, numbers.next().?, 10);
                var z = try std.fmt.parseInt(i32, numbers.next().?, 10);
                var length = x*x + y*y + z*z;
                scanners[scannerNumber][knownLocs[scannerNumber]] = Coord{ .x = x, .y = y, .z = z, .length = length };
                knownLocs[scannerNumber] += 1;
                //print("scanner: {}:{} {},{},{}\n", .{scannerNumber, knownLocs[scannerNumber], x, y, z});
            }
        }
        scannerNumber += 1;
    }

    {
        try findLineSegments(&similarGeoms);

        // Check if the line segments are same dimensions
        for(similarGeoms.items) |item1, ind1|
        {
            for(similarGeoms.items) |item2, ind2|
            {
                if(ind1 >= ind2 or item1.scannerId == item2.scannerId or item1.diff.length != item2.diff.length)
                    continue;

                var d1: [3]i64 = .{item1.diff.x, item1.diff.y, item1.diff.z};
                var d2: [3]i64 = .{item2.diff.x, item2.diff.y, item2.diff.z};

                var i: u32 = 0;
                outer: while(i < 3) : (i += 1)
                {
                    if(d1[i] != d2[0])
                        continue;
                    var j: u32 = 0;
                    while(j < 3) : (j += 1)
                    {
                        if(i == j or d1[j] != d2[1])
                            continue;
                        var k: u32 = 0;
                        while(k < 3) : (k += 1)
                        {
                            if(i == k or j == k or d1[k] != d2[2])
                                continue;

                            try matches.append(Pair{.first = ind1, .second = ind2});
                            break :outer;

                        }
                    }
                }
            }
        }
    }
    var positions = std.mem.zeroes([32]Coord);
    {
        var transforms: [30][30]ScoreTransform = std.mem.zeroes([30][30]ScoreTransform);
        var mergeTable = std.mem.zeroes([32]u32);

        // Go through all the matched line segments, and count matching beacons with different
        // rotations.
        for(matches.items) |match|
        {
            const g1 = similarGeoms.items[match.first];
            const g2 = similarGeoms.items[match.second];

            if(((mergeTable[g1.scannerId]) & (@as(u32, 1) << @intCast(u5, g2.scannerId))) != 0)
                continue;

            var bestMatch: ScoreTransform = undefined;
            bestMatch.score = 0;
            var bestMatchIndex: u32 = 0;
            var rotation: u32 = 0;
            while(rotation < 24) : (rotation += 1)
            {
                const newMatch = calculateMatches(g1, g2, rotation);
                if(newMatch.score > bestMatch.score)
                {
                    bestMatch = newMatch;
                    bestMatchIndex = rotation;
                }
            }
            // lets guess 6 is enough match amount
            if(bestMatch.score >= 6)
            {
                // Fix the position to take count that we might be using non-zero beacon.
                // Write down the transforms between each group.
                const pos = getLocationAFromB(Coord {.x = 0, .y = 0, .z = 0, .length = 0 }, bestMatch);
                positions[g1.scannerId] = pos;

                mergeTable[g1.scannerId] |= @as(u32, 1) << @intCast(u5, g2.scannerId);
                mergeTable[g2.scannerId] |= @as(u32, 1) << @intCast(u5, g1.scannerId);

                if(transforms[g1.scannerId][g2.scannerId].score < bestMatch.score)
                    transforms[g1.scannerId][g2.scannerId] = bestMatch;
                if(transforms[g2.scannerId][g1.scannerId].score < bestMatch.score)
                    transforms[g2.scannerId][g1.scannerId] = bestMatch;
            }
        }
        // merge all beacons
        {
            var j: u32 = scannerNumber - 1;
            while(j > 0) : (j -= 1)
            {
                var i: u5 = @intCast(u5, scannerNumber - 1);
                while(mergeTable[j - 1] != 0 )
                {
                    while((mergeTable[j - 1] >> i) & 1 == 0)
                    {
                        i -= 1;
                    }

                    var smaller:u32 = @minimum(i, j - 1);
                    var bigger:u32 = @maximum(i, j - 1);
                    _ = mergeLists(smaller, bigger, transforms[smaller][bigger]);

                    mergeTable[j - 1] &= ~(@as(u32, 1) << (@intCast(u5, i)));
                }
            }
        }
    }
    // Part A:
    var resultA: u64 = knownLocs[0];

    var resultB: u64 = 0;
    {
        var biggestDistance: i32 = 0;
        var j: u32 = 0;
        while(j < scannerNumber) : (j += 1)

        {
            var i: u32 = 0;
            while(i < scannerNumber) : (i += 1)
            {
                var diff = dec(positions[i], positions[j]);
                diff.x = if(diff.x < 0) -diff.x else diff.x;
                diff.y = if(diff.y < 0) -diff.y else diff.y;
                diff.z = if(diff.z < 0) -diff.z else diff.z;
                biggestDistance = @maximum(diff.x + diff.y + diff.z, biggestDistance);
            }
        }
        resultB = @intCast(u64, biggestDistance);
    }



    const res =try std.fmt.bufPrint(printBuffer, "Day 19-1: Beacons: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day 19-2: Biggest manhattan distance: {}\n", .{resultB});
    return res.len + res2.len;
}

// there is probably something smarter here
fn mergeLists(aInd: u32, bInd: u32, bestMatch: ScoreTransform) u32
{
    var addedA: u32 = 0;
    var addedB: u32 = 0;

//    //if(aInd < bInd)
    {
        var i: u32 = 0;
        while(i < knownLocs[aInd]) : (i += 1)
        {
            const pA = scanners[aInd][i];
            const pointA = getLocationBFromA(pA, bestMatch);

            var foundB = false;
            var j: u32 = 0;
            while(j < knownLocs[bInd]) : (j += 1)
            {
                const pB = scanners[bInd][j];

                if(equals(pB, pointA))
                {
                    foundB = true;
                    break;
                }
            }


            if(!foundB)
            {
                scanners[bInd][knownLocs[bInd]] = pointA;
                knownLocs[bInd] += 1;
                addedB += 1;
            }
        }
    }
//    //else
    {
        var i: u32  = 0;
        while(i < knownLocs[bInd]) : (i += 1)
        {
            const pB = scanners[bInd][i];
            const pointB = getLocationAFromB(pB, bestMatch);

            var foundA = false;
            var j: u32 = 0;
            while(j < knownLocs[aInd]) : (j += 1)
            {
                const pA = scanners[aInd][j];

                if(equals(pA, pointB))
                {
                    foundA = true;
                    break;
                }
            }
            if(!foundA)
            {
                scanners[aInd][knownLocs[aInd]] = pointB;
                knownLocs[aInd] += 1;
                addedA += 1;
            }
        }
    }
    return addedA + addedB;
}


const ScoreTransform = struct
{
    origOffset: Coord, //offset before rotation
    rotatedOffset: Coord, // offset after rotation
    rotation: u32,
    score: u32,
};

// Notice from
fn getLocationAFromB(b: Coord, trans: ScoreTransform) Coord
{
    const movement = dec(b, trans.origOffset);
    // rotate it
    const rotatedPoint = rotate(movement, trans.rotation, false);

    // move it to overlap offset
    const overLappedPoint = add(rotatedPoint, trans.rotatedOffset);
    return overLappedPoint;
}
fn printPoint(a: Coord) void
{
    print("P: {}, {}, {}\n", .{a.x, a.y, a.z});
}

fn getLocationBFromA(a: Coord, trans: ScoreTransform) Coord
{
    const movement = dec(a, trans.rotatedOffset);
    // rotate it
    const rotatedPoint = rotate(movement, trans.rotation, true);
    // move it to overlap offset
    const overLappedPoint = add(rotatedPoint, trans.origOffset);
    //printPoint(overLappedPoint);
    //print("\n", .{});
    return overLappedPoint;
}

fn calculateMatches(g1: SimilarGeom, g2: SimilarGeom, rotation: u32) ScoreTransform
{
    const p1 = scanners[g1.scannerId][g1.lineId1];
    const p2 = scanners[g1.scannerId][g1.lineId2];

    const p3 = scanners[g2.scannerId][g2.lineId1];
    const p4 = scanners[g2.scannerId][g2.lineId2];

    const line = rotate(dec(p3, p4), rotation, false);


    const p1p2diff = dec(p1, p2);
    const p2p1diff = dec(p2, p1);

    var offset: Coord = undefined;

    // Find which rotation seems to match.
    if(equals(p1p2diff, line))
    {
        offset = p1;
    }
    else if(equals(p2p1diff, line))
    {
        offset = p2;
    }
    else
    {
        var empty: ScoreTransform = undefined;
        empty.score = 0;
        return empty;
    }

    var trans = ScoreTransform{.origOffset = p3, .rotatedOffset = offset, .rotation = rotation, .score = 1 };
    var i: u32 = 0;
    while(i < knownLocs[g1.scannerId]) : (i += 1)
    {
        const point = scanners[g1.scannerId][i];
        var j: u32 = 0;
        while(j < knownLocs[g2.scannerId]) : (j += 1)
        {
            const checkPoint = scanners[g2.scannerId][j];
            const point2 = getLocationAFromB(checkPoint, trans);

            if(equals(point, point2))
            {
                trans.score += 1;
                break;
            }
        }
    }
    return trans;
}

fn add(a: Coord, b:Coord) Coord
{
    return Coord{.x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z, .length = 0 };
}
fn dec(a: Coord, b: Coord) Coord
{
    return Coord {.x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z, .length = 0 };
}
fn equals(a: Coord, b: Coord) bool
{
    return a.x == b.x and a.y == b.y and a.z == b.z;
}

const invertRotatationTable: [24]u32 = .{
     0,  1,  3,  2,
     4,  5,  6,  7,

    12,  9, 18, 23,
     8, 13, 19, 22,

    21, 17, 10, 14,
    20, 16, 15, 11,
};

fn rotate(a: Coord, rotation: u32, inverse: bool) Coord
{
    const rot = if(inverse) invertRotatationTable[rotation % 24] else rotation % 24;
    var r = a;

    //if(true)
    {
        switch(rot)
        {
            0 => { r.x =  a.x; r.y =  a.y; r.z =  a.z; },
            1 => { r.x = -a.x; r.y = -a.y; r.z =  a.z; },
            2 => { r.x = -a.y; r.y =  a.x; r.z =  a.z; },
            3 => { r.x =  a.y; r.y = -a.x; r.z =  a.z; },

            4 => { r.x = -a.x; r.y =  a.y; r.z = -a.z; },
            5 => { r.x =  a.x; r.y = -a.y; r.z = -a.z; },
            6 => { r.x =  a.y; r.y =  a.x; r.z = -a.z; },
            7 => { r.x = -a.y; r.y = -a.x; r.z = -a.z; },

            8  => { r.x = -a.z; r.y =  a.y; r.z =  a.x; },
            9  => { r.x =  a.z; r.y = -a.y; r.z =  a.x; },
            10 => { r.x =  a.y; r.y =  a.z; r.z =  a.x; },
            11 => { r.x = -a.y; r.y = -a.z; r.z =  a.x; },

            12 => { r.x =  a.z; r.y =  a.y; r.z = -a.x; },
            13 => { r.x = -a.z; r.y = -a.y; r.z = -a.x; },
            14 => { r.x = -a.y; r.y =  a.z; r.z = -a.x; },
            15 => { r.x =  a.y; r.y = -a.z; r.z = -a.x; },

            16 => { r.x =  a.x; r.y = -a.z; r.z =  a.y; },
            17 => { r.x = -a.x; r.y =  a.z; r.z =  a.y; },
            18 => { r.x =  a.z; r.y =  a.x; r.z =  a.y; },
            19 => { r.x = -a.z; r.y = -a.x; r.z =  a.y; },

            20 => { r.x = -a.x; r.y = -a.z; r.z = -a.y; },
            21 => { r.x =  a.x; r.y =  a.z; r.z = -a.y; },
            22 => { r.x = -a.z; r.y =  a.x; r.z = -a.y; },
            23 => { r.x =  a.z; r.y = -a.x; r.z = -a.y; },
            else => {}
        }
    }
//    else
//    {
//        switch(rotation)
//        {
//            0  => { r.x =  a.x; r.y =  a.y; r.z = a.z; },
//            1  => { r.x = -a.x; r.y = -a.y; r.z = a.z; },
//            2  => { r.x =  a.y; r.y = -a.x; r.z = a.z; },
//            3  => { r.x = -a.y; r.y =  a.x; r.z = a.z; },
//
//            4  => { r.x = -a.x; r.y =  a.y; r.z = -a.z; },
//            5  => { r.x =  a.x; r.y = -a.y; r.z = -a.z; },
//            6  => { r.x =  a.y; r.y =  a.x; r.z = -a.z; },
//            7  => { r.x = -a.y; r.y = -a.x; r.z = -a.z; },
//
//            8  => { r.x =  a.z; r.y =  a.y; r.z = -a.x; },
//            9  => { r.x =  a.z; r.y = -a.y; r.z =  a.x; },
//            10 => { r.x =  a.z; r.y =  a.x; r.z =  a.y; },
//            11 => { r.x =  a.z; r.y = -a.x; r.z = -a.y; },
//
//            12 => { r.x = -a.z; r.y =  a.y; r.z =  a.x; },
//            13 => { r.x = -a.z; r.y = -a.y; r.z = -a.x; },
//            14 => { r.x = -a.z; r.y = -a.x; r.z =  a.y; },
//            15 => { r.x = -a.z; r.y =  a.x; r.z = -a.y; },
//
//            16 => { r.x =  a.x; r.y =  a.z; r.z = -a.y; },
//            17 => { r.x = -a.x; r.y =  a.z; r.z =  a.y; },
//            18 => { r.x =  a.y; r.y =  a.z; r.z =  a.x; },
//            19 => { r.x = -a.y; r.y =  a.z; r.z = -a.x; },
//
//            20 => { r.x = -a.x; r.y = -a.z; r.z = -a.y; },
//            21 => { r.x =  a.x; r.y = -a.z; r.z =  a.y; },
//            22 => { r.x =  a.y; r.y = -a.z; r.z = -a.x; },
//            23 => { r.x = -a.y; r.y = -a.z; r.z =  a.x; },
//            else => {}
//        }
//
//    }
    return r;

}



fn findLineSegments(similarGeoms: *std.ArrayList(SimilarGeom)) anyerror!void
{
    var i: u32 = 0;
    while(i < scannerNumber) : (i += 1)
    {
        var j: u32 = 0;
        while(j < knownLocs[i]) : (j += 1)
        {
            var k = (j + 1);
            while(k < knownLocs[i]) : (k += 1)
            {
                const g1 = scanners[i][j];
                const g2 = scanners[i][k];

                var diff = dec(g1, g2);
                diff.length = diff.x * diff.x + diff.y * diff.y + diff.z * diff.z;

                diff.x = if(diff.x < 0) -diff.x else diff.x;
                diff.y = if(diff.y < 0) -diff.y else diff.y;
                diff.z = if(diff.z < 0) -diff.z else diff.z;

                //const count = similarGeoms.items.len;
                if(diff.x < 500 and diff.y < 500 and diff.z < 500)
                {
                    const geom = SimilarGeom{.scannerId = i, .lineId1 = j, .lineId2 = k, .diff = diff};
                    try similarGeoms.append(geom);
                }
           }
        }
    }

}