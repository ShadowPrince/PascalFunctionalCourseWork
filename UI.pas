unit UI;
interface
  uses Dialogs;

  function inputBoxUntil(p1, p2, p3: string): string;
  
implementation

  function inputBoxUntil(p1, p2, p3: string): string;
  begin
    Result := InputBox(p1, p2, p3);
  end;
end.
