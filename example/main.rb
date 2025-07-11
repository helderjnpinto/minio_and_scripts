require 'aws-sdk-s3'
require 'dotenv/load'
require 'securerandom'

# Load ENV vars
access_key = ENV['MINIO_ACCESS_KEY']
secret_key = ENV['MINIO_SECRET_KEY']
endpoint   = ENV['MINIO_ENDPOINT']
bucket     = ENV['MINIO_BUCKET']

s3 = Aws::S3::Client.new(
  access_key_id: access_key,
  secret_access_key: secret_key,
  region: 'eu-west-2',             # Required but arbitrary
  endpoint: endpoint,
  force_path_style: true
)

s3r = Aws::S3::Resource.new(client: s3)

# Create bucket if not exists
begin
  s3.head_bucket(bucket: bucket)
  puts "Bucket '#{bucket}' already exists."
rescue Aws::S3::Errors::NotFound
  s3.create_bucket(bucket: bucket)
  puts "Created bucket: #{bucket}"
end

# Upload a file
file_name = "test_#{SecureRandom.hex(4)}.txt"
File.write(file_name, "Hello from Ruby at #{Time.now}")

puts "Uploading file: #{file_name}"
s3.put_object(
  bucket: bucket,
  key: file_name,
  body: File.read(file_name)
)
puts "✅ Uploaded #{file_name}."

# Generate presigned URL (readable)
url = Aws::S3::Presigner.new(client: s3).presigned_url(
  :get_object,
  bucket: bucket,
  key: file_name,
  expires_in: 3600
)

puts "Presigned download URL (valid 1h):"
puts url

# Optional: download file
downloaded_file = "downloaded_#{file_name}"
File.write(downloaded_file, s3.get_object(bucket: bucket, key: file_name).body.read)
puts "✅ Downloaded file as #{downloaded_file}."
