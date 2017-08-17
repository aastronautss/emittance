module SystemEvents
  class Watcher
    def self.watch(identifier)
      ActiveSupport::Notifications.subscribe(identifier) do |name, |
        
      end
    end
  end
end
