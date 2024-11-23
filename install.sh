#!/bin/bash

# Verifică dacă variabila de mediu PORT este setată, altfel folosește portul implicit
PORT=${PORT:-3000}  # Dacă PORT nu este setat, se folosește 3000

echo "Portul pentru aplicație este: $PORT"

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
  echo "Repository-ul este deja clonat. Actualizare..."
  cd "$TARGET_DIR" || exit
  git pull
  cd ..
fi

# Navighează în directorul aplicației
cd "$TARGET_DIR" || exit

# Instalează dependențele
npm install

# Creează fișierul .env cu portul specificat
cat <<EOT > .env
# Variabile de mediu
PORT=$PORT
EOT

echo "Fișierul .env a fost creat cu următorul conținut:"
cat .env

# Rulează aplicația
echo "Pornire aplicație..."
node index
