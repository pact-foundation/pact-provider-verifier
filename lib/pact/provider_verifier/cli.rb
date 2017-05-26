require 'thor'
require 'socket'
require 'pact/provider_verifier/app'

module Pact
  module ProviderVerifier
    class CLI < Thor
      desc 'verify', "Runs the Pact verification process"
      method_option :pact_urls, aliases: "-u", desc: "Comma-separated list of Pact file URIs. Supports local and networked (http-based) files", :required => true
      method_option :provider_base_url, aliases: "-h", desc: "Provide host URL", :required => true
      method_option :provider_states_setup_url, aliases: "-c", desc: "Base URL to setup the provider states at", :required => false
      method_option :provider_app_version, aliases: "-a", desc: "The provider application version, required for publishing verification results", :required => false
      method_option :publish_verification_results, aliases: "-r", desc: "Publish verification results to the broker", required: false
      method_option :broker_username, aliases: "-n", desc: "Pact Broker username", :required => false
      method_option :broker_password, aliases: "-p", desc: "Pact Broker password", :required => false
      method_option :verbose, aliases: "-v", desc: "Verbose output", :required => false
      method_option :provider_states_url, aliases: "-s", desc: "DEPRECATED", :required => false

      def verify
        app = Pact::ProviderVerifier::App.new(options)
        app.verify_pacts
      end

      default_task :verify
    end
  end
end
