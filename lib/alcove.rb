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
        copy_input_files(@product_name, temp_dir)

        puts '🔍  Generating report...'
        gen_success = gen_info_files(gi_filename_absolute, temp_dir, @product_name)
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

    def copy_input_files(product_name, temp_dir)
        # TODO: Need to also search XcodeServer dirs
        xcode_base = File.join(Etc.getpwuid.dir, "/Library/Developer/Xcode/DerivedData")

        Find.find(xcode_base) do |path|
            if path.match(/#{product_name}.*\.gcda\Z/) || path.match(/#{product_name}.*\.gcno\Z/)
                FileUtils.cp(path, "#{temp_dir}/")
            end
        end
    end

    def gen_info_files(filename, temp_dir, product_name)
        absolute_temp_dir = File.join(Dir.pwd, temp_dir)
        gen_info_cmd = "geninfo #{absolute_temp_dir}/*.gcno --output-filename #{filename}"
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
