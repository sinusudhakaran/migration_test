unit BKIniFiles;

//------------------------------------------------------------------------------
interface

uses
  Classes,
  IniFiles;

type
  TCommentMemIniFile = class(TMemIniFile)
  private
    fComments : TStringList;

    procedure InsertCommentsToList(var aList : TStringList);
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;

    procedure UpdateFile; override;

    property Comments : TStringList read fComments write fComments;
  end;

implementation

{ TCommentMemIniFile }
//------------------------------------------------------------------------------
procedure TCommentMemIniFile.InsertCommentsToList(var aList: TStringList);
var
  CommentIndex : integer;
begin
  aList.BeginUpdate;
  try
    for CommentIndex := fComments.Count - 1 downto 0 do
      aList.Insert(0,fComments.Strings[CommentIndex]);
  finally
    aList.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
constructor TCommentMemIniFile.Create(const FileName: string);
begin
  inherited Create(FileName);

  fComments := TStringList.create();
end;

//------------------------------------------------------------------------------
destructor TCommentMemIniFile.Destroy;
begin
  fComments.Free;

  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TCommentMemIniFile.UpdateFile;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    GetStrings(List);
    InsertCommentsToList(List);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

end.
