require "csv"
class ActiverecordJsonLoader::CsvConverter
  def self.convert_csv_to_hash(filename)
    csvs = CSV.table(filename, header_converters: :downcase)
    hash = csvs.map do |csv|
      self.convert_attributes csv.to_h
    end
    hash
  end

  private

  def self.convert_attributes(csv)
    returned_csv = csv.to_h.dup
    csv.to_h.select { |k, _v| k.include? "." }.group_by { |k, _v| k.split(".").first }.each do |k, v|
      relation_key = k.gsub(/[0-9]+/, "")
      attributes = v.map { |key, value|[key.gsub(/#{k}\./, ""), value] }.to_h
      relation_attributes = attributes.select { |key, _v| key.include? "." }
      if relation_attributes.present?
        attributes.merge!(self.convert_attributes relation_attributes)
        relation_attributes.each do |key, _value|
          attributes.delete key
          returned_csv.delete "#{k}.#{key}"
        end
      end
      if relation_key == k
        returned_csv.merge! relation_key => attributes
      else
        if returned_csv.key? relation_key
          returned_csv[relation_key] << attributes
        else
          returned_csv[relation_key] = [attributes]
        end
      end
      attributes.each { |key, value| returned_csv.delete "#{k}.#{key}" }
    end
    returned_csv
  end
end
