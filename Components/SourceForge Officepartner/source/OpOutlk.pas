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

{$IFDEF DCC6ORLATER}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

unit OpOutlk;

interface

uses Classes, ActiveX, OpShared, OpOlk98, 
  OpOlkXP {$IFDEF DCC6ORLATER},                              {!!.62}
  Variants {$ENDIF};

type
  TOpOlItemType = (OlitMail, OlitAppointment, OlitContact, OlitTask,
    OlitJournal, OlitNote, OlitPost);
  TOpOlImportance =  (olimpLow, olImpNormal, olImpHigh);
  TOpOlSensitivity = (olSensNormal, olSensPersonal, olSensPrivate, olSensConfidential);
  TOpOlDisplayType = (oldtUser, oldtDistList, oldtForum, oldtAgent, oldtOrganization,
    oldtPrivateDistList, oldtRemoteUser);
  TOpOlTrackingStatus = (oltsNone, oltsDelivered,
    oltsNotDelivered, oltsNotRead, oltsRecallFailure,
    oltsRecallSuccess, oltsRead, oltsReplied);
  TOpOlMailRecipientType = (olmrtOriginator, olmrtTo, olmrtCC, olmrtBCC);
  TOpOlInspectorClose = (olicSave, olicDiscard, olicPromptForSave);
  TOpOlGender = (olGendUnspecified, olGendFemale, olGendMale);
  TOpOlNoteColor = (olncBlue, olncGreen, olncPink, olncYellow, olncWhite);
  TOpOlMailingAddress = (olmaNone, olmaHome, olmaBusiness, olmaOther);
  TOpOlMeetingResponse = (olmrTentative, olmrAccepted, olmrDeclined);
  TOpOlBusyStatus = (olbsFree, olbsTentative, olbsBusy, olbsOutOfOffice);
  TOpOlMeetingStatus = (olmsNonMeeting, olmsMeeting, olmsReceived, olmsCanceled);
  TOpOlNetMeetingType = (olnmtNetMeeting, olnmtChat, olnmtNetShow);
  TOpOlRecurrenceState = (olrsApptNotRecurring, olrsApptMaster, olrsApptOccurrence,
    olrsApptException);
  TOpOlResponseStatus = (olrespstNone, olrespstOrganized, olrespstTentative,
    olrespstAccepted, olrespstDeclined, olrespstNotResponded);
  TOpOlTaskDelegationState = (oltdsNotDelegated, oltdsUnknown,
    oltdsAccepted, oltdsDeclined);
  TOpOlTaskOwnership = (oltoNewTask, oltoDelegatedTask, oltoOwnTask);
  TOpOlTaskResponse = (oltrSimple, oltrAssign, oltrAccept, oltrDecline);
  TOpOlTaskStatus = (olTskStatNotStarted, olTskStatInProgress, olTskStatComplete,
    olTskStatWaiting, olTskStatDeferred);
  TOpOlSaveAsType = (olsatTXT, olsatRTF, olsatTemplate, olsatMSG, olsatDoc,
    olsatHTML, olsatVCard, olsatVCal);

  TItemSendEvent = procedure (Item: IDispatch; var Cancel: WordBool) of object;
  TReminderEvent = procedure (Item: IDispatch) of object;
  TOptionsPagesAddEvent = procedure (Pages: PropertyPages) of object;

  TOpOutlook = class;
  TOpAttachmentList = class;
  TOpRecipientList = class;
  TOpMailListProp = class;
  TOpMailItem = class;

  {: TOpOutlookItem is the base class for classes representing Outlook items,
     such as appointments, mail messages, tasks, posts, journal entries, notes,
     and contact items. }
  TOpOutlookItem = class(TObject)
  end;

  {: TOpAppointmentItem encapsulatetes the Outlook _AppointmentItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateAppointmentItem method. }
  TOpAppointmentItem = class(TOpOutlookItem)
  private
    FAppointmentItem: _AppointmentItem;
    FAttachments: TOpAttachmentList;
    FRecipients: TOpRecipientList;
    function GetAllDayEvent: Boolean;
    function GetBillingInformation: string;
    function GetBody: string;
    function GetBusyStatus: TOpOlBusyStatus;
    function GetCategories: string;
    function GetCompanies: string;
    function GetConversationIndex: string;
    function GetConversationTopic: string;
    function GetCreationTime: TDateTime;
    function GetDuration: Integer;
    function GetEnd_: TDateTime;
    function GetEntryID: string;
    function GetFormDescription: FormDescription;
    function GetImportance: TOpOlImportance;
    function GetInspector: Inspector;
    function GetIsOnlineMeeting: Boolean;
    function GetIsRecurring: Boolean;
    function GetLastModificationTime: TDateTime;
    function GetLocation: string;
    function GetMeetingStatus: TOpOlMeetingStatus;
    function GetMessageClass: string;
    function GetMileage: string;
    function GetNetMeetingAutoStart: Boolean;
    function GetNetMeetingOrganizerAlias: string;
    function GetNetMeetingServer: string;
    function GetNetMeetingType: TOpOlNetMeetingType;
    function GetNoAging: Boolean;
    function GetOptionalAttendees: string;
    function GetOrganizer: string;
    function GetOutlookInternalVersion: Integer;
    function GetOutlookVersion: string;
    function GetRecurrenceState: TOpOlRecurrenceState;
    function GetReminderMinutesBeforeStart: Integer;
    function GetReminderOverrideDefault: Boolean;
    function GetReminderPlaySound: Boolean;
    function GetReminderSet: Boolean;
    function GetReminderSoundFile: string;
    function GetReplyTime: TDateTime;
    function GetRequiredAttendees: string;
    function GetResources: string;
    function GetResponseRequested: Boolean;
    function GetResponseStatus: TOpOlResponseStatus;
    function GetSaved: Boolean;
    function GetSensitivity: TOpOlSensitivity;
    function GetSize: Integer;
    function GetStart: TDateTime;
    function GetSubject: string;
    function GetUnRead: Boolean;
    procedure SetAllDayEvent(Value: Boolean);
    procedure SetBillingInformation(const Value: string);
    procedure SetBody(const Value: string);
    procedure SetBusyStatus(Value: TOpOlBusyStatus);
    procedure SetCategories(const Value: string);
    procedure SetCompanies(const Value: string);
    procedure SetDuration(Value: Integer);
    procedure SetEnd_(const Value: TDateTime);
    procedure SetImportance(Value: TOpOlImportance);
    procedure SetIsOnlineMeeting(Value: Boolean);
    procedure SetLocation(const Value: string);
    procedure SetMeetingStatus(Value: TOpOlMeetingStatus);
    procedure SetMessageClass(const Value: string);
    procedure SetMileage(const Value: string);
    procedure SetNetMeetingAutoStart(Value: Boolean);
    procedure SetNetMeetingOrganizerAlias(const Value: string);
    procedure SetNetMeetingServer(const Value: string);
    procedure SetNetMeetingType(Value: TOpOlNetMeetingType);
    procedure SetNoAging(Value: Boolean);
    procedure SetOptionalAttendees(const Value: string);
    procedure SetReminderMinutesBeforeStart(Value: Integer);
    procedure SetReminderOverrideDefault(Value: Boolean);
    procedure SetReminderPlaySound(Value: Boolean);
    procedure SetReminderSet(Value: Boolean);
    procedure SetReminderSoundFile(const Value: string);
    procedure SetReplyTime(const Value: TDateTime);
    procedure SetRequiredAttendees(const Value: string);
    procedure SetResources(const Value: string);
    procedure SetResponseRequested(Value: Boolean);
    procedure SetSensitivity(Value: TOpOlSensitivity);
    procedure SetStart(const Value: TDateTime);
    procedure SetSubject(const Value: string);
    procedure SetUnRead(Value: Boolean);
  public
    constructor Create(ApptItem: _AppointmentItem);
    destructor Destroy; override;
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: TOpAppointmentItem;
    procedure Delete;
    procedure Display(Modal: Boolean);
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    procedure ClearRecurrencePattern;
    function ForwardAsVcal: TOpMailItem;
    function GetRecurrencePattern: RecurrencePattern;
    function Respond(Response: TOpOlMeetingResponse;
       NoUI, AdditionalTextDialog: Boolean): MeetingItem;
    procedure Send;
    {: AppointmentItem provides the Outlook _AppointmentItem interface associated
       with the instance. }
    property AppointmentItem: _AppointmentItem read FAppointmentItem;
    property Attachments: TOpAttachmentList read FAttachments;
    property BillingInformation: string read GetBillingInformation write SetBillingInformation;
    property Body: string read GetBody write SetBody;
    property Categories: string read GetCategories write SetCategories;
    property Companies: string read GetCompanies write SetCompanies;
    property ConversationIndex: string read GetConversationIndex;
    property ConversationTopic: string read GetConversationTopic;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property FormDescription: FormDescription read GetFormDescription;
    property Importance: TOpOlImportance read GetImportance write SetImportance;
    property ItemInspector: Inspector read GetInspector;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property MessageClass: string read GetMessageClass write SetMessageClass;
    property Mileage: string read GetMileage write SetMileage;
    property NoAging: Boolean read GetNoAging write SetNoAging;
    property OutlookInternalVersion: Integer read GetOutlookInternalVersion;
    property OutlookVersion: string read GetOutlookVersion;
    property Saved: Boolean read GetSaved;
    property Sensitivity: TOpOlSensitivity read GetSensitivity write SetSensitivity;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject write SetSubject;
    property UnRead: Boolean read GetUnRead write SetUnRead;
    property AllDayEvent: Boolean read GetAllDayEvent write SetAllDayEvent;
    property BusyStatus: TOpOlBusyStatus read GetBusyStatus write SetBusyStatus;
    property Duration: Integer read GetDuration write SetDuration;
    property End_: TDateTime read GetEnd_ write SetEnd_;
    property IsOnlineMeeting: Boolean read GetIsOnlineMeeting write SetIsOnlineMeeting;
    property IsRecurring: Boolean read GetIsRecurring;
    property Location: string read GetLocation write SetLocation;
    property MeetingStatus: TOpOlMeetingStatus read GetMeetingStatus write SetMeetingStatus;
    property NetMeetingAutoStart: Boolean read GetNetMeetingAutoStart write SetNetMeetingAutoStart;
    property NetMeetingOrganizerAlias: string read GetNetMeetingOrganizerAlias write SetNetMeetingOrganizerAlias;
    property NetMeetingServer: string read GetNetMeetingServer write SetNetMeetingServer;
    property NetMeetingType: TOpOlNetMeetingType read GetNetMeetingType write SetNetMeetingType;
    property OptionalAttendees: string read GetOptionalAttendees write SetOptionalAttendees;
    property Organizer: string read GetOrganizer;
    property Recipients: TOpRecipientList read FRecipients;
    property RecurrenceState: TOpOlRecurrenceState read GetRecurrenceState;
    property ReminderMinutesBeforeStart: Integer read GetReminderMinutesBeforeStart write SetReminderMinutesBeforeStart;
    property ReminderOverrideDefault: Boolean read GetReminderOverrideDefault write SetReminderOverrideDefault;
    property ReminderPlaySound: Boolean read GetReminderPlaySound write SetReminderPlaySound;
    property ReminderSet: Boolean read GetReminderSet write SetReminderSet;
    property ReminderSoundFile: string read GetReminderSoundFile write SetReminderSoundFile;
    property ReplyTime: TDateTime read GetReplyTime write SetReplyTime;
    property RequiredAttendees: string read GetRequiredAttendees write SetRequiredAttendees;
    property Resources: string read GetResources write SetResources;
    property ResponseRequested: Boolean read GetResponseRequested write SetResponseRequested;
    property ResponseStatus: TOpOlResponseStatus read GetResponseStatus;
    property Start: TDateTime read GetStart write SetStart;
  end;

  {: TOpContactItem encapsulatetes the Outlook _ContactItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateContactItem method. }
  TOpContactItem = class(TOpOutlookItem)
  private
    FContactItem: _ContactItem;
    function GetAccount: string;
    function GetAnniversary: TDateTime;
    function GetAssistantName: string;
    function GetAssistantTelephoneNumber: string;
    function GetBillingInformation: string;
    function GetBirthday: TDateTime;
    function GetBusiness2TelephoneNumber: string;
    function GetBusinessAddress: string;
    function GetBusinessAddressCity: string;
    function GetBusinessAddressCountry: string;
    function GetBusinessAddressPostalCode: string;
    function GetBusinessAddressPostOfficeBox: string;
    function GetBusinessAddressState: string;
    function GetBusinessAddressStreet: string;
    function GetBusinessFaxNumber: string;
    function GetBusinessHomePage: string;
    function GetBusinessTelephoneNumber: string;
    function GetCallbackTelephoneNumber: string;
    function GetCarTelephoneNumber: string;
    function GetCategories: string;
    function GetChildren: string;
    function GetCompanies: string;
    function GetCompanyAndFullName: string;
    function GetCompanyLastFirstNoSpace: string;
    function GetCompanyLastFirstSpaceOnly: string;
    function GetCompanyMainTelephoneNumber: string;
    function GetCompanyName: string;
    function GetComputerNetworkName: string;
    function GetCreationTime: TDateTime;
    function GetCustomerID: string;
    function GetDepartment: string;
    function GetEmail1Address: string;
    function GetEmail1AddressType: string;
    function GetEmail1DisplayName: string;
    function GetEmail1EntryID: string;
    function GetEmail2Address: string;
    function GetEmail2AddressType: string;
    function GetEmail2DisplayName: string;
    function GetEmail2EntryID: string;
    function GetEmail3Address: string;
    function GetEmail3AddressType: string;
    function GetEmail3DisplayName: string;
    function GetEmail3EntryID: string;
    function GetEntryID: string;
    function GetFileAs: string;
    function GetFirstName: string;
    function GetFTPSite: string;
    function GetFullName: string;
    function GetFullNameAndCompany: string;
    function GetGender: TOpOlGender;
    function GetInspector: Inspector;
    function GetGovernmentIDNumber: string;
    function GetHobby: string;
    function GetHome2TelephoneNumber: string;
    function GetHomeAddress: string;
    function GetHomeAddressCity: string;
    function GetHomeAddressCountry: string;
    function GetHomeAddressPostalCode: string;
    function GetHomeAddressPostOfficeBox: string;
    function GetHomeAddressState: string;
    function GetHomeAddressStreet: string;
    function GetHomeFaxNumber: string;
    function GetHomeTelephoneNumber: string;
    function GetImportance: OlImportance;
    function GetInitials: string;
    function GetInternetFreeBusyAddress: string;
    function GetISDNNumber: string;
    function GetJobTitle: string;
    function GetJournal: Boolean;
    function GetLanguage: string;
    function GetLastFirstAndSuffix: string;
    function GetLastFirstNoSpace: string;
    function GetLastFirstNoSpaceCompany: string;
    function GetLastFirstSpaceOnly: string;
    function GetLastFirstSpaceOnlyCompany: string;
    function GetLastModificationTime: TDateTime;
    function GetLastName: string;
    function GetLastNameAndFirstName: string;
    function GetMailingAddress: string;
    function GetMailingAddressCity: string;
    function GetMailingAddressCountry: string;
    function GetMailingAddressPostalCode: string;
    function GetMailingAddressPostOfficeBox: string;
    function GetMailingAddressState: string;
    function GetMailingAddressStreet: string;
    function GetManagerName: string;
    function GetMiddleName: string;
    function GetMobileTelephoneNumber: string;
    function GetNetMeetingAlias: string;
    function GetNetMeetingServer: string;
    function GetNickName: string;
    function GetNoAging: Boolean;
    function GetOfficeLocation: string;
    function GetOrganizationalIDNumber: string;
    function GetOtherAddress: string;
    function GetOtherAddressCity: string;
    function GetOtherAddressCountry: string;
    function GetOtherAddressPostalCode: string;
    function GetOtherAddressPostOfficeBox: string;
    function GetOtherAddressState: string;
    function GetOtherAddressStreet: string;
    function GetOtherFaxNumber: string;
    function GetOtherTelephoneNumber: string;
    function GetPagerNumber: string;
    function GetPersonalHomePage: string;
    function GetPrimaryTelephoneNumber: string;
    function GetProfession: string;
    function GetRadioTelephoneNumber: string;
    function GetReferredBy: string;
    function GetSaved: Boolean;
    function GetSelectedMailingAddress: TOpOlMailingAddress;
    function GetSize: Integer;
    function GetSpouse: string;
    function GetSuffix: string;
    function GetTelexNumber: string;
    function GetTitle: string;
    function GetTTYTDDTelephoneNumber: string;
    function GetUser1: string;
    function GetUser2: string;
    function GetUser3: string;
    function GetUser4: string;
    function GetUserCertificate: string;
    function GetUserProperties: UserProperties;
    function GetWebPage: string;
    function GetYomiCompanyName: string;
    function GetYomiFirstName: string;
    function GetYomiLastName: string;
    procedure SetAccount(const Value: string);
    procedure SetAnniversary(const Value: TDateTime);
    procedure SetAssistantName(const Value: string);
    procedure SetAssistantTelephoneNumber(const Value: string);
    procedure SetBillingInformation(const Value: string);
    procedure SetBirthday(const Value: TDateTime);
    procedure SetBusiness2TelephoneNumber(const Value: string);
    procedure SetBusinessAddress(const Value: string);
    procedure SetBusinessAddressCity(const Value: string);
    procedure SetBusinessAddressCountry(const Value: string);
    procedure SetBusinessAddressPostalCode(const Value: string);
    procedure SetBusinessAddressPostOfficeBox(const Value: string);
    procedure SetBusinessAddressState(const Value: string);
    procedure SetBusinessAddressStreet(const Value: string);
    procedure SetBusinessFaxNumber(const Value: string);
    procedure SetBusinessHomePage(const Value: string);
    procedure SetBusinessTelephoneNumber(const Value: string);
    procedure SetCallbackTelephoneNumber(const Value: string);
    procedure SetCarTelephoneNumber(const Value: string);
    procedure SetCategories(const Value: string);
    procedure SetChildren(const Value: string);
    procedure SetCompanies(const Value: string);
    procedure SetCompanyMainTelephoneNumber(const Value: string);
    procedure SetCompanyName(const Value: string);
    procedure SetComputerNetworkName(const Value: string);
    procedure SetCustomerID(const Value: string);
    procedure SetDepartment(const Value: string);
    procedure SetEmail1Address(const Value: string);
    procedure SetEmail1AddressType(const Value: string);
    procedure SetEmail2Address(const Value: string);
    procedure SetEmail2AddressType(const Value: string);
    procedure SetEmail3Address(const Value: string);
    procedure SetEmail3AddressType(const Value: string);
    procedure SetFileAs(const Value: string);
    procedure SetFirstName(const Value: string);
    procedure SetFTPSite(const Value: string);
    procedure SetFullName(const Value: string);
    procedure SetGender(Value: TOpOlGender);
    procedure SetGovernmentIDNumber(const Value: string);
    procedure SetHobby(const Value: string);
    procedure SetHome2TelephoneNumber(const Value: string);
    procedure SetHomeAddress(const Value: string);
    procedure SetHomeAddressCity(const Value: string);
    procedure SetHomeAddressCountry(const Value: string);
    procedure SetHomeAddressPostalCode(const Value: string);
    procedure SetHomeAddressPostOfficeBox(const Value: string);
    procedure SetHomeAddressState(const Value: string);
    procedure SetHomeAddressStreet(const Value: string);
    procedure SetHomeFaxNumber(const Value: string);
    procedure SetHomeTelephoneNumber(const Value: string);
    procedure SetImportance(Value: OlImportance);
    procedure SetInitials(const Value: string);
    procedure SetInternetFreeBusyAddress(const Value: string);
    procedure SetISDNNumber(const Value: string);
    procedure SetJobTitle(const Value: string);
    procedure SetJournal(Value: Boolean);
    procedure SetLanguage(const Value: string);
    procedure SetLastName(const Value: string);
    procedure SetMailingAddress(const Value: string);
    procedure SetMailingAddressCity(const Value: string);
    procedure SetMailingAddressCountry(const Value: string);
    procedure SetMailingAddressPostalCode(const Value: string);
    procedure SetMailingAddressPostOfficeBox(const Value: string);
    procedure SetMailingAddressState(const Value: string);
    procedure SetMailingAddressStreet(const Value: string);
    procedure SetManagerName(const Value: string);
    procedure SetMiddleName(const Value: string);
    procedure SetMobileTelephoneNumber(const Value: string);
    procedure SetNetMeetingAlias(const Value: string);
    procedure SetNetMeetingServer(const Value: string);
    procedure SetNickName(const Value: string);
    procedure SetNoAging(Value: Boolean);
    procedure SetOfficeLocation(const Value: string);
    procedure SetOrganizationalIDNumber(const Value: string);
    procedure SetOtherAddress(const Value: string);
    procedure SetOtherAddressCity(const Value: string);
    procedure SetOtherAddressCountry(const Value: string);
    procedure SetOtherAddressPostalCode(const Value: string);
    procedure SetOtherAddressPostOfficeBox(const Value: string);
    procedure SetOtherAddressState(const Value: string);
    procedure SetOtherAddressStreet(const Value: string);
    procedure SetOtherFaxNumber(const Value: string);
    procedure SetOtherTelephoneNumber(const Value: string);
    procedure SetPagerNumber(const Value: string);
    procedure SetPersonalHomePage(const Value: string);
    procedure SetPrimaryTelephoneNumber(const Value: string);
    procedure SetProfession(const Value: string);
    procedure SetRadioTelephoneNumber(const Value: string);
    procedure SetReferredBy(const Value: string);
    procedure SetSelectedMailingAddress(Value: TOpOlMailingAddress);
    procedure SetSpouse(const Value: string);
    procedure SetSuffix(const Value: string);
    procedure SetTelexNumber(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetTTYTDDTelephoneNumber(const Value: string);
    procedure SetUser1(const Value: string);
    procedure SetUser2(const Value: string);
    procedure SetUser3(const Value: string);
    procedure SetUser4(const Value: string);
    procedure SetUserCertificate(const Value: string);
    procedure SetWebPage(const Value: string);
    procedure SetYomiCompanyName(const Value: string);
    procedure SetYomiFirstName(const Value: string);
    procedure SetYomiLastName(const Value: string);
  public
    constructor Create(AContactItem: _ContactItem);
    {: ContactItem provides the Outlook _ContactItem interface associated
       with the instance.}
    property ContactItem: _ContactItem read FContactItem;
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: IDispatch;
    procedure Delete;
    procedure Display(Modal: Boolean);
    function Move(const DestFldr: MAPIFolder): IDispatch;
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    function ForwardAsVcard: TOpMailItem;
    property BillingInformation: string read GetBillingInformation write SetBillingInformation;
    property Categories: string read GetCategories write SetCategories;
    property Companies: string read GetCompanies write SetCompanies;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property Importance: OlImportance read GetImportance write SetImportance;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property NoAging: Boolean read GetNoAging write SetNoAging;
    property Saved: Boolean read GetSaved;
    property Size: Integer read GetSize;
    property UserProperties: UserProperties read GetUserProperties;
    property Account: string read GetAccount write SetAccount;
    property Anniversary: TDateTime read GetAnniversary write SetAnniversary;
    property AssistantName: string read GetAssistantName write SetAssistantName;
    property AssistantTelephoneNumber: string read GetAssistantTelephoneNumber write SetAssistantTelephoneNumber;
    property Birthday: TDateTime read GetBirthday write SetBirthday;
    property Business2TelephoneNumber: string read GetBusiness2TelephoneNumber write SetBusiness2TelephoneNumber;
    property BusinessAddress: string read GetBusinessAddress write SetBusinessAddress;
    property BusinessAddressCity: string read GetBusinessAddressCity write SetBusinessAddressCity;
    property BusinessAddressCountry: string read GetBusinessAddressCountry write SetBusinessAddressCountry;
    property BusinessAddressPostalCode: string read GetBusinessAddressPostalCode write SetBusinessAddressPostalCode;
    property BusinessAddressPostOfficeBox: string read GetBusinessAddressPostOfficeBox write SetBusinessAddressPostOfficeBox;
    property BusinessAddressState: string read GetBusinessAddressState write SetBusinessAddressState;
    property BusinessAddressStreet: string read GetBusinessAddressStreet write SetBusinessAddressStreet;
    property BusinessFaxNumber: string read GetBusinessFaxNumber write SetBusinessFaxNumber;
    property BusinessHomePage: string read GetBusinessHomePage write SetBusinessHomePage;
    property BusinessTelephoneNumber: string read GetBusinessTelephoneNumber write SetBusinessTelephoneNumber;
    property CallbackTelephoneNumber: string read GetCallbackTelephoneNumber write SetCallbackTelephoneNumber;
    property CarTelephoneNumber: string read GetCarTelephoneNumber write SetCarTelephoneNumber;
    property Children: string read GetChildren write SetChildren;
    property CompanyAndFullName: string read GetCompanyAndFullName;
    property CompanyLastFirstNoSpace: string read GetCompanyLastFirstNoSpace;
    property CompanyLastFirstSpaceOnly: string read GetCompanyLastFirstSpaceOnly;
    property CompanyMainTelephoneNumber: string read GetCompanyMainTelephoneNumber write SetCompanyMainTelephoneNumber;
    property CompanyName: string read GetCompanyName write SetCompanyName;
    property ComputerNetworkName: string read GetComputerNetworkName write SetComputerNetworkName;
    property CustomerID: string read GetCustomerID write SetCustomerID;
    property Department: string read GetDepartment write SetDepartment;
    property Email1Address: string read GetEmail1Address write SetEmail1Address;
    property Email1AddressType: string read GetEmail1AddressType write SetEmail1AddressType;
    property Email1DisplayName: string read GetEmail1DisplayName;
    property Email1EntryID: string read GetEmail1EntryID;
    property Email2Address: string read GetEmail2Address write SetEmail2Address;
    property Email2AddressType: string read GetEmail2AddressType write SetEmail2AddressType;
    property Email2DisplayName: string read GetEmail2DisplayName;
    property Email2EntryID: string read GetEmail2EntryID;
    property Email3Address: string read GetEmail3Address write SetEmail3Address;
    property Email3AddressType: string read GetEmail3AddressType write SetEmail3AddressType;
    property Email3DisplayName: string read GetEmail3DisplayName;
    property Email3EntryID: string read GetEmail3EntryID;
    property FileAs: string read GetFileAs write SetFileAs;
    property FirstName: string read GetFirstName write SetFirstName;
    property FTPSite: string read GetFTPSite write SetFTPSite;
    property FullName: string read GetFullName write SetFullName;
    property FullNameAndCompany: string read GetFullNameAndCompany;
    property Gender: TOpOlGender read GetGender write SetGender;
    property GovernmentIDNumber: string read GetGovernmentIDNumber write SetGovernmentIDNumber;
    property Hobby: string read GetHobby write SetHobby;
    property Home2TelephoneNumber: string read GetHome2TelephoneNumber write SetHome2TelephoneNumber;
    property HomeAddress: string read GetHomeAddress write SetHomeAddress;
    property HomeAddressCity: string read GetHomeAddressCity write SetHomeAddressCity;
    property HomeAddressCountry: string read GetHomeAddressCountry write SetHomeAddressCountry;
    property HomeAddressPostalCode: string read GetHomeAddressPostalCode write SetHomeAddressPostalCode;
    property HomeAddressPostOfficeBox: string read GetHomeAddressPostOfficeBox write SetHomeAddressPostOfficeBox;
    property HomeAddressState: string read GetHomeAddressState write SetHomeAddressState;
    property HomeAddressStreet: string read GetHomeAddressStreet write SetHomeAddressStreet;
    property HomeFaxNumber: string read GetHomeFaxNumber write SetHomeFaxNumber;
    property HomeTelephoneNumber: string read GetHomeTelephoneNumber write SetHomeTelephoneNumber;
    property Initials: string read GetInitials write SetInitials;
    property ItemInspector: Inspector read GetInspector;
    property InternetFreeBusyAddress: string read GetInternetFreeBusyAddress write SetInternetFreeBusyAddress;
    property ISDNNumber: string read GetISDNNumber write SetISDNNumber;
    property JobTitle: string read GetJobTitle write SetJobTitle;
    property Journal: Boolean read GetJournal write SetJournal;
    property Language: string read GetLanguage write SetLanguage;
    property LastFirstAndSuffix: string read GetLastFirstAndSuffix;
    property LastFirstNoSpace: string read GetLastFirstNoSpace;
    property LastFirstNoSpaceCompany: string read GetLastFirstNoSpaceCompany;
    property LastFirstSpaceOnly: string read GetLastFirstSpaceOnly;
    property LastFirstSpaceOnlyCompany: string read GetLastFirstSpaceOnlyCompany;
    property LastName: string read GetLastName write SetLastName;
    property LastNameAndFirstName: string read GetLastNameAndFirstName;
    property MailingAddress: string read GetMailingAddress write SetMailingAddress;
    property MailingAddressCity: string read GetMailingAddressCity write SetMailingAddressCity;
    property MailingAddressCountry: string read GetMailingAddressCountry write SetMailingAddressCountry;
    property MailingAddressPostalCode: string read GetMailingAddressPostalCode write SetMailingAddressPostalCode;
    property MailingAddressPostOfficeBox: string read GetMailingAddressPostOfficeBox write SetMailingAddressPostOfficeBox;
    property MailingAddressState: string read GetMailingAddressState write SetMailingAddressState;
    property MailingAddressStreet: string read GetMailingAddressStreet write SetMailingAddressStreet;
    property ManagerName: string read GetManagerName write SetManagerName;
    property MiddleName: string read GetMiddleName write SetMiddleName;
    property MobileTelephoneNumber: string read GetMobileTelephoneNumber write SetMobileTelephoneNumber;
    property NetMeetingAlias: string read GetNetMeetingAlias write SetNetMeetingAlias;
    property NetMeetingServer: string read GetNetMeetingServer write SetNetMeetingServer;
    property NickName: string read GetNickName write SetNickName;
    property OfficeLocation: string read GetOfficeLocation write SetOfficeLocation;
    property OrganizationalIDNumber: string read GetOrganizationalIDNumber write SetOrganizationalIDNumber;
    property OtherAddress: string read GetOtherAddress write SetOtherAddress;
    property OtherAddressCity: string read GetOtherAddressCity write SetOtherAddressCity;
    property OtherAddressCountry: string read GetOtherAddressCountry write SetOtherAddressCountry;
    property OtherAddressPostalCode: string read GetOtherAddressPostalCode write SetOtherAddressPostalCode;
    property OtherAddressPostOfficeBox: string read GetOtherAddressPostOfficeBox write SetOtherAddressPostOfficeBox;
    property OtherAddressState: string read GetOtherAddressState write SetOtherAddressState;
    property OtherAddressStreet: string read GetOtherAddressStreet write SetOtherAddressStreet;
    property OtherFaxNumber: string read GetOtherFaxNumber write SetOtherFaxNumber;
    property OtherTelephoneNumber: string read GetOtherTelephoneNumber write SetOtherTelephoneNumber;
    property PagerNumber: string read GetPagerNumber write SetPagerNumber;
    property PersonalHomePage: string read GetPersonalHomePage write SetPersonalHomePage;
    property PrimaryTelephoneNumber: string read GetPrimaryTelephoneNumber write SetPrimaryTelephoneNumber;
    property Profession: string read GetProfession write SetProfession;
    property RadioTelephoneNumber: string read GetRadioTelephoneNumber write SetRadioTelephoneNumber;
    property ReferredBy: string read GetReferredBy write SetReferredBy;
    property SelectedMailingAddress: TOpOlMailingAddress read GetSelectedMailingAddress write SetSelectedMailingAddress;
    property Spouse: string read GetSpouse write SetSpouse;
    property Suffix: string read GetSuffix write SetSuffix;
    property TelexNumber: string read GetTelexNumber write SetTelexNumber;
    property Title: string read GetTitle write SetTitle;
    property TTYTDDTelephoneNumber: string read GetTTYTDDTelephoneNumber write SetTTYTDDTelephoneNumber;
    property User1: string read GetUser1 write SetUser1;
    property User2: string read GetUser2 write SetUser2;
    property User3: string read GetUser3 write SetUser3;
    property User4: string read GetUser4 write SetUser4;
    property UserCertificate: string read GetUserCertificate write SetUserCertificate;
    property WebPage: string read GetWebPage write SetWebPage;
    property YomiCompanyName: string read GetYomiCompanyName write SetYomiCompanyName;
    property YomiFirstName: string read GetYomiFirstName write SetYomiFirstName;
    property YomiLastName: string read GetYomiLastName write SetYomiLastName;
  end;

  {: TOpJournalItem encapsulatetes the Outlook _JournalItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateJournalItem method. }
  TOpJournalItem = class(TOpOutlookItem)
  private
    FJournalItem: _JournalItem;
    FAttachments: TOpAttachmentList;
    function GetBillingInformation: string;
    function GetBody: string;
    function GetCategories: string;
    function GetCompanies: string;
    function GetContactNames: string;
    function GetConversationIndex: string;
    function GetConversationTopic: string;
    function GetCreationTime: TDateTime;
    function GetDocPosted: Boolean;
    function GetDocPrinted: Boolean;
    function GetDocRouted: Boolean;
    function GetDocSaved: Boolean;
    function GetDuration: Integer;
    function GetEnd_: TDateTime;
    function GetEntryID: string;
    function GetImportance: TOpOlImportance;
    function GetLastModificationTime: TDateTime;
    function GetMessageClass: string;
    function GetMileage: string;
    function GetNoAging: Boolean;
    function GetOutlookInternalVersion: Integer;
    function GetOutlookVersion: string;
    function GetSaved: Boolean;
    function GetSensitivity: TOpOlSensitivity;
    function GetSize: Integer;
    function GetStart: TDateTime;
    function GetSubject: string;
    function GetType_: string;
    function GetUnRead: Boolean;
    procedure SetBillingInformation(const Value: string);
    procedure SetBody(const Value: string);
    procedure SetCategories(const Value: string);
    procedure SetCompanies(const Value: string);
    procedure SetContactNames(const Value: string);
    procedure SetDocPosted(Value: Boolean);
    procedure SetDocPrinted(Value: Boolean);
    procedure SetDocRouted(Value: Boolean);
    procedure SetDocSaved(Value: Boolean);
    procedure SetDuration(Value: Integer);
    procedure SetEnd_(const Value: TDateTime);
    procedure SetImportance(Value: TOpOlImportance);
    procedure SetMessageClass(const Value: string);
    procedure SetMileage(const Value: string);
    procedure SetNoAging(Value: Boolean);
    procedure SetSensitivity(Value: TOpOlSensitivity);
    procedure SetStart(const Value: TDateTime);
    procedure SetSubject(const Value: string);
    procedure SetType_(const Value: string);
    procedure SetUnRead(Value: Boolean);
    function GetInspector: Inspector;
  public
    constructor Create(AJournalItem: _JournalItem);
    destructor Destroy; override;                                    {!!.62}
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: TOpJournalItem;
    procedure Delete;
    procedure Display(Modal: Boolean);
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    function Forward: TOpMailItem;
    function Reply: TOpMailItem;
    function ReplyAll: TOpMailItem;
    procedure StartTimer;
    procedure StopTimer;
    property Attachments: TOpAttachmentList read FAttachments;
    property BillingInformation: string read GetBillingInformation write SetBillingInformation;
    property Body: string read GetBody write SetBody;
    property Categories: string read GetCategories write SetCategories;
    property Companies: string read GetCompanies write SetCompanies;
    property ConversationIndex: string read GetConversationIndex;
    property ConversationTopic: string read GetConversationTopic;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property Importance: TOpOlImportance read GetImportance write SetImportance;
    property ItemInspector: Inspector read GetInspector;
    {: JournalItem provides the Outlook _JournalItem interface associated
       with the instance. }
    property JournalItem: _JournalItem read FJournalItem;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property MessageClass: string read GetMessageClass write SetMessageClass;
    property Mileage: string read GetMileage write SetMileage;
    property NoAging: Boolean read GetNoAging write SetNoAging;
    property OutlookInternalVersion: Integer read GetOutlookInternalVersion;
    property OutlookVersion: string read GetOutlookVersion;
    property Saved: Boolean read GetSaved;
    property Sensitivity: TOpOlSensitivity read GetSensitivity write SetSensitivity;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject write SetSubject;
    property UnRead: Boolean read GetUnRead write SetUnRead;
    property ContactNames: string read GetContactNames write SetContactNames;
    property DocPosted: Boolean read GetDocPosted write SetDocPosted;
    property DocPrinted: Boolean read GetDocPrinted write SetDocPrinted;
    property DocRouted: Boolean read GetDocRouted write SetDocRouted;
    property DocSaved: Boolean read GetDocSaved write SetDocSaved;
    property Duration: Integer read GetDuration write SetDuration;
    property End_: TDateTime read GetEnd_ write SetEnd_;
    property Type_: string read GetType_ write SetType_;
    property Start: TDateTime read GetStart write SetStart;
  end;

  {: TOpNoteItem encapsulatetes the Outlook _NoteItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateNoteItem method. }
  TOpNoteItem = class(TOpOutlookItem)
  private
    FNoteItem: _NoteItem;
    function GetBody: string;
    function GetCategories: string;
    function GetColor: TOpOlNoteColor;
    function GetCreationTime: TDateTime;
    function GetEntryID: string;
    function GetHeight: Integer;
    function GetLastModificationTime: TDateTime;
    function GetLeft: Integer;
    function GetMessageClass: string;
    function GetSaved: Boolean;
    function GetSize: Integer;
    function GetSubject: string;
    function GetTop: Integer;
    function GetWidth: Integer;
    procedure SetBody(const Value: string);
    procedure SetCategories(const Value: string);
    procedure SetColor(const Value: TOpOlNoteColor);
    procedure SetHeight(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetMessageClass(const Value: string);
    procedure SetTop(Value: Integer);
    procedure SetWidth(Value: Integer);
  public
    constructor Create(ANoteItem: _NoteItem);
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: TOpNoteItem;
    procedure Delete;
    procedure Display(Modal: Boolean);
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    property Body: string read GetBody write SetBody;
    property Categories: string read GetCategories write SetCategories;
    property Color: TOpOlNoteColor read GetColor write SetColor;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property Height: Integer read GetHeight write SetHeight;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property Left: Integer read GetLeft write SetLeft;
    property MessageClass: string read GetMessageClass write SetMessageClass;
    {: NoteItem provides the Outlook _NoteItem interface associated
       with the instance. }
    property NoteItem: _NoteItem read FNoteItem;
    property Saved: Boolean read GetSaved;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
  end;

  {: TOpPostItem encapsulatetes the Outlook _PostItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreatePostItem method. }
  TOpPostItem = class(TOpOutlookItem)
  private
    FAttachments: TOpAttachmentList;
    FPostItem: _PostItem;
    function GetBillingInformation: string;
    function GetBody: string;
    function GetCategories: string;
    function GetCompanies: string;
    function GetConversationIndex: string;
    function GetConversationTopic: string;
    function GetCreationTime: TDateTime;
    function GetEntryID: string;
    function GetExpiryTime: TDateTime;
    function GetHTMLBody: string;
    function GetImportance: TOpOlImportance;
    function GetInspector: Inspector;
    function GetLastModificationTime: TDateTime;
    function GetMessageClass: string;
    function GetMileage: string;
    function GetNoAging: Boolean;
    function GetOutlookInternalVersion: Integer;
    function GetOutlookVersion: string;
    function GetReceivedTime: TDateTime;
    function GetSaved: Boolean;
    function GetSenderName: string;
    function GetSensitivity: TOpOlSensitivity;
    function GetSentOn: TDateTime;
    function GetSize: Integer;
    function GetSubject: string;
    function GetUnRead: Boolean;
    procedure SetBillingInformation(const Value: string);
    procedure SetBody(const Value: string);
    procedure SetCategories(const Value: string);
    procedure SetCompanies(const Value: string);
    procedure SetExpiryTime(const Value: TDateTime);
    procedure SetHTMLBody(const Value: string);
    procedure SetImportance(Value: TOpOlImportance);
    procedure SetMessageClass(const Value: string);
    procedure SetMileage(const Value: string);
    procedure SetNoAging(Value: Boolean);
    procedure SetSensitivity(Value: TOpOlSensitivity);
    procedure SetSubject(const Value: string);
    procedure SetUnRead(Value: Boolean);
  public
    constructor Create(APostItem: _PostItem);
    destructor Destroy; override;
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: TOpPostItem;
    procedure Delete;
    procedure Display(Modal: Boolean);
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    procedure ClearConversationIndex;
    function Forward: TOpMailItem;
    procedure Post;
    function Reply: TOpMailItem;
    property Attachments: TOpAttachmentList read FAttachments;
    property BillingInformation: string read GetBillingInformation write SetBillingInformation;
    property Body: string read GetBody write SetBody;
    property Categories: string read GetCategories write SetCategories;
    property Companies: string read GetCompanies write SetCompanies;
    property ConversationIndex: string read GetConversationIndex;
    property ConversationTopic: string read GetConversationTopic;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property Importance: TOpOlImportance read GetImportance write SetImportance;
    property ItemInspector: Inspector read GetInspector;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property MessageClass: string read GetMessageClass write SetMessageClass;
    property Mileage: string read GetMileage write SetMileage;
    property NoAging: Boolean read GetNoAging write SetNoAging;
    property OutlookInternalVersion: Integer read GetOutlookInternalVersion;
    property OutlookVersion: string read GetOutlookVersion;
    {: PostItem provides the Outlook _PostItem interface associated
       with the instance. }
    property PostItem: _PostItem read FPostItem;
    property Saved: Boolean read GetSaved;
    property Sensitivity: TOpOlSensitivity read GetSensitivity write SetSensitivity;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject write SetSubject;
    property UnRead: Boolean read GetUnRead write SetUnRead;
    property ExpiryTime: TDateTime read GetExpiryTime write SetExpiryTime;
    property HTMLBody: string read GetHTMLBody write SetHTMLBody;
    property ReceivedTime: TDateTime read GetReceivedTime;
    property SenderName: string read GetSenderName;
    property SentOn: TDateTime read GetSentOn;
  end;

  {: TOpTaskItem encapsulatetes the Outlook _TaskItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateTaskItem method. }
  TOpTaskItem = class(TOpOutlookItem)
  private
    FAttachments: TOpAttachmentList;
    FRecipients: TOpRecipientList;
    FTaskItem: _TaskItem;
    function GetActualWork: Integer;
    function GetBillingInformation: string;
    function GetBody: string;
    function GetCardData: string;
    function GetCategories: string;
    function GetCompanies: string;
    function GetComplete: Boolean;
    function GetContactNames: string;
    function GetContacts: string;
    function GetConversationIndex: string;
    function GetConversationTopic: string;
    function GetCreationTime: TDateTime;
    function GetDateCompleted: TDateTime;
    function GetDelegationState: TOpOlTaskDelegationState;
    function GetDelegator: string;
    function GetDueDate: TDateTime;
    function GetEntryID: string;
    function GetInspector: Inspector;
    function GetImportance: TOpOlImportance;
    function GetIsRecurring: Boolean;
    function GetLastModificationTime: TDateTime;
    function GetMessageClass: string;
    function GetMileage: string;
    function GetNoAging: Boolean;
    function GetOrdinal: Integer;
    function GetOutlookInternalVersion: Integer;
    function GetOutlookVersion: string;
    function GetOwner: string;
    function GetOwnership: TOpOlTaskOwnership;
    function GetPercentComplete: Integer;
    function GetReminderOverrideDefault: Boolean;
    function GetReminderPlaySound: Boolean;
    function GetReminderSet: Boolean;
    function GetReminderSoundFile: string;
    function GetReminderTime: TDateTime;
    function GetResponseState: TOpOlTaskResponse;
    function GetRole: string;
    function GetSaved: Boolean;
    function GetSchedulePlusPriority: string;
    function GetSensitivity: TOpOlSensitivity;
    function GetSize: Integer;
    function GetStartDate: TDateTime;
    function GetStatus: TOpOlTaskStatus;
    function GetStatusOnCompletionRecipients: string;
    function GetStatusUpdateRecipients: string;
    function GetSubject: string;
    function GetTeamTask: Boolean;
    function GetTotalWork: Integer;
    function GetUnRead: Boolean;
    procedure SetActualWork(Value: Integer);
    procedure SetBillingInformation(const Value: string);
    procedure SetBody(const Value: string);
    procedure SetCardData(const Value: string);
    procedure SetCategories(const Value: string);
    procedure SetCompanies(const Value: string);
    procedure SetComplete(Value: Boolean);
    procedure SetContactNames(const Value: string);
    procedure SetContacts(const Value: string);
    procedure SetDateCompleted(const Value: TDateTime);
    procedure SetDueDate(const Value: TDateTime);
    procedure SetImportance(Value: TOpOlImportance);
    procedure SetMessageClass(const Value: string);
    procedure SetMileage(const Value: string);
    procedure SetNoAging(Value: Boolean);
    procedure SetOrdinal(Value: Integer);
    procedure SetOwner(const Value: string);
    procedure SetPercentComplete(Value: Integer);
    procedure SetReminderOverrideDefault(Value: Boolean);
    procedure SetReminderPlaySound(Value: Boolean);
    procedure SetReminderSet(Value: Boolean);
    procedure SetReminderSoundFile(const Value: string);
    procedure SetReminderTime(const Value: TDateTime);
    procedure SetRole(const Value: string);
    procedure SetSchedulePlusPriority(const Value: string);
    procedure SetSensitivity(Value: TOpOlSensitivity);
    procedure SetStartDate(const Value: TDateTime);
    procedure SetStatus(Value: TOpOlTaskStatus);
    procedure SetStatusOnCompletionRecipients(const Value: string);
    procedure SetStatusUpdateRecipients(const Value: string);
    procedure SetSubject(const Value: string);
    procedure SetTeamTask(Value: Boolean);
    procedure SetTotalWork(Value: Integer);
    procedure SetUnRead(Value: Boolean);
  public
    constructor Create(ATaskItem: _TaskItem);
    destructor Destroy; override;
    procedure Close(SaveMode: TOpOlInspectorClose);
    function Copy: TOpTaskItem;
    procedure Delete;
    procedure Display(Modal: Boolean);
    procedure PrintOut;
    procedure Save;
    procedure SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
    function Assign: TOpTaskItem;
    procedure CancelResponseState;
    procedure ClearRecurrencePattern;
    function GetRecurrencePattern: RecurrencePattern;
    procedure MarkComplete;
    function Respond(Response: TOpOlTaskResponse; NoUI, AdditionalTextDialog: Boolean): TOpTaskItem;
    procedure Send;
    function SkipRecurrence: Boolean;
    function StatusReport: IDispatch;
    property Attachments: TOpAttachmentList read FAttachments;
    property BillingInformation: string read GetBillingInformation write SetBillingInformation;
    property Body: string read GetBody write SetBody;
    property Categories: string read GetCategories write SetCategories;
    property Companies: string read GetCompanies write SetCompanies;
    property ConversationIndex: string read GetConversationIndex;
    property ConversationTopic: string read GetConversationTopic;
    property CreationTime: TDateTime read GetCreationTime;
    property EntryID: string read GetEntryID;
    property ItemInspector: Inspector read GetInspector;
    property Importance: TOpOlImportance read GetImportance write SetImportance;
    property LastModificationTime: TDateTime read GetLastModificationTime;
    property MessageClass: string read GetMessageClass write SetMessageClass;
    property Mileage: string read GetMileage write SetMileage;
    property NoAging: Boolean read GetNoAging write SetNoAging;
    property OutlookInternalVersion: Integer read GetOutlookInternalVersion;
    property OutlookVersion: string read GetOutlookVersion;
    property Saved: Boolean read GetSaved;
    property Sensitivity: TOpOlSensitivity read GetSensitivity write SetSensitivity;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject write SetSubject;
    property UnRead: Boolean read GetUnRead write SetUnRead;
    property ActualWork: Integer read GetActualWork write SetActualWork;
    property CardData: string read GetCardData write SetCardData;
    property Complete: Boolean read GetComplete write SetComplete;
    property Contacts: string read GetContacts write SetContacts;
    property ContactNames: string read GetContactNames write SetContactNames;
    property DateCompleted: TDateTime read GetDateCompleted write SetDateCompleted;
    property DelegationState: TOpOlTaskDelegationState read GetDelegationState;
    property Delegator: string read GetDelegator;
    property DueDate: TDateTime read GetDueDate write SetDueDate;
    property IsRecurring: Boolean read GetIsRecurring;
    property Ordinal: Integer read GetOrdinal write SetOrdinal;
    property Owner: string read GetOwner write SetOwner;
    property Ownership: TOpOlTaskOwnership read GetOwnership;
    property PercentComplete: Integer read GetPercentComplete write SetPercentComplete;
    property Recipients: TOpRecipientList read FRecipients;
    property ReminderTime: TDateTime read GetReminderTime write SetReminderTime;
    property ReminderOverrideDefault: Boolean read GetReminderOverrideDefault write SetReminderOverrideDefault;
    property ReminderPlaySound: Boolean read GetReminderPlaySound write SetReminderPlaySound;
    property ReminderSet: Boolean read GetReminderSet write SetReminderSet;
    property ReminderSoundFile: string read GetReminderSoundFile write SetReminderSoundFile;
    property ResponseState: TOpOlTaskResponse read GetResponseState;
    property Role: string read GetRole write SetRole;
    property SchedulePlusPriority: string read GetSchedulePlusPriority write SetSchedulePlusPriority;
    property StartDate: TDateTime read GetStartDate write SetStartDate;
    property Status: TOpOlTaskStatus read GetStatus write SetStatus;
    property StatusOnCompletionRecipients: string read GetStatusOnCompletionRecipients write SetStatusOnCompletionRecipients;
    property StatusUpdateRecipients: string read GetStatusUpdateRecipients write SetStatusUpdateRecipients;
    {: TaskItem provides the Outlook _TaskItem interface associated
       with the instance. }
    property TaskItem: _TaskItem read FTaskItem;
    property TeamTask: Boolean read GetTeamTask write SetTeamTask;
    property TotalWork: Integer read GetTotalWork write SetTotalWork;
  end;

  {: TOpMailItem encapsulatetes the Outlook _MailItem interface.
     You will most commonly create an instance of this class using the
     TOpOutlook.CreateMailItem method. }
  TOpMailItem = class(TOpOutlookItem)
  private
    FAttachments: TOpAttachmentList;
    FMailItem: _MailItem;
    FRecipients: TOpRecipientList;
    function GetAutoForwarded: Boolean;
    function GetBCC: string;
    function GetBody: string;
    function GetCC: string;
    function GetDeferredDeliveryTime: TDateTime;
    function GetHTMLBody: string;
    function GetImportance: TOpOlImportance;
    function GetMsgTo: string;
    function GetSaved: Boolean;
    function GetSenderName: string;
    function GetSensitivity: TOpOlSensitivity;
    function GetSent: Boolean;
    function GetSize: Integer;
    function GetSubject: string;
    function GetUnRead: Boolean;
    procedure SetAutoForwarded(Value: Boolean);
    procedure SetBCC(const Value: string);
    procedure SetBody(const Value: string);
    procedure SetCC(const Value: string);
    procedure SetDeferredDeliveryTime(const Value: TDateTime);
    procedure SetHTMLBody(const Value: string);
    procedure SetImportance(Value: TOpOlImportance);
    procedure SetMsgTo(const Value: string);
    procedure SetSensitivity(Value: TOpOlSensitivity);
    procedure SetSubject(const Value: string);
    procedure SetUnRead(Value: Boolean);
  public
    constructor Create(AMailItem: _MailItem);
    destructor Destroy; override;
    procedure ClearConversationIndex;
    procedure Delete;
    procedure Display(Modal: Boolean);
    function Forward: TOpMailItem;
    procedure PrintOut;
    function Reply: TOpMailItem;
    function ReplyAll: TOpMailItem;
    procedure Save;
    procedure Send;
    property Attachments: TOpAttachmentList read FAttachments;
    property AutoForwarded: Boolean read GetAutoForwarded write SetAutoForwarded;
    property Body: string read GetBody write SetBody;
    property DeferredDeliveryTime: TDateTime read GetDeferredDeliveryTime write
      SetDeferredDeliveryTime;
    property HTMLBody: string read GetHTMLBody write SetHTMLBody;
    property Importance: TOpOlImportance read GetImportance write SetImportance;
    {: MailItem provides the Outlook _MailItem interface associated
       with the instance. }
    property MailItem: _MailItem read FMailItem;
    property MsgBCC: string read GetBCC write SetBCC;
    property MsgCC: string read GetCC write SetCC;
    property MsgTo: string read GetMsgTo write SetMsgTo;
    property Recipients: TOpRecipientList read FRecipients;
    property Saved: Boolean read GetSaved;
    property SenderName: string read GetSenderName;
    property Sensitivity: TOpOlSensitivity read GetSensitivity write SetSensitivity;
    property Sent: Boolean read GetSent;
    property Size: Integer read GetSize;
    property Subject: string read GetSubject write SetSubject;
    property UnRead: Boolean read GetUnRead write SetUnRead;
  end;

  {: TOpMailListItem is the base class for items that are a part of Outlook
     collections, such as TOpRecipient and TOpAttachment. }
  TOpMailListItem = class(TObject)
  private
    FListProp: TOpMailListProp;
  protected
    property ListProp: TOpMailListProp read FListProp;
  public
    constructor Create(AListProp: TOpMailListProp);
    destructor Destroy; override;
  end;

  {: TOpMailListProp is the base class for Outlook properties that are
     collections, such as TOpRecipientList and TOpAttachmentList. }
  TOpMailListProp = class(TObject)
  private
    FDestroying: Boolean;
    FFreeList: TOpFreeList;
    FOwner: TOpOutlookItem;
  protected
    function GetCount: Integer; virtual; abstract;
  public
    constructor Create(AOwner: TOpOutlookItem);
    destructor Destroy; override;
    procedure AddItem(Item: TOpMailListItem);
    procedure RemoveItem(Item: TOpMailListItem);
    property Count: Integer read GetCount;
    property Destroying: Boolean read FDestroying;
  end;

  {: TOpRecipient encapsulates the Outlook Recipient interface, which is a
     representation of one recipient for a give Outlook item, such as an email
     message.  Typically, you would access instances of this class via a
     TOpRecipientList. }
  TOpRecipient = class(TOpMailListItem)
  private
    FIntf: Recipient;
    FOwner: TOpRecipientList;
    function GetAddress: string;
    function GetDisplayType: TOpOlDisplayType;
    function GetEntryID: string;
    function GetIndex: Integer;
    function GetName: string;
    function GetRecipientType: TOpOlMailRecipientType;
    function GetResolved: Boolean;
    function GetTrackingStatus: TOpOlTrackingStatus;
    function GetTrackingStatusTime: TDateTime;
    procedure SetRecipientType(Value: TOpOlMailRecipientType);
    procedure SetTrackingStatus(Value: TOpOlTrackingStatus);
    procedure SetTrackingStatusTime(const Value: TDateTime);
    function GetAddressEntry: AddressEntry;
    procedure SetAddressEntry(const Value: AddressEntry);
  public
    constructor Create(AOwner: TOpRecipientList; Intf: Recipient);
    destructor Destroy; override;
    function Resolve: Boolean;
    property Address: string read GetAddress;
    property AddressEntry: AddressEntry read GetAddressEntry write SetAddressEntry;
    property DisplayType: TOpOlDisplayType read GetDisplayType;
    property EntryID: string read GetEntryID;
    property Index: Integer read GetIndex;
    property Name: string read GetName;
    {: RecipientIntf provides the Outlook Recipient interface associated
       with the instance. }
    property RecipientIntf: Recipient read FIntf;
    property Resolved: Boolean read GetResolved;
    property TrackingStatus: TOpOlTrackingStatus read GetTrackingStatus
      write SetTrackingStatus;
    property TrackingStatusTime: TDateTime read GetTrackingStatusTime
      write SetTrackingStatusTime;
    property RecipientType: TOpOlMailRecipientType read GetRecipientType
      write SetRecipientType;
  end;

  {: TOpRecipient encapsulates the Outlook Recipients interface.  Many Outlook
     item classes surface a Recipients property of this type, enabling you to
     gain access to the recipients of an item. }
  TOpRecipientList = class(TOpMailListProp)
  private
    FIntf: Recipients;
    function GetItems(Index: Integer): TOpRecipient;
  protected
    function GetCount: Integer; override;
  public
    constructor Create(AOwner: TOpOutlookItem; Intf: Recipients);
    function Add(const Name: string): TOpRecipient;
    procedure Remove(Index: Integer);
    function ResolveAll: Boolean;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TOpRecipient read GetItems;
    {: RecipientsIntf provides the Outlook Recipients interface associated
       with the instance. }
    property RecipientsIntf: Recipients read FIntf;
  end;

  {: TOpAttachment encapsulates the Outlook Attachment interface.  Typically,
     you would access instances of this class via a TOpAttachmentList. }
  TOpAttachment = class(TOpMailListItem)
  private
    FOwner: TOpAttachmentList;
    FIntf: Attachment;
    function GetFileName: string;
    function GetPathName: string;
    function GetDisplayName: string;
  public
    constructor Create(AOwner: TOpAttachmentList; Intf: Attachment);
    destructor Destroy; override;
    {: AttachmentIntf provides the Outlook Attachment interface associated
       with the instance. }
    property AttachmentIntf: Attachment read FIntf;
    property DisplayName: string read GetDisplayName;
    property FileName: string read GetFileName;
    property PathName: string read GetPathName;
  end;

  {: TOpAttachmentList encapsulates the Outlook Attachments interface.  Many
     Outlook item classes surface an Attachments property of this type,
     enabling you to gain access to the attachments for a given item. }
  TOpAttachmentList = class(TOpMailListProp)
  private
    FIntf: Attachments;
    function GetItems(Index: Integer): TOpAttachment;
  protected
    function GetCount: Integer; override;
  public
    constructor Create(AOwner: TOpOutlookItem; Intf: Attachments);
    function Add(const FileName: string): TOpAttachment;
    procedure Remove(Index: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TOpAttachment read GetItems;
    {: AttachmentsIntf provides the Outlook Attachments interface associated
       with the instance. }
    property AttachmentsIntf: Attachments read FIntf;
  end;

  {: TOpOutlook encapsulates the main interface to the Outlook application. }
  TOpOutlook = class(TOpOutlookBase)
  private
    FMapiNamespace: NameSpace;
    FNewSession: Boolean;
    FServer: _Application;
    FShowLoginDialog: Boolean;
    FLoggedOn: Boolean;
    FOnItemSend: TItemSendEvent;
    FOnNewMail: TOpOfficeEvent;
    FOnReminder: TReminderEvent;
    FOnOptionsPagesAdd: TOptionsPagesAddEvent;
    FOnStartup: TOpOfficeEvent;
    FOnQuit: TOpOfficeEvent;
    procedure Disconnect;
    function GetName: string;
    function GetVersion: string;
    procedure SetNewSession(Value: Boolean);
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoOnItemSend(const Item: IDispatch; var Cancel: WordBool); dynamic;
    procedure DoOnNewMail; dynamic;
    procedure DoOnReminder(const Item: IDispatch); dynamic;
    procedure DoOnOptionsPagesAdd(const Pages: PropertyPages); dynamic;
    procedure DoOnStartup; dynamic;
    procedure DoOnQuit; dynamic;
    function GetConnected: Boolean; override;
    function GetOfficeVersion: TOpOfficeVersion; override;
  public
    function CreateInstance: _Application;
    {: CreateAppointmentItem creates and returns a new TOpAppointmentItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateAppointmentItem: TOpAppointmentItem;
    {: CreateContactItem creates and returns a new TOpContactItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateContactItem: TOpContactItem;
    function CreateItem(Item: TOpNestedCollectionItem): IDispatch; override;
    {: CreateJournalItem creates and returns a new TOpJournalItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateJournalItem: TOpJournalItem;
    {: CreateMailItem creates and returns a new TOpMailItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateMailItem: TOpMailItem;
    {: CreateNoteItem creates and returns a new TOpNoteItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateNoteItem: TOpNoteItem;
    {: CreatePostItem creates and returns a new TOpPostItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreatePostItem: TOpPostItem;
    {: CreateTaskItem creates and returns a new TOpTaskItem
       instance.  The instance obtained from this method must be disposed of
       using its Free method. }
    function CreateTaskItem: TOpTaskItem;
    procedure GetAppInfo(Info: TStrings); override;
    procedure HandleEvent(const IID: TIID; DispId: Integer; const Params: TVariantArgList); override;
    {: Login logs into Outlook with the specified profile name and password.
       It is normally not necessary to call this method if Outlook is already
       running. }
    procedure Login(const Profile, Password: string);
    {: Logoff logs off of Outlook.  You only need to call this method if you
       wish to log off prior to disconnecting from Outlook, because setting the
       Connected property to False also causes this method to be called. }
    procedure Logoff;
    procedure Quit;
    {: SendMailMessage provides a means for easily sending an Outlook mail
       message with one method call.  The ToAddrs, CcAddrs, BccAddrs parameters
       should contain semicolon-delimited list of respective To, CC, BCC
       recipients.  These can either be internet email addresses or names that
       can be resolved from the Outlook address book.  The MsgSubject parameter
       should contain the subject of the message.  The MsgText parameter holds
       the text of the message.  The MsgAttachments parameter is a list of
       file names that will serve as message attachments.  You may pass nil in
       the MsgAttachments parameters if there are no attachments. }
    procedure SendMailMessage(const ToAddrs, CcAddrs, BccAddrs, MsgSubject: string;
      MsgText, MsgAttachments: TStrings);
    {: The MapiNamespace property contains the Outlook NameSpace interface
       for Outlook's MAPI namespace. }
    property MapiNamespace: NameSpace read FMapiNamespace;
    property Name: string read GetName;
    {: The Server property provides the Outlook's _Application interface should
       you wish to directly manipulate that interface. }
    property Server: _Application read FServer;
    property Version: string read GetVersion;
  published
    property Connected;
    property MachineName;
    {: NewSession dictates whether a new session is started or the existing
       session is used when logging in via the Login metahod. }
    property NewSession: Boolean read FNewSession write SetNewSession;
    property PropDirection;
    {: ShowLoginDialog controls whether a login dialog is display when logging
       in via the Login method. }
    property ShowLoginDialog: Boolean read FShowLoginDialog write FShowLoginDialog;
    //#<Events>
    property OnOpConnect;
    property OnOpDisconnect;
    property OnGetInstance;
    property OnItemSend: TItemSendEvent read FOnItemSend write FOnItemSend;
    property OnNewMail: TOpOfficeEvent read FOnNewMail write FOnNewMail;
    property OnReminder: TReminderEvent read FOnReminder write FOnReminder;
    property OnOptionsPagesAdd: TOptionsPagesAddEvent read FOnOptionsPagesAdd
      write FOnOptionsPagesAdd;
    property OnStartup: TOpOfficeEvent read FOnStartup write FOnStartup;
    property OnQuit: TOpOfficeEvent read FOnQuit write FOnQuit;
    //#</Events>
  end;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
   Windows, ComObj, OpConst;

{ TOpOutlook }

function TOpOutlook.CreateInstance: _Application;
var
  TestName: WideString;
  TestDispID: TDispID;
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}

  // Since Outlook 2000's Appliation coclass has a different GUID than
  // Outlook 98, we first try to create an Outlook 2000 instance.  If that
  // fails, we then try to create an Outlook 98 instance.  Outlook 97 will also
  // respond to this CoCreate, so we must check to make sure we're not
  // talking to Outlook 97.  If all fails, an exception is raised.
  if CoCreate(OpOlkXP.CLASS_Application_, _Application, Result) = S_OK then
    begin
      if Pos('10.', Result.Version) > 0 then                         {!!.63}
        FOfficeVersion := ovXP                                       {!!.63}
      else if Pos('9.', Result.Version) > 0 then                     {!!.63}
        FOfficeVersion := ov2000
      else                                                           {!!.63}
        FOfficeVersion := ovUnknown;                                 {!!.63}
    end
  else if CoCreate(OpOlk98.CLASS_Application_, _Application, Result) = S_OK then
    begin
      TestName := 'Version';
      // "Version" property is unsupported under Outlook 97, so that is the litmus test
      if Result.GetIDsOfNames(GUID_NULL, @TestName, 1, GetThreadLocale,
        @TestDispID) <> S_OK then
        begin
          Result := nil;
          FOfficeVersion := ovUnknown;
          OfficeError(SOl97NotSupported);
        end;
      FOfficeVersion := ov98;
    end
  else begin
    FOfficeVersion := ovUnknown;
    OfficeError(SFailCreateOutlook);
  end;
end;

function TOpOutlook.CreateAppointmentItem: TOpAppointmentItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpAppointmentItem.Create(FServer.CreateItem(Ord(OlitAppointment)) as _AppointmentItem);
end;

function TOpOutlook.CreateContactItem: TOpContactItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpContactItem.Create(FServer.CreateItem(Ord(OlitContact)) as _ContactItem);
end;

function TOpOutlook.CreateItem(Item: TOpNestedCollectionItem): IDispatch;
begin
  Result := nil;
end;

function TOpOutlook.CreateJournalItem: TOpJournalItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpJournalItem.Create(FServer.CreateItem(Ord(OlitJournal)) as _JournalItem);
end;

function TOpOutlook.CreateMailItem: TOpMailItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpMailItem.Create(FServer.CreateItem(Ord(OlitMail)) as _MailItem);
end;

function TOpOutlook.CreateNoteItem: TOpNoteItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpNoteItem.Create(FServer.CreateItem(Ord(OlitNote)) as _NoteItem);
end;

function TOpOutlook.CreatePostItem: TOpPostItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpPostItem.Create(FServer.CreateItem(Ord(OlitPost)) as _PostItem);
end;

function TOpOutlook.CreateTaskItem: TOpTaskItem;
begin
  CheckActive(True, ctMethod);
  Result := TOpTaskItem.Create(FServer.CreateItem(Ord(OlitTask)) as _TaskItem);
end;

procedure TOpOutlook.DoOnItemSend(const Item: IDispatch;
  var Cancel: WordBool);
begin
  if Assigned(FOnItemSend) then FOnItemSend(Item, Cancel);
end;

procedure TOpOutlook.DoOnNewMail;
begin
  if Assigned(FOnNewMail) then FOnNewMail;
end;

procedure TOpOutlook.DoOnOptionsPagesAdd(const Pages: PropertyPages);
begin
  if Assigned(FOnOptionsPagesAdd) then FOnOptionsPagesAdd(Pages);
end;

procedure TOpOutlook.DoOnQuit;
begin
  if Assigned(FOnQuit) then FOnQuit;
end;

procedure TOpOutlook.DoOnReminder(const Item: IDispatch);
begin
  if Assigned(FOnReminder) then FOnReminder(Item);
end;

procedure TOpOutlook.DoOnStartup;
begin
  if Assigned(FOnStartup) then FOnStartup;
end;

procedure TOpOutlook.GetAppInfo(Info: TStrings);
var
  App: _Application;
begin
  if Connected then App := FServer
  else App := CreateInstance;
  Info.Add(SProductEquals + App.Name);
  Info.Add(SVersionEquals + App.Version);
end;

function TOpOutlook.GetConnected: Boolean;
begin
  Result := FServer <> nil;
end;

function TOpOutlook.GetName: string;
begin
  CheckActive(True, ctProperty);
  Result := FServer.Name;
end;

function TOpOutlook.GetVersion: string;
begin
  CheckActive(True, ctProperty);
  Result := FServer.Version;
end;

procedure TOpOutlook.HandleEvent(const IID: TIID; DispId: Integer;
  const Params: TVariantArgList);
begin
  if IsEqualGUID(IID, ApplicationEvents) then
  begin
    case DispId of
      61442: DoOnItemSend(IDispatch(Params[0].dispVal), Params[1].pBool^);
      61443: DoOnNewMail;
      61444: DoOnReminder(IDispatch(Params[0].dispVal));
      61445: DoOnOptionsPagesAdd(PropertyPages(Params[0].dispVal));
      61446: DoOnStartup;
      61447: DoOnQuit;
    end;
  end;
end;

procedure TOpOutlook.Quit;
begin
  CheckActive(True, ctMethod);
  FServer.Quit;
end;

procedure TOpOutlook.SetNewSession(Value: Boolean);
begin
  if FNewSession <> Value then
  begin
    if Connected then
      OfficeError(SCantSetWhileConnected);
    FNewSession := Value;
  end;
end;

procedure TOpOutlook.Login(const Profile, Password: string);
begin
  CheckActive(True, ctMethod);
  FMapiNamespace.Logon(Profile, Password, FShowLoginDialog, FNewSession);
  FLoggedOn := True;
end;

procedure TOpOutlook.Logoff;
begin
  CheckActive(True, ctMethod);
  FMapiNamespace.Logoff;
  FLoggedOn := False;
end;

procedure TOpOutlook.Disconnect;
begin
  Events.Free;
  FMapiNamespace := nil;
  FServer := nil;
end;

procedure TOpOutlook.SendMailMessage(const ToAddrs, CcAddrs, BccAddrs,
  MsgSubject: string; MsgText, MsgAttachments: TStrings);
var
  Mail: TOpMailItem;
  I: Integer;
begin
  CheckActive(True, ctMethod);
  Mail := CreateMailItem;
  try
    with Mail do
    begin
      if ToAddrs <> '' then MsgTo := ToAddrs;
      if CcAddrs <> '' then MsgCc := CcAddrs;
      if BccAddrs <> '' then MsgBcc := BccAddrs;
      if MsgSubject <> '' then Subject := MsgSubject;
      if MsgText <> nil then Body := MsgText.Text;
      if MsgAttachments <> nil then
        for I := 0 to MsgAttachments.Count - 1 do
          Attachments.Add(MsgAttachments[I]);
      if not Recipients.ResolveAll then
        OfficeError(SFailedToResolveRecipients);
      Send;
    end;
  finally
    Mail.Free;
  end;
end;

procedure TOpOutlook.DoConnect;
begin
  try
    FServer := CreateInstance;
    FMapiNameSpace := FServer.GetNamespace('MAPI');
    if FMapiNameSpace = nil then
      OfficeError(SFailFindMapiNamespace);
    // Appliation events are only supported in Oulook 2000 and Outlook 2002
    if OfficeVersion >= ov2000 then                                   {!!.64}
      CreateEvents(FServer, ApplicationEvents);
  except
    if FLoggedOn then Logoff;
    Disconnect;
    raise;
  end;
end;

procedure TOpOutlook.DoDisconnect;
begin
  Disconnect;
end;

function TOpOutlook.GetOfficeVersion: TOpOfficeVersion;
begin
  Result := FOfficeVersion;
end;

{ TOpAppointmentItem }

constructor TOpAppointmentItem.Create(ApptItem: _AppointmentItem);
begin
  inherited Create;
  FAppointmentItem := ApptItem;
  FAttachments := TOpAttachmentList.Create(Self, ApptItem.Attachments);
  FRecipients := TOpRecipientList.Create(Self, ApptItem.Recipients);
end;

destructor TOpAppointmentItem.Destroy;
begin
  FAttachments.Free;
  FRecipients.Free;
  inherited Destroy;
end;

procedure TOpAppointmentItem.ClearRecurrencePattern;
begin
  FAppointmentItem.ClearRecurrencePattern;
end;

procedure TOpAppointmentItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FAppointmentItem.Close(Ord(SaveMode));
end;

function TOpAppointmentItem.Copy: TOpAppointmentItem;
begin
  Result := TOpAppointmentItem.Create(FAppointmentItem.Copy as _AppointmentItem);
end;

procedure TOpAppointmentItem.Delete;
begin
  FAppointmentItem.Delete;
end;

procedure TOpAppointmentItem.Display(Modal: Boolean);
begin
  FAppointmentItem.Display(Modal);
end;

function TOpAppointmentItem.ForwardAsVcal: TOpMailItem;
begin
  Result := TOpMailItem.Create(FAppointmentItem.ForwardAsVcal as _MailItem);
end;

function TOpAppointmentItem.GetAllDayEvent: Boolean;
begin
  Result := FAppointmentItem.AllDayEvent;
end;

function TOpAppointmentItem.GetBillingInformation: string;
begin
  Result := FAppointmentItem.BillingInformation;
end;

function TOpAppointmentItem.GetBody: string;
begin
  Result := FAppointmentItem.Body;
end;

function TOpAppointmentItem.GetBusyStatus: TOpOlBusyStatus;
begin
  Result := TOpOlBusyStatus(FAppointmentItem.BusyStatus);
end;

function TOpAppointmentItem.GetCategories: string;
begin
  Result := FAppointmentItem.Categories;
end;

function TOpAppointmentItem.GetCompanies: string;
begin
  Result := FAppointmentItem.Companies;
end;

function TOpAppointmentItem.GetConversationIndex: string;
begin
  Result := FAppointmentItem.ConversationIndex;
end;

function TOpAppointmentItem.GetConversationTopic: string;
begin
  Result := FAppointmentItem.ConversationTopic;
end;

function TOpAppointmentItem.GetCreationTime: TDateTime;
begin
  Result := FAppointmentItem.CreationTime;
end;

function TOpAppointmentItem.GetDuration: Integer;
begin
  Result := FAppointmentItem.Duration;
end;

function TOpAppointmentItem.GetEnd_: TDateTime;
begin
  Result := FAppointmentItem.End_;
end;

function TOpAppointmentItem.GetEntryID: string;
begin
  Result := FAppointmentItem.EntryID;
end;

function TOpAppointmentItem.GetFormDescription: FormDescription;
begin
  Result := FAppointmentItem.FormDescription;
end;

function TOpAppointmentItem.GetImportance: TOpOlImportance;
begin
  Result := TOpOlImportance(FAppointmentItem.Importance);
end;

function TOpAppointmentItem.GetInspector: Inspector;
begin
  Result := FAppointmentItem.GetInspector;
end;

function TOpAppointmentItem.GetIsOnlineMeeting: Boolean;
begin
  Result := FAppointmentItem.IsOnlineMeeting;
end;

function TOpAppointmentItem.GetIsRecurring: Boolean;
begin
  Result := FAppointmentItem.IsRecurring;
end;

function TOpAppointmentItem.GetLastModificationTime: TDateTime;
begin
  Result := FAppointmentItem.LastModificationTime;
end;

function TOpAppointmentItem.GetLocation: string;
begin
  Result := FAppointmentItem.Location;
end;

function TOpAppointmentItem.GetMeetingStatus: TOpOlMeetingStatus;
begin
  Result := TOpOlMeetingStatus(FAppointmentItem.MeetingStatus);
end;

function TOpAppointmentItem.GetMessageClass: string;
begin
  Result := FAppointmentItem.MessageClass;
end;

function TOpAppointmentItem.GetMileage: string;
begin
  Result := FAppointmentItem.Mileage;
end;

function TOpAppointmentItem.GetNetMeetingAutoStart: Boolean;
begin
  Result := FAppointmentItem.NetMeetingAutoStart;
end;

function TOpAppointmentItem.GetNetMeetingOrganizerAlias: string;
begin
  Result := FAppointmentItem.NetMeetingOrganizerAlias;
end;

function TOpAppointmentItem.GetNetMeetingServer: string;
begin
  Result := FAppointmentItem.NetMeetingServer;
end;

function TOpAppointmentItem.GetNetMeetingType: TOpOlNetMeetingType;
begin
  Result := TOpOlNetMeetingType(FAppointmentItem.NetMeetingType);
end;

function TOpAppointmentItem.GetNoAging: Boolean;
begin
  Result := FAppointmentItem.NoAging;
end;

function TOpAppointmentItem.GetOptionalAttendees: string;
begin
  Result := FAppointmentItem.OptionalAttendees;
end;

function TOpAppointmentItem.GetOrganizer: string;
begin
  Result := FAppointmentItem.Organizer;
end;

function TOpAppointmentItem.GetOutlookInternalVersion: Integer;
begin
  Result := FAppointmentItem.OutlookInternalVersion;
end;

function TOpAppointmentItem.GetOutlookVersion: string;
begin
  Result := FAppointmentItem.OutlookVersion;
end;

function TOpAppointmentItem.GetRecurrencePattern: RecurrencePattern;
begin
  Result := FAppointmentItem.GetRecurrencePattern;
end;

function TOpAppointmentItem.GetRecurrenceState: TOpOlRecurrenceState;
begin
  Result := TOpOlRecurrenceState(FAppointmentItem.RecurrenceState);
end;

function TOpAppointmentItem.GetReminderMinutesBeforeStart: Integer;
begin
  Result := FAppointmentItem.ReminderMinutesBeforeStart;
end;

function TOpAppointmentItem.GetReminderOverrideDefault: Boolean;
begin
  Result := FAppointmentItem.ReminderOverrideDefault;
end;

function TOpAppointmentItem.GetReminderPlaySound: Boolean;
begin
  Result := FAppointmentItem.ReminderPlaySound;
end;

function TOpAppointmentItem.GetReminderSet: Boolean;
begin
  Result := FAppointmentItem.ReminderSet;
end;

function TOpAppointmentItem.GetReminderSoundFile: string;
begin
  Result := FAppointmentItem.ReminderSoundFile;
end;

function TOpAppointmentItem.GetReplyTime: TDateTime;
begin
  Result := FAppointmentItem.ReplyTime;
end;

function TOpAppointmentItem.GetRequiredAttendees: string;
begin
  Result := FAppointmentItem.RequiredAttendees;
end;

function TOpAppointmentItem.GetResources: string;
begin
  Result := FAppointmentItem.Resources;
end;

function TOpAppointmentItem.GetResponseRequested: Boolean;
begin
  Result := FAppointmentItem.ResponseRequested;
end;

function TOpAppointmentItem.GetResponseStatus: TOpOlResponseStatus;
begin
  Result := TOpOlResponseStatus(FAppointmentItem.ResponseStatus);
end;

function TOpAppointmentItem.GetSaved: Boolean;
begin
  Result := FAppointmentItem.Saved;
end;

function TOpAppointmentItem.GetSensitivity: TOpOlSensitivity;
begin
  Result := TOpOlSensitivity(FAppointmentItem.Sensitivity);
end;

function TOpAppointmentItem.GetSize: Integer;
begin
  Result := FAppointmentItem.Size;
end;

function TOpAppointmentItem.GetStart: TDateTime;
begin
  Result := FAppointmentItem.Start;
end;

function TOpAppointmentItem.GetSubject: string;
begin
  Result := FAppointmentItem.Subject;
end;

function TOpAppointmentItem.GetUnRead: Boolean;
begin
  Result := FAppointmentItem.UnRead;
end;

procedure TOpAppointmentItem.PrintOut;
begin
  FAppointmentItem.PrintOut;
end;

function TOpAppointmentItem.Respond(Response: TOpOlMeetingResponse; NoUI,
  AdditionalTextDialog: Boolean): MeetingItem;
const
  EnumToOrd: array[TOpOlMeetingResponse] of Cardinal = ($2, $3, $4);
begin
  Result := FAppointmentItem.Respond(EnumToOrd[Response], NoUI, AdditionalTextDialog);
end;

procedure TOpAppointmentItem.Save;
begin
  FAppointmentItem.Save;
end;

procedure TOpAppointmentItem.Send;
begin
  FAppointmentItem.Send;
end;

procedure TOpAppointmentItem.SetAllDayEvent(Value: Boolean);
begin
  FAppointmentItem.AllDayEvent := Value;
end;

procedure TOpAppointmentItem.SetBillingInformation(const Value: string);
begin
  FAppointmentItem.BillingInformation := Value;
end;

procedure TOpAppointmentItem.SetBody(const Value: string);
begin
  FAppointmentItem.Body := Value;
end;

procedure TOpAppointmentItem.SetBusyStatus(Value: TOpOlBusyStatus);
begin
  FAppointmentItem.BusyStatus := Ord(Value);
end;

procedure TOpAppointmentItem.SetCategories(const Value: string);
begin
  FAppointmentItem.Categories := Value;
end;

procedure TOpAppointmentItem.SetCompanies(const Value: string);
begin
  FAppointmentItem.Companies := Value;
end;

procedure TOpAppointmentItem.SetDuration(Value: Integer);
begin
  FAppointmentItem.Duration := Value;
end;

procedure TOpAppointmentItem.SetEnd_(const Value: TDateTime);
begin
  FAppointmentItem.End_ := Value;
end;

procedure TOpAppointmentItem.SetImportance(Value: TOpOlImportance);
begin
  FAppointmentItem.Importance := Ord(Value);
end;

procedure TOpAppointmentItem.SetIsOnlineMeeting(Value: Boolean);
begin
  FAppointmentItem.IsOnlineMeeting := Value;
end;

procedure TOpAppointmentItem.SetLocation(const Value: string);
begin
  FAppointmentItem.Location := Value;
end;

procedure TOpAppointmentItem.SetMeetingStatus(Value: TOpOlMeetingStatus);
begin
  FAppointmentItem.MeetingStatus := Ord(Value);
end;

procedure TOpAppointmentItem.SetMessageClass(const Value: string);
begin
  FAppointmentItem.MessageClass := Value;
end;

procedure TOpAppointmentItem.SetMileage(const Value: string);
begin
  FAppointmentItem.Mileage := Value;
end;

procedure TOpAppointmentItem.SetNetMeetingAutoStart(Value: Boolean);
begin
  FAppointmentItem.NetMeetingAutoStart := Value;
end;

procedure TOpAppointmentItem.SetNetMeetingOrganizerAlias(const Value: string);
begin
  FAppointmentItem.NetMeetingOrganizerAlias := Value;
end;

procedure TOpAppointmentItem.SetNetMeetingServer(const Value: string);
begin
  FAppointmentItem.NetMeetingServer := Value;
end;

procedure TOpAppointmentItem.SetNetMeetingType(Value: TOpOlNetMeetingType);
begin
  FAppointmentItem.NetMeetingType := Ord(Value);
end;

procedure TOpAppointmentItem.SetNoAging(Value: Boolean);
begin
  FAppointmentItem.NoAging := Value;
end;

procedure TOpAppointmentItem.SetOptionalAttendees(const Value: string);
begin
  FAppointmentItem.OptionalAttendees := Value;
end;

procedure TOpAppointmentItem.SetReminderMinutesBeforeStart(Value: Integer);
begin
  FAppointmentItem.ReminderMinutesBeforeStart := Value;
end;

procedure TOpAppointmentItem.SetReminderOverrideDefault(Value: Boolean);
begin
  FAppointmentItem.ReminderOverrideDefault := Value;
end;

procedure TOpAppointmentItem.SetReminderPlaySound(Value: Boolean);
begin
  FAppointmentItem.ReminderPlaySound := Value;
end;

procedure TOpAppointmentItem.SetReminderSet(Value: Boolean);
begin
  FAppointmentItem.ReminderSet := Value;
end;

procedure TOpAppointmentItem.SetReminderSoundFile(const Value: string);
begin
  FAppointmentItem.ReminderSoundFile := Value;
end;

procedure TOpAppointmentItem.SetReplyTime(const Value: TDateTime);
begin
  FAppointmentItem.ReplyTime := Value;
end;

procedure TOpAppointmentItem.SetRequiredAttendees(const Value: string);
begin
  FAppointmentItem.RequiredAttendees := Value;
end;

procedure TOpAppointmentItem.SetResources(const Value: string);
begin
  FAppointmentItem.Resources := Value;
end;

procedure TOpAppointmentItem.SetResponseRequested(Value: Boolean);
begin
  FAppointmentItem.ResponseRequested := Value;
end;

procedure TOpAppointmentItem.SetSensitivity(Value: TOpOlSensitivity);
begin
  FAppointmentItem.Sensitivity := Ord(Value);
end;

procedure TOpAppointmentItem.SetStart(const Value: TDateTime);
begin
  FAppointmentItem.Start := Value;
end;

procedure TOpAppointmentItem.SetSubject(const Value: string);
begin
  FAppointmentItem.Subject := Value;
end;

procedure TOpAppointmentItem.SetUnRead(Value: Boolean);
begin
  FAppointmentItem.UnRead := Value;
end;

procedure TOpAppointmentItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FAppointmentItem.SaveAs(Path, Ord(SaveAsType));
end;

{ TOpContactItem }

constructor TOpContactItem.Create(AContactItem: _ContactItem);
begin
  inherited Create;
  FContactItem := AContactItem;
end;

procedure TOpContactItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FContactItem.Close(Ord(SaveMode));
end;

function TOpContactItem.Copy: IDispatch;
begin
  Result := FContactItem.Copy;
end;

procedure TOpContactItem.Delete;
begin
  FContactItem.Delete;
end;

procedure TOpContactItem.Display(Modal: Boolean);
begin
  FContactItem.Display(Modal);
end;

function TOpContactItem.ForwardAsVcard: TOpMailItem;
begin
  Result := TOpMailItem.Create(FContactItem.ForwardAsVCard);
end;

function TOpContactItem.GetAccount: string;
begin
  Result := FContactItem.Account;
end;

function TOpContactItem.GetAnniversary: TDateTime;
begin
  Result := FContactItem.Anniversary;
end;

function TOpContactItem.GetAssistantName: string;
begin
  Result := FContactItem.AssistantName;
end;

function TOpContactItem.GetAssistantTelephoneNumber: string;
begin
  Result := FContactItem.AssistantTelephoneNumber;
end;

function TOpContactItem.GetBillingInformation: string;
begin
  Result := FContactItem.BillingInformation;
end;

function TOpContactItem.GetBirthday: TDateTime;
begin
  Result := FContactItem.Birthday;
end;

function TOpContactItem.GetBusiness2TelephoneNumber: string;
begin
  Result := FContactItem.Business2TelephoneNumber;
end;

function TOpContactItem.GetBusinessAddress: string;
begin
  Result := FContactItem.BusinessAddress;
end;

function TOpContactItem.GetBusinessAddressCity: string;
begin
  Result := FContactItem.BusinessAddressCity;
end;

function TOpContactItem.GetBusinessAddressCountry: string;
begin
  Result := FContactItem.BusinessAddressCountry;
end;

function TOpContactItem.GetBusinessAddressPostalCode: string;
begin
  Result := FContactItem.BusinessAddressPostalCode;
end;

function TOpContactItem.GetBusinessAddressPostOfficeBox: string;
begin
  Result := FContactItem.BusinessAddressPostOfficeBox;
end;

function TOpContactItem.GetBusinessAddressState: string;
begin
  Result := FContactItem.BusinessAddressState;
end;

function TOpContactItem.GetBusinessAddressStreet: string;
begin
  Result := FContactItem.BusinessAddressStreet;
end;

function TOpContactItem.GetBusinessFaxNumber: string;
begin
  Result := FContactItem.BusinessFaxNumber;

end;

function TOpContactItem.GetBusinessHomePage: string;
begin
  Result := FContactItem.BusinessHomePage;
end;

function TOpContactItem.GetBusinessTelephoneNumber: string;
begin
  Result := FContactItem.BusinessTelephoneNumber;
end;

function TOpContactItem.GetCallbackTelephoneNumber: string;
begin
  Result := FContactItem.CallbackTelephoneNumber;
end;

function TOpContactItem.GetCarTelephoneNumber: string;
begin
  Result := FContactItem.CarTelephoneNumber;
end;

function TOpContactItem.GetCategories: string;
begin
  Result := FContactItem.Categories;
end;

function TOpContactItem.GetChildren: string;
begin
  Result := FContactItem.Children;
end;

function TOpContactItem.GetCompanies: string;
begin
  Result := FContactItem.Companies;
end;

function TOpContactItem.GetCompanyAndFullName: string;
begin
  Result := FContactItem.CompanyAndFullName;
end;

function TOpContactItem.GetCompanyLastFirstNoSpace: string;
begin
  Result := FContactItem.CompanyLastFirstNoSpace;
end;

function TOpContactItem.GetCompanyLastFirstSpaceOnly: string;
begin
  Result := FContactItem.CompanyLastFirstSpaceOnly;
end;

function TOpContactItem.GetCompanyMainTelephoneNumber: string;
begin
  Result := FContactItem.CompanyMainTelephoneNumber;
end;

function TOpContactItem.GetCompanyName: string;
begin
  Result := FContactItem.CompanyName;
end;

function TOpContactItem.GetComputerNetworkName: string;
begin
  Result := FContactItem.ComputerNetworkName;
end;

function TOpContactItem.GetCreationTime: TDateTime;
begin
  Result := FContactItem.CreationTime;
end;

function TOpContactItem.GetCustomerID: string;
begin
  Result := FContactItem.CustomerID;
end;

function TOpContactItem.GetDepartment: string;
begin
  Result := FContactItem.Department;
end;

function TOpContactItem.GetEmail1Address: string;
begin
  Result := FContactItem.Email1Address;
end;

function TOpContactItem.GetEmail1AddressType: string;
begin
  Result := FContactItem.Email1AddressType;
end;

function TOpContactItem.GetEmail1DisplayName: string;
begin
  Result := FContactItem.Email1DisplayName;
end;

function TOpContactItem.GetEmail1EntryID: string;
begin
  Result := FContactItem.Email1EntryID;
end;

function TOpContactItem.GetEmail2Address: string;
begin
  Result := FContactItem.Email2Address;
end;

function TOpContactItem.GetEmail2AddressType: string;
begin
  Result := FContactItem.Email2AddressType;
end;

function TOpContactItem.GetEmail2DisplayName: string;
begin
  Result := FContactItem.Email2DisplayName;
end;

function TOpContactItem.GetEmail2EntryID: string;
begin
  Result := FContactItem.Email2EntryID;
end;

function TOpContactItem.GetEmail3Address: string;
begin
  Result := FContactItem.Email3Address;
end;

function TOpContactItem.GetEmail3AddressType: string;
begin
  Result := FContactItem.Email3AddressType;
end;

function TOpContactItem.GetEmail3DisplayName: string;
begin
  Result := FContactItem.Email3DisplayName;
end;

function TOpContactItem.GetEmail3EntryID: string;
begin
  Result := FContactItem.Email3EntryID;
end;

function TOpContactItem.GetEntryID: string;
begin
  Result := FContactItem.EntryID;
end;

function TOpContactItem.GetFileAs: string;
begin
  Result := FContactItem.FileAs;
end;

function TOpContactItem.GetFirstName: string;
begin
  Result := FContactItem.FirstName;
end;

function TOpContactItem.GetFTPSite: string;
begin
  Result := FContactItem.FTPSite;
end;

function TOpContactItem.GetFullName: string;
begin
  Result := FContactItem.FullName;
end;

function TOpContactItem.GetFullNameAndCompany: string;
begin
  Result := FContactItem.FullNameAndCompany;
end;

function TOpContactItem.GetGender: TOpOlGender;
begin
  Result := TOpOlGender(FContactItem.Gender);
end;

function TOpContactItem.GetInspector: Inspector;
begin
  Result := FContactItem.GetInspector;
end;

function TOpContactItem.GetGovernmentIDNumber: string;
begin
  Result := FContactItem.GovernmentIDNumber;
end;

function TOpContactItem.GetHobby: string;
begin
  Result := FContactItem.Hobby;
end;

function TOpContactItem.GetHome2TelephoneNumber: string;
begin
  Result := FContactItem.Home2TelephoneNumber;
end;

function TOpContactItem.GetHomeAddress: string;
begin
  Result := FContactItem.HomeAddress;
end;

function TOpContactItem.GetHomeAddressCity: string;
begin
  Result := FContactItem.HomeAddressCity;
end;

function TOpContactItem.GetHomeAddressCountry: string;
begin
  Result := FContactItem.HomeAddressCountry;
end;

function TOpContactItem.GetHomeAddressPostalCode: string;
begin
  Result := FContactItem.HomeAddressPostalCode;
end;

function TOpContactItem.GetHomeAddressPostOfficeBox: string;
begin
  Result := FContactItem.HomeAddressPostOfficeBox;
end;

function TOpContactItem.GetHomeAddressState: string;
begin
  Result := FContactItem.HomeAddressState;
end;

function TOpContactItem.GetHomeAddressStreet: string;
begin
  Result := FContactItem.HomeAddressStreet;
end;

function TOpContactItem.GetHomeFaxNumber: string;
begin
  Result := FContactItem.HomeFaxNumber;
end;

function TOpContactItem.GetHomeTelephoneNumber: string;
begin
  Result := FContactItem.HomeTelephoneNumber;
end;

function TOpContactItem.GetImportance: OlImportance;
begin
  Result := FContactItem.Importance;
end;

function TOpContactItem.GetInitials: string;
begin
  Result := FContactItem.Initials;
end;

function TOpContactItem.GetInternetFreeBusyAddress: string;
begin
  Result := FContactItem.InternetFreeBusyAddress;
end;

function TOpContactItem.GetISDNNumber: string;
begin
  Result := FContactItem.ISDNNumber;
end;

function TOpContactItem.GetJobTitle: string;
begin
  Result := FContactItem.JobTitle;
end;

function TOpContactItem.GetJournal: Boolean;
begin
  Result := FContactItem.Journal;
end;

function TOpContactItem.GetLanguage: string;
begin
  Result := FContactItem.Language;
end;

function TOpContactItem.GetLastFirstAndSuffix: string;
begin
  Result := FContactItem.LastFirstAndSuffix;
end;

function TOpContactItem.GetLastFirstNoSpace: string;
begin
  Result := FContactItem.LastFirstNoSpace;
end;

function TOpContactItem.GetLastFirstNoSpaceCompany: string;
begin
  Result := FContactItem.LastFirstNoSpaceCompany;
end;

function TOpContactItem.GetLastFirstSpaceOnly: string;
begin
  Result := FContactItem.LastFirstSpaceOnly;
end;

function TOpContactItem.GetLastFirstSpaceOnlyCompany: string;
begin
  Result := FContactItem.LastFirstSpaceOnlyCompany;
end;

function TOpContactItem.GetLastModificationTime: TDateTime;
begin
  Result := FContactItem.LastModificationTime;
end;

function TOpContactItem.GetLastName: string;
begin
  Result := FContactItem.LastName;
end;

function TOpContactItem.GetLastNameAndFirstName: string;
begin
  Result := FContactItem.LastNameAndFirstName;
end;

function TOpContactItem.GetMailingAddress: string;
begin
  Result := FContactItem.MailingAddress;
end;

function TOpContactItem.GetMailingAddressCity: string;
begin
  Result := FContactItem.MailingAddressCity;
end;

function TOpContactItem.GetMailingAddressCountry: string;
begin
  Result := FContactItem.MailingAddressCountry;
end;

function TOpContactItem.GetMailingAddressPostalCode: string;
begin
  Result := FContactItem.MailingAddressPostalCode;
end;

function TOpContactItem.GetMailingAddressPostOfficeBox: string;
begin
  Result := FContactItem.MailingAddressPostOfficeBox;
end;

function TOpContactItem.GetMailingAddressState: string;
begin
  Result := FContactItem.MailingAddressState;
end;

function TOpContactItem.GetMailingAddressStreet: string;
begin
  Result := FContactItem.MailingAddressStreet;
end;

function TOpContactItem.GetManagerName: string;
begin
  Result := FContactItem.ManagerName;
end;

function TOpContactItem.GetMiddleName: string;
begin
  Result := FContactItem.MiddleName;
end;

function TOpContactItem.GetMobileTelephoneNumber: string;
begin
  Result := FContactItem.MobileTelephoneNumber;
end;

function TOpContactItem.GetNetMeetingAlias: string;
begin
  Result := FContactItem.NetMeetingAlias;
end;

function TOpContactItem.GetNetMeetingServer: string;
begin
  Result := FContactItem.NetMeetingServer;
end;

function TOpContactItem.GetNickName: string;
begin
  Result := FContactItem.NickName;
end;

function TOpContactItem.GetNoAging: Boolean;
begin
  Result := FContactItem.NoAging;
end;

function TOpContactItem.GetOfficeLocation: string;
begin
  Result := FContactItem.OfficeLocation;
end;

function TOpContactItem.GetOrganizationalIDNumber: string;
begin
  Result := FContactItem.OrganizationalIDNumber;
end;

function TOpContactItem.GetOtherAddress: string;
begin
  Result := FContactItem.OtherAddress;
end;

function TOpContactItem.GetOtherAddressCity: string;
begin
  Result := FContactItem.OtherAddressCity;
end;

function TOpContactItem.GetOtherAddressCountry: string;
begin
  Result := FContactItem.OtherAddressCountry;
end;

function TOpContactItem.GetOtherAddressPostalCode: string;
begin
  Result := FContactItem.OtherAddressPostalCode;
end;

function TOpContactItem.GetOtherAddressPostOfficeBox: string;
begin
  Result := FContactItem.OtherAddressPostOfficeBox;
end;

function TOpContactItem.GetOtherAddressState: string;
begin
  Result := FContactItem.OtherAddressState;
end;

function TOpContactItem.GetOtherAddressStreet: string;
begin
  Result := FContactItem.OtherAddressStreet;
end;

function TOpContactItem.GetOtherFaxNumber: string;
begin
  Result := FContactItem.OtherFaxNumber;
end;

function TOpContactItem.GetOtherTelephoneNumber: string;
begin
  Result := FContactItem.OtherTelephoneNumber;
end;

function TOpContactItem.GetPagerNumber: string;
begin
  Result := FContactItem.PagerNumber;
end;

function TOpContactItem.GetPersonalHomePage: string;
begin
  Result := FContactItem.PersonalHomePage;
end;

function TOpContactItem.GetPrimaryTelephoneNumber: string;
begin
  Result := FContactItem.PrimaryTelephoneNumber;
end;

function TOpContactItem.GetProfession: string;
begin
  Result := FContactItem.Profession;
end;

function TOpContactItem.GetRadioTelephoneNumber: string;
begin
  Result := FContactItem.RadioTelephoneNumber;
end;

function TOpContactItem.GetReferredBy: string;
begin
  Result := FContactItem.ReferredBy;
end;

function TOpContactItem.GetSaved: Boolean;
begin
  Result := FContactItem.Saved
end;

function TOpContactItem.GetSelectedMailingAddress: TOpOlMailingAddress;
begin
  Result := TOpOlMailingAddress(FContactItem.SelectedMailingAddress);
end;

function TOpContactItem.GetSize: Integer;
begin
  Result := FContactItem.Size;
end;

function TOpContactItem.GetSpouse: string;
begin
  Result := FContactItem.Spouse;
end;

function TOpContactItem.GetSuffix: string;
begin
  Result := FContactItem.Suffix;
end;

function TOpContactItem.GetTelexNumber: string;
begin
  Result := FContactItem.TelexNumber;
end;

function TOpContactItem.GetTitle: string;
begin
  Result := FContactItem.Title;
end;

function TOpContactItem.GetTTYTDDTelephoneNumber: string;
begin
  Result := FContactItem.TTYTDDTelephoneNumber;
end;

function TOpContactItem.GetUser1: string;
begin
  Result := FContactItem.User1;
end;

function TOpContactItem.GetUser2: string;
begin
  Result := FContactItem.User2;
end;

function TOpContactItem.GetUser3: string;
begin
  Result := FContactItem.User3;
end;

function TOpContactItem.GetUser4: string;
begin
  Result := FContactItem.User4;
end;

function TOpContactItem.GetUserCertificate: string;
begin
  Result := FContactItem.UserCertificate;
end;

function TOpContactItem.GetUserProperties: UserProperties;
begin
  Result := FContactItem.UserProperties;
end;

function TOpContactItem.GetWebPage: string;
begin
  Result := FContactItem.WebPage;
end;

function TOpContactItem.GetYomiCompanyName: string;
begin
  Result := FContactItem.YomiCompanyName;
end;

function TOpContactItem.GetYomiFirstName: string;
begin
  Result := FContactItem.YomiFirstName;
end;

function TOpContactItem.GetYomiLastName: string;
begin
  Result := FContactItem.YomiLastName;
end;

function TOpContactItem.Move(const DestFldr: MAPIFolder): IDispatch;
begin
  Result := FContactItem.Move(DestFldr);
end;

procedure TOpContactItem.PrintOut;
begin
  FContactItem.PrintOut;
end;

procedure TOpContactItem.Save;
begin
  FContactItem.Save;
end;

procedure TOpContactItem.SetAccount(const Value: string);
begin
  FContactItem.Account := Value;
end;

procedure TOpContactItem.SetAnniversary(const Value: TDateTime);
begin
  FContactItem.Anniversary := Value;
end;

procedure TOpContactItem.SetAssistantName(const Value: string);
begin
  FContactItem.AssistantName := Value;
end;

procedure TOpContactItem.SetAssistantTelephoneNumber(const Value: string);
begin
  FContactItem.AssistantTelephoneNumber := Value;
end;

procedure TOpContactItem.SetBillingInformation(const Value: string);
begin
  FContactItem.BillingInformation := Value;
end;

procedure TOpContactItem.SetBirthday(const Value: TDateTime);
begin
  FContactItem.Birthday := Value;
end;

procedure TOpContactItem.SetBusiness2TelephoneNumber(const Value: string);
begin
  FContactItem.Business2TelephoneNumber := Value;
end;

procedure TOpContactItem.SetBusinessAddress(const Value: string);
begin
  FContactItem.BusinessAddress := Value;
end;

procedure TOpContactItem.SetBusinessAddressCity(const Value: string);
begin
  FContactItem.BusinessAddressCity := Value;
end;

procedure TOpContactItem.SetBusinessAddressCountry(const Value: string);
begin
  FContactItem.BusinessAddressCountry := Value;
end;

procedure TOpContactItem.SetBusinessAddressPostalCode(const Value: string);
begin
  FContactItem.BusinessAddressPostalCode := Value;
end;

procedure TOpContactItem.SetBusinessAddressPostOfficeBox(
  const Value: string);
begin
  FContactItem.BusinessAddressPostOfficeBox := Value;
end;

procedure TOpContactItem.SetBusinessAddressState(const Value: string);
begin
  FContactItem.BusinessAddressState := Value;
end;

procedure TOpContactItem.SetBusinessAddressStreet(const Value: string);
begin
  FContactItem.BusinessAddressStreet := Value;
end;

procedure TOpContactItem.SetBusinessFaxNumber(const Value: string);
begin
  FContactItem.BusinessFaxNumber := Value;
end;

procedure TOpContactItem.SetBusinessHomePage(const Value: string);
begin
  FContactItem.BusinessHomePage := Value;
end;

procedure TOpContactItem.SetBusinessTelephoneNumber(const Value: string);
begin
  FContactItem.BusinessTelephoneNumber := Value;
end;

procedure TOpContactItem.SetCallbackTelephoneNumber(const Value: string);
begin
  FContactItem.CallbackTelephoneNumber := Value;
end;

procedure TOpContactItem.SetCarTelephoneNumber(const Value: string);
begin
  FContactItem.CarTelephoneNumber := Value;
end;

procedure TOpContactItem.SetCategories(const Value: string);
begin
  FContactItem.Categories := Value;
end;

procedure TOpContactItem.SetChildren(const Value: string);
begin
  FContactItem.Children := Value;
end;

procedure TOpContactItem.SetCompanies(const Value: string);
begin
  FContactItem.Companies := Value;
end;

procedure TOpContactItem.SetCompanyMainTelephoneNumber(
  const Value: string);
begin
  FContactItem.CompanyMainTelephoneNumber := Value;
end;

procedure TOpContactItem.SetCompanyName(const Value: string);
begin
  FContactItem.CompanyName := Value;
end;

procedure TOpContactItem.SetComputerNetworkName(const Value: string);
begin
  FContactItem.ComputerNetworkName := Value;
end;

procedure TOpContactItem.SetCustomerID(const Value: string);
begin
  FContactItem.CustomerID := Value;
end;

procedure TOpContactItem.SetDepartment(const Value: string);
begin
  FContactItem.Department := Value;
end;

procedure TOpContactItem.SetEmail1Address(const Value: string);
begin
  FContactItem.Email1Address := Value;
end;

procedure TOpContactItem.SetEmail1AddressType(const Value: string);
begin
  FContactItem.Email1AddressType := Value;
end;

procedure TOpContactItem.SetEmail2Address(const Value: string);
begin
  FContactItem.Email2Address := Value;
end;

procedure TOpContactItem.SetEmail2AddressType(const Value: string);
begin
  FContactItem.Email2AddressType := Value;
end;

procedure TOpContactItem.SetEmail3Address(const Value: string);
begin
  FContactItem.Email3Address := Value;
end;

procedure TOpContactItem.SetEmail3AddressType(const Value: string);
begin
  FContactItem.Email3AddressType := Value;
end;

procedure TOpContactItem.SetFileAs(const Value: string);
begin
  FContactItem.FileAs := Value;
end;

procedure TOpContactItem.SetFirstName(const Value: string);
begin
  FContactItem.FirstName := Value;
end;

procedure TOpContactItem.SetFTPSite(const Value: string);
begin
  FContactItem.FTPSite := Value;
end;

procedure TOpContactItem.SetFullName(const Value: string);
begin
  FContactItem.FullName := Value;
end;

procedure TOpContactItem.SetGender(Value: TOpOlGender);
begin
  FContactItem.Gender := Ord(Value);
end;

procedure TOpContactItem.SetGovernmentIDNumber(const Value: string);
begin
  FContactItem.GovernmentIDNumber := Value;
end;

procedure TOpContactItem.SetHobby(const Value: string);
begin
  FContactItem.Hobby := Value;
end;

procedure TOpContactItem.SetHome2TelephoneNumber(const Value: string);
begin
  FContactItem.Home2TelephoneNumber := Value;
end;

procedure TOpContactItem.SetHomeAddress(const Value: string);
begin
  FContactItem.HomeAddress := Value;
end;

procedure TOpContactItem.SetHomeAddressCity(const Value: string);
begin
  FContactItem.HomeAddressCity := Value;
end;

procedure TOpContactItem.SetHomeAddressCountry(const Value: string);
begin
  FContactItem.HomeAddressCountry := Value;
end;

procedure TOpContactItem.SetHomeAddressPostalCode(const Value: string);
begin
  FContactItem.HomeAddressPostalCode := Value;
end;

procedure TOpContactItem.SetHomeAddressPostOfficeBox(const Value: string);
begin
  FContactItem.HomeAddressPostOfficeBox := Value;
end;

procedure TOpContactItem.SetHomeAddressState(const Value: string);
begin
  FContactItem.HomeAddressState := Value;
end;

procedure TOpContactItem.SetHomeAddressStreet(const Value: string);
begin
  FContactItem.HomeAddressStreet := Value;
end;

procedure TOpContactItem.SetHomeFaxNumber(const Value: string);
begin
  FContactItem.HomeFaxNumber := Value;
end;

procedure TOpContactItem.SetHomeTelephoneNumber(const Value: string);
begin
  FContactItem.HomeTelephoneNumber := Value;
end;

procedure TOpContactItem.SetImportance(Value: OlImportance);
begin
  FContactItem.Importance := Value;
end;

procedure TOpContactItem.SetInitials(const Value: string);
begin
  FContactItem.Initials := Value;
end;

procedure TOpContactItem.SetInternetFreeBusyAddress(const Value: string);
begin
  FContactItem.InternetFreeBusyAddress := Value;
end;

procedure TOpContactItem.SetISDNNumber(const Value: string);
begin
  FContactItem.ISDNNumber := Value;
end;

procedure TOpContactItem.SetJobTitle(const Value: string);
begin
  FContactItem.JobTitle := Value;
end;

procedure TOpContactItem.SetJournal(Value: Boolean);
begin
  FContactItem.Journal := Value;
end;

procedure TOpContactItem.SetLanguage(const Value: string);
begin
  FContactItem.Language := Value;
end;

procedure TOpContactItem.SetLastName(const Value: string);
begin
  FContactItem.LastName := Value;
end;

procedure TOpContactItem.SetMailingAddress(const Value: string);
begin
  FContactItem.MailingAddress := Value;
end;

procedure TOpContactItem.SetMailingAddressCity(const Value: string);
begin
  FContactItem.MailingAddressCity := Value;
end;

procedure TOpContactItem.SetMailingAddressCountry(const Value: string);
begin
  FContactItem.MailingAddressCountry := Value;
end;

procedure TOpContactItem.SetMailingAddressPostalCode(const Value: string);
begin
  FContactItem.MailingAddressPostalCode := Value;
end;

procedure TOpContactItem.SetMailingAddressPostOfficeBox(
  const Value: string);
begin
  FContactItem.MailingAddressPostOfficeBox := Value;
end;

procedure TOpContactItem.SetMailingAddressState(const Value: string);
begin
  FContactItem.MailingAddressState := Value;
end;

procedure TOpContactItem.SetMailingAddressStreet(const Value: string);
begin
  FContactItem.MailingAddressStreet := Value;
end;

procedure TOpContactItem.SetManagerName(const Value: string);
begin
  FContactItem.ManagerName := Value;
end;

procedure TOpContactItem.SetMiddleName(const Value: string);
begin
  FContactItem.MiddleName := Value;
end;

procedure TOpContactItem.SetMobileTelephoneNumber(const Value: string);
begin
  FContactItem.MobileTelephoneNumber := Value;
end;

procedure TOpContactItem.SetNetMeetingAlias(const Value: string);
begin
  FContactItem.NetMeetingAlias := Value;
end;

procedure TOpContactItem.SetNetMeetingServer(const Value: string);
begin
  FContactItem.NetMeetingServer := Value;
end;

procedure TOpContactItem.SetNickName(const Value: string);
begin
  FContactItem.NickName := Value;
end;

procedure TOpContactItem.SetNoAging(Value: Boolean);
begin
  FContactItem.NoAging := Value;
end;

procedure TOpContactItem.SetOfficeLocation(const Value: string);
begin
  FContactItem.OfficeLocation := Value;
end;

procedure TOpContactItem.SetOrganizationalIDNumber(const Value: string);
begin
  FContactItem.OrganizationalIDNumber := Value;
end;

procedure TOpContactItem.SetOtherAddress(const Value: string);
begin
  FContactItem.OtherAddress := Value;
end;

procedure TOpContactItem.SetOtherAddressCity(const Value: string);
begin
  FContactItem.OtherAddressCity := Value;
end;

procedure TOpContactItem.SetOtherAddressCountry(const Value: string);
begin
  FContactItem.OtherAddressCountry := Value;
end;

procedure TOpContactItem.SetOtherAddressPostalCode(const Value: string);
begin
  FContactItem.OtherAddressPostalCode := Value;
end;

procedure TOpContactItem.SetOtherAddressPostOfficeBox(const Value: string);
begin
  FContactItem.OtherAddressPostOfficeBox := Value;
end;

procedure TOpContactItem.SetOtherAddressState(const Value: string);
begin
  FContactItem.OtherAddressState := Value;
end;

procedure TOpContactItem.SetOtherAddressStreet(const Value: string);
begin
  FContactItem.OtherAddressStreet := Value;
end;

procedure TOpContactItem.SetOtherFaxNumber(const Value: string);
begin
  FContactItem.OtherFaxNumber := Value;
end;

procedure TOpContactItem.SetOtherTelephoneNumber(const Value: string);
begin
  FContactItem.OtherTelephoneNumber := Value;
end;

procedure TOpContactItem.SetPagerNumber(const Value: string);
begin
  FContactItem.PagerNumber := Value;
end;

procedure TOpContactItem.SetPersonalHomePage(const Value: string);
begin
  FContactItem.PersonalHomePage := Value;
end;

procedure TOpContactItem.SetPrimaryTelephoneNumber(const Value: string);
begin
  FContactItem.PrimaryTelephoneNumber := Value;
end;

procedure TOpContactItem.SetProfession(const Value: string);
begin
   FContactItem.Profession := Value;
end;

procedure TOpContactItem.SetRadioTelephoneNumber(const Value: string);
begin
  FContactItem.RadioTelephoneNumber := Value;
end;

procedure TOpContactItem.SetReferredBy(const Value: string);
begin
  FContactItem.ReferredBy := Value;
end;

procedure TOpContactItem.SetSelectedMailingAddress(Value: TOpOlMailingAddress);
begin
  FContactItem.SelectedMailingAddress := Ord(Value);
end;

procedure TOpContactItem.SetSpouse(const Value: string);
begin
  FContactItem.Spouse := Value;
end;

procedure TOpContactItem.SetSuffix(const Value: string);
begin
  FContactItem.Suffix := Value;
end;

procedure TOpContactItem.SetTelexNumber(const Value: string);
begin
  FContactItem.TelexNumber := Value;
end;

procedure TOpContactItem.SetTitle(const Value: string);
begin
  FContactItem.Title := Value;
end;

procedure TOpContactItem.SetTTYTDDTelephoneNumber(const Value: string);
begin
  FContactItem.TTYTDDTelephoneNumber := Value;
end;

procedure TOpContactItem.SetUser1(const Value: string);
begin
  FContactItem.User1 := Value;
end;

procedure TOpContactItem.SetUser2(const Value: string);
begin
  FContactItem.User2 := Value;
end;

procedure TOpContactItem.SetUser3(const Value: string);
begin
  FContactItem.User3 := Value;
end;

procedure TOpContactItem.SetUser4(const Value: string);
begin
  FContactItem.User4 := Value;
end;

procedure TOpContactItem.SetUserCertificate(const Value: string);
begin
  FContactItem.UserCertificate := Value;
end;

procedure TOpContactItem.SetWebPage(const Value: string);
begin
  FContactItem.WebPage := Value;
end;

procedure TOpContactItem.SetYomiCompanyName(const Value: string);
begin
  FContactItem.YomiCompanyName := Value;
end;

procedure TOpContactItem.SetYomiFirstName(const Value: string);
begin
  FContactItem.YomiFirstName := Value;
end;

procedure TOpContactItem.SetYomiLastName(const Value: string);
begin
  FContactItem.YomiLastName := Value;
end;

procedure TOpContactItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FContactItem.SaveAs(Path, Ord(SaveAsType));
end;

{ TOpNoteItem }

constructor TOpNoteItem.Create(ANoteItem: _NoteItem);
begin
  inherited Create;
  FNoteItem := ANoteItem;
end;

procedure TOpNoteItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FNoteItem.Close(Ord(SaveMode));
end;

function TOpNoteItem.Copy: TOpNoteItem;
begin
  Result := TOpNoteItem.Create(FNoteItem.Copy as _NoteItem);
end;

procedure TOpNoteItem.Delete;
begin
  FNoteItem.Delete;
end;

procedure TOpNoteItem.Display(Modal: Boolean);
begin
  FNoteItem.Display(Modal);
end;

function TOpNoteItem.GetBody: string;
begin
  Result := FNoteItem.Body;
end;

function TOpNoteItem.GetCategories: string;
begin
  Result := FNoteItem.Categories;
end;

function TOpNoteItem.GetColor: TOpOlNoteColor;
begin
  Result := TOpOlNoteColor(FNoteItem.Color);
end;

function TOpNoteItem.GetCreationTime: TDateTime;
begin
  Result := FNoteItem.CreationTime;
end;

function TOpNoteItem.GetEntryID: string;
begin
  Result := FNoteItem.EntryID;
end;

function TOpNoteItem.GetHeight: Integer;
begin
  Result := FNoteItem.Height;
end;

function TOpNoteItem.GetLastModificationTime: TDateTime;
begin
  Result := FNoteItem.LastModificationTime;
end;

function TOpNoteItem.GetLeft: Integer;
begin
  Result := FNoteItem.Left;
end;

function TOpNoteItem.GetMessageClass: string;
begin
  Result := FNoteItem.MessageClass;
end;

function TOpNoteItem.GetSaved: Boolean;
begin
  Result := FNoteItem.Saved;
end;

function TOpNoteItem.GetSize: Integer;
begin
  Result := FNoteItem.Size;
end;

function TOpNoteItem.GetSubject: string;
begin
  Result := FNoteItem.Subject;
end;

function TOpNoteItem.GetTop: Integer;
begin
  Result := FNoteItem.Top;
end;

function TOpNoteItem.GetWidth: Integer;
begin
  Result := FNoteItem.Width;
end;

procedure TOpNoteItem.PrintOut;
begin
  FNoteItem.PrintOut;
end;

procedure TOpNoteItem.Save;
begin
  FNoteItem.Save;
end;

procedure TOpNoteItem.SetBody(const Value: string);
begin
  FNoteItem.Body := Value;
end;

procedure TOpNoteItem.SetCategories(const Value: string);
begin
  FNoteItem.Categories := Value;
end;

procedure TOpNoteItem.SetColor(const Value: TOpOlNoteColor);
begin
  FNoteItem.Color := Ord(Value);
end;

procedure TOpNoteItem.SetHeight(Value: Integer);
begin
  FNoteItem.Height := Value;
end;

procedure TOpNoteItem.SetLeft(Value: Integer);
begin
  FNoteItem.Left := Value;
end;

procedure TOpNoteItem.SetMessageClass(const Value: string);
begin
  FNoteItem.MessageClass := Value;
end;

procedure TOpNoteItem.SetTop(Value: Integer);
begin
  FNoteItem.Top := Value;
end;

procedure TOpNoteItem.SetWidth(Value: Integer);
begin
  FNoteItem.Width := Value;
end;

procedure TOpNoteItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FNoteItem.SaveAs(Path, Ord(SaveAsType));
end;

{ TOpPostItem }

constructor TOpPostItem.Create(APostItem: _PostItem);
begin
  inherited Create;
  FPostItem := APostItem;
  FAttachments := TOpAttachmentList.Create(Self, APostItem.Get_Attachments);
end;

destructor TOpPostItem.Destroy;
begin
  FAttachments.Free;
  inherited Destroy;
end;

procedure TOpPostItem.ClearConversationIndex;
begin
  FPostItem.ClearConversationIndex;
end;

procedure TOpPostItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FPostItem.Close(Ord(SaveMode));
end;

function TOpPostItem.Copy: TOpPostItem;
begin
  Result := TOpPostItem.Create(FPostItem.Copy as _PostItem);
end;

procedure TOpPostItem.Delete;
begin
  FPostItem.Delete;
end;

procedure TOpPostItem.Display(Modal: Boolean);
begin
  FPostItem.Display(Modal);
end;

function TOpPostItem.Forward: TOpMailItem;
begin
  Result := TOpMailItem.Create(FPostItem.Forward as _MailItem);
end;

function TOpPostItem.GetBillingInformation: string;
begin
  Result := FPostItem.BillingInformation;
end;

function TOpPostItem.GetBody: string;
begin
  Result := FPostItem.Body;
end;

function TOpPostItem.GetCategories: string;
begin
  Result := FPostItem.Categories;
end;

function TOpPostItem.GetCompanies: string;
begin
  Result := FPostItem.Companies;
end;

function TOpPostItem.GetConversationIndex: string;
begin
  Result := FPostItem.ConversationIndex;
end;

function TOpPostItem.GetConversationTopic: string;
begin
  Result := FPostItem.ConversationTopic;
end;

function TOpPostItem.GetCreationTime: TDateTime;
begin
  Result := FPostItem.CreationTime;
end;

function TOpPostItem.GetEntryID: string;
begin
  Result := FPostItem.EntryID;
end;

function TOpPostItem.GetExpiryTime: TDateTime;
begin
  Result := FPostItem.ExpiryTime;
end;

function TOpPostItem.GetHTMLBody: string;
begin
  Result := FPostItem.HTMLBody;
end;

function TOpPostItem.GetImportance: TOpOlImportance;
begin
  Result := TOpOlImportance(FPostItem.Importance);
end;

function TOpPostItem.GetInspector: Inspector;
begin
  Result := FPostItem.GetInspector;
end;

function TOpPostItem.GetLastModificationTime: TDateTime;
begin
  Result := FPostItem.LastModificationTime;
end;

function TOpPostItem.GetMessageClass: string;
begin
  Result := FPostItem.MessageClass;
end;

function TOpPostItem.GetMileage: string;
begin
  Result := FPostItem.Mileage;
end;

function TOpPostItem.GetNoAging: Boolean;
begin
  Result := FPostItem.NoAging;
end;

function TOpPostItem.GetOutlookInternalVersion: Integer;
begin
  Result := FPostItem.OutlookInternalVersion;
end;

function TOpPostItem.GetOutlookVersion: string;
begin
  Result := FPostItem.OutlookVersion;
end;

function TOpPostItem.GetReceivedTime: TDateTime;
begin
  Result := FPostItem.ReceivedTime;
end;

function TOpPostItem.GetSaved: Boolean;
begin
  Result := FPostItem.Saved;
end;

function TOpPostItem.GetSenderName: string;
begin
  Result := FPostItem.SenderName;
end;

function TOpPostItem.GetSensitivity: TOpOlSensitivity;
begin
  Result := TOpOlSensitivity(FPostItem.Sensitivity);
end;

function TOpPostItem.GetSentOn: TDateTime;
begin
  Result := FPostItem.SentOn;
end;

function TOpPostItem.GetSize: Integer;
begin
  Result := FPostItem.Size;
end;

function TOpPostItem.GetSubject: string;
begin
  Result := FPostItem.Subject;
end;

function TOpPostItem.GetUnRead: Boolean;
begin
  Result := FPostItem.UnRead;
end;

procedure TOpPostItem.Post;
begin
  FPostItem.Post;
end;

procedure TOpPostItem.PrintOut;
begin
  FPostItem.PrintOut;
end;

function TOpPostItem.Reply: TOpMailItem;
begin
  Result := TOpMailItem.Create(FPostItem.Reply as _MailItem);
end;

procedure TOpPostItem.Save;
begin
  FPostItem.Save;
end;

procedure TOpPostItem.SetBillingInformation(const Value: string);
begin
  FPostItem.BillingInformation := Value;
end;

procedure TOpPostItem.SetBody(const Value: string);
begin
  FPostItem.Body := Value;
end;

procedure TOpPostItem.SetCategories(const Value: string);
begin
  FPostItem.Categories := Value;
end;

procedure TOpPostItem.SetCompanies(const Value: string);
begin
  FPostItem.Companies := Value;
end;

procedure TOpPostItem.SetExpiryTime(const Value: TDateTime);
begin
  FPostItem.ExpiryTime := Value;
end;

procedure TOpPostItem.SetHTMLBody(const Value: string);
begin
  FPostItem.HTMLBody := Value;
end;

procedure TOpPostItem.SetImportance(Value: TOpOlImportance);
begin
  FPostItem.Importance := Ord(Value);
end;

procedure TOpPostItem.SetMessageClass(const Value: string);
begin
  FPostItem.MessageClass := Value;
end;

procedure TOpPostItem.SetMileage(const Value: string);
begin
  FPostItem.Mileage := Value;
end;

procedure TOpPostItem.SetNoAging(Value: Boolean);
begin
  FPostItem.NoAging := Value;
end;

procedure TOpPostItem.SetSensitivity(Value: TOpOlSensitivity);
begin
  FPostItem.Sensitivity := Ord(Value);
end;

procedure TOpPostItem.SetSubject(const Value: string);
begin
  FPostItem.Subject := Value;
end;

procedure TOpPostItem.SetUnRead(Value: Boolean);
begin
  FPostItem.UnRead := Value;
end;

procedure TOpPostItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FPostItem.SaveAs(Path, Ord(SaveAsType));
end;

{ TOpJournalItem }

procedure TOpJournalItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FJournalItem.Close(Ord(SaveMode));
end;

function TOpJournalItem.Copy: TOpJournalItem;
begin
  Result := TOpJournalItem.Create(FJournalItem.Copy as _JournalItem);
end;

constructor TOpJournalItem.Create(AJournalItem: _JournalItem);
begin
  inherited Create;
  FJournalItem := AJournalItem;
  FAttachments := TOpAttachmentList.Create(Self, AJournalItem.Get_Attachments);
end;

{!!.62}
destructor TOpJournalItem.Destroy;
begin
  FAttachments.Free;
  inherited Destroy;
end;

procedure TOpJournalItem.Delete;
begin
  FJournalItem.Delete;
end;

procedure TOpJournalItem.Display(Modal: Boolean);
begin
  FJournalItem.Display(Modal);
end;

function TOpJournalItem.Forward: TOpMailItem;
begin
  Result := TOpMailItem.Create(FJournalItem.Forward);
end;

function TOpJournalItem.GetBillingInformation: string;
begin
  Result := FJournalItem.BillingInformation;
end;

function TOpJournalItem.GetBody: string;
begin
  Result := FJournalItem.Body;
end;

function TOpJournalItem.GetCategories: string;
begin
  Result := FJournalItem.Categories;
end;

function TOpJournalItem.GetCompanies: string;
begin
  Result := FJournalItem.Companies;
end;

function TOpJournalItem.GetContactNames: string;
begin
  Result := FJournalItem.ContactNames;
end;

function TOpJournalItem.GetConversationIndex: string;
begin
  Result := FJournalItem.ConversationIndex;
end;

function TOpJournalItem.GetConversationTopic: string;
begin
  Result := FJournalItem.ConversationTopic;
end;

function TOpJournalItem.GetCreationTime: TDateTime;
begin
  Result := FJournalItem.CreationTime;
end;

function TOpJournalItem.GetDocPosted: Boolean;
begin
  Result := FJournalItem.DocPosted;
end;

function TOpJournalItem.GetDocPrinted: Boolean;
begin
  Result := FJournalItem.DocPrinted;
end;

function TOpJournalItem.GetDocRouted: Boolean;
begin
  Result := FJournalItem.DocRouted;
end;

function TOpJournalItem.GetDocSaved: Boolean;
begin
  Result := FJournalItem.DocSaved;
end;

function TOpJournalItem.GetDuration: Integer;
begin
  Result := FJournalItem.Duration;
end;

function TOpJournalItem.GetEnd_: TDateTime;
begin
  Result := FJournalItem.End_;
end;

function TOpJournalItem.GetEntryID: string;
begin
  Result := FJournalItem.EntryID;
end;

function TOpJournalItem.GetImportance: TOpOlImportance;
begin
  Result := TOpOlImportance(FJournalItem.Importance);
end;

function TOpJournalItem.GetInspector: Inspector;
begin
  Result := FJournalItem.GetInspector;
end;

function TOpJournalItem.GetLastModificationTime: TDateTime;
begin
  Result := FJournalItem.LastModificationTime;
end;

function TOpJournalItem.GetMessageClass: string;
begin
  Result := FJournalItem.MessageClass;
end;

function TOpJournalItem.GetMileage: string;
begin
  Result := FJournalItem.Mileage;
end;

function TOpJournalItem.GetNoAging: Boolean;
begin
  Result := FJournalItem.NoAging;
end;

function TOpJournalItem.GetOutlookInternalVersion: Integer;
begin
  Result := FJournalItem.OutlookInternalVersion;
end;

function TOpJournalItem.GetOutlookVersion: string;
begin
  Result := FJournalItem.OutlookVersion;
end;

function TOpJournalItem.GetSaved: Boolean;
begin
  Result := FJournalItem.Saved;
end;

function TOpJournalItem.GetSensitivity: TOpOlSensitivity;
begin
  Result := TOpOlSensitivity(FJournalItem.Sensitivity);
end;

function TOpJournalItem.GetSize: Integer;
begin
  Result := FJournalItem.Size;
end;

function TOpJournalItem.GetStart: TDateTime;
begin
  Result := FJournalItem.Start;
end;

function TOpJournalItem.GetSubject: string;
begin
  Result := FJournalItem.Subject;
end;

function TOpJournalItem.GetType_: string;
begin
  Result := FJournalItem.Type_;
end;

function TOpJournalItem.GetUnRead: Boolean;
begin
  Result := FJournalItem.UnRead;
end;

procedure TOpJournalItem.PrintOut;
begin
  FJournalItem.PrintOut;
end;

function TOpJournalItem.Reply: TOpMailItem;
begin
  Result := TOpMailItem.Create(FJournalItem.Reply);
end;

function TOpJournalItem.ReplyAll: TOpMailItem;
begin
  Result := TOpMailItem.Create(FJournalItem.ReplyAll);
end;

procedure TOpJournalItem.Save;
begin
  FJournalItem.Save;
end;

procedure TOpJournalItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FJournalItem.SaveAs(Path, Ord(SaveAsType));
end;

procedure TOpJournalItem.SetBillingInformation(const Value: string);
begin
  FJournalItem.BillingInformation := Value;
end;

procedure TOpJournalItem.SetBody(const Value: string);
begin
  FJournalItem.Body := Value;
end;

procedure TOpJournalItem.SetCategories(const Value: string);
begin
  FJournalItem.Categories := Value;
end;

procedure TOpJournalItem.SetCompanies(const Value: string);
begin
  FJournalItem.Companies := Value;
end;

procedure TOpJournalItem.SetContactNames(const Value: string);
begin
  FJournalItem.ContactNames := Value;
end;

procedure TOpJournalItem.SetDocPosted(Value: Boolean);
begin
  FJournalItem.DocPosted := Value;
end;

procedure TOpJournalItem.SetDocPrinted(Value: Boolean);
begin
  FJournalItem.DocPrinted := Value;
end;

procedure TOpJournalItem.SetDocRouted(Value: Boolean);
begin
  FJournalItem.DocRouted := Value;
end;

procedure TOpJournalItem.SetDocSaved(Value: Boolean);
begin
  FJournalItem.DocSaved := Value;
end;

procedure TOpJournalItem.SetDuration(Value: Integer);
begin
  FJournalItem.Duration := Value;
end;

procedure TOpJournalItem.SetEnd_(const Value: TDateTime);
begin
  FJournalItem.End_ := Value;
end;

procedure TOpJournalItem.SetImportance(Value: TOpOlImportance);
begin
  FJournalItem.Importance := Ord(Value);
end;

procedure TOpJournalItem.SetMessageClass(const Value: string);
begin
  FJournalItem.MessageClass := Value;
end;

procedure TOpJournalItem.SetMileage(const Value: string);
begin
  FJournalItem.Mileage := Value;
end;

procedure TOpJournalItem.SetNoAging(Value: Boolean);
begin
  FJournalItem.NoAging := Value;
end;

procedure TOpJournalItem.SetSensitivity(Value: TOpOlSensitivity);
begin
  FJournalItem.Sensitivity := Ord(Value);
end;

procedure TOpJournalItem.SetStart(const Value: TDateTime);
begin
  FJournalItem.Start := Value;
end;

procedure TOpJournalItem.SetSubject(const Value: string);
begin
  FJournalItem.Subject := Value;
end;

procedure TOpJournalItem.SetType_(const Value: string);
begin
  FJournalItem.Type_ := Value;
end;

procedure TOpJournalItem.SetUnRead(Value: Boolean);
begin
  FJournalItem.UnRead := Value;
end;

procedure TOpJournalItem.StartTimer;
begin
  FJournalItem.StartTimer;
end;

procedure TOpJournalItem.StopTimer;
begin
  FJournalItem.StopTimer;
end;

{ TOpTaskItem }

constructor TOpTaskItem.Create(ATaskItem: _TaskItem);
begin
  inherited Create;
  FTaskItem := ATaskItem;
  FAttachments := TOpAttachmentList.Create(Self, ATaskItem.Attachments);
  FRecipients := TOpRecipientList.Create(Self, ATaskItem.Recipients);
end;

destructor TOpTaskItem.Destroy;
begin
  FAttachments.Free;
  FRecipients.Free;
  inherited Destroy;
end;

function TOpTaskItem.Assign: TOpTaskItem;
begin
  Result := TOpTaskItem.Create(FTaskItem.Assign);             
end;

procedure TOpTaskItem.CancelResponseState;
begin
  FTaskItem.CancelResponseState;
end;

procedure TOpTaskItem.ClearRecurrencePattern;
begin
  FTaskItem.ClearRecurrencePattern;
end;

procedure TOpTaskItem.Close(SaveMode: TOpOlInspectorClose);
begin
  FTaskItem.Close(Ord(SaveMode));
end;

function TOpTaskItem.Copy: TOpTaskItem;
begin
  Result := TOpTaskItem.Create(FTaskItem.Copy as _TaskItem);
end;

procedure TOpTaskItem.Delete;
begin
  FTaskItem.Delete;
end;

procedure TOpTaskItem.Display(Modal: Boolean);
begin
  FTaskItem.Display(Modal);
end;

function TOpTaskItem.GetActualWork: Integer;
begin
  Result := FTaskItem.ActualWork;
end;

function TOpTaskItem.GetBillingInformation: string;
begin
  Result := FTaskItem.BillingInformation;
end;

function TOpTaskItem.GetBody: string;
begin
  Result := FTaskItem.Body;
end;

function TOpTaskItem.GetCardData: string;
begin
  Result := FTaskItem.CardData;
end;

function TOpTaskItem.GetCategories: string;
begin
  Result := FTaskItem.Categories;
end;

function TOpTaskItem.GetCompanies: string;
begin
  Result := FTaskItem.Companies;
end;

function TOpTaskItem.GetComplete: Boolean;
begin
  Result := FTaskItem.Complete;
end;

function TOpTaskItem.GetContactNames: string;
begin
  Result := FTaskItem.ContactNames;
end;

function TOpTaskItem.GetContacts: string;
begin
  Result := FTaskItem.Contacts;
end;

function TOpTaskItem.GetConversationIndex: string;
begin
  Result := FTaskItem.ConversationIndex;
end;

function TOpTaskItem.GetConversationTopic: string;
begin
  Result := FTaskItem.ConversationTopic;
end;

function TOpTaskItem.GetCreationTime: TDateTime;
begin
  Result := FTaskItem.CreationTime;
end;

function TOpTaskItem.GetDateCompleted: TDateTime;
begin
  Result := FTaskItem.DateCompleted;
end;

function TOpTaskItem.GetDelegationState: TOpOlTaskDelegationState;
begin
  Result := TOpOlTaskDelegationState(FTaskItem.DelegationState);
end;

function TOpTaskItem.GetDelegator: string;
begin
  Result := FTaskItem.Delegator;
end;

function TOpTaskItem.GetDueDate: TDateTime;
begin
  Result := FTaskItem.DueDate;
end;

function TOpTaskItem.GetEntryID: string;
begin
  Result := FTaskItem.EntryID;
end;

function TOpTaskItem.GetInspector: Inspector;
begin
  Result := FTaskItem.GetInspector;
end;

function TOpTaskItem.GetImportance: TOpOlImportance;
begin
  Result := TOpOlImportance(FTaskItem.Importance);
end;

function TOpTaskItem.GetIsRecurring: Boolean;
begin
  Result := FTaskItem.IsRecurring;
end;

function TOpTaskItem.GetLastModificationTime: TDateTime;
begin
  Result := FTaskItem.LastModificationTime;
end;

function TOpTaskItem.GetMessageClass: string;
begin
  Result := FTaskItem.MessageClass;
end;

function TOpTaskItem.GetMileage: string;
begin
  Result := FTaskItem.Mileage;
end;

function TOpTaskItem.GetNoAging: Boolean;
begin
  Result := FTaskItem.NoAging;
end;

function TOpTaskItem.GetOrdinal: Integer;
begin
  Result := FTaskItem.Ordinal;
end;

function TOpTaskItem.GetOutlookInternalVersion: Integer;
begin
  Result := FTaskItem.OutlookInternalVersion;
end;

function TOpTaskItem.GetOutlookVersion: string;
begin
  Result := FTaskItem.OutlookVersion;
end;

function TOpTaskItem.GetOwner: string;
begin
  Result := FTaskItem.Owner;
end;

function TOpTaskItem.GetOwnership: TOpOlTaskOwnership;
begin
  Result := TOpOlTaskOwnership(FTaskItem.Ownership);
end;

function TOpTaskItem.GetPercentComplete: Integer;
begin
  Result := FTaskItem.PercentComplete;
end;

function TOpTaskItem.GetRecurrencePattern: RecurrencePattern;
begin
  Result := FTaskItem.GetRecurrencePattern;
end;

function TOpTaskItem.GetReminderOverrideDefault: Boolean;
begin
  Result := FTaskItem.ReminderOverrideDefault;
end;

function TOpTaskItem.GetReminderPlaySound: Boolean;
begin
  Result := FTaskItem.ReminderPlaySound;
end;

function TOpTaskItem.GetReminderSet: Boolean;
begin
  Result := FTaskItem.ReminderSet;
end;

function TOpTaskItem.GetReminderSoundFile: string;
begin
  Result := FTaskItem.ReminderSoundFile;
end;

function TOpTaskItem.GetReminderTime: TDateTime;
begin
  Result := FTaskItem.ReminderTime;
end;

function TOpTaskItem.GetResponseState: TOpOlTaskResponse;
begin
  Result := TOpOlTaskResponse(FTaskItem.ResponseState);
end;

function TOpTaskItem.GetRole: string;
begin
  Result := FTaskItem.Role;
end;

function TOpTaskItem.GetSaved: Boolean;
begin
  Result := FTaskItem.Saved;
end;

function TOpTaskItem.GetSchedulePlusPriority: string;
begin
  Result := FTaskItem.SchedulePlusPriority;
end;

function TOpTaskItem.GetSensitivity: TOpOlSensitivity;
begin
  Result := TOpOlSensitivity(FTaskItem.Sensitivity);
end;

function TOpTaskItem.GetSize: Integer;
begin
  Result := FTaskItem.Size;
end;

function TOpTaskItem.GetStartDate: TDateTime;
begin
  Result := FTaskItem.StartDate;
end;

function TOpTaskItem.GetStatus: TOpOlTaskStatus;
begin
  Result := TOpOlTaskStatus(FTaskItem.Status);
end;

function TOpTaskItem.GetStatusOnCompletionRecipients: string;
begin
  Result := FTaskItem.StatusOnCompletionRecipients;
end;

function TOpTaskItem.GetStatusUpdateRecipients: string;
begin
  Result := FTaskItem.StatusUpdateRecipients;
end;

function TOpTaskItem.GetSubject: string;
begin
  Result := FTaskItem.Subject;
end;

function TOpTaskItem.GetTeamTask: Boolean;
begin
  Result := FTaskItem.TeamTask;
end;

function TOpTaskItem.GetTotalWork: Integer;
begin
  Result := FTaskItem.TotalWork;
end;

function TOpTaskItem.GetUnRead: Boolean;
begin
  Result := FTaskItem.UnRead;
end;

procedure TOpTaskItem.MarkComplete;
begin
  FTaskItem.MarkComplete;
end;

procedure TOpTaskItem.PrintOut;
begin
  FTaskItem.PrintOut;
end;

function TOpTaskItem.Respond(Response: TOpOlTaskResponse; NoUI,
  AdditionalTextDialog: Boolean): TOpTaskItem;
begin
  Result := TOpTaskItem.Create(FTaskItem.Respond(Ord(Response), NoUI,
    AdditionalTextDialog));
end;

procedure TOpTaskItem.Save;
begin
  FTaskItem.Save;
end;

procedure TOpTaskItem.Send;
begin
  FTaskItem.Send;
end;

procedure TOpTaskItem.SetActualWork(Value: Integer);
begin
  FTaskItem.ActualWork := Value;
end;

procedure TOpTaskItem.SetBillingInformation(const Value: string);
begin
  FTaskItem.BillingInformation := Value;
end;

procedure TOpTaskItem.SetBody(const Value: string);
begin
  FTaskItem.Body := Value;
end;

procedure TOpTaskItem.SetCardData(const Value: string);
begin
  FTaskItem.CardData := Value;
end;

procedure TOpTaskItem.SetCategories(const Value: string);
begin
  FTaskItem.Categories := Value;
end;

procedure TOpTaskItem.SetCompanies(const Value: string);
begin
  FTaskItem.Companies := Value;
end;

procedure TOpTaskItem.SetComplete(Value: Boolean);
begin
  FTaskItem.Complete := Value;
end;

procedure TOpTaskItem.SetContactNames(const Value: string);
begin
  FTaskItem.ContactNames := Value;
end;

procedure TOpTaskItem.SetContacts(const Value: string);
begin
  FTaskItem.Contacts := Value;
end;

procedure TOpTaskItem.SetDateCompleted(const Value: TDateTime);
begin
  FTaskItem.DateCompleted := Value;
end;

procedure TOpTaskItem.SetDueDate(const Value: TDateTime);
begin
  FTaskItem.DueDate := Value;
end;

procedure TOpTaskItem.SetImportance(Value: TOpOlImportance);
begin
  FTaskItem.Importance := Ord(Value);
end;

procedure TOpTaskItem.SetMessageClass(const Value: string);
begin
  FTaskItem.MessageClass := Value;
end;

procedure TOpTaskItem.SetMileage(const Value: string);
begin
  FTaskItem.Mileage := Value;
end;

procedure TOpTaskItem.SetNoAging(Value: Boolean);
begin
  FTaskItem.NoAging := Value;
end;

procedure TOpTaskItem.SetOrdinal(Value: Integer);
begin
  FTaskItem.Ordinal := Value;
end;

procedure TOpTaskItem.SetOwner(const Value: string);
begin
  FTaskItem.Owner := Value;
end;

procedure TOpTaskItem.SetPercentComplete(Value: Integer);
begin
  FTaskItem.PercentComplete := Value;
end;

procedure TOpTaskItem.SetReminderOverrideDefault(Value: Boolean);
begin
  FTaskItem.ReminderOverrideDefault := Value;
end;

procedure TOpTaskItem.SetReminderPlaySound(Value: Boolean);
begin
  FTaskItem.ReminderPlaySound := Value;
end;

procedure TOpTaskItem.SetReminderSet(Value: Boolean);
begin
  FTaskItem.ReminderSet := Value;
end;

procedure TOpTaskItem.SetReminderSoundFile(const Value: string);
begin
  FTaskItem.ReminderSoundFile := Value;
end;

procedure TOpTaskItem.SetReminderTime(const Value: TDateTime);
begin
  FTaskItem.ReminderTime := Value;
end;

procedure TOpTaskItem.SetRole(const Value: string);
begin
  FTaskItem.Role := Value;
end;

procedure TOpTaskItem.SetSchedulePlusPriority(const Value: string);
begin
  FTaskItem.SchedulePlusPriority := Value;
end;

procedure TOpTaskItem.SetSensitivity(Value: TOpOlSensitivity);
begin
  FTaskItem.Sensitivity := Ord(Value);
end;

procedure TOpTaskItem.SetStartDate(const Value: TDateTime);
begin
  FTaskItem.StartDate := Value;
end;

procedure TOpTaskItem.SetStatus(Value: TOpOlTaskStatus);
begin
  FTaskItem.Status := Ord(Value);
end;

procedure TOpTaskItem.SetStatusOnCompletionRecipients(const Value: string);
begin
  FTaskItem.StatusOnCompletionRecipients := Value;
end;

procedure TOpTaskItem.SetStatusUpdateRecipients(const Value: string);
begin
  FTaskItem.StatusUpdateRecipients := Value;
end;

procedure TOpTaskItem.SetSubject(const Value: string);
begin
  FTaskItem.Subject := Value;
end;

procedure TOpTaskItem.SetTeamTask(Value: Boolean);
begin
  FTaskItem.TeamTask := Value;
end;

procedure TOpTaskItem.SetTotalWork(Value: Integer);
begin
  FTaskItem.TotalWork := Value;
end;

procedure TOpTaskItem.SetUnRead(Value: Boolean);
begin
  FTaskItem.UnRead := Value;
end;

function TOpTaskItem.SkipRecurrence: Boolean;
begin
  Result := FTaskItem.SkipRecurrence;
end;

function TOpTaskItem.StatusReport: IDispatch;
begin
  Result := FTaskItem.StatusReport;
end;

procedure TOpTaskItem.SaveAs(const Path: string; SaveAsType: TOpOlSaveAsType);
begin
  FTaskItem.SaveAs(Path, Ord(SaveAsType));
end;

{ TOpMailItem }

procedure TOpMailItem.ClearConversationIndex;
begin
  FMailItem.ClearConversationIndex;
end;

constructor TOpMailItem.Create(AMailItem: _MailItem);
begin
  inherited Create;
  FMailItem := AMailItem;
  FAttachments := TOpAttachmentList.Create(Self, AMailItem.Attachments);
  FRecipients := TOpRecipientList.Create(Self, AMailItem.Recipients);
end;

procedure TOpMailItem.Delete;
begin
  FMailItem.Delete;
end;

destructor TOpMailItem.Destroy;
begin
  FRecipients.Free;                                                  {!!.62}
  FAttachments.Free;
  inherited Destroy;
end;

procedure TOpMailItem.Display(Modal: Boolean);
begin
  FMailItem.Display(Modal);
end;

function TOpMailItem.Forward: TOpMailItem;
begin
  Result := TOpMailItem.Create(FMailItem.Forward);
end;

function TOpMailItem.GetAutoForwarded: Boolean;
begin
  Result := FMailItem.AutoForwarded;
end;

function TOpMailItem.GetBCC: string;
begin
  Result := FMailItem.BCC;
end;

function TOpMailItem.GetBody: string;
begin
  Result :=  FMailItem.Body;
end;

function TOpMailItem.GetCC: string;
begin
  Result := FMailItem.CC;
end;

function TOpMailItem.GetDeferredDeliveryTime: TDateTime;
begin
  Result := FMailItem.DeferredDeliveryTime;
end;

function TOpMailItem.GetHTMLBody: string;
begin
  Result := FMailItem.HTMLBody;
end;

function TOpMailItem.GetImportance: TOpOlImportance;
begin
  Result := TOpOlImportance(FMailItem.Importance);
end;

function TOpMailItem.GetMsgTo: string;
begin
  Result := FMailItem.To_;
end;

function TOpMailItem.GetSaved: Boolean;
begin
  Result := FMailItem.Saved;
end;

function TOpMailItem.GetSenderName: string;
begin
  Result := FMailItem.SenderName;
end;

function TOpMailItem.GetSensitivity: TOpOlSensitivity;
begin
  Result := TOpOlSensitivity(FMailItem.Sensitivity);
end;

function TOpMailItem.GetSent: Boolean;
begin
  Result := FMailItem.Sent;
end;

function TOpMailItem.GetSize: Integer;
begin
  Result := FMailItem.Size;
end;

function TOpMailItem.GetSubject: string;
begin
  Result := FMailItem.Subject;
end;

function TOpMailItem.GetUnRead: Boolean;
begin
  Result := FMailItem.UnRead;
end;

procedure TOpMailItem.PrintOut;
begin
  FMailItem.PrintOut;
end;

function TOpMailItem.Reply: TOpMailItem;
begin
  Result := TOpMailItem.Create(FMailItem.Reply);
end;

function TOpMailItem.ReplyAll: TOpMailItem;
begin
  Result := TOpMailItem.Create(FMailItem.ReplyAll);
end;

procedure TOpMailItem.Save;
begin
  FMailItem.Save;
end;

procedure TOpMailItem.Send;
begin
  FMailItem.Send;
end;

procedure TOpMailItem.SetAutoForwarded(Value: Boolean);
begin
  FMailItem.AutoForwarded := Value;
end;

procedure TOpMailItem.SetBCC(const Value: string);
begin
  FMailItem.BCC := Value;
end;

procedure TOpMailItem.SetBody(const Value: string);
begin
  FMailItem.Body := Value;
end;

procedure TOpMailItem.SetCC(const Value: string);
begin
  FMailItem.CC := Value;
end;

procedure TOpMailItem.SetDeferredDeliveryTime(const Value: TDateTime);
begin
  FMailItem.DeferredDeliveryTime := Value;
end;

procedure TOpMailItem.SetHTMLBody(const Value: string);
begin
  FMailItem.HTMLBody := Value;
end;

procedure TOpMailItem.SetImportance(Value: TOpOlImportance);
begin
  FMailItem.Importance := Ord(Value);
end;

procedure TOpMailItem.SetMsgTo(const Value: string);
begin
  FMailItem.To_ := Value;
end;

procedure TOpMailItem.SetSensitivity(Value: TOpOlSensitivity);
begin
  FMailItem.Sensitivity := Ord(Value);
end;

procedure TOpMailItem.SetSubject(const Value: string);
begin
  FMailItem.Subject := Value;
end;

procedure TOpMailItem.SetUnRead(Value: Boolean);
begin
  FMailItem.UnRead := Value;
end;

{ TOpAttachmentList }

constructor TOpAttachmentList.Create(AOwner: TOpOutlookItem; Intf: Attachments);
begin
  inherited Create(AOwner);
  FIntf := Intf;
end;

function TOpAttachmentList.Add(const FileName: string): TOpAttachment;
begin
  Result := TOpAttachment.Create(Self, FIntf.Add(FileName, olByValue, EmptyParam,
    EmptyParam));
end;

function TOpAttachmentList.GetCount: Integer;
begin
  Result := FIntf.Count;
end;

function TOpAttachmentList.GetItems(Index: Integer): TOpAttachment;
begin
  Result := TOpAttachment.Create(Self, FIntf.Item(Index));
end;

procedure TOpAttachmentList.Remove(Index: Integer);
begin
  FIntf.Remove(Index);
end;

{ TOpAttachment }

constructor TOpAttachment.Create(AOwner: TOpAttachmentList; Intf: Attachment);
begin
  inherited Create(AOwner);
  FOwner := AOwner;
  FIntf := Intf;
end;

destructor TOpAttachment.Destroy;
begin
  if not ListProp.Destroying then FIntf.Delete;
  inherited Destroy;
end;

function TOpAttachment.GetDisplayName: string;
begin
  Result := FIntf.DisplayName;
end;

function TOpAttachment.GetFileName: string;
begin
  Result := FIntf.FileName;
end;

function TOpAttachment.GetPathName: string;
begin
  Result := FIntf.PathName;
end;

{ TOpMailListProp }

constructor TOpMailListProp.Create(AOwner: TOpOutlookItem);
begin
  inherited Create;
  FOwner := AOwner;
  FFreeList := TOpFreeList.Create;
end;

destructor TOpMailListProp.Destroy;
begin
  FDestroying := True;
  FFreeList.Free;
  inherited Destroy;
end;

procedure TOpMailListProp.AddItem(Item: TOpMailListItem);
begin
  FFreeList.Add(Pointer(Item));
end;

procedure TOpMailListProp.RemoveItem(Item: TOpMailListItem);
begin
  FFreeList.Remove(Pointer(Item));
end;

{ TOpRecipientList }

constructor TOpRecipientList.Create(AOwner: TOpOutlookItem; Intf: Recipients);
begin
  inherited Create(AOwner);
  FIntf := Intf;
  if FIntf = nil then OfficeError('recipients is nil');
end;

function TOpRecipientList.Add(const Name: string): TOpRecipient;
begin
  Result := TOpRecipient.Create(Self, FIntf.Add(Name));
end;

function TOpRecipientList.GetCount: Integer;
begin
  Result := FIntf.Count;
end;

function TOpRecipientList.GetItems(Index: Integer): TOpRecipient;
begin
  Result := TOpRecipient.Create(Self, FIntf.Item(Index));
end;

procedure TOpRecipientList.Remove(Index: Integer);
begin
  FIntf.Remove(Index);
end;

function TOpRecipientList.ResolveAll: Boolean;
begin
  Result := FIntf.ResolveAll;
end;

{ TOpMailListItem }

constructor TOpMailListItem.Create(AListProp: TOpMailListProp);
begin
  inherited Create;
  FListProp := AListProp;
  AListProp.AddItem(Self);
end;

destructor TOpMailListItem.Destroy;
begin
  if not FListProp.Destroying then FListProp.RemoveItem(Self);
  inherited Destroy;
end;

{ TOpRecipient }

constructor TOpRecipient.Create(AOwner: TOpRecipientList; Intf: Recipient);
begin
  inherited Create(AOwner);
  FOwner := AOwner;
  FIntf := Intf;
end;

destructor TOpRecipient.Destroy;
begin
  if not FListProp.Destroying then FIntf.Delete;
  inherited Destroy;
end;

function TOpRecipient.GetAddress: string;
begin
  Result := FIntf.Address;
end;

function TOpRecipient.GetAddressEntry: AddressEntry;
begin
  Result := FIntf.AddressEntry;
end;

function TOpRecipient.GetDisplayType: TOpOlDisplayType;
begin
  Result := TOpOlDisplayType(FIntf.DisplayType);
end;

function TOpRecipient.GetEntryID: string;
begin
  Result := FIntf.EntryID;
end;

function TOpRecipient.GetIndex: Integer;
begin
  Result := FIntf.Index;
end;

function TOpRecipient.GetName: string;
begin
  Result := FIntf.Name;
end;

function TOpRecipient.GetRecipientType: TOpOlMailRecipientType;
begin
  Result := TOpOlMailRecipientType(FIntf.Type_);
end;

function TOpRecipient.GetResolved: Boolean;
begin
  Result := FIntf.Resolved;
end;

function TOpRecipient.GetTrackingStatus: TOpOlTrackingStatus;
begin
  Result := TOpOlTrackingStatus(FIntf.TrackingStatus);
end;

function TOpRecipient.GetTrackingStatusTime: TDateTime;
begin
  Result := FIntf.TrackingStatusTime;
end;

function TOpRecipient.Resolve: Boolean;
begin
  Result := FIntf.Resolve;
end;

procedure TOpRecipient.SetAddressEntry(const Value: AddressEntry);
begin
  FIntf.AddressEntry := Value;
end;

procedure TOpRecipient.SetRecipientType(Value: TOpOlMailRecipientType);
begin
  FIntf.Type_ := Ord(Value);
end;

procedure TOpRecipient.SetTrackingStatus(Value: TOpOlTrackingStatus);
begin
  FIntf.TrackingStatus := Ord(Value);
end;

procedure TOpRecipient.SetTrackingStatusTime(const Value: TDateTime);
begin
  FIntf.TrackingStatusTime := Value;
end;

end.
