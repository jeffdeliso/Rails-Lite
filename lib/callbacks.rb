module CallBacks
  METHODS = [:index, :create, :new, :edit, :update, :show, :destroy]
  def before_action(method, options = { only: METHODS, except: [] })
  defualt = { only: METHODS, except: [] }
  defualt.merge!(options)
    names = defualt[:only] - defualt[:except]
    names.each do |name|
      m = instance_method(name)
      define_method(name) do
        send(method)
        m.bind(self).call
      end
    end
  end
end