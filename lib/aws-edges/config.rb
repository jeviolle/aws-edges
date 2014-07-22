module AWSEdges
  class Config
    @@valid_keys = ["name", "sources", "cluster", "label", "edges", 
                    "from", "from_shape", "from_color", 
                    "to", "to_shape", "to_color" ,"rotate", "save_as"]
    @@valid_sources = ["VPC","EC2","RDS","Redshift","Subnet"]
    @@valid_prefixes = @@valid_sources

    def initialize
      @node_types = @@valid_sources.map{|s| 
        eval "AWSEdges::#{s}.supported_fields.map{|f| s.downcase + '_' + f}"
      }.flatten
    end

    def msg_and_exit(msg)
      puts msg
      exit 1
    end

    ##
    # Validate the source section of the config file
    #
    def validate_sources(sources)
      msg_and_exit("No sources specified in the config") if sources.nil?
      sources.each do |source|
        unless @@valid_sources.map{|i| i.downcase}.include?(source)
          msg_and_exit("Invalid source detected in config: #{source}")
        end
      end
    end

    ##
    # Verify that a graph name is specified in the config
    #
    def validate_name(graph_name)
      msg_and_exit("No graph name specified in the config") if graph_name.nil?
    end

    ##
    # Confirm that from and to edges are specified properly and are 
    # not a many-to-many relationship
    def validate_nodes(hashed_data)
      nodes = []
      hashed_data.each do |k,v|
        if k == "edges"
          v.each{|e| 
            if e["from"].include?('-') and e["to"].include?('-')
              msg_and_exit("Error: from many to many edges detected in config:\n (#{e['from']}) -> (#{e['to']})")
            end
            nodes.push e["from"]
            nodes.push e["to"]
          } 
        end
        nodes.push(validate_nodes(v)) if v.class == Hash
      end
      nodes.flatten.uniq.each do |u|
        unless @node_types.include?(u)
          msg_and_exit("Invalid edge node specified: #{u}")
        end
      end
    end

    ##
    # Internal method for testing a color
    private def test_color(color)
      colors = digraph.class::BOLD_COLORS + digraph.class::LIGHT_COLORS
      msg_and_exit("Invalid color specified: #{color}") unless colors.include?(color) 
    end

    ##
    # Verify that the colors defined are supported by the 
    # underlying Graph gem
    def validate_colors(hashed_data)
      hashed_data.each do |k,v|
        if k == "edges"
          v.each{|e|
            if e["from_color"]
              test_color(e["from_color"])
            end

            if e["to_color"]
              test_color(e["to_color"])
            end
          }
        end
      end
    end

    ##
    # Internal method for testing a shape
    private def test_shape(shape)
      shapes = digraph.class::SHAPES
      msg_and_exit("Invalid shape specified: #{shape}") unless shapes.include?(shape)
    end

    ##
    # Verify that the shapes defined are supported by the 
    # underlying Graph gem
    def validate_shapes(hashed_data)
      hashed_data.each do |k,v|
        if k == "edges"
          v.each{|e|
            if e["from_shape"]
              test_shape(e["from_shape"])
            end

            if e["to_shape"]
              test_shape(e["to_shape"])
            end
          }
        end
      end
    end

    ##
    # Validate that the 'keys' are valid in the config
    def validate_keys(hashed_data)
      keys = []
      hashed_data.each do |k,v|
        unless k == "edges"
          keys.push(k)
          keys.push(validate_keys(v)) if v.class == Hash 
        else
          v.each{|e|
            keys.push(validate_keys(e)) 
          }
        end
      end
      keys.flatten.uniq.each do |u|
        unless @@valid_keys.include?(u)
          msg_and_exit("Invalid key found in config: #{u}")
        end
      end
    end

    ##
    # Attempt to parse the json/yaml config and run through
    # validation
    def parse(file_type,config_file)
      begin
      case file_type
      when /^yaml$/i
        config = YAML.load(File.read(config_file))
      when /^json$/i
        config = JSON.parse(File.read(config_file))
      else
        msg_and_exit("Invalid file type specified: #{file_type}")
      end
      rescue Exception => e
        msg_and_exit("Failed to parse config: #{e.message}")
      end

      # run through validation checks
      validate_keys(config)
      validate_colors(config)
      validate_shapes(config)
      validate_sources(config['sources'])
      validate_nodes(config)
      validate_name(config['name'])

      return config
    end

  end
end
