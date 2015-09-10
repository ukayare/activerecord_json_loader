require 'spec_helper'

describe ActiverecordJsonLoader do
  it 'has a version number' do
    expect(ActiverecordJsonLoader::VERSION).not_to be nil
  end

  describe "#import_from_json" do
    context "single data of json" do
      it "imported data" do
        Char.import_from_json File.expand_path "../json/char.json", __FILE__
        expect(Char.exists?(id: 1)).to be true
      end
    end

    context "array data of json" do
      it "imported data" do
        Char.import_from_json File.expand_path "../json/chars.json", __FILE__
        expect(Char.all.count).to eq 3
      end
    end

    context "from different another data import" do
      it "imported data and changed name" do
        Char.import_from_json File.expand_path "../json/char.json", __FILE__
        expect(Char.find(1).name).not_to eq "huga"
        Char.import_from_json File.expand_path "../json/different_char.json", __FILE__
        expect(Char.find(1).name).to eq "huga"
      end
    end

    context "from same data" do
      it "imported data and changed name" do
        Char.import_from_json File.expand_path "../json/char.json", __FILE__
        before_updated_at = Char.find(1).updated_at
        Char.import_from_json File.expand_path "../json/char.json", __FILE__
        expect(Char.find(1).updated_at).to eq before_updated_at
      end
    end

    context "single layer relational data included" do
      context "when single relation" do
        it "imported data both origin and single relational data" do
          Char.import_from_json File.expand_path "../json/char_char_skill.json", __FILE__
          expect(Char.find(1).name).to eq "hogege"
          expect(CharSkill.exists?(char_id: 1)).to be true
        end
      end

      context "when multi relation" do
        context "when new data" do
          it "imported data both origin and multi relational data" do
            Char.import_from_json File.expand_path "../json/char_char_arousals.json", __FILE__
            expect(Char.find(1).name).to eq "hogege"
            expect(CharArousal.where(char_id: 1).count).to eq 3
          end
        end

        context "when same count data" do
          it "imported data both origin and multi relational data" do
            Char.import_from_json File.expand_path "../json/char_char_arousals.json", __FILE__
            char = Char.find 1
            expect(char.name).to eq "hogege"
            arousal_effects = CharArousal.where(char_id: 1).pluck(:effect_id)
            expect(CharArousal.where(char_id: 1).count).to eq 3
            Char.import_from_json File.expand_path "../json/char_char_arousals_same_count.json", __FILE__
            expect(CharArousal.where(char_id: 1).pluck(:effect_id)).not_to match_array arousal_effects
            expect(CharArousal.where(char_id: 1).count).to eq 3
          end
        end

        context "when different count data" do
          it "imported data both origin and multi relational data and adjust count" do
            Char.import_from_json File.expand_path "../json/char_char_arousals.json", __FILE__
            char = Char.find 1
            expect(char.name).to eq "hogege"
            arousal_effects = CharArousal.where(char_id: 1).pluck(:effect_id)
            expect(CharArousal.where(char_id: 1).count).to eq 3
            Char.import_from_json File.expand_path "../json/char_char_arousals_different_count.json", __FILE__
            expect(CharArousal.where(char_id: 1).pluck(:effect_id)).not_to match_array arousal_effects
            expect(CharArousal.where(char_id: 1).count).to eq 2
          end
        end
      end
    end

    context "multi relational data included" do
      context "when single relation" do
        it "imported data both origin and single relational data" do
          Char.import_from_json File.expand_path "../json/char_char_skill_char_skill_effects.json", __FILE__
          char = Char.find(1)
          expect(char.name).to eq "hogege"
          expect(char.char_skill).not_to be nil
          expect(char.char_skill.char_skill_effects.count).to be 3
        end
      end
    end
  end
end
