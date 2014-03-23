module AWSEdges
  class Redshift 
    attr_reader :nodes

    def initialize(describe_clusters)
      @nodes = Array.new
      describe_clusters[:clusters].each{|c|
        @nodes.push({
          :db_name => c[:db_name],
          :vpc_id => c[:vpc_id],
          :availability_zone => c[:availability_zone],
          :subnet_group_name => c[:cluster_subnet_group_name],
          :publicly_accessible => c[:publicly_accessible],
          :cluster_version => c[:cluster_version],
          :encrypted => c[:encrypted],
          :cluster_nodes => []
        })

        cluster_nodes = Array.new
        c[:cluster_nodes].each{|n|
          cluster_nodes.push({
            :node_role => n[:role_name],
            :public_ip_address => n[:public_ip_address],
            :private_ip_address => n[:private_ip_address]
          })
        }
        @nodes[@nodes.length - 1][:cluster_nodes] = cluster_nodes
      }
    end

    def self.supported_fields
      [
        "db_name", "vpc_id", "availability_zone",
        "subnet_group_name", "publicly_accessible", "cluster_version",
        "encrypted", "cluster_nodes-node_role",
        "cluster_nodes-public_ip_address", "cluster_nodes-private_ip_address"
      ]
    end
  end
end
