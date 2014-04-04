namespace :pul_store do
  @db_fixtures_root = Rails.root.join('db/fixtures')

  desc "Load the PUL Store Language terms"
  task load_languages: :environment do
    load_languages
  end

  desc "Delete the PUL Store Language terms"
  task delete_languages: :environment do
    delete_languages
  end

  desc "Reload (delete and load) the PUL Store Language terms"
  task reset_languages: :environment do
    delete_languages
    load_languages
  end


  desc "Load the PUL Store Metadata Sources"
  task load_md_sources: :environment do
    load_md_sources
  end

  desc "Delete the PUL Store Metadata Sources"
  task delete_md_sources: :environment do
    delete_md_sources
  end

  desc "Reload (delete and load) the PUL Store Metadata Sources"
  task reset_md_sources: :environment do
    delete_md_sources
    load_md_sources
  end

  private

  def delete_languages
    Language.delete_all
  end

  def load_languages
    csv_fp = File.join(@db_fixtures_root, 'iso639-2.csv')
    csv = CSV.parse(File.read(csv_fp), headers: true)
    csv.each do |row| 
      puts "CREATE Language #{row}"
      Language.create!(row.to_hash) 
    end
  end

  def delete_md_sources
    MetadataSource.delete_all
  end

  def load_md_sources
    csv_fp = File.join(@db_fixtures_root, 'metadata_sources.csv')
    csv = CSV.parse(File.read(csv_fp), headers: true)
    csv.each do |row| 
      puts "CREATE MetadataSource #{row}"
      MetadataSource.create!(row.to_hash) 
    end
  end

end
