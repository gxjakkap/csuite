#!/usr/bin/env bash

set -euo pipefail

LATEST_LINK="https://raw.githubusercontent.com/gxjakkap/csuite/main/scriptversions.json"
REPO_BASE="https://raw.githubusercontent.com/gxjakkap/csuite/main"
LOCAL_JSON_PATH=".csuite/local_scriptversions.json"
REMOTE_JSON_PATH=".csuite/.remote_scriptversions.json"

echo "Checking for updates..."
curl -sSL "$LATEST_LINK" -o "$REMOTE_JSON_PATH" || { echo "Error: Failed to fetch remote version information."; exit 1; }

if [ ! -f "$LOCAL_JSON_PATH" ]; then
    echo "No local scriptversions.json found. Please remove .csuite folder and run 'npx create-csuite' to download it."
    rm -f "$REMOTE_JSON_PATH"
    exit 1
fi

STALE_SCRIPTS=$(python3 -c "
import json
import sys

try:
    with open(sys.argv[1], 'r') as f:
        remote_data = json.load(f)
except:
    sys.exit(0)

try:
    with open(sys.argv[2], 'r') as f:
        local_data = json.load(f)
except:
    sys.exit(0)

platform = local_data.get('platform', 'linux')

stale = []

for remote_cat, remote_items in remote_data.items():
    if remote_cat in ['linux', 'win'] and remote_cat != platform:
        continue
    
    local_cat = 'scripts' if remote_cat == platform else remote_cat
    
    if not isinstance(remote_items, dict):
        continue

    local_items = local_data.get(local_cat, {})

    for key, remote_ver in remote_items.items():
        local_ver = local_items.get(key, 0)
        if remote_ver > local_ver:
            stale.append(f\"{local_cat} {key} {remote_cat}\")

print('\n'.join(stale))
" "$REMOTE_JSON_PATH" "$LOCAL_JSON_PATH")

if [ -z "$STALE_SCRIPTS" ]; then
    echo "All scripts are up to date."
    rm -f "$REMOTE_JSON_PATH"
    exit 0
fi

echo "Updates found! Pulling latest versions..."

while read -r local_category item remote_category; do
    if [ -z "$local_category" ]; then continue; fi
    
    echo "-> Updating $local_category: $item"
    
    SUCCESS=0
    if [ "$local_category" = "scripts" ]; then
        DOWNLOAD_URL=\"${REPO_BASE}/src/scripts/${remote_category}/${item}.sh\"
        curl -sSL "$DOWNLOAD_URL" -o "./${item}" && chmod +x "./${item}" && SUCCESS=1 || true
        
    elif [ "$local_category" = "py" ]; then
        DOWNLOAD_URL=\"${REPO_BASE}/src/py/${item}.py\"
        mkdir -p .csuite/test
        curl -sSL "$DOWNLOAD_URL" -o "./.csuite/test/${item}.py" && SUCCESS=1 || true
        
    elif [ "$local_category" = "template" ]; then
        ext=\"\"
        if [ \"$item\" = \"c\" ] || [ \"$item\" = \"cpp\" ] || [ \"$item\" = \"java\" ]; then
            ext=\".$item\"
        elif [ \"$item\" = \"test\" ]; then
            ext=\".json\"
        fi
        
        DOWNLOAD_URL=\"${REPO_BASE}/src/template/${item}${ext}\"
        mkdir -p .csuite/template
        curl -sSL "$DOWNLOAD_URL" -o "./.csuite/template/${item}${ext}" && SUCCESS=1 || true
    fi
    
    if [ $SUCCESS -eq 1 ]; then
        # Update the local json to the newly pulled version
        python3 -c "
import json
import sys

with open(sys.argv[1], 'r') as f:
    local_data = json.load(f)
with open(sys.argv[2], 'r') as f:
    remote_data = json.load(f)

local_cat = sys.argv[3]
item = sys.argv[4]
remote_cat = sys.argv[5]

if local_cat not in local_data:
    local_data[local_cat] = {}

local_data[local_cat][item] = remote_data.get(remote_cat, {}).get(item, 0)

with open(sys.argv[1], 'w') as f:
    json.dump(local_data, f, indent=4)
" "$LOCAL_JSON_PATH" "$REMOTE_JSON_PATH" "$local_category" "$item" "$remote_category"

        echo "Successfully updated $item!"
    else
        echo "Failed to properly download $item."
    fi
done <<< "$STALE_SCRIPTS"

rm -f "$REMOTE_JSON_PATH"
echo "Update process finished!"