# Docker Kerberos KDC Server

This repository provides a ready-to-use Dockerized Kerberos Key Distribution Center (KDC) server. It simplifies the deployment and management of a Kerberos KDC by leveraging Docker.

---

## Features

- Configurable Kerberos Realm, Server, and Encryption Types.
- Support for custom principals and admin accounts.
- Automatically initializes the Kerberos database on first run.
- Uses `kadm5.acl` for fine-grained ACL configuration.
- Persisted Kerberos database using Docker volumes.
- Prebuilt Docker image available on [GitHub Container Registry (ghcr.io)](https://ghcr.io/froz42/docker-kdc).

---

## Getting Started

### Prerequisites

- Docker installed on your system.
- `docker-compose` installed for orchestration.

---

## Configuration

### Environment Variables

The following environment variables can be configured via an `.env` file or directly in `docker-compose.yml`:

| Variable                         | Description                                   | Example                          |
| -------------------------------- | --------------------------------------------- | -------------------------------- |
| `KDC_REALM`                      | Kerberos realm name                           | `EXAMPLE.FR`                     |
| `KDC_SERVER`                     | Fully Qualified Domain Name (FQDN) of the KDC | `kdc.example.fr`                 |
| `KDC_SUPPORTED_ENCRYPTION_TYPES` | Supported encryption types for Kerberos       | `aes256-cts-hmac-sha1-96:normal` |
| `KADMIN_PRINCIPAL`               | Admin principal for managing Kerberos         | `kadmin/admin`                   |
| `KADMIN_PASSWORD`                | Password for the admin principal              | `admin`                          |

### ACL Configuration

The `kadm5.acl` file is used to configure ACLs for Kerberos administration. A default ACL file is included:

```plaintext
kadmin/admin@EXAMPLE.COM *
```

### Docker Volumes

- The Kerberos database is stored in the `database` volume. This ensures data persistence across container restarts.

---

## Usage

### Build and Run the Container

1. Clone the repository and navigate to the project directory.

2. Ensure the `.env` file contains the desired configurations.

3. Use `docker-compose` to build and run the container:

   ```bash
   docker-compose up --build
   ```

### Prebuilt Image

You can also pull the prebuilt image directly from the GitHub Container Registry:

```bash
docker pull ghcr.io/froz42/docker-kdc:latest
```

To use the prebuilt image, modify `docker-compose.yml`:

```yaml
services:
  kdc-server:
    image: ghcr.io/froz42/docker-kdc:latest
```

---

## Entrypoint Details

The container uses the following entrypoint script:

1. Creates the `krb5.conf` and `kdc.conf` configuration files dynamically based on the environment variables.

2. Initializes the Kerberos database if not already initialized, and generates a master password.

3. Configures the admin principal using the specified `KADMIN_PRINCIPAL` and `KADMIN_PASSWORD`.

4. Starts the Kerberos KDC server.

---

## Example `docker-compose.yml`

```yaml
version: "3.7"
services:
  kdc-server:
    image: ghcr.io/froz42/docker-kdc:latest
    ports:
      - "88:88"
      - "749:749"
      - "750:750"
    environment:
      - KDC_REALM=${KDC_REALM}
      - KDC_SERVER=${KDC_SERVER}
      - KADMIN_PRINCIPAL=${KADMIN_PRINCIPAL}
      - KADMIN_PASSWORD=${KADMIN_PASSWORD}
      - KDC_SUPPORTED_ENCRYPTION_TYPES=${KDC_SUPPORTED_ENCRYPTION_TYPES}
    volumes:
      - ./kadm5.acl:/etc/krb5kdc/kadm5.acl
      - database:/var/lib/krb5kdc

volumes:
  database:
```

---

## Logs and Debugging

On startup, the container logs useful information, such as:

- Configured realm and principal.
- Master password (on first initialization).

Example log output:

```plaintext
REALM: EXAMPLE.FR
KADMIN_PRINCIPAL_FULL: kadmin/admin@EXAMPLE.FR
KADMIN_PASSWORD: ********

IMPORTANT: Save the following master password
Master password: some-randomly-generated-master-password

Starting Kerberos KDC
Creating KDC principal
```

---

## References

- [Kerberos Documentation](https://web.mit.edu/kerberos/)

For issues or contributions, feel free to open a GitHub issue or submit a pull request.
