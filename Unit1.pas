unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Models, FuncModel, StdCtrls, 
  
  LeagueWorkflow, PlayerWorkflow, UI, CLI, ClubWorkflow, UnitLog, UnitHelp, UnitShow, UnitFrShowLg,
  FuncModelTest, DB;

type
  TFMain = class(TForm)
    LBLeague: TListBox;
    LBClub: TListBox;
    ETerm: TEdit;
    FrShow: TFrShow;
    LBPlayer: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure LBLeagueClick(Sender: TObject);
    procedure LBClubClick(Sender: TObject);
    procedure LBPlayerClick(Sender: TObject);
    procedure ETermKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;
  KBHook: HHook;
  database: PModel;
  selLgNum, selCbNum, selPlNum, selCat: integer;
  searchRes: PModel;
  searchCat, searchCur: integer;
  function keyboardHook(code: integer; word: word; long: longint): longint; stdcall;
  procedure updateView();
  procedure actionTestData();
  function selLgPointer(): PModel;
  function selCbPointer(): PModel;
  function selPlPointer(): PModel;
  procedure actionSearchMove();
  procedure actionUp();
  procedure actionDown();
  procedure startup();

implementation

{$R *.dfm}

{ selection Helpers }

procedure TFMain.LBLeagueClick(Sender: TObject); begin                                                                                 
  selCat := 0;
  selLgNum := FMain.LBLeague.ItemIndex;
  l('Selected lg ' + intToStr(selLgNum) + ' at ' + intToStr(integer(selLgPointer())));
  updateView();
end;

procedure TFMain.LBClubClick(Sender: TObject); begin
  selCat := 1;
  selCbNum := FMain.LBClub.ItemIndex;
  l('Selected cb ' + intToStr(selCbNum) + ' at ' + intToStr(integer(selCbPointer())));
  updateView();
end;
                            
procedure TFMain.LBPlayerClick(Sender: TObject); begin
  selCat := 2;
  selPlNum := FMain.LBPlayer.ItemIndex;
  l('Selected pl ' + intToStr(selPlNum) + ' at ' + intToStr(integer(selPlPointer())));
  updateView();  
end;


function selLgPointer(): PModel; begin
  result := get(database, selLgNum);  
end;

function selLg(): League; begin
  result := selLgPointer()^ as League;
end;

function selCbPointer(): PModel; begin
  result := get(selLg().clubs, selCbNum);
end;

function selCb(): Club; begin
  result := selCbPointer()^ as Club;
end;

function selPlPointer(): PModel; begin
  result := get(selCb().players, selPlNum);
end;

function selPl(): Player; begin
  result := selPlPointer()^ as Player;
end;

function selPointer(): PModel; begin
  case selCat of
    0: result := selLgPointer();
    1: result := selCbPointer();
    2: result := selPlPointer();
  end;
end;

function selCatPointer(): PModel; begin
  case selCat of 
    0: result := database;
    1: result := selLg().clubs;
    2: result := selCb().players;
  end;
end;
{ update view }

procedure updateView(); var
  focusLb: TListBox;
begin
  // clear interface
  with FMain do begin
    LBLeague.Clear();
    LBClub.Clear();
    LBPlayer.Clear();
     
    LBLeague.Color := clWindow;
    LBCLub.Color := clWindow;
    LBPlayer.Color := clWindow;

    FrShow.Visible := false;
  end;
  
  // focus pane
  case selCat of
    0: focusLb := FMain.LBLeague;
    1: focusLb := FMain.LBClub;
    2: focusLb := FMain.LBPlayer;
  end;
  focusLb.Color := clScrollBar; 

  if (database = nil) then 
    exit;

  // push data
  // this operation needed only if data is modified
  // but this procedure called even if cursor moved
  // not i'm too lazy to fix this
  // maybe later?
  lOffsetPlus();
  //lTimerStart('Pushing data');
  if (selLgPointer() <> nil) then begin
    lgShowInBox(database, FMain.LBLeague);
    cbShowInBox(selLg().clubs, FMain.LBClub);
    if (selCbPointer() <> nil) then begin
      plShowInBox(selCb().players, FMain.LBPlayer);
    end;
  end;
  //lTimerReport();
  lOffsetMinus();

  // set cursor
  FMain.LBLeague.ItemIndex := selLgNum;
  FMain.LBClub.ItemIndex := selCbNum;
  FMain.LBPlayer.ItemIndex := selPlNum;
  
  // show info of selected object
  FMain.FrShow.show(selCat, selPointer());
  
  // log 
  l(
    'View updated: lg=' + 
    intToStr(selLgNum) + 
    ', cl=' + 
    intToStr(selCbNum) +
    '; cat=' +
    intToStr(selCat) +
    '. Current pointer ' + 
    intToStr(integer(selPointer())) +
    ', Sel pointer ' +
    intToStr(integer(selPointer()))
  );
