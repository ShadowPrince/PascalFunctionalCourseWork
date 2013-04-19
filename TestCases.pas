unit TestCases;

interface
  type
    TestCaseEnv = class end;
    TestFunc = function(tc: TestCaseEnv): boolean;
    Logger = procedure(s: string);
    
    PTTest = ^TTest;
    TTest = record
      test: Pointer;
      name: string;

      n: PTTest;
    end;
    TestCase = class(TestCaseEnv)
      tests: PTTest;
      logger: Logger;
      
      procedure test();
      procedure success(test: TTest);
      procedure fail(test: TTest);
      procedure setLogger(fnc: Logger);
      procedure add(name: string; fnc: TestFunc);
    end;
    
implementation
  procedure TestCase.setLogger(fnc: Logger); begin
    self.logger := @fnc;
  end;

  procedure TestCase.success(test: TTest); begin
    self.logger(
      'Test success - ' + test.name
    );
  end;

  procedure TestCase.fail(test: TTest); begin
    self.logger(
      'Test failed - ' + test.name
    );
  end;
  
  procedure TestCase.test(); var
    p: PTTest;
    fnc: TestFunc;
  begin
    p := self.tests;
    while (p <> nil) do begin
      fnc := @p^.test;
      if (fnc(self)) then
        self.success(p^)
      else
        self.fail(p^);
            
      p := p^.n;
    end;
  end;

  procedure TestCase.add(name: string; fnc: TestFunc); var
    p, last, pnew: PTTest;
  begin
    p := self.tests;
    while (p <> nil) do begin
      last := p;
      p := p^.n;
    end;        

    new(pnew);
    pnew^.test := @fnc;
    pnew^.name := name;
    pnew^.n := nil;

    last.n := pnew;            
  end;
end.

