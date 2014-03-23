module AWSEdges
  class VPC
    attr_reader :nodes

    def initialize(describe_vpcs)
      @nodes = Array.new
      describe_vpcs[:vpc_set].each{|v|
        @nodes.push({
          :vpc_id => v[:vpc_id],
          :cidr_block => v[:cidr_block]
        })
      }
    end

    def self.supported_fields
      [ "vpc_id", "cidr_block" ]
    end
  end
end
