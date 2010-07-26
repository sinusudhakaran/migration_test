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

unit OpXlate;

interface

uses
  OpDbOlk, OpMSO, OpPower, OpWord, OpOutlk, OpExcel, OpShared, OpOlkXP, OpXlXP,
  OpPpt2k, OpWrd2k, OpModels, OpDbOfc, OpAbout, OpEvents;

type
  TBalloon                   = TOpBalloon;
  TDVSlideTransition         = TOpSlideTransition;
  TDVMailMerge               = TOpMailMerge;
  TNestedCollection          = TOpNestedCollection;
  TDVExcelCharts             = TOpExcelCharts;
  TDVExcelHyperlinks         = TOpExcelHyperlinks;
  TDVExcelRanges             = TOpExcelRanges;
  TDVExcelWorkbooks          = TOpExcelWorkbooks;
  TDVExcelWorksheets         = TOpExcelWorksheets;
  TDVPresentations           = TOpPresentations;
  TDVSlides                  = TOpSlides;
  TDocumentBookmarks         = TOpDocumentBookmarks;
  TDocumentHyperlinks        = TOpDocumentHyperlinks;
  TDocumentShapes            = TOpDocumentShapes;
  TDocumentTables            = TOpDocumentTables;
  TWordDocuments             = TOpWordDocuments;
  TNestedCollectionItem      = TOpNestedCollectionItem;
  TDVExcelChart              = TOpExcelChart;
  TDVExcelHyperlink          = TOpExcelHyperlink;
  TDVExcelRange              = TOpExcelRange;
  TDVExcelWorkbook           = TOpExcelWorkbook;
  TDVExcelWorksheet          = TOpExcelWorksheet;
  TDVPresentation            = TOpPresentation;
  TDVSlide                   = TOpSlide;
  TDocumentBookmark          = TOpDocumentBookmark;
  TDocumentHyperlink         = TOpDocumentHyperlink;
  TDocumentShape             = TOpDocumentShape;
  TDocumentTable             = TOpDocumentTable;
  TWordDocument              = TOpWordDocument;
  TDVAssistant               = TOpAssistant;
  TDVOfficeComponent         = TOpOfficeComponent;
  TDVOutlookBase             = TOpOutlookBase;
  TDVOutlook                 = TOpOutlook;
  TDVExcelBase               = TOpExcelBase;
  TDVExcel                   = TOpExcel;
  TDVPowerPointBase          = TOpPowerPointBase;
  TDVPowerPoint              = TOpPowerPoint;
  TDVWordBase                = TOpWordBase;
  TDVWord                    = TOpWord;
  TDVContactsDataSet         = TOpContactsDataSet;
  TDVUnkownComponent         = TOpUnknownComponent;
  TDVDataSetModel            = TOpDataSetModel;
  TDVEventModel              = TOpEventModel;
  {TFrmAppInfo                = TFrmAbout;}
  TDVEventAdapter            = TOpEventAdapter;
  TDVEventSink               = TOpEventSink;
  TFreeList                  = TOpFreeList;
  TBaseData                  = TOpBaseData;
  TBusinessData              = TOpBusinessData;
  TDefaultData               = TOpDefaultData;
  TMiscData                  = TOpMiscData;
  TNetworkData               = TOpNetworkData;
  TPersonalData              = TOpPersonalData;
  TBaseDataClass             = TOpBaseDataClass;
  TMailListItem              = TOpMailListItem;
  TAttachment                = TOpAttachment;
  TRecipient                 = TOpRecipient;
  TMailListProp              = TOpMailListProp;
  TAttachmentList            = TOpAttachmentList;
  TRecipientList             = TOpRecipientList;
  TOutlookItem               = TOpOutlookItem;
  TDVAppointmentItem         = TOpAppointmentItem;
  TDVContactItem             = TOpContactItem;
  TDVJournalItem             = TOpJournalItem;
  TDVMailItem                = TOpMailItem;
  TDVNoteItem                = TOpNoteItem;
  TDVPostItem                = TOpPostItem;
  TDVTaskItem                = TOpTaskItem;
  EEventSinkException        = EOpEventSinkException;
  EOfficeError               = EOpOfficeError;
  IDvModel                   = IOpModel;
  OnDvConnect                = OnOpConnect;
  OnDvDisconnect             = OnOpDisconnect;
  TDvModelProperty           = TOpModelProperty;
  TDvOfficeFileProperty      = TOpOfficeFileProperty;
  TDvOfficeAssistantProperty = TOpOfficeAssistantProperty;
  TDvMachineNameProperty     = TOpMachineNameProperty;
  TDvEventOperation          = TOpEventOperation;
  //TDvComponentModel          = TOpComponentModel;
  TdvCoCreateInstanceExProc  = TOpCoCreateInstanceExProc;

  //
  TOlImportance		= TOpOlImportance;
  //olImportanceLow		= olImpLow;
  //olImportanceNormal	= olImpNormal;
  //olImportanceHigh	= olImpHigh;
  TOlSensitivity		= TOpOlSensitivity;
  //olNormal		= olSensNormal;
  //olPersonal		= olSensPersonal;
  //olPrivate		= olSensPrivate;
  //olConfidential		= olSensConfidential;
  TOlDisplayType		= TOpOlDisplayType;
  //olUser		        = oldtUser;
  //olDistList		= oldtDistList;
  //olForum		        = oldtForum;
  //olAgent		        = oldtAgent;
  //olOrganization		= oldtOrganization;
  //olPrivateDistList	= oldtPrivateDistList;
  //olRemoteUser		= oldtRemoteUser;
  TOlTrackingStatus	= TOpOlTrackingStatus;
  //olTrackingNone		= oltsNone;
  //olTrackingDelivered	= oltsDelivered;
  //olTrackingNotDelivered	= oltsNotDelivered;
  //olTrackingNotRead	= oltsNotRead;
  //olTrackingRecallFailure	= oltsRecallFailure;
  //olTrackingRecallSuccess	= oltsRecallSuccess;
  //olTrackingRead		= oltsRead;
  //olTrackingReplied       = oltsReplied;
  TOlMailRecipientType	= TOpOlMailRecipientType;
  //olOriginator		= olmrtOriginator;
  //olTo		        = olmrtTo;
  //olCC		        = olmrtCC;
  //olBCC		        = olmrtBCC;
  TOlInspectorClose	= TOpOlInspectorClose;
  //olSave		        = olicSave;
  //olDiscard		= olicDiscard;
  //olPromptForSave		= olicPromptForSave;
  TOlGender		= TOpOlGender;
  //olUnspecified		= olGendUnspecified;
  //olFemale		= olGendFemale;
  //olMale		        = olGendMale;
  TOlNoteColor 		= TOpOlNoteColor;
  //olBlue		        = olncBlue;
  //olGreen		        = olncGreen;
  //olPink		        = olncPink;
  //olYellow		= olncYellow;
  //olWhite		        = olncWhite;
  TOlMailingAddress 	= TOpOlMailingAddress;
  //olNone		        = olmaNone;
  //olHome		        = olmaHome;
  //olBusiness	        = olmaBusiness;
  //olOther		        = olmaOther;
  TOlMeetingResponse	= TOpOlMeetingResponse;
  //olMeetingTentative	= olmrTentative;
  //olMeetingAccepted	= olmrAccepted;
  //olMeetingDeclined	= olmrDeclined;
  TOlBusyStatus		= TOpOlBusyStatus;
  //olFree		        = olbsFree;
  //olTentative		= olbsTentative;
  //olBusy		        = olbsBusy;
  //olOutOfOffice		= olbsOutOfOffice;
  TOlMeetingStatus 	= TOpOlMeetingStatus;
  //olNonMeeting		= olmsNonMeeting;
  //olMeeting		= olmsMeeting;
  //olMeetingReceived	= olmsReceived;
  //olMeetingCanceled	= olmsCanceled;
  TOlNetMeetingType	= TOpOlNetMeetingType;
  //olNetMeeting		= olnmtNetMeeting;
  //olChat		        = olnmtChat;
  //olNetShow		= olnmtNetShow;
  TOlItemType 		= TOpOlItemType;
  //olMailItem		= olitMail;
  //olAppointmentItem	= olitAppointment;
  //olContactItem		= olitContact;
  //olTaskItem		= olitTask;
  //olJournalItem		= olitJournal;
  //olNoteItem		= olitNote;
  //olPostItem		= olitPost;
  TOlRecurrenceState 	= TOpOlRecurrenceState;
  //olApptNotRecurring	= olrsApptNotRecurring;
  //olApptMaster		= olrsApptMaster;
  //olApptOccurrence	= olrsApptOccurrence;
  //olApptException		= olrsApptException;
  TOlResponseStatus 	= TOpOlResponseStatus;
  //olResponseNone		= olrespstNone;
  //olResponseOrganized	= olrespstOrganized;
  //olResponseTentative	= olrespstTentative;
  //olResponseAccepted	= olrespstAccepted;
  //olResponseDeclined	= olrespstDeclined;
  //olResponseNotResponded	= olrespstNotResponded;
  TOlTaskDelegationState	= TOpOlTaskDelegationState;
  //olTaskNotDelegated	= oltdsNotDelegated;
  //olTaskDelegationUnknown	= oltdsUnknown;
  //olTaskDelegationAccepted  = oltdsAccepted;
  //olTaskDelegationDeclined  = oltdsDeclined;
  TOlTaskOwnership 	= TOpOlTaskOwnership;
  //olNewTask		= oltoNewTask;
  //olDelegatedTask		= oltoDelegatedTask;
  //olOwnTask		= oltoOwnTask;
  TOlTaskResponse 	= TOpOlTaskResponse;
  //olTaskSimple		= oltrSimple;
  //olTaskAssign		= oltrAssign;
  //olTaskAccept		= oltrAccept;
  //olTaskDecline		= oltrDecline;
  TOlTaskStatus 		= TOpOlTaskStatus;
  //olTaskNotStarted	= olTskStatNotStarted;
  //olTaskInProgress	= olTskStatInProgress;
  //olTaskComplete		= olTskStatComplete;
  //olTaskWaiting		= olTskStatWaiting;
  //olTaskDeferred		= olTskStatDeferred;
  TOlSaveAsType 		= TOpOlSaveAsType;
  //olTXT		        = olsatTXT;
  //olRTF		        = olsatRTF;
  //olTemplate		= olsatTemplate;
  //olMSG		        = olsatMSG;
  //olDoc		        = olsatDoc;
  //olHTML		        = olsatHTML;
  //olVCard		        = olsatVCard;
  //olVCal		        = olsatVCal;


implementation

end.
