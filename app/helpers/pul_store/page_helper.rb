# Pages Helpers
module PulStore::PageHelper
  def pul_store_page_path(id)
  	"/pages/#{id}"
  end

  def pul_store_iif_path(id)
    PulStore::ImageServerUtils::build_iiif_request(id)
  end

end