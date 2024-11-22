# aura-rb

Parsing, conversion, and validation for Urbit date, phonetic name, and number
auras.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add urbit-aura

If bundler is not being used to manage dependencies, install the gem by
executing:

    $ gem install urbit-aura

## Usage

```ruby
require 'aura'

Aura.version # => "0.1.0"

# @p
Aura::P.patp(0) # => "~zod"
Aura::P.patp("0") # => "~zod"
Aura::P.hex2patp("0x12345678") # => "~milbyt-wacmeg"
Aura::P.patp2hex("~zod") # => "00"
Aura::P.patp2dec("~zod") # => 0
Aura::P.clan("~zod") # => "galaxy"
Aura::P.clan("~mastyr-bottec") # => "planet"
Aura::P.sein("~mastyr-bottec") # => "~wanzod"
Aura::P.valid_pat?("~zod") # => true
Aura::P.valid_patp?("invalid") # => false
Aura::P.pre_sig("zod") # => "~zod"
Aura::P.de_sig("~zod") # => "zod"
Aura::P.cite("~mastyr-bottec") # => "~mastyr-bottec"

# @q
Aura::Q.patq(123456) # => "~doznec-fitrys"
Aura::Q.patq("123456") # => "~doznec-fitrys"
Aura::Q.hex2patq("1e240") # => "~doznec-fitrys"
Aura::Q.hex2patq("0x1e240") # => "~doznec-fitrys"
Aura::Q.patq2hex("~doznec-fitrys") # => "0001e240"
Aura::Q.patq2dec("~doznec-fitrys") # => 123456
Aura::Q.valid_patq?("~doznec-fitrys") # => true
Aura::Q.valid_patq?("invalid") # => false
```

## Development

TODO:

- [ ] Tests
- [ ] Dates (`@da`)
- [ ] More numbers (`@uv`, `@ud`, etc...)

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/urbit/aura-rb.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
