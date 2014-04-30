require 'logger'

namespace :lae do

  desc "Seed the development environment with fake Boxes and Folders"
  task seed_dev: :environment do
    TEST_BARCODES = YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))
    box_count = 5
    folder_min = 15
    folder_max = 42
    page_min = 2
    page_max = 11
    project = FactoryGirl.create(:project)
    puts "Project \"#{project.pid}\""

    box_count.times do |bi|
      box = FactoryGirl.create(:lae_box, project: project)
      puts "+-Box #{bi+1} \"#{box.pid}\""
      rand(folder_min .. folder_max).times do |fi|
        folder = FactoryGirl.create(:lae_core_folder, box: box, project: project)
        puts "  +-Folder #{fi+1} \"#{folder.pid}\""
        rand(page_min .. page_max).times do |pi|
          pi+=1
          page = FactoryGirl.create(:page, project: project, folder: folder, text: nil, sort_order: pi)
          puts "    +-Page #{pi} \"#{page.pid}\""
          # folder.save!
          page.save!
        end
      end
    end
  end

  desc 'Ingest a directory that represents a box (run as rake "lae:ingest_box[some/file.jhove.xml]"'
  require File.expand_path('../../pul_store/lae/image_loader', __FILE__) 
  task :ingest_box, [:audit_path_arg] => :environment do |t, args|

    # TODO: should probably have some counters for success vs. fail

    status = 0

    begin # Do everything inside here! ensure exits.

      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO

      # 1. Parse the audit XML
      audit = PulStore::Lae::ImageLoader.parse_audit(args[:audit_path_arg])
      # 2. Check for breakers (fail if any)
      breakers = PulStore::Lae::ImageLoader.validate_audit_for_breakers(audit)
      unless breakers == []
        breakers.each { |problem| logger.fatal problem }
        status = 1
        raise 'There were problems that made this drive unacceptable.'
      end
      # 3. Check for individual errors (OK to continue, so log case by case)
      file_errors = PulStore::Lae::ImageLoader.validate_audit_members(audit)
      # 3.1 Report the errors
      file_errors.each { |e| logger.warn e }


      # 4. Go through and start making jobs that make pages and add them to Folders (yay!)
      # - make sure this includes making JP2s and copying them to the image server

  

    rescue => err

      logger.fatal("#{err.message} Trace follows:")
      err.backtrace.each { |line| logger.fatal line }


    ensure
     
      logger.close
      exit(status)

    end
  end

end
