require 'optparse'
require 'ostruct'

require 'EditDistance'
require 'LCS'

class SeqAnalysis
  
  def parseArgs(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    @options = OpenStruct.new
    @options.remove_eq_chars = false
    @options.output = "result.txt"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: analysis.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-i", "--input FILE",
              "The input file containing the data") do |i|
        @options.input = i
      end

      opts.on("-o", "--o FILE",
              "The analysis file path") do |o|
        @options.output = o
      end
      
      opts.on("-c", "--csv", "Write csv file instead of txt") do |c|
        @options.write_csv = c
      end

      opts.on("-r", "--remove", "Remove equivalent fixations") do |r|
        @options.remove_eq_chars = r
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opts.parse!(args)
    if @options.input==nil
      puts opts
      exit
    end
  end  # parse()
  
  def analyse
    parse_input
    preprocess_data
    results = []
    
    @data.keys.sort!.each{ |key|
      puts "Processing data of #{key} ..."
      @data.keys.sort!.each{ |key2|
          if key != key2
            key_result = []
            key_result << key
            key_result << key2
            
            levenshtein_distance = @data[key].edit_distance(@data[key2])
            levenshtein_sim = @data[key].edit_distance_similarity(@data[key2])
            longest_sub_seq = @data[key].largest_common_subsequence(@data[key2])
            
            key_result << levenshtein_distance
            key_result << levenshtein_sim
            key_result << longest_sub_seq
            results << key_result
          end
      }      
    }
    write(results)
  end
  
  private
  def parse_input
    @data={}
    File.open(@options.input, "r") do |in_file|
      while (line = in_file.gets)
        if line.include? "VP"
          tmp = in_file.gets
          @data[line.strip]=tmp.strip
        end
      end
    end
  end

  def preprocess_data
    @data.keys.each{ |key|
      new_data = preprocess(@data[key])
      @data[key]=new_data
    }
  end
  
  def preprocess(data)
    previous_char = ''
    result_string = ''
    data_string = String.new(data)
    data_string.scan(/./m){ |x| 
      if x == ' ' || x == previous_char
        # do nothing
      else 
        result_string << x
        # similar chars are only removed if option is set
        if @options.remove_eq_chars
          previous_char = x
        end
      end
    }
    return result_string
  end
  
  def write(results)
    if @options.write_csv
      write_csv(results)
    else
      write_txt(results)
    end
  end
  
  def write_csv(results)
    puts "Writing CSV files not implemented yet. Writing plain text file instead."
    write_txt(results)
  end
  
  def write_txt(results)
    output_file = File.new(@options.output,"w+")
    output_file << "Analysis Results\n"
    output_file << "===========================================================\n"
    
    first_result = true
    
    results.each{ |result|
      if first_result
        first_result = false
      else
        output_file << "-----------------------------------------------------------\n"
      end
      output_file << "\n\nResults for #{result[0]}:\n"
      output_file << " - Compared to #{result[1]}\n"
      output_file << "   * Seq 1: #{@data[result[0]]}\n"
      output_file << "   * Seq 1: #{@data[result[1]]}\n"

      output_file << "   * Edit Distance:                     #{result[2]}\n"
      output_file << "   * Similarity:                        #{result[3]}\n"
      output_file << "   * Longest Common Subsequence Length: #{result[4].length}\n"
      output_file << "   * Longest Subsequence:               #{result[4]}\n"
    }
    
    output_file.close 
  end
  
end

#
# Execution starts here
#
s = SeqAnalysis.new
s.parseArgs(ARGV)
results = s.analyse

