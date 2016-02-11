guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  files.each do |file|  # Assume files are symlinked from somewhere
    watch helper.real_path(file)
  end
end

guard :rdoc, output: 'public/doc' do
  watch /^README/
  watch %r{.+\.rb$}
end
