class HelloCommand < RemoteCommand
  def self.command_name
    "hello"
  end
  
  def call
    if name = arguments.first
      render "Hello, #{name}!"
    else
      render :tcl => ["Hello", "Tcl list"]
    end
  end
end
