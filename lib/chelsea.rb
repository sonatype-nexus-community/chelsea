# frozen_string_literal: true

# Lazy loading
module Chelsea
  autoload :CLI,          'chelsea/cli'
  autoload :Deps,         'chelsea/deps'
  autoload :Bom,          'chelsea/bom'
  autoload :IQClient,     'chelsea/iq_client'
  autoload :OSSIndex,     'chelsea/oss_index'
  autoload :Config,       'chelsea/config'
  autoload :Version,      'chelsea/version'
end
