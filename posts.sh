#!/bin/bash

# Pfade
OLD_POSTS_DIR="./temp_backup/src/content/blog"
NEW_POSTS_DIR="./src/data/blog"
BACKUP_BRANCH="backup-vor-theme-wechsel"
TEMP_DIR="temp_backup"

# 1. Sicherstellen, dass die Zielverzeichnisse existieren
echo "Stelle sicher, dass die Zielverzeichnisse existieren..."
mkdir -p "$NEW_POSTS_DIR"

# 2. Den alten Branch in ein temporäres Verzeichnis klonen
echo "Klone den alten Branch in ein temporäres Verzeichnis, um die Posts zu extrahieren..."
git clone --depth 1 --branch "$BACKUP_BRANCH" https://github.com/inventory69/voidtales-blog.git "$TEMP_DIR"

# 3. Überprüfen, ob das Klonen erfolgreich war
if [ ! -d "$OLD_POSTS_DIR" ]; then
  echo "Fehler: Das Verzeichnis der alten Blog-Posts wurde nicht gefunden. Bitte überprüfe den Pfad: $OLD_POSTS_DIR"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# 4. Iteriere durch die alten Blog-Posts
echo "Beginne mit der Übertragung der Blog-Posts..."
for file in "$OLD_POSTS_DIR"/*.md; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    echo "Verarbeite: $filename"
    
    # Temporäre Datei für die neuen Inhalte erstellen
    temp_file=$(mktemp)
    
    # Extrahiere Titel und Datum
    # awk-Befehl ist empfindlich. Dieser passt zu den meisten Fällen.
    title=$(awk '/^title: / {
      sub(/^title: /, "");
      sub(/"$/, "");
      sub(/^"/, "");
      print
    }' "$file")
    
    pubDateRaw=$(awk '/^date: / {print $2}' "$file" | tr -d '"')

    # Formatieren des Datums
    # Wenn ein Datum gefunden wird, formatieren wir es neu
    if [ -z "$pubDateRaw" ]; then
      pubDate=$(date "+%Y-%m-%d %H:%M:%S") # Verwende das aktuelle Datum als Fallback
    else
      pubDate=$(date -d "$pubDateRaw" "+%Y-%m-%d %H:%M:%S")
    fi

    # Erstellen der neuen Frontmatter
    echo "---" > "$temp_file"
    echo "title: \"$title\"" >> "$temp_file"
    echo "pubDatetime: $pubDate" >> "$temp_file" # WICHTIG: KEINE ANFÜHRUNGSZEICHEN MEHR
    echo "description: \"\"" >> "$temp_file"
    echo "---" >> "$temp_file"
    
    # Alten Inhalt nach der Frontmatter kopieren
    awk '/^---/ { p=!p } p' "$file" >> "$temp_file"
    
    # Neue Datei anlegen
    mv "$temp_file" "$NEW_POSTS_DIR/$filename"
  fi
done

# 5. Aufräumen des temporären Verzeichnisses
echo "Aufräumen des temporären Backups..."
rm -rf "$TEMP_DIR"

echo "Die Blog-Posts wurden erfolgreich in das neue Theme übertragen. Bitte überprüfe die Dateien in src/data/blog und füge eine Beschreibung für jeden Post hinzu."