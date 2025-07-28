#!/bin/bash
set -euo pipefail
is_created=0
# Check if relayer_deployer.json doesn't exist
if [ ! -f ".env" ]; then
    echo "Error: .env file not found; exiting..."
    exit 1
fi
if [ ! -f "state/relayer_deployer.json" ]; then
    echo "relayer_deployer.json not found, running relayer-init..."
    ./relayer-init
    cp -Rv relayer_deployer.json state/relayer_deployer.json
    is_created=1
fi
# Read values from relayer_deployer.json and update .env
if [ -f "state/relayer_deployer.json" ]; then
    if [ "$is_created" = 1 ]; then
        OUT_STATE_HEX=$(jq -r '.out_state_hex' state/relayer_deployer.json)
        INDEX=$(jq -r '.index' state/relayer_deployer.json)
        SEED=$(jq -r '.seed_signature' state/relayer_deployer.json)

        # Exit if any of the required values are missing from the json
        if [[ -z "$OUT_STATE_HEX" || "$OUT_STATE_HEX" == "null" || \
            -z "$INDEX" || "$INDEX" == "null" || \
            -z "$SEED" || "$SEED" == "null" ]]; then
            echo "Error: Could not read required values from state/relayer_deployer.json" >&2
            exit 1
        fi
        

        # Update .env file
        # We use a temporary file and cat to avoid "Device or resource busy" errors with sed -i on mounted files.
        sed -e "s#^RELAYER_INIT_STATE=.*#RELAYER_INIT_STATE=$OUT_STATE_HEX#" \
            -e "s#^RELAYER_WALLET_SEED_INDEX=.*#RELAYER_WALLET_SEED_INDEX=$INDEX#" \
            -e "s#^RELAYER_WALLET_SEED=.*#RELAYER_WALLET_SEED=$SEED#" .env > .env.tmp && \
        cat .env.tmp > .env && \
        rm .env.tmp
        
        echo "Updated .env with init state, index and seed from relayer_deployer.json"
        
        sleep 30
    fi
    
    # Execute the main relayer program
    exec ./main
else
    echo "unable to read relayer_deployer.json"
    exit 1
fi


