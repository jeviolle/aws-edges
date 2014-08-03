module AWSEdges
  class IAM
    attr_reader :nodes

    def initialize(iam)
      @nodes = Array.new

      # get IAM groups
      iam.list_groups[:groups].each{|g|
        @nodes.push({
          :group_name => g[:group_name],
          :group_id => g[:group_id],
          :group_arn => g[:arn],
          :group_create_date => g[:create_date],
          :users => []
        }) 

        assigned_users = Array.new
        iam.get_group(options = {:group_name => g[:group_name]})[:users].each {|u|
          assigned_users.push({
            :user_name => u[:user_name],
            :user_id => u[:user_id],
            :arn => u[:arn],
            :path => u[:path],
            :create_date => u[:create_date],
          })
        }
        @nodes[@nodes.length - 1][:users] = assigned_users
      }

      # get IAM users
      iam.list_users[:users].each{|u|
        @nodes.push({
          :user_name => u[:user_name],
          :user_id => u[:user_id],
          :user_arn => u[:arn],
          :user_path => u[:path],
          :user_create_date => u[:create_date],
          :groups => []
        })

        assigned_groups = Array.new
        iam.list_groups_for_user(options = {:user_name => u[:user_name]})[:groups].each {|g|
          assigned_groups.push({
            :path => g[:path],
            :group_name => g[:group_name],
            :group_id => g[:group_id],
            :arn => g[:arn],
            :create_date => g[:create_date]
          }) 
        }
        @nodes[@nodes.length - 1][:groups] = assigned_groups
      }
    end

    def self.supported_fields
      [ "group_path", "group_name", "group_id", "group_arn",
        "group_create_date", "users-path", "users-user_name",
        "users-user_id", "users-arn", "users-create_date",
        "user_path", "user_name", "user_id", "user_arn",
        "user_create_date", "groups-path", "groups-group_name",
        "groups-group_id", "groups-arn", "groups-create_date"
      ]
    end
  end

end
