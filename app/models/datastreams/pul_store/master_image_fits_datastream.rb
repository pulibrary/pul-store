# Lifted shamelessly from 
# https://github.com/projecthydra/sufia/blob/master/sufia-models/app/models/datastreams/fits_datastream.rb
class PulStore::MasterImageFitsDatastream < ActiveFedora::OmDatastream
  include OM::XML::Document

  def prefix
    'master_tech_metadata__'
  end

  set_terminology do |t|
    t.root(:path => "fits", 
           :xmlns => "http://hul.harvard.edu/ois/xml/ns/fits/fits_output", 
           :schema => "http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd")
    t.identification {
      t.identity {
        t.master_format_label(:path=>{:attribute=>"format"})
        t.master_mime_type(:path=>{:attribute=>"mimetype"}, index_as: [:stored_searchable, :facetable])
      }
    }
    t.fileinfo {
      t.master_file_size(:path=>"size")
      t.master_last_modified(:path=>"lastmodified")
      t.master_filename(:path=>"filename")
      t.master_md5checksum(:path=>"md5checksum")
      # t.rights_basis(:path=>"rightsBasis")
      # t.copyright_basis(:path=>"copyrightBasis")
      # t.copyright_note(:path=>"copyrightNote")
    }
    t.filestatus { 
      t.master_well_formed(:path=>"well-formed", index_as: [:stored_searchable, :facetable])
      t.master_valid(:path=>"valid", index_as: [:stored_searchable, :facetable])
      t.master_status_message(:path=>"message", index_as: [:stored_searchable])
    }
    t.metadata {
      # t.document {
      #   t.file_title(:path=>"title")
      #   t.file_author(:path=>"author")
      #   t.file_language(:path=>"language")
      #   t.page_count(:path=>"pageCount")
      #   t.word_count(:path=>"wordCount")
      #   t.character_count(:path=>"characterCount")
      #   t.paragraph_count(:path=>"paragraphCount")
      #   t.line_count(:path=>"lineCount")
      #   t.table_count(:path=>"tableCount")
      #   t.graphics_count(:path=>"graphicsCount")
      # }
      t.image {
        t.master_byte_order(:path=>"byteOrder")
        t.master_compression(:path=>"compressionScheme")
        t.master_width(:path=>"imageWidth")
        t.master_height(:path=>"imageHeight")
        t.master_color_space(:path=>"colorSpace")
        t.master_profile_name(:path=>"iccProfileName")
        t.master_profile_version(:path=>"iccProfileVersion")
        t.master_orientation(:path=>"orientation")
        t.master_color_map(:path=>"colorMap")
        t.master_image_producer(:path=>"imageProducer", index_as: [:stored_searchable, :facetable])
        t.master_capture_device(:path=>"captureDevice", index_as: [:stored_searchable, :facetable])
        t.master_scanning_software(:path=>"scanningSoftwareName", index_as: [:stored_searchable, :facetable])
        t.master_exif_version(:path=>"exifVersion")
        t.master_gps_timestamp(:path=>"gpsTimeStamp")
        t.master_latitude(:path=>"gpsDestLatitude")
        t.master_longitude(:path=>"gpsDestLongitude")
        t.master_bits_per_sample(:path=>"bitsPerSample")
        t.master_color_space(:path=>"colorSpace")

      }
      # t.text {
      #   t.character_set(:path=>"charset")
      #   t.markup_basis(:path=>"markupBasis")
      #   t.markup_language(:path=>"markupLanguage")
      # }
      # t.audio {
      #   t.duration(:path=>"duration")
      #   t.bit_depth(:path=>"bitDepth")
      #   t.sample_rate(:path=>"sampleRate")
      #   t.channels(:path=>"channels")
      #   t.data_format(:path=>"dataFormatType")
      #   t.offset(:path=>"offset")
      # }
      # t.video {
      #   # Not yet implemented in FITS
      # }
    }
    t.master_format_label(:proxy=>[:identification, :identity, :master_format_label])
    t.master_mime_type(:proxy=>[:identification, :identity, :master_mime_type])
    t.master_file_size(:proxy=>[:fileinfo, :master_file_size])
    t.master_last_modified(:proxy=>[:fileinfo, :master_last_modified])
    t.master_filename(:proxy=>[:fileinfo, :master_filename])
    t.master_md5checksum(:proxy=>[:fileinfo, :master_md5checksum])
    # t.rights_basis(:proxy=>[:fileinfo, :rights_basis])
    # t.copyright_basis(:proxy=>[:fileinfo, :copyright_basis])
    # t.copyright_note(:proxy=>[:fileinfo, :copyright_note])
    t.master_well_formed(:proxy=>[:filestatus, :master_well_formed])
    t.master_valid(:proxy=>[:filestatus, :master_valid])
    t.master_status_message(:proxy=>[:filestatus, :master_status_message])
    # t.file_title(:proxy=>[:metadata, :document, :file_title])
    # t.file_author(:proxy=>[:metadata, :document, :file_author])
    # t.page_count(:proxy=>[:metadata, :document, :page_count])
    # t.file_language(:proxy=>[:metadata, :document, :file_language])
    # t.word_count(:proxy=>[:metadata, :document, :word_count])
    # t.character_count(:proxy=>[:metadata, :document, :character_count])
    # t.paragraph_count(:proxy=>[:metadata, :document, :paragraph_count])
    # t.line_count(:proxy=>[:metadata, :document, :line_count])
    # t.table_count(:proxy=>[:metadata, :document, :table_count])
    # t.graphics_count(:proxy=>[:metadata, :document, :graphics_count])
    t.master_byte_order(:proxy=>[:metadata, :image, :master_byte_order])
    t.master_compression(:proxy=>[:metadata, :image, :master_compression])
    t.master_width(:proxy=>[:metadata, :image, :master_width])
    t.master_height(:proxy=>[:metadata, :image, :master_height])
    t.master_color_space(:proxy=>[:metadata, :image, :master_color_space])
    t.master_profile_name(:proxy=>[:metadata, :image, :master_profile_name])
    t.master_profile_version(:proxy=>[:metadata, :image, :master_profile_version])
    t.master_orientation(:proxy=>[:metadata, :image, :master_orientation])
    t.master_color_map(:proxy=>[:metadata, :image, :master_color_map])
    t.master_image_producer(:proxy=>[:metadata, :image, :master_image_producer])
    t.master_capture_device(:proxy=>[:metadata, :image, :master_capture_device])
    t.master_scanning_software(:proxy=>[:metadata, :image, :master_scanning_software])
    t.master_exif_version(:proxy=>[:metadata, :image, :master_exif_version])
    t.master_gps_timestamp(:proxy=>[:metadata, :image, :master_gps_timestamp])
    t.master_latitude(:proxy=>[:metadata, :image, :master_latitude])
    t.master_longitude(:proxy=>[:metadata, :image, :master_longitude])
    t.master_color_space(:proxy=>[:metadata, :image, :master_color_space])
    t.master_bits_per_sample(:proxy=>[:metadata, :image, :master_bits_per_sample])
    # t.character_set(:proxy=>[:metadata, :text, :character_set])
    # t.markup_basis(:proxy=>[:metadata, :text, :markup_basis])
    # t.markup_language(:proxy=>[:metadata, :text, :markup_language])
    # t.duration(:proxy=>[:metadata, :audio, :duration])
    # t.bit_depth(:proxy=>[:metadata, :audio, :bit_depth])
    # t.sample_rate(:proxy=>[:metadata, :audio, :sample_rate])
    # t.channels(:proxy=>[:metadata, :audio, :channels])
    # t.data_format(:proxy=>[:metadata, :audio, :data_format])
    # t.offset(:proxy=>[:metadata, :audio, :offset])
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.fits(:xmlns => 'http://hul.harvard.edu/ois/xml/ns/fits/fits_output',
               'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
               'xsi:schemaLocation' =>
    "http://hul.harvard.edu/ois/xml/ns/fits/fits_output
    http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd",
               :version => "0.6.0",
               :timestamp => "1/25/12 11:04 AM") {
        xml.identification {
          xml.identity(:format => '', :mimetype => '', 
                       :toolname => 'FITS', :toolversion => '') {
            xml.tool(:toolname => '', :toolversion => '')
            xml.version(:toolname => '', :toolversion => '')
            xml.externalIdentifier(:toolname => '', :toolversion => '')
          }
        }
        xml.fileinfo {
          xml.size(:toolname => '', :toolversion => '')
          xml.creatingApplicatioName(:toolname => '', :toolversion => '',
                                     :status => '')
          xml.lastmodified(:toolname => '', :toolversion => '', :status => '')
          xml.filepath(:toolname => '', :toolversion => '', :status => '')
          xml.filename(:toolname => '', :toolversion => '', :status => '')
          xml.md5checksum(:toolname => '', :toolversion => '', :status => '')
          xml.fslastmodified(:toolname => '', :toolversion => '', :status => '')
        }
        xml.filestatus {
          xml.tag! "well-formed", :toolname => '', :toolversion => '', :status => ''
          xml.valid(:toolname => '', :toolversion => '', :status => '')
        }
        # xml.metadata {
        #   xml.document {
        #     xml.title(:toolname => '', :toolversion => '', :status => '')
        #     xml.author(:toolname => '', :toolversion => '', :status => '')
        #     xml.pageCount(:toolname => '', :toolversion => '')
        #     xml.isTagged(:toolname => '', :toolversion => '')
        #     xml.hasOutline(:toolname => '', :toolversion => '')
        #     xml.hasAnnotations(:toolname => '', :toolversion => '')
        #     xml.isRightsManaged(:toolname => '', :toolversion => '', :status => '')
        #     xml.isProtected(:toolname => '', :toolversion => '')
        #     xml.hasForms(:toolname => '', :toolversion => '', :status => '')
        #   }
        # }
      }
    end
    builder.doc
  end
end
