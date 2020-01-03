# coding: utf-8

# Generates notation (in gly format) for the Epiphany proclamation,
# by default for the next 50 years.

require 'calendarium-romanum'
require 'gly'

# Movable feasts whose dates are part in the Epiphany proclamation,
# as feast symbols defined by calendarium-romanum
FEASTS = %i(ash_wednesday easter_sunday ascension pentecost corpus_christi first_advent_sunday)

class DateToText
  # Parts of generated "text dates", syllabified, in format expected by the Gly parser.
  NUMERALS = [
    nil,
    'prv -- ní -- ho',
    'dru -- hé -- ho',
    'tře -- tí -- ho',
    'čtvr -- té -- ho',
    'pá -- té -- ho',
    'šes -- té -- ho',
    'sed -- mé -- ho',
    'os -- mé -- ho',
    'de -- vá -- té -- ho',
    'de -- sá -- té -- ho',
    'je -- de -- nác -- té -- ho',
    'dva -- nác -- té -- ho',
    'tři -- nác -- té -- ho',
    'čtr -- nác -- té -- ho',
    'pat -- nác -- té -- ho',
    'šest -- nác -- té -- ho',
    'se -- dm -- nác -- té -- ho',
    'o -- sm -- nác -- té -- ho',
    'de -- va -- te -- nác -- té -- ho',
    'dva -- cá -- té -- ho',
    'dva -- cá -- té -- ho prv -- ní -- ho',
    'dva -- cá -- té -- ho dru -- hé -- ho',
    'dva -- cá -- té -- ho tře -- tí -- ho',
    'dva -- cá -- té -- ho čtvr -- té -- ho',
    'dva -- cá -- té -- ho pá -- té -- ho',
    'dva -- cá -- té -- ho šes -- té -- ho',
    'dva -- cá -- té -- ho sed -- mé -- ho',
    'dva -- cá -- té -- ho os -- mé -- ho',
    'dva -- cá -- té -- ho de -- vá -- té -- ho',
    'tři -- cá -- té -- ho',
    'tři -- cá -- té -- ho prv -- ní -- ho',
  ]

  MONTHS = [
    nil,
    'led -- na',
    'ú -- no -- ra',
    'břez -- na',
    'dub -- na',
    'květ -- na',
    'červ -- na',
    'čer -- ven -- ce',
    'srp -- na',
    'zá -- ří',
    'říj -- na',
    'lis -- to -- pa -- du',
    'pro -- sin -- ce',
  ]

  # Takes `Date`, returns it's string representation as it will be chanted.
  def self.call(date)
    NUMERALS[date.day] +
      ' ' +
      MONTHS[date.month]
  end
end

# Each public method (names correspond to feast symbols) returns a snippet of gly notation
# with the date of the movable feast in question.
class GlySnippetForFeast
  # Expects (civil, not liturgical) year for whose Epiphany the proclamation is being generated.
  def initialize(year)
    @year = year
    @parser = Gly::Parser.new
  end

  def ash_wednesday
    make_snippet __method__, initial_pes: false
  end

  def easter_sunday
    make_snippet __method__
  end

  def ascension
    make_snippet __method__
  end

  def pentecost
    make_snippet __method__
  end

  def corpus_christi
    make_snippet __method__
  end

  def first_advent_sunday
    make_snippet __method__, initial_pes: false, final_ornament: false
  end

  protected

  def make_snippet(feast, initial_pes: true, final_ornament: true)
    liturgical_year = feast == :first_advent_sunday ? @year : @year - 1
    date = CalendariumRomanum::Temporale::Dates.public_send(feast, @year)
    lyrics = DateToText.(date)
    lyrics_parsed = @parser.parse_str(lyrics).scores.first.lyrics
    syllable_count =
      lyrics_parsed
        .each_syllable
        .reject {|s| s =~ /\A\s*\Z/ }
        .to_a
        .size

    music =
      (initial_pes ? 'fh ' : 'h ') + # first note
      if final_ornament
        last_word_length = lyrics_parsed.each_word.to_a.last.each_syllable.to_a.count
        raise "last word too short '#{lyrics}'" if last_word_length < 2

        # reciting
        ('h ' * (syllable_count - last_word_length - 3)) +
          # preparatory syllables
          'g h ' +
          # last word
          'i ' +
          ('h ' * (last_word_length - 2))
      else
        ('h ' * (syllable_count - 2))
      end +
      'h.'

    music + "\n" + lyrics
  end
end



year_from = (ARGV[0] || Time.now.year).to_i
year_to = (ARGV[1] || (year_from + 50)).to_i

template = File.read 'template.gly'

out = STDOUT

out.puts "\\header\ntitle: Ohlášení pohyblivých svátků"
(year_from..year_to).each_with_index do |year, i|
  out.puts "\\markup\\pagebreak" if i > 0

  out.puts "\\markup\\section*{#{year}}"
  out.puts

  buffer = template.dup
  glyfier = GlySnippetForFeast.new year

  FEASTS.each do |feast|
    placeholder = "{{#{feast}}}"

    buffer.sub! placeholder, glyfier.send(feast)
  end

  out.puts buffer
end
