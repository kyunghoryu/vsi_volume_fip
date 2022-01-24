#variable ibmcloud_api_key {}


provider "ibm" {


  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 300
}
