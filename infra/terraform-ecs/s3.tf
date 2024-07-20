terraform {
  backend "s3" {
    bucket         = "dev-backet-gor-tf-state"
    region         = "eu-central-1"
    encrypt        = true
    key            = "AWS/dev/terraform.tfstate"
    #dynamodb_table = "terraform_state_eu_central_1"
  }
}


#если нужно будет лочить стейт тд то с помощью дайнамо дб
  
