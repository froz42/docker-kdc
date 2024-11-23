FROM phusion/baseimage:noble-1.0.0

RUN apt-get update && apt-get install -y \
    krb5-kdc krb5-admin-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]

EXPOSE 88 750 749

CMD ["/usr/sbin/kadmind", "-nofork"]
