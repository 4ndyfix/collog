require "../collog"

class SimpleLogExample
  Log = ::Log.for self.name

  def initialize
    ::Log.colorized = true
    ::Log.setup :trace
  end

  def run
    Log.trace { "This is a trace message." }
    Log.debug { "This is a debug message." }
    Log.info { "This is an info message." }
    Log.warn { "This is a warn message!" }
    Log.error { "This is an error message!!" }
    raise "raised!"
  rescue exc
    Log.fatal(exception: exc) { "This is a fatal message!!!" }
  end
end

SimpleLogExample.new.run
