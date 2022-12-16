# By using the terraform creating EC2 instance and attaching VPC, EBS volume and Security gruop in aws cloud provider. 

## Terraform

Terraform is an open-source infrastructure-as-configuration software tool created by HashiCorp. Users define and provide data center infrastructure using a declarative configuration language known as HashiCorp Configuration Language, or optionally JSON. [clickhere](https://developer.hashicorp.com/terraform/intro). more info

## Terraform installation 

  - Terraform can be installed as a binary files and executables 
  
  - install terraform by usin this url [clickhere](https://developer.hashicorp.com/terraform/downloads).
  
  - By using the above url download terraform on your local machines or vm's.
  
### Terraform installation on linux 
  - By using the `wget`command u can download terraform in your machine 
```
wget https://releases.hashicorp.com/terraform/1.3.6/terraform_1.3.6_linux_amd64.zip
```

  - After executing the above command `terraform_1.3.6_linux_amd64.zip` file will be downlodaded to your machine.
  
  - Next `unzip` the `terraform_1.3.6_linux_amd64.` file by executing the ` unzip terraform_1.3.6_linux_amd64.zip`command.
  
  - If `unzip` is not avilable in your machine install it frist then execute above command.
  
  - When you are executing the `unzip terraform_1.3.6_linux_amd64.zip` it creates a file named `terraform*`.
  
  - Move `terraform*` file to `/usr/local/bin`. by using below command 
  ```
  mv terraform /usr/local/bin
  ```
  
  - If it is installed successfully or not check by passing below command.
  ```
  terrform  version
  ```
> **Note** for creating the resources in aws cloud environment you have an account&credentioals for that account. In your account create a one `IAM` user [clickhere](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html). for creating `IAM` user in aws cloud services, After creating the `IAM` user it gives a `AWS Access Key ID` and `AWS Secret Access Key `. copy this keys or download csv.file into your localmachine by clicking the download button.
   
  
### Installing awscli

- Frist of all download the `awscli` on your machine [click here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for downloading.

- Then run the command `aws configure`  it will ask some information about your aws user details, shown below.

```
@hellouser:~/terraform-practise/terraform-learning$ aws configure
AWS Access Key ID [****************jgdhdg]: xxxxxxxxxxxxxxxxxxxx
AWS Secret Access Key [****************hyuew]: xxxxxxxxxxxxxxxxxxxxxxxxxxx
Default region name [us-east-1b]: us-east-1b
Default output format [None]: json/text
```

## Writing configuration file 

- By using the hashicorp configuration language(hcl) write the terraform configuration files by providing the `.tf` extension.

- create one file named as `main.tf` by using the `touch` command. And write the configuration for creating the resources in perticular provider.

## Writing provider for terraform 

- select a aws provider for building/creating the infrastructure on aws cloud services.

- For writing the config file you can serch ** terraform aws provider ** on any web browser. it gives lot of results for how to write/mention aws provider in configuration file.

- Hashicorp provides official docs for terraform providers  how to write in configuration files.

![image](https://user-images.githubusercontent.com/97168620/208152702-ad7eb01f-99e1-459d-a697-fd095e2fda9a.png)

- By clicking the above link it provides detailed in formatin .

- In the configuration file `main.tf` file in the providers block write the below mentiond code 

```
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
```

- The providers part is done, by mentioning above code.

## Creating  vpc with public subnet 

- For creating the vpc by using the terraform in aws serech on web browser [clickhere](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
 
- By clicking the above linck it will redirect to offcial website.

- The below shown code is used for creating vpc with public subnet 
```
resource "aws_vpc" "my_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my Custom VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.my_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```

- By using the above code we can create vpc on the aws cloud services.

## Creating securtiy gruop on aws by using terraform

- By creating security gruop in aws [clickhere](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group). for reference

- In this security group `22`,`80`,`8080` and `3306` ports are opend.

```
# creating and attaching security group to ec2 instance
resource "aws_security_group" "web_sg" {
  name   = "Mycustom-security"
  vpc_id = aws_vpc.my_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name = "My custom security"
  } 
}
```

- In this security group mentioned  above created vpc_id `vpc_id = aws_vpc.my_custom_vpc.id`. and this code is used for creating security gruop in aws cloud.

## Creating EC2 instance in aws by using terraform 

- For creating the ec2 instance [clickhere](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) for more information.

- In this EC2 instance  resource block we have to metion above created `vpc public subnet id` and ` security group name `.

- And mention the `ami id ` of the instance and `region` and name of the instance .
```
#creating ec2 resource and adding vpc and security group to the instance

resource "aws_instance" "web_instance" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  key_name      = "terraform"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
tags = {
  Name = "terrafromlearning"
  }
}
```

## Creating Ebs volume and attached to the ec2 instance 

- For writing the ebs volume resource block [clickhere](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment).

- In this stage created 8gb of ebs volume and attached to the `EC2` instance shown below.
```
# creating ebs volume and Attaching ebs volume
resource "aws_ebs_volume" "volume-1" {
 availability_zone = "us-east-1a"
 type = "gp2"
 size = 8
 tags = {
    Name = "myebsvolume"
 }

}

# Attaching ebs volume
resource "aws_volume_attachment" "volume-1-attachment" {
 device_name = "/dev/xvdh"
 volume_id = "${aws_ebs_volume.volume-1.id}"
 instance_id = "${aws_instance.web_instance.id}"
}
```
- In this stage mentioned  above created `ec2` instance id.

> **Note** After writing the all the required resources in the `main.tf` configuration file use the below mentioned commands 
   
   terraform init
	
	 terraform validate
	
	 terraform plan 
	
	 terraform apply
	
	 terraform destroy
	
## Terraform initialize 

- By running the below command initialize the terraform 

```
terraform init
```

- The terraform init command initializes a working directory containing Terraform configuration files.

- This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control.

```
@hellouser:~/terraform-practise/terraform-learning$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v4.45.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Terraform validate 

- By run the below command validate the terraform configuration file
```
terraform validate
```
- The terraform validate command validates the configuration files in a directory.

- And referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc.

```
@hellouser:~/terraform-practise/terraform-learning$ terraform validate
Success! The configuration is valid.

```

## Terraform plan command 

- By run the below command 
```
terraform plan 
```

- The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. 

- By default, when Terraform creates a plan it: Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.

```
@hellouser:~/terraform-practise/terraform-learning$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

    }

Plan: 10 to add, 0 to change, 0 to destroy.

```
- It gives the above result by executing the command `terraform plan`.

## Terraform apply command 

- By run the below command we will create the resources in the mentioned providers/aws cloud service.

```
terraform apply
```

- The terraform apply command performs a plan just like terraform plan does.

- But then actually carries out the planned changes to each resource using the relevant infrastructure provider's API.

- It asks for confirmation from the user before making any changes, unless it was explicitly told to skip approval.

```
@hellouser:~/terraform-practise/terraform-learning$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

    }

Resources added 10, 0 to change, 0 to destroy.
```

## Terraform destroy command 

- By executing the below command destroy the resources created by terraform configurationfile 

```
terraform destroy
```
- The terraform destroy command terminates resources managed by your Terraform project.

- This command is the inverse of terraform apply in that it terminates all the resources specified in your Terraform state. 

- It does not destroy resources running elsewhere that are not managed by the current Terraform project.

```
@hellouser:~/terraform-practise/terraform-learning$ terraform destroy

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

    }

Resources added 0, 0 to change, 10 to destroy.

```

- For complete source code [clickhere](https://github.com/anilgitpractice/terraform-learning/blob/main/main.tf).

- By using the terraform configurationfile successfully created ec2 instance and attaching vpc, security_groupand ebs volume 😅

> **Note** In this source code writen in hard coded values you can use varibles by [clickhere](https://developer.hashicorp.com/terraform/language/values/variables) for creating varibles.



