module ActiveFedora
  class UnsavedDigitalObject

    def assign_pid()
      @pid ||= IdService.mint
    end

  end
end
