require 'pact/pact_broker'
require 'ostruct'

module Pact
  module ProviderVerifier
    class AggregatePactConfigs

      def self.call(pact_urls, provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
        new(pact_urls, provider_name, consumer_version_tags, pact_broker_base_url, http_client_options).call
      end

      def initialize(pact_urls, provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
        @pact_urls = pact_urls
        @provider_name = provider_name
        @consumer_version_tags = consumer_version_tags
        @pact_broker_base_url = pact_broker_base_url
        @http_client_options = http_client_options
      end

      def call
         pacts_urls_from_broker + pact_urls.collect{ |uri| OpenStruct.new(uri: uri) }
      end

      private

      attr_reader :pact_urls, :provider_name, :consumer_version_tags, :pact_broker_base_url, :http_client_options

      def pacts_urls_from_broker
        if pact_broker_base_url && provider_name
          net_pending_pact_uris.collect{ | uri| OpenStruct.new(uri: uri, pending: true) } +
            non_pending_pact_uris.collect{ | uri| OpenStruct.new(uri: uri) }
        else
          []
        end
      end

      def non_pending_pact_uris
        @non_pending_pact_uris ||= Pact::PactBroker.fetch_pact_uris(provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
      end

      def pending_pact_uris
        @pending_pact_uris ||= Pact::PactBroker.fetch_pending_pact_uris(provider_name, pact_broker_base_url, http_client_options)
      end

      def net_pending_pact_uris
        if ENV['PACT_INCLUDE_PENDING'] == 'true'
          pending_pact_uris - non_pending_pact_uris
        else
          []
        end
      end
    end
  end
end
