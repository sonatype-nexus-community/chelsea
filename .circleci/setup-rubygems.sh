mkdir ~/.gem
echo -e "---\r\n:rubygems_api_key: $RUBY_GEMS_API_TOKEN" > ~/.gem/credentials
chmod 0600 /home/circleci/.gem/credentials
