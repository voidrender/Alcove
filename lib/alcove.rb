require 'colored'
require 'etc'
require 'find'
require 'fileutils'
require 'ostruct'
require 'optparse'

class Alcove
    def initialize(options)
        @output_directory = options.output_directory
        @product_name = options.product_name
        @remove_filter = options.remove_filter
        @verbose = options.verbose
    end

    def generate_report
        build_dir = get_objects_dir(@product_name)
        if build_dir.length > 0
            puts "✅  Found build directory: #{build_dir}".green if @verbose
        else
            puts "🚫  No build directory found for product name: #{@product_name} ".red
            exit(1)
        end

        temp_dir = 'alcove-temp'
        # geninfo parameters
        gi_filename = 'alcove-info.temp'
        gi_filename_absolute = File.join(temp_dir, gi_filename)
        # lcov parameters
        lcov_filename = 'alcove-lcov.info'
        lcov_filename_absolute = File.join(temp_dir, lcov_filename)
        lcov_system_removals = ['*iPhoneSimulator*']

        FileUtils.rm_rf(temp_dir)
        FileUtils.mkdir(temp_dir)

        puts '🔍  Generating report...'
        gen_success = gen_info_files(gi_filename_absolute, build_dir, temp_dir, @product_name)
        if gen_success
            puts '✅  geninfo successful'.green if @verbose
        else
            puts '🚫  geninfo failed!  Verify value given for --product-name.'.red
            FileUtils.rm_rf(temp_dir)
            exit(1)
        end

        lcov_removals = lcov_system_removals + @remove_filter
        lcov_success = lcov(gi_filename_absolute, lcov_removals, lcov_filename_absolute)
        if lcov_success
            puts '✅  lcov successful'.green if @verbose
        else
            puts '🚫  lcov failed!'.red
            FileUtils.rm_rf(temp_dir)
            exit(1)
        end

        genhtml_success = genhtml(@output_directory, lcov_filename_absolute)
        if genhtml_success
            puts '✅  Successfully generated report'.green
            puts "🍻  Open #{@output_directory}/index.html to view the report"
        else
            puts '🚫  genhtml failed!'.red
            FileUtils.rm_rf(temp_dir)
            exit(1)
        end

        # Clean up temporary files
        FileUtils.rm_rf(temp_dir)
    end

private

    def get_objects_dir(product_name)
        xcode_base = File.join(Etc.getpwuid.dir, "/Library/Developer/Xcode/DerivedData")
        # TODO: This should be more robust.  At the moment, it assumes a lot about the directory structure.
        Dir.entries(xcode_base).each do |entry|
            if entry.include?(product_name)
                return File.join(xcode_base, entry, "Build/Intermediates/#{product_name}.build/Debug-iphonesimulator/#{product_name}.build/Objects-normal/x86_64")
            end
        end

        return ''
    end

    def gen_info_files(filename, build_dir, temp_dir, product_name)
        gen_info_cmd = "geninfo #{build_dir}/*.gcno --output-filename #{filename}"
        gen_info_cmd += ' --quiet' unless @verbose
        return system gen_info_cmd
    end

    def lcov(info_filename, filenames_to_remove, lcov_file)
        all_removals = filenames_to_remove.map { |i| '"' + i.to_s + '"' }.join(" ")
        lcov_cmd = "lcov --remove #{info_filename} #{all_removals} > #{lcov_file}"
        lcov_cmd += ' --quiet' unless @verbose
        return system lcov_cmd
    end


    def genhtml(output_directory, lcov_filename)
        genhtml_cmd = "genhtml --no-function-coverage --no-branch-coverage --output-directory #{output_directory} #{lcov_filename}"
        genhtml_cmd += ' --quiet' unless @verbose
        return system genhtml_cmd
    end
end
