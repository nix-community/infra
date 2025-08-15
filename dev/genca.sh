#!/usr/bin/env bash
# https://github.com/NixOS/infra/blob/5d020952f5b870ff323904035347cd768530617d/non-critical-infra/hosts/staging-hydra/genca.sh
set -x

hosts="build03 build04"

O="Nix Community Infra"

newDir="$(date '+%Y-%m-%dT%H:%M')"
mkdir "${newDir}"
cd "${newDir}" || exit

openssl genpkey -algorithm Ed25519 -out ca.key
openssl req -x509 -new -nodes -key ca.key -sha256 -days 18250 -out ca.crt \
  -subj "/O=${O}/CN=hydra-queue-runner-ca"

cat <<EOF >server.cnf
[req]
prompt             = no
x509_extensions    = v3_req
req_extensions     = v3_req
default_md         = sha256
distinguished_name = req_distinguished_name

[req_distinguished_name]
O  = ${O}
CN = queue-runner.hydra.nix-community.org

[v3_req]
basicConstraints = CA:FALSE
keyUsage         = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage = critical, serverAuth
subjectAltName   = @alt_names

[alt_names]
DNS.1 = queue-runner.hydra.nix-community.org
EOF

openssl genpkey -algorithm Ed25519 -out server.key
openssl req -new -key server.key -out server.csr -config server.cnf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 18250 -sha256 -extfile server.cnf -extensions v3_req

for host in ${hosts}; do
  openssl genpkey -algorithm Ed25519 -out "client-${host}.key"
  openssl req -new -key "client-${host}.key" -out "client-${host}.csr" \
    -subj "/O=${O}/CN=hydra-queue-builder-${host}"
  openssl x509 -req -in "client-${host}.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -out "client-${host}.crt" -days 18250 -sha256
done

rm -rf -- *.csr *.srl
rm server.cnf

cd - || exit
