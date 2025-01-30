#!/bin/bash

# Verifică dacă scriptul este într-un terminal interactiv
if [[ ! -t 0 ]]; then
  echo "Scriptul trebuie să fie rulat într-un terminal interactiv."
  exit 1
fi

# Solicită utilizatorului să introducă cheia de criptare
echo "Configurare cheia de criptare pentru aplicație:"
read -p "Introduceți cheia de criptare: " ENCRYPTION_KEY

# Folosește valoarea introdusă de utilizator
ENCRYPTION_KEY=${ENCRYPTION_KEY}

echo "Cheia de criptare aleasă este: $ENCRYPTION_KEY"

# Actualizează sistemul
sudo apt update && sudo apt upgrade -y

# Instalează Node.js și npm (dacă nu sunt deja instalate)
if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Setează URL-ul repository-ului și directorul țintă
REPO_URL="https://github.com/AMTCentru/simulatorUserNameDomain/archive/refs/heads/main.tar.gz" # Link modificat pentru arhiva .tar.gz
TARGET_DIR="simulatorUserNameDomain"

# Verifică dacă directorul țintă există deja și îl șterge
if [ -d "$TARGET_DIR" ]; then
  echo "Directorul $TARGET_DIR există deja. Îl voi șterge și voi descărca din nou repository-ul..."
  rm -rf "$TARGET_DIR"
fi

# Creează directorul țintă
mkdir -p "$TARGET_DIR"

# Descarcă repository-ul ca .tar.gz direct în directorul țintă folosind wget
echo "Se descarcă repository-ul..."
wget -O "$TARGET_DIR/repo.tar.gz" "$REPO_URL"

# Verifică dacă descărcarea a fost reușită
if [ ! -f "$TARGET_DIR/repo.tar.gz" ]; then
  echo "Eroare: Descărcarea a eșuat. Verifică URL-ul și conexiunea la internet."
  exit 1
fi

# Navighează în directorul aplicației
cd "$TARGET_DIR" || exit

# Extrage arhiva în același director
tar -xvzf repo.tar.gz

# **NU** șterge fișierul arhivă
echo "Arhiva repo.tar.gz a fost păstrată."

# Mută fișierele din folderul extras în `TARGET_DIR`
mv simulatorUserNameDomain-main/* .
rm -rf simulatorUserNameDomain-main

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
URL="http://localhost:8080/admin"
xdg-open "$URL" &  # Deschide URL-ul în browser

# Rulează aplicația Node.js
node index &

# Ieși din terminal
exit
