namespace(:test) do
  Rake::TestTask.new('models') do |t|
    t.libs << 'test'
    t.pattern = 'test/models/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new('controllers') do |t|
    t.libs << 'test'
    t.pattern = 'test/controllers/*_test.rb'
    t.verbose = true
  end
end

desc 'Run all tests'
Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end