unit Unit2;

interface

uses System.SysUtils,System.Types,System.UITypes,System.Generics.Collections,FMX.Types,FMX.Dialogs;

type


TPoints = TList<TPointF>;

TBrokenLine = class
Points: TPoints;
Name: string;
constructor Create(Arr: TPoints; inName: string);
procedure Draw(canvas: TCanvas); virtual;
procedure relocate(direction: word);
procedure zoom(a: byte);
procedure turn(a: byte);
function testRange(w,h: single): boolean;
end;

TPolygon = class(TBrokenLine)
procedure Draw(canvas: TCanvas); override;
end;

TFiguresList = TObjectList<TBrokenLine>;


const

WORK_WITH_FIGURES = 1;    //режимы работы
BROKEN_LINE = 2;
POLYGON = 3;

UP = 1;     //направления перемещения
DOWN = 3;
LEFT =4;
RIGHT = 2;

MIN_ANGLE = 0.01; //элементароный угол поворота
MIN_RELOC = 1; //элементаронео перемещение
INCREASE = 1.01; //коэффициент увеличения
DECREASE = 0.99; //коэффициент уменьшения

var
currentMode: integer = 0;
FiguresList: TFiguresList;
drawFigure: TPoints;
currentFigure: TBrokenLine;
curPoint: TPointF;


implementation

uses Math;

constructor TBrokenLine.Create;
var i: integer;
begin
Points := TPoints.Create;
for i := 0 to Arr.Count-1 do Points.Add(Arr[i]);
name := InName;
end;



procedure TBrokenLine.Draw;
var i: integer;
begin
  canvas.BeginScene;
  for i := 0 to Points.Count-2 do
    canvas.DrawLine(Points[i],Points[i+1],1);
  canvas.EndScene;
end;

{ TPolygon }

procedure TPolygon.Draw;
begin
  inherited;
  with canvas do
  begin
    BeginScene;
    DrawLine(Points[Points.Count-1],Points[0],1);
    EndScene;
  end;

end;

procedure TBrokenLine.relocate(direction: word);
var i: integer;
     p: TPointF;
begin
  p:= TPointF.Create(0,0);
  case direction of
  UP: for i := 0 to Points.Count-1 do begin p.X := Points[i].X; p.Y := Points[i].y - MIN_RELOC; Points[i] := p;  end;
  RIGHT: for i := 0 to Points.Count-1 do begin p.X := Points[i].X + MIN_RELOC; p.Y := Points[i].y; Points[i] := p;  end;
  DOWN: for i := 0 to Points.Count-1 do begin p.X := Points[i].X; p.Y := Points[i].y + MIN_RELOC; Points[i] := p;  end;
  LEFT: for i := 0 to Points.Count-1 do begin p.X := Points[i].X-MIN_RELOC; p.Y := Points[i].y; Points[i] := p;  end;
  end;
end;

procedure TBrokenLine.zoom(a: byte);
var i: integer;
x,y: single;
centr,p: TPointF;
begin
  x := 0;
  y := 0;
  for i := 0 to Points.Count-1 do
  begin
    x := x + Points[i].X;
    y := y + Points[i].y;
  end;
  x := x/Points.Count;
  y := y/Points.Count;

centr := TpointF.Create(x,y);

for i := 0 to Points.Count-1 do
  begin
    case a of
    1: begin x := (Points[i].X - centr.X) * INCREASE + centr.X;
             y := (Points[i].Y - centr.Y) * INCREASE + centr.Y;
        end;
    0: begin x := (Points[i].X - centr.X) * DECREASE + centr.X;
             y := (Points[i].Y - centr.Y) * DECREASE + centr.Y;
        end;
    end;
    p := TPointF.Create(x,y);
    Points[i] := p;
  end;
end;

procedure TBrokenLine.turn(a: byte);
var i: integer;
x,y: single;
centr,p: TPointF;
begin
try
  x := 0;
  y := 0;
  for i := 0 to Points.Count-1 do
  begin
    x := x + Points[i].X;
    y := y + Points[i].y;
  end;
  x := x/Points.Count;
  y := y/Points.Count;

centr := TpointF.Create(x,y);

for i := 0 to Points.Count-1 do
  begin
    case a of
    1: begin x := (Points[i].X - centr.X) * cos(MIN_ANGLE) - (Points[i].Y - centr.Y)* sin(MIN_ANGLE) + centr.X;
             y := (Points[i].X - centr.X) * sin(MIN_ANGLE) + (Points[i].Y - centr.Y) * cos(MIN_ANGLE) + centr.Y;
        end;
    0: begin x := (Points[i].X - centr.X) * cos(-MIN_ANGLE) - (Points[i].Y - centr.Y)* sin(-MIN_ANGLE) + centr.X;
             y := (Points[i].X - centr.X) * sin(-MIN_ANGLE) + (Points[i].Y - centr.Y) * cos(-MIN_ANGLE) + centr.Y;
        end;
    end;
    p := TPointF.Create(x,y);
    Points[i] := p;
  end;
except
  on EAccessViolation do ShowMessage('Нет объектов');
end;
end;

function TBrokenLine.testRange(w,h: single): boolean;
var i,j: integer;
p: boolean;
t: TPointF;

begin
i := 0;
p:=true;
t:=TPointF.Create(0,0);
while (i < Points.Count) and p do
begin
  if  (Points[i].X >= w-5) then
     begin
       p:=false;
       for j := 0 to Points.Count - 1 do
          begin
            t.X := Points[j].X-5;
            t.Y := Points[j].y;
            Points[j] := t;
          end;
     end;
  if  (Points[i].X <= 5)  then begin p:=false; for j := 0 to Points.Count - 1 do begin t.X := Points[j].X+5; t.Y := Points[j].y; Points[j] := t; end; end;
  if (Points[i].y >= h-5) then  begin p:=false; for j := 0 to Points.Count - 1 do begin t.y := Points[j].y-5; t.x := Points[j].x; Points[j] := t; end; end;
  if (Points[i].y <= 5) then begin p:=false; for j := 0 to Points.Count - 1 do begin t.y := Points[j].y+5; t.x := Points[j].x; Points[j] := t; end; end;
  inc(i);
end;
if not p then result := true
else result := false;

end;

initialization

FiguresList := TFiguresList.Create;
FiguresList.Count := 0;
drawFigure := TPoints.Create;
drawFigure.Count := 0;
curPoint := TPointF.Create(0,0);


end.
