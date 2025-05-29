# typed: strict
# frozen_string_literal: true

module CodeTeams
  class Team
    extend T::Sig

    sig { params(config_yml: String).returns(Team) }
    def self.from_yml(config_yml)
      hash = YAML.load_file(config_yml)

      new(
        config_yml: config_yml,
        raw_hash: hash
      )
    end

    sig { params(raw_hash: T::Hash[T.untyped, T.untyped]).returns(Team) }
    def self.from_hash(raw_hash)
      new(
        config_yml: nil,
        raw_hash: raw_hash
      )
    end

    sig { params(plugin: T.class_of(Plugin)).void }
    def self.register_plugin(plugin)
      define_method(plugin.data_accessor_name) do
        plugin.for(self).public_send(plugin.data_accessor_name)
      end
    end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    attr_reader :raw_hash

    sig { returns(T.nilable(String)) }
    attr_reader :config_yml

    sig do
      params(
        config_yml: T.nilable(String),
        raw_hash: T::Hash[T.untyped, T.untyped]
      ).void
    end
    def initialize(config_yml:, raw_hash:)
      @config_yml = config_yml
      @raw_hash = raw_hash
    end

    sig { returns(String) }
    def name
      Plugins::Identity.for(self).identity.name
    end

    sig { returns(String) }
    def to_tag
      CodeTeams.tag_value_for(name)
    end

    sig { params(other: Object).returns(T::Boolean) }
    def ==(other)
      if other.is_a?(CodeTeams::Team)
        name == other.name
      else
        false
      end
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
      name.hash
    end
  end
end
