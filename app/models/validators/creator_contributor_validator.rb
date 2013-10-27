# TODO needs tests! Not sure that any are getting through

class CreatorContributorValidator < ActiveModel::Validator
  def validate(record)
    if ( record.creator.present? && record.contributor.present? )
      record.errors[:base] << "Only creator OR contributor can be specified"
    elsif ( record.creator.present? && record.creator.target.class == Array ) 
      # class is always ActiveFedora::RdfNode::TermProxy, 
      # hence target.class
      record.errors[:base] << "#{record.creator.target.class} Only zero one creator can be specified"
    elsif ( record.contributor.present?  && 
            (record.contributor.target.length == 1 || 
             record.contributor.target.class == String ) 
          )
      record.errors[:base] << "Only zero OR MORE THAN one contributor can be specified"
    end
  end
end
