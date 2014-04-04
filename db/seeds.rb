require 'csv'
# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

MetadataSource.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'metadata_sources.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row|  MetadataSource.create!(row.to_hash) }

# Languages
Language.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'iso639-2.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row| Language.create!(row.to_hash) }

# LAE Genre terms
PulStore::Lae::Genre.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'lae_genres.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row| PulStore::Lae::Genre.create!(row.to_hash) }

# LAE Areas
PulStore::Lae::Area.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'lae_areas.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row| PulStore::Lae::Area.create!(row.to_hash) }

# LAE Subjects and Topics
PulStore::Lae::Category.delete_all
PulStore::Lae::Subject.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'lae_subjects.csv')
csv = CSV.parse(File.read(csv_fp), headers: true, header_converters: :symbol, converters: :all)
csv.each do |row|
  category_label = row[:category]
  subject_label = row[:subject]
  subject_uri = row[:uri] # may be nil

  category = PulStore::Lae::Category.find_by(label: category_label)
  if category.nil?
    puts "Create LAE Category #{category_label}"
    category = PulStore::Lae::Category.create(label: category_label)
  end

  subject = PulStore::Lae::Subject.find_by(label: subject_label)
  if subject.nil?
    puts "    Create LAE Subject #{subject_label}"
    subject = PulStore::Lae::Subject.create(label: subject_label, uri: subject_uri, category: category)
  end

end
