# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :cli => "--format RSpec::Pride --tty --fail-fast"  do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'cucumber', :cli => '--tags ~@wip --format Cucumber::Pride::Formatter' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^(bin|lib)/.+$})                 { 'features' }
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

# vim:syntax=ruby