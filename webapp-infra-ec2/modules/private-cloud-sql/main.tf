resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${var.subnet1}", "${var.subnet2}"]
}

resource "aws_security_group" "default" {
  name        = "db-instance"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "rajesh"
  password             = "master12"
  parameter_group_name = "default.mysql5.7"

  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids    = ["${aws_security_group.default.id}"]
  publicly_accessible = true
  skip_final_snapshot = true
}