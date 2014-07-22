# aws-edges

## Overview

**aws-edges** allows you to created high level graphviz digraphs of your AWS components. Currently this does not cover everything returned from the AWS Ruby SDK, only select components so far. 

## Installation

```
$ gem install aws-edges
```

## Usage

```
$ ./aws-edges -h
Usage: aws-edges [options]
    -c, --config [CONFIG_FILE]       Config file
    -f, --config-format [yaml|json]  Config file format (yaml or json)
    -a [ACCESS_KEY_ID],              AWS Access Key ID
        --access-key-id
    -s [SECRET_ACCESS_KEY],          AWS Secret Access Key
        --secret-key-id
    -r, --region [REGION]            AWS Region (ie: us-east-1)
    -C, --list-colors                Prints out a list of supported colors
    -S, --list-shapes                Prints out a list of supported shapes
    -?, --help                       Shows this message
```

## Configuration Example

There are some examples located in the 'examples' directory. Below is one of them. The *sources* section tells the *aws-edges* script what to pull from AWS. And the rest is pretty self explanatory. 

The basic structure is show below. The `name` key provides the output name of the graph generated. Which will generate both a *.dot* and *.png* file by default. 

```
---
  name: "my graph name"
  sources: 
    - "ec2"
    - "subnet"
    - "vpc"
  edges: 
    - 
      from_shape: "egg"   
      from: "vpc_cidr_block"
      to: "vpc_vpc_id"
      to_shape: "triangle"
    - 
      from: "subnet_vpc_id"
      to: "subnet_subnet_id"
      to_color: "brown"
    -
      from: "ec2_subnet_id"
      to: "ec2_private_ip_address"
    -
      from: "ec2_private_ip_address"
      to: "ec2_instance_id"
    -
      from_color: "orange"
      from: "ec2_instance_id"
      to: "ec2_availability_zone"
    -
      from: "subnet_cidr_block"
      to: "subnet_subnet_id"
```
### Specifying output format

If you like to save the graph in a different format other than the default `png`. You can specify the `save_as: "pdf"` or some other image format such as tiff. 

### Mapping a 'many' node

What is a 'many' node? Simply put, it is a object containing many entries or an Hash of an Array of Hashes.

The syntax for mapping a 'many' node is `"redshift_cluster_nodes-private_ip_address"`. The `-` character indicating that `redshift_cluster_nodes` is an Array and you want all the `private_ip_address` objects/property.

### Grouping edges

Sometime you would like to visually group a set or sets of edges together so they appear in a container. This can help distinguish the relation between edge objects. You will need to group your objects using the `cluster` key and can label it using something like; `label: "My VPCs"`. Below is an example config snippet:

```
---
  name: "example"
  rotate: true
  sources: 
    - "vpc"
  cluster: 
    label: "Virtual Private Clouds"
    edges: 
      - 
        to: "vpc_cidr_block"
        from: "vpc_vpc_id"
```

### Changing the layout

By default graphs are generated in a horizontal top down structure. If you like a vertical left to right representation you will need to set the `rotate: true` property in your config like so:

```
$ cat myconfig.yml
---
  name: "example"
  rotate: true
  sources: 
    - "vpc"
    - "ec2"
    - "subnet"
```

### Adding edge colors

In order to make it easier to identify groups of like edges, coloring (fill) support has been added. Being that this utilizes the `graph` gem it supports all of the colors supported by it. 

[Visit Graphviz Colors to see what they look like](http://www.graphviz.org/content/color-names)

To see what colors are available run the following command:

```
$ aws-edges -C
```

or

```
$ aws-edges --list-colors
```

To use colors, in your config simply add either `to_color: "orange"` or `from_color: "brown"` to the `edges` section of the config. (See example above)

### Adding edges shapes

In order to make it easier to identify *like* edges, shape support has been added. As with colors, it supports the shapes available to the `graph` gem on which the gem requires.

[Visit Graphviz Shapes to see what the look like](http://www.graphviz.org/content/node-shapes)

To list the supported shapes, run the following command:

```
$ aws-edges -S
```

or

```
$ aws-edges --list-shapes
```

To use shapes, in your config simply add either `to_shape: "triangle"` or `from_shape: "egg"` to the `edges` section of the config. (See example above)

## Hacking and Contributing

Fork it and start hacking. Below is a brief summary of the layout of the code.

Inside 'lib/aws-edges' are the classes used. These are kind of categorized by the AWS Ruby SDK "describe*" methods and client types. For example, *subnet.rb* only parses the EC2 *describe-subnets* output. Each class file contains an *initialize* method and a *supported_fields* public method.

The 'config.rb' is used to parse the configuration file (which can be either yaml or json). It uses the *supported_fields* method to validate what is entered in the config. It also contains a *valid_keys*, *valid_sources*, *valid_prefixes*.

'graph.rb' is what creates the graphs.

