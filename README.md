# Serveur SFTP Docker léger

Image Docker légère basée sur Alpine Linux pour exposer un volume via SFTP avec support de plusieurs comptes utilisateurs.

## Utilisation rapide

# Construire l'image
docker-compose build

# Démarrer le serveur
docker-compose up -d

# Se connecter depuis un autre container
sftp -P 2222 client1@localhost
# Mot de passe: secret123## Configuration

### Variables d'environnement

#### Configuration multi-utilisateurs (recommandé)

Vous pouvez créer autant de comptes SFTP que nécessaire en utilisant des variables numérotées :

- `SFTP_USER_N`: Nom d'utilisateur pour le compte N (ex: `SFTP_USER_1`, `SFTP_USER_2`, etc.)
- `SFTP_PASSWORD_N`: Mot de passe pour le compte N (ex: `SFTP_PASSWORD_1`, `SFTP_PASSWORD_2`, etc.)
- `SFTP_DIR_N`: Dossier accessible pour le compte N dans `/data` (ex: `SFTP_DIR_1`, `SFTP_DIR_2`, etc.)

**Exemple :**
environment:
  - SFTP_USER_1=client1
  - SFTP_PASSWORD_1=secret123
  - SFTP_DIR_1=client1_files
  
  - SFTP_USER_2=client2
  - SFTP_PASSWORD_2=secret456
  - SFTP_DIR_2=client2_files**Notes :**
- Si `SFTP_DIR_N` n'est pas défini, le nom d'utilisateur est utilisé comme nom de dossier
- Si `SFTP_PASSWORD_N` n'est pas défini, le nom d'utilisateur est utilisé comme mot de passe
- Les numéros doivent être séquentiels (1, 2, 3, etc.) sans interruption

#### Configuration simple (rétrocompatibilité)

Pour un seul utilisateur, vous pouvez toujours utiliser les variables non numérotées :

- `SFTP_USER`: Nom d'utilisateur (défaut: `sftpuser`)
- `SFTP_PASSWORD`: Mot de passe (défaut: `sftpuser`)
- `SFTP_DIR`: Dossier accessible dans `/data` (défaut: nom d'utilisateur)

### Volume

Le dossier `./data` est monté dans `/data` du container. Chaque utilisateur a accès uniquement à son propre dossier dans `/data`.

### Connexion depuis d'autres containers

Si les containers sont sur le même réseau Docker (`sftp_network`), utilisez:

sftp -P 22 client1@sftp
sftp -P 22 client2@sftpDepuis l'hôte ou un container externe:

sftp -P 2222 client1@localhost
sftp -P 2222 client2@localhost### Exemple avec un autre service

Voir `docker-compose.example.yml` pour un exemple complet avec plusieurs utilisateurs et un service client.

Pour tester depuis un autre container:
sh
# Dans le docker-compose, ajoutez votre service au réseau sftp_network
# Puis depuis votre container:
sftp -P 22 client1@sftp
sftp -P 22 client2@sftp## Sécurité

⚠️ **Pour la production**, changez les mots de passe par défaut via les variables d'environnement ou utilisez des clés SSH.