#!/bin/sh
#
# Ensure salt minion configuration's file_roots are correctly set up
#
#################################################################
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

###
# Declare primary global script vars
###
DATESTAMP="$(date '+%Y%m%d%H%M')"
SALTRPMNAME="salt-minion"
SVCNAME="${SALTRPMNAME}"
HAVESALTRPM=$(rpm --quiet -q ${SALTRPMNAME})$?
MINIONCONF="/etc/salt/minion"
SALTFORMULAPATH="/srv/salt/formulas/enterprise-layer"


#################################
## Define modular-functionality
#################################

# Add formula-path to Salt Minion configuration
function FixMinion() {

   # Preserve original Salt Minion config
   mv ${MINIONCONF} ${MINIONCONF}-${DATESTAMP}

   if [[ $? -eq 0 ]]
   then
      # Do a ranged search-and-replace
      sed '{
         /^file_roots/,/^$/{
            /^$/{N
              s#\n#    - '${SALTFORMULAPATH}'\n\n#
            }
         }
      }' ${MINIONCONF}-${DATESTAMP} > ${MINIONCONF}
   else
      echo "Failed to create minion save-file. Aborting..." > /dev/stderr
      exit 1
   fi
}


##########################
## Main functionality...
##########################

#
if [[ ${HAVESALTRPM} -eq 0 ]]
then
   echo "Found Salt RPM"
elif [[ -s ${MINIONCONF} ]]
then
   echo "Found minion config but no Salt RPM"
else
   echo "No trace of Salt installation found. Aborting..." > /dev/stderr
   exit 1
fi

echo "Adding enterprise-layer formula-path to Minion file_roots"
FixMinion
