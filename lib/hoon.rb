# frozen_string_literal: true

require "murmurhash3"

# Functions from relevant Hoon utility cores.
module Hoon
  # ++  muk
  #
  # See arvo/sys/hoon.hoon
  #
  # @param syd [Integer] The seed for the hash function
  # @param key [Integer] The key
  # @return [Integer] The hash value
  def self.muk(syd, key)
    # Extract the least significant byte and the second byte
    lo = key & 0xff
    hi = (key >> 8) & 0xff

    # Create a string from these two bytes
    kee = [lo, hi].pack("CC")

    # Use murmurhash3 gem to compute the hash
    MurmurHash3::V32.str_hash(kee, syd)
  end

  # See arvo/sys/hoon.hoon
  module Ob
    # A pseudorandom function for j in (0..3)
    def self.F(j, arg)
      raku = [0xb76d5eed, 0xee281300, 0x85bcae01, 0x4b387af7]
      Hoon.muk(raku[j], arg)
    end

    def self.feis(arg)
      Fe(4, 65_535, 65_536, 0xffffffff, method(:F), arg)
    end

    def self.Fe(r, a, b, k, f, m)
      c = fe(r, a, b, f, m)
      c < k ? c : fe(r, a, b, f, c)
    end

    def self.fe(r, a, b, f, m)
      ell = m % a
      arr = m / a

      r.times do |j|
        eff = f.call(j, arr).to_i
        tmp = j.even? ? (ell + eff) % a : (ell + eff) % b
        ell = arr
        arr = tmp
      end

      if r.odd?
        a * arr + ell
      else
        arr == a ? a * arr + ell : a * ell + arr
      end
    end

    def self.tail(arg)
      Fen(4, 65_535, 65_536, 0xffffffff, method(:F), arg)
    end

    def self.Fen(r, a, b, k, f, m)
      c = fen(r, a, b, f, m)
      c < k ? c : fen(r, a, b, f, c)
    end

    def self.fen(r, a, b, f, m)
      ahh = r.odd? ? m / a : m % a
      ale = r.odd? ? m % a : m / a

      l = ale == a ? ahh : ale
      r = ale == a ? ale : ahh

      r.downto(1) do |j|
        eff = f.call(j - 1, l).to_i
        tmp = j.odd? ? ((r + a) - (eff % a)) % a : ((r + b) - (eff % b)) % b
        r = l
        l = tmp
      end

      a * r + l
    end

    def self.fein(arg)
      loop(arg)
    end

    def self.fynd(arg)
      loop(arg)
    end

    def self.loop(pyn)
      lo = pyn & 0xffffffff
      hi = pyn & 0xffffffff00000000

      if (pyn >= 0x10000) && (pyn <= 0xffffffff)
        0x10000 + feis(pyn - 0x10000)
      elsif (pyn >= 0x100000000) && (pyn <= 0xffffffffffffffff)
        hi | loop(lo)
      else
        pyn
      end
    end
  end
end
