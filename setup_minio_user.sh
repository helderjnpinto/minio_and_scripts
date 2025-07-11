#!/bin/bash

# CONFIGURAÇÕES
MC_VERSION="RELEASE.2024-05-10T01-41-27Z"
MINIO_ALIAS="minio"
MINIO_URL="http://127.0.0.1:9900"
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadminpass"

NEW_ACCESS_KEY="mybucketuser"
NEW_SECRET_KEY="supersecret123"
BUCKET_NAME="my-bucket"
POLICY_NAME="readwrite-${BUCKET_NAME}"

# 1. Verificar se o mc já está instalado
if ! command -v mc &> /dev/null; then
  echo "📦 Installing mc..."
  curl -sO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  sudo mv mc /usr/local/bin/
else
  echo "✅ mc already installed at $(which mc)"
fi

# 2. Criar alias MinIO
echo "🔗 Adding MinIO host alias '$MINIO_ALIAS'..."
mc alias set $MINIO_ALIAS $MINIO_URL $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD || exit 1

# 3. Criar bucket se não existir
if ! mc ls $MINIO_ALIAS/$BUCKET_NAME &> /dev/null; then
  echo "🪣 Creating bucket: $BUCKET_NAME"
  mc mb $MINIO_ALIAS/$BUCKET_NAME
else
  echo "ℹ️ Bucket '$BUCKET_NAME' already exists."
fi

# 4. Criar política customizada
echo "🛡 Creating policy: $POLICY_NAME"
echo '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::'$BUCKET_NAME'/*"]
    },
    {
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::'$BUCKET_NAME'"]
    }
  ]
}' > /tmp/policy.json

mc admin policy create $MINIO_ALIAS $POLICY_NAME /tmp/policy.json

# 5. Criar usuário e associar política
echo "👤 Creating user '$NEW_ACCESS_KEY' and assigning policy..."
mc admin user add $MINIO_ALIAS $NEW_ACCESS_KEY $NEW_SECRET_KEY
mc admin policy attach $MINIO_ALIAS $POLICY_NAME --user $NEW_ACCESS_KEY

# Limpeza
rm -f /tmp/policy.json

echo ""
echo "✅ Done! User '$NEW_ACCESS_KEY' now has read/write access to bucket '$BUCKET_NAME'."
echo "🔐 Access Key: $NEW_ACCESS_KEY"
echo "🔐 Secret Key: $NEW_SECRET_KEY"
