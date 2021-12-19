const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


const Coord = struct
{
    x: i64,
    y: i64,
    z: i64,
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
                var x = try std.fmt.parseInt(i64, numbers.next().?, 10);
                var y = try std.fmt.parseInt(i64, numbers.next().?, 10);
                var z = try std.fmt.parseInt(i64, numbers.next().?, 10);
                scanners[scannerNumber][knownLocs[scannerNumber]] = Coord{ .x = x, .y = y, .z = z };
                knownLocs[scannerNumber] += 1;
                //print("scanner: {}:{} {},{},{}\n", .{scannerNumber, knownLocs[scannerNumber], x, y, z});
            }
        }
        scannerNumber += 1;
    }
    {
        // checking cross product
        var i: u32 = 0;
        while(i < 24) : (i += 1)
        {
            const a = rotate(Coord{.x = 1, .y = 0, .z = 0}, i, false);
            const b = rotate(Coord{.x = 0, .y = 1, .z = 0}, i, false);
            const c = rotate(Coord{.x = 0, .y = 0, .z = 1}, i, false);

            var d: Coord = undefined;
            d.x = a.y * b.z - a.z * b.y;
            d.y = a.z * b.x - a.x * b.z;
            d.z = a.x * b.y - a.y * b.x;

            if(!equals(c, d))
            {
                print("Something is wrong: {}\n", .{i});
            }
        }
    }

    var positions = std.mem.zeroes([32]Coord);

    var added: u32 = 1;
    while(added != 0)
    {
        added = 0;
        var mergeTable = std.mem.zeroes([32]u32);
        var scannerId: u32 = 1;
        while(scannerId < scannerNumber and mergeTable[scannerId] == 0) : (scannerId += 1)
        {
            var j: u32 = 0;
            while(j < knownLocs[0]) : (j += 1)
            {
                var bestMatch = ScoreTransform{.origOffset = Coord{.x = 0, .y = 0, .z = 0},
                    .rotatedOffset = Coord{.x = 0, .y = 0, .z = 0}, .rotation = 0, .score = 0 };
                const p1 = scanners[0][j];
                var i: u32 = 0;
                while(i < knownLocs[scannerId]) : (i += 1)
                {
                    const p2 = scanners[scannerId][i];
                    var l: u32 = 0;
                    while(l < 24) : (l += 1)
                    {
                        var trans = ScoreTransform{.origOffset = p2, .rotatedOffset = p1, .rotation = l, .score = 0 };
                        var k: u32 = 0;
                        while(k < knownLocs[scannerId]) : (k += 1)
                        {
                            if(i == k)
                                continue;
                            const transPoint = getLocationAFromB(scanners[scannerId][k], trans);

                            var found = false;
                            var m: u32 = 0;
                            while(m < knownLocs[0]) : (m += 1)
                            {
                                if(equals(scanners[0][m], transPoint))
                                {
                                    found = true;
                                    break;
                                }
                            }
                            if(found)
                            {
                                trans.score += 1;
                            }
                        }
                        if(trans.score > bestMatch.score)
                        {
                            //print("score: {} to {}\n", .{trans.score, bestMatch.score});
                            //print("rot: {}\n", .{trans.rotation});
                            //print("rot: {}\n", .{bestMatch.rotation});
                            bestMatch = trans;
                            //print("rot: {}\n", .{bestMatch.rotation});
                            //print("score: {} to {}\n", .{trans.score, bestMatch.score});
                            if(bestMatch.score >= 5)
                                break;
                        }

                    }
                }
//            }
                // lets guess 5 is enough match amount
                if(bestMatch.score >= 5)// and ((mergeTable[g1.scannerId]) & (@as(u32, 1) << @intCast(u5, g2.scannerId))) == 0)
                {
                    if(mergeTable[scannerId] == 0)
                    {
                        const pos = getLocationAFromB(Coord {.x = 0, .y = 0, .z = 0 }, bestMatch);
                        positions[scannerId] = pos;
                        mergeTable[scannerId] = 1;
                        added += mergeLists(0, scannerId, bestMatch);
                    }
                    break;
                }
            }
        }
    }
    {
        var i: u32 = 0;
        while(i < scannerNumber) : (i += 1)
        {
            print("scanner: {} knows: {}\n", .{i, knownLocs[i]});
            print("position:", .{});
            printPoint(positions[i]);
        }
    }
    {
        var biggestDistance: i64 = 0;
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
            // print("{}", .{i});
                //printPoint(scanners[0][i]);
            }
        }
        print("biggest disatance: {}\n", .{biggestDistance});
    }

    var resultA: u64 = 0;

    var resultB: u64 = 0;

    const res =try std.fmt.bufPrint(printBuffer, "Da.y 18-1: Sum: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Da.y 18-2: Maximum value: {}\n", .{resultB});
    return res.len + res2.len;
}

