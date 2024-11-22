# frozen_string_literal: true

require("ob")

# Functionality for wrangling Urbit `@da`, `@p`, `@q`, `@ux`, etc.
module Aura
  VERSION = "0.1.0"

  def self.version
    VERSION
  end

  # List of all possible prefixes for @p encoding.
  PREFIXES = %w[
    doz mar bin wan sam lit sig hid fid lis sog dir wac sab wis sib
    rig sol dop mod fog lid hop dar dor lor hod fol rin tog sil mir
    hol pas lac rov liv dal sat lib tab han tic pid tor bol fos dot
    los dil for pil ram tir win tad bic dif roc wid bis das mid lop
    ril nar dap mol san loc nov sit nid tip sic rop wit nat pan min
    rit pod mot tam tol sav pos nap nop som fin fon ban mor wor sip
    ron nor bot wic soc wat dol mag pic dav bid bal tim tas mal lig
    siv tag pad sal div dac tan sid fab tar mon ran nis wol mis pal
    las dis map rab tob rol lat lon nod nav fig nom nib pag sop ral
    bil had doc rid moc pac rav rip fal tod til tin hap mic fan pat
    tac lab mog sim son pin lom ric tap fir has bos bat poc hac tid
    hav sap lin dib hos dab bit bar rac par lod dos bor toc hil mac
    tom dig fil fas mit hob har mig hin rad mas hal rag lag fad top
    mop hab nil nos mil fop fam dat nol din hat nac ris fot rib hoc
    nim lar fit wal rap sar nal mos lan don dan lad dov riv bac pol
    lap tal pit nam bon ros ton fod pon sov noc sor lav mat mip fip
  ].freeze

  # List of all possible suffixes for @p encoding.
  SUFFIXES = %w[
    zod nec bud wes sev per sut let ful pen syt dur wep ser wyl sun
    ryp syx dyr nup heb peg lup dep dys put lug hec ryt tyv syd nex
    lun mep lut sep pes del sul ped tem led tul met wen byn hex feb
    pyl dul het mev rut tyl wyd tep bes dex sef wyc bur der nep pur
    rys reb den nut sub pet rul syn reg tyd sup sem wyn rec meg net
    sec mul nym tev web sum mut nyx rex teb fus hep ben mus wyx sym
    sel ruc dec wex syr wet dyl myn mes det bet bel tux tug myr pel
    syp ter meb set dut deg tex sur fel tud nux rux ren wyt nub med
    lyt dus neb rum tyn seg lyx pun res red fun rev ref mec ted rus
    bex leb dux ryn num pyx ryg ryx fep tyr tus tyc leg nem fer mer
    ten lus nus syl tec mex pub rym tuc fyl lep deb ber mug hut tun
    byl sud pem dev lur def bus bep run mel pex dyt byt typ lev myl
    wed duc fur fex nul luc len ner lex rup ned lec ryd lyd fen wel
    nyd hus rel rud nes hes fet des ret dun ler nyr seb hul ryl lud
    rem lys fyn wer ryc sug nys nyl lyn dyn dem lux fed sed bec mun
    lyr tes mud nyt byr sen weg fyr mur tel rep teg pec nel nev fes
  ].freeze

  def bex(n)
    2**n
  end

  def rsh(a, b, c)
    c / bex(bex(a) * b)
  end

  def met(a, b, c = 0)
    b.zero? ? c : met(a, rsh(a, 1, b), c + 1)
  end

  def end_bits(a, b, c)
    c % bex(bex(a) * b)
  end

  def patp2syls(name)
    name.gsub(/[\^~-]/, "").scan(/.{1,3}/)
  end

  def self.valid_pat?(name)
    raise ArgumentError, "valid_pat?: non-string input" unless name.is_a? String

    leading_tilde = name.start_with?("~")

    return false if !leading_tilde || name.length < 4

    syls = patp2syls(name)
    wrong_length = syls.length.odd? && syls.length != 1
    syls_exist = syls.each_with_index.all? do |syl, index|
      if index.odd? || syls.length == 1
        SUFFIXES.include?(syl)
      else
        PREFIXES.include?(syl)
      end
    end

    !wrong_length && syls_exist
  end

  # @p
  module P
    extend Aura

    # Convert a hex-encoded string to a @p-encoded string.
    def self.hex2patp(hex)
      raise ArgumentError, "hex2patp: null input" if hex.nil?

      patp(hex.delete_prefix("0x").to_i(16))
    end

    # Convert a @p-encoded string to a hex-encoded string.
    def self.patp2hex(name)
      raise ArgumentError, "patp2hex: not a valid @p" unless valid_pat?(name)

      syls = patp2syls(name)
      addr = syls.each_with_index.inject("") do |acc, (syl, idx)|
        idx.odd? || syls.length == 1 ? acc + syl2bin(SUFFIXES.index(syl)) : acc + syl2bin(PREFIXES.index(syl))
      end

      bn = addr.to_i(2)
      hex = Ob.fynd(bn).to_s(16)
      hex.length.odd? ? hex.rjust(hex.length + 1, "0") : hex
    end

    # Convert a @p-encoded string to an integer.
    def self.patp2dec(name)
      patp2hex(name).to_i(16)
    rescue ArgumentError
      raise "patp2dec: not a valid @p"
    end

    # Find whether the given @p-encoded string is a galaxy, star, planet, moon,
    # or comet.
    def self.clan(who)
      begin
        name = patp2dec(who)
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

    # Find the parent of the given @p-encoded string.
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

    # Validate a @p-encoded string.
    def self.valid_patp?(str)
      valid_pat?(str) && str == patp(patp2dec(str))
    end

    # Convert a number into a @p-encoded string.
    def self.patp(arg)
      raise ArgumentError, "patp: null input" if arg.nil?

      n = arg.to_i # Assuming arg can be converted to an integer directly
      sxz = Ob.fein(n)
      dyy = met(4, sxz)

      loop_fn = lambda do |tsxz, timp, trep|
        log = end_bits(4, 1, tsxz)
        pre = PREFIXES[rsh(3, 1, log)]
        suf = SUFFIXES[end_bits(3, 1, log)]
        etc = if (timp % 4).zero?
                timp.zero? ? "" : "--"
              else
                "-"
              end

        res = pre + suf + etc + trep

        timp == dyy ? trep : loop_fn.call(rsh(4, 1, tsxz), timp + 1, res)
      end

      dyx = met(3, sxz)

      "~#{dyx <= 1 ? SUFFIXES[sxz] : loop_fn.call(sxz, 0, "")}"
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

    def self.syl2bin(idx)
      idx.to_s(2).rjust(8, "0")
    end
  end

  # @q utility functions.
  module Q
    extend Aura

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
    def self.hex2patq(arg)
      raise ArgumentError, "hex2patq: input must be a string" unless arg.is_a?(String)

      arg = arg.delete_prefix("0x")
      hex = arg.length.odd? ? arg.rjust(arg.length + 1, "0") : arg
      buf = hex.to_s.scan(/../).map(&:hex)
      buf2patq(buf)
    end

    # Convert a @q-encoded string to an integer.
    def self.patq2dec(name)
      patq2hex(name).to_i(16)
    end

    # Convert a @q-encoded string to a hex-encoded string.
    #
    # Note that this preservers leading zero bytes.
    def self.patq2hex(name)
      raise ArgumentError, "patq2hex: not a valid @q" unless P.valid_pat?(name)

      chunks = name.delete_prefix("~").split("-")
      dec2hex = ->(dec) { format("%02x", dec) }
      splat = chunks.map do |chunk|
        syls = chunk[0..2], chunk[3..]
        if syls[1].nil? || syls[1].empty?
          dec2hex.call(SUFFIXES.index(syls[0]))
        else
          dec2hex.call(PREFIXES.index(syls[0])) + dec2hex.call(SUFFIXES.index(syls[1]))
        end
      end

      name.empty? ? "00" : splat.join("")
    end

    # Validate a @q-encoded string.
    # TODO: FINISH ME
    def self.valid_patq?(str)
    end

    def prefix_name(byts)
      byts[1].nil? ? PREFIXES[0] + SUFFIXES[byts[0]] : PREFIXES[byts[0]] + SUFFIXES[byts[1]]
    end

    def name(byts)
      byts[1].nil? ? SUFFIXES[byts[0]] : PREFIXES[byts[0]] + SUFFIXES[byts[1]]
    end

    def alg(pair, chunked)
      pair.length.odd? && chunked.length > 1 ? prefix_name(pair) : name(pair)
    end
  end
end
