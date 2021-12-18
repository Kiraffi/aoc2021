const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const bytesMax: u32 = 1024;


fn isNumber(c: u8) bool
{
    return c < Comma;
}

const Comma: u8 = 253;
const LeftBracket: u8 = 254;
const RightBracket: u8 = 255;

pub fn day18(_: *std.mem.Allocator, inputFile: []const u8, printBuffer: []u8) anyerror! usize
{
    var str: [bytesMax]u8 = undefined; //std.mem.zeroes([bytesMax]u8);

    var parsedLines: [100][64]u8 = undefined;
    var parsedLineLens: [100]usize = undefined;
    var lineCount: usize = 0;

    var strLen: usize = 0;
    // Parse lines to strings....
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        while(lines.next()) |line|
        {
            var tmpStr: []u8 = &parsedLines[lineCount];
            var tmpStrLen: usize = 0;
            var i: usize = 0;
            while(i < line.len) : (i += 1)
            {
                const c = line[i];
                switch(c)
                {
                    '[' => tmpStr[tmpStrLen] = LeftBracket,
                    ']' => tmpStr[tmpStrLen] = RightBracket,
                    ',' => tmpStr[tmpStrLen] = Comma,
                    '0'...'9' => tmpStr[tmpStrLen] = c - '0',
                    else => {}
                }
                tmpStrLen += 1;
            }
            parsedLineLens[lineCount] = tmpStrLen;
            lineCount += 1;
        }
    }
    
    // Part A
    var resultA: u64 = 0;
    {
        // add '[' in front of the string
        {
            var i: usize = 0;
            while(i < lineCount - 1) : (i += 1)
            {
                str[i] = LeftBracket;
            }
            strLen = 0;
        }
        var i: usize = 0;

        while(i < lineCount) : (i += 1)
        {
            const start = lineCount - i - 1;
            const tmpStr: []u8 = &parsedLines[i];
            const tmpStrLen = parsedLineLens[i];

            if(i > 0)
            {
                // adding because of first bracket.
                strLen += 1;
                str[start + strLen] = Comma;
                strLen += 1;
            }
            std.mem.copy(u8, str[start + strLen..], tmpStr[0..tmpStrLen]);
            strLen += tmpStrLen;
            if(i > 0)
            {
                str[start + strLen] = RightBracket;
                strLen += 1;
            }
            if(i > 0)
                strLen = parseLine(str[lineCount - i - 1..], strLen);

        }

        resultA = evaluateString(&str, strLen);
    }
    
    // Part B
    var resultB: u64 = 0;
    {
        var maxNumber: u64 = 0;
        var i: usize = 0;
        while(i < lineCount) : (i += 1)
        {
            const tmpStr: []u8 = &parsedLines[i];
            const tmpStrLen = parsedLineLens[i];
            var j: usize = i + 1;
            while(j < lineCount) : (j += 1)
            {
                const tmpStr2: []u8 = &parsedLines[j];
                const tmpStrLen2 = parsedLineLens[j];

                {
                    str[0] = LeftBracket;
                    strLen = 1;
                    std.mem.copy(u8, str[strLen..], tmpStr[0..tmpStrLen]);
                    strLen += tmpStrLen;
                    str[strLen] = Comma;
                    strLen += 1;

                    std.mem.copy(u8, str[strLen..], tmpStr2[0..tmpStrLen2]);
                    strLen += tmpStrLen2;
                    str[strLen] = RightBracket;
                    strLen += 1;
                    strLen = parseLine(&str, strLen);
                    maxNumber = @maximum(maxNumber, evaluateString(&str, strLen));
                }

                {
                    str[0] = LeftBracket;
                    strLen = 1;
                    std.mem.copy(u8, str[strLen..], tmpStr2[0..tmpStrLen2]);
                    strLen += tmpStrLen2;
                    str[strLen] = Comma;
                    strLen += 1;

                    std.mem.copy(u8, str[strLen..], tmpStr[0..tmpStrLen]);
                    strLen += tmpStrLen;
                    str[strLen] = RightBracket;
                    strLen += 1;
                    strLen = parseLine(&str, strLen);
                    maxNumber = @maximum(maxNumber, evaluateString(&str, strLen));
                }
            }
        }
        resultB = maxNumber;
    }

    const res =try std.fmt.bufPrint(printBuffer, "Day 18-1: Sum: {}\n", .{resultA});
    const res2 = try std.fmt.bufPrint(printBuffer[res.len..], "Day 18-2: Maximum value: {}\n", .{resultB});
    return res.len + res2.len;
}

const Stack = struct
{
    leftValue: u64,
    rightValue: u64,
};