end;

{ actions }

procedure actionLog(); begin
  case FLog.Visible of
    true: FLog.Hide();
    false: begin
      FLog.Show();
      FLog.Top := FMain.Top + FMain.Height;
    end;
  end;
end;

procedure actionHelp(); begin
  case FHelp.Visible of
    true: FHelp.Hide();
    false: begin
      FHelp.Show();
      FHelp.Top := FMain.Top + FMain.Height;
    end;
  end;
end;
           
procedure actionSave(); begin
  FMain.FrShow.save(selCat, selPointer());

  updateView();
end;

procedure actionTestData(); begin
  addTestData(database);
  updateView();
end;

procedure actionAdd(); begin    
  case selCat of
    0: lgAdd(database, '<name>');
    1: cbAdd(selLg(), '<name>');
    2: plAdd(selCb(), '<name>');
  end;
  updateView();
  actionDown(); // @TODO: move to last

  FMain.FocusControl(FMain.FrShow.Edit1);
end;

procedure actionDelete(); begin
  lTimerStart('Deleting item under cursor');
  lOffsetPlus();
  case selCat of
    0: lgDelete(database, selLgNum);
    1: cbDelete(selLg().clubs, selCbNum);
    2: plDelete(selCb().players, selPlNum);
  end;
  lOffsetMinus();
  lTimerReport();
  actionUp();

  updateView();
end;

procedure actionSearch(term: string); begin
  searchCat := selCat;
  case selCat of
    0: begin
      searchRes := lgSearch(database, term);
      searchCur := 0;
    end;
    1: searchRes := cbSearch(selLg().clubs, term);
    2: searchRes := plSearch(selCb().players, term);
  end;
  actionSearchMove();

  l(
    'Search in ' + 
    intToStr(selCat) + 
    ' on "' + 
    term + 
    '", ' +
    intToStr(count(searchRes)) +
    ' results.'
  );
end;

procedure actionSearchMove(); var
  lb: TListBox;
begin
  l(
    'Moved search cursor to ' +
    intToStr(searchCur) +
    ' at pointer ' +
    intToStr(integer(
      (get(searchRes, searchCur)^ as SearchResult).pointer
    ))
  );

  
  case searchCat of
    0: FMain.LBLeague.ItemIndex := pos(
      database, 
      (get(searchRes, searchCur)^ as SearchResult).pointer
    );
    1: FMain.LBClub.ItemIndex := pos(
      selLg().clubs,
      (get(searchRes, searchCur)^ as SearchResult).pointer
    );
    2: FMain.LBPlayer.ItemIndex := pos(
      selCb().players,
      (get(searchRes, searchCur)^ as SearchResult).pointer
    );
  end;
    
end;

procedure actionDown(); var
  v: ^integer;
  max: integer;
begin
  case selCat of
    0: begin
      v := @selLgNum;
      max := count(database);
    end;    
    1: begin
      v := @selCbNum;
      if (selLgPointer() <> nil) then
        max := count(selLg().clubs)
      else
        max := 0;
    end;
    2: begin
      v := @selPlNum;
      if (selCbPointer() <> nil) then
        max := count(selCb().players)
      else
        max := 0;
    end;
  end;

  inc(v^);
  if (v^ > max - 1) then v^ := 0;
  
  updateView();
end;

procedure actionUp(); var
  v: ^integer;
  max: integer;
begin
  // @TODO: refactor
  case selCat of
    0: begin
      v := @selLgNum;
      max := count(database);
    end;
    1: begin
      v := @selCbNum;
      if (selLgPointer() <> nil) then
        max := count(selLg().clubs)
      else
        max := 0;
    end;
    2: begin
      v := @selPlNum;
      if (selCbPointer() <> nil) then
        max := count(selCb().players)
      else
        max := 0;
    end;
  end;

  dec(v^);
  if (v^ < 0) then v^ := max - 1;
  updateView();
end;

procedure actionSearchNext(); var
  res: SearchResult;
begin
  inc(searchCur);
  if (searchCur > count(searchRes) - 1) then
    searchCur := 0;

  actionSearchMove();
end;

