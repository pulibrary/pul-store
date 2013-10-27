class CreatorContributorValidator < ActiveModel::Validator
  def validate(record)
    if ( record.creator.present? && record.contributor.present? )
      record.errors[:base] << "Only creator OR contributor can be specified"
    elsif record.creator.length > 1
      record.errors[:base] << "Only zero one creator can be specified"
    elsif ( record.contributor.present? && record.contributor.length == 1 )
      record.errors[:base] << "Only zero OR MORE THAN one contributor can be specified"
    end
  end
end
