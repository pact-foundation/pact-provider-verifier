require 'pact/provider_verifier/error'

# Keep in sync with pact_broker-client/lib/pact_broker/client/git.rb

module Pact
  module ProviderVerifier
    module Git
      COMMAND = 'git rev-parse --abbrev-ref HEAD'

      def self.branch
        `#{COMMAND}`.strip
      rescue StandardError => e
        raise Pact::ProviderVerifier::Error, "Could not determine current git branch using command `#{COMMAND}`. #{e.class} #{e.message}"
      end
    end
  end
end
