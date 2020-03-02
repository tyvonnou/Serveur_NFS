#!/bin/bash
. param
. functions
# On récupére le nom de machine
hostname=$(hostname)

# Partie exécuté si la machine est serveur
if [ $hostname = "serveur" ]
then
    echo "identification: serveur"

    # On vérifie si le service nfs-serveur est actif
    isActive=$(systemctl is-active nfs-server.service)

    # Si le service est inconnue
    if [ $isActive = "unknown" ]
    then
        # On le fait connaître
        systemctl enable nfs-server.service
        # On active le service
        systemctl start nfs-server.service
    fi

    # Si le service est juste incatif
    if [ $isActive = "inactive" ]
    then
        # On active le service
        systemctl start nfs-server.service
    fi

    # On affiche l'état final du service
    finalState=$(systemctl is-active nfs-server.service)
    echo "nfs-serveur : $finalState"

    # On stop le firewall
    systemctl stop firewalld.service

    # Tant qu'il y a des machines dans le fichier des machines
    while IFS= read -r line
    do
        # Je récupère le nom
        nomActuel=$(echo $line | cut -d ' ' -f 2)
        # Chemin du fichier à modifier
        cible="/etc/exports"
        # Création des lignes à ajouter
        partageOpt="$EXPORT_APP $nomActuel($EXPORT_APP_OPT)"
        partageHome="$EXPORT_HOME $nomActuel($EXPORT_HOME_OPT)"
        # Suppression des lignes si elles exites déjà afin d'éviter les doublons
        remove_line $cible "$EXPORT_APP $nomActuel"
        remove_line $cible "$EXPORT_HOME $nomActuel"
        # Puis ajout des lignes
        add_line $cible "$partageOpt"
        add_line $cible "$partageHome"
    done < "$MACHINE_LISTE"

    echo "$cible =>"
    cat $cible

    # Création des répertoire
    if [ ! -d "$EXPORT_APP" ]
    then
      mkdir -p $EXPORT_APP
    fi

    if [ ! -d "$EXPORT_HOME" ]
    then
      mkdir -p $EXPORT_HOME
    fi

    # Mise à jour de la table courante de systèmes de fichiers partagés par NFS
    exportfs -a
    exportfs -f
fi

# Partie exécuté si la machine est client
if [ $hostname = "client" ]
then
    echo "identification: client"

    # Préparation des lignes à inséré dans /etc/fstab
    ligne1="$SERVEUR_NFS:$EXPORT_HOME  $MOUNT_HOME  nfs    $MOUNT_HOME_OPT    0 0"
    ligne2="$SERVEUR_NFS:$EXPORT_APP   $MOUNT_APP           nfs    $MOUNT_APP_OPT    0 0"

    # Suppression des lignes pour éviter les doublons
    cible="/etc/fstab"
    remove_line $cible $SERVEUR_NFS:$EXPORT_HOME
    remove_line $cible $SERVEUR_NFS:$EXPORT_APP

    # Et puis ajout des lignes
    add_line $cible "$ligne1"
    add_line $cible "$ligne2"

    echo "$cible =>"
    cat $cible

    # Création du répertoire de montage
    if [ ! -d "$MOUNT_HOME" ]
    then
      mkdir -p $MOUNT_HOME
    fi

    if [ ! -d "$MOUNT_APP" ]
    then
      mkdir -p $MOUNT_APP
    fi

    echo "maintenant faire =>"
    echo "mount -a"
    echo "cd $MOUNT_HOME"
fi
