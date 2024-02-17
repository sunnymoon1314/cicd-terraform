terraform {
  backend "s3" {
    bucket = "sctp-ce5-tfstate-bucket-1"
    key    = "soon.tfstate"
    region = "us-east-1"
  }
}
