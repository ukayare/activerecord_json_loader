require "active_support/concern"
require "activerecord_json_loader/version"

module ActiverecordJsonLoader
  extend ActiveSupport::Concern
  module ClassMethods
    def import_from_json(filename)
      json_data = self.load_json filename
      case json_data
      when Array
        json_data.each do |row_data|
          self.import_row_data row_data
        end
      when Hash
        self.import_row_data json_data
      end
    end

    def divide_attributes(row_data)
      row_data.partition { |k, _v| self.attribute_names.include? k }.map(&:to_h)
    end

    protected
    def load_json(filename)
      json_data = open(filename) { |io| JSON.load io }
    end

    def import_data(json_data)
      case json_data
      when Array
        json_data.each do |row_data|
          self.import_row_data row_data
        end
      when Hash
        self.import_row_data json_data
      end
    end

    def import_row_data(row_data, klass=self)
      record_instance = if row_data["id"]
                          klass.where(id: row_data["id"]).first_or_initialize
                        else
                          klass.new
                        end
      record_instance.update_row_data row_data
    end
  end

  def update_row_data(row_data)
    self_attributes, another_attributes = self.class.divide_attributes row_data
    self.attributes = self_attributes
    if self.changed?
      self.update_with_version
    end
    relation_updated_flag = another_attributes.any? do |key, value|
      case value
      when Hash
        relation_instance = self.try(key) || self.try("build_#{key}")
        relation_instance.update_row_data value
      when Array
        relation_instances = self.try(key).all
        updated_flag = false
        value.each_with_index do |relation_attributes, i|
          relation_instance = relation_instances[i] || self.try(key).build
          relation_instance.update_row_data relation_attributes
        end
        updated_flag || self.delete_remain_relation(relation_instances[value.size..-1])
      else
        false
      end
    end
    if relation_updated_flag
      self.update_with_version
    end
  end

  def update_with_version
    if self.respond_to? :version
      self.version += 1
    end
    if self.class.respond_to? :with_writable
      self.class.with_writable { self.save! }
    else
      self.save!
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

  def update_relation_instance(relation_name, value)
    relation_instance = self.try(relation_name) || self.try("build_#{relation_name}")
    return false if relation_instance.blank?
    relation_instance.attributes = value
    return false unless relation_instance.changed?
    relation_instance.update_with_version
  end

  def update_relation_instances(relation_name, values)
    relation_instances = self.try(relation_name).all
    updated_flag = false
    values.each_with_index do |relation_attributes, i|
      relation_instance = relation_instances[i] || self.try(relation_name).build
      relation_instance.attributes = relation_attributes
      next unless relation_instance.changed?
      relation_instance.update_with_version
      updated_flag = true
    end
    updated_flag || self.delete_remain_relation(relation_instances[values.size..-1])
  end
end
