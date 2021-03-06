module DataMapper
  
  class ValidationError < StandardError; end
  
  class ObjectNotFoundError < StandardError; end
  
  class MaterializationError < StandardError; end
  
  class RepositoryNotSetupError < StandardError; end
  
  class IncompleteResourceError < StandardError; end
end

class StandardError
  
  def display
    "#{message}\n\t#{backtrace.join("\n\t")}"
  end
end