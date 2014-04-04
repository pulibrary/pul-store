# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Languages
Rake::Task["pul_store:reset_languages"].execute
# Metadata Sources
Rake::Task["pul_store:reset_md_sources"].execute

# LAE Terminologies
Rake::Task["lae:reset_genres"].execute
Rake::Task["lae:reset_areas"].execute
Rake::Task["lae:reset_subjects"].execute
