# Istio test porject

## Istio in Action Github Repository

- https://github.com/istioinaction/book-source-code/tree/master

## Access Gateway Service

Fixed NodePorts for easy access:

- HTTP: 30080 → access at http://localhost:30080
- HTTPS: 30443 → access at https://localhost:30443

## Call endpoints CH4
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

## Call endpoints CH5

```
curl http://localhost:30080/items -H "Host: catalog.istioinaction.io"
curl http://localhost:30080/items -H "Host: catalog.istioinaction.io" -H "x-istio-cohort: internal"

# Multiple times
for i in {1..100}; do curl -s http://localhost:30080/items -H "Host: catalog.istioinaction.io"; done
```

## Call Endpoints CH6

```
curl http://localhost:30080 -H "Host: simple-web.istioinaction.io"

for in in {1..100}; do time curl -s \
-H "Host: simple-web.istioinaction.io" http://localhost:30080 \
| jq .code; printf "\n"; done

## Fortio Load Test
fortio load -H "Host: simple-web.istioinaction.io" \
-quiet -jitter -t 30s -c 1 -qps 1 http://localhost:30080/

fortio load -H "Host: simple-web.istioinaction.io" \
-allow-initial-errors -quiet -jitter -t 30s -c 10 -qps 20 http://localhost:30080/
```

## Call Endpoints CH9.1

```
## Wrong issuer
WRONG_ISSUER=eyJhbGciOiJSUzI1NiIsImtpZCI6IkNVLUFESkpFYkg5YlhsMHRwc1FXWXVvNEV3bGt4RlVIYmVKNGNra2FrQ00iLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ3NDUxNTE1NDgsImdyb3VwIjoidXNlciIsImlhdCI6MTU5MTU1MTU0OCwiaXNzIjoib2xkLWF1dGhAaXN0aW9pbmFjdGlvbi5pbyIsInN1YiI6Ijc5ZDc1MDZjLWI2MTctNDZkMS1iYzFmLWY1MTFiNWQzMGFiMCJ9.eUEbrJ3Gr4F5eViMlLsIGcD6UIId6tH6u5vLN_IzPnwpSSp6vy6knVgC1GHsWPWwnEhcPHz1TlQz8E3O6F7oVyNhMTJyniaXtVyByvgAVCbeaOYVRnm1aSWwjFt5IfJJcbk21BWbPfE12Hfbo03sRq1hI1iEcn4nbtoh8tjj_G4r8gwiKVlkA3g5bFkwiSEmZQe2cumzgdtNu4XzU5ghl6cdFyzYD5x3750uy_bfduaQokCVymQq3P-dUPnz7_5-ZOj-3SRb3yHbmvlAnyQgTgIlQc3J-anGnsqec33lhVh5RdNuxKj9J14a-ub9ysjzUvcXh1expDqNxR33BaQnpQ

curl -H "Host: webapp.istioinaction.io" -H "Authorization: Bearer $WRONG_ISSUER" -sSl localhost:30080/api/catalog

## Requests with no token
curl -H "Host: webapp.istioinaction.io" -sSl -o /dev/null -w "%{http_code}" localhost:30080/api/catalog
curl -H "Host: webapp.istioinaction.io" -v localhost:30080/api/catalog

USER_TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IkNVLUFESkpFYkg5YlhsMHRwc1FXWXVvNEV3bGt4RlVIYmVKNGNra2FrQ00iLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ3NDUxNDUwMzgsImdyb3VwIjoidXNlciIsImlhdCI6MTU5MTU0NTAzOCwiaXNzIjoiYXV0aEBpc3Rpb2luYWN0aW9uLmlvIiwic3ViIjoiOWI3OTJiNTYtN2RmYS00ZTRiLWE4M2YtZTIwNjc5MTE1ZDc5In0.jNDoRx7SNm8b1xMmPaOEMVgwdnTmXJwD5jjCH9wcGsLisbZGcR6chkirWy1BVzYEQDTf8pDJpY2C3H-aXN3IlAcQ1UqVe5lShIjCMIFTthat3OuNgu-a91csGz6qtQITxsOpMcBinlTYRsUOICcD7UZcLugxK4bpOECohHoEhuASHzlH-FYESDB-JYrxmwXj4xoZ_jIsdpuqz_VYhWp8e0phDNJbB6AHOI3m7OHCsGNcw9Z0cks1cJrgB8JNjRApr9XTNBoEC564PX2ZdzciI9BHoOFAKx4mWWEqW08LDMSZIN5Ui9ppwReSV2ncQOazdStS65T43bZJwgJiIocSCg

## Succesful GET request with token
curl -H "Host: webapp.istioinaction.io" -H "Authorization: Bearer $USER_TOKEN" -sSl -o /dev/null -w "%{http_code}" localhost:30080/api/catalog

## RBAC error with POST request with user token
curl -H "Host: webapp.istioinaction.io" -H "Authorization: Bearer $USER_TOKEN" -XPOST localhost:30080/api/catalog --data '{"id": 2, "name": "Shoes", "price": "84.00"}'

ADMIN_TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IkNVLUFESkpFYkg5YlhsMHRwc1FXWXVvNEV3bGt4RlVIYmVKNGNra2FrQ00iLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ3NDUxNDUwNzEsImdyb3VwIjoiYWRtaW4iLCJpYXQiOjE1OTE1NDUwNzEsImlzcyI6ImF1dGhAaXN0aW9pbmFjdGlvbi5pbyIsInN1YiI6IjIxOGQzZmI5LTQ2MjgtNGQyMC05NDNjLTEyNDI4MWM4MGU3YiJ9.MEL9ANwx4kvxkK90cdkUBejn-cLIrACdvGiE9T4RE3F1FRc4et4EZ79s-tbb7OJgnOCkTcvB-Q4V_9WaeAU_kNvzM1rGGh1a0ahQI01Iipt0c6RUlWk1GUr5eUul7xw5MoR-kKDuB-fB0qG2_WQfyiqez6uO9OGJxipTwfhoWJfq_9sZ3p7d8iwJzIcCleTb6ywKmIa4gJb0UhaVcs77HP7KTq9PzTj2adOa2KtfH0BTFjAymZKJVEsV64A_XdNAybiVmEmd8kqTuIbHob-ZT9Mlyl3ER_A6rbIzx6myD9F8m1GIaz2fgtMCJyawuxd_YK4L1cvWhJ2BkbyCtC1znQ

curl -H "Host: webapp.istioinaction.io" -H "Authorization: Bearer $ADMIN_TOKEN" -XPOST -sSl -w "%{http_code}" localhost:30080/api/catalog/items  --data '{"id": 2, "name": "Shoes", "price": "84.00"}'
```


## Notes
When the ingress-gateway needs to read the certificate from a secret the deployment needs to be restarted