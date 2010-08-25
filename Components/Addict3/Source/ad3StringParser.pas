{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10865: ad3StringParser.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:36 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:58 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:44 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:54 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:28 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Base Parser Class for Strings

History:
9/15/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3StringParser;

{$I addict3.inc}

interface

uses
    Classes, Windows,
    ad3ParserBase;

type

    //************************************************************
    // 2nd Generation String Parser
    //************************************************************

    TStringParser = class(TControlParser)
    protected

        FString             :^String;
        FEndX               :LongInt;
        FUsingEnd           :Boolean;
        FX                  :LongInt;
        FLength             :LongInt;

    public

        {$IFNDEF T2H}
        procedure Initialize( EditControl:Pointer ); override;
        function GetChar : char; override;
        function GetLine : String; override;
        function MoveNext : Boolean; override;
        function MovePrevious : Boolean; override;
        procedure SetPosition( XPos:LongInt; YPos:LongInt; PosType:TPositionType ); override;
        procedure GetPosition( var XPos:LongInt; var YPos:LongInt ); override;
        procedure SelectWord( Length:LongInt ); override;
        procedure ReplaceWord( Replacement:String; State:LongInt ); override;
        procedure IgnoreWord( State:LongInt ); override;
        procedure CenterSelection; override;
        procedure GetCursorPosition( var XPos:LongInt; var YPos:LongInt ); override;
        procedure GetSelectionPosition( var XPosStart:LongInt; var YPosStart:LongInt; var XPosEnd:LongInt; var YPosEnd:LongInt ); override;
        procedure GetControlScreenPosition( var ControlPosition:TRect ); override;
        procedure GetSelectionScreenPosition( var SelectionPosition:TRect ); override;
        procedure UndoLast( State:LongInt; UndoAction:LongInt; var UndoData:LongInt ); override;
        {$ENDIF}
    end;

implementation

uses
    ad3Util;

//************************************************************
// TControlParser Implementation
//************************************************************

procedure TStringParser.Initialize( EditControl:Pointer );
begin
    FString     := EditControl;
    FUsingEnd   := False;
    FEndX       := 0;
    FX          := 1;
end;

//************************************************************

function TStringParser.GetChar:char;
begin
    if (Length(FString^) >= FX) then
    begin
        Result := (FString^)[FX];
    end
    else
    begin
        Result := #0;
    end;
end;

//************************************************************

function TStringParser.GetLine:String;
begin
    Result := FString^;
end;

//************************************************************

function TStringParser.MoveNext:Boolean;
begin
    Result := (FX <= Length(FString^));
    inc( FX );
    if (Result) then
    begin
        if FUsingEnd and (FX > FEndX) then
        begin
            Result := False;
        end;
    end;
end;

//************************************************************

function TStringParser.MovePrevious:Boolean;
begin
    Result := (FX > 1);
    if (Result) then
    begin
        dec( FX );
    end;
end;

//************************************************************

procedure TStringParser.SetPosition( XPos:LongInt; YPos:LongInt; PosType:TPositionType );
begin
    if (PosType = ptCurrent) then
    begin
        FX := ADMax( 1, XPos );
    end
    else if (PosType = ptEnd) then
    begin
        FUsingEnd   := True;
        FEndX       := XPos;
    end;
end;

//************************************************************

procedure TStringParser.GetPosition( var XPos:LongInt; var YPos:LongInt );
begin
    XPos    := FX;
    YPos    := 0;
end;

//************************************************************

procedure TStringParser.SelectWord( Length:LongInt );
begin
    FLength := Length;
    FX      := FX - Length;
end;

//************************************************************

procedure TStringParser.ReplaceWord( Replacement:String; State:LongInt );
begin
    if (FUsingEnd) then
    begin
        FEndX   := FEndX + (Length(Replacement) - FLength);
    end;

    delete( FString^, FX, FLength );
    insert( Replacement, FString^, FX );

    FX      := FX + Length(Replacement);
end;

//************************************************************

procedure TStringParser.IgnoreWord( State:LongInt );
begin
    FX := FX + FLength;
end;

//************************************************************

procedure TStringParser.CenterSelection;
begin
end;

//************************************************************

procedure TStringParser.GetCursorPosition( var XPos:LongInt; var YPos:LongInt );
begin
    XPos    := FX;
    YPos    := 0;
end;

//************************************************************

procedure TStringParser.GetSelectionPosition( var XPosStart:LongInt; var YPosStart:LongInt; var XPosEnd:LongInt; var YPosEnd:LongInt );
begin
    XPosStart   := FX;
    YPosStart   := 0;
    XPosEnd     := FX;
    YPosEnd     := 0;
end;

//************************************************************

procedure TStringParser.GetControlScreenPosition( var ControlPosition:TRect );
begin
    ControlPosition := Rect( -1, -1, -1, -1 );
end;

//************************************************************

procedure TStringParser.GetSelectionScreenPosition( var SelectionPosition:TRect );
begin
    SelectionPosition := Rect( -1, -1, -1, -1 );
end;

//************************************************************

procedure TStringParser.UndoLast( State:LongInt; UndoAction:LongInt; var UndoData:LongInt );
begin
end;

end.
