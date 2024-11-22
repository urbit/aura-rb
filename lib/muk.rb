# frozen_string_literal: true

require("murmurhash3")

# ++  muk
module Muk
  def self.muk(syd, key)
    # Extract the least significant byte and the second byte
    lo = key & 0xff
    hi = (key >> 8) & 0xff

    # Create a string from these two bytes
    kee = [lo, hi].pack("CC")

    # Use murmurhash3 gem to compute the hash
    MurmurHash3::V32.str_hash(kee, syd)
  end
end
