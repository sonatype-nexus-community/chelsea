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
$ chelsea --help
usage: /usr/local/bin/chelsea [options]
    -f, --file         Path to your Gemfile.lock
    -x, --clear        Clear OSS Index cache
    -c, --config       Set persistent config for OSS Index
    -u, --user         Specify OSS Index Username
    -p, --token        Specify OSS Index API Token
    -a, --application  Specify the IQ application id
    -i, --server       Specify the IQ server url
    -iu, --iquser      Specify the IQ username
    -it, --iqpass      Specify the IQ auth token
    -w, --whitelist    Set path to vulnerability whitelist file
    -v, --verbose      For text format, list dependencies, their reverse dependencies (what brought them in to your project), and if they are vulnerable. (default: false)
    -t, --format       Choose what type of format you want your report in (default: text) (options: text, json, xml)
    -b, --iq           Use Nexus IQ Server to audit your project
    -s, --stage        Specify Nexus IQ Stage (default: build) (options: develop, build, stage-release, release, operate)
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
/Users/<username>/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:...
``` 
 
We are using ruby version 2.6.6, but newer versions should also work.
```
rbenv install 2.6.6
``` 

Install `bundler`:
```
gem install bundler
```

Install dependencies:
```
bundle install
```

Run tests:
```
bundle exec rspec
```

To install this gem onto your local machine, run `bundle exec rake install`. To manually release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Release Process

Chelsea is automatically released after a commit to the `master` branch.

To avoid performing a release after a commit to the `master` branch, be sure your commit message includes `[skip ci] `.

## Why Chelsea?

One of the awesome developers at Sonatype was thinking of names, and came upon the [Chelsea filter](https://en.wikipedia.org/wiki/Chelsea_filter). A Chelsea filter is used to separate gemstones, helping gemologists distinguish between real emeralds, and just regular green glass. We felt this tool helps you do something very similar, looking at your RubyGems, and seeing which are pristine, and which are less than ok at the moment.

## How to Fix Vulnerabilities

So you've found a vulnerability. Now what? The best case is to upgrade the vulnerable component to a newer/non-vulnerable
version. However, it is likely the vulnerable component is not a direct dependency, but instead is a transitive dependency
(a dependency of a dependency, of a dependency, wash-rinse-repeat). In such a case, the first step is to figure out which
direct dependency (and sub-dependencies) depend on the vulnerable component. 

The `gem dependency` command will show a dependency tree for all gems from the current Gemfile with their dependencies.
The `bundle outdated` command will show a list of all gems which have newer versions. 

As an example, suppose we've learned that component `rexml`, version 3.2.4 is vulnerable (CVE-2021-28965). 
Use the following command to determine which components depend on `rexml`.
```shell
$ gem dependency -R rexml
Gem rexml-3.1.9
  bundler (>= 0, development)
  rake (>= 0, development)
  Used by
    rubocop-1.9.0 (rexml (>= 0))

Gem rexml-3.2.4
  bundler (>= 0, development)
  rake (>= 0, development)
  Used by
    rubocop-1.9.0 (rexml (>= 0))
```

There are a number of approaches to resolving the vulnerability, but no matter which approach you choose, you should 
probably make sure all the tests are passing before making any dependency changes.
```shell
bundle exec rspec
...
Finished in 0.1411 seconds (files took 0.67222 seconds to load)
22 examples, 0 failures
```

One approach is to upgrade everything to the latest version available. This solution might make people nervous about
introducing breaking changes. (You have unit tested everything right? ;) )
<details>
  <summary>Click to expand output of command:

```shell
$ bundle update 
```
  </summary>

```shell
  $ bundle update
Fetching gem metadata from https://rubygems.org/.........
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies...
Using rake 12.3.3
Using public_suffix 4.0.6 (was 4.0.3)
Using addressable 2.7.0
Using ast 2.4.2
Using bundler 2.1.4
Using byebug 11.1.3 (was 11.1.2)
Using ox 2.13.4
Using equatable 0.7.0 (was 0.6.1)
Using tty-color 0.6.0 (was 0.5.2)
Using pastel 0.7.4
Using unf_ext 0.0.7.7
Using unf 0.1.4
Using domain_name 0.5.20190701
Using http-cookie 1.0.3
Using mime-types-data 3.2021.0225 (was 3.2020.0512)
Using mime-types 3.3.1
Using netrc 0.11.0
Using rest-client 2.0.2
Using slop 4.8.2
Using tty-font 0.5.0
Using tty-cursor 0.7.1
Using tty-spinner 0.9.3
Using necromancer 0.7.0 (was 0.6.0)
Using strings-ansi 0.2.0
Using unicode-display_width 1.7.0
Using unicode_utils 1.4.0
Using strings 0.1.8
Using tty-screen 0.8.1
Using tty-table 0.11.0
Using chelsea 0.0.28 (was 0.0.27) from source at `.`
Using rexml 3.2.5 (was 3.2.4)
Using crack 0.4.5 (was 0.4.3)
Using diff-lcs 1.4.4 (was 1.3)
Using hashdiff 1.0.1
Using parallel 1.20.1
Using parser 3.0.1.0 (was 3.0.0.0)
Using rainbow 3.0.0
Using regexp_parser 2.1.1 (was 2.0.3)
Using rspec-support 3.10.2 (was 3.9.2)
Using rspec-core 3.10.1 (was 3.9.1)
Using rspec-expectations 3.10.1 (was 3.9.1)
Using rspec-mocks 3.10.2 (was 3.9.1)
Using rspec 3.10.0 (was 3.9.0)
Using rspec_junit_formatter 0.4.1
Using rubocop-ast 1.4.1
Using ruby-progressbar 1.11.0
Using rubocop 1.12.1 (was 1.9.0)
Using webmock 3.8.3
Bundle updated!
Gems in the group production were not updated.
```
</details>

Perhaps a more palatable approach would be to upgrade to a newer version of the "Used by" component, meaning you upgrade
the direct dependency (`rubocop`) to a version that does not depend on a vulnerable version of the transitive dependency
(`rexml`). This approach will make fewer changes overall.

In some cases, no such upgrade of the direct dependency exists that avoids a dependence on the vulnerable component. 
In such a case, the next step is to file an issue with the direct dependency project for them to update the vulnerable
sub-dependencies. Be sure to read and follow any vulnerability reporting instructions published by the project: Look for
a `SECURITY.md` file, or other instructions on how to report vulnerabilities. Some projects may prefer you not report 
the vulnerability publicly.

In our example, there is a newer version of the direct dependency available:
```shell
  $ bundle outdated | grep rubocop
  * rubocop (newest 1.12.1, installed 1.9.0) in group "default"
