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
*CloudWatch with auto-scaling, for target tracking scaling policy*
*CloudWatch for ec2 and ssm to store the cloudwatch agent config*
*ec2 role and permission to access cloudwatch,ssm and s3*



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
- cwagent_config.json # it store the agent metrics
- role_ssm.tf # it enables the ec2 to have access to aws resources, while the ssm stores the metrics for cloudwatch

##  **Prerequisites**
- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create resources

## *Features*
- *CloudWatch for auto-scaling, using __Target Tracking Base__ (aws handles the scaling automataically)*


- ```hcl
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

- *CloudWatch for monitoring ec2 and ssm to store the agent config*

- *create ssm manager*
- ```hcl
  resource "aws_ssm_parameter" "cw_agent_config" {
  name  = "/CWAgent/config"
  type  = "String"
  value = file("./cwagent_config.json")
}

- *create the cloudwatch agent config(let it be in json) file*
- ```json
  {
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}


- *create a role for the ec2 instances to be able to access any aws resource*
- ```hcl
  resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"
  description = "IAM role for EC2 instances to use SSM and CloudWatch Agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

- *create a policy for cloudwatch for ec2 to have access to cloudwatch*
- ```hcl
  resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

- *create a policy for ssm so ec2 will also have access to it*
- ```hcl 
  resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

- *create an instance profile for the ec2, because ec2 does not have direct access to the role*
- ```hcl
  resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}
<!-- kindly note that the role policies has been attached to the role, and the role is attached to the instance profile -->

- *Next is to install cloud watch agent on all auto-scaling ec2 instances, we will make use of the user-data-sh script*
- ```bash
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  dpkg -i -E ./amazon-cloudwatch-agent.deb

- *Next is to fetch the ssm cwagent config*
- ```bash
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -c ssm:${aws_ssm_parameter.cw_agent_config.name} -s


- *For the ec2 to have access to download the cloudwatch agent from s3, i gave the ec2 s3 permission*
- ```hcl
  resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
<!-- The ec2 has only ReadOnlyAccess, for least priviledge -->