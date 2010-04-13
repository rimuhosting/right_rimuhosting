#
# Copyright (c) 2009 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
module Rightscale
  module RimuHosting

    class BenchmarkingBlock #:nodoc:
      attr_accessor :parser, :service
      def initialize
        # Benchmark::Tms instance for service access benchmarking.
        @service = Benchmark::Tms.new()
        # Benchmark::Tms instance for parsing benchmarking.
        @parser = Benchmark::Tms.new()
      end
    end

    class Interface
      RIMUHOSTING_ENDPOINT = "https://rimuhosting.com/r"
      DEFAULT_LIMIT = 1000

      @@rimuhosting_problems = []
      def self.rimuhosting_problems
        @@rimuhosting_problems
      end

      @@bench = Rightscale::RimuHosting::BenchmarkingBlock.new
      def self.bench
        @@bench
      end

      @@params = {}
      def self.params
        @@params
      end

      def params
        @params
      end

      def merged_params #:nodoc:
        @@params.merge(@params)
      end
      
      @@caching = false

      attr_accessor :api_key
      attr_reader   :auth_headers
      attr_reader   :auth_token
      attr_accessor :auth_endpoint
      attr_accessor :service_endpoint
      attr_accessor :last_request
      attr_accessor :last_response
      attr_accessor :last_error
      attr_reader   :logger
      attr_reader   :cache

      # Parses an endpoint and returns a hash of data
      def endpoint_to_host_data(endpoint)# :nodoc:
        service = URI.parse(endpoint).path
        service.chop! if service[/\/$/]  # remove a trailing '/'
        { :server   => URI.parse(endpoint).host,
          :service  => service,
          :protocol => URI.parse(endpoint).scheme,
          :port     => URI.parse(endpoint).port }
      end

    
      def initialize(api_key=nil, params={})
        @params = params
        # Auth data
        @api_key  = api_key || ENV['RIMUHOSTING_API_KEY']
        @auth_token = "rimuhosting apikey=#{@api_key}"
        @service_endpoint_data = endpoint_to_host_data(RIMUHOSTING_ENDPOINT)
        # Logger
        @logger = @params[:logger] || (defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER) || Logger.new(STDOUT)
        # Request and response
        @last_request = nil
        @last_response = nil
        # cache
        @cache = {}
      end
  
      def generate_request(verb, path='', opts={}) #:nodoc:
        # Form a valid http verb: 'Get', 'Post', 'Put', 'Delete'
        verb = verb.to_s.capitalize
        raise "Unsupported HTTP verb #{verb.inspect}!" unless verb[/^(Get|Post|Put|Delete)$/]
        # Select an endpoint
        endpoint_data = (opts[:endpoint_data] || @service_endpoint_data).dup
        # Fix a path
        path = "/#{path}" if !path.blank? && !path[/^\//]
        # Request variables
        request_params = opts[:vars].to_a.map do |key, value|
          key = key.to_s.downcase
          # Make sure we do not pass a Time object instead of integer for 'changes-since'
          value = value.to_i if key == 'changes-since'
          "#{URI.escape(key)}=#{URI.escape(value.to_s)}"
        end.join('&')
        # Build a request final path
        service = opts[:no_service_path] ? '' : endpoint_data[:service]
        request_path  = "#{service}#{path}"
        request_path  = '/' if request_path.blank?
        request_path += "?#{request_params}" unless request_params.blank?
        # Create a request
        request = eval("Net::HTTP::#{verb}").new(request_path)
        request.body = opts[:body] if opts[:body]
        # Set headers
        opts[:headers].to_a.each do |key, value|
          key = key.to_s.downcase
        # make sure 'if-modified-since' is always httpdated
          if key == 'if-modified-since'
            value = Time.at(value)     if value.is_a?(Fixnum)
            value = value.utc.httpdate if value.is_a?(Time)
          end
          puts value.to_s
          request[key] = value.to_s
        end
        request['content-type'] ||= 'application/json'
        request['accept'] = 'application/json'
       
        # prepare output hash
        endpoint_data.merge(:request => request)
      end

      # Just requests a remote end
      def internal_request_info(request_hash) #:nodoc:
        on_event(:on_request, request_hash)
        @connection  ||= Rightscale::HttpConnection.new(:exception => Error, :logger => @logger, :http_connection_read_timeout => 600)
        @last_request  = request_hash[:request]
        @@bench.service.add!{ @last_response = @connection.request(request_hash) }
        on_event(:on_response)
      end

      # Request a remote end and process any errors is found
      def request_info(request_hash) #:nodoc:
        internal_request_info(request_hash)
        result = nil
        # check response for success...
        case @last_response.code
        when '200'  # SUCCESS
          @error_handler = nil
          on_event(:on_success)
          
          # Parse a response body. If the body is empty the return +true+
          @@bench.parser.add! do
            result = if @last_response.body.blank? then true
                     else
                       case @last_response['content-type'].first
                       when 'application/json' then JSON::parse(@last_response.body)
                       else @last_response.body
                       end
                     end
          end
        #TODO: add error checking for rimuhosting errros
        else # ERROR
          @last_error = HttpErrorHandler::extract_error_description(@last_response, merged_params[:verbose_errors])
          on_event(:on_error, @last_error)
          @error_handler ||= HttpErrorHandler.new(self, :errors_list => self.class.rimuhosting_problems)
          result           = @error_handler.check(request_hash)
          @error_handler   = nil
          if result.nil?
            on_event(:on_failure)
            raise Error.new(@last_error)
          end
        end
        result
      rescue
        @error_handler = nil
        raise
      end

      #  simple_path('/v1.0/123456/images/detail?var1=var2') #=> '/images/detail?var1=var2'
      def simple_path(path) # :nodoc:
        (path[/^#{@service_endpoint_data[:service]}(.*)/] && $1) || path
      end

      #  simple_path('/v1.0/123456/images/detail?var1=var2') #=> '/images/detail'
      def cached_path(path) # :nodoc:
        simple_path(path)[/([^?]*)/] && $1
      end

      
      # Call RimuHosting
      def api(verb, path='', options={}) # :nodoc:
        options[:headers] ||= {}
        options[:headers]['Authorization'] = @auth_token
        request_info(generate_request(verb, path, options))
      end

      # Call RimuHosting. Use cache if possible
      # TODO: figure out what to do here. And if it applies to rimuhosting.
      def api_or_cache(verb, path, options={}) # :nodoc:
        api(verb, path, options)
      end

      # Events (callbacks) for logging and debugging features.
      # These callbacks do not catch low level connection errors that are handled by RightHttpConnection but
      # only HTTP errors.
      def on_event(event, *params) #:nodoc:
        self.merged_params[event].call(self, *params) if self.merged_params[event].kind_of?(Proc)
      end

    end

    #------------------------------------------------------------
    # Error handling
    #------------------------------------------------------------

    class NoChange < RuntimeError
    end

    class Error < RuntimeError
    end

    class HttpErrorHandler # :nodoc:

      # Some error are too ennoing to be logged: '404' comes very often when one calls
      # incrementally_list_something
#      SKIP_LOGGING_ON   = ['404']
      SKIP_LOGGING_ON   = []

      @@reiteration_start_delay = 0.2
      def self.reiteration_start_delay
        @@reiteration_start_delay
      end
      def self.reiteration_start_delay=(reiteration_start_delay)
        @@reiteration_start_delay = reiteration_start_delay
      end
      @@reiteration_time = 5
      def self.reiteration_time
        @@reiteration_time
      end
      def self.reiteration_time=(reiteration_time)
        @@reiteration_time = reiteration_time
      end

      #TODO make this rimu specific
      # Format a response error message.
      def self.extract_error_description(response, verbose=false) #:nodoc:
        message = nil
        Interface::bench.parser.add! do
          message = begin
          puts response.body
                      if response.body[/^<!DOCTYPE HTML PUBLIC/] then response.message
                      else
                        message = JSON::parse(response.body)['jaxrs_response']['error_info']['full_error_message']
                      end
                    rescue
                      response.message
                    end
        end
        "#{response.code}: #{message}"
      end

      # params:
      #  :reiteration_time
      #  :errors_list
      def initialize(handle, params={}) #:nodoc:
        @handle        = handle           # Link to RightEc2 | RightSqs | RightS3 instance
        @started_at    = Time.now
        @stop_at       = @started_at  + (params[:reiteration_time] || @@reiteration_time)
        @errors_list   = params[:errors_list] || []
        @reiteration_delay = @@reiteration_start_delay
        @retries       = 0
      end

      # Process errored response
      def check(request_hash)  #:nodoc:
        result      = nil
        error_found = false
        response    = @handle.last_response
        error_message = @handle.last_error
        # Log the error
        logger = @handle.logger
        unless SKIP_LOGGING_ON.include?(response.code)
          logger.warn("##### #{@handle.class.name} returned an error: #{error_message} #####")
          logger.warn("##### #{@handle.class.name} request: #{request_hash[:server]}:#{request_hash[:port]}#{request_hash[:request].path} ####")
        end
        # now - check the error
        @errors_list.each do |error_to_find|
          if error_message[/#{error_to_find}/i]
            error_found = error_to_find
            logger.warn("##### Retry is needed, error pattern match: #{error_to_find} #####")
            break
          end
        end
        # yep, we know this error and have to do a retry when it comes
        if error_found || REAUTHENTICATE_ON.include?(@handle.last_response.code)
          # check the time has gone from the first error come
          # Close the connection to the server and recreate a new one.
          # It may have a chance that one server is a semi-down and reconnection
          # will help us to connect to the other server
          if (Time.now < @stop_at)
            @retries += 1
            @handle.logger.warn("##### Retry ##{@retries} is being performed. Sleeping for #{@reiteration_delay} sec. Whole time: #{Time.now-@started_at} sec ####")
            sleep @reiteration_delay
            @reiteration_delay *= 2
            # Always make sure that the fp is set to point to the beginning(?)
            # of the File/IO. TODO: it assumes that offset is 0, which is bad.
            if request_hash[:request].body_stream && request_hash[:request].body_stream.respond_to?(:pos)
              begin
                request_hash[:request].body_stream.pos = 0
              rescue Exception => e
                logger.warn("Retry may fail due to unable to reset the file pointer -- #{self.class.name} : #{e.inspect}")
              end
            end
            # Oops it seems we have been asked about reauthentication..
            if REAUTHENTICATE_ON.include?(@handle.last_response.code)
              @handle.authenticate
              @handle.request_info(request_hash)
            end
            # Make another try
            result = @handle.request_info(request_hash)
          else
            logger.warn("##### Ooops, time is over... ####")
          end
        end
        result
      end

    end
  end
end