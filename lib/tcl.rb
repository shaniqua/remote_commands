module Tcl
  class << self
    def array_to_list(array)
      array.map { |element| string_to_word(element.to_s) }.join(" ")
    end
    
    def string_to_word(string)
      should_be_braced?(string) ? brace_string(string) : escape_string(string)
    end
    
    private
      def should_be_braced?(string)
        string =~ /^$|\\.|[\s\v$\[]|\\\]|\\\{|\\\}/ &&
          string !~ /(?:^|[^\\])\\$|(?:^|[^\\])\{|(?:^|[^\\])\}/
      end
      
      def brace_string(string)
        "{#{string}}"
      end
      
      def escape_string(string)
        string.gsub(/[\[\]\{\}\"\s\v]/) do |char|
          {"\f"=>"\\f", "\n"=>"\\n", "\r" =>"\\r", "\t"=>"\\t", "\v"=>"\\v"}[char] || "\\#{char}"
        end
      end
  end
end

if __FILE__ == $0
  require "test/unit"

  class TclWordTest < Test::Unit::TestCase
    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end
  
    def assert_braced(string)
      assert_equal ["{", "}"], [string[0, 1], string[-1, 1]], "#{string.inspect} is not braced"
    end
  
    def assert_not_braced(string)
      assert_not_equal ["{", "}"], [string[0, 1], string[-1, 1]], "#{string.inspect} is braced"
    end
  
    def word(string)
      Tcl.string_to_word(string)
    end
    
    test :"an empty string should be braced" do
      assert_braced word("")
    end
  
    test :"a string that contains whitespace should be braced" do
      assert_braced word(" ")
      assert_braced word("\f")
      assert_braced word("\n")
      assert_braced word("\r")
      assert_braced word("\t")
      assert_braced word("\v")
    end
  
    test :"a string that contains a dollar sign should be braced" do
      assert_braced word("$")
    end
  
    test :"a string that contains an open-bracket should be braced" do
      assert_braced word("[")
    end

    test :"a string that contains an escaped close-bracket should be braced" do
      assert_braced word("\\]")
    end

    test :"a string that contains an escaped open-brace should be braced" do
      assert_braced word("\\{")
    end
  
    test :"a string that contains an escaped close-brace should be braced" do
      assert_braced word("\\}")
    end
  
    test :"a string that otherwise should be braced but ends in a backslash should not be braced" do
      assert_not_braced word("\\")
      assert_not_braced word(" \\")
      assert_not_braced word("$\\")
      assert_not_braced word("[\\")
    end

    test :"a string that ends in an escaped backslash should be braced" do
      assert_braced word("\\\\")
    end

    test :"a string that otherwise should be braced but contains an unescaped open-brace should not be braced" do
      assert_not_braced word("{")
      assert_not_braced word(" {")
      assert_not_braced word("${")
      assert_not_braced word("[{")
    end
  
    test :"a string that otherwise should be braced but contains an unescaped close-brace should not be braced" do
      assert_not_braced word("}")
      assert_not_braced word(" }")
      assert_not_braced word("$}")
      assert_not_braced word("[}")
    end
      
    test :"open-brackets should be escaped in an unbraced string" do
      assert_equal "\\[\\", word("[\\")
    end
  
    test :"close-brackets should be escaped in an unbraced string" do
      assert_equal "\\]\\", word("]\\")
    end
  
    test :"open-braces should be escaped in an unbraced string" do
      assert_equal "\\{\\", word("{\\")
    end
  
    test :"close-braces should be escaped in an unbraced string" do
      assert_equal "\\}\\", word("}\\")
    end
  
    test :"quotes should be escaped in an unbraced string" do
      assert_equal "\\\"\\", word("\"\\")
    end
  
    test :"spaces should be escaped in an unbraced string" do
      assert_equal "\\ \\", word(" \\")
    end

    test :"newlines should be escaped in an unbraced string" do
      assert_equal "\\n\\", word("\n\\")
    end
  
    test :"carriage returns should be escaped in an unbraced string" do
      assert_equal "\\r\\", word("\r\\")
    end

    test :"tabs should be escaped in an unbraced string" do
      assert_equal "\\t\\", word("\t\\")
    end
  
    test :"vertical tabs should be escaped in an unbraced string" do
      assert_equal "\\v\\", word("\v\\")
    end
  
    test :"form-feeds should be escaped in an unbraced string" do
      assert_equal "\\f\\", word("\f\\")
    end
  end
end
