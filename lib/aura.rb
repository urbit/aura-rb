# frozen_string_literal: true

require "aura/helpers"
require "aura/p"
require "aura/q"
require "hoon"

require_relative "aura/version"

# Functionality for wrangling Urbit `@da`, `@p`, `@q`, `@ux`, etc.
module Aura
  def self.version
    Aura::VERSION
  end
end
