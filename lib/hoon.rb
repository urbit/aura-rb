# frozen_string_literal: true

require "murmurhash3"

# Functions from relevant Hoon utility cores.
module Hoon
  # ++  muk
  def self.muk(syd, key)
    # Extract the least significant byte and the second byte
    lo = key & 0xff
    hi = (key >> 8) & 0xff

    # Create a string from these two bytes
    kee = [lo, hi].pack("CC")

    # Use murmurhash3 gem to compute the hash
    MurmurHash3::V32.str_hash(kee, syd)
  end

  # ++  ob
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
      loop_fn = lambda do |j, ell, arr|
        if j > r
          if r.odd?
            a * arr + ell
          else
            arr == a ? a * arr + ell : a * ell + arr
          end
        else
          eff = f.call(j - 1, arr) # Assuming f is a Proc/lambda

          tmp = if j.odd?
                  (ell + eff) % a
                else
                  (ell + eff) % b
                end

          loop_fn.call(j + 1, arr, tmp)
        end
      end

      left = m % a
      right = m / a

      loop_fn.call(1, left, right)
    end

    def self.tail(arg)
      Fen(4, 65_535, 65_536, 0xffffffff, method(:F), arg)
    end

    def self.Fen(r, a, b, k, f, m)
      c = fen(r, a, b, f, m)
      c < k ? c : fen(r, a, b, f, c)
    end

    # TODO: FIXME
    def self.fen(r, a, b, f, m)
      # Inner recursive function using Ruby way of doing recursion
      loop_fn = lambda do |j, ell, arr|
        return a * arr + ell if j < 1

        eff = f.call(j - 1, ell) # Assuming f is a Proc/lambda

        # Same comment about deviation from B&R (2002)
        tmp = if j.odd?
                (arr + a - (eff % a)) % a
              else
                (arr + b - (eff % b)) % b
              end

        loop_fn.call(j - 1, tmp, ell)
      end

      ahh = r.odd? ? m / a : m % a
      ale = r.odd? ? m % a : m / a

      left = ale == a ? ahh : ale
      right = ale == a ? ale : ahh

      loop_fn.call(r, left, right)
    end

    def self.fein_loop(pyn)
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

    def self.fein(arg)
      fein_loop(arg)
    end

    def self.fynd_loop(cry)
      lo = cry & 0xffffffff
      hi = cry & 0xffffffff00000000

      if (cry >= 0x10000) && (cry <= 0xffffffff)
        0x10000 + tail(cry - 0x10000)
      elsif (cry >= 0x100000000) && (cry <= 0xffffffffffffffff)
        hi | loop(lo)
      else
        cry
      end
    end

    def self.fynd(arg)
      fynd_loop(arg)
    end
  end
end
