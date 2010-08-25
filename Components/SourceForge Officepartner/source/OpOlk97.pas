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

{$IFDEF CBuilder}
  {$Warnings Off}
{$ENDIF}

unit OpOlk97;

// ************************************************************************ //
// WARNING                                                                  //
// -------                                                                  //
// The types declared in this file were generated from data read from a     //
// Type Library. If this type library is explicitly or indirectly (via      //
// another type library referring to this type library) re-imported, or the //
// 'Refresh' command of the Type Library Editor activated while editing the //
// Type Library, the contents of this file will be regenerated and all      //
// manual modifications will be lost.                                       //
// ************************************************************************ //

// PASTLWTR : $Revision:   1.11.1.75  $
// File generated on 5/18/99 12:19:35 PM from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\Program Files\Microsoft Office\Office\Msoutl8.olb
// IID\LCID: {00062FFF-0000-0000-C000-000000000046}\0
// Helpfile: C:\Program Files\Microsoft Office\Office\VBAOUTL.HLP
// HelpString: Microsoft Outlook 8.0 Object Library
// Version:    8.0
// ************************************************************************ //

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, 
  OpOfc97, OpFrms97;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:      //
//   Type Libraries     : LIBID_xxxx                                    //
//   CoClasses          : CLASS_xxxx                                    //
//   DISPInterfaces     : DIID_xxxx                                     //
//   Non-DISP interfaces: IID_xxxx                                      //
// *********************************************************************//
const
  LIBID_Outlook: TGUID = '{00062FFF-0000-0000-C000-000000000046}';
  IID__IItemEvents: TGUID = '{0006313A-0000-0000-C000-000000000046}';
  DIID__DItemEvents: TGUID = '{0006303A-0000-0000-C000-000000000046}';
  IID__IAction: TGUID = '{00063143-0000-0000-C000-000000000046}';
  DIID_Action: TGUID = '{00063043-0000-0000-C000-000000000046}';
  IID__IActions: TGUID = '{0006313E-0000-0000-C000-000000000046}';
  DIID_Actions: TGUID = '{0006303E-0000-0000-C000-000000000046}';
  IID__IApplication: TGUID = '{00063101-0000-0000-C000-000000000046}';
  DIID__DApplication: TGUID = '{00063001-0000-0000-C000-000000000046}';
  CLASS_Application_: TGUID = '{0006F033-0000-0000-C000-000000000046}';
  IID__IAppointmentItem: TGUID = '{00063133-0000-0000-C000-000000000046}';
  DIID__DAppointmentItem: TGUID = '{00063033-0000-0000-C000-000000000046}';
  CLASS_AppointmentItem: TGUID = '{00061030-0000-0000-C000-000000000046}';
  IID__IAttachment: TGUID = '{00063107-0000-0000-C000-000000000046}';
  DIID_Attachment: TGUID = '{00063007-0000-0000-C000-000000000046}';
  IID__IAttachments: TGUID = '{0006313C-0000-0000-C000-000000000046}';
  DIID_Attachments: TGUID = '{0006303C-0000-0000-C000-000000000046}';
  IID__IContactItem: TGUID = '{00063121-0000-0000-C000-000000000046}';
  DIID__DContactItem: TGUID = '{00063021-0000-0000-C000-000000000046}';
  CLASS_ContactItem: TGUID = '{00061031-0000-0000-C000-000000000046}';
  IID__IExplorer: TGUID = '{00063103-0000-0000-C000-000000000046}';
  DIID_Explorer: TGUID = '{00063003-0000-0000-C000-000000000046}';
  IID__IFolders: TGUID = '{00063140-0000-0000-C000-000000000046}';
  DIID_Folders: TGUID = '{00063040-0000-0000-C000-000000000046}';
  IID__IFormDescription: TGUID = '{00063146-0000-0000-C000-000000000046}';
  DIID_FormDescription: TGUID = '{00063046-0000-0000-C000-000000000046}';
  IID__IInspector: TGUID = '{00063105-0000-0000-C000-000000000046}';
  DIID_Inspector: TGUID = '{00063005-0000-0000-C000-000000000046}';
  IID__IItems: TGUID = '{00063141-0000-0000-C000-000000000046}';
  DIID_Items: TGUID = '{00063041-0000-0000-C000-000000000046}';
  IID__IJournalItem: TGUID = '{00063122-0000-0000-C000-000000000046}';
  DIID__DJournalItem: TGUID = '{00063022-0000-0000-C000-000000000046}';
  CLASS_JournalItem: TGUID = '{00061037-0000-0000-C000-000000000046}';
  IID__IMailItem: TGUID = '{00063134-0000-0000-C000-000000000046}';
  DIID__DMailItem: TGUID = '{00063034-0000-0000-C000-000000000046}';
  CLASS_MailItem: TGUID = '{00061033-0000-0000-C000-000000000046}';
  IID__IMAPIFolder: TGUID = '{00063106-0000-0000-C000-000000000046}';
  DIID_MAPIFolder: TGUID = '{00063006-0000-0000-C000-000000000046}';
  IID__IMeetingCanceledItem: TGUID = '{00063128-0000-0000-C000-000000000046}';
  DIID__DMeetingCanceledItem: TGUID = '{00063028-0000-0000-C000-000000000046}';
  CLASS__MeetingCanceledItem: TGUID = '{00061040-0000-0000-C000-000000000046}';
  IID__IMeetingRequestAcceptedItem: TGUID = '{00063130-0000-0000-C000-000000000046}';
  DIID__DMeetingRequestAcceptedItem: TGUID = '{00063030-0000-0000-C000-000000000046}';
  CLASS__MeetingRequestAcceptedItem: TGUID = '{00061042-0000-0000-C000-000000000046}';
  IID__IMeetingRequestDeclinedItem: TGUID = '{00063131-0000-0000-C000-000000000046}';
  DIID__DMeetingRequestDeclinedItem: TGUID = '{00063031-0000-0000-C000-000000000046}';
  CLASS__MeetingRequestDeclinedItem: TGUID = '{00061043-0000-0000-C000-000000000046}';
  IID__IMeetingRequestItem: TGUID = '{00063129-0000-0000-C000-000000000046}';
  DIID__DMeetingRequestItem: TGUID = '{00063029-0000-0000-C000-000000000046}';
  CLASS_MeetingRequestItem: TGUID = '{00061041-0000-0000-C000-000000000046}';
  IID__IMeetingRequestTentativeItem: TGUID = '{00063132-0000-0000-C000-000000000046}';
  DIID__DMeetingRequestTentativeItem: TGUID = '{00063032-0000-0000-C000-000000000046}';
  CLASS__MeetingRequestTentativeItem: TGUID = '{00061044-0000-0000-C000-000000000046}';
  IID__INameSpace: TGUID = '{00063102-0000-0000-C000-000000000046}';
  DIID_NameSpace: TGUID = '{00063002-0000-0000-C000-000000000046}';
  IID__INoteItem: TGUID = '{00063125-0000-0000-C000-000000000046}';
  DIID__DNoteItem: TGUID = '{00063025-0000-0000-C000-000000000046}';
  CLASS_NoteItem: TGUID = '{00061034-0000-0000-C000-000000000046}';
  IID__IOfficeDocumentItem: TGUID = '{00063120-0000-0000-C000-000000000046}';
  DIID__DOfficeDocumentItem: TGUID = '{00063020-0000-0000-C000-000000000046}';
  CLASS__OfficeDocumentItem: TGUID = '{00061061-0000-0000-C000-000000000046}';
  IID__IPages: TGUID = '{0006313F-0000-0000-C000-000000000046}';
  DIID_Pages: TGUID = '{0006303F-0000-0000-C000-000000000046}';
  IID__IPostItem: TGUID = '{00063124-0000-0000-C000-000000000046}';
  DIID__DPostItem: TGUID = '{00063024-0000-0000-C000-000000000046}';
  CLASS_PostItem: TGUID = '{0006103A-0000-0000-C000-000000000046}';
  IID__IRecipient: TGUID = '{00063145-0000-0000-C000-000000000046}';
  DIID_Recipient: TGUID = '{00063045-0000-0000-C000-000000000046}';
  IID__IRecipients: TGUID = '{0006313B-0000-0000-C000-000000000046}';
  DIID_Recipients: TGUID = '{0006303B-0000-0000-C000-000000000046}';
  IID__IRecurrencePattern: TGUID = '{00063144-0000-0000-C000-000000000046}';
  DIID_RecurrencePattern: TGUID = '{00063044-0000-0000-C000-000000000046}';
  IID__IRemoteItem: TGUID = '{00063123-0000-0000-C000-000000000046}';
  DIID__DRemoteItem: TGUID = '{00063023-0000-0000-C000-000000000046}';
  CLASS_RemoteItem: TGUID = '{00061060-0000-0000-C000-000000000046}';
  IID__IReportItem: TGUID = '{00063126-0000-0000-C000-000000000046}';
  DIID__DReportItem: TGUID = '{00063026-0000-0000-C000-000000000046}';
  CLASS_ReportItem: TGUID = '{00061035-0000-0000-C000-000000000046}';
  IID__ITaskItem: TGUID = '{00063135-0000-0000-C000-000000000046}';
  DIID__DTaskItem: TGUID = '{00063035-0000-0000-C000-000000000046}';
  CLASS_TaskItem: TGUID = '{00061032-0000-0000-C000-000000000046}';
  IID__ITaskRequestAcceptItem: TGUID = '{00063138-0000-0000-C000-000000000046}';
  DIID__DTaskRequestAcceptItem: TGUID = '{00063038-0000-0000-C000-000000000046}';
  CLASS__TaskRequestAcceptItem: TGUID = '{00061052-0000-0000-C000-000000000046}';
  IID__ITaskRequestDeclineItem: TGUID = '{00063139-0000-0000-C000-000000000046}';
  DIID__DTaskRequestDeclineItem: TGUID = '{00063039-0000-0000-C000-000000000046}';
  CLASS__TaskRequestDeclineItem: TGUID = '{00061053-0000-0000-C000-000000000046}';
  IID__ITaskRequestItem: TGUID = '{00063136-0000-0000-C000-000000000046}';
  DIID__DTaskRequestItem: TGUID = '{00063036-0000-0000-C000-000000000046}';
  CLASS_TaskRequestItem: TGUID = '{00061050-0000-0000-C000-000000000046}';
  IID__ITaskRequestUpdateItem: TGUID = '{00063137-0000-0000-C000-000000000046}';
  DIID__DTaskRequestUpdateItem: TGUID = '{00063037-0000-0000-C000-000000000046}';
  CLASS__TaskRequestUpdateItem: TGUID = '{00061051-0000-0000-C000-000000000046}';
  IID__IUserProperties: TGUID = '{0006313D-0000-0000-C000-000000000046}';
  DIID_UserProperties: TGUID = '{0006303D-0000-0000-C000-000000000046}';
  IID__IUserProperty: TGUID = '{00063142-0000-0000-C000-000000000046}';
  DIID_UserProperty: TGUID = '{00063042-0000-0000-C000-000000000046}';
  IID__IRecipientControl: TGUID = '{D87E7E16-6897-11CE-A6C0-00AA00608FAA}';
  DIID__DRecipientControl: TGUID = '{0006F025-0000-0000-C000-000000000046}';
  DIID__DRecipientControlEvents: TGUID = '{D87E7E17-6897-11CE-A6C0-00AA00608FAA}';
  CLASS__RecipientControl: TGUID = '{0006F023-0000-0000-C000-000000000046}';
  IID__IDocSiteControl: TGUID = '{43507DD0-811D-11CE-B565-00AA00608FAA}';
  DIID__DDocSiteControl: TGUID = '{0006F026-0000-0000-C000-000000000046}';
  DIID__DDocSiteControlEvents: TGUID = '{50BB9B50-811D-11CE-B565-00AA00608FAA}';
  CLASS__DocSiteControl: TGUID = '{0006F024-0000-0000-C000-000000000046}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                  //
// *********************************************************************//
// OlAttachmentType constants
type
  OlAttachmentType = TOleEnum;
const
  olByValue = $00000001;
  olByReference = $00000004;
  olEmbeddedItem = $00000005;
  olOLE = $00000006;

// OlBusyStatus constants
type
  OlBusyStatus = TOleEnum;
const
  olFree = $00000000;
  olTentative = $00000001;
  olBusy = $00000002;
  olOutOfOffice = $00000003;

// OlDaysOfWeek constants
type
  OlDaysOfWeek = TOleEnum;
const
  olSunday = $00000001;
  olMonday = $00000002;
  olTuesday = $00000004;
  olWednesday = $00000008;
  olThursday = $00000010;
  olFriday = $00000020;
  olSaturday = $00000040;

// OlDefaultFolders constants
type
  OlDefaultFolders = TOleEnum;
const
  olFolderDeletedItems = $00000003;
  olFolderOutbox = $00000004;
  olFolderSentMail = $00000005;
  olFolderInbox = $00000006;
  olFolderCalendar = $00000009;
  olFolderContacts = $0000000A;
  olFolderJournal = $0000000B;
  olFolderNotes = $0000000C;
  olFolderTasks = $0000000D;

// OlFolderDisplayMode constants
type
  OlFolderDisplayMode = TOleEnum;
const
  olFolderDisplayNormal = $00000000;
  olFolderDisplayFolderOnly = $00000001;
  olFolderDisplayNoNavigation = $00000002;

// OlFormRegistry constants
type
  OlFormRegistry = TOleEnum;
const
  olDefaultRegistry = $00000000;
  olOrganizationRegistry = $00000004;
  olPersonalRegistry = $00000002;
  olFolderRegistry = $00000003;

// OlGender constants
type
  OlGender = TOleEnum;
const
  olUnspecified = $00000000;
  olFemale = $00000001;
  olMale = $00000002;

// OlImportance constants
type
  OlImportance = TOleEnum;
const
  olImportanceLow = $00000000;
  olImportanceNormal = $00000001;
  olImportanceHigh = $00000002;

// OlInspectorClose constants
type
  OlInspectorClose = TOleEnum;
const
  olSave = $00000000;
  olDiscard = $00000001;
  olPromptForSave = $00000002;

// OlItems constants
type
  OlItems = TOleEnum;
const
  olMailItem = $00000000;
  olAppointmentItem = $00000001;
  olContactItem = $00000002;
  olTaskItem = $00000003;
  olJournalItem = $00000004;
  olNoteItem = $00000005;
  olPostItem = $00000006;

// OlJournalRecipientType constants
type
  OlJournalRecipientType = TOleEnum;
const
  olAssociatedContact = $00000001;

// OlMailingAddress constants
type
  OlMailingAddress = TOleEnum;
const
  olNone = $00000000;
  olHome = $00000001;
  olBusiness = $00000002;
  olOther = $00000003;

// OlMailRecipientType constants
type
  OlMailRecipientType = TOleEnum;
const
  olOriginator = $00000000;
  olTo = $00000001;
  olCC = $00000002;
  olBCC = $00000003;

// OlMeetingRecipientType constants
type
  OlMeetingRecipientType = TOleEnum;
const
  olOrganizer = $00000000;
  olRequired = $00000001;
  olOptional = $00000002;
  olResource = $00000003;

// OlMeetingStatus constants
type
  OlMeetingStatus = TOleEnum;
const
  olNonMeeting = $00000000;
  olMeeting = $00000001;
  olMeetingReceived = $00000003;
  olMeetingCanceled = $00000005;

// OlNoteColor constants
type
  OlNoteColor = TOleEnum;
const
  olBlue = $00000000;
  olGreen = $00000001;
  olPink = $00000002;
  olYellow = $00000003;
  olWhite = $00000004;

// OlRecurrenceType constants
type
  OlRecurrenceType = TOleEnum;
const
  olRecursDaily = $00000000;
  olRecursWeekly = $00000001;
  olRecursMonthly = $00000002;
  olRecursMonthNth = $00000003;
  olRecursYearly = $00000005;
  olRecursYearNth = $00000006;

// OlRemoteStatus constants
type
  OlRemoteStatus = TOleEnum;
const
  olRemoteStatusNone = $00000000;
  olUnMarked = $00000001;
  olMarkedForDownload = $00000002;
  olMarkedForCopy = $00000003;
  olMarkedForDelete = $00000004;

// OlMeetingResponse constants
type
  OlMeetingResponse = TOleEnum;
const
  olMeetingAccepted = $00000003;
  olMeetingDeclined = $00000004;
  olMeetingTentative = $00000002;

// OlResponseStatus constants
type
  OlResponseStatus = TOleEnum;
