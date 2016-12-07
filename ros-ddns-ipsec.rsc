#Script for changing IPSEC address when DNS changes.
#Script will iterate through all peers looking for addr_<dnsname> in the comments. It will then
#check for changes in the IP for that DNS name if the ip address differs it will modify the peer
#as well as any policy with the old IP address as well.

#TODO Add log entries for changes.
#TODO Setup netwatch entries for each tunnel


:local ipsecpeer;
:local "vpn-interface-name";
:local "vpn-dns-name";
:local "current-vpn-ip";
:local "new-vpn-ip";
:local ipsecpolicy;
:local iskillneeded;
/ip ipsec peer;
:foreach ipsecpeer in={[find where comment~"^addr_.*"]} do={
	:set "vpn-dns-name" ([get $ipsecpeer comment]);
	:set "vpn-dns-name" ([:pick $"vpn-dns-name" 5 [:len $"vpn-dns-name"]]);
	:set "new-vpn-ip" [:resolve $"vpn-dns-name"]
	:set "current-vpn-ip" [/ip ipsec peer get $ipsecpeer address]
	:set "current-vpn-ip" [:pick $"current-vpn-ip" 0 [:find $"current-vpn-ip" "/"]]
	:if ($"current-vpn-ip" != $"new-vpn-ip") do={
		:set iskillneeded true;
		/ip ipsec peer set $ipsecpeer address=$"new-vpn-ip";
		/ip ipsec policy;
		:foreach ipsecpolicy in={[find where sa-dst-address=$"current-vpn-ip"]} do={
			set $ipsecpolicy sa-dst-address=$"new-vpn-ip";
		}
	}
}

:if ($iskillneeded = true) do={
	/ip ipsec remote-peers kill-connections;
}
