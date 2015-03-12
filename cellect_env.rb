require 'yaml'

module CellectEnv

  def stringify_value(value)
    return value if value.nil?
    value = value.to_s
    value.empty? ? nil : value
  end

  def setup_env_vars
    setup_environment
    load_db_yaml
    load_zk_yaml
    @env_vars = { "ZK_URL" => @zk_url, "PG_POOL" => stringify_value(@pg_pool),
                  "PG_HOST" => @pg_host, "PG_PORT" => stringify_value(@pg_port),
                  "PG_DB" => @pg_db, "PG_USER" => @pg_user, "PG_PASS" => @pg_pass,
                  "RACK_ENV" => @environment }
  end

  private

  def setup_environment
    @environment = ENV['RACK_ENV']
    if @environment == nil
      @environment = 'production'
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
      @pg_user = ENV['PG_ENV_PG_USER']
      @pg_pass = ENV['PG_ENV_PASS']
      @pg_pool = ENV['PG_ENV_POOL']
    end
  end

  def load_zk_yaml
    begin
      zookeepers = YAML.load(File.read("/production_config/zookeeper.yml"))
      zk = zookeepers[@environment]
      @zk_url = "#{zk['host']}:#{zk['port']}"
    rescue Errno::ENOENT
      @zk_url = "#{ENV["ZK_PORT_2181_TCP_ADDR"]}:#{ENV["ZK_PORT_2181_TCP_PORT"]}"
    end
  end
end
