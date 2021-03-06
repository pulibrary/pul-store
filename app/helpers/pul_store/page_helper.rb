# Pages Helpers
module PulStore::PageHelper
  def pul_store_page_path(id)
  	"/pages/#{id}"
  end

  def pul_store_iiif_path(id, params={})
    PulStore::ImageServerUtils::build_iiif_request(id, params)
  end

  def pul_store_iiif_info_path(id)
    PulStore::ImageServerUtils::build_iiif_info_request(id)
  end

  def pul_store_iiif_page_info_list(page_list)
    iiif_info_list = page_list.map do |page|
      pul_store_iiif_info_path(page['id'])
    end
  end

  def pul_store_iiif_ids_label_list(page_list)
    iiif_page_label_list = page_list.map do |page|
      {"id" => "#{PulStore::ImageServerUtils::pid_to_iiif_id(page['id'])}.jp2",
       "label" => "#{page['folder_id']} page: #{page['sort_order']}" }
    end
  end

  def pul_store_iiif_pid_info_list(pid_list)
    iiif_info_list = pid_list.map do |pid|
      pul_store_iiif_info_path(pid)
    end
  end

  def pul_store_page_modal_target(id)
    "\##{pul_store_page_model_string(id)}"
  end

  def pul_store_page_model_string(id)
    id.gsub(":", "")
  end

end