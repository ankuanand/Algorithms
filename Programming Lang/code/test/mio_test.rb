require "test_helper"
require "mio"

class MioTest < Test::Unit::TestCase
  Dir["test/mio/*.mio"].each do |file|
    name = File.basename(file, ".mio")
    
    # Define a test method for each .mio file under test/mio.
    # The test will assert the output of the program is the same as the concatenation of all `# => `
    # markers in the code.
    define_method "test_#{name}" do
      expected = File.read(file).split("\n").map { |l| l[/^ *# => (.*)$/, 1] }.compact.join("\n")
      actual = capture_streams { Mio.load file }.chomp
      assert_equal expected, actual
    end
  end
end