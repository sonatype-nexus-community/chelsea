<!--

    Copyright 2019-Present Sonatype Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->

<p align="center">
    <img src="https://github.com/sonatype-nexus-community/chelsea/blob/master/docs/images/chelsea.png" width="350"/>
</p>
<p align="center">
    <a href="https://rubygems.org/gems/chelsea"><img src="https://img.shields.io/gem/v/chelsea" /></a>
    <a href="https://gitter.im/sonatype-nexus-community/chelsea?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge"><img src="https://badges.gitter.im/sonatype-nexus-community/chelsea.svg" /></a>
    <a href="https://circleci.com/gh/sonatype-nexus-community/chelsea"><img src="https://circleci.com/gh/sonatype-nexus-community/chelsea.svg?style=shield" /></a>
</p>

# Chelsea

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

### Usage with Nexus IQ Server

Chelsea can as well work with Sonatype's Nexus IQ Server, allowing you to set policy related to your open source consumption, letting you fine tune what you consume.

To use with Nexus IQ Server, run Chelsea like so:

`chelsea --file Gemfile.lock --application yourpublicapplicationid --iq`

Output after running will look like so, assuming you have no policy violations:

```
$ chelsea --file Gemfile.lock --application testapp --iq
 _____  _            _                   
/  __ \| |          | |                  
| /  \/| |__    ___ | | ___   ___   __ _ 
| |    | '_ \  / _ \| |/ __| / _ \ / _` |
| \__/\| | | ||  __/| |\__ \|  __/| (_| |
 \____/|_| |_| \___||_||___/ \___| \__,_|
                                         
                                         
Version: 0.0.13
[+] Submitting sbom to Nexus IQ Server ...done.
[+] Polling Nexus IQ Server for results ...done.
Hi! Chelsea here, no policy violations for this audit!
Report URL: http://localhost:8070/ui/links/application/testapp/report/0e0f469269534b7a809304b5f68cdd88
```

## Development

We suggest using [rbenv](https://github.com/rbenv/rbenv) to setup a reliable ruby development environment.

Follow the [installation steps](https://github.com/rbenv/rbenv#installation). 
For macos (10.15.7), there was a problem with step 2, with: `$ rbenv init`. The command 
printed suggested editing `~/.bashrc`; however, this did not work in our case (even after an OS reboot),
and we had to instead edit `~/bash_profile`. To sanity check your installation, you should see the 
`.rbenv` directory early in your PATH, e.g.:
```
$ echo $PATH
/Users/<username>/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/TeX/texbin:/usr/local/go/bin:/opt/X11/bin:/Applications/Wireshark.app/Contents/MacOS:/usr/local/git/bin
``` 
 
We are using ruby version 2.6.6, but newer versions should also work.
```
rbenv install 2.6.6
``` 

~~Old Setup Steps~~
~~After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.~~

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Why Chelsea?

One of the awesome developers at Sonatype was thinking of names, and came upon the [Chelsea filter](https://en.wikipedia.org/wiki/Chelsea_filter). A Chelsea filter is used to separate gemstones, helping gemologists distinguish between real emeralds, and just regular green glass. We felt this tool helps you do something very similar, looking at your RubyGems, and seeing which are pristine, and which are less than ok at the moment.

## Contributing

We care a lot about making the world a safer place, and that's why we created `chelsea`. If you as well want to speed up the pace of software development by working on this project, jump on in! Before you start work, create a new issue, or comment on an existing issue, to let others know you are!

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Chelsea project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sonatype-nexus-community/chelsea/blob/master/CODE_OF_CONDUCT.md).

## The Fine Print

Remember:

* If you are a Sonatype customer, you may file Sonatype support tickets related to `chelsea` support in regard to this project
  * We suggest you file issues here on GitHub as well, so that the community can pitch in
* If you are not a Sonatype customer, Do NOT file Sonatype support tickets related to nancy support in regard to this project, file an issue here on GitHub

Have fun creating and using `chelsea` and the [Sonatype OSS Index](https://ossindex.sonatype.org/), we are glad to have you here!

## Getting help

Looking to contribute to our code but need some help? There's a few ways to get information:

* Chat with us on [Gitter](https://gitter.im/sonatype-nexus-community/chelsea)

## Copyright

Copyright (c) 2019 Allister Beharry. See [MIT License](LICENSE.txt) for further details.
