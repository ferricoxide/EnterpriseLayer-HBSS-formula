#
# This salt state runs a downloaded copy of ePO server's exported
#      install.sh. The `install.sh` file is a pre-configured, 
#      self-installing SHell Archive. The SHAR installs the
#      MFEcma and MFErt RPMs, service configuration (XML) files
#      and SSL keys necessary to secure communications between
#      the local McAfee agent software and the ePO server.
#
#################################################################

{%- set hbssRpms = [
	"MFEcma",
	"MFErt",
	] %}
{%- set keystorPath = '/opt/McAfee/cma/scratch/keystore' %}
{%- set keyFiles = [
	"agentprvkey.bin",
	"agentpubkey.bin",
	"serverpubkey.bin",
	"serverreqseckey.bin",
	] %}


{%- for mfeRpm in hbssRpms %}
  {%- if salt['pkg.file_list'](mfeRpm) %}
isinstalled-{{ mfeRpm }}:
  cmd.run:
    - name: 'echo "{{ mfeRpm }} is already installed"'
  {%- endif %}
{%- endfor %}
