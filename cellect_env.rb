require 'yaml'

module CellectEnv

  def stringify_value(value)
    return value if value.nil?
    value = value.to_s
    value.empty? ? nil : value
  end

  def setup_env_vars
    setup_environment
    preload_workflows
    load_db_yaml
    set_redis_url
    @env_vars = {
      "ATTENTION_REDIS_URL" => @redis_url,
      "DATABASE_URL" => database_url,
      "RACK_ENV" => @environment,
      "PRELOAD_WORKFLOWS" => @preload_workflows
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

  def set_redis_url
    @redis_url = ENV['ATTENTION_REDIS_URL']
    if File.exists?("/production_config/redis.yml")
      configs = YAML.load(File.read("/production_config/redis.yml"))
      config = configs[@environment]
      @redis_url ||= redis['url']
    else
      @redis_url ||= docker_redis_url
    end
  end

  def load_db_yaml
    begin
      databases = YAML.load(File.read("/production_config/database.yml"))
      db = databases[@environment]
      @pg_host = db['host']
      @pg_port = db['port']
      @pg_db = db['database']
      @pg_user = db['username']
      @pg_pass = db['password']
      @pg_pool = db['pool']
    rescue Errno::ENOENT
      @pg_host = ENV['PG_PORT_5432_TCP_ADDR']
      @pg_port = ENV['PG_PORT_5432_TCP_PORT']
      @pg_db = ENV['PG_ENV_DB']
      @pg_pool = ENV['PG_ENV_POOL']
      @pg_user = ENV['PG_ENV_POSTGRES_USER']
      @pg_pass = ENV['PG_ENV_POSTGRES_PASSWORD']
    end
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

  def docker_redis_url
    "redis://#{ENV["REDIS_PORT_6379_TCP_ADDR"]}:#{ENV["REDIS_PORT_6379_TCP_PORT"]}/0"
  end
end
