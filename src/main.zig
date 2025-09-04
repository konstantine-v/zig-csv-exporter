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
    math_scr: u8,
    read_scr: u8,
    writ_scr: u8,
    total_scr: u16,

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
        const total_token = tokens.next() orelse return error.InvalidFormat;

        return Stdnt{
            .gender = (try std.fmt.parseInt(u8, gender_token, 10)) == 1,
            .eth = try parseEthnicity(allocator, eth_token),
            .p_edu = try parseEducation(allocator, edu_token),
            .lunch = (try std.fmt.parseInt(u8, lunch_token, 10)) == 1,
            .test_prep = (try std.fmt.parseInt(u8, prep_token, 10)) == 1,
            .math_scr = try std.fmt.parseInt(u8, math_token, 10),
            .read_scr = try std.fmt.parseInt(u8, read_token, 10),
            .writ_scr = try std.fmt.parseInt(u8, write_token, 10),
            .total_scr = try std.fmt.parseInt(u16, total_token, 10),
        };
    }
};

// Helper function to convert boolean to u8
fn boolToU8(value: bool) u8 {
    return if (value) 1 else 0;
}

pub fn main() !void {
    // GeneralPurposeAllocator for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // File Selection - TODO Change to specifiy file in CLI
    const file_path = "students.csv";

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
        const line = try std.fmt.bufPrint(&line_buf, "{},{},{},{},{},{},{},{},{}\n", .{ boolToU8(student.gender), @intFromEnum(student.eth), @intFromEnum(student.p_edu), boolToU8(student.lunch), boolToU8(student.test_prep), student.math_scr, student.read_scr, student.writ_scr, student.total_scr });
        try new_file.writeAll(line);
    }
}
