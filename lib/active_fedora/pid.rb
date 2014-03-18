module ActiveFedora
  class UnsavedDigitalObject

    def assign_pid()
      @pid ||= PulStore::IdService.mint
    end

  end
end
