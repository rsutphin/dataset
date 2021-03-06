SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
require "#{SPEC_ROOT}/../plugit/descriptor"

# From RSpec's spec_helper.rb. Useful to keep testing of ExampleGroup from
# being overly noisy in the console output.
share_as :SandboxedOptions do
  attr_reader :options

  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    ::Spec::Runner.use(@options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new))
  end

  after(:each) do
    ::Spec::Runner.use(@original_rspec_options)
  end

  def run_with(options)
    ::Spec::Runner::CommandLine.run(options)
  end
end

$LOAD_PATH << SPEC_ROOT
RAILS_ROOT = "#{SPEC_ROOT}/.."
$LOAD_PATH << "#{RAILS_ROOT}/lib"
RAILS_LOG_FILE = "#{RAILS_ROOT}/log/test.log"
SQLITE_DATABASE = "#{SPEC_ROOT}/sqlite3.db"

require 'fileutils'
FileUtils.mkdir_p(File.dirname(RAILS_LOG_FILE))
FileUtils.touch(RAILS_LOG_FILE)
FileUtils.mkdir_p("#{SPEC_ROOT}/tmp")
FileUtils.rm_rf("#{SPEC_ROOT}/tmp/*")

require 'logger'
RAILS_DEFAULT_LOGGER = Logger.new(RAILS_LOG_FILE)
RAILS_DEFAULT_LOGGER.level = Logger::DEBUG

ActiveRecord::Base.silence do
  ActiveRecord::Base.configurations = {'test' => {
    'adapter' => 'sqlite3',
    'database' => SQLITE_DATABASE
  }}
  ActiveRecord::Base.establish_connection 'test'
  load "#{SPEC_ROOT}/schema.rb"
end

require "models"
require "dataset"
require "#{SPEC_ROOT}/custom_matchers"