# TP3: Montage NFS  

Il s'agit ici de la réalisation d'un tp d'administration système.

## Configuration : set_nfs.sh

Ce script sert à configurer les paramètres nfs d'une machine.

### Prérequis

Avant d'executer le script il faut créer les fichiers **machines** et **param** contenant les éléments suivant :

```
$cat machines

192.168.56.101 serveur
192.168.56.102 client
192.168.56.103 esclave

```
Le fichier machines comprends le nom des machines et leur adresse IP associée.

```
$cat param

MACHINE_LISTE=machines
IF=enp0s3
DOMAINE_IP="ubo.local"

SERVEUR_NFS=serveur
EXPORT_HOME=/export/home
EXPORT_HOME_OPT=rw,no_root_squash
MOUNT_HOME=/home/serveur
MOUNT_HOME_OPT=hard,rw

EXPORT_APP=/export/opt
EXPORT_APP_OPT=ro
MOUNT_APP=/opt
MOUNT_APP_OPT=soft,ro


```
Le fichier param contient le chemin du fichier précédent, l'interface réseau à configurer et le nom de domaine.
Il contient également tout les paramètres nécéssaires à la mise en place des client/serveur NFS.

Il faut également une machine client et une machine serveur, mis en place grâce aux script du TP précédent.

### Utilisation

Le script doit être utiliser avec un utilisateur ayant les droit nécéssaires pour modifier les fichiers de configuration réseau de la machine.

**Serveur :**
```
[root@serveur ase20]# ./set_nfs.sh
identification: serveur
nfs-serveur : active
0
0
0
0
0
0
0
0
0
0
0
0
/etc/exports =>
/export/opt serveur(ro)
/export/home serveur(rw,no_root_squash)
/export/opt client(ro)
/export/home client(rw,no_root_squash)
/export/opt esclave(ro)

```

Le script va identifier qu'il s'agit bien du serveur, activer nfs-server.service, arrêter le firewalld.
Puis il va modifier le fichier /etc/exports et ajouter les machines reseigner dans le fichier $MACHINE_LISTE.

Il va ensuite créer les répertoires à exporter.
Si tout se passe bien le script affiche 0 partout.

**Client :**
```
identification: client
0
0
0
0
/etc/fstab =>
serveur:/export/home /home/serveur nfs hard,rw 0 0
serveur:/export/opt /opt nfs soft,ro 0 0
maintenant faire =>
mount -a
cd /home/serveur

```

Le script va identifier qu'il s'agit bien du client.
Puis il va modifier le fichier /etc/fstab.
Et enfin il créer les répertoires de montage et affiche les commandes à faire pour accéder au dossier.
Si tout se passe bien le script affiche 0 partout.

## Vérification : verify_nfs.sh

Ce script sert à vérifier la bonne execution du script précédent.

### Prérequis

Pour pouvoir faire les vérification il faut avoir lancer le script set_nfs.sh sur la machine.

**Serveur :**

```
[root@serveur ase20]# ./set_nfs.sh
identification: serveur
nfs-serveur : active
0
0
0
0
0
0
0
0
0
0
0
0
/etc/exports =>
/export/opt serveur(ro)
/export/home serveur(rw,no_root_squash)
/export/opt client(ro)
/export/home client(rw,no_root_squash)
/export/opt esclave(ro)
```

**Client :**

```
identification: client
0
0
0
0
/etc/fstab =>
serveur:/export/home /home/serveur nfs hard,rw 0 0
serveur:/export/opt /opt nfs soft,ro 0 0
maintenant faire =>
mount -a
cd /home/serveur
```



### Utilisation

**Serveur :**

Le script va d'abord vérifier si le service nfs-server est bien actif et que le firewall est bien arrêté.
Ensuite il va vérifier que toutes les machine sont bien dans /etc/exports.
Et pour finir il va vérifier que les répertoires à exporter sont bien créer.

```
[root@serveur ase20]# ./verify_nfs.sh
Vérification: serveur

- Vérification services
--- nfs-server.service --  actif
--- firewalld.service --  stop

- Vérification /etc/exports
--- ligne: /export/opt serveur(ro) --  trouvé
--- ligne: /export/home serveur(rw,no_root_squash) --  trouvé
--- ligne: /export/opt client(ro) --  trouvé
--- ligne: /export/home client(rw,no_root_squash) --  trouvé
--- ligne: /export/opt esclave(ro) --  trouvé
--- ligne: /export/home esclave(rw,no_root_squash) --  trouvé

- Vérificaton des répertoires d'export
--- répertoire: /export/opt --  trouvé
--- répertoire: /export/home --  trouvé

```

**Client :**

Le script va d'abord effectuer un ping vers le serveur.
Ensuite il va vérifier que le ficher /etc/fstab est bien configuré.
Pour finir il va vérifier que les répertories de montage on bien été créer.

```
[root@client ase20]# ./verify_nfs.sh
Vérification: client

- Ping vers le serveur
--- Ping vers serveur  réussi

- Vérificaton /etc/fstab
--- ligne: serveur:/export/home /home/serveur nfs hard,rw 0 0 --  trouvé
--- ligne: serveur:/export/opt /opt nfs soft,ro 0 0 --  trouvé

- Vérificaton des répertoires de montages
--- répertoire: /home/serveur --  trouvé
--- répertoire: /opt --  trouvé

```

## Auteurs

* **Yvonnou Théo** - *Réalisation des scripts* - Master I TIIL-A
