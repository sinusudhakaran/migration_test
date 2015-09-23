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
    FMustBeClosedAfter: boolean;
    FTempExportDir: string;

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
    procedure setMustBeClosedAfter(const Value: boolean);
    procedure SetTempExportDir(const Value: string);

    property MustBeClosedAfter : boolean read FMustBeClosedAfter write setMustBeClosedAfter;
    function OutlookRunning : IDispatch;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddToRecipient(const sEmailAddress : string);
    procedure AddCCRecipient(const sEmailAddress : string);
    procedure AddBCCRecipient(const sEmailAddress : string);
    procedure AddAttachment(const aFilePath : string);
    procedure ExportGlobalContactsList;

    property CopiesCount : Integer read FCopiesCount write SetCopiesCount;
    property EmailBody : string read GetEmailBody write SetEmailBody;
    property EmailSubject : string read GetEmailSubject write SetEmailSubject;
    property IsRichText : Boolean read FRichText write SetRichText;
    property IsHTML : Boolean read FIsHTML write SetIsHTML;
    property HtmlBodyFilePath : string read FHtmlBodyFilePath write SetHtmlBodyFilePath;
    property RTFBodyFilePath : string read FRTFBodyFilePath write SetRTFBodyFilePath;
    property TempExportDir : string read FTempExportDir write SetTempExportDir;

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

   MapiNameSpace = 'MAPI';
   MapiContacts = 'Contacts';
   X400Type = 'EX';
   XmlnsMicrosoft = 'http://schemas.microsoft.com/mapi/proptag/0x39FE001E';
   CSVHeader ='Code;Name;Address1;Address2;Address3;Phone;Fax;Mobile;Salutation;Email;Contact;User';
   CSVSeparator = ';';

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
  FOutlookOleObject := OutlookRunning;

  if VarIsClear(FOutlookOleObject) then
  begin
    FOutlookOleObject := CreateOleObject(APPLICATION_NAME_OUTLOOK);
    MustBeClosedAfter := True;
  end;

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
  if MustBeClosedAfter then
    FOutlookOleObject.Quit;

  FOutlookOleObject := Unassigned;

  if FileExists(HtmlBodyFilePath) then
    DeleteFile(PChar(HtmlBodyFilePath));

  if FileExists(RTFBodyFilePath) then
    DeleteFile(PChar(RTFBodyFilePath));

  inherited;
end;

procedure TOutlookOle.ExportGlobalContactsList;
var
  Namespace : OleVariant;
  AddressList :  OleVariant;
  AddressListItem : OleVariant;
  Contact : OleVariant;
  iCounter : integer;
  tmp : TStringList;
  csvstring : string;

  function ConvertX400(const sAddress : string) : string;
  var
    iCount : integer;
    entry : OleVariant;
    varMailItem : OleVariant;
    varAddress : OleVariant;
    varRecipient : OleVariant;
  begin
    Result := '';
    for iCount := 1 to AddressList.Count do
    begin
      entry := AddressList.Item(iCount);
      if entry.Address = sAddress then
      begin
        varMailItem := FOutlookOleObject.CreateItem(olMailItemTo);
        try
          varAddress := varMailItem.Recipients.Add(sAddress);
          varAddress.Resolve;
          varRecipient := varMailItem.Recipients[1];
          Result := varRecipient.PropertyAccessor.GetProperty(XmlnsMicrosoft);
        finally
          varMailItem := Unassigned;
          varAddress := Unassigned;
          varRecipient := Unassigned;
        end;
      end;
    end;
  end;

