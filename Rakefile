require 'fileutils'

task :default => [:build]

desc 'Build analyze-jwplayer.swf'
task :build do
  puts 'Compiling analyze-jwplayer.swf...'
  puts ''
  puts %x{cd plugins/analyze; sh build.sh}
  puts ''
  puts 'Done!'
end
