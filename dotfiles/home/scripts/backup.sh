#!/usr/bin/env bash

# TODO: Run /home/mesa/.dotfiles/backup.py

set -e

notify-send "Backup cron job" "Running backup script"

cd ~/

BACKUP_PATH="/media/${USER}/backup"
OUTPUT_FILE="dev_backup-$(date +%Y-%m-%d-%I-%M-%p).tar.gz"
MAX_TAR_BACKUPS=5

# If `TARGET_DIR` does not exists default to $HOME
if [[ ! -d "${BACKUP_PATH}" ]]; then
    echo "ERROR: '${BACKUP_PATH}' does not exists!"
    exit 1
fi

rsync -avh  "${HOME}/patchbay.qpwgraph"    "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.bash_history"        "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.bashrc"              "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.gitconfig"           "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.git-credentials"     "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.zsh_history"         "${BACKUP_PATH}/"
rsync -avh  "${HOME}/.gnupg"               "${BACKUP_PATH}/"

# Before uncommenting this line
#   make this script run without sudo prompt
# sudo rsync -avh "/etc/ssmtp"              "${BACKUP_PATH}/"
#

tar --exclude="target" --exclude="node_modules" \
    -vzpcf "${BACKUP_PATH}/${OUTPUT_FILE}" dev

# BEGIN ----- remove old tar files
BACKUPS_COUNT="$(ls ${BACKUP_PATH}/dev_backup-*.tar.gz | wc -l)"
DIFF=$((BACKUPS_COUNT-MAX_TAR_BACKUPS))
TAR_FILES_TO_REMOVE="$(ls -t ${BACKUP_PATH}/dev_backup-*.tar.gz | tail -n ${DIFF})"

if [[ "${DIFF}" -gt 0 ]]; then
    rm ${TAR_FILES_TO_REMOVE}
fi
# END ----- remove old tar files
