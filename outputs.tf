output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.basic_ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.basic_ec2.public_ip
}

output "ssh_command" {
  description = "Command to SSH into your Linux instance from Windows PowerShell"
  value       = "ssh -i linux_lab_key.pem ec2-user@${aws_instance.basic_ec2.public_ip}"
}

output "health_check_url" {
  description = "URL to test Challenge 3 (Health Check API once started)"
  value       = "http://${aws_instance.basic_ec2.public_ip}:8080/health"
}

output "private_key_file" {
  description = "Path to the downloaded private key file"
  value       = local_file.private_key.filename
}
