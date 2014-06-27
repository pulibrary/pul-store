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

end