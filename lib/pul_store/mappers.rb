module PulStore
  module Mappers
    # _tesi
    def self.stored_searchable_single_string
      Solrizer::Descriptor.new(:text_en, :indexed, :stored, :searchable)
    end

    # results in _isi, same as:
    #
    #       index.type :integer
    #       index.as :stored_sortable
    #
    # def self.stored_searchable_single_integer
    #   Solrizer::Descriptor.new(:integer, :indexed, :stored, :searchable)
    # end
  end
end
