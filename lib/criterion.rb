require "criterion/version"
require "forwardable"

module Criterion
  extend Forwardable

  def_delegators :criteria,
    :where, :not, :order, :limit, :offset, :skip,
    :sum, :maximum, :minimum, :average

  def criteria
    Criteria.new(self)
  end

  class Criteria
    extend Forwardable
    include Enumerable

    MULTI_VALUE_METHODS   = [ :where, :not, :order ]
    SINGLE_VALUE_METHODS  = [ :limit, :offset ]
    RESULT_METHODS = [
      :[], :at, :count, :empty?, :fetch, :first, :include?, :index,
      :last, :length, :reverse, :rindex, :sample, :size, :sort,
      :sort_by, :take, :take_while, :values_at
    ]

    attr_accessor \
      :where_values, :not_values, :order_values,
      :limit_value, :offset_value

    def_delegators :to_a, *RESULT_METHODS

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

    def not(query = {})
      clone.tap do |r|
        r.not_values.merge!(query) unless query.empty?
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

    def average(field)
      total = count
      return nil if total.zero?
      sum(field) / total.to_f
    end

    def sum(field)
      to_a.inject(0) { |sum, obj| sum + obj.send(field) }
    end

    def minimum(field)
      to_a.collect { |x| x.send(field) }.min
    end

    def maximum(field)
      to_a.collect { |x| x.send(field) }.max
    end

    def where?
      !where_values.empty?
    end

    def not?
      !not_values.empty?
    end

    def order?
      !order_values.empty?
    end

    def offset?
      valid_number?(offset_value)
    end

    def limit?
      valid_number?(limit_value)
    end

    def to_a
      results = @records.select{ |record| keep?(record) }
      results = results.sort_by(&ordering_args) if order?
      results = results.drop(offset_value) if offset?
      results = results.take(limit_value) if limit?
      results
    end
    alias_method :all, :to_a
    alias_method :to_ary, :to_a

    def each(&block)
      to_a.each(&block)
    end

    private

    def criteria_matches?(record, values)
      values.all? do |method, value|
        value === record.send(method)
      end
    end

    def keep?(record)
      keep = where? ? criteria_matches?(record, where_values) : true
      exclude = not? ? criteria_matches?(record, not_values) : false
      keep && !exclude
    end

    def ordering_args
      Proc.new do |item|
        order_values.map do |sort|
          next unless [ :asc, :desc ].include?(sort.last)
          sort.last == :desc ? -item.send(sort.first) : item.send(sort.first)
        end
      end
    end

    def valid_number?(value)
      return false unless value.is_a?(Integer)
      value >= 0
    end

  end

end