const
  olResponseNone = $00000000;
  olResponseOrganized = $00000001;
  olResponseTentative = $00000002;
  olResponseAccepted = $00000003;
  olResponseDeclined = $00000004;
  olResponseNotResponded = $00000005;

// OlSaveAsType constants
type
  OlSaveAsType = TOleEnum;
const
  olTXT = $00000000;
  olRTF = $00000001;
  olTemplate = $00000002;
  olMSG = $00000003;
  olDoc = $00000004;

// OlSensitivity constants
type
  OlSensitivity = TOleEnum;
const
  olNormal = $00000000;
  olPersonal = $00000001;
  olPrivate = $00000002;
  olConfidential = $00000003;

// OlFlagStatus constants
type
  OlFlagStatus = TOleEnum;
const
  olNoFlag = $00000000;
  olFlagComplete = $00000001;
  olFlagMarked = $00000002;

// OlTaskDelegationState constants
type
  OlTaskDelegationState = TOleEnum;
const
  olTaskNotDelegated = $00000000;
  olTaskDelegationUnknown = $00000001;
  olTaskDelegationAccepted = $00000002;
  olTaskDelegationDeclined = $00000003;

// OlTaskOwnership constants
type
  OlTaskOwnership = TOleEnum;
const
  olNewTask = $00000000;
  olDelegatedTask = $00000001;
  olOwnTask = $00000002;

// OlTaskRecipientType constants
type
  OlTaskRecipientType = TOleEnum;
const
  olUpdate = $00000001;
  olFinalStatus = $00000002;

// OlTaskResponse constants
type
  OlTaskResponse = TOleEnum;
const
  olTaskSimple = $00000000;
  olTaskAssign = $00000001;
  olTaskAccept = $00000002;
  olTaskDecline = $00000003;

// OlTaskStatus constants
type
  OlTaskStatus = TOleEnum;
const
  olTaskNotStarted = $00000000;
  olTaskInProgress = $00000001;
  olTaskComplete = $00000002;
  olTaskWaiting = $00000003;
  olTaskDeferred = $00000004;

// OlTrackingStatus constants
type
  OlTrackingStatus = TOleEnum;
const
  olTrackingNone = $00000000;
  olTrackingDelivered = $00000001;
  olTrackingNotDelivered = $00000002;
  olTrackingNotRead = $00000003;
  olTrackingRecallFailure = $00000004;
  olTrackingRecallSuccess = $00000005;
  olTrackingRead = $00000006;
  olTrackingReplied = $00000007;

// OlUserPropertyType constants
type
  OlUserPropertyType = TOleEnum;
const
  olText = $00000001;
  olNumber = $00000003;
  olDateTime = $00000005;
  olYesNo = $00000006;
  olDuration = $00000007;
  olKeywords = $0000000B;
  olPercent = $0000000C;
  olCurrency = $0000000E;
  olFormula = $00000012;
  olCombination = $00000013;

// OlActionCopyLike constants
type
  OlActionCopyLike = TOleEnum;
const
  olReply = $00000000;
  olReplyAll = $00000001;
  olForward = $00000002;
  olReplyFolder = $00000003;
  olRespond = $00000004;

// OlActionReplyStyle constants
type
  OlActionReplyStyle = TOleEnum;
const
  olOmitOriginalText = $00000000;
  olEmbedOriginalItem = $00000001;
  olIncludeOriginalText = $00000002;
  olIndentOriginalText = $00000003;
  olLinkOriginalItem = $00000004;
  olUserPreference = $00000005;

// OlActionResponseStyle constants
type
  OlActionResponseStyle = TOleEnum;
const
  olOpen = $00000000;
  olSend = $00000001;
  olPrompt = $00000002;

// OlActionShowOn constants
type
  OlActionShowOn = TOleEnum;
const
  olDontShow = $00000000;
  olMenu = $00000001;
  olMenuAndToolbar = $00000002;

type

// *********************************************************************//
// Forward declaration of interfaces defined in Type Library            //
// *********************************************************************//
  _IItemEvents = interface;
  _DItemEvents = dispinterface;
  _IAction = interface;
  Action = dispinterface;
  _IActions = interface;
  Actions = dispinterface;
  _IApplication = interface;
  _DApplication = dispinterface;
  _IAppointmentItem = interface;
  _DAppointmentItem = dispinterface;
  _IAttachment = interface;
  Attachment = dispinterface;
  _IAttachments = interface;
  Attachments = dispinterface;
  _IContactItem = interface;
  _DContactItem = dispinterface;
  _IExplorer = interface;
  Explorer = dispinterface;
  _IFolders = interface;
  Folders = dispinterface;
  _IFormDescription = interface;
  FormDescription = dispinterface;
  _IInspector = interface;
  Inspector = dispinterface;
  _IItems = interface;
  Items = dispinterface;
  _IJournalItem = interface;
  _DJournalItem = dispinterface;
  _IMailItem = interface;
  _DMailItem = dispinterface;
  _IMAPIFolder = interface;
  MAPIFolder = dispinterface;
  _IMeetingCanceledItem = interface;
  _DMeetingCanceledItem = dispinterface;
  _IMeetingRequestAcceptedItem = interface;
  _DMeetingRequestAcceptedItem = dispinterface;
  _IMeetingRequestDeclinedItem = interface;
  _DMeetingRequestDeclinedItem = dispinterface;
  _IMeetingRequestItem = interface;
  _DMeetingRequestItem = dispinterface;
  _IMeetingRequestTentativeItem = interface;
  _DMeetingRequestTentativeItem = dispinterface;
  _INameSpace = interface;
  NameSpace = dispinterface;
  _INoteItem = interface;
  _DNoteItem = dispinterface;
  _IOfficeDocumentItem = interface;
  _DOfficeDocumentItem = dispinterface;
  _IPages = interface;
  Pages = dispinterface;
  _IPostItem = interface;
  _DPostItem = dispinterface;
  _IRecipient = interface;
  Recipient = dispinterface;
  _IRecipients = interface;
  Recipients = dispinterface;
  _IRecurrencePattern = interface;
  RecurrencePattern = dispinterface;
  _IRemoteItem = interface;
  _DRemoteItem = dispinterface;
  _IReportItem = interface;
  _DReportItem = dispinterface;
  _ITaskItem = interface;
  _DTaskItem = dispinterface;
  _ITaskRequestAcceptItem = interface;
  _DTaskRequestAcceptItem = dispinterface;
  _ITaskRequestDeclineItem = interface;
  _DTaskRequestDeclineItem = dispinterface;
  _ITaskRequestItem = interface;
  _DTaskRequestItem = dispinterface;
  _ITaskRequestUpdateItem = interface;
  _DTaskRequestUpdateItem = dispinterface;
  _IUserProperties = interface;
  UserProperties = dispinterface;
  _IUserProperty = interface;
  UserProperty = dispinterface;
  _IRecipientControl = interface;
  _DRecipientControl = dispinterface;
  _DRecipientControlEvents = dispinterface;
  _IDocSiteControl = interface;
  _DDocSiteControl = dispinterface;
  _DDocSiteControlEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                     //
// (NOTE: Here we map each CoClass to its Default Interface)            //
// *********************************************************************//
  Application_ = _DApplication;
  AppointmentItem = _DAppointmentItem;
  ContactItem = _DContactItem;
  JournalItem = _DJournalItem;
  MailItem = _DMailItem;
  _MeetingCanceledItem = _DMeetingCanceledItem;
  _MeetingRequestAcceptedItem = _DMeetingRequestAcceptedItem;
  _MeetingRequestDeclinedItem = _DMeetingRequestDeclinedItem;
  MeetingRequestItem = _DMeetingRequestItem;
  _MeetingRequestTentativeItem = _DMeetingRequestTentativeItem;
  NoteItem = _DNoteItem;
  _OfficeDocumentItem = _DOfficeDocumentItem;
  PostItem = _DPostItem;
  RemoteItem = _DRemoteItem;
  ReportItem = _DReportItem;
  TaskItem = _DTaskItem;
  _TaskRequestAcceptItem = _DTaskRequestAcceptItem;
  _TaskRequestDeclineItem = _DTaskRequestDeclineItem;
  TaskRequestItem = _DTaskRequestItem;
  _TaskRequestUpdateItem = _DTaskRequestUpdateItem;
  _RecipientControl = _DRecipientControl;
  _DocSiteControl = _DDocSiteControl;


// *********************************************************************//
// Declaration of structures, unions and aliases.                       //
// *********************************************************************//
  PUserType1 = ^TGUID; {*}
  PShortint1 = ^Shortint; {*}
  PPShortint1 = ^PShortint1; {*}
  PUserType2 = ^DISPPARAMS; {*}


// *********************************************************************//
// Interface: _IItemEvents
// Flags:     (4096) Dispatchable
// GUID:      {0006313A-0000-0000-C000-000000000046}
// *********************************************************************//
  _IItemEvents = interface(IDispatch)
    ['{0006313A-0000-0000-C000-000000000046}']
    function Read: WordBool; stdcall;
    function Write: WordBool; stdcall;
    function Open: WordBool; stdcall;
    function Close: WordBool; stdcall;
    function Send: WordBool; stdcall;
    function Reply(const Response: IDispatch): WordBool; stdcall;
    function ReplyAll(const Response: IDispatch): WordBool; stdcall;
    function Forward(const Forward: IDispatch): WordBool; stdcall;
    function CustomAction(const Action: IDispatch; const Response: IDispatch): WordBool; stdcall;
    procedure CustomPropertyChange(const Name: WideString); stdcall;
    procedure PropertyChange(const Name: WideString); stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DItemEvents
