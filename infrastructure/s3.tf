
#***********************************************************
# Create KMS Key for File Bucket 
#***********************************************************

resource "aws_kms_key" "file-bucket" {
  description = "${var.project_name} file_store"

  tags = { 
    Name = "${var.project_name} files" 
  }

}

#***********************************************************
# Call AWS data for use in script
#***********************************************************
data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}





#***********************************************************
# Create  File bucket 
#***********************************************************

resource "aws_s3_bucket" "filebucket" {
  bucket        = "${var.trailprefix}files"

  tags = {
    Name = "${var.project_name} File_Bucket"
  }



   server_side_encryption_configuration {
     rule {
       apply_server_side_encryption_by_default {
         kms_master_key_id = "${aws_kms_key.file-bucket.arn}"
         sse_algorithm     = "aws:kms"
       }
     }
 }
}
#***********************************************************
# Block Public Access 
#***********************************************************




resource "aws_s3_bucket_public_access_block" "trailbucket" {
  bucket = "${aws_s3_bucket.trail_logs.id}" 

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true 
}



resource "aws_s3_bucket_public_access_block" "filebucket" {
  bucket = "${aws_s3_bucket.filebucket.id}" 

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true 
}



#***********************************************************
# Create KMS Key for Cloudtrail 
#***********************************************************

resource "aws_kms_key" "trail_key" {
  description = "${var.project_name} trail_log"

  tags = { 
    Name = "${var.project_name} Trail_Log" 
  }

}


#***********************************************************
# Create Trail bucket 
#***********************************************************

resource "aws_s3_bucket" "trail_logs" {
  bucket        = "${var.trailprefix}trailbucket"
  force_destroy = true

  tags = {
    Name = "${var.project_name} Trail_Bucket"
  }



   server_side_encryption_configuration {
     rule {
       apply_server_side_encryption_by_default {
         kms_master_key_id = "aws_kms_key.trail_key.arn"
         sse_algorithm     = "aws:kms"
       }
     }

}

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.trailprefix}trailbucket"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.trailprefix}trailbucket/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}




#***********************************************************
# Capture Cloud Trail 
#***********************************************************

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.trailprefix}trail"
  s3_bucket_name                = "${var.trailprefix}trailbucket"
  include_global_service_events = true

  tags = {
    Name = "${var.project_name} Trail"
  }
}

resource "aws_iam_role" "cloudtrail_iam_role" {
  name = "${var.trailprefix}cloudtrail"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "wazuh_trail_role" {
  name = "wazuh_trail_role"
  role = "${aws_iam_role.cloudtrail_iam_role.name}"
}


#***********************************************************
# Wazuh Cloud Trail Role
#***********************************************************

resource "aws_iam_role" "wazuh_iam_role" {
  name = "wazuh_iam_role"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "wazuh_traillog_policy" {
  description = "give wazuh access to the s3 cloudtrail buckets"

#  role = "{data.aws_iam_instance_profile.wazuh_trail_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",                
                "s3:ListBucket",
                "sts:AssumeRole"                
            ],
            "Resource": [
                "arn:aws:s3:::secops-jupiter-env-trailbucket",
                "arn:aws:s3:::secops-jupiter-env-trailbucket/*",    
                "arn:aws:iam::857476524517:role/wazuh_iam_role",
                "arn:aws:iam::857476524517:instance-profile/wazuh_trail_role"
            ]
        }
    ]
}
EOF

}

