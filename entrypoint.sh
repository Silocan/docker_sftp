#!/bin/sh
set -e

# Fonction pour configurer un utilisateur SFTP
setup_sftp_user() {
    local username=$1
    local password=$2
    local directory=$3
    
    if ! id -u "$username" > /dev/null 2>&1; then
        adduser -D -s /bin/false "$username"
    fi
    
    if [ -n "$password" ]; then
        echo "$username:$password" | chpasswd
    else
        echo "$username:$username" | chpasswd
    fi
    
    # Créer le répertoire utilisateur dans /data
    local user_dir="/data/${directory:-$username}"
    mkdir -p "$user_dir"
    chown "$username:$username" "$user_dir"
    chmod 755 "$user_dir"
    
    # Ajouter la configuration SSH pour cet utilisateur
    if ! grep -q "Match User $username" /etc/ssh/sshd_config; then
        echo "" >> /etc/ssh/sshd_config
        echo "Match User $username" >> /etc/ssh/sshd_config
        echo "    ChrootDirectory /data" >> /etc/ssh/sshd_config
        echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config
        echo "    AllowTcpForwarding no" >> /etc/ssh/sshd_config
        echo "    X11Forwarding no" >> /etc/ssh/sshd_config
    fi
}

# S'assurer que le répertoire /data existe et a les bonnes permissions
mkdir -p /data
chown root:root /data
chmod 755 /data

# Liste des utilisateurs autorisés
ALLOW_USERS=""

# Parcourir les variables d'environnement pour créer les utilisateurs
i=1
while true; do
    eval "username=\${SFTP_USER_${i}}"
    
    # Si aucune variable n'est définie pour cet index, arrêter
    if [ -z "$username" ]; then
        break
    fi
    
    eval "password=\${SFTP_PASSWORD_${i}}"
    eval "directory=\${SFTP_DIR_${i}}"
    
    # Utiliser des valeurs par défaut si non définies
    password=${password:-${username}}
    directory=${directory:-${username}}
    
    # Configurer l'utilisateur
    setup_sftp_user "$username" "$password" "$directory"
    
    # Ajouter à la liste des utilisateurs autorisés
    if [ -z "$ALLOW_USERS" ]; then
        ALLOW_USERS="$username"
    else
        ALLOW_USERS="$ALLOW_USERS $username"
    fi
    
    i=$((i + 1))
done

# Si aucun utilisateur n'a été défini, utiliser les variables par défaut (rétrocompatibilité)
if [ -z "$ALLOW_USERS" ]; then
    SFTP_USER=${SFTP_USER:-sftpuser}
    SFTP_PASSWORD=${SFTP_PASSWORD:-sftpuser}
    SFTP_DIR=${SFTP_DIR:-sftpuser}
    setup_sftp_user "$SFTP_USER" "$SFTP_PASSWORD" "$SFTP_DIR"
    ALLOW_USERS="$SFTP_USER"
fi

# Mettre à jour AllowUsers dans la config SSH
sed -i "s/^AllowUsers.*/AllowUsers $ALLOW_USERS/" /etc/ssh/sshd_config || \
    echo "AllowUsers $ALLOW_USERS" >> /etc/ssh/sshd_config

exec "$@"