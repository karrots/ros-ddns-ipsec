#Script for changing the local-address of EoIP tunnels when a new WAN address is
#obtained. Due to no IP change hooks in the DHCP client change detection will
#need to be done via scheduled script or a netwatch script.

#The script will iterate through eoip tunnels with the comment of
#"int_<interfacename>". It will then use <interfacename> to search the
#dhcp-client list for a corresponding interface to obtain the current IP address
#from.

:local eoiptun;
:local "current-vpn-ip";
:local "new-vpn-ip";
:local "wan-int"

/interface eoip;
:foreach eoiptun in={[find where comment~"^int_.*"]} do={
	:set "wan-int" ([get $eoiptun comment]);
	:log info ($"wan-int");
	:set "wan-int" ([:pick $"wan-int" 4 [:len $"wan-int"]]);
	:log info ($"wan-int");
	:set "new-vpn-ip" [/ip dhcp-client get [find interface~$"wan-int"] address ]
	:log info ($"new-vpn-ip");
    :set "new-vpn-ip" [:pick $"new-vpn-ip" 0 [:find $"new-vpn-ip" "/"]]
	:log info ($"new-vpn-ip");
	:set "current-vpn-ip" [/interface eoip get $eoiptun local-address]
	:log info ($"current-vpn-ip");
	:if ($"current-vpn-ip" != $"new-vpn-ip") do={
        /interface eoip set $eoiptun local-address=[:toip $"new-vpn-ip"];
	}
}
