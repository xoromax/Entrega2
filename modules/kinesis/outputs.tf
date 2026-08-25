output "stream_name" {
  value = aws_kinesis_stream.main.name
}

output "stream_arn" {
  value = aws_kinesis_stream.main.arn
}

output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.bronze.name
}

output "bronze_bucket_name" {
  value = aws_s3_bucket.bronze.bucket
}