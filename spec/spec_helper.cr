require "spec"
require "../src/collog"

class LogCatcher
  LOG = ::Log.for self.name

  struct ShortFormat < ::Log::StaticFormatter
    def run
      timestamp
      string " - "
      severity
      string ": "
      message
    end
  end

  struct LongFormat < ::Log::StaticFormatter
    def run
      timestamp
      string " - "
      progname
      string " - "
      source
      string " "
      pid
      string " "
      severity
      string ": "
      message
      string " "
      data
    end
  end

  def initialize(formatter=LogCatcher::ShortFormat)
    @mem = IO::Memory.new
    backend = ::Log::IOBackend.new(@mem, formatter: formatter, dispatcher: ::Log::DispatchMode::Sync)
    ::Log.setup(:trace, backend)
  end

  def run(&code : Log ->)
    code.call LOG
    buffer = Bytes.new @mem.size
    @mem.rewind.read buffer
    log_content = String.new buffer, "UTF8"
    color_stat = ColorStat.new(log_content).calc
    ColorStat::Result.new log_content, color_stat
  end

  class ColorStat
    @regex = Regex.new "\e[[;0-9]+m"
    @colors = {} of Symbol => Int32

    def initialize(@content : String)
    end

    def calc
      @content.scan @regex do |match|
        ansi_esc_seq = match[0]
        color = case ansi_esc_seq
        when "\e[0m" then :reset  
        when "\e[30m" then :Black
        when "\e[31m" then :Red
        when "\e[32m" then :Green
        when "\e[33m" then :Yellow
        when "\e[34m" then :Blue
        when "\e[35m" then :Magenta
        when "\e[36m" then :Cyan
        when "\e[37m" then :White
        when "\e[90m" then :BrightBlack
        when "\e[91m" then :BrightRed
        when "\e[92m" then :BrightGreen
        when "\e[93m" then :BrightYellow
        when "\e[94m" then :BrightBlue
        when "\e[95m" then :BrightMagenta
        when "\e[96m" then :BrightCyan
        when "\e[97m" then :BrightWhite
        when "\e[38;5;17m" then :Blue17ofColor256  
        when "\e[38;5;18m" then :Blue18ofColor256  
        when "\e[38;5;19m" then :Blue19ofColor256  
        when "\e[38;5;20m" then :Blue20ofColor256  
        when "\e[38;5;21m" then :Blue21ofColor256
        when "\e[38;2;250;128;114m" then :Salmon
        when "\e[38;2;218;165;32m" then :Gold
        else :Unknown 
        end
        @colors[color] = 0 unless @colors.has_key? color
        @colors[color] += 1
      end
      @colors
    end

    struct Result
      getter content, colors
      def initialize(@content : String, @colors : Hash(Symbol, Int32))
      end
    end
  end
end
