# Serveur SFTP Docker léger

Image Docker légère basée sur Alpine Linux pour exposer un volume via SFTP.

## Utilisation rapide

```bash
# Construire l'image
docker-compose build

# Démarrer le serveur
docker-compose up -d

# Se connecter depuis un autre container
sftp -P 2222 sftpuser@localhost
# Mot de passe par défaut: sftpuser
```

## Configuration

### Variables d'environnement

- `SFTP_USER`: Nom d'utilisateur (défaut: `sftpuser`)
- `SFTP_PASSWORD`: Mot de passe (défaut: `sftpuser`)

### Volume

Le dossier `./data` est monté dans `/data` du container. Les fichiers y sont accessibles via SFTP.

### Connexion depuis d'autres containers

Si les containers sont sur le même réseau Docker (`sftp_network`), utilisez:

```bash
sftp -P 22 sftpuser@sftp
```

Depuis l'hôte ou un container externe:

```bash
sftp -P 2222 sftpuser@localhost
```

### Exemple avec un autre service

Voir `docker-compose.example.yml` pour un exemple complet avec un service client.

Pour tester depuis un autre container:

```bash
# Dans le docker-compose, ajoutez votre service au réseau sftp_network
# Puis depuis votre container:
sftp -P 22 sftpuser@sftp
```

## Sécurité

⚠️ **Pour la production**, changez le mot de passe par défaut via les variables d'environnement ou utilisez des clés SSH.

