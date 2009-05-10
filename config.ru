$:.unshift File.join(File.dirname(__FILE__), "lib")
require "remote_command"

Dir[File.join(File.dirname(__FILE__), "commands", "**", "*.rb")].each do |command_file|
  require File.join(File.dirname(command_file), File.basename(command_file, ".rb"))
end

Module.constants.grep(/Command$/).each do |command_name|
  command = Module.const_get(command_name)
  if command < RemoteCommand && command.respond_to?(:command_name)
    map("/#{command.command_name}") { run(command) }
  end
end
