
resource "aws_kinesis_firehose_delivery_stream" "stream_to_s3" {
 # Creates firehose with "direct put" source
  for_each                    = { for firehose in var.firehose_details : firehose.firehose_stream_name => firehose }
  name        = each.value.firehose_stream_name

 destination = "extended_s3"
 extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = each.value.bucket_arn

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          orc_ser_de {}
        }
      }
         schema_configuration {
        role_arn      =  aws_iam_role.firehose_role.arn  
        database_name = each.value.glue_database_name
        table_name    = each.value.glue_catalogtable_name
        region        = "ap-south-1"
      }
    }

    # buffer_size        = each.value.buffer_size
    # buffer_interval    = each.value.buffer_interval

    s3_backup_mode     = each.value.s3_backup_mode

    s3_backup_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = each.value.backup_bucket_arn
      # buffer_size        = each.value.backup_buffer_size
      # buffer_interval    = each.value.backup_buffer_interval
      compression_format = each.value.backup_compression_format
    }

# cloudwatch_logging_options{
#   enabled = each.value.cloudwatch_logging_enabled
# }

}
  lifecycle {
    ignore_changes = [tags]
  }

}
resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy =<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  lifecycle {
    ignore_changes = [tags]
  }

}
resource "aws_iam_role_policy" "policy_for_firehose_access_to_glue" {
  name = "firehose_access_to_glue"
  role = aws_iam_role.firehose_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = var.policy_action
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })


}

