require "criterion/version"
require "forwardable"

module Criterion
  extend Forwardable

  def_delegators :scoped, :where, :order, :limit, :offset, :skip

  def criteria
    @criteria ||= Criteria.new(self)
  end

  def scoped
    criteria.clone
  end

  class Criteria
    extend Forwardable
    include Enumerable

    MULTI_VALUE_METHODS   = [ :where, :order ]
    SINGLE_VALUE_METHODS  = [ :limit, :offset ]

    attr_accessor :where_values, :order_values, :limit_value, :offset_value

    def_delegators :to_a, :first, :last, :count, :include?, :empty?

    def initialize(records)
      @records = records
      MULTI_VALUE_METHODS.each { |v| instance_variable_set(:"@#{v}_values", {}) }
      SINGLE_VALUE_METHODS.each { |v| instance_variable_set(:"@#{v}_value", nil) }
    end

    def where(query = {})
      clone.tap do |r|
        r.where_values.merge!(query) unless query.empty?
      end
    end

    def order(*args)
      sort = {}
      args.collect do |arg|
        sort.merge!(arg.is_a?(Hash) ? arg : { arg => :asc })
      end
      clone.tap do |r|
        r.order_values.merge!(sort) unless sort.empty?
      end
    end

    def limit(value = true)
      clone.tap { |r| r.limit_value = value }
    end

    def offset(value = true)
      clone.tap { |r| r.offset_value = value }
    end
    alias_method :skip, :offset

    def to_a
      results = @records.select do |record|
        where_values.all? do |method, value|
          value === record.send(method)
        end
      end
      results = results.sort_by(&ordering_args)
      results = results.drop(offset_value) if offset_value.is_a?(Integer)
      results = results.take(limit_value) if limit_value.is_a?(Integer)
      results
    end

    def each(&block)
      to_a.each(&block)
    end

    private

    def ordering_args
      Proc.new do |item|
        order_values.map do |sort|
          sort.last == :desc ? -item.send(sort.first) : item.send(sort.first)
        end
      end
    end

  end

end
