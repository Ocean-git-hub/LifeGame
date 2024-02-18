class LifeGame
  def initialize(width = 10, height = 10, random = true)
    @g_board = if random
                 Board.random(width, height)
               else
                 Board.new(width, height)
               end
    @height = height
    @width = width
  end

  def set_board
    input = ' '; x_p = 0; y_p = 0
    loop do
      system('cls')
      puts 'Board edit mode'
      puts 'd: cursor down, u: cusor up, r: cursor right, l: cursor left, f: finish edit mode'
      if input == 'd'
        y_p += 1
      elsif input == 'u'
        y_p -= 1
      elsif input == 'r'
        x_p += 1
      elsif input == 'l'
        x_p -= 1
      elsif input == ''
        @g_board.set_board(x_p, y_p)
      end
      x_p, y_p = prevent_out_of_board(x_p, y_p)
      out_put_board_with_pointer(x_p, y_p)
      puts
      break if (input = gets.chomp) == 'f'
    end
  end

  def auto(time = 1)
    while true
      system('cls')
      out_put_status
      out_put_board
      sleep(time)
      puts
      @g_board.next_generation
    end
  end

  def each_generation
    while true
      system('cls')
      out_put_status
      out_put_board
      gets
      puts
      @g_board.next_generation
    end
  end

  private

  def prevent_out_of_board(x_p, y_p)
    x_p = @width - 1 if x_p.negative?
    x_p = 0 if x_p >= @width
    y_p = @height - 1 if y_p.negative?
    y_p = 0 if y_p >= @height
    [x_p, y_p]
  end

  def out_put_board_with_pointer(x_p, y_p)
    board = ''
    lines = 0
    @g_board.get_board.lines do |line|
      if y_p == lines
        board << line.chomp! + " ←\r\n"
      else
        board << line
      end
      lines += 1
    end
    str = '  ' * x_p + '↑'
    board << str
    print board
  end

  def out_put_status
    puts 'generation:' + @g_board.generation.to_s + '  alive:' + @g_board.alive.to_s + '  death:' + @g_board.death.to_s
  end

  def out_put_board
    print @g_board.get_board
  end

  class Board
    attr_reader :generation, :death, :alive

    def self.random(width, height)
      new(width, height, true)
    end

    def initialize(width, height, random = false, cell = Cell)
      @generation = 1
      @width = width
      @height = height
      @board = Array.new(height).map {Array.new(width)}

      width.times do |i|
        height.times do |j|
          if random
            if rand(2).zero?
              object = cell.alive
              @board[j][i] = object
            else
              object = cell.death
              @board[j][i] = object
            end
          else
            @board[j][i] = cell.new
          end
        end
      end
      calculate_cells
    end

    def next_generation
      @generation += 1
      turn_cell
      calculate_cells
    end

    def get_board
      str = ''
      @board.each do |k|
        k.each do |j|
          if j.life == Cell::ALIVE
            str << '■'
          else
            str << '□'
          end
        end
        str << "\r\n"
      end
      str
    end

    def set_board(x_p, y_p)
      @board[y_p][x_p].turn
    end

    private

    def calculate_cells
      @alive = 0
      @death = 0
      @board.each do |i|
        i.each do |j|
          if j.life == Cell::ALIVE
            @alive += 1
          else
            @death += 1
          end
        end
      end
    end

    def turn_cell
      current_generation = Marshal.load(Marshal.dump(@board))
      @width.times do |i|
        @height.times do |j|
          if current_generation[j][i].life == Cell::DEATH
            @board[j][i].generate if can_generate(current_generation, i, j)
          else
            @board[j][i].kill if can_kill(current_generation, i, j)
          end
        end
      end
    end

    def is_out_board(x, y, pos)
      if x + pos % 3 - 1 < 0 || y + pos / 3 - 1 < 0 || x + pos % 3 - 1 >= @width || y + pos / 3 - 1 >= @height
        true
      else
        false
      end
    end

    def can_kill(board, x, y)
      i = 0
      9.times do |k|
        unless is_out_board(x, y, k)
          i += 1 if k != 4 && board[y + k / 3 - 1][x + k % 3 - 1].life == Cell::ALIVE
        end
      end
      if i <= 1 || i >= 4
        true
      else
        false
      end
    end

    def can_generate(board, x, y)
      i = 0
      9.times do |k|
        unless is_out_board(x, y, k)
          i += 1 if board[y + k / 3 - 1][x + k % 3 - 1].life == Cell::ALIVE && k != 4
        end
      end
      if i == 3
        true
      else
        false
      end
    end
  end

  class Cell
    attr_reader :life
    @life
    ALIVE = 0
    DEATH = 1

    def self.death
      new(DEATH)
    end

    def self.alive
      new(ALIVE)
    end

    def initialize(life = DEATH)
      @life = life
    end

    def turn
      if @life == ALIVE
        kill
      elsif @life == DEATH
        generate
      end
    end

    def kill
      @life = DEATH
    end

    def generate
      @life = ALIVE
    end
  end
end

game = LifeGame.new(90, 40)
game.set_board
game.auto(0.1)
