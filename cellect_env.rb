require 'yaml'

module CellectEnv

  DEFAULT_REDIS_DB = 1

  def stringify_value(value)
    return value if value.nil?
    value = value.to_s
    value.empty? ? nil : value
  end

  def setup_env_vars
    setup_environment
    preload_workflows
    load_db_yaml
    load_redis_yaml
    @env_vars = {
      "ATTENTION_REDIS_URL" => redis_url,
      "DATABASE_URL" => database_url,
      "RACK_ENV" => @environment,
      "PRELOAD_WORKFLOWS" => @preload_workflows,
      "RELOAD_TIMEOUT" => ENV['RELOAD_TIMEOUT']
    }
  end

  private

  def setup_environment
    @environment = ENV['RACK_ENV']
    if @environment == nil
      @environment = 'production'
    end
  end

  def preload_workflows
    ids = (ENV['PRELOAD_WORKFLOWS'] || "").split(",")
    @preload_workflows = ids.map(&:to_i).select { |int| int != 0 }.join(",")
  end

  def load_redis_yaml
    configs = YAML.load(File.read("/production_config/redis.yml"))
    config = configs[@environment]
    @redis_host = config['host']
    @redis_port = config['port']
    @redis_db   = config['db'] || DEFAULT_REDIS_DB
  rescue Errno::ENOENT
    @redis_host = ENV["REDIS_PORT_6379_TCP_ADDR"]
    @redis_port = ENV["REDIS_PORT_6379_TCP_PORT"]
    @redis_db   = ENV["REDIS_ENV_DB"] || DEFAULT_REDIS_DB
  end

  def load_db_yaml
    databases = YAML.load(File.read("/production_config/database.yml"))
    db = databases[@environment]
    @pg_host = db['host']
    @pg_port = db['port']
    @pg_db   = db['database']
    @pg_user = db['username']
    @pg_pass = db['password']
    @pg_pool = db['pool']
  rescue Errno::ENOENT
    @pg_host = ENV['PG_PORT_5432_TCP_ADDR']
    @pg_port = ENV['PG_PORT_5432_TCP_PORT']
    @pg_db   = ENV['PG_ENV_DB']
    @pg_pool = ENV['PG_ENV_POOL']
    @pg_user = ENV['PG_ENV_POSTGRES_USER']
    @pg_pass = ENV['PG_ENV_POSTGRES_PASSWORD']
  end

  def default_conn_pool_size
    @default_conn_pool_size ||= 16
  end

  def connection_pool_value
    pool_val = (@pg_pool).to_s
    if ['', '0'].include?(pool_val)
      default_conn_pool_size
    else
      pool_val
    end
  end

  def database_url
    ENV['DATABASE_URL'] ||
    "postgresql://#{@pg_user}:#{@pg_pass}@#{@pg_host}:#{@pg_port}/#{@pg_db}?pool=#{connection_pool_value}"
  end

  def redis_url
    ENV['ATTENTION_REDIS_URL'] ||
    "redis://#{@redis_host}:#{@redis_port}/#{@redis_db}"
  end
end
