// Using the Kaggle dataset for student records
// https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data

const std = @import("std");

// Enum for race/ethnicity groups
const Ethnicity = enum(u4) { group_a = 0, group_b = 1, group_c = 2, group_d = 3, group_e = 4, _ };

const Education = enum(u4) { hs_some = 0, hs_full = 1, college_some = 2, deg_associates = 3, deg_bachelor = 4, deg_master = 5, _ };

const Stdnt = struct {
    gender: bool,
    eth: Ethnicity,
    p_edu: Education,
    lunch: bool,
    test_prep: bool,
    math_scr: u8,
    read_scr: u8,
    writ_scr: u8,
    total_scr: u16,

    // Custom method to parse ethnicity
    fn parseEthnicity(allocator: std.mem.Allocator, eth_str: []const u8) !Ethnicity {
        // Allocate buffer for lowercase conversion
        var lowercase = try allocator.alloc(u8, eth_str.len);
        defer allocator.free(lowercase);

        // Manual lowercase conversion
        for (eth_str, 0..) |char, i| {
            lowercase[i] = std.ascii.toLower(char);
        }

        // Map variations to enum values
        if (std.mem.eql(u8, lowercase, "group a")) return .group_a;
        if (std.mem.eql(u8, lowercase, "group b")) return .group_b;
        if (std.mem.eql(u8, lowercase, "group c")) return .group_c;
        if (std.mem.eql(u8, lowercase, "group d")) return .group_d;
        if (std.mem.eql(u8, lowercase, "group e")) return .group_e;

        return error.InvalidEthnicity;
    }

    // Custom method to parse Parent Education, follows parseEthnicity
    fn parseEducation(allocator: std.mem.Allocator, edu_str: []const u8) !Education {
        var lowercase = try allocator.alloc(u8, edu_str.len);
        defer allocator.free(lowercase);

        for (edu_str, 0..) |char, i| {
            lowercase[i] = std.ascii.toLower(char);
        }
        // Map to enums for degree status
        if (std.mem.eql(u8, lowercase, "some high school")) return .hs_some;
        if (std.mem.eql(u8, lowercase, "high school")) return .hs_full;
        if (std.mem.eql(u8, lowercase, "some college")) return .college_some;
        if (std.mem.eql(u8, lowercase, "associate's degree")) return .deg_associates;
        if (std.mem.eql(u8, lowercase, "bachelor's degree")) return .deg_bachelor;
        if (std.mem.eql(u8, lowercase, "master's degree")) return .deg_master;
        // TODO: Change to switchcase?

        std.debug.print("Invalid education value: {s}\n", .{edu_str});

        return error.InvalidEducation;
    }

    // Parse method for CSV line
    pub fn fromCSVLine(allocator: std.mem.Allocator, line: []const u8) !Stdnt {
        var tokens = std.mem.tokenize(u8, line, ",");

        // Skip header if present
        if (std.mem.startsWith(u8, line, "gender,race_ethnicity")) {
            return error.HeaderRow;
        }

        return Stdnt{
            .gender = (try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10)) == 1,
            .eth = try parseEthnicity(allocator, tokens.next() orelse return error.InvalidFormat),
            .p_edu = try parseEducation(allocator, tokens.next() orelse return error.InvalidFormat),
            .lunch = (try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10)) == 1,
            .test_prep = (try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10)) == 1,
            .math_scr = try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10),
            .read_scr = try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10),
            .writ_scr = try std.fmt.parseInt(u8, tokens.next() orelse return error.InvalidFormat, 10),
            .total_scr = try std.fmt.parseInt(u16, tokens.next() orelse return error.InvalidFormat, 10),
        };
    }
};

pub fn main() !void {
    // GeneralPurposeAllocator for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // File Selection - TODO Change to specifiy file in CLI
    const file_path: ?[]const u8 = "data/example.csv";

    const file = try std.fs.cwd().openFile(file_path.?, .{});
    defer file.close();

    const csv_content = try std.fs.cwd().readFileAlloc(allocator, file_path.?, 1024 * 1024);
    defer allocator.free(csv_content);

    var lines = std.mem.tokenize(u8, csv_content, "\n");
    var students = std.ArrayList(Stdnt).init(allocator);
    defer students.deinit();

    // Parse each line into a Stdnt
    while (lines.next()) |line| {
        const student = Stdnt.fromCSVLine(allocator, line) catch |err| {
            if (err == error.HeaderRow) continue;
            return err;
        };
        try students.append(student);
    }

    const new_file = try std.fs.cwd().createFile("data/output.csv", .{
        .truncate = true, // Overwrite the file if it already exists
    });
    defer new_file.close();

    const writer = new_file.writer();

    // Convert file to updated format
    for (students.items) |student| {
        try writer.print("{},{},{},{},{},{},{},{},{}\n", .{ student.gender, @intFromEnum(student.eth), @intFromEnum(student.p_edu), student.lunch, student.test_prep, student.math_scr, student.read_scr, student.writ_scr, student.total_scr });
    }
}
