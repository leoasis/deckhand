require 'singleton'

module Deckhand

  def self.configure(&block)
    Configuration.instance.initializer_block = block
  end

  def self.config
    Configuration.instance
  end

  module ConfigurationDSL

    def model(model_class, &block)
      models_config[model_class] = Deckhand::Configuration::ModelConfig.new({
        singular: [:label, :fields_to_show, :show_only],
        defaults: {show: [], exclude: []}
      }, &block)
    end

    def model_label(*methods)
      global_config[:model_label] = methods + global_config[:model_label]
    end

  end

  class Configuration
    include Singleton
    include ConfigurationDSL

    attr_accessor :initializer_block, :models_config, :global_config
    attr_reader :search_config, :models_by_name

    def load_initializer_block
      self.models_config = {}
      self.global_config = {model_label: [:id]}

      # TODO allow only DSL methods to be called
      instance_eval &initializer_block

      @search_config = models_config.map do |model, config|
        if config.search_on
          [model, config.search_on]
        end
      end.compact

      names = models_config.keys.map {|m| [m.to_s, m] }.flatten
      @models_by_name = Hash[*names]
    end

    def reset
      self.models_config = self.global_config = nil
    end

    def has_model?(model)
      models_by_name.keys.include? model.to_s
    end

    def fields_to_show(model)
      models_config[model].show
    end

    # a model's label can either be a symbol name of a method on that model,
    # or a block that will be eval'ed in instance context.
    # it can be defined in the model's configuration block with the "label" keyword,
    # or fall back to the "model_label" keyword at the top level of configuration.
    # the top-level configuration only supports methods, not blocks.
    def label(model)
      models_config[model].label ||= global_config[:model_label].instance_eval do
        detect {|attr| model.method_defined? attr } || last
      end
    end

    def link?(model, field)
      !!field_info(model, field)
    end

    def field_info(model, field)
      # FIXME mongoid-specific, also probably missing some cases
      model.fields.detect {|a, b| a == "#{field}_id" }
    end

    def model_name_for(model, field)
      # FIXME there's probably an easier, more reliable way to do this
      field_info(model, field).last.metadata.instance_eval do
        self[:class_name] || self[:name].capitalize
      end
    end

  end

end