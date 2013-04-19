{ Dirty implementation of some functional-programming features }
unit FuncModel;
interface
uses
  Models, RegExpr, UnitLog, SysUtils;

type
  CloneFunc = function(ins: TObject): TObject;
  SearchDispatcher = function(pins: PModel): string;
  MapDispatcher = function(pins: PModel): PModel;
  EachDispatcher = procedure(pins: PModel); 
  PairsDispatcher = procedure(p1: PModel; p2: PModel);
  
  FoldAcc = record // record for storing values trought fold dispatchers
    int: array[0..10] of integer;
    str: array[0..10] of string;       
    p: array[0..10] of PModel;
    pointer: array[0..10] of Pointer;
    tobject: array[0..10] of TObject;
  end;
  FoldDispatcher = procedure(ins: PModel; var acc: FoldAcc);
  FilterDispatcher = function(ins: PModel): boolean; 

procedure each(start: PModel; dispatcher: EachDispatcher);
//procedure eachr(start: PModel; dispatcher: EachDispatcher);

function foldl(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc): FoldAcc; overload;
//function foldr(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc): FoldAcc; overload;
function foldl(start: PModel; dispatcher: FoldDispatcher): FoldAcc; overload;
//function foldr(start: PModel; dispatcher: FoldDispatcher): FoldAcc; overload;

procedure add(var p: PModel; ins: PointerModel);
procedure delete(var start: PModel; index: integer); overload;
procedure delete(var start: PModel; p: PModel); overload;

function search(database: PModel; term: string; disp: SearchDispatcher): PModel;
function filter(start: PModel; disp: FilterDispatcher): PModel;
function pairs(start: PModel; disp: PairsDispatcher): PModel;

function get(start: PModel; i: integer): PModel;
function last(start: PModel): PModel;
function first(start: PModel): PModel;
function count(start: PModel): integer;
function empty(start: PModel): boolean;
function pos(start: PModel; needle: PModel): integer; overload;

function reverse(start: PModel): PModel; overload;
function reverse(start: PModel; clnFn: CloneFunc): PModel; overload;


{ IMPLEMENTATION }
implementation
           
{ Each implementation }
procedure each(start: PModel; dispatcher: EachDispatcher); var
  p: PModel;
begin
  while (start <> nil) do begin  // @CYCLE
    p := start;
    start := start^.n;

    dispatcher(p);
  end;
end;

{ Right each implementation }
procedure eachr(start: PModel; dispatcher: EachDispatcher); var
  p: PModel;
begin
  each(reverse(start), dispatcher);
end;

{ Left fold implementation }
function foldl(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc): FoldAcc; overload; var
  p: PModel;
begin
  while (start <> nil) do begin // @CYCLE
    p := start;
    start := start^.n;
    
    dispatcher(p, acc);
  end;
  result := acc;
end;

function foldl(start: PModel; dispatcher: FoldDispatcher): FoldAcc; overload; var
  p: PModel;
begin
  result := foldl(start, dispatcher, result);
end;

{ Right fold implementation }
function foldr(start: PModel; dispatcher: FoldDispatcher; var acc: FoldAcc): FoldAcc; overload; var
  p: PModel;
begin
  foldl(reverse(start), dispatcher, acc);
  result := acc;
end;

function foldr(start: PModel; dispatcher: FoldDispatcher): FoldAcc; overload; var
  p: PModel;
begin
  result := foldr(start, dispatcher, result);
end;

{ Pairs }
function pairs(start: PModel; disp: PairsDispatcher): PModel; var
  p1, p2: PModel;
begin
  while (start <> nil) do begin // @CYCLE
    p2 := start;
    p1 := p2^.p;
    
    start := start^.n;

    disp(p1, p2);
  end;
  result := start;
end;

procedure add(var p: PModel; ins: PointerModel); var
  ap, np: PModel;
begin
  //ins := modelCopy(oldins as TObject) as PointerModel;
  ins.n := nil;
  ins.p := nil;
      
  new(ap);
  ap^ := ins;

  if (p = nil) then begin
    new(p);
    p^ := ins;
  end else begin
    np := last(p); // get last element
    np^.n := ap; // point last next to new 
    ap^.p := np; // poins new prev to last
  end;    

