resource "aws_iam_role" "server" {
  name = "${var.project}-server-${var.environment}"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "server" {
  name = "${var.project}-server-${var.environment}"
  role = aws_iam_role.server.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "server" {
  name = "${var.project}-server-${var.environment}"
  role = aws_iam_role.server.name
}

# resource "aws_key_pair" "server" {
#   key_name   = "${var.project}-server-${var.environment}"
#   public_key = file("instance-public.key")
# }

resource "aws_instance" "iac-demo" {
  ami           = data.aws_ami.ubuntu-18_04.id
  instance_type = var.server_instance_type

  # key_name             = aws_key_pair.server.key_name
  iam_instance_profile = aws_iam_instance_profile.server.name

  # Assign security group rules to the server
  security_groups = [
    aws_security_group.server.name
  ]

  tags = {
    Name        = "iac-demo-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "null_resource" "provisioner" {
  connection {
    host = aws_instance.iac-demo.public_ip
    type = "ssh"
    user = "ubuntu"
    # private_key = file("${path.module}/instance-private.key")
  }

  triggers = {
    init_sha1 = sha1(file("provision/server-init.sh"))
    app       = sha1(file("provision/webserver/app.js"))
    package   = sha1(file("provision/webserver/package.json"))
  }

  provisioner "file" {
    source      = "provision/webserver"
    destination = "/home/ubuntu"
  }

  provisioner "remote-exec" {
    script = "provision/server-init.sh"
  }
}
