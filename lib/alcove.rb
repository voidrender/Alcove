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
        @search_directory = options.search_directory
        @temp_dir = 'alcove-temp'
    end

    def generate_report
        puts ' 🔍  Generating report...'

        cleanup()
        FileUtils.mkdir(@temp_dir)

        puts ' 📦  Gathering .gcno and .gcda files...' if @verbose
        copy_input_files(@product_name)

        gi_filename_absolute = File.join(@temp_dir, 'alcove-info.temp')
        gen_success = gen_info_files(gi_filename_absolute)
        if gen_success
            puts ' ✅  geninfo successful'.green if @verbose
        else
            STDERR.puts ' 🚫  geninfo failed!'.red
            cleanup()
            return false
        end

        lcov_removals = @remove_filter + ['*iPhoneSimulator*']
        lcov_filename_absolute = File.join(@temp_dir, 'alcove-lcov.info')
        lcov_success = lcov(gi_filename_absolute, lcov_removals, lcov_filename_absolute)
        if lcov_success
            puts ' ✅  lcov successful'.green if @verbose
        else
            STDERR.puts ' 🚫  lcov failed!'.red
            cleanup()
            return false
        end

        genhtml_success = genhtml(@output_directory, lcov_filename_absolute)
        if genhtml_success
            puts '' if @verbose
            puts ' ✅  Successfully generated report'.green
            puts " 🍻  Open #{@output_directory}/index.html to view the report"
        else
            STDERR.puts ' 🚫  genhtml failed!'.red
            cleanup()
            return false
        end

        cleanup()
        return true
    end

private

    def cleanup
        FileUtils.rm_rf(@temp_dir)
    end

    def copy_input_files(product_name)
        derived_data = ''
        if @search_directory
            puts "  Search directory provided." if @verbose
            derived_data = @search_directory
        elsif ENV['XCS_SOURCE_DIR']
            puts "  Xcode Server found." if @verbose
            derived_data = ENV['XCS_SOURCE_DIR'].sub('Source', 'DerivedData')
        else
            puts "  Development machine found." if @verbose
            derived_data = File.join(Etc.getpwuid.dir, "/Library/Developer/Xcode/DerivedData")
        end

        puts "  Searching in #{derived_data}..." if @verbose
        Find.find(derived_data) do |path|
            if path.match(/#{product_name}.*\.gcda\Z/) || path.match(/#{product_name}.*\.gcno\Z/)
                puts "  👍  .#{path.sub(derived_data, "")}".green if @verbose
                FileUtils.cp(path, "#{@temp_dir}/")
            end
        end
    end

    def gen_info_files(filename)
        absolute_temp_dir = File.join(Dir.pwd, @temp_dir)
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
        FileUtils.mkpath(output_directory)
        genhtml_cmd = "genhtml --no-function-coverage --no-branch-coverage --output-directory #{output_directory} #{lcov_filename}"
        genhtml_cmd += ' --quiet' unless @verbose
        return system genhtml_cmd
    end
end
