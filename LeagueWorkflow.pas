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
  { lgSearch }
  function lgSearch(database: PModel; term: string): PModel; var
    x: boolean;
    function SearchDisp(pins: PModel): string; begin
      result := (pins^ as League).name;
    end;
  begin
    result := search(database, term, @SearchDisp);
  end;
   
  { lgShowListInBox }
  procedure lgShowInBox(database: PModel; lb: TListBox);
    procedure ShowDisp(pins: PModel; var acc: FoldAcc); begin
      (acc.tobject[0] as TListBox).Items.Append(
        (pins^ as League).str()
      );
    end;
  var
    acc: FoldAcc;
  begin
    lb.Clear();
    acc.tobject[0] := lb;
    foldl(database, @showDisp, acc);
  end;

  { lgAdd }
  procedure lgAdd(var database: PModel; name: string); var
    lg: League;
  begin
    lg := League.new(name);
    add(database, lg);
  end;

  { lgDrop }
  procedure lgDrop(var database: PModel);
    procedure DropDisp(pins: PModel); begin
      if (pins^.n <> nil) then begin
        dispose(pins^.n);
      end;
    end;
  begin
    each(reverse(database), @DropDisp);
    dispose(database);
    database := nil;
  end;

  { lgDelete }
  procedure lgDelete(var database: PModel; index: integer); begin
    l('Disposed lg ' + (get(database, index)^ as League).str() + ' disposed at lgwf');
    lOffsetPlus();
    each((get(database, index)^ as League).clubs, @CBDelDisp);
    lOffsetMinus();    
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