fn evaluateString(str: []u8, strLen: usize) u64
{
    // stack
    var stack: [1024]Stack = undefined;
    var stackPos: usize = 0;
    stack[0].leftValue = 0x8000_0000_0000_0000;
    stack[0].rightValue = 0x8000_0000_0000_0000;

    var i: usize = 0;
    while(i < strLen) : (i += 1)
    {
        const c = str[i];
        switch(c)
        {
            LeftBracket => 
            {
                stackPos += 1;
                stack[stackPos].leftValue = 0x8000_0000_0000_0000;
                stack[stackPos].rightValue = 0x8000_0000_0000_0000;
            },
            RightBracket =>
            {
                const lValue = stack[stackPos].leftValue;
                const rValue = stack[stackPos].rightValue;
                const value = lValue * 3 + rValue * 2;


                // reset...
                stack[stackPos].leftValue = 0x8000_0000_0000_0000;
                stack[stackPos].rightValue = 0x8000_0000_0000_0000;

                stackPos -= 1;

                const isLeft = (stack[stackPos].leftValue) >> @as(u6, 63);
                stack[stackPos].leftValue = lerp(stack[stackPos].leftValue, value, isLeft);
                stack[stackPos].rightValue = lerp(stack[stackPos].rightValue, value, 1 - isLeft);

            },
            Comma =>
            {
            },

            // is number
            else => 
            {
                const isLeft = (stack[stackPos].leftValue) >> @as(u6, 63);
                stack[stackPos].leftValue = lerp(stack[stackPos].leftValue, c, isLeft);
                stack[stackPos].rightValue = lerp(stack[stackPos].rightValue, c, 1 - isLeft);
            }
        }
    }
    return stack[0].leftValue;
}

fn lerp(left: u64, right: u64, lerpValue: u64) u64
{
    return left * (1 - lerpValue) + right * (lerpValue);
}

// Using some possible indexing system would probably be faster like linked list.
fn parseLine(str: []u8, strsLen: usize) usize
{
    var strLen = strsLen;
    var actionHappened = true;
    var checkExplosion = false;

    while(actionHappened or checkExplosion)
    {
        if(!checkExplosion)
            actionHappened = false;

        var tmpStr: [bytesMax]u8 = undefined;
        var tmpStrLen: usize = 0;

        var bracketCount: u32 = 0;

        var i: u32 = 0;
        var rightMem: u8 = 0;
        while(i < strLen) : (i += 1)
        {
            const c = str[i];
            tmpStr[tmpStrLen] = c;
            tmpStrLen += 1;

            if(c == LeftBracket)
            {
                bracketCount += 1;
            } 
            else if(c == RightBracket) 
            {
                if(bracketCount > 4 and !actionHappened)
                {
                    actionHappened = true;

                    // cos we havent done any actions, its [numA, numB] always.
                    rightMem = str[i - 1];
                    var left: u8 = str[i - 3];
                    tmpStrLen -= 5;

                    var j = tmpStrLen;
                    while( !isNumber(tmpStr[j]) and j > 0) : (j -= 1) {}

                    if(isNumber(tmpStr[j]))
                    {
                        tmpStr[j] += left;
                    }

                    tmpStr[tmpStrLen] = 0;
                    tmpStrLen += 1;
                }
                bracketCount -= 1;
            }

            else if(isNumber(c))
            {
                var num = c;
                num += rightMem;
                rightMem = 0;
                if(num > 9 and !actionHappened and checkExplosion)
                {
                    actionHappened = true;
                    const numL = num / 2;
                    const numR = num - numL;
                    tmpStr[tmpStrLen - 1] = LeftBracket;
                    tmpStr[tmpStrLen + 0] = numL;
                    tmpStr[tmpStrLen + 1] = Comma;
                    tmpStr[tmpStrLen + 2] = numR;
                    tmpStr[tmpStrLen + 3] = RightBracket;
                    tmpStrLen += 4;
                }
                else
                {
                    tmpStr[tmpStrLen - 1] = num;
                }
            }
        }
        
        if(checkExplosion)
        {
            checkExplosion = false;
        }
        else if(!actionHappened and !checkExplosion)
        {
            checkExplosion = true;
        }

        std.mem.copy(u8, str, tmpStr[0..tmpStrLen]);
        strLen = tmpStrLen;
    }

    return strLen;
}

fn printString(str: []u8) void
{
    var i: usize = 0;
    while(i < str.len) : (i += 1)
    {
        const c = str[i];
        if(isNumber(c))
        {
            print("{}", .{c});
        }
        else if(c == LeftBracket)
        {
            print("[", .{});
        }
        else if(c == RightBracket)
        {
            print("]", .{});
        }
        else if(c == Comma)
        {
            print(",", .{});
        }
    }
    print("\n", .{});
}