# TODO -list
# add color attribute support
# add shape support
# add xref support for edge nodes (eg:)
#   - ec2_private_ip_address
#   - vpc_cidr_block
# change edge to node if point is missing
# add support for nested values
#   - redshift_cluster_nodes-*

module AWSEdges
  class Graph
    attr_reader :format
    
    def initialize(config_data, aws_data)
      @config = config_data
      @aws = aws_data
    end

    def map_edges(from, to)
      cmd_string = ""  
      from_prefix, from_node = $1, $2 if from =~ /^(\w+?)_(.+)/
      to_prefix, to_node = $1, $2 if to =~ /^(\w+?)_(.+)/
      @aws[:"#{from_prefix}"].each do |node|
            if from_node.include?('-')
              (parent, child) = from_node.split('-')
              node[:"#{parent}"].each do |i|
                cmd_string += " edge " + '"' + 
                i[:"#{child}"].to_s + '","' +
                node[:"#{to_node}"].to_s + '";'
              end
            elsif to_node.include?('-')
              (parent, child) = to_node.split('-')
              node[:"#{parent}"].each do |i|
                cmd_string += " edge " + '"' + 
                node[:"#{from_node}"].to_s + '","' +
                i[:"#{child}"].to_s + '";'
              end
            else
              cmd_string += " edge " + '"' + 
              node[:"#{from_node}"].to_s + '","' + 
              node[:"#{to_node}"].to_s + '";'
            end
      end
      cmd_string
    end

    def generate_graph_statements(config)
      cmd_string = ""
      config.each do |key,value|
        if key == "cluster"
          cmd_string += "cluster \"#{value['label']}\" do " 
          cmd_string += "label \"#{value['label']}\";"
          cmd_string += generate_graph_statements(value)
          cmd_string += " end;"
        elsif key == "edges"
          value.each do |e|
            cmd_string += map_edges(e['from'], e['to'])
          end
        end
      end
      cmd_string
    end

    def create_graph()
      ##
      # default to png output format
      # for a full list: http://www.graphviz.org/doc/info/output.html
      format = @config.delete('save_as')
      format = "png" unless format
      graph_name = @config.delete('name').gsub(/\s+/,'_')
      rotate_layout = true if @config['rotate'] == true
      cmds = generate_graph_statements(@config)
      digraph do
        rotate if rotate_layout
        boxes
        eval cmds
        save "#{graph_name}", "#{format}"  
      end
    end
  end
end
