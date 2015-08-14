#
# This salt state adds the requisite iptables exceptions to the
#      INPUT filters to allow the ePO management server to
#      initiate CnC connections to the locally-installed McAfee
#      Agent software.
#
#################################################################

{%- set ePOport = '8591' %}
{%- set fwFile = '/etc/sysconfig/iptables' %}
{%- set lookFor = 'INPUT .* --dport ' + ePOport %}

hbss-FWnotify:
  cmd.run:
    - name: 'echo "Inserting requisite rules into iptables"'

hbss-ePOmanage:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match:
        - state
        - comment
    - comment: "ePO management of McAfee Agent"
    - connstate: NEW
    - dport: {{ ePOport }}
    - proto: tcp
    - save: True
    - unless: 'grep -qw -- "{{ lookFor }}" {{ fwFile }}'

