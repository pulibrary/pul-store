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
