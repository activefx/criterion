require 'spec_helper'

RSpec.describe Criterion do

  let(:one) { Hashie::Mash.new(name: 'Matt', age: 30) }
  let(:two) { Hashie::Mash.new(name: 'Mark', age: 45) }
  let(:three) { Hashie::Mash.new(name: 'John', age: 50) }

  let(:collection) { [ one, two, three ].extend(described_class) }
  let(:criteria) { collection.criteria }

  it "has a version number" do
    expect(Criterion::VERSION).not_to be nil
  end

  it "does not persist criteria state" do
    collection.not(age: Integer)
    expect(collection.where(name: 'Matt')).not_to be_empty
  end

  context "::Criteria" do

    context "#critera" do

      it "returns a Criterion::Criteria" do
        expect(collection.criteria).to be_a Criterion::Criteria
      end

    end

    context "#where" do

      it "can filter by exact value" do
        expect(collection.where(name: 'Matt').first).to eq one
      end

      it "can filter by regular expression" do
        expect(collection.where(name: /J/).first).to eq three
      end

      it "can filter by proc" do
        expect(collection.where(age: ->(age){ age.odd? }).first).to eq two
      end

      it "can filter by class" do
        expect(collection.where(age: Integer).count).to eq 3
      end

      it "can filter by range" do
        expect(collection.where(age: 42..48).first).to eq two
      end

      it "can filter on multiple arguments" do
        expect(collection.where(name: 'Matt', age: 28...32).first).to eq one
      end

      it "can chain multiple where calls" do
        expect(collection.where(name: 'Matt').where(age: 30).first).to eq one
      end

      it "all arguments must match to return results" do
        expect(collection.where(name: 'Matt', age: 40)).to be_empty
      end

    end

    context "where?" do

      it "returns false if there are no where criteria" do
        expect(criteria).not_to be_where
      end

      it "returns true when where criteria is present" do
        expect(collection.where(name: 'Matt')).to be_where
      end

    end

    context "#or" do

      it "provides an alternative to the where conditions" do
        expect(collection.where(name: 'Matt').or(name: 'John').to_a).to eq [ one, three ]
      end

      it "requires where values to provide an alternative" do
        expect(collection.or(name: 'John').to_a).not_to eq [ three ]
      end

      it "works when both values are procs" do
        results = collection
          .where(age: ->(age){ age == 30 })
          .or(age: ->(age){ age == 50 }).to_a
        expect(results).to eq [ one, three ]
      end

    end

    context "#or?" do

      it "returns false if there are no not criteria" do
        expect(criteria).not_to be_or
      end

      it "returns true when not criteria is present" do
        expect(collection.or(name: 'Matt')).to be_or
      end

    end

    context "#not" do

      it "does not include matching values" do
        expect(collection.not(name: 'Matt')).not_to include one
      end

      it "all values must match for result to be excluded" do
        expect(collection.not(name: 'Matt', age: 40)).to include one
      end

    end

    context "not?" do

      it "returns false if there are no not criteria" do
        expect(criteria).not_to be_not
      end

      it "returns true when not criteria is present" do
        expect(collection.not(name: 'Matt')).to be_not
      end

    end

    context "#order" do

      it "sorts the results in ascending order by default" do
        expect(collection.order(:name).first).to eq three
      end

      it "can sort the results in descending order" do
        expect(collection.order(age: :desc).first).to eq three
      end

    end

    context "order?" do

      it "returns false if there are no order criteria" do
        expect(criteria).not_to be_order
      end

      it "returns true when order criteria is present" do
        expect(collection.order(:name)).to be_order
      end

    end

    context "#limit" do

      it "limits the number of results" do
        expect(collection.where(age: 0..100).limit(2).count).to eq 2
      end

    end

    context "limit?" do

      it "returns false if there are no limit criteria" do
        expect(criteria).not_to be_limit
      end

      it "returns true when limit criteria is present" do
        expect(collection.limit(2)).to be_limit
      end

    end

    context "offset" do

      it "skips the specified number of records" do
        expect(collection.where(age: 0..100).offset(1).first).to eq two
      end

      it "is aliased to #skip" do
        expect(criteria.method(:offset)).to eq criteria.method(:skip)
      end

    end

    context "offset?" do

      it "returns false if there are no offset criteria" do
        expect(criteria).not_to be_offset
      end

      it "returns true when offset criteria is present" do
        expect(collection.offset(2)).to be_offset
      end

    end

    context "#count" do

      it "totals the results matching the criteria" do
        expect(collection.where(name: 'Matt').count).to eq 1
      end

    end

    context "#first" do

      it "returns the first result matching the criteria" do
        expect(collection.where(name: 'Matt').first.name).to eq 'Matt'
      end

    end

    context "#last" do

      it "returns the last result matching the criteria" do
        expect(collection.where(name: 'Matt').last.name).to eq 'Matt'
      end

    end

    context "#all" do

      it "returns all results" do
        expect(collection.where.all.count).to eq 3
      end

    end

    context "Calculations" do

      context "#sum" do

        it "totals the numbers for the specified field" do
          expect(collection.where(age: 35..55).sum(:age)).to eq 95
        end

      end

      context "#maximum" do

        it "returns the highest value for the specified field" do
          expect(collection.maximum(:age)).to eq 50
        end

      end

      context "#minimum" do

        it "returns the lowest value for the specified field" do
          expect(collection.minimum(:age)).to eq 30
        end

      end

      context "#average" do

        it "calculates the mean for the specified field" do
          expect(collection.average(:age)).to be_within(0.1).of(41.6)
        end

        it "returns nil if there are no values in the collection" do
          expect(collection.where(age: 0..1).average(:age)).to be_nil
        end

      end

    end

  end

end
