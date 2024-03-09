program minesweeper;

uses
  graphABC;

const
  windowWidth = 1200;
  windowHeight = 660;
  fieldWidth = 20;
  fieldHeight = 10;
  countOfMines = fieldWidth * fieldHeight div 20; // 100% : 10 = 10% (200 : 10 = 20)
  cellSize = 60;

var
  field: array [1..fieldWidth] of array [1..fieldHeight] of byte;
  isOpened: array [1..fieldWidth] of array [1..fieldHeight] of boolean;
  isFlag: array [1..fieldWidth] of array [1..fieldHeight] of boolean;
  firstTurn, isGameOver, isButtonHover: boolean;
  placeOfMines: array [1..fieldWidth * fieldHeight] of integer;
  openedCells: integer;
  
  colors: array [1..9] of Color := (clBlue, clGreen, clRed, clDarkBlue, clBrown, clTurquoise, clBlack, clWhite, clGray);
  
  prevX, prevY: integer;

procedure FillR(x, y: integer; c1, c2: Color);
begin
  if (x + y) mod 2 = 0 then
    SetBrushColor(c1)
  else
    SetBrushColor(c2);
    FillRectangle((x - 1) * cellSize, y * cellSize, x * cellSize, (y + 1) * cellSize);
end;

procedure generateField;
begin
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
      FillR(x, y, RGB(162, 209, 73), RGB(170, 215, 81));
end;

procedure startGame;
begin
  firstTurn := true;
  isGameOver := false;
  isButtonHover := false;
  openedCells := 0;
  SetBrushColor(RGB(74, 117, 44));
  FillRectangle(538, 0, 662, 60);
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
    begin
      field[x][y] := 0;
      isOpened[x][y] := false;
      isFlag[x][y] := false;
    end;
  for var i := 1 to fieldWidth * fieldHeight do
    placeOfMines[i] := i;
  
  prevX := 1;
  prevY := 1;
  
  generateField;
end;

procedure setWindow;
begin
  SetWindowSize(windowWidth, windowHeight);
  CenterWindow;
  SetWindowTitle('Minesweeper - by Pesniakov Igor');
  SetWindowIsFixedSize(true);
  SetFontName('Consolas');
  ClearWindow(RGB(74, 117, 44));
  SetBrushColor(RGB(165, 186, 150));
  FillRoundRect(1061, 11, 1189, 49, 8, 8);
  SetFontSize(21);
  SetFontColor(RGB(74, 117, 44));
  TextOut(1071, 14, 'RESTART');
  SetFontSize(cellSize div 10 * 6);
  SetFontStyle(fsBold);
  startGame;
end;

procedure setNumbers;
begin
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
      if field[x][y] = 9 then
        for var dy := -1 to 1 do
          for var dx := -1 to 1 do
            if (x + dx > 0) and (x + dx <= fieldWidth) and (y + dy > 0) and (y + dy <= fieldHeight) and (field[x + dx][y + dy] <> 9) and ((dx <> 0) or (dy <> 0)) then // последнее условие не обязательно
                field[x + dx][y + dy] += 1;
end;

procedure generateMines(x, y: integer);
begin
  firstTurn := false;
  var z := 0;
  for var dy := -1 to 1 do
    for var dx := -1 to 1 do
      if (x + dx > 0) and (x + dx <= fieldWidth) and (y + dy > 0) and (y + dy <= fieldHeight) then
      begin
        Swap(placeOfMines[(x - 1 + dx) * fieldHeight + y + dy], placeOfMines[fieldWidth * fieldHeight - z]);
        z += 1;
      end;
  for var i := 1 to countOfMines do
  begin
    var rnd := Random(1, (fieldWidth * fieldHeight - i - z));
    field[(placeOfMines[rnd] - 1) div fieldHeight + 1][(placeOfMines[rnd] - 1) mod fieldHeight + 1] := 9;
    Swap(placeOfMines[rnd], placeOfMines[fieldWidth * fieldHeight - i - z]);
  end;
  setNumbers;            
