module AWSEdges
  class Subnet
    attr_reader :nodes

    def initialize(describe_subnets)
      @nodes = Array.new
      describe_subnets[:subnet_set].each{|s|
        @nodes.push({
          :vpc_id => s[:vpc_id],
          :cidr_block => s[:cidr_block],
          :availability_zone => s[:availability_zone],
          :subnet_id => s[:subnet_id]
        })
      }
    end

    def self.supported_fields
      [ "vpc_id", "cidr_block", "availability_zone", "subnet_id" ]
    end
  end
end
