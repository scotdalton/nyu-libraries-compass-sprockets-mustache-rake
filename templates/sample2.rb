require File.join(File.dirname(__FILE__), 'sample')
class Sample2 < Sample
  attr_reader :header
  def initialize
    @header = "HEADER SAMPLE 2"
  end
end