const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const Box = struct
{
    xi0: i64,
    xi1: i64,
    yi0: i64,
    yi1: i64,
    zi0: i64,
    zi1: i64,
    setState: i64,
    size: i64,
};

pub fn day22(allocator: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{
    var resultA: u64 = 0;
    var resultB: u64 = 0;


    var cubeArray = std.ArrayList(Box).init(allocator);
    defer cubeArray.deinit();


    var offCubeArray = std.ArrayList(Box).init(allocator);
    defer offCubeArray.deinit();

    var onCubeArray = std.ArrayList(Box).init(allocator);
    defer onCubeArray.deinit();

    var currentOnCubeArray = std.ArrayList(Box).init(allocator);
    defer currentOnCubeArray.deinit();

    // Parse lines to strings....
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        while(lines.next()) |line|
        {
            var text = std.mem.tokenize(u8, line, " ");

            const onoff = text.next().?;
            const positions = text.next().?;

            var coords = std.mem.tokenize(u8, positions, ",");

            var froms: [3]i64 = undefined;
            var tos: [3]i64 = undefined;
            var index: u32 = 0;
            while(coords.next()) |coord|
            {
                var fromTo = std.mem.tokenize(u8, coord[2..], "..");
                froms[index] = try std.fmt.parseInt(i64, fromTo.next().?, 10);
                // Add one for inclusion
                tos[index] = try std.fmt.parseInt(i64, fromTo.next().?, 10);
                tos[index] += 1;
                index += 1;
            }

            const setState: i64 = if(std.mem.eql(u8, onoff, "on")) 1 else 0;
            const box = Box{
                .xi0 = froms[0], .xi1 = tos[0],
                .yi0 = froms[1], .yi1 = tos[1],
                .zi0 = froms[2], .zi1 = tos[2],
                .setState = setState, .size = (tos[0] - froms[0]) * (tos[1] - froms[1]) * (tos[2] - froms[2])
            };
            try cubeArray.append(box);
            if(setState == 1)
               try onCubeArray.append(box)
            else
               try offCubeArray.append(box);
        }
    }

    // Part A
    {
        // add one to the size.
        var cubes = std.mem.zeroes([102][102][102]u8);
//        const constantBox = Box{
//            .xi0 = -50, .xi1 = 51,
//            .yi0 = -50, .yi1 = 51,
//            .zi0 = -50, .zi1 = 51,
//            .setState = setState, .size = 101 * 101 * 101;
//        };
        for(cubeArray.items) |cube|
        {
//            var sizeBox = getOverlapBox(cube, constantBox);

            if(cube.xi0 > 50 or cube.yi0 > 50 or cube.zi0 > 50 or
                cube.xi1 < -50 or cube.yi1 < -50 or cube.zi0 < -50
            )
            {
                continue;
            }
            var froms: [3]usize = undefined;
            var tos: [3]usize = undefined;

            froms[0] = @intCast(usize, @maximum(cube.xi0, -50) + 51);
            // Extra 1 for including the number 50
            tos[0] = @intCast(usize, @minimum(cube.xi1, 51) + 51);
            froms[1] = @intCast(usize, @maximum(cube.yi0, -50) + 51);
            tos[1] = @intCast(usize, @minimum(cube.yi1, 51) + 51);
            froms[2] = @intCast(usize, @maximum(cube.zi0, -50) + 51);
            tos[2] = @intCast(usize, @minimum(cube.zi1, 51) + 51);



            const setState: u8 = @intCast(u8, cube.setState);
            var k: usize = froms[2];
            while(k < tos[2]) : (k += 1)
            {
                var j: usize = froms[1];
                while(j < tos[1]) : (j += 1)
                {
                    var i: usize = froms[0];
                    while(i < tos[0]) : (i += 1)
                    {
                        cubes[k][j][i] = setState;
                    }
                }
            }
        }

        {
            var count: usize = 0;
            var k: usize = 0;
            while(k < 102) : (k += 1)
            {
                var j: usize = 0;
                while(j < 102) : (j += 1)
                {
                    var i: usize = 0;
                    while(i < 102) : (i += 1)
                    {
                        count += cubes[k][j][i];
                    }
                }
            }

            print("has: {} cubes on\n", .{count});

        }
        // Part B
        {
            var count: i64 = 0;
            // Hopefully indexes in order
            for(cubeArray.items) |cube, i|
            {
                //print("i: {}\n", .{i} );
                // Add every new cube count regardless if there was one or not.
                if(cube.setState == 1)
                    count += cube.size;
                for(cubeArray.items) |cube2, j|
                {
                    // Already added ones, shouldnt try to add from offing one.
                    if(j >= i or cube2.setState == 0)
                        continue;
                    // calculate intersect volume and reduce the count, shouldnt go negative size.
                    // should also count those added previously 2 times same intersecting volumes
                    const overlap = getOverlapBox(cube, cube2);
                    count -= overlap.size;

                    // if the cube is off, we should make sure not to off something many times
                    // so checking the overlap
                    if(cube.setState == 1)
                    {
                        for(cubeArray.items) |cube3, k|
                        {
                            // Already added ones, shouldnt try to add from offing one.
                            if(k >= j)// or cube3.setState == 1)
                                continue;

                            const overlap2 = getOverlapBox(overlap, cube3);
                            count += overlap2.size;
                        }
                    }
                    else
                    {

                    }
                }
            }
            //2758514936282235 right
            //5819329772767773
            //11968749311662531
            //24976248138910391
            //22434365988662145
            //2089231914525007610
            print("count: {}\n", .{count});
        }
    }



    const res =try std.fmt.bufPrint(printBuffer, "Day 22-1: Beacons: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day 22-2: Biggest manhattan distance: {}\n", .{resultB});
    return res.len + res2.len;
}


fn getOverlapBox(boxA: Box, boxB: Box) Box
{
    // the max size should be at least min so no negative reductions.
    var overlapBox: Box = undefined;

    overlapBox.xi0 = @maximum(boxA.xi0, boxB.xi0);
    overlapBox.xi1 = @maximum(overlapBox.xi0, @minimum(boxA.xi1, boxB.xi1));
    overlapBox.yi0 = @maximum(boxA.yi0, boxB.yi0);
    overlapBox.yi1 = @maximum(overlapBox.yi0, @minimum(boxA.yi1, boxB.yi1));
    overlapBox.zi0 = @maximum(boxA.zi0, boxB.zi0);
    overlapBox.zi1 = @maximum(overlapBox.zi0, @minimum(boxA.zi1, boxB.zi1));
    overlapBox.size = (overlapBox.xi1 - overlapBox.xi0) * (overlapBox.yi1 - overlapBox.yi0) * (overlapBox.zi1 - overlapBox.zi0);
    overlapBox.setState = 0;
    return overlapBox;
}