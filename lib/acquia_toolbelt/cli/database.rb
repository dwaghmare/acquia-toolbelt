module AcquiaToolbelt
  class CLI
    class Database < AcquiaToolbelt::Thor
      no_tasks do
        # Internal: Build the database output.
        #
        # Output the database information exposing all the available fields and
        # data to the end user.
        #
        # Returns multiple lines.
        def output_database_instance(database)
          ui.say "> Username: #{database["username"]}"
          ui.say "> Password: #{database["password"]}"
          ui.say "> Host: #{database["host"]}"
          ui.say "> DB cluster: #{database["db_cluster"]}"
          ui.say "> Instance name: #{database["instance_name"]}"
        end
      end

      # Public: Add a database to the subscription.
      #
      # Returns a status message.
      desc "add", "Add a database."
      method_option :database, :type => :string, :aliases => %w(-d), :required => true,
        :desc => "Name of the database to create."
      def add
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        database     = options[:database]
        add_database = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/dbs", "POST", :db => "#{database}"
        ui.success "Database '#{database}' has been successfully created." if add_database["id"]
      end

      # Public: Copy a database from one environment to another.
      #
      # Returns a status message.
      desc "copy", "Copy a database from one environment to another."
      method_option :database, :type => :string, :aliases => %w(-d), :required => true,
        :desc => "Name of the database to copy."
      method_option :origin, :type => :string, :aliases => %w(-o), :required => true,
        :desc => "Origin of the database to copy."
      method_option :target, :type => :string, :aliases => %w(-t), :required => true,
        :desc => "Target of where to copy the database."
      def copy
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        database      = options[:database]
        origin        = options[:origin]
        target        = options[:target]
        copy_database = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/dbs/#{database}/db-copy/#{origin}/#{target}", "POST"
        ui.success "Database '#{database}' has been copied from #{origin} to #{target}." if copy_database["id"]
      end

      # Public: Delete a database from a subscription.
      #
      # NB: This will delete all instances of the datavbase across all
      # environments.
      #
      # Returns a status message.
      desc "delete", "Delete a database."
      method_option :database, :type => :string, :aliases => %w(-d), :required => true,
        :desc => "Name of the database to delete."
      def delete
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        database  = options[:database]
        delete_db = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/dbs/#{database}", "DELETE"
        ui.success "Database '#{database}' has been successfully deleted." if delete_db["id"]
      end

      # Public: List all databases available within a subscription.
      #
      # Returns a database listing.
      desc "list", "List all databases."
      method_option :database, :type => :string, :aliases => %w(-d),
        :desc => "Name of the database to view."
      def list
        if options[:subscription]
          subscription = options[:subscription]
        else
          subscription = AcquiaToolbelt::CLI::API.default_subscription
        end

        database    = options[:database]
        environment = options[:environment]

        # Output a single database where the name and environment are specified.
        if database && environment
          database = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/dbs/#{database}"
          ui.say
          output_database_instance(database)

        # Only an environment was set so get all expanded data for the requested
        # environment.
        elsif environment
          databases = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/envs/#{environment}/dbs"
          databases.each do |db|
            ui.say
            ui.say "#{db["name"]}"
            output_database_instance(db)
          end

        # Just a general listing of the databases, no in depth details.
        else
          databases = AcquiaToolbelt::CLI::API.request "sites/#{subscription}/dbs"
          ui.say
          databases.each do |db|
            say "> #{db["name"]}"
          end
        end
      end
    end
  end
end