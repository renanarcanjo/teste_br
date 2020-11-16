variable "rg_main" {
  description = "The name of resource group "
  type = string
}

variable "rg_vnet" {
  description = "The name of resource group VNET"
  type = string
}

variable "location" { 
  description = "Location "
  type = string
}

variable "env_proj" { 
  description = "Enviroment deploy"
  type = string
}

variable "nome_vnet" { 
  description = "VNET Name"
  type = string
}

variable "tag_ambiente" { 
  description = "TAG Enviroment"
  type = string
}

variable "tag_arquiteto" { 
  description = "TAG Arch"
  type = string
}

variable "tag_respo" { 
  description = "TAG Responsavel"
  type = string
}

variable "tag_app" { 
  description = "TAG Aplicacao"
  type = string
}

variable "tag_fornecedor" { 
  description = "TAG Fonecedor"
  type = string
}

variable "subnet_aks" {
  description = "Subnet AKS"
  type = string
}

variable "subnet_mgm" {
  description = "Subnet Management"
  type = string
}

variable "rt_mgm" {
  description = "Route Table MGM"
  type = string
}

variable "nsg_name" {
  description = "Name of Security Group"
  type = string
}

variable "workspace_name" {
  description = "Log Analytics Name"
  type = string
}

variable "peering_name" {
  description = "the name of the peering"
  type = string
  default = "Peering-to-SubBRK"
}

variable "dest_vnet_id"{
  description = "vnet id of the destination vnet"
  type = string
  default = "/subscriptions/ea75cb51-afe3-4691-9136-eb174ad5a756/resourceGroups/RG-FIREWALL/providers/Microsoft.Network/virtualNetworks/FW-Transit-Vnet"
}

variable "dnsp" {
  description = "Primary DNS"
  type = string
}

variable "dnss" {
  description = "Secondary DNS"
  type = string
}

variable "subnet_mgm_name" {
  description = "Name of Subnet Mgm"
  type = string
}

variable "project" {
  description = "Name of Project"
  type = string
}

variable "add_space" {
  description = "Address Space of VNET"
  type = string
}

variable "subnet_aks_name" {
  description = "Name of Subnet"
  type = string
}

variable "cr_name" {
  description = "Container Registry"
  type = string
}

variable "aksname" {
    description = "the name of aks cluster"
    type = string
    default = "aksname"
}

variable "dnsprefix"{
    description = "the dns internal prefix"
    type = string
    default = "brkinternal"
}

variable "nodecount" {
    description = "The total number of node count cluster should have"
    type = string
    default = "3"
}

variable "nodesize" {
    description = "The size of the vms in nodepool"
    type = string
    default = "Standard_D1_V2"
}

variable "nsg"{
    description = "the name of the resource group"
    type = string
    default = "defaultnsg"
}

variable "loadbalance"{
    description = "SKU Load Balance"
    type = string
    default = "standard"
}
