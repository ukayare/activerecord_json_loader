require "active_support/concern"
require "activerecord_json_loader/version"
require "activerecord_json_loader/csv_converter"

module ActiverecordJsonLoader
  extend ActiveSupport::Concern

  module ClassMethods
    def import_from_csv(filename)
      csv_data = ActiverecordJsonLoader::CsvConverter.convert_csv_to_hash(filename)
      self.import_data csv_data
    end

    def import_from_json(filename)
      json_data = self.load_json filename
      self.import_data json_data
    end

    def divide_attributes(row_data)
      row_data.partition { |k, _v| self.attribute_names.include? k }.map(&:to_h)
    end

    def divide_relation_key(another_attributes)
      relation_keys = self.reflect_on_all_associations.map(&:name).map(&:to_s)
      another_attributes.select { |key, value| relation_keys.include? key }
    end

    def get_latest_version
      # note
      # This method is published full scan query.
      # If you think you undesirable this, this method should be overridden to get the latest version in a different way.
      # ex)
      # * using cache store latest version.
      # * using model for version information.
      if self.attribute_names.include? "version"
        self.maximum("version").to_i
      else
        0
      end
    end

    protected
    def load_json(filename)
      json_data = open(filename) { |io| JSON.load io }
    end

    def import_data(json_data)
      latest_version = self.get_latest_version
      case json_data
      when Array
        json_data.select do |row_data|
          self.import_row_data row_data, latest_version
        end.present?
      when Hash
        self.import_row_data json_data, latest_version
      else
        false
      end
    end

    def import_row_data(row_data, latest_version)
      record_instance = if row_data["id"]
                          self.where(id: row_data["id"]).first_or_initialize
                        else
                          self.new
                        end
      record_instance.update_row_data row_data, latest_version
    end
  end

  def update_row_data(row_data, latest_version)
    origin_updated = false
    relation_updated = false
    self_attributes, another_attributes = self.class.divide_attributes row_data
    origin_updated = self.update_origin self_attributes, latest_version
    return origin_updated if another_attributes.blank?
    relation_updated = self.update_relation another_attributes
    if (!origin_updated && relation_updated)
      self.update_with_version latest_version
      true
    else
      false
    end
  end

  def update_origin(self_attributes, latest_version)
    self_attributes
    self.attributes = self_attributes
    return false unless self.changed?
    self.update_with_version latest_version
    true
  end

  def update_relation(another_attributes)
    latest_version = self.class.get_latest_version
    self.class.divide_relation_key(another_attributes).select do |key, value|
    case value
    when Hash
      relation_instance = self.try(key) || self.try("build_#{key}")
      relation_instance.update_row_data value, latest_version
    when Array
      relation_instances = self.try(key).to_a
        updated_flag = false
        value.each_with_index do |relation_attributes, i|
          relation_instance = relation_instances[i] || self.try(key).build
          relation_updated = relation_instance.update_row_data relation_attributes, latest_version
          updated_flag ||= relation_updated
        end
        relation_deleted = self.delete_remain_relation(relation_instances[value.size..-1])
        updated_flag || relation_deleted
      else
        false
      end
    end.present?
  end


  def update_with_version(latest_version)
    if self.respond_to?(:version)
      self.version = latest_version + 1
    end
    if self.class.respond_to? :with_writable
      self.class.with_writable { self.save }
    else
      self.save
    end
  end

  def delete_remain_relation(remain_instances)
    return false if remain_instances.blank?
    remain_instances.each do |remain_instance|
      if self.class.respond_to? :with_writable
        remain_instance.class.with_writable { remain_instance.destroy }
      else
        remain_instance.destroy
      end
    end
    true
  end
end
