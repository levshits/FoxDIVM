require 'fox16'
require_relative 'slae'
include Fox
class Complex
  def round(n)
    re = self.real
    im = self.imaginary
     Complex(re.round(n), im.round(n))
  end
end
class Main < FXMainWindow
  def
  initialize(app)
    super(app, "DIVM", :width => 500, :height => 400)
    add_controls
  end
  def
  create
    super
    show(PLACEMENT_SCREEN)
  end
  private
  def add_controls
      controls_frame = FXHorizontalFrame.new(self,:opts=>LAYOUT_FILL_X)
      FXLabel.new(controls_frame,'Dimension')
      dimensions_edit = FXTextField.new(controls_frame,5 , :opts=>TEXTFIELD_INTEGER)
      enter_button = FXButton.new(controls_frame,'Enter',:opts=>BUTTON_NORMAL)
      enter_button.connect(SEL_COMMAND) do
        enter_button_click(dimensions_edit.text.to_i)
        end
      solve_button = FXButton.new(controls_frame,'Solve',:opts=>BUTTON_NORMAL|LAYOUT_RIGHT)
      method_box = FXComboBox.new(controls_frame,15,:opts=>COMBOBOX_STATIC|FRAME_SUNKEN|FRAME_THICK|LAYOUT_RIGHT)
      method_box.fillItems ['Gauss','Holetsky']
      solve_button.connect(SEL_COMMAND) do
        solve_button_click(method_box.currentItem)
      end
      FXLabel.new(controls_frame,'Method of solving',:opts=>LAYOUT_RIGHT)
      grid_frame = FXHorizontalFrame.new(self,:opts=>LAYOUT_FILL_X|LAYOUT_FILL_Y)
      @grid = FXTable.new(grid_frame,:opts=>LAYOUT_FILL_X|LAYOUT_FILL_Y)
  end
  def enter_button_click(dimensions)
    p "enter" +dimensions.to_s
    @grid.clearItems
    @grid.insertColumns(0,dimensions+2)
    @grid.insertRows(0,dimensions)
    (0...@grid.numRows).each { |i| @grid.setRowText(i,(i+1).to_s+' Equation')}
    (0...@grid.numColumns-2).each { |i| @grid.setColumnText(i,'x'+(i+1).to_s)}
    @grid.setColumnText(dimensions+1,'result')
    @grid.setColumnText(dimensions,'b')

  end
  def solve_button_click(variant)
    if @grid.numColumns != 0
      matrix = Array.new(@grid.numRows){Array.new(@grid.numRows+1,0)}
      (0...@grid.numRows).each{|i|
        (0...@grid.numRows+1).each{|j|
          matrix[i][j] = @grid.getItem(i,j).to_s.to_c}}
      (0...@grid.numRows).each{|i| @grid.setItemText(i,@grid.numRows+1,'')}
      matrix = matrix.map {|array| Vector[*array]}
      slae = Slae.new(matrix)
      result = 0
      case variant
        when(0)
          result = slae.solve_by_gauss
        when(1)
          result = slae.solve_by_holetsky

      end
      p result
      case result
        when(1)
          FXMessageBox.new(self, 'Result','Unlimited count of solutions',:opts=>MBOX_OK).execute
        when(2)
          FXMessageBox.new(self, 'Result','No solution!',:opts=>MBOX_OK).execute
        when(3)
          (0...@grid.numRows).each{|i| @grid.setItemText(i,@grid.numRows+1,slae.get_slae(i,-1).round(3).to_s)}
          FXMessageBox.new(self, 'Result','The system has successfully solved!',:opts=>MBOX_OK).execute
        when(4)
          FXMessageBox.new(self, 'Result',"System can't be solved by Holetsky method!",:opts=>MBOX_OK).execute
      end
    end
  end
end
app = FXApp.new
Main.new(app)
app.create
app.run