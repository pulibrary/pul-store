require 'noid'

# Shamelessly lifted from Sufia/ScholarSphere

class PulStore::IdService

  def self.noid_template
    PUL_STORE_CONFIG['noid_template']
  end

  @minter = ::Noid::Minter.new(:template => noid_template)
  @pid = $$
  @namespace = PUL_STORE_CONFIG['id_namespace']
  @semaphore = Mutex.new

  def self.valid?(identifier)
    # remove the fedora namespace since it's not part of the noid
    noid = identifier.split(":").last
    return @minter.valid? noid
  end

  def self.mint
    @semaphore.synchronize do
      while true
        pid = self.next_id
        return pid unless ActiveFedora::Base.exists?(pid)
      end
    end
  end

  protected

  def self.next_id
    pid = ''
    File.open(PUL_STORE_CONFIG['minter_statefile'], File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      yaml = YAML::load(f.read)
      yaml = {:template => noid_template} unless yaml
      minter = ::Noid::Minter.new(yaml)
      pid = "#{@namespace}:#{minter.mint}"
      f.rewind
      yaml = YAML::dump(minter.dump)
      f.write yaml
      f.flush
      f.truncate(f.pos)
    end
    return pid
  end
end
