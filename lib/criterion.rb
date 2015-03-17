require "criterion/version"
require "forwardable"

module Criterion
  extend Forwardable

  def_delegators :scoped,
    :where, :order, :limit, :offset, :skip,
    :sum, :maximum, :minimum, :average

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

    def to_a
      results = @records.select do |record|
        where_values.all? do |method, value|
          value === record.send(method)
        end
      end
      results = results.sort_by(&ordering_args) unless order_values.empty?
      results = results.drop(offset_value) if offset_value.is_a?(Integer)
      results = results.take(limit_value) if limit_value.is_a?(Integer)
      results
    end
    alias_method :all, :to_a

    def each(&block)
      to_a.each(&block)
    end

    private

    def ordering_args
      Proc.new do |item|
        order_values.map do |sort|
          next unless [ :asc, :desc ].include?(sort.last)
          sort.last == :desc ? -item.send(sort.first) : item.send(sort.first)
        end
      end
    end

  end

end
