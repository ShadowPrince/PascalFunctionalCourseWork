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
  procedure l(s: boolean); overload;
  procedure error(s: string); overload;

  function arrayToStr(a: array of string; len: integer): string; overload;
  
var
  FLog: TFLog;
  
implementation

uses Unit1;

{$R *.dfm}

// @TODO: time 

procedure log(lvl: string; str: string); begin
  FLog.MLog.Lines.Append(
    '[' + lvl + '] (' 
    + intToStr(HourOf(Now)) + ':' 
    + intToStr(MinuteOf(Now)) + ':'
    + intToStr(SecondOf(Now)) + ') '
    + str
  );
end;

procedure l(s: boolean); overload; begin
  if (s) then log('log', 'true') else log('log', 'false');
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
  l('Log started');
  updateView();
end;

end.
