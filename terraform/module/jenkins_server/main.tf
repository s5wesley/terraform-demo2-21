resource "aws_instance" "vm" {
  count                   = var.instance_count
  ami                     = var.ec2_instance_ami
  instance_type           = var.ec2_instance_type
  key_name                = var.ec2_instance_key_name
  vpc_security_group_ids  = [aws_security_group.sg.id]
  subnet_id               = var.subnet_id
  disable_api_termination = var.enable_termination_protection

  root_block_device {
    volume_size = var.root_volume_size
  }

  user_data = <<-EOF
    #!/bin/bash

    # This script will install java and jenkins
    echo "Checking the operating system"
    OS=$(awk -F= '/PRETTY_NAME/{gsub(/"/,"",$2); print $2}' /etc/os-release | awk '{print$1}')

    echo 'checking if jenkins is installed'
    ls /var/lib | grep jenkins
    if [[ \${1} -eq 0 ]]; then 
      echo "Jenkins is installed"
      exit 1
    else
      case $OS in
        Ubuntu)
          sudo apt update
          sudo apt install ca-certificates -y
          sudo apt search openjdk
          sudo apt install openjdk-11-jdk -y
          java -version
          ufw allow 8080/tcp   2&>/dev/null 
          wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
          sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
          sudo apt-get update -y
          sudo apt-get install jenkins -y
          systemctl start jenkins 
          systemctl enable jenkins
          ;;
        CentOS) 
          sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
          sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
          sudo yum upgrade -y
          sudo yum install jenkins java-11-openjdk-devel -y
          sudo systemctl daemon-reload
          systemctl start jenkins 
          systemctl enable jenkins
          firewall-cmd --permanent --add-port=8080/tcp   2&>/dev/null 
          firewall-cmd --reload 2&>/dev/null
          ;;
        Amazon)
          sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
          sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
          sudo yum upgrade -y
          sudo yum install jenkins java-1.8.0 -y
          sudo systemctl daemon-reload
          systemctl start jenkins 
          systemctl enable jenkins
          firewall-cmd --permanent --add-port=8080/tcp   2&>/dev/null   
          firewall-cmd --reload 2&>/dev/null
          ;;
        *)
          echo "Your operating system is UNKNOWN"
          exit 1
          ;;
      esac 
    fi
  EOF

  tags = merge(var.tags, {
    Name = format("%s-%s-%s-${var.instance_name}-%d", var.tags["id"], var.tags["environment"], var.tags["project"], count.index + 1)
  })
}
