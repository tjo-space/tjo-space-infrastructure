# code.tjo.space

Forgejo Deployment

### Components

- Debian
- FirewallD
- Caddy
  - Handling TLS termination, dynamic certificate provisioning.
- Grafana Alloy
  - Metrics and Logs being shipped to https://monitor.tjo.cloud.
- Forgejo
- Anubis
- Valkey + Redis Exporter
