# TODO -list
# add edge shape/color attribute support
# add node (ie path)  color/shape support
# allow control of node_attribs << filled
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

    ##
    # Generate the graphviz digraph statement for edges
    #
    def map_edges(from, from_color, to, to_color)
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

                unless from_color.nil?
                  unless from_color.empty?
                    cmd_string += assign_color_attribute(from_color, i[:"#{child}"])
                  end
                end

                unless to_color.nil?
                  unless to_color.empty?
                    cmd_string += assign_color_attribute(to_color, node[:"#{to_node}"]) 
                  end
                end

              end
            elsif to_node.include?('-')
              (parent, child) = to_node.split('-')
              node[:"#{parent}"].each do |i|
                cmd_string += " edge " + '"' + 
                node[:"#{from_node}"].to_s + '","' +
                i[:"#{child}"].to_s + '";'

                unless from_color.nil?
                  unless from_color.empty?
                    cmd_string += assign_color_attribute(from_color, node[:"#{from_node}"])
                  end
                end

                unless to_color.nil?
                  unless to_color.empty?
                    cmd_string += assign_color_attribute(to_color, i[:"#{child}"]) 
                  end
                end

              end
            else
              cmd_string += " edge " + '"' + 
              node[:"#{from_node}"].to_s + '","' + 
              node[:"#{to_node}"].to_s + '";'

              unless from_color.nil?
                unless from_color.empty?
                  cmd_string += assign_color_attribute(from_color, from_node)
                end
              end

              unless to_color.nil?
                unless to_color.empty?
                  cmd_string += assign_color_attribute(to_color, to_node) 
                end
              end

            end
      end
      cmd_string
    end

    ##
    # TODO: assign colors
    # all eg: edge_attribs << orange
    def assign_color_attribute(color, edge)
      return "#{color} << node(\"#{edge}\");"
    end

    ##
    # TODO: assign shapes
    # single eg: triangle << node("EDGE")
    # all eg: edge_attribs << triangle
    def assign_shape_attribute()
    end

    ##
    # Dynamically create graphviz digraph statements
    # based on the config file input
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
            cmd_string += map_edges(e['from'], e['from_color'], e['to'], e['to_color'])
          end
        end
      end
      cmd_string
    end

    ##
    # Main method for creating graphviz digraphs from the
    # parsed config file
    def create_graph()
      ##
      # default to png output format
      # for a full list: http://www.graphviz.org/doc/info/output.html
      format = @config.delete('save_as')
      format = "png" unless format
      graph_name = @config.delete('name').gsub(/\s+/,'_')
      rotate_layout = true if @config['rotate'] == true
      cmds = generate_graph_statements(@config)
      begin
      digraph do
        node_attribs << filled
        rotate if rotate_layout
        boxes
        eval cmds
        save "#{graph_name}", "#{format}"  
      end
      rescue Exception => e
        puts "Failed to create the graph: #{e}"
        exit 1
      end
    end
  end
end
