#!/bin/bash
. param
. functions

# On récupére le nom de machine
hostname=$(hostname)

# Vérification de la machine serveur
if [ $hostname = "serveur" ]
then
  echo "Vérification: serveur"
  echo ""
  # On vérifie si le service nfs-serveur est actif
  echo "- Vérification services"
  isActive=$(systemctl is-active nfs-server.service)

  # Si le service est inconnu
  if [ $isActive = "active" ]
  then
    echo -e "--- nfs-server.service -- \033[32m actif \033[0m"
  else
    echo -e "--- nfs-server.service -- \033[31m stop \033[0m"
  fi

  # On vérifie si le firewall est actif
  isActive=$(systemctl is-active firewalld.service)
  if [ $isActive = "active" ]
  then
    echo -e "--- nfs-server.service -- \033[31m actif \033[0m"
  else
    echo -e "--- firewalld.service -- \033[32m stop \033[0m"
  fi

  echo ""
  echo "- Vérification /etc/exports"
  # Tant qu'il y a des machines dans le fichier des machines
  while IFS= read -r line
  do
      # Je récupère le nom
      nomActuel=$(echo $line | cut -d ' ' -f 2)
      # Chemin du fichier à vérifier
      cible="/etc/exports"
      # Création des lignes à vérifier
      partageOpt="$EXPORT_APP $nomActuel($EXPORT_APP_OPT)"
      partageHome="$EXPORT_HOME $nomActuel($EXPORT_HOME_OPT)"
      # Vérification des lignes
      if  grep -q "$partageOpt" $cible
      then
        echo -e "--- ligne: $partageOpt -- \033[32m trouvé \033[0m"
      else
        echo -e "--- ligne: $partageOpt -- \033[31m introuvable \033[0m"
      fi
      if  grep -q "$partageHome" $cible
      then
        echo -e "--- ligne: $partageHome -- \033[32m trouvé \033[0m"
      else
        echo -e "--- ligne: $partageHome -- \033[31m introuvable \033[0m"
      fi
  done < "$MACHINE_LISTE"

  # Vérification des répertoires d'export
  echo ""
  echo "- Vérificaton des répertoires d'export"
  if [ ! -d "$EXPORT_APP" ]
  then
    echo -e "--- répertoire: $EXPORT_APP -- \033[31m introuvable \033[0m"
  else
    echo -e "--- répertoire: $EXPORT_APP -- \033[32m trouvé \033[0m"
  fi
  if [ ! -d "$EXPORT_HOME" ]
  then
    echo -e "--- répertoire: $EXPORT_HOME -- \033[31m introuvable \033[0m"
  else
    echo -e "--- répertoire: $EXPORT_HOME -- \033[32m trouvé \033[0m"
  fi
fi

# Vérification de la machine client
if [ $hostname = "client" ]
then
  echo "Vérification: client"
  echo ""
  # Ping vers le serveur
  echo "- Ping vers le serveur"
  ping -c1  $SERVEUR_NFS 1>/dev/null
  if [ "$?" = 0 ]
  then
    echo -e "--- Ping vers $SERVEUR_NFS \033[32m réussi \033[0m"
  else
    echo -e "--- Ping vers $SERVEUR_NFS \033[31m échoué \033[0m"
  fi

  # Ligne à vérifier dans /etc/fstab
  ligne1="$SERVEUR_NFS:$EXPORT_HOME $MOUNT_HOME nfs $MOUNT_HOME_OPT 0 0"
  ligne2="$SERVEUR_NFS:$EXPORT_APP $MOUNT_APP nfs $MOUNT_APP_OPT 0 0"
  # Fichier cible
  cible="/etc/fstab"

  echo ""
  echo "- Vérificaton $cible"
  # Vérification des lignes
  if  grep -q "$ligne1" $cible
  then
    echo -e "--- ligne: $ligne1 -- \033[32m trouvé \033[0m"
  else
    echo -e "--- ligne: $ligne1 -- \033[31m introuvable \033[0m"
  fi
  if  grep -q "$ligne2" $cible
  then
    echo -e "--- ligne: $ligne2 -- \033[32m trouvé \033[0m"
  else
    echo -e "--- ligne: $ligne2 -- \033[31m introuvable \033[0m"
  fi

  # Vérification des répertoires de montage
  echo ""
  echo "- Vérificaton des répertoires de montages"
  if [ ! -d "$MOUNT_HOME" ]
  then
    echo -e "--- répertoire: $MOUNT_HOME -- \033[31m introuvable \033[0m"
  else
    echo -e "--- répertoire: $MOUNT_HOME -- \033[32m trouvé \033[0m"
  fi
  if [ ! -d "$MOUNT_APP" ]
  then
    echo -e "--- répertoire: $MOUNT_APP -- \033[31m introuvable \033[0m"
  else
    echo -e "--- répertoire: $MOUNT_APP -- \033[32m trouvé \033[0m"
  fi
fi
