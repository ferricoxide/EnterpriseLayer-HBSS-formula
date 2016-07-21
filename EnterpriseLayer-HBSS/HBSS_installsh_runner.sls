#
# This salt state runs a downloaded copy of ePO server's exported
#      install.sh. The `install.sh` file is a pre-configured,
#      self-installing SHell Archive. The SHAR installs the
#      MFEcma and MFErt RPMs, service configuration (XML) files
#      and SSL keys necessary to secure communications between
#      the local McAfee agent software and the ePO server.
#
#################################################################

{%- set repoHost = pillar['hbss']['repo_uri_host'] %}
{%- set repoPath = pillar['hbss']['repo_uri_root_path'] %}
{%- set repoEnv = pillar['hbss']['repo_uri_config_path'] %}
{%- set repoFullPath = repoHost ~ '/' ~ repoPath ~ '/' ~ repoEnv %}
{%- set repoFileSrc = pillar['hbss']['package_name'] %}
{%- set repoFileHash = pillar['hbss']['package_hash'] %}
{%- set hashType = pillar['hbss']['package_hashtype'] %}
{%- set fileSrc = repoFullPath ~ '/' ~ repoFileSrc %}
{%- set fileHash = repoFullPath ~ '/' ~ repoFileHash %}
{%- set hbssRpms = salt['pillar.get'](
  'hbss:hbssRpms',
  [ 'MFEcma', 'MFErt' ]) %}
{%- set MFEinstallRoot = pillar['hbss']['install_root_dir'] %}
{%- set keystorPath = MFEinstallRoot ~ '/' ~ pillar['hbss']['keystorPath'] %}
{%- set keyFiles = pillar['hbss']['keyFiles'] %}

HBSS install dependencies:
  pkg.installed:
    - pkgs:
      - unzip

HBSS-stageFile:
  file.managed:
  - name: /root/install.sh
  - source: {{ fileSrc }}
  - source_hash: {{ hashType }}={{ repoFileHash }}
  - user: root
  - group: root
  - mode: 0700
  - require:
    - pkg: HBSS install dependencies

HBSS-installsh:
  cmd.run:
    - name: 'sh {{ repoFileSrc }} -i'
    - cwd: '/root'
    - require:
      - file: HBSS-stageFile
    - unless:
{%- for RPM in hbssRpms %}
      - 'rpm --quiet -q {{ RPM }}'
{%- endfor %}
{%- for keyFile in keyFiles %}
      - 'test -s {{ keystorPath }}/{{ keyFile }}'
{%- endfor %}
