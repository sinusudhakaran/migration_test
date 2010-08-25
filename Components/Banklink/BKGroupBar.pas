unit BKGroupBar;
{
 Adds a write-only property ClickByCaption that fires an action linked
 to the specified item when a value is assigned to it.

 String should be in the following format:

 "Group caption/Item caption"
 (Separated by a "/", case insensitive, "*" allowed as a wildcard at the start
  and end of both captions)
}

interface

uses
  SysUtils, Classes, Controls, RzGroupBar;

type
  TBKGroupBar = class(TRzGroupBar)
  private
    procedure SetClickByCaption(const Value: string);
  protected
  public
  published
    property ClickByCaption: string write SetClickByCaption;
  end;

procedure Register;

implementation

uses
  StrUtils;

procedure Register;
begin
  RegisterComponents('BankLink', [TBKGroupBar]);
end;

function StringMatches(pattern,caption: string): Boolean;
var
  anyStart,anyEnd: boolean;
begin
  result:=True;
  if (pattern='') and (caption='') then
    exit;
  result:=False;
  if pattern='' then
    exit;
  anyStart:=pattern[1]='*';
  anyEnd:=pattern[length(pattern)]='*';
  if anyStart and anyEnd then
  begin
    if length(pattern)<=2 then
    begin
      result:=True;
      exit;
    end;
    pattern:=copy(pattern,2,length(pattern)-2);
    result:=pos(pattern,caption)>0;
  end
  else
    if anyStart then
    begin
      pattern:=copy(pattern,2,length(pattern)-1);
      result:=AnsiEndsStr(pattern,caption);
    end
    else
      if anyEnd then
      begin
        pattern:=copy(pattern,1,length(pattern)-1);
        result:=AnsiStartsStr(pattern,caption);
      end
      else
        result:=pattern=caption;
end;

procedure TBKGroupBar.SetClickByCaption(const Value: string);
var
  GroupCaption,ItemCaption: string;
  ps: integer;
  gc,ic: integer;
begin
  GroupCaption:='';
  ItemCaption:='';
  ps:=pos('/',Value);
  if ps>0 then
  begin
    GroupCaption:=UpperCase(Copy(Value,1,ps-1));
    ItemCaption:=UpperCase(Copy(Value,ps+1,length(Value)));
  end
  else
    ItemCaption:=UpperCase(Value);

  if ItemCaption='' then
    exit;
  for gc:=0 to GroupCount-1 do
    with Groups[gc] as TRzGroup do
      if (GroupCaption='') or StringMatches(GroupCaption,UpperCase(Caption)) then
        for ic:=0 to Items.Count-1 do
          with Items[ic] as TRzGroupItem do
            if StringMatches(ItemCaption,UpperCase(AnsiReplaceStr(Caption,'&',''))) then
            begin
              Click;
              exit;
            end
end;

end.
