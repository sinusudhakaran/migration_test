unit OutlookOle;

interface

uses
  Windows, Messages, SysUtils, System.Variants, System.Classes, FMX.Dialogs, FMX.StdCtrls, ComObj, VCL.COMCtrls, VCL.Forms, ActiveX;

type
  TOutlookOle = class
  private
    FOutlookOleObject : OleVariant;
    FMailItem : OleVariant;
    FRecipientsToList : TStringList;
    FRecipientsCCList : TStringList;
    FRecipientsBCCList : TStringList;
    FAttachmentsList : TStringList;
    FCopiesCount: Integer;
    FEmailBody : string;
    FEmailSubject : string;
    FRichText: Boolean;
    FHtmlBodyFilePath: string;
    FRTFBodyFilePath: string;
    FIsHTML: Boolean;

    function CheckExists(const sEmailAddress : string; stList : TStringList) : Boolean;
    function PrepareEmail : boolean;
    procedure SetCopiesCount(const Value: Integer);
    function GetEmailBody: string;
    procedure SetEmailBody(const Value: string);
    function GetEmailSubject: string;
    procedure SetEmailSubject(const Value: string);
    procedure SetRichText(const Value: Boolean);
    procedure SetHtmlBodyFilePath(const Value: string);
    procedure SetRTFBodyFilePath(const Value: string);
    procedure SetIsHTML(const Value: Boolean);

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddToRecipient(const sEmailAddress : string);
    procedure AddCCRecipient(const sEmailAddress : string);
    procedure AddBCCRecipient(const sEmailAddress : string);
    procedure AddAttachment(const aFilePath : string);

    property CopiesCount : Integer read FCopiesCount write SetCopiesCount;
    property EmailBody : string read GetEmailBody write SetEmailBody;
    property EmailSubject : string read GetEmailSubject write SetEmailSubject;
    property IsRichText : Boolean read FRichText write SetRichText;
    property IsHTML : Boolean read FIsHTML write SetIsHTML;
    property HtmlBodyFilePath : string read FHtmlBodyFilePath write SetHtmlBodyFilePath;
    property RTFBodyFilePath : string read FRTFBodyFilePath write SetRTFBodyFilePath;

    function SendEmail : integer;
 end;

resourcestring
   APPLICATION_NAME_OUTLOOK = 'Outlook.Application';
   APPLICATION_NAME_WORD = 'Word.Application';

const
   olMailItemTo = 0; //To
   olMailItemCC = 1; //CC
   olMailItemBCC = 2; //BCC

   olFormatUnspecified = 0;
   olFormatPlain = 1;
   olFormatHTML = 2;
   olFormatRichText = 3;

   wdAlertsNone = 0;

implementation

{ TOutlookOle }

procedure TOutlookOle.AddAttachment(const aFilePath: string);
begin
  if FileExists(aFilePath) then
    FAttachmentsList.Add(aFilePath);
end;

procedure TOutlookOle.AddBCCRecipient(const sEmailAddress: string);
begin
  if not CheckExists(sEmailAddress, FRecipientsBCCList) then
    FRecipientsBCCList.Add(sEmailAddress);
end;

procedure TOutlookOle.AddCCRecipient(const sEmailAddress: string);
begin
  if not CheckExists(sEmailAddress, FRecipientsCCList) then
    FRecipientsCCList.Add(sEmailAddress);
end;

procedure TOutlookOle.AddToRecipient(const sEmailAddress: string);
begin
  if not CheckExists(sEmailAddress, FRecipientsToList) then
    FRecipientsToList.Add(sEmailAddress);
end;

function TOutlookOle.CheckExists(const sEmailAddress: string;  stList: TStringList): Boolean;
var
  i : Integer;
begin
  Result := False;
  if (Trim(sEmailAddress) <> '') and (stList.Count > 0) then
  begin
    for i := 0 to stList.Count - 1 do
    begin
      if AnsiUpperCase(sEmailAddress) = AnsiUpperCase(stList.Strings[i]) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

constructor TOutlookOle.Create;
begin
  FOutlookOleObject := CreateOleObject(APPLICATION_NAME_OUTLOOK);
  FRecipientsToList := TStringList.Create;
  FRecipientsCCList := TStringList.Create;
  FRecipientsBCCList := TStringList.Create;
  FAttachmentsList := TStringList.Create;
  FRichText := False;
  FCopiesCount := 1;
end;

