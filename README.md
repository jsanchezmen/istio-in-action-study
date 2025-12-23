# Istio test porject

## Access Gateway Service

Fixed NodePorts for easy access:

- HTTP: 30080 → access at http://localhost:30080
- HTTPS: 30443 → access at https://localhost:30443

## Call endpoints
```
# Http
curl http://127.0.0.1:30080/api/catalog -H "Host: webapp.istioinaction.io"

# Https simple TLS
curl -v https://webapp.istioinaction.io:30443/ --resolve webapp.istioinaction.io:30443:127.0.0.1 --cacert certs/ca-chain.cert.pem -H "Host: webapp.istioinaction.io"

curl -v https://webapp.istioinaction.io:30443/api/catalog --resolve webapp.istioinaction.io:30443:127.0.0.1 --cacert certs/ca-chain.cert.pem -H "Host: webapp.istioinaction.io"

# Https mTLS
curl -v https://webapp.istioinaction.io:30443/api/catalog --resolve webapp.istioinaction.io:30443:127.0.0.1 --cacert certs/ca-chain.cert.pem -H "Host: webapp.istioinaction.io" --cert certs/client-cert.cert.pem --key certs/client-key.key.pem

# Https simple TLS catalog service
curl -v https://catalog.istioinaction.io:30443/items --resolve catalog.istioinaction.io:30443:127.0.0.1 --cacert certs/catalog-ca-chain.cert.pem -H "Host:catalog.istioinaction.io"

# Curl simple tls SNI service 1
curl https://simple-sni-1.istioinaction.io:30010/ --cacert certs/sni-svc-1-ca-chain.cert.pem --resolve simple-sni-1.istioinaction.io:30010:127.0.0.1 -H "Host: simple-sni-1.istioinaction.io"

# Curl simple tls SNI service 2
curl https://simple-sni-2.istioinaction.io:30010/ --cacert certs/sni-svc-2-ca-chain.cert.pem --resolve simple-sni-2.istioinaction.io:30010:127.0.0.1 -H "Host: simple-sni-2.istioinaction.io"

# Telnet TCP port
telnet 127.0.0.1 30011

```

## Notes
When the ingress-gateway needs to read the certificate from a secret the deployment needs to be restarted