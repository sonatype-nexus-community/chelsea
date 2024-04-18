/*
 * Copyright 2019-Present Sonatype Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Library(['private-pipeline-library', 'jenkins-shared']) _

dockerizedBuildPipeline(
  buildAndTest: {
    sh '''
    bundle exec rspec --format progress --format RspecJunitFormatter --out test_results/rspec.xml
    '''
  },
  vulnerabilityScan: {
    withDockerImage(env.DOCKER_IMAGE_ID, {
      withCredentials([usernamePassword(credentialsId: 'jenkins-saas-service-acct',
        usernameVariable: 'IQ_USERNAME', passwordVariable: 'IQ_PASSWORD')]) {
        sh '''
        gem build chelsea.gemspec
        gem install ./chelsea-*.gem
        chelsea --file Gemfile.lock -b -a chelsea -iu $IQ_USERNAME -it $IQ_PASSWORD -i https://sonatype.sonatype.app/platform --stage release
        '''
      }
    })
  },
  testResults: [ 'test_results/rspec.xml' ],
  onFailure: {
    notifyChat(currentBuild: currentBuild, env: env, room: 'community-oss-fun')
    sendEmailNotification(currentBuild, env, [], 'community-group@sonatype.com')
  }
)
