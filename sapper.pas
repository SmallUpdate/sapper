program sapper;

uses
  graphABC, ABCObjects;

const
  windowWidth = 1280;
  windowHeight = 720;
  fieldSize = 7; // fieldWidth, fieldHeight
  countOfMines = fieldSize * fieldSize div 10; // 10%
  cellSize = windowHeight div (fieldSize + 2); // 60: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30
                                              // 100: 1, 2, 4, 5, 10, 20, 50

var
  field: array [1..fieldSize] of array [1..fieldSize] of byte;
  isOpened: array [1..fieldSize] of array [1..fieldSize] of boolean;
  isFlag: array [1..fieldSize] of array [1..fieldSize] of boolean;
  firstTurn := true;
  placeOfMines: array [1..fieldSize * fieldSize] of integer;
  
  //prevX, prevY: integer;

procedure setWindow;
begin
  SetWindowSize(windowWidth, windowHeight);
  CenterWindow;
  SetWindowTitle('Sapper - ultra delux');
  SetWindowIsFixedSize(true);
  SetFontName('Consolas');
  SetFontSize(cellSize div 10 * 6);
  SetFontStyle(fsBold);
  for var y := 1 to fieldSize do
    for var x := 1 to fieldSize do
    begin
      field[x][y] := 0;
      isOpened[x][y] := false;
      isFlag[x][y] := false;
    end;
  for var i := 1 to fieldSize * fieldSize do
    placeOfMines[i] := i;
  
  //prevX := 1;
  //prevY := 1;
end;

procedure generateField;
begin
  for var y := 1 to fieldSize do
    for var x := 1 to fieldSize do
    begin
      if (x + y) mod 2 = 0 then
        SetBrushColor(RGB(162, 209, 73))
      else
        SetBrushColor(RGB(170, 215, 81));
      FillRectangle(x * cellSize, y * cellSize, (x + 1) * cellSize, (y + 1) * cellSize);
    end;
end;

procedure setNumbers;
begin
  for var y := 1 to fieldSize do
    for var x := 1 to fieldSize do
      if field[x][y] = 9 then
        for var dy := -1 to 1 do
          for var dx := -1 to 1 do
            if (x + dx > 0) and (x + dx <= fieldSize) and (y + dy > 0) and (y + dy <= fieldSize) and (field[x + dx][y + dy] <> 9) and ((dx <> 0) or (dy <> 0)) then // последнее условие не обязательно
                field[x + dx][y + dy] += 1;
end;

procedure generateMines(x, y: integer);
begin
  firstTurn := false;
  var z := 0;
  for var dy := -1 to 1 do
    for var dx := -1 to 1 do
      if (x + dx > 0) and (x + dx <= fieldSize) and (y + dy > 0) and (y + dy <= fieldSize) then
      begin
        Swap(placeOfMines[(x - 1 + dx) * fieldSize + y + dy], placeOfMines[fieldSize * fieldSize - z]);
        z += 1;
      end;
  for var i := 1 to countOfMines do
  begin
    var rnd := Random(1, (fieldSize * fieldSize - i - z));
    field[(placeOfMines[rnd] - 1) div fieldSize + 1][(placeOfMines[rnd] - 1) mod fieldSize + 1] := 9;
    Swap(placeOfMines[rnd], placeOfMines[fieldSize * fieldSize - i - z]);
  end;
  setNumbers;            
end;

procedure openCell(x, y: integer);
begin
  if (x > 0) and (x <= fieldSize) and (y > 0) and (y <= fieldSize) and not isOpened[x][y] and not isFlag[x][y] then
  begin
    isOpened[x][y] := true;
    if (x + y) mod 2 = 0 then
       SetBrushColor(RGB(215, 184, 153))
    else
      SetBrushColor(RGB(229, 194, 159));
    FillRectangle(x * cellSize, y * cellSize, (x + 1) * cellSize, (y + 1) * cellSize);
    if firstTurn then
    GenerateMines(x, y);
    if field[x][y] <> 0 then
      TextOut(x * cellSize + 17, y * cellSize + 2, field[x][y].ToString)
    else
      for var dy := -1 to 1 do
        for var dx := -1 to 1 do
          if (dx <> 0) or (dy <> 0) then
            openCell(x + dx, y + dy);
  end;
end;

procedure mouseUp(x, y, mb: integer);
begin
  x := x div cellSize;
  y := y div cellSize;
  SetWindowTitle('x: ' + x + ' y: ' + y);
  if mb = 1 then
    openCell(x, y)
  else // set flag
  begin
    if not isOpened[x][y] then
    begin
      if isFlag[x][y] then
      begin
        if (x + y) mod 2 = 0 then
          SetBrushColor(RGB(162, 209, 73))
        else
          SetBrushColor(RGB(170, 215, 81));
        FillRectangle(x * cellSize, y * cellSize, (x + 1) * cellSize, (y + 1) * cellSize);
      end
      else
      begin
        if (x + y) mod 2 = 0 then
           SetBrushColor(RGB(209, 73, 73))
        else
          SetBrushColor(RGB(215, 81, 81));
        FillRectangle(x * cellSize, y * cellSize, (x + 1) * cellSize, (y + 1) * cellSize);
      end;
      isFlag[x][y] := not isFlag[x][y];
    end;
  end;
end;

{procedure mouseMove(x, y, mb: integer);
begin
  x := x div cellSize;
  y := y div cellSize;
  if (x > 0) and (x <= fieldSize) and (y > 0) and (y <= fieldSize) and not isOpened[x][y] and not isFlag[x][y] then
  begin
    if (x + y) mod 2 = 0 then
       SetBrushColor(RGB(185, 221, 119))
    else
      SetBrushColor(RGB(191, 225, 125));
    FillRectangle(x * cellSize, y * cellSize, (x + 1) * cellSize, (y + 1) * cellSize);
    
    if ((prevX <> x) or (prevY <> y)) and not isOpened[prevX][prevY] and not isFlag[prevX][prevY] then
    begin
      if (prevX + prevY) mod 2 = 0 then
        SetBrushColor(RGB(162, 209, 73))
      else
        SetBrushColor(RGB(170, 215, 81));
    FillRectangle(prevX * cellSize, prevY * cellSize, (prevX + 1) * cellSize, (prevY + 1) * cellSize);
    end;
    prevX := x;
    prevY := y;
  end
  else
    if ((prevX <> x) or (prevY <> y)) and not isOpened[prevX][prevY] and not isFlag[prevX][prevY] then
    begin
      if (prevX + prevY) mod 2 = 0 then
        SetBrushColor(RGB(162, 209, 73))
      else
        SetBrushColor(RGB(170, 215, 81));
    FillRectangle(prevX * cellSize, prevY * cellSize, (prevX + 1) * cellSize, (prevY + 1) * cellSize);
    end;
end;}

begin
  setWindow;
  generateField;
  {for var i := 1 to fieldSize * fieldSize do
    mouseUp(((i - 1) div fieldSize + 1) * cellSize, ((i - 1) mod fieldSize + 1) * cellSize, 1);}
  OnMouseUp := mouseUp;
//OnMouseMove := mouseMove;
//SaveWindow('window.png');
end.