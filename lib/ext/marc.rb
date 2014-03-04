module MARC

  class Record

    def has_1xx?
      self.tags.any? { |t| ['100','110','111'].include? t }
    end

    def has_any_7xx_without_t?
      self.fields(['700', '710', '711']).select { |df| !df['t'] } != []
    end

    def get_linked_field(src_field)
      if src_field['6']
        idx = src_field['6'].split('-')[1].split('/')[0].to_i - 1
        self.select { |df| df.tag == '880' }[idx]
      end
    end

    # Shamelessly lifted from SolrMARC, with a few changes; no doubt there will
    # be more.
    @@THREE_OR_FOUR_DIGITS = /^(20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1)(\d{2})\.?$/
    @@FOUR_DIGIT_PATTERN_BRACES = /^\[([12]\d{3})\??\]\.?$/
    @@FOUR_DIGIT_PATTERN_ONE_BRACE = /^\[(20|19|18|17|16|15|14|13|12|11|10)(\d{2})/
    @@FOUR_DIGIT_PATTERN_OTHER_1 = /^l(\d{3})/
    @@FOUR_DIGIT_PATTERN_OTHER_2 = /^\[(20|19|18|17|16|15|14|13|12|11|10)\](\d{2})/
    @@FOUR_DIGIT_PATTERN_OTHER_3 = /^\[?(20|19|18|17|16|15|14|13|12|11|10)(\d)[^\d]\]?/
    @@FOUR_DIGIT_PATTERN_OTHER_4 = /i\.e\.\,? (20|19|18|17|16|15|14|13|12|11|10)(\d{2})/
    @@FOUR_DIGIT_PATTERN_OTHER_5 = /^\[?(\d{2})\-\-\??\]?/
    @@BC_DATE_PATTERN = /[0-9]+ [Bb]\.?[Cc]\.?/
    def best_date
      date = nil
      if self['260']['c']
        field_260c = self['260']['c']
        case field_260c
          when @@THREE_OR_FOUR_DIGITS
            date = "#{$1}#{$2}"
          when @@FOUR_DIGIT_PATTERN_BRACES
            date = $1
          when @@FOUR_DIGIT_PATTERN_ONE_BRACE
            date = $1
          when @@FOUR_DIGIT_PATTERN_OTHER_1
            date = "1#{$1}"
          when @@FOUR_DIGIT_PATTERN_OTHER_2
            date = "#{$1}#{$2}"
          when @@FOUR_DIGIT_PATTERN_OTHER_3
            date = "#{$1}#{$2}0"
          when @@FOUR_DIGIT_PATTERN_OTHER_4
            date = "#{$1}#{$2}"
          when @@FOUR_DIGIT_PATTERN_OTHER_5
            date = "#{$1}00"
          when @@BC_DATE_PATTERN
            date = nil
        end
      end
      date ||= self.date_from_008
    end

    def date_from_008
      d = self['008'].value[7,4].gsub 'u', '0'
      d if d =~ /^[0-9]{4}$/
    end

    private
    def self.strip_brackets(date)
      date.gsub(/[\[\]]/, '') 
    end


  end

  class DataField

    @@alpha = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    def format(hsh={})
      codes = hsh.has_key?(:codes) ? hsh[:codes] : @@alpha
      separator = hsh.has_key?(:separator) ? hsh[:separator] : ' '
      exclude_alpha = hsh.has_key?(:exclude_alpha) ? hsh[:exclude_alpha] : []

      exclude_alpha.each { |ex| codes.delete ex }

      subfield_values = []
      self.select { |sf| codes.include? sf.code }.each do |sf|
        subfield_values << sf.value
      end
      subfield_values.join(separator)
    end

    def has_linked_field?
      !self['6'].nil?
    end

  end



end
