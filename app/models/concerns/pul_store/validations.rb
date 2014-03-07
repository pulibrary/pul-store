# "32101067700821"
module PulStore::Validations
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  def validate_shipped_before_received
    unless [shipped_date.blank?, received_date.blank?].any?
      if shipped_date > received_date
        errors.add(:received_date, 'must be later that shipped date.')
      end
    end
  end

  def validate_lae_folder_extent
    unless self.send(:has_extent?)
      errors.add(:base, "Width and height OR a page count is required")
    end
  end

  def validate_barcode_uniqueness
    if self.kind_of?(PulStore::Base) && self.respond_to?(:barcode) && !self.send(:barcode).blank?
      # TODO: if it is a PulStore::Base and has responds to barcode??
      o = self.class.where(prov_metadata__barcode_tesim: self.send(:barcode))
      unless o.count == 0
        errors.add(:barcode, "Barcode \"#{self.send(:barcode)}\" already exists in the system.")
      end
    end
  end

  def validate_barcode
    unless self.send(:barcode).blank?
      calc_check_digit = calculate_barcode_checkdigit(:barcode)
      actual_check_digit = barcode[-1,1].to_i
      unless calc_check_digit == actual_check_digit
        errors.add(:barcode, "Barcode checkdigit is not valid.")
      end
    end
  end

  def validate_page_belongs_to_exactly_one_item
    parent_options = [:folder, :text]
    parent_count = parent_options.select { |po| !self.send(po).nil? }.length
    unless parent_count == 1
      msg = "A page must be a part of exactly one Item. This belongs to #{parent_count}."
      self.errors.add(:base, msg)
    end
  end

  def validate_page_count_is_present
    unless self.page_count.blank?
      errors.add(:page_count, "Page Count Can't Be Filled In when width and height are filled in")
    end
  end

  def validate_width_height_are_present
    unless self.width_in_cm.blank? && self.height_in_cm.blank?
      errors.add(:width_in_cm, "Width cannot be used when page count is filled in")
      errors.add(:height_in_cm, "Height cannot be used when page count is filled in")
    end
  end

  protected
  def calculate_barcode_checkdigit(barcode)
    # To calculate the checksum:
    # Start with the total set to zero
    total = 0
    # and scan the 13 digits from left to right:
    bc_ints = self.send(:barcode).scan(/\d/).map { |i| i.to_i }
    13.times do |i|
      # If the digit is in an even-numbered position (2, 4, 6...) add it to the total.
      if (i+1) % 2 == 0
        total += bc_ints[i]
      # If the digit is in an odd-numbered position (1, 3, 5...):
      else
        # multiply the digit by 2.
        product = bc_ints[i]*2
        # If the product is equal to or greater than 10 subtract 9 from the product.
        product = product - 9 if product >= 10
        # Then add the product to the total.
        total += product
      end
    end
    # After all digits have been processed, divide the total by 10 and take the remainder.
    rem = total % 10
    # If the remainder = 0, that is the check digit. If the remainder is not
    # zero, the check digit is 10 minus the remainder.
    rem == 0 ? 0 : 10-rem
  end

end
