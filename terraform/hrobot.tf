resource "hrobot_ssh_key" "admin" {
  for_each = {
    for file in fileset(path.module, "../users/keys/*") :
    basename(file) => file
  }
  name       = each.key
  public_key = file(each.value)
}
