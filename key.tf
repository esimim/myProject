resource "aws_key_pair" "myProject" {
  key_name   = "myProject"
  public_key = file(var.MY_PUBLIC_KEY)
}
