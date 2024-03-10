program minesweeper;

uses
  graphABC;

const
  windowWidth = 1200;
  windowHeight = 660;
  scale = 4;
  fieldWidth = 10 * scale;
  fieldHeight = 5 * scale;
  countOfMines = fieldWidth * fieldHeight div 10;
  cellSize = (windowHeight - 60) div fieldHeight;
  lightGreen = RGB(170, 215, 81);
  darkGreen = RGB(162, 209, 73);
  lightYellow = RGB(229, 194, 159);
  darkYellow = RGB(215, 184, 153);
  lightRed = RGB(215, 81, 81);
  darkRed = RGB(209, 73, 73);

type cellProperties = record
  open, flag: boolean;
  digit: byte;
end;

var
  cell: array [1..fieldWidth] of array [1..fieldHeight] of cellProperties;
  firstTurn, isGameOver: boolean;
  placeOfMines: array [1..fieldWidth * fieldHeight] of integer;
  openedCells: integer;
  colors: array [1..9] of Color := (clBlue, clGreen, clRed, clDarkBlue, clBrown, clTurquoise, clBlack, clWhite, clGray);

procedure FillR(x, y: integer; c1, c2: Color);
begin
  if (x + y) mod 2 = 0 then
    SetBrushColor(c1)
  else
    SetBrushColor(c2);
    FillRectangle((x - 1) * cellSize, (y - 1) * cellSize + 60, x * cellSize, y * cellSize + 60);
end;

procedure generateField;
begin
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
      FillR(x, y, darkGreen, lightGreen);
end;

procedure startGame;
begin
  firstTurn := true;
  isGameOver := false;
  openedCells := 0;
  SetBrushColor(RGB(74, 117, 44));
  FillRectangle(538, 0, 662, 60);
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
    begin
      cell[x][y].digit := 0;
      cell[x][y].open := false;
      cell[x][y].flag := false;
    end;
  for var i := 1 to fieldWidth * fieldHeight do
    placeOfMines[i] := i;
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
  SetFontStyle(fsBold);
  FillRoundRect(1061, 11, 1189, 49, 8, 8);
  SetFontSize(21);
  SetFontColor(RGB(74, 117, 44));
  TextOut(1071, 14, 'RESTART');
  SetFontSize(cellSize div 10 * 6);
  startGame;
end;

procedure setDigits;
begin
  for var y := 1 to fieldHeight do
    for var x := 1 to fieldWidth do
      if cell[x][y].digit = 9 then
        for var dy := -1 to 1 do
          for var dx := -1 to 1 do
            if (x + dx > 0) and (x + dx <= fieldWidth) and (y + dy > 0) and (y + dy <= fieldHeight) and (cell[x + dx][y + dy].digit <> 9) then
                cell[x + dx][y + dy].digit += 1;
end;

procedure generateMines(x, y: integer);
begin
  firstTurn := false;
  var z := 0;
  for var dy := -1 to 1 do
    for var dx := -1 to 1 do
      if (x + dx > 0) and (x + dx <= fieldWidth) and (y + dy > 0) and (y + dy <= fieldHeight) then
      begin
        if (x - 1) * fieldHeight + y < fieldWidth * fieldHeight div 2 then
          Swap(placeOfMines[(x - 1 + dx) * fieldHeight + y + dy], placeOfMines[fieldWidth * fieldHeight - z])
        else
          Swap(placeOfMines[(x - 1 + dx) * fieldHeight + y + dy], placeOfMines[z + 1]);
        z += 1;
      end;
  for var i := 1 to countOfMines do
  begin
    var rnd: integer;
    if (x - 1) * fieldHeight + y < fieldWidth * fieldHeight div 2 then
      rnd := Random(1, (fieldWidth * fieldHeight - i - z))
    else
      rnd := Random(z + i, (fieldWidth * fieldHeight) - 1);
    cell[(placeOfMines[rnd] - 1) div fieldHeight + 1][(placeOfMines[rnd] - 1) mod fieldHeight + 1].digit := 9;
    Swap(placeOfMines[rnd], placeOfMines[fieldWidth * fieldHeight - i - z])
  end;
  setDigits;            
end;

procedure gameOver(isWin: boolean);
begin
  isGameOver := true;
  SetBrushColor(clTransparent);
  SetFontColor(RGB(162, 209, 73));
  SetFontSize(36);
  if isWin then
    TextOut(554, 0, 'WIN')
  else
    TextOut(538, 0, 'LOSE');
  SetFontSize(cellSize div 10 * 6);
end;

procedure openCell(x, y: integer);
begin
  if  not isGameOver and (x > 0) and (x <= fieldWidth) and (y > 0) and (y <= fieldHeight) and not cell[x][y].open and not cell[x][y].flag then
  begin
    cell[x][y].open := true;
    openedCells += 1;
    FillR(x, y, darkYellow, lightYellow);
    if firstTurn then
    GenerateMines(x, y);
    if cell[x][y].digit <> 0 then
    begin
      SetFontColor(colors[cell[x][y].digit]);
      TextOut((x - 1) * cellSize + 34 div scale, (y - 1) * cellSize + 8 div scale + 60, cell[x][y].digit.ToString);
      if cell[x][y].digit = 9 then
        gameOver(false)
      else
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
  if  not isGameOver and (y > 0) and not cell[x][y].open and not firstTurn then
  begin
    if cell[x][y].flag then
      FillR(x, y, darkGreen, lightGreen)
    else
      FillR(x, y, darkRed, lightRed);
    cell[x][y].flag := not cell[x][y].flag;
  end;
end;

procedure mouseDown(x, y, mb: integer);
begin
  LockDrawing;
  if mb = 1 then
  begin
    //SetWindowTitle('x: ' + x + ' y: ' + y + ' | ' + 'x: ' + (x div cellSize + 1) + ' y: ' + ((y - 60) div cellSize + 1));
    if y > 60 then
      openCell(x div cellSize + 1, (y - 60) div cellSize + 1);
    if (x >= 1061) and (x <= 1189) and (y >= 11) and (y <= 49) then
      startGame;
  end
  else
    if y > 60 then
    setFlag(x div cellSize + 1, (y - 60) div cellSize + 1);
  UnlockDrawing;
end;

procedure keyDown(key: integer);
begin
  LockDrawing;
  if key = VK_Escape then
      startGame;
  UnlockDrawing;
end;

begin
  setWindow;
  OnMouseDown := mouseDown;
  OnKeyDown := keyDown;
end.