#!/bin/bash

# For starting a new chain node
set -e

# Run pre_bootstrap.sh only once
if [ ! -f "/root/.nyks/prebootstrap_done" ]; then
    echo "Running pre_bootstrap.sh for the first time..."
    pre_bootstrap.sh
    touch /root/.nyks/prebootstrap_done
else
    echo "pre_bootstrap.sh already completed. Skipping..."
fi

# Start nyksd and wait
nyksd start &

# Run bootstrap.sh only once
if [ ! -f "/root/.nyks/bootstrap_done" ]; then
sleep 15
    echo "Running bootstrap.sh for the first time..."
    bootstrap.sh
    touch /root/.nyks/bootstrap_done
else
sleep 3
    echo "bootstrap.sh already completed. Skipping..."
fi

echo "Starting btcDepositConfirmer"
exec depositconfirmer

#============================================

# For joining an existing chain node

#!/bin/bash
# set -e

# # Run pre_bootstrap_join.sh only once
# if [ ! -f "/root/.nyks/prebootstrap_join_done" ]; then
#     echo "Running pre_bootstrap_join.sh for the first time..."
#     pre_bootstrap_join.sh
#     touch /root/.nyks/prebootstrap_join_done
# else
#     echo "pre_bootstrap_join.sh already completed. Skipping..."
# fi

# # Start nyksd and wait
# nyksd start &

# # Run bootstrap.sh only once
# if [ ! -f "/root/.nyks/bootstrap_join_done" ]; then
# sleep 15
#     echo "Running bootstrap_join.sh for the first time..."
#     bootstrap_join.sh
#     touch /root/.nyks/bootstrap_join_done
# else
# sleep 3
#     echo "bootstrap_join.sh already completed. Skipping..."
# fi

# echo "Starting btcDepositConfirmer"
# exec depositconfirmer
