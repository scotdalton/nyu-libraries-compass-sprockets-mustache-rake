require 'mustache'
class Sample < Mustache
  attr_reader :header
  def initialize
    @header = "HEADER"
  end
end