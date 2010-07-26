(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

unit OpDbOlk;

interface

uses Classes, Db, OpOutlk, OpOlkXP, TypInfo;

type
  TContactInfoKind = (citDefault, citBusiness, citPersonal, citNetwork,
    citMisc);
  TContactInfoKinds = set of TContactInfoKind;

  {: Specifies the source of the address list with which the component will
     communicate.  Possible values are:
       cltContacts: The Contacts address list
       cltFolders: All folders in the MAPINameSpace will be searched to find a
                   folder with a DefaultItemType of OlitContact and a
                   name matching that specified by the ListName property.
                   Searching will terminate when the first match is found.
       cltCustom:  The list will be furnished by the developer by handling the
                   OnGetListSource event.}
  TContactListSource = (cltContacts, cltFolders, cltCustom);

  {: The is the type of the OnGetListSource event, which is fired when the
     ListSource property is cltCustom in order to obtain the contacts list with
     which the component will communicate.  It is the responsiblity of the
     developer to ensure the Items passed back contains ContactItem elements.}
  TGetListSourceEvent = procedure (Sender: TObject; out ContactList: Items) of object;

  {: The TOpContactsDataSet component is a VCL dataset that provides access to
     the Outlook contact manager.  Basic dataset functionality, such as
     edits, appends, and delete are supported by this component.  More
     advanced functionality, such as inserts, sorting, and filters are not
     supported in this release. }
  TOpContactsDataSet = class(TDataSet)
  private
    FContactInfo: TContactInfoKinds;
    FFoundMatch: Boolean;
    FItems: Items;
    FListName: string;
    FListSource: TContactListSource;
    FNeedFreeOutlook: Boolean;
    FOnGetListSource: TGetListSourceEvent;
    FOutlook: TOpOutlook;
    FRecordPos: Integer;
    procedure DoPostItem(Item: _ContactItem; Buffer: Pointer);
    function FindFolderByName(const Fldrs: Folders; const Name: string): MAPIFolder;
    function FindMatchingFolder(Fldrs: Folders): Items;
    procedure InitializeRecordBuffer(Buffer: Pointer);
    procedure SetOutlook(Value: TOpOutlook);
    procedure SetContactInfo(Value: TContactInfoKinds);
    procedure SetListSource(const Value: TContactListSource);
    procedure SetListName(const Value: string);
  protected
    function AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    function GetRecordSize: Word; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    function IsCursorOpen: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    procedure SetRecNo(Value: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
  published
    property Active;
    {: The ContactInfo property enables the user to determine what types of
       contact information are available in the dataset.  By limiting the items
       in this set, you can limit the number of automation calls sent to the
       server in order to read and post data. }
    property ContactInfo: TContactInfoKinds read FContactInfo write SetContactInfo default [citDefault];
    {: The ListName property is used when ListSource is cltFolders in order to
       determine the list with which the component will communicate.  If
       the first character of ListName is '/' or '\', then the component
       assumes that you are specifying a full folder path name for the
       contacts folder in question (e.g., '\Public Folders\My Contacts').
       Otherwise, the component will traverse all of the folders within
       the MAPINameSpace, looking for the first folder with a
       DefaultItemType of OlitContact whose name matches ListName. }
    property ListName: string read FListName write SetListName;
    {: The ListSource property determines the type of address list to which
       the component will connect.  If the value of this property is cltFolders,
       then the ListName property is used to determine which list to access.
       If the value is cltCustom, then the OnGetListSource event is fired to
       obtain the list, and this event must be handled by the developer.  See
       the documentation for the TContactListSource type for complete
       information on the possible values for this property.}
    property ListSource: TContactListSource read FListSource write SetListSource
      default cltContacts;
    {: The Outlook property should be set to the TOpOutlook component through
       which you wish to manipulate the contact manager. }
    property Outlook: TOpOutlook read FOutlook write SetOutlook;
    //#<Events>
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnDeleteError;
    property OnEditError;
    {: The OnGetListSource event is fired when the ListSource property is
       cltCustom in order to obtain the contacts list with which the component
       will communicate.  It is the responsiblity of the developer to ensure
       the Items passed back contains ContactItem elements.}
    property OnGetListSource: TGetListSourceEvent read FOnGetListSource write
      FOnGetListSource;
    property OnNewRecord;
    property OnPostError;
    //#</Events>
  end;


type
{$M+}
  TOpBaseData = class
  private
    FPropCount: Integer;
    FPropList: PPropList;
    function ReadDispStrProp(Disp: Pointer; PropIdx: Cardinal): WideString;
    procedure WriteDispStrProp(Disp: Pointer; PropIdx: Cardinal;
      const PropVal: WideString);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure ReadPropertiesFromDisp(Disp: Pointer);
    procedure WritePropertiesToDisp(Disp: Pointer);
    class procedure CreateFieldDefsFromProps(FieldDefs: TFieldDefs);
  end;
{$M-}

  TOpBaseDataClass = class of TOpBaseData;

  TOpDefaultData = class(TOpBaseData)
  private
    FMailingAddressCountry: string;
    FMailingAddressState: string;
    FFirstName: string;
    FSuffix: string;
    FMiddleName: string;
    FMailingAddressCity: string;
    FPrimaryTelephoneNumber: string;
    FLastName: string;
    FMailingAddressPostOfficeBox: string;
    FPagerNumber: string;
    FMailingAddressPostalCode: string;
    FMobileTelephoneNumber: string;
    FMailingAddressStreet: string;
  published
    property FirstName: string index 120 read FFirstName write FFirstName;
    property LastName: string index 170 read FLastName write FLastName;
    property MiddleName: string index 189 read FMiddleName write FMiddleName;
    property Suffix: string index 237 read FSuffix write FSuffix;
    property MailingAddressCity: string index 175 read FMailingAddressCity write FMailingAddressCity;
    property MailingAddressCountry: string index 177 read FMailingAddressCountry write FMailingAddressCountry;
    property MailingAddressPostalCode: string index 179 read FMailingAddressPostalCode write FMailingAddressPostalCode;
    property MailingAddressPostOfficeBox: string index 181 read FMailingAddressPostOfficeBox write FMailingAddressPostOfficeBox;
    property MailingAddressState: string index 183 read FMailingAddressState write FMailingAddressState;
    property MailingAddressStreet: string index 185 read FMailingAddressStreet write FMailingAddressStreet;
    property MobileTelephoneNumber: string index 191 read FMobileTelephoneNumber write FMobileTelephoneNumber;
    property PagerNumber: string index 221 read FPagerNumber write FPagerNumber;
    property PrimaryTelephoneNumber: string index 225 read FPrimaryTelephoneNumber write FPrimaryTelephoneNumber;
  end;

  TOpBusinessData = class(TOpBaseData)
  private
    FCustomerID: string;
    FBusinessFaxNumber: string;
    FBusinessHomePage: string;
    FBusiness2TelephoneNumber: string;
    FBusinessAddressPostOfficeBox: string;
    FBusinessAddressStreet: string;
    FCompanyMainTelephoneNumber: string;
    FAccount: string;
    FAssistantTelephoneNumber: string;
    FAssistantName: string;
    FOfficeLocation: string;
    FBusinessAddressState: string;
    FBillingInformation: string;
    FProfession: string;
    FBusinessAddressPostalCode: string;
    FReferredBy: string;
    FBusinessTelephoneNumber: string;
    FCompanies: string;
    FOrganizationalIDNumber: string;
    FTitle: string;
    FManagerName: string;
    FBusinessAddressCity: string;
    FBusinessAddressCountry: string;
    FDepartment: string;
    FGovernmentIDNumber: string;
    FCompanyName: string;
  published
    property BillingInformation: string index 6 read FBillingInformation write FBillingInformation;
    property Companies: string index 12 read FCompanies write FCompanies;
    property Account: string index 49 read FAccount write FAccount;
    property AssistantName: string index 53 read FAssistantName write FAssistantName;
    property AssistantTelephoneNumber: string index 55 read FAssistantTelephoneNumber write FAssistantTelephoneNumber;
    property Business2TelephoneNumber: string index 59 read FBusiness2TelephoneNumber write FBusiness2TelephoneNumber;
    property BusinessAddressCity: string index 63 read FBusinessAddressCity write FBusinessAddressCity;
    property BusinessAddressCountry: string index 65 read FBusinessAddressCountry write FBusinessAddressCountry;
    property BusinessAddressPostalCode: string index 67 read FBusinessAddressPostalCode write FBusinessAddressPostalCode;
    property BusinessAddressPostOfficeBox: string index 69 read FBusinessAddressPostOfficeBox write FBusinessAddressPostOfficeBox;
    property BusinessAddressState: string index 71 read FBusinessAddressState write FBusinessAddressState;
    property BusinessAddressStreet: string index 73 read FBusinessAddressStreet write FBusinessAddressStreet;
    property BusinessFaxNumber: string index 75 read FBusinessFaxNumber write FBusinessFaxNumber;
    property BusinessHomePage: string index 77 read FBusinessHomePage write FBusinessHomePage;
    property BusinessTelephoneNumber: string index 79 read FBusinessTelephoneNumber write FBusinessTelephoneNumber;
    property CompanyMainTelephoneNumber: string index 90 read FCompanyMainTelephoneNumber write FCompanyMainTelephoneNumber;
    property CompanyName: string index 92 read FCompanyName write FCompanyName;
    property CustomerID: string index 96 read FCustomerID write FCustomerID;
    property Department: string index 98 read FDepartment write FDepartment;
    property GovernmentIDNumber: string index 129 read FGovernmentIDNumber write FGovernmentIDNumber;
    property JobTitle: string index 159 read FGovernmentIDNumber write FGovernmentIDNumber;
    property ManagerName: string index 187 read FManagerName write FManagerName;
    property OfficeLocation: string index 199 read FOfficeLocation write FOfficeLocation;
    property OrganizationalIDNumber: string index 201 read FOrganizationalIDNumber write FOrganizationalIDNumber;
    property Profession: string index 227 read FProfession write FProfession;
    property ReferredBy: string index 231  read FReferredBy write FReferredBy;
    property Title: string index 241 read FTitle write FTitle;
  end;

  TOpPersonalData = class(TOpBaseData)
  private
    FHomeAddressStreet: string;
    FHomeFaxNumber: string;
    FHomeAddressPostOfficeBox: string;
    FHomeAddressPostalCode: string;
    FHomeAddressState: string;
    FSpouse: string;
    FHomeTelephoneNumber: string;
    FHomeAddressCountry: string;
    FChildren: string;
    FHobby: string;
    FHomeAddressCity: string;
    FHome2TelephoneNumber: string;
    FNickName: string;
  published
    property Children: string index 85 read FChildren write FChildren;
    property Hobby: string index 131 read FHobby write FHobby;
    property Home2TelephoneNumber: string index 133 read FHome2TelephoneNumber write FHome2TelephoneNumber;
    property HomeAddressCity: string index 137 read FHomeAddressCity write FHomeAddressCity;
    property HomeAddressCountry: string index 139 read FHomeAddressCountry write FHomeAddressCountry;
    property HomeAddressPostalCode: string index 141 read FHomeAddressPostalCode write FHomeAddressPostalCode;
    property HomeAddressPostOfficeBox: string index 143 read FHomeAddressPostOfficeBox write FHomeAddressPostOfficeBox;
    property HomeAddressState: string index 145 read FHomeAddressState write FHomeAddressState;
    property HomeAddressStreet: string index 147 read FHomeAddressStreet write FHomeAddressStreet;
    property HomeFaxNumber: string index 149 read FHomeFaxNumber write FHomeFaxNumber;
    property HomeTelephoneNumber: string index 151 read FHomeTelephoneNumber write FHomeTelephoneNumber;
    property NickName: string index 197 read FNickName write FNickName;
    property Spouse: string index 235 read FSpouse write FSpouse;
  end;

  TOpNetworkData = class(TOpBaseData)
  private
    FEmail2Address: string;
    FEmail3Address: string;
    FComputerNetworkName: string;
    FRadioTelephoneNumber: string;
    FInternetFreeBusyAddress: string;
    FISDNNumber: string;
    FEmail1Address: string;
    FNetMeetingServer: string;
    FNetMeetingAlias: string;
    FTTYTDDTelephoneNumber: string;
    FFTPSite: string;
    FTelexNumber: string;
    FPersonalHomePage: string;
    FWebPage: string;
    FEmail1AddressType: string;
    FEmail2AddressType: string;
    FEmail3AddressType: string;
  published
    property ComputerNetworkName: string index 94 read FComputerNetworkName write FComputerNetworkName;
    property Email1Address: string index 100 read FEmail1Address write FEmail1Address;
    property Email1AddressType: string index 102 read FEmail1AddressType write FEmail1AddressType;
    property Email2Address: string index 106 read FEmail2Address write FEmail2Address;
    property Email2AddressType: string index 108 read FEmail2AddressType write FEmail2AddressType;
    property Email3Address: string index 112 read FEmail3Address write FEmail3Address;
    property Email3AddressType: string index 114 read FEmail3AddressType write FEmail3AddressType;
    property FTPSite: string index 122 read FFTPSite write FFTPSite;
    property InternetFreeBusyAddress: string index 155 read FInternetFreeBusyAddress write FInternetFreeBusyAddress;
    property ISDNNumber: string index 157 read FISDNNumber write FISDNNumber;
    property NetMeetingAlias: string index 193 read FNetMeetingAlias write FNetMeetingAlias;
    property NetMeetingServer: string index 195 read FNetMeetingServer write FNetMeetingServer;
    property PersonalHomePage: string index 223 read FPersonalHomePage write FPersonalHomePage;
    property RadioTelephoneNumber: string index 229 read FRadioTelephoneNumber write FRadioTelephoneNumber;
    property TelexNumber: string index 239 read FTelexNumber write FTelexNumber;
    property TTYTDDTelephoneNumber: string index 243 read FTTYTDDTelephoneNumber write FTTYTDDTelephoneNumber;
    property WebPage: string index 255 read FWebPage write FWebPage;
  end;

  TOpMiscData = class(TOpBaseData)
  private
    FUser3: string;
    FOtherAddressCountry: string;
    FUser2: string;
    FCategories: string;
    FUserCertificate: string;
    FUser4: string;
    FOtherAddressCity: string;
    FYomiFirstName: string;
    FUser1: string;
    FCallbackTelephoneNumber: string;
    FOtherAddressState: string;
    FLanguage: string;
    FYomiLastName: string;
    FOtherFaxNumber: string;
    FOtherAddressPostOfficeBox: string;
    FOtherAddressStreet: string;
    FCarTelephoneNumber: string;
    FYomiCompanyName: string;
    FOtherTelephoneNumber: string;
    FOtherAddressPostalCode: string;
  published
    property Categories: string index 10 read FCategories write FCategories;
    property CallbackTelephoneNumber: string index 81 read FCallbackTelephoneNumber write FCallbackTelephoneNumber;
    property CarTelephoneNumber: string index 83 read FCarTelephoneNumber write FCarTelephoneNumber;
    property Language: string index 163 read FLanguage write FLanguage;
    property OtherAddressCity: string index 205 read FOtherAddressCity write FOtherAddressCity;
    property OtherAddressCountry: string index 207 read FOtherAddressCountry write FOtherAddressCountry;
    property OtherAddressPostalCode: string index 209 read FOtherAddressPostalCode write FOtherAddressPostalCode;
    property OtherAddressPostOfficeBox: string index 211 read FOtherAddressPostOfficeBox write FOtherAddressPostOfficeBox;
    property OtherAddressState: string index 213 read FOtherAddressState write FOtherAddressState;
    property OtherAddressStreet: string index 215 read FOtherAddressStreet write FOtherAddressStreet;
    property OtherFaxNumber: string index 217 read FOtherFaxNumber write FOtherFaxNumber;
    property OtherTelephoneNumber: string index 219 read FOtherTelephoneNumber write FOtherTelephoneNumber;
    property User1: string index 245 read FUser1 write FUser1;
    property User2: string index 247 read FUser2 write FUser2;
    property User3: string index 249 read FUser3 write FUser3;
    property User4: string index 251 read FUser4 write FUser4;
    property UserCertificate: string index 253 read FUserCertificate write FUserCertificate;
    property YomiCompanyName: string index 257 read FYomiCompanyName write FYomiCompanyName;
    property YomiFirstName: string index 259 read FYomiFirstName write FYomiFirstName;
    property YomiLastName: string index 261 read FYomiLastName write FYomiLastName;
  end;

  PContactRec = ^TContactRec;
  TContactRec = record
    Data: TList;
    Row: _ContactItem;
    Idx: Integer;
    BMFlag: TBookMarkFlag;
  end;


implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF} SysUtils, Windows, Messages,
  Forms, OpConst, OpShared, Controls;

const
  ContactKindArray: array[TContactInfoKind] of TOpBaseDataClass = (TOpDefaultData,
    TOpBusinessData, TOpPersonalData, TOpNetworkData, TOpMiscData);
  StringFieldSize = 128;

function Min(Val1, Val2: Integer): Integer;
begin
  if Val1 < Val2 then Result := Val1
  else Result := Val2;
end;

{ TOpContactsDataSet }

constructor TOpContactsDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BookmarkSize := SizeOf(Integer);   // initialize bookmark size for VCL
  FContactInfo := [citDefault];

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

function TOpContactsDataSet.AllocRecordBuffer: PChar;
begin
  Result := AllocMem(SizeOf(TContactRec));
  InitializeRecordBuffer(Result);
end;

procedure TOpContactsDataSet.FreeRecordBuffer(var Buffer: PChar);
var
  I: Integer;
  L: TList;
begin
  L := PContactRec(Buffer)^.Data;
  for I := L.Count - 1 downto 0 do
    TObject(L.Items[I]).Free;
  L.Free;
  PContactRec(Buffer)^.Row := nil;
  FreeMem(Buffer);
  Buffer := nil;
end;

procedure TOpContactsDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PInteger(Data)^ := PContactRec(Buffer)^.Idx;
end;

function TOpContactsDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PContactRec(Buffer)^.BMFlag;
end;

function TOpContactsDataSet.GetFieldData(Field: TField;
  Buffer: Pointer): Boolean;
var
  FieldVal: string;
  Prop: PPropInfo;
  I: Integer;
  List: TList;
begin
  List := PContactRec(ActiveBuffer)^.Data;
  for I := 0 to List.Count - 1 do
  begin
    Prop := GetPropInfo(TObject(List[I]).ClassInfo, Field.FieldName);
    if Prop <> nil then
    begin
      FieldVal := GetStrProp(TObject(List[I]), Prop);
      if FieldVal <> '' then
        Move(FieldVal[1], Buffer^, Min(Field.Size, Length(FieldVal) + 1))
      else
        FillChar(Buffer^, Field.Size, #0);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TOpContactsDataSet.GetRecNo: Integer;
begin
  UpdateCursorPos;
  if (FRecordPos = 0) and (RecordCount > 0) then
    Result := 1
  else
    Result := FRecordPos + 1;
end;

function TOpContactsDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
var
  Item: _ContactItem;
  ItemDisp: IDispatch;
  List: TList;
  I: Integer;
begin
  Result := grOk;
  case GetMode of
    gmPrior:
      if FRecordPos <= 1 then
      begin
        FRecordPos := 1;
        Result := grBOF;
      end
      else
        Dec(FRecordPos);
    gmCurrent:
      if (FRecordPos = 0) or (FRecordPos >= RecordCount) then
         Result := grError;
    gmNext:
      //if FRecordPos >= RecordCount - 1 then                          {!!.61}
      if FRecordPos > RecordCount - 1 then                             {!!.61} 
        Result := grEOF
      else
        Inc(FRecordPos);
  end;
  if Result = grOk then
  begin
    ItemDisp := FItems.Item(FRecordPos);
    if ItemDisp = nil then
      Result := grError
    else begin
      if ItemDisp.QueryInterface(_ContactItem, Item) <> S_OK then
      begin
        // Work around OL2000: Recurse if an unsupported interface is obtained 
        Result := GetRecord(Buffer, GetMode, DoCheck);
        Exit;
      end;
      List := PContactRec(Buffer)^.Data;
      for I := 0 to List.Count - 1 do
      begin
        TOpBaseData(List[I]).ReadPropertiesFromDisp(Pointer(Item));
        with PContactRec(Buffer)^ do
        begin
          Row := Item;
          Idx := FRecordPos;
          BMFlag := bfCurrent;
        end;
      end;
    end;
  end;
  if (Result = grError) and DoCheck then
    OfficeError(SFailFetch);
end;

function TOpContactsDataSet.GetRecordCount: Integer;
begin
  Result := FItems.Count;
end;

function TOpContactsDataSet.GetRecordSize: Word;
begin
  Result := SizeOf(TContactRec);
end;

procedure TOpContactsDataSet.InternalAddRecord(Buffer: Pointer;
  Append: Boolean);
begin
  DoPostItem(FItems.Add(OlitContact) as _ContactItem, Buffer);
  InternalLast;
end;

procedure TOpContactsDataSet.InternalClose;
begin
  if DefaultFields then DestroyFields;
  FItems := nil;
  FRecordPos := 0;
  if FNeedFreeOutlook then
  begin
    FOutlook.Free;
    FOutlook := nil;
  end;
end;

procedure TOpContactsDataSet.InternalDelete;
begin
  FItems.Remove(FRecordPos);
end;

procedure TOpContactsDataSet.InternalFirst;
begin
  FRecordPos := 0;
end;

procedure TOpContactsDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  FRecordPos := PInteger(Bookmark)^;
end;

procedure TOpContactsDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TOpContactsDataSet.InternalInitFieldDefs;
var
  I: TContactInfoKind;
begin
  FieldDefs.Clear;
  for I := Low(TContactInfoKind) to High(TContactInfoKind) do
    if I in FContactInfo then
      ContactKindArray[I].CreateFieldDefsFromProps(FieldDefs);
end;

procedure TOpContactsDataSet.InternalInitRecord(Buffer: PChar);
var
  List: TList;
  I: Integer;
begin
  List := PContactRec(Buffer)^.Data;
  if List = nil then
    FillChar(Buffer^, SizeOf(TContactRec), 0)
  else begin
    for I := List.Count - 1 downto 0 do
      TObject(List.Items[I]).Free;
    List.Clear;
    FillChar(PContactRec(Buffer)^.Row, SizeOf(TContactRec) - SizeOf(TList), 0);
  end;
  InitializeRecordBuffer(Buffer);
end;

procedure TOpContactsDataSet.InternalLast;
begin
  FRecordPos := FItems.Count;
end;

procedure TOpContactsDataSet.InternalOpen;
var
  OldCursor: TCursor;
begin
  if FOutlook = nil then
  begin
    FOutlook := TOpOutlook.Create(nil);
    FNeedFreeOutlook := True;
  end;
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if not FOutlook.Connected then FOutlook.Connected := True;
    case FListSource of
      cltContacts:
        FItems := FOutlook.MapiNamespace.GetDefaultFolder(olFolderContacts).Items;
      cltFolders:
        begin
          if FListName = '' then OfficeError(SListNameEmpty);
          FItems := FindMatchingFolder(FOutlook.MapiNamespace.Folders);
        end;
      cltCustom:
        if Assigned(FOnGetListSource) then FOnGetListSource(Self, FItems);
    end;
    if FItems = nil then OfficeError(SFailConnectItems);
    InternalInitFieldDefs;             // initialize FieldDef objects
    // Create TField components when no persistent fields have been created
    if DefaultFields then CreateFields;
    BindFields(True);                  // bind FieldDefs to actual data
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TOpContactsDataSet.InternalPost;
var
  NewItem: _ContactItem;
begin
  // If we're in edit mode, then get current record, otherwise get new record
  if State = dsEdit then
    NewItem := FItems.Item(FRecordPos) as _ContactItem
  else
    NewItem := FItems.Add(OlitContact) as _ContactItem;
  DoPostItem(NewItem, ActiveBuffer)
end;

procedure TOpContactsDataSet.InternalSetToRecord(Buffer: PChar);
begin
  FRecordPos := PContactRec(Buffer)^.Idx;
end;

function TOpContactsDataSet.IsCursorOpen: Boolean;
begin
  Result := FItems <> nil;
end;

procedure TOpContactsDataSet.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FOutlook) and (Operation = opRemove) then
  begin
    Close;
    FOutlook := nil;
  end;
end;

procedure TOpContactsDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PContactRec(Buffer)^.Idx := PInteger(Data)^;
end;

procedure TOpContactsDataSet.SetBookmarkFlag(Buffer: PChar;
  Value: TBookmarkFlag);
begin
  PContactRec(Buffer)^.BMFlag := Value;
end;

procedure TOpContactsDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  FieldVal: string;
  Prop: PPropInfo;
  I: Integer;
  List: TList;
begin
  FieldVal := PChar(Buffer);
  List := PContactRec(ActiveBuffer)^.Data;
  for I := 0 to List.Count - 1 do
  begin
    Prop := GetPropInfo(TObject(List[I]).ClassInfo, Field.FieldName);
    if Prop <> nil then
    begin
      SetStrProp(TObject(List[I]), Prop, FieldVal);
      DataEvent(deFieldChange, Longint(Field));
      Exit;
    end;
  end;
  OfficeError(SCantSetFieldData);
end;

procedure TOpContactsDataSet.SetOutlook(Value: TOpOutlook);
begin
  if FOutlook <> Value then
  begin
    if IsCursorOpen then OfficeError(SCantSetWhileConnected);
    if Value <> nil then Value.FreeNotification(Self);
    FOutlook := Value;
  end;
end;

procedure TOpContactsDataSet.SetRecNo(Value: Integer);
begin
  if (Value >= 0) and (Value <= RecordCount) then
  begin
    FRecordPos := Value - 1;
    Resync([]);
  end;
end;

procedure TOpContactsDataSet.SetContactInfo(Value: TContactInfoKinds);
begin
  if FContactInfo <> Value then
  begin
    if Active then OfficeError(SCantSetWhileConnected);
    FContactInfo := Value;
  end;
end;

procedure TOpContactsDataSet.DoPostItem(Item: _ContactItem; Buffer: Pointer);
var
  I: Integer;
  List: TList;
begin
  List := PContactRec(Buffer)^.Data;
  for I := 0 to List.Count - 1 do
    TOpBaseData(List[I]).WritePropertiesToDisp(Pointer(Item));
end;

procedure TOpContactsDataSet.InitializeRecordBuffer(Buffer: Pointer);
var
  I: TContactInfoKind;
begin
  if PContactRec(Buffer)^.Data = nil then
    PContactRec(Buffer)^.Data := TList.Create;
  for I := Low(TContactInfoKind) to High(TContactInfoKind) do
    if I in ContactInfo then
      PContactRec(Buffer)^.Data.Add(ContactKindArray[I].Create);
end;

procedure TOpContactsDataSet.SetListSource(const Value: TContactListSource);
begin
  if FListSource <> Value then
  begin
    if Active then OfficeError(SCantSetWhileConnected);
    FListSource := Value;
  end;
end;

procedure TOpContactsDataSet.SetListName(const Value: string);
begin
  if CompareText(FListName, Value) <> 0 then
  begin
    if Active then OfficeError(SCantSetWhileConnected);
    FListName := Value;
  end;
end;

function TOpContactsDataSet.FindFolderByName(const Fldrs: Folders;
  const Name: string): MAPIFolder;
var
  F: MAPIFolder;
  I: Integer;
begin
  Result := nil;
  for I := 1 to Fldrs.Count do
  begin
    F := Fldrs.Item(I);
    if CompareText(F.Name, Name) = 0 then
    begin
      Result := F;
      Exit;
    end;
  end;
end;

function TOpContactsDataSet.FindMatchingFolder(Fldrs: Folders): Items;
var
  I, CharPos, PathLen, NameLen: Integer;
  F: MAPIFolder;
  CurrFolderName: string;
begin
  Result := nil;
  if FListName <> '' then
  begin
    // If leading character is a slash, then assume they are providing
    // the full path name to the Outlook folder
    if (FListName[1] in ['/', '\']) and (Length(FListName) > 1) then
    begin
      CharPos := 2;
      PathLen := Length(FListName);
      for I := CharPos to PathLen do
      begin
        if (I = PathLen) or (FListName[I] in ['/', '\']) then
        begin
          if I = PathLen then NameLen := PathLen
          else NameLen := I - CharPos;
          CurrFolderName := Copy(FListName, CharPos, NameLen);
          F := FindFolderByName(Fldrs, CurrFolderName);
          if F <> nil then Fldrs := F.Folders;
          CharPos := I + 1;
        end;
      end;
      if (F <> nil) and (F.DefaultItemType = OpOlkXP.olContactItem) then
        Result := F.Items;
    end
    // If leading character is not a slash, then look for first folder
    // with a matching name
    else begin
      FFoundMatch := False;
      for I := 1 to Fldrs.Count do
      begin
        if FFoundMatch then Exit;
        F := Fldrs.Item(I);
        if (F.DefaultItemType = OpOlkXP.olContactItem) and
          (CompareText(F.Name, FListName) = 0) then
        begin
          Result := F.Items;
          FFoundMatch := True;
          Exit;
        end
        else
          Result := FindMatchingFolder(F.Folders);
      end;
    end;
  end;
end;

{ TOpBaseData }

constructor TOpBaseData.Create;
begin
  FPropCount := GetTypeData(ClassInfo)^.PropCount;
  if FPropCount > 0 then
  begin
    GetMem(FPropList, FPropCount * SizeOf(Pointer));
    GetPropInfos(ClassInfo, FPropList);
  end;
end;

destructor TOpBaseData.Destroy;
begin
  if FPropList <> nil then FreeMem(FPropList);
  inherited Destroy;
end;

class procedure TOpBaseData.CreateFieldDefsFromProps(FieldDefs: TFieldDefs);
const
  FieldTypes: array[TTypeKind] of TFieldType = (ftUnknown, ftInteger, ftString,
    ftInteger, ftFloat, ftString, ftInteger, ftUnknown, ftUnknown,  ftString,
    ftString, ftString, ftString, ftUnknown, ftUnknown, ftUnknown
    {$IFNDEF VERSION3},ftInteger, ftUnknown{$ENDIF});
var
  Cnt, I: Integer;
  PList: PPropList;
  Prop: PPropInfo;
begin
  Cnt := GetTypeData(ClassInfo)^.PropCount;
  if Cnt > 0 then
  begin
    GetMem(PList, Cnt * SizeOf(Pointer));
    try
      GetPropInfos(ClassInfo, PList);
      for I := 0 to Cnt - 1 do
      begin
        Prop := PList[I];
        {$IFDEF VER110}
        with TFieldDef.Create(FieldDefs) do
        begin
          Name := Prop^.Name;
          DataType := FieldTypes[Prop^.PropType^.Kind];
          Size := StringFieldSize;
          FieldNo := 1;
        end;
        {$ELSE}
        TFieldDef.Create(FieldDefs, Prop^.Name, FieldTypes[Prop^.PropType^.Kind],
          StringFieldSize, False, 1);
        {$ENDIF}
      end;
    finally
      FreeMem(PList);
    end;
  end;
end;

procedure TOpBaseData.ReadPropertiesFromDisp(Disp: Pointer);
var
  I: Integer;
  Prop: PPropInfo;
  PropVal: WideString;
  VtOffset: Integer;
begin
  for I := 0 to FPropCount - 1 do
  begin
    Prop := FPropList[I];
    case Prop^.PropType^.Kind of
      tkLString:
        begin
          VtOffset := 28 + (Prop^.Index * 4);
          PropVal := ReadDispStrProp(Disp, VtOffset);
          SetStrProp(Self, Prop, PropVal);
        end;
    end;
  end;
end;

procedure TOpBaseData.WritePropertiesToDisp(Disp: Pointer);
var
  I: Integer;
  Prop: PPropInfo;
  PropVal, CurVal: WideString;
  VtOffset: Integer;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    for I := 0 to FPropCount - 1 do
    begin
      Prop := FPropList[I];
      case Prop^.PropType^.Kind of
        tkLString:
          begin
            PropVal := GetStrProp(Self, Prop);
            VtOffset := 28 + (Prop^.Index * 4);
            CurVal := ReadDispStrProp(Disp, VtOffset);
            // Outlook is tempermental when setting properties willy-nilly,
            // so we only set the property value if it has changed in the
            // dataset.
            if AnsiCompareStr(PropVal, CurVal) <> 0 then
              WriteDispStrProp(Disp, VtOffset + 4, PropVal);
          end;
      end;
    end;
    _ContactItem(Disp).Save;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

function TOpBaseData.ReadDispStrProp(Disp: Pointer; PropIdx: Cardinal): WideString;
begin
  asm
    mov eax, Result               // load and clear out prop
    call System.@WStrClr
    push eax                      // push prop
    mov eax, Disp
    push eax                      // push interface pointer
    mov eax, [eax]                // dereference vtable pointer
    add eax, PropIdx              // add vtable offset
    call dword ptr [eax]          // call method
    call System.@CheckAutoResult  // use safecall error checker
  end;
end;

procedure TOpBaseData.WriteDispStrProp(Disp: Pointer; PropIdx: Cardinal;
  const PropVal: WideString);
begin
  asm
    mov eax, PropVal
    push eax                      // push property value
    mov eax, Disp
    push eax                      // push interface pointer
    mov eax, [eax]                // dereference vtable pointer
    add eax, PropIdx              // add vtable offset
    call dword ptr [eax]          // call method
    call System.@CheckAutoResult  // use safecall error checker
  end;
end;

end.
