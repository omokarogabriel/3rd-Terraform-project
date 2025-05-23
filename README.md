**## THIS DOCUMENT THE INFRASTRUCTURE, USING TERRAFORM ##**
> ==This project automates the provisioning of AWS cloud infrastructure using Terraform. It includes VPC creation, subnets(public for alb, private for ec2 instances), security groups,igw,eip,nat gateway,alb,auto-scaling and cloudwatch to monitor the scaling policy. With deploying a static website using BASH SCRIPT.==

**INFRASTRUCTURE OUTLINE**
*vpc*
*internet gateway*
*route table, route and associate the route table to the public subnet*
*eip(elastic ip address)*
*nat gateway*
*route table, route and associate the route table to the public subnet*
*availability zone with data*
*security group(alb and ec2)*
*alb(application load balancer)*
*target group*
*listener*
*launch template or launch configuration*
*auto-scaling group*
*scaling policy(aws automatic scaling)*
*a simple webpage, to display in the browser*


**PROJECT STRUCTURE FILES**
- alb.tf # load balncer, target group and listener
- auto-scaling # auto scaling group and aws scaling policy
<!-- - instances.tf # lanuch template for the auto scaling -->
- locals.tf # general tags and project info
- network.tf # vpc,subnets,routes
- output.tf # displays all resource name or id
- provider.tf   # The file contains the provider configuration for AWS and the data sources
                # to retrieve the availability zones and the current AWS account ID.
                # It uses the AWS provider to interact with AWS services and resources.
- security.tf # the traffic of the resource for port
- terraform.tfvars # the default value of the variable
- user-data.sh # the script that install and manage packages with the index files
- variable.tf # the values info

##  **Prerequisites**
- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create resources

