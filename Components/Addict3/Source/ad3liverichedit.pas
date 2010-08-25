{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10839: ad3LiveRichEdit.pas 
{
{   Rev 1.16    8/31/2005 1:10:52 AM  mnovak
{ 
}
{
{   Rev 1.14    8/30/2005 11:19:28 PM  mnovak
}
{
{   Rev 1.13    8/30/2005 10:42:36 PM  mnovak
{ Fixed IrregularLineHeights issue (painting heights on last line)
}
{
{   Rev 1.12    22/08/2005 7:44:56 am  Glenn
{ D2005 improvement - adding types to uses.
}
{
{   Rev 1.11    28/07/2005 1:50:26 pm  Glenn
{ Add support for changes in JVCL 3
}
{
{   Rev 1.9    20/12/2004 3:24:16 pm  Glenn
}
{
{   Rev 1.8    9/14/2004 10:04:46 PM  mnovak
}
{
{   Rev 1.8    9/14/2004 8:47:14 PM  mnovak
{ Fix DevExpress Subclass eternal painting loop issue...
}
{
{   Rev 1.7    9/11/2004 5:14:10 PM  mnovak
{ Background Color Change Fix
{ DevExpress Fix
}
{
{   Rev 1.6    9/8/2004 11:36:02 PM  mnovak
{ LiveSpell Control Destruction Fixes
}
{
{   Rev 1.5    8/31/2004 2:43:12 AM  mnovak
{ Improve Control Auto-Detect and Child Window handling for DevExpress support
}
{
{   Rev 1.4    2/21/2004 11:59:42 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.3    12/3/2003 1:03:28 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.2    11/25/2003 10:11:36 PM  mnovak
{ Add support for JVXRichEdit (open source RXEdit)
}
{
{   Rev 1.0    8/25/2003 1:01:40 AM  mnovak
}
{
{   Rev 1.7    1/10/2003 10:48:10 PM  mnovak
{ Allow cursor-word to be spell-highlighted if the control does not have focus.
}
{
{   Rev 1.6    12/17/2002 6:01:06 PM  mnovak
{ Added documentation Hints for Time2Help
}
{
{   Rev 1.5    12/15/2002 8:31:52 PM  mnovak
{ Fixed two Marking Alignment Issues:
{ * Last Line - with mixed fonts or embedded icons, the last line would
{ represent itself incorrectly... this has now been fixed.
{ * IrregularLineHeights - started pixel sniffing at first error position,
{ rather than start of line to avoid issues with embedded bitmaps
}
{
{   Rev 1.4    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.3    7/29/2002 11:59:56 PM  mnovak
{ Added requested OnWordCheck event
}
{
{   Rev 1.2    27/07/2002 10:11:26 pm  glenn
}
{
{   Rev 1.1    7/21/2002 9:08:06 AM  mnovak
{ Fixed French word parsing in the RichEdit control.
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

Livespell enabled RichEdit interface

History:
11/03/00    - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3LiveRichEdit;

{$I addict3.inc}

interface

uses
    messages, classes, windows, controls, graphics, richedit, forms,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    {$IFDEF Delphi9AndAbove} types, {$ENDIF}
    ad3Util,
    ad3SpellBase,
    ad3StringParser,
    ad3ParserBase,
    ad3ParseEngine,
    ad3WinAPIParser,
    ad3Configuration,
    ad3CustomDictionary;

type
    //************************************************************
    // Livespell interface for a RichEdit control
    //************************************************************

    TAddictLiveRichEdit = class(TObject)
    protected
        FEdit               :TWinControl;
        FHandle             :HWND;

        FLiveSpelling       :Boolean;
        FLiveCorrect        :Boolean;
        FAddictSpell        :TAddictSpell3Base;
        FLiveColor          :TColor;
        FBackgroundColor        :TColor;
        FBackgroundColorCached  :Boolean;
        FBackgroundSysColor     :Boolean;
        FDoubleBuffered     :Boolean;
        FLiveOptions        :Boolean;
        FLiveMenuOptions    :TSpellPopupOptions;
        FLiveReadOnly       :Boolean;

        FExpandKeys         :String;
        FLastKey            :Char;

        FStringParser       :TStringParser;
        FAPIParser          :TWinAPIControlParser;
        FParsingEngine      :TParsingEngine;

        FWatchSpelling          :Boolean;
        FWatchCorrect           :Boolean;
        FSearching              :Boolean;
        FUseIgnore              :Boolean;
        FVersionCheckNeeded     :Boolean;
        FSufficientVersion      :Boolean;
        FBufferNextPaint        :Boolean;
        FLastFirstLine          :LongInt;
        FIrregularLineHeights   :Boolean;
        FIrregularLeftMargin    :Boolean;
        FAggressiveContextMenu  :Boolean;        
        FHardcodeLeft           :Boolean;
        FControlCanDoubleBuffer :Boolean;

        FLineList           :TObjectList;
        FIgnoreDictionary   :TCustomDictionary;
        FIgnoreWords        :TStringList;

        FOnBeginEditing     :TNotifyEvent;
        FOnWordCheck        :TWordCheckEvent;

        FLMDTools           :Boolean;
        FInfoPower          :Boolean;
        FDXMemo             :Boolean;
        FDXInPlace          :Boolean;
        FRXLib              :Boolean;

    protected

        // Various Notifications

        procedure OnAddCustomIgnore( Sender:TObject ); virtual;
        procedure OnConfigChanged( Sender:TObject ); virtual;
        procedure OnParserIgnoreWord( Sender:TObject ); virtual;
        procedure OnPopupResult( Sender:TObject ); virtual;

        // Utility Functions

        function GetControlHandle:HWND;
        procedure VerifyHandle; virtual;
        function  HandleAssigned:Boolean; virtual;
        function  CurrentlyDoubleBuffering:Boolean; virtual;
        procedure MarkLineHeightCacheDirty; virtual;
        procedure MarkAllLinesDirty; virtual;
        procedure CheckWatchSpelling; virtual;
        function  WordOK( const Word:String; const PrevWord:String ):Boolean; virtual;
        procedure BeginEditing; virtual;

        // Property read/write functions

        procedure WriteWinControl( NewControl:TWinControl ); virtual;
        procedure WriteHWND( NewHWND: HWND ); virtual;
        procedure WriteParsingEngine( NewEngine:TParsingEngine ); virtual;
        procedure WriteLiveSpelling( LiveSpelling:Boolean ); virtual;
        procedure WriteLiveCorrect( LiveCorrect:Boolean ); virtual;
        procedure WriteAddictSpell( AddictSpell:TAddictSpell3Base ); virtual;
        procedure WriteLiveColor( Color:TColor ); virtual;
        procedure WriteLiveOptions( Options:Boolean ); virtual;
        procedure WriteLiveReadOnly( NewLiveReadOnly:Boolean ); virtual;

        // RichEdit Utility Functions

        function GetLineString( Index:Integer ):String;
        function SelStart:LongInt;
        function SelLength:LongInt;
        function SelText:String;
        function WordWrap:Boolean;
        function ReadOnly:Boolean;
        procedure SetUpdateState( Updating:Boolean );

        // Painting Utility Functions

        function GetTextBottomPixelPosition( DC:HDC; LineNum:Integer; XStart:Integer; YStart:Integer; NextLineStart:Integer ):Integer;
        function GetLastLineTextBottomPixelPosition(    GuessedPosition:Integer;
                                                        DrawDC:HDC;
                                                        LineNum:Integer;
                                                        FirstErrorXStart:Integer; FirstErrorXStop:Integer;
                                                        StartPosition:TPoint;
                                                        LineChecked:Boolean ):Integer;
        function GetDrawingYPos( DrawDC:HDC; LineNum:Integer; FirstErrorXStart:Integer; FirstErrorXStop:Integer; LineChecked:Boolean ):Integer;
        procedure DrawMarker( DC:HDC; YPos:LongInt; StartPos:LongInt; EndPos:LongInt );
        procedure PaintSpellingErrors( DC:HDC );
        procedure CheckCorrect( Key: Char );

    public
        constructor Create;
        destructor Destroy; override;

        // Notificaitons

        procedure Notification( AComponent:TComponent; Operation:TOperation );
        procedure KeyPress(var Key: Char);
        procedure NotifySelectionChange;

        // Messages

        function  WMEraseBkgnd(var Message: TWMEraseBkgnd):Boolean;
        function  WMPaint(var Message: TWMPaint; var PaintCleanup:Boolean):Boolean;
        procedure WMPaintCleanup( var Message: TWMPaint );
        function  WMContextMenu(var Message: TWMContextMenu):Boolean;
        function  WMContextMenuInternal(var Message: TWMContextMenu):Boolean;
        procedure WMSize( var Message: TWMSize );
        function  WMKeyDown( var Message: TWMKeyDown ):Boolean;
        procedure WMKeyUp( var Message: TWMKeyUp );
        function  WMRButtonDown( var Message: TWMRButtonDown ):Boolean;
        function  WMRButtonUp( var Message: TWMRButtonUp ):Boolean;
        procedure EMSetReadOnly;
        procedure EMSetTargetDevice;
        procedure EMGetOleInterface;

        procedure SearchAndReplace( Word:String; ReplacementWord:String ); virtual;
        procedure IgnoreWord( State:LongInt ); virtual;
        procedure Check( CheckType:TCheckType ); virtual;

        // Public properties

        property WinControl:TWinControl read FEdit write WriteWinControl;
        property WindowHandle:HWND read FHandle write WriteHWND;
        property ParsingEngine:TParsingEngine read FParsingEngine write WriteParsingEngine;
        property ExpansionChars:String read FExpandKeys write FExpandKeys;
        property LiveSpelling:Boolean read FLiveSpelling write WriteLiveSpelling;
        property LiveCorrect:Boolean read FLiveCorrect write WriteLiveCorrect;
        property AddictSpell:TAddictSpell3Base read FAddictSpell write WriteAddictSpell;
        property LiveSpellingColor:TColor read FLiveColor write WriteLiveColor;
        property DoubleBuffered:Boolean read FDoubleBuffered write FDoubleBuffered;
        property LiveSpellingOptions:Boolean read FLiveOptions write WriteLiveOptions;
        property LiveMenuOptions:TSpellPopupOptions read FLiveMenuOptions write FLiveMenuOptions;
        property LiveSpellingReadOnly:Boolean read FLiveReadOnly write WriteLiveReadOnly;
        property IrregularLineHeights:Boolean read FIrregularLineHeights write FIrregularLineHeights;
        property IrregularLeftMargin:Boolean read FIrregularLeftMargin write FIrregularLeftMargin;
        property AggressiveContextMenu:Boolean read FAggressiveContextMenu write FAggressiveContextMenu;

        //#<Events>
        property OnBeginEditing:TNotifyEvent read FOnBeginEditing write FOnBeginEditing;
        property OnWordCheck:TWordCheckEvent read FOnWordCheck write FOnWordCheck;
        //#</Events>
    end;


implementation

uses
    ad3MainDictionary,
    sysutils;

const
    KFrenchLanguage         = $000c;

type
    TSpellingError = class(TObject)
    public
        X1, X2          :Integer;
    end;

    TLineCache = class(TObject)
    public
        constructor Create;
        destructor Destroy; override;
    public
        OldLine         :String;
        SpellingErrors  :TObjectList;
        Dirty           :Boolean;
        NextLineDelta   :Integer;
        DrawDelta       :Integer;
    end;

//************************************************************
// TLineCache
//************************************************************

constructor TLineCache.Create;
begin
    inherited Create;
    SpellingErrors  := TObjectList.Create;
    Dirty           := True;
    NextLineDelta   := 0;
    DrawDelta       := 0;
end;

//************************************************************

destructor TLineCache.Destroy;
begin
    SpellingErrors.Free;
    inherited Destroy;
end;



//************************************************************
// TAddictLiveRichEdit
//************************************************************

constructor TAddictLiveRichEdit.Create;
begin
    inherited Create;

    FEdit               := nil;
    FHandle             := 0;

    FLiveSpelling       := True;
    FLiveCorrect        := True;
    FAddictSpell        := nil;
    FLiveColor          := clRed;
    FBackgroundColorCached  := False;
    FDoubleBuffered     := True;
    FLiveOptions        := True;
    FLiveMenuOptions    := [spDialog, spAutoCorrect, spChangeAll, spAdd, spIgnore, spIgnoreAll, spReplace];
    FLiveReadOnly       := False;

    FExpandKeys         := ' .,;:' + #9;
    FLastKey            := #0;

    FStringParser       := TStringParser.Create;
    FAPIParser          := TWinAPIControlParser.Create;
    FParsingEngine      := TMainParsingEngine.Create;

    FWatchSpelling          := False;
    FWatchCorrect           := False;
    FSearching              := False;
    FUseIgnore              := True;
    FVersionCheckNeeded     := True;
    FSufficientVersion      := False;
    FBufferNextPaint        := True;
    FLastFirstLine          := 0;
    FIrregularLineHeights   := False;
    FIrregularLeftMargin    := True;
    FAggressiveContextMenu  := False;
    FHardcodeLeft           := False;
    FControlCanDoubleBuffer := True;

    FLineList               := TObjectList.Create;

    FIgnoreDictionary       := TCustomDictionary.Create;

    FIgnoreWords            := TStringList.Create;
    FIgnoreWords.Sorted     := True;
    FIgnoreWords.Duplicates := dupIgnore;

    FOnBeginEditing         := nil;

    FLMDTools               := False;
    FInfoPower              := False;
    FDXMemo                 := False;
    FDXInPlace              := False;
    FRXLib                  := False;
end;

//************************************************************

destructor TAddictLiveRichEdit.Destroy;
var
    Index   :Integer;
begin
    AddictSpell := nil;

    FStringParser.Free;
    FAPIParser.Free;
    FParsingEngine.Free;

    FLineList.Free;
    FIgnoreDictionary.Free;
    for Index := 0 to FIgnoreWords.Count - 1 do
    begin
        if (Assigned( FIgnoreWords.Objects[Index] )) then
        begin
            FIgnoreWords.Objects[Index].Free;
            FIgnoreWords.Objects[Index] := nil;
        end;
    end;
    FIgnoreWords.Free;

    inherited Destroy;
end;



//************************************************************
// Message Handlers
//************************************************************

function TAddictLiveRichEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd):Boolean;
begin
    Result := True;

    if  (CurrentlyDoubleBuffering) then
    begin
        // While we're double buffering, we deny any erase
        // background messages that don't come in double-buffered

        if not(GetObjectType( Message.DC ) = OBJ_MEMDC) then
        begin
            Result := False;
        end;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WMPaint(var Message: TWMPaint; var PaintCleanup:Boolean ):Boolean;
var
    FRange      :FORMATRANGE;
    OffsetX     :Integer;
    OffsetY     :Integer;
    DC          :HDC;
    MemDC       :HDC;
    PS          :PAINTSTRUCT;
    MemBitmap   :HBITMAP;
    OldBitmap   :HBITMAP;
    LineNum     :Integer;
    LineIndex   :Integer;
    TopPos      :TPoint;
    ClientRect  :TRect;
    IRect       :TRect;
    BackBrush   :HBRUSH;
begin
    PaintCleanup    := False;
    Result          := False;

    if not(FWatchSpelling) or FSearching or not(HandleAssigned) then
    begin
        Result := True;
        Exit;
    end;

    GetClientRect( FHandle, ClientRect );

    // Make the invalidation region slightly larger to accommodate our
    // squiggly line...  also check out the line number for the first visible
    // line and if it changes (the user scrolled), then we'll invalidate the
    // whole control

    GetUpdateRect( FHandle, IRect, True );

    LineNum := SendMessage( FHandle, EM_GETFIRSTVISIBLELINE, 0, 0 );
    if (LineNum <> FLastFirstLine) then
    begin
        FLastFirstLine := LineNum;
        InvalidateRect( FHandle, nil, TRUE );
    end
    else
    begin
        if not(IsRectEmpty( IRect )) then
        begin
            IRect.Bottom := ADMin( ClientRect.Bottom, IRect.Bottom + 4 );
            if (not FSufficientVersion) then
            begin
                IRect.Left  := 0;
                IRect.Right := (ClientRect.Right - ClientRect.Left);
            end;
            InvalidateRect( FHandle, @IRect, TRUE );
        end;
    end;

    // OK, we'de REALLY like to double buffer the paint of the RichEdit control,
    // but I haven't yet found a completely reliable way to do so.  At this
    // point, we check to see if there is selected text.  If there's not, then
    // we fake up a print message for the RichEdit to get it printing to our
    // back buffer.  However, it will not print its selection to the back
    // buffer.  Thus, when we have a selection, we have to dispatch the paint
    // message back to the RichEdit to let it do its work.

    if (CurrentlyDoubleBuffering) and not(IsRectEmpty(IRect)) then
    begin
        DC := GetDC(0);
        MemBitmap := CreateCompatibleBitmap(DC, ClientRect.Right, ClientRect.Bottom);
        OffsetX := 1440 div GetDeviceCaps( DC, LOGPIXELSX );
        OffsetY := 1440 div GetDeviceCaps( DC, LOGPIXELSY );
        ReleaseDC(0, DC);
        MemDC := CreateCompatibleDC(0);
        OldBitmap := SelectObject(MemDC, MemBitmap);
        try
            LineIndex   := SendMessage( FHandle, EM_LINEINDEX, WPARAM(LineNum), 0 );

            SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TopPos), LineIndex );

            // After much experimentation, it simply appears as though the
            // EM_FORMATRANGE proc draws one pixel lower than it should if you
            // send it a negative Y coordinate.

            if (TopPos.Y < 0) then
            begin
                DEC( TopPos.Y );
            end;

            DC := BeginPaint(FHandle, PS);

            FRange.hdc          := MemDC;
            FRange.hdcTarget    := MemDC;
            if (FHardcodeLeft) then
            begin
                FRange.rc.left  := 1 * OffsetX;
            end
            else
            begin
                FRange.rc.left  := TopPos.X * OffsetX;
            end;
            FRange.rc.top       := TopPos.Y * OffsetY;
            FRange.rc.right     := (ClientRect.right - 2) * OffsetX;
            FRange.rc.bottom    := (ClientRect.bottom + 30) * OffsetY;
            CopyRect( FRange.rcPage, FRange.rc );
            FRange.rcPage.Left  := 0;
            FRange.rcPage.Right := ClientRect.right * OffsetX;
            FRange.chrg.cpMin   := LineIndex;
            FRange.chrg.cpMax   := -1;

            // Note the + 30 from above.  This is to convince the richedit to go
            // ahead and render the partial line so we don't have scrolling trails.

            if (not(FBackgroundColorCached)) then
            begin
                FBackgroundColorCached  := True;
                FBackgroundColor        := SendMessage( FHandle, EM_SETBKGNDCOLOR, 1, 0 );
                FBackgroundSysColor     := (FBackgroundColor = TColor(GetSysColor(COLOR_WINDOW)));
                if (not FBackgroundSysColor) then
                begin
                    SendMessage( FHandle, EM_SETBKGNDCOLOR, 0, FBackgroundColor );
                end
            end;

            if (FBackgroundSysColor) then
            begin
                FillRect( MemDC, ClientRect, GetSysColorBrush(COLOR_WINDOW) );
            end
            else
            begin
                BackBrush := CreateSolidBrush( FBackgroundColor );
                FillRect( MemDC, ClientRect, BackBrush );
                DeleteObject( BackBrush );
            end;

            SendMessage( FHandle, WM_ERASEBKGND, WPARAM(MemDC), 0 );
            SendMessage( FHandle, EM_FORMATRANGE, 0, 0 );
            SendMessage( FHandle, EM_FORMATRANGE, 1, LPARAM(@FRange) );

            PaintSpellingErrors( MemDC );

            BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, MemDC, 0, 0, SRCCOPY);

            EndPaint(FHandle, PS);

            // OK, so we have a problem...  if the text is centered, then our
            // method of determining where the proper left offset is will not
            // work, as we'll get the left of the centered text.  So, we use
            // a bit of fuzzy logic... if we ever get an X that's more than
            // 2, we assume that we can no longer rely on the given X position
            // and then we just hardcode it

            // DevExpress's Memo component can't have an irregular left hand
            // margin since they're not truly RTF, so we won't have to go
            // down this path for their memo component.

            if (TopPos.X > 2) and (not FHardcodeLeft) and (not FDXMemo) and (not FRXLib)then
            begin
                FHardcodeLeft   := True;
                if (FIrregularLeftMargin) then
                begin
                    FControlCanDoubleBuffer := False;
                end;
                InvalidateRect( FHandle, nil, TRUE );
            end;

        finally
            SelectObject(MemDC, OldBitmap);
            DeleteDC(MemDC);
            DeleteObject(MemBitmap);
        end;
    end
    else
    begin
        // When word-wrap is off, we have leftovers at the 0 column that we
        // need to have painted, so we have to invalidate that line...

        if not WordWrap then
        begin
            IRect := Rect( 0, 0, 1, ClientRect.Bottom );
            InvalidateRect( FHandle, @IRect, TRUE );
        end;

        // Have the control paint itself

        Result          := True;

        // Signal to call WMPaintCleanup to paint the spelling errors

        PaintCleanup        := True;

        // We can now allow double buffering... no gaurantee that we'll do
        // it though...

        FBufferNextPaint    := True;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WMPaintCleanup( var Message: TWMPaint );
var
    DC  :HDC;
begin
    if (HandleAssigned) then
    begin
        // Party on the DC after the control is finished

        DC := GetDC( FHandle );
        PaintSpellingErrors( DC );
        ReleaseDC( FHandle, DC );
    end;
end;


//************************************************************

function TAddictLiveRichEdit.WMContextMenu( var Message:TWMContextMenu ):Boolean;
begin
    Result := False;
    if (not FAggressiveContextMenu) then
    begin
        Result := WMContextMenuInternal( Message );
    end;
end;

function TAddictLiveRichEdit.WMContextMenuInternal( var Message:TWMContextMenu ):Boolean;
var
    MousePos        :TPoint;
    CharPos         :LongInt;
    LineNum         :LongInt;
    LineStart       :LongInt;
    LineText        :String;
    Word            :String;
    PrevWord        :String;
    WordChange      :String;
    Found           :Boolean;
    XPos            :LongInt;
    YPos            :LongInt;
    PosRect         :TRect;
    PopupResult     :TSpellPopupOption;
    OldEndMessage   :TSpellEndMessage;
    OldInitialPos   :TSpellDialogInitialPos;
    IRect           :TRect;
    ClientRect      :TRect;
    CurXPos         :Integer;
    CurYPos         :Integer;
begin
    Result := False;

    if not FWatchSpelling or not(HandleAssigned) then
    begin
        Result := True;
        Exit;
    end;

    if Assigned(FEdit) and (csDesigning in FEdit.ComponentState) then
    begin
        Exit;
    end;

    MousePos    := SmallPointToPoint( Message.Pos );

    // Handle a keyboard generated message.  For purposes of our control, we'll
    // assume that this corresponds to the current cursor position.

    if (MousePos.X < 0) then
    begin
        SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@MousePos), SelStart );

        inc( MousePos.X );
        inc( MousePos.Y );
    end
    else
    begin
        ScreenToClient( FHandle, MousePos );
    end;

    GetClientRect( FHandle, ClientRect );

    if not PtInRect( ClientRect, MousePos ) then
    begin
        Result := True;
        Exit;
    end;

    CharPos     := SendMessage( FHandle, EM_CHARFROMPOS, 0, LPARAM(@MousePos) );
    LineNum     := SendMessage( FHandle, EM_LINEFROMCHAR, WPARAM(CharPos), 0 );
    LineStart   := SendMessage( FHandle, EM_LINEINDEX, WPARAM(LineNum), 0 );
    CharPos     := CharPos - LineStart;

    LineText    := GetLineString( LineNum );

    if (FAddictSpell.RunLineIgnore(LineText)) then
    begin
        Result := True;
        Exit;
    end;

    // Walk all words on this line

    FStringParser.Initialize( @LineText );

    FParsingEngine.Initialize( FStringParser, CheckType_All );

    Found       := False;
    Word        := FParsingEngine.NextWord;
    PrevWord    := '';

    while (Word <> '') do
    begin
        if not(WordOK( Word, PrevWord )) then
        begin
            FStringParser.GetPosition( XPos, YPos );

            if  (CharPos >= (XPos - Length(Word) - 1)) and
                (CharPos <= (XPos - 1)) then
            begin
                Found := True;
                break;
            end;

            if (XPos > CharPos) then
            begin
                break;
            end;
        end;

        if (FUseIgnore) then
        begin
            PrevWord := Word;
        end;

        Word    := FParsingEngine.NextWord;
    end;

    if Found then
    begin
        FAPIParser.InitializeFromHWND( FHandle );
        FAPIParser.SetPosition( XPos - 1, LineNum, ptCurrent );
        FAPIParser.SelectWord( Length(Word) );
        FAPIParser.GetSelectionScreenPosition( PosRect );
        FAPIParser.GetPosition( CurXPos, CurYPos );

        WordChange  := Word;
        PopupResult := FAddictSpell.ShowPopupMenu(  FEdit,              // could be nil w/o FEdit
                                                    FLiveMenuOptions,
                                                    PosRect.Left, PosRect.Bottom, WordChange );

        case PopupResult of
        spDialog:
            begin
                OldEndMessage                   := FAddictSpell.EndMessage;
                FAddictSpell.EndMessage         := emNever;
                OldInitialPos                   := FAddictSpell.DialogInitialPos;
                FAddictSpell.DialogInitialPos   := ipUnderSelection;

                FAddictSpell.CheckWinControlHWND( FHandle, ctSelected );

                FAddictSpell.DialogInitialPos   := OldInitialPos;
                FAddictSpell.EndMessage         := OldEndMessage;
            end;
        spAutoCorrect:
            begin
                BeginEditing;
                FAPIParser.ReplaceWord( WordChange, ReplacementState_AutoCorrect );
            end;
        spChangeAll:
            begin
                BeginEditing;
                FAPIParser.ReplaceWord( WordChange, ReplacementState_ReplaceAll );
                SearchAndReplace( Word, WordChange );
            end;
        spAdd:
            begin
                MarkAllLinesDirty;
                InvalidateRect( FHandle, nil, TRUE );
            end;
        spIgnoreAll:
            begin
                MarkAllLinesDirty;
                InvalidateRect( FHandle, nil, TRUE );
            end;
        spIgnore:
            begin
                IgnoreWord( IgnoreState_Ignore );
            end;
        spReplace:
            begin
                BeginEditing;
                FAPIParser.ReplaceWord( WordChange, ReplacementState_Replace );
            end;
        end;

        ScreenToClient( FHandle, PosRect.TopLeft );
        ScreenToClient( FHandle, PosRect.BottomRight );

        IRect := Rect( 0, PosRect.Top - 1, ClientRect.Right, PosRect.Bottom + 1 );
        InvalidateRect( FHandle, @IRect, TRUE );
    end
    else
    begin
        Result := True;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WMSize( var Message: TWMSize );
begin
    if HandleAssigned then
    begin
        InvalidateRect( FHandle, nil, TRUE );
        FBufferNextPaint    := False;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WMKeyDown( var Message: TWMKeyDown ):Boolean;
var
    CMMessage   :TWMContextMenu;
begin
    Result := True;

    if (FAggressiveContextMenu) then
    begin
        if  (Message.CharCode = VK_APPS) or
            ((Message.CharCode = VK_F10) and (ssShift in KeyDataToShiftState(Message.KeyData))) then
        begin
            VerifyHandle;

            CMMessage.Msg   := WM_CONTEXTMENU;
            CMMessage.hWnd  := FHandle;
            CMMessage.Pos.x := -1;
            CMMessage.Pos.y := -1;

            Result := WMContextMenuInternal( CMMessage );
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WMKeyUp( var Message: TWMKeyUp );
begin
    if (FLastKey <> #0) then
    begin
        CheckCorrect( FLastKey );
        FLastKey := #0;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WMRButtonDown( var Message: TWMRButtonDown ):Boolean;
var
    CMMessage   :TWMContextMenu;
    BigPoint    :TPoint;
begin
    Result := True;

    if (FAggressiveContextMenu) then
    begin
        VerifyHandle;

        CMMessage.Msg   := WM_CONTEXTMENU;
        CMMessage.hWnd  := FHandle;
        BigPoint        := SmallPointToPoint(Message.Pos);
        ClientToScreen(FHandle,BigPoint);
        CMMessage.Pos   := PointToSmallPoint(BigPoint);

        Result := WMContextMenuInternal( CMMessage );
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WMRButtonUp( var Message: TWMRButtonUp ):Boolean;
var
    Version     :OSVERSIONINFO;
    Allowed     :Boolean;
    CMMessage   :TWMContextMenu;
    BigPoint    :TPoint;
begin
    Result  := True;

    if (not FAggressiveContextMenu) then
    begin
        VerifyHandle;

        Allowed :=  (not FLMDTools) and
                    (not FInfoPower) and
                    (not FDXInPlace) and
                    (not FRXLib) and
                    {$IFDEF UsingDelphi4} True {$ELSE} False {$ENDIF};
        if (Allowed) then
        begin
            Version.dwOSVersionInfoSize := SizeOf(Version);
            GetVersionEx(Version);
            if (Version.dwPlatformId < 5) and (HandleAssigned) then
            begin
                CMMessage.Msg   := WM_CONTEXTMENU;
                CMMessage.hWnd  := FHandle;
                BigPoint        := SmallPointToPoint(Message.Pos);
                ClientToScreen(FHandle,BigPoint);
                CMMessage.Pos   := PointToSmallPoint(BigPoint);

                Result := WMContextMenuInternal( CMMessage );
            end;
        end;

        // Some controls, for whatever reason, completely swallows the WM_CONTEXTMENU
        // messages that we attempt to post to it... so we have to do this directly
        // Not as clean, but it still works.

        if (FLMDTools or FInfoPower or FDXInPlace or FRXLib) then
        begin
            CMMessage.Msg   := WM_CONTEXTMENU;
            CMMessage.hWnd  := FHandle;
            BigPoint        := SmallPointToPoint(Message.Pos);
            ClientToScreen(FHandle,BigPoint);
            CMMessage.Pos   := PointToSmallPoint(BigPoint);

            Result := WMContextMenuInternal( CMMessage );
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.EMSetReadOnly;
begin
    CheckWatchSpelling;
end;

//************************************************************

procedure TAddictLiveRichEdit.EMSetTargetDevice;
begin
    FControlCanDoubleBuffer := False;
    if HandleAssigned then
    begin
        InvalidateRect( FHandle, nil, TRUE );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.EMGetOleInterface;
begin
    MarkLineHeightCacheDirty;        
end;




//************************************************************
// Protected Notifications
//************************************************************

procedure TAddictLiveRichEdit.Notification( AComponent:TComponent; Operation:TOperation );
begin
    if  (Operation = opRemove) and
        (AComponent is TAddictSpell3Base) and
        (AComponent = TComponent(FAddictSpell)) then
    begin
        AddictSpell := nil;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.OnAddCustomIgnore( Sender:TObject );
begin
    if (FLiveOptions) then
    begin
        CheckWatchSpelling;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.OnConfigChanged( Sender:TObject );
begin
    if (FWatchSpelling) and (HandleAssigned) then
    begin
        MarkAllLinesDirty;
        InvalidateRect( FHandle, nil, TRUE );
    end;
    if (Assigned(FAddictSpell)) then
    begin
        if (FAddictSpell.MainDictionaries.Count > 0) then
        begin
            (FParsingEngine as TMainParsingEngine).AllowFrenchExceptions := ((TMainDictionary(FAddictSpell.MainDictionaries[0]).Language and $00FF) = KFrenchLanguage);
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.OnParserIgnoreWord( Sender:TObject );
begin
    if  (FWatchSpelling) and
        not(FAddictSpell.OnParserIgnoreWordList.Before) then
    begin
        if (    (FAddictSpell.OnParserIgnoreWordList.State = IgnoreState_IgnoreAll) or
                (FAddictSpell.OnParserIgnoreWordList.State = IgnoreState_Add)       or
                (FAddictSpell.CurrentWord = SelText)                                    ) then
        begin
            IgnoreWord( FAddictSpell.OnParserIgnoreWordList.State );
        end
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.OnPopupResult( Sender:TObject );
begin
    if  (FWatchSpelling) and
        (HandleAssigned) and
        (   (FAddictSpell.OnPopupResultList.PopupResult = spAdd) or
            (FAddictSpell.OnPopupResultList.PopupResult = spIgnoreAll)) then
    begin
        MarkAllLinesDirty;
        InvalidateRect( FHandle, nil, TRUE );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.NotifySelectionChange;
var
    LineNum         :Integer;
    LineStartPos    :Integer;
    LineStartPos2   :Integer;
    Index           :Integer;
    TextPos         :TPoint;
    IRect           :TRect;
    ClientRect      :TRect;
    CursorLine      :Integer;
    LineCache       :TLineCache;
begin
    if (FWatchSpelling) and (HandleAssigned) then
    begin
        // Iterate through all visible lines...

        LineNum     := SendMessage( FHandle, EM_GETFIRSTVISIBLELINE, 0, 0 );
        CursorLine  := SendMessage( FHandle, EM_LINEFROMCHAR, SelStart, 0 );
        Index       := LineNum;

        GetClientRect( FHandle, ClientRect );

        repeat
            if (FLineList.Count <= LineNum) then
            begin
                break;
            end;

            LineCache := TLineCache(FLineList[LineNum]);

            if  (Assigned(LineCache)) and
                (   (LineCache.Dirty and (CursorLine <> LineNum))   or
                    (   not(FSufficientVersion) and
                        (CursorLine = LineNum)  and
                        (LineCache.OldLine <> GetLineString(CursorLine))
                    )
                ) then
            begin
                LineCache.Dirty := True;

                LineStartPos    := SendMessage( FHandle, EM_LINEINDEX, LineNum, 0 );
                SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), LineStartPos );
                IRect.Left  := 0;
                IRect.Top   := TextPos.Y;
                IRect.Right := ClientRect.Right;

                LineStartPos2   := SendMessage( FHandle, EM_LINEINDEX, LineNum + 1, 0 );
                if (LineStartPos2 > 0) then
                begin
                    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), LineStartPos2 );
                    IRect.Bottom    := TextPos.Y;
                end
                else
                begin
                    IRect.Bottom    := ClientRect.Bottom;
                end;

                InvalidateRect( FHandle, @IRect, TRUE );
            end;

            inc(LineNum);

            // Check to see if we've run out of lines or visible lines...

            Index := SendMessage( FHandle, EM_LINEINDEX, WPARAM(LineNum), 0 );
            if (Index >= 0) then
            begin
                SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), Index );
            end;

        until (Index < 0) or (TextPos.Y > ClientRect.Bottom);

    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.KeyPress( var Key: Char );
begin
    FLastKey := Key;
end;



//************************************************************
// Utility Functions
//************************************************************

function TAddictLiveRichEdit.GetControlHandle:HWND;
begin
    Result := 0;

    if (assigned(FEdit)) and (FEdit.Parent <> nil) then
    begin
        FEdit.HandleNeeded;

        // Sadly, in some cases (DevExpress) the window we get here is not
        // really the RichEdit control, but rather a simple parent window of
        // the RichEdit control.  Check to ensure that what we're looking at
        // is really a RichEdit and if not, see if there is a child that's a
        // RichEdit to use...

        if not(IsRichEdit( FEdit.Handle )) then
        begin
            Result := GetWindow( FEdit.Handle, GW_CHILD );
            while (IsWindow(Result)) and not(IsRichEdit(Result)) do
            begin
                Result := GetWindow( Result, GW_HWNDNEXT );
            end;
        end;

        if not(IsWindow(Result)) then
        begin
            Result := FEdit.Handle;
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.VerifyHandle;
begin
    // Delphi has this annoying habit of reallocating the handle
    // of windows that we're looking at, so for controls that we
    // have the Delphi pointer to, we always check to ensure that
    // Delphi hasn't reallocated the handle... if it does, then
    // we go ahead and switch it ourselves too...

    if (    (FHandle > 0) and
            (Assigned(FEdit)) and
            (FEdit.HandleAllocated) and
            (GetControlHandle <> FHandle)   ) then
    begin
        FHandle := GetControlHandle;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.HandleAssigned:Boolean;
begin
    VerifyHandle;
    Result := (FHandle > 0);
end;

//************************************************************

function TAddictLiveRichEdit.CurrentlyDoubleBuffering:Boolean;
var
    VersionMS   :DWORD;
    VersionLS   :DWORD;
begin
    if (FVersionCheckNeeded) then
    begin
        FVersionCheckNeeded := False;

        if (Ad3Util.GetFileVersion( 'RichEd32.dll', VersionMS, VersionLS )) then
        begin
            FSufficientVersion  :=  (((VersionMS and $FFFF0000) shr 16) >= 5) and
                                    (((VersionLS and $FFFF0000) shr 16) >= 1500);
        end;
    end;

    Result :=   FWatchSpelling and          // live spell is on
                FDoubleBuffered and         // we are allowing double buffering
                FSufficientVersion and      // sufficient enough version to do the buffering
                WordWrap and                // word-wrap is on (without wrap we have scroll probs)
                (SelLength = 0) and         // there is no selection (buffered painting doesn't print the sel)
                FBufferNextPaint and        // and we're temporarily allowing a double buffer
                FControlCanDoubleBuffer;    // and the control's supports double buffering
end;

//************************************************************

procedure TAddictLiveRichEdit.MarkLineHeightCacheDirty;
var
    Index   :LongInt;
begin
    for Index := 0 to FLineList.Count - 1 do
    begin
        if Assigned(FLineList[Index]) then
        begin
            TLineCache(FLineList[Index]).DrawDelta := 0;
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.MarkAllLinesDirty;
var
    Index   :LongInt;
begin
    for Index := 0 to FLineList.Count - 1 do
    begin
        if Assigned(FLineList[Index]) then
        begin
            TLineCache(FLineList[Index]).Dirty := True;
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.CheckWatchSpelling;
var
    Spell   :Boolean;
    Correct :Boolean;
begin
    // Setup our defaults...

    Spell   := FLiveSpelling;
    Correct := FLiveCorrect;

    // Now adjust the options based upon the configuration if we're
    // using Addict's options...

    if  Assigned(FAddictSpell) and
        HandleAssigned and
        (not(assigned(FEdit)) or not(csDesigning in FEdit.ComponentState)) and
        FLiveOptions then
    begin
        if (FLiveSpelling) then
        begin
            FAddictSpell.ConfigAvailableOptions := FAddictSpell.ConfigAvailableOptions + [soLiveSpelling];
        end;
        if (FLiveCorrect) then
        begin
            FAddictSpell.ConfigAvailableOptions := FAddictSpell.ConfigAvailableOptions + [soLiveCorrect];
        end;

        Spell   :=  (soLiveSpelling in FAddictSpell.Configuration.SpellOptions) and
                    (soLiveSpelling in FAddictSpell.ConfigAvailableOptions);
        Correct :=  (soLiveCorrect in FAddictSpell.Configuration.SpellOptions) and
                    (soLiveCorrect in FAddictSpell.ConfigAvailableOptions);
    end;

    // Now, the final determination based upon availability

    Spell   := Spell and Assigned(FAddictSpell) and FLiveSpelling and
                (FLiveReadOnly or (not ReadOnly));
    Correct := Correct and Assigned(FAddictSpell) and FLiveCorrect and
                (FLiveReadOnly or (not ReadOnly));

    // And finally make the switch only if we need to...

    if (Spell <> FWatchSpelling) then
    begin
        FWatchSpelling := Spell;

        if not FWatchSpelling then
        begin
            FLineList.Clear;
        end;

        if HandleAssigned then
        begin
            InvalidateRect( FHandle, nil, TRUE );
        end;
    end;

    if (Correct <> FWatchCorrect) then
    begin
        FWatchCorrect := Correct;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WordOK( const Word:String; const PrevWord:String ):Boolean;
var
    Index       :Integer;
    Replacement :String;
    CheckType   :TWordCheckType;
begin
    Result      := FAddictSpell.WordAcceptable( Word );
    if (Result) then
    begin
        if FAddictSpell.UseExcludeWords and FAddictSpell.WordExcluded( Word ) then
        begin
            Result      := False;
            CheckType   := wcExcluded;
        end
        else
        begin
            CheckType   := wcAccepted;
        end;
    end
    else
    begin
        CheckType := wcDenied;
    end;

    if not(Result) then
    begin
        if (FUseIgnore and FIgnoreDictionary.IgnoreExists( Word )) then
        begin
            Index := FIgnoreWords.IndexOf( Word );
            if (Index >= 0) then
            begin
                Result := (TStringList(FIgnoreWords.Objects[Index]).IndexOf( PrevWord ) >= 0);
            end;
        end;
    end;

    if (Assigned(FOnWordCheck)) then
    begin
        FOnWordCheck( Self, Word, CheckType, Replacement );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.BeginEditing;
begin
    if (Assigned( FOnBeginEditing )) then
    begin
        FOnBeginEditing( FEdit );   // FEdit may be nil
    end;
end;





//************************************************************
// Property read/write functions
//************************************************************

procedure TAddictLiveRichEdit.WriteWinControl( NewControl:TWinControl );
begin
    FEdit := NewControl;
    if (assigned(FEdit)) then
    begin
        WriteHWND( GetControlHandle );
    end
    else
    begin
        WriteHWND( 0 );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteHWND( NewHWND: HWND );
var
    ClassName           :Array[0..1023] of Char;
    Name                :String;
begin
    if (Assigned(FEdit) and (GetControlHandle <> NewHWND)) then
    begin
        // This will cause ourselves to be re-entered... be wary of that.
        FEdit := nil;
    end;

    if (HandleAssigned) then
    begin
        InvalidateRect( FHandle, nil, TRUE );
    end;

    FHandle := NewHWND;
    if (HandleAssigned) then
    begin
        ClassName[0]        := #0;
        GetClassName( FHandle, ClassName, 1024 );
        Name                := ClassName;
        Name                := AnsiLowercase( Name );

        FLMDTools           := (pos( 'lmd', Name ) > 0);
        FInfoPower          := (pos( 'ww', Name ) > 0);
        FDXMemo             := (pos( 'dxmemo', Name ) > 0);
        FDXInPlace          := (pos( 'dxinplace', Name ) > 0);
        FRXLib              := ((pos( 'rx', Name ) > 0) or (pos( 'jv', Name ) > 0));

        if (FLMDTools) then
        begin
            // LMD Tools doesn't erase the background properly, so we turn
            // off double buffering for them...

            FControlCanDoubleBuffer := False;
        end;

        CheckWatchSpelling;
    end;    
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteParsingEngine( NewEngine:TParsingEngine );
begin
    if (Assigned(NewEngine)) then
    begin
        FParsingEngine.Free;
        FParsingEngine := NewEngine;

        if (Assigned( FAddictSpell )) then
        begin
            FParsingEngine.OnInlineIgnore   := AddictSpell.RunInlineIgnore;
            FParsingEngine.OnPreCheckIgnore := AddictSpell.RunPreCheckIgnore;
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteLiveSpelling( LiveSpelling:Boolean );
begin
    FLiveSpelling       := LiveSpelling;
    CheckWatchSpelling;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteLiveCorrect( LiveCorrect:Boolean );
begin
    FLiveCorrect        := LiveCorrect;
    CheckWatchSpelling;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteAddictSpell( AddictSpell:TAddictSpell3Base );
begin
    if (FAddictSpell <> AddictSpell) then
    begin
        // Unhook the previous instance...

        if  (Assigned(FAddictSpell)) and
            (   not(assigned(FEdit)) or
                not(csDesigning in FEdit.ComponentState)    ) then  // "Borrowing" component state...
        begin
            FAddictSpell.OnAddCustomIgnoreList.Remove(Self);
            FAddictSpell.OnConfigChangedList.Remove(Self);
            FAddictSpell.OnParserIgnoreWordList.Remove(Self);
            FAddictSpell.OnPopupResultList.Remove(Self);
        end;

        FAddictSpell        := AddictSpell;

        // Hook up the new instance...

        if  (Assigned(FAddictSpell)) and
            (   not(assigned(FEdit)) or
                not(csDesigning in FEdit.ComponentState)    ) then  // "Borrowing" component state...
        begin
            FAddictSpell.OnAddCustomIgnoreList.Add( Self, OnAddCustomIgnore );
            FAddictSpell.OnConfigChangedList.Add( Self, OnConfigChanged );
            FAddictSpell.OnParserIgnoreWordList.Add( Self, OnParserIgnoreWord );
            FAddictSpell.OnPopupResultList.Add( Self, OnPopupResult );

            FParsingEngine.OnInlineIgnore   := AddictSpell.RunInlineIgnore;
            FParsingEngine.OnPreCheckIgnore := AddictSpell.RunPreCheckIgnore;
        end
        else
        begin
            FParsingEngine.OnInlineIgnore   := nil;
            FParsingEngine.OnPreCheckIgnore := nil;
        end;

        CheckWatchSpelling;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteLiveColor( Color:TColor );
begin
    if (Color <> FLiveColor) then
    begin
        FLiveColor := Color;

        if HandleAssigned then
        begin
            InvalidateRect( FHandle, nil, TRUE );
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteLiveOptions( Options:Boolean );
begin
    FLiveOptions := Options;

    CheckWatchSpelling;
end;

//************************************************************

procedure TAddictLiveRichEdit.WriteLiveReadOnly( NewLiveReadOnly:Boolean );
begin
    FLiveReadOnly   := NewLiveReadOnly;

    CheckWatchSpelling;
end;



//************************************************************
// RichEdit Utility Functions
//************************************************************

function TAddictLiveRichEdit.GetLineString( Index:Integer ):String;
var
    Text    :array[0..4095] of Char;
    Len     :Integer;
begin
    if HandleAssigned then
    begin
        Word((@Text)^) := SizeOf(Text);
        Len := SendMessage( FHandle, EM_GETLINE, Index, Longint(@Text) );
        SetString( Result, Text, Len );
    end
    else
    begin
        Result := '';
    end;
end;

//************************************************************

function TAddictLiveRichEdit.SelStart:LongInt;
var
    StartPos    :DWORD;
    EndPos      :DWORD;
begin
    StartPos    := 0;
    if HandleAssigned then
    begin
        SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );
    end;

    Result := StartPos;
end;

//************************************************************

function TAddictLiveRichEdit.SelLength:LongInt;
var
    StartPos    :DWORD;
    EndPos      :DWORD;
begin
    StartPos    := 0;
    EndPos      := 0;
    if HandleAssigned then
    begin
        SendMessage( FHandle, EM_GETSEL, LongInt(@StartPos), LongInt(@EndPos) );
    end;

    Result := LongInt(EndPos - StartPos);
end;

//************************************************************

function TAddictLiveRichEdit.SelText:String;
var
    Text    :array[0..4095] of Char;
    Len     :Integer;
begin
    Result := '';
    if (SelLength < 4000) and (HandleAssigned) then
    begin
        Len := SendMessage( FHandle, EM_GETSELTEXT, 0, Longint(@Text) );
        SetString( Result, Text, Len );
    end;
end;

//************************************************************

function TAddictLiveRichEdit.WordWrap:Boolean;
begin
    Result :=   HandleAssigned and
                ((GetWindowLong( FHandle, GWL_STYLE ) and ES_MULTILINE) <> 0);
end;

//************************************************************

function TAddictLiveRichEdit.ReadOnly:Boolean;
begin
    Result :=   HandleAssigned and
                ((GetWindowLong( FHandle, GWL_STYLE ) and ES_READONLY) <> 0);
end;

//************************************************************

procedure TAddictLiveRichEdit.SetUpdateState( Updating:Boolean );
begin
    if HandleAssigned then
    begin
        // In some instances we've seen IsWindowVisible return
        // false if the window was locked for Redraw... thus
        // the (not Updating) bit on the end...

        if (IsWindowVisible(FHandle)) or (not Updating)then
        begin
            SendMessage( FHandle, WM_SETREDRAW, Ord(not Updating), 0 );
        end;
        if not Updating then
        begin
            if Assigned(FEdit) and (FEdit.Handle = FHandle) then
            begin
                FEdit.Refresh;
            end
            else
            begin
                InvalidateRect( FHandle, nil, TRUE );
                UpdateWindow( FHandle );
            end;
            SendMessage( FHandle, CM_TEXTCHANGED, 0, 0 );
        end;
    end;
end;



//************************************************************
// Painting Utility Functions
//************************************************************

// This code, whilst seemingly somewhat scary is actually
// moderately straightforward.  It attempts to ascertain the
// proper location to draw the squiggly line under a piece of
// text by looking at the bits in the control directly.

function TAddictLiveRichEdit.GetTextBottomPixelPosition( DC:HDC; LineNum:Integer; XStart:Integer; YStart:Integer; NextLineStart:Integer ):Integer;
var
    Index       :Integer;
    MaxHeight   :Integer;
    CountArray  :array of Integer;
    HitCount    :Integer;
    ValidPixel  :Boolean;
    HitBottom   :Boolean;
    PixelColor  :COLORREF;
    FirstColor  :COLORREF;
    MaxPosition :Integer;
    LineCache   :TLineCache;
begin
    LineCache   := nil;
    MaxHeight   := NextLineStart - YStart;

    // First of all, this method is about the farthest thing from being
    // fast... thus we cache the data in the LineCache and if we already have
    // it around, then we return it straight out of the cache...

    if (FLineList.Count > LineNum) then
    begin
        LineCache := TLineCache(FLineList[LineNum]);
        if (Assigned(LineCache)) then
        begin
            if (LineCache.NextLineDelta = MaxHeight) and (LineCache.DrawDelta > 0) then
            begin
                Result := LineCache.DrawDelta;
                Exit;
            end;
        end;
    end;

    SetLength( CountArray, MaxHeight );
    for Index := 0 to MaxHeight-1 do
    begin
        CountArray[Index] := 0;
    end;

    HitCount := 0;

    // Continue until we've run out of valid pixels to look at, or
    // until we hit what we feel is a good point at which we think we can
    // make an accurate guess (currently denoted at 100)

    repeat
        ValidPixel  := False;
        HitBottom   := False;
        FirstColor  := CLR_INVALID;
        MaxPosition := 0;

        // Walk the line of pixels top to bottom and determine what the
        // bottommost position of the textcolor is for this line.

        for Index := 0 to MaxHeight-1 do
        begin
            PixelColor := GetPixel( DC, XStart, YStart + Index );
            if (PixelColor <> CLR_INVALID) and (PixelColor <> COLORREF(FLiveColor)) then
            begin
                ValidPixel := True;

                if (FirstColor = CLR_INVALID) then
                begin
                    FirstColor := PixelColor;
                end
                else if (FirstColor <> PixelColor) then
                begin
                    MaxPosition := Index;
                end;

                if (Index = MaxHeight-1) then
                begin
                    HitBottom := True;
                end;
            end;
        end;

        // If we actually hit the bottom and we have a position, then we
        // can mark this one as a hit...

        if (MaxPosition > 0) and (HitBottom) then
        begin
            inc(HitCount);
            inc(CountArray[MaxPosition]);
        end;

        // Do the next vertical line...

        inc(XStart);

    until not(ValidPixel) or (HitCount > (MaxHeight * 6));

    // Now, determine what bottommost text position was used most frequently...
    // this is most likely to give us the baseline for the bottom of the text.

    MaxPosition := 0;
    for Index := 1 to MaxHeight-1 do
    begin
        if (CountArray[Index] > CountArray[MaxPosition]) then
        begin
            MaxPosition := Index;
        end;
    end;

    // If we have sufficient hits at the max position (subjectively chosen at 5)
    // Then we can return our result based upon that position and cache the
    // value for future usage... else we give up and return the appropriate spot
    // based upon the next line.

    if (MaxPosition > 0) and (CountArray[MaxPosition] > 5) then
    begin
        Result := MaxPosition + 4;

        if (Assigned(LineCache)) then
        begin
            LineCache.NextLineDelta := MaxHeight;
            LineCache.DrawDelta     := Result;
        end;
    end
    else
    begin
        Result := MaxHeight;
    end;
end;

//************************************************************

function TAddictLiveRichEdit.GetLastLineTextBottomPixelPosition(    GuessedPosition:Integer;
                                                                    DrawDC:HDC;
                                                                    LineNum:Integer;
                                                                    FirstErrorXStart:Integer; FirstErrorXStop:Integer;
                                                                    StartPosition:TPoint;
                                                                    LineChecked:Boolean ):Integer;
var
    LineCache       :TLineCache;
    Index           :Integer;
    TopBottom       :Integer;
    PixelColor      :COLORREF;
    MatchedColors   :Array[0..1,0..1] of COLORREF;  // [top/bottom][color1/color2]
    MatchedCounts   :Array[0..1,0..1] of COLORREF;  // [top/bottom][color1/color2]
    Offset          :Integer;
    MaxHeight       :Integer;
    CountArray      :array of Integer;
    TopStart        :Integer;
    HitBottom       :Boolean;
    FirstColor      :COLORREF;
    MaxPosition     :Integer;
    YIndex          :Integer;
    TextPos         :TPoint;
begin
    LineCache := nil;

    // OK, first lets go see if we've run this already and the results are in
    // our line cache... if they are, then we're done.

    if (FLineList.Count > LineNum) then
    begin
        LineCache := TLineCache(FLineList[LineNum]);
    end;

    if (not Assigned(LineCache)) then
    begin
        Result := GuessedPosition;
        Exit;
    end;

    // Since we re-check lines everytime we paint *and* they are dirty, we're
    // only interested in regenerating this position (if we have a valid stored
    // position) when the line is checked/changed.

    if  (not LineChecked) and
        (LineCache.NextLineDelta = 0) and
        (LineCache.DrawDelta > 0) then
    begin
        Result := LineCache.DrawDelta;
        Exit;
    end;

    LineCache.NextLineDelta    := 0;
    LineCache.DrawDelta        := 0;

    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), FirstErrorXStart );
    FirstErrorXStart    := TextPos.X;

    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), FirstErrorXStop );
    FirstErrorXStop     := TextPos.X;

    // OK, first thing's first... we attempt to do a quick validation that the
    // GuessedPosition is accurate.  Hopefully it is... it'll save us alot of
    // problems...

    // Quick verification is to scan slightly above the proposed position and
    // see if the area has some signs of having text on it... also to scan along
    // where the draw is to happen to verify that the area is vacant presently...

    for Index := 0 to 1 do
    begin
        for TopBottom := 0 to 1 do
        begin
            MatchedColors[TopBottom][Index] := CLR_INVALID;
            MatchedCounts[TopBottom][Index] := 0;
        end;
    end;

    for Index := FirstErrorXStart to FirstErrorXStop do
    begin
        for TopBottom := 0 to 1 do
        begin
            if (TopBottom = 0) then
            begin
                Offset := -8;
            end
            else
            begin
                // We paint from offsets (-2 to -4)...
                // Offset (-3) allows us to look down the line...
                Offset := -3;
            end;

            PixelColor := GetPixel( DrawDC, Index, StartPosition.Y + GuessedPosition + Offset );
            if (PixelColor = CLR_INVALID) then
            begin
                Result := GuessedPosition;
                Exit;
            end;

            if (MatchedColors[TopBottom][0] = CLR_INVALID) then
            begin
                if (PixelColor <> COLORREF(FLiveColor)) then
                begin
                    MatchedColors[TopBottom][0] := PixelColor;
                    inc(MatchedCounts[TopBottom][0]);
                end;
            end
            else if (MatchedColors[TopBottom][0] = PixelColor) then
            begin
                inc(MatchedCounts[TopBottom][0]);
            end
            else if (MatchedColors[TopBottom][1] = CLR_INVALID) then
            begin
                if (PixelColor <> COLORREF(FLiveColor)) then
                begin
                    MatchedColors[TopBottom][1] := PixelColor;
                    inc(MatchedCounts[TopBottom][1]);
                end;
            end
            else if (MatchedColors[TopBottom][1] = PixelColor) then
            begin
                inc(MatchedCounts[TopBottom][1]);
            end;
        end;
    end;

    if (MatchedColors[0][1] <> CLR_INVALID) then
    begin
        // OK, if we have a 2nd color match on the top row check, then the main
        // thing to look for is a non-match on the bottom row, or a heavy
        // balance on the bottom row...

        if  (MatchedCounts[1][0] > (Round(0.75 * (FirstErrorXStop - FirstErrorXStart)))) or
            (MatchedCounts[1][1] > (Round(0.75 * (FirstErrorXStop - FirstErrorXStart)))) then
        begin
            // Cache our value and return...

            LineCache.DrawDelta := GuessedPosition;
            Result              := GuessedPosition;
            Exit;
        end;
    end;

    // Unfortunately, we don't believe that we're going to draw the squiggle
    // in the correct place now.  We need to attempt to figure out how to detect
    // where the proper place to draw it is now....  we'll take an approach similar
    // to GetTextBottomPixelPosition, except we have to be a bit more wide open

    MaxHeight := 300;
    SetLength( CountArray, MaxHeight );
    for Index := 0 to MaxHeight-1 do
    begin
        CountArray[Index] := 0;
    end;

    TopStart    := StartPosition.Y;

    for Index := FirstErrorXStart to FirstErrorXStop do
    begin
        HitBottom   := True;
        FirstColor  := CLR_INVALID;
        MaxPosition := 0;

        // Walk the line of pixels top to bottom and determine what the
        // bottommost position of the textcolor is for this line.

        for YIndex := 0 to MaxHeight-1 do
        begin
            PixelColor := GetPixel( DrawDC, Index, TopStart + YIndex );
            if (PixelColor = CLR_INVALID) then
            begin
                HitBottom := (YIndex > 0);
                break;
            end;

            if (FirstColor = CLR_INVALID) then
            begin
                if (PixelColor <> COLORREF(FLiveColor)) then
                begin
                    FirstColor := PixelColor;
                end;
            end
            else if (FirstColor <> PixelColor) then
            begin
                if (PixelColor <> COLORREF(FLiveColor)) then
                begin
                    MaxPosition := YIndex;
                end;
            end
            else
            begin
                if (MaxPosition > 0) and (MaxPosition < (YIndex - 15)) then
                begin
                    // We've passed the text by more than 15 pixels... assume
                    // we're done with it...

                    break;
                end;
            end;
        end;

        // If we actually hit the bottom and we have a position, then we
        // can mark this one as a hit...

        if (MaxPosition > 0) and (HitBottom) and (MaxPosition < MaxHeight) then
        begin
            inc(CountArray[MaxPosition]);
        end;
    end;

    // Now, determine what bottommost text position was used most frequently...
    // this is most likely to give us the baseline for the bottom of the text.

    MaxPosition := 0;
    for Index := 1 to MaxHeight-1 do
    begin
        if (CountArray[Index] > CountArray[MaxPosition]) then
        begin
            MaxPosition := Index;
        end;
    end;

    // If we have hits at this position, then we choose it as the default
    // position under which we'll put our line....

    if (MaxPosition > 0) and (CountArray[MaxPosition] > 0) then
    begin
        Result              := MaxPosition + 4;
        LineCache.DrawDelta := Result;
        Exit;
    end;

    Result := GuessedPosition;
end;


//************************************************************

function TAddictLiveRichEdit.GetDrawingYPos( DrawDC:HDC; LineNum:Integer; FirstErrorXStart:Integer; FirstErrorXStop:Integer; LineChecked:Boolean ):Integer;
var
    CharPos         :LongInt;
    dc              :HDC;
    tmFont          :TTextMetric;
    StartPosition   :TPoint;
    Position        :TPoint;
    NextLinePos     :LongInt;
    Format          :TCharFormat;
    Font            :TFont;
    OldFont         :HFont;
    TextPos         :TPoint;
begin
    if not(HandleAssigned) then
    begin
        Result := 0;
        Exit;
    end;

    CharPos := SendMessage( FHandle, EM_LINEINDEX, LineNum, 0 );
    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@StartPosition), CharPos );

    // Get the font height to adjust the bottom...

    dc := GetDC( FHandle );
    GetTextMetrics( dc, tmFont );
    ReleaseDC( FHandle, dc );

    Result      := StartPosition.Y + (tmFont.tmHeight + tmFont.tmExternalLeading);

    // OK... this will usually get the job done for us, but the RichEdit could
    // have an embedded or switched fonts bitmap that will make this line taller
    // than we would really expect it to be... so we'll make an honest attempt
    // to account for that.

    NextLinePos := SendMessage( FHandle, EM_LINEINDEX, LineNum + 1, 0 );
    if (NextLinePos <> -1) then
    begin
        SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@Position), NextLinePos );

        if (FIrregularLineHeights) and (Position.Y > StartPosition.Y) then
        begin
            SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), FirstErrorXStart );
            Result := StartPosition.Y + GetTextBottomPixelPosition( DrawDC, LineNum, TextPos.X, StartPosition.Y, Position.Y );
        end
        else if (Position.y > Result) then
        begin
            Result := Position.y + 4;
        end;
    end
    else
    begin
        // In this case, getting the NextLinePos has failed which most likely
        // means that we've gone off of the current line...

        // We need to do a sanity check to make sure we're not drawing the
        // squiggly line on the word if the font sizes are different for the
        // last line... we do this by getting the default charformat and
        // doing some calculations to determine the font height from it.

        ZeroMemory( @Format, sizeof(Format) );
        Format.cbSize   := sizeof(Format);
        SendMessage( FHandle, EM_GETCHARFORMAT, 0, LPARAM(@Format) );

        Font := TFont.Create;
        try
            dc := CreateCompatibleDC(0);
            if (dc <> 0) then
            begin
                Font.Name   := Format.szFaceName;
                Font.Size   := (Format.yHeight div 20);
                OldFont     := SelectObject( dc, Font.Handle );
                GetTextMetrics( dc, tmFont );
                SelectObject( dc, OldFont );
                DeleteDC(dc);
            end;
        finally
            Font.Free;
        end;

        dec( tmFont.tmHeight );
        if ((StartPosition.Y + (tmFont.tmHeight + tmFont.tmExternalLeading)) > Result) then
        begin
            Result := StartPosition.Y + (tmFont.tmHeight + tmFont.tmExternalLeading)
        end;

        // OK, based on a bug report we've also identified that if an embedded picture (or a
        // drastic font size change happens on the *last* line of text, then the squiggle could
        // get out of sync with the text.  So, for this case, we're going to always attempt
        // based upon pixel position where the bottom position of that line is.

        Result := StartPosition.Y + GetLastLineTextBottomPixelPosition( (Result - StartPosition.Y), DrawDC, LineNum, FirstErrorXStart, FirstErrorXStop, StartPosition, LineChecked );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.DrawMarker( DC:HDC; YPos:LongInt; StartPos:LongInt; EndPos:LongInt );
var
    Points      :Array[0..1023] of TPoint;
    PCount      :Integer;
    UpSlope     :Boolean;
    TextPos     :TPoint;
begin
    if not(HandleAssigned) then
    begin
        Exit;
    end;

    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), StartPos );
    StartPos := TextPos.X;

    SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), EndPos );
    EndPos := TextPos.X;

    PCount  := 0;
    UpSlope := True;

    while ((PCount < 1024) and (StartPos < EndPos)) do
    begin
        Points[PCount].X := StartPos;
        inc(StartPos, 2);

        if (UpSlope) then
        begin
            Points[PCount].Y := YPos - 4;
        end
        else
        begin
            Points[PCount].Y := YPos - 2;
        end;

        inc( PCount );
        UpSlope := not UpSlope;
    end;

    if (PCount > 0) then
    begin
        Points[PCount - 1].X := EndPos;

        MoveToEx( DC, Points[0].x, Points[0].y, nil );
        PolylineTo( DC, Points, PCount );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.PaintSpellingErrors( DC:HDC );
var
    LineNum         :LongInt;
    LineText        :String;
    Word            :String;
    PrevWord        :String;
    XPos            :LongInt;
    YPos            :LongInt;
    LineCache       :TLineCache;
    SpellingError   :TSpellingError;
    Index           :Integer;
    TextPos         :TPoint;
    SStart          :LongInt;
    LineStartPos    :LongInt;
    DirtyVal        :Boolean;
    hNewPen         :HPEN;
    hOldPen         :HGDIOBJ;
    YDrawPos        :Integer;
    ClientRect      :TRect;
    LineChecked     :Boolean;
begin
    if  not(Assigned(FAddictSpell)) or
        not(HandleAssigned) then
    begin
        exit;
    end;

    FUseIgnore := (spIgnore in FLiveMenuOptions);

    GetClientRect( FHandle, ClientRect );

    // Create the pen we'll be using and select it into the DC

    hNewPen := CreatePen( PS_SOLID, 1, FLiveColor );
    hOldPen := SelectObject( DC, hNewPen );

    try
        // Cache the position of the cursor away...

        SStart      := SelStart;

        // Iterate through all visible lines...

        LineNum     := SendMessage( FHandle, EM_GETFIRSTVISIBLELINE, 0, 0 );

        repeat
            LineChecked := False;
            LineText    := GetLineString( LineNum );

            if (FLineList.Count <= LineNum) then
            begin
                FLineList.Count := LineNum + 64;
            end;

            // Get our structure representing this line

            LineCache := TLineCache(FLineList[LineNum]);

            if (not Assigned(LineCache)) then
            begin
                LineCache           := TLineCache.Create;
                FLineList[LineNum]  := LineCache;
            end;

            // If the line is dirty or has changed, then we need to figure
            // out the spelling errors for it.

            if LineCache.Dirty or (LineCache.OldLine <> LineText) then
            begin
                LineChecked         := True;
                LineCache.OldLine   := LineText;
                LineCache.SpellingErrors.Clear;

                DirtyVal := False;

                LineStartPos := SendMessage( FHandle, EM_LINEINDEX, LineNum, 0 );

                if not(FAddictSpell.RunLineIgnore(LineText)) then
                begin
                    // Walk all words on this line

                    FStringParser.Initialize( @LineText );

                    FParsingEngine.Initialize( FStringParser, CheckType_All );

                    Word        := FParsingEngine.NextWord;
                    PrevWord    := '';

                    while (Word <> '') do
                    begin
                        if not(WordOK( Word, PrevWord )) then
                        begin
                            FStringParser.GetPosition( XPos, YPos );

                            // We don't want to call out the word the cursor
                            // immediately follows as being misspelled (until they
                            // leave it).

                            if  (SStart <> (LineStartPos + XPos - 1)) or
                                (GetFocus <> FHandle) then
                            begin
                                SpellingError := TSpellingError.Create;

                                SpellingError.X2 := (XPos - 1);
                                SpellingError.X1 := (XPos - Length(Word) - 1);

                                LineCache.SpellingErrors.Add( SpellingError );
                            end
                            else
                            begin
                                DirtyVal := True;
                            end;
                        end;

                        if (FUseIgnore) then
                        begin
                            PrevWord := Word;
                        end;

                        Word    := FParsingEngine.NextWord;
                    end;
                end;

                LineCache.Dirty := DirtyVal;
            end;

            // Paint spelling errors on this line

            if (LineCache.SpellingErrors.Count > 0) then
            begin
                LineStartPos  := SendMessage( FHandle, EM_LINEINDEX, LineNum, 0 );
                SpellingError := TSpellingError(LineCache.SpellingErrors[0]);
                YDrawPos      := GetDrawingYPos( DC, LineNum, SpellingError.X1 + LineStartPos, SpellingError.X2 + LineStartPos, LineChecked );

                for Index := 0 to LineCache.SpellingErrors.Count - 1 do
                begin
                    SpellingError := TSpellingError(LineCache.SpellingErrors[Index]);
                    DrawMarker( DC, YDrawPos, SpellingError.X1 + LineStartPos, SpellingError.X2 + LineStartPos );
                end;
            end;

            inc(LineNum);

            // Check to see if we've run out of lines or visible lines...

            Index := SendMessage( FHandle, EM_LINEINDEX, WPARAM(LineNum), 0 );
            if (Index >= 0) then
            begin
                SendMessage( FHandle, Messages.EM_POSFROMCHAR, WPARAM(@TextPos), Index );
            end;

        until (Index < 0) or (TextPos.Y > ClientRect.Bottom);

    finally
        SelectObject( DC, hOldPen );
        DeleteObject( hNewPen );
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.CheckCorrect( Key: Char );
var
    StartPos        :LongInt;
    LineNum         :LongInt;
    LineText        :String;
    LineStartPos    :LongInt;
    Word            :String;
    Correction      :String;
begin
    StartPos    := SelStart;

    if  (FWatchCorrect) and
        HandleAssigned and
        (pos( Key, FExpandKeys ) > 0) and
        (SelLength = 0) then
    begin
        LineNum         := SendMessage( FHandle, EM_LINEFROMCHAR, WPARAM(StartPos), 0 );
        LineText        := GetLineString( LineNum );
        LineStartPos    := SendMessage( FHandle, EM_LINEINDEX, LineNum, 0 );

        FAPIParser.InitializeFromHWND( FHandle );

        FParsingEngine.Initialize( FAPIParser, CheckType_All );
        FParsingEngine.AdjustToPosition( StartPos - LineStartPos - 2, LineNum );

        Word := FParsingEngine.NextWord;

        if (Word <> '') and (not(WordOK( Word, '' )) or (FAddictSpell.UseAutoCorrectFirst))then
        begin
            if (FAddictSpell.WordHasCorrection( Word, Correction )) then
            begin
                SetUpdateState( True );
                try
                    BeginEditing;
                    FAPIParser.SelectWord( Length(Word) );
                    FAPIParser.ReplaceWord( Correction, ReplacementState_AutoCorrect );

                    StartPos := StartPos + (Length(Correction) - Length(Word));
                    SendMessage( FHandle, EM_SETSEL, StartPos, StartPos );
                finally
                    SetUpdateState( False );
                end;
            end;
        end;
    end;
end;




//************************************************************
// Publicly Exposed Functions
//************************************************************

procedure TAddictLiveRichEdit.SearchAndReplace( Word:String; ReplacementWord:String );
var
    FindWord    :String;
    StartTime   :DWORD;
    CursorShown :Boolean;
    OldCursor   :TCursor;
    SStart      :LongInt;
    SLen        :LongInt;
begin
    if  (Word = ReplacementWord) or
        FSearching or
        not HandleAssigned then
    begin
        Exit;
    end;

    CursorShown := False;
    StartTime   := GetTickCount;
    OldCursor   := 0;

    SStart      := SelStart;
    SLen        := SelLength;

    FSearching := True;
    SetUpdateState( True );
    try
        FAPIParser.InitializeFromHWND( FHandle );

        FParsingEngine.Initialize( FAPIParser, CheckType_All );

        FindWord := FParsingEngine.NextWord;
        while (FindWord <>'') do
        begin
            if (FindWord = Word) then
            begin
                BeginEditing;
                FAPIParser.SelectWord( Length(FindWord) );
                FAPIParser.ReplaceWord( ReplacementWord, ReplacementState_Replace );
            end;

            if (not CursorShown) and ((GetTickCount - StartTime) > 500) then
            begin
                CursorShown     := True;
                OldCursor       := Screen.Cursor;
                Screen.Cursor   := crHourglass;
            end;

            FindWord := FParsingEngine.NextWord;
        end;

        SendMessage( FHandle, EM_SETSEL, SStart, SStart + SLen );

    finally

        SetUpdateState( False );
        FSearching := False;
        if (CursorShown) then
        begin
            Screen.Cursor   := OldCursor;
        end;
    end;

    InvalidateRect( FHandle, nil, TRUE );
end;

//************************************************************

procedure TAddictLiveRichEdit.IgnoreWord( State:LongInt );
var
    Word        :String;
    PrevWord    :String;
    NextWord    :String;
    CurXPos     :Integer;
    CurYPos     :Integer;
    Index       :Integer;
    IRect       :TRect;
    XPos        :Integer;
    YPos        :Integer;
begin
    if (FWatchSpelling) and (HandleAssigned) then
    begin
        case State of
        IgnoreState_Ignore:
            begin
                FAPIParser.InitializeFromHWND( FHandle );
                FAPIParser.GetCursorPosition( XPos, YPos );

                FParsingEngine.Initialize( FAPIParser, CheckType_All );
                FParsingEngine.AdjustToPosition( XPos, YPos );

                Word := FParsingEngine.NextWord;

                if (Word = SelText) then
                begin
                    FParsingEngine.AdjustToPosition( 0, YPos );

                    PrevWord := '';
                    NextWord := '';

                    repeat
                        NextWord := FParsingEngine.NextWord;

                        FAPIParser.GetPosition( CurXPos, CurYPos );

                        if (CurXPos >= XPos) or (NextWord = '') then
                        begin
                            break;
                        end;

                        PrevWord := NextWord;

                    until (CurYPos <> YPos);

                    if (NextWord = Word) then
                    begin
                        FAPIParser.SelectWord( Length(Word) );

                        FIgnoreDictionary.AddIgnore( Word );

                        Index := FIgnoreWords.IndexOf( Word );
                        if (Index < 0) then
                        begin
                            Index := FIgnoreWords.Add( Word );
                        end;

                        if not(Assigned( FIgnoreWords.Objects[Index] )) then
                        begin
                            FIgnoreWords.Objects[Index] := TStringList.Create;
                            TStringList(FIgnoreWords.Objects[Index]).Sorted     := True;
                            TStringList(FIgnoreWords.Objects[Index]).Duplicates := dupIgnore;
                        end;

                        TStringList(FIgnoreWords.Objects[Index]).Add( PrevWord );

                        if (YPos < FLineList.Count) and Assigned(FLineList[YPos]) then
                        begin
                            FAPIParser.GetSelectionScreenPosition( IRect );
                            InvalidateRect( FHandle, @IRect, TRUE );

                            TLineCache(FLineList[YPos]).Dirty := True;
                        end;
                    end;
                end;
            end;

        IgnoreState_Add, IgnoreState_IgnoreAll:
            begin
                // Remove the selection before invalidating to get the
                // buffered painting code back involved before the invalidate

                SendMessage( FHandle, EM_SETSEL, SelStart, SelStart );

                MarkAllLinesDirty;
                InvalidateRect( FHandle, nil, TRUE );

                // Note that we force the redraw now.  Reason is that we
                // invalidate we're probably not going to process another paint
                // message until the next time we select something... at which
                // we can't use double buffering.  Instead, we force the paint
                // now so we can get away with it.

                if (Assigned(FEdit)) then
                begin
                    FEdit.Update;
                end
                else
                begin
                    UpdateWindow( FHandle );
                end;
            end;
        end;
    end;
end;

//************************************************************

procedure TAddictLiveRichEdit.Check( CheckType:TCheckType );
var
    Parser      :TWinAPIControlParser;
begin
    if  Assigned(FAddictSpell) and
        HandleAssigned then
    begin
        Parser := TWinAPIControlParser.Create;
        Parser.InitializeFromHWND( FHandle );

        FAddictSpell.CheckParser( Parser, CheckType );

        if not(FAddictSpell.FreeParser) then
        begin
            Parser.Free;
        end;
    end;
end;


end.


