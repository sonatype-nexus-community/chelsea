# Chelsea

![Gem](https://img.shields.io/gem/v/chelsea)
[![Gitter](https://badges.gitter.im/sonatype-nexus-community/chelsea.svg)](https://gitter.im/sonatype-nexus-community/chelsea?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![CircleCI](https://circleci.com/gh/sonatype-nexus-community/chelsea.svg?style=shield)](https://circleci.com/gh/sonatype-nexus-community/chelsea)

Chelsea is a CLI application written in Ruby, designed to allow you to scan your RubyGem powered projects and report on any vulnerabilities in your third party dependencies. It is powered by [Sonatype's OSS Index.](https://ossindex.sonatype.org/)

## Usage

Chelsea can be installed with the `gem` command:

```
$ gem install chelsea
```

```
$ chelsea 
 _____  _            _                   
/  __ \| |          | |                  
| /  \/| |__    ___ | | ___   ___   __ _ 
| |    | '_ \  / _ \| |/ __| / _ \ / _` |
| \__/\| | | ||  __/| |\__ \|  __/| (_| |
 \____/|_| |_| \___||_||___/ \___| \__,_|
                                         
                                         
Version: 0.0.11

usage: chelsea [options] ...

Options:
    -f, --file         Path to your Gemfile.lock
    -c, --config       Set persistent config for OSS Index
    -u, --user         Specify OSS Index Username
    -p, --token        Specify OSS Index API Token
    -a, --application  Specify the IQ application id
    -i, --server       Specify the IQ server url
    -iu, --iquser      Specify the IQ username
    -it, --iqpass      Specify the IQ auth token
    -w, --whitelist    Set path to vulnerability whitelist file
    -q, --quiet        Make chelsea only output vulnerable third party dependencies for text output (default: false)
    -t, --format       Choose what type of format you want your report in (default: text) (options: text, json, xml)
    -b, --iq           Use Nexus IQ Server to audit your project
    --version          Print the version
    -h, --help         Show usage
```

### Basic usage

The most basic usage of chelsea would look like:

`chelsea --file Gemfile.lock`

After running this command, you'd see something similar to the following:

```
 _____  _            _                   
/  __ \| |          | |                  
| /  \/| |__    ___ | | ___   ___   __ _ 
| |    | '_ \  / _ \| |/ __| / _ \ / _` |
| \__/\| | | ||  __/| |\__ \|  __/| (_| |
 \____/|_| |_| \___||_||___/ \___| \__,_|
                                         
                                         
Version: 0.0.11
[+] Parsing dependencies ...done.
[+] Parsing Versions ...done.
[+] Making request to OSS Index server ...done.

Audit Results
=============
```

Audit Results will show a list of your third party dependencies, their reverse dependencies (so what brought them in to your project), and if they are vulnerable or not.

### Quiet usage

Running with `--quiet` will only output any vulnerable dependencies found, similar to:

<<<<<<< HEAD
Options:
    -f, --file         path to your Gemfile.lock
    -c, --config       Set persistent config for OSS Index
    -u, --user         Specify OSS Index Username
    -p, --token        Specify OSS Index API Token
    -a, --application  Specify the IQ application id
    -i, --server       Specify the IQ server url
    -iu, --iquser      Specify the IQ username
    -it, --iqpass      Specify the IQ auth token
    -w, --whitelist    Set path to vulnerability whitelist file
    -q, --quiet        make chelsea only output vulnerable third party dependencies for text output (default: false)
    -t, --format       choose what type of format you want your report in (default: text) (options: text, json, xml)
    -b, --sbom         generate an sbom
    --version          print the version
    -h, --help         show usage
=======
```
 _____  _            _                   
/  __ \| |          | |                  
| /  \/| |__    ___ | | ___   ___   __ _ 
| |    | '_ \  / _ \| |/ __| / _ \ / _` |
| \__/\| | | ||  __/| |\__ \|  __/| (_| |
 \____/|_| |_| \___||_||___/ \___| \__,_|
                                         
                                         
Version: 0.0.11
[15/31] - pkg:gem/rake@10.5.0 Vulnerable.
        Required by: domain_name-0.5.20190701
        Required by: equatable-0.6.1
        Required by: pastel-0.7.3
        Required by: public_suffix-4.0.3
        Required by: rspec_junit_formatter-0.4.1
        Required by: slop-4.8.1
        Required by: slop-4.8.0
        Required by: unf-0.1.4
        Required by: unf_ext-0.0.7.7
        Required by: unf_ext-0.0.7.6
>>>>>>> master
```

This can be useful if you are only interested in seeing your vulnerable dependencies, and not the whole list.

### Usage with Formatters

Chelsea can be run with a number of different formatters:

- `json`
- `text` (default)
- `xml` (output is JUnit XML style, useful for treating vulnerable dependencies as failing test cases)

To use the formatters, run Chelsea like so:

`chelsea --file Gemfile.lock --format json`

### Rate Limiting / Setting OSS Index config

Chelsea will cache results from OSS Index, preventing Rate Limiting to occur in most cases. However, usage in CI, or heavy usage of Chelsea from a single IP can run into rate limiting, and the good news is you can [register on OSS Index](https://ossindex.sonatype.org/user/register), and then get your API Token from [your settings](https://ossindex.sonatype.org/user/settings). Once you have that, you can set config for Chelsea like so:

`chelsea --config`

Chelsea will prompt you to save your config, provide your username (email address that you registered on OSS Index with), and API Token, save those, and voila! Your rate limiting should be sufficient for most use cases at this point. If it isn't, get in touch via our GitHub issues, and we can take a look at your use case and potentially partner!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Why Chelsea?

One of the awesome developers at Sonatype was thinking of names, and came upon the [Chelsea filter](https://en.wikipedia.org/wiki/Chelsea_filter). A Chelsea filter is used to separate gemstones, helping gemologists distinguish between real emeralds, and just regular green glass. We felt this tool helps you do something very similar, looking at your RubyGems, and seeing which are pristine, and which are less than ok at the moment.

## Contributing

We care a lot about making the world a safer place, and that's why we created `chelsea`. If you as well want to speed up the pace of software development by working on this project, jump on in! Before you start work, create a new issue, or comment on an existing issue, to let others know you are!

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Chelsea project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sonatype-nexus-community/chelsea/blob/master/CODE_OF_CONDUCT.md).

## The Fine Print

It is worth noting that this is **NOT SUPPORTED** by Sonatype, and is a contribution of ours
to the open source community (read: you!)

Remember:

* Use this contribution at the risk tolerance that you have
* Do NOT file Sonatype support tickets related to `chelsea` support in regard to this project
* DO file issues here on GitHub, so that the community can pitch in

Phew, that was easier than I thought. Last but not least of all:

Have fun creating and using `chelsea` and the [Sonatype OSS Index](https://ossindex.sonatype.org/), we are glad to have you here!

## Getting help

Looking to contribute to our code but need some help? There's a few ways to get information:

* Chat with us on [Gitter](https://gitter.im/sonatype-nexus-community/chelsea)

## Copyright

Copyright (c) 2019 Allister Beharry. See [MIT License](LICENSE.txt) for further details.
