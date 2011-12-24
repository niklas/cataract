
class ScenarioTodo < Set
  include Term::ANSIColor
  def to_term
    ''.tap do |out|
      out << intense_yellow("TODO scenarios\n\n")
      group_by(&:feature).each do |feature, scenarios|
        out << intense_yellow("  #{feature.title}\n")
        scenarios.each do |scenario|
          out << yellow("   * #{scenario.title}\n")
          out << intense_black("     #{scenario.file_colon_line}\n")
        end
      end
    end
  end
end

$scenarios_todo = ScenarioTodo.new

Before '@todo' do |scenario|
  if scenario.is_a?(Cucumber::Ast::Scenario)
    $scenarios_todo << scenario
  end
end

at_exit do
  unless $scenarios_todo.empty?
    todos = $scenarios_todo.to_term
    STDERR.puts todos
    File.open( Rails.root.join('log/TODO'), 'w' ) do |file|
      file.puts todos
    end
  end
end
