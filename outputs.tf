output "vm_public_ip" {
  value = module.vnet.vm_public_ip
}

output "appgw_public_ip" {
  value = module.appgw.appgw_public_ip
}
