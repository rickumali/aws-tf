output "public_ip" {
    value = aws_instance.example_instance.public_ip
    description = "The Public IP of the EC2"
}