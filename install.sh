#!/bin/bash

# Verifică dacă scriptul este într-un terminal interactiv
if [[ ! -t 0 ]]; then
  echo "Scriptul trebuie să fie rulat într-un terminal interactiv."
  exit 1
fi


# Actualizează sistemul
sudo apt update && sudo apt upgrade -y

# Verifică dacă Node.js și npm sunt instalate
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "Node.js și npm nu sunt instalate. Se instalează versiunea 20..."
  
  # Descărcare și instalare Node.js 20 folosind wget
  wget -O nodesource_setup.sh https://deb.nodesource.com/setup_20.x
  sudo bash nodesource_setup.sh
  sudo apt install -y nodejs npm  # Instalează și npm

  # Șterge scriptul după instalare
  rm -f nodesource_setup.sh
else
  echo "Node.js și npm sunt deja instalate."
fi

# Verifică versiunile instalate
echo "Versiunea instalată de Node.js:"
node -v
echo "Versiunea instalată de npm:"
npm -v

# Solicită utilizatorului să introducă cheia de criptare
echo "Configurare cheia de criptare pentru aplicație:"
read -p "Introduceți cheia de criptare: " ENCRYPTION_KEY

# Folosește valoarea introdusă de utilizator
ENCRYPTION_KEY=${ENCRYPTION_KEY}

echo "Cheia de criptare aleasă este: $ENCRYPTION_KEY"


# Setează URL-ul repository-ului și directorul țintă
REPO_URL="https://github.com/AMTCentru/simulatorUserNameDomain/archive/refs/heads/main.tar.gz" # Înlocuiește cu linkul corect
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

# Extrage arhiva în același director și apoi șterge fișierul arhivă
tar -xvzf repo.tar.gz
rm repo.tar.gz

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
