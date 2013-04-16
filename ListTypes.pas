unit ListTypes;
interface
type
  TPRec = ^TRec;
  TRec = record
    name: string;

    n: TPRec;
    p: TPRec;
  end;

implementation

end.
