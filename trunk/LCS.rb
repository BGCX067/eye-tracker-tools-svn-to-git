class String
  def largest_common_subsequence(target)
    if self == target
      return self
    end
    
    m = self.length
    n = target.length
    p = 1 + [m,n].min

    #this matrix will be used to calc the LCS-Matrix
    lcs_mtx = []
    # initialize the 2 dim array to 0
    (0..m).each { || lcs_mtx << Array.new(n+1,0) }
    
    # fill the matrix using dyn programming
    (1..m).each { |i|
      (1..n).each { |j|
          if self[i-1] == target[j-1]
            lcs_mtx[i][j] = lcs_mtx[i-1][j-1] + 1
          elsif lcs_mtx[i-1][j] >= lcs_mtx[i][j-1]
            lcs_mtx[i][j] = lcs_mtx[i-1][j]
          else
            lcs_mtx[i][j] = lcs_mtx[i][j-1]
          end
        }
      }
      
    #backtrac to find one of the possible several largest common sub sequnences
    return backtrack(lcs_mtx, target, m, n)
  end
  
  private
  def backtrack(lcs_mtx, target, i, j)
   if i==0 || j == 0
      return ""
    elsif self[i-1] == target[j-1]
      return backtrack(lcs_mtx, target, i-1, j-1) + self[i-1,1]
    else
      if lcs_mtx[i][j-1] > lcs_mtx[i-1][j]
        return backtrack(lcs_mtx, target, i, j-1)
      else
        return backtrack(lcs_mtx, target, i-1, j)
      end
    end
  end
  
end
