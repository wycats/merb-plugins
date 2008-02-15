desc 'Run unit tests'
Rake::TestTask.new('test_unit') do |t|
  t.libs << 'test'
  t.pattern = 'test/unit/*_test.rb'
  t.verbose = true
end

desc 'Run functional tests'
Rake::TestTask.new('test_functional') do |t|
  t.libs << 'test'
  t.pattern = 'test/functional/*_test.rb'
  t.verbose = true
end

desc 'Run all tests'
Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end