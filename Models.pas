unit Models;

interface
type

  PModel = ^ PointerModel;
  
  PointerModel = class
    n: PModel;
    p: PModel;

    procedure assign(pm: PointerModel); virtual; abstract;
  end;
    
  SearchResult = class(PointerModel)
    pointer: PModel;

    procedure assign(sr: SearchResult);
    constructor new(p: PModel);
  end;
  
  League = class(PointerModel)
    name: string;
    clubs: PModel;
    head: string;
    
    procedure assign(lg: League);
    constructor new(name: string);
    function str(): string;
  end;

  Club = class(PointerModel)
    name: string;
    players: PModel;
    lg: League;
    head: string;
    president: string;
    captain: string;
    sponsor: string;

    trainer_name, trainer_spec, trainer_exp, trainer_qua: string;

    procedure assign(cb: Club);
    constructor new(name: string; lg: League);
    function str(): string;    
  end;

  Player = class(PointerModel)
    name: string;
    club: Club;
    amplua: string;
    salary: string;
    contract: string;

    procedure assign(pl: Player);
    constructor new(name: string; club: Club);
    function str(): string;
  end;

  function copyModel(p1: TObject): TObject;
  
implementation

  constructor SearchResult.new(p: PModel); begin
    self.pointer := p;
  end;
  
  procedure SearchResult.assign(sr: SearchResult);
   begin
    self.pointer := sr.pointer;
  end;

  constructor League.new(name: string); begin
    self.name := name;
  end;

  procedure League.assign(lg: League); begin
    self.name := lg.name;
    self.clubs := lg.clubs;
  end;
  
  function League.str(): string; begin
    result := self.name;
  end;

  constructor Club.new(name: string; lg: League); begin
    self.name := name;
    self.lg := lg;
  end;

  procedure Club.assign(cb: Club); begin
    self.name := cb.name;
    self.players := cb.players;
    self.lg := cb.lg;
  end;

  function Club.str(): string; begin
    result := self.name;
  end;
  
  constructor Player.new(name: string; club: Club); begin
    self.name := name;
    self.club := club;
  end;

  procedure Player.assign(pl: Player); begin
    self.name := pl.name;
    self.club := pl.club;
  end;

  function Player.str(): string; begin
    result := self.name;
  end;

  function copyModel(p1: TObject): TObject; var
    cls: TClass;
  begin
    result := p1.ClassType.Create() as TObject;
    if (p1.ClassType = League) then
      (result as League).assign(p1 as League)
    else if (p1.ClassType = Club) then
      (result as Club).assign(p1 as Club)
    else if (p1.ClassType = Player) then
      (result as Player).assign(p1 as Player)
    else if (p1.ClassType = SearchResult) then
      (result as SearchResult).assign(p1 as SearchResult);
    ;
  end;
end.
