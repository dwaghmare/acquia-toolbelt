module AcquiaToolbelt
  class CLI
    class Domains < AcquiaToolbelt::Thor
      no_tasks do
        # Internal: Purge a web cache for a domain.
        #
        # Returns a status message.
        def purge_domain(subscription, environment, domain)
          # Ensure all the required fields are available.
          if subscription.nil? || environment.nil? || domain.nil?
            ui.fail 'Purge request is missing a required parameter.'
            return
          end

          purge_request = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/domains/#{domain}/cache", 'DELETE'

          if purge_request['id']
            ui.success "#{domain} has been successfully purged."
          else
            ui.fail AcquiaToolbelt::CLI::API.display_error(purge_request)
          end
        end
      end

      # Public: List all domains on a subscription.
      #
      # Returns all domains.
      desc 'list', 'List all domains.'
      def list
        # Set the subscription if it has been passed through, otherwise use the
        # default.
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        # Get all the environments to loop over unless the environment is set.
        if options[:environment]
          environments = []
          environments << options[:environment]
        else
          environments = AcquiaToolbelt::CLI::API.environments
        end

        ui.say

        rows = []
        headings = ['Domain']

        environments.each do |environment|
          domains = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/domains"
          domains.each do |domain|
            row_data = []
            row_data << domain['name']
            rows << row_data
          end
        end

        ui.output_table('', headings, rows)
      end

      # Public: Add a domain to the subscription.
      #
      # Returns a status message.
      desc 'add', 'Add a domain.'
      method_option :domain, :type => :string, :aliases => %w(-d), :required => true,
        :desc => 'Full URL of the domain to add - No slashes or protocols required.'
      def add
        if options[:environment].nil?
          ui.say "No value provided for required options '--environment'"
          return
        end

        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        environment = options[:environment]
        domain      = options[:domain]
        add_domain  = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/domains/#{domain}", 'POST'

        if add_domain['id']
          ui.success "Domain #{domain} has been successfully added to #{environment}."
        else
          ui.fail AcquiaToolbelt::CLI::API.display_error(add_domain)
        end
      end

      # Public: Delete a domain from an environment.
      #
      # Returns a status message.
      desc 'delete', 'Delete a domain.'
      method_option :domain, :type => :string, :aliases => %w(-d), :required => true,
        :desc => 'Full URL of the domain to delete - No slashes or protocols required.'
      def delete
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        environment   = options[:environment]
        domain        = options[:domain]
        delete_domain = AcquiaToolbelt::CLI::API.request "/sites/#{subscription}/envs/#{environment}/domains/#{domain}", 'DELETE'

        if delete_domain["id"]
          ui.success "Domain #{domain} has been successfully deleted from #{environment}."
        else
          ui.fail AcquiaToolbelt::CLI::API.display_error(delete_domain)
        end
      end

      # Public: Purge a domains web cache.
      #
      # Returns a status message.
      desc 'purge', "Purge a domain's web cache."
      method_option :domain, :type => :string, :aliases => %w(-d),
        :desc => 'URL of the domain to purge.'
      def purge
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        domain      = options[:domain]
        environment = options[:environment]

        # If the domain is not defined, we are going to clear a whole
        # environment. This can have severe performance impacts on your
        # environments. We need to be sure this is definitely what you want to
        # do.
        if domain
          purge_domain(subscription, environment, domain)
        else
          all_env_clear = ui.ask "You are about to clear all domains in the #{environment} environment. Are you sure? (y/n)"
          # Last chance to bail out.
          if all_env_clear == "y"
            domains = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/domains"
            domains.each do |domain|
              purge_domain("#{subscription}", "#{environment}", "#{domain['name']}")
            end
          else
            ui.info 'Ok, no action has been taken.'
          end
        end
      end

      # Public: Move domains from one environment to another.
      #
      # Returns a status message.
      desc 'move', 'Move a domain to another environment.'
      method_option :domains, :type => :string, :aliases => %w(-d),
        :desc => 'List of comma separated domains to move.'
      method_option :origin, :type => :string, :aliases => %w(-o),
        :desc => 'Origin environment to move the domains from.'
      method_option :target, :type => :string, :aliases => %w(-t),
        :desc => 'Target environment to move the domains to.'
      def move
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        domains = options[:domains].split(',')
        origin  = options[:origin]
        target  = options[:target]
        data    = { :domains => domains }

        move_domain = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/domain-move/#{origin}/#{target}", 'POST', data
        if move_domain['id']
          ui.success "Domain move from #{origin} to #{target} has been successfully completed."
        else
          ui.fail AcquiaToolbelt::CLI::API.display_error(move_domain)
        end
      end
    end
  end
end
