#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-config-environment-description: Quickly identify which git config file is being used
# Usage: git whoami
#
# For fun, we named this little tool as `WhoAmI`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.1"

echo ""
echo "🪞 ⁉️  WhoAmI $ALIAS_VERSION — Git Environment Identifier"
echo "───────────────────────────────────────────────────────────────"
echo ""

userEmail=$(git config user.email)
userName=$(git config user.name)
remoteOriginUrl=$(git config remote.origin.url)
remoteOriginPath=${remoteOriginUrl#*:}      # remove everything before :
remoteOriginAuthor=${remoteOriginPath%/*}   # remove final /repo-name
printf "%-23s%s\n" "User Name:" "$userName"
printf "%-23s%s\n"  "User Email:" "$userEmail"
printf "%-23s%s\n"  "Remote Origin Author:" "$remoteOriginAuthor"

echo ""
echo "🪞 ⁉️  WhoAmI finished"
echo "───────────────────────────────────────────────────────────────"
