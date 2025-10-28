#!/bin/bash
set -euo pipefail

REPO_DIR="/home/kaf/docker/n8n-stack"
LOG_FILE="/home/kaf/docker/n8n-stack/deploy.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "===== Starting deployment ====="
cd "$REPO_DIR"

log "Checking for updates..."
git fetch origin main 2>&1 | tee -a "$LOG_FILE"
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date"
    exit 0
fi

CHANGED_FILES=$(git diff --name-only "$LOCAL" "$REMOTE")
WATCHED_FILES=("docker-compose.yml" "secrets/production.env.enc" "scripts/deploy.sh")
NEEDS_DEPLOY=false

for file in "${WATCHED_FILES[@]}"; do
    if grep -Fxq "$file" <<<"$CHANGED_FILES"; then
        NEEDS_DEPLOY=true
        break
    fi
done

if [ "$NEEDS_DEPLOY" = false ]; then
    WATCH_LIST=$(printf "%s, " "${WATCHED_FILES[@]}")
    WATCH_LIST=${WATCH_LIST%, }
    log "No changes in watched files (${WATCH_LIST}). Fast-forwarding without deployment."
    git pull origin main 2>&1 | tee -a "$LOG_FILE"
    log "===== Sync complete, deployment skipped ====="
    exit 0
fi

log "Relevant changes detected: $(echo "$CHANGED_FILES" | tr '\n' ' ')"
log "Pulling latest changes..."
git pull origin main 2>&1 | tee -a "$LOG_FILE"

log "Decrypting secrets..."
sops -d secrets/production.env.enc > .env

log "Deploying containers..."
docker compose pull 2>&1 | tee -a "$LOG_FILE"
docker compose up -d --remove-orphans 2>&1 | tee -a "$LOG_FILE"

log "Checking status..."
docker compose ps 2>&1 | tee -a "$LOG_FILE"

log "===== Deployment complete ====="