```
Now we can update the `rubocop` component as follows:
<details>
  <summary>Click to expand output of command:

```shell
$ bundle update rubocop
```
  </summary>

```shell
$ bundle update rubocop
Fetching gem metadata from https://rubygems.org/.........
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies...
Using rake 12.3.3
Fetching public_suffix 4.0.3
Installing public_suffix 4.0.3
Using addressable 2.7.0
Using ast 2.4.2
Using bundler 2.1.4
Fetching byebug 11.1.2
Installing byebug 11.1.2 with native extensions
Using ox 2.13.4
Using equatable 0.6.1
Using tty-color 0.5.2
Using pastel 0.7.4
Using unf_ext 0.0.7.7
Using unf 0.1.4
Using domain_name 0.5.20190701
Using http-cookie 1.0.3
Using mime-types-data 3.2020.0512
Using mime-types 3.3.1
Using netrc 0.11.0
Using rest-client 2.0.2
Using slop 4.8.2
Using tty-font 0.5.0
Using tty-cursor 0.7.1
Using tty-spinner 0.9.3
Using necromancer 0.6.0
Using strings-ansi 0.2.0
Using unicode-display_width 1.7.0
Using unicode_utils 1.4.0
Using strings 0.1.8
Using tty-screen 0.8.1
Using tty-table 0.11.0
Using chelsea 0.0.28 from source at `.`
Using safe_yaml 1.0.5
Fetching crack 0.4.3
Installing crack 0.4.3
Fetching diff-lcs 1.3
```
</details>

Yet another alternative approach is to upgrade the transitive dependency (`rexml` in our example). 

Use the command below to determine if there is a newer version of the vulnerable component.
```shell
  $ bundle outdated | grep rexml
  * rexml (newest 3.2.5, installed 3.2.4)
```
Now we can update the `rexml` component as follows:
<details>
  <summary>Click to expand output of command:

```shell
$ bundle update rexml
```
  </summary>

```shell
$ bundle update rexml
Fetching gem metadata from https://rubygems.org/.........
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies...
Using rake 12.3.3
Using public_suffix 4.0.3
Using addressable 2.7.0
Using ast 2.4.2
Using bundler 2.1.4
Using byebug 11.1.2
Using ox 2.13.4
Using equatable 0.7.0 (was 0.6.1)
Using tty-color 0.6.0 (was 0.5.2)
Using pastel 0.7.4
Using unf_ext 0.0.7.7
Using unf 0.1.4
Using domain_name 0.5.20190701
Using http-cookie 1.0.3
Using mime-types-data 3.2021.0225 (was 3.2020.0512)
Using mime-types 3.3.1
Using netrc 0.11.0
Using rest-client 2.0.2
Using slop 4.8.2
Using tty-font 0.5.0
Using tty-cursor 0.7.1
Using tty-spinner 0.9.3
Using necromancer 0.7.0 (was 0.6.0)
Using strings-ansi 0.2.0
Using unicode-display_width 1.7.0
Using unicode_utils 1.4.0
Using strings 0.1.8
Using tty-screen 0.8.1
Using tty-table 0.11.0
Using chelsea 0.0.28 (was 0.0.27) from source at `.`
Using safe_yaml 1.0.5
Using crack 0.4.3
Using diff-lcs 1.3
Using hashdiff 1.0.1
Using parallel 1.20.1
Using parser 3.0.0.0
Using rainbow 3.0.0
Using regexp_parser 2.0.3
Using rexml 3.2.5 (was 3.2.4)
Using rspec-support 3.9.2
Using rspec-core 3.9.1
Using rspec-expectations 3.9.1
Using rspec-mocks 3.9.1
Using rspec 3.9.0
Using rspec_junit_formatter 0.4.1
Using rubocop-ast 1.4.1
Using ruby-progressbar 1.11.0
Using rubocop 1.9.0
Using webmock 3.8.3
Bundle updated!
Gems in the group production were not updated.
```
</details>

Regardless of which approach you choose, you should verify the tests pass after you upgrade dependencies.
```shell
bundle exec rspec
...
Finished in 0.12826 seconds (files took 0.5069 seconds to load)
22 examples, 0 failures
```
Full disclosure, it turns out that after upgrading `rubocop` (via: `bundle update rubocop`),
a `# rubocop:disable Layout/LineLength` was no longer needed. 
Happily, the CI test suite failed and pointed quickly to the fix (just needed to remove `# rubocop`
disable/enable comments).

Victory! Commit the changes, and we're done. (see [PR: #44](https://github.com/sonatype-nexus-community/chelsea/pull/44))

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
