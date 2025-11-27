module InteractiveProgram
  def start
    @buffer = ''
    @current_code = gets.chomp
    if @current_code.empty?
      run_program
    end  
  end

  def run_program
    while true
      begin
        @current_code = gets.chomp
        break if @current_code == 'q'
        evaluate
      rescue SyntaxError => e
        next if e.message =~  /unexpected end-of-input/
      end
    end
  end

  def evaluate
    @buffer << @current_code << ';'
    return_val = eval @buffer, TOPLEVEL_BINDING
    display_return_val(return_val)
    clear_buffer
  end

  def display_return_val(return_val)
    print "#=>"
    puts return_val.inspect
  end

  def clear_buffer
    @buffer.clear
  end
end

Object.include InteractiveProgram
start