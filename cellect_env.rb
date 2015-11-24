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
    load_zk_yaml
    @env_vars = {
      "ZK_URL" => @zk_url,
      "DATABASE_URL" => "postgresql://#{@pg_user}:#{@pg_pass}@#{@pg_host}:#{@pg_port}/#{@pg_db}?pool=#{connection_pool_value}",
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
      @pg_user = ENV['PG_ENV_PG_USER']
      @pg_pass = ENV['PG_ENV_PASS']
      @pg_pool = ENV['PG_ENV_POOL']
    end
  end

  def default_conn_pool_size
    @default_conn_pool_size ||= 8
  end

  def connection_pool_value
    pool_val = (@pg_pool).to_s
    if ['', '0'].include?(pool_val)
      default_conn_pool_size
    else
      pool_val
    end
  end

  def load_zk_yaml
    begin
      zookeepers = YAML.load(File.read("/production_config/zookeeper.yml"))
      zk = zookeepers[@environment]
      @zk_url = zk['url']
    rescue Errno::ENOENT
      @zk_url = "#{ENV["ZK_PORT_2181_TCP_ADDR"]}:#{ENV["ZK_PORT_2181_TCP_PORT"]}"
    end
  end
end
