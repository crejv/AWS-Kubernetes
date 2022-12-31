# AWS-Kubernetes

# User's AccessKeys to make programmatic calls to AWS for Provider Credentials

export AWS_ACCESS_KEY_ID="anaccesskey"

export AWS_SECRET_ACCESS_KEY="asecretkey"

export AWS_DEFAULT_REGION="us-west-2"

#AmazonResourceName(ARN) from AssumeRole so User is granted Additional Permissions/Policies

export TF_VAR_custom_role="arn:aws:iam::YOUR_ACCT#123456789:role/YOUR_ASSUME_ROLE"
