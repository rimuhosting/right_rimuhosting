require 'rubygems'
require 'hoe'
require "rake/testtask"
require 'rcov/rcovtask'
$: << File.dirname(__FILE__)
require './lib/right_rimuhosting.rb'

# Suppress Hoe's self-inclusion as a dependency for our Gem. This also keeps
# Rake & rubyforge out of the dependency list. Users must manually install
# these gems to run tests, etc.
# TRB 2/20/09: also do this for the extra_dev_deps array present in newer hoes.
# Older versions of RubyGems will try to install developer-dependencies as
# required runtime dependencies....
class Hoe
    def extra_deps
          @extra_deps.reject do |x|
                  Array(x).first == 'hoe'
                      end
            end
      def extra_dev_deps
            @extra_dev_deps.reject do |x|
                    Array(x).first == 'hoe'
                        end
              end
end

Hoe.new('right_rimuhosting', RightRimuHosting::VERSION) do |p|
  p.rubyforge_name = 'rightscale'
  p.author = 'RightScale, Inc.'
  p.email = 'rubygems@rightscale.com'
  p.summary = 'Interface classes for the RimuHosting API'
  p.extra_deps = [['right_http_connection','>= 1.2.4']]
end
