unit FuncModelTest;
interface
  uses FuncModel, SysUtils, TestCases, Models;
  procedure testFuncModel(logger: Logger);
  
implementation

type
  Envi = class(TestEnv)
    db: PModel;
  end;
  Model = class(PointerModel)
    data: string;
    constructor new(data: string);
  end;

function testModelCopy(old: TObject): TObject; begin
  result := Model.new((old as Model).data);
end;
  
constructor Model.new(data: string); begin
  self.data := data;
end;
  
procedure testFuncModel(logger: Logger); var
  tc: TestCase;
  env: Envi;
  
  function testAdd(env: Envi): boolean; begin
    result := true;
    // add on empty
    add(env.db, Model.new('tai'));
    env.assertEquals(result, (env.db^ as Model).data, 'tai');
    
    // add on not empty
    add(env.db, Model.new('tai2'));
    env.assertEquals(result, (get(env.db, 1)^ as Model).data, 'tai2'); 
    
    // add on not empty
    add(env.db, Model.new('tai3'));
    env.assertEquals(result, (get(env.db, 2)^ as Model).data, 'tai3'); 
  end;
  
  function testAdditional(env: Envi): boolean; var
    db: PModel;
  begin
    result := true;
    db := nil;
    add(db, Model.new('tai'));
    add(db, Model.new('tai2'));
    // getters
    env.assertEquals(result, (get(db, 1)^ as Model).data, 'tai2');
    env.assertEquals(result, (last(db)^ as Model).data, 'tai2');
    env.assertEquals(result, (first(db)^ as Model).data, 'tai');
    // checkers
    env.assertFalse(result, empty(db));
    env.assertEquals(result, count(db), 2);
    // pos
    env.assertEquals(result, pos(db, get(db, 0)), 0);
    env.assertEquals(result, pos(db, last(db)), 1);
    // mod
    env.assertEquals(result, (get(reverse(db, @testModelCopy), 0)^ as Model).data, 'tai2');
    env.assertEquals(result, count(reverse(db, @testModelCopy)), 2);
  end;   

  function testEach(env: Envi): boolean; var
    db: PModel;
    procedure disp(pins: PModel); begin (pins^ as Model).data := 'data'; end;
    procedure disp2(pins: PModel); begin (pins^ as Model).data := 'data2'; end;
  begin
    result := true;
    db := nil;
    add(db, Model.new('data'));
    add(db, Model.new('data2'));
    // each
    each(env.db, @disp);
    env.assertEquals(result, (db^ as Model).data, 'data');
  end;

  function testFold(env: Envi): boolean; var
    db: PModel;
    procedure d(pins: PModel; var acc: FoldAcc); begin
      acc.str[0] := acc.str[0] + (pins^ as Model).data;
    end;
  begin
    result := true;
    db := nil;
    add(db, Model.new('data'));
    add(db, Model.new('data2'));
    
    // fold
    env.assertEquals(result, foldl(db, @d).str[0], 'datadata2');
    // right fold
    env.assertEquals(result, foldl(reverse(db, @testModelCopy), @d).str[0], 'data2data');
  end;

  function testDelete(env: Envi): boolean; var
    db: PModel;
  begin
    result := true;
    db := nil;
    add(db, Model.new('data'));
    add(db, Model.new('data2'));

    // delete first
    delete(db, 0);
    env.assertEquals(result, (get(db, 0)^ as Model).data, 'data2');
    env.assertEquals(result, count(db), 1);

    add(db, Model.new('data3'));
    // delete first by pointer
    delete(db, db);
    env.assertEquals(result, (get(db, 0)^ as Model).data, 'data3');
    env.assertEquals(result, count(db), 1);

    add(db, Model.new('data4'));
    // delete last 
    delete(db, 1);                         
    env.assertEquals(result, (get(db, 0)^ as Model).data, 'data3');
    env.assertEquals(result, count(db), 1);

    add(db, Model.new('data5'));
    // delete last by pointer
    delete(db, last(db));                         
    env.assertEquals(result, (get(db, 0)^ as Model).data, 'data3');
    env.assertEquals(result, count(db), 1);

    add(db, Model.new('data6'));
    add(db, Model.new('data7'));
    // delete mid
    delete(db, 1);
    env.assertEquals(result, (last(db)^ as Model).data, 'data7');
    env.assertEquals(result, count(db), 2);
    
    add(db, Model.new('data7'));
    // delete mid by pointer
    delete(db, get(db, 1));
    env.assertEquals(result, (first(db)^ as Model).data, 'data3');
    env.assertEquals(result, count(db), 2);
  end;
  function testSearch(env: TestEnv): boolean; var
    db, res: PModel;
    function disp(pins: PModel): string; begin
      result := (pins^ as Model).data;
    end;
  begin
    result := true;
    db := nil;

    add(db, Model.new('data'));
    add(db, Model.new('data2'));
    add(db, Model.new('something'));
    add(db, Model.new('something2'));

    res := search(db, 'data', @disp);
    env.assertEquals(result, count(res), 2);
    env.assertEquals(result, ((first(res)^ as SearchResult).pointer^ as Model).data, 'data');
    
    res := search(db, 'something', @disp);
    env.assertEquals(result, count(res), 2);                                                 
    env.assertEquals(result, ((last(res)^ as SearchResult).pointer^ as Model).data, 'something2');
    
    res := search(db, '57', @disp);
    env.assertTrue(result, empty(res));
  end;
  function testPairs(env: TestEnv): boolean; var
    db: PModel;
    procedure disp(p1, p2: PModel); begin
      if (p1 <> nil) and (p2 <> nil) then begin
        if ((p1^ as Model).data = (p2^ as Model).data) then
          delete(p1, p2);
      end;
    end;
  begin
    result := true;
    db := nil;
    
    add(db, Model.new('data'));
    add(db, Model.new('data'));
    add(db, Model.new('something'));
    add(db, Model.new('something'));

    // unique
    pairs(db, @testPairs);
    env.assertEquals(result, count(db), 2);
  end;
begin
  env := Envi.Create();
  env.db := nil;
  
  tc := TestCase.create('Func', env, @logger);
  tc.add('TestAdd', @testAdd);
  tc.add('TestAdditional', @testAdditional);  
  tc.add('TestEach', @testEach);
  tc.add('TestFold', @testFold);
  tc.add('TestDelete', @testDelete);
  tc.add('TestSearch', @testSearch);
  
  tc.run();
end;
   
end.
