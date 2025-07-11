# MinIO Ruby S3 Example

This is a sample script to connect to a local or remote MinIO S3 server using Ruby and the AWS SDK.

## ⚙ Requirements

- Ruby 3.x+
- MinIO server running (local or remote)
- S3 credentials

## 🚀 Setup

```bash
cd minio_s3_example
cp .env.example .env     # edit this file
bundle install
ruby main.rb
