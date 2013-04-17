unit LeagueWorkflow;
interface
  uses Models, FuncModel, StdCtrls, ClubWorkflow, PlayerWorkflow, RegExpr, UnitLog;
  
  procedure lgShowInBox(database: PModel; lb: TListBox);
  procedure lgAdd(var database: PModel; name: string);
  procedure lgDrop(var database: PModel);
  procedure lgDelete(var database: PModel; index: integer);
  function lgSearch(database: PModel; term: string): PModel;
  procedure addTestData(var database: PModel); 

implementation

  type
    ShowDisp = class(FoldDispatcher)
      procedure dispatch(pins: PModel; var acc: FoldAcc); override;
    end;
    DropDisp = class(EachDispatcher)
      procedure dispatch(pins: PModel); override;
    end;
    SearchDisp = class(SearchDispatcher)
      function dispatch(pins: PModel): string; override;
    end;

  { lgSearch }
  function SearchDisp.dispatch(pins: PModel): string; begin
    result := (pins^ as League).name;
  end;
  function lgSearch(database: PModel; term: string): PModel; begin
    result := search(database, term, SearchDisp.Create);
  end;
   
  { lgShowListInBox }
  procedure ShowDisp.dispatch(pins: PModel; var acc: FoldAcc); begin
    (acc.tobject[0] as TListBox).Items.Append(
      (pins^ as League).str()
    );
    
  end;
  procedure lgShowInBox(database: PModel; lb: TListBox); var
    acc: FoldAcc;
  begin
    lb.Clear();
    acc.tobject[0] := lb;
    foldl(database, showDisp.Create, acc);
  end;

  { lgAdd }
  procedure lgAdd(var database: PModel; name: string); var
    lg: League;
    p: PModel;
  begin
    lg := League.new(name);
    if (empty(database)) then begin
      new(p);
      p^ := lg;
      database := p;
    end else 
      add(last(database), lg);
  end;

  { lgDrop }
  procedure DropDisp.dispatch(pins: PModel); begin
    if (pins^.n <> nil) then begin
      dispose(pins^.n);
    end;
  end;
  procedure lgDrop(var database: PModel); begin
    eachr(database, DropDisp.Create);
    dispose(database);
    database := nil;
  end;

  { lgDelete }
  procedure lgDelete(var database: PModel; index: integer); var
    lg: League;
    cb: Club;
  begin
    //lg := get(database, index)^ as League;
    each((get(database, index)^ as League).clubs, CBDelDisp.Create);
    
    delete(database, index);
  end;
  
  { addTestData }
  procedure addTestData(var database: PModel); var
    bundesliga: League;
    pclubs: PModel;
    pplayers: PModel;         
  begin
    bundesliga := League.new('Bundesliga');

    new(pclubs);                                                      
    pclubs^ := Club.new('Manchester', bundesliga);
    add(pclubs, Club.new('Milan', bundesliga));

    new(pplayers);
    pplayers^ := Player.new('Roonie', pclubs^ as Club);
    add(pplayers, Player.new('Ronaldo', pclubs^ as Club));
    (pclubs^ as Club).players := pplayers;

    bundesliga.clubs := pclubs;
  
    new(database);
    database^ := bundesliga;
  end;
end.
