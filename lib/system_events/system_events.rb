module SystemEvents
  class << self
    @enabled = true

    def enabled?
      !!@enabled
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end
  end
end
