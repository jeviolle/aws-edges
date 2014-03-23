require 'json'
require 'yaml'
require 'graph'
require 'aws-edges/vpc.rb'
require 'aws-edges/subnet.rb'
require 'aws-edges/ec2.rb'
require 'aws-edges/rds.rb'
require 'aws-edges/redshift.rb'
require 'aws-edges/version.rb'
require 'aws-edges/config.rb'
require 'aws-edges/graph.rb'

##
# AWS Edges creates a simple chart of your
# current AWS environment. 
#
module AWSEdges
  # hierarchy and filter
  # --------------------
  # region -> vpc -> az -> subnet -> ec2 -> instances
  # region -> vpc -> az -> subnet_group -> redshift -> cluster -> nodes
  # region -> vpc -> az -> subnet_group -> rds -> nodes
  #
  # region -> az -> ec2 -> instances
  # region -> az -> redshift -> cluster -> nodes
  # region -> az -> rds -> nodes
  #
  # types of charts
  # ---------------
  # eip mapping
  # iam access map
  # ec2 map
  # rds map
  # ami map
  # redshift map
  # instances map (contains ec2, rds, redshift)
  # security group map
  # complete map (contains all)
end
