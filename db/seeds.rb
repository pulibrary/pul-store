# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

DB_FIXTURES_ROOT = Rails.root.join('db/fixtures')

def load_from_csv(file_name, klass)
  csv_fp = File.join(DB_FIXTURES_ROOT, file_name)
  csv = CSV.parse(File.read(csv_fp), headers: true)
  csv.each do |row| 
    puts "CREATE #{klass.name} #{row}"
    klass.create!(row.to_hash) 
  end
end

def delete_languages
  Language.delete_all
end

def load_languages
  load_from_csv('iso639-2.csv', Language)
end

def reset_languages
  delete_languages
  load_languages
end

def delete_md_sources
  MetadataSource.delete_all
end

def load_md_sources
  load_from_csv('metadata_sources.csv', MetadataSource)
end

def reset_md_sources
  delete_md_sources
  load_md_sources
end

def delete_genres
  PulStore::Lae::Genre.delete_all
end

def load_genres
  load_from_csv('lae_genres.csv', PulStore::Lae::Genre)
end

def reset_genres
  delete_genres
  load_genres
end

def delete_areas
  PulStore::Lae::Area.delete_all
end

def load_areas
  load_from_csv('lae_areas.csv', PulStore::Lae::Area)
end

def reset_areas
  delete_areas
  load_areas
end

def load_subjects
  csv_fp = File.join(DB_FIXTURES_ROOT, 'lae_subjects.csv')
  csv = CSV.parse(File.read(csv_fp), headers: true, header_converters: :symbol, converters: :all)
  csv.each do |row|
    #puts "Create LAE Subject/Category #{row}"
    category_label = row[:category]
    subject_label = row[:subject]
    subject_uri = row[:uri] # may be nil

    category = PulStore::Lae::Category.find_by(label: category_label)
    if category.nil?
      category = PulStore::Lae::Category.create(label: category_label)
    end

    subject = PulStore::Lae::Subject.find_by(label: subject_label)
    if subject.nil?
      subject = PulStore::Lae::Subject.create(label: subject_label, uri: subject_uri, category: category)
    end

  end
end

def delete_subjects
  PulStore::Lae::Category.delete_all
  PulStore::Lae::Subject.delete_all
end

def reset_subjects
  delete_subjects
  load_subjects
end


reset_languages
reset_md_sources
reset_genres
reset_areas
reset_subjects

