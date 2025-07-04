resource "aws_s3_bucket" "remote_state" {
    bucket = "bori-itgx-intership-remote-state"

    lifecycle {
        prevent_destroy = true
    }

    tags = {
        Name = "bori-itgx-intership-remote-state"
    }
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.remote_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
    bucket = aws_s3_bucket.remote_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}
