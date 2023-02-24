require "log"
require "colorize"

class Log
  alias Color = Colorize::Color256 | Colorize::ColorRGB | Symbol
  class_property? colorized
  @@colorized = true
  @@colorbox : Hash(Log::Severity, Hash(Symbol, Color)) = {
    Log::Severity::Trace => {
      :timestamp => :white,
      :severity  => :white,
      :string    => :white,
      :message   => :white,
      :string    => :white,
      :context   => :white,
      :data      => :white,
      :progname  => :white,
      :pid       => :white,
      :source    => :white,
      :exception => :white,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)
    },
    Log::Severity::Debug => {
      :timestamp => :dark_gray,
      :severity  => :dark_gray,
      :message   => :dark_gray,
      :string    => :dark_gray,
      :context   => :dark_gray,
      :data      => :dark_gray,
      :progname  => :dark_gray,
      :pid       => :dark_gray,
      :source    => :dark_gray,
      :exception => :dark_gray,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)
    },
    Log::Severity::Info => {
      :timestamp => :light_green,
      :severity  => :light_green,
      :message   => :light_green,
      :string    => :light_green,
      :context   => :light_green,
      :data      => :light_green,
      :progname  => :light_green,
      :pid       => :light_green,
      :source    => :light_green,
      :exception => :light_green,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)      
    },
    Log::Severity::Warn => {
      :timestamp => :light_yellow,
      :severity  => :light_yellow,
      :message   => :light_yellow,
      :string    => :light_yellow,
      :context   => :light_yellow,
      :data      => :light_yellow,
      :progname  => :light_yellow,
      :pid       => :light_yellow,
      :source    => :light_yellow,
      :exception => :light_yellow,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)      
    },
    Log::Severity::Error => {
      :timestamp => :light_red,
      :severity  => :light_red,
      :message   => :light_red,
      :string    => :light_red,
      :context   => :light_red,
      :data      => :light_red,
      :progname  => :light_red,
      :pid       => :light_red,
      :source    => :light_red,
      :exception => :light_red,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)      
    },
    Log::Severity::Fatal => {
      :timestamp => :light_magenta,
      :severity  => :light_magenta,
      :message   => :light_magenta,
      :string    => :light_magenta,
      :context   => :light_magenta,
      :data      => :light_magenta,
      :progname  => :light_magenta,
      :pid       => :light_magenta,
      :source    => :light_magenta,
      :exception => :light_magenta,
      :dummyANSI => :black,
      :dummy256  => Colorize::Color256.new(0),
      :dummyRGB  => Colorize::ColorRGB.new(0, 0, 0)      
    }
  }

  def self.colorbox
    @@colorbox
  end

  struct StaticFormatter
    @color : Hash(Symbol, Color)

    def initialize(@entry : Log::Entry, @io : IO)
      @color = case @entry.severity
               when Log::Severity::Trace then Log.colorbox[Log::Severity::Trace]
               when Log::Severity::Debug then Log.colorbox[Log::Severity::Debug]
               when Log::Severity::Info  then Log.colorbox[Log::Severity::Info]
               when Log::Severity::Warn  then Log.colorbox[Log::Severity::Warn]
               when Log::Severity::Error then Log.colorbox[Log::Severity::Error]
               when Log::Severity::Fatal then Log.colorbox[Log::Severity::Fatal]
               else                           Log.colorbox[Log::Severity::Trace]
               end.as Hash(Symbol, Color)
    end

    def timestamp
      @io << @entry.timestamp.to_rfc3339(fraction_digits: 3).colorize(@color[:timestamp]).toggle(Log.colorized?)
    end

    def severity
      just_val = Log.colorized? ? 15 : 6
      @entry.severity.label.colorize(@color[:severity]).toggle(Log.colorized?).to_s.rjust(@io, just_val)
    end

    def source(*, before = nil, after = nil)
      if @entry.source.size > 0
        @io << before.colorize(@color[:source]).toggle(Log.colorized?)
        @io << @entry.source.colorize(@color[:source]).toggle(Log.colorized?)
        @io << after.colorize(@color[:source]).toggle(Log.colorized?)
      end
    end

    def string(str) : Nil
      @io << str.colorize(@color[:string]).toggle(Log.colorized?)
    end

    def message
      @io << @entry.message.colorize(@color[:message]).toggle(Log.colorized?)
    end

    def exception(*, before = '\n', after = nil)
      if ex = @entry.exception
        @io << before.colorize(@color[:exception]).toggle(Log.colorized?)
        @io << ex.inspect_with_backtrace.colorize(@color[:exception]).toggle(Log.colorized?)
        @io << after.colorize(@color[:exception]).toggle(Log.colorized?)
      end
    end

    def data(*, before = nil, after = nil) : Nil
      unless @entry.data.empty?
        @io << before.colorize(@color[:data]).toggle(Log.colorized?)
        @io << @entry.data.colorize(@color[:data]).toggle(Log.colorized?)
        @io << after.colorize(@color[:data]).toggle(Log.colorized?)
      end
    end

    def context(*, before = nil, after = nil)
      unless @entry.context.empty?
        @io << before.colorize(@color[:context]).toggle(Log.colorized?)
        @io << @entry.context.colorize(@color[:context]).toggle(Log.colorized?)
        @io << after.colorize(@color[:context]).toggle(Log.colorized?)
      end
    end

    def progname : Nil
      @io << Log.progname.colorize(@color[:progname]).toggle(Log.colorized?)
    end

    def pid(*, before = '#', after = nil)
      @io << before.colorize(@color[:pid]).toggle(Log.colorized?)
      @io << Log.pid.colorize(@color[:pid]).toggle(Log.colorized?)
      @io << after.colorize(@color[:pid]).toggle(Log.colorized?)
    end
  end

  LEVEL = {
    "DEBUG" => Log::Severity::Debug,
    "INFO"  => Log::Severity::Info,
    "WARN"  => Log::Severity::Warn,
    "ERROR" => Log::Severity::Error,
    "FATAL" => Log::Severity::Fatal,
  }
end
