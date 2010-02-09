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
    class Interface

      #--------------------------------
      # Images
      #--------------------------------

      # List images. Options: 
      # { "get_distros_response" : { "status_message" : null
      # , "status_code" : 200
      #, "error_info" : null
      #  , "response_type" : "OK"
      #  , "human_readable_message" : "Here are the distros we are offering on new orders."
      #  , "response_display_duration_type" : "REGULAR"
      #  , "distro_infos" : [{ "distro_code" : "lenny"
      #        , "distro_description" : "Debian 5.0 32-bit (aka Lenny, RimuHosting recommended distro)"}
      #    , { "distro_code" : "lenny.64"
      #        , "distro_description" : "Debian 5.0 64-bit (aka Lenny, RimuHosting recommended distro)"}
      #    , { "distro_code" : "centos5"
      #        , "distro_description" : "Centos5 32-bit"}
      #    , { "distro_code" : "centos5.64"
      #        , "distro_description" : "Centos5 64-bit"}
      #    , { "distro_code" : "ubuntu910"
      #        , "distro_description" : "Ubuntu 9.10 32-bit (Karmic Koala, from 2009-10)"}
      #    , { "distro_code" : "ubuntu910.64"
      #        , "distro_description" : "Ubuntu 9.10 64-bit (Karmic Koala, from 2009-10)"}
      #    , { "distro_code" : "ubuntu804"
      #        , "distro_description" : "Ubuntu 8.04 32-bit (Hardy Heron, 5 yr long term support (LTS))"}
      #    , { "distro_code" : "ubuntu804.64"
      #        , "distro_description" : "Ubuntu 8.04 64-bit (Hardy Heron, 5 yr long term support (LTS))"}
      #    , { "distro_code" : "fedora12"
      #        , "distro_description" : "Fedora 12 32-bit"}
      #    , { "distro_code" : "fedora12.64"
      #        , "distro_description" : "Fedora 12 64-bit"}]}}
      def list_images(opts={})
        api_or_cache(:get, "/distributions",opts)
      end

      #--------------------------------
      # Flavors
      #--------------------------------

      # List flavors
      #
      
      def list_flavors(opts={})
        api_or_cache(:get, "/pricing-plans",opts)
      end
      #--------------------------------
      # Servers
      #--------------------------------

      # List servers.
      #
      def list_servers(opts={})
        api_or_cache(:get, "/orders;include_inactive=N", opts)
      end

      # Launch a new server.
      #  +Server_data+ is a hash of params params:
      #   Mandatory: :name, :image_id, :flavor_id
     def create_server(server_data, opts={} )
        body = {
          'new-vps' => {
            'instantiation_options' => {
               'domain_name' => server_data[:name],
               'distro'  => server_data[:image_id],},
            'pricing_plan_code' => server_data[:flavor_id],
          }
        }
        
        api(:post, "/orders/new-vps", opts.merge(:body => body.to_json))
      end

      # Get a server data.
      def get_server(server_id, opts={})
        api(:get, "/orders/order-#{server_id}-blah", opts)
      end

      # Reboot a server.
      #
      #  # Soft reboot
      #  rimuhosting.reboot_server(2290) #=> true
      #
      #  # Hard reboot (power off)
      #  rimuhosting.reboot_server(2290, :hard) #=> true
      #
      def reboot_server(server_id, type = :soft, opts={})
        state = nil
        if type == :soft then
          state = 'RESTARTING'
        else
          state = 'POWERCYCLING'
        end
        
        body = { 'reboot' => { 'running_state' => state } }
        api(:put, "/orders/order-#{server_id}-blan/vps/running-state", opts.merge(:body => body.to_json))
      end

      # Resize a server
      # 
      # :memory_mb 
      # :disk_mb
      def resize_server(server_id, opts={})
        body = { 'resize' => {}}
        body['resize']['memory_mb'] = opts[:memory_mb] if opts[:memory_mb] 
        body['resize']['disk_space_mb'] = opts[:disk_mb] if opts[:disk_mb]
        api(:put, "/orders/order-#{server_id}-blah/vps/parameters", opts.merge(:body => body.to_json))
      end

      # Delete a server
      def delete_server(server_id, opts={})
        api(:delete, "/orders/order-#{server_id}-blah/vps", opts)
      end
    end
  end
end