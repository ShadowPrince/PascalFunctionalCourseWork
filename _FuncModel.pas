{ Dirty implementation of some functional-programming features }
unit FuncModel;
interface
uses
  Dialogs, StdCtrls, Models, RegExpr, UnitLog;

type
  SearchDispatcher = class(PointerModel)
    function dispatch(pins: PModel): string; virtual; abstract; 
  end;
  MapDispatcher = class
    function dispatch(pins: PModel): PModel; virtual; abstract;
  end;
  EachDispatcher = class
    procedure dispatch(pins: PModel); virtual; abstract;
  end;
  FoldAcc = record // record for storing values trought fold dispatchers
    int: array[0..10] of integer;
    str: array[0..10] of string;
    p: array[0..10] of PModel;
    tobject: array[0..10] of TObject;
  end;
  FoldDispatcher = class
    procedure dispatch(ins: PModel; var acc: FoldAcc); virtual; abstract;
  end;

procedure each(start: PModel; dispatcher: EachDispatcher);
procedure eachr(start: PModel; dispatcher: EachDispatcher);

procedure foldl(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc);
procedure foldr(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc);


procedure add(var p: PModel; ins: PointerModel);
procedure delete(var start: PModel; index: integer);
function search(database: PModel; term: string; disp: SearchDispatcher): PModel;

function get(start: PModel; i: integer): PModel;
function last(start: PModel): PModel;

function count(start: PModel): integer;
function empty(start: PModel): boolean;

function pointerPos(start: PModel; needle: PModel): integer;


{ IMPLEMENTATION }
implementation
             
type
  SearchDisp = class(FoldDispatcher)
    procedure dispatch(pins: PModel; var acc: FoldAcc); override;
  end;
  
{ Each implementation }
procedure each(start: PModel; dispatcher: EachDispatcher); var
  p: PModel;
begin
  while (start <> nil) do begin
    p := start;
    start := start^.n;

    dispatcher.dispatch(p);
  end;
end;

{ Right each implementation }
procedure eachr(start: PModel; dispatcher: EachDispatcher); var
  p: PModel;
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
procedure foldl(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc); begin
  while (start <> nil) do begin
    dispatcher.dispatch(start, acc);
    start := start^.n;
  end;
end;

{ Right fold implementation }
procedure foldr(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc); var
  p: PModel;
  x: string;
begin
  x := acc.str[0];
  p := nil;
  while (start <> nil) do begin
    p := start;
    start := start^.n;
  end;

  while (p <> nil) do begin
    dispatcher.dispatch(p, acc);
    p := p^.p;
  end;
end;

procedure add(var p: PModel; ins: PointerModel); var
  ap, np: PModel;
begin
  np := nil;
  
  new(ap);
  ap^ := ins;
  ap^.p := p;
  
  if (p = nil) then begin
    new(p);
    p^ := ins;
    
  end else if (p^.n = nil) then begin
    p^.n := ap;
    ap^.n := nil;
  end else begin
    np := p^.n;

    p^.n := ap;
    ap^.p := p;
    ap^.n := np;
  end;
end;

procedure delete(var start: PModel; index: integer); var
  p: PModel;
begin      
  p := get(start, index);
  if (p^.p <> nil) and (p^.n <> nil) then begin // middle
    p^.p^.n := p^.n; // drop middle element
    p^.n^.p := p^.p;
  end else if (p^.p = nil) and (p^.n <> nil) then begin // first
    start := p^.n; // make next as start
    start.p := nil; // and nil prev (pointer to rec)
  end else if (p^.p <> nil) then begin // last
    p^.p^.n := nil; // nil pointer to rec
  end else begin // only one
    start := nil; // nil start
  end;
  dispose(p);
end;

function last(start: PModel): PModel; begin
  result := get(start, -1);
end;

function get(start: PModel; i: integer): PModel; begin
  result := start;
  while (start <> nil) do begin
    result := start;
    if (i = 0) then exit;
    start := start^.n;
    dec(i);
  end;
end;

function count(start: PModel): integer; begin
  result := 0;
  while (start <> nil) do begin
    inc(result);
    start := start^.n;
  end;
end;

function empty(start: PModel): boolean; begin
  result := start = nil;
end;

function pointerPos(start: PModel; needle: PModel): integer; begin
  result := 0;
  while (start <> nil) and (start <> needle) do begin
    start := start^.n;

    inc(result);
  end;
end;

procedure SearchDisp.dispatch(pins: PModel; var acc: FoldAcc); var
  re: TRegExpr;
  res: SearchResult;
  resp: PModel;
begin
  re := TRegExpr.Create;

  re.InputString := (acc.p[1]^ as SearchDispatcher).dispatch(pins);
  re.Expression := acc.str[0];
  if (re.Exec) then begin
    res := SearchResult.new(pins);
    res.p := nil;
    res.n := nil;
    new(resp);
    resp^ := res;
    
    if (acc.p[0] = nil) then begin
      acc.p[0] := resp;
    end else 
      add(acc.p[0], res);
  end;
end;
function search(database: PModel; term: string; disp: SearchDispatcher): PModel; var
  acc: FoldAcc;
begin
  acc.p[0] := nil;
  new(acc.p[1]);
  acc.p[1]^ := disp;
  acc.str[0] := term;

  foldl(database, SearchDisp.Create, acc);
  result := acc.p[0];                      
end;

end.

