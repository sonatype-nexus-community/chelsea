#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM docker-all.repo.sonatype.com/ruby:2.6

RUN apt-get update && \	
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /home/jenkins

WORKDIR /home/jenkins

COPY . .

RUN useradd -r -u 1002 -g 100 -d /home/jenkins jenkins

RUN chown jenkins:100 /home/jenkins

USER jenkins

RUN gem install bundler

RUN bundle install

CMD ["/bin.bash"]