begin
  if DirectoryExists(FTempExportDir) then
  begin
    Namespace := FOutlookOleObject.GetNameSpace(MapiNameSpace);
    tmp := TStringList.Create;
    try
      //AddressList := Namespace.AddressLists.Item('Global Address List').AddressEntries;
      AddressList := Namespace.AddressLists.Item(MapiContacts).AddressEntries;
      if AddressList.Count > 0  then
      begin
        tmp.Add(CSVHeader);
        for iCounter := 1 to AddressList.Count do
        begin
          AddressListItem := AddressList.Item(iCounter);
          //if AddressListItem.Type = X400Type then
          begin
            Contact := AddressList.Item(iCounter).GetExchangeUser ;
            //Contact := AddressList.Item(iCounter);
            if not VarIsClear(Contact) then
            begin
              //TO DO extract data from both Exhange and not exchange users generate CSV string and save to a file
              //tmp.Add(Contact.JobTitle);
              {if not VarIsClear(Contact.CompanyName) then
                csvstring := csvstring + Contact.CompanyName + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.CompanyName) then
                csvstring := csvstring + Contact.CompanyName + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.Name) then
                csvstring := csvstring + Contact.Name + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.AddressCity) then
                csvstring := csvstring + Contact.AddressCity + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.PostalCode) then
                csvstring := csvstring + Contact.PostalCode + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.PostalCode) then
                csvstring := csvstring + Contact.PostalCode + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;

              if not VarIsClear(Contact.PostalCode) then
                csvstring := csvstring + Contact.PostalCode + CSVSeparator
              else
                csvstring := csvstring + CSVSeparator;}

             tmp.Add(csvstring);
            end;

{

        CSVHeader ='Code;Name;Address1;Address2;Address3;Phone;Fax;Mobile;Salutation;Email;Contact;User';
        code := '';
        clientname := Trim(ocdsContacts.FieldByName('CompanyName').AsString);
        address1 := '';
        address2 := '';
        address3 := '';
        phone := '';
        fax := '';
        mobile := '';
        sal := '';
        email := '';
        contact := Trim(ocdsContacts.FieldByName('FirstName').AsString + ' ' +
            ocdsContacts.FieldByName('MiddleName').AsString + ' ' +
            ocdsContacts.FieldByName('LastName').AsString);

         Trim(ocdsContacts.FieldByName('HomeTelephoneNumber').AsString);
         Trim(ocdsContacts.FieldByName('BusinessFaxNumber').AsString);
         Trim(ocdsContacts.FieldByName('MobileTelephoneNumber').AsString);
         Trim(ocdsContacts.FieldByName('CarTelephoneNumber').AsString);
         Trim(ocdsContacts.FieldByName('Title').AsString);
         email

}
          end;
          //tmp.Add(RetriveInfoForContact(AddressListItem.Name));
          //tmp.Add(AddressListItem.Name + ';' + ConvertX400(AddressListItem.Address)+';'+AddressListItem.BusinessAddressStreet);

          if iCounter > 10 then
            exit;
        end;
      end;
    finally
      tmp.SaveToFile(FTempExportDir+'\TempMapiOulookExportFile.csv');
      tmp.Free;
      Namespace := Unassigned;
    end;
  end;
end;

function TOutlookOle.GetEmailBody: string;
begin
  Result := FEmailBody;
end;

function TOutlookOle.GetEmailSubject: string;
begin
  Result := FEmailSubject;
end;

function TOutlookOle.OutlookRunning: IDispatch;
var
  ClassID: TCLSID;
  Unknown: IUnknown;
begin
  Result := nil;
  ClassID := ProgIDToClassID(APPLICATION_NAME_OUTLOOK);
  if Succeeded(GetActiveObject(ClassID, nil, Unknown)) then
    OleCheck(Unknown.QueryInterface(IDispatch, Result))
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
  //thats just export to CSV we dont want to send a message
  if not SameStr(TempExportDir, '') then
  begin
    ExportGlobalContactsList;
    exit;
  end;

  if PrepareEmail then
  begin
    FMailItem.Send;
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

procedure TOutlookOle.setMustBeClosedAfter(const Value: boolean);
begin
  FMustBeClosedAfter := Value;
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

procedure TOutlookOle.SetTempExportDir(const Value: string);
begin
  FTempExportDir := Value;
end;

end.
