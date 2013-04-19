unit TestCases;

interface
  uses SysUtils;
  type
    Logger = procedure(s: string);
    
    TestEnv = class
      logger: Logger;
      assertNum: integer;
      
      procedure l(s: string);
      procedure preTest();
      procedure postTest();
      procedure preAssert();
      procedure postAssertFailed();
      procedure postAssertSuccess();
      procedure assertEquals(var r: boolean; a, b: string); overload;
      procedure assertEquals(var r: boolean; a, b: integer); overload;
      procedure assertUnEquals(var r: boolean; a, b: string); overload;
      procedure assertUnEquals(var r: boolean; a, b: integer); overload;
      procedure assertTrue(var r: boolean; a: boolean); overload;
      procedure assertFalse(var r: boolean; a: boolean); overload;
    end;
    
    TestFunc = function(tc: TestEnv): boolean;
    
    PTTest = ^TTest;
    TTest = record
      test: TestFunc;
      name: string;

      n: PTTest;
    end;
    
    TestCase = class
      tests: PTTest;
      logger: Logger;
      result: boolean;
      env: TestEnv;
      name: string;
                                  
      constructor create(name: string; env: TestEnv; fnc: Logger);
      
      procedure run();
      procedure success(test: TTest);
      procedure fail(test: TTest);
      procedure add(name: string; fnc: TestFunc);
    end;

    
implementation
  procedure TestEnv.preTest(); begin
    self.assertNum := 0;
  end;
  procedure TestEnv.postTest(); begin

  end;
  procedure TestEnv.preAssert(); begin
    inc(self.assertNum);
  end;
  procedure TestEnv.postAssertSuccess(); begin

  end;
  procedure TestEnv.postAssertFailed(); begin

  end;

  procedure TestEnv.l(s: string); begin
    self.logger('        ASSERT ' + intToStr(self.assertNum) + ' FAILED: ' + s);
  end;

  procedure TestEnv.assertEquals(var r: boolean; a, b: string); begin
    self.preAssert();
    r := r and (a = b);
    if (a <> b) then begin
      self.postAssertFailed();
      self.l('' + a + ' <> ' + b);
    end else self.postAssertSuccess();
  end;
  procedure TestEnv.assertEquals(var r: boolean; a, b: integer); begin  
    self.preAssert();
    r := r and (a = b);
    if (a <> b) then begin 
      self.postAssertFailed();
      self.l('' + intToStr(a) + ' <> ' + intToStr(b));
    end else self.postAssertSuccess();
  end;
  
  procedure TestEnv.assertUnEquals(var r: boolean; a, b: string); begin
    self.preAssert();
    r := r and (a <> b);
    if (a <> b) then begin
      self.postAssertFailed();
      self.l('' + (a) + ' = ' + (b));  
    end else self.postAssertSuccess();
  end;
  procedure TestEnv.assertUnEquals(var r: boolean; a, b: integer); begin
    self.preAssert();
    r := r and (a <> b);
    if (a <> b) then begin
      self.postAssertFailed();
      self.l('' + intToStr(a) + ' = ' + intToStr(b));
    end else self.postAssertSuccess();
  end;
  
  procedure TestEnv.assertTrue(var r: boolean; a: boolean); begin 
    self.preAssert();
    r := r and (a);
    if (not a) then begin
      self.postAssertFailed();
      self.l('false');   
    end else self.postAssertSuccess();
  end;
  procedure TestEnv.assertFalse(var r: boolean; a: boolean); begin 
    self.preAssert();
    assertTrue(r, not a);
    if (a) then begin
      self.postAssertFailed();
      self.l('true');
    end else self.postAssertSuccess();
  end;               

  constructor TestCase.create(name: string; env: TestEnv; fnc: Logger); begin
    self.logger := @fnc;
    self.env := env;
    self.env.logger := @fnc;
    self.tests := nil;
    self.result := true;
    self.name := name;
  end;

  procedure TestCase.success(test: TTest); begin
  end;

  procedure TestCase.fail(test: TTest); begin
  end;
  
  procedure TestCase.run(); var
    p: PTTest;
    fnc: TestFunc;
  begin
    self.logger('Testcase ' + self.name + ' running:');
    p := self.tests;
    while (p <> nil) do begin
      fnc := p^.test;
      //self.logger('    Test ' + p^.name + ':');
      self.env.preTest();
      if (fnc(self.env)) then
        self.success(p^)
      else begin
        self.fail(p^);
        self.result := false;
      end;
      self.env.postTest();      
      p := p^.n;
    end;
    if (self.result) then
      self.logger('    SUCCESS')
    else
      self.logger('    FAILED');
  end;

  procedure TestCase.add(name: string; fnc: TestFunc); var
    p, last, pnew: PTTest;
  begin
    p := self.tests;
    last := nil;
    while (p <> nil) do begin
      last := p;
      p := p^.n;
    end;        

    new(pnew);
    pnew^.test := @fnc;
    pnew^.name := name;
    pnew^.n := nil;

    if (last = nil) then begin
      new(self.tests);
      self.tests^ := pnew^;
    end else
      last^.n := pnew;    
  end;
end.

