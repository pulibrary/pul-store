require 'csv'
# This file should contain all the record creation needed to seed the database 
# with its default values. The data can then be loaded with the rake db:seed 
# (or created alongside the db with db:setup).

# TODO this should be a QA vocab!
MetadataSource.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'metadata_sources.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row|  MetadataSource.create!(row.to_hash) }

# Languages
Language.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'iso639-1.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row|  Language.create!(row.to_hash) }

# LAE Genre terms 
PulStore::Lae::Genre.delete_all
fp = Rails.root.join('db', 'fixtures', 'lae_genres.yml')
YAML.load(File.read(fp)).each do |k,h|
  PulStore::Lae::Genre.create!(h)
end

# LAE Areas
PulStore::Lae::Area.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'lae_areas.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row| PulStore::Lae::Area.create!(row.to_hash) }

# LAE Subjects and Topics
PulStore::Lae::Subject.delete_all
PulStore::Lae::Topic.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'lae_subjects.csv')
csv = CSV.parse(File.read(csv_fp), headers: true, header_converters: :symbol, converters: :all)
csv.each do |row|
  subject_value = row[:subject].strip
  topic_value = row[:topic].strip

  subject = PulStore::Lae::Subject.find_by(value: subject_value)
  if subject.nil?
    subject = PulStore::Lae::Subject.create(value: subject_value)
  end

  topic = PulStore::Lae::Topic.find_by(value: topic_value)
  if topic.nil?
    topic = PulStore::Lae::Topic.create(value: topic_value)
  end

  subject.topics << topic

end
