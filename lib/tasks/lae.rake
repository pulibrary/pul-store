namespace :lae do

  desc "Seed the development environment with fake Boxes and Folders"
  task seed_dev: :environment do
    TEST_BARCODES = YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))
    box_count = 2
    folder_min = 3
    folder_max = 150
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




end
