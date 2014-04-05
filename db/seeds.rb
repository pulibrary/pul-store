# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
require 'rake'

# Languages
Rake::Task["pul_store:reset_languages"].invoke
# Metadata Sources
Rake::Task["pul_store:reset_md_sources"].invoke

# LAE Terminologies
Rake::Task["lae:reset_genres"].invoke
Rake::Task["lae:reset_areas"].invoke
Rake::Task["lae:reset_subjects"].invoke
