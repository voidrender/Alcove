require 'minitest/autorun'
require 'alcove'

class TestAlcove < MiniTest::Test
  def setup
    alcoveOptions = OpenStruct.new
    @alcove = Alcove.new(alcoveOptions)
  end

  def test_get_search_directory_dev
    search_directory = @alcove.get_search_directory
    assert_equal(File.join(Etc.getpwuid.dir, "/Library/Developer/Xcode/DerivedData"), search_directory)
  end

  def test_get_search_directory_xcs
    ENV["XCS_SOURCE_DIR"] = "XcodeServer/Source"
    search_directory = @alcove.get_search_directory
    assert_equal("XcodeServer/DerivedData", search_directory)
  end

end
