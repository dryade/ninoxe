# -*- coding: utf-8 -*-
class Chouette::Loader

  attr_reader :schema, :database, :user, :password, :host

  def initialize(schema)
    @schema = schema

    Chouette::ActiveRecord.connection_pool.spec.config.tap do |config|
      @database = config[:database]
      @user = config[:username]
      @password = config[:password]
      @host = (config[:host] or "localhost")
    end
  end

  # Load dump where datas are in schema 'chouette'
  def load_dump(file)
    logger.info "Load #{file} in schema #{schema}"
    with_pg_password do
      execute!("sed -e 's/ chouette/ #{schema}/' -e 's/ agilis/ #{user}/' #{file} | psql #{pg_options} --set ON_ERROR_ROLLBACK=1 --set ON_ERROR_STOP=1")
    end
    self
  end

  def backup(file)
    logger.info "Backup schema #{schema} in #{file}"

    with_pg_password do
      execute!("pg_dump -n #{schema} -f #{file} #{pg_options}")
    end

    self
  end

  def pg_options
    [].tap do |options|
      options << "-U #{user}" if user
      options << database
    end.join(" ")
  end

  def drop
    logger.info "Drop schema #{schema}"
    with_pg_password do
      execute!("psql -c 'DROP SCHEMA #{schema} CASCADE;' #{pg_options}")
    end
    self
  end

  def with_pg_password(&block)
    ENV['PGPASSWORD'] = password.to_s if password
    begin
      yield
    ensure
      ENV['PGPASSWORD'] = nil
    end
  end

  @@binarisation_command = "binarisation"
  cattr_accessor :binarisation_command

  def binarize(period, target_directory)
    # TODO check these computed daybefore/dayafter
    day_before = period.begin - Date.today
    day_after = period.end - period.begin

    execute! "#{binarisation_command} --host=#{host} --dbname=#{database} --user=#{user} --password=#{password} --schema=#{schema} --daybefore=#{day_before} --dayafter=#{day_after} #{target_directory}"
  end

  class ExecutionError < StandardError; end

  def available_loggers
    [].tap do |logger|
      logger << Chouette::ActiveRecord.logger  
      logger << Rails.logger if defined?(Rails)
      logger << Logger.new($stdout)
    end.compact
  end

  def logger
    @logger ||= available_loggers.first
  end

  def execute!(command)
    logger.debug "execute '#{command}'"
    output = `#{command} 2>&1`
    logger.debug output unless output.empty?

    if $? != 0
      raise ExecutionError.new("Command failed: #{command} (error code #{$?})")
    end

    true
  end

end
