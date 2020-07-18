const std = @import("std");
const assert = std.debug.assert;
const approxEq = std.math.approxEq;

pub const MixedNumber = struct {
    whole: i32,
    fraction: Fraction,
};

pub const Fraction = struct {
    numerator: i32,
    denominator: i32,
};

pub fn mediantInPlace(result: *Fraction, a: Fraction, b: Fraction) void {
    result.numerator = a.numerator + b.numerator;
    result.denominator = a.denominator + b.denominator;
}

pub fn mediant(a: Fraction, b: Fraction) Fraction {
    return Fraction{
        .numerator = a.numerator + b.numerator,
        .denominator = a.denominator + b.denominator,
    };
}

pub fn floatToNumber(n: f32, limit: i32) MixedNumber {
    var whole = @floatToInt(i32, n);
    var whats_left = n - @intToFloat(f32, whole);
    var fraction = findFraction(whats_left, limit);
    return MixedNumber{
        .whole = whole,
        .fraction = fraction,
    };
}

pub fn findFraction(n: f32, limit: i32) Fraction {
    var left = Fraction{
        .numerator = 0,
        .denominator = 1,
    };
    var right = Fraction{
        .numerator = 1,
        .denominator = 1,
    };
    var result = mediant(left, right);

    var epsilon = 1.0 / @intToFloat(f32, limit);

    while (result.denominator <= limit) {
        var decimal = @intToFloat(f32, result.numerator) / @intToFloat(f32, result.denominator);

        if (approxEq(f32, decimal, n, epsilon)) break;
        
        if (decimal > n) {
            right.numerator = result.numerator;
            right.denominator = result.denominator;
        } else if (decimal < n) {
            left.numerator = result.numerator;
            left.denominator = result.denominator;
        }

        mediantInPlace(&result, left, right);
    }

    return result;
}

fn equalFractions(a: Fraction, b: Fraction) bool {
    return a.numerator == b.numerator and a.denominator == b.denominator;
}

fn equalNumbers(a: MixedNumber, b: MixedNumber) bool {
    return a.whole == b.whole and equalFractions(a.fraction, b.fraction);
}

test "float to number" {
    const TestCase = struct {
        input: f32,
        limit: i32,
        expected: MixedNumber,
    };
    var testCases = [_]TestCase{
        TestCase{
            .input = 0.5,
            .limit = 100,
            .expected = MixedNumber{
                .whole = 0,
                .fraction = Fraction{
                    .numerator = 1,
                    .denominator = 2,
                },
            },
        },
        TestCase{
            .input = 0.33333,
            .limit = 100,
            .expected = MixedNumber{
                .whole = 0,
                .fraction = Fraction{
                    .numerator = 1,
                    .denominator = 3,
                },
            },
        },
        TestCase{
            .input = 2.33333,
            .limit = 100,
            .expected = MixedNumber{
                .whole = 2,
                .fraction = Fraction{
                    .numerator = 1,
                    .denominator = 3,
                },
            },
        },
        TestCase{
            .input = 1.9090909,
            .limit = 10000000,
            .expected = MixedNumber{
                .whole = 1,
                .fraction = Fraction{
                    .numerator = 10,
                    .denominator = 11,
                },
            },
        },
    };

    for (testCases) |testCase| {
        var actual = floatToNumber(testCase.input, testCase.limit);
        assert(equalNumbers(actual, testCase.expected));
    }
}

test "find fraction" {
    const TestCase = struct {
        input: f32,
        limit: i32,
        expected: Fraction,
    };
    var testCases = [_]TestCase{
        TestCase{
            .input = 0.5,
            .limit = 100,
            .expected = Fraction{
                .numerator = 1,
                .denominator = 2,
            },
        },
        TestCase{
            .input = 0.33333,
            .limit = 100,
            .expected = Fraction{
                .numerator = 1,
                .denominator = 3,
            },
        },
        TestCase{
            .input = 0.048896581566421,
            .limit = 10000000,
            .expected = Fraction{
                .numerator = 113,
                .denominator = 2311,
            },
        },
    };

    for (testCases) |testCase| {
        var actual = findFraction(testCase.input, testCase.limit);
        assert(equalFractions(actual, testCase.expected));
    }
}

test "mediant" {
    var a = Fraction{
        .numerator = 0,
        .denominator = 1,
    };
    var b = Fraction{
        .numerator = 1,
        .denominator = 1,
    };

    var actual = mediant(a, b);
    var expected = Fraction{
        .numerator = 1,
        .denominator = 2,
    };

    assert(equalFractions(actual, expected));
}
