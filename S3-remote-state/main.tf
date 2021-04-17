resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-myproject"  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-myproject"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"  
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-myproject"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-myproject"
    encrypt        = true
  }
}
