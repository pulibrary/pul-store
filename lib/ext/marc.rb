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

    # Shamelessly lifted from SolrMARC, with a few enhancements.
    @@FOUR_DIGIT_PATTERN_BRACES = /\[[12]\d{3,3}\]/
    @@FOUR_DIGIT_PATTERN_ONE_BRACE = /\[[12]\d{3,3}/
    @@FOUR_DIGIT_PATTERN_STARTING_WITH_1_2 = /(20|19|18|17|16|15)[0-9][0-9]/
    @@FOUR_DIGIT_PATTERN_OTHER_1 = /l\d{3}/
    @@FOUR_DIGIT_PATTERN_OTHER_2 = /\[19\]\d{2,2}/
    @@FOUR_DIGIT_PATTERN_OTHER_3 = /\[?(20|19|18|17|16|15)([0-9])[-?0-9]\]?/
    @@FOUR_DIGIT_PATTERN_OTHER_4 = /i\.e\. (20|19|18|17|16|15)[0-9][0-9]/
    @@FOUR_DIGIT_PATTERN_OTHER_5 = /\[?(\d{2,2})\-\-\??\]?/
    @@BC_DATE_PATTERN = /[0-9]+ [Bb][.]?[Cc][.]?/
    @@FOUR_DIGIT_PATTERN = /\d{4,4}/
    def get_best_date
      date = nil
      if self['260']['c']
      else
        date = self.date_from_008
      end
      date
    end

    def date_from_008
      d = self['008'].value[7,4].gsub 'u', '0'
      d if d =~ /^[0-9]{4}$/
    end

  end

  class DataField

    @@alpha = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    def format(codes=@@alpha, separator=' ')
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
