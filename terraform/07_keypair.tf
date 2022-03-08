resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}"
  public_key = file(var.ssh_pubkey_file)
}
