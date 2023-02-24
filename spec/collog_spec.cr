require "./spec_helper"

ENV["LOG_LEVEL"] = "trace"

describe Log do
  it "shows commplete default colorized logging" do
    result = LogCatcher.new.run do |log|
      log.trace { "This is a trace message." }
      log.debug { "This is a debug message." }
      log.info &.emit("This is an info message.", user_id: 42)
      log.warn { "This is a warn message!" }
      log.error { "This is an error message!!" }
      log.fatal(exception: Exception.new("raised!")) { "This is a fatal message!!!" }
    end
    puts result.content
    #pp result.content
    #pp result.colors
    result.colors[:BrightWhite].should eq 5
    result.colors[:BrightBlack].should eq 5
    result.colors[:BrightGreen].should eq 5
    result.colors[:BrightYellow].should eq 5
    result.colors[:BrightRed].should eq 5
    result.colors[:BrightMagenta].should eq 5
  end

  it "shows a different blue customized info message." do
    result = LogCatcher.new(LogCatcher::LongFormat).run do |log|
      Log.colorbox[Log::Severity::Info][:timestamp] = Colorize::Color256.new(17)
      Log.colorbox[Log::Severity::Info][:progname] = Colorize::Color256.new(18)
      Log.colorbox[Log::Severity::Info][:string] = Colorize::Color256.new(18)
      Log.colorbox[Log::Severity::Info][:source] = Colorize::Color256.new(19)
      Log.colorbox[Log::Severity::Info][:pid] = Colorize::Color256.new(20)     
      Log.colorbox[Log::Severity::Info][:severity] = Colorize::Color256.new(21)
      Log.colorbox[Log::Severity::Info][:message] = :light_blue
      log.info { "This is a different blue info message." }
    end
    puts
    puts result.content
    #pp result.content
    #pp result.colors
    result.colors[:Blue17ofColor256].should eq 1
    result.colors[:Blue18ofColor256].should eq 7
    result.colors[:Blue19ofColor256].should eq 3
    result.colors[:Blue20ofColor256].should eq 3
    result.colors[:Blue21ofColor256].should eq 1
    result.colors[:BrightBlue].should eq 1
  end  

  it "shows another colored customized info message." do
    result = LogCatcher.new(LogCatcher::LongFormat).run do |log|
      Log.colorbox[Log::Severity::Info][:timestamp] = Colorize::ColorRGB.new(250,128,114)
      Log.colorbox[Log::Severity::Info][:progname] = Colorize::ColorRGB.new(250,128,114)
      Log.colorbox[Log::Severity::Info][:string] = Colorize::ColorRGB.new(250,128,114)
      Log.colorbox[Log::Severity::Info][:source] = Colorize::ColorRGB.new(250,128,114)
      Log.colorbox[Log::Severity::Info][:pid] = Colorize::ColorRGB.new(250,128,114)     
      Log.colorbox[Log::Severity::Info][:severity] = Colorize::ColorRGB.new(218,165,32)
      Log.colorbox[Log::Severity::Info][:message] = Colorize::ColorRGB.new(218,165,32)
      log.info { "This is another colored info message." }
    end
    puts
    puts result.content
    #pp result.content
    #pp result.colors
    result.colors[:Salmon].should eq 14
    result.colors[:Gold].should eq 2
  end  
end
