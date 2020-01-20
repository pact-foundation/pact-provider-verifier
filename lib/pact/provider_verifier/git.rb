require 'pact/provider_verifier/error'

# Keep in sync with pact_broker-client/lib/pact_broker/client/git.rb

module Pact
  module ProviderVerifier
    module Git
      COMMAND = 'git rev-parse --abbrev-ref HEAD'.freeze
      BRANCH_ENV_VAR_NAMES = %w{BUILDKITE_BRANCH CIRCLE_BRANCH TRAVIS_BRANCH GIT_BRANCH GIT_LOCAL_BRANCH APPVEYOR_REPO_BRANCH CI_COMMIT_REF_NAME}.freeze

      def self.branch
        find_branch_from_env_vars || branch_from_git_command
      end

      # private

      def self.find_branch_from_env_vars
        BRANCH_ENV_VAR_NAMES.collect { |env_var_name| branch_from_env_var(env_var_name) }.compact.first
      end

      def self.branch_from_env_var(env_var_name)
        val = ENV[env_var_name]
        if val && val.strip.size > 0
          val
        else
          nil
        end
      end

      def self.branch_from_git_command
        branch_names = nil
        begin
          branch_names = execute_git_command
            .split("\n")
            .collect(&:strip)
            .reject(&:empty?)
            .collect(&:split)
            .collect(&:first)
            .collect{ |line| line.gsub(/^origin\//, '') }
            .reject{ |line| line == "HEAD" }

        rescue StandardError => e
          raise Pact::ProviderVerifier::Error, "Could not determine current git branch using command `#{COMMAND}`. #{e.class} #{e.message}"
        end

        validate_branch_names(branch_names)
        branch_names[0]
      end

      def self.validate_branch_names(branch_names)
        if branch_names.size == 0
          raise Pact::ProviderVerifier::Error, "Command `#{COMMAND}` didn't return anything that could be identified as the current branch."
        end

        if branch_names.size > 1
          raise Pact::ProviderVerifier::Error, "Command `#{COMMAND}` returned multiple branches: #{branch_names.join(", ")}. You will need to get the branch name another way."
        end
      end

      def self.execute_git_command
        `#{COMMAND}`
      end
    end
  end
end
