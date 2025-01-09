class Attachment < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  image_accessor :file

  def get_parent_object
    case self.imageable_type
    when "Customer"
      Customer.find(self.imageable_id) rescue nil
    when "Product"
      Product.find(self.imageable_id) rescue nil
    when "Driver"
      Driver.find(self.imageable_id) rescue nil
    when "Supplier"
      Supplier.find(self.imageable_id) rescue nil
    when "Staff"
      Staff.find(self.imageable_id) rescue nil
    when "Vehicle"
      Vehicle.find(self.imageable_id) rescue nil
    when "Legality"
      Legality.find(self.imageable_id) rescue nil
    when "Invoice"
			Invoice.find(self.imageable_id) rescue nil
    when "Taxinvoice"
			Taxinvoice.find(self.imageable_id) rescue nil
    when "Taxinvoiceattachment"
      Taxinvoiceattachment.find(self.imageable_id) rescue nil
    when "Quotationgroup"
			Quotationgroup.find(self.imageable_id) rescue nil
    default
      nil
    end
  end  

  def extension
    if self.file_name[-4]=="."
      self.file_name[-3,3]
    elsif self.file_name[-5]=="."
      self.file_name[-4,4]
    else
      nil
    end
  end

  def slug
    if self.file_name[-4]=="."
      file_name[0..-4].downcase.gsub(/\W/,"-")
    elsif self.file_name[-5]=="."
      file_name[0..-5].downcase.gsub(/\W/,"-")
    else
      nil
    end
  end

  def df_exists?
    File.exists?Rails.root.join("public/system/dragonfly", Rails.env, self.file_uid)
  end

end
