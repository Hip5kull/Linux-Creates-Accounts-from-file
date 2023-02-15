#!/bin/bash

# Vérifie si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root." 
   exit 1
fi

# Récupère le nom du fichier texte contenant les informations sur les utilisateurs
echo "Entrez le nom du fichier texte contenant les informations sur les utilisateurs (format : prenom nom groupe): "
read filename

# Vérifie si le fichier texte existe
if [ ! -f $filename ]; then
    echo "Le fichier $filename n'existe pas."
    exit 1
fi

# Parcourt le fichier texte pour créer les utilisateurs
while read -r prenom nom groupe; do
    username=$(echo "$prenom$nom" | tr '[:upper:]' '[:lower:]' | cut -c1-8)
    password=$(openssl rand -base64 12 | tr -d "=+/")
    encrypted_password=$(echo "$password" | openssl passwd -1 -stdin)
    
    # Vérifie si le groupe existe, sinon le crée
    getent group $groupe > /dev/null
    if [ $? -ne 0 ]; then
        groupadd $groupe
    fi
    
    # Crée l'utilisateur et ajoute au groupe correspondant
    useradd -m -p $encrypted_password -s /bin/bash -g $groupe $username
    
    echo "L'utilisateur $username a été créé avec le mot de passe : $password" >> login_users.txt
done < "$filename"

exit 0
