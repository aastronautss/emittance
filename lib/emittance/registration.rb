# @private
class Emittance::Registration
  attr_reader :identifier

  def initialize(identifier, &callback)
    @identifier = identifier
    @callback = callback
  end

  def call(event)
    @callback.call event
  end
end
