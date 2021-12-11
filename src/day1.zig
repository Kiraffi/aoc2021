const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

pub fn day1(alloc: *std.mem.Allocator, comptime inputFile: []const u8) anyerror!void
{
        // just for allocator
    var nums = std.ArrayList(i32).init(alloc);
    defer nums.deinit();

    // original
    //var file = try std.fs.cwd().openFile("input_day1.txt", .{});
    //defer file.close();
    //
    //var buffer: [1024*1024 * 4]u8 = undefined;
    //const bytes_read = try file.read(buffer[0..buffer.len]);
    var numbers: u32 = 0;
    //var number_array: [65536]u32 = undefined;

    var prevNumber: [3]u32 = .{0, 0, 0};
    var countA: u32 = 0;
    var countB: u32 = 0;

    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    var prevNumberIndex:u32 = 0;
    while (lines.next()) |line|
    {
        const num:u32 = try std.fmt.parseInt(u32, line, 10);
        //number_array[numbers] = num;
        if(numbers > 0 and num > prevNumber[(prevNumberIndex + 2) % 3])
            countA += 1;
        if(numbers > 2 and num > prevNumber[prevNumberIndex])
            countB += 1;

        numbers += 1;
        prevNumber[prevNumberIndex] = num;
        prevNumberIndex = (prevNumberIndex + 1) % 3;
    }
    print("Day1-1: larger numbers {d} \n", .{countA});


    //i = 0; old
    //while (i < numbers - 3) : (i += 1)
    //{
    //    const firstNumber = number_array[i]; // + number_array[i + 1] + number_array[i + 2];
    //    const secondNumber = number_array[i + 3]; // + number_array[i + 1] + number_array[i + 2];
    //    if(firstNumber < secondNumber)
    //    {
    //        countB += 1;
    //    }
    //}
    print("Day1-2: larger numbers {d} \n", .{countB});

}
