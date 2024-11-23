#!/bin/bash

# Actualizează sistemul
sudo apt update && sudo apt upgrade -y

# Instalează Node.js și npm (dacă nu sunt deja instalate)
if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Clonează repository-ul tău de pe GitHub
REPO_URL="https://github.com/AMTCentru/simulatorUserNameDomain.git" # Înlocuiește cu linkul tău
TARGET_DIR="aplicatie"

if [ ! -d "$TARGET_DIR" ]; then
  git clone "$REPO_URL" "$TARGET_DIR"
else
  echo "Repository-ul este deja clonat."
fi

# Navighează în directorul aplicației
cd "$TARGET_DIR" || exit

# Instalează dependențele
npm install

# Rulează aplicația
npm start
