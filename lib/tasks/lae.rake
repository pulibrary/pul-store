namespace :lae do
  @db_fixtures_root = Rails.root.join('db/fixtures')

  desc "Load the LAE Genre terms"
  task load_genres: :environment do
    load_lae_genres
  end

  desc "Delete the LAE Genre terms"
  task delete_genres: :environment do
    delete_lae_genres
  end

  desc "Reload (delete and load) the LAE Genre terms"
  task reset_genres: :environment do
    delete_lae_genres
    load_lae_genres
  end

  desc "Load the LAE Area terms"
  task load_areas: :environment do
    load_lae_areas
  end

  desc "Delete the LAE Area terms"
  task delete_areas: :environment do
    delete_lae_areas
  end

  desc "Reload (delete and load) the LAE Area terms"
  task reset_areas: :environment do
    delete_lae_areas
    load_lae_areas
  end

  desc "Load the LAE Subject terms"
  task load_subjects: :environment do
    load_lae_subjects
  end

  desc "Delete the LAE Subject terms"
  task delete_subjects: :environment do
    delete_lae_subjects
  end

  desc "Reload (delete and load) the LAE Subject terms"
  task reset_subjects: :environment do
    delete_lae_subjects
    load_lae_subjects
  end

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

  private
  def delete_lae_genres
    PulStore::Lae::Genre.delete_all
  end

  def load_lae_genres
    csv_fp = File.join(@db_fixtures_root, 'lae_genres.csv')
    csv = CSV.parse(File.read(csv_fp), headers: true)
    csv.each do |row| 
      puts "CREATE LAE Genre #{row}"
      PulStore::Lae::Genre.create!(row.to_hash) 
    end
  end

  def delete_lae_areas
    PulStore::Lae::Area.delete_all
  end

  def load_lae_areas
    csv_fp = File.join(@db_fixtures_root, 'lae_areas.csv')
    csv = CSV.parse(File.read(csv_fp), headers: true)
    csv.each do |row| 
      puts "CREATE LAE Area #{row}"
      PulStore::Lae::Area.create!(row.to_hash) 
    end
  end

  def load_lae_subjects
    csv_fp = File.join(@db_fixtures_root, 'lae_subjects.csv')
    csv = CSV.parse(File.read(csv_fp), headers: true, header_converters: :symbol, converters: :all)
    csv.each do |row|
      puts "Create LAE Subject/Category #{row}"
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

  def delete_lae_subjects
    PulStore::Lae::Category.delete_all
    PulStore::Lae::Subject.delete_all
  end


end
