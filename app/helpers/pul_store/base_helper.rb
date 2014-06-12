module PulStore::BaseHelper

# map state to a bootstrap label colors
  def pul_store_base_state_to_label(state, bootstrap_elem)
    case state
    when "New"
      return "#{bootstrap_elem}-info"
    when "Error"
      return "#{bootstrap_elem}-warning"
    when "In Production"
      return "#{bootstrap_elem}-success"
    when "Needs QC"
      return "#{bootstrap_elem}-danger"
    when "Has Core Metadata"
      return "#{bootstrap_elem}-primary"
    when "Suppressed"
      return "muted" # should grey out element
    else # Prelim Medatadata
      return "#{bootstrap_elem}-default"
    end
  end

end
