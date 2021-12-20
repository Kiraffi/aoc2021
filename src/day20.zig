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
            
            // counting 3 << 0 + 3 << 3 + 3 << 6 +...+ 3 << 21 = 13176245766935394011
            //{
            //    var i: u6 = 0;
            //    var value: u64 = 0;
            //    while( i < 22) : (i += 1)
            //    {
            //        value += @as(u64, 3) << (i * 3);
            //    }
            //    print("value: {}\n", .{value});
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
            // for some reason seems to break values over 16
            const heightAmount: u6 = 16;
            var rowValues: [heightAmount + 2]u64 = undefined;

            while(j < top + height) : (j += heightAmount)
            {
                var i = (left & ~(@as(u32, 63)));

                // Taking last bit from previous block.
                var filterIndex: u64 = 0;
                {
                    var tmp2: u6 = 0;
                    while(tmp2 < heightAmount + 2) : (tmp2 += 1)
                    {
                        const value = sourceImage[((j - 1) * ImageSize + i)/ 64 - 1] >> 63;
                        filterIndex |= value << ((heightAmount + 1 - tmp2) * 3);
                    }
                }

                filterIndex = filterIndex << 1;
                {
                    var tmp2: u6 = 0;
                    while(tmp2 < heightAmount + 2) : (tmp2 += 1)
                    {
                        rowValues[tmp2] = sourceImage[((j - 1 + tmp2) * ImageSize + i)/ 64 + 1];
                        filterIndex |= (rowValues[tmp2] & 1) << ((heightAmount + 1 - tmp2) * 3);
                        // pop off first bit
                        rowValues[tmp2] = rowValues[tmp2] >> 1;
                    }
                }

                while(i < left + width) : (i += 64)
                {
                    //printMap(sourceImage, i - 1, j - 1, 3, 3);
                    var writeValue = std.mem.zeroes([16]u64);

                    var tmp: u6 = 0;
                    while(tmp < 63) : (tmp += 1)
                    {
                        //printMap(sourceImage, i - 1 + tmp, j - 1, 3, 3);
                        // keep bits 1,2, 4,5, 7,8 and multiples of those, every 3rd and 3rd + 1 bits for 63 bits,
                        // 3 << 0 + 3 << 3 + 3 << 6 +...+ 3 << 21 = 13176245766935394011
                        filterIndex &= @as(u64, 13176245766935394011);
                        filterIndex = filterIndex << 1;

                        var tmp2: u6 = 0;
                        while(tmp2 < heightAmount + 2) : (tmp2 += 1)
                        {
                            filterIndex |= (rowValues[tmp2] & 1) << ((heightAmount + 1 - tmp2) * 3);
                            rowValues[tmp2] = rowValues[tmp2] >> 1;
                        }

                        tmp2 = 0;
                        while(tmp2 < heightAmount) : (tmp2 += 1)
                        {
                            const filterValue = sampleFilter(&filter, (filterIndex >> ((heightAmount - 1 - tmp2) * 3)) & 511);
                            writeValue[tmp2] |= @intCast(u64, filterValue) << tmp;
                        }
                    }

                    // last bit of next 64 bits needs the first bit read into filterindex.
                    filterIndex &= @as(u64, 13176245766935394011);
                    filterIndex = filterIndex << 1;
                    {
                        var tmp2: u6 = 0;
                        while(tmp2 < heightAmount + 2) : (tmp2 += 1)
                        {
                            // Read the next block values into rowValues.
                            rowValues[tmp2] = sourceImage[((j - 1 + tmp2) * ImageSize + i)/ 64 + 1];
                            filterIndex |= (rowValues[tmp2] & 1) << ((heightAmount + 1 - tmp2) * 3);
                            // pop off first bit
                            rowValues[tmp2] = rowValues[tmp2] >> 1;
                        }
                    }

                    // write heightAmount lines of 64 bits.
                    {
                        var tmp2: u6 = 0;
                        while(tmp2 < heightAmount) : (tmp2 += 1)
                        {
                            const filterValue = sampleFilter(&filter, (filterIndex >> ((heightAmount - 1 - tmp2) * 3)) & 511);
                            writeValue[tmp2] |= @intCast(u64, filterValue) << 63;
                            destImage[((j + tmp2) * ImageSize + i) / 64] = writeValue[tmp2];
                        }
                    }
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
