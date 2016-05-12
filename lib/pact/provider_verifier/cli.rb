require 'thor'
require 'socket'
require 'pact/provider_verifier/app'

module Pact
  module ProviderVerifier
    class CLI < Thor
      desc 'verify', "Runs the Pact verification process"
      method_option :pact_urls, aliases: "-u", desc: "Comma-separated list of Pact file URIs. Supports local and networked (http-based) files", :required => true
      method_option :provider_base_url, aliases: "-h", desc: "Provide host URL", :required => true
      method_option :provider_states_url, aliases: "-s", desc: "Base URL to retrieve the provider states from", :required => false
      method_option :provider_states_setup_url, aliases: "-c", desc: "Base URL to setup the provider states at", :required => false

      def verify
        app = Pact::ProviderVerifier::App.new(options)
        app.verify_pacts
      end

      default_task :verify
    end
  end
end
