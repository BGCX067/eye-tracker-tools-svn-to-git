require 'optparse'
require 'ostruct'

require 'EditDistance'
require 'LCS'

class SetSeqAnalysis
  
  def parseArgs(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    @options = OpenStruct.new
    @options.remove_eq_chars = false
    @options.output = "result.txt"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: SetSeqAnalysis.rb [options]"

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
    results = set_largest_common_subsequence(@data)
    write(results)
  end
  
   def set_largest_common_subsequence(set)
		results = []
		set2 = set.reverse
		set.each{ |s1|
			tmp = s1
			set2.each{ |s2|
				if s1 != s2
					tmp = tmp.largest_common_subsequence(s2)
				end
			}
			results << tmp
		}
		return results
	end
  
  private
  
  def set_largest_common_subsequence(set)
		results = []
		set2 = set.reverse
		set.each{ |s1|
			tmp = s1
			set2.each{ |s2|
				if s1 != s2
					tmp = tmp.largest_common_subsequence(s2)
				end
			}
			results << tmp
		}
		return results
	end
  
  def parse_input
    @data=[]
    File.open(@options.input, "r") do |in_file|
      while (line = in_file.gets)
       @data << line
      end
    end
  end

  def preprocess_data
	  new_data = []
	  @data.each{ |string|
      	new_data << preprocess(string)
      }
	  @data = new_data
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
    output_file = File.new(@options.output,"w+")
    output_file << "Analysis Results\n"
	output_file << "-----------------------------------------------------------\n"
    
	i=1
	@data.each do |string|
		output_file << "Seq #{i}: #{string}\n"
		i = i+1
	end
	
	output_file << "-----------------------------------------------------------\n"
    results.each{|r|
    	output_file << "Longest Common Subsequence Length: #{r.length}\n"
		output_file << "Longest Subsequence:               #{r}\n"
    }
    output_file.close 
  end
  
end

#
# Execution starts here
#
s = SetSeqAnalysis.new
s.parseArgs(ARGV)
s.analyse

