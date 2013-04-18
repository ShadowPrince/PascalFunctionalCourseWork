unit ClubWorkflow;

interface
  uses FuncModel, Models, StdCtrls, Dialogs, UnitLog, PlayerWorkflow;
                                        
  procedure CBDelDisp(pins: PModel); 
  
  procedure cbShowInBox(start: PModel; lb: TListBox);
  procedure cbAdd(lg: League; name: string);
  procedure cbDelete(var start: PModel; index: integer);
  function cbSearch(start: PModel; term: string): PModel;

implementation

  procedure CBDelDisp(pins: PModel); var
    cb: Club;
  begin
    cb := pins^ as Club;
    each(cb.players, @PlDelDisp);
    
    l('Disposed club at cbwf ' + cb.str());
    dispose(pins);
  end;

  { cbSearch }
  function SearchDisp(pins: PModel): string; begin
    result := (pins^ as Club).name;
  end;
  function cbSearch(start: PModel; term: string): PModel; begin
    result := search(start, term, @SearchDisp);
  end;
  
  { cbShow }
  procedure ShowDisp(pins: PModel; var acc: FoldAcc); begin
    (acc.tobject[0] as TListBox).Items.Add(
      (pins^ as Club).str()
    );
  end;
  procedure cbShowInBox(start: PModel; lb: TListBox); var
    acc: FoldAcc;
  begin
    lb.Clear();
    acc.tobject[0] := lb;
    foldl(start, @ShowDisp, acc);
  end;

  { cbAdd }
  procedure cbAdd(lg: League; name: string); var
    cb: Club;
    p: PModel;
  begin
    cb := Club.new(name, lg);
    if (empty(lg.clubs)) then begin
      new(p);
      p^ := cb;
      lg.clubs := p;
    end else
      add(lg.clubs, cb);
  end;

  { cbDelete }
  procedure cbDelete(var start: PModel; index: integer); begin
    each((get(start, index)^ as Club).players, @PlDelDisp);

    l('Deleted cb ' + (get(start, index)^ as Club).str() + ' at cbwf');
    delete(start, index);
  end;
end.
