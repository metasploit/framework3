##
# $Id:
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'


class Metasploit3 < Msf::Auxiliary

	include Msf::Exploit::Remote::SunRPC
	include Msf::Auxiliary::Scanner

	def initialize
		super(
			'Name'          => 'NFS Mount Scanner',
			'Description'   => %q{
				This module scans NFS mounts and their permissions.
			},	
			'Author'	    => ['tebo <tebo [at] attackresearch.com>'],
			'References'	=>
				[
					['URL',	'http://www.ietf.org/rfc/rfc1094.txt'],
				],
			'License'	=> MSF_LICENSE
		)

		register_options([
			OptString.new('HOSTNAME', [false, 'Remote hostname', 'localhost']),
			OptInt.new('GID', [false, 'GID to emulate', 0]),
			OptInt.new('UID', [false, 'UID to emulate', 0])
		], self.class)
	end

	def run_host(ip)

		begin

			hostname	= datastore['HOSTNAME']
			program		= 100005
			progver		= 1
			procedure	= 1

			pport = sunrpc_create('udp', program, progver)
			sunrpc_authunix(hostname, datastore['UID'], datastore['GID'], [])
			resp = sunrpc_call(5, "")
			
			if (resp[3,1].unpack('C')[0] == 0x01)
				print_status("#{ip} Exports found")
				while XDR.decode_int!(resp) == 1 do
					dir = XDR.decode_string!(resp)
					while XDR.decode_int!(resp) == 1 do
						grp = XDR.decode_string!(resp)
					end
					print_line("#{ip}\t#{dir}\t[#{grp}]")
				end
			else
				print_status("#{ip} has no exports")
			end

			sunrpc_destroy	
		rescue ::Rex::Proto::SunRPC::RPCTimeout
		end
	end

end
