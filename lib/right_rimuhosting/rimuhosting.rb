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
      # { "get_pricing_plans_response" : { "status_message" : null
      #  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "Here some pricing plans we are offering on new orders.&nbsp; Note we offer most disk and memory sizes.&nbsp; So if you setup a new server feel free to vary these (e.g. different memory, disk, etc) and we will just adjust the pricing to suit.&nbsp; If you are an NZ-based customer then we would need to add GST."
	#  , "response_display_duration_type" : "REGULAR"
	#  , "pricing_plan_infos" : [{ "pricing_plan_code" : "SYD1"
	#        , "pricing_plan_description" : "MiroVPSSyd (Sydney-based Server)"
	#        , "monthly_recurring_fee" : 32.68
	#        , "monthly_recurring_amt" : { "amt" : 35.0
	#            , "currency" : "CUR_AUD"
	#            , "amt_usd" : 32.68}
	#        , "minimum_memory_mb" : 100
	#        , "minimum_disk_gb" : 4
	#        , "minimum_data_transfer_allowance_gb" : 6
	#        , "see_also_url" : "http://rimuhosting.com/order/serverdetails.jsp?plan=SYD1"
	#        , "server_type" : "VPS"
	#        , "offered_at_data_center" : { "data_center_location_code" : "DCSYDNEY"
	#            , "data_center_location_name" : "Sydney"
	#            , "data_center_location_country_2ltr" : "AU"}},
      #    ... ]}

      def list_flavors(opts={})
        api_or_cache(:get, "/pricing-plans;server_type=VPS",opts)
      end
      #--------------------------------
      # Servers
      #--------------------------------

      # List servers.
      #
      #{ "get_orders_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "Found 16 orders"
	#  , "response_display_duration_type" : "REGULAR"
	#  , "about_orders" : [{ "order_oid" : 184612801
	#        , "domain_name" : "rimuhosting.jclouds-4618"
	#        , "slug" : "order-184612801-rimuhosting-jclouds-4"
	#        , "billing_oid" : 50081656
	#        , "is_on_customers_own_physical_server" : false
	#        , "vps_parameters" : { "memory_mb" : 160
	#            , "disk_space_mb" : 4096
	#            , "disk_space_2_mb" : 0}
	#        , "host_server_oid" : "836"
	#        , "server_type" : "VPS"
	#        , "data_transfer_allowance" : { "data_transfer_gb" : 30
	#            , "data_transfer" : "30"}
	#        , "billing_info" : { "monthly_recurring_fee" : 20.19
	#            , "monthly_recurring_amt" : { "amt" : 20.19
	#                , "currency" : "CUR_USD"
	#                , "amt_usd" : 20.19}
	#            , "suspended_date" : null
	#            , "prepaid_until" : null
	#            , "order_date" : { "ms_since_epoch": 1270440210000, "iso_format" : "2010-04-05T04:03:30Z", "users_tz_offset_ms" : 43200000}
	#            , "cancellation_date" : null}
	#        , "location" : { "data_center_location_code" : "DCDALLAS"
	#            , "data_center_location_name" : "Dallas"
	#            , "data_center_location_country_2ltr" : "US"}
	#        , "allocated_ips" : { "primary_ip" : "74.50.60.216"
	#            , "secondary_ips" : []}
	#        , "running_state" : "RUNNING"
	#        , "distro" : "ubuntu910.64"}
      #        , ... ]}
      #
      def list_servers(opts={})
        api_or_cache(:get, "/orders;include_inactive=N", opts)
      end

      # Launch a new server.
      #  +Server_data+ is a hash of params params:
      #   Mandatory: :name, :image_id, :flavor_id
      #
      # { "post_new_vps_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : null
	#  , "response_display_duration_type" : "REGULAR"
	#  , "setup_messages" : ["Selected user as the logged in user: Ivan Meredith"
	#    , "Selected billing details as the first 'wire' billing details found for the user: Wire Transfer"
	#    , "No VPS paramters provided, using default values."
	#    , "'memory_mb' not provided, setting to 160MB."
	#    , "'disk_space_mb' not provided, setting to 4GB."]
	#  , "about_order" : { "order_oid" : 279599011
	#      , "domain_name" : "rightscale-test.com"
	#      , "slug" : "order-279599011-rightscale-test-com"
	#      , "billing_oid" : 50081656
	#      , "is_on_customers_own_physical_server" : false
	#      , "vps_parameters" : { "memory_mb" : 160
	#          , "disk_space_mb" : 4096
	#          , "disk_space_2_mb" : 0}
	#      , "host_server_oid" : "835"
	#      , "server_type" : "VPS"
	#      , "data_transfer_allowance" : { "data_transfer_gb" : 30
	#          , "data_transfer" : "30"}
	#      , "billing_info" : { "monthly_recurring_fee" : 20.19
	#          , "monthly_recurring_amt" : { "amt" : 20.19
	#              , "currency" : "CUR_USD"
	#              , "amt_usd" : 20.19}
	#          , "suspended_date" : null
	#          , "prepaid_until" : null
	#          , "order_date" : { "ms_since_epoch": 1271117910000, "iso_format" : "2010-04-13T00:18:30Z", "users_tz_offset_ms" : 43200000}
	#          , "cancellation_date" : null}
	#      , "location" : { "data_center_location_code" : "DCDALLAS"
	#          , "data_center_location_name" : "Dallas"
	#          , "data_center_location_country_2ltr" : "US"}
	#      , "allocated_ips" : { "primary_ip" : "74.50.61.12"
	#          , "secondary_ips" : []}
	#      , "running_state" : "RUNNING"
	#      , "distro" : "lenny"}
	#  , "new_order_request" : { "billing_oid" : 0
	#      , "user_oid" : 0
	#      , "host_server_oid" : null
	#      , "ip_request" : { "num_ips" : 1
	#          , "extra_ip_reason" : ""}
	#      , "vps_parameters" : { "memory_mb" : 160
	#          , "disk_space_mb" : 4096
	#          , "disk_space_2_mb" : 0}
	#      , "pricing_plan_code" : "MIRO1B"
	#      , "instantiation_options" : { "domain_name" : "rightscale-test.com"
	#          , "control_panel" : "webmin"
	#          , "password" : "repeew69"
	#          , "distro" : "lenny"}
	#      , "instantiation_via_clone_options" : null
	#      , "file_injection_data" : null}
	#  , "running_vps_info" : { "pings_ok" : true
	#      , "current_kernel" : "default"
	#      , "current_kernel_canonical" : "2.6.30.5-xenU.i386"
	#      , "last_backup_message" : ""
	#      , "is_console_login_enabled" : false
	#      , "console_public_authorized_keys" : null
	#      , "is_backup_running" : false
	#      , "is_backups_enabled" : true
	#      , "next_backup_time" : { "ms_since_epoch": 1271134800000, "iso_format" : "2010-04-13T05:00:00Z", "users_tz_offset_ms" : 43200000}
	#      , "vps_uptime_s" : 15
	#      , "vps_cpu_time_s" : 11
	#      , "running_state" : "RUNNING"
	#      , "is_suspended" : false}}}
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
      #   { "get_order_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "Information about rimuhosting.jclouds-4618"
	#  , "response_display_duration_type" : "REGULAR"
	#  , "about_order" : { "order_oid" : 184612801
	#      , "domain_name" : "rimuhosting.jclouds-4618"
	#      , "slug" : "order-184612801-rimuhosting-jclouds-4"
	#      , "billing_oid" : 50081656
	#      , "is_on_customers_own_physical_server" : false
	#      , "vps_parameters" : { "memory_mb" : 160
	#          , "disk_space_mb" : 4096
	#          , "disk_space_2_mb" : 0}
	#      , "host_server_oid" : "836"
	#      , "server_type" : "VPS"
	#      , "data_transfer_allowance" : { "data_transfer_gb" : 30
	#          , "data_transfer" : "30"}
	#      , "billing_info" : { "monthly_recurring_fee" : 20.19
	#          , "monthly_recurring_amt" : { "amt" : 20.19
	#              , "currency" : "CUR_USD"
	#              , "amt_usd" : 20.19}
	#          , "suspended_date" : null
	#          , "prepaid_until" : null
	#          , "order_date" : { "ms_since_epoch": 1270440210000, "iso_format" : "2010-04-05T04:03:30Z", "users_tz_offset_ms" : 43200000}
	#          , "cancellation_date" : null}
	#      , "location" : { "data_center_location_code" : "DCDALLAS"
	#          , "data_center_location_name" : "Dallas"
	#          , "data_center_location_country_2ltr" : "US"}
	#      , "allocated_ips" : { "primary_ip" : "74.50.60.216"
	#          , "secondary_ips" : []}
	#      , "running_state" : "RUNNING"
	#      , "distro" : "ubuntu910.64"}}}
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
      #{ "put_running_state_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "rimuhosting.jclouds-4618 restarted.  After the reboot rimuhosting.jclouds-4618 is pinging OK."
	#  , "response_display_duration_type" : "REGULAR"
	#  , "is_restarted" : true
	#  , "is_pinging" : true
	#  , "running_vps_info" : { "pings_ok" : true
	#      , "current_kernel" : "default64"
	#      , "current_kernel_canonical" : "2.6.30.5-xenU.x86_64"
	#      , "last_backup_message" : "Finished backup at 20100407-0507"
	#      , "is_console_login_enabled" : true
	#      , "console_public_authorized_keys" : null
	#      , "is_backup_running" : false
	#      , "is_backups_enabled" : true
	#      , "next_backup_time" : { "ms_since_epoch": 1271221200000, "iso_format" : "2010-04-14T05:00:00Z", "users_tz_offset_ms" : 43200000}
	#      , "vps_uptime_s" : 50
	#      , "vps_cpu_time_s" : 1
	#      , "running_state" : "RUNNING"
	#      , "is_suspended" : false}
	#  , "host_server_info" : { "is_host64_bit_capable" : true
	#      , "default_kernel_i386" : "2.6.30.5-xenU.i386"
	#      , "default_kernel_x86_64" : "2.6.30.5-xenU.x86_64"
	#      , "cpu_model_name" : "Intel(R) Xeon(R) CPU           E5506  @ 2.13GHz"
	#      , "host_num_cores" : 1
	#      , "host_xen_version" : "3.4.2"
	#      , "hostload" : [1.76
	#        , 0.95
	#        , 0.46]
	#      , "host_uptime_s" : 5156988
	#      , "host_mem_mb_free" : 28544
	#      , "host_mem_mb_total" : 73718
	#      , "running_vpss" : 74}
	#  , "running_state_messages" : null}}

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
      #
      # { "put_running_vps_data_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "Resource change completed."
	#  , "response_display_duration_type" : "REGULAR"
	#  , "resource_change_result" : { "original_pricing" : { "amt" : 20.19
	#          , "cur" : "CUR_USD"}
	#      , "new_pricing" : { "amt" : 30.32
	#          , "cur" : "CUR_USD"}
	#      , "resource_change_messages" : ["Initiating a memory change on 'rimuhosting.jclouds-4618'."
	#        , "host836.rimuhosting.com has 28,544MB out of 73,718MB of memory available, and 275GB out of 1,863GB of disk space available."
	#        , "Updating the rimuhosting.jclouds-4618 parameters file memory setting."
	#        , "Restarting rimuhosting.jclouds-4618 so the memory change can occur."
	#        , "rimuhosting.jclouds-4618 pinging OK after the restart."
	#        , "Memory change from 160MB to 400MB.  Date: 2010-04-13.  Monthly pricing changed from 20.19 USD to 30.32 USD, 10.13 USD more.  Pro-rated change of 5.99 USD over 18 days.  Added an 'extra fee' of 23.13 USD."
	#        , "Completed."]
	#      , "were_resources_changed" : true}
	#  , "resource_change_request" : { "memory_mb" : 400
	#      , "disk_space_mb" : null
	#      , "disk_space_2_mb" : null}
	#  , "about_order" : { "order_oid" : 184612801
	#      , "domain_name" : "rimuhosting.jclouds-4618"
	#      , "slug" : "order-184612801-rimuhosting-jclouds-4"
	#      , "billing_oid" : 50081656
	#      , "is_on_customers_own_physical_server" : false
	#      , "vps_parameters" : { "memory_mb" : 160
	#          , "disk_space_mb" : 4096
	#          , "disk_space_2_mb" : 0}
	#      , "host_server_oid" : "836"
	#      , "server_type" : "VPS"
	#      , "data_transfer_allowance" : { "data_transfer_gb" : 30
	#          , "data_transfer" : "30"}
	#      , "billing_info" : { "monthly_recurring_fee" : 20.19
	#          , "monthly_recurring_amt" : { "amt" : 20.19
	#              , "currency" : "CUR_USD"
	#              , "amt_usd" : 20.19}
	#          , "suspended_date" : null
	#          , "prepaid_until" : null
	#          , "order_date" : { "ms_since_epoch": 1270440210000, "iso_format" : "2010-04-05T04:03:30Z", "users_tz_offset_ms" : 43200000}
	#          , "cancellation_date" : null}
	#      , "location" : { "data_center_location_code" : "DCDALLAS"
	#          , "data_center_location_name" : "Dallas"
	#          , "data_center_location_country_2ltr" : "US"}
	#      , "allocated_ips" : { "primary_ip" : "74.50.60.216"
	#          , "secondary_ips" : []}
	#      , "running_state" : "RUNNING"
	#      , "distro" : "ubuntu910.64"}}}

      def resize_server(server_id, opts={})
        body = { 'resize' => {}}
        body['resize']['memory_mb'] = opts[:memory_mb] if opts[:memory_mb] 
        body['resize']['disk_space_mb'] = opts[:disk_mb] if opts[:disk_mb]
        api(:put, "/orders/order-#{server_id}-blah/vps/parameters", opts.merge(:body => body.to_json))
      end

      # Delete a server
      #
      # { "delete_server_response" : { "status_message" : null
	#  , "status_code" : 200
	#  , "error_info" : null
	#  , "response_type" : "OK"
	#  , "human_readable_message" : "Server removed"
	#  , "response_display_duration_type" : "REGULAR"
	#  , "cancel_messages" : ["rimuhosting.jclouds-4618 is being shut down."
	#    , "If you need to un-cancel the server please contact our support team."
	#    , "Thank you for having hosted rimuhosting.jclouds-4618 with us."]}}

      def delete_server(server_id, opts={})
        api(:delete, "/orders/order-#{server_id}-blah/vps", opts)
      end
    end
  end
end
