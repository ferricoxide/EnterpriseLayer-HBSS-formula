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
function AddToMinion() {

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

      # Restart minion (to reread updated config)
      service ${SALTRPMNAME} restart > /dev/null 2>&1
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

SALTISCFGD=$(grep -q "^file_roots:" ${MINIONCONF})$?

if [[ ${SALTISCFGD} -eq 0 ]]
then
   printf "'file_roots' directive already active...\n"

   if [[ $(grep -q "${SALTFORMULAPATH}" ${MINIONCONF})$? -eq 0 ]]
   then
      printf "\t...and enterprise-layer formula-path already defined.\n"
   else 
      printf "\t...adding enterprise-layer formula-path definition.\n"
      AddToMinion
   fi
else
   printf "'file_roots' directive not yet active. "
   echo
fi
