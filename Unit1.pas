unit Unit1;

interface

uses
  Windows,System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Objects,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Bindings.Outputs,
  Data.Bind.Components, FMX.Layouts, FMX.ListBox,Unit2;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ListBox1: TListBox;
    Timer1: TTimer;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;



implementation

{$R *.fmx}

procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var i: integer;
a: boolean;
begin
try
if FiguresList.Count <> 0 then
 for i := 0 to FiguresList.Count-1 do
  begin
   if FiguresList[i] = currentFigure then
    begin
     Form1.PaintBox1.Canvas.Stroke.Color := TAlphaColorRec.Red;
     Form1.PaintBox1.Canvas.StrokeThickness := 5;
     FiguresList[i].Draw(Form1.PaintBox1.Canvas);
     Form1.PaintBox1.Canvas.Stroke.Color := TAlphaColorRec.Black;
     Form1.PaintBox1.Canvas.StrokeThickness := 1;
    end
   else FiguresList[i].Draw(Form1.PaintBox1.Canvas);

   // canvas.Fill.Color := $000000
  end;
if drawFigure.Count > 1 then
 for i := 0 to drawFigure.Count-2 do
  begin
    with Form1.PaintBox1.Canvas do
      begin
        BeginScene;
        DrawLine(drawFigure[i],drawFigure[i+1],1);
        EndScene;
      end;
  end;




except

on  EAccessViolation do;

end;
end;


procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
if SpeedButton2.IsPressed then
  begin
    currentMode := BROKEN_LINE;
    SpeedButton3.IsPressed := false;
  end
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
if SpeedButton3.IsPressed then
  begin
    currentMode := POLYGON;
    SpeedButton2.IsPressed := false;
  end
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var i: integer;
begin
try
if FiguresList.Count <> 0 then
if  Form1.Active = true then
begin
if currentFigure.testRange(PaintBox1.width,PaintBox1.height) then raise ERangeError.Create('Граница!');

if GetAsyncKeyState(37) <> 0 then //влево
   begin
     currentFigure.relocate(4);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(38) <> 0 then         //вверх
   begin
     currentFigure.relocate(1);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(39) <> 0 then                //вправо
   begin
     currentFigure.relocate(2);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(40) <> 0 then                  //вниз
   begin
     currentFigure.relocate(3);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(18) <> 0 then              //увеличение - alt
   begin
     currentFigure.zoom(1);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(17) <> 0 then         //уменьшение - ctrl
   begin
     currentFigure.zoom(0);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(33) <> 0 then        //поворот против часовой стрелки - PageUp
   begin
     currentFigure.turn(0);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(34) <> 0 then     //поворот по часовйо стрелке PgDown
   begin
     currentFigure.turn(1);
      Form1.PaintBox1.Repaint;
   end;

if GetAsyncKeyState(46) <> 0 then     //удаление - Delete
   begin
      if ListBox1.ItemIndex <> -1 then
      begin
        i:=0;
        while FiguresList[i] <> currentFigure do inc(i);
        ListBox1.Items.Delete(ListBox1.ItemIndex);
        FiguresList.Delete(i);
        if FiguresList.Count <> 0 then currentFigure := FiguresList[0];
        Form1.PaintBox1.Repaint;
      end;
   end;
end;
except
  on EAccessViolation do;
  on E: ERangeError do ShowMessage(E.Message);
end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
case Key of

13: if (drawFigure.Count > 1) then
  begin

    if drawFigure[0].Distance(drawFigure[drawFigure.Count-1]) < 5 then drawFigure.Remove(drawFigure[drawFigure.Count-1]);

    case currentMode of
       BROKEN_LINE:  currentFigure := TBrokenLine.Create(drawFigure,'Ломанная №' + IntToStr(FiguresList.Count+1) );
           POLYGON:  currentFigure := TPolygon.Create(drawFigure, 'Многоугольник №' + IntToStr(FiguresList.Count+1));
    end;

    FiguresList.Add(currentFigure);
    drawFigure.Count := 0;
    ListBox1.Items.Add(FiguresList[FiguresList.Count-1].Name);
    PaintBox1.Repaint;
  end;

  end;

end;

procedure TForm1.ListBox1Click(Sender: TObject);
var i: integer;
begin
if ListBox1.Items.Count <> 0 then
 begin
  if ListBox1.ItemIndex = -1 then  ListBox1.ItemIndex := 0;
  i:=0;
  while ListBox1.Items[ListBox1.ItemIndex] <> FiguresList[i].Name do inc(i);
  currentFigure := FiguresList[i];
  Form1.PaintBox1.Repaint;
 end;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
if ((currentMode = POLYGON) or (currentMode = BROKEN_LINE)) then
  begin
    curPoint.X := x;
    curPoint.Y := y;
    drawFigure.Add(curPoint);
    PaintBox1.Repaint;
  end;
end;


end.
