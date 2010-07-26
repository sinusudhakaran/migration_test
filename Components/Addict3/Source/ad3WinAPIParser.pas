{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10883: ad3WinAPIParser.pas 
{
{   Rev 1.7    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.6    20/12/2004 3:24:48 pm  Glenn
}
{
{   Rev 1.5    9/14/2004 10:04:04 PM  mnovak
{ Elminate RichEdit Dependency
}
{
{   Rev 1.5    9/14/2004 8:46:54 PM  mnovak
{ Remove RichEdit Dependencies
}
{
{   Rev 1.4    8/31/2004 2:43:22 AM  mnovak
{ Improve Control Auto-Detect and Child Window handling for DevExpress support
}
{
{   Rev 1.3    2/22/2004 12:00:04 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    12/3/2003 1:03:50 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.1    11/25/2003 9:16:28 PM  mnovak
{ Implement TControlParser2 method: GetControl
}
{
{   Rev 1.0    8/25/2003 1:01:58 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:14 AM  mnovak
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

Base Parser Class for Windows Edit Controls

History:
7/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3WinAPIParser;

{$I addict3.inc}

interface

uses
    windows, sysutils, classes, controls, messages, ad3Util,
    ad3ParserBase;

type

    //************************************************************
    // 2nd Generation Windows API Parser
    //************************************************************

    TWinAPIControlType = (actEdit, actRichEdit, actRichEdit2);

    TWinAPIControlParser = class(TControlParser2)
    protected

        FEdit               :TWinControl;
        FHandle             :HWND;
        FControlType        :TWinAPIControlType;
        FEndX               :LongInt;
        FEndY               :LongInt;
        FUsingEnd           :Boolean;
        FX                  :LongInt;
        FY                  :LongInt;

        FLine               :array[0..16383] of Char;   // 16k max line len
        FLineIndex          :LongInt;
        FLineLength         :LongInt;
        FLineCount          :LongInt;
        FDirty              :Boolean;

        FSelStart           :DWORD;     // cached between select word & replace word
        FSelLen             :DWORD;

    protected

        {$IFNDEF T2H}
        function EnsureLineCurrent:Boolean; virtual;
        procedure Perform_EM_POSFROMCHAR( Position:LongInt; var Dest:TPoint ); virtual;
        {$ENDIF}

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
        function GetControl:TComponent; override;
        {$ENDIF}

        // Additional Public API

        procedure InitializeFromHWND( Handle:HWND );

        // Additional property tweaks...

        property ControlType:TWinAPIControlType read FControlType write FControlType;
        property Control:TWinControl read FEdit;
        property ControlHWND:HWND read FHandle;
    end;

implementation


//************************************************************
// Utility Functions
//************************************************************

function TWinAPIControlParser.EnsureLineCurrent:Boolean;
begin
    Result := True;

    // Auto-Skip to another line if needbe

    if (FY = FLineIndex) then
    begin
        if (FX >= FLineLength) then
        begin
            INC(FY);
            FX := 0;
        end
        else if (FX < 0) then
        begin
            if (FY > 0) then
            begin
                DEC(FY);
                FX := -1;
            end
            else
            begin
                Result  := False;
                FX      := 0;
                Exit;
            end;
        end;
    end;

    // Now fetch the new line if needbe

    if (FY <> FLineIndex) or FDirty then
    begin
        Result := (FY < FLineCount);
        if (Result) then
        begin
            FDirty                  := False;
            Word((@FLine)^)         := SizeOf(FLine) - 10;
            FLineLength             := SendMessage( FHandle, EM_GETLINE, FY, LongInt(@FLine) );
            FLine[FLineLength]      := #13;
            FLine[FLineLength + 1]  := #10;
            FLine[FLineLength + 2]  := #0;
            FLineLength             := FLineLength + 2;
            FLineIndex              := FY;
            FLineCount              := SendMessage( FHandle, EM_GETLINECOUNT, 0, 0 );
        end;
        if (FX <= -1) then
        begin
            FX := FLineLength - 1;
        end;
    end;

    // Check for overflow...

    if FUsingEnd and (FX > FEndX) and (FY >= FEndY) then
    begin
        Result := False;
    end;
end;

//************************************************************

procedure TWinAPIControlParser.Perform_EM_POSFROMCHAR( Position:LongInt; var Dest:TPoint );
var
    RetVal      :LongInt;
begin
    Dest.X := 0;
    Dest.Y := 0;

    // RichEdit v1 handles this message differently from the edit control, or
    // v2 of the RichEdit control.  See:  Article ID: Q137805

    if (FControlType = actRichEdit) then
    begin
        SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@Dest), Position );
    end
    else
    begin
        RetVal  := SendMessage( FHandle, Messages.EM_POSFROMCHAR, Position, 0 );
        if (RetVal <> -1) then
        begin
            Dest.X  := (RetVal and $0000FFFF);
            Dest.Y  := ((RetVal and $FFFF0000) shr 16);
        end;
    end;
end;



//************************************************************
// TControlParser Implementation
//************************************************************

procedure TWinAPIControlParser.Initialize( EditControl:Pointer );
begin
    FEdit       := TWinControl(EditControl);
    InitializeFromHWND( FEdit.Handle );
end;

//************************************************************

function TWinAPIControlParser.GetChar:char;
begin
    if (EnsureLineCurrent) then
    begin
        Result  := FLine[FX];
    end
    else
    begin
        Result := #0;
    end;
end;

//************************************************************

function TWinAPIControlParser.GetLine:String;
begin
    if (EnsureLineCurrent) then
    begin
        Result := FLine;
    end
    else
    begin
        Result := '';
    end;
end;

//************************************************************

function TWinAPIControlParser.MoveNext:Boolean;
begin
    inc( FX );
    Result := EnsureLineCurrent;
end;

//************************************************************

function TWinAPIControlParser.MovePrevious:Boolean;
begin
    dec( FX );
    Result := EnsureLineCurrent;
end;

//************************************************************

procedure TWinAPIControlParser.SetPosition( XPos:LongInt; YPos:LongInt; PosType:TPositionType );
begin
    if (PosType = ptCurrent) then
    begin
        FDirty  := True;
        FX      := XPos;
        FY      := YPos;
    end
    else if (PosType = ptEnd) then
    begin
        FUsingEnd   := True;
        FEndX       := XPos;
        FEndY       := YPos;
    end;
end;

//************************************************************

procedure TWinAPIControlParser.GetPosition( var XPos:LongInt; var YPos:LongInt );
begin
    XPos    := FX;
    YPos    := FY;
end;

//************************************************************

procedure TWinAPIControlParser.SelectWord( Length:LongInt );
begin
    FX          := FX - Length;
    FSelStart   := SendMessage( FHandle, EM_LINEINDEX, FY, 0 ) + FX;
    FSelLen     := Length;

    SendMessage( FHandle, EM_SETSEL, LongInt(FSelStart), LongInt(FSelStart) + LongInt(FSelLen) );
end;

//************************************************************

procedure TWinAPIControlParser.ReplaceWord( Replacement:String; State:LongInt );
var
    StartPos    :DWORD;
    EndPos      :DWORD;
begin
    // Restore the selected position for those controls who
    // nuke their position out from under us between selecting
    // and replacing the words (namely DevExpress's in-place editor)

    SendMessage( FHandle, EM_SETSEL, LongInt(FSelStart), LongInt(FSelStart) + LongInt(FSelLen) );

    // Adjust the end position if necessary

    if (FUsingEnd) and (FY = FEndY) then
    begin
        StartPos    := 0;
        EndPos      := 0;

        SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

        FEndX   := FEndX + (Length(Replacement) - LongInt(EndPos - StartPos));
    end;

    // Do the replacement

    SendMessage( FHandle, EM_REPLACESEL, 0, longint(PChar(Replacement)) );

    FX      := FX + Length(Replacement);
    FDirty  := True;
end;

//************************************************************

procedure TWinAPIControlParser.IgnoreWord( State:LongInt );
var
    StartPos    :DWORD;
    EndPos      :DWORD;
begin
    StartPos    := 0;
    EndPos      := 0;
    SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

    FX := FX + LongInt(EndPos - StartPos);
end;

//************************************************************

procedure TWinAPIControlParser.CenterSelection;
var
    dc              :HDC;
    tmFont          :TTextMetric;
    FontHeight      :LongInt;
    FirstVisible    :LongInt;
    StartPos        :DWORD;
    EndPos          :DWORD;
    ClientRect      :TRect;
    ClientHeight    :Integer;
begin
    // center the selection in the edit control verticly.

    dc := GetDC( FHandle );
    GetTextMetrics( dc, tmFont );
    ReleaseDC( FHandle, dc );
    FontHeight  := tmFont.tmHeight + tmFont.tmExternalLeading;

    GetClientRect( FHandle, ClientRect );
    ClientHeight := (ClientRect.Bottom - ClientRect.Top);

    FirstVisible := SendMessage( FHandle, EM_GETFIRSTVISIBLELINE, 0, 0 );
    SendMessage( FHandle, EM_LINESCROLL, 0, (FY - (FirstVisible + ((ClientHeight div FontHeight) div 2))) );

    // Now we'll try to make sure the text is horizontally visible.

    StartPos    := 0;
    EndPos      := 0;
    SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

    SendMessage( FHandle, EM_SETSEL, StartPos, StartPos );
    SendMessage( FHandle, EM_SCROLLCARET, 0, 0 );
    SendMessage( FHandle, EM_SETSEL, EndPos, EndPos );
    SendMessage( FHandle, EM_SCROLLCARET, 0, 0 );

    SendMessage( FHandle, EM_SETSEL, StartPos, EndPos );
end;

//************************************************************

procedure TWinAPIControlParser.GetCursorPosition( var XPos:LongInt; var YPos:LongInt );
var
    StartPos    :DWORD;
    EndPos      :DWORD;     // TSM bug
begin
    StartPos    := 0;
    SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

    YPos        := SendMessage( FHandle, EM_LINEFROMCHAR, StartPos, 0 );
    XPos        := LongInt(StartPos) - SendMessage( FHandle, EM_LINEINDEX, YPos, 0 );
end;

//************************************************************

procedure TWinAPIControlParser.GetSelectionPosition( var XPosStart:LongInt; var YPosStart:LongInt; var XPosEnd:LongInt; var YPosEnd:LongInt );
var
    StartPos    :DWORD;
    EndPos      :DWORD;
begin
    StartPos    := 0;
    EndPos      := 0;
    SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

    YPosStart   := SendMessage( FHandle, EM_LINEFROMCHAR, StartPos, 0 );
    XPosStart   := LongInt(StartPos) - SendMessage( FHandle, EM_LINEINDEX, YPosStart, 0 );

    YPosEnd     := SendMessage( FHandle, EM_LINEFROMCHAR, EndPos, 0 );
    XPosEnd     := LongInt(EndPos) - SendMessage( FHandle, EM_LINEINDEX, YPosEnd, 0 );
end;

//************************************************************

procedure TWinAPIControlParser.GetControlScreenPosition( var ControlPosition:TRect );
var
    P           :TPoint;
    WindowRect  :TRect;
begin
    P := Point( 0, 0 );
    ClientToScreen( FHandle, P );

    GetWindowRect( FHandle, WindowRect );

    ControlPosition := Rect(    P.X,
                                P.Y,
                                P.X + (WindowRect.Right - WindowRect.Left),
                                P.Y + (WindowRect.Bottom - WindowRect.Top) );
end;

//************************************************************

procedure TWinAPIControlParser.GetSelectionScreenPosition( var SelectionPosition:TRect );
var
    StartPos    :DWORD;
    EndPos      :DWORD;
    dc          :HDC;
    tmFont      :TTextMetric;
    Position    :TPoint;
    NextLinePos :LongInt;
begin
    StartPos    := 0;
    EndPos      := 0;
    SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );

    Perform_EM_POSFROMCHAR( StartPos, Position );
    SelectionPosition.Left  := Position.x;
    SelectionPosition.Top   := Position.y;

    Perform_EM_POSFROMCHAR( EndPos, Position );
    SelectionPosition.Right := Position.x;

    ClientToScreen( FHandle, SelectionPosition.TopLeft );
    ClientToScreen( FHandle, SelectionPosition.BottomRight );

    // Get the font height to adjust the bottom...

    dc := GetDC( FHandle );
    GetTextMetrics( dc, tmFont );
    ReleaseDC( FHandle, dc );

    SelectionPosition.Bottom := SelectionPosition.Top + (tmFont.tmHeight + tmFont.tmExternalLeading);

    // OK... this will usually get the job done for us, but the RichEdit could
    // have an embedded bitmap that will make this line taller than we would
    // really expect it to be... so we'll make an honest attempt to account for
    // that.

    NextLinePos := SendMessage( FHandle, EM_LINEINDEX, FY + 1, 0 );
    if (NextLinePos <> -1) then
    begin
        Perform_EM_POSFROMCHAR( NextLinePos, Position );

        ClientToScreen( FHandle, Position );

        if (Position.y > SelectionPosition.Bottom) then
        begin
            SelectionPosition.Bottom := Position.y;
        end;
    end;
end;

//************************************************************

procedure TWinAPIControlParser.UndoLast( State:LongInt; UndoAction:LongInt; var UndoData:LongInt );
begin
end;

//************************************************************

function TWinAPIControlParser.GetControl:TComponent;
begin
    Result := Control;
end;




//************************************************************
// Additional Public API
//************************************************************

procedure TWinAPIControlParser.InitializeFromHWND( Handle:HWND );
var
    ClassName   :Array[0..1023] of Char;
    Name        :String;
    ChildWindow :HWND;
begin
    FHandle     := Handle;

    FUsingEnd   := False;
    FX          := 0;
    FY          := 0;
    FDirty      := True;
    FLineLength := 0;
    FLineIndex  := -1;
    FLine[0]    := #0;
    FSelStart   := 0;
    FSelLen     := 0;

    FLineCount  := SendMessage( FHandle, EM_GETLINECOUNT, 0, 0 );

    // Attempt to verify that the item we're looking at is actually an edit
    // control.  Standard windows edit controls should always return > 0 from
    // the EM_GETLINECOUNT API.  When this isn't found to be true, we attempt
    // to look at the children to see if one of them is an edit control.  If it
    // is, then we proceed to check it.

    if (FLineCount = 0) then
    begin
        ChildWindow := GetWindow( Handle, GW_CHILD );
        while (IsWindow(ChildWindow)) do
        begin
            FLineCount  := SendMessage( ChildWindow, EM_GETLINECOUNT, 0, 0 );
            if (FLineCount > 0) then
            begin
                FHandle := ChildWindow;
                break;
            end;
            ChildWindow := GetWindow( ChildWindow, GW_HWNDNEXT );
        end;
    end;

    // Do auto-detection of the control type we're checking (if possible)

    ClassName[0]    := #0;
    GetClassName( FHandle, ClassName, 1024 );
    Name            := ClassName;
    Name            := AnsiLowercase( Name );

    if (pos( 'richedit2', Name ) > 0) then
    begin
        FControlType := actRichEdit2;
    end
    else if (pos( 'richedit', Name ) > 0) or
            (pos( 'syntaxmemo', Name ) > 0) or
            (pos( 'lmdmemo', Name ) > 0) then
    begin
        FControlType := actRichEdit;
    end
    else
    begin
        // OK, we're completely on auto-detect mode at this point.

        if (IsRichEdit(FHandle)) then
        begin
            FControlType := actRichEdit;
        end
        else
        begin
            FControlType := actEdit;
        end;
    end;
end;


end.

