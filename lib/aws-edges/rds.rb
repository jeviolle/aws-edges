module AWSEdges
  class RDS 
    attr_reader :nodes

    def initialize(describe_db_instances)
      @nodes = Array.new
      describe_db_instances[:db_instances].each{|i|
        @nodes.push({
          :db_name => i[:db_name],
          :db_engine => i[:engine],
          :vpc_id => i[:db_subnet_group][:vpc_id],
          :subnet_group_name => i[:db_subnet_group][:db_subnet_group_name],
          :availability_zone => i[:availability_zone],
          :secondary_availability_zone => i[:secondary_availability_zone],
          :multi_az => i[:multi_az],
          :db_engine_version => i[:engine_version],
          :iops => i[:iops],
          :publicly_accessible => i[:publicly_accessible]
        })
      }
    end

    def self.supported_fields
      [
        "db_name", "db_engine", "vpc_id",
        "subnet_group_name", "availability_zone",
        "secondary_availability_zone", "multi_az",
        "db_engine_version", "iops", "publicly_accessible"
      ]
    end
  end
end
