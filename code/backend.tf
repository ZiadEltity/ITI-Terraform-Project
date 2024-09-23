terraform {
  backend "s3" {
    bucket         = "tr-statefile"
    key            = "tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-state"
  }
}