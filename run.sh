#!/bin/bash
npm init -y || { echo "'npm init -y ' a eșuat!"; exit 1; }
npm update || { echo "'npm update  ' a eșuat!"; exit 1; }
node index

echo "Procesul s-a finalizat cu succes!"
