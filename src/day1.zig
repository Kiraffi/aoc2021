const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

pub fn day1(_: *std.mem.Allocator, comptime inputFile: []const u8, printingVals: bool) anyerror!void
{
    // original
    //var file = try std.fs.cwd().openFile("input_day1.txt", .{});
    //defer file.close();
    //
    //var buffer: [1024*1024 * 4]u8 = undefined;
    //const bytes_read = try file.read(buffer[0..buffer.len]);
    var numbers: u32 = 0;
    //var number_array: [65536]u32 = undefined;

    var prevNumber: [4]u32 = .{0, 0, 0, 0};
    var countA: u32 = 0;
    var countB: u32 = 0;

    var prevNumberIndex:u32 = 0;
    var i: u32 = 0;
    while (i < inputFile.len) : (i += 1)
    {
        var num:u32 = 0;
        while(i < inputFile.len) : (i += 1)
        {
            const c: u8 = inputFile[i];
            if(c >= '0' and c <='9')
            {
                num = num * 10 + c - '0';
            }
            else
            {
                break;
            }
        }
        if(num > 0)
        {
            if(numbers > 0 and num > prevNumber[(prevNumberIndex + 3) % 4])
                countA += 1;
            if(numbers > 2 and num > prevNumber[(prevNumberIndex + 1) % 4])
                countB += 1;

            numbers += 1;
            prevNumber[prevNumberIndex] = num;
            prevNumberIndex = (prevNumberIndex + 1) % 4;
        }
    }
    if(printingVals)
    {
        print("Day1-1: larger numbers {d} \n", .{countA});
        print("Day1-2: larger numbers {d} \n", .{countB});
    }
}
