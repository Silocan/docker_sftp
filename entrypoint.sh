#!/bin/sh
set -e

# Fonction pour configurer un utilisateur SFTP
setup_sftp_user() {
    local username=$1
    local password=$2
    
    if ! id -u "$username" > /dev/null 2>&1; then
        adduser -D -s /bin/false "$username"
    fi
    
    if [ -n "$password" ]; then
        echo "$username:$password" | chpasswd
    else
        echo "$username:$username" | chpasswd
    fi
    
    # Créer le répertoire utilisateur dans /data
    mkdir -p "/data/$username"
    chown "$username:$username" "/data/$username"
    chmod 755 "/data/$username"
    
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

# Utiliser les variables d'environnement ou les valeurs par défaut
SFTP_USER=${SFTP_USER:-sftpuser}
SFTP_PASSWORD=${SFTP_PASSWORD:-sftpuser}

# Configurer l'utilisateur principal
setup_sftp_user "$SFTP_USER" "$SFTP_PASSWORD"

# Mettre à jour AllowUsers dans la config SSH
sed -i "s/^AllowUsers.*/AllowUsers $SFTP_USER/" /etc/ssh/sshd_config || \
    echo "AllowUsers $SFTP_USER" >> /etc/ssh/sshd_config

exec "$@"

