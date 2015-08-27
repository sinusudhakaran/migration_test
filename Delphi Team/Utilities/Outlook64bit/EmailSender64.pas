unit EmailSender64;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.Mapi;

  type
    TEmailSender64 = class
    private
      FIsHTML: boolean;
      FBody: string;
      FCCList: TStringList;
      FSubject: string;
      FBCCList: TStringList;
      FIsRTF: boolean;
      FTOList: TStringList;
      FAttachmentsList: TStringList;

      MapiMessage: TMapiMessage;
      MapilpSender : TMapiRecipDesc;
      MapilpRecipient: array of TMapiRecipDesc;
      MapilpRec : PMapiRecipDesc;
      MapilpSend : PMapiRecipDesc;
      MapiSession : UINT_PTR;
      MapiHandle : UIntPtr;

      procedure SetBody(const Value: string);
      procedure SetIsHTML(const Value: boolean);
      procedure SetIsRTF(const Value: boolean);
      procedure SetSubject(const Value: string);

      function CheckExistAddressExitsInList(const sAddress : string; const aList : TStringList) : boolean;
      function PrepareEmail : Cardinal;
      //MAPI
      function LogOn : integer;
      function LogOff : integer;
      function ResolveNames(const sAddress : string; var pPMapiRecipDesc : PMapiRecipDesc) : Cardinal;
    public
      constructor Create;
      destructor Destroy; override;

      property CCList : TStringList read FCCList;
      property BCCList : TStringList read FBCCList;
      property TOList : TStringList read FTOList;
      property AttachmentsList : TStringList read FAttachmentsList;

      property Subject : string read FSubject write SetSubject;
      property Body : string read FBody write SetBody;
      property IsRTF : boolean read FIsRTF write SetIsRTF;
      property IsHTML : boolean read FIsHTML write SetIsHTML;

      procedure AddTO(const sAddressTO : string);
      procedure AddCC(const sAddressCC : string);
      procedure AddBCC(const sAddressBCC : string);
      procedure AddAttchment(const sPathToFile : string);

      procedure Clean;

      function SendEmail : integer;
  end;

resourcestring
    rsSUCCESS_SUCCESS                 = 'successfuly sent';
    rsMAPI_USER_ABORT                 = 'user abort';
    rsMAPI_E_FAILURE                  = 'MAPI failed';
    rsMAPI_E_LOGIN_FAILURE            = 'login failed';
    rsMAPI_E_DISK_FULL                = 'disc is full';
    rsMAPI_E_INSUFFICIENT_MEMORY      = 'insufficient memory';
    rsMAPI_E_ACCESS_DENIED            = 'access denied';
    rsMAPI_E_TOO_MANY_SESSIONS        = 'too many sessions';
    rsMAPI_E_TOO_MANY_FILES           = 'too many files';
    rsMAPI_E_TOO_MANY_RECIPIENTS      = 'too many recipients';
    rsMAPI_E_ATTACHMENT_NOT_FOUND     = 'attachment not found';
    rsMAPI_E_ATTACHMENT_OPEN_FAILURE  = 'attachment open failure';
    rsMAPI_E_ATTACHMENT_WRITE_FAILURE = 'attachment write failure';
    rsMAPI_E_UNKNOWN_RECIPIENT        = 'unknown recipient';
    rsMAPI_E_BAD_RECIPTYPE            = 'bad recipient type';
    rsMAPI_E_NO_MESSAGES              = 'no message';
    rsMAPI_E_INVALID_MESSAGE          = 'invlid message';
    rsMAPI_E_TEXT_TOO_LARGE           = 'text is too large';
    rsMAPI_E_INVALID_SESSION          = 'invalid session';
    rsMAPI_E_TYPE_NOT_SUPPORTED       = 'type is not supported';
    rsMAPI_E_AMBIGUOUS_RECIPIENT	    = 'ambiguous recipient';
    rsMAPI_E_MESSAGE_IN_USE		        = 'message is in use';
    rsMAPI_E_NETWORK_FAILURE	        = 'network failure';
    rsMAPI_E_INVALID_EDITFIELDS	      = 'invalid edit fiels';
    rsMAPI_E_INVALID_RECIPS		        = 'invalid recipient';
    rsMAPI_E_NOT_SUPPORTED		        = 'not supported';

const
  EXTEND_STRING = '_';
  MINIMUM_LEN  = 5;

implementation

{ TEmailSender64 }

procedure TEmailSender64.AddAttchment(const sPathToFile: string);
begin
  if not CheckExistAddressExitsInList(sPathToFile, FAttachmentsList) and FileExists(Trim(sPathToFile)) then
    FAttachmentsList.Add(Trim(sPathToFile));
end;

