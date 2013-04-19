unit CLI;

interface
  uses UnitLog;
  const C_EXIT = 1;
  const C_SAVE = 2;
  const C_SEARCH = 3;
  const C_HELP = 4;
  const C_TESTDATA = 5;
  const C_REMOVE = 6;
  const C_TEST = 7;
  type
    TCommandArgs = array[0..100] of string;
    TCommand = integer;
    TCommandTask = record 
      cmd: TCommand;
      args: TCommandArgs;
      len: integer;
    end;

  function parseStr(str: string): TCommandTask;                                     

implementation

function recognizeCommand(s: string): TCommand; begin
  result := -1;
  {ls} if (s = 'exit') or (s = 'q') then
    result := C_EXIT
  else if (s = '/') then
    result := C_SEARCH
  else if (s = 'w') or (s = 'save') then
    result := C_SAVE
  else if (s = 'help') then
    result := C_HELP
  else if (s = 'td') then
    result := C_TESTDATA
  else if (s = 'remove') then
    result := C_REMOVE
  else if (s = 'test') then
    result := C_TEST
  ;
end; 

function parseStr(str: string): TCommandTask; var
  cmd: TCommand;
  args: TCommandArgs;
  buff: string;
  i, argsi: integer;
  ch: string;
begin
  i := 1;
  argsi := 0;
  cmd := 0;
  str := str + ' ';
  
  while (i < length(str) + 2) do begin
    ch := copy(str, i, 1);

    if (ch = ' ') or (i = length(str)) then begin
      if (cmd = 0) then begin
        cmd := recognizeCommand(buff); 
      end else begin
        args[argsi] := buff;
        inc(argsi);
      end;
      buff := '';
    end else begin
      buff := buff + ch;
    end;
    inc(i);
  end;

  result.cmd := cmd;
  result.args := args;
  result.len := argsi;
end;

end.
