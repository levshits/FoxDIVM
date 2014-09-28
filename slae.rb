require 'matrix'
require 'mathn'
class Vector
  def /(arg)
    self * (1 / arg)
  end
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
        l_matrix[i][0] = @slae[i][0] / u_matrix[0][0]
        sum = 0
        (0...u_matrix.size).each{|k| sum += l_matrix[i][k] * u_matrix[k][j]}
        u_matrix[i][j] = @slae[i][j] - sum;
        if i<=j
          sum = 0
          (0...i).each{|k| sum += l_matrix[j][k] * u_matrix[k][i]}
          l_matrix[j][i] = (@slae[j][i]-sum)/u_matrix[i][i]
        end

      }}
    p l_matrix
    p u_matrix
    y = Array.new(@slae.size,0)
    (0...@slae.size).each{|i|
      sum = 0
      (0...i).each{|j| sum+=y[j]*l_matrix[i][j]}
      y[i] = (@slae[i][-1]-sum)/l_matrix[i][i]
    }
    x = Array.new(@slae.size,0)
    (0...@slae.size).to_a.reverse.each{|i|
      sum = 0
      (i+1...@slae.size).each{|j| sum+=y[j]*u_matrix[i][j]}
      x[i] = (y[i]-sum)/u_matrix[i][i]
    }
    p y
    p x
    return 1

  end
  def solve_by_gauss
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
              return 1
            end}
          return 2
        end
      end}
    if is_unlimited
      return 1
    end
    3
  end
  def solve_by_holetsky
    (0...@slae.size).each{ |i|
      (i...@slae.size).each { |j|
        if @slae[i][j]!=@slae[j][i]
          return 4
        end}}
    l_matrix = Array.new(@slae.size){Array.new(@slae.size+1,0)}

    (0...@slae.size).each{|i|
      (0...i).each{ |j|
        temp=0
        (0...j).each{ |k|
          temp+=l_matrix[i][k]*l_matrix[j][k]
        }
        if l_matrix[j][j]==0
          return 4
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
      lt_matrix[i][j] = l_matrix[j][i]
      if l_matrix[j][i].is_a?(Complex)
        return 4
      end}}
    (0...@slae.size).each{|i| l_matrix[i][-1]=@slae[i][-1]}
    l_matrix  = l_matrix.map{ |array| Vector[*array]}
    buffer_slae = Slae.new(l_matrix)
    if buffer_slae.solve_by_gauss != 3
      return 4
    end
    (0...@slae.size).each{|i| lt_matrix[i][-1] = buffer_slae.get_slae(i, -1)}
    lt_matrix  = lt_matrix.map{ |array| Vector[*array]}
    buffer_slae = Slae.new(lt_matrix)
    if buffer_slae.solve_by_gauss != 3
      return 4
    end
    @slae = buffer_slae.get_full_table
    3
  end
end