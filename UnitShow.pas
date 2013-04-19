unit UnitShow;

// @TODO: refactor entire
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs,

  Models, FuncModel, StdCtrls;

type                                         
  TFrShow = class(TFrame)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure save(t: integer; pins: PModel);
    procedure show(t: integer; pins: PModel);
    function activeWithChilds(): boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

function TFrShow.activeWithChilds(): boolean; begin
  result := false;
  if (self.Focused) then result := true;
  if (self.Edit1.Focused) then result := true;
  if (self.Edit2.Focused) then result := true;
  if (self.Edit3.Focused) then result := true;
end;

procedure TFrShow.save(t: integer; pins: PModel); var
  lg: League;
  cb: Club;
  pl: Player;
  fr: TFrShow;
begin
  fr := self;
  if (pins = nil) then begin
    fr.Visible := false;
    exit;
  end;

  case t of
    0: begin // League
      lg := (pins^ as League);

      with fr do begin
        lg.name := Edit1.Text;
      end;
    end;
    1: begin // Club
      cb := (pins^ as Club);

      with fr do begin
        cb.name := Edit1.Text;
      end;
    end;
    2: begin // Player
      pl := (pins^ as Player);

      with fr do begin
        pl.name := Edit1.Text;
      end;
    end;
  end;
end;

procedure TFrShow.show(t: integer; pins: PModel); var
  lg: League;
  cb: Club;
  pl: Player;
  fr: TFrShow;
begin
  fr := self;
  if (pins = nil) then begin
    fr.Visible := false;
    exit;
  end else fr.Visible := true;

  case t of
    0: begin // League
      lg := (pins^ as League);

      with fr do begin
        Label1.Caption := 'Name:';
        Edit1.Text := lg.name;
        Edit2.Visible := false;
        Edit3.Visible := false;
        Label2.Visible := false;
        Label3.Visible := false;
      end;
    end;
    1: begin // Club
      cb := (pins^ as Club);

      with fr do begin
        Edit1.Visible := true;
        Label1.Caption := 'Name:';
        Edit1.Text := cb.name;
        Edit2.Visible := false;
        Edit3.Visible := false;
        Label2.Visible := false;
        Label3.Visible := false;
      end;
    end;
    2: begin // Player
      pl := (pins^ as Player);

      with fr do begin
        Edit1.Visible := true;
        Edit1.Text := pl.name;
        Label1.Caption := 'Name:';
        Edit2.Visible := false;
        Edit3.Visible := false;
        Label2.Visible := false;
        Label3.Visible := false;
      end;
    end;
  end;
end;

end.
