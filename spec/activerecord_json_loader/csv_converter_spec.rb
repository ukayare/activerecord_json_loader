require 'spec_helper'

describe ActiverecordJsonLoader::CsvConverter do
  describe "#convert_csv_to_hash" do
    context "no relation data" do
      it "success hash converted" do
        result = ActiverecordJsonLoader::CsvConverter.convert_csv_to_hash File.expand_path "../../csv/char.csv", __FILE__
        expected_hash = [
          { "id" => 1, "name" => "hoge", "hp" => 10000 },
          { "id" => 2, "name" => "huga", "hp" => 15000 }
        ]
        expect(result).to eq expected_hash
      end
    end

    context "exist relation data of 1 to N" do
      it "success hash converted" do
        result = ActiverecordJsonLoader::CsvConverter.convert_csv_to_hash File.expand_path "../../csv/char_and_skill.csv", __FILE__
        expected_hash = [
          { "id" => 1, "name" => "hoge", "hp" => 10000, "skill" => [{ "value" => 1 }, { "value" => 2 }] },
          { "id" => 2, "name" => "huga", "hp" => 15000, "skill" => [{ "value" => 3 }, { "value" => 4 }] },
        ]
        expect(result).to eq expected_hash
      end
    end

    context "exist relation data of 1 to 1" do
      it "success hash converted" do
        result = ActiverecordJsonLoader::CsvConverter.convert_csv_to_hash File.expand_path "../../csv/char_and_element.csv", __FILE__
        expected_hash = [
          { "id" => 1, "name" => "hoge", "hp" => 10000, "element" => { "value" => 1, "element_id" => 2 } },
          { "id" => 2, "name" => "huga", "hp" => 15000, "element" => { "value" => 3, "element_id" => 4 } },
        ]
        expect(result).to eq expected_hash
      end
    end

    context "exist relation data of 1 to N and 1" do
      it "success hash converted" do
        result = ActiverecordJsonLoader::CsvConverter.convert_csv_to_hash File.expand_path "../../csv/char_and_skill_and_effect.csv", __FILE__
        expected_hash = [
          { "id" => 1, "name" => "hoge", "hp" => 10000, "skill" => [{ "effect" => { "type_id" => 1 } }, { "effect" => { "type_id" => 2 } }] },
          { "id" => 2, "name" => "huga", "hp" => 15000, "skill" => [{ "effect" => { "type_id" => 3 } }, { "effect" => { "type_id" => 4 } }] },
        ]
        expect(result).to eq expected_hash
      end
    end
  end 
end
