# aws-edges

## Overview

**aws-edges** allows you to created high level graphviz digraphs of your AWS components. Currently this does not cover everything returned from the AWS Ruby SDK, only select components so far. 

## Installation

```
$ gem install aws-edges
```

## Usage

```
$ aws-edges --help
Usage: aws-edges [options]
    -c, --config [CONFIG_FILE]       Config file
    -f, --config-format [yaml|json]  Config file format (yaml or json)
    -a [ACCESS_KEY_ID],              AWS Access Key ID
        --access-key-id
    -s [SECRET_ACCESS_KEY],          AWS Secret Access Key
        --secret-key-id
    -r, --region [REGION]            AWS Region (ie: us-east-1)
    -?, --help                       Shows this message
```

## Configuration Example

There are some examples located in the 'examples' directory. Below is one of them. The *sources* section tells the *aws-edges* script what to pull from AWS. And the rest is pretty self explanatory. 

The syntax for mapping a 'many' node is '"redshift_cluster_nodes-private_ip_address"'. The '-' character indicating that 'redshift_cluster_nodes' is an Array and you want the 'private_ip_address' object.

```
---
  name: "my graph name"
  sources: 
    - "ec2"
    - "subnet"
    - "vpc"
  edges: 
    -
      from: "vpc_cidr_block"
      to: "vpc_vpc_id"
    - 
      from: "subnet_vpc_id"
      to: "subnet_subnet_id"
    -
      from: "ec2_subnet_id"
      to: "ec2_private_ip_address"
    -
      from: "ec2_private_ip_address"
      to: "ec2_instance_id"
    -
      from: "ec2_instance_id"
      to: "ec2_availability_zone"
    -
      from: "subnet_cidr_block"
      to: "subnet_subnet_id"
```

## Hacking and Contributing

Fork it and start hacking. Below is a brief summary of the layout of the code.

Inside 'lib/aws-edges' are the classes used. These are kind of categorized by the AWS Ruby SDK "describe*" methods and client types. For example, *subnet.rb* only parses the EC2 *describe-subnets* output. Each class file contains an *initialize* method and a *supported_fields* public method.

The 'config.rb' is used to parse the configuration file (which can be either yaml or json). It uses the *supported_fields* method to validate what is entered in the config. It also contains a *valid_keys*, *valid_sources*, *valid_prefixes*.

'graph.rb' is what creates the graphs.

