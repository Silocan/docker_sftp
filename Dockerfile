FROM alpine:latest

RUN apk add --no-cache openssh openssh-sftp-server && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd

# Configuration SSH pour SFTP uniquement
RUN echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "AllowUsers sftpuser" >> /etc/ssh/sshd_config

# Script d'initialisation pour créer l'utilisateur
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

