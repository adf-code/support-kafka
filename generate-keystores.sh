#!/bin/bash

set -e

# === Konfigurasi ===
PASSWORD="changeit"
DAYS_VALID=365
KEYSTORE_DIR="./secrets"
COMMON_NAME="localhost"

# === Membuat direktori ===
mkdir -p "$KEYSTORE_DIR"

# === Kafka ===
echo "🔐 Generating Kafka keystore & truststore..."

keytool -genkeypair \
  -alias kafka \
  -keyalg RSA \
  -keysize 2048 \
  -validity $DAYS_VALID \
  -keystore "$KEYSTORE_DIR/kafka.keystore.jks" \
  -dname "CN=$COMMON_NAME, OU=Dev, O=MyCompany, L=Jakarta, S=Java, C=ID" \
  -storepass $PASSWORD \
  -keypass $PASSWORD

keytool -exportcert \
  -alias kafka \
  -keystore "$KEYSTORE_DIR/kafka.keystore.jks" \
  -storepass $PASSWORD \
  -rfc -file "$KEYSTORE_DIR/kafka.cer"

keytool -importcert \
  -alias kafka-ca \
  -file "$KEYSTORE_DIR/kafka.cer" \
  -keystore "$KEYSTORE_DIR/kafka.truststore.jks" \
  -storepass $PASSWORD -noprompt

# === Zookeeper ===
echo "🔐 Generating Zookeeper keystore & truststore..."

keytool -genkeypair \
  -alias zookeeper \
  -keyalg RSA \
  -keysize 2048 \
  -validity $DAYS_VALID \
  -keystore "$KEYSTORE_DIR/zookeeper.keystore.jks" \
  -dname "CN=$COMMON_NAME, OU=Dev, O=MyCompany, L=Jakarta, S=Java, C=ID" \
  -storepass $PASSWORD \
  -keypass $PASSWORD

keytool -exportcert \
  -alias zookeeper \
  -keystore "$KEYSTORE_DIR/zookeeper.keystore.jks" \
  -storepass $PASSWORD \
  -rfc -file "$KEYSTORE_DIR/zookeeper.cer"

keytool -importcert \
  -alias zookeeper-ca \
  -file "$KEYSTORE_DIR/zookeeper.cer" \
  -keystore "$KEYSTORE_DIR/zookeeper.truststore.jks" \
  -storepass $PASSWORD -noprompt

echo "✅ All keystores and truststores created in $KEYSTORE_DIR"

# === Kafka UI ===
keytool -import -trustcacerts \
  -alias kafka-ca \
  -file ./secrets/kafka.cer \
  -keystore ./secrets/kafka-ui.truststore.jks \
  -storepass changeit \
  -noprompt

keytool -genkeypair \
  -alias kafka \
  -keyalg RSA \
  -keystore kafka.keystore.jks \
  -storepass changeit \
  -keypass changeit \
  -dname "CN=localhost" \
  -ext SAN=dns:localhost,ip:127.0.0.1