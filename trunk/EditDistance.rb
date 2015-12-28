class String
  #calculate the edit distance using dyn. programming
  def edit_distance (target)
    s = self.downcase
    t = target.downcase
    
    return calculate_edit_matrix(s, t)
  end
  
  
  #calculate the lexical similarity of this string and target
  def edit_distance_similarity (target)
   return 1-(self.edit_distance(target) / [self.length, target.length].max.to_f)
  end
  
  
  #
  # private section
  #
  private
  def init_cost_matrix (source_size, target_size)
    cost_matrix = Array.new(source_size)
    i=0
    while i<source_size
      cost_matrix[i] = Array.new(target_size)
      cost_matrix[i][0]=i
      i+=1
    end
    j=1
    while j<target_size
      cost_matrix[0][j]=j
      j+=1
    end
    return cost_matrix
  end
  
  def calculate_edit_matrix(source, target)
    cost_matrix = init_cost_matrix(source.length, target.length)
    i=1
    while i<source.length
      j=1
      while j<target.length
        x = cost_matrix[i-1][j]+1
        y = cost_matrix[i][j-1]+1
        
        if (source[i-1] == target[j-1])
          z = cost_matrix[i-1][j-1]
        else
          z = cost_matrix[i-1][j-1]+1
        end
        cost_matrix[i][j] = [x,y,z].min
        j+=1
      end
      i+=1
    end
    
    cost_matrix[source.size-1][target.size-1]
  end
end