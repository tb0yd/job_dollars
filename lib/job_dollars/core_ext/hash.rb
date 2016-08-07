
class Hash

  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end

  alias nested_under_indifferent_access with_indifferent_access
end
