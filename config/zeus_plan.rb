require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def test
    require 'factory_girl'
    FactoryGirl.reload
    super
  end

  # was removed from zeus default plan in https://github.com/burke/zeus/commit/a3df16778b06ed43af801a6c4c7a2380ce2a844a
  def cucumber_environment
    require 'cucumber/rspec/disable_option_parser'
    require 'cucumber/cli/main'
    @cucumber_runtime = Cucumber::Runtime.new
  end

  def cucumber(argv=ARGV)
    cucumber_main = Cucumber::Cli::Main.new(argv.dup)
    had_failures = cucumber_main.execute!(@cucumber_runtime)
    exit_code = had_failures ? 1 : 0
    exit exit_code
  end
end

Zeus.plan = CustomPlan.new