procedure TEmailSender64.AddBCC(const sAddressBCC: string);
begin
  if not CheckExistAddressExitsInList(sAddressBCC, FBCCList) then
    FBCCList.Add(Trim(sAddressBCC));
end;

procedure TEmailSender64.AddCC(const sAddressCC: string);
begin
  if not CheckExistAddressExitsInList(sAddressCC, FCCList) then
    FCCList.Add(Trim(sAddressCC));
end;

procedure TEmailSender64.AddTO(const sAddressTO: string);
begin
  if not CheckExistAddressExitsInList(sAddressTO, FTOList) then
    FTOList.Add(Trim(sAddressTO));
end;

function TEmailSender64.CheckExistAddressExitsInList(const sAddress: string; const aList: TStringList): boolean;
var
  i : integer;
begin
  Result := True;
  for i := 0 to aList.Count - 1 do
  begin
    if SameText(sAddress, aList[i]) then
    begin
      Break;
      exit;
    end;
  end;
  Result := False;
end;

procedure TEmailSender64.Clean;
begin
  FBody := '';
  FSubject := '';

  FIsRTF := False;
  FIsHTML:= False;

  FTOList.Clear;
  FCCList.Clear;
  FBCCList.Clear;
  FAttachmentsList.Clear;

  FillChar(MapiMessage, SizeOf(MapiMessage), #0);
  FillChar(MapilpSender, SizeOf(MapilpSender), #0);
  FillChar(MapilpRec, SizeOf(MapilpRec), #0);
  FillChar(MapilpSend, SizeOf(MapilpSend), #0);
  SetLength(MapilpRecipient, 0);
end;

constructor TEmailSender64.Create;
begin
  FTOList := TStringList.Create;
  FCCList := TStringList.Create;
  FBCCList := TStringList.Create;
  FAttachmentsList := TStringList.Create;
  MapiHandle := UInt(10000000);
  Clean;
end;

destructor TEmailSender64.Destroy;
begin
  FTOList.Free;
  FCCList.Free;
  FBCCList.Free;
  FAttachmentsList.Free;
  SetLength(MapilpRecipient, 0);
  inherited;
end;

function TEmailSender64.LogOff: integer;
begin
  Result := MapiLogOff(MapiSession, MapiHandle, MAPI_LOGOFF_SHARED or  MAPI_LOGOFF_UI, 0);
end;

function TEmailSender64.LogOn: integer;
begin
  Result := MapiLogon(MapiHandle, PAnsiChar(AnsiString('')), PAnsiChar(AnsiString('')), MAPI_NEW_SESSION or MAPI_LOGON_UI or MAPI_USE_DEFAULT, 0, @MapiSession);
end;

function TEmailSender64.PrepareEmail : Cardinal;
var
  i : integer;
  MapilpRecipientItem: TMapiRecipDesc;
  MapilpRec : PMapiRecipDesc;
  Attachments : PMapiFileDesc;

  procedure CleanRecs(var aMapilpRecipientItem : TMapiRecipDesc; var aMapilpRec : PMapiRecipDesc; var aMapilpRecipientArr : TMapiRecipDesc);
  begin
    FillChar(aMapilpRecipientItem, sizeof(aMapilpRecipientItem), #0);
    FillChar(aMapilpRecipientArr, sizeof(aMapilpRecipientArr), #0);
    FillChar(aMapilpRec, sizeof(aMapilpRec), #0);
  end;

  procedure FillReceipRecord(var rcMapiRecord : TMapiRecipDesc; var rcMapiRec : PMapiRecipDesc; const aClass : Cardinal);
  begin
    rcMapiRecord.ulRecipClass := aClass;
    rcMapiRecord.lpszName := rcMapiRec^.lpszName;
    rcMapiRecord.lpszAddress := rcMapiRec^.lpszAddress;
    rcMapiRecord.ulReserved := rcMapiRec^.ulReserved;
    rcMapiRecord.ulEIDSize := rcMapiRec^.ulEIDSize;
    rcMapiRecord.lpEntryID := rcMapiRec^.lpEntryID;
  end;

begin
  Result := MAPI_E_FAILURE;
  if LogOn = SUCCESS_SUCCESS then
  begin
    if FTOList.Count > 0 then
    begin
      if Length(Trim(Subject)) <= MINIMUM_LEN then
        Subject := Subject + EXTEND_STRING;
      if Length(Trim(Body)) <= MINIMUM_LEN then
        Body := Body + EXTEND_STRING;

      MapiMessage.lpszSubject := PAnsiChar(AnsiString(Subject));
      MapiMessage.lpszNoteText := PAnsiChar(AnsiString(Body));
      MapiMessage.nRecipCount := FTOList.Count + FCCList.Count + FBCCList.Count;
      MapiMessage.lpszMessageType := nil;

      //TO
      for i := 0 to FTOList.Count - 1 do
      begin
        SetLength(MapilpRecipient, Length(MapilpRecipient) + 1);

        CleanRecs(MapilpRecipientItem, MapilpRec, MapilpRecipient[Length(MapilpRecipient) - 1]);
        Result := ResolveNames(FTOList.Strings[i], MapilpRec);
        if Result <> SUCCESS_SUCCESS then
        begin
          break;
          exit;
        end;
        FillReceipRecord(MapilpRecipientItem, MapilpRec, MAPI_TO);
        MapilpRecipient[Length(MapilpRecipient) - 1] := MapilpRecipientItem;
      end;

      //CC
      for i := 0 to FCCList.Count - 1 do
      begin
        SetLength(MapilpRecipient, Length(MapilpRecipient) + 1);

        CleanRecs(MapilpRecipientItem, MapilpRec, MapilpRecipient[Length(MapilpRecipient) - 1]);
        Result := ResolveNames(FCCList.Strings[i], MapilpRec);
        if Result <> SUCCESS_SUCCESS then
        begin
          break;
          exit;
        end;
        FillReceipRecord(MapilpRecipientItem, MapilpRec, MAPI_CC);
        MapilpRecipient[Length(MapilpRecipient) - 1] := MapilpRecipientItem;
      end;

      //BCC
      for i := 0 to FBCCList.Count - 1 do
      begin
        SetLength(MapilpRecipient, Length(MapilpRecipient) + 1);

        CleanRecs(MapilpRecipientItem, MapilpRec, MapilpRecipient[Length(MapilpRecipient) - 1]);
        Result := ResolveNames(FBCCList.Strings[i], MapilpRec);
        if Result <> SUCCESS_SUCCESS then
        begin
          break;
          exit;
        end;
        FillReceipRecord(MapilpRecipientItem, MapilpRec, MAPI_BCC);
        MapilpRecipient[Length(MapilpRecipient) - 1] := MapilpRecipientItem;
      end;

      MapiMessage.lpRecips :=  Pointer(MapilpRecipient);

      //attachments
      if FAttachmentsList.Count > 0 then
      begin
        GetMem(Attachments, SizeOf(TMapiFileDesc) * FAttachmentsList.Count);
        for i := 0 to FAttachmentsList.Count - 1 do
        begin
          Attachments[i].ulReserved := 0;
          Attachments[i].flFlags := 0;
          Attachments[i].nPosition := Cardinal($FFFFFFFF);
          Attachments[i].lpszPathName := PAnsiChar(AnsiString(FAttachmentsList.Strings[i]));
          Attachments[i].lpszFileName := PAnsiChar(AnsiString(ExtractFileName(FAttachmentsList.Strings[i])));
          Attachments[i].lpFileType := nil;
        end;
        MapiMessage.nFileCount := FAttachmentsList.Count;
        MapiMessage.lpFiles := @Attachments^;
      end
      else
      begin
        MapiMessage.nFileCount := 0;
        MapiMessage.lpFiles := nil;
      end;
      //end creating mail
    end;
  end;
end;

function TEmailSender64.ResolveNames(const sAddress : string; var pPMapiRecipDesc : PMapiRecipDesc) : Cardinal;
var
  iResultCode : integer;
begin
  iResultCode := MapiResolveName(MapiSession, MapiHandle, PAnsiChar(AnsiString(sAddress)), MAPI_NEW_SESSION, 0, pPMapiRecipDesc);
  if iResultCode in [MAPI_E_AMBIGUOUS_RECIPIENT, MAPI_E_UNKNOWN_RECIPIENT] then
    MapiResolveName(MapiSession, MapiHandle, PAnsiChar(AnsiString(sAddress)), MAPI_DIALOG, 0, pPMapiRecipDesc);
  Result := iResultCode;
end;

function TEmailSender64.SendEmail: integer;
begin
  Result := PrepareEmail;

  if Result = SUCCESS_SUCCESS then
    Result := MapiSendMail(MapiSession, MapiHandle, MapiMessage, MAPI_DIALOG or MAPI_NEW_SESSION or MAPI_ALLOW_OTHERS, 0);

  LogOff;
  Clean;
end;

procedure TEmailSender64.SetBody(const Value: string);
begin
  FBody := Value;
end;

procedure TEmailSender64.SetIsHTML(const Value: boolean);
begin
  FIsHTML := Value;
end;

procedure TEmailSender64.SetIsRTF(const Value: boolean);
begin
  FIsRTF := Value;
end;

procedure TEmailSender64.SetSubject(const Value: string);
begin
  FSubject := Value;
end;

end.
