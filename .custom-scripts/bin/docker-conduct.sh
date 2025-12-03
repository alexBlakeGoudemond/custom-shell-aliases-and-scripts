#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# docker-conduct: Use docker compose to bring containers and images up or down
# Usage: docker-conduct -h
# Usage: docker-conduct -p <projectName> -f <composeFile>
# Usage: docker-conduct -c -p <projectName>
# For fun, we named this little tool as `Dockerissimo`
#
# Bash insights:
# - has custom defined functions which are invoked without parentheses, for example: `usage`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.0"

echo ""
echo "🐋  Dockerissimo $ALIAS_VERSION — Docker Compose Conductor 🎶"
echo "───────────────────────────────────────────────────────────────"


# Default values
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="dockerissimo-default-container-group"
COMMAND="up"

usage() {
  echo "Dockerissimo - Conduct your Docker Compose projects with flair!"
  echo ""
  echo "Usage: docker conduct [options]"
  echo ""
  echo "Options:"
  echo "  -p <projectName>     Specify the Docker Compose project name"
  echo "  -f <composeFile>     Path to docker-compose file (relative to current dir)"
  echo "  -c                   Cease the playing (docker compose down)"
  echo "  -h                   Show this help message"
  echo ""
  echo "Default behavior: docker compose up -d"
  exit 1
}

project_exists() {
  local pname="$1"
  if [[ -z "$pname" ]]; then
    pname=$(basename "$(pwd)")
  fi

  # find all container-groups / compose project groups with the name; `-q` produces exit status of 0 or 1
  docker compose ls --format json | grep -q "\"Name\":\"$pname\""
}

# Parse options
while getopts ":p:f:ch" opt; do
  case $opt in
    p) PROJECT_NAME="$OPTARG" ;;
    f) COMPOSE_FILE="$OPTARG" ;;
    c) COMMAND="down" ;;
    h) usage ;;
    \?) echo "Invalid option -$OPTARG"; usage ;;
    :) echo "Option -$OPTARG requires an argument."; usage ;;
  esac
done

# Check if docker-compose file exists
if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "❌ Docker Compose file '$COMPOSE_FILE' not found!"
  exit 1
fi

# Build compose command
COMPOSE_CMD="docker compose -f $COMPOSE_FILE"
if [[ -n "$PROJECT_NAME" ]]; then
  COMPOSE_CMD="$COMPOSE_CMD -p $PROJECT_NAME"
fi

# Execute commands, also invoke the function project_exists
if [[ "$COMMAND" == "up" ]]; then
  if project_exists "$PROJECT_NAME"; then
    echo "⚠️ Project already exists! Will not start again."
  else
    echo "🎵 Dockerissimo is conducting: composing project..."
    $COMPOSE_CMD up -d --build
    echo "✅ Project is up and running!"
  fi
else
  # down command
  if project_exists "$PROJECT_NAME"; then
    echo "✋ Dockerissimo is ceasing the playing..."
    $COMPOSE_CMD down --rmi local
    echo "✅ Project stopped and removed!"
  else
    echo "🚦 project is not running, nothing to stop"
    $COMPOSE_CMD down --rmi local
    echo "✅ Project removed!"
  fi
fi

echo ""
echo "🐋  Dockerissimo finished 🎶"
echo "───────────────────────────────────────────────────────────────"