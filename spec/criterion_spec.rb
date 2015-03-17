require 'spec_helper'

RSpec.describe Criterion do

  let(:one) { Hashie::Mash.new(name: 'Matt', age: 30) }
  let(:two) { Hashie::Mash.new(name: 'Mark', age: 45) }
  let(:three) { Hashie::Mash.new(name: 'John', age: 50) }

  let(:collection) { [ one, two, three ].extend(described_class) }
  let(:criteria) { collection.where(name: 'Matt') }

  it 'has a version number' do
    expect(Criterion::VERSION).not_to be nil
  end

  context "::Criteria" do

    context "#where" do

      it "returns a criteria" do
        expect(collection.where).to be_a Criterion::Criteria
      end

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

      it "can chain multiple where calles" do
        expect(collection.where(name: 'Matt').where(age: 30).first).to eq one
      end

      it "all arguments must match to return results" do
        expect(collection.where(name: 'Matt', age: 40)).to be_empty
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

    context "#limit" do

      it "limits the number of results" do
        expect(collection.where(age: 0..100).limit(2).count).to eq 2
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

    context "#count" do

      it "totals the results matching the criteria" do
        expect(criteria.count).to eq 1
      end

    end

    context "#first" do

      it "returns the first result matching the criteria" do
        expect(criteria.first.name).to eq 'Matt'
      end

    end

    context "#last" do

      it "returns the last result matching the criteria" do
        expect(criteria.last.name).to eq 'Matt'
      end

    end

  end

end
