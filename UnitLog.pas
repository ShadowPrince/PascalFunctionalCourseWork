unit UnitLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils;

type
  TFLog = class(TForm)
    MLog: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  
  procedure l(s: string); overload;
  procedure l(s: integer); overload;
  procedure l(s: word); overload;
  //gprocedure l(b: boolean); overload;
  procedure error(s: string); overload;

  procedure lOffsetPlus();
  procedure lOffsetMinus();
  procedure lOffsetReset();

  procedure lTimerStart(); overload;
  procedure lTimerStart(msg: string); overload;
  procedure lTimerReport();
  function arrayToStr(a: array of string; len: integer): string; overload;
  
var
  FLog: TFLog;
  offset: integer;
  timeStart: int64;
  
implementation

uses Unit1;

{$R *.dfm}

// @TODO: time 
function DateTimeToMillis(aDateTime: TDateTime): Int64; 
var 
  TimeStamp: TTimeStamp; 
begin 
  TimeStamp := DateTimeToTimeStamp (aDateTime); 
  Result := Int64 (TimeStamp.Date) * MSecsPerDay + TimeStamp.Time; 
end;

procedure lTimerStart(); overload; begin
  timeStart := DateTimeToMillis(Now);
end;

procedure lTimerStart(msg: string); overload; begin
  l(msg);
  lTimerStart();
end;

procedure lTimerReport(); begin
  l('Operation finished in ' + floatToStr((DateTimeToMillis(Now) - timeStart)/1000) + ' sec.');
  timeStart := 0;
end;

procedure lOffsetReset(); begin
  offset := 0;
end;

procedure lOffsetSet(o: integer); begin
  offset := o;
end;

procedure lOffsetPlus(); begin
  offset := offset + 4;
end;

procedure lOffsetMinus(); begin
  offset := offset - 4;
  if offset < 0 then offset := 0;
end;

procedure log(lvl: string; str: string); var
  offsetStr: string;
  i: integer;
begin
  offsetStr := '';
  for i := 0 to offset do offsetStr := offsetStr + ' ';
  FLog.MLog.Lines.Append(''
    + '[' + lvl + '] (' 
    + intToStr(HourOf(Now)) + ':' 
    + intToStr(MinuteOf(Now)) + ':'
    + intToStr(SecondOf(Now)) + ') '
    + offsetStr
    + str
  );
end;

procedure l(b: boolean); overload; begin
  if (b) then log('log', 'true') else log('log', 'false');
end;

procedure l(s: string); overload; begin
  log('log', s);
end;

procedure l(s: integer); overload; begin
  log('log', intToStr(s));
end;         

procedure l(s: word); overload; begin
  log('log', intToStr(s));
end;


procedure error(s: string); overload; begin
  log('error', s);
end;

function arrayToStr(a: array of string; len: integer): string; overload; var
  i: integer;
begin
  i := 0;
  result := '';
  while (i < len) do begin
    result := result + ' ' + a[i];
    inc(i);
  end;
end;     

procedure TFLog.FormCreate(Sender: TObject); begin
  startup();
end;

end.
