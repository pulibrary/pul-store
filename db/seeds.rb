require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# MetadataSources
MetadataSource.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'metadata_sources.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row|  MetadataSource.create!(row.to_hash) }

# Languages
Language.delete_all
csv_fp = Rails.root.join('db', 'fixtures', 'iso639-2.csv')
csv = CSV.parse(File.read(csv_fp), headers: true)
csv.each { |row|  Language.create!(row.to_hash) }
