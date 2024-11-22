# frozen_string_literal: true

require_relative("helpers")
require_relative("../hoon")

module Aura
  # @p
  module P
    extend Helpers
    include Hoon

    def self.hex2patp(hex)
      raise ArgumentError, "hex2patp: null input" if hex.nil?

      patp(hex.to_i(16))
    end

    def self.patp2hex(name)
      raise ArgumentError, "patp2hex: not a valid @p" unless valid_pat?(name)

      syls = patp2syls(name)
      addr = syls.each_with_index.inject("") do |acc, (syl, idx)|
        idx.odd? || syls.length == 1 ? acc + syl2bin(suffixes.index(syl)) : acc + syl2bin(prefixes.index(syl))
      end

      bn = addr.to_i(2)
      hex = Ob.fynd(bn).to_s(16)
      hex.length.odd? ? "0x#{hex.rjust(hex.length + 1, "0")}" : "0x#{hex}"
    end

    def self.patp2dec(name)
      patp2hex(name).to_i(16)
    rescue ArgumentError
      raise "patp2dec: not a valid @p"
    end

    def self.clan(who)
      begin
        name = patp2dec(who)
        puts name
      rescue ArgumentError
        raise "clan: not a valid @p"
      end

      wid = met(3, name)
      case wid
      when (0..1) then "galaxy"
      when 2 then "star"
      when (3..4) then "planet"
      when (5..8) then "moon"
      else "comet"
      end
    end

    def self.sein(name)
      begin
        who = patp2dec(name)
        mir = clan(name)
      rescue ArgumentError
        raise "sein: not a valid @p"
      end

      res = case mir
            when "galaxy" then who
            when "star" then end_bits(3, 1, who)
            when "planet" then end_bits(4, 1, who)
            when "moon" then end_bits(5, 1, who)
            else 0
            end
      patp(res)
    end

    def self.valid_patp?(str)
      valid_pat?(str) && str == patp(patp2dec(str))
    end

    def self.patp(arg)
      raise ArgumentError, "patp: null input" if arg.nil?

      n = arg.to_i # Assuming arg can be converted to an integer directly
      sxz = Ob.fein(n)
      dyy = met(4, sxz)

      loop_fn = lambda do |tsxz, timp, trep|
        log = end_bits(4, 1, tsxz)
        pre = prefixes[rsh(3, 1, log)]
        suf = suffixes[end_bits(3, 1, log)]
        etc = if (timp % 4).zero?
                timp.zero? ? "" : "--"
              else
                "-"
              end

        res = pre + suf + etc + trep

        timp == dyy ? trep : loop_fn.call(rsh(4, 1, tsxz), timp + 1, res)
      end

      dyx = met(3, sxz)

      "~#{dyx <= 1 ? suffixes[sxz] : loop_fn.call(sxz, 0, "")}"
    end

    def self.pre_sig(ship)
      return "" if ship.nil? || ship.empty?

      ship.strip.start_with?("~") ? ship.strip : "~#{ship.strip}"
    end

    def self.de_sig(ship)
      return "" if ship.nil? || ship.empty?

      ship.gsub("~", "")
    end

    def self.cite(ship)
      return nil if ship.nil? || ship.empty?

      patp = de_sig(ship)
      case patp.length
      when 56 # comet
        pre_sig("#{patp[0..5]}_#{patp[50..55]}")
      when 27 # moon
        pre_sig("#{patp[14..19]}^#{patp[21..26]}")
      else
        pre_sig(patp)
      end
    end

    private

    #   const syl2bin = (idx: number) => idx.toString(2).padStart(8, '0');
    def self.syl2bin(idx)
      idx.to_s(2).rjust(8, "0")
    end
  end
end
