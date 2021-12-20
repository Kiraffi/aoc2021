const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const ImageSize: u32 = 512;

const ImageOffset: u32 = 100;
pub fn day20(_: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{
    var filter = std.mem.zeroes([8]u64);

    var resultA: u64 = 0;
    var resultB: u64 = 0;

    var image = std.mem.zeroes([ImageSize * ImageSize]u8);
    var image2 = std.mem.zeroes([ImageSize * ImageSize]u8);

    var rows: u32 = 0;
    var cols: u32 = 0;
    // Parse lines to strings....
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");

        // parsing the filter
        {
            var line = lines.next().?;
            var bit: u32 = 0;
            while(bit < line.len) : (bit += 1)
            {
                if(line[bit] == '#')
                {
                    const bitPos = @intCast(u6, bit % 64);
                    filter[bit / 64] |= @as(u64, 1) << bitPos;
                }
                // otherwise '.' is zero
            }

            // print filter
            //{
            //    bit = 0;
            //    while(bit < 512) : (bit += 1)
            //    {
            //        const c: u8 = if(sampleFilter(&filter, bit) == 1) '#' else '.';
            //        print("{c}", .{c});
            //    }
            //    print("\n", .{});
            //}
        }

        {
            var row: u32 = ImageOffset;
            while(lines.next()) |line|
            {
                var col: u32 = ImageOffset;
                cols = @intCast(u32, line.len);
                var i: u32 = 0;
                while(i < line.len) : (i += 1)
                {
                    image[row * ImageSize + col] = if(line[i] == '#') 1 else 0;
                    col += 1;
                }
                row += 1;
                rows += 1;
            }
        }
        // printing
        {
            //printMap(&image, ImageOffset, ImageOffset, cols, rows);
        }


        // check special case if going borders, like what is ... ... ... value, and ### ### ### value. like does it do some
        // interesting stuff, and then determine that all borders need to sample that
        var borderBit: u8 = @intCast(u8, filter[0] & 1);

        var loop: u32 = 0;
        while(loop < 50) : (loop += 1)
        {
            const sourceImage = if(loop % 2 == 0) &image else &image2;
            const destImage = if(loop % 2 == 0) &image2 else &image;

            const top: u32 = ImageOffset - loop - 1;
            const left: u32 = ImageOffset - loop - 1;
            const width: u32 = cols + (loop + 1) * 2;
            const height: u32 = rows + (loop + 1) * 2;

            // Optimizing the thing by imagesize? Only check the middle
            // This means technically it can only grow one or max 2? pixels per modify
            var j = top;
            while(j < top + height) : (j += 1)
            {
                var i = left;
                while(i < left + width) : (i += 1)
                {
                    //printMap(sourceImage, i - 1, j - 1, 3, 3);
                    var filterIndex: u32 = 0;

                    var y: u32 = j - 1;
                    while(y <= j + 1) : (y += 1)
                    {
                        var x: u32 = i - 1;
                        while(x <= i + 1) : (x += 1)
                        {
                            filterIndex = filterIndex << 1;
                            filterIndex |= @intCast(u32, sourceImage[x + y * ImageSize]);
                        }
                    }
                    const sample = sampleFilter(&filter, filterIndex);
                    //print("x: {}, y: {}, value: {} sample value: {}\n\n", .{i, j, filterIndex, sample});
                    destImage[i + j * ImageSize] = sample;
                }
            }

            // Handle borders separately
            {
                // thinking cache, doing first line, then edges,
                // then last line so no need to jump around memory
                // as much.

                // beginning rows, need to actually only handle 2 extra pixels
                j = top - 2;
                while(j < top) : (j += 1)
                {
                    var i = left - 2;
                    while(i < left + width + 2) : (i += 1)
                    {
                        destImage[i + j * ImageSize] = borderBit;
                    }
                }
                // left and right edge
                while(j < top + height) : (j += 1)
                {
                    // left
                    var i = left - 2;
                    destImage[i + 0 + j * ImageSize] = borderBit;
                    destImage[i + 1 + j * ImageSize] = borderBit;

                    // right
                    i = left + width;
                    destImage[i + 0 + j * ImageSize] = borderBit;
                    destImage[i + 1 + j * ImageSize] = borderBit;
                }
                // end rows
                while(j < top + height + 2) : (j += 1)
                {
                    var i = left - 2;

                    while(i < left + width + 2) : (i += 1)
                    {
                        destImage[i + j * ImageSize] = borderBit;
                    }
                }

            }
            
            const bit: u64 = @intCast(u64, borderBit) * 511;
            borderBit = @intCast(u8, (filter[bit / 64] >> @intCast(u6, bit % 64)) & 1);

            if(loop == 1)
            {
                //printMap(destImage, top, left, width, height);
                resultA = countHashes(destImage, top, left, width, height);
            }
            if(loop == 49)
            {
                //printMap(destImage, top, left, width, height);
                resultB = countHashes(destImage, top, left, width, height);
            }
        }
    }


    const res =try std.fmt.bufPrint(printBuffer, "Day 20-1: Hashes: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day 20-2: Hashes after 50 filters: {}\n", .{resultB});
    return res.len + res2.len;
}

fn countHashes(image: []const u8, x: u32, y: u32, width: u32, height: u32) u32
{
    var result: u32 = 0;
    var j = x;
    while(j < y + height) : (j += 1)
    {
        var i = x;
        while(i < x + width) : (i += 1)
        {
            result += @intCast(u32, image[i + j * ImageSize]);
        }
    }
    return result;
}

fn sampleFilter(filter: []const u64, bit: u32) u8
{
    const bitPos = @intCast(u6, bit % 64);
    return @intCast(u8, ((filter[bit / 64] >> bitPos) & 1));
}

fn printMap(image: []const u8, startX: u32, startY: u32, width: u32, height: u32) void
{
    var j: u32 = startY;
    while(j < startY + height) : (j += 1)
    {
        var i: u32 = startX;
        while(i < startX + width) : (i += 1)
        {
            const c = (1 - image[j * ImageSize + i]) * ('.' - '#') + '#';
            print("{c}", .{c});
        }
        print("\n", .{});
    }
}
