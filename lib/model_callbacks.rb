module ModelCallbacks
  def after_init
    names = @@after_init_names[self.class]
    names.each { |name| self.send(name) }
  end

  def self.included(klass)
    class << klass
      alias_method :__new, :new
      def new(*args)
        e = __new(*args)
        e.after_init
        e
      end
    end
  end

  def after_initialize(*names)
    @@after_init_names ||= Hash.new { |h, k| h[k] = [] }
    @@after_init_names[self] = names
  end
end