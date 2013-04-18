{ Unit for all list actions }
unit List;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Func, ListTypes;

type
  ListRemoveDispatcher = class(FoldDispatcher)
    procedure dispatch(rec: TPRec; var acc: FoldAcc); override;
  end;
  ListDropDispatcher = class(EachDispatcher)
    procedure dispatch(rec: TPRec); override;
  end;

procedure listShowInBox(start: TPRec; box: TListBox);

procedure listRemove(var start: TPRec; index: integer);
procedure listDrop(var start: TPRec);

{ IMPLEMENTATION }
implementation

{ Show list in TListBox }
procedure listShowInBox(start: TPRec; box: TListBox);
begin
end;

{ Remove element from list }
procedure ListRemoveDispatcher.dispatch(rec: TPRec; var acc: FoldAcc);
begin
  if (acc.int[0] = acc.int[1]) then begin
    if (rec^.p <> nil) and (rec^.n <> nil) then begin // middle
      rec^.p^.n := rec^.n; // drop middle element
      rec^.n^.p := rec^.p;
    end else if (rec^.p = nil) and (rec^.n <> nil) then begin // first
      acc.prec[0] := rec^.n; // make next as start
      acc.prec[0]^.p := nil; // and nil prev (pointer to rec)
    end else if (rec^.p <> nil) then begin // last
      rec^.p^.n := nil; // nil pointer to rec
    end else begin // only one
      acc.prec[0] := nil; // nil start
    end;

    acc.prec[1] := rec;
  end;

  inc(acc.int[0]);
end;          
procedure listRemove(var start: TPRec; index: integer);
var
  acc: FoldAcc;
begin
  acc.int[0] := 0; // cycle iterator
  acc.int[1] := index; 
  acc.prec[0] := start; // start pointer
  acc.prec[1] := nil; // dispose pointer

  acc := foldl(start, ListRemoveDispatcher.Create, acc);
  
  start := acc.prec[0];
  dispose(acc.prec[1]);
end;
    
procedure ListDropDispatcher.dispatch(rec: TPRec);
begin
  if (rec^.n <> nil) then begin
    dispose(rec^.n);
  end;
end;
procedure listDrop(var start: TPRec);
begin
  eachr(start, ListDropDispatcher.Create);
  dispose(start);
  start := nil;
end;

end.
