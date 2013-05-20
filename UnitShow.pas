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
    Edit4: TEdit;
    Edit5: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure save(t: integer; pins: PModel);
    procedure show(t: integer; pins: PModel);
    procedure hide();
    procedure showNum(n: integer);
    function activeWithChilds(): boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrShow.showNum(n: integer); var i, labels, edits: integer;
begin
  labels := n;
  edits := n;
  for i := 0 to self.ComponentCount - 1 do begin
    if (self.Components[i].ClassType = TEdit) then if (edits > 0) then begin
      (self.Components[i] as TEdit).Visible := true;
      (self.Components[i] as TEdit).Text := '';
      dec(edits);
    end;
    if (self.Components[i].ClassType = TLabel) then if (labels > 0) then begin
      (self.Components[i] as TLabel).Visible := true;
      (self.Components[i] as TLabel).Caption := '';
      dec(labels);
    end;
  end;
end;

function TFrShow.activeWithChilds(): boolean; var
  i: integer;
begin
  result := false;
  if (self.Focused) then begin 
    result := true;
    exit;
  end;
  for i := 0 to self.ComponentCount - 1 do begin
    if (self.Components[i].ClassType = TEdit) and (self.Components[i] as TEdit).Focused then begin
      result := true;
      break;
    end;
  end;
end;

procedure TFrShow.hide(); var i: integer;
begin
  for i := 0 to self.ComponentCount - 1 do begin
    if (self.Components[i].ClassType = TEdit) then
      (self.Components[i] as TEdit).Visible := false;
    if (self.Components[i].ClassType = TLabel) then
      (self.Components[i] as TLabel).Visible := false;    
  end;
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
        lg.head := Edit2.Text;
      end;
    end;
    1: begin // Club
      cb := (pins^ as Club);

      with fr do begin
        cb.name := Edit1.Text; 
        cb.head := Edit2.Text;
        cb.president := Edit3.Text;
        cb.captain := Edit4.Text;
        cb.sponsor := Edit5.Text;
        cb.trainer_name := Edit6.Text;
        cb.trainer_exp := Edit7.Text;
        cb.trainer_qua := Edit8.Text;
      end;
    end;
    2: begin // Player
      pl := (pins^ as Player);

      with fr do begin
        pl.name := Edit1.Text;
        pl.salary := Edit4.Text;
        pl.contract := Edit3.Text;
        pl.amplua := Edit2.Text;
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
  fr.hide();
  
  if (pins = nil) then begin
    fr.Visible := false;
    exit;
  end else fr.Visible := true;

  case t of
    0: begin // League
      lg := (pins^ as League);

      with fr do begin
        fr.showNum(2);
        Label1.Caption := 'Name:';
        Edit1.Text := lg.name;

        Label2.Caption := 'Headq:';
        Edit2.Text := lg.head;
      end;
    end;
    1: begin // Club
      cb := (pins^ as Club);

      with fr do begin
        fr.showNum(8);
        
        Label1.Caption := 'Name:';
        Edit1.Text := cb.name;
        
        Label2.Caption := 'Headq:';
        Edit2.Text := cb.head;
        
        Label3.Caption := 'President:';
        Edit3.Text := cb.president;
        
        Label4.Caption := 'Captain:';
        Edit4.Text := cb.captain;

        Label5.Caption := 'Sponsor:';
        Edit5.Text := cb.sponsor;

        Label6.Caption := 'Trainer:';
        Edit6.Text := cb.trainer_name;

        Label7.Caption := 'Trainer exp:';
        Edit7.Text := cb.trainer_exp;

        Label8.Caption := 'Trainer qua:';
        Edit7.Text := cb.trainer_qua;        
      end;
    end;
    2: begin // Player
      pl := (pins^ as Player);

      with fr do begin
        showNum(4);
        Edit1.Text := pl.name;
        Label1.Caption := 'Name:';

        Label2.Caption := 'Amplua:';
        Edit2.Text := pl.amplua;

        Label4.Caption := 'Salary:';
        Edit4.Text := pl.salary;

        Label3.Caption := 'Contract:';
        Edit3.Text := pl.contract;
      end;
    end;
  end;
end;

end.
