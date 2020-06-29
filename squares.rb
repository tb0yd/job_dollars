require 'erb'
require 'csv'
require 'action_view'

class SquareErb
  include ActionView::Helpers::NumberHelper

  def initialize
    @rows = CSV.read(ARGV[0], headers: true)
    @template = File.read('./squares.html.erb')
  end

  def render
    ERB.new(@template).result( binding )
  end
end

File.open("squares.html", "w+") { |f| f << SquareErb.new.render }
