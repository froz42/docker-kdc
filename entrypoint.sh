#!/usr/bin/env bash

set -e

KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$KDC_REALM

echo "REALM: $KDC_REALM"
echo "KADMIN_PRINCIPAL_FULL: $KADMIN_PRINCIPAL_FULL"
echo "KADMIN_PASSWORD: ********"
echo ""

# we check if the 

cat > /etc/krb5.conf <<EOF
[libdefaults]
	default_realm = $KDC_REALM

[realms]
	$KDC_REALM = {
		kdc_ports = 88,750
		kadmind_port = 749
		kdc = $KDC_SERVER
		admin_server = $KDC_SERVER
	}
EOF

cat > /etc/krb5kdc/kdc.conf <<EOF
[realms]
	$KDC_REALM = {
		acl_file = /etc/krb5kdc/kadm5.acl
		max_renewable_life = 7d 0h 0m 0s
		supported_enctypes = $KDC_SUPPORTED_ENCRYPTION_TYPES
		default_principal_flags = +preauth
		key_stash_file = /var/lib/krb5kdc/.k5.$KDC_REALM
	}
EOF

if [ ! -f /etc/krb5kdc/kadm5.acl ]; then
    echo "Creating default ACL file since it does not exist"
    cat > /etc/krb5kdc/kadm5.acl <<EOF
$KADMIN_PRINCIPAL_FULL *
EOF
fi

# we check if the database is already initialized
if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo "Initializing Kerberos database"

    MASTER_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)

    echo
    echo
    echo "IMPORTANT: Save the following master password"
    echo "Master password: $MASTER_PASSWORD"
    echo
    echo

    echo "Creating Kerberos database"
    kdb5_util create -s -P $MASTER_PASSWORD
fi

echo "Starting Kerberos KDC"
krb5kdc

echo "Creating KDC principal"
kadmin.local -q "delete_principal -force $KADMIN_PRINCIPAL_FULL"
kadmin.local -q "addprinc -pw $KADMIN_PASSWORD $KADMIN_PRINCIPAL_FULL"

$@