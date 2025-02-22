The McAfee HBSS ePO console exports pre-configured, self-installing SHell ARchive bundles. Bundle-updates should be performed on a regular basis - or any time that HBSS components have been modified. All bundles will be named install.sh and should be made available via a network-based share (HTTP preferred, but CIFS is acceptable. To use the bundles - outside of an CM automation-framework - perform the following steps on the HBSS client:

1. Download a copy of the `install.sh` file from the network share and copy to the installation-target (HBSS client).
2. Change the mode of the `install.sh` script to be executable (e.g., `chmod a+x install.sh`)
3. Configure the client's host-based firewall to allow inbound connetions from the HBSS server. For `iptables` do the following:
  1. Issue `iptables -A <CHAIN> -p tcp -m tcp --dport <AgentWakupPort> -m comment --comment "McAfee Agent" -j ACCEPT` to add the necessary exceptions to the in-memory rule-sets

    **Note:** If iptables implements default-deny by having a catch-all deny-handler as final rule in the chain, this operation will need to be modified to be an INSERT ahead of that rule rather than the APPEND operation shown.

  2. Issue a `service iptables save` to save the updated, in-memory rule-sets to disk.
4. Use the `cmdagent` (default install location is `/opt/McAfee/cma/bin`) to initiate  and verify agent/server communications. Execute:

  ~~~
/opt/McAfee/cma/bin/cmdagent -P -E -C -F
  ~~~

  If this is not done, the client will need to wait for an ePO neetwork scan to discover the client. This may result in unacceptable delays for ePO-based enforcement actions to begin.
5. Communications may be further verified by viewing the contents of the agent's log-file, `/opt/McAfee/cma/scratch/etc/log`

**Note:** Before running the HBSS `install.sh` script, make sure that previous versions of the `MFEcma` and `MFErt` RPMs are not installed.
