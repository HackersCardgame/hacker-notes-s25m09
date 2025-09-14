#!/bin/bash

#TODO: geht das auch wenn die Datei PNG oder Png heisst ???

SRC="/home/marc/"
DST="/home/marc/ocr"

# Rekursiv alle Bilder finden und verarbeiten
find "$SRC" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r FILE; do

  # Pfad relativ zum Quellordner
  REL=$(realpath --relative-to="$SRC" "$FILE")

  # Zielordner erstellen
  mkdir -p "$DST/$(dirname "$REL")"

  # OCR durchfuhren
  tesseract "$FILE" "$DST/${REL}.txt"

  echo "OCR done: $REL"
done

