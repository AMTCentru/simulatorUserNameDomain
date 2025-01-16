#!/bin/bash

# Verifică dacă scriptul este într-un terminal interactiv
if [[ ! -t 0 ]]; then
  echo "Scriptul trebuie să fie rulat într-un terminal interactiv."
  exit 1
fi

# Solicită utilizatorului să introducă cheia de criptare
echo "Configurare cheia de criptare pentru aplicație:"
read -p "Introduceți cheia de criptare : " ENCRYPTION_KEY

# Setează valoarea implicită a ENCRYPTION_KEY dacă nu este introdusă nici o valoare
ENCRYPTION_KEY=${ENCRYPTION_KEY}  # Folosește valoarea introdusă de utilizator

echo "Cheia de criptare aleasă este: $ENCRYPTION_KEY"

# Actualizează sistemul
sudo apt update && sudo apt upgrade -y

# Instalează Node.js și npm (dacă nu sunt deja instalate)
if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Setează URL-ul repository-ului și directorul țintă
REPO_URL="https://github.com/AMTCentru/simulatorUserNameDomain.git" # Înlocuiește cu linkul tău
TARGET_DIR="simulatorUserNameDomain"

# Verifică dacă directorul țintă există deja și îl șterge
if [ -d "$TARGET_DIR" ]; then
  echo "Directorul $TARGET_DIR există deja. Îl voi șterge și voi clona din nou repository-ul..."
  rm -rf "$TARGET_DIR"
fi

# Clonează repository-ul tău de pe GitHub
git clone "$REPO_URL" "$TARGET_DIR"

# Navighează în directorul aplicației
cd "$TARGET_DIR" || exit

# Instalează dependențele
npm install

# Creează fișierul .env cu ENCRYPTION_KEY specificat
cat <<EOT > .env
# Variabile de mediu
ENCRYPTION_KEY=$ENCRYPTION_KEY
EOT

echo "Fișierul .env a fost creat cu următorul conținut:"
cat .env

# Rulează aplicația
echo "Pornire aplicație..."

# Deschide URL-ul în browserul implicit
# Poți înlocui `http://localhost:$PORT` cu orice URL de care ai nevoie
URL="http://localhost:8080/admin"
xdg-open "$URL" &  # Deschide URL-ul în browser

# Rulează aplicația Node.js
node index &

# Ieși din terminal
exit
