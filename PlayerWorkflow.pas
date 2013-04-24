unit PlayerWorkflow;
interface
  uses Models, FuncModel, StdCtrls, RegExpr, UnitLog;
    
  procedure PlDelDisp(pins: PModel); 
  procedure plShowInBox(start: PModel; lb: TListBox);
  function plSearch(start: PModel; term: string): PModel;
  function plSearchAmplua(start: PModel; term: string): PModel;
  procedure plAdd(club: Club; name: string);
  procedure plDelete(var start: PModel; index: integer);
    
implementation
  procedure PlDelDisp(pins: PModel); begin
    l('Disposed player at plwf ' + (pins^ as Player).str());
    dispose(pins);
  end;

  { plSearch }
  function plSearch(start: PModel; term: string): PModel;
    function SearchDisp(pins: PModel): string; begin
      result := (pins^ as Player).name;
    end;
  begin
    result := search(start, term, @SearchDisp);
  end;

  function plSearchAmplua(start: PModel; term: string): PModel;
    function SearchDisp(pins: PModel): string; begin
      result := (pins^ as Player).amplua;
    end;
  begin
    result := search(start, term, @SearchDisp);
  end;

   
  { plShowListInBox }
  procedure plShowInBox(start: PModel; lb: TListBox); var 
    acc: FoldAcc;
    procedure ShowDisp(pins: PModel; var acc: FoldAcc); begin
      (acc.tobject[0] as TListBox).Items.Append(
        (pins^ as Player).str()
      );
    end;
  begin
    lb.Clear();
    acc.tobject[0] := lb;
    foldl(start, @showDisp, acc);
  end;

  { plAdd }
  procedure plAdd(club: Club; name: string); var
    pl: Player;
    p: PModel;
  begin
    pl := Player.new(name, Club);
    add(club.players, pl);
  end;

  { plDelete }
  procedure plDelete(var start: PModel; index: integer); begin
    l('Disposed player at plwf ' + (get(start, index)^ as Player).str());
    delete(start, index);
  end;
end.
