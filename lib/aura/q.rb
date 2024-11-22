# frozen_string_literal: true

require_relative("helpers")
require_relative("../hoon")
require_relative("p")

module Aura
  # @q
  module Q
    extend Helpers

    module_function

    # Convert a number to a @q-encoded string.
    def self.patq(arg)
      n = arg.to_i
      buf = n.to_s(16).scan(/../).map(&:hex)
      buf2patq(buf)
    end

    def self.buf2patq(buf)
      # Split the buffer into chunks of 2, with a special case for odd-length buffers
      chunked = if buf.length.odd? && buf.length > 1
                  [[buf[0]]] + buf[1..].each_slice(2).to_a
                else
                  buf.each_slice(2).to_a
                end

      chunked.reduce("~") do |acc, elem|
        acc + (acc == "~" ? "" : "-") + alg(elem, chunked)
      end
    end

    # Convert a hex-encoded string to a @q-encoded string.
    #
    # Note that this preserves leading zero bytes.
    #
    # @param arg [String] The hex-encoded string to convert.
    # @return [String] The @q-encoded string after conversion.
    def self.hex2patq(arg)
      raise ArgumentError, "hex2patq: input must be a string" unless arg.is_a?(String)

      arg = arg.delete_prefix("0x")
      hex = arg.length.odd? ? arg.rjust(arg.length + 1, "0") : arg
      buf = hex.to_s.scan(/../).map(&:hex)
      buf2patq(buf)
    end

    # Convert a @q-encoded string to a hex-encoded string.
    #
    # Note that this preservers leading zero bytes.
    #
    # @param name [String] The @q-encoded string to be converted.
    # @return [String] The hex-encoded string after conversion.
    def self.patq2hex(name)
      raise ArgumentError, "patq2hex: not a valid @q" unless P.valid_pat?(name)
    end

    def prefix_name(byts)
      byts[1].nil? ? prefixes[0] + suffixes[byts[0]] : prefixes[byts[0]] + suffixes[byts[1]]
    end

    def name(byts)
      byts[1].nil? ? suffixes[byts[0]] : prefixes[byts[0]] + suffixes[byts[1]]
    end

    def alg(pair, chunked)
      pair.length.odd? && chunked.length > 1 ? prefix_name(pair) : name(pair)
    end
  end
end
