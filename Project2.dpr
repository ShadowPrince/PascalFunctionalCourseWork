program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {FMain},
  Models in 'Models.pas',
  FuncModel in 'FuncModel.pas',
  LeagueWorkflow in 'LeagueWorkflow.pas',
  UI in 'UI.pas',
  ClubWorkflow in 'ClubWorkflow.pas',
  UnitLog in 'UnitLog.pas' {FLog},
  CLI in 'CLI.pas',
  UnitHelp in 'UnitHelp.pas' {FHelp},
  UnitShow in 'UnitShow.pas' {FrShow: TFrame},
  PlayerWorkflow in 'PlayerWorkflow.pas',
  TestCases in 'TestCases.pas',
  FuncModelTest in 'FuncModelTest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFLog, FLog);
  Application.CreateForm(TFHelp, FHelp);
  Application.Run;
end.
