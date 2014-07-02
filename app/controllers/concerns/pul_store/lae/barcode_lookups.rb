module PulStore::Lae::BarcodeLookups
  extend ActiveSupport::Concern
  included do
    def get_box_by_barcode(barcode)
      PulStore::Lae::Box.where(prov_metadata__barcode_tesi: barcode).first
    end

    def get_hard_drive_by_barcode(barcode)
      PulStore::Lae::HardDrive.where(prov_metadata__barcode_tesi: barcode).first
    end
  end
end