destructor TOutlookOle.Destroy;
begin
  FRecipientsToList.Free;
  FRecipientsCCList.Free;
  FRecipientsBCCList.Free;
  FAttachmentsList.Free;
  FOutlookOleObject.Quit;
  FOutlookOleObject := Unassigned;

  if FileExists(HtmlBodyFilePath) then
    DeleteFile(PChar(HtmlBodyFilePath));

  if FileExists(RTFBodyFilePath) then
    DeleteFile(PChar(RTFBodyFilePath));

  inherited;
end;

function TOutlookOle.GetEmailBody: string;
begin
  Result := FEmailBody;
end;

function TOutlookOle.GetEmailSubject: string;
begin
  Result := FEmailSubject;
end;

function TOutlookOle.PrepareEmail : boolean;
var
  i : integer;
  varAppWord : OleVariant;
  varHtmlStrList : TStringList;
begin
  Result := False;
  if FRecipientsToList.Count > 0 then
  begin
    FMailItem := FOutlookOleObject.CreateItem(olMailItemTo);
    FMailItem.Display(False);
    // filling TO
    for i := 0 to FRecipientsToList.Count - 1 do
      FMailItem.Recipients.Add(FRecipientsToList.Strings[i]);
    //filling CC
    if FRecipientsCCList.Count > 0 then
    begin
      for i := 0 to FRecipientsCCList.Count - 1 do
        FMailItem.Recipients.Add(FRecipientsCCList.Strings[i]).Type := olMailItemCC;
    end;
    //filling BCC
    if FRecipientsBCCList.Count > 0 then
    begin
      for i := 0 to FRecipientsBCCList.Count - 1 do
        FMailItem.Recipients.Add(FRecipientsBCCList.Strings[i]).Type := olMailItemBCC;
    end;

    FMailItem.Subject := EmailSubject;

    if IsRichText then
    begin
      FMailItem.BodyFormat := olFormatRichText;
      if FileExists(RTFBodyFilePath) then
      begin
        varAppWord := CreateOleObject(APPLICATION_NAME_WORD);
        try
          varAppWord.Visible := False;
          varAppWord.DisplayAlerts := wdAlertsNone;
          varAppWord.Documents.Open(RTFBodyFilePath, False);
          varAppWord.ActiveDocument.Range.Select;
          varAppWord.Selection.Copy;
          FMailItem.GetInspector.WordEditor.Range.Paste;
        finally
          varAppWord.Quit;
          varAppWord := Unassigned;
        end;
      end;
    end
    else
    begin
      if IsHTML then
      begin
        FMailItem.BodyFormat := olFormatHTML;
        if FileExists(HtmlBodyFilePath) then
        begin
          varHtmlStrList := TStringList.Create;
          try
            varHtmlStrList.LoadFromFile(HtmlBodyFilePath);
            FMailItem.HTMLBody := varHtmlStrList.Text;
          finally
            varHtmlStrList.Free;
          end;
        end;
      end else
       FMailItem.Body := EmailBody;
    end;

    if FAttachmentsList.Count > 0 then
    begin
      for i := 0 to FAttachmentsList.Count - 1 do
        FMailItem.Attachments.Add(FAttachmentsList.Strings[i]);
    end;

    Result := True;
  end;
end;

function TOutlookOle.SendEmail : integer;
begin
  if PrepareEmail then
  begin
    FMailItem.Send;
    //FOutlookOleObject.GetNamespace('MAPI').SendAndReceive(True);
    FMailItem := Unassigned;
  end;
  Result := 0;
end;

procedure TOutlookOle.SetCopiesCount(const Value: Integer);
begin
  FCopiesCount := Value;
end;

procedure TOutlookOle.SetEmailBody(const Value: string);
begin
  FEmailBody := Value;
end;

procedure TOutlookOle.SetEmailSubject(const Value: string);
begin
  FEmailSubject := Value;
end;

procedure TOutlookOle.SetHtmlBodyFilePath(const Value: string);
begin
  FHtmlBodyFilePath := Value;
  IsHTML := True;
end;

procedure TOutlookOle.SetIsHTML(const Value: Boolean);
begin
  FIsHTML := Value;
end;

procedure TOutlookOle.SetRichText(const Value: Boolean);
begin
  FRichText := Value;
end;
procedure TOutlookOle.SetRTFBodyFilePath(const Value: string);
begin
  FRTFBodyFilePath := Value;
  IsRichText := True;
end;

end.
