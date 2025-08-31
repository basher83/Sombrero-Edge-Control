terraform {
  backend "remote" {
    hostname     = "the-mothership.scalr.io"
    organization = "env-v0o8ts5tr6gr8hg"

    workspaces {
      name = "production-microk8s"
    }
  }
}
