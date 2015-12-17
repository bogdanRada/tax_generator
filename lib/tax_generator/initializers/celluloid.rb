Celluloid::Logger::WithBacktrace.class_eval do
  alias_method :original_decorate, :decorate

  def decorate(string)
    return if string.include?('signaled spuriously')
    original_decorate(string)
  end

end
