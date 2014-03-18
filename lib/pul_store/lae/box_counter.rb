require 'noid'
class PulStore::Lae::BoxCounter

  def self.noid_template
    ".zd"
  end

  @minter = ::Noid::Minter.new(:template => noid_template)
  @pid = $$
  @semaphore = Mutex.new

  def self.valid?(identifier)
    return @minter.valid? identifier
  end

  def self.mint
    @semaphore.synchronize do
      while true
        box_no = self.next_id
        return box_no unless PulStore::Lae::Box.where(prov_metadata__physical_number_tesim: box_no)
      end
    end
  end

  protected

  def self.next_id
    box_no = ''
    File.open(PUL_STORE_CONFIG['lae_box_counter_statefile'], File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      yaml = YAML::load(f.read)
      yaml = { template: noid_template } unless yaml
      minter = ::Noid::Minter.new(yaml)
      box_no = "#{minter.mint}"
      f.rewind
      yaml = YAML::dump(minter.dump)
      f.write yaml
      f.flush
      f.truncate(f.pos)
    end
    return box_no
  end
end