// there is probably something smarter here
fn mergeLists(aInd: u32, bInd: u32, bestMatch: ScoreTransform) u32
{
    //print("rotation here: {}, a: {}, b{}\n", .{bestMatch.rotation, aInd, bInd});
    var addedA: u32 = 0;
    //var addedB: u32 = 0;
    const testCoord = Coord{.x=26, .y=-1119, .z=1091 };
    var i: u32 = 0;
//    while(i < knownLocs[aInd]) : (i += 1)
//    {
//        const pA = scanners[aInd][i];
//        const pointA = getLocationBFromA(pA, bestMatch);
//
//        if(equals(pointA, testCoord))
//        {
//            print("special found1 \n", .{});
//        }
//
//        var foundB = false;
//        var j: u32 = 0;
//        while(j < knownLocs[bInd]) : (j += 1)
//        {
//            const pB = scanners[bInd][j];
//            if(equals(pB, testCoord))
//            {
//                print("special foun2 \n", .{});
//            }
//            if(equals(pB, pointA))
//            {
//                foundB = true;
//                break;
//            }
//        }
//
//
//        if(!foundB)
//        {
//            scanners[bInd][knownLocs[bInd]] = pointA;
//            knownLocs[bInd] += 1;
//            addedB += 1;
//        }
//    }

    i = 0;
    while(i < knownLocs[bInd]) : (i += 1)
    {
        const pB = scanners[bInd][i];
        const pointB = getLocationAFromB(pB, bestMatch);


        if(equals(pointB, testCoord))
        {
            print("special found3 \n", .{});
        }
        var foundA = false;
        var j: u32 = 0;
        while(j < knownLocs[aInd]) : (j += 1)
        {
            const pA = scanners[aInd][j];
            if(equals(pA, testCoord))
            {
                print("special found4 \n", .{});
            }




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
    //print("added a: {}, added b: {}\n", .{addedA, addedB});
    //print("added a: {}\n", .{addedA});
    return addedA;// + addedB;
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
    //print("original: ", .{});
    //printPoint(b);
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
    //printPoint(movement);
    // rotate it
    const rotatedPoint = rotate(movement, trans.rotation, true);
    //printPoint(rotatedPoint);
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


    if(!equals(p1, rotate(rotate(p1, rotation, false), rotation, true )))
    {
        print("somethign is wrong with neg rots: {}\n", .{rotation});
    }

    const p1p2diff = dec(p1, p2);
    const p2p1diff = dec(p2, p1);

    var offset: Coord = undefined;

    if(equals(p1p2diff, line))
    {
        offset = p1; //dec(p1, p3);
        //print("p1p2same\n", .{});
    }
    else if(equals(p2p1diff, line))
    {
        offset = p2; //dec(p2, p3);
        //print("p2p1same\n", .{});
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
            //// move p3 to 0
            //const movement = dec(scanners[g2.scannerId][j], p3);
            //// rotate it
            //const rot = rotate(movement, rotation);
//
            //// move it to overlap offset which is either p1 or p2
            //const point2 = add(rot, offset);//rotate(add(scanners[g2.scannerId][j], offset), rotation);
            if(equals(point, point2))
            {
                trans.score += 1;
                if(!equals(getLocationBFromA(point2, trans), checkPoint))

                {
                    //print("hmm not equal\n", .{});
                }
//                else
//                {
//                    print("equal!\n", .{});
//                }
                break;
            }
        }
    }
    return trans;
}

fn add(a: Coord, b:Coord) Coord
{
    return Coord{.x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
}
fn dec(a: Coord, b: Coord) Coord
{
    return Coord {.x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
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
    //if(rotation > 24)
    //{
    //    r.y = -r.y;
    //    r.z = -r.z;
    //}
    //print("rot o: {} rot n: {}\n", .{rotation, rot});
// inverse)
    if(true)
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
    else
    {
        switch(rotation)
        {
            0  => { r.x =  a.x; r.y =  a.y; r.z = a.z; },
            1  => { r.x = -a.x; r.y = -a.y; r.z = a.z; },
            2  => { r.x =  a.y; r.y = -a.x; r.z = a.z; },
            3  => { r.x = -a.y; r.y =  a.x; r.z = a.z; },

            4  => { r.x = -a.x; r.y =  a.y; r.z = -a.z; },
            5  => { r.x =  a.x; r.y = -a.y; r.z = -a.z; },
            6  => { r.x =  a.y; r.y =  a.x; r.z = -a.z; },
            7  => { r.x = -a.y; r.y = -a.x; r.z = -a.z; },

            8  => { r.x =  a.z; r.y =  a.y; r.z = -a.x; },
            9  => { r.x =  a.z; r.y = -a.y; r.z =  a.x; },
            10 => { r.x =  a.z; r.y =  a.x; r.z =  a.y; },
            11 => { r.x =  a.z; r.y = -a.x; r.z = -a.y; },

            12 => { r.x = -a.z; r.y =  a.y; r.z =  a.x; },
            13 => { r.x = -a.z; r.y = -a.y; r.z = -a.x; },
            14 => { r.x = -a.z; r.y = -a.x; r.z =  a.y; },
            15 => { r.x = -a.z; r.y =  a.x; r.z = -a.y; },

            16 => { r.x =  a.x; r.y =  a.z; r.z = -a.y; },
            17 => { r.x = -a.x; r.y =  a.z; r.z =  a.y; },
            18 => { r.x =  a.y; r.y =  a.z; r.z =  a.x; },
            19 => { r.x = -a.y; r.y =  a.z; r.z = -a.x; },

            20 => { r.x = -a.x; r.y = -a.z; r.z = -a.y; },
            21 => { r.x =  a.x; r.y = -a.z; r.z =  a.y; },
            22 => { r.x =  a.y; r.y = -a.z; r.z = -a.x; },
            23 => { r.x = -a.y; r.y = -a.z; r.z =  a.x; },
            else => {}
        }

    }
    return r;

}



fn findSimilarOffsets(similarGeoms: *std.ArrayList(SimilarGeom)) anyerror!void
{
    var i: u32 = 0;
    while(i < scannerNumber) : (i += 1)
    {
        var j: u32 = 0;
        while(j < knownLocs[i]) : (j += 1)
        {
            var k = (j + 1) % knownLocs[i];
            while(k < knownLocs[i]) : (k += 1)
            {
                const g1 = scanners[i][j];
                const g2 = scanners[i][k];

                var diff = Coord{.x = g1.x - g2.x, .y = g1.y - g2.y, .z = g1.z - g2.z };

                diff.x = if(diff.x < 0) -diff.x else diff.x;
                diff.y = if(diff.y < 0) -diff.y else diff.y;
                diff.z = if(diff.z < 0) -diff.z else diff.z;

                //const count = similarGeoms.items.len;
                //if(diff.x < 1000 and diff.y < 1000 and diff.z < 1000)
                {
                const geom = SimilarGeom{.scannerId = i, .lineId1 = j, .lineId2 = k, .diff = diff};
                try similarGeoms.append(geom);
                }
//                if(g1.x == g2.x)
//                {
//                    print("C: {} Scanner: {}:   {}-{} x is same: {}\n", .{count, i, j, k, g1.x});
//
//                    try similarGeoms.append(geom);
//
//                }
//                if(g1.y == g2.y)
//                {
//                    print("C: {} Scanner: {}:   {}-{} y is same: {}\n", .{count, i, j, k, g1.y});
//                    try similarGeoms.append(geom);
//                }
//                if(g1.z == g2.z)
//                {
//                    print("C: {} Scanner: {}:   {}-{} z is same: {}\n", .{count, i, j, k, g1.z});
//
//                    try similarGeoms.append(geom);
//                }
            }
        }
    }

}