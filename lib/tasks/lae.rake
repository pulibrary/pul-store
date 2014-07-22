require 'logger'
require 'order_up'

namespace :lae do

  desc "Seed the development environment with fake Boxes and Folders"
  task seed_dev: :environment do
    TEST_BARCODES = YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))
    box_count = 2
    folder_min = 3
    folder_max = 250
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
          page = FactoryGirl.create(:page, project: project, folder: folder, text: nil)
          puts "    +-Page #{pi} \"#{page.pid}\""
          # folder.save!
          page.save!
        end
      end
    end
  end

  desc "Seed dev with the Boxes and Folders in the fixtures (for debugging queuing)"
  task seed_queue_fixtures: :environment do

    projects = YAML.load_file(Rails.root.join('db/fixtures/projects.yml'))
    projects.map{ |project| PulStore::Project.create(project) }
    
    box = FactoryGirl.create(:lae_box, barcode: '32101075851483')
    ['32101075851434','32101075851459'].each do |barcode|
      FactoryGirl.create(:lae_core_folder, barcode: barcode, box: box)
    end

    box = FactoryGirl.create(:lae_box, barcode: '32101081556985')
    ['32101093680005','32101093680013'].each do |barcode|
      FactoryGirl.create(:lae_core_folder, barcode: barcode, box: box)
    end

  end

  desc 'Verify the contents of an LAE hard drive (run as rake "lae:verify_drive[some/file.jhove.xml]"'
  task :verify_drive, [:audit_path_arg] => :environment do |t, args|
    require File.expand_path('../../pul_store/lae/jhove_audit_utilities', __FILE__) 
    status = 0

    begin # Do everything inside here. `ensure` exits.

      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO

      # 1. Parse the audit XML
      audit = PulStore::Lae::JhoveAuditUtilities.parse_audit(args[:audit_path_arg])
      # 2. Check for breakers (fail if any)
      breakers = PulStore::Lae::JhoveAuditUtilities.validate_audit_for_breakers(audit, logger: logger)
      unless breakers == []
        breakers.each { |problem| logger.fatal problem }
        status = 1
        raise 'There were problems that made this drive unacceptable.'
      end
      # 3. Check for individual errors (OK to continue, so log case by case)
      file_errors = PulStore::Lae::JhoveAuditUtilities.validate_audit_members(audit, logger: logger)
      # 3.1 Report the errors
      if file_errors.length == 0
        page_args = PulStore::Lae::JhoveAuditUtilities.filter_and_group_images_and_ocr(audit, logger: logger)
        # Write Job args to a yaml file for consumption by PulStore::Lae::ImageLoaderJob        
        out_fp = args[:audit_path_arg].sub(/\.jhove\.xml$/, '.jobs.yml')
        File.open(out_fp, 'w') { |f| f.write page_args.to_yaml }
      else
        file_errors.each { |e| logger.warn e }
      end

    rescue => err

      logger.fatal("#{err.message} Trace follows:")
      err.backtrace.each { |line| logger.fatal line }

    ensure
     
      logger.close
      exit(status)

    end
  end


  desc 'Ingest a directory that represents a box from yaml provided by lae:ingest_drive (run as rake "lae:ingest_box[some/barcode.jobs.yml]"'
  task :ingest_drive, [:jobs_file_arg] => :environment do |t, args|
    require File.expand_path('../../pul_store/lae/jhove_audit_utilities', __FILE__) 
    status = 0
    begin # Do everything inside here. `ensure` exits.

      logger = nil
      if Rails.env.development?
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG
      else
        logger = Logger.new("#{Rails.root}/log/lae_ingest_#{Date.today.strftime('%Y-%m-%d')}.log")
        logger.level = Logger::INFO
      end
      page_args = YAML::load_file(args[:jobs_file_arg])
      page_args.each do |job_args| 
        logger.debug("Job args: #{job_args}")
        job = PulStore::Lae::ImageLoaderJob.new(job_args)
        OrderUp.push(job)
      end

    rescue => err

      logger.fatal("#{err.message} Trace follows:")
      err.backtrace.each { |line| logger.fatal line }

    ensure

      logger.close
      exit(status)

    end
  end



end
