unit Models;

interface
type

  PModel = ^ PointerModel;
  
  PointerModel = class
    n: PModel;
    p: PModel;
  end;
    
  SearchResult = class(PointerModel)
    pointer: PModel;

    constructor new(p: PModel);
  end;
  
  League = class(PointerModel)
    name: string;
    clubs: PModel;
    
    constructor new(name: string);
    function str(): string;
  end;

  Club = class(PointerModel)
    name: string;
    players: PModel;
    lg: League;

    constructor new(name: string; lg: League);
    function str(): string;    
  end;

  Player = class(PointerModel)
    name: string;
    club: Club;

    constructor new(name: string; club: Club);
    function str(): string;
  end;
  
implementation

  constructor SearchResult.new(p: PModel); begin
    self.pointer := p;
  end;

  constructor League.new(name: string); begin
    self.name := name;
  end;

  function League.str(): string; begin
    result := self.name;
  end;

  constructor Club.new(name: string; lg: League); begin
    self.name := name;
    self.lg := lg;
  end;

  function Club.str(): string; begin
    result := self.name;
  end;
  constructor Player.new(name: string; club: Club); begin
    self.name := name;
    self.club := club;
  end;

  function Player.str(): string; begin
    result := self.name;
  end;
end.
