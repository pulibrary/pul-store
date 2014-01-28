Rails.env = 'development'

namespace :lae do

  desc "Seed the development environment with fake Boxes and Folders"
  task seed_dev: :environment do
    box_count = 5
    folder_min = 15
    folder_max = 42
    page_min = 2
    page_max = 11
    project = FactoryGirl.create(:project)
    puts "Project \"#{project.pid}\""

    box_count.times do |bi|

      puts "+-Box #{bi+1}"
      @box = FactoryGirl.create(:lae_box, project: project)

      rand(folder_min .. folder_max).times do |fi|

        puts "  +-Folder #{fi+1}"
        @folder = FactoryGirl.create(:lae_core_folder, box: @box, project: project)

        rand(page_min .. page_max).times do |pi|
          pi+=1
          puts "    +-Page #{pi}"
          p = FactoryGirl.create(:page, project: project, sort_order: pi)
          p.folder = @folder
          @folder.save
          p.save
        end
      end
    end

  end

end
