require "active_support/concern"
require "activerecord_json_loader/version"

module ActiverecordJsonLoader
  extend ActiveSupport::Concern
  module ClassMethod
    def self.import_from_json(filename)
      json_data = self.load_json filename
      json_data.each do |row_data|
        self.import_row_data row_data
      end
    end

    def self.load_json(filename)
      json_data = open(filename) { |io| JSON.load io }
    end

    def self.import_row_data(row_data)
      model_attributes, another_attributes = row_data.partition { |k, _v| self.attribute_names.include? k }.map(&:to_h)
      record_instance = if model_attributes["id"]
                          self.where(id: model_attributes["id"]).first_or_initialize
                        else
                          self.new
                        end
      record_instance.attributes = model_attributes
      relation_updated_flag = another_attributes.any? do |key, value|
        case value
        when Hash
          record_instance.update_relation_instance key, value
        when Array
          record_instance.update_relation_instances key, value
        else
          false
        end
      end
      if record_instance.changed? || relation_updated_flag
        record_instance.update_with_version
      end
    end
  end

  def update_with_version
    if self.respond_to? :version
      self.version += 1
    end
    self.class.with_writable { self.save! }
  end

  def delete_remain_relation(remain_instances)
    return false if remain_instances.blank?
    remain_instances.each do |remain_instance|
      remain_instance.class.with_writable { remain_instance.destroy }
    end
    true
  end

  def update_relation_instance(relation_name, value)
    relation_instance = self.try(relation_name) || self.try("build_#{relation_name}")
    return false if relation_instance.blank?
    relation_instance.attributes = value
    return false unless relation_instance.changed?
    relation_instance.class.with_writable { relation_instance.save }
  end

  def update_relation_instances(relation_name, values)
    relation_instances = self.try(relation_name).all
    updated_flag = false
    values.each_with_index do |relation_attributes, i|
      relation_instance = relation_instances[i] || self.try(relation_name).build
      relation_instance.attributes = relation_attributes
      next unless relation_instance.changed?
      relation_instance.class.with_writable { relation_instance.save }
      updated_flag = true
    end
    updated_flag || self.delete_remain_relation(relation_instances[values.size..-1])
  end
end
