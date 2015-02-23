require 'minitest/autorun'
require 'alcove'

class TestAlcove < MiniTest::Test
  def setup
    alcoveOptions = OpenStruct.new
    @alcove = Alcove.new(alcoveOptions)
  end

  def test_get_search_directory_dev
    ENV["XCS_SOURCE_DIR"] = nil
    search_directory = @alcove.get_search_directory
    assert_equal(File.join(Etc.getpwuid.dir, "/Library/Developer/Xcode/DerivedData"), search_directory)
  end

  def test_get_search_directory_xcs
    ENV["XCS_SOURCE_DIR"] = "XcodeServer/Source"
    search_directory = @alcove.get_search_directory
    assert_equal("XcodeServer/DerivedData", search_directory)
  end

  def test_extract_percent_from_summary_empty
    summary = ""
    percent = @alcove.extract_percent_from_summary(summary)
    assert_equal(0, percent)
  end

  def test_extract_percent_from_summary_without_lines
    summary = "This is a garbage string"
    percent = @alcove.extract_percent_from_summary(summary)
    assert_equal(0, percent)
  end

  def test_extract_percent_from_summary_less_than_100
    summary = "Reading tracefile alcove-temp/alcove-info.temp\nSummary coverage rate:\n  lines......: 60.5% (3302 of 5457 lines)\n  functions..: 62.2% (906 of 1456 functions)\n  branches...: no data found"
    percent = @alcove.extract_percent_from_summary(summary)
    assert_equal(60.5, percent)
  end

  def test_extract_percent_from_summary_100
    summary = "Reading tracefile alcove-temp/alcove-info.temp\nSummary coverage rate:\n  lines......: 100.0% (3302 of 5457 lines)\n  functions..: 62.2% (906 of 1456 functions)\n  branches...: no data found"
    percent = @alcove.extract_percent_from_summary(summary)
    assert_equal(100.0, percent)
  end

end
