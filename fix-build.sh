#!/bin/bash

echo "Starte die Korrektur der OG-Image-Generierung..."

# Pfade zu den betroffenen Dateien
OG_SITE_FILE="src/pages/og.png.ts"
OG_POST_FILE="src/pages/posts/[...slug]/index.png.ts"

# Prüfe, ob die Dateien existieren
if [ ! -f "$OG_SITE_FILE" ] || [ ! -f "$OG_POST_FILE" ]; then
    echo "Fehler: OG-Image-Dateien wurden nicht gefunden. Das Skript kann nicht ausgeführt werden."
    exit 1
fi

# 1. Korrigiere die Datei für das OG-Bild der Hauptseite
echo "Passe die Datei: $OG_SITE_FILE an..."
# Ersetze die fehlerhafte Zeile
sed -i 's/new Response(await generateOgImageForSite(), {/new Response(await generateOgImageForSite(), {/' "$OG_SITE_FILE"

# 2. Korrigiere die Datei für die OG-Bilder der Posts
echo "Passe die Datei: $OG_POST_FILE an..."
# Der Fehler liegt hier in der Art und Weise, wie die Daten übergeben werden.
# Wir müssen den Buffer in einen ArrayBuffer umwandeln.
sed -i 's/new Response(await generateOgImageForPost(props as CollectionEntry<"blog">), {/new Response(Buffer.from(await generateOgImageForPost(props as CollectionEntry<"blog">)).buffer, {/' "$OG_POST_FILE"

echo "Die Korrekturen wurden angewendet."
echo "Bitte führe 'git add .', 'git commit' und 'git push origin main' aus."