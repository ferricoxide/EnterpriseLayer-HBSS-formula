#
# This salt state adds the requisite iptables exceptions to the
#      INPUT filters to allow the ePO management server to
#      initiate CnC connections to the locally-installed McAfee
#      Agent software.
#
#################################################################

{%- set hbssPorts = salt['pillar.get'](
  'hbss:client_in_ports',
  [ '8591' ]) %}
{%- set fwFile = '/etc/sysconfig/iptables' %}

hbss-FWnotify:
  cmd.run:
    - name: 'echo "Inserting requisite rules into iptables"'

{%- for inport in hbssPorts -%}
{%- set lookFor = 'INPUT .* --dport ' ~ inport %}
hbss-ePOmanage-port_{{ inport }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match:
        - state
        - comment
    - comment: "ePO management of McAfee Agent"
    - connstate: NEW
    - dport: {{ inport }}
    - proto: tcp
    - save: True
    - unless: 'grep -qw -- "{{ lookFor }}" {{ fwFile }}'
{%- endfor %}
