unit ClubWorkflow;

interface
  uses FuncModel, Models, StdCtrls, Dialogs, UnitLog, PlayerWorkflow;
  type
    CBDelDisp = class(EachDispatcher)
      procedure dispatch(pins: PModel); override;
    end;

  procedure cbShowInBox(start: PModel; lb: TListBox);
  procedure cbAdd(lg: League; name: string);
  procedure cbDelete(var start: PModel; index: integer);
  function cbSearch(start: PModel; term: string): PModel;

implementation
  type
    ShowDisp = class(FoldDispatcher) 
      procedure dispatch(pins: PModel; var acc: FoldAcc); override;
    end;
    SearchDisp = class(SearchDispatcher)
      function dispatch(pins: PModel): string; override;
    end;

  procedure CBDelDisp.dispatch(pins: PModel); var
    cb: Club;
    cbc: Club;
  begin
    cbc := pins^ as Club;
    if (cbc.players <> nil) then begin
      eachr(cbc.players, PlDelDisp.Create);
      l('Disposed player at clwf ' + (cbc.players^ as Player).str());
      dispose(cbc.players);
    end;
    if (pins^.n <> nil) then begin
      cb := pins^.n^ as Club;
      l('Disposed club at clubwf ' + cb.str);
  
      dispose(pins^.n);
    end;
  end;

  { cbSearch }
  function SearchDisp.dispatch(pins: PModel): string; begin
    result := (pins^ as Club).name;
  end;
  function cbSearch(start: PModel; term: string): PModel; begin
    result := search(start, term, SearchDisp.Create);
  end;
  
  { cbShow }
  procedure ShowDisp.dispatch(pins: PModel; var acc: FoldAcc); begin
    (acc.tobject[0] as TListBox).Items.Add(
      (pins^ as Club).str()
    );
  end;
  procedure cbShowInBox(start: PModel; lb: TListBox); var
    acc: FoldAcc;
  begin
    lb.Clear();
    acc.tobject[0] := lb;
    foldl(start, ShowDisp.Create, acc);
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
    if ((get(start, index)^ as Club).players <> nil) then begin
      eachr((get(start, index)^ as Club).players, PlDelDisp.Create);
      l('Disposed player at clwf ' + (((get(start, index)^ as Club).players^ as Player).str()));
      delete((get(start, index)^ as Club).players, 0);
    end;
    delete(start, index);
  end;
end.