end;

procedure delete(var start: PModel; index: integer); overload; var
  p: PModel;
begin      
  p := get(start, index);
  if (p^.p <> nil) and (p^.n <> nil) then begin // middle
    p^.p^.n := p^.n; // drop middle element
    p^.n^.p := p^.p;
  end else if (p^.p = nil) and (p^.n <> nil) then begin // first
    start := p^.n; // make next as start
    start.p := nil; // and nil prev (pointer to rec)
  end else if (p^.p <> nil) and (p^.n = nil) then begin // last
    p^.p^.n := nil; // nil pointer to rec
  end else begin // only one
    start := nil; // nil start
  end;
  dispose(p);
end;

procedure delete(var start: PModel; p: PModel); overload; 
begin      
  if (p^.p <> nil) and (p^.n <> nil) then begin // middle
    p^.p^.n := p^.n; // drop middle element
    p^.n^.p := p^.p;
  end else if (p^.p = nil) and (p^.n <> nil) then begin // first
    start := p^.n; // make next as start
    start.p := nil; // and nil prev (pointer to rec)
  end else if (p^.p <> nil) and (p^.n = nil) then begin // last
    p^.p^.n := nil; // nil pointer to rec
  end else begin // only one
    start := nil; // nil start
  end;
  dispose(p);
end;

function reverse(start: PModel): PModel; overload; var
  p: PModel;
begin
  result := nil;
  p := last(start);
  while (p <> nil) do begin // @CYCLE
    add(result, copyModel(p^) as PointerModel);
    p := p^.p;
  end;
end;

function reverse(start: PModel; clnFn: CloneFunc): PModel; overload; var
  p: PModel;
begin
  result := nil;
  p := last(start);
  while (p <> nil) do begin // @CYCLE
    add(result, clnFn(p^) as PointerModel);
    p := p^.p;
  end;
end;

function last(start: PModel): PModel; begin
  result := get(start, -1);
end;

function first(start: PModel): PModel; begin
  result := get(start, 0);
end;

function get(start: PModel; i: integer): PModel; begin
  result := start;
  while (start <> nil) do begin // @CYCLE
    result := start;
    if (i = 0) then exit;
    start := start^.n;
    dec(i);
  end;
end;

function count(start: PModel): integer; var
  acc: FoldAcc;
  procedure disp(p: PModel; var acc: FoldAcc); begin
    inc(acc.int[0]);
  end;
begin
  acc.int[0] := 0;
  foldl(start, @disp, acc);
  result := acc.int[0];
end;

function empty(start: PModel): boolean; begin
  result := start = nil;
end;

function pos(start: PModel; needle: PModel): integer; overload; begin
  result := 0;
  while (start <> nil) and (start <> needle) do begin // @CYCLE
    start := start^.n;

    inc(result);
  end;
end;


function search(database: PModel; term: string; disp: SearchDispatcher): PModel; var
  acc: FoldAcc;
  procedure searchDisp(pins: PModel; var acc: FoldAcc); var
    re: TRegExpr;
    res: SearchResult;
    resp: PModel;
    disp: SearchDispatcher;
  begin
    re := TRegExpr.Create;

    disp := acc.pointer[0];
    re.InputString := disp(pins);
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
begin
  acc.p[0] := nil;
  acc.pointer[0] := @disp;
  acc.str[0] := term;

  foldl(database, @searchDisp, acc);
  result := acc.p[0];                      
end;

function filter(start: PModel; disp: FilterDispatcher): PModel; var
  acc: FoldAcc;
  p: PModel;

  procedure sdisp(p: PModel; var acc: FoldAcc); var
    disp: FilterDispatcher;
  begin
    disp := acc.pointer[0];
    if (disp(p)) then
      add(acc.p[0], SearchResult.new(p));
  end;
begin
  acc.pointer[0] := @disp;
  acc.p[0] := @start;

  foldl(start, @sdisp, acc);
end;
end.
