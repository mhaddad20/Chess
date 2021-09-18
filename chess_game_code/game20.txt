require 'ruby2d'

set background: '#FFF3C9' # background color
set height: 600
set width: 800

SQUARE_SIZE=60 # size of the squares on the board
class Game
  def initialize # initialise our variables

    $board_pieces=[[],[],[],[],[],[],[],[]] # the board that will hold all the pieces
    $square_position =[] # positions of each square on the screen
    for a in 0..7
      $board_pieces[0].push('')
      $board_pieces[1].push('') # add black pawns to the second row
      $board_pieces[2].push('')
      $board_pieces[3].push('')
      $board_pieces[4].push('')
      $board_pieces[5].push('')
      $board_pieces[6].push('')# add white pawns to the seventh row
      $board_pieces[7].push('')
    end
    #$board_pieces[7][7]='bb'
    # $board_pieces[7][3]='bb'
    $board_pieces[7][7]='wq'
    $board_pieces[0][6]='bb'

    $board_pieces[7][4]='wK'# white king



    $board_pieces[0][4]='bK'# black king

    $square_chosen=[[],[],[],[],[],[],[],[]] # identify the square chosen by the player(boolean array)
    $valid_moves=[[],[],[],[],[],[],[],[]] # identify which moves are valid for a piece(boolean array)
    $board_colors=['#FFE4BE','#AF6700'] # colors of the the squares on the board
    $en_passant_squares=[] # positions for squares that will have en passant
    $white_king=[] # stores coordinates for the white king
    $black_king=[]# stores coordinates for the black king
    $white_king_moves_into_check=[[],[],[],[],[],[],[],[]]
    $black_king_moves_into_check=[[],[],[],[],[],[],[],[]]
    $color_squares=[[],[],[],[],[],[],[],[]]
    @add_positions=false
    @square_position_x=0 # get the row the square is on
    @square_position_y=0 # get the column the square is on
    @turn=0 # player turn
    @en_passant=false
    @en_passant_white=false
    @en_passant_black=false
    @white_check=false
    @black_check=false
    $white_check=[[],[],[],[],[],[],[],[]] # stores the boolean values for the pieces when the white king is in check
    $black_check=[[],[],[],[],[],[],[],[]]
    $protect_king_array=[] # positions for the pieces that will protect the king
    $moves=[]
    $array=[]
    @moves_available
    @found=false #
    @double_check=0 # number of times the king is checked
    @x_position_king=0 # x coordinates of king
    @y_position_king=0 # y coordinates of king
    @finished=false
    @is_draw=false
    $type_draw=[false,false,false,false,false]#stalemate,perpetual,insufficiency,50-move-rule,agreement
    $perpetual_hash={} # array to hold positions in case the same position occured three times
    $perpetual_hash.default=0
    @num_moves=0
  end

  def draw # draw the board
    y=50
    for a in 0..7
      x=150
      arr=[]
      square_chosen=[]
      valid_moves=[]
      square_under_attack=[]
      square_under_attack2=[]
      white_is_checked=[]
      black_is_checked=[]
      color_of_square=[]
      for b in 0..7
        if @add_positions==false # populate these arrays
          arr.push([x,y])
          square_chosen.push(false)
          valid_moves.push(false)
          square_under_attack.push(false)
          square_under_attack2.push(false)
          white_is_checked.push(false)
          black_is_checked.push(false)
          color_of_square.push((b+a)%2)
        end
        square_color=Square.new(x:x,y:y,color:$board_colors[(b+a)%2],size:SQUARE_SIZE,opacity:0.9) # colors switch every time
        if $board_pieces[a][b]=='wp' # draw the pieces on the board
          Image.new('wp.png',x:x+10,y:y+10)
        elsif $board_pieces[a][b]=='bp'
          Image.new('bp.png',x:x,y:y+5)
        elsif $board_pieces[a][b]=='wb'
          Image.new('white_bishop.png',x:x,y:y)
        elsif $board_pieces[a][b]=='bb'
          Image.new('black_bishop.png',x:x+5,y:y+5)
        elsif $board_pieces[a][b]=='wr'
          Image.new('white_rook.png',x:x+2.5,y:y+7.5)
        elsif $board_pieces[a][b]=='br'
          Image.new('black_rook.png',x:x+2.5,y:y)
        elsif $board_pieces[a][b]=='wk'
          Image.new('white_knight.png',x:x,y:y+2.5)
        elsif $board_pieces[a][b]=='bk'
          Image.new('black_knight.png',x:x,y:y)
        elsif $board_pieces[a][b]=='wq'
          Image.new('white_queen.png',x:x,y:y)
        elsif $board_pieces[a][b]=='bq'
          Image.new('black_queen.png',x:x+2.5,y:y+2.5)
        elsif $board_pieces[a][b]=='wK'
          Image.new('white_king.png',x:x,y:y+2.5)
        elsif $board_pieces[a][b]=='bK'
          Image.new('black_king.png',x:x+2.5,y:y+2.5)
        end
        x+=60
      end
      if @add_positions==false # stop adding to these arrays after the first push
        $square_position.push(arr) # holds the position of each square on the screen
        $square_chosen[a]=square_chosen # detect if square is chosen by player
        $valid_moves[a]=valid_moves  # show valid moves for player
        $white_king_moves_into_check[a]=square_under_attack
        $black_king_moves_into_check[a]=square_under_attack2
        $white_check[a]=white_is_checked
        $black_check[a]=black_is_checked
        $color_squares[a]=color_of_square
      end
      y+=60
    end
    @add_positions=true
    insufficient_material
    threefold_repetition
    fifty_move_rule

    if @finished==false
      if @white_check && $type_draw[1]==false
        Text.new("Check!",x:Window.width/100*40,y:Window.height/100*2.5,color:'red')
      elsif @black_check && $type_draw[1]==false
        Text.new("Check!",x:Window.width/100*40,y:Window.height/100*2.5,color:'red')
      end
    end
    if finished?
      game_over_text
    elsif is_draw?
      type_of_draw
    end
  end
  def game_over_text
    @turn%2==0 ? winner='Black' : winner='White'
    Text.new("Checkmate! #{winner} wins! Press R to Play Again",x:Window.width/100*20,y:Window.height/100,color:'red')
  end
  def game_finish
    @finished=true
  end
  def finished?
    @finished
  end
  def end_game_draw
    @is_draw=true
  end
  def is_draw?
    @is_draw
  end
  def insufficient_material
    end_by_draw=false
    board=[]
    knight_bishop=['wb','wk','bk','bb']
    pieces=['wp','wb','wr','wk','wq','bp','bb','br','bk','bq','bK','wK']
    for a in 0..7
      for b in 0..7
        if pieces.include?($board_pieces[a][b])
          board.push($board_pieces[a][b])
        end
      end
    end
    if end_by_draw==false
      board.size > 2 ? end_by_draw=false : end_by_draw=true
    end
    if end_by_draw==false
      if board.size==3
        board.each do |x|
          if x != 'wK' || x != 'bK'
            knight_bishop.include?(x) ? end_by_draw=true : end_by_draw=false
          end
        end
      end
    end
    if end_by_draw==false
      if board.size==4
        board= board-['wK','bK'].sort
        if board[0]=='bb' &&board[1]=='wb'
          index_bb= $board_pieces.flatten.index("bb")
          index_wb= $board_pieces.flatten.index("wb")
          $color_squares.flatten[index_bb]== $color_squares.flatten[index_wb] ? end_by_draw=true : end_by_draw=false
        end
      end
    end
    if end_by_draw
      $type_draw[2] = true
      end_game_draw
    end
  end
  def threefold_repetition
    if $perpetual_hash[$board_pieces]>=3
      $type_draw[1]=true
      end_game_draw
    end
  end
  def fifty_move_rule
    if @num_moves>=100
      $type_draw[3]=true
      end_game_draw
    end
  end
  def type_of_draw
    for a in 0..3
      if $type_draw[a]
        case a
        when 1
          if @white_check || @black_check
            Text.new("Draw by Perpetual check! Press R to Play Again",x:Window.width/100*20,y:Window.height/100,color:'red')
          else
            Text.new("Draw by Threefold repetition! Press R to Play Again",x:Window.width/100*20,y:Window.height/100,color:'red')
          end
        when 2
          Text.new("Draw by insufficient material! Press R to Play Again",x:Window.width/100*20,y:Window.height/100,color:'red')
        when 3
          Text.new("Draw by 50-move-rule! Press R to Play Again",x:Window.width/100*20,y:Window.height/100,color:'red')
        end
      end
    end
  end
  def check_moves # available moves to protect the king
    if $valid_moves.flatten.any?{|x|x==true}
      @moves_available=true
    end
  end

  def first_move_pawn_white?(row,col) # if the white pawn hasn't moved yet
    row==6 && $board_pieces[row][col]=='wp' ? true :false
  end
  def first_move_pawn_black?(row,col) # if the black pawn hasn't moved yet
    row==1 && $board_pieces[row][col]=='bp' ? true :false
  end

  def first_pawn_move(row,col) # discovers which pawn hasn't moved yet
    row==6 && $board_pieces[row][col]=='wp' ?first_move_pawn_white?(row,col) : first_move_pawn_black?(row,col)
  end

  def valid_moves(row,col) # show valid moves for these pieces
    if $board_pieces[row][col]=='wp' # if the player selects the white pawn
      pawn_move('wp',row,col)
    elsif $board_pieces[row][col]=='bp' # if the player selects the black pawn
      pawn_move('bp',row,col)
    elsif $board_pieces[row][col]=='bb'#if player selects the black bishop
      bishop_top_left('bb',row,col)
      bishop_top_right('bb',row,col)
      bishop_bottom_right('bb',row,col)
      bishop_bottom_left('bb',row,col)
    elsif $board_pieces[row][col]=='wb'#if player selects the white bishop
      bishop_top_left('wb',row,col)
      bishop_top_right('wb',row,col)
      bishop_bottom_right('wb',row,col)
      bishop_bottom_left('wb',row,col)
    elsif $board_pieces[row][col]=='wr' # valid moves for the white rook
      rook_forward('wr',row,col)
      rook_right('wr',row,col)
      rook_back('wr',row,col)
      rook_left('wr',row,col)
    elsif $board_pieces[row][col]=='br' # valid moves for the black rook
      rook_forward('br',row,col)
      rook_right('br',row,col)
      rook_back('br',row,col)
      rook_left('br',row,col)
    elsif $board_pieces[row][col]=='wk' # moves for the white knight
      knight_move('wk',row,col)
    elsif $board_pieces[row][col]=='bk' # moves for the black knight
      knight_move('bk',row,col)
    elsif $board_pieces[row][col]=='wq' # moves for the white queen
      queen_move('wq',row,col)
    elsif $board_pieces[row][col]=='bq' # moves for the black queen
      queen_move('bq',row,col)
    elsif $board_pieces[row][col]=='wK' # moves for the white king
      king_move('wK',row,col)
    elsif $board_pieces[row][col]=='bK' # moves for the black king
      king_move('bK',row,col)
    end
  end
  #color piece means which color was chosen
  # color is true for white and false for black
  def pawn_move(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    pawn_square=1 # 1 square ahead of the pawn
    pawn_square2=2 # 2 squares ahead of the pawn
    enemy_piece='bp' # the opposite piece
    if color==false # if the color is black
      pawn_square*=-1
      pawn_square2*=-1
      enemy_piece='wp'
    end
    if first_pawn_move(row,col)#detect which color pawn the player selects and if that pawn has a first move or not
      if $board_pieces[row-pawn_square2][col]==''&&$board_pieces[row-pawn_square][col]==''# advance two squares
        protect_king(row-pawn_square2,col,row,col,color)
        protect_king(row-pawn_square,col,row,col,color)

      elsif $board_pieces[row-pawn_square][col]!=nil && $board_pieces[row-pawn_square][col]==''# advance one square
        protect_king(row-pawn_square,col,row,col,color)
      end
    elsif $board_pieces[row-pawn_square][col]!=nil && $board_pieces[row-pawn_square][col]==''# advance one square
      protect_king(row-pawn_square,col,row,col,color)
    end
    if col==7 # pawn does not go out of bounds when attacking diagonally
      piece_capture(color,row-pawn_square,col-1,row,col)
      if (row==4||row==3)&&@en_passant # en passant rules for the last column
        if $board_pieces[row][col-1]==enemy_piece
          if $en_passant_squares[0]==col-1
            $valid_moves[row-pawn_square][col-1]=true
          end
        end
      end

    elsif col==0 # pawn does not go out of bounds when attacking diagonally
      piece_capture(color,row-pawn_square,col+1,row,col)
      if (row==4||row==3)&&@en_passant # en passant rules for the first column
        if $board_pieces[row][col+1]==enemy_piece
          if $en_passant_squares[0]==col+1
            $valid_moves[row-pawn_square][col+1]=true
          end
        end
      end
    elsif piece_capture(color,row-pawn_square,col+1,row,col)||piece_capture(color,row-pawn_square,col-1,row,col)#pieces to attack diagonally if there are any
      if piece_capture(color,row-pawn_square,col+1,row,col) &&piece_capture(color,row-pawn_square,col-1,row,col)
        piece_capture(color,row-pawn_square,col+1,row,col)
        piece_capture(color,row-pawn_square,col-1,row,col)

      elsif piece_capture(color,row-pawn_square,col+1,row,col)
        piece_capture(color,row-pawn_square,col+1,row,col)
      elsif piece_capture(color,row-pawn_square,col-1,row,col)
        piece_capture(color,row-pawn_square,col-1,row,col)
      end
    elsif col>=1 && col<=6 # en passant rules for column numbers between 2 and 7
      if (row==4||row==3)&&@en_passant
        if $board_pieces[row][col+1]==enemy_piece
          if $en_passant_squares[0]==col+1
            $valid_moves[row-pawn_square][col+1]=true
          end
        end
        if $board_pieces[row][col-1]==enemy_piece
          if $en_passant_squares[0]==col-1
            $valid_moves[row-pawn_square][col-1]=true
          end
        end
      end
    end
  end
  def knight_positions(row,col,num) # possible positions for the knight
    if row-num*2>=0 && col-num>=0 && row-num*2<=7 && col-num<=7
      $array_positions.push([row-num*2,col-num])
    end
    if row-num>=0 && col-num*2>=0 && row-num<=7 && col-num*2<=7
      $array_positions.push([row-num,col-num*2])
    end
    if row-num*2<=7 && col+num <=7 && row-num*2>=0 && col+num>=0
      $array_positions.push([row-num*2,col+num])
    end
    if row-num<=7 && col+num*2<=7 && row-num>=0 && col+num*2>=0
      $array_positions.push([row-num,col+num*2])
    end
  end
  def knight_move(color_piece,row,col) # moving the knight
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    $array_positions=[]
    knight_positions(row,col,1)
    knight_positions(row,col,-1)
    $array_positions.each do |x|
      if $board_pieces[x[0]][x[1]]==''
        protect_king(x[0],x[1],row,col,color)
      else
        if piece_capture(color,x[0],x[1],row,col)
          protect_king(x[0],x[1],row,col,color)
        end
      end
    end
  end
  def queen_move(color_piece,row,col) # move the queen, same logic as bishop and rook
    rook_forward(color_piece,row,col)
    rook_left(color_piece,row,col)
    rook_right(color_piece,row,col)
    rook_back(color_piece,row,col)
    bishop_bottom_left(color_piece,row,col)
    bishop_bottom_right(color_piece,row,col)
    bishop_top_right(color_piece,row,col)
    bishop_top_left(color_piece,row,col)
  end


  def piece_capture_king(color,curr_row,curr_col)
    if color # if white, attack the black pieces and vice versa
      if black_pieces(curr_row,curr_col)
        $valid_moves[curr_row][curr_col]=true
      end
    else
      if white_pieces(curr_row,curr_col)
        $valid_moves[curr_row][curr_col]=true
      end
    end
  end

  def color_king_moves_into_check(color,row,col)
    color==true ? $black_king_moves_into_check[row][col]=true : $white_king_moves_into_check[row][col]=true
  end
  def square_under_attack(row,col)
    if $white_king_moves_into_check[row][col]==false&&$black_king_moves_into_check[row][col]==false
      $valid_moves[row][col]=true
    end
  end

  def capture_piece_safely(color,row,col)
    if $white_king_moves_into_check[row][col]==false&&$black_king_moves_into_check[row][col]==false
      piece_capture_king(color,row,col)
    end
  end
  def king_move(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    col_above = col-1
    col_below=col-1
    if row!=0 # move king forward
      for a in 0..2
        if col_above>=0 && col_above<=7
          if $board_pieces[row-1][col_above]==''
            square_under_attack(row-1,col_above)
          else
            capture_piece_safely(color,row-1,col_above)#pk
          end
        end
        col_above+=1
      end
    end
    if row!=7 # move king back
      for a in 0..2
        if col_below>=0 && col_below<=7
          if $board_pieces[row+1][col_below]==''
            square_under_attack(row+1,col_below)
          else
            capture_piece_safely(color,row+1,col_below)
          end
        end
        col_below+=1
      end
    end
    column = col-1
    for a in 0..2 # move king left or right
      if column>=0 && column<=7
        if $board_pieces[row][column]==''
          square_under_attack(row,column)
        else
          capture_piece_safely(color,row,column)
        end
      end
      column+=1
    end
  end

  def checked_squares(color_piece,row,col)
    if color_piece=='wr' || color_piece=='br'
      rook_forward_could_check(color_piece,row,col)
      rook_back_could_check(color_piece,row,col)
      rook_left_could_check(color_piece,row,col)
      rook_right_could_check(color_piece,row,col)
    elsif color_piece=='bb' || color_piece=='wb'
      bishop_bottom_left_could_check(color_piece,row,col)
      bishop_bottom_right_could_check(color_piece,row,col)
      bishop_top_left_could_check(color_piece,row,col)
      bishop_top_right_could_check(color_piece,row,col)
    elsif color_piece=='wq' || color_piece=='bq'
      bishop_bottom_left_could_check(color_piece,row,col)
      bishop_bottom_right_could_check(color_piece,row,col)
      bishop_top_left_could_check(color_piece,row,col)
      bishop_top_right_could_check(color_piece,row,col)
      rook_forward_could_check(color_piece,row,col)
      rook_back_could_check(color_piece,row,col)
      rook_left_could_check(color_piece,row,col)
      rook_right_could_check(color_piece,row,col)
    elsif color_piece=='wk' || color_piece=='bk'
      knight_move_check(color_piece,row,col)
    elsif color_piece=='wp' || color_piece=='bp'
      pawn_move_could_check(color_piece,row,col)
    elsif color_piece=='wK' || color_piece=='bK'
      king_move_check(color_piece,row,col)
    end
  end
  def king_retreat?(color,row,col)
    return true if ($board_pieces[row][col]!='wK' && color)||($board_pieces[row][col]!='bK' && color==false)
    false
  end
  def pawn_move_could_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    pawn_square=1 # 1 square ahead of the pawn
    pawn_square2=2 # 2 squares ahead of the pawn
    enemy_piece='bp' # the opposite piece
    if color==false # if the color is black
      pawn_square*=-1
      pawn_square2*=-1
      enemy_piece='wp'
    end
    if col==7 # pawn does not go out of bounds when attacking diagonally
      if piece_capture(color,row-pawn_square,col-1,row,col)
        color_king_moves_into_check(color,row-pawn_square,col-1)
      end
    elsif col==0 # pawn does not go out of bounds when attacking diagonally
      color_king_moves_into_check(color,row-pawn_square,col+1)
    elsif col>=1 &&col <=7
      color_king_moves_into_check(color,row-pawn_square,col+1)
      color_king_moves_into_check(color,row-pawn_square,col-1)
    end
  end
  def king_move_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    col_above = col-1
    col_below=col-1
    if row!=0 # move king forward
      for a in 0..2
        if col_above>=0 && col_above<=7
          if $board_pieces[row-1][col_above]==''
            color_king_moves_into_check(color,row-1,col_above)
          else
            color_king_moves_into_check(color,row-1,col_above)
          end
        end
        col_above+=1
      end
    end
    if row!=7 # move king back
      for a in 0..2
        if col_below>=0 && col_below<=7
          if $board_pieces[row+1][col_below]==''
            color_king_moves_into_check(color,row+1,col_below)
          else
            color_king_moves_into_check(color,row+1,col_below)
          end
        end
        col_below+=1
      end
    end
    column = col-1
    for a in 0..2 # move king left or right
      if column>=0 && column<=7
        if $board_pieces[row][column]==''
          color_king_moves_into_check(color,row,column)
        else
          color_king_moves_into_check(color,row,column)
        end
      end
      column+=1
    end
  end
  def knight_move_check(color_piece,row,col) # moving the knight
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    $array_positions=[]
    knight_positions(row,col,1)
    knight_positions(row,col,-1)
    $array_positions.each do |x|
      if $board_pieces[x[0]][x[1]]==''
        color_king_moves_into_check(color,x[0],x[1])
      else
        color_king_moves_into_check(color,x[0],x[1])
      end
    end
  end
  def bishop_top_left_could_check(color_piece,row,col)
    color=true
    color_piece[0]=='b' ? color=true : color=false
    curr_row =row-1
    curr_col=col-1
    if row!=0
      until curr_col<0||curr_row<0 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row-=1
        curr_col-=1
      end
    end
  end
  def bishop_top_right_could_check(color_piece,row,col)
    color=true
    color_piece[0]=='b' ? color=true : color=false
    curr_row =row-1
    curr_col=col+1
    if row!=0
      until curr_col>7||curr_row<0 #all possible top right bishop squares
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row-=1
        curr_col+=1
      end
    end
  end
  def bishop_bottom_left_could_check(color_piece,row,col)
    color=true
    color_piece[0]=='b' ? color=true : color=false
    curr_row =row+1
    curr_col=col-1
    if row!=7
      until curr_col<0||curr_row>7 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row+=1
        curr_col-=1
      end
    end
  end
  def bishop_bottom_right_could_check(color_piece,row,col)
    color=true
    color_piece[0]=='b' ? color=true : color=false
    curr_row =row+1
    curr_col=col+1
    if row!=7
      until curr_col>7||curr_row>7 #all possible bottom right bishop squares
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row+=1
        curr_col+=1
      end
    end
  end

  def rook_forward_could_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='b' ? color=true : color=false #true for white, false for black
    curr_row=row-1
    curr_col=col
    if row!=0
      until curr_row<0 # let the rook advance forward
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row-=1
      end
    end
  end
  def rook_right_could_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='b' ? color=true : color=false #true for white, false for black
    curr_row=row
    curr_col=col+1
    if col!=7
      until curr_col>7 # let the rook advance to the right
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_col+=1
      end
    end
  end
  def rook_back_could_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='b' ? color=true : color=false #true for white, false for black
    curr_row=row+1
    curr_col=col
    if row!=7
      until curr_row>7 # let the rook move back
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_row+=1
      end
    end
  end
  def rook_left_could_check(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='b' ? color=true : color=false #true for white, false for black
    curr_row=row
    curr_col=col-1
    if col!=0
      until curr_col<0 # let the rook move left
        if $board_pieces[curr_row][curr_col]==''
          color_king_moves_into_check(color,curr_row,curr_col)
        else
          color_king_moves_into_check(color,curr_row,curr_col)
          if king_retreat?(color,curr_row,curr_col)
            break
          end
        end
        curr_col-=1
      end
    end
  end


  def rook_forward(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    curr_row=row-1
    curr_col=col
    if row!=0
      until curr_row<0 # let the rook advance forward
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row-=1
      end
    end
  end
  def rook_right(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    curr_row=row
    curr_col=col+1
    if col!=7
      until curr_col>7 # let the rook advance to the right
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_col+=1
      end
    end
  end
  def rook_back(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    curr_row=row+1
    curr_col=col
    if row!=7
      until curr_row>7 # let the rook move back
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row+=1
      end
    end
  end
  def rook_left(color_piece,row,col)
    color=true #true for white, false for black
    color_piece[0]=='w' ? color=true : color=false #true for white, false for black
    curr_row=row
    curr_col=col-1
    if col!=0
      until curr_col<0 # let the rook move left
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_col-=1
      end
    end
  end

  def bishop_top_left(color_piece,row,col)
    color=true
    color_piece[0]=='w' ? color=true : color=false
    curr_row =row-1
    curr_col=col-1
    if row!=0
      until curr_col<0||curr_row<0 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row-=1
        curr_col-=1
      end
    end
  end
  def bishop_top_right(color_piece,row,col)
    color=true
    color_piece[0]=='w' ? color=true : color=false
    curr_row =row-1
    curr_col=col+1
    if row!=0
      until curr_col>7||curr_row<0 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row-=1
        curr_col+=1
    end
  end
  end
  def bishop_bottom_left(color_piece,row,col)
    color=true
    color_piece[0]=='w' ? color=true : color=false
    curr_row =row+1
    curr_col=col-1
    if row!=7
      until curr_col<0||curr_row>7 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row+=1
        curr_col-=1
      end
    end
  end
  def bishop_bottom_right(color_piece,row,col)
    color=true
    color_piece[0]=='w' ? color=true : color=false
    curr_row =row+1
    curr_col=col+1
    if row!=7
      until curr_col>7||curr_row>7 #all possible top left bishop squares
        if $board_pieces[curr_row][curr_col]==''
          protect_king(curr_row,curr_col,row,col,color)
        else
          piece_capture(color,curr_row,curr_col,row,col)
          break
        end
        curr_row+=1
        curr_col+=1
      end
    end
  end
  def position_king(color) # get the position of the king
    position_white_king
    position_black_king
    if color
      @x_position_king=$white_king[0]
      @y_position_king=$white_king[1]
    else
      @x_position_king=$black_king[0]
      @y_position_king=$black_king[1]
    end
  end

  def is_check_top_left(color) # check if the a piece that is defending the king is attacked by another piece
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king-1
    col=@y_position_king-1
    until row<0 || col <0
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'b' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row-=1
      col-=1
    end
    false
  end
  def is_check_top_right(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king-1
    col=@y_position_king+1
    until row<0 || col >7
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'b' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row-=1
      col+=1
    end
    false
  end
  def is_check_bottom_left(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king+1
    col=@y_position_king-1
    until row>7 || col <0
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'b' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row+=1
      col-=1
    end
    false
  end
  def is_check_bottom_right(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king+1
    col=@y_position_king+1
    until row>7 || col >7
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'b' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row+=1
      col+=1
    end
    false
  end
  def is_check_up(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king-1
    col=@y_position_king
    until row<0
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'r' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row-=1
    end
    false
  end
  def is_check_down(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king+1
    col=@y_position_king
    until row>7
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'r' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      row+=1
    end
    false
  end
  def is_check_left(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king
    col=@y_position_king-1
    until col<0
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'r' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      col-=1
    end
    false
  end
  def is_check_right(color)
    position_king(color)
    color ? enemy='b' : enemy='w'
    row=@x_position_king
    col=@y_position_king+1
    until col>7
      if $board_pieces[row][col]!=''
        if $board_pieces[row][col]==enemy+'r' ||$board_pieces[row][col]==enemy+'q'
          return true
        else
          return false
        end
      end
      col+=1
    end
    false
  end
  def valid_check_moves(row,col,row_piece,col_piece,color)
    piece = $board_pieces[row_piece][col_piece] # piece on the current square
    piece2 = $board_pieces[row][col] # piece that will be placed on another square
    $board_pieces[row][col]=piece
    $board_pieces[row_piece][col_piece]=''
    if is_check_top_left(color)||is_check_top_right(color)||is_check_bottom_left(color)||is_check_bottom_right(color) ||
      is_check_up(color)||is_check_down(color)||is_check_left(color)||is_check_right(color)
      $valid_moves[row][col]=false
    else
      $valid_moves[row][col]=true
    end
    $board_pieces[row_piece][col_piece]=piece
    $board_pieces[row][col]=piece2
  end
  def protect_king(row,col,row_piece,col_piece,color) # calculate the valid moves for each piece
    """
  'row_piece' is current square
  'row' is piece that will be placed on the board
  'color' = white or black
  """
    if @white_check # valid moves if white king is in check
      if $white_check[row][col]
        $valid_moves[row][col]=true
      end
    elsif @black_check # valid moves if black king is in check
      if $black_check[row][col]
        $valid_moves[row][col]=true
      end
    else
      if color # place the piece on another square and find out if there is a check before adding some valid moves
        valid_check_moves(row,col,row_piece,col_piece,color)
      else
        valid_check_moves(row,col,row_piece,col_piece,color)
      end
    end
  end

  def piece_capture(color,curr_row,curr_col,row,col) # shows which color pieces are valid to attack
    if color # if white, attack the black pieces and vice versa
      if black_pieces(curr_row,curr_col)
        protect_king(curr_row,curr_col,row,col,color)
      end
    else
      if white_pieces(curr_row,curr_col)
        protect_king(curr_row,curr_col,row,col,color)
      end
    end
  end


  def black_pieces(row,col)# pieces that white can attack
    pieces = ['bp','bb','br','bk','bq','bK']
    pieces.include?($board_pieces[row][col])
  end

  def white_pieces(row,col) # pieces that black can attack
    pieces=['wp','wb','wr','wk','wq','wK']
    pieces.include?($board_pieces[row][col])
  end

  def position_white_king # get position of the white king
    for a in 0..7
      for b in 0..7
        if $board_pieces[a][b]=='wK'
          $white_king=[a,b]
        end
      end
    end
  end

  def position_black_king# get position of the black king
    for a in 0..7
      for b in 0..7
        if $board_pieces[a][b]=='bK'
          $black_king=[a,b]
        end
      end
    end
  end


  def select_square # highlights a square when selected by the player
    for row in 0..7
      for col in 0..7
        arr= $square_position[row][col]
        if $square_chosen[row][col]==true
          Square.new(x:arr[0],y:arr[1],color:'yellow',size:SQUARE_SIZE,opacity:0.1)
          #valid_moves(row,col)
          for valid_moves_row in 0..7
            for valid_moves_col in 0..7
              if $valid_moves[valid_moves_row][valid_moves_col]
                arr=$square_position[valid_moves_row][valid_moves_col]
                Square.new(x:arr[0],y:arr[1],color:'#DC3200',size:SQUARE_SIZE,opacity:0.4)
              end
            end
          end
        end
      end
    end
  end

  def select_square_false # stop showing highlighted squares
    for row in 0..7
      for col in 0..7
        $square_chosen[row][col]=false
      end
    end
  end

  def valid_moves_false # stops showing valid moves
    for row in 0..7
      for col in 0..7
        $valid_moves[row][col]=false
      end
    end
  end

  def current_piece?(row,col)# detects if any piece has been chosen
    white_pieces_array=['wp','wb','wk','wr','wq','wK']
    black_pieces_array=['br','bp','bb','bk','bq','bK']
    if @turn%2==0
      return true if white_pieces_array.include?($board_pieces[row][col])
    elsif @turn%2==1
      return true if black_pieces_array.include?($board_pieces[row][col])
    end
    false
  end

  def square_chosen_twice # count the number of squares chosen by the player
    count=0
    $square_chosen.each do |x|
      x.each {|y| y==true ? count+=1 :count+=0}
    end
    count
  end

  def square_chosen_index # get the location of the square chosen by the player
    for a in 0..7
      for b in 0..7
        if $square_chosen[a][b]
          @square_position_x=a
          @square_position_y=b
        end
      end
    end
  end

  def square_chosen_index_capturing(row,col) # get the previous location of the square chosen by the player for the purpose of capturing
    for a in 0..7
      for b in 0..7
        if a!=row && b!=col
          if $square_chosen[a][b]
            @square_position_x=a
            @square_position_y=b
          end
        end
      end
    end
  end

  def can_be_captured(row,col) # verify if these pieces can be captured
    pieces =  ["wp","wb","wk","wr","wq","br","bb","bk","bq"]
    return true if pieces.include?($board_pieces[row][col])&& $valid_moves[row][col]
    false
  end
  def pawn_in_eighth_rank?(row,col) # verify if pawn is in the eighth rank
    if $board_pieces[row][col]=='wp'
      return true if row==0
    elsif $board_pieces[row][col]=='bp'
      return true if row==7
    end
    false
  end
  def pawn_promotion(row,col)#promote the pawn to a queen if in the eighth rank
    if pawn_in_eighth_rank?(row,col)
      $board_pieces[row][col]=='wp' ? $board_pieces[row][col]='wq' : $board_pieces[row][col]='bq'
    end
  end

  def verify_white_passant?(row,col) #check if white can move two squares
    if row==6
      return true if $board_pieces[row][col]=='wp' && $board_pieces[row-1][col]==''&& $board_pieces[row-2][col]==''
    end
    false
  end

  def verify_black_passant?(row,col)#check if black can move two squares
    if row==1
      return true if $board_pieces[row][col]=='bp' && $board_pieces[row+1][col]==''&& $board_pieces[row+2][col]==''
    end
    false
  end

  def reset_squares
    select_square_false # hide highlighted squares
    valid_moves_false# hide valid moves
  end

  def king_avoid_square # squares the king cannot go to
    pieces=[]
    @turn%2==0 ? pieces=["bb","br","bq","bk","bp","bK"] : pieces=["wb","wr","wq","wk","wp","wK"]
    for i in 0..7
      for j in 0..7
        if pieces.include?$board_pieces[i][j]
          checked_squares($board_pieces[i][j],i,j)#
        end
      end
    end
  end

  def defend_squares(found,color) # possible squares to defend the king from an attack
    if found
      $protect_king_array.each do |x|
        if color=='w'
          $white_check[x[0]][x[1]]=true
        else
          $black_check[x[0]][x[1]]=true
        end
      end
    else
      $protect_king_array=[]
    end
    @found=false
  end
  def bishop_bl(curr_row,curr_col,piece,color) # use the bishop to protect the king from a check
    until curr_col>7||curr_row<0 #all possible top left bishop squares
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row-=1
      curr_col+=1
    end
    defend_squares(@found,color)
  end # bishop attacking bottom-left from the king
  def bishop_br(curr_row,curr_col,piece,color)
    until curr_row<0 || curr_col<0
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row-=1
      curr_col-=1
    end
    defend_squares(@found,color)
  end
  def bishop_tl(curr_row,curr_col,piece,color)
    until curr_row>7 || curr_col>7
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row+=1
      curr_col+=1
    end
    defend_squares(@found,color)
  end
  def bishop_tr(curr_row,curr_col,piece,color)
    until curr_row>7 || curr_col<0
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row+=1
      curr_col-=1
    end
    defend_squares(@found,color)
  end
  def rook_f(curr_row,curr_col,piece,color)
    until curr_row<0
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row-=1
    end
    defend_squares(@found,color)
  end
  def rook_b(curr_row,curr_col,piece,color)
    until curr_row>7
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_row+=1
    end
    defend_squares(@found,color)
  end
  def rook_l(curr_row,curr_col,piece,color)
    until curr_col<0
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_col-=1
    end
    defend_squares(@found,color)
  end
  def rook_r(curr_row,curr_col,piece,color)
    until curr_col>7
      $protect_king_array.push([curr_row,curr_col])
      if $board_pieces[curr_row][curr_col]==piece
        $protect_king_array.push([curr_row,curr_col])
        @found=true
        break
      end
      curr_col+=1
    end
    defend_squares(@found,color)
  end
  def pawn_attack_white(curr_row,curr_col,piece,color) # pawn will protect the king from check
    p_square_row= curr_row+1
    p_square_col1= curr_col-1
    p_square_col2= curr_col+1
    if p_square_row>=0 && p_square_row<=6
      if p_square_col1>=0 &&p_square_col1<=6
        if $board_pieces[p_square_row][p_square_col1]==piece
          $protect_king_array.push([p_square_row,p_square_col1])
          @found=true
        end
      end
    end

    if p_square_row>=0 && p_square_row<=6
      if p_square_col2>=1 && p_square_col2<=7
        if $board_pieces[p_square_row][p_square_col2]==piece
          $protect_king_array.push([p_square_row,p_square_col2])
          @found=true
          defend_squares(@found,color)
        end
      end
    end
    defend_squares(@found,color)
  end
  def pawn_attack_black(curr_row,curr_col,piece,color)
    p_square_row= curr_row-1
    p_square_col1= curr_col-1
    p_square_col2= curr_col+1
    if p_square_row>=0 && p_square_row<=6
      if p_square_col1>=0 &&p_square_col1<=6
        if $board_pieces[p_square_row][p_square_col1]==piece
          $protect_king_array.push([p_square_row,p_square_col1])
          @found=true
        end
      end
    end

    if p_square_row>=0 && p_square_row<=6
      if p_square_col2>=1 && p_square_col2<=7
        if $board_pieces[p_square_row][p_square_col2]==piece
          $protect_king_array.push([p_square_row,p_square_col2])
          @found=true
          defend_squares(@found,color)
        end
      end
    end
    defend_squares(@found,color)
  end
  def knight_attack(curr_row,curr_col,piece,color)
    $array_positions=[]
    knight_positions(curr_row,curr_col,1)
    knight_positions(curr_row,curr_col,-1)
    $array_positions.each do |x|
      if $board_pieces[x[0]][x[1]]==piece
        $protect_king_array.push([x[0],x[1]])
        @found=true
        break
      end
    end
    defend_squares(@found,color)
  end

  def white_king_check(piece) # put all valid moves into an array when the king is in check
    position_white_king
    x=$white_king[0]
    y=$white_king[1]
    for a in 0..7
      for b in 0..7
        if $valid_moves[a][b]
          if a==x&&b==y
            @white_check=true
            @double_check+=1
            if @double_check==2
              falsek
              break
            end
            curr_row=x
            curr_col=y
            color='w'
            $protect_king_array=[]
            @found = false
            if piece=='bb'
              bishop_br(curr_row,curr_col,piece,color)
              bishop_bl(curr_row,curr_col,piece,color)
              bishop_tl(curr_row,curr_col,piece,color)
              bishop_tr(curr_row,curr_col,piece,color)
            elsif piece=='br'
              rook_f(curr_row,curr_col,piece,color)
              rook_b(curr_row,curr_col,piece,color)
              rook_l(curr_row,curr_col,piece,color)
              rook_r(curr_row,curr_col,piece,color)
            elsif piece=='bq'
              bishop_br(curr_row,curr_col,piece,color)
              bishop_bl(curr_row,curr_col,piece,color)
              bishop_tl(curr_row,curr_col,piece,color)
              bishop_tr(curr_row,curr_col,piece,color)
              rook_f(curr_row,curr_col,piece,color)
              rook_b(curr_row,curr_col,piece,color)
              rook_l(curr_row,curr_col,piece,color)
              rook_r(curr_row,curr_col,piece,color)
            elsif piece=='bp'
              pawn_attack_black(curr_row,curr_col,piece,color)
            elsif piece=='bk'
              knight_attack(curr_row,curr_col,piece,color)
            end
          end
        end
      end
    end
  end
  def black_king_check(piece)# put all valid moves into an array when the king is in check
    position_black_king
    x=$black_king[0]
    y=$black_king[1]
    for a in 0..7
      for b in 0..7
        if $valid_moves[a][b]
          if a==x&&b==y
            @black_check=true
            @double_check+=1
            if @double_check==2
              falsek
              break
            end
            curr_row=x
            curr_col=y
            color='b'
            $protect_king_array=[]
            @found = false
            if piece=='wb'
              bishop_br(curr_row,curr_col,piece,color)
              bishop_bl(curr_row,curr_col,piece,color)
              bishop_tl(curr_row,curr_col,piece,color)
              bishop_tr(curr_row,curr_col,piece,color)
            elsif piece=='wr'
              rook_f(curr_row,curr_col,piece,color)
              rook_b(curr_row,curr_col,piece,color)
              rook_l(curr_row,curr_col,piece,color)
              rook_r(curr_row,curr_col,piece,color)
            elsif piece=='wq'
              bishop_br(curr_row,curr_col,piece,color)
              bishop_bl(curr_row,curr_col,piece,color)
              bishop_tl(curr_row,curr_col,piece,color)
              bishop_tr(curr_row,curr_col,piece,color)
              rook_f(curr_row,curr_col,piece,color)
              rook_b(curr_row,curr_col,piece,color)
              rook_l(curr_row,curr_col,piece,color)
              rook_r(curr_row,curr_col,piece,color)
            elsif piece=='wp'
              pawn_attack_white(curr_row,curr_col,piece,color)
            elsif piece=='wk'
              knight_attack(curr_row,curr_col,piece,color)
            end
          end
        end
      end
    end
  end


  def falsek
    for a in 0..7
      for b in 0..7
        $white_check[a][b]=false
        $black_check[a][b]=false
      end
    end
  end
  def king_false
    for a in 0..7
      for b in 0..7
        $white_king_moves_into_check[a][b]=false
        $black_king_moves_into_check[a][b]=false
      end
    end
  end
  def team_capture(row,col) #prevent pieces from capturing their own pieces
    if @turn%2==0
      for e in 0..7
        for r in 0..7
          if $valid_moves[e][r] && white_pieces(e,r) && white_pieces(row,col)
            $valid_moves[e][r]=false
          end
        end
      end
    end
  end

  def move2(x,y) # update the board on each click
    king_false
    king_avoid_square
    if @white_check&& @moves_available==false
      position_white_king
      valid_moves($white_king[0],$white_king[1])
    elsif @black_check&& @moves_available==false
      position_black_king
      valid_moves($black_king[0],$black_king[1])
    end

  end
  def cannot_defend_king
    @moves_available=false
    if @white_check
      for a in 0..7
        for b in 0..7
          if white_pieces(a,b)
            valid_moves_false
            valid_moves(a,b)
            check_moves
          end
        end
      end
    elsif @black_check
      for a in 0..7
        for b in 0..7
          if black_pieces(a,b)
            valid_moves_false
            valid_moves(a,b)
            check_moves
          end
        end
      end
    end
  end
  def team_killing(row,col) # prevent team killing
    if white_pieces(row,col) && @turn%2==0
      valid_moves(row,col)
    elsif black_pieces(row,col) && @turn%2==1
      valid_moves(row,col)
    end
  end
  def defend_king
    for k in 0..7
      for l in 0..7
        if black_pieces(k,l) # place pieces in front of the king if in check
          valid_moves_false
          valid_moves(k,l)
          white_king_check($board_pieces[k][l])
        elsif white_pieces(k,l)
          valid_moves_false
          valid_moves(k,l)
          black_king_check($board_pieces[k][l])
        end
      end
    end
  end
  def en_passant_move(a,b)
    if @en_passant_white # check if black has the power of en passant
      if $board_pieces[a][b]=='wp' && $board_pieces[a+2][b]==''&& $board_pieces[a+1][b]==''#check if white moved two squares
        @en_passant=true # set en passant to true
        $en_passant_squares=[b] # input this column number as the en passant capture square
      else
        @en_passant=false
        $en_passant_squares=[] # empty this array
      end
    elsif @en_passant_black
      if $board_pieces[a][b]=='bp' && $board_pieces[a-2][b]==''&& $board_pieces[a-1][b]==''
        @en_passant=true
        $en_passant_squares=[b]
      else
        @en_passant=false
        $en_passant_squares=[]
      end
    else
      @en_passant=false
      $en_passant_squares=[]
    end
  end
  def double_check_king(row,col) #check if king is  attacked by two pieces
    if @white_check
      position_white_king
      if row==$white_king[0] && col==$white_king[1]
        $square_chosen[row][col]=true
        valid_moves($white_king[0],$white_king[1])
      end
    elsif @black_check
      position_black_king
      if row==$black_king[0] && col==$black_king[1]
        $square_chosen[row][col]=true
        valid_moves($black_king[0],$black_king[1])
      end
    end
  end
  def zero_move_checkmate(x,y)
    move2(x,y)
    if $valid_moves.flatten.all?{|x| x==false}
      game_finish
    end
  end
  def move(x,y) # update the board on each click
  position_black_king
  position_white_king
  king_false
  king_avoid_square
  point=false
  for row in 0..7
    for col in 0..7
      arr= $square_position[row][col]
      current_square = Square.new(x:arr[0],y:arr[1],opacity:0,size:SQUARE_SIZE)
      if current_square.contains?(x,y) # if the mouse points to a square on the board
        point =true
        if current_piece?(row,col) # if the mouse points to a chess piece
          team_capture(row,col)
          if square_chosen_twice>=1 # if squares were chosen twice
            if can_be_captured(row,col) # if the second square is a piece that can be captured
              print "cap"
              square_chosen_index # location of the second square
              square_chosen_index_capturing(row,col) # location of the first square
              $board_pieces[row][col]=$board_pieces[@square_position_x][@square_position_y]# update the board to indicate the piece has been captured
              $board_pieces[@square_position_x][@square_position_y]=''#update the board to show the square left by the attacking piece has been marked as empty
              pawn_promotion(row,col)
              @turn+=1
              @num_moves=0
              print "cap"
              $perpetual_hash[$board_pieces]+=1
              reset_squares
            else
              reset_squares
            end
          end
          if @double_check==2
            double_check_king(row,col)
          else
            $square_chosen[row][col]=true # show square chosen by the player
            valid_moves(row,col) # display all valid moves
          end
        else
          for a in 0..7
            for b in 0..7
              arr= $square_position[a][b]
              @en_passant_white=false
              @en_passant_black=false
              if $valid_moves[a][b]==true
                if a==row&&b==col # this is to move a piece from one square to another without capturing
                  if verify_white_passant?(a+2,b)
                    @en_passant_white=true
                  elsif verify_black_passant?(a-2,b)
                    @en_passant_black=true
                  end
                  square_chosen_index
                  @turn+=1
                  $perpetual_hash[$board_pieces]+=1
                  $board_pieces[row][col]=$board_pieces[@square_position_x][@square_position_y]#change current position on the board to previous position
                  if $board_pieces[row][col]=='wp' || $board_pieces[row][col]=='bp'
                    @num_moves=0
                  else
                    @num_moves+=1
                  end
                  $board_pieces[@square_position_x][@square_position_y]='' # update board position as empty
                  if $board_pieces[row][col]=='bp' && @en_passant # if en passant is active and the current square is a black pawn
                    if $board_pieces[row-1][col]=='wp' # if the square behind us is a white pawn, take it out of the game
                      $board_pieces[row-1][col]=''
                    end
                  elsif  $board_pieces[row][col]=='wp' && @en_passant# if en passant is active and the current square is a black pawn
                    if $board_pieces[row+1][col]=='bp'# if the square behind us is a black pawn, take it out of the game
                      $board_pieces[row+1][col]=''
                    end
                  end
                  pawn_promotion(a,b)
                  en_passant_move(a,b)
                end
              end
            end
          end
          @white_check=false
          @black_check=false
          falsek
          reset_squares
          @double_check=0 # check if the king is double checked
          defend_king # defend king from an attack
          reset_squares
          cannot_defend_king
          team_killing(row,col)
          reset_squares
        end
      end
    end
  end
  if @white_check&& @moves_available==false # game ends if there are no available moves when the king is in check
    zero_move_checkmate(x,y)
  elsif @black_check&& @moves_available==false # game ends if there are no available moves when the king is in check
    zero_move_checkmate(x,y)
  elsif @moves_available==false
    print "ok"
  end

  if point==false # clear valid moves when pointing off screen
    valid_moves_false
  end

    print @num_moves,"\n"
  end
end

game = Game.new

update do
    clear
    game.draw
    game.select_square
end

on :mouse_down do |event|
  unless game.finished? || game.is_draw?
    game.move(event.x,event.y)
  end
end

on :key_down do |event|
  if (game.finished?||game.is_draw?) && event.key=='r'
    game = Game.new
  end
end



show
