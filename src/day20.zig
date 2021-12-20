const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const ImageSize: u32 = 512;

const ImageOffset: u32 = 256;
pub fn day20(_: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{
    // seems faster to just use bytes instead of packing the bits into u64
    var filter = std.mem.zeroes([512]u8);

    var resultA: u64 = 0;
    var resultB: u64 = 0;

    var image = std.mem.zeroes([ImageSize * ImageSize / 64]u64);
    var image2 = std.mem.zeroes([ImageSize * ImageSize / 64]u64);

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
                    filter[bit] = 1;
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
                    const bit: u64 = if(line[i] == '#') 1 else 0;
                    setSample(&image, col, row, bit);
                    col += 1;
                }
                row += 1;
                rows += 1;
            }
        }
        // printing
        {
            //printMap(&image, ImageOffset, ImageOffset, cols, rows);
            //print("\n", .{});
        }


        // check special case if going borders, like what is ... ... ... value, and ### ### ### value. like does it do some
        // interesting stuff, and then determine that all borders need to sample that
        var borderBit: u64 = filter[0] & 1;

        var loop: u32 = 0;
        while(loop < 50) : (loop += 1)
        {
            const sourceImage = if(loop % 2 == 0) &image else &image2;
            const destImage = if(loop % 2 == 0) &image2 else &image;

            const top: u32 = ImageOffset - loop - 1;
            const left: u32 = ImageOffset - loop - 1;
            const width: u32 = cols + (loop + 1) * 2;
            const height: u32 = rows + (loop + 1) * 2;

            // Handle borders separately, just fill the whole buffer with bit set or not
            {
                const value: u64 = borderBit * 0xffff_ffff_ffff_ffff;
                var index: u32 = 0;
                while(index < destImage.len) : (index += 1)
                {
                    destImage[index] = value;
                }
            }
            

            // Optimizing the thing by imagesize? Only check the middle
            // This means technically it can only grow one or max 2? pixels per modify

            // nastiness of having to read next bit... and previous

            // maybe the memory layout should have been 
            var j = top;
            while(j < top + height) : (j += 1)
            {
                var i = (left & ~(@as(u32, 63)));
                 
                var topRow: u64 = sourceImage[((j - 1) * ImageSize + i)/ 64 - 1];
                var midRow: u64 = sourceImage[((j + 0) * ImageSize + i)/ 64 - 1];
                var botRow: u64 = sourceImage[((j + 1) * ImageSize + i)/ 64 - 1];

                // Since bits are flipped... 63th bit should be 2nd bit, and 62th should be first.
                var filterIndex: u32 = 0;
                filterIndex |= @intCast(u32, topRow >> 63) << 6;
                filterIndex |= @intCast(u32, midRow >> 63) << 3;
                filterIndex |= @intCast(u32, botRow >> 63);

                // last bit of next 64 bits needs the first bit read into filterindex.
                topRow = sourceImage[((j - 1) * ImageSize + i) / 64];
                midRow = sourceImage[((j + 0) * ImageSize + i) / 64];
                botRow = sourceImage[((j + 1) * ImageSize + i) / 64];

                filterIndex = filterIndex << 1;
                filterIndex |= @intCast(u32, topRow & 1) << 6;
                filterIndex |= @intCast(u32, midRow & 1) << 3;
                filterIndex |= @intCast(u32, botRow & 1);

                // pop first bit off...
                topRow = topRow >> 1;
                midRow = midRow >> 1;
                botRow = botRow >> 1;
                while(i < left + width) : (i += 64)
                {
                    //printMap(sourceImage, i - 1, j - 1, 3, 3);
                    var writeValue: u64 = 0;

                    var tmp: u32 = 0;
                    while(tmp < 63) : (tmp += 1)
                    {
                        //printMap(sourceImage, i - 1 + tmp, j - 1, 3, 3);
                        // keep bits 1,2, 4,5, 7,8
                        filterIndex &= @as(u32, 219); //(1 + 2 + 8 + 16 + 64 + 128));
                        filterIndex = filterIndex << 1;

                        filterIndex |= @intCast(u32, topRow & 1) << 6;
                        filterIndex |= @intCast(u32, midRow & 1) << 3;
                        filterIndex |= @intCast(u32, botRow & 1);

                        topRow = topRow >> 1;
                        midRow = midRow >> 1;
                        botRow = botRow >> 1;

                        writeValue |= sampleFilter(&filter, filterIndex) << @intCast(u6, tmp);
                    }

                    // last bit of next 64 bits needs the first bit read into filterindex.
                    topRow = sourceImage[((j - 1) * ImageSize + i) / 64 + 1];
                    midRow = sourceImage[((j + 0) * ImageSize + i) / 64 + 1];
                    botRow = sourceImage[((j + 1) * ImageSize + i) / 64 + 1];

                    filterIndex &= @as(u32, 219); //(1 + 2 + 8 + 16 + 64 + 128));
                    filterIndex = filterIndex << 1;
                    filterIndex |= @intCast(u32, topRow & 1) << 6;
                    filterIndex |= @intCast(u32, midRow & 1) << 3;
                    filterIndex |= @intCast(u32, botRow & 1);
                    
                    topRow = topRow >> 1;
                    midRow = midRow >> 1;
                    botRow = botRow >> 1;

                    writeValue |= sampleFilter(&filter, filterIndex) << @intCast(u6, 63);
                    destImage[(j * ImageSize + i) / 64] = writeValue;
                }
            }


            const bit = borderBit * 511;
            borderBit = sampleFilter(&filter, bit);

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
            //printMap(destImage, top - 5, left - 5, width + 10, height + 10);
            //print("\n", .{});
        }
    }


    const res =try std.fmt.bufPrint(printBuffer, "Day 20-1: Hashes: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day 20-2: Hashes after 50 filters: {}\n", .{resultB});
    return res.len + res2.len;
}

fn getSample(image: []const u64, x: u32, y: u32) u32
{
    const index = x + y * ImageSize;
    return @intCast(u32, (image[index / 64] >> @intCast(u6, (index % 64))) & 1);
}
fn setSample(image: []u64, x: u32, y: u32, value: u64) void
{
    const index = x + y * ImageSize;
    const bit: u64 = @as(u64, 1) << @intCast(u6, (index % 64));
    image[index / 64] &= ~bit;
    image[index / 64] |= bit * value;
}

// should use countbits maybe
fn countHashes(image: []const u64, x: u32, y: u32, width: u32, height: u32) u32
{
    var result: u32 = 0;
    var j = x;
    while(j < y + height) : (j += 1)
    {
        var i = x;
        while(i < x + width) : (i += 1)
        {
            result += getSample(image, i, j);
        }
    }
    return result;
}

fn sampleFilter(filter: []const u8, bit: u64) u64
{
    return filter[bit];
}

fn printMap(image: []const u64, startX: u32, startY: u32, width: u32, height: u32) void
{
    var j: u32 = startY;
    while(j < startY + height) : (j += 1)
    {
        var i: u32 = startX;
        while(i < startX + width) : (i += 1)
        {
            const c = @intCast(u8, ((1 - getSample(image, i, j)) * ('.' - '#') + '#'));

            print("{c}", .{c});
        }
        print("\n", .{});
    }
}
