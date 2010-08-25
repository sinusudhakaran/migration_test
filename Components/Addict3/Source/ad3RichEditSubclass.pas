{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10855: ad3RichEditSubclass.pas 
{
{   Rev 1.4    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:28 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:48 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:36 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:46 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Livespell enabled RichEdit interface

History:
3/18/01     - Michael Novak     - Initial Write

**************************************************************)

unit ad3RichEditSubclass;

{$I addict3.inc}

interface

uses
    ComCtrls, messages, classes, graphics, richedit, windows, controls, forms,
    ad3Util,
    ad3LiveRichEdit;

type
    //************************************************************
    // Livespell interface for a RichEdit control
    //************************************************************

    TAddictRichEditSubclass = class(TAddictLiveRichEdit)
    protected
        FSubclassHandle :HWND;

        FDefWndProc     :Pointer;
        FInstance       :Pointer;

        FLastStartPos   :DWORD;

    protected

        procedure WriteHWND( NewHWND: HWND ); override;

        procedure SubclassWndProc( var Message:TMessage );

    public
        constructor Create;
        destructor Destroy; override;
                
    end;


implementation


//************************************************************
// TAddictRichEditSubclass
//************************************************************

constructor TAddictRichEditSubclass.Create;
begin
    inherited Create;

    FSubclassHandle         := 0;

    FDefWndProc     := nil;
    {$IFDEF Delphi6AndAbove}
    FInstance       := Classes.MakeObjectInstance(SubclassWndProc);
    {$ELSE}
    FInstance       := MakeObjectInstance(SubclassWndProc);
    {$ENDIF}

    FLastStartPos   := 0;
end;

//************************************************************

destructor TAddictRichEditSubclass.Destroy;
begin
    WinControl := nil;

    {$IFDEF Delphi6AndAbove}
    Classes.FreeObjectInstance(FInstance);
    {$ELSE}
    FreeObjectInstance(FInstance);
    {$ENDIF}

    inherited;
end;


//************************************************************
// Property read/write functions
//************************************************************

procedure TAddictRichEditSubclass.WriteHWND( NewHWND: HWND );
begin
    if ((FSubclassHandle <> 0) and (IsWindow(FSubclassHandle))) then
    begin
        SetWindowLong( FSubclassHandle, GWL_WNDPROC, LongInt(FDefWndProc) );
        FDefWndProc     := nil;
        FSubclassHandle := 0;
    end;

    inherited WriteHWND( NewHWND );

    if (NewHWND <> 0) and IsWindow(NewHWND) then
    begin
        FSubclassHandle := NewHWND;
        FDefWndProc     := Pointer( GetWindowLong(FSubclassHandle, GWL_WNDPROC) );
        SetWindowLong( FSubclassHandle, GWL_WNDPROC, LongInt(FInstance) );
    end;
end;


//************************************************************
// Subclassed WindowProc
//************************************************************

procedure TAddictRichEditSubclass.SubclassWndProc( var Message:TMessage );
var
    Cleanup     :Boolean;
    StartPos    :DWORD;
    ch          :Char;
begin
    try
        case Message.Msg of

        WM_PAINT:
            begin
                Message.Result := 0;
                if (WMPaint( TWMPaint(Message), Cleanup )) then
                begin
                    Message.Result := CallWindowProc( FDefWndProc, FSubclassHandle, Message.Msg, Message.WParam, Message.LParam );
                end;
                if (Cleanup) then
                begin
                    WMPaintCleanup( TWMPaint(Message) );
                end;

                Exit;
            end;

        WM_ERASEBKGND:
            begin
                Message.Result := 1;
                if not(WMEraseBkgnd( TWMEraseBkgnd(Message) )) then
                begin
                    Exit;
                end;
            end;

        WM_RBUTTONDOWN:
            begin
                if not(WMRButtonDown( TWMRButtonDown(Message) )) then
                begin
                    Exit;
                end;                  
            end;

        WM_CONTEXTMENU:
            begin
                if not(WMContextMenu( TWMContextMenu(Message) )) then
                begin
                    Exit;
                end;
            end;

        WM_SIZE:
            begin
                WMSize( TWMSize(Message) );
            end;

        WM_CHAR:
            begin
                ch := Char(TWMChar(Message).CharCode);
                KeyPress( ch );
            end;

        WM_KEYDOWN,
        WM_SYSKEYDOWN:
            begin
                if not(WMKeyDown( TWMKeyDown(Message) )) then
                begin
                    Exit;
                end;
            end;

        WM_KEYUP:
            begin
                WMKeyUp( TWMKeyUp(Message) );
            end;

        WM_RBUTTONUP:
            begin
                if not(WMRButtonUp( TWMRButtonUp(Message) )) then
                begin
                    Exit;
                end;
            end;

        EM_SETREADONLY:
            begin
                Message.Result := CallWindowProc( FDefWndProc, FSubclassHandle, Message.Msg, Message.WParam, Message.LParam );
                EMSetReadOnly;
                Exit;
            end;

        EM_GETOLEINTERFACE:
            begin
                EMGetOleInterface;
            end;

        EM_SETTARGETDEVICE:
            begin
                EMSetTargetDevice;
            end;

        WM_NCDESTROY:
            begin
                Message.Result  := CallWindowProc( FDefWndProc, FSubclassHandle, Message.Msg, Message.WParam, Message.LParam );
                WinControl      := nil;
                Exit;
            end;

        end;

        case Message.Msg of
        WM_LBUTTONUP,
        WM_MBUTTONUP,
        WM_RBUTTONUP,
        WM_KEYUP:
            begin
                StartPos    := 0;
                SendMessage( FSubclassHandle, EM_GETSEL, LongInt(@StartPos), 0 );
                if (StartPos <> FLastStartPos) then
                begin
                    FLastStartPos := StartPos;
                    NotifySelectionChange;
                end;
            end;
        end;

        Message.Result := CallWindowProc( FDefWndProc, FSubclassHandle, Message.Msg, Message.WParam, Message.LParam );

    except
        Application.HandleException(Self);
    end;
end;


end.

