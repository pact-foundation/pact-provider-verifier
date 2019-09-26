require 'pact/pact_broker'
require 'ostruct'
require 'pact/provider/pact_uri'

module Pact
  module ProviderVerifier
    class AggregatePactConfigs

      def self.call(pact_urls, provider_name, consumer_version_tags, provider_version_tags, pact_broker_base_url, http_client_options)
        new(pact_urls, provider_name, consumer_version_tags, provider_version_tags, pact_broker_base_url, http_client_options).call
      end

      def initialize(pact_urls, provider_name, consumer_version_tags, provider_version_tags, pact_broker_base_url, http_client_options)
        @pact_urls = pact_urls
        @provider_name = provider_name
        @consumer_version_tags = consumer_version_tags
        @provider_version_tags = provider_version_tags
        @pact_broker_base_url = pact_broker_base_url
        @http_client_options = http_client_options
      end

      def call
        if ENV['PACT_BROKER_PACTS_FOR_VERIFICATION_ENABLED'] == 'true' && pacts_for_verification_uris.any?
          pacts_for_verification_uris + specified_pact_uris
        else
          pacts_urls_from_broker + specified_pact_uris
        end
      end

      private

      attr_reader :pact_urls, :provider_name, :consumer_version_tags, :provider_version_tags, :pact_broker_base_url, :http_client_options

      def specified_pact_uris
        pact_urls.collect{ | url | Pact::PactBroker.build_pact_uri(url) }
      end

      def pacts_urls_from_broker
        if pact_broker_base_url && provider_name
          old_pact_uris
        else
          []
        end
      end

      def old_pact_uris
         @old_pact_uris ||= Pact::PactBroker.fetch_pact_uris(provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
      end

      def pacts_for_verification_uris
        @pacts_for_verification ||= Pact::PactBroker.fetch_pacts_for_verification(provider_name, consumer_version_selectors, provider_version_tags, pact_broker_base_url, http_client_options)
      end

      def consumer_version_selectors
        consumer_version_tags.collect{ |tag| { tag: tag, latest: true } }
      end
    end
  end
end
