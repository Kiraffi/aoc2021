const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

pub fn day1(alloc: *std.mem.Allocator) anyerror!void
{
        // just for allocator
    var nums = std.ArrayList(i32).init(alloc);
    defer nums.deinit();

    var file = try std.fs.cwd().openFile("input_day1.txt", .{});
    defer file.close();

    var buffer: [1024*1024 * 4]u8 = undefined;
    const bytes_read = try file.read(buffer[0..buffer.len]);

    var numbers: u32 = 0;
    var number_array: [65536]u32 = undefined;
    var i: u32 = 0;
    var num: u32 = 0;

    while (i < bytes_read) : (i += 1)
    {
        const value = buffer[i];
        if ((value >= '0') and (value <= '9'))
        {
            num = num * 10 + (value - '0');
        }
        else
        {
            number_array[numbers] = num;
            num = 0;
            numbers += 1;
        }
    }

    i = 0;
    var countA: u32 = 0;
    while (i < numbers - 1) : (i += 1)
    {
        if(number_array[i] < number_array[i + 1])
        {
            countA += 1;
        }
    }
    print("Day1-1: larger numbers {d} \n", .{countA});


    i = 0;
    var countB: u32 = 0;
    while (i < numbers - 3) : (i += 1)
    {
        const firstNumber = number_array[i] + number_array[i + 1] + number_array[i + 2];
        const secondNumber = number_array[i + 3] + number_array[i + 1] + number_array[i + 2];
        if(firstNumber < secondNumber)
        {
            countB += 1;
        }
    }
    print("Day1-2: larger numbers {d} \n", .{countB});

}
