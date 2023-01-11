variable "your_ip" {
  description = "Enter your public IP address (i.e. 111.222.22.104/32)"
  type        = string
}

variable "ami_id" {
  description = "Enter the AMI ID you want to use for your EC2 instance"
  type        = string
  default = "ami-0f924dc71d44d23e2"
}

variable "instance_type" {
  description = "Enter instance type for your EC2 instance"
  type        = string
  default = "t2.micro"
}