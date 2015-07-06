# MY_UUID ${my_uuid}
# PEER_UUID ${peer_uuid}
# FLOATING_IP ${floating_ip}

vrrp_instance VI_1 {
   debug 2
   interface eth0
   state ${my_state}
   virtual_router_id 42
   priority ${my_priority}
   unicast_src_ip ${my_ip}
   unicast_peer {
       ${peer_ip}
   }

   notify_master /etc/keepalived/master.sh
}
