#!/usr/bin/ruby

def gen_info_files(filename)
    puts '> Generating info files...'
    gen_info_cmd = 'geninfo ../*.gcno --no-recursion --output-filename ' + filename
    return system gen_info_cmd
end

def lcov(info_file_name, file_names_to_remove, lcov_file)
    puts '> Running lcov...'
    mapped_files = file_names_to_remove.map { |i| '"' + i.to_s + '"' }.join(" ")
    lcov_cmd = "lcov --remove #{info_file_name} #{mapped_files} > #{lcov_file}"
    return system lcov_cmd
end

def gen_html(output_directory, lcov_filename)
    puts '> Generating HTML files...'
    genhtml_cmd = 'genhtml --output-directory ' + output_directory + ' ' + lcov_filename
    return system genhtml_cmd
end
   
GI_FILE = "alcove-Info.temp"
LCOV_FILE = "alcove-lcov.info"
OUTPUT_DIR = "report"

puts gen_info_files(GI_FILE)
puts lcov(GI_FILE, ["*iPhoneSimulator*"], LCOV_FILE)
puts gen_html(OUTPUT_DIR, LCOV_FILE)

File.delete(GI_FILE)
File.delete(LCOV_FILE)
