{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10831: ad3Grid.pas 
{
{   Rev 1.3    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.2    2/21/2004 11:59:40 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:26 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:38 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Helper functions for dealing with Delphi's Grids

History:
3/9/01      - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Grid;

{$I addict3.inc}

interface

uses
    ad3SpellBase,
    grids;

type
    TAddictGrid = class(TStringGrid)
    end;

    TAddictStringGridHelper = class(TObject)
    protected
        FInit           :Boolean;
        FAlwaysShow     :Boolean;
        FStringGrid     :TStringGrid;
        FOriginalRow    :Integer;
        FOriginalColumn :Integer;
    public
        constructor create;

        procedure InitStringGrid( Grid:TStringGrid );
        procedure FinishWithStringGrid;
        procedure PrepareCell( Column:LongInt; Row:LongInt );
        procedure CheckCell( Addict:TAddictSpell3Base; Column:LongInt; Row:LongInt );
        procedure CheckRow( Addict:TAddictSpell3Base; Row:LongInt );
        procedure CheckColumn( Addict:TAddictSpell3Base; Column:LongInt );
    end;

implementation

uses
    stdctrls,
    forms;

constructor TAddictStringGridHelper.create;
begin
    FInit       := False;
    FAlwaysShow := False;
    FStringGrid := nil;
end;

procedure TAddictStringGridHelper.InitStringGrid( Grid:TStringGrid );
begin
    FInit               := False;
    FStringGrid         := Grid;
    FAlwaysShow         := goAlwaysShowEditor in FStringGrid.Options;
    FStringGrid.Options := FStringGrid.Options + [goAlwaysShowEditor];
    FOriginalRow        := FStringGrid.Row;
    FOriginalColumn     := FStringGrid.Col;
end;

procedure TAddictStringGridHelper.FinishWithStringGrid;
begin
    if (assigned(TAddictGrid(FStringGrid).InplaceEditor)) then
    begin
        TEdit(TAddictGrid(FStringGrid).InplaceEditor).HideSelection := True;
    end;
    if not(FAlwaysShow) then
    begin
        FStringGrid.Options := FStringGrid.Options - [goAlwaysShowEditor];
    end;
    FStringGrid.Row     := FOriginalRow;
    FStringGrid.Col     := FOriginalColumn;
    FStringGrid := nil;
end;

procedure TAddictStringGridHelper.PrepareCell( Column:LongInt; Row:LongInt );
begin
    Assert( assigned(FStringGrid) );

    FStringGrid.Col := Column;
    FStringGrid.Row := Row;
    TAddictGrid(FStringGrid).ShowEditor;

    if (not FInit) then
    begin
        FInit := True;

        TEdit(TAddictGrid(FStringGrid).InplaceEditor).HideSelection := False;
        TAddictGrid(FStringGrid).InplaceEditor.SetFocus;

        // Complete Hack - For whatever reason, the string grid's editor doesn't
        // "come around" until we kick it in the pants a second time...

        TAddictGrid(FStringGrid).InplaceEditor.BringToFront;
        Application.ProcessMessages;
        TAddictGrid(FStringGrid).ShowEditor;
    end;

    TAddictGrid(FStringGrid).InplaceEditor.BringToFront;
    Application.ProcessMessages;
end;

procedure TAddictStringGridHelper.CheckCell( Addict:TAddictSpell3Base; Column:LongInt; Row:LongInt );
begin
    PrepareCell( Column, Row );
    Addict.CheckWinControl( TAddictGrid(FStringGrid).InplaceEditor, ctAll );
end;

procedure TAddictStringGridHelper.CheckRow( Addict:TAddictSpell3Base; Row:LongInt );
var
    Index: Integer;
begin
    for Index := 0 to FStringGrid.ColCount - 1 do
    begin
        CheckCell( Addict, Index, Row );
        if (Addict.CheckCanceled) then
        begin
            break;
        end;
    end;
end;

procedure TAddictStringGridHelper.CheckColumn( Addict:TAddictSpell3Base; Column:LongInt );
var
    Index: Integer;
begin
    for Index := 0 to FStringGrid.RowCount - 1 do
    begin
        CheckCell( Addict, Column, Index );
        if (Addict.CheckCanceled) then
        begin
            break;
        end;
    end;
end;

end.

