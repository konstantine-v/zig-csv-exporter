// Using the Kaggle dataset for student records
// https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data

const std = @import("std");

// Reusable mapping type generator to ensure type identity across call sites
fn MappingType(comptime T: type) type {
    return struct { str: []const u8, value: T };
}

// Enum for race/ethnicity groups
const Ethnicity = enum(u4) { group_a = 0, group_b = 1, group_c = 2, group_d = 3, group_e = 4, _ };

const Education = enum(u4) { hs_some = 0, hs_full = 1, college_some = 2, deg_associates = 3, deg_bachelor = 4, deg_master = 5, _ };

// Generic function to convert string to lowercase
fn toLowercase(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var lowercase = try allocator.alloc(u8, input.len);
    for (input, 0..) |char, i| {
        lowercase[i] = std.ascii.toLower(char);
    }
    return lowercase;
}

// Generic function to parse enum from string with mapping
fn parseEnumFromString(comptime T: type, allocator: std.mem.Allocator, input: []const u8, mappings: []const MappingType(T)) !T {
    const lowercase = try toLowercase(allocator, input);
    defer allocator.free(lowercase);

    for (mappings) |mapping| {
        if (std.mem.eql(u8, lowercase, mapping.str)) {
            return mapping.value;
        }
    }

    return error.InvalidValue;
}

const Stdnt = struct {
    gender: bool,
    eth: Ethnicity,
    p_edu: Education,
    lunch: bool,
    test_prep: bool,
    math_scr: u7,
    read_scr: u7,
    writ_scr: u7,

    // Custom method to parse ethnicity
    fn parseEthnicity(allocator: std.mem.Allocator, eth_str: []const u8) !Ethnicity {
        const mappings = [_]MappingType(Ethnicity){
            .{ .str = "group a", .value = .group_a },
            .{ .str = "group b", .value = .group_b },
            .{ .str = "group c", .value = .group_c },
            .{ .str = "group d", .value = .group_d },
            .{ .str = "group e", .value = .group_e },
        };

        return parseEnumFromString(Ethnicity, allocator, eth_str, &mappings);
    }

    // Custom method to parse Parent Education
    fn parseEducation(allocator: std.mem.Allocator, edu_str: []const u8) !Education {
        const mappings = [_]MappingType(Education){
            .{ .str = "some high school", .value = .hs_some },
            .{ .str = "high school", .value = .hs_full },
            .{ .str = "some college", .value = .college_some },
            .{ .str = "associate's degree", .value = .deg_associates },
            .{ .str = "bachelor's degree", .value = .deg_bachelor },
            .{ .str = "master's degree", .value = .deg_master },
        };

        return parseEnumFromString(Education, allocator, edu_str, &mappings);
    }

    // Parse method for CSV line
    pub fn fromCSVLine(allocator: std.mem.Allocator, line: []const u8) !Stdnt {
        var tokens = std.mem.splitSequence(u8, line, ",");

        // Skip header if present
        if (std.mem.startsWith(u8, line, "gender,race_ethnicity")) {
            return error.HeaderRow;
        }

        const gender_token = tokens.next() orelse return error.InvalidFormat;
        const eth_token = tokens.next() orelse return error.InvalidFormat;
        const edu_token = tokens.next() orelse return error.InvalidFormat;
        const lunch_token = tokens.next() orelse return error.InvalidFormat;
        const prep_token = tokens.next() orelse return error.InvalidFormat;
        const math_token = tokens.next() orelse return error.InvalidFormat;
        const read_token = tokens.next() orelse return error.InvalidFormat;
        const write_token = tokens.next() orelse return error.InvalidFormat;

        // Skip any extra columns at the end
        while (tokens.next() != null) {
            // Skip extra columns
        }

        return Stdnt{
            .gender = (try std.fmt.parseInt(u1, gender_token, 10)) == 1,
            .eth = try parseEthnicity(allocator, eth_token),
            .p_edu = try parseEducation(allocator, edu_token),
            .lunch = (try std.fmt.parseInt(u1, lunch_token, 10)) == 1,
            .test_prep = (try std.fmt.parseInt(u1, prep_token, 10)) == 1,
            .math_scr = try std.fmt.parseInt(u7, math_token, 10),
            .read_scr = try std.fmt.parseInt(u7, read_token, 10),
            .writ_scr = try std.fmt.parseInt(u7, write_token, 10),
        };
    }
};

// Helper function to convert boolean to u8
fn boolToU1(value: bool) u1 {
    return if (value) 1 else 0;
}

pub fn main() !void {
    // GeneralPurposeAllocator for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // CLI: first argument is the input CSV file path
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) return error.MissingFileArgument;
    const file_path: []const u8 = args[1];

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const csv_content = try std.fs.cwd().readFileAlloc(allocator, file_path, 1024 * 1024);
    defer allocator.free(csv_content);

    var lines = std.mem.splitSequence(u8, csv_content, "\n");
    var students = std.ArrayListUnmanaged(Stdnt){};
    defer students.deinit(allocator);

    // Parse each line into a Stdnt
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue; // skip empty/whitespace-only lines
        const student = Stdnt.fromCSVLine(allocator, trimmed) catch |err| {
            if (err == error.HeaderRow) continue;
            return err;
        };
        try students.append(allocator, student);
    }

    const new_file = try std.fs.cwd().createFile("output.csv", .{
        .truncate = true, // Overwrite the file if it already exists
    });
    defer new_file.close();

    // Use direct file writes with formatted buffer lines

    // Convert file to updated format
    var line_buf: [256]u8 = undefined;
    for (students.items) |student| {
        // Input data
        const gender_int: u1 = boolToU1(student.gender);
        const eth_int: u3 = @intCast(@intFromEnum(student.eth)); // 5 values
        const edu_int: u3 = @intCast(@intFromEnum(student.p_edu)); // 6 values
        const lunch_int: u1 = boolToU1(student.lunch);
        const prep_int: u1 = boolToU1(student.test_prep);
        const math_int: u7 = student.math_scr;
        const read_int: u7 = student.read_scr;
        const write_int: u7 = student.writ_scr;

        // Pack into a u64
        const packed_value: u64 =
            (@as(u32, gender_int) << 29) |
            (@as(u32, eth_int) << 26) |
            (@as(u32, edu_int) << 23) |
            (@as(u32, lunch_int) << 22) |
            (@as(u32, prep_int) << 21) |
            (@as(u32, math_int) << 14) |
            (@as(u32, read_int) << 7) |
            @as(u32, write_int);

        // Print as hex (e.g., 0x7C81E240)
        // std.debug.print("Packed hex: 0x{X:0>16}\n", .{packed_value});

        const line = try std.fmt.bufPrint(&line_buf, "{}, ", .{packed_value});
        try new_file.writeAll(line);
    }

    // Ensure all data is flushed to disk
    try new_file.sync();
}
