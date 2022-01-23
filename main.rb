begin
  require "gosu"
rescue LoadError
  puts "Failed to load Ruby/Gosu, trying ../ffi-gosu..."
  begin
    require_relative "../ffi-gosu/lib/gosu"
  rescue LoadError
    puts "Failed to load ../ffi-gosu aswell. Please install a gosu variant."
    raise
  end
end

class Window < Gosu::Window
  GAME_ROOT = File.expand_path(".", __dir__)
  PADDING = 4
  PADDING2 = PADDING * 2
  SONG_TIMEOUT = 3_000
  SONG = "battleThemeB.mp3"

  def initialize(*args)
    super

    self.caption = "mojoAL Stutter Trigger"

    @no_mojoal = Gem::Version.new(Gosu::VERSION) < Gem::Version.new("1.4.0")

    @song = Gosu::Song.new("#{GAME_ROOT}/#{SONG}")
    @font = Gosu::Font.new(28)

    @started = false
    @plays = 0

    @started_playing = 0
  end

  def draw
    Gosu.draw_rect(0, 0, width, height, @no_mojoal ? 0xff_800000 : 0xff_aa5500)
    Gosu.draw_rect(PADDING, PADDING, width - PADDING2, height - PADDING2, 0xdd_222222)

    unless @started
      @font.draw_markup("mojoAL is not in use!\n\n    Using <c=f80>Gosu #{Gosu::VERSION}</c>, 1.4.0 required!\n\n    Press TAB to continue anyways.", 10, 10, 10) if @no_mojoal
      @font.draw_text("Press ENTER | RETURN to start...\n\n    CHECK YOUR VOLUME!", 10, 10, 10) unless @no_mojoal
      return
    end

    @font.draw_text("Playing #{(SONG_TIMEOUT * 0.001).round} seconds of #{SONG}", 10, 10, 10) if @song.playing?
    @font.draw_text("Plays: #{@plays}", 10, 10 + @font.height, 10)
    @font.draw_markup("<c=f00>mojoAL not in use!</c>", 10, height - (@font.height + PADDING), 10) if @no_mojoal
  end

  def update
    return unless @started

    if @song.playing?
      @song.stop if Gosu.milliseconds >= @started_playing + SONG_TIMEOUT
    else
      @started_playing = Gosu.milliseconds
      @song.play
      @plays += 1
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_F7
      puts "Fault triggered after #{@plays} songs"
    when Gosu::KB_ENTER, Gosu::KB_RETURN
      return if @no_mojoal

      @started = true
    when Gosu::KB_TAB
      @started = true
    end
  end
end

Window.new(480, 250).show
