#!/bin/bash

# === Konfiguration ===
MYSQL_USER="backup"
MYSQL_PASS="SICHERES_PASSWORT"

BACKUP_LOCAL_DIR="/tmp/mysql_backups"
REMOTE_USER="user"
REMOTE_HOST="host"
REMOTE_DIR="/hath/to/backup"

EMAIL_RECIPIENT="mail@tld.org"
MAX_BACKUP_DAYS=7
LOGFILE="/var/log/mysql_backup.log"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="mysql_backup_$TIMESTAMP.sql"
FILENAME_GZ="$FILENAME.gz"

# === Backup starten ===
echo "[$TIMESTAMP] Starte MySQL-Backup" | tee -a "$LOGFILE"
mkdir -p "$BACKUP_LOCAL_DIR"

# Backup erstellen
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" --all-databases --single-transaction --quick --lock-tables=false > "$BACKUP_LOCAL_DIR/$FILENAME"
if [ $? -ne 0 ]; then
    echo "❌ Backup fehlgeschlagen!" | tee -a "$LOGFILE"
    echo "MySQL-Backup fehlgeschlagen am $TIMESTAMP" | mail -s "MySQL-Backup fehlgeschlagen" "$EMAIL_RECIPIENT"
    exit 2
fi

# Backup komprimieren
gzip "$BACKUP_LOCAL_DIR/$FILENAME"

# Übertragung per scp
scp "$BACKUP_LOCAL_DIR/$FILENAME_GZ" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
if [ $? -ne 0 ]; then
    echo "❌ SCP-Übertragung fehlgeschlagen!" | tee -a "$LOGFILE"
    echo "MySQL-Backup-Übertragung fehlgeschlagen am $TIMESTAMP" | mail -s "MySQL-Backup: SCP fehlgeschlagen" "$EMAIL_RECIPIENT"
    exit 3
fi

# Alte lokale Backups löschen
find "$BACKUP_LOCAL_DIR" -type f -name "mysql_backup_*.sql.gz" -mtime +$MAX_BACKUP_DAYS -exec rm {} \;

# Alte Backups auf Remote-Server löschen
ssh "$REMOTE_USER@$REMOTE_HOST" "find '$REMOTE_DIR' -type f -name 'mysql_backup_*.sql.gz' -mtime +$MAX_BACKUP_DAYS -delete"

# Lokales Archiv entfernen (nach erfolgreichem Transfer)
rm -f "$BACKUP_LOCAL_DIR/$FILENAME_GZ"

echo "✅ Backup abgeschlossen: $FILENAME_GZ" | tee -a "$LOGFILE"