end;

procedure gameOver(isWin: boolean);
begin
  isGameOver := true;
  SetBrushColor(clTransparent);
  SetFontColor(RGB(162, 209, 73));
  SetFontSize(42);
  if isWin then
    TextOut(554, -4, 'WIN')
  else
    TextOut(538, -4, 'LOSE');
end;

procedure openCell(x, y: integer);
begin
  if  not isGameOver and (x > 0) and (x <= fieldWidth) and (y > 0) and (y <= fieldHeight) and not isOpened[x][y] and not isFlag[x][y] then
  begin
    isOpened[x][y] := true;
    openedCells += 1;
    FillR(x, y, RGB(215, 184, 153), RGB(229, 194, 159));
    if firstTurn then
    GenerateMines(x, y);
    if field[x][y] <> 0 then
    begin
      //SetFontColor(RGB(0 + (field[x][y] - 1) * 31, 127, 255 - (field[x][y] - 1) * 31));
      
      SetFontColor(colors[field[x][y]]);
      
      TextOut(x * cellSize - 43, y * cellSize + 2, field[x][y].ToString);
      if field[x][y] = 9 then
        gameOver(false);
      if openedCells = fieldWidth * fieldHeight - countOfMines then
        gameOver(true);
    end
    else
      for var dy := -1 to 1 do
        for var dx := -1 to 1 do
          if (dx <> 0) or (dy <> 0) then
            openCell(x + dx, y + dy);
  end;
end;

procedure setFlag(x, y: integer);
begin
  if  not isGameOver and (y > 0) and not isOpened[x][y] and not firstTurn then
  begin
    if isFlag[x][y] then
      FillR(x, y, RGB(162, 209, 73), RGB(170, 215, 81))
    else
      FillR(x, y, RGB(209, 73, 73), RGB(215, 81, 81));
    isFlag[x][y] := not isFlag[x][y];
  end;
end;

procedure mouseUp(x, y, mb: integer);
begin
  if mb = 1 then
  begin
    openCell(x div cellSize + 1, y div cellSize);
    if (x >= 1061) and (x <= 1189) and (y >= 11) and (y <= 49) then
      startGame;
  end
  else
    setFlag(x div cellSize + 1, y div cellSize);
end;

procedure mouseMove(x, y, mb: integer);
begin
  if not isButtonHover and (x >= 1061) and (x <= 1189) and (y >= 11) and (y <= 49) then
  begin
    SetFontSize(21);
    SetBrushColor(clTransparent);
    isButtonHover := true;
    SetFontColor(clWhite);
    TextOut(1071, 14, 'RESTART');
    SetFontSize(cellSize div 10 * 6);
  end
  else
    if isButtonHover and ((x < 1061) or (x > 1189) or (y < 11) or (y > 49)) then
    begin
      SetFontSize(21);
      SetBrushColor(clTransparent);
      isButtonHover := false;
      SetFontColor(RGB(74, 117, 44));
      TextOut(1071, 14, 'RESTART');
    SetFontSize(cellSize div 10 * 6);
    end;
  x := x div cellSize + 1;
  y := y div cellSize;
  if (x > 0) and (x <= fieldWidth) and (y > 0) and (y <= fieldHeight) and not isOpened[x][y] and not isFlag[x][y] then
  begin
    FillR(x, y, RGB(185, 221, 119), RGB(191, 225, 125));
    
    if ((prevX <> x) or (prevY <> y)) and not isOpened[prevX][prevY] and not isFlag[prevX][prevY] then
      FillR(prevX, prevY, RGB(162, 209, 73), RGB(170, 215, 81));
    prevX := x;
    prevY := y;
  end
  else
    if ((prevX <> x) or (prevY <> y)) and not isOpened[prevX][prevY] and not isFlag[prevX][prevY] then
      FillR(prevX, prevY, RGB(162, 209, 73), RGB(170, 215, 81));
end;

begin
  setWindow;
  OnMouseUp := mouseUp;
  OnMouseMove := mouseMove;
end.