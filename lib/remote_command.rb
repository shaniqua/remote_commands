require "tcl"

class RemoteCommand
  def self.call(env)
    if env["REQUEST_METHOD"] == "POST"
      new(Rack::Request.new(env)).response
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end

  attr_reader :request, :command, :arguments, :state

  def initialize(request)
    @request   = request
    @command   = request.params["command"]
    @arguments = request.params["arguments"] || []
    @state     = request.params["state"] || {}
  end
  
  def response
    call
    respond_with(200, :body => @body || "")
  rescue StandardError => e
    respond_with(500, :body => e)
  end
  
  protected
    def render(body)
      raise DoubleRenderError, "tried to render twice" if @body

      if body.is_a?(Hash) && body[:tcl]
        @body = Tcl.array_to_list([*body[:tcl]])
        @type = "application/tcl"
      else
        @body = body.to_s
        @type = "text/plain"
      end
    end
  
    def respond_with(status, options = {})
      body = (options[:body] || "").to_s
      type = (options[:type] || "text/plain").to_s
      [status, {"Content-Type" => type, "Content-Length" => body.length.to_s}, [body]]
    end
end
