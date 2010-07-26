unit BKRichEdit;

interface

uses
  Forms,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Controls,
  StdCtrls,
  ComCtrls,
  RzEdit,
  RichEdit;

type
  PENLink = ^TENLink;
  TLinkClickEvent = procedure(Sender: TObject; LinkClicked: string; LinkLine: integer) of object;
  TBKRichEdit = class(TRzRichEdit)
  private
    FOnLinkClicked: TLinkClickEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure DoSetMaxLength(Value: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSelectionLink;
  published
    property OnLinkClicked: TLinkClickEvent read FOnLinkClicked write FOnLinkClicked;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKRichEdit]);
end;

{ TBKRichEdit }

procedure TBKRichEdit.CMMouseEnter(var Msg: TMessage);
begin
  if Enabled then
    begin
      if Assigned(OnMouseEnter) then
        OnMouseEnter(Self);
    end;
end;

procedure TBKRichEdit.CMMouseLeave(var Msg: TMessage);
begin
  if Enabled then
    begin
      if Assigned(OnMouseLeave) then
        OnMouseLeave(Self);
    end;
end;

procedure TBKRichEdit.CNNotify(var Msg: TWMNotify);
var
  TR: TTextRangeA;
begin
  if Msg.NMHdr.code = EN_LINK then
    begin
      if Assigned(OnLinkClicked) then
        begin
          if PENLink(Msg.NMHdr).msg = WM_LBUTTONUP then
            begin
              TR.chrg := PENLink(Msg.NMHdr).chrg;
              GetMem(TR.lpStrText, TR.chrg.cpMax - TR.chrg.cpMin + 2);
              SendMessage(Handle, EM_GETTEXTRANGE, 0, Integer(addr(TR)));
              OnLinkClicked(Self, TR.lpStrText, Line);
              FreeMem(TR.lpStrText);
            end;
        end;
      Msg.Result := 0;
    end
  else
    begin
      inherited;
    end;
end;

constructor TBKRichEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnLinkClicked := nil;
  FOnMouseEnter := nil;
  FOnMouseLeave := nil;
end;

procedure TBKRichEdit.CreateWnd;
begin
  inherited CreateWnd;
  SendMessage(Handle, EM_SETEVENTMASK, 0, SendMessage(Handle, EM_GETEVENTMASK, 0, 0) or ENM_LINK);
  SendMessage(Handle, EM_AUTOURLDETECT, 1, 0);
end;

destructor TBKRichEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TBKRichEdit.DoSetMaxLength(Value: Integer);
begin
  if Value = 0 then
    SendMessage(Handle, EM_EXLIMITTEXT, 0, System.MaxInt -2)
  else
    SendMessage(Handle, EM_EXLIMITTEXT, 0, Value);
end;

procedure TBKRichEdit.Loaded;
begin
  inherited;
  if Self.MaxLength = 0 then
    SendMessage(Handle, EM_EXLIMITTEXT, 0, System.MaxInt -2);
end;

procedure TBKRichEdit.SetSelectionLink;
var
  CF: TCharFormatA;
begin
  FillChar(CF, SizeOf(CF), 0);
  CF.cbSize := SizeOf(CF);
  CF.dwMask := CFM_LINK;
  CF.dwEffects := CFE_LINK;
  SendMessage(Handle, EM_SETCHARFORMAT, SCF_SELECTION, Integer(addr(CF)));
end;

end.