procedure actionSearchPrev(); begin
  dec(searchCur);
  if (searchCur < 0) then
    searchCur := count(searchRes) - 1;

  actionSearchMove();
end;

procedure showTerm(); begin
  FMain.ETerm.Visible := true;
  FMain.FocusControl(FMain.ETerm);
  FMain.Height := FMain.Height + FMain.ETerm.Height;
end;

procedure hideTerm(); begin
  FMain.ETerm.Clear();
  FMain.Height := FMain.Height - FMain.ETerm.Height;
  FMain.ETerm.Visible := false;
end;

{ exec string command }
procedure execStrCommand(str: string); var
  task: TCommandTask;
begin
  task := parseStr(str);
  lOffsetPlus();
  l(
    'Command executed: ' + 
    intToStr(task.cmd) + 
    ' - ' + 
    arrayToStr(task.args, task.len) + 
    ' (' + str + ')'
  );

  case (task.cmd) of 
    C_EXIT: Application.Terminate;
    C_SAVE: begin
      l('Saving database to ' + task.args[0]);
      lTimerStart();
      lOffsetPlus();
      saveDb(initDb(task.args[0]), database);
      lOffsetMinus();
      lTimerReport();
    end;
    C_OPEN: begin
      l('Fetching database from ' + task.args[0]);
      lTimerStart();
      lOffsetPlus();
      openDb(initDb(task.args[0]), database);
      lOffsetMinus();
      lTimerReport();
      updateView();
    end;
    C_SEARCH: actionSearch(task.args[0]);
    C_HELP: actionHelp();
    C_TESTDATA: begin
      actionTestData();
    end;
    C_TEST: testFuncModel(@l);
    C_SEARCH_AMPLUA: begin
      searchRes := plSearchAmplua(selCb().players, task.args[0]);
      searchCur := 0;
      searchCat := selCat;
      actionSearchMove();
      l('Search amplua: ' + intToStr(count(searchRes)) + ' results');
    end;
  end;
  lOffsetMinus();
end;

{ keyboard hook }
function keyboardHook(code: integer; word: word; long: longint): longint; begin
  Result := -1;
  { special edit hook }
  if (FMain.FrShow.activeWithChilds()) then begin
    case strToInt(intToStr(word)) of
      13: begin
        actionSave();
      end;
      27: FMain.FocusControl(FMain.LBLeague);
    end;
  end;

  { if hook dont needed }
  if 
    (long < 0) 
    or 
    ((not FMain.Active) and (not FLog.Active) and (not FHelp.Active))
    or 
    (FMain.ETerm.Focused)
    or 
    (FMain.FrShow.activeWithChilds())
  then begin
    Result := 0;
    exit;
  end;
  
  { main hook }
  case strToInt(intToStr(word)) of 
    ord('A'): actionAdd();
    ord('R'): updateView();
    ord('E'): FMain.FocusControl(FMain.FrShow.Edit1);
    ord('D'): actionDelete();
    ord('G'): actionLog();
    ord('N'): actionSearchNext();
    ord('P'): actionSearchPrev();
    ord(191): actionHelp(); // ?
    ord('Q'): begin
      Application.Terminate();
    end;
    ord('J'): begin
      actionDown();
    end;
    ord('K'): begin
      actionUp();
    end;
    ord('H'): begin                       
      dec(selCat);
      if (selCat < 0) then selCat := 2;
      updateView();
    end;
    ord('L'): begin
      inc(selCat);
      if (selCat > 2) then selCat := 0;
      updateView();
    end;
    186: begin // :
      showTerm();
      FMain.ETerm.Text := ':';      
      FMain.ETerm.SelLength := 0;
      FMain.ETerm.SelStart := 1;
    end;
    //9: begin // tab
    //  inc(selCat);
    //  if (selCat > 2) then selCat := 0;
    //  updateView();
    //end;
  end;

end;

{ term keys }
procedure TFMain.ETermKeyPress(Sender: TObject; var Key: Char);
begin
  case ord(Key) of
    27: begin
      hideTerm();
    end;
    13: begin
      execStrCommand(copy(FMain.ETerm.Text, 2, length(FMain.ETerm.Text)));
      hideTerm();
    end;
  end;
end;
   
{ create }
procedure TFMain.FormCreate(Sender: TObject); begin
  KBHook := SetWindowsHookEx(WH_KEYBOARD, @keyboardHook, HInstance, GetCurrentThreadId());
end;

procedure startup(); begin
  l('Log started');
  actionTestData();
  updateView();
end;

end.
