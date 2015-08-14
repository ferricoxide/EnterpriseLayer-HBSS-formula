#
# This salt state runs a downloaded copy of ePO server's exported
#      install.sh. The `install.sh` file is a pre-configured, 
#      self-installing SHell Archive. The SHAR installs the
#      MFEcma and MFErt RPMs, service configuration (XML) files
#      and SSL keys necessary to secure communications between
#      the local McAfee agent software and the ePO server.
#
#################################################################

{%- set hbssRpms = "MFEcma MFErt" %}
{%- set keystorPath = '/opt/McAfee/cma/scratch/keystore' %}
{%- set keyFiles = [
	"agentprvkey.bin",
	"agentpubkey.bin",
	"serverpubkey.bin",
	"serverreqseckey.bin",
	] %}

HBSS-stageFile:
  file.managed:
  - name: /root/install.sh
  - source: file:///var/tmp/install.sh
  - source_hash: md5=25f62dd66653b148b5792f0bc3211559
  - user: root
  - group: root
  - mode: 0700

HBSS-installsh:
  cmd.run:
    - name: 'echo "Run HBSS installer"'
    - cwd: '/root'
    - onlyif: 
      - HBSS-stageFile
    - unless:
      - 'rpm --quiet -q MFErt'
      - 'rpm --quiet -q MFEcma'

