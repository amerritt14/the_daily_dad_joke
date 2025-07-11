# Ensure Tailwind CSS is built during asset precompilation
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])
end
