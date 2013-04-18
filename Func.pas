{ Dirty implementation of some functional-programming features }
unit Func;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ListTypes;

type
  MapDispatcher = class
    function dispatch(rec: TPRec): TPRec; virtual; abstract;
  end;
  EachDispatcher = class
    procedure dispatch(rec: TPRec); virtual; abstract;
  end;
  FoldAcc = record // record for storing values trought fold dispatchers
    int: array[0..10] of integer;
    str: array[1..10] of string;
    prec: array[0..10] of TPRec;
  end;
  FoldDispatcher = class
    procedure dispatch(rec: TPRec; var acc: FoldAcc); virtual; abstract;
  end;

procedure each(start: TPRec; dispatcher: EachDispatcher);
procedure eachr(start: TPRec; dispatcher: EachDispatcher);

function map(start: TPRec; dispatcher: MapDispatcher): TPRec;

function foldl(start: TPRec; dispatcher: FoldDispatcher; acc: FoldAcc): FoldAcc;
function foldr(start: TPRec; dispatcher: FoldDispatcher; acc: FoldAcc): FoldAcc;

{ IMPLEMENTATION }
implementation

{ Map implementation (return new list of same TPRec type) }
function map(start: TPRec; dispatcher: MapDispatcher): TPRec;
var
  res, resp: TPRec;
begin
  res := nil;
  resp := nil;
  while (start <> nil) do begin
    res := dispatcher.dispatch(start);
    res^.p := resp;
    res^.n := nil;

    if (resp <> nil) then
      resp^.n := res
    else
      result := res;

    resp := res;
    start := start^.n;
  end;
end;

{ Each implementation }
procedure each(start: TPRec; dispatcher: EachDispatcher);
begin
  while (start <> nil) do begin
    dispatcher.dispatch(start);

    start := start^.n;
  end;
end;

{ Right each implementation }
procedure eachr(start: TPRec; dispatcher: EachDispatcher);
var
  p: TPRec;
begin
  p := nil;
  while (start <> nil) do begin
    p := start;
    start := start^.n;
  end;

  while (p <> nil) do begin
    dispatcher.dispatch(p);
    p := p^.p;
  end;
end;

{ Left fold implementation }
function foldl(start: TPRec; dispatcher: FoldDispatcher; acc: FoldAcc): FoldAcc;
begin
  while (start <> nil) do begin
    dispatcher.dispatch(start, acc);
    start := start^.n;
  end;

  result := acc;
end;

{ Right fold implementation }
function foldr(start: TPRec; dispatcher: FoldDispatcher; acc: FoldAcc): FoldAcc;
var
  p: TPRec;
begin
  p := nil;
  while (start <> nil) do begin
    p := start;
    start := start^.n;
  end;
  
  while (p <> nil) do begin
    dispatcher.dispatch(p, acc);
    p := p^.p;
  end;

  result := acc;
end;

end.
