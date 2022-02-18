# frozen_string_literal: true

require_relative "filterman/version"

module Filterman
  def self.included(base)
    base.extend(ClassMethods)
  end

  def apply_filters!(from: :params, on: nil)
    collection_variable_name = "@#{on || controller_name}"
    params = send(from)

    self.class.filters.each do |filter|
      # we set: @companies = filter.apply(on: @companies, from: params)
      instance_variable_set(
        collection_variable_name,
        filter.apply(collection: instance_variable_get(collection_variable_name), params: params)
      )
    end
  end

  module ClassMethods
    def available_filters(*simple_filters, **complex_filters)
      simple_filters.each { |name| filters << Filter.new(name) }
      complex_filters.each { |name, options| filters << Filter.new(name, **options) }
    end

    def filters
      @filters ||= []
    end
  end

  class Filter
    def initialize(name, **options)
      @name = name
      @options = options
    end

    def apply(collection:, params:)
      return collection unless (value = params[name].presence)

      if scope
        collection.send(scope, value)
      elsif query
        query.call(collection, value)
      else
        collection.where(name => value)
      end
    end

    private

    def scope
      options[:scope]
    end

    def query
      options[:query]
    end

    attr_reader :name, :options
  end
end
