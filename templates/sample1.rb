require File.join(File.dirname(__FILE__), 'sample')
class Sample1 < Sample
  attr_reader :header
  def initialize
    @header = "HEADER SAMPLE 1"
  end
end