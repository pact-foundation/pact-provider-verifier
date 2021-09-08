require 'pact/pact_broker'
require 'ostruct'
require 'pact/provider/pact_uri'

module Pact
  module ProviderVerifier
    class AggregatePactConfigs

      def self.call(pact_urls, provider_name, consumer_version_tags, consumer_version_selectors, provider_version_branch, provider_version_tags, pact_broker_base_url, http_client_options, options)
        new(pact_urls, provider_name, consumer_version_tags, consumer_version_selectors, provider_version_branch, provider_version_tags, pact_broker_base_url, http_client_options, options).call
      end

      def initialize(pact_urls, provider_name, consumer_version_tags, consumer_version_selectors, provider_version_branch, provider_version_tags, pact_broker_base_url, http_client_options, options)
        @pact_urls = pact_urls
        @provider_name = provider_name
        @consumer_version_tags = consumer_version_tags
        @consumer_version_selectors = consumer_version_selectors
        @provider_version_branch = provider_version_branch
        @provider_version_tags = provider_version_tags
        @pact_broker_base_url = pact_broker_base_url
        @http_client_options = http_client_options
        @options = options
      end

      def call
        pacts_urls_from_broker + specified_pact_uris
      end

      private

      attr_reader :pact_urls, :provider_name, :consumer_version_tags, :consumer_version_selectors, :provider_version_branch, :provider_version_tags, :pact_broker_base_url, :http_client_options, :options

      def specified_pact_uris
        pact_urls.collect{ | url | Pact::PactBroker.build_pact_uri(url, http_client_options) }
      end

      def pacts_urls_from_broker
        if pact_broker_base_url && provider_name
          pacts_for_verification
        else
          []
        end
      end

      def pacts_for_verification
        @pacts_for_verification ||= Pact::PactBroker.fetch_pact_uris_for_verification(
          provider_name,
          aggregated_consumer_version_selectors,
          provider_version_branch,
          provider_version_tags,
          pact_broker_base_url,
          http_client_options,
          pact_options
        )
      end

      def aggregated_consumer_version_selectors
        consumer_version_selectors + consumer_version_tags.collect{ |tag| { tag: tag, latest: true } }
      end

      def pact_options
        {
          include_pending_status: options[:enable_pending],
          include_wip_pacts_since: options[:include_wip_pacts_since]
        }
      end
    end
  end
end
