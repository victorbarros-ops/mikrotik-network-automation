# -------------------------------------------------------------------------
# SCRIPT: Dual WAN Failover with Recursive Routing
# DESCRIPTION: Manages 2 PPPoE connections with automatic failover based on
#              recursive routing check (pinging 1.1.1.1 and 8.8.8.8).
# AUTHOR: Victor Augusto (Adapted)
# -------------------------------------------------------------------------

:local createRoute do={
  /log/info message="Add route $remoteAddress"
  /ip/route/add dst-address=$dstAddress gateway=$remoteAddress scope=10 target-scope=10 distance=$distance comment=("D".$wan)
  /ip/route/add dst-address=0.0.0.0/0 gateway=$gateway scope=30 target-scope=11 distance=$distance check-gateway=ping routing-table=main suppress-hw-offload=no comment=("D".$wan)
}

:local wanConf {
  {
  "remoteAddress"=$"remote-address";
  "dstAddress"=1.1.1.1/32;
  "gateway"=1.1.1.1;
  "distance"=1;
  "wan"="pppoe-out1"
  };
  {
  "remoteAddress"=$"remote-address";
  "dstAddress"=8.8.8.8/32;
  "gateway"=8.8.8.8;
  "distance"=2;
  "wan"="pppoe-out2"
  };
}

:local getInterface [/interface/get $interface];
:foreach w in=$wanConf do={
 :local wan ($w->"wan");
 :if ($wan = ($getInterface->"name")) do={
  :if ([:len [/ip/route/print as-value where comment=("D".$wan)]] > 0) do={
   /log/info message="Remove route D$wan"
   /ip/route/remove [find comment=("D".$wan)]
  }
  
  $createRoute remoteAddress=($w->"remoteAddress") dstAddress=($w->"dstAddress") gateway=($w->"gateway") distance=($w->"distance") wan=$wan
 }
}

:local removeRoute do={ 
 /ip/route/remove [find comment=$wan]
}

:local gw [/ip/route/print as-value where gateway=$"remote-address"];
:if (($gw->0->"comment") != "") do={
 $removeRoute wan=($gw->0->"comment")
}
