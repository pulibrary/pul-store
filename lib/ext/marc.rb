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

    def get_best_date
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
