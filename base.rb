Bundler.require
Dotenv.load

# If you need an ssh tunnel use: ssh -L 1521:localhost:1521 your_oracle_box

TIMESTAMP = Time.now.strftime("%Y%m%d-%H%M%S")

def use_default_options(require_args: false, &block)
  options(require_args: require_args) do
    add :aleph_sid, "--aleph-sid SID", "Aleph SID", String, default: ENV.fetch("ALEPH_SID") { "aleph22" }
    add :aleph_user, "-u", "--aleph-user USER", "Aleph User", String, default: ENV.fetch("ALEPH_USER") { "padview" }
    add :aleph_password, "-p", "--aleph-password PASS", "Aleph Password", String, default: ENV.fetch("ALEPH_PASSWORD") { "" }
    add :aleph_host, "--aleph-host HOST", "Aleph Host", String, default: ENV.fetch("ALEPH_HOST") { "localhost" }
    add :aleph_port, "--aleph-port PORT", "Aleph Port", String, default: ENV.fetch("ALEPH_PORT") { "1521" }
    add :dry_run, "--dry-run", "Do not perform database writes", default: false
    block.call(self) if block_given?
  end
end

def db
  @db ||= Sequel.oracle(
    options[:aleph_sid],
    user: options[:aleph_user],
    password: options[:aleph_password],
    host: options[:aleph_host],
    port: options[:aleph_port],
    logger: begin
      logger = Logger.new(STDOUT)
      logger.level = "error"
      logger
    end
  )
end

def log(filename, message:, log_on_console: true)
  puts message if log_on_console
  File.open(filename, 'a') { |file| file.write("#{message}\n") }
end