// Flags:     (4096) Dispatchable
// GUID:      {0006303A-0000-0000-C000-000000000046}
// *********************************************************************//
  _DItemEvents = dispinterface
    ['{0006303A-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    function Read: WordBool; dispid 61441;
    function Write: WordBool; dispid 61442;
    function Open: WordBool; dispid 61443;
    function Close: WordBool; dispid 61444;
    function Send: WordBool; dispid 61445;
    function Reply(const Response: IDispatch): WordBool; dispid 62566;
    function ReplyAll(const Response: IDispatch): WordBool; dispid 62567;
    function Forward(const Forward: IDispatch): WordBool; dispid 62568;
    function CustomAction(const Action: IDispatch; const Response: IDispatch): WordBool; dispid 61446;
    procedure CustomPropertyChange(const Name: WideString); dispid 61448;
    procedure PropertyChange(const Name: WideString); dispid 61449;
  end;

// *********************************************************************//
// Interface: _IAction
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063143-0000-0000-C000-000000000046}
// *********************************************************************//
  _IAction = interface(IDispatch)
    ['{00063143-0000-0000-C000-000000000046}']
    function Get_CopyLike(out CopyLike: OlActionCopyLike): HResult; stdcall;
    function Set_CopyLike(CopyLike: OlActionCopyLike): HResult; stdcall;
    function Get_Enabled(out Enabled: WordBool): HResult; stdcall;
    function Set_Enabled(Enabled: WordBool): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Name(out Name: WideString): HResult; stdcall;
    function Set_Name(const Name: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Prefix(out Prefix: WideString): HResult; stdcall;
    function Set_Prefix(const Prefix: WideString): HResult; stdcall;
    function Get_ReplyStyle(out ReplyStyle: OlActionReplyStyle): HResult; stdcall;
    function Set_ReplyStyle(ReplyStyle: OlActionReplyStyle): HResult; stdcall;
    function Get_ResponseStyle(out ResponseStyle: OlActionResponseStyle): HResult; stdcall;
    function Set_ResponseStyle(ResponseStyle: OlActionResponseStyle): HResult; stdcall;
    function Get_ShowOn(out ShowOn: OlActionShowOn): HResult; stdcall;
    function Set_ShowOn(ShowOn: OlActionShowOn): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Execute(out Item: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Action
// Flags:     (4096) Dispatchable
// GUID:      {00063043-0000-0000-C000-000000000046}
// *********************************************************************//
  Action = dispinterface
    ['{00063043-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property CopyLike: OlActionCopyLike dispid 100;
    property Enabled: WordBool dispid 103;
    property MessageClass: WideString dispid 26;
    property Name: WideString dispid 12289;
    property Parent: IDispatch readonly dispid 61441;
    property Prefix: WideString dispid 61;
    property ReplyStyle: OlActionReplyStyle dispid 101;
    property ResponseStyle: OlActionResponseStyle dispid 102;
    property ShowOn: OlActionShowOn dispid 105;
    procedure Delete; dispid 108;
    function Execute: IDispatch; dispid 106;
  end;

// *********************************************************************//
// Interface: _IActions
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006313E-0000-0000-C000-000000000046}
// *********************************************************************//
  _IActions = interface(IDispatch)
    ['{0006313E-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Add(out Action: Action): HResult; stdcall;
    function Item(Index: OleVariant; out Action: Action): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Actions
// Flags:     (4096) Dispatchable
// GUID:      {0006303E-0000-0000-C000-000000000046}
// *********************************************************************//
  Actions = dispinterface
    ['{0006303E-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    function Add: Action; dispid 100;
    function Item(Index: OleVariant): Action; dispid 81;
    procedure Remove(Index: Integer); dispid 82;
  end;

// *********************************************************************//
// Interface: _IApplication
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063101-0000-0000-C000-000000000046}
// *********************************************************************//
  _IApplication = interface(IDispatch)
    ['{00063101-0000-0000-C000-000000000046}']
    function Get_Assistant(out Assistant: Assistant): HResult; stdcall;
    function ActiveExplorer(out ActiveExplorer: Explorer): HResult; stdcall;
    function ActiveInspector(out ActiveInspector: Inspector): HResult; stdcall;
    function CreateItem(ItemType: OlItems; out Item: IDispatch): HResult; stdcall;
    function CreateItemFromTemplate(const TemplatePath: WideString; InFolder: OleVariant; 
                                    out Item: IDispatch): HResult; stdcall;
    function CreateObject(const ObjectName: WideString; out Object_: IDispatch): HResult; stdcall;
    function GetNamespace(const Type_: WideString; out NameSpace: NameSpace): HResult; stdcall;
    function Quit: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DApplication
// Flags:     (4096) Dispatchable
// GUID:      {00063001-0000-0000-C000-000000000046}
// *********************************************************************//
  _DApplication = dispinterface
    ['{00063001-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Assistant: Assistant readonly dispid 276;
    function ActiveExplorer: Explorer; dispid 273;
    function ActiveInspector: Inspector; dispid 274;
    function CreateItem(ItemType: OlItems): IDispatch; dispid 266;
    function CreateItemFromTemplate(const TemplatePath: WideString; InFolder: OleVariant): IDispatch; dispid 267;
    function CreateObject(const ObjectName: WideString): IDispatch; dispid 277;
    function GetNamespace(const Type_: WideString): NameSpace; dispid 272;
    procedure Quit; dispid 275;
  end;

// *********************************************************************//
// Interface: _IAppointmentItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063133-0000-0000-C000-000000000046}
// *********************************************************************//
  _IAppointmentItem = interface(IDispatch)
    ['{00063133-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_AllDayEvent(out AllDayEvent: WordBool): HResult; stdcall;
    function Set_AllDayEvent(AllDayEvent: WordBool): HResult; stdcall;
    function Get_BusyStatus(out BusyStatus: OlBusyStatus): HResult; stdcall;
    function Set_BusyStatus(BusyStatus: OlBusyStatus): HResult; stdcall;
    function Get_Duration(out Duration: Integer): HResult; stdcall;
    function Set_Duration(Duration: Integer): HResult; stdcall;
    function Get_End_(out End_: TDateTime): HResult; stdcall;
    function Set_End_(End_: TDateTime): HResult; stdcall;
    function Get_IsRecurring(out IsRecurring: WordBool): HResult; stdcall;
    function Get_Location(out Location: WideString): HResult; stdcall;
    function Set_Location(const Location: WideString): HResult; stdcall;
    function Get_MeetingStatus(out MeetingStatus: OlMeetingStatus): HResult; stdcall;
    function Set_MeetingStatus(MeetingStatus: OlMeetingStatus): HResult; stdcall;
    function Get_OptionalAttendees(out OptionalAttendees: WideString): HResult; stdcall;
    function Set_OptionalAttendees(const OptionalAttendees: WideString): HResult; stdcall;
    function Get_Organizer(out Organizer: WideString): HResult; stdcall;
    function Get_Recipients(out Recipients: Recipients): HResult; stdcall;
    function Get_ReminderMinutesBeforeStart(out ReminderMinutesBeforeStart: Integer): HResult; stdcall;
    function Set_ReminderMinutesBeforeStart(ReminderMinutesBeforeStart: Integer): HResult; stdcall;
    function Get_ReminderOverrideDefault(out ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Set_ReminderOverrideDefault(ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Get_ReminderPlaySound(out ReminderPlaySound: WordBool): HResult; stdcall;
    function Set_ReminderPlaySound(ReminderPlaySound: WordBool): HResult; stdcall;
    function Get_ReminderSet(out ReminderSet: WordBool): HResult; stdcall;
    function Set_ReminderSet(ReminderSet: WordBool): HResult; stdcall;
    function Get_ReminderSoundFile(out ReminderSoundFile: WideString): HResult; stdcall;
    function Set_ReminderSoundFile(const ReminderSoundFile: WideString): HResult; stdcall;
    function Get_ReplyTime(out ReplyTime: TDateTime): HResult; stdcall;
    function Set_ReplyTime(ReplyTime: TDateTime): HResult; stdcall;
    function Get_RequiredAttendees(out RequiredAttendees: WideString): HResult; stdcall;
    function Set_RequiredAttendees(const RequiredAttendees: WideString): HResult; stdcall;
    function Get_Resources(out Resources: WideString): HResult; stdcall;
    function Set_Resources(const Resources: WideString): HResult; stdcall;
    function Get_ResponseRequested(out ResponseRequested: WordBool): HResult; stdcall;
    function Set_ResponseRequested(ResponseRequested: WordBool): HResult; stdcall;
    function Get_ResponseStatus(out ResponseStatus: OlResponseStatus): HResult; stdcall;
    function Get_Start(out Start: TDateTime): HResult; stdcall;
    function Set_Start(Start: TDateTime): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function ClearRecurrencePattern: HResult; stdcall;
    function GetRecurrencePattern(out RecurrencPattern: RecurrencePattern): HResult; stdcall;
    function Respond(Response: OlMeetingResponse; fNoUI: OleVariant; 
                     fAdditionalTextDialog: OleVariant; out ResponseItem: IDispatch): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DAppointmentItem
// Flags:     (4096) Dispatchable
// GUID:      {00063033-0000-0000-C000-000000000046}
// *********************************************************************//
  _DAppointmentItem = dispinterface
    ['{00063033-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property AllDayEvent: WordBool dispid 33301;
    property BusyStatus: OlBusyStatus dispid 33285;
    property Duration: Integer dispid 33299;
    property End_: TDateTime dispid 33294;
    property IsRecurring: WordBool readonly dispid 33315;
    property Location: WideString dispid 33288;
    property MeetingStatus: OlMeetingStatus dispid 33303;
    property OptionalAttendees: WideString dispid 3587;
    property Organizer: WideString readonly dispid 66;
    property Recipients: Recipients readonly dispid 63508;
    property ReminderMinutesBeforeStart: Integer dispid 34049;
    property ReminderOverrideDefault: WordBool dispid 34076;
    property ReminderPlaySound: WordBool dispid 34078;
    property ReminderSet: WordBool dispid 34051;
    property ReminderSoundFile: WideString dispid 34079;
    property ReplyTime: TDateTime dispid 33312;
    property RequiredAttendees: WideString dispid 3588;
    property Resources: WideString dispid 3586;
    property ResponseRequested: WordBool dispid 99;
    property ResponseStatus: OlResponseStatus readonly dispid 33304;
    property Start: TDateTime dispid 33293;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    procedure ClearRecurrencePattern; dispid 61605;
    function GetRecurrencePattern: RecurrencePattern; dispid 61604;
    function Respond(Response: OlMeetingResponse; fNoUI: OleVariant; 
                     fAdditionalTextDialog: OleVariant): IDispatch; dispid 62722;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _IAttachment
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063107-0000-0000-C000-000000000046}
// *********************************************************************//
  _IAttachment = interface(IDispatch)
    ['{00063107-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_DisplayName(out DisplayName: WideString): HResult; stdcall;
    function Set_DisplayName(const DisplayName: WideString): HResult; stdcall;
    function Get_FileName(out FileName: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_PathName(out PathName: WideString): HResult; stdcall;
    function Get_Position(out Position: Integer): HResult; stdcall;
    function Set_Position(Position: Integer): HResult; stdcall;
    function Get_Type_(out Type_: OlAttachmentType): HResult; stdcall;
    function Delete: HResult; stdcall;
    function SaveAsFile(const Path: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Attachment
// Flags:     (4096) Dispatchable
// GUID:      {00063007-0000-0000-C000-000000000046}
// *********************************************************************//
  Attachment = dispinterface
    ['{00063007-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property DisplayName: WideString dispid 12289;
    property FileName: WideString readonly dispid 14084;
    property Parent: IDispatch readonly dispid 113;
    property PathName: WideString readonly dispid 14088;
    property Position: Integer dispid 114;
    property Type_: OlAttachmentType readonly dispid 14085;
    procedure Delete; dispid 105;
    procedure SaveAsFile(const Path: WideString); dispid 104;
  end;

// *********************************************************************//
// Interface: _IAttachments
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006313C-0000-0000-C000-000000000046}
// *********************************************************************//
  _IAttachments = interface(IDispatch)
    ['{0006313C-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant; out Attachment: Attachment): HResult; stdcall;
    function Item(Index: OleVariant; out Attachment: Attachment): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Attachments
// Flags:     (4096) Dispatchable
// GUID:      {0006303C-0000-0000-C000-000000000046}
// *********************************************************************//
  Attachments = dispinterface
    ['{0006303C-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    property Parent: IDispatch readonly dispid 61441;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant): Attachment; dispid 101;
    function Item(Index: OleVariant): Attachment; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
  end;

// *********************************************************************//
// Interface: _IContactItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063121-0000-0000-C000-000000000046}
// *********************************************************************//
  _IContactItem = interface(IDispatch)
    ['{00063121-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_Account(out Account: WideString): HResult; stdcall;
    function Set_Account(const Account: WideString): HResult; stdcall;
    function Get_Anniversary(out Anniversary: TDateTime): HResult; stdcall;
    function Set_Anniversary(Anniversary: TDateTime): HResult; stdcall;
    function Get_AssistantName(out AssistantName: WideString): HResult; stdcall;
    function Set_AssistantName(const AssistantName: WideString): HResult; stdcall;
    function Get_AssistantTelephoneNumber(out AssistantTelephoneNumber: WideString): HResult; stdcall;
    function Set_AssistantTelephoneNumber(const AssistantTelephoneNumber: WideString): HResult; stdcall;
    function Get_Birthday(out Birthday: TDateTime): HResult; stdcall;
    function Set_Birthday(Birthday: TDateTime): HResult; stdcall;
    function Get_Business2TelephoneNumber(out Business2TelephoneNumber: WideString): HResult; stdcall;
    function Set_Business2TelephoneNumber(const Business2TelephoneNumber: WideString): HResult; stdcall;
    function Get_BusinessAddress(out BusinessAddress: WideString): HResult; stdcall;
    function Set_BusinessAddress(const BusinessAddress: WideString): HResult; stdcall;
    function Get_BusinessAddressCity(out BusinessAddressCity: WideString): HResult; stdcall;
    function Set_BusinessAddressCity(const BusinessAddressCity: WideString): HResult; stdcall;
    function Get_BusinessAddressCountry(out BusinessAddressCountry: WideString): HResult; stdcall;
    function Set_BusinessAddressCountry(const BusinessAddressCountry: WideString): HResult; stdcall;
    function Get_BusinessAddressPostalCode(out BusinessAddressPostalCode: WideString): HResult; stdcall;
    function Set_BusinessAddressPostalCode(const BusinessAddressPostalCode: WideString): HResult; stdcall;
    function Get_BusinessAddressPostOfficeBox(out BusinessAddressPostOfficeBox: WideString): HResult; stdcall;
    function Set_BusinessAddressPostOfficeBox(const BusinessAddressPostOfficeBox: WideString): HResult; stdcall;
    function Get_BusinessAddressState(out BusinessAddressState: WideString): HResult; stdcall;
    function Set_BusinessAddressState(const BusinessAddressState: WideString): HResult; stdcall;
    function Get_BusinessAddressStreet(out BusinessAddressStreet: WideString): HResult; stdcall;
    function Set_BusinessAddressStreet(const BusinessAddressStreet: WideString): HResult; stdcall;
    function Get_BusinessFaxNumber(out BusinessFaxNumber: WideString): HResult; stdcall;
    function Set_BusinessFaxNumber(const BusinessFaxNumber: WideString): HResult; stdcall;
    function Get_BusinessHomePage(out BusinessHomePage: WideString): HResult; stdcall;
    function Set_BusinessHomePage(const BusinessHomePage: WideString): HResult; stdcall;
    function Get_BusinessTelephoneNumber(out BusinessTelephoneNumber: WideString): HResult; stdcall;
    function Set_BusinessTelephoneNumber(const BusinessTelephoneNumber: WideString): HResult; stdcall;
    function Get_CallbackTelephoneNumber(out CallbackTelephoneNumber: WideString): HResult; stdcall;
    function Set_CallbackTelephoneNumber(const CallbackTelephoneNumber: WideString): HResult; stdcall;
    function Get_CarTelephoneNumber(out CarTelephoneNumber: WideString): HResult; stdcall;
    function Set_CarTelephoneNumber(const CarTelephoneNumber: WideString): HResult; stdcall;
    function Get_Children(out Children: WideString): HResult; stdcall;
    function Set_Children(const Children: WideString): HResult; stdcall;
    function Get_CompanyAndFullName(out CompanyAndFullName: WideString): HResult; stdcall;
    function Get_CompanyMainTelephoneNumber(out CompanyMainTelephoneNumber: WideString): HResult; stdcall;
    function Set_CompanyMainTelephoneNumber(const CompanyMainTelephoneNumber: WideString): HResult; stdcall;
    function Get_CompanyName(out CompanyName: WideString): HResult; stdcall;
    function Set_CompanyName(const CompanyName: WideString): HResult; stdcall;
    function Get_ComputerNetworkName(out ComputerNetworkName: WideString): HResult; stdcall;
    function Set_ComputerNetworkName(const ComputerNetworkName: WideString): HResult; stdcall;
    function Get_CustomerID(out CustomerID: WideString): HResult; stdcall;
    function Set_CustomerID(const CustomerID: WideString): HResult; stdcall;
    function Get_Department(out Department: WideString): HResult; stdcall;
    function Set_Department(const Department: WideString): HResult; stdcall;
    function Get_Email1Address(out Email1Address: WideString): HResult; stdcall;
    function Set_Email1Address(const Email1Address: WideString): HResult; stdcall;
    function Get_Email1AddressType(out Email1AddressType: WideString): HResult; stdcall;
    function Set_Email1AddressType(const Email1AddressType: WideString): HResult; stdcall;
    function Get_Email1DisplayName(out Email1DisplayName: WideString): HResult; stdcall;
    function Get_Email1EntryID(out Email1EntryID: WideString): HResult; stdcall;
    function Get_Email2Address(out Email2Address: WideString): HResult; stdcall;
    function Set_Email2Address(const Email2Address: WideString): HResult; stdcall;
    function Get_Email2AddressType(out Email2AddressType: WideString): HResult; stdcall;
    function Set_Email2AddressType(const Email2AddressType: WideString): HResult; stdcall;
    function Get_Email2DisplayName(out Email2DisplayName: WideString): HResult; stdcall;
    function Get_Email2EntryID(out Email2EntryID: WideString): HResult; stdcall;
    function Get_Email3Address(out Email3Address: WideString): HResult; stdcall;
    function Set_Email3Address(const Email3Address: WideString): HResult; stdcall;
    function Get_Email3AddressType(out Email3AddressType: WideString): HResult; stdcall;
    function Set_Email3AddressType(const Email3AddressType: WideString): HResult; stdcall;
    function Get_Email3DisplayName(out Email3DisplayName: WideString): HResult; stdcall;
    function Get_Email3EntryID(out Email3EntryID: WideString): HResult; stdcall;
    function Get_FileAs(out FileAs: WideString): HResult; stdcall;
    function Set_FileAs(const FileAs: WideString): HResult; stdcall;
    function Get_FirstName(out FirstName: WideString): HResult; stdcall;
    function Set_FirstName(const FirstName: WideString): HResult; stdcall;
    function Get_FTPSite(out FTPSite: WideString): HResult; stdcall;
    function Set_FTPSite(const FTPSite: WideString): HResult; stdcall;
    function Get_FullName(out FullName: WideString): HResult; stdcall;
    function Set_FullName(const FullName: WideString): HResult; stdcall;
    function Get_FullNameAndCompany(out FullNameAndCompany: WideString): HResult; stdcall;
    function Get_Gender(out Gender: OlGender): HResult; stdcall;
    function Set_Gender(Gender: OlGender): HResult; stdcall;
    function Get_GovernmentIDNumber(out GovernmentIDNumber: WideString): HResult; stdcall;
    function Set_GovernmentIDNumber(const GovernmentIDNumber: WideString): HResult; stdcall;
    function Get_Hobby(out Hobby: WideString): HResult; stdcall;
    function Set_Hobby(const Hobby: WideString): HResult; stdcall;
    function Get_Home2TelephoneNumber(out Home2TelephoneNumber: WideString): HResult; stdcall;
    function Set_Home2TelephoneNumber(const Home2TelephoneNumber: WideString): HResult; stdcall;
    function Get_HomeAddress(out HomeAddress: WideString): HResult; stdcall;
    function Set_HomeAddress(const HomeAddress: WideString): HResult; stdcall;
    function Get_HomeAddressCity(out HomeAddressCity: WideString): HResult; stdcall;
    function Set_HomeAddressCity(const HomeAddressCity: WideString): HResult; stdcall;
    function Get_HomeAddressCountry(out HomeAddressCountry: WideString): HResult; stdcall;
    function Set_HomeAddressCountry(const HomeAddressCountry: WideString): HResult; stdcall;
    function Get_HomeAddressPostalCode(out HomeAddressPostalCode: WideString): HResult; stdcall;
    function Set_HomeAddressPostalCode(const HomeAddressPostalCode: WideString): HResult; stdcall;
    function Get_HomeAddressPostOfficeBox(out HomeAddressPostOfficeBox: WideString): HResult; stdcall;
    function Set_HomeAddressPostOfficeBox(const HomeAddressPostOfficeBox: WideString): HResult; stdcall;
    function Get_HomeAddressState(out HomeAddressState: WideString): HResult; stdcall;
    function Set_HomeAddressState(const HomeAddressState: WideString): HResult; stdcall;
    function Get_HomeAddressStreet(out HomeAddressStreet: WideString): HResult; stdcall;
    function Set_HomeAddressStreet(const HomeAddressStreet: WideString): HResult; stdcall;
    function Get_HomeFaxNumber(out HomeFaxNumber: WideString): HResult; stdcall;
    function Set_HomeFaxNumber(const HomeFaxNumber: WideString): HResult; stdcall;
    function Get_HomeTelephoneNumber(out HomeTelephoneNumber: WideString): HResult; stdcall;
    function Set_HomeTelephoneNumber(const HomeTelephoneNumber: WideString): HResult; stdcall;
    function Get_Initials(out Initials: WideString): HResult; stdcall;
    function Set_Initials(const Initials: WideString): HResult; stdcall;
    function Get_ISDNNumber(out ISDNNumber: WideString): HResult; stdcall;
    function Set_ISDNNumber(const ISDNNumber: WideString): HResult; stdcall;
    function Get_JobTitle(out JobTitle: WideString): HResult; stdcall;
    function Set_JobTitle(const JobTitle: WideString): HResult; stdcall;
    function Get_Journal(out Journal: WordBool): HResult; stdcall;
    function Set_Journal(Journal: WordBool): HResult; stdcall;
    function Get_Language(out Language: WideString): HResult; stdcall;
    function Set_Language(const Language: WideString): HResult; stdcall;
    function Get_LastName(out LastName: WideString): HResult; stdcall;
    function Set_LastName(const LastName: WideString): HResult; stdcall;
    function Get_LastNameAndFirstName(out LastNameAndFirstName: WideString): HResult; stdcall;
    function Get_MailingAddress(out MailingAddress: WideString): HResult; stdcall;
    function Set_MailingAddress(const MailingAddress: WideString): HResult; stdcall;
    function Get_MailingAddressCity(out MailingAddressCity: WideString): HResult; stdcall;
    function Set_MailingAddressCity(const MailingAddressCity: WideString): HResult; stdcall;
    function Get_MailingAddressCountry(out MailingAddressCountry: WideString): HResult; stdcall;
    function Set_MailingAddressCountry(const MailingAddressCountry: WideString): HResult; stdcall;
    function Get_MailingAddressPostalCode(out MailingAddressPostalCode: WideString): HResult; stdcall;
    function Set_MailingAddressPostalCode(const MailingAddressPostalCode: WideString): HResult; stdcall;
    function Get_MailingAddressPostOfficeBox(out MailingAddressPostOfficeBox: WideString): HResult; stdcall;
    function Set_MailingAddressPostOfficeBox(const MailingAddressPostOfficeBox: WideString): HResult; stdcall;
    function Get_MailingAddressState(out MailingAddressState: WideString): HResult; stdcall;
    function Set_MailingAddressState(const MailingAddressState: WideString): HResult; stdcall;
    function Get_MailingAddressStreet(out MailingAddressStreet: WideString): HResult; stdcall;
    function Set_MailingAddressStreet(const MailingAddressStreet: WideString): HResult; stdcall;
    function Get_ManagerName(out ManagerName: WideString): HResult; stdcall;
    function Set_ManagerName(const ManagerName: WideString): HResult; stdcall;
    function Get_MiddleName(out MiddleName: WideString): HResult; stdcall;
    function Set_MiddleName(const MiddleName: WideString): HResult; stdcall;
    function Get_MobileTelephoneNumber(out MobileTelephoneNumber: WideString): HResult; stdcall;
    function Set_MobileTelephoneNumber(const MobileTelephoneNumber: WideString): HResult; stdcall;
    function Get_NickName(out NickName: WideString): HResult; stdcall;
    function Set_NickName(const NickName: WideString): HResult; stdcall;
    function Get_OfficeLocation(out OfficeLocation: WideString): HResult; stdcall;
    function Set_OfficeLocation(const OfficeLocation: WideString): HResult; stdcall;
    function Get_OrganizationalIDNumber(out OrganizationalIDNumber: WideString): HResult; stdcall;
    function Set_OrganizationalIDNumber(const OrganizationalIDNumber: WideString): HResult; stdcall;
    function Get_OtherAddress(out OtherAddress: WideString): HResult; stdcall;
    function Set_OtherAddress(const OtherAddress: WideString): HResult; stdcall;
    function Get_OtherAddressCity(out OtherAddressCity: WideString): HResult; stdcall;
    function Set_OtherAddressCity(const OtherAddressCity: WideString): HResult; stdcall;
    function Get_OtherAddressCountry(out OtherAddressCountry: WideString): HResult; stdcall;
    function Set_OtherAddressCountry(const OtherAddressCountry: WideString): HResult; stdcall;
    function Get_OtherAddressPostalCode(out OtherAddressPostalCode: WideString): HResult; stdcall;
    function Set_OtherAddressPostalCode(const OtherAddressPostalCode: WideString): HResult; stdcall;
    function Get_OtherAddressPostOfficeBox(out OtherAddressPostOfficeBox: WideString): HResult; stdcall;
    function Set_OtherAddressPostOfficeBox(const OtherAddressPostOfficeBox: WideString): HResult; stdcall;
    function Get_OtherAddressState(out OtherAddressState: WideString): HResult; stdcall;
    function Set_OtherAddressState(const OtherAddressState: WideString): HResult; stdcall;
    function Get_OtherAddressStreet(out OtherAddressStreet: WideString): HResult; stdcall;
    function Set_OtherAddressStreet(const OtherAddressStreet: WideString): HResult; stdcall;
    function Get_OtherFaxNumber(out OtherFaxNumber: WideString): HResult; stdcall;
    function Set_OtherFaxNumber(const OtherFaxNumber: WideString): HResult; stdcall;
    function Get_OtherTelephoneNumber(out OtherTelephoneNumber: WideString): HResult; stdcall;
    function Set_OtherTelephoneNumber(const OtherTelephoneNumber: WideString): HResult; stdcall;
    function Get_PagerNumber(out PagerNumber: WideString): HResult; stdcall;
    function Set_PagerNumber(const PagerNumber: WideString): HResult; stdcall;
    function Get_PersonalHomePage(out PersonalHomePage: WideString): HResult; stdcall;
    function Set_PersonalHomePage(const PersonalHomePage: WideString): HResult; stdcall;
    function Get_PrimaryTelephoneNumber(out PrimaryTelephoneNumber: WideString): HResult; stdcall;
    function Set_PrimaryTelephoneNumber(const PrimaryTelephoneNumber: WideString): HResult; stdcall;
    function Get_Profession(out Profession: WideString): HResult; stdcall;
    function Set_Profession(const Profession: WideString): HResult; stdcall;
    function Get_RadioTelephoneNumber(out RadioTelephoneNumber: WideString): HResult; stdcall;
    function Set_RadioTelephoneNumber(const RadioTelephoneNumber: WideString): HResult; stdcall;
    function Get_ReferredBy(out ReferredBy: WideString): HResult; stdcall;
    function Set_ReferredBy(const ReferredBy: WideString): HResult; stdcall;
    function Get_SelectedMailingAddress(out SelectedMailingAddress: OlMailingAddress): HResult; stdcall;
    function Set_SelectedMailingAddress(SelectedMailingAddress: OlMailingAddress): HResult; stdcall;
    function Get_Spouse(out Spouse: WideString): HResult; stdcall;
    function Set_Spouse(const Spouse: WideString): HResult; stdcall;
    function Get_Suffix(out Suffix: WideString): HResult; stdcall;
    function Set_Suffix(const Suffix: WideString): HResult; stdcall;
    function Get_TelexNumber(out TelexNumber: WideString): HResult; stdcall;
    function Set_TelexNumber(const TelexNumber: WideString): HResult; stdcall;
    function Get_Title(out Title: WideString): HResult; stdcall;
    function Set_Title(const Title: WideString): HResult; stdcall;
    function Get_TTYTDDTelephoneNumber(out TTYTDDTelephoneNumber: WideString): HResult; stdcall;
    function Set_TTYTDDTelephoneNumber(const TTYTDDTelephoneNumber: WideString): HResult; stdcall;
    function Get_User1(out User1: WideString): HResult; stdcall;
    function Set_User1(const User1: WideString): HResult; stdcall;
    function Get_User2(out User2: WideString): HResult; stdcall;
    function Set_User2(const User2: WideString): HResult; stdcall;
    function Get_User3(out User3: WideString): HResult; stdcall;
    function Set_User3(const User3: WideString): HResult; stdcall;
    function Get_User4(out User4: WideString): HResult; stdcall;
    function Set_User4(const User4: WideString): HResult; stdcall;
    function Get_UserCertificate(out UserCertificate: WideString): HResult; stdcall;
    function Set_UserCertificate(const UserCertificate: WideString): HResult; stdcall;
    function Get_WebPage(out WebPage: WideString): HResult; stdcall;
    function Set_WebPage(const WebPage: WideString): HResult; stdcall;
    function Get_YomiCompanyName(out YomiCompanyName: WideString): HResult; stdcall;
    function Set_YomiCompanyName(const YomiCompanyName: WideString): HResult; stdcall;
    function Get_YomiFirstName(out YomiFirstName: WideString): HResult; stdcall;
    function Set_YomiFirstName(const YomiFirstName: WideString): HResult; stdcall;
    function Get_YomiLastName(out YomiLastName: WideString): HResult; stdcall;
    function Set_YomiLastName(const YomiLastName: WideString): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DContactItem
// Flags:     (4096) Dispatchable
// GUID:      {00063021-0000-0000-C000-000000000046}
// *********************************************************************//
  _DContactItem = dispinterface
    ['{00063021-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property Account: WideString dispid 14848;
    property Anniversary: TDateTime dispid 14913;
    property AssistantName: WideString dispid 14896;
    property AssistantTelephoneNumber: WideString dispid 14894;
    property Birthday: TDateTime dispid 14914;
    property Business2TelephoneNumber: WideString dispid 14875;
    property BusinessAddress: WideString dispid 32795;
    property BusinessAddressCity: WideString dispid 32838;
    property BusinessAddressCountry: WideString dispid 32841;
    property BusinessAddressPostalCode: WideString dispid 32840;
    property BusinessAddressPostOfficeBox: WideString dispid 32842;
    property BusinessAddressState: WideString dispid 32839;
    property BusinessAddressStreet: WideString dispid 32837;
    property BusinessFaxNumber: WideString dispid 14884;
    property BusinessHomePage: WideString dispid 14929;
    property BusinessTelephoneNumber: WideString dispid 14856;
    property CallbackTelephoneNumber: WideString dispid 14850;
    property CarTelephoneNumber: WideString dispid 14878;
    property Children: WideString dispid 32780;
    property CompanyAndFullName: WideString readonly dispid 32792;
    property CompanyMainTelephoneNumber: WideString dispid 14935;
    property CompanyName: WideString dispid 14870;
    property ComputerNetworkName: WideString dispid 14921;
    property CustomerID: WideString dispid 14922;
    property Department: WideString dispid 14872;
    property Email1Address: WideString dispid 32899;
    property Email1AddressType: WideString dispid 32898;
    property Email1DisplayName: WideString readonly dispid 32896;
    property Email1EntryID: WideString readonly dispid 32901;
    property Email2Address: WideString dispid 32915;
    property Email2AddressType: WideString dispid 32914;
    property Email2DisplayName: WideString readonly dispid 32912;
    property Email2EntryID: WideString readonly dispid 32917;
    property Email3Address: WideString dispid 32931;
    property Email3AddressType: WideString dispid 32930;
    property Email3DisplayName: WideString readonly dispid 32928;
    property Email3EntryID: WideString readonly dispid 32933;
    property FileAs: WideString dispid 32773;
    property FirstName: WideString dispid 14854;
    property FTPSite: WideString dispid 14924;
    property FullName: WideString dispid 12289;
    property FullNameAndCompany: WideString readonly dispid 32793;
    property Gender: OlGender dispid 14925;
    property GovernmentIDNumber: WideString dispid 14855;
    property Hobby: WideString dispid 14915;
    property Home2TelephoneNumber: WideString dispid 14895;
    property HomeAddress: WideString dispid 32794;
    property HomeAddressCity: WideString dispid 14937;
    property HomeAddressCountry: WideString dispid 14938;
    property HomeAddressPostalCode: WideString dispid 14939;
    property HomeAddressPostOfficeBox: WideString dispid 14942;
    property HomeAddressState: WideString dispid 14940;
    property HomeAddressStreet: WideString dispid 14941;
    property HomeFaxNumber: WideString dispid 14885;
    property HomeTelephoneNumber: WideString dispid 14857;
    property Initials: WideString dispid 14858;
    property ISDNNumber: WideString dispid 14893;
    property JobTitle: WideString dispid 14871;
    property Journal: WordBool dispid 32805;
    property Language: WideString dispid 14860;
    property LastName: WideString dispid 14865;
    property LastNameAndFirstName: WideString readonly dispid 32791;
    property MailingAddress: WideString dispid 14869;
    property MailingAddressCity: WideString dispid 14887;
    property MailingAddressCountry: WideString dispid 14886;
    property MailingAddressPostalCode: WideString dispid 14890;
    property MailingAddressPostOfficeBox: WideString dispid 14891;
    property MailingAddressState: WideString dispid 14888;
    property MailingAddressStreet: WideString dispid 14889;
    property ManagerName: WideString dispid 14926;
    property MiddleName: WideString dispid 14916;
    property MobileTelephoneNumber: WideString dispid 14876;
    property NickName: WideString dispid 14927;
    property OfficeLocation: WideString dispid 14873;
    property OrganizationalIDNumber: WideString dispid 14864;
    property OtherAddress: WideString dispid 32796;
    property OtherAddressCity: WideString dispid 14943;
    property OtherAddressCountry: WideString dispid 14944;
    property OtherAddressPostalCode: WideString dispid 14945;
    property OtherAddressPostOfficeBox: WideString dispid 14948;
    property OtherAddressState: WideString dispid 14946;
    property OtherAddressStreet: WideString dispid 14947;
    property OtherFaxNumber: WideString dispid 14883;
    property OtherTelephoneNumber: WideString dispid 14879;
    property PagerNumber: WideString dispid 14881;
    property PersonalHomePage: WideString dispid 14928;
    property PrimaryTelephoneNumber: WideString dispid 14874;
    property Profession: WideString dispid 14918;
    property RadioTelephoneNumber: WideString dispid 14877;
    property ReferredBy: WideString dispid 14919;
    property SelectedMailingAddress: OlMailingAddress dispid 32802;
    property Spouse: WideString dispid 14920;
    property Suffix: WideString dispid 14853;
    property TelexNumber: WideString dispid 14892;
    property Title: WideString dispid 14917;
    property TTYTDDTelephoneNumber: WideString dispid 14923;
    property User1: WideString dispid 32847;
    property User2: WideString dispid 32848;
    property User3: WideString dispid 32849;
    property User4: WideString dispid 32850;
    property UserCertificate: WideString dispid 32790;
    property WebPage: WideString dispid 32811;
    property YomiCompanyName: WideString dispid 32814;
    property YomiFirstName: WideString dispid 32812;
    property YomiLastName: WideString dispid 32813;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
  end;

// *********************************************************************//
// Interface: _IExplorer
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063103-0000-0000-C000-000000000046}
// *********************************************************************//
  _IExplorer = interface(IDispatch)
    ['{00063103-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_CommandBars(out CommandBars: CommandBars): HResult; stdcall;
    function Get_CurrentFolder(out CurrentFolder: MAPIFolder): HResult; stdcall;
    function Set_CurrentFolder(const CurrentFolder: MAPIFolder): HResult; stdcall;
    function Get_Parent(out Parent: Application_): HResult; stdcall;
    function Close: HResult; stdcall;
    function Display: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Explorer
// Flags:     (4096) Dispatchable
// GUID:      {00063003-0000-0000-C000-000000000046}
// *********************************************************************//
  Explorer = dispinterface
    ['{00063003-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property CommandBars: CommandBars readonly dispid 8448;
    property CurrentFolder: MAPIFolder dispid 8449;
    property Parent: Application_ readonly dispid 61441;
    procedure Close; dispid 8451;
    procedure Display; dispid 8452;
  end;

// *********************************************************************//
// Interface: _IFolders
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063140-0000-0000-C000-000000000046}
// *********************************************************************//
  _IFolders = interface(IDispatch)
    ['{00063140-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Add(const Name: WideString; Type_: OleVariant; out Folder: MAPIFolder): HResult; stdcall;
    function Item(Index: OleVariant; out Folder: MAPIFolder): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Folders
// Flags:     (4096) Dispatchable
// GUID:      {00063040-0000-0000-C000-000000000046}
// *********************************************************************//
  Folders = dispinterface
    ['{00063040-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    function Add(const Name: WideString; Type_: OleVariant): MAPIFolder; dispid 100;
    function Item(Index: OleVariant): MAPIFolder; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
  end;

// *********************************************************************//
// Interface: _IFormDescription
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063146-0000-0000-C000-000000000046}
// *********************************************************************//
  _IFormDescription = interface(IDispatch)
    ['{00063146-0000-0000-C000-000000000046}']
    function Get_Category(out Category: WideString): HResult; stdcall;
    function Set_Category(const Category: WideString): HResult; stdcall;
    function Get_CategorySub(out CategorySub: WideString): HResult; stdcall;
    function Set_CategorySub(const CategorySub: WideString): HResult; stdcall;
    function Get_Comment(out Comment: WideString): HResult; stdcall;
    function Set_Comment(const Comment: WideString): HResult; stdcall;
    function Get_ContactName(out ContactName: WideString): HResult; stdcall;
    function Set_ContactName(const ContactName: WideString): HResult; stdcall;
    function Get_DisplayName(out DisplayName: WideString): HResult; stdcall;
    function Set_DisplayName(const DisplayName: WideString): HResult; stdcall;
    function Get_Hidden(out Hidden: WordBool): HResult; stdcall;
    function Set_Hidden(Hidden: WordBool): HResult; stdcall;
    function Get_Icon(out Icon: WideString): HResult; stdcall;
    function Set_Icon(const Icon: WideString): HResult; stdcall;
    function Get_Locked(out Locked: WordBool): HResult; stdcall;
    function Set_Locked(Locked: WordBool): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Get_MiniIcon(out MiniIcon: WideString): HResult; stdcall;
    function Set_MiniIcon(const MiniIcon: WideString): HResult; stdcall;
    function Get_Name(out Name: WideString): HResult; stdcall;
    function Set_Name(const Name: WideString): HResult; stdcall;
    function Get_Number(out Number: WideString): HResult; stdcall;
    function Set_Number(const Number: WideString): HResult; stdcall;
    function Get_OneOff(out OneOff: WordBool): HResult; stdcall;
    function Set_OneOff(OneOff: WordBool): HResult; stdcall;
    function Get_Password(out Password: WideString): HResult; stdcall;
    function Set_Password(const Password: WideString): HResult; stdcall;
    function Get_Template(out Template: WideString): HResult; stdcall;
    function Set_Template(const Template: WideString): HResult; stdcall;
    function Get_UseWordMail(out UseWordMail: WordBool): HResult; stdcall;
    function Set_UseWordMail(UseWordMail: WordBool): HResult; stdcall;
    function Get_Version(out Version: WideString): HResult; stdcall;
    function Set_Version(const Version: WideString): HResult; stdcall;
    function PublishForm(Registry: OlFormRegistry; Folder: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  FormDescription
// Flags:     (4096) Dispatchable
// GUID:      {00063046-0000-0000-C000-000000000046}
// *********************************************************************//
  FormDescription = dispinterface
    ['{00063046-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Category: WideString dispid 13060;
    property CategorySub: WideString dispid 13061;
    property Comment: WideString dispid 12292;
    property ContactName: WideString dispid 13059;
    property DisplayName: WideString dispid 12289;
    property Hidden: WordBool dispid 13063;
    property Icon: WideString dispid 4093;
    property Locked: WordBool dispid 102;
    property MessageClass: WideString readonly dispid 26;
    property MiniIcon: WideString dispid 4092;
    property Name: WideString dispid 61469;
    property Number: WideString dispid 104;
    property OneOff: WordBool dispid 101;
    property Password: WideString dispid 103;
    property Template: WideString dispid 106;
    property UseWordMail: WordBool dispid 105;
    property Version: WideString dispid 13057;
    procedure PublishForm(Registry: OlFormRegistry; Folder: OleVariant); dispid 107;
  end;

// *********************************************************************//
// Interface: _IInspector
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063105-0000-0000-C000-000000000046}
// *********************************************************************//
  _IInspector = interface(IDispatch)
    ['{00063105-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_CommandBars(out CommandBars: CommandBars): HResult; stdcall;
    function Get_CurrentItem(out CurrentItem: IDispatch): HResult; stdcall;
    function Get_ModifiedFormPages(out ModifiedFormPages: Pages): HResult; stdcall;
    function Get_Parent(out Parent: Application_): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function HideFormPage(const PageName: WideString): HResult; stdcall;
    function IsWordMail(out IsWordMail: WordBool): HResult; stdcall;
    function SetCurrentFormPage(const PageName: WideString): HResult; stdcall;
    function ShowFormPage(const PageName: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Inspector
// Flags:     (4096) Dispatchable
// GUID:      {00063005-0000-0000-C000-000000000046}
// *********************************************************************//
  Inspector = dispinterface
    ['{00063005-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property CommandBars: CommandBars readonly dispid 8448;
    property CurrentItem: IDispatch readonly dispid 8450;
    property ModifiedFormPages: Pages readonly dispid 8454;
    property Parent: Application_ readonly dispid 61441;
    procedure Close(SaveMode: OlInspectorClose); dispid 8451;
    procedure Display(Modal: OleVariant); dispid 8452;
    procedure HideFormPage(const PageName: WideString); dispid 8456;
    function IsWordMail: WordBool; dispid 8453;
    procedure SetCurrentFormPage(const PageName: WideString); dispid 8460;
    procedure ShowFormPage(const PageName: WideString); dispid 8457;
  end;

// *********************************************************************//
// Interface: _IItems
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063141-0000-0000-C000-000000000046}
// *********************************************************************//
  _IItems = interface(IDispatch)
    ['{00063141-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Get_IncludeRecurrences(out IncludeRecurrences: WordBool): HResult; stdcall;
    function Set_IncludeRecurrences(IncludeRecurrences: WordBool): HResult; stdcall;
    function Add(Type_: OleVariant; out Item: IDispatch): HResult; stdcall;
    function Find(const Filter: WideString; out Item: IDispatch): HResult; stdcall;
    function FindNext(out Item: IDispatch): HResult; stdcall;
    function Item(Index: OleVariant; out Item: IDispatch): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
    function Restrict(const Filter: WideString; out Items: Items): HResult; stdcall;
    function Sort(const Property_: WideString; Descending: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Items
// Flags:     (4096) Dispatchable
// GUID:      {00063041-0000-0000-C000-000000000046}
// *********************************************************************//
  Items = dispinterface
    ['{00063041-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    property IncludeRecurrences: WordBool dispid 206;
    function Add(Type_: OleVariant): IDispatch; dispid 200;
    function Find(const Filter: WideString): IDispatch; dispid 203;
    function FindNext: IDispatch; dispid 204;
    function Item(Index: OleVariant): IDispatch; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
    function Restrict(const Filter: WideString): Items; dispid 202;
    procedure Sort(const Property_: WideString; Descending: OleVariant); dispid 205;
  end;

// *********************************************************************//
// Interface: _IJournalItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063122-0000-0000-C000-000000000046}
// *********************************************************************//
  _IJournalItem = interface(IDispatch)
    ['{00063122-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_ContactNames(out ContactNames: WideString): HResult; stdcall;
    function Set_ContactNames(const ContactNames: WideString): HResult; stdcall;
    function Get_DocPosted(out DocPosted: WordBool): HResult; stdcall;
    function Set_DocPosted(DocPosted: WordBool): HResult; stdcall;
    function Get_DocPrinted(out DocPrinted: WordBool): HResult; stdcall;
    function Set_DocPrinted(DocPrinted: WordBool): HResult; stdcall;
    function Get_DocRouted(out DocRouted: WordBool): HResult; stdcall;
    function Set_DocRouted(DocRouted: WordBool): HResult; stdcall;
    function Get_DocSaved(out DocSaved: WordBool): HResult; stdcall;
    function Set_DocSaved(DocSaved: WordBool): HResult; stdcall;
    function Get_Duration(out Duration: Integer): HResult; stdcall;
    function Set_Duration(Duration: Integer): HResult; stdcall;
    function Get_End_(out End_: TDateTime): HResult; stdcall;
    function Set_End_(End_: TDateTime): HResult; stdcall;
    function Get_Recipients(out Recipients: Recipients): HResult; stdcall;
    function Get_Start(out Start: TDateTime): HResult; stdcall;
    function Set_Start(Start: TDateTime): HResult; stdcall;
    function Get_Type_(out Type_: WideString): HResult; stdcall;
    function Set_Type_(const Type_: WideString): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function Forward(out Item: MailItem): HResult; stdcall;
    function Reply(out Item: MailItem): HResult; stdcall;
    function ReplyAll(out Item: MailItem): HResult; stdcall;
    function StartTimer: HResult; stdcall;
    function StopTimer: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DJournalItem
// Flags:     (4096) Dispatchable
// GUID:      {00063022-0000-0000-C000-000000000046}
// *********************************************************************//
  _DJournalItem = dispinterface
    ['{00063022-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property ContactNames: WideString dispid 3588;
    property DocPosted: WordBool dispid 34577;
    property DocPrinted: WordBool dispid 34574;
    property DocRouted: WordBool dispid 34576;
    property DocSaved: WordBool dispid 34575;
    property Duration: Integer dispid 34567;
    property End_: TDateTime dispid 34568;
    property Recipients: Recipients readonly dispid 63508;
    property Start: TDateTime dispid 34566;
    property Type_: WideString dispid 34560;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function Forward: MailItem; dispid 63507;
    function Reply: MailItem; dispid 63504;
    function ReplyAll: MailItem; dispid 63505;
    procedure StartTimer; dispid 63269;
    procedure StopTimer; dispid 63270;
  end;

// *********************************************************************//
// Interface: _IMailItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063134-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMailItem = interface(IDispatch)
    ['{00063134-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_AlternateRecipientAllowed(out AlternateRecipientAllowed: WordBool): HResult; stdcall;
    function Set_AlternateRecipientAllowed(AlternateRecipientAllowed: WordBool): HResult; stdcall;
    function Get_AutoForwarded(out AutoForwarded: WordBool): HResult; stdcall;
    function Set_AutoForwarded(AutoForwarded: WordBool): HResult; stdcall;
    function Get_BCC(out BCC: WideString): HResult; stdcall;
    function Set_BCC(const BCC: WideString): HResult; stdcall;
    function Get_CC(out CC: WideString): HResult; stdcall;
    function Set_CC(const CC: WideString): HResult; stdcall;
    function Get_ConversationIndex(out ConversationIndex: WideString): HResult; stdcall;
    function Get_ConversationTopic(out ConversationTopic: WideString): HResult; stdcall;
    function Get_DeferredDeliveryTime(out DeferredDeliveryTime: TDateTime): HResult; stdcall;
    function Set_DeferredDeliveryTime(DeferredDeliveryTime: TDateTime): HResult; stdcall;
    function Get_DeleteAfterSubmit(out DeleteAfterSubmit: WordBool): HResult; stdcall;
    function Set_DeleteAfterSubmit(DeleteAfterSubmit: WordBool): HResult; stdcall;
    function Get_ExpiryTime(out ExpiryTime: TDateTime): HResult; stdcall;
    function Set_ExpiryTime(ExpiryTime: TDateTime): HResult; stdcall;
    function Get_FlagDueBy(out FlagDueBy: TDateTime): HResult; stdcall;
    function Set_FlagDueBy(FlagDueBy: TDateTime): HResult; stdcall;
    function Get_FlagRequest(out FlagRequest: WideString): HResult; stdcall;
    function Set_FlagRequest(const FlagRequest: WideString): HResult; stdcall;
    function Get_FlagStatus(out FlagStatus: OlFlagStatus): HResult; stdcall;
    function Set_FlagStatus(FlagStatus: OlFlagStatus): HResult; stdcall;
    function Get_OriginatorDeliveryReportRequested(out OriginatorDeliveryReportRequested: WordBool): HResult; stdcall;
    function Set_OriginatorDeliveryReportRequested(OriginatorDeliveryReportRequested: WordBool): HResult; stdcall;
    function Get_ReadReceiptRequested(out ReadReceiptRequested: WordBool): HResult; stdcall;
    function Set_ReadReceiptRequested(ReadReceiptRequested: WordBool): HResult; stdcall;
    function Get_ReceivedByEntryID(out ReceivedByEntryID: WideString): HResult; stdcall;
    function Get_ReceivedByName(out ReceivedByName: WideString): HResult; stdcall;
    function Get_ReceivedOnBehalfOfEntryID(out ReceivedOnBehalfOfEntryID: WideString): HResult; stdcall;
    function Get_ReceivedOnBehalfOfName(out ReceivedOnBehalfOfName: WideString): HResult; stdcall;
    function Get_ReceivedTime(out ReceivedTime: TDateTime): HResult; stdcall;
    function Get_RecipientReassignmentProhibited(out RecipientReassignmentProhibited: WordBool): HResult; stdcall;
    function Set_RecipientReassignmentProhibited(RecipientReassignmentProhibited: WordBool): HResult; stdcall;
    function Get_Recipients(out Recipients: Recipients): HResult; stdcall;
    function Get_ReminderOverrideDefault(out ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Set_ReminderOverrideDefault(ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Get_ReminderPlaySound(out ReminderPlaySound: WordBool): HResult; stdcall;
    function Set_ReminderPlaySound(ReminderPlaySound: WordBool): HResult; stdcall;
    function Get_ReminderSet(out ReminderSet: WordBool): HResult; stdcall;
    function Set_ReminderSet(ReminderSet: WordBool): HResult; stdcall;
    function Get_ReminderSoundFile(out ReminderSoundFile: WideString): HResult; stdcall;
    function Set_ReminderSoundFile(const ReminderSoundFile: WideString): HResult; stdcall;
    function Get_ReminderTime(out ReminderTime: TDateTime): HResult; stdcall;
    function Set_ReminderTime(ReminderTime: TDateTime): HResult; stdcall;
    function Get_RemoteStatus(out RemoteStatus: OlRemoteStatus): HResult; stdcall;
    function Get_ReplyRecipientNames(out ReplyRecipientNames: WideString): HResult; stdcall;
    function Get_ReplyRecipients(out ReplyRecipients: Recipients): HResult; stdcall;
    function Get_SaveSentMessageFolder(out SaveSentMessageFolder: MAPIFolder): HResult; stdcall;
    function Set_SaveSentMessageFolder(const SaveSentMessageFolder: MAPIFolder): HResult; stdcall;
    function Get_SenderName(out SenderName: WideString): HResult; stdcall;
    function Get_SentOn(out SentOn: TDateTime): HResult; stdcall;
    function Get_SentOnBehalfOfName(out SentOnBehalfOfName: WideString): HResult; stdcall;
    function Set_SentOnBehalfOfName(const SentOnBehalfOfName: WideString): HResult; stdcall;
    function Get_To_(out To_: WideString): HResult; stdcall;
    function Set_To_(const To_: WideString): HResult; stdcall;
    function Get_VotingOptions(out VotingOptions: WideString): HResult; stdcall;
    function Set_VotingOptions(const VotingOptions: WideString): HResult; stdcall;
    function Get_VotingResponse(out VotingResponse: WideString): HResult; stdcall;
    function Set_VotingResponse(const VotingResponse: WideString): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function ClearConversationIndex: HResult; stdcall;
    function Forward(out Item: MailItem): HResult; stdcall;
    function Reply(out Item: MailItem): HResult; stdcall;
    function ReplyAll(out Item: MailItem): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMailItem
// Flags:     (4096) Dispatchable
// GUID:      {00063034-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMailItem = dispinterface
    ['{00063034-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property AlternateRecipientAllowed: WordBool dispid 2;
    property AutoForwarded: WordBool dispid 5;
    property BCC: WideString dispid 3586;
    property CC: WideString dispid 3587;
    property ConversationIndex: WideString readonly dispid 113;
    property ConversationTopic: WideString readonly dispid 112;
    property DeferredDeliveryTime: TDateTime dispid 15;
    property DeleteAfterSubmit: WordBool dispid 3585;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 48;
    property FlagRequest: WideString dispid 34096;
    property FlagStatus: OlFlagStatus dispid 4240;
    property OriginatorDeliveryReportRequested: WordBool dispid 35;
    property ReadReceiptRequested: WordBool dispid 41;
    property ReceivedByEntryID: WideString readonly dispid 63;
    property ReceivedByName: WideString readonly dispid 64;
    property ReceivedOnBehalfOfEntryID: WideString readonly dispid 67;
    property ReceivedOnBehalfOfName: WideString readonly dispid 68;
    property ReceivedTime: TDateTime readonly dispid 3590;
    property RecipientReassignmentProhibited: WordBool dispid 43;
    property Recipients: Recipients readonly dispid 63508;
    property ReminderOverrideDefault: WordBool dispid 34076;
    property ReminderPlaySound: WordBool dispid 34078;
    property ReminderSet: WordBool dispid 34051;
    property ReminderSoundFile: WideString dispid 34079;
    property ReminderTime: TDateTime dispid 34050;
    property RemoteStatus: OlRemoteStatus readonly dispid 34065;
    property ReplyRecipientNames: WideString readonly dispid 80;
    property ReplyRecipients: Recipients readonly dispid 61459;
    property SaveSentMessageFolder: MAPIFolder dispid 62465;
    property SenderName: WideString readonly dispid 3098;
    property SentOn: TDateTime readonly dispid 57;
    property SentOnBehalfOfName: WideString dispid 66;
    property To_: WideString dispid 3588;
    property VotingOptions: WideString dispid 61467;
    property VotingResponse: WideString dispid 34084;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    procedure ClearConversationIndex; dispid 63522;
    function Forward: MailItem; dispid 63507;
    function Reply: MailItem; dispid 63504;
    function ReplyAll: MailItem; dispid 63505;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _IMAPIFolder
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063106-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMAPIFolder = interface(IDispatch)
    ['{00063106-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_DefaultItemType(out DefaultItemType: OlItems): HResult; stdcall;
    function Get_DefaultMessageClass(out DefaultMessageClass: WideString): HResult; stdcall;
    function Get_Description(out Description: WideString): HResult; stdcall;
    function Set_Description(const Description: WideString): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_Folders(out Folders: Folders): HResult; stdcall;
    function Get_Items(out Items: Items): HResult; stdcall;
    function Get_Name(out Name: WideString): HResult; stdcall;
    function Set_Name(const Name: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_StoreID(out StoreID: WideString): HResult; stdcall;
    function Get_UnReadItemCount(out UnReadItemCount: Integer): HResult; stdcall;
    function CopyTo(const DestinationFolder: MAPIFolder; out Folder: MAPIFolder): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display: HResult; stdcall;
    function GetExplorer(DisplayMode: OleVariant; out Explorer: Explorer): HResult; stdcall;
    function MoveTo(const DestinationFolder: MAPIFolder): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  MAPIFolder
// Flags:     (4096) Dispatchable
// GUID:      {00063006-0000-0000-C000-000000000046}
// *********************************************************************//
  MAPIFolder = dispinterface
    ['{00063006-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property DefaultItemType: OlItems readonly dispid 12550;
    property DefaultMessageClass: WideString readonly dispid 12551;
    property Description: WideString dispid 12292;
    property EntryID: WideString readonly dispid 61470;
    property Folders: Folders readonly dispid 8451;
    property Items: Items readonly dispid 12544;
    property Name: WideString dispid 12289;
    property Parent: IDispatch readonly dispid 61441;
    property StoreID: WideString readonly dispid 12552;
    property UnReadItemCount: Integer readonly dispid 13827;
    function CopyTo(const DestinationFolder: MAPIFolder): MAPIFolder; dispid 61490;
    procedure Delete; dispid 61509;
    procedure Display; dispid 12548;
    function GetExplorer(DisplayMode: OleVariant): Explorer; dispid 12545;
    procedure MoveTo(const DestinationFolder: MAPIFolder); dispid 61492;
  end;

// *********************************************************************//
// Interface: _IMeetingCanceledItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063128-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMeetingCanceledItem = interface(IDispatch)
    ['{00063128-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedAppointment(AddToCalendar: WordBool; out AppointmentItem: AppointmentItem): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMeetingCanceledItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063028-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMeetingCanceledItem = dispinterface
    ['{00063028-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedAppointment(AddToCalendar: WordBool): AppointmentItem; dispid 63328;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _IMeetingRequestAcceptedItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063130-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMeetingRequestAcceptedItem = interface(IDispatch)
    ['{00063130-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedAppointment(AddToCalendar: WordBool; out AppointmentItem: AppointmentItem): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMeetingRequestAcceptedItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063030-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMeetingRequestAcceptedItem = dispinterface
    ['{00063030-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedAppointment(AddToCalendar: WordBool): AppointmentItem; dispid 63328;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _IMeetingRequestDeclinedItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063131-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMeetingRequestDeclinedItem = interface(IDispatch)
    ['{00063131-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedAppointment(AddToCalendar: WordBool; out AppointmentItem: AppointmentItem): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMeetingRequestDeclinedItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063031-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMeetingRequestDeclinedItem = dispinterface
    ['{00063031-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedAppointment(AddToCalendar: WordBool): AppointmentItem; dispid 63328;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _IMeetingRequestItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063129-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMeetingRequestItem = interface(IDispatch)
    ['{00063129-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedAppointment(AddToCalendar: WordBool; out AppointmentItem: AppointmentItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMeetingRequestItem
// Flags:     (4096) Dispatchable
// GUID:      {00063029-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMeetingRequestItem = dispinterface
    ['{00063029-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedAppointment(AddToCalendar: WordBool): AppointmentItem; dispid 63328;
  end;

// *********************************************************************//
// Interface: _IMeetingRequestTentativeItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063132-0000-0000-C000-000000000046}
// *********************************************************************//
  _IMeetingRequestTentativeItem = interface(IDispatch)
    ['{00063132-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedAppointment(AddToCalendar: WordBool; out AppointmentItem: AppointmentItem): HResult; stdcall;
    function Send: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DMeetingRequestTentativeItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063032-0000-0000-C000-000000000046}
// *********************************************************************//
  _DMeetingRequestTentativeItem = dispinterface
    ['{00063032-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedAppointment(AddToCalendar: WordBool): AppointmentItem; dispid 63328;
    procedure Send; dispid 61557;
  end;

// *********************************************************************//
// Interface: _INameSpace
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063102-0000-0000-C000-000000000046}
// *********************************************************************//
  _INameSpace = interface(IDispatch)
    ['{00063102-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_CurrentUser(out CurrentUser: Recipient): HResult; stdcall;
    function Get_Folders(out Folders: Folders): HResult; stdcall;
    function Get_Parent(out Parent: Application_): HResult; stdcall;
    function Get_Type_(out Type_: WideString): HResult; stdcall;
    function CreateRecipient(const RecipientName: WideString; out Recipient: Recipient): HResult; stdcall;
    function DoRemoteRefresh: HResult; stdcall;
    function GetDefaultFolder(FolderType: OlDefaultFolders; out Folder: MAPIFolder): HResult; stdcall;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant; 
                             out Folder: MAPIFolder): HResult; stdcall;
    function GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant; 
                           out Item: IDispatch): HResult; stdcall;
    function GetRecipientFromID(const EntryID: WideString; out Recipient: Recipient): HResult; stdcall;
    function GetSharedDefaultFolder(const Recipient: Recipient; FolderType: OlDefaultFolders; 
                                    out Folder: MAPIFolder): HResult; stdcall;
    function Logoff: HResult; stdcall;
    function Logon(Profile: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                   NewSession: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  NameSpace
// Flags:     (4096) Dispatchable
// GUID:      {00063002-0000-0000-C000-000000000046}
// *********************************************************************//
  NameSpace = dispinterface
    ['{00063002-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property CurrentUser: Recipient readonly dispid 8449;
    property Folders: Folders readonly dispid 8451;
    property Parent: Application_ readonly dispid 61441;
    property Type_: WideString readonly dispid 8452;
    function CreateRecipient(const RecipientName: WideString): Recipient; dispid 8458;
    procedure DoRemoteRefresh; dispid 8471;
    function GetDefaultFolder(FolderType: OlDefaultFolders): MAPIFolder; dispid 8459;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant): MAPIFolder; dispid 8456;
    function GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant): IDispatch; dispid 8457;
    function GetRecipientFromID(const EntryID: WideString): Recipient; dispid 8455;
    function GetSharedDefaultFolder(const Recipient: Recipient; FolderType: OlDefaultFolders): MAPIFolder; dispid 8460;
    procedure Logoff; dispid 8454;
    procedure Logon(Profile: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant); dispid 8453;
  end;

// *********************************************************************//
// Interface: _INoteItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063125-0000-0000-C000-000000000046}
// *********************************************************************//
  _INoteItem = interface(IDispatch)
    ['{00063125-0000-0000-C000-000000000046}']
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Color(out Color: OlNoteColor): HResult; stdcall;
    function Set_Color(Color: OlNoteColor): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Height(out Height: Integer): HResult; stdcall;
    function Set_Height(Height: Integer): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_Left(out Left: Integer): HResult; stdcall;
    function Set_Left(Left: Integer): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Parent(out Parent: MAPIFolder): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Get_Top(out Top: Integer): HResult; stdcall;
    function Set_Top(Top: Integer): HResult; stdcall;
    function Get_Width(out Width: Integer): HResult; stdcall;
    function Set_Width(Width: Integer): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DNoteItem
// Flags:     (4096) Dispatchable
// GUID:      {00063025-0000-0000-C000-000000000046}
// *********************************************************************//
  _DNoteItem = dispinterface
    ['{00063025-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Application_: Application_ readonly dispid 61440;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Color: OlNoteColor dispid 35584;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property GetInspector: Inspector readonly dispid 61502;
    property Height: Integer dispid 35587;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property Left: Integer dispid 35588;
    property MessageClass: WideString dispid 26;
    property Parent: MAPIFolder readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString readonly dispid 63392;
    property Top: Integer dispid 35589;
    property Width: Integer dispid 35586;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
  end;

// *********************************************************************//
// Interface: _IOfficeDocumentItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063120-0000-0000-C000-000000000046}
// *********************************************************************//
  _IOfficeDocumentItem = interface(IDispatch)
    ['{00063120-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DOfficeDocumentItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063020-0000-0000-C000-000000000046}
// *********************************************************************//
  _DOfficeDocumentItem = dispinterface
    ['{00063020-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
  end;

// *********************************************************************//
// Interface: _IPages
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006313F-0000-0000-C000-000000000046}
// *********************************************************************//
  _IPages = interface(IDispatch)
    ['{0006313F-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Add(Name: OleVariant; out Page: Page): HResult; stdcall;
    function Item(Index: OleVariant; out Page: Page): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Pages
// Flags:     (4096) Dispatchable
// GUID:      {0006303F-0000-0000-C000-000000000046}
// *********************************************************************//
  Pages = dispinterface
    ['{0006303F-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    function Add(Name: OleVariant): Page; dispid 300;
    function Item(Index: OleVariant): Page; dispid 81;
    procedure Remove(Index: Integer); dispid 301;
  end;

// *********************************************************************//
// Interface: _IPostItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063124-0000-0000-C000-000000000046}
// *********************************************************************//
  _IPostItem = interface(IDispatch)
    ['{00063124-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_ConversationIndex(out ConversationIndex: WideString): HResult; stdcall;
    function Get_ConversationTopic(out ConversationTopic: WideString): HResult; stdcall;
    function Get_ExpiryTime(out ExpiryTime: TDateTime): HResult; stdcall;
    function Set_ExpiryTime(ExpiryTime: TDateTime): HResult; stdcall;
    function Get_ReceivedTime(out ReceivedTime: TDateTime): HResult; stdcall;
    function Get_SenderName(out SenderName: WideString): HResult; stdcall;
    function Get_SentOn(out SentOn: TDateTime): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function ClearConversationIndex: HResult; stdcall;
    function Forward(out Item: MailItem): HResult; stdcall;
    function Post: HResult; stdcall;
    function Reply(out Item: MailItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DPostItem
// Flags:     (4096) Dispatchable
// GUID:      {00063024-0000-0000-C000-000000000046}
// *********************************************************************//
  _DPostItem = dispinterface
    ['{00063024-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property ConversationIndex: WideString readonly dispid 113;
    property ConversationTopic: WideString readonly dispid 112;
    property ExpiryTime: TDateTime dispid 21;
    property ReceivedTime: TDateTime readonly dispid 3590;
    property SenderName: WideString readonly dispid 3098;
    property SentOn: TDateTime readonly dispid 57;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    procedure ClearConversationIndex; dispid 63522;
    function Forward: MailItem; dispid 63507;
    procedure Post; dispid 61557;
    function Reply: MailItem; dispid 63504;
  end;

// *********************************************************************//
// Interface: _IRecipient
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063145-0000-0000-C000-000000000046}
// *********************************************************************//
  _IRecipient = interface(IDispatch)
    ['{00063145-0000-0000-C000-000000000046}']
    function Get_Address(out Address: WideString): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_AutoResponse(out AutoResponse: WideString): HResult; stdcall;
    function Set_AutoResponse(const AutoResponse: WideString): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_MeetingResponseStatus(out MeetingResponseStatus: OlResponseStatus): HResult; stdcall;
    function Set_MeetingResponseStatus(MeetingResponseStatus: OlResponseStatus): HResult; stdcall;
    function Get_Name(out Name: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Resolved(out Resolved: WordBool): HResult; stdcall;
    function Get_TrackingStatus(out TrackingStatus: OlTrackingStatus): HResult; stdcall;
    function Set_TrackingStatus(TrackingStatus: OlTrackingStatus): HResult; stdcall;
    function Get_TrackingStatusTime(out TrackingStatusTime: TDateTime): HResult; stdcall;
    function Set_TrackingStatusTime(TrackingStatusTime: TDateTime): HResult; stdcall;
    function Get_Type_(out Type_: Integer): HResult; stdcall;
    function Set_Type_(Type_: Integer): HResult; stdcall;
    function Delete: HResult; stdcall;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant; 
                      out FreeBusyInfo: WideString): HResult; stdcall;
    function Resolve(out Success: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Recipient
// Flags:     (4096) Dispatchable
// GUID:      {00063045-0000-0000-C000-000000000046}
// *********************************************************************//
  Recipient = dispinterface
    ['{00063045-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Address: WideString readonly dispid 12291;
    property Application_: Application_ readonly dispid 61440;
    property AutoResponse: WideString dispid 106;
    property EntryID: WideString readonly dispid 61470;
    property MeetingResponseStatus: OlResponseStatus dispid 102;
    property Name: WideString readonly dispid 12289;
    property Parent: IDispatch readonly dispid 109;
    property Resolved: WordBool readonly dispid 100;
    property TrackingStatus: OlTrackingStatus dispid 118;
    property TrackingStatusTime: TDateTime dispid 119;
    property Type_: Integer dispid 112;
    procedure Delete; dispid 110;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 111;
    function Resolve: WordBool; dispid 113;
  end;

// *********************************************************************//
// Interface: _IRecipients
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006313B-0000-0000-C000-000000000046}
// *********************************************************************//
  _IRecipients = interface(IDispatch)
    ['{0006313B-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Add(const Name: WideString; out Recipient: Recipient): HResult; stdcall;
    function Item(Index: OleVariant; out Recipient: Recipient): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
    function ResolveAll(out Success: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Recipients
// Flags:     (4096) Dispatchable
// GUID:      {0006303B-0000-0000-C000-000000000046}
// *********************************************************************//
  Recipients = dispinterface
    ['{0006303B-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    function Add(const Name: WideString): Recipient; dispid 111;
    function Item(Index: OleVariant): Recipient; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
    function ResolveAll: WordBool; dispid 126;
  end;

// *********************************************************************//
// Interface: _IRecurrencePattern
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063144-0000-0000-C000-000000000046}
// *********************************************************************//
  _IRecurrencePattern = interface(IDispatch)
    ['{00063144-0000-0000-C000-000000000046}']
    function Get_DayOfMonth(out DayOfMonth: Integer): HResult; stdcall;
    function Set_DayOfMonth(DayOfMonth: Integer): HResult; stdcall;
    function Get_DayOfWeekMask(out DayOfWeekMask: OlDaysOfWeek): HResult; stdcall;
    function Set_DayOfWeekMask(DayOfWeekMask: OlDaysOfWeek): HResult; stdcall;
    function Get_Duration(out Duration: Integer): HResult; stdcall;
    function Set_Duration(Duration: Integer): HResult; stdcall;
    function Get_EndTime(out EndTime: TDateTime): HResult; stdcall;
    function Set_EndTime(EndTime: TDateTime): HResult; stdcall;
    function Get_Instance(out Instance: Integer): HResult; stdcall;
    function Set_Instance(Instance: Integer): HResult; stdcall;
    function Get_Interval(out Interval: Integer): HResult; stdcall;
    function Set_Interval(Interval: Integer): HResult; stdcall;
    function Get_MonthOfYear(out MonthOfYear: Integer): HResult; stdcall;
    function Set_MonthOfYear(MonthOfYear: Integer): HResult; stdcall;
    function Get_NoEndDate(out NoEndDate: WordBool): HResult; stdcall;
    function Set_NoEndDate(NoEndDate: WordBool): HResult; stdcall;
    function Get_Occurrences(out Occurrences: Integer): HResult; stdcall;
    function Set_Occurrences(Occurrences: Integer): HResult; stdcall;
    function Get_PatternEndDate(out PatternEndDate: TDateTime): HResult; stdcall;
    function Set_PatternEndDate(PatternEndDate: TDateTime): HResult; stdcall;
    function Get_PatternStartDate(out PatternStartDate: TDateTime): HResult; stdcall;
    function Set_PatternStartDate(PatternStartDate: TDateTime): HResult; stdcall;
    function Get_RecurrenceType(out RecurrenceType: OlRecurrenceType): HResult; stdcall;
    function Set_RecurrenceType(RecurrenceType: OlRecurrenceType): HResult; stdcall;
    function Get_Regenerate(out Regenerate: WordBool): HResult; stdcall;
    function Set_Regenerate(Regenerate: WordBool): HResult; stdcall;
    function Get_StartTime(out StartTime: TDateTime): HResult; stdcall;
    function Set_StartTime(StartTime: TDateTime): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  RecurrencePattern
// Flags:     (4096) Dispatchable
// GUID:      {00063044-0000-0000-C000-000000000046}
// *********************************************************************//
  RecurrencePattern = dispinterface
    ['{00063044-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property DayOfMonth: Integer dispid 4096;
    property DayOfWeekMask: OlDaysOfWeek dispid 4097;
    property Duration: Integer dispid 4109;
    property EndTime: TDateTime dispid 4108;
    property Instance: Integer dispid 4099;
    property Interval: Integer dispid 4100;
    property MonthOfYear: Integer dispid 4102;
    property NoEndDate: WordBool dispid 4107;
    property Occurrences: Integer dispid 4101;
    property PatternEndDate: TDateTime dispid 4098;
    property PatternStartDate: TDateTime dispid 4104;
    property RecurrenceType: OlRecurrenceType dispid 4103;
    property Regenerate: WordBool dispid 4106;
    property StartTime: TDateTime dispid 4105;
  end;

// *********************************************************************//
// Interface: _IRemoteItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063123-0000-0000-C000-000000000046}
// *********************************************************************//
  _IRemoteItem = interface(IDispatch)
    ['{00063123-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_HasAttachment(out HasAttachment: WordBool): HResult; stdcall;
    function Get_RemoteMessageClass(out RemoteMessageClass: WideString): HResult; stdcall;
    function Get_TransferSize(out TransferSize: Integer): HResult; stdcall;
    function Get_TransferTime(out TransferTime: Integer): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DRemoteItem
// Flags:     (4096) Dispatchable
// GUID:      {00063023-0000-0000-C000-000000000046}
// *********************************************************************//
  _DRemoteItem = dispinterface
    ['{00063023-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property HasAttachment: WordBool readonly dispid 36615;
    property RemoteMessageClass: WideString readonly dispid 36610;
    property TransferSize: Integer readonly dispid 36613;
    property TransferTime: Integer readonly dispid 36612;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
  end;

// *********************************************************************//
// Interface: _IReportItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063126-0000-0000-C000-000000000046}
// *********************************************************************//
  _IReportItem = interface(IDispatch)
    ['{00063126-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DReportItem
// Flags:     (4096) Dispatchable
// GUID:      {00063026-0000-0000-C000-000000000046}
// *********************************************************************//
  _DReportItem = dispinterface
    ['{00063026-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
  end;

// *********************************************************************//
// Interface: _ITaskItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063135-0000-0000-C000-000000000046}
// *********************************************************************//
  _ITaskItem = interface(IDispatch)
    ['{00063135-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Get_ActualWork(out ActualWork: Integer): HResult; stdcall;
    function Set_ActualWork(ActualWork: Integer): HResult; stdcall;
    function Get_CardData(out CardData: WideString): HResult; stdcall;
    function Set_CardData(const CardData: WideString): HResult; stdcall;
    function Get_Complete(out Complete: WordBool): HResult; stdcall;
    function Set_Complete(Complete: WordBool): HResult; stdcall;
    function Get_Contacts(out Contacts: WideString): HResult; stdcall;
    function Set_Contacts(const Contacts: WideString): HResult; stdcall;
    function Get_DateCompleted(out DateCompleted: TDateTime): HResult; stdcall;
    function Set_DateCompleted(DateCompleted: TDateTime): HResult; stdcall;
    function Get_DelegationState(out DelegationState: OlTaskDelegationState): HResult; stdcall;
    function Get_Delegator(out Delegator: WideString): HResult; stdcall;
    function Get_DueDate(out DueDate: TDateTime): HResult; stdcall;
    function Set_DueDate(DueDate: TDateTime): HResult; stdcall;
    function Get_IsRecurring(out IsRecurring: WordBool): HResult; stdcall;
    function Get_Ordinal(out Ordinal: Integer): HResult; stdcall;
    function Set_Ordinal(Ordinal: Integer): HResult; stdcall;
    function Get_Owner(out Owner: WideString): HResult; stdcall;
    function Set_Owner(const Owner: WideString): HResult; stdcall;
    function Get_Ownership(out Ownership: OlTaskOwnership): HResult; stdcall;
    function Get_PercentComplete(out PercentComplete: Integer): HResult; stdcall;
    function Set_PercentComplete(PercentComplete: Integer): HResult; stdcall;
    function Get_Recipients(out Recipients: Recipients): HResult; stdcall;
    function Get_ReminderOverrideDefault(out ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Set_ReminderOverrideDefault(ReminderOverrideDefault: WordBool): HResult; stdcall;
    function Get_ReminderPlaySound(out ReminderPlaySound: WordBool): HResult; stdcall;
    function Set_ReminderPlaySound(ReminderPlaySound: WordBool): HResult; stdcall;
    function Get_ReminderSet(out ReminderSet: WordBool): HResult; stdcall;
    function Set_ReminderSet(ReminderSet: WordBool): HResult; stdcall;
    function Get_ReminderSoundFile(out ReminderSoundFile: WideString): HResult; stdcall;
    function Set_ReminderSoundFile(const ReminderSoundFile: WideString): HResult; stdcall;
    function Get_ReminderTime(out ReminderTime: TDateTime): HResult; stdcall;
    function Set_ReminderTime(ReminderTime: TDateTime): HResult; stdcall;
    function Get_ResponseState(out ResponseState: OlTaskResponse): HResult; stdcall;
    function Get_Role(out Role: WideString): HResult; stdcall;
    function Set_Role(const Role: WideString): HResult; stdcall;
    function Get_SchedulePlusPriority(out SchedulePlusPriority: WideString): HResult; stdcall;
    function Set_SchedulePlusPriority(const SchedulePlusPriority: WideString): HResult; stdcall;
    function Get_StartDate(out StartDate: TDateTime): HResult; stdcall;
    function Set_StartDate(StartDate: TDateTime): HResult; stdcall;
    function Get_Status(out Status: OlTaskStatus): HResult; stdcall;
    function Set_Status(Status: OlTaskStatus): HResult; stdcall;
    function Get_StatusOnCompletionRecipients(out StatusOnCompletionRecipients: WideString): HResult; stdcall;
    function Set_StatusOnCompletionRecipients(const StatusOnCompletionRecipients: WideString): HResult; stdcall;
    function Get_StatusUpdateRecipients(out StatusUpdateRecipients: WideString): HResult; stdcall;
    function Set_StatusUpdateRecipients(const StatusUpdateRecipients: WideString): HResult; stdcall;
    function Get_TeamTask(out TeamTask: WordBool): HResult; stdcall;
    function Set_TeamTask(TeamTask: WordBool): HResult; stdcall;
    function Get_TotalWork(out TotalWork: Integer): HResult; stdcall;
    function Set_TotalWork(TotalWork: Integer): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function Assign(out Item: TaskItem): HResult; stdcall;
    function CancelResponseState: HResult; stdcall;
    function ClearRecurrencePattern: HResult; stdcall;
    function GetRecurrencePattern: HResult; stdcall;
    function MarkComplete: HResult; stdcall;
    function Respond(Response: OlTaskResponse; fNoUI: OleVariant; 
                     fAdditionalTextDialog: OleVariant; out Item: TaskItem): HResult; stdcall;
    function Send: HResult; stdcall;
    function SkipRecurrence: WordBool; stdcall;
    function StatusReport(out StatusReport: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DTaskItem
// Flags:     (4096) Dispatchable
// GUID:      {00063035-0000-0000-C000-000000000046}
// *********************************************************************//
  _DTaskItem = dispinterface
    ['{00063035-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    property ActualWork: Integer dispid 33040;
    property CardData: WideString dispid 33067;
    property Complete: WordBool dispid 33052;
    property Contacts: WideString dispid 34106;
    property DateCompleted: TDateTime dispid 33039;
    property DelegationState: OlTaskDelegationState readonly dispid 33066;
    property Delegator: WideString readonly dispid 33057;
    property DueDate: TDateTime dispid 33029;
    property IsRecurring: WordBool readonly dispid 62999;
    property Ordinal: Integer dispid 33059;
    property Owner: WideString dispid 33055;
    property Ownership: OlTaskOwnership readonly dispid 33065;
    property PercentComplete: Integer dispid 63007;
    property Recipients: Recipients readonly dispid 63508;
    property ReminderOverrideDefault: WordBool dispid 34076;
    property ReminderPlaySound: WordBool dispid 34078;
    property ReminderSet: WordBool dispid 34051;
    property ReminderSoundFile: WideString dispid 34079;
    property ReminderTime: TDateTime dispid 34050;
    property ResponseState: OlTaskResponse readonly dispid 63011;
    property Role: WideString dispid 33063;
    property SchedulePlusPriority: WideString dispid 33071;
    property StartDate: TDateTime dispid 33028;
    property Status: OlTaskStatus dispid 33025;
    property StatusOnCompletionRecipients: WideString dispid 3586;
    property StatusUpdateRecipients: WideString dispid 3587;
    property TeamTask: WordBool dispid 33027;
    property TotalWork: Integer dispid 33041;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function Assign: TaskItem; dispid 63008;
    procedure CancelResponseState; dispid 63010;
    procedure ClearRecurrencePattern; dispid 61605;
    procedure GetRecurrencePattern; dispid 61604;
    procedure MarkComplete; dispid 62989;
    function Respond(Response: OlTaskResponse; fNoUI: OleVariant; fAdditionalTextDialog: OleVariant): TaskItem; dispid 63009;
    procedure Send; dispid 61557;
    function SkipRecurrence: WordBool; dispid 63012;
    function StatusReport: IDispatch; dispid 62994;
  end;

// *********************************************************************//
// Interface: _ITaskRequestAcceptItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063138-0000-0000-C000-000000000046}
// *********************************************************************//
  _ITaskRequestAcceptItem = interface(IDispatch)
    ['{00063138-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedTask(AddToTaskList: WordBool; out Item: TaskItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DTaskRequestAcceptItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063038-0000-0000-C000-000000000046}
// *********************************************************************//
  _DTaskRequestAcceptItem = dispinterface
    ['{00063038-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedTask(AddToTaskList: WordBool): TaskItem; dispid 61460;
  end;

// *********************************************************************//
// Interface: _ITaskRequestDeclineItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063139-0000-0000-C000-000000000046}
// *********************************************************************//
  _ITaskRequestDeclineItem = interface(IDispatch)
    ['{00063139-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedTask(AddToTaskList: WordBool; out Item: TaskItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DTaskRequestDeclineItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063039-0000-0000-C000-000000000046}
// *********************************************************************//
  _DTaskRequestDeclineItem = dispinterface
    ['{00063039-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedTask(AddToTaskList: WordBool): TaskItem; dispid 61460;
  end;

// *********************************************************************//
// Interface: _ITaskRequestItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063136-0000-0000-C000-000000000046}
// *********************************************************************//
  _ITaskRequestItem = interface(IDispatch)
    ['{00063136-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedTask(AddToTaskList: WordBool; out Item: TaskItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DTaskRequestItem
// Flags:     (4096) Dispatchable
// GUID:      {00063036-0000-0000-C000-000000000046}
// *********************************************************************//
  _DTaskRequestItem = dispinterface
    ['{00063036-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedTask(AddToTaskList: WordBool): TaskItem; dispid 61460;
  end;

// *********************************************************************//
// Interface: _ITaskRequestUpdateItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063137-0000-0000-C000-000000000046}
// *********************************************************************//
  _ITaskRequestUpdateItem = interface(IDispatch)
    ['{00063137-0000-0000-C000-000000000046}']
    function Get_Actions(out Actions: Actions): HResult; stdcall;
    function Get_Application_(out Application_: Application_): HResult; stdcall;
    function Get_Attachments(out Attachments: Attachments): HResult; stdcall;
    function Get_BillingInformation(out BillingInformation: WideString): HResult; stdcall;
    function Set_BillingInformation(const BillingInformation: WideString): HResult; stdcall;
    function Get_Body(out Body: WideString): HResult; stdcall;
    function Set_Body(const Body: WideString): HResult; stdcall;
    function Get_Categories(out Categories: WideString): HResult; stdcall;
    function Set_Categories(const Categories: WideString): HResult; stdcall;
    function Get_Companies(out Companies: WideString): HResult; stdcall;
    function Set_Companies(const Companies: WideString): HResult; stdcall;
    function Get_CreationTime(out CreationTime: TDateTime): HResult; stdcall;
    function Get_EntryID(out EntryID: WideString): HResult; stdcall;
    function Get_FormDescription(out FormDescription: FormDescription): HResult; stdcall;
    function Get_GetInspector(out GetInspector: Inspector): HResult; stdcall;
    function Get_Importance(out Importance: OlImportance): HResult; stdcall;
    function Set_Importance(Importance: OlImportance): HResult; stdcall;
    function Get_LastModificationTime(out LastModificationTime: TDateTime): HResult; stdcall;
    function Get_MessageClass(out MessageClass: WideString): HResult; stdcall;
    function Set_MessageClass(const MessageClass: WideString): HResult; stdcall;
    function Get_Mileage(out Mileage: WideString): HResult; stdcall;
    function Set_Mileage(const Mileage: WideString): HResult; stdcall;
    function Get_NoAging(out NoAging: WordBool): HResult; stdcall;
    function Set_NoAging(NoAging: WordBool): HResult; stdcall;
    function Get_OutlookInternalVersion(out OutlookInternalVersion: WideString): HResult; stdcall;
    function Get_OutlookVersion(out OutlookVersion: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Saved(out Saved: WordBool): HResult; stdcall;
    function Get_Sensitivity(out Sensitivity: OlSensitivity): HResult; stdcall;
    function Set_Sensitivity(Sensitivity: OlSensitivity): HResult; stdcall;
    function Get_Size(out Size: Integer): HResult; stdcall;
    function Get_Subject(out Subject: WideString): HResult; stdcall;
    function Set_Subject(const Subject: WideString): HResult; stdcall;
    function Get_UnRead(out UnRead: WordBool): HResult; stdcall;
    function Set_UnRead(UnRead: WordBool): HResult; stdcall;
    function Get_UserProperties(out UserProperties: UserProperties): HResult; stdcall;
    function Close(SaveMode: OlInspectorClose): HResult; stdcall;
    function Copy(out Item: IDispatch): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Display(Modal: OleVariant): HResult; stdcall;
    function Move(const DestFldr: MAPIFolder; out Item: IDispatch): HResult; stdcall;
    function Save: HResult; stdcall;
    function SaveAs(const Path: WideString; Type_: OleVariant): HResult; stdcall;
    function PrintOut: HResult; stdcall;
    function GetAssociatedTask(AddToTaskList: WordBool; out Item: TaskItem): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DTaskRequestUpdateItem
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063037-0000-0000-C000-000000000046}
// *********************************************************************//
  _DTaskRequestUpdateItem = dispinterface
    ['{00063037-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Actions: Actions readonly dispid 63511;
    property Application_: Application_ readonly dispid 61440;
    property Attachments: Attachments readonly dispid 63509;
    property BillingInformation: WideString dispid 34101;
    property Body: WideString dispid 37120;
    property Categories: WideString dispid 36865;
    property Companies: WideString dispid 34107;
    property CreationTime: TDateTime readonly dispid 12295;
    property EntryID: WideString readonly dispid 61470;
    property FormDescription: FormDescription readonly dispid 61589;
    property GetInspector: Inspector readonly dispid 61502;
    property Importance: OlImportance dispid 23;
    property LastModificationTime: TDateTime readonly dispid 12296;
    property MessageClass: WideString dispid 26;
    property Mileage: WideString dispid 34100;
    property NoAging: WordBool dispid 34062;
    property OutlookInternalVersion: WideString readonly dispid 34130;
    property OutlookVersion: WideString readonly dispid 34132;
    property Parent: IDispatch readonly dispid 61441;
    property Saved: WordBool readonly dispid 61603;
    property Sensitivity: OlSensitivity dispid 54;
    property Size: Integer readonly dispid 3592;
    property Subject: WideString dispid 55;
    property UnRead: WordBool dispid 61468;
    property UserProperties: UserProperties readonly dispid 63510;
    procedure Close(SaveMode: OlInspectorClose); dispid 61475;
    function Copy: IDispatch; dispid 61490;
    procedure Delete; dispid 61514;
    procedure Display(Modal: OleVariant); dispid 61606;
    function Move(const DestFldr: MAPIFolder): IDispatch; dispid 61492;
    procedure Save; dispid 61512;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    procedure PrintOut; dispid 61491;
    function GetAssociatedTask(AddToTaskList: WordBool): TaskItem; dispid 61460;
  end;

// *********************************************************************//
// Interface: _IUserProperties
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006313D-0000-0000-C000-000000000046}
// *********************************************************************//
  _IUserProperties = interface(IDispatch)
    ['{0006313D-0000-0000-C000-000000000046}']
    function Get_Count(out Count: Integer): HResult; stdcall;
    function Add(const Name: WideString; Type_: OlUserPropertyType; AddToFolderFields: OleVariant; 
                 DisplayFormat: OleVariant; out UserProperty: UserProperty): HResult; stdcall;
    function Find(const Name: WideString; Custom: OleVariant): HResult; stdcall;
    function Item(Index: OleVariant; out UserProperty: UserProperty): HResult; stdcall;
    function Remove(Index: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  UserProperties
// Flags:     (4096) Dispatchable
// GUID:      {0006303D-0000-0000-C000-000000000046}
// *********************************************************************//
  UserProperties = dispinterface
    ['{0006303D-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Count: Integer readonly dispid 80;
    function Add(const Name: WideString; Type_: OlUserPropertyType; AddToFolderFields: OleVariant; 
                 DisplayFormat: OleVariant): UserProperty; dispid 102;
    procedure Find(const Name: WideString; Custom: OleVariant); dispid 103;
    function Item(Index: OleVariant): UserProperty; dispid 81;
    procedure Remove(Index: Integer); dispid 82;
  end;

// *********************************************************************//
// Interface: _IUserProperty
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00063142-0000-0000-C000-000000000046}
// *********************************************************************//
  _IUserProperty = interface(IDispatch)
    ['{00063142-0000-0000-C000-000000000046}']
    function Get_Formula(out Formula: WideString): HResult; stdcall;
    function Set_Formula(const Formula: WideString): HResult; stdcall;
    function Get_Name(out Name: WideString): HResult; stdcall;
    function Get_Parent(out Parent: IDispatch): HResult; stdcall;
    function Get_Type_(out Type_: OlUserPropertyType): HResult; stdcall;
    function Get_ValidationFormula(out ValidationFormula: WideString): HResult; stdcall;
    function Set_ValidationFormula(const ValidationFormula: WideString): HResult; stdcall;
    function Get_ValidationText(out ValidationText: WideString): HResult; stdcall;
    function Set_ValidationText(const ValidationText: WideString): HResult; stdcall;
    function Get_Value(out Value: OleVariant): HResult; stdcall;
    function Set_Value(Value: OleVariant): HResult; stdcall;
    function Delete: HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  UserProperty
// Flags:     (4096) Dispatchable
// GUID:      {00063042-0000-0000-C000-000000000046}
// *********************************************************************//
  UserProperty = dispinterface
    ['{00063042-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Formula: WideString dispid 103;
    property Name: WideString readonly dispid 12289;
    property Parent: IDispatch readonly dispid 61441;
    property Type_: OlUserPropertyType readonly dispid 109;
    property ValidationFormula: WideString dispid 104;
    property ValidationText: WideString dispid 105;
    property Value: OleVariant dispid 0;
    procedure Delete; dispid 108;
  end;

// *********************************************************************//
// Interface: _IRecipientControl
// Flags:     (4112) Hidden Dispatchable
// GUID:      {D87E7E16-6897-11CE-A6C0-00AA00608FAA}
// *********************************************************************//
  _IRecipientControl = interface(IDispatch)
    ['{D87E7E16-6897-11CE-A6C0-00AA00608FAA}']
    function Get_Enabled(out Enabled: WordBool): HResult; stdcall;
    function Set_Enabled(Enabled: WordBool): HResult; stdcall;
    function Get_BackColor(out BackColor: Integer): HResult; stdcall;
    function Set_BackColor(BackColor: Integer): HResult; stdcall;
    function Get_ForeColor(out ForeColor: Integer): HResult; stdcall;
    function Set_ForeColor(ForeColor: Integer): HResult; stdcall;
    function Get_ReadOnly(out ReadOnly: WordBool): HResult; stdcall;
    function Set_ReadOnly(ReadOnly: WordBool): HResult; stdcall;
    function Get_Font(out Font: IFontDisp): HResult; stdcall;
    function Set_Font(const Font: IFontDisp): HResult; stdcall;
    function Get_SpecialEffect(out Effect: Integer): HResult; stdcall;
    function Set_SpecialEffect(Effect: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DRecipientControl
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006F025-0000-0000-C000-000000000046}
// *********************************************************************//
  _DRecipientControl = dispinterface
    ['{0006F025-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property Enabled: WordBool dispid -514;
    property BackColor: Integer dispid -501;
    property ForeColor: Integer dispid -513;
    property ReadOnly: WordBool dispid -2147356664;
    property Font: IFontDisp dispid -512;
    property SpecialEffect: Integer dispid 12;
  end;

// *********************************************************************//
// DispIntf:  _DRecipientControlEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {D87E7E17-6897-11CE-A6C0-00AA00608FAA}
// *********************************************************************//
  _DRecipientControlEvents = dispinterface
    ['{D87E7E17-6897-11CE-A6C0-00AA00608FAA}']
  end;

// *********************************************************************//
// Interface: _IDocSiteControl
// Flags:     (4112) Hidden Dispatchable
// GUID:      {43507DD0-811D-11CE-B565-00AA00608FAA}
// *********************************************************************//
  _IDocSiteControl = interface(IDispatch)
    ['{43507DD0-811D-11CE-B565-00AA00608FAA}']
    function Get_ReadOnly(out ReadOnly: WordBool): HResult; stdcall;
    function Set_ReadOnly(ReadOnly: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  _DDocSiteControl
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0006F026-0000-0000-C000-000000000046}
// *********************************************************************//
  _DDocSiteControl = dispinterface
    ['{0006F026-0000-0000-C000-000000000046}']
    procedure QueryInterface_(var riid: {??TGUID} OleVariant; out ppvObj: {??Pointer} OleVariant); dispid 1610612736;
    function AddRef_: UINT; dispid 1610612737;
    function Release_: UINT; dispid 1610612738;
    procedure GetTypeInfoCount_(out pctinfo: SYSUINT); dispid 1610678272;
    procedure GetTypeInfo_(itinfo: SYSUINT; lcid: UINT; out pptinfo: {??Pointer} OleVariant); dispid 1610678273;
    procedure GetIDsOfNames_(var riid: {??TGUID} OleVariant; rgszNames: {??PPShortint1} OleVariant; 
                             cNames: SYSUINT; lcid: UINT; out rgdispid: Integer); dispid 1610678274;
    procedure Invoke_(dispidMember: Integer; var riid: {??TGUID} OleVariant; lcid: UINT; 
                      wFlags: {??Word} OleVariant; var pdispparams: {??DISPPARAMS} OleVariant; 
                      out pvarResult: OleVariant; out pexcepinfo: {??EXCEPINFO} OleVariant; 
                      out puArgErr: SYSUINT); dispid 1610678275;
    property ReadOnly: WordBool dispid -2147356664;
  end;

// *********************************************************************//
// DispIntf:  _DDocSiteControlEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {50BB9B50-811D-11CE-B565-00AA00608FAA}
// *********************************************************************//
  _DDocSiteControlEvents = dispinterface
    ['{50BB9B50-811D-11CE-B565-00AA00608FAA}']
  end;

  CoApplication_ = class
    class function Create: _DApplication;
    class function CreateRemote(const MachineName: string): _DApplication;
  end;

  CoAppointmentItem = class
    class function Create: _DAppointmentItem;
    class function CreateRemote(const MachineName: string): _DAppointmentItem;
  end;

  CoContactItem = class
    class function Create: _DContactItem;
    class function CreateRemote(const MachineName: string): _DContactItem;
  end;

  CoJournalItem = class
    class function Create: _DJournalItem;
    class function CreateRemote(const MachineName: string): _DJournalItem;
  end;

  CoMailItem = class
    class function Create: _DMailItem;
    class function CreateRemote(const MachineName: string): _DMailItem;
  end;

  Co_MeetingCanceledItem = class
    class function Create: _DMeetingCanceledItem;
    class function CreateRemote(const MachineName: string): _DMeetingCanceledItem;
  end;

  Co_MeetingRequestAcceptedItem = class
    class function Create: _DMeetingRequestAcceptedItem;
    class function CreateRemote(const MachineName: string): _DMeetingRequestAcceptedItem;
  end;

  Co_MeetingRequestDeclinedItem = class
    class function Create: _DMeetingRequestDeclinedItem;
    class function CreateRemote(const MachineName: string): _DMeetingRequestDeclinedItem;
  end;

  CoMeetingRequestItem = class
    class function Create: _DMeetingRequestItem;
    class function CreateRemote(const MachineName: string): _DMeetingRequestItem;
  end;

  Co_MeetingRequestTentativeItem = class
    class function Create: _DMeetingRequestTentativeItem;
    class function CreateRemote(const MachineName: string): _DMeetingRequestTentativeItem;
  end;

  CoNoteItem = class
    class function Create: _DNoteItem;
    class function CreateRemote(const MachineName: string): _DNoteItem;
  end;

  Co_OfficeDocumentItem = class
    class function Create: _DOfficeDocumentItem;
    class function CreateRemote(const MachineName: string): _DOfficeDocumentItem;
  end;

  CoPostItem = class
    class function Create: _DPostItem;
    class function CreateRemote(const MachineName: string): _DPostItem;
  end;

  CoRemoteItem = class
    class function Create: _DRemoteItem;
    class function CreateRemote(const MachineName: string): _DRemoteItem;
  end;

  CoReportItem = class
    class function Create: _DReportItem;
    class function CreateRemote(const MachineName: string): _DReportItem;
  end;

  CoTaskItem = class
    class function Create: _DTaskItem;
    class function CreateRemote(const MachineName: string): _DTaskItem;
  end;

  Co_TaskRequestAcceptItem = class
    class function Create: _DTaskRequestAcceptItem;
    class function CreateRemote(const MachineName: string): _DTaskRequestAcceptItem;
  end;

  Co_TaskRequestDeclineItem = class
    class function Create: _DTaskRequestDeclineItem;
    class function CreateRemote(const MachineName: string): _DTaskRequestDeclineItem;
  end;

  CoTaskRequestItem = class
    class function Create: _DTaskRequestItem;
    class function CreateRemote(const MachineName: string): _DTaskRequestItem;
  end;

  Co_TaskRequestUpdateItem = class
    class function Create: _DTaskRequestUpdateItem;
    class function CreateRemote(const MachineName: string): _DTaskRequestUpdateItem;
  end;

implementation

uses ComObj;

class function CoApplication_.Create: _DApplication;
begin
  Result := CreateComObject(CLASS_Application_) as _DApplication;
end;

class function CoApplication_.CreateRemote(const MachineName: string): _DApplication;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Application_) as _DApplication;
end;

class function CoAppointmentItem.Create: _DAppointmentItem;
begin
  Result := CreateComObject(CLASS_AppointmentItem) as _DAppointmentItem;
end;

class function CoAppointmentItem.CreateRemote(const MachineName: string): _DAppointmentItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AppointmentItem) as _DAppointmentItem;
end;

class function CoContactItem.Create: _DContactItem;
begin
  Result := CreateComObject(CLASS_ContactItem) as _DContactItem;
end;

class function CoContactItem.CreateRemote(const MachineName: string): _DContactItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ContactItem) as _DContactItem;
end;

class function CoJournalItem.Create: _DJournalItem;
begin
  Result := CreateComObject(CLASS_JournalItem) as _DJournalItem;
end;

class function CoJournalItem.CreateRemote(const MachineName: string): _DJournalItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_JournalItem) as _DJournalItem;
end;

class function CoMailItem.Create: _DMailItem;
begin
  Result := CreateComObject(CLASS_MailItem) as _DMailItem;
end;

class function CoMailItem.CreateRemote(const MachineName: string): _DMailItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MailItem) as _DMailItem;
end;

class function Co_MeetingCanceledItem.Create: _DMeetingCanceledItem;
begin
  Result := CreateComObject(CLASS__MeetingCanceledItem) as _DMeetingCanceledItem;
end;

class function Co_MeetingCanceledItem.CreateRemote(const MachineName: string): _DMeetingCanceledItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__MeetingCanceledItem) as _DMeetingCanceledItem;
end;

class function Co_MeetingRequestAcceptedItem.Create: _DMeetingRequestAcceptedItem;
begin
  Result := CreateComObject(CLASS__MeetingRequestAcceptedItem) as _DMeetingRequestAcceptedItem;
end;

class function Co_MeetingRequestAcceptedItem.CreateRemote(const MachineName: string): _DMeetingRequestAcceptedItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__MeetingRequestAcceptedItem) as _DMeetingRequestAcceptedItem;
end;

class function Co_MeetingRequestDeclinedItem.Create: _DMeetingRequestDeclinedItem;
begin
  Result := CreateComObject(CLASS__MeetingRequestDeclinedItem) as _DMeetingRequestDeclinedItem;
end;

class function Co_MeetingRequestDeclinedItem.CreateRemote(const MachineName: string): _DMeetingRequestDeclinedItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__MeetingRequestDeclinedItem) as _DMeetingRequestDeclinedItem;
end;

class function CoMeetingRequestItem.Create: _DMeetingRequestItem;
begin
  Result := CreateComObject(CLASS_MeetingRequestItem) as _DMeetingRequestItem;
end;

class function CoMeetingRequestItem.CreateRemote(const MachineName: string): _DMeetingRequestItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MeetingRequestItem) as _DMeetingRequestItem;
end;

class function Co_MeetingRequestTentativeItem.Create: _DMeetingRequestTentativeItem;
begin
  Result := CreateComObject(CLASS__MeetingRequestTentativeItem) as _DMeetingRequestTentativeItem;
end;

class function Co_MeetingRequestTentativeItem.CreateRemote(const MachineName: string): _DMeetingRequestTentativeItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__MeetingRequestTentativeItem) as _DMeetingRequestTentativeItem;
end;

class function CoNoteItem.Create: _DNoteItem;
begin
  Result := CreateComObject(CLASS_NoteItem) as _DNoteItem;
end;

class function CoNoteItem.CreateRemote(const MachineName: string): _DNoteItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_NoteItem) as _DNoteItem;
end;

class function Co_OfficeDocumentItem.Create: _DOfficeDocumentItem;
begin
  Result := CreateComObject(CLASS__OfficeDocumentItem) as _DOfficeDocumentItem;
end;

class function Co_OfficeDocumentItem.CreateRemote(const MachineName: string): _DOfficeDocumentItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__OfficeDocumentItem) as _DOfficeDocumentItem;
end;

class function CoPostItem.Create: _DPostItem;
begin
  Result := CreateComObject(CLASS_PostItem) as _DPostItem;
end;

class function CoPostItem.CreateRemote(const MachineName: string): _DPostItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PostItem) as _DPostItem;
end;

class function CoRemoteItem.Create: _DRemoteItem;
begin
  Result := CreateComObject(CLASS_RemoteItem) as _DRemoteItem;
end;

class function CoRemoteItem.CreateRemote(const MachineName: string): _DRemoteItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RemoteItem) as _DRemoteItem;
end;

class function CoReportItem.Create: _DReportItem;
begin
  Result := CreateComObject(CLASS_ReportItem) as _DReportItem;
end;

class function CoReportItem.CreateRemote(const MachineName: string): _DReportItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReportItem) as _DReportItem;
end;

class function CoTaskItem.Create: _DTaskItem;
begin
  Result := CreateComObject(CLASS_TaskItem) as _DTaskItem;
end;

class function CoTaskItem.CreateRemote(const MachineName: string): _DTaskItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TaskItem) as _DTaskItem;
end;

class function Co_TaskRequestAcceptItem.Create: _DTaskRequestAcceptItem;
begin
  Result := CreateComObject(CLASS__TaskRequestAcceptItem) as _DTaskRequestAcceptItem;
end;

class function Co_TaskRequestAcceptItem.CreateRemote(const MachineName: string): _DTaskRequestAcceptItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__TaskRequestAcceptItem) as _DTaskRequestAcceptItem;
end;

class function Co_TaskRequestDeclineItem.Create: _DTaskRequestDeclineItem;
begin
  Result := CreateComObject(CLASS__TaskRequestDeclineItem) as _DTaskRequestDeclineItem;
end;

class function Co_TaskRequestDeclineItem.CreateRemote(const MachineName: string): _DTaskRequestDeclineItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__TaskRequestDeclineItem) as _DTaskRequestDeclineItem;
end;

class function CoTaskRequestItem.Create: _DTaskRequestItem;
begin
  Result := CreateComObject(CLASS_TaskRequestItem) as _DTaskRequestItem;
end;

class function CoTaskRequestItem.CreateRemote(const MachineName: string): _DTaskRequestItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TaskRequestItem) as _DTaskRequestItem;
end;

class function Co_TaskRequestUpdateItem.Create: _DTaskRequestUpdateItem;
begin
  Result := CreateComObject(CLASS__TaskRequestUpdateItem) as _DTaskRequestUpdateItem;
end;

class function Co_TaskRequestUpdateItem.CreateRemote(const MachineName: string): _DTaskRequestUpdateItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__TaskRequestUpdateItem) as _DTaskRequestUpdateItem;
end;

end.
