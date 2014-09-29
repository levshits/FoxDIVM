require 'matrix'
require 'mathn'
class Vector
  def /(arg)
    self * (1 / arg)
  end
end
class NoSolutionExeption<Exception
end
class UnlimitedCountOfSolutions<Exception
end
class HoletskyProblem<Exception
end
class LUProblem<Exception
end
class Slae

  def initialize(n)
    @slae = n
  end
  def get_slae(i,j)
    @slae[i][j]
  end
  def get_full_table
    @slae
  end
  def get_size
    @slae.size
  end
  def solve_by_lu
    l_matrix = Array.new(@slae.size){Array.new(@slae.size,0)}
    u_matrix = Array.new(@slae.size){Array.new(@slae.size,0)}
    (0...u_matrix.size).each{|i|
      (0...u_matrix.size).each{|j|
        u_matrix[0][i] = @slae[0][i]
        if u_matrix[0][0]==0
          raise LUProblem
        end
        l_matrix[i][0] = @slae[i][0] / u_matrix[0][0]
        sum = 0
        (0...i).each{|k| sum += l_matrix[i][k] * u_matrix[k][j]}
        u_matrix[i][j] = @slae[i][j] - sum;
        if i<=j
          sum = 0
          (0...i).each{|k| sum += l_matrix[j][k] * u_matrix[k][i]}
          if u_matrix[i][i]==0
            raise LUProblem,"The system can't be solved by LU"
          end
          l_matrix[j][i] = (@slae[j][i]-sum)/u_matrix[i][i]
        end

      }}
    p l_matrix
    p u_matrix
    y = Array.new(@slae.size,0)
    (0...@slae.size).each{|i|
      sum = 0
      (0...i).each{|j| sum+=y[j]*l_matrix[i][j]}
      if l_matrix[i][i]==0
        raise LUProblem,"The system can't be solved by LU"
      end
      y[i] = (@slae[i][-1]-sum)/l_matrix[i][i]
    }
    x = Array.new(@slae.size,0)
    (0...@slae.size).to_a.reverse.each{|i|
      sum = 0
      (i+1...@slae.size).each{|j| sum+=x[j]*u_matrix[i][j]}
      if u_matrix[i][i]==0
        raise LUProblem,"The system can't be solved by LU"
      end
      x[i] = (y[i]-sum)/u_matrix[i][i]
    }
    p y
    p
    return x

  end
  def solve_by_gauss_simple
    (0...@slae.size).each{ |i|
      if @slae[i][i]!=0
        @slae[i] /= @slae[i][i]
        #p @slae
        (i+1...@slae.size).each{ |j| @slae[j] -= @slae[i] * @slae[j][i] }
        #p @slae
      end
    }
    #p @slae
    is_unlimited = false
    p @slae
    (1...@slae.size).to_a.reverse.each{ |i|
      (0...i).each{ |j| @slae[j] -= @slae[i] * @slae[j][i] }
      if @slae[i][i]==0
        if @slae[i][i] == @slae[i][-1]
          is_unlimited = true
        else
          (0...@slae.size).each{|j|
            if @slae[i][j]!=0
              raise UnlimitedCountOfSolutions,"Unlimited count of solutions"
            end}
          raise NoSolutionExeption,"No solution"
        end
      end}
    if is_unlimited
      raise UnlimitedCountOfSolutions,"Unlimited count of solutions"
    end
    x = []
    (0...@slae.size).each{|index|x<<@slae[index][-1]}
    return x
  end
  def solve_by_gauss
    have_empty_string = false
    (0...@slae.size).each{ |i|
      is_empty = true
    (0...@slae.size+1).each{|j| is_empty = is_empty&&(@slae[i][j]==0)}
    if is_empty
      have_empty_string = true
    end}
    have_empty_col = false
      empty_col_number = 0
      (0...@slae.size).each{ |i|
        is_empty = true
        (0...@slae.size).each{|j| is_empty = is_empty&&(@slae[j][i]==0)}
        if is_empty
          have_empty_col = true
          empty_col_number = i
        end}
    message =''
    if have_empty_string && have_empty_col
      raise Exception,"Solution has no depensies from x#{empty_col_number+1}. Please delete empty string from SLAE"
    end
    (0...@slae.size).each{ |i|
      max_index = i
      max_element = @slae[i][i]
      (i...@slae.size).each{|j| if @slae[j][i]>max_element
                                  max_element=@slae[j][i]
                                  max_index = j
                                end}
      if max_index!=i
        temp = @slae[i]
        @slae[i] = @slae[max_index]
        @slae[max_index] = temp
      end
      if @slae[i][i]!=0
       @slae[i] /= @slae[i][i]
       (i+1...@slae.size).each{ |j| @slae[j] -= @slae[i] * @slae[j][i] }
     end
    }
    is_unlimited = false
    is_not_realized = true
    message =''
    result = Array.new(@slae.size,0)
    (0...@slae.size).each{ |i|
      count_of_notzero = 0
      index_of_notzero = 0
      (0...@slae.size).each{|j| if @slae[i][j]!=0
                                    count_of_notzero+=1
                                    index_of_notzero =j
                                end}
      if count_of_notzero == 1
        message += " If x#{index_of_notzero+1}=#{@slae[i][-1]}"
      end}
    p @slae
    (1...@slae.size).to_a.reverse.each{ |i|
      (0...i).each{ |j| @slae[j] -= @slae[i] * @slae[j][i] }}
    p @slae
    (0...@slae.size).to_a.reverse.each{|i|
     if@slae[i][i]==0
       if @slae[i][-1]==0
         is_unlimited = true
         result[i] = 0
       else
         raise NoSolutionExeption,"No solution"
       end
     else
       result[i]=@slae[i][-1]
     end}
    if is_unlimited
      raise Exception,"Unlimited count of solutions"+message
    end
    return result

  end
  def solve_by_holetsky
    (0...@slae.size).each{ |i|
      (i...@slae.size).each { |j|
        if @slae[i][j]!=@slae[j][i].conj
          raise HoletskyProblem,"The system can't be solved by Holetsky"
        end}}
    l_matrix = Array.new(@slae.size){Array.new(@slae.size+1,0)}

    (0...@slae.size).each{|i|
      (0...i).each{ |j|
        temp=0
        (0...j).each{ |k|
          temp+=l_matrix[i][k]*l_matrix[j][k]
        }
        if l_matrix[j][j]==0
          raise HoletskyProblem,"The system can't be solved by Holetsky"
        end
        l_matrix[i][j] = (@slae[i][j] - temp)/l_matrix[j][j]
      }

      temp = @slae[i][i]
      (0...i).each{ |k| temp-=l_matrix[i][k]*l_matrix[i][k]}
      l_matrix[i][i] = Math.sqrt(temp)
    }
    #p l_matrix
    lt_matrix = Array.new(@slae.size){Array.new(@slae.size+1,0)}
    (0...@slae.size).each{ |i| (0...@slae.size).each{|j|
      lt_matrix[i][j] = l_matrix[j][i].conj
      }}
    (0...@slae.size).each{|i| l_matrix[i][-1]=@slae[i][-1]}
    l_matrix  = l_matrix.map{ |array| Vector[*array]}
    begin
      buffer_slae = Slae.new(l_matrix)
      y = buffer_slae.solve_by_gauss_simple
      (0...@slae.size).each{|i| lt_matrix[i][-1] = y[i]}
      lt_matrix  = lt_matrix.map{ |array| Vector[*array]}
      buffer_slae = Slae.new(lt_matrix)
      x = buffer_slae.solve_by_gauss_simple
      rescue Exception
        raise HoletskyProblem,"The system can't be solved by Holetsky"
    end
    return x
  end
end