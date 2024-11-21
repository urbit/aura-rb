# frozen_string_literal: true

require_relative "aura/version"
require_relative "hoon"

# Functionality for wrangling Urbit `@da`, `@p`, `@q`, `@ux`, etc.
module Aura
  def self.version
    Aura::VERSION
  end

  extend Hoon
end
