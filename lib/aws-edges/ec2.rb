module AWSEdges 
  class EC2 
    attr_reader :nodes

    def initialize(describe_instances)
      @nodes = Array.new
      describe_instances[:reservation_set].each{|r| r[:instances_set].each{|i|
        @nodes.push({
          :instance_id => i[:instance_id],
          :instance_type => i[:instance_type],
          :kernel_id => i[:kernel_id],
          :ramdisk_id => i[:ramdisk_id],
          :architecture => i[:architecture],
          :ebs_optimized => i[:ebs_optimized],
          :root_device_type => i[:root_device_type],
          :root_device_name => i[:root_device_name],
          :virtualization_type => i[:virtualization_type],
          :hypervisor => i[:hypervisor],
          :source_dest_check => i[:source_dest_check],
          :image_id => i[:image_id],
          :vpc_id => i[:vpc_id],
          :subnet_id => i[:subnet_id],
          :public_dns_name => i[:dns_name],
          :public_ip_address => i[:ip_address],
          :private_dns_name => i[:private_dns_name],
          :private_ip_address => i[:private_ip_address],
          :availability_zone => i[:placement][:availability_zone],
          :security_groups => []
        })

        security_groups = Array.new
        i[:group_set].each{|g|
          security_groups.push({
            :group_name => g[:group_name],
            :group_id => g[:group_id]
          })
        }
        @nodes[@nodes.length - 1][:security_groups] = security_groups
      }}
    end

    def self.supported_fields
      [
        "instance_id", "kernel_id", "ramdisk_id", "architecture",
        "ebs_optimized", "root_device_type", "root_device_name",
        "virtualization_type", "hypervisor", "source_dest_check", "image_id", "vpc_id",
        "subnet_id", "public_dns_name", "public_ip_address", "private_dns_name", 
        "private_ip_address", "availability_zone", "security_groups-group_name",
        "security_groups-group_id"
      ]
    end
  end
end
