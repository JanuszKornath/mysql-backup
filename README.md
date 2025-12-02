# MySQL Backup Script (Bash)

Ein robustes Bash-Skript zum automatisierten Sichern aller MySQL-Datenbanken.  
Das Skript erstellt ein komprimiertes Backup, überträgt es per SCP auf einen Remote-Server, führt Logging durch, verschickt Fehler-E-Mails und bereinigt alte Backups lokal und remote.

## Features

- Vollständiges MySQL-Datenbankbackup (`mysqldump --all-databases`)
- Kompression via `gzip`
- Sichere Übertragung per `scp`
- E-Mail-Benachrichtigung bei Fehlern
- Automatisches Löschen alter Backups (lokal & remote)
- Logging in `/var/log/mysql_backup.log`
- Für Cronjobs geeignet
- Installation

## Benutzung
  Skript speichern, z. B. unter:
  ```
  /usr/local/bin/mysql_backup.sh
  ```
  Ausführbar machen:
  ```
  chmod +x /usr/local/bin/mysql_backup.sh
  ```
  Konfiguration im Skript anpassen (Benutzer, Passwörter, Pfade).
