
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressDataController                                        }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSDATACONTROLLER AND ALL         }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}
                                                              
unit cxCustomData;

{$I cxVer.inc}

interface

uses
  SysUtils, Classes, {$IFDEF DELPHI6}Variants, {$ENDIF}cxVariants,
  cxDataUtils, cxDataStorage, cxFilter, dxCore;

const
  cxNullEditingRecordIndex = -MaxInt;

type
  TcxCustomDataControllerInfo = class;
  TcxCustomDataController = class;
  TcxCustomDataProvider = class;
  TcxCustomDataField = class;
  TcxCustomDataFieldList = class;
  TcxCustomDataRelationList = class;
  TcxDataSummaryItem = class;
  TcxDataSummaryItems = class;
  TcxDataSummaryGroup = class;
  TcxDataSummaryGroups = class;
  TcxDataSummaryGroupItemLinks = class;
  TcxDataSummary = class;

  EcxInvalidDataControllerOperation = class(EdxException);

  { TcxCustomDataSource }

  TcxDataRecordHandle = Pointer;
  TcxDataItemHandle = Pointer;

  TcxCustomDataSource = class
  private
    FCurrentProvider: TcxCustomDataProvider;
    FProvider: TcxCustomDataProvider;
    FProviders: TList;
    function GetDataController: TcxCustomDataController;
    function GetProvider: TcxCustomDataProvider;
    procedure AddProvider(AProvider: TcxCustomDataProvider);
    procedure RemoveProvider(AProvider: TcxCustomDataProvider);
    procedure RemoveFromProviders;
  protected
    function AppendRecord: TcxDataRecordHandle; virtual; // *
    procedure CustomSort; virtual; // when IsCustomSorting = True
    procedure DeleteRecord(ARecordHandle: TcxDataRecordHandle); virtual; // *
    function GetDefaultItemID(AItemIndex: Integer): Integer; virtual;
    function GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean; virtual;
    function GetDisplayText(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): string; virtual;
    function GetInfoForCompare(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle; var PValueBuffer: PAnsiChar): Boolean; virtual;
    function GetItemHandle(AItemIndex: Integer): TcxDataItemHandle; virtual;
    function GetRecordCount: Integer; virtual; // *
    function GetRecordId(ARecordHandle: TcxDataRecordHandle): Variant; virtual; // Save Keys Required
    function GetRecordHandle(ARecordIndex: Integer): TcxDataRecordHandle; virtual;
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; virtual; // *
    function InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle; virtual; // *
    function IsCustomSorting: Boolean; virtual;
    function IsNativeCompare: Boolean; virtual;
    function IsNativeCompareFunc: Boolean; virtual;
    function IsRecordIdSupported: Boolean; virtual; // Save Keys Required
    procedure LoadRecordHandles; virtual;
    function NativeCompareFunc(ARecordHandle1, ARecordHandle2: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Integer; virtual;
    procedure SetRecordCount(ARecordCount: Integer); virtual;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle; const AValue: Variant); virtual; // *
    property CurrentProvider: TcxCustomDataProvider read FCurrentProvider write FCurrentProvider;
    // tree
    function AddRecordHandle(ARecordHandle: TcxDataRecordHandle): Integer;
  public
    destructor Destroy; override;
    procedure DataChanged; virtual;
    function GetRecordHandleByIndex(ARecordIndex: Integer): TcxDataRecordHandle;
    function GetRecordIndexByHandle(ARecordHandle: TcxDataRecordHandle): Integer;
    property DataController: TcxCustomDataController read GetDataController;
    property Provider: TcxCustomDataProvider read GetProvider;
  end;

  TcxCustomDataSourceClass = class of TcxCustomDataSource;

  { TcxCustomDataProvider }

  TcxDataChange = (dcField, dcRecord, dcNew, dcDeleted, dcTotal);
  TcxDataChangeInfo = record
    Kind: TcxDataChange;
    ItemIndex: Integer;
    RecordIndex: Integer;
  end;

  TcxDataLayoutChange = (lcStructure, lcData);
  TcxDataLayoutChanges = set of TcxDataLayoutChange;

  TcxDataSummaryCountValues = array of Integer;
  TcxDataSummaryValues = array of Variant;

  TcxCustomDataProvider = class
  private
    FActiveChanging: Boolean;
    FChanging: Boolean;
    FCustomDataSource: TcxCustomDataSource;
    FDataChangedLocked: Boolean;
    FDataController: TcxCustomDataController;
    FEditingRecordIndex: Integer;
    FEditingRecordIndex1: Integer; // After
    FEditingRecordIndex2: Integer; // Before
    FInsertedRecordIndex: Integer;
    FInUpdateData: Boolean;
    FLocateCount: Integer;
    FLockCount: Integer;
    FModified: Boolean;
    FRecreatedFieldsAfterFirst: Boolean;
    FSavedRecordIndex: Integer;
    procedure SetCustomDataSource(Value: TcxCustomDataSource);
  protected
    FInInserting: Boolean;
    FInserting: Boolean;
    FLoadAllNeeded: Boolean;
    // Mode
    procedure CustomSort; virtual; // when IsCustomSorting = True
    function IsCustomDataSourceSupported: Boolean; virtual;
    function IsCustomSorting: Boolean; virtual;
    function IsGridMode: Boolean; virtual;
    function IsDataSource: Boolean; virtual;
    function IsOtherInsert: Boolean; virtual;
    function IsRecordIdSupported: Boolean; virtual;
    function IsSyncMode: Boolean; virtual;
    // State
    function IsActive: Boolean; virtual;
    function IsActiveDataSet: Boolean; virtual;
    function IsBOF: Boolean; virtual;
    function IsChanging: Boolean; virtual;
    function IsEditing: Boolean; virtual;
    function IsEOF: Boolean; virtual;
    function IsGridModeUpdating: Boolean; virtual;
    function IsInserting: Boolean; virtual;
    function IsModified: Boolean; virtual;
    function IsUnboundColumnMode: Boolean; virtual;
    // Navigation
    procedure CorrectRecordIndex(ARecordIndex: Integer); virtual;
    procedure First; virtual;
    procedure Prev; virtual;
    procedure Next; virtual;
    procedure Last; virtual;
    procedure MoveBy(ADistance: Integer); virtual;
    procedure Scroll(ADistance: Integer); virtual;
    procedure SavePos; virtual;
    procedure RestorePos; virtual;
    // Editing
    function CanAppend: Boolean; virtual;
    function CanDelete: Boolean; virtual;
    function CanInitEditing(ARecordIndex: Integer): Boolean; virtual;
    function CanInsert: Boolean; virtual;
    function CanModify: Boolean; virtual;

    procedure Append; virtual;
    procedure Cancel; virtual;
    procedure DoUpdateData; virtual;
    procedure Delete; virtual;
    procedure DeleteRecords(AList: TList); virtual;
    procedure DeleteSelection; virtual;
    procedure Edit; virtual;
    function GetEditValue(ARecordIndex: Integer; AField: TcxCustomDataField; AEditValueSource: TcxDataEditValueSource): Variant; virtual;
    procedure Insert; virtual;
    procedure Post(AForcePost: Boolean = False); virtual;
    procedure PostEditingData; virtual;
    function SetEditValue(ARecordIndex: Integer; AField: TcxCustomDataField; const AValue: Variant; AEditValueSource: TcxDataEditValueSource): Boolean; virtual;

    procedure BeginDeleting; virtual;
    procedure EndDeleting; virtual;

    procedure AssignItemValue(ARecordIndex: Integer; AField: TcxCustomDataField; const AValue: Variant); virtual;
    procedure ClearSavedRecord;
    procedure CreateSavedRecord(ARecordIndex: Integer);
    procedure DoInitInsertingRecord(AInsertingRecordIndex: Integer; const AGroupValues: TcxDataSummaryValues); virtual;
    procedure EditingRecord; virtual;
    procedure InsertingRecord(AIsAppending: Boolean); virtual;
    procedure ResetChanging; virtual;
    procedure ResetEditing; virtual;
    procedure ResetModified; virtual;
    procedure SetChanging; virtual;
    procedure SetEditing; virtual;
    procedure SetModified; virtual;
    // Lock Notify
    procedure BeginLocate; virtual;
    procedure EndLocate; virtual;
    procedure Freeze; virtual;
    procedure Unfreeze; virtual;
    // Data
    function AddRecordHandle(AData: Pointer): Integer;
    function AppendRecord: Integer; virtual;
    procedure DeleteRecord(ARecordIndex: Integer); virtual;
    function GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean; virtual;
    function GetDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField): string; virtual;
//    function GetRecordCount: Integer; virtual;
    function GetExternalDataDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField): string; virtual;
    function GetExternalDataValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    function GetRecordId(ARecordIndex: Integer): Variant; virtual;
    function GetRecordIndex: Integer; virtual;
    function GetValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    function GetValueDefReaderClass: TcxValueDefReaderClass; virtual;
    function InsertRecord(ARecordIndex: Integer): Integer; virtual;
    procedure LoadDataBuffer; virtual;
    procedure LoadRecordHandles;
    function NativeCompare(ARecordIndex1, ARecordIndex2: Integer; AField: TcxCustomDataField): Integer; virtual;
    function NativeCompareFunc(ARecordIndex1, ARecordIndex2: Integer; AField: TcxCustomDataField): Integer; virtual;
    procedure SetDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField; const Value: string); virtual;
    procedure SetRecordCount(ARecordCount: Integer); virtual;
    procedure SetValue(ARecordIndex: Integer; AField: TcxCustomDataField; const Value: Variant); virtual;
    // Notification
    procedure ActiveChanged(AActive: Boolean); virtual;
    procedure DataChanged(ADataChange: TcxDataChange; AItemIndex, ARecordIndex: Integer); virtual;
    procedure DataScrolled(ADistance: Integer); virtual;
    procedure LayoutChanged(ADataLayoutChanges: TcxDataLayoutChanges); virtual;

    property ActiveChanging: Boolean read FActiveChanging write FActiveChanging;
    property CustomDataSource: TcxCustomDataSource read FCustomDataSource write SetCustomDataSource;
    property DataController: TcxCustomDataController read FDataController;
    property EditingRecordIndex: Integer read FEditingRecordIndex;
    property InsertedRecordIndex: Integer read FInsertedRecordIndex;
    property LocateCount: Integer read FLocateCount;
    property LockCount: Integer read FLockCount;
    property RecreatedFieldsAfterFirst: Boolean read FRecreatedFieldsAfterFirst write FRecreatedFieldsAfterFirst;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
  end;

  TcxCustomDataProviderClass = class of TcxCustomDataProvider;

  { TcxCustomDataField }

  TcxCustomDataField = class
  private
    FFieldList: TcxCustomDataFieldList;
    FIsInternal: Boolean;
    FItem: TObject;
    FLockRecreateData: Integer;
    FNeedConversion: Boolean;
    FNeedConversionFlag: Integer; // 0 - undefined; -1 - not needed; 1 - needed; 2 - SortByDisplayText
    FPrepared: Boolean;
    FReferenceField: TcxCustomDataField;
    FTextStored: Boolean;
    FValueDef: TcxValueDef;
    FValueTypeClass: TcxValueTypeClass;
    function GetDataController: TcxCustomDataController;
    function GetIndex: Integer;
    function GetNotifier: TComponent;
    function GetTextStored: Boolean;
    function GetValueDef: TcxValueDef;
    function GetValueTypeClass: TcxValueTypeClass;
    procedure SetIndex(Value: Integer);
    procedure SetIsInternal(Value: Boolean);
    procedure SetReferenceField(Value: TcxCustomDataField);
    procedure SetTextStored(Value: Boolean);
    procedure SetValueTypeClass(Value: TcxValueTypeClass);
  protected
    procedure BeginRecreateData;
    procedure Changed;
    procedure ClearData;
    procedure CreateData;
    procedure EndRecreateData;
    procedure Reassign(ASource: TcxCustomDataField); virtual;
    procedure RemoveNotification(AComponent: TComponent); virtual;
    property FieldList: TcxCustomDataFieldList read FFieldList;
    property NeedConversion: Boolean read FNeedConversion write FNeedConversion;
    property Notifier: TComponent read GetNotifier;
    property TextStored: Boolean read GetTextStored write SetTextStored;
    property ValueDef: TcxValueDef read GetValueDef;
  public
    constructor Create(AFieldList: TcxCustomDataFieldList); virtual;
    destructor Destroy; override;
    function CanModify(AEditValueSource: TcxDataEditValueSource): Boolean; virtual;
    function IsUnbound: Boolean; virtual;
    function IsValueDefInternal: Boolean; virtual;
    property DataController: TcxCustomDataController read GetDataController;
    property Index: Integer read GetIndex write SetIndex;
    property IsInternal: Boolean read FIsInternal write SetIsInternal;
    property Item: TObject read FItem write FItem;
    property ReferenceField: TcxCustomDataField read FReferenceField write SetReferenceField;
    property ValueTypeClass: TcxValueTypeClass read GetValueTypeClass write SetValueTypeClass;
  end;

  TcxCustomDataFieldClass = class of TcxCustomDataField;

  { TcxCustomDataFieldList }

  TcxCustomDataFieldList = class
  private
    FDataController: TcxCustomDataController;
    FFieldDestroyed: Boolean;
    FInternalCount: Integer;
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxCustomDataField;
    function GetItemCount: Integer;
  protected
    procedure Add(AField: TcxCustomDataField);
    procedure Clear;
    procedure RemoveField(AField: TcxCustomDataField);
    procedure RemoveNotification(AComponent: TComponent); virtual;
    procedure Update;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    function FieldByItem(AItem: TObject): TcxCustomDataField;
    procedure ReassignFields(ADestroyedField: TcxCustomDataField);
    property Count: Integer read GetCount;
    property DataController: TcxCustomDataController read FDataController;
    property ItemCount: Integer read GetItemCount;
    property Items[Index: Integer]: TcxCustomDataField read GetItem; default;
  end;

  { Master-Detail }

  TcxDetailInfoObject = class
    LinkObject: TObject;
    HasChildren: Boolean;
    HasChildrenAssigned: Boolean;
  public
    destructor Destroy; override;
  end;

  TcxDetailObject = class
  private
    FActiveRelationIndex: Integer;
    FInfoObjects: TList;
    FExpanded: Boolean;
    function GetInfoObject(Index: Integer): TcxDetailInfoObject;
    function GetInfoObjectCount: Integer;
    function GetIsEmpty: Boolean;
    function GetLinkObject(Index: Integer): TObject;
    function GetLinkObjectCount: Integer;
    procedure SetInfoObject(Index: Integer; Value: TcxDetailInfoObject);
    procedure SetLinkObject(Index: Integer; Value: TObject);
  protected
    procedure CorrectCount(ARelations: TcxCustomDataRelationList);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function ClearHasChildrenFlag: Boolean;
    procedure ClearInfoObject(AIndex: Integer);
    property ActiveRelationIndex: Integer read FActiveRelationIndex write FActiveRelationIndex;
    property Expanded: Boolean read FExpanded write FExpanded;
    property InfoObjectCount: Integer read GetInfoObjectCount;
    property InfoObjects[Index: Integer]: TcxDetailInfoObject read GetInfoObject write SetInfoObject;
    property IsEmpty: Boolean read GetIsEmpty;
    property LinkObjectCount: Integer read GetLinkObjectCount;
    property LinkObjects[Index: Integer]: TObject read GetLinkObject write SetLinkObject;
  end;

  { TcxCustomDataRelation }

  TcxCustomDataRelation = class
  private
    FDetailDataController: TcxCustomDataController;
    FItem: TObject;
    FRelationList: TcxCustomDataRelationList;
    function GetDataController: TcxCustomDataController;
    function GetIndex: Integer;
  protected
    procedure Changed;
    procedure RemoveDataField(ADataField: TcxCustomDataField); virtual;
  public
    constructor Create(ARelationList: TcxCustomDataRelationList; AItem: TObject); virtual;
    destructor Destroy; override;
    procedure Assign(ASource: TcxCustomDataRelation); virtual;
    property DataController: TcxCustomDataController read GetDataController;
    property DetailDataController: TcxCustomDataController read FDetailDataController;
    property Index: Integer read GetIndex;
    property Item: TObject read FItem;
    property RelationList: TcxCustomDataRelationList read FRelationList;
  end;

  TcxCustomDataRelationClass = class of TcxCustomDataRelation;

  { TcxCustomDataRelationList }

  TcxCustomDataRelationList = class
  private
    FDataController: TcxCustomDataController;
    FDataField: TcxCustomDataField;
    FItems: TList;
    FLockCount: Integer;
    procedure AddItem(AItem: TcxCustomDataRelation);
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxCustomDataRelation;
    procedure RemoveItem(AItem: TcxCustomDataRelation);
  protected
    procedure Changed(ARelation: TcxCustomDataRelation);
    function GetValueAsDetailObject(ARecordIndex: Integer): TcxDetailObject;
    procedure RemoveDataField(ADataField: TcxCustomDataField);
    procedure Update(ARelation: TcxCustomDataRelation);

    property DataController: TcxCustomDataController read FDataController;
    property LockCount: Integer read FLockCount;
  public
    constructor Create(ADataController: TcxCustomDataController);
    destructor Destroy; override;
    function Add(AItem: TObject): TcxCustomDataRelation;
    procedure Assign(ASource: TcxCustomDataRelationList);
    procedure BeginUpdate;
    procedure Clear;
    function ClearDetailObject(ARecordIndex, ARelationIndex: Integer): Boolean;
    procedure EndUpdate;
    function FindByItem(AItem: TObject): TcxCustomDataRelation;
    function GetDetailObject(ARecordIndex: Integer): TcxDetailObject;
    function IsDetailObjectExist(ARecordIndex, ARelationIndex: Integer): Boolean;
    function IsEmpty: Boolean;
    procedure Move(ACurIndex, ANewIndex: Integer);
    procedure RemoveByItem(AItem: TObject);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TcxCustomDataRelation read GetItem; default;
  end;

  { TcxCustomDataController }

  { TcxSortingFieldList }

  TcxDataSortOrder = (soNone, soAscending, soDescending);

  TcxDataSortInfo = record
    Field: TcxCustomDataField;
    SortOrder: TcxDataSortOrder;
  end;
  PcxDataSortInfo = ^TcxDataSortInfo;

  TcxNoParamsEvent = procedure of object;

  TcxSortingFieldList = class
  private
    FItems: TList;              
    FOnChanged: TcxNoParamsEvent;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxDataSortInfo;
  protected
    procedure Add(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
    procedure Changed;
    procedure Delete(Index: Integer);
    function Find(AField: TcxCustomDataField): Integer;
    procedure Insert(Index: Integer; AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
    procedure Move(ACurIndex, ANewIndex: Integer);
    procedure Remove(AField: TcxCustomDataField);
    procedure SetSortOrder(Index: Integer; ASortOrder: TcxDataSortOrder);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AppendFrom(AList: TcxSortingFieldList);
    procedure ChangeSorting(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder); virtual;
    procedure CheckField(AField: TcxCustomDataField);
    procedure Clear;
    function SortIndexByField(AField: TcxCustomDataField): Integer;
    function SortOrderByField(AField: TcxCustomDataField): TcxDataSortOrder;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TcxDataSortInfo read GetItem; default;
    property OnChanged: TcxNoParamsEvent read FOnChanged write FOnChanged;
  end;

  TcxGroupingFieldList = class(TcxSortingFieldList)
  public
    procedure ChangeGrouping(AField: TcxCustomDataField; AGroupIndex: Integer);
    procedure ChangeSorting(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder); override;
    function GroupIndexByField(AField: TcxCustomDataField): Integer;
    procedure UpdateSorting(ASortingFieldList: TcxSortingFieldList);
  end;

  { TcxDataGroups }

  TcxDataGroupInfo = class
    RowIndex: Integer;
    Expanded: Boolean;
    Level: Integer;
    BeginRecordListIndex: Integer;
    EndRecordListIndex: Integer;
    SummaryValues: Variant;
  end;

  TcxGroupsRowInfo = record
    Expanded: Boolean;
    Level: Integer;
    RecordListIndex: Integer;
  end;

  TcxDataGroups = class
  private
    FFields: TList;
    FItems: TList;

    function GetField(Index: Integer): TcxCustomDataField;
    function GetFieldCount: Integer;
    function GetItem(Index: Integer): TcxDataGroupInfo;
    function GetItemCount: Integer;
    function GetRowCount: Integer;
    function GetRowInfo(ARowIndex: Integer): TcxGroupsRowInfo;
    function GetTopVisibleItem(ARowIndex: Integer; var ACurIndex: Integer): TcxDataGroupInfo;
  protected
    procedure Add(const ADataGroupInfo: TcxDataGroupInfo);
    procedure AddField(AField: TcxCustomDataField);
    function AddEmpty: TcxDataGroupInfo;
    procedure Clear;
    function Find(ARowIndex: Integer; var AItem: TcxDataGroupInfo): Integer;
    function FindByIndex(ARecordListIndex, ALevel: Integer): Integer;
    function IsVisible(AIndex: Integer): Boolean;
    function MakeVisible(AIndex: Integer; AExpand: Boolean): Boolean;

    property FieldCount: Integer read GetFieldCount;
    property Fields[Index: Integer]: TcxCustomDataField read GetField;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ChangeExpanding(ARowIndex: Integer; AExpanded, ARecursive: Boolean);
    procedure FullExpanding(AExpanded: Boolean);
    function GetChildCount(AIndex: Integer): Integer;
    function GetChildIndex(AParentIndex, AIndex: Integer): Integer;
    function GetChildRecordListIndex(AParentIndex, AIndex: Integer): Integer;
    function GetDataRecordListIndex(AInfo: TcxDataGroupInfo): Integer;
    function GetFirstLevelCount: Integer;
    function GetFirstLevelIndex(AIndex: Integer): Integer;
    function GetIndexByRowIndex(ARowIndex: Integer): Integer;
    function GetIndexByRowIndexLevel(ARowIndex, ALevel: Integer): Integer;
    function GetLevel(AIndex: Integer): Integer;
    function GetParentIndex(AChildIndex: Integer): Integer;
    procedure Rebuild;
    procedure SetItem(AIndex: Integer; AItem: TcxDataGroupInfo);

    property Count: Integer read GetItemCount;
    property Items[Index: Integer]: TcxDataGroupInfo read GetItem; default;
    property LevelCount: Integer read GetFieldCount;
    property RowInfo[RowIndex: Integer]: TcxGroupsRowInfo read GetRowInfo;
    property RowCount: Integer read GetRowCount;
  end;

  { TcxCustomDataControllerInfo }

  TcxDataControllerInfoChange = (dcicLoad, dcicGrouping, dcicSorting,
    dcicFocusedRow, dcicView, dcicExpanding, dcicResetFocusedRow, dcicSelection,
    dcicSummary, dcicFocusedRecord);
  TcxDataControllerInfoChanges = set of TcxDataControllerInfoChange;

  TcxRowInfo = record
    Expanded: Boolean;
    Level: Integer;
    RecordIndex: Integer;
  end;

  TcxDataFocusingInfo = class
  private
    FChangedFlag: Boolean;
    FDataControllerInfo: TcxCustomDataControllerInfo;
    FLevel: Integer;
    FPrevNewItemRowFocused: Boolean;
    FPrevRecordIndex: Integer;
    FRecordIndex: Integer;
    FRowIndex: Integer;
  protected
    procedure Assign(AFocusingInfo: TcxDataFocusingInfo);
    procedure Clear;
    function IsEqual(AFocusingInfo: TcxDataFocusingInfo): Boolean;
    procedure ResetPos;
    procedure SavePos;
    property Level: Integer read FLevel write FLevel;
    property RecordIndex: Integer read FRecordIndex write FRecordIndex;
    property RowIndex: Integer read FRowIndex write FRowIndex;
  public
    constructor Create(ADataControllerInfo: TcxCustomDataControllerInfo);
  end;

  TcxDataExpandingInfoState = (eisExpanded, eisSelected);
  TcxDataExpandingInfoStateSet = set of TcxDataExpandingInfoState;

  TcxDataExpandingInfo = record
    Level: Integer;
    Value: Variant;
    State: TcxDataExpandingInfoStateSet;
  end;
  PcxDataExpandingInfo = ^TcxDataExpandingInfo;

  TcxDataExpandingInfos = class
  private
    FFields: TList;
    FItems: TList;
    FSaveStates: TcxDataExpandingInfoStateSet;
    function Find(AField: TcxCustomDataField): Integer;
    function GetCount: Integer;
    function GetEmpty: Boolean;
    function GetField(Index: Integer): TcxCustomDataField;
    function GetFieldCount: Integer;
    function GetItem(Index: Integer): PcxDataExpandingInfo;
  protected
    procedure AddField(AField: TcxCustomDataField);
    procedure AddItem(ALevel: Integer; const AValue: Variant; AState: TcxDataExpandingInfoStateSet);
    procedure CheckField(AField: TcxCustomDataField);
    procedure Clear;
    procedure ClearFields;
    procedure ClearValues;
  public
    constructor Create;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Empty: Boolean read GetEmpty;
    property FieldCount: Integer read GetFieldCount;
    property Fields[Index: Integer]: TcxCustomDataField read GetField;
    property Items[Index: Integer]: PcxDataExpandingInfo read GetItem; default;
    property SaveStates: TcxDataExpandingInfoStateSet read FSaveStates write FSaveStates;
  end;

  TcxDataSelectionInfo = record
    Level: Integer;
    RecordIndex: Integer; // if Level = -1 then RecordIndex is GroupIndex (in DataGroups)
    RowIndex: Integer;
  end;
  PcxDataSelectionInfo = ^TcxDataSelectionInfo;

  TcxDataSelection = class
  private
    FAnchorRowIndex: Integer;
    FDataController: TcxCustomDataController;
    FItems: TList;
    FFields: TList;
    FOnChanged: TcxNoParamsEvent;
    function GetCount: Integer;
    function GetField(Index: Integer): TcxCustomDataField;
    function GetFieldCount: Integer;
    function GetItem(Index: Integer): PcxDataSelectionInfo;
  protected
    procedure Changed;
    procedure CheckAfterFiltering;
    procedure ClearAnchor; virtual;
    procedure InternalAdd(AIndex, ARowIndex, ARecordIndex, ALevel: Integer); virtual;
    procedure InternalClear; virtual;
    procedure InternalDelete(AIndex: Integer); virtual;
    procedure SetInternalCount(ACount: Integer); virtual;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    procedure Add(AIndex, ARowIndex, ARecordIndex, ALevel: Integer); virtual;
    procedure AddField(AField: TcxCustomDataField);
    procedure Clear;
    procedure ClearAll;
    procedure ClearFields;
    procedure Delete(AIndex: Integer);
    function FindByGroupIndex(AGroupIndex: Integer): Integer;
    function FindByRecordIndex(ARecordIndex: Integer): Integer;
    function FindByRowIndex(ARowIndex: Integer; var AIndex: Integer): Boolean; virtual;
    function IsRecordSelected(ARecordIndex: Integer): Boolean;
    function IsRowSelected(ARowIndex: Integer): Boolean;
    procedure Sort;
    property Count: Integer read GetCount;
    property DataController: TcxCustomDataController read FDataController;
    property FieldCount: Integer read GetFieldCount;
    property Fields[Index: Integer]: TcxCustomDataField read GetField;
    property Items[Index: Integer]: PcxDataSelectionInfo read GetItem; default;
    property AnchorRowIndex: Integer read FAnchorRowIndex;
    property OnChanged: TcxNoParamsEvent read FOnChanged write FOnChanged;
  end;

  TcxDataSelectionClass = class of TcxDataSelection;

  TcxCustomDataControllerInfo = class
  private
    FChanges: TcxDataControllerInfoChanges;
    FDataController: TcxCustomDataController;
    FDataGroups: TcxDataGroups;
    FExpandingInfo: TcxDataExpandingInfos;
    FExpandingFlag: Boolean;
    FFocusingFlag: Boolean;
    FFocusingInfo: TcxDataFocusingInfo;
    FGroupingFieldList: TcxGroupingFieldList;
    FInCanFocusedRowChanging: Boolean;
    FInfoCalculation: Boolean;
    FLockCount: Integer;
    FPrevFocusingInfo: TcxDataFocusingInfo;
    FRecordList: TList;
    FSelection: TcxDataSelection;
    FSortingFieldList: TcxSortingFieldList;
    FTotalSortingFieldList: TcxSortingFieldList;
    procedure CheckAfterCollapsing;
    procedure CheckExpanding;
    procedure CheckFocusing;
    procedure CheckFocusingAfterFilter;
    procedure CheckInfo;
    procedure ClearInfo;
    function CompareRecords(ARecord1, ARecord2: Pointer): Integer;
    function GetFocusedRecordIndex: Integer;
    function GetFocusedRowIndex: Integer;
    function GetNewItemRowFocusingChanged: Boolean;
    function GetPrevFocusedRecordIndex: Integer;
    function GetPrevFocusedRowIndex: Integer;
    procedure SaveInfo;
    procedure SetFocusedRowIndex(Value: Integer);
  protected
    function CanFocusedRowChanging(ARowIndex: Integer): Boolean;
    procedure CorrectFocusedRow(ARowIndex: Integer);
    procedure DoChangeFocusedRow(AValue: Integer; AIsInternal: Boolean);
    procedure DoFilter;
    procedure DoGrouping;
    procedure DoLoad;
    procedure DoSort;
    procedure DoBeginSummary;
    procedure DoEndSummary;
    function FindDataGroup(ARecordListIndex: Integer): Integer;
    function FindFocusedRow(ANearest: Boolean): Integer;
    procedure ForwardChanges;
    function GetInternalRecordCount: Integer;
    function GetInternalRecordListIndex(ARecordIndex: Integer): Integer;
    function IsAlwaysExpanded: Boolean;
    function IsGrouped: Boolean;
    function IsSummaryForSelectedRecords: Boolean;
    function LocateGroupByLevel(AGroupIndex, ALevel: Integer): Integer;
    function LocateDetail(AGroupIndex, ARecordListIndex: Integer; AMakeVisible: Boolean): Integer;
    procedure PrepareSorting;
    procedure RecalcSelection;
    procedure ResetFocusing;
    procedure SaveExpanding(ASaveStates: TcxDataExpandingInfoStateSet);
    procedure TruncateSelection; virtual;
    procedure UnprepareSorting;
    procedure Update; virtual;
    // Sorting By Summary
    procedure DoSortBySummary;
    function IsSortingBySummary: Boolean;

    property SortingFieldList: TcxSortingFieldList read FSortingFieldList;
    property TotalSortingFieldList: TcxSortingFieldList read FTotalSortingFieldList;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure CheckChanges;
    procedure CheckRowIndex(ARowIndex: Integer);
    function GetInternalRecordIndex(ARecordListIndex: Integer): Integer;
    procedure Refresh;
    procedure RefreshFocused;
    procedure RefreshSummary(ARedrawOnly: Boolean);
    // Notify
    procedure ExpandingChanged;
    procedure FocusedRecordChanged(AChangedFlag: Boolean);
    procedure GroupingChanged;
    procedure SelectionChanged;
    procedure SortingChanged;
    // Structure
    procedure RemoveField(AField: TcxCustomDataField);
    procedure UpdateField(AField: TcxCustomDataField);
    // Sorting
    procedure ChangeSortIndex(AField: TcxCustomDataField; ASortIndex: Integer);
    procedure ChangeSorting(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
    procedure ClearSorting(AKeepGroupedItems: Boolean);
    // Grouping
    procedure ChangeExpanding(ARowIndex: Integer; AExpanded, ARecursive: Boolean);
    procedure ChangeGrouping(AField: TcxCustomDataField; AGroupIndex: Integer);
    procedure ClearGrouping;
    function CompareGroupRecords(ARecordIndex1, ARecordIndex2, AIndex: Integer): Integer;
    procedure FullCollapse;
    procedure FullExpand;
    property DataGroups: TcxDataGroups read FDataGroups;
    property GroupingFieldList: TcxGroupingFieldList read FGroupingFieldList;
    // View Data
    function GetNearestRowIndex(ARowIndex: Integer): Integer;
    function GetRowCount: Integer;
    function GetRowIndexByRecordIndex(ARecordIndex: Integer; AMakeVisible: Boolean): Integer;
    function GetRowInfo(ARowIndex: Integer): TcxRowInfo;
    // Selection
    procedure ChangeRowSelection(ARowIndex: Integer; ASelection: Boolean);
    procedure ClearSelection;
    procedure ClearSelectionAnchor;
    function GetSelectedCount: Integer;
    function GetSelectedRowIndex(Index: Integer): Integer;
    function IsRowSelected(ARowIndex: Integer): Boolean;
    property Selection: TcxDataSelection read FSelection;
    // Navigation
    property FocusedRecordIndex: Integer read GetFocusedRecordIndex;
    property FocusedRowIndex: Integer read GetFocusedRowIndex write SetFocusedRowIndex;
    property NewItemRowFocusingChanged: Boolean read GetNewItemRowFocusingChanged;
    property PrevFocusedRecordIndex: Integer read GetPrevFocusedRecordIndex;
    property PrevFocusedRowIndex: Integer read GetPrevFocusedRowIndex;

    property DataController: TcxCustomDataController read FDataController;
    property LockCount: Integer read FLockCount;
  end;

  { Filter }

  TcxDataFilterCriteriaItem = class(TcxFilterCriteriaItem)
  private
    function GetDataController: TcxCustomDataController;
    function GetField: TcxCustomDataField;
  protected
    function GetDataValue(AData: TObject): Variant; override;
    function GetFieldCaption: string; override;
    function GetFieldName: string; override;
    function GetItemLink: TObject; override;
    procedure SetItemLink(Value: TObject); override;
  public
    property DataController: TcxCustomDataController read GetDataController;
    property Field: TcxCustomDataField read GetField;
  end;

  TcxDataFilterValueList = class(TcxFilterValueList)
  private
    function GetDataController: TcxCustomDataController;
  public
    procedure Load(AItemIndex: Integer; AInitSortByDisplayText: Boolean = True;
      AUseFilteredValues: Boolean = False); virtual;
    property DataController: TcxCustomDataController read GetDataController;
  end;

  TcxDataFilterGetValueListEvent = procedure(Sender: TcxFilterCriteria;
    AItemIndex: Integer; AValueList: TcxDataFilterValueList) of object;

  TcxDataFilterCriteria = class(TcxFilterCriteria)
  private
    FActive: Boolean;
    FDataController: TcxCustomDataController;
    FDestroying: Boolean;
    FOnGetValueList: TcxDataFilterGetValueListEvent;
    procedure SetActive(Value: Boolean);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function DoFilterRecord(ARecordIndex: Integer): Boolean;
    function GetIDByItemLink(AItemLink: TObject): Integer; override;
    function GetNameByItemLink(AItemLink: TObject): string; override;
    function GetItemClass: TcxFilterCriteriaItemClass; override;
    function GetItemLinkByID(AID: Integer): TObject; override;
    function GetItemLinkByName(const AName: string): TObject; override;
    function GetValueListClass: TcxFilterValueListClass; override;
    function IsDestroying: Boolean;
    function IsInternal: Boolean;
    function IsLoading: Boolean;
    procedure Update; override;
    property Destroying: Boolean read FDestroying;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent; AIgnoreItemNames: Boolean = False); override;
    procedure AssignEvents(Source: TPersistent); override;
    function CreateValueList: TcxDataFilterValueList; virtual;
    function FindItemByItemLink(AItemLink: TObject): TcxFilterCriteriaItem; override;
    function IsFiltering: Boolean; virtual;
    procedure RemoveItemByField(AField: TcxCustomDataField);
    property DataController: TcxCustomDataController read FDataController;
  published
    property Active: Boolean read FActive write SetActive default False;
    property OnGetValueList: TcxDataFilterGetValueListEvent read FOnGetValueList write FOnGetValueList;
  end;

  TcxDataFilterCriteriaClass = class of TcxDataFilterCriteria;

  { Filters }

  TcxDataFilterList = class(TList)
  private
    function GetItem(Index: Integer): TcxDataFilterCriteria;
  protected
    procedure RemoveItemByField(AField: TcxCustomDataField);
  public
    procedure Clear; override;
    property Items[Index: Integer]: TcxDataFilterCriteria read GetItem; default;
  end;

  { Groups }

  TcxDataGroupIndex = Integer;

  TcxDataControllerGroups = class
  private
    FDataController: TcxCustomDataController;
    function GetChildCount(DataGroupIndex: TcxDataGroupIndex): Integer;
    function GetChildDataGroupIndex(ParentDataGroupIndex: TcxDataGroupIndex; ChildIndex: Integer): TcxDataGroupIndex;
    function GetChildRecordIndex(ParentDataGroupIndex: TcxDataGroupIndex; ChildIndex: Integer): Integer;
    function GetDataControllerInfo: TcxCustomDataControllerInfo;
    function GetDataGroupIndexByRowIndex(RowIndex: Integer): TcxDataGroupIndex;
    function GetDataGroups: TcxDataGroups;
    function GetFieldGroupIndex(AField: TcxCustomDataField): Integer;
    function GetGroupingItemCount: Integer;
    function GetGroupingItemIndex(Index: Integer): Integer;
    function GetGroupDisplayText(ADataGroupIndex: TcxDataGroupIndex): string;
    function GetGroupValue(ADataGroupIndex: TcxDataGroupIndex): Variant;
    function GetItemGroupIndex(AItemIndex: Integer): Integer;
    function GetLevel(ADataGroupIndex: TcxDataGroupIndex): Integer;
    function GetParentDataGroupIndex(ChildDataGroupIndex: TcxDataGroupIndex): TcxDataGroupIndex;
  protected
    function GetGroupRecordIndex(ADataGroupIndex: TcxDataGroupIndex): Integer;
    property DataControllerInfo: TcxCustomDataControllerInfo read GetDataControllerInfo;
    property DataGroups: TcxDataGroups read GetDataGroups;
    property LevelCount: Integer read GetGroupingItemCount;
  public
    constructor Create(ADataController: TcxCustomDataController);
    procedure ChangeExpanding(ARowIndex: Integer; AExpanded, ARecursive: Boolean);
    procedure ChangeGrouping(AItemIndex, AGroupIndex: Integer);
    procedure ClearGrouping;
    procedure FullCollapse;
    procedure FullExpand;
    function GetDataGroupIndexByGroupValue(AParentDataGroupIndex: TcxDataGroupIndex;
      const AGroupValue: Variant): TcxDataGroupIndex;
    function HasAsParent(ARowIndex, AParentRowIndex: Integer): Boolean;
    procedure LoadRecordIndexes(AList: TList; ADataGroupIndex: TcxDataGroupIndex);
    procedure LoadRecordIndexesByRowIndex(AList: TList; ARowIndex: Integer);

    property DataController: TcxCustomDataController read FDataController;
    // Grouping
    property FieldGroupIndex[AField: TcxCustomDataField]: Integer read GetFieldGroupIndex;
    property GroupingItemCount: Integer read GetGroupingItemCount;
    property GroupingItemIndex[Index: Integer]: Integer read GetGroupingItemIndex;
    property ItemGroupIndex[ItemIndex: Integer]: Integer read GetItemGroupIndex;
    // Navigation
    property DataGroupIndexByRowIndex[RowIndex: Integer]: TcxDataGroupIndex read GetDataGroupIndexByRowIndex;
    property Level[ADataGroupIndex: TcxDataGroupIndex]: Integer read GetLevel;
    property ChildCount[DataGroupIndex: TcxDataGroupIndex]: Integer read GetChildCount; // for Level = 0 DataGroupIndex = -1
    property ChildDataGroupIndex[ParentDataGroupIndex: TcxDataGroupIndex; ChildIndex: Integer]: TcxDataGroupIndex read GetChildDataGroupIndex;
    property ChildRecordIndex[ParentDataGroupIndex: TcxDataGroupIndex; ChildIndex: Integer]: Integer read GetChildRecordIndex;
    property ParentDataGroupIndex[ChildDataGroupIndex: TcxDataGroupIndex]: TcxDataGroupIndex read GetParentDataGroupIndex;
    // Values
    property GroupDisplayTexts[ADataGroupIndex: TcxDataGroupIndex]: string read GetGroupDisplayText;
    property GroupValues[ADataGroupIndex: TcxDataGroupIndex]: Variant read GetGroupValue;
  end;

  { Summary }

  TcxCustomDataSummaryItem = class(TCollectionItem)
  private
    FField: TcxCustomDataField;
    function GetItemLink: TObject;
    procedure SetItemLink(Value: TObject);
  protected
    function GetDataController: TcxCustomDataController; virtual; abstract;
    procedure ItemLinkChanging(AField: TcxCustomDataField); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    property DataController: TcxCustomDataController read GetDataController;
    property ItemLink: TObject read GetItemLink write SetItemLink;
    property Field: TcxCustomDataField read FField;
  end;

  TcxSummaryKind = (skNone, skSum, skMin, skMax, skCount, skAverage);
  TcxSummaryOption = (soNullIgnore, soSelectedRecords, soMultipleSelectedRecords);
  TcxSummaryOptions = set of TcxSummaryOption;
  TcxSummaryPosition = (spGroup, spFooter);

  TcxSummaryProperty = (spFormat, spKind, spSorted);
  TcxSummaryProperties = set of TcxSummaryProperty;

  TcxSummaryValueType = (svtFloat, svtCurrency, svtDate);

  TcxDataSummaryItemGetTextEvent = procedure(Sender: TcxDataSummaryItem;
    const AValue: Variant; AIsFooter: Boolean; var AText: string) of object;

  TcxDataSummaryItem = class(TcxCustomDataSummaryItem)
  private
    FFormat: string;
    FKind: TcxSummaryKind;
    FSorted: Boolean;
    FOnGetText: TcxDataSummaryItemGetTextEvent;
    function GetPosition: TcxSummaryPosition;
    function GetSummaryItems: TcxDataSummaryItems;
    procedure SetFormat(const Value: string);
    procedure SetKind(Value: TcxSummaryKind);
    procedure SetPosition(Value: TcxSummaryPosition);
    procedure SetSorted(Value: Boolean);
  protected
    FPosition: TcxSummaryPosition;
    function GetDataController: TcxCustomDataController; override;
    function GetValueType(AVarType: TVarType): TcxSummaryValueType;
    function IsCurrency(AVarType: TVarType): Boolean; virtual;
    function IsDataBinded: Boolean; virtual;
    function IsPositionStored: Boolean; virtual;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function DataField: TcxCustomDataField; virtual;
    function FormatValue(const AValue: Variant; AIsFooter: Boolean): string; virtual;
    property DataController: TcxCustomDataController read GetDataController;
    property SummaryItems: TcxDataSummaryItems read GetSummaryItems;
    property Sorted: Boolean read FSorted write SetSorted default False;
  published
    property Format: string read FFormat write SetFormat;
    property Kind: TcxSummaryKind read FKind write SetKind default skNone;
    property Position: TcxSummaryPosition read GetPosition write SetPosition stored IsPositionStored;
    property OnGetText: TcxDataSummaryItemGetTextEvent read FOnGetText write FOnGetText;
  end;                    

  TcxDataSummaryItemClass = class of TcxDataSummaryItem;

  TcxSummaryEventArguments = record
    RecordIndex: Integer;
    SummaryItem: TcxDataSummaryItem;
  end;

  TcxSummaryEventOutArguments = record
    Value: Variant;
    SummaryValue: Variant;
    CountValue: Integer;
    Done: Boolean;
  end;

  TcxSummaryEvent = procedure(ASender: TcxDataSummaryItems;
    Arguments: TcxSummaryEventArguments;
    var OutArguments: TcxSummaryEventOutArguments) of object;

  TcxDataSummaryItems = class(TcxCollection)
  private
    FSummary: TcxDataSummary;
    FOnSummary: TcxSummaryEvent;
    function GetDataController: TcxCustomDataController;
    function GetItem(Index: Integer): TcxDataSummaryItem;
    procedure SetItem(Index: Integer; Value: TcxDataSummaryItem);
  protected
    procedure BeforeSortingChange(AItem: TcxDataSummaryItem; AValue: Boolean); virtual;
    procedure ChangedView;
    function GetItemPosition(AItem: TcxDataSummaryItem): TcxSummaryPosition; virtual;
    function GetOwner: TPersistent; override;
    function IndexOfField(AField: TcxCustomDataField): Integer;
    function IsPositionStored(AItem: TcxDataSummaryItem): Boolean; virtual;
    function ItemOfField(AField: TcxCustomDataField): TcxDataSummaryItem;
    procedure Update(Item: TCollectionItem); override;
    // simple summary routines
    function AddDataItem(AItemIndex: Integer; APosition: TcxSummaryPosition): TcxDataSummaryItem;
    procedure CheckItemEmpty(AItem: TcxDataSummaryItem);
    procedure GetDataItemProperties(AItemIndex: Integer; APosition: TcxSummaryPosition;
      AProperties: TcxSummaryProperties; var AFormat: string; var AKind: TcxSummaryKind;
      var ASorted: Boolean);
    function IsPropertiesEmpty(AProperties: TcxSummaryProperties; const AFormat: string;
      AKind: TcxSummaryKind; ASorted: Boolean): Boolean; virtual;
    procedure SetDataItemProperties(AItemIndex: Integer; APosition: TcxSummaryPosition;
      AProperties: TcxSummaryProperties; const AFormat: string; AKind: TcxSummaryKind;
      ASorted: Boolean);
    procedure SetItemProperties(AItem: TcxDataSummaryItem; APosition: TcxSummaryPosition;
      AProperties: TcxSummaryProperties; const AFormat: string; AKind: TcxSummaryKind;
      ASorted: Boolean);
  public
    constructor Create(ASummary: TcxDataSummary; AItemClass: TcxDataSummaryItemClass); virtual;
    function Add: TcxDataSummaryItem; overload;
    function Add(AItemLink: TObject; APosition: TcxSummaryPosition;
      AKind: TcxSummaryKind; const AFormat: string = ''): TcxDataSummaryItem; overload;
    procedure Assign(Source: TPersistent); override;
    procedure AssignEvents(Source: TPersistent); virtual;
    function DefaultFormat(AValueType: TcxSummaryValueType; ASummaryKind: TcxSummaryKind; AIsFooter: Boolean): string; virtual;
    procedure DeleteItems(AItemLink: TObject; APosition: TcxSummaryPosition);
    function GetGroupText(const ASummaryValues: Variant): string; virtual;
    function IndexOf(AItem: TcxDataSummaryItem): Integer;
    function IndexOfItemLink(AItemLink: TObject): Integer;
    function ItemOfItemLink(AItemLink: TObject): TcxDataSummaryItem;
    // simple summary
    function GetDataItem(AItemIndex: Integer; APosition: TcxSummaryPosition;
      ACheckKind: Boolean = False; AKind: TcxSummaryKind = skNone): TcxDataSummaryItem; virtual;
    function GetDataItemFormat(AItemIndex: Integer; APosition: TcxSummaryPosition): string;
    function GetDataItemKind(AItemIndex: Integer; APosition: TcxSummaryPosition): TcxSummaryKind;
    function GetDataItemSorted(AItemIndex: Integer; APosition: TcxSummaryPosition): Boolean;
    procedure SetDataItemFormat(AItemIndex: Integer; APosition: TcxSummaryPosition; const Value: string);
    procedure SetDataItemKind(AItemIndex: Integer; APosition: TcxSummaryPosition; Value: TcxSummaryKind);
    procedure SetDataItemSorted(AItemIndex: Integer; APosition: TcxSummaryPosition; Value: Boolean);

    property DataController: TcxCustomDataController read GetDataController;
    property Items[Index: Integer]: TcxDataSummaryItem read GetItem write SetItem; default;
    property Summary: TcxDataSummary read FSummary;
  published
    property OnSummary: TcxSummaryEvent read FOnSummary write FOnSummary;
  end;

  TcxDataFooterSummaryItems = class(TcxDataSummaryItems)
  protected
    function GetItemPosition(AItem: TcxDataSummaryItem): TcxSummaryPosition; override;
    function IsPositionStored(AItem: TcxDataSummaryItem): Boolean; override;
  end;

  TcxDataGroupSummaryItems = class(TcxDataSummaryItems)
  private
    FBeginText: string;
    FEndText: string;
    FSeparator: string;
    FOwner: TPersistent;
    function IsBeginTextStored: Boolean;
    function IsEndTextStored: Boolean;
    function IsSeparatorStored: Boolean;
    procedure SetBeginText(const Value: string);
    procedure SetEndText(const Value: string);
    procedure SetSeparator(const Value: string);
  protected
    procedure BeforeSortingChange(AItem: TcxDataSummaryItem; AValue: Boolean); override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(ASummary: TcxDataSummary; AItemClass: TcxDataSummaryItemClass); override;
    procedure Assign(Source: TPersistent); override;
    function GetGroupText(const ASummaryValues: Variant): string; override;
    function SortedSummaryItem: TcxDataSummaryItem;
  published
    property BeginText: string read FBeginText write SetBeginText stored IsBeginTextStored;
    property EndText: string read FEndText write SetEndText stored IsEndTextStored;
    property Separator: string read FSeparator write SetSeparator stored IsSeparatorStored;
  end;

  TcxDataSummaryGroupItemLink = class(TcxCustomDataSummaryItem)
  private
    function GetSummaryGroupItemLinks: TcxDataSummaryGroupItemLinks;
  protected
    function GetDataController: TcxCustomDataController; override;
    procedure ItemLinkChanging(AField: TcxCustomDataField); override;
  public
    property SummaryGroupItemLinks: TcxDataSummaryGroupItemLinks read GetSummaryGroupItemLinks;
  end;

  TcxDataSummaryGroupItemLinkClass = class of TcxDataSummaryGroupItemLink;

  TcxDataSummaryGroupItemLinks = class(TcxCollection)
  private
    FSummaryGroup: TcxDataSummaryGroup;
    function GetItem(Index: Integer): TcxDataSummaryGroupItemLink;
    procedure SetItem(Index: Integer; Value: TcxDataSummaryGroupItemLink);
  protected
    function GetOwner: TPersistent; override;
    function IndexOfField(AField: TcxCustomDataField): Integer;
    function ItemOfField(AField: TcxCustomDataField): TcxDataSummaryGroupItemLink;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(ASummaryGroup: TcxDataSummaryGroup; AItemClass: TcxDataSummaryGroupItemLinkClass); virtual;
    function Add: TcxDataSummaryGroupItemLink;
    function IndexOfItemLink(AItemLink: TObject): Integer;
    function ItemOfItemLink(AItemLink: TObject): TcxDataSummaryGroupItemLink;
    property Items[Index: Integer]: TcxDataSummaryGroupItemLink read GetItem write SetItem; default;
    property SummaryGroup: TcxDataSummaryGroup read FSummaryGroup;
  end;

  TcxDataSummaryGroup = class(TCollectionItem)
  private
    FItemLinks: TcxDataSummaryGroupItemLinks;
    FSummaryItems: TcxDataGroupSummaryItems;
    function GetItemLinks: TcxDataSummaryGroupItemLinks;
    function GetSummaryGroups: TcxDataSummaryGroups;
    procedure SetItemLinks(Value: TcxDataSummaryGroupItemLinks);
    procedure SetSummaryItems(Value: TcxDataGroupSummaryItems);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property SummaryGroups: TcxDataSummaryGroups read GetSummaryGroups;
  published
    property Links: TcxDataSummaryGroupItemLinks read GetItemLinks write SetItemLinks;
    property SummaryItems: TcxDataGroupSummaryItems read FSummaryItems write SetSummaryItems;
  end;

  TcxDataSummaryGroups = class(TcxCollection)
  private
    FSummary: TcxDataSummary;
    function GetItem(Index: Integer): TcxDataSummaryGroup;
    procedure SetItem(Index: Integer; Value: TcxDataSummaryGroup);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(ASummary: TcxDataSummary);
    function Add: TcxDataSummaryGroup;
    function FindByItemLink(AItemLink: TObject): TcxDataSummaryGroup;
    property Summary: TcxDataSummary read FSummary;
    property Items[Index: Integer]: TcxDataSummaryGroup read GetItem write SetItem; default;
  end;

  TcxAfterSummaryEvent = procedure(ASender: TcxDataSummary) of object;

  TcxDataSummary = class(TPersistent)
  private
    FDataController: TcxCustomDataController;
    FDefaultGroupSummaryItems: TcxDataGroupSummaryItems;
    FDestroying: Boolean;
    FFooterSummaryItems: TcxDataFooterSummaryItems;
    FFooterSummaryValues: Variant; // array of Variant
    FInAfterSummary: Boolean;
    FLockCount: Integer;
    FOptions: TcxSummaryOptions;
    FSetCustomSummary: Boolean;
    FSummaryGroups: TcxDataSummaryGroups;
    FOnAfterSummary: TcxAfterSummaryEvent;
    function GetFooterSummaryValue(Index: Integer): Variant;
    function GetFooterSummaryText(Index: Integer): string;
    function GetGroupSummaryItems(Level: Integer): TcxDataGroupSummaryItems;
    function GetGroupSummaryText(RowIndex: Integer): string;
    function GetGroupSummaryDisplayValue(RowIndex, Level, Index: Integer): Variant;
    function GetGroupSummaryValue(DataGroupIndex: TcxDataGroupIndex; Index: Integer): Variant;
    function GetGroupFooterIndexOfItemLink(Level: Integer; ItemLink: TObject): Integer;
    function GetGroupFooterSummaryText(RowIndex, Level, Index: Integer): string;
    function GetOptions: TcxSummaryOptions;
    procedure SetDefaultGroupSummaryItems(Value: TcxDataGroupSummaryItems);
    procedure SetFooterSummaryItems(Value: TcxDataFooterSummaryItems);
    procedure SetFooterSummaryValue(Index: Integer; Value: Variant);
    procedure SetGroupSummaryDisplayValue(RowIndex, Level, Index: Integer; const Value: Variant);
    procedure SetGroupSummaryValue(DataGroupIndex: TcxDataGroupIndex; Index: Integer; const Value: Variant);
    procedure SetOptions(Value: TcxSummaryOptions);
    procedure SetSummaryGroups(Value: TcxDataSummaryGroups);
  protected
    procedure BeginCalculateSummary(ASummaryItems: TcxDataSummaryItems;
      var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues); virtual;
    procedure CalculateSummary(ASummaryItems: TcxDataSummaryItems;
      ABeginIndex, AEndIndex: Integer; var ACountValues: TcxDataSummaryCountValues;
      var ASummaryValues: TcxDataSummaryValues; var SummaryValues: Variant); virtual;
    procedure Changed(ARedrawOnly: Boolean); virtual;
    procedure DoAfterSummary; virtual;
    procedure DoFinishSummaryValue(ASummaryItem: TcxDataSummaryItem;
      var SummaryValue: Variant; var CountValue: Integer); virtual;
    procedure DoSummaryValue(ASummaryItem: TcxDataSummaryItem; ARecordIndex: Integer;
      var SummaryValue: Variant; var CountValue: Integer); virtual;
    procedure EndCalculateSummary(ASummaryItems: TcxDataSummaryItems;
      var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues;
      var SummaryValues: Variant); virtual;
    function GetGroupSummaryValues(ADataGroupIndex: TcxDataGroupIndex): PVariant;
    function GetOwner: TPersistent; override;
    function GetRecordIndex(ARecordListIndex: Integer): Integer; virtual;
    function GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass; virtual;
    function GetSummaryItemClass: TcxDataSummaryItemClass; virtual;
    function IsValidSummaryValuesIndex(const ASummaryValues: Variant; AIndex: Integer): Boolean; virtual;
    procedure Update(ARedrawOnly: Boolean); virtual;
    property Destroying: Boolean read FDestroying;
    property LockCount: Integer read FLockCount;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignEvents(Source: TPersistent); virtual;
    procedure BeginUpdate;
    procedure BeginCalculate; virtual;
    procedure EndCalculate; virtual;
    procedure Calculate; virtual;
    procedure CalculateFooterSummary; virtual;
    procedure CalculateGroupSummary; virtual;
    procedure CancelUpdate;
    procedure EndUpdate;
    function GetGroupSummaryInfo(ARowIndex: Integer; var ASummaryItems: TcxDataSummaryItems;
      var ASummaryValues: PVariant): Boolean;
    function GetPatternSummaryItems(APatternSummary: TcxDataSummary; ASummaryItems: TcxDataSummaryItems): TcxDataSummaryItems;
    procedure Recalculate;
    procedure RemoveItemByField(AField: TcxCustomDataField);

    property DataController: TcxCustomDataController read FDataController;
    property FooterSummaryValues[Index: Integer]: Variant read GetFooterSummaryValue write SetFooterSummaryValue;
    property FooterSummaryTexts[Index: Integer]: string read GetFooterSummaryText;
    property GroupFooterIndexOfItemLink[Level: Integer; ItemLink: TObject]: Integer read GetGroupFooterIndexOfItemLink;
    property GroupSummaryItems[Level: Integer]: TcxDataGroupSummaryItems read GetGroupSummaryItems;
    // only for View
    property GroupFooterSummaryTexts[RowIndex, Level, Index: Integer]: string read GetGroupFooterSummaryText;
    property GroupSummaryText[RowIndex: Integer]: string read GetGroupSummaryText;
    property GroupSummaryDisplayValues[RowIndex, Level, Index: Integer]: Variant read GetGroupSummaryDisplayValue write SetGroupSummaryDisplayValue;
    // summary group values
    property GroupSummaryValues[DataGroupIndex: TcxDataGroupIndex; Index: Integer]: Variant read GetGroupSummaryValue write SetGroupSummaryValue;
  published
    property DefaultGroupSummaryItems: TcxDataGroupSummaryItems read FDefaultGroupSummaryItems write SetDefaultGroupSummaryItems;
    property FooterSummaryItems: TcxDataFooterSummaryItems read FFooterSummaryItems write SetFooterSummaryItems;
    property SummaryGroups: TcxDataSummaryGroups read FSummaryGroups write SetSummaryGroups;
    property Options: TcxSummaryOptions read GetOptions write SetOptions default [];
    property OnAfterSummary: TcxAfterSummaryEvent read FOnAfterSummary write FOnAfterSummary;
  end;

  TcxDataSummaryClass = class of TcxDataSummary;

  { Incremental Search }

  TcxDataControllerSearch = class
  private
    FDataController: TcxCustomDataController;
    FLocked: Boolean;
    function GetItemIndex: Integer;
    function GetSearching: Boolean;
    function GetSearchText: string;
    procedure SetItemIndex(const Value: Integer);
  protected
    procedure DoFocusedRecord(AFilteredRecordIndex: Integer); virtual;
    function DoSearch(AStartFilteredRecordIndex, AEndFilteredRecordIndex: Integer;
      const ASubText: string; AForward: Boolean): Integer; virtual;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    procedure Cancel;
    function Locate(AItemIndex: Integer; const ASubText: string): Boolean; virtual;
    function LocateNext(AForward: Boolean): Boolean; virtual;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    property DataController: TcxCustomDataController read FDataController;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Locked: Boolean read FLocked;
    property Searching: Boolean read GetSearching;
    property SearchText: string read GetSearchText;
  end;

  TcxDataControllerSearchClass = class of TcxDataControllerSearch;

  { TcxCustomDataController }
  // Changing Notification

  TcxDataControllerChange = (dccLayout, dccData, dccFocus, dccSelection,
    dccDetail, dccSummary, dccSearch, dccSorting, dccGrouping, dccSyncMasterPos,
    dccBookmark, dccUpdateRecord);
  TcxDataControllerChanges = set of TcxDataControllerChange;

  TcxUpdateControlInfo = class
  end;

  TcxUpdateControlInfoClass = class of TcxUpdateControlInfo;

  TcxFocusedRecordChangedInfo = class(TcxUpdateControlInfo)
  private
    FFocusedRecordIndex: Integer;
    FPrevFocusedRecordIndex: Integer;
    FFocusedRowIndex: Integer;
    FPrevFocusedRowIndex: Integer;
    FNewItemRowFocusingChanged: Boolean;
  public
    constructor Create(APrevFocusedRecordIndex, AFocusedRecordIndex, APrevFocusedRowIndex, AFocusedRowIndex: Integer;
      ANewItemRowFocusingChanged: Boolean);
    property FocusedRecordIndex: Integer read FFocusedRecordIndex;
    property PrevFocusedRecordIndex: Integer read FPrevFocusedRecordIndex;
    property FocusedRowIndex: Integer read FFocusedRowIndex;
    property PrevFocusedRowIndex: Integer read FPrevFocusedRowIndex;
    property NewItemRowFocusingChanged: Boolean read FNewItemRowFocusingChanged;
  end;

  TcxFocusedRowChangedInfo = class(TcxUpdateControlInfo)
  private
    FFocusedRowIndex: Integer;
    FPrevFocusedRowIndex: Integer;
  public
    constructor Create(APrevFocusedRowIndex, AFocusedRowIndex: Integer);
    property FocusedRowIndex: Integer read FFocusedRowIndex;
    property PrevFocusedRowIndex: Integer read FPrevFocusedRowIndex;
  end;

  TcxGroupingChangingInfo = class(TcxUpdateControlInfo);

  TcxLayoutChangedInfo = class(TcxUpdateControlInfo)
  { RowCount has not been changed }
  end;

  TcxUpdateRecordInfo = class(TcxUpdateControlInfo) { Record is changed }
  private
    FRecordIndex: Integer;
  public
    constructor Create(ARecordIndex: Integer);
    property RecordIndex: Integer read FRecordIndex;
  end;

  TcxDataChangedInfo = class(TcxUpdateControlInfo)
  { RowCount has been changed; Grouping/Expanding changed }
    Kind: TcxDataChange;
    ItemIndex: Integer;    // Kind = dcField
    RecordIndex: Integer;  // Kind = dcRecord
  end;

  TcxBookmarkChangedInfo = class(TcxUpdateControlInfo)
  end;

  TcxSelectionChangedInfo = class(TcxUpdateControlInfo)
  private
    FRowIndexes: TList;
    function GetCount: Integer;
    function GetRowIndex(Index: Integer): Integer;
  public
    constructor Create;
    constructor CreateEx(ARowIndex1, ARowIndex2: Integer);
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property RowIndexes[Index: Integer]: Integer read GetRowIndex;
  end;

  TcxSearchChangedInfo = class(TcxUpdateControlInfo)
  end;

  TcxDataSelectionChangedInfo = record
    SelectedCount: Integer;
    RowIndex: Integer;
  end;

  TcxUpdateControlEvent = procedure(AInfo: TcxUpdateControlInfo) of object;

  TcxDataControllerLocateObject = class
  private
    FDataController: TcxCustomDataController;
    FInternalRecordIndex: Integer;
  protected
    property DataController: TcxCustomDataController read FDataController;
    property InternalRecordIndex: Integer read FInternalRecordIndex;
  public
    constructor Create(ADataController: TcxCustomDataController); virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    function FindRecordIndex: Integer; virtual; abstract;
    procedure ReadData(AValueDefReader: TcxValueDefReader);
  end;

  TcxDataControllerKeyLocateObject = class(TcxDataControllerLocateObject)
  private
    FFields: TList;
  public
    constructor Create(ADataController: TcxCustomDataController); override;
    destructor Destroy; override;
    procedure AddField(AField: TcxCustomDataField);
    procedure ClearFields;
    function FindRecordIndex: Integer; override;
    property FieldList: TList read FFields;
  end;

  TcxDataControllerGroupLocateObject = class(TcxDataControllerLocateObject)
  private
    FFields: TList;
    FFindFields: TList;
    FFindGroupRecordEnabled: Boolean;
    FLevel: Integer;
    procedure CorrectFindFields;
    procedure SetLevel(Value: Integer);
  public
    constructor Create(ADataController: TcxCustomDataController); override;
    destructor Destroy; override;
    function FindRecordIndex: Integer; override;
    property Level: Integer read FLevel write SetLevel;
  end;

  TcxValueDefUnboundReader = class(TcxValueDefReader)
  private
    FItems: TList;
    FValues: TList;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear;
    function GetValue(AValueDef: TcxValueDef): Variant; override;
    function IsInternal(AValueDef: TcxValueDef): Boolean; override;
    procedure SetValue(AValueDef: TcxValueDef; const AValue: Variant);
    procedure Truncate(AItemCount: Integer);
  end;

  TcxValueDefRecordReader = class(TcxValueDefReader)
  private
    FDataController: TcxCustomDataController;
    FRecordIndex: Integer;
  public
    constructor Create(ADataController: TcxCustomDataController; ARecordIndex: Integer); reintroduce;
    function GetDisplayText(AValueDef: TcxValueDef): string; override;
    function GetValue(AValueDef: TcxValueDef): Variant; override;
    function IsInternal(AValueDef: TcxValueDef): Boolean; override;
  end;

  TcxDataControllerComparisonMode = (dccmSorting, dccmGrouping, dccmOther);

  // Detail Mode
  TcxDataControllerDetailMode = (dcdmNone, dcdmPattern, dcdmClone);

  TcxDataControllerEachDetailProc = procedure(ADataController: TcxCustomDataController) of object;
  TcxDataControllerEachRowProc = procedure(ARowIndex: Integer; ARowInfo: TcxRowInfo) of object;

  TcxDataControllerNotifier = class(TComponent) // because TcxCustomDataController is TPersistent
  private
    FDataController: TcxCustomDataController;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent; ADataController: TcxCustomDataController); reintroduce;
    property DataController: TcxCustomDataController read FDataController;
  end;

  TcxSortingBySummaryEngineClass = class of TcxSortingBySummaryEngine;

  TcxSortingBySummaryEngine = class
  private
    FDataControllerInfo: TcxCustomDataControllerInfo;
    function GetDataController: TcxCustomDataController;
  protected
    property DataController: TcxCustomDataController read GetDataController;
  public
    constructor Create(ADataControllerInfo: TcxCustomDataControllerInfo); virtual;
    procedure Sort; virtual; abstract;
    property DataControllerInfo: TcxCustomDataControllerInfo read FDataControllerInfo;
  end;

  TcxDataControllerCompareEvent = procedure(ADataController: TcxCustomDataController;
    ARecordIndex1, ARecordIndex2, AItemIndex: Integer; const V1, V2: Variant;
    var Compare: Integer) of object;

  TcxDataRecordChangedEvent = procedure(ADataController: TcxCustomDataController;
    ARecordIndex, AItemIndex: Integer) of object;
  TcxDataControllerNotifyEvent = procedure(ADataController: TcxCustomDataController) of object;

  TcxDataDetailExpandingEvent = procedure(ADataController: TcxCustomDataController;
    ARecordIndex: Integer; var AAllow: Boolean) of object;
  TcxDataDetailExpandedEvent = procedure(ADataController: TcxCustomDataController;
    ARecordIndex: Integer) of object;
  TcxDataRecordNotifyEvent = TcxDataDetailExpandedEvent; 

  TcxDataControllerOption = (dcoAnsiSort, dcoCaseInsensitive, dcoAssignGroupingValues,
    dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoSortByDisplayText,
    dcoFocusTopRowAfterSorting, dcoGroupsAlwaysExpanded, dcoImmediatePost,
    dcoInsertOnNewItemRowFocusing);
  TcxDataControllerOptions = set of TcxDataControllerOption;

  TcxDataControllerEditKind = (dceInsert, dceEdit, dceChanging, dceModified);
  TcxDataControllerEditState = set of TcxDataControllerEditKind;

  TcxDataControllerEditOperation = (dceoAppend, dceoDelete, dceoEdit, dceoInsert,
    dceoShowEdit);
  TcxDataControllerEditOperations = set of TcxDataControllerEditOperation;

  TcxDataListenerLink = class
    Ref: TcxCustomDataController;
  end;

  TcxDataFilterRecordEvent = procedure(ADataController: TcxCustomDataController;
    ARecordIndex: Integer; var Accept: Boolean) of object;

  TcxCustomDataController = class(TPersistent, IUnknown)
  private
    FActive: Boolean;
    FAfterSummaryFlag: Boolean;
    FBookmarkRecordIndex: Integer;
    FDataChangedFlag: Boolean;
    FDataChangedLockCount: Integer;
//    FDataChangeInfo: TcxDataChangeInfo;
    FChanges: TcxDataControllerChanges;
    FCheckFocusingAfterFilterNeeded: Boolean;
    FCreatingDataController: TcxCustomDataController;
    FCreatingLinkObject: Boolean;
    FDataChangedListeners: TList;
    FDataChangeRefCount: Integer;
    FDataControllerInfo: TcxCustomDataControllerInfo;
    FDataStorage: TcxDataStorage;
    FDestroying: Boolean;
    FGroupingChanged: Boolean;
    FLoadedStorage: Boolean;
    FGroups: TcxDataControllerGroups;
    FFields: TcxCustomDataFieldList;
    FFilter: TcxDataFilterCriteria;
    FFilterChanged: Boolean;
    FFilters: TcxDataFilterList;
    FFocusedSelected: Boolean;
    FIncrementalFilterField: TcxCustomDataField;
    FIncrementalFilterText: string;
    FIncrementalSearchField: TcxCustomDataField;
    FIncrementalSearching: Boolean;
    FIncrementalSearchText: string;
    FInCancel: Boolean;
    FInLoadStorage: Boolean;
    FInNotifyControl: Boolean;
    FInOnSortingChanged: Boolean;
    FInternalFindRecord: Boolean;
    FIsDetailExpanding: Boolean;
    FIsPattern: Boolean;
    FIsPatternSave: Boolean;
    FInSetCustomDataSource: Boolean;
    FInSmartLoad: Boolean;
    FListenerLinks: TList;
    FLockGridModeNotifyCount: Integer;
    FLockUpdateFieldsCount: Integer;
    FUpdateFieldsFlag: Boolean;
    FNewItemRecordIndex: Integer;
    FNewItemRowFocused: Boolean;
    FMasterRecordIndex: Integer;
    FMasterRelation: TcxCustomDataRelation;
    FMultiSelect: Boolean;
    FNotifier: TcxDataControllerNotifier;
    FOptions: TcxDataControllerOptions;
    FOwner: TComponent;
    FPrevSelectionChangedInfo: TcxDataSelectionChangedInfo;
    FProvider: TcxCustomDataProvider;
    FRecordHandlesField: TcxCustomDataField;
    FRecreatingLinkObject: Boolean;
    FRelations: TcxCustomDataRelationList;
    FSaveObject: TObject;
    FSaveObjectLockCount: Integer;
    FSearch: TcxDataControllerSearch;
    FSelectionChangedInfo: TcxDataSelectionChangedInfo;
    FSortingBySummaryChanged: Boolean;
    FSortingBySummaryDataItemField: TcxCustomDataField;
    FSortingChanged: Boolean;
    FStructureChanged: Boolean;
    FStructureRecreated: Boolean;
    FSummary: TcxDataSummary;
    FUpdateItems: Boolean;
    FUseNewItemRowForEditing: Boolean;
    FOnAfterCancel: TcxDataControllerNotifyEvent;
    FOnAfterDelete: TcxDataControllerNotifyEvent;
    FOnAfterInsert: TcxDataControllerNotifyEvent;
    FOnAfterPost: TcxDataControllerNotifyEvent;
    FOnBeforeCancel: TcxDataControllerNotifyEvent;
    FOnBeforeDelete: TcxDataRecordNotifyEvent;
    FOnBeforeInsert: TcxDataControllerNotifyEvent;
    FOnBeforePost: TcxDataControllerNotifyEvent;
    FOnFilterRecord: TcxDataFilterRecordEvent;
    FOnNewRecord: TcxDataRecordNotifyEvent;
    FOnCompare: TcxDataControllerCompareEvent;
    FOnDataChanged: TNotifyEvent;
    FOnDetailCollapsing: TcxDataDetailExpandingEvent;
    FOnDetailCollapsed: TcxDataDetailExpandedEvent;
    FOnDetailExpanding: TcxDataDetailExpandingEvent;
    FOnDetailExpanded: TcxDataDetailExpandedEvent;
    FOnGroupingChanged: TNotifyEvent;
    FOnRecordChanged: TcxDataRecordChangedEvent;
    FOnSortingChanged: TNotifyEvent;
    FOnUpdateControl: TcxUpdateControlEvent;
    function GetCustomDataSource: TcxCustomDataSource;
    function GetDetailMode: TcxDataControllerDetailMode;
    function GetFilteredIndexByRecordIndex(Index: Integer): Integer;
    function GetFilteredRecordCount: Integer;
    function GetFilteredRecordIndex(Index: Integer): Integer;
    function GetIsEditing: Boolean;
    function GetIsPattern: Boolean;
    function GetIsRowInfoValid: Boolean;
    function GetLockCount: Integer;
    function GetNewItemRowFocused: Boolean;
    function GetOptions: TcxDataControllerOptions;
    function GetRelations: TcxCustomDataRelationList;
    function GetSortingBySummaryDataItemIndex: Integer;
    procedure SetCustomDataSource(Value: TcxCustomDataSource);
    procedure SetIsPattern(Value: Boolean);
    procedure SetFilter(Value: TcxDataFilterCriteria);
    procedure SetFocusedRowIndex(Value: Integer);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetNewItemRowFocused(Value: Boolean);
    procedure SetOnFilterRecord(Value: TcxDataFilterRecordEvent);
    procedure SetOptions(Value: TcxDataControllerOptions);
    procedure SetSummary(Value: TcxDataSummary);
    procedure SetUseNewItemRowForEditing(Value: Boolean);
    procedure SetSortingBySummaryDataItemIndex(Value: Integer);

    procedure Update;
    // Notify
    procedure BeforeGroupingNotification;
    procedure BookmarkNotification;
    procedure DataNotification;
    procedure DoGroupingChanged;
    procedure DoSortingBySummaryChanged;
    procedure DoSortingChanged;
    procedure FocusedNotification;
    procedure LayoutNotification;
    procedure UpdateRecordNotification;
    procedure SearchNotification;
    procedure SelectionNotification;
    procedure NotifyControl(AUpdateControlInfo: TcxUpdateControlInfo);
    procedure NotifyListenerLinks;
    procedure ResetDataChangeInfo;
  protected
    FDataChangeInfo: TcxDataChangeInfo;
    FInDeleteSelection: Boolean;
    FInFocusDetails: Boolean;
    FNearestRecordIndex: Integer;
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // Based
    function AddInternalField: TcxCustomDataField; virtual;
    function AddField: TcxCustomDataField; virtual;
    function AppendInSmartLoad: Integer; virtual;
    procedure BeforeSorting; virtual;
    function CalcEditingRecordIndex: Integer; virtual;
    function CanChangeDetailExpanding(ARecordIndex: Integer; AExpanded: Boolean): Boolean; virtual;
    function CanFocusRecord(ARecordIndex: Integer): Boolean; virtual;
    function CanSelectRow(ARowIndex: Integer): Boolean; virtual;
    procedure CheckChanges;
    procedure Change(AChanges: TcxDataControllerChanges);
    procedure CheckBookmarkValid(ADeletedRecordIndex: Integer); virtual;
    procedure CheckDataSetCurrent; virtual;
    procedure CheckEditingRecordIndex(ARecordIndex: Integer); virtual;
    procedure CheckInternalRecordRange(ARecordIndex: Integer);
    procedure CheckItemRange(AItemIndex: Integer);
    function CheckDetailsBrowseMode: Boolean; virtual;
    function CheckMasterBrowseMode: Boolean; virtual;
    procedure CheckMode;
    procedure CheckNearestFocusRow;
    procedure CheckRange(ARecordIndex, AItemIndex: Integer);
    procedure CheckRecordRange(ARecordIndex: Integer);
    procedure CheckSelectedCount(ADeletedRecordIndex: Integer); // TODO: rename CheckRecordsAfterDelete
    procedure ClearDataChangedListeners;
    procedure ClearDetailsMasterRelation(ARelation: TcxCustomDataRelation);
    procedure CopyRecord(AFromRecordIndex, AToRecordIndex: Integer); virtual;
    procedure CorrectAfterInsert(ARecordIndex: Integer); virtual;
    procedure CorrectAfterDelete(ARecordIndex: Integer); virtual;
    procedure CorrectPrevSelectionChangedInfo;
    procedure DeleteInSmartLoad(ARecordIndex: Integer); virtual;
    procedure Unlocked; virtual;

    procedure DoAfterCancel; virtual;
    procedure DoAfterDelete; virtual;
    procedure DoAfterInsert; virtual;
    procedure DoAfterPost; virtual;
    procedure DoBeforeCancel; virtual;
    procedure DoBeforeDelete(ARecordIndex: Integer); virtual;
    procedure DoBeforeInsert; virtual;
    procedure DoBeforePost; virtual;
    function DoFilterRecord(ARecordIndex: Integer): Boolean; virtual;
    function IsFilterRecord: Boolean; virtual;
    procedure DoNewRecord(ARecordIndex: Integer); virtual;

    procedure DoDataChanged; virtual;
    procedure DoDetailExpanding(ARecordIndex: Integer; var AAllow: Boolean); virtual;
    procedure DoDetailExpanded(ARecordIndex: Integer); virtual;
    procedure DoDetailCollapsing(ARecordIndex: Integer; var AAllow: Boolean); virtual;
    procedure DoDetailCollapsed(ARecordIndex: Integer); virtual;
    function DoIncrementalFilterRecord(ARecordIndex: Integer): Boolean; virtual;
    procedure DoReadRecord(ARecordIndex: Integer); virtual;
    function DoSearchInGridMode(const ASubText: string; AForward, ANext: Boolean): Boolean; virtual;
    function FindItemByInternalID(AID: Integer): TObject; virtual;
    function FindItemByName(const AName: string): TObject; virtual;
    function FindProperItemLink(AItemLink: TObject): TObject; virtual;
    function GetActiveRecordIndex: Integer; virtual; // GridMode
    function GetDataProviderClass: TcxCustomDataProviderClass; virtual;
    function GetDataSelectionClass: TcxDataSelectionClass; virtual;
    function GetEditOperations: TcxDataControllerEditOperations; virtual;
    function GetEditState: TcxDataControllerEditState; virtual;
    function GetDefaultActiveRelationIndex: Integer; virtual;
    function GetFieldClass: TcxCustomDataFieldClass; virtual;
    function GetFilterCriteriaClass: TcxDataFilterCriteriaClass; virtual;
    function GetInternalDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField): string; virtual;
    function GetItemID(AItem: TObject): Integer; virtual;
    function GetItemName(AItem: TObject): string; virtual;
    function GetInternalRecordId(ARecordIndex: Integer; AFieldList: TList): Variant; virtual;
    function GetInternalValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    procedure GetKeyFields(AList: TList); virtual;
    function GetLastRecordIndex: Integer;
    function GetRecordIndex: Integer; virtual;
    function GetRelationClass: TcxCustomDataRelationClass; virtual;
    function GetSearchClass: TcxDataControllerSearchClass; virtual;
    function GetStoredDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField): string;
    function GetStoredValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
    function GetSummaryClass: TcxDataSummaryClass; virtual;
    function GetSummaryItemClass: TcxDataSummaryItemClass; virtual;
    function GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass; virtual;
    function InternalCheckBookmark(ADeletedRecordIndex: Integer): Boolean; virtual;
    procedure InternalClearBookmark; virtual;
    procedure InternalGotoBookmark; virtual;
    function InternalSaveBookmark: Boolean; virtual;
    function IsDataBound: Boolean;
    function IsDataChangedListenersExist: Boolean;
    function IsDataField(AField: TcxCustomDataField): Boolean; virtual;
    function IsDestroying: Boolean; virtual;
    function IsFocusedSelectedMode: Boolean; virtual;
    function IsImmediatePost: Boolean; virtual;
    function IsKeyNavigation: Boolean; virtual;
    function IsLoading: Boolean; virtual;
    function IsProviderDataSource: Boolean; virtual; // Data Aware / Unbound
    function IsProviderMode: Boolean; virtual;
    function IsRecordID: Boolean;
    function IsSmartLoad: Boolean; virtual;
    function IsSmartRefresh: Boolean; virtual;
    function IsUnboundMode: Boolean; virtual;
    procedure LoadStorage; virtual;
    function IsNewItemRecordIndex(ARecordIndex: Integer): Boolean;
    function LockOnAfterSummary: Boolean; virtual;
    procedure NotifyDataChangedListeners;
    procedure NotifyDataControllers; virtual;
    procedure PrepareField(AField: TcxCustomDataField); virtual;
    procedure ProviderValueDefSetProc(AValueDef: TcxValueDef; AFromRecordIndex, AToRecordIndex: Integer; AValueDefReader: TcxValueDefReader); virtual;
    procedure RemoveNotification(AComponent: TComponent); virtual;
    procedure ResetMasterHasChildrenFlag;
    procedure ResetNewItemRowFocused;
    procedure RestructData; virtual;
    procedure SetStoredValue(ARecordIndex: Integer; AField: TcxCustomDataField; const Value: Variant);
    function SyncDetailsFocusWithMaster: Boolean; virtual;
    procedure SyncMasterPos; virtual;
    procedure UpdateFields; virtual;
    procedure UpdateFocused; virtual;
    procedure UpdateRelations(ARelation: TcxCustomDataRelation); virtual;
    procedure UpdateUseRecordIDState;
    procedure UpdateStorage(AUpdateFields: Boolean);
    function UseRecordID: Boolean; virtual;
    // Notification for Self
    class function AddListenerLink(ADataController: TcxCustomDataController): TcxDataListenerLink;
    class procedure RemoveListenerLink(ALink: TcxDataListenerLink);
    // Notification from DataStorage
    procedure DataStorageClearInternalRecords(Sender: TObject); virtual;
    // Notification from Fields
    procedure RemoveField(ADataField: TcxCustomDataField); virtual;
    // Notification from Filter
    procedure FilterChanged; virtual;
    procedure SummaryChanged(ARedrawOnly: Boolean); virtual;
    // Notification from Provider
    procedure ActiveChanged(AActive: Boolean); virtual;
    procedure DataChanged(ADataChange: TcxDataChange; AItemIndex, ARecordIndex: Integer); virtual;
    procedure DataScrolled(ADistance: Integer); virtual;
    procedure LayoutChanged(ADataLayoutChanges: TcxDataLayoutChanges); virtual;
    // Notification for Grid
    procedure DoBeforeFocusedRowChange(ARowIndex: Integer); virtual;
    procedure DoValueTypeClassChanged(AItemIndex: Integer); virtual;
    procedure UpdateControl(AInfo: TcxUpdateControlInfo); virtual;
    // methods for Grid
//    function GetDisplayText(ARecordIndex, AItemIndex: Integer): string; virtual;
    function GetIncrementalSearchText(ARecordIndex, AItemIndex: Integer): string; virtual;
    function GetFilterDisplayText(ARecordIndex, AItemIndex: Integer): string; virtual;
    // Compare
    function CompareByField(ARecordIndex1, ARecordIndex2: Integer;
      AField: TcxCustomDataField; AMode: TcxDataControllerComparisonMode): Integer; virtual;
    function CompareEqualRecords(ARecordIndex1, ARecordIndex2: Integer): Integer; virtual;
    function CompareRecords(ARecordIndex1, ARecordIndex2: Integer;
      ASortInfo: TcxDataSortInfo; AMode: TcxDataControllerComparisonMode = dccmOther): Integer; virtual;
    function FindGroupRecord(ABufferRecordIndex: Integer; AGroupItemCount: Integer): Integer;
    function FindRecordByFields(ABufferRecordIndex: Integer; AFields: TList): Integer;
    function GetComparedValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    function IsConversionNeededForCompare(AField: TcxCustomDataField): Boolean; virtual;
    function IsFilterItemSortByDisplayText(AItemIndex: Integer): Boolean; virtual;
    function IsStringConversionNeeded(AField: TcxCustomDataField): Boolean; virtual;
    function IsSortByDisplayTextNeeded(AField: TcxCustomDataField): Boolean; virtual;
    function NativeCompare(ARecordIndex1, ARecordIndex2: Integer; AField: TcxCustomDataField): Integer;
    // Internal Data
    procedure DeleteFocusedRecord;
    procedure DeleteRecords(AList: TList);
    // Smart Load
    procedure BeginSmartLoad; virtual;
    procedure EndSmartLoad; virtual;
    function LoadRecord(AData: Pointer): Integer; virtual;
    // Locate
    procedure BeginReadRecord; virtual;
    procedure EndReadRecord; virtual;
    // Sorting By Summary
    function GetSortingBySummaryEngineClass: TcxSortingBySummaryEngineClass; virtual;

    property DataStorage: TcxDataStorage read FDataStorage;
    property Fields: TcxCustomDataFieldList read FFields;
    property Notifier: TcxDataControllerNotifier read FNotifier;
    property Provider: TcxCustomDataProvider read FProvider;
    property LockUpdateFieldsCount: Integer read FLockUpdateFieldsCount;
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeforeDestruction; override;
    procedure Destroying; // for CLR 
    function GetOwner: TPersistent; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure BeginFullUpdate; virtual;
    procedure EndFullUpdate; virtual;
    procedure BeginUpdateFields;
    procedure EndUpdateFields;
    procedure SaveKeys;
    procedure RestoreKeys;
    // internal for Grid
    function CreateFilter: TcxDataFilterCriteria; virtual;
    // Notification from Grid
    function AddItem(AItem: TObject): TcxCustomDataField; virtual;
    function ItemPropertiesChanged(AItemIndex: Integer): Boolean; virtual;
    procedure Loaded; virtual;
    procedure RemoveItem(AItem: TObject); virtual;
    procedure UpdateItemIndexes; virtual;
    procedure UpdateItems(AUpdateFields: Boolean);
    function ExecuteAction(Action: TBasicAction): Boolean; virtual;
    function UpdateAction(Action: TBasicAction): Boolean; virtual;
    // Data Changed notify
    procedure AddDataChangedListener(AInstance: TObject; ADataChangedEvent: TNotifyEvent);
    procedure RemoveDataChangedListener(AInstance: TObject; ADataChangedEvent: TNotifyEvent);
    procedure AddDataChangeRefCount;
    procedure RemoveDataChangeRefCount;
    function DataChangedNotifyLocked: Boolean; virtual;
    function IsDataLoading: Boolean; 
    procedure LockDataChangedNotify;
    procedure UnlockDataChangedNotify;
    procedure LockGridModeNotify;
    procedure UnlockGridModeNotify;
    // Structure
    procedure ChangeNeedConversion(AItemIndex: Integer; ANeedConversion: Boolean); virtual;
    procedure ChangeTextStored(AItemIndex: Integer; ATextStored: Boolean); virtual;
    procedure ChangeValueTypeClass(AItemIndex: Integer; AValueTypeClass: TcxValueTypeClass); virtual;
    function GetItem(Index: Integer): TObject; virtual; abstract;
    function GetItemCount: Integer; virtual;
    function GetItemNeedConversion(AItemIndex: Integer): Boolean; virtual;
    function GetItemTextStored(AItemIndex: Integer): Boolean; virtual;
    function GetItemValueTypeClass(AItemIndex: Integer): TcxValueTypeClass;
    function IsDisplayFormatDefined(AItemIndex: Integer; AIgnoreSimpleCurrency: Boolean): Boolean; virtual;
    // Data
    function AppendRecord: Integer;
    procedure DeleteRecord(ARecordIndex: Integer);
    function GetGroupValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    procedure GetGroupValues(ARecordIndex: Integer; var AValues: TcxDataSummaryValues); virtual;
    function GetDisplayText(ARecordIndex, AItemIndex: Integer): string; virtual;
    function GetRecordCount: Integer; virtual;
    function GetRecordId(ARecordIndex: Integer): Variant; virtual;
    function GetValue(ARecordIndex, AItemIndex: Integer): Variant; virtual;
    function InsertRecord(ARecordIndex: Integer): Integer;
    procedure Refresh; virtual;
    procedure SetDisplayText(ARecordIndex, AItemIndex: Integer; const Value: string); virtual;
    procedure SetRecordCount(Value: Integer); virtual;
    procedure SetValue(ARecordIndex, AItemIndex: Integer; const Value: Variant); virtual;
    procedure SortByDisplayTextChanged;
    // Data Editing
    procedure Append; virtual;
    procedure Cancel; virtual;
    function CanInitEditing(AItemIndex: Integer): Boolean; virtual;
    procedure CheckBrowseMode; virtual;
    procedure DeleteFocused; virtual;
    procedure DeleteSelection; virtual;
    procedure Edit; virtual;
    procedure FocusControl(AItemIndex: Integer; var Done: Boolean); virtual;
    function GetEditValue(AItemIndex: Integer; AEditValueSource: TcxDataEditValueSource): Variant; virtual;
    function GetItemValueSource(AItemIndex: Integer): TcxDataEditValueSource; virtual;
    procedure Insert; virtual;
    procedure Post(AForcePost: Boolean = False); virtual;
    procedure PostEditingData; virtual;
    procedure RefreshExternalData; virtual;
    function SetEditValue(AItemIndex: Integer; const AValue: Variant; AEditValueSource: TcxDataEditValueSource): Boolean; virtual;
    procedure UpdateData; virtual;
    // Data New Item Row
    function GetEditingRecordIndex: Integer; virtual;
    function GetNewItemRecordIndex: Integer; virtual;
    // Data Save/Load
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    // Master-Detail: Relations
    function GetMasterDataController: TcxCustomDataController; virtual;
    function GetMasterRecordIndex: Integer; virtual;
    function GetMasterRelation: TcxCustomDataRelation; virtual;
    function GetPatternDataController: TcxCustomDataController;
    function GetRootDataController: TcxCustomDataController;
    function IsDetailMode: Boolean; virtual;
    // Master-Detail: Grid override
    function CreateDetailLinkObject(ARelation: TcxCustomDataRelation; ARecordIndex: Integer): TObject; virtual;
    procedure FocusDetails(ARecordIndex: Integer);
    function GetDetailDataControllerByLinkObject(ALinkObject: TObject): TcxCustomDataController; virtual;
    // Master-Detail: Grid Notifications
    procedure ResetRelationByItem(AItem: TObject); virtual;
    procedure SetMasterMode(AMasterRelation: TcxCustomDataRelation; AIsPattern: Boolean);
    procedure SetMasterRelation(AMasterRelation: TcxCustomDataRelation; AMasterRecordIndex: Integer); virtual;
    // Master-Detail: View Data
    procedure ChangeDetailActiveRelationIndex(ARecordIndex: Integer; ARelationIndex: Integer);
    function ChangeDetailExpanding(ARecordIndex: Integer; AExpanded: Boolean): Boolean;
    procedure ClearDetailLinkObject(ARecordIndex: Integer; ARelationIndex: Integer);
    procedure ClearDetails;
    procedure CollapseDetails;
    procedure ForEachDetail(AMasterRelation: TcxCustomDataRelation; AProc: TcxDataControllerEachDetailProc);
    function GetDetailActiveRelationIndex(ARecordIndex: Integer): Integer;
    function GetDetailDataController(ARecordIndex: Integer; ARelationIndex: Integer): TcxCustomDataController;
    function GetDetailExpanding(ARecordIndex: Integer): Boolean;
    function GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean;
    function GetDetailLinkObject(ARecordIndex: Integer; ARelationIndex: Integer): TObject;
    function IsDetailDataControllerExist(ARecordIndex: Integer; ARelationIndex: Integer): Boolean;
    procedure ResetHasChildrenFlag;
    // View Data
    procedure ForEachRow(ASelectedRows: Boolean; AProc: TcxDataControllerEachRowProc); virtual;
    function GetNearestRowIndex(ARowIndex: Integer): Integer; 
    function GetRowCount: Integer;
    function GetRowIndexByRecordIndex(ARecordIndex: Integer; AMakeVisible: Boolean): Integer;
    function GetRowInfo(ARowIndex: Integer): TcxRowInfo;
    function GetRowDisplayText(const ARowInfo: TcxRowInfo; var AItemIndex: Integer): string;
    function GetRowValue(const ARowInfo: TcxRowInfo; AItemIndex: Integer): Variant;
    procedure MakeRecordVisible(ARecordIndex: Integer);
    // Export in GridMode
    function FocusSelectedRow(ASelectedIndex: Integer): Boolean; virtual;
    procedure RestoreDataSetPos; virtual;
    procedure SaveDataSetPos; virtual;
    // Navigation
    procedure ChangeFocusedRecordIndex(ARecordIndex: Integer);
    function ChangeFocusedRowIndex(ARowIndex: Integer): Boolean;
    procedure CheckFocusedRow;
    function GetFocusedRecordIndex: Integer;
    function GetFocusedRowIndex: Integer;
    procedure GotoFirst;
    procedure GotoLast;
    procedure GotoNext;
    procedure GotoPrev;
    function IsBOF: Boolean;
    function IsEOF: Boolean;
    function IsGridMode: Boolean;
    procedure MoveBy(ADistance: Integer);
    procedure Scroll(ADistance: Integer);
    procedure SetFocus; virtual;
    // Bookmark
    procedure ClearBookmark;
    procedure GotoBookmark;
    function IsBookmarkAvailable: Boolean; virtual;
    function IsBookmarkRow(ARowIndex: Integer): Boolean; virtual;
    procedure SaveBookmark; 
    // Filtering
    function GetFilterDataValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; virtual;
    function GetFilterItemFieldCaption(AItem: TObject): string; virtual;
    function GetFilterItemFieldName(AItem: TObject): string; virtual;
    // Search
    function ChangeIncrementalFilterText(const AText: string): Boolean;
    function FindRecordIndexByText(AStartRecordIndex, AItemIndex: Integer;
      const AText: string; APartialCompare, ACircular, AForward: Boolean): Integer; virtual;
    function GetIncrementalFilterText: string; virtual;
    function IsIncrementalFilter: Boolean; virtual;
    procedure ResetIncrementalFilter; virtual;
    function SetIncrementalFilter(AItemIndex: Integer; const AText: string): Integer; virtual;
    // Sorting
    procedure ChangeItemSortingIndex(AItemIndex: Integer; ASortingIndex: Integer);
    procedure ChangeSorting(AItemIndex: Integer; ASortOrder: TcxDataSortOrder);
    procedure ClearSorting(AKeepGroupedItems: Boolean);
    function GetItemSortByDisplayText(AItemIndex: Integer; ASortByDisplayText: Boolean): Boolean; virtual;
    function GetItemSortOrder(AItemIndex: Integer): TcxDataSortOrder;
    function GetItemSortingIndex(AItemIndex: Integer): Integer;
    function GetSortingItemCount: Integer;
    function GetSortingItemIndex(Index: Integer): Integer;
    // MultiSelect
    procedure ChangeRowSelection(ARowIndex: Integer; ASelection: Boolean); virtual;
    procedure CheckFocusedSelected;
    procedure ClearSelection;
    procedure ClearSelectionAnchor; virtual;
    function GetRowId(ARowIndex: Integer): Variant; virtual;
    function GetSelectedCount: Integer;
    function GetSelectedRowIndex(Index: Integer): Integer; virtual; // Visible Order
    function GetSelectionAnchorRowIndex: Integer; virtual;
    function IsRowSelected(ARowIndex: Integer): Boolean;
    function IsSelectionAnchorExist: Boolean; virtual;
    procedure SelectAll; virtual;
    procedure SelectFromAnchor(ARowIndex: Integer; AKeepSelection: Boolean); virtual;
    procedure SelectRows(AStartRowIndex, AEndRowIndex: Integer);
    procedure SetSelectionAnchor(ARowIndex: Integer); virtual;
    procedure SyncSelected(ASelected: Boolean); // not MultiSelect only
    procedure SyncSelectionFocusedRecord; virtual;

    property Active: Boolean read FActive;
    property CustomDataSource: TcxCustomDataSource read GetCustomDataSource write SetCustomDataSource;
    property DataControllerInfo: TcxCustomDataControllerInfo read FDataControllerInfo;
    property DetailMode: TcxDataControllerDetailMode read GetDetailMode;
    property DisplayTexts[RecordIndex, ItemIndex: Integer]: string read GetDisplayText write SetDisplayText;
    property Groups: TcxDataControllerGroups read FGroups;
    property EditingRecordIndex: Integer read GetEditingRecordIndex;
    property EditOperations: TcxDataControllerEditOperations read GetEditOperations;
    property EditState: TcxDataControllerEditState read GetEditState;
    property Filter: TcxDataFilterCriteria read FFilter write SetFilter;
    property FilteredIndexByRecordIndex[Index: Integer]: Integer read GetFilteredIndexByRecordIndex;
    property FilteredRecordCount: Integer read GetFilteredRecordCount;
    property FilteredRecordIndex[Index: Integer]: Integer read GetFilteredRecordIndex;
    property FocusedRecordIndex: Integer read GetFocusedRecordIndex write ChangeFocusedRecordIndex;
    property FocusedRowIndex: Integer read GetFocusedRowIndex write SetFocusedRowIndex;
    property IsCreatingLinkObject: Boolean read FCreatingLinkObject;
    property IsDetailExpanding: Boolean read FIsDetailExpanding;
    property IsEditing: Boolean read GetIsEditing;
    property IsPattern: Boolean read GetIsPattern write SetIsPattern;
    property IsRowInfoValid: Boolean read GetIsRowInfoValid;
    property IsUpdatingItems: Boolean read FUpdateItems;
    property ItemCount: Integer read GetItemCount;
    property LockCount: Integer read GetLockCount;
    property LockGridModeNotifyCount: Integer read FLockGridModeNotifyCount;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property NewItemRecordIndex: Integer read GetNewItemRecordIndex;
    property NewItemRowFocused: Boolean read GetNewItemRowFocused write SetNewItemRowFocused;
    property Options: TcxDataControllerOptions read GetOptions write SetOptions default [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding];
    property RecordCount: Integer read GetRecordCount write SetRecordCount;
    property Relations: TcxCustomDataRelationList read GetRelations;
    property RowCount: Integer read GetRowCount;
    property Search: TcxDataControllerSearch read FSearch;
    property Summary: TcxDataSummary read FSummary write SetSummary;
    property UseNewItemRowForEditing: Boolean read FUseNewItemRowForEditing write SetUseNewItemRowForEditing;
    property Values[RecordIndex, ItemIndex: Integer]: Variant read GetValue write SetValue;
    // Sorting By Summary
    property SortingBySummaryDataItemIndex: Integer read GetSortingBySummaryDataItemIndex write SetSortingBySummaryDataItemIndex;

    property OnAfterCancel: TcxDataControllerNotifyEvent read FOnAfterCancel write FOnAfterCancel;
    property OnAfterDelete: TcxDataControllerNotifyEvent read FOnAfterDelete write FOnAfterDelete;
    property OnAfterInsert: TcxDataControllerNotifyEvent read FOnAfterInsert write FOnAfterInsert;
    property OnAfterPost: TcxDataControllerNotifyEvent read FOnAfterPost write FOnAfterPost;
    property OnBeforeCancel: TcxDataControllerNotifyEvent read FOnBeforeCancel write FOnBeforeCancel;
    property OnBeforeDelete: TcxDataRecordNotifyEvent read FOnBeforeDelete write FOnBeforeDelete;
    property OnBeforeInsert: TcxDataControllerNotifyEvent read FOnBeforeInsert write FOnBeforeInsert;
    property OnBeforePost: TcxDataControllerNotifyEvent read FOnBeforePost write FOnBeforePost;
    property OnFilterRecord: TcxDataFilterRecordEvent read FOnFilterRecord write SetOnFilterRecord;
    property OnNewRecord: TcxDataRecordNotifyEvent read FOnNewRecord write FOnNewRecord;

    property OnCompare: TcxDataControllerCompareEvent read FOnCompare write FOnCompare;
    property OnDataChanged: TNotifyEvent read FOnDataChanged write FOnDataChanged;
    property OnDetailCollapsing: TcxDataDetailExpandingEvent read FOnDetailCollapsing write FOnDetailCollapsing;
    property OnDetailCollapsed: TcxDataDetailExpandedEvent read FOnDetailCollapsed write FOnDetailCollapsed;
    property OnDetailExpanding: TcxDataDetailExpandingEvent read FOnDetailExpanding write FOnDetailExpanding;
    property OnDetailExpanded: TcxDataDetailExpandedEvent read FOnDetailExpanded write FOnDetailExpanded;
    property OnGroupingChanged: TNotifyEvent read FOnGroupingChanged write FOnGroupingChanged;
    property OnRecordChanged: TcxDataRecordChangedEvent read FOnRecordChanged write FOnRecordChanged;
    property OnSortingChanged: TNotifyEvent read FOnSortingChanged write FOnSortingChanged;
    property OnUpdateControl: TcxUpdateControlEvent read FOnUpdateControl write FOnUpdateControl;
  end;

  TcxCustomDataControllerClass = class of TcxCustomDataController;

  TCompareItems = function (AItem1, AItem2: Pointer): Integer of object;

procedure QuickSortList(ASortList: PPointerList;
  L, R: Integer; ACompareFunc: TCompareItems);

procedure InvalidOperation(const S: string);

const
  cxDataFilterVersion: Byte = 3;
  
implementation

uses
{$IFDEF DELPHI9}
  Windows,
{$ENDIF}
  cxDataConsts, cxFilterConsts;

const
  stDataControllerSignature = 'DataController1';
  stBeginText = '(';
  stEndText = ')';
  stSeparator = ',';
  NullRecordHandle: TcxDataRecordHandle = TcxDataRecordHandle(-1);

  {$IFNDEF DELPHI6}
  // HRESULT value definitions from windows.pas
  // Success codes
  S_OK    = $00000000;
  S_FALSE = $00000001;
  // No such interface supported
  E_NOINTERFACE = HRESULT($80004002);
  {$ENDIF}

type
  TNotifyEventItem = class
    Instance: TObject; 
    Event: TNotifyEvent;
  end;

  { Keys Storage }

  TcxSaveObject = class;

  TcxKeyInfo = class
    Key: Variant;
  end;

  TcxSelectedKeyInfo = class(TcxKeyInfo)
    SelectedIndex: Integer;
  end;

  TcxDetailKeyInfo = class(TcxKeyInfo)
    ActiveRelationIndex: Integer;
    SubDetail: TcxSaveObject;
  end;

  TcxKeys = class
  private
    FDataController: TcxCustomDataController;
    FKeyFields: TList;
    FKeys: TList;
    procedure SetDataController(Value: TcxCustomDataController);
  protected
    procedure DoRestore; virtual;
    procedure DoSave; virtual;
    function Find(ARecordIndex: Integer; var AIndex: Integer): Boolean;
    procedure FreeKeyInfo(AKeyInfo: TObject); virtual;
    property DataController: TcxCustomDataController read FDataController write SetDataController;
    property Keys: TList read FKeys;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Delete(AIndex: Integer);
    procedure Restore(ADataController: TcxCustomDataController);
    procedure Save(ADataController: TcxCustomDataController);
  end;

  TcxDetailKeys = class(TcxKeys)
  protected
    procedure DoRestore; override;
    procedure DoSave; override;
    procedure FreeKeyInfo(AKeyInfo: TObject); override;
  end;

  TcxSelectedKeys = class(TcxKeys)
  protected
    procedure DoRestore; override;
    procedure DoSave; override;
    procedure FreeKeyInfo(AKeyInfo: TObject); override;
  end;

  TcxSaveObject = class
  private
    FDetailKeys: TcxDetailKeys;
    FSelectedKeys: TcxSelectedKeys;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Restore(ADataController: TcxCustomDataController);
    procedure Save(ADataController: TcxCustomDataController);
  end;

function CompareByLinkObject(AItem1, AItem2: Pointer): Integer;
begin
  Result := TcxCustomDataField(TcxValueDef(AItem1).LinkObject).Index -
    TcxCustomDataField(TcxValueDef(AItem2).LinkObject).Index;
end;

procedure InvalidOperation(const S: string);
begin
  raise EcxInvalidDataControllerOperation.Create(S);
end;

function CompareSelectionList(AItem1, AItem2: Pointer): Integer;
begin
  Result := PcxDataSelectionInfo(AItem1).RowIndex - PcxDataSelectionInfo(AItem2).RowIndex;
end;

function CompareIntegers(AItem1, AItem2: Pointer): Integer;
begin
  Result := Integer(AItem1) - Integer(AItem2);
end;

function CompareByKey(AItem1, AItem2: Pointer): Integer;
begin
  Result := VarCompare(TcxKeyInfo(AItem1).Key, TcxKeyInfo(AItem2).Key);
end;

procedure QuickSortList(ASortList: PPointerList;
  L, R: Integer; ACompareFunc: TCompareItems);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := ASortList[(L + R) shr 1];
    repeat
      while ACompareFunc(ASortList[I], P) < 0 do
        Inc(I);
      while ACompareFunc(ASortList[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := ASortList[I];
        ASortList[I] := ASortList[J];
        ASortList[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSortList(ASortList, L, J, ACompareFunc);
    L := I;
  until I >= R;
end;

function IsValueDefInternal(AValueDef: TcxValueDef): Boolean;
begin
  Result := (AValueDef.LinkObject is TcxCustomDataField) and
    TcxCustomDataField(AValueDef.LinkObject).IsValueDefInternal;
end;

procedure ListSetCount(AList: TList; ANewCount: Integer);
begin
      AList.Count := ANewCount;
end;

{ TcxKeys }

constructor TcxKeys.Create;
begin
  inherited Create;
  FKeyFields := TList.Create;
  FKeys := TList.Create;
end;

destructor TcxKeys.Destroy;
begin
  Clear;
  FKeyFields.Free;
  FKeys.Free;
  inherited Destroy;
end;

procedure TcxKeys.Clear;
var
  I: Integer;
begin
  for I := 0 to Keys.Count - 1 do
    FreeKeyInfo(Keys[I]);
  Keys.Clear;
end;

procedure TcxKeys.Delete(AIndex: Integer);
begin
  FreeKeyInfo(Keys[AIndex]);
  Keys.Delete(AIndex);
end;

procedure TcxKeys.Restore(ADataController: TcxCustomDataController);
begin
  DataController := ADataController;
  if Keys.Count > 0 then // !!! TODO
  begin
    DoRestore;
    Clear;
  end;
end;

procedure TcxKeys.Save(ADataController: TcxCustomDataController);
begin
  Clear;
  DataController := ADataController;
  DoSave;
  Keys.Sort(CompareByKey);
end;

procedure TcxKeys.DoRestore;
begin
end;

procedure TcxKeys.DoSave;
begin
end;

function TcxKeys.Find(ARecordIndex: Integer; var AIndex: Integer): Boolean;
var
  I: Integer;
  AKeyInfo: TcxKeyInfo;
begin
  Result := False;
  for I := 0 to Keys.Count - 1 do
  begin
    AKeyInfo := TcxKeyInfo(Keys[I]);
    if VarEquals(DataController.GetInternalRecordId(ARecordIndex, FKeyFields), AKeyInfo.Key) then
    begin
      AIndex := I;
      Result := True;
      Break;
    end;
  end;
end;

procedure TcxKeys.FreeKeyInfo(AKeyInfo: TObject);
begin
  AKeyInfo.Free;
end;

procedure TcxKeys.SetDataController(Value: TcxCustomDataController);
begin
  FDataController := Value;
  FKeyFields.Clear;
  DataController.GetKeyFields(FKeyFields);
end;

{ TcxDetailKeys }

procedure TcxDetailKeys.DoRestore;
var
  I, J: Integer;
  ADetailKeyInfo: TcxDetailKeyInfo;
  ADetailLinkObject: TObject;
  ADataController: TcxCustomDataController;
begin
  for I := 0 to DataController.RecordCount - 1 do
  begin
    if Find(I, J) then
    begin
      ADetailKeyInfo := TcxDetailKeyInfo(Keys[J]);
      DataController.ChangeDetailExpanding(I, True);
      DataController.ChangeDetailActiveRelationIndex(I, ADetailKeyInfo.ActiveRelationIndex);
      if ADetailKeyInfo.SubDetail <> nil then
      begin
        if DataController.GetDetailExpanding(I) and
          (DataController.GetDetailActiveRelationIndex(I) = ADetailKeyInfo.ActiveRelationIndex) then
        begin
          // WARNING: GetDetailDataController->nil !
          ADetailLinkObject := DataController.GetDetailLinkObject(I, ADetailKeyInfo.ActiveRelationIndex);
          if ADetailLinkObject <> nil then
          begin
            ADataController := DataController.GetDetailDataControllerByLinkObject(ADetailLinkObject);
            if ADataController.InheritsFrom(DataController.ClassType) then //if ADataController is TcxDBDataController then
              ADetailKeyInfo.SubDetail.Restore(ADataController);
          end;
        end;
      end;
    end;
  end;
end;

procedure TcxDetailKeys.DoSave;
var
  I: Integer;
  ADetailKeyInfo: TcxDetailKeyInfo;
  ADetailLinkObject: TObject;
  ADataController: TcxCustomDataController;
begin
  for I := 0 to DataController.RecordCount - 1 do
  begin
    if DataController.GetDetailExpanding(I) then
    begin
      ADetailKeyInfo := TcxDetailKeyInfo.Create;
      Keys.Add(ADetailKeyInfo);
      ADetailKeyInfo.Key := DataController.GetInternalRecordId(I, FKeyFields);
      ADetailKeyInfo.ActiveRelationIndex := DataController.GetDetailActiveRelationIndex(I);
      ADetailKeyInfo.SubDetail := TcxSaveObject.Create;
      // WARNING: GetDetailDataController->nil !
      ADetailLinkObject := DataController.GetDetailLinkObject(I, ADetailKeyInfo.ActiveRelationIndex);
      if ADetailLinkObject <> nil then
      begin
        ADataController := DataController.GetDetailDataControllerByLinkObject(ADetailLinkObject);
        if ADataController.InheritsFrom(DataController.ClassType) then //if ADataController is TcxDBDataController then
          ADetailKeyInfo.SubDetail.Save(ADataController);
      end;
    end;
  end;
end;

procedure TcxDetailKeys.FreeKeyInfo(AKeyInfo: TObject);
begin
  if TcxDetailKeyInfo(AKeyInfo).SubDetail <> nil then
    TcxDetailKeyInfo(AKeyInfo).SubDetail.Free;
  AKeyInfo.Free;
end;

{ TcxSelectedKeys }

procedure TcxSelectedKeys.DoRestore;
var
  I, J: Integer;
  ASelection: TcxDataSelection;
  ASelectedKeyInfo: TcxSelectedKeyInfo;
begin
  ASelection := DataController.DataControllerInfo.Selection;
  if ASelection.Count = 0 then Exit;
  // TODO: Level check <> -1
  for I := 0 to DataController.RecordCount - 1 do
  begin
    if Find(I, J) then
    begin
      ASelectedKeyInfo := TcxSelectedKeyInfo(Keys[J]);
      if ASelectedKeyInfo.SelectedIndex < ASelection.Count then
        ASelection[ASelectedKeyInfo.SelectedIndex].RecordIndex := I;
      Delete(J);
    end;
  end;

  for I := 0 to Keys.Count - 1 do
  begin
    ASelectedKeyInfo := TcxSelectedKeyInfo(Keys[I]);
    if (0 <= ASelectedKeyInfo.SelectedIndex) and (ASelectedKeyInfo.SelectedIndex < ASelection.Count) then
      ASelection[ASelectedKeyInfo.SelectedIndex].RecordIndex := -1;
  end;

  for I := ASelection.Count - 1 downto 0 do
    if ASelection[I].RecordIndex = -1 then
      ASelection.Delete(I);

  DataController.DataControllerInfo.ExpandingChanged;
end;

procedure TcxSelectedKeys.DoSave;
var
  ASelection: TcxDataSelection;
  I: Integer;
  PSelectionInfo: PcxDataSelectionInfo;
  ASelectedKeyInfo: TcxSelectedKeyInfo;
begin
  ASelection := DataController.DataControllerInfo.Selection;
  for I := 0 to ASelection.Count - 1 do
  begin
    PSelectionInfo := ASelection[I];
    if (PSelectionInfo.Level <> -1) and
      (PSelectionInfo.RecordIndex < DataController.RecordCount) then
    begin
      ASelectedKeyInfo := TcxSelectedKeyInfo.Create;
      Keys.Add(ASelectedKeyInfo);
      ASelectedKeyInfo.SelectedIndex := I;
      ASelectedKeyInfo.Key := DataController.GetInternalRecordId(PSelectionInfo.RecordIndex, FKeyFields);
    end;
  end;
  DataController.DataControllerInfo.SaveExpanding([eisExpanded, eisSelected]);
end;

procedure TcxSelectedKeys.FreeKeyInfo(AKeyInfo: TObject);
begin
  AKeyInfo.Free;
end;

{ TcxSaveObject }

constructor TcxSaveObject.Create;
begin
  inherited Create;
  FDetailKeys := TcxDetailKeys.Create;
  FSelectedKeys := TcxSelectedKeys.Create;
end;

destructor TcxSaveObject.Destroy;
begin
  FSelectedKeys.Free;
  FDetailKeys.Free;
  inherited Destroy;
end;

procedure TcxSaveObject.Restore(ADataController: TcxCustomDataController);
begin
  if ADataController.IsCreatingLinkObject then Exit;
  if ADataController.IsKeyNavigation then
  begin
    FDetailKeys.Restore(ADataController);
    FSelectedKeys.Restore(ADataController);
  end
  else
    ADataController.CheckSelectedCount(-1);
end;

procedure TcxSaveObject.Save(ADataController: TcxCustomDataController);
begin
  if ADataController.IsCreatingLinkObject or
    ADataController.IsDestroying then Exit;
  if ADataController.IsKeyNavigation then
  begin
    FDetailKeys.Save(ADataController);
    FSelectedKeys.Save(ADataController);
  end;
end;

{ TcxCustomDataSource }

destructor TcxCustomDataSource.Destroy;
begin
  RemoveFromProviders;
  FProviders.Free;
  FProviders := nil;
//  if Assigned(FProvider) then
//    FProvider.CustomDataSource := nil;
  inherited Destroy;
end;

procedure TcxCustomDataSource.DataChanged;
begin
  if Provider = nil then Exit;
  Provider.DataController.BeginFullUpdate;
  try
    Provider.DataChanged(dcTotal, -1, -1);
  finally
    Provider.DataController.EndFullUpdate;
  end;
end;

function TcxCustomDataSource.GetRecordHandleByIndex(ARecordIndex: Integer): TcxDataRecordHandle;
begin
  Result := TcxDataRecordHandle(Integer(DataController.GetInternalValue(ARecordIndex, DataController.FRecordHandlesField)));
end;

function TcxCustomDataSource.GetRecordIndexByHandle(ARecordHandle: TcxDataRecordHandle): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DataController.RecordCount - 1 do
    if GetRecordHandleByIndex(I) = ARecordHandle then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxCustomDataSource.CustomSort;
begin
end;

function TcxCustomDataSource.AppendRecord: TcxDataRecordHandle;
begin
  Result := NullRecordHandle;
  // IMPL: Add + Data Notify
end;

procedure TcxCustomDataSource.DeleteRecord(ARecordHandle: TcxDataRecordHandle);
begin
  // IMPL: Delete + Data Notify
end;

function TcxCustomDataSource.GetDefaultItemID(AItemIndex: Integer): Integer;
begin
  Result := DataController.GetItemID(DataController.GetItem(AItemIndex));
end;

function TcxCustomDataSource.GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean;
begin
  Result := False; 
end;

function TcxCustomDataSource.GetDisplayText(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): string;
begin
  try
    Result := VarToStr(GetValue(ARecordHandle, AItemHandle));
  except
    on EVariantError do
      Result := '';
  end;
end;

function TcxCustomDataSource.GetInfoForCompare(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; var PValueBuffer: PAnsiChar): Boolean;
begin
  InvalidOperation(cxSDataCustomDataSourceInvalidCompare);
  Result := False; // i.e. IS NULL
end;

function TcxCustomDataSource.GetItemHandle(AItemIndex: Integer): TcxDataItemHandle;
begin
  Result := TcxDataItemHandle(AItemIndex);
end;

function TcxCustomDataSource.GetRecordCount: Integer;
begin
  Result := 0;
end;

function TcxCustomDataSource.GetRecordId(ARecordHandle: TcxDataRecordHandle): Variant;
begin
  Result := Null;
end;

function TcxCustomDataSource.GetRecordHandle(ARecordIndex: Integer): TcxDataRecordHandle;
begin
  Result := TcxDataRecordHandle(ARecordIndex);
end;

function TcxCustomDataSource.GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant;
begin
  Result := Null;
end;

function TcxCustomDataSource.InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle;
begin
  // IMPL: Insert + Data Notify
  Result := AppendRecord;
end;

function TcxCustomDataSource.IsCustomSorting: Boolean;
begin
  Result := False;
end;

function TcxCustomDataSource.IsNativeCompare: Boolean;
begin
  Result := False;
end;

function TcxCustomDataSource.IsNativeCompareFunc: Boolean;
begin
  Result := False;
end;

function TcxCustomDataSource.IsRecordIdSupported: Boolean;
begin
  Result := False;
end;

procedure TcxCustomDataSource.LoadRecordHandles;
var
  I: Integer;
begin
  DataController.DataStorage.Clear(Provider.FDataChangedLocked);
  DataController.DataStorage.RecordCount := GetRecordCount;
  for I := 0 to DataController.{DataStorage.}RecordCount - 1 do
    DataController.SetStoredValue(I, DataController.FRecordHandlesField, Integer(GetRecordHandle(I)));
end;

function TcxCustomDataSource.NativeCompareFunc(ARecordHandle1, ARecordHandle2: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Integer;
begin
  Result := 0;
end;

procedure TcxCustomDataSource.SetRecordCount(ARecordCount: Integer);
begin
  // IMPL: change record count + Data Notify
end;

procedure TcxCustomDataSource.SetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; const AValue: Variant);
begin
  // IMPL: change Value + Data Notify
end;

function TcxCustomDataSource.AddRecordHandle(ARecordHandle: TcxDataRecordHandle): Integer;
begin
  Result := DataController.DataStorage.AppendRecord;
  DataController.SetStoredValue(Result, DataController.FRecordHandlesField, Integer(ARecordHandle));
end;

function TcxCustomDataSource.GetDataController: TcxCustomDataController;
begin
  Result := Provider.DataController;
end;

function TcxCustomDataSource.GetProvider: TcxCustomDataProvider;
begin
  if FCurrentProvider <> nil then
    Result := FCurrentProvider
  else
    Result := FProvider;
end;

procedure TcxCustomDataSource.AddProvider(AProvider: TcxCustomDataProvider);
begin
  if FProviders = nil then
    FProviders := TList.Create;
  FProviders.Add(AProvider);
end;

procedure TcxCustomDataSource.RemoveProvider(AProvider: TcxCustomDataProvider);
begin
  if FProviders = nil then Exit;
  FProviders.Remove(AProvider);
  if CurrentProvider = AProvider then
    CurrentProvider := nil;
end;

procedure TcxCustomDataSource.RemoveFromProviders;
var
  I: Integer;
begin
  if FProviders = nil then Exit;
  for I := FProviders.Count - 1 downto 0 do
    if TcxCustomDataProvider(FProviders[I]).CustomDataSource = Self then
      TcxCustomDataProvider(FProviders[I]).CustomDataSource := nil;
end;

{ TcxCustomDataProvider }

constructor TcxCustomDataProvider.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
  FEditingRecordIndex := cxNullEditingRecordIndex;
  FEditingRecordIndex1 := cxNullEditingRecordIndex;
  FEditingRecordIndex2 := cxNullEditingRecordIndex;
  FInsertedRecordIndex := -1;
end;

destructor TcxCustomDataProvider.Destroy;
begin
  ClearSavedRecord;
  CustomDataSource := nil;
  inherited Destroy;
end;

// Mode

procedure TcxCustomDataProvider.CustomSort;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    CustomDataSource.CustomSort;
  end;
end;

function TcxCustomDataProvider.IsCustomDataSourceSupported: Boolean;
begin
  Result := True;
end;

function TcxCustomDataProvider.IsCustomSorting: Boolean;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.IsCustomSorting;
  end
  else
    Result := False;
end;

function TcxCustomDataProvider.IsGridMode: Boolean;
begin
  Result := False;
end;

function TcxCustomDataProvider.IsDataSource: Boolean;
begin
  Result := False;
end;

function TcxCustomDataProvider.IsOtherInsert: Boolean;
begin
  Result := False;
end;

function TcxCustomDataProvider.IsRecordIdSupported: Boolean;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.IsRecordIdSupported;
  end
  else
    Result := False;
end;

function TcxCustomDataProvider.IsSyncMode: Boolean;
begin
  Result := False;
end;

// State

function TcxCustomDataProvider.IsActive: Boolean;
begin
  Result := CustomDataSource <> nil;
end;

function TcxCustomDataProvider.IsActiveDataSet: Boolean;
begin
  Result := False;
end;

function TcxCustomDataProvider.IsBOF: Boolean;
begin
  Result := True;
end;

function TcxCustomDataProvider.IsChanging: Boolean;
begin
  Result := FChanging;
end;

function TcxCustomDataProvider.IsEditing: Boolean;
begin
  Result := FEditingRecordIndex <> cxNullEditingRecordIndex;
end;

function TcxCustomDataProvider.IsEOF: Boolean;
begin
  Result := True;
end;

function TcxCustomDataProvider.IsGridModeUpdating: Boolean;
begin
  Result := False;
end;

function TcxCustomDataProvider.IsInserting: Boolean;
begin
  Result := IsEditing and FInserting;
end;

function TcxCustomDataProvider.IsModified: Boolean;
begin
  Result := FModified;
end;

function TcxCustomDataProvider.IsUnboundColumnMode: Boolean;
begin
  Result := not CanModify; // !!!
end;

// Navigation

procedure TcxCustomDataProvider.CorrectRecordIndex(ARecordIndex: Integer);
begin
end;

procedure TcxCustomDataProvider.First;
begin
  FRecreatedFieldsAfterFirst := False;
end;

procedure TcxCustomDataProvider.Prev;
begin
end;

procedure TcxCustomDataProvider.Next;
begin
end;

procedure TcxCustomDataProvider.Last;
begin
end;

procedure TcxCustomDataProvider.MoveBy(ADistance: Integer);
begin
end;

procedure TcxCustomDataProvider.Scroll(ADistance: Integer);
begin
end;

procedure TcxCustomDataProvider.SavePos;
begin
end;

procedure TcxCustomDataProvider.RestorePos;
begin
end;

// Editing

function TcxCustomDataProvider.CanAppend: Boolean;
begin
  Result := CanModify;
end;

function TcxCustomDataProvider.CanInsert: Boolean;
begin
  Result := CanModify;
end;

function TcxCustomDataProvider.CanDelete: Boolean;
begin
  Result := DataController.FilteredRecordCount > 0;
end;

function TcxCustomDataProvider.CanInitEditing(ARecordIndex: Integer): Boolean;
begin
  DataController.CheckRecordRange(ARecordIndex);
  if not IsEditing then
    SetEditing;
  if IsEditing then
    SetChanging;
  Result := True;
end;

function TcxCustomDataProvider.CanModify: Boolean;
begin
  Result := True;
end;

procedure TcxCustomDataProvider.Append;
begin
  InsertingRecord(True);
end;

procedure TcxCustomDataProvider.Cancel;
var
  ARecordIndex: Integer;
begin
  DataController.DoBeforeCancel;
  DataController.BeginUpdate;
  try
    if (FEditingRecordIndex <> cxNullEditingRecordIndex) and
      ((FEditingRecordIndex < DataController.RecordCount) or
       (FEditingRecordIndex = DataController.FNewItemRecordIndex)) then
    begin
      if IsInserting then
      begin
        DataController.FInSmartLoad := DataController.IsSmartLoad;
        try
          ARecordIndex := DataController.GetFocusedRecordIndex;
          DataController.DeleteRecord(FEditingRecordIndex);
          if not DataController.FInCancel and
            (ARecordIndex >= DataController.RecordCount) then
            DataController.ChangeFocusedRecordIndex(ARecordIndex - 1);
        finally
          DataController.FInSmartLoad := False;
        end;
      end
      else
        if FSavedRecordIndex < 0 then
        begin                                                 
          DataController.CopyRecord(FSavedRecordIndex, FEditingRecordIndex);
        end;
    end;
    ResetEditing;
  finally
    DataController.EndUpdate;
  end;
  DataController.DoAfterCancel;
end;

procedure TcxCustomDataProvider.DoUpdateData;
begin
  if FInUpdateData then Exit;
  FInUpdateData := True;
  try
    if IsChanging then
      DataController.UpdateData;
  finally
    FInUpdateData := False;
  end;
end;

procedure TcxCustomDataProvider.Delete;
var
  ARecordIndex: Integer;
begin
  ARecordIndex := DataController.DataControllerInfo.FocusedRecordIndex;
  if ARecordIndex <> -1 then
  begin
    DataController.DoBeforeDelete(ARecordIndex);
    if DataController.IsProviderMode then
      DataController.SaveKeys;
    try
      DataController.DeleteRecord(ARecordIndex);
      DataController.CheckNearestFocusRow;
    finally
      if DataController.IsProviderMode then
        DataController.RestoreKeys;
    end;
    DataController.DoAfterDelete;
  end;
end;

procedure TcxCustomDataProvider.DeleteRecords(AList: TList);
var
  I, ARecordIndex: Integer;
begin
  if DataController.IsProviderMode then
    DataController.SaveKeys;
  try
    DataController.BeginFullUpdate;
    try
      for I := AList.Count - 1 downto 0 do
      begin
        ARecordIndex := Integer(AList[I]);
        DataController.DoBeforeDelete(ARecordIndex);
        DataController.DeleteRecord(ARecordIndex);
        DataController.DoAfterDelete;
      end;
      if DataController.FInDeleteSelection then
        DataController.ClearSelection;
    finally
      DataController.EndFullUpdate;
    end;
//    if DataController.LockCount = 0 then
      DataController.CheckNearestFocusRow;
  finally
    if DataController.IsProviderMode then
      DataController.RestoreKeys;
  end;
end;

procedure TcxCustomDataProvider.DeleteSelection;
var
  AList: TList;
  I, ARowIndex: Integer;
  ARowInfo: TcxRowInfo;
begin
  AList := TList.Create;
  try
    for I := 0 to DataController.GetSelectedCount - 1 do
    begin
      ARowIndex := DataController.GetSelectedRowIndex(I);
      ARowInfo := DataController.GetRowInfo(ARowIndex);
      if ARowInfo.Level < DataController.Groups.LevelCount then // It's Group Row
        DataController.Groups.LoadRecordIndexesByRowIndex(AList, ARowIndex)
      else
        AList.Add(Pointer(ARowInfo.RecordIndex));
    end;
    // Delete Records
    DataController.FInDeleteSelection := True;
    try
      DataController.DeleteRecords(AList);
    finally
      DataController.FInDeleteSelection := False;
    end;
//    DataController.ClearSelection;
  finally
    AList.Free;
  end;
end;

procedure TcxCustomDataProvider.Edit;
begin
  SetEditing;
end;

function TcxCustomDataProvider.GetEditValue(ARecordIndex: Integer; AField: TcxCustomDataField;
  AEditValueSource: TcxDataEditValueSource): Variant;
begin
  if ARecordIndex <> cxNullEditingRecordIndex then
    Result := DataController.GetInternalValue(ARecordIndex, AField)
  else
  begin
    Result := Null;
    InvalidOperation(cxSDataRecordIndexError);
  end;
end;

procedure TcxCustomDataProvider.Insert;
begin
  InsertingRecord(False);
end;

procedure TcxCustomDataProvider.Post(AForcePost: Boolean);
var
  ARecordIndex: Integer;
  APostFlag: Boolean;
begin
  DataController.BeginFullUpdate;
  try
    ARecordIndex := -1;
    APostFlag := False;
    DoUpdateData;
    if IsInserting and not IsModified and not AForcePost then
      Cancel
    else
    begin
      APostFlag := True;
      DataController.DoBeforePost;
      ARecordIndex := FEditingRecordIndex;
      if IsInserting and DataController.UseNewItemRowForEditing and
        (FEditingRecordIndex <> cxNullEditingRecordIndex) then
      begin
        FDataChangedLocked := CustomDataSource <> nil;
        try
          FInsertedRecordIndex := DataController.AppendRecord;
          ARecordIndex := FInsertedRecordIndex;
        finally
          FDataChangedLocked := False;
        end;
        DataController.CopyRecord(FEditingRecordIndex, FInsertedRecordIndex);
      end;
      ResetEditing;
    end;
    DataController.DataChanged(dcRecord, -1, ARecordIndex);
    if APostFlag then
      DataController.DoAfterPost;
  finally
    DataController.EndFullUpdate;
  end;
end;

procedure TcxCustomDataProvider.PostEditingData;
begin
  DoUpdateData;
  ResetChanging;
end;

function TcxCustomDataProvider.SetEditValue(ARecordIndex: Integer; AField: TcxCustomDataField;
  const AValue: Variant; AEditValueSource: TcxDataEditValueSource): Boolean;
begin
  if (AEditValueSource = evsText) and (VarToStr(AValue) = '') then
    DataController.SetValue(ARecordIndex, AField.Index, Null)
  else
    DataController.SetValue(ARecordIndex, AField.Index, AValue);
  SetModified;
  Result := True;
end;

procedure TcxCustomDataProvider.BeginDeleting;
var
  ARowIndex: Integer;
begin
  if not IsGridMode and (DataController.FocusedRowIndex <> -1) then
  begin
    ARowIndex := DataController.FocusedRowIndex;
    if not DataController.MultiSelect or
      (DataController.IsRowSelected(ARowIndex) or (DataController.GetSelectedCount = 0)) then
      ARowIndex := DataController.GetNearestRowIndex(ARowIndex);
    if ARowIndex <> -1 then
      DataController.FNearestRecordIndex := DataController.GetRowInfo(ARowIndex).RecordIndex;
  end;
end;

procedure TcxCustomDataProvider.EndDeleting;
begin
  DataController.FNearestRecordIndex := -1;
end;

procedure TcxCustomDataProvider.AssignItemValue(ARecordIndex: Integer;
  AField: TcxCustomDataField; const AValue: Variant);
begin
  DataController.Values[ARecordIndex, AField.Index] := AValue;
end;

procedure TcxCustomDataProvider.ClearSavedRecord;
begin
  if FSavedRecordIndex < 0 then
  begin
    FDataController.DataStorage.DeleteRecord(FSavedRecordIndex);
    FSavedRecordIndex := 0;
  end;
end;

procedure TcxCustomDataProvider.CreateSavedRecord(ARecordIndex: Integer);
begin
  if FSavedRecordIndex = 0 then
    FSavedRecordIndex := FDataController.DataStorage.AddInternalRecord;
  FDataController.CopyRecord(ARecordIndex, FSavedRecordIndex);
end;

procedure TcxCustomDataProvider.DoInitInsertingRecord(AInsertingRecordIndex: Integer; const AGroupValues: TcxDataSummaryValues);
var
  I: Integer;
begin
  if (DataController.Groups.GroupingItemCount > 0) and
    (dcoAssignGroupingValues in DataController.Options) then
  begin
    for I := 0 to DataController.Groups.GroupingItemCount - 1 do
      AssignItemValue(AInsertingRecordIndex,
        DataController.Fields[DataController.Groups.GroupingItemIndex[I]],
        AGroupValues[I]);
  end;
  DataController.DoNewRecord(AInsertingRecordIndex);
end;

procedure TcxCustomDataProvider.EditingRecord;
var
  ARowIndex: Integer;
begin
  if DataController.UseNewItemRowForEditing and DataController.NewItemRowFocused and
    not IsInserting then
  begin
    Insert;
    Exit;
  end;
  FEditingRecordIndex := DataController.CalcEditingRecordIndex;
   
  if FEditingRecordIndex >= 0 then
  begin
    FEditingRecordIndex1 := cxNullEditingRecordIndex;
    FEditingRecordIndex2 := cxNullEditingRecordIndex;
    ARowIndex := DataController.GetFocusedRowIndex;
    if ARowIndex <> -1 then
    begin
      if ARowIndex < (DataController.GetRowCount - 1) then
      begin
        ARowIndex := ARowIndex + 1;
        FEditingRecordIndex2 := DataController.GetRowInfo(ARowIndex).RecordIndex;
      end
      else
      begin
        ARowIndex := ARowIndex - 1;
        if 0 <= ARowIndex then
          FEditingRecordIndex1 := DataController.GetRowInfo(ARowIndex).RecordIndex
        else
          FEditingRecordIndex1 := DataController.GetRowInfo(DataController.GetFocusedRowIndex).RecordIndex;
      end;
    end;
  end;

  if FEditingRecordIndex = cxNullEditingRecordIndex then Exit;
  if (not IsDataSource or DataController.IsSmartRefresh) and not IsInserting then // !!!
    CreateSavedRecord(FEditingRecordIndex);
  DataController.Change([dccUpdateRecord]);
end;

procedure TcxCustomDataProvider.InsertingRecord(AIsAppending: Boolean);
var
  ARowIndex, ARecordIndex: Integer;
  AGroupValues: TcxDataSummaryValues;
begin
  // TODO: proc
  if not IsDataSource and IsInserting and not IsChanging and not IsModified then Exit;
  if IsEditing and (IsChanging or IsModified) and not IsDataSource then
  begin
    if IsChanging then
      PostEditingData;
    Post;
  end;
  //
  DataController.DoBeforeInsert;
  DataController.BeginUpdate;
  try
    if DataController.UseNewItemRowForEditing then
    begin
      ARecordIndex := DataController.GetFocusedRecordIndex;
      if (ARecordIndex < 0) and (DataController.GetRowCount > 0) then
        ARecordIndex := DataController.GetRowInfo(0).RecordIndex;
      FEditingRecordIndex := DataController.NewItemRecordIndex;
      DataController.NewItemRowFocused := True;
      DataController.GetGroupValues(ARecordIndex, AGroupValues);
    end
    else
    begin
      if not AIsAppending then
        DataController.ClearSelection; // TODO: ?
      if IsGridMode then
      begin
        ARecordIndex := DataController.GetActiveRecordIndex; //DataController.GetFocusedRecordIndex;
        DataController.GetGroupValues(ARecordIndex, AGroupValues);
        FEditingRecordIndex := ARecordIndex;
      end
      else
      begin
        if AIsAppending then
        begin
          ARecordIndex := DataController.GetLastRecordIndex;
          DataController.GetGroupValues(ARecordIndex, AGroupValues);
          FEditingRecordIndex := DataController.AppendRecord;
          FEditingRecordIndex1 := ARecordIndex;
        end
        else
        begin
          ARowIndex := DataController.GetFocusedRowIndex;
          if ARowIndex <> -1 then
            ARecordIndex := DataController.GetRowInfo(ARowIndex).RecordIndex
          else
            ARecordIndex := 0;
          DataController.GetGroupValues(ARecordIndex, AGroupValues);
          FEditingRecordIndex := DataController.InsertRecord(ARecordIndex);
          FEditingRecordIndex2 := ARecordIndex;
          if (FEditingRecordIndex <= ARecordIndex) and
            (FEditingRecordIndex2 < DataController.RecordCount - 1) then
            Inc(FEditingRecordIndex2);
        end;
      end;
    end;
    DoInitInsertingRecord(FEditingRecordIndex, AGroupValues);
    ResetChanging;
    FInserting := True;
  finally
    DataController.EndUpdate;
  end;
  DataController.ChangeFocusedRecordIndex(FEditingRecordIndex);
  DataController.DoAfterInsert;
end;

procedure TcxCustomDataProvider.ResetChanging;
begin
  FChanging := False;
end;

procedure TcxCustomDataProvider.ResetEditing;
begin
  if (FEditingRecordIndex <> cxNullEditingRecordIndex) and
    (FEditingRecordIndex = DataController.FNewItemRecordIndex) and
    (DataController.FNewItemRecordIndex < 0{is real new item row}) then
    FDataController.DataStorage.DeleteRecord(FEditingRecordIndex);
  FEditingRecordIndex := cxNullEditingRecordIndex;
  FEditingRecordIndex1 := cxNullEditingRecordIndex;
  FEditingRecordIndex2 := cxNullEditingRecordIndex;
  FInserting := False;
  ResetChanging;
  ResetModified;
  ClearSavedRecord;
end;

procedure TcxCustomDataProvider.ResetModified;
begin
  FModified := False;
end;

procedure TcxCustomDataProvider.SetChanging;
begin
  FChanging := True;
end;

procedure TcxCustomDataProvider.SetEditing;
begin
  EditingRecord;
end;

procedure TcxCustomDataProvider.SetModified;
begin
  FModified := True;
end;

// Lock Notify

procedure TcxCustomDataProvider.BeginLocate;
begin
  Inc(FLocateCount);
end;

procedure TcxCustomDataProvider.EndLocate;
begin
  Dec(FLocateCount);
end;

procedure TcxCustomDataProvider.Freeze;
begin
  Inc(FLockCount);
end;

procedure TcxCustomDataProvider.Unfreeze;
begin
  Dec(FLockCount);
end;

// Data

function TcxCustomDataProvider.AddRecordHandle(AData: Pointer): Integer;
begin
  Result := -1;
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.AddRecordHandle(AData);
  end;
end;

function TcxCustomDataProvider.AppendRecord: Integer;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.GetRecordIndexByHandle(CustomDataSource.AppendRecord);
  end
  else
    Result := -1;
end;

procedure TcxCustomDataProvider.DeleteRecord(ARecordIndex: Integer);
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    CustomDataSource.DeleteRecord(CustomDataSource.GetRecordHandleByIndex(ARecordIndex));
  end;
end;

function TcxCustomDataProvider.GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean;
begin
  Result := False;
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.GetDetailHasChildren(ARecordIndex, ARelationIndex);
  end;
end;

function TcxCustomDataProvider.GetDisplayText(ARecordIndex: Integer; AField: TcxCustomDataField): string;
var
  ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    ARecordHandle := CustomDataSource.GetRecordHandleByIndex(ARecordIndex);
    AItemHandle := CustomDataSource.GetItemHandle(AField.Index);
    Result := CustomDataSource.GetDisplayText(ARecordHandle, AItemHandle);
  end
  else
    Result := '';
end;

{function TcxCustomDataProvider.GetRecordCount: Integer;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    Result := CustomDataSource.GetRecordCount;
  end
  else
    Result := 0;
end;}

function TcxCustomDataProvider.GetExternalDataDisplayText(ARecordIndex: Integer;
  AField: TcxCustomDataField): string;
begin
  Result := '';
end;

function TcxCustomDataProvider.GetExternalDataValue(ARecordIndex: Integer;
  AField: TcxCustomDataField): Variant;
begin
  Result := Null;
end;

function TcxCustomDataProvider.GetRecordId(ARecordIndex: Integer): Variant;
var
  ARecordHandle: TcxDataRecordHandle;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    ARecordHandle := CustomDataSource.GetRecordHandleByIndex(ARecordIndex);
    Result := CustomDataSource.GetRecordId(ARecordHandle);
  end
  else
    Result := Null;
end;

function TcxCustomDataProvider.GetRecordIndex: Integer;
begin
  Result := -1;
end;

function TcxCustomDataProvider.GetValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
var
  ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    ARecordHandle := CustomDataSource.GetRecordHandleByIndex(ARecordIndex);
    AItemHandle := CustomDataSource.GetItemHandle(AField.Index);
    Result := CustomDataSource.GetValue(ARecordHandle, AItemHandle);
  end
  else
    Result := Null;
end;

function TcxCustomDataProvider.GetValueDefReaderClass: TcxValueDefReaderClass;
begin
  Result := TcxValueDefReader;
end;

function TcxCustomDataProvider.InsertRecord(ARecordIndex: Integer): Integer;
var
  ARecordHandle: TcxDataRecordHandle;
begin
  Result := -1;
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    if CustomDataSource.GetRecordCount = 0 then
      ARecordHandle := CustomDataSource.AppendRecord
    else
      ARecordHandle := CustomDataSource.InsertRecord(CustomDataSource.GetRecordHandleByIndex(ARecordIndex));
    Result := CustomDataSource.GetRecordIndexByHandle(ARecordHandle);
  end;
end;

procedure TcxCustomDataProvider.LoadDataBuffer;
begin
end;

procedure TcxCustomDataProvider.LoadRecordHandles;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    CustomDataSource.LoadRecordHandles;
  end;
end;

function TcxCustomDataProvider.NativeCompare(ARecordIndex1, ARecordIndex2: Integer;
  AField: TcxCustomDataField): Integer;

  procedure GetCompareInfo(ARecordIndex: Integer; var IsNull: Boolean; var P: PAnsiChar);
  var
    ARecordHandle: TcxDataRecordHandle;
    AItemHandle: TcxDataItemHandle;
  begin
    if ARecordIndex <= -1 then // internal record
      IsNull := DataController.DataStorage.GetCompareInfo(ARecordIndex, AField.ValueDef, P)
    else
    begin
      ARecordHandle := CustomDataSource.GetRecordHandleByIndex(ARecordIndex);
      AItemHandle := CustomDataSource.GetItemHandle(AField.Index);
      IsNull := not CustomDataSource.GetInfoForCompare(ARecordHandle, AItemHandle, P);
    end;
  end;

var
  AIsNull1, AIsNull2: Boolean;
  P1, P2: PAnsiChar;
begin
  if (ARecordIndex1 <= -1) and (ARecordIndex2 <= -1) then
    Result := DataController.DataStorage.CompareRecords(ARecordIndex1, ARecordIndex2, AField.ValueDef)
  else
  begin
    CustomDataSource.CurrentProvider := Self;
    GetCompareInfo(ARecordIndex1, AIsNull1, P1);
    GetCompareInfo(ARecordIndex2, AIsNull2, P2);
    Result := AField.ValueDef.CompareValues(AIsNull1, AIsNull2, P1, P2);
  end;
end;

function TcxCustomDataProvider.NativeCompareFunc(ARecordIndex1, ARecordIndex2: Integer;
  AField: TcxCustomDataField): Integer;
begin
  CustomDataSource.CurrentProvider := Self;
  with CustomDataSource do
    Result := NativeCompareFunc(GetRecordHandleByIndex(ARecordIndex1),
      GetRecordHandleByIndex(ARecordIndex2), GetItemHandle(AField.Index));
end;

procedure TcxCustomDataProvider.SetDisplayText(ARecordIndex: Integer;
  AField: TcxCustomDataField; const Value: string);
begin
end;

procedure TcxCustomDataProvider.SetRecordCount(ARecordCount: Integer);
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    CustomDataSource.SetRecordCount(ARecordCount);
  end;  
end;

procedure TcxCustomDataProvider.SetValue(ARecordIndex: Integer;
  AField: TcxCustomDataField; const Value: Variant);
var
  ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle;
begin
  if CustomDataSource <> nil then
  begin
    CustomDataSource.CurrentProvider := Self;
    ARecordHandle := CustomDataSource.GetRecordHandleByIndex(ARecordIndex);
    AItemHandle := CustomDataSource.GetItemHandle(AField.Index);
    CustomDataSource.SetValue(ARecordHandle, AItemHandle, Value);
  end;
end;

// Notification

procedure TcxCustomDataProvider.ActiveChanged(AActive: Boolean);
begin
  DataController.ActiveChanged(AActive);
  ResetEditing;
end;

procedure TcxCustomDataProvider.DataChanged(ADataChange: TcxDataChange;
  AItemIndex, ARecordIndex: Integer);
begin
  if (LockCount = 0) {and (LocateCount = 0) }then
    DataController.DataChanged(ADataChange, AItemIndex, ARecordIndex);
  if FDataChangedLocked then
    ResetChanging
  else
    ResetEditing;
end;

procedure TcxCustomDataProvider.DataScrolled(ADistance: Integer);
begin
  DataController.DataScrolled(ADistance);
  ResetChanging;
end;

procedure TcxCustomDataProvider.LayoutChanged(ADataLayoutChanges: TcxDataLayoutChanges);
begin
  DataController.LayoutChanged(ADataLayoutChanges);
end;

procedure TcxCustomDataProvider.SetCustomDataSource(Value: TcxCustomDataSource);
begin
  if not IsCustomDataSourceSupported then Exit;
  if FCustomDataSource <> Value then
  begin
    if FCustomDataSource <> nil then
      FCustomDataSource.RemoveProvider(Self);
    FCustomDataSource := Value;
    if FCustomDataSource <> nil then
      FCustomDataSource.AddProvider(Self);

    DataController.FInSetCustomDataSource := True;
    try
      if not DataController.FDestroying then
        DataController.RestructData;
    finally
      DataController.FInSetCustomDataSource := False;
    end;
  end;
end;

{ TcxCustomDataField }

constructor TcxCustomDataField.Create(AFieldList: TcxCustomDataFieldList);
begin
  inherited Create;
  FFieldList := AFieldList;
end;

destructor TcxCustomDataField.Destroy;
begin
  FieldList.RemoveField(Self);
  ClearData;
  inherited Destroy;
end;

function TcxCustomDataField.CanModify(AEditValueSource: TcxDataEditValueSource): Boolean;
begin
  Result := Assigned(ValueDef)
    or DataController.IsProviderMode {don't support cancel for ValueDef = nil};
end;

function TcxCustomDataField.IsUnbound: Boolean;
begin
  Result := False;
end;

function TcxCustomDataField.IsValueDefInternal: Boolean;
begin
  Result := IsInternal;
end;

procedure TcxCustomDataField.BeginRecreateData;
begin
  if FLockRecreateData = 0 then
    ClearData;
  Inc(FLockRecreateData);
end;

procedure TcxCustomDataField.Changed;
begin
  if (FieldList.DataController.Provider.LockCount = 0) then
    FieldList.DataController.Provider.LayoutChanged([lcStructure]);
end;

procedure TcxCustomDataField.ClearData;
begin
  if Assigned(FReferenceField) then Exit;
  if Assigned(FValueDef) then
  begin
    FValueDef.Free;
    FValueDef := nil;
  end;
end;

procedure TcxCustomDataField.CreateData;
var
  ADataStorage: TcxDataStorage;
begin
  if Assigned(FReferenceField) or (FValueTypeClass = nil) then Exit;
  ClearData;
  ADataStorage := FieldList.DataController.DataStorage;
  FValueDef := ADataStorage.ValueDefs.Add(FValueTypeClass, IsInternal, TextStored, Self);
end;

procedure TcxCustomDataField.EndRecreateData;
begin
  Dec(FLockRecreateData);
  if FLockRecreateData = 0 then
    CreateData;
end;

procedure TcxCustomDataField.Reassign(ASource: TcxCustomDataField);
begin
  FReferenceField := nil;
  FValueDef := ASource.FValueDef;
  if FValueDef <> nil then
    FValueDef.LinkObject := Self;
  FValueTypeClass := ASource.FValueTypeClass;
  ASource.FValueDef := nil;
  ASource.FValueTypeClass := nil;
end;

procedure TcxCustomDataField.RemoveNotification(AComponent: TComponent);
begin
end;

function TcxCustomDataField.GetDataController: TcxCustomDataController;
begin
  Result := FieldList.DataController;
end;

function TcxCustomDataField.GetIndex: Integer;
begin
  Result := FieldList.FItems.IndexOf(Self);
end;

function TcxCustomDataField.GetNotifier: TComponent;
begin
  Result := FieldList.DataController.Notifier;
end;

function TcxCustomDataField.GetTextStored: Boolean;
begin
  if Assigned(FReferenceField) then
    Result := FReferenceField.TextStored
  else
    Result := FTextStored;
end;

function TcxCustomDataField.GetValueDef: TcxValueDef;
begin
  if Assigned(FReferenceField) then
    Result := FReferenceField.ValueDef
  else
    Result := FValueDef;
end;

function TcxCustomDataField.GetValueTypeClass: TcxValueTypeClass;
begin
  if Assigned(FReferenceField) then
    Result := FReferenceField.ValueTypeClass
  else
    Result := FValueTypeClass;
end;

procedure TcxCustomDataField.SetIndex(Value: Integer);
var
  ACurIndex: Integer;
begin
  ACurIndex := Index;
  if ACurIndex <> Value then
    FieldList.FItems.Move(ACurIndex, Value);
end;

procedure TcxCustomDataField.SetIsInternal(Value: Boolean);
begin
  if FIsInternal <> Value then
  begin
    FIsInternal := Value;
    FieldList.Update;
  end;
end;

procedure TcxCustomDataField.SetReferenceField(Value: TcxCustomDataField);
begin
  if FReferenceField <> Value then
  begin
    if Value <> nil then
    begin
      while Value.FReferenceField <> nil do
        Value := Value.FReferenceField;
    end;
    if Value <> Self then
    begin
      if FReferenceField = nil then
        ValueTypeClass := nil;
      FReferenceField := Value;
    end;
  end;
end;

procedure TcxCustomDataField.SetTextStored(Value: Boolean);
begin
  if Assigned(FReferenceField) then Exit;
  if FTextStored <> Value then
  begin
    BeginRecreateData;
    try
      FTextStored := Value;
    finally
      EndRecreateData;
    end;
  end;
end;

procedure TcxCustomDataField.SetValueTypeClass(Value: TcxValueTypeClass);
begin
  if Assigned(FReferenceField) then Exit;
  if FValueTypeClass <> Value then
  begin
    BeginRecreateData;
    try
      FValueTypeClass := Value;
    finally
      EndRecreateData;
    end;
  end;
end;

{ TcxCustomDataFieldList }

constructor TcxCustomDataFieldList.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FItems := TList.Create;
  FDataController := ADataController;
end;

destructor TcxCustomDataFieldList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

function TcxCustomDataFieldList.FieldByItem(AItem: TObject): TcxCustomDataField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].Item = AItem then
    begin
      Result := Items[I];
      Break;
    end;
end;

procedure TcxCustomDataFieldList.ReassignFields(ADestroyedField: TcxCustomDataField);
var
  I: Integer;
  ACurrentField, ANewReferenceField: TcxCustomDataField;
begin
  ANewReferenceField := nil;
  for I := 0 to Count - 1 do
  begin
    ACurrentField := Items[I];
    if ACurrentField.ReferenceField = ADestroyedField then
    begin
      if ANewReferenceField = nil then
      begin
        ANewReferenceField := ACurrentField;
        ACurrentField.Reassign(ADestroyedField);
      end
      else
        ACurrentField.ReferenceField := ANewReferenceField;
    end;
  end;
end;

procedure TcxCustomDataFieldList.Add(AField: TcxCustomDataField);
begin
  if not AField.IsInternal then
    FItems.Insert(ItemCount, AField) // Before Internal Fields
  else
    FItems.Add(AField);
  Update;  
end;

procedure TcxCustomDataFieldList.Clear;
begin
  while FItems.Count > 0 do
    TcxCustomDataField(FItems.Last).Free;
end;

procedure TcxCustomDataFieldList.RemoveField(AField: TcxCustomDataField);
var
  ASavedField: TcxCustomDataField;
begin
  FFieldDestroyed := True;
  ASavedField := AField;
//  DataController.RemoveField(AField);
  ReassignFields(AField);
  FItems.Remove(AField);
  DataController.RemoveField(ASavedField);
  Update;
end;

procedure TcxCustomDataFieldList.RemoveNotification(AComponent: TComponent);
var
  I: Integer;
begin
  I := 0;
  while I < Count do
  begin
    Items[I].RemoveNotification(AComponent);
    Inc(I);
  end;
end;

procedure TcxCustomDataFieldList.Update;
var
  I: Integer;
begin
  FInternalCount := 0;
  for I := 0 to Count - 1 do
    if Items[I].IsInternal then
      Inc(FInternalCount);
end;

function TcxCustomDataFieldList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxCustomDataFieldList.GetItem(Index: Integer): TcxCustomDataField;
begin
  Result := TcxCustomDataField(FItems[Index]);
end;

function TcxCustomDataFieldList.GetItemCount: Integer;
begin
  Result := FItems.Count - FInternalCount;
end;

{ TcxDetailInfoObject }

destructor TcxDetailInfoObject.Destroy;
begin
  LinkObject.Free;
  inherited Destroy;;
end;

{ TcxDetailObject }

constructor TcxDetailObject.Create;
begin
  inherited Create;
  FActiveRelationIndex := -1;
  FInfoObjects := TList.Create;
end;

destructor TcxDetailObject.Destroy;
begin
  Clear;
  FInfoObjects.Free;
  inherited Destroy;
end;

procedure TcxDetailObject.Clear;
var
  I: Integer;
  AObject: TObject; 
begin
  for I := 0 to FInfoObjects.Count - 1 do
  begin
    AObject := TObject(FInfoObjects[I]);
    FInfoObjects[I] := nil;
    AObject.Free;
  end;
  FInfoObjects.Clear;
end;

function TcxDetailObject.ClearHasChildrenFlag: Boolean;
var
  I: Integer;
  AInfoObject: TcxDetailInfoObject;
begin
  Result := False;
  for I := 0 to FInfoObjects.Count - 1 do
  begin
    AInfoObject := TcxDetailInfoObject(FInfoObjects[I]);
    if AInfoObject <> nil then
    begin
      if not Result and AInfoObject.HasChildrenAssigned then
        Result := True;
      AInfoObject.HasChildrenAssigned := False;
    end;
  end;    
end;

procedure TcxDetailObject.ClearInfoObject(AIndex: Integer);
begin
  TObject(FInfoObjects[AIndex]).Free;
  FInfoObjects[AIndex] := nil;
end;

procedure TcxDetailObject.CorrectCount(ARelations: TcxCustomDataRelationList);
var
  I: Integer;
begin
  if FInfoObjects.Count < ARelations.Count then
    ListSetCount(FInfoObjects, ARelations.Count);
  if FInfoObjects.Count > 0 then
  begin
    if FActiveRelationIndex < 0 then
      FActiveRelationIndex := 0;
    if FActiveRelationIndex >= ARelations.Count then // !!!
      FActiveRelationIndex := ARelations.Count - 1;
    // Check Hidden Levels
    if ARelations[FActiveRelationIndex].DetailDataController = nil then
      for I := 0 to ARelations.Count - 1 do
        if ARelations[I].DetailDataController <> nil then
        begin
          FActiveRelationIndex := I;
          Break;
        end;
  end
  else
    FActiveRelationIndex := -1;
end;

function TcxDetailObject.GetInfoObject(Index: Integer): TcxDetailInfoObject;
begin
  if (0 <= Index) and (Index < FInfoObjects.Count) then
    Result := TcxDetailInfoObject(FInfoObjects[Index])
  else
    Result := nil;
end;

function TcxDetailObject.GetInfoObjectCount: Integer;
begin
  if FInfoObjects <> nil then
    Result := FInfoObjects.Count
  else
    Result := 0;
end;

function TcxDetailObject.GetIsEmpty: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to LinkObjectCount - 1 do
    if LinkObjects[I] <> nil then
    begin
      Result := False;
      Break;
    end;
end;

function TcxDetailObject.GetLinkObject(Index: Integer): TObject;
var
  AInfoObject: TcxDetailInfoObject;
begin
  Result := nil;
  if (0 <= Index) and (Index < InfoObjectCount) then
  begin
    AInfoObject := InfoObjects[Index];
    if AInfoObject <> nil then
      Result := AInfoObject.LinkObject;
  end;
end;

function TcxDetailObject.GetLinkObjectCount: Integer;
begin
  Result := InfoObjectCount;
end;

procedure TcxDetailObject.SetInfoObject(Index: Integer; Value: TcxDetailInfoObject);
begin
  if Index >= FInfoObjects.Count then
    ListSetCount(FInfoObjects, Index + 1);
  FInfoObjects[Index] := Value;
end;

procedure TcxDetailObject.SetLinkObject(Index: Integer; Value: TObject);
begin
  if Index >= FInfoObjects.Count then
    ListSetCount(FInfoObjects, Index + 1);
  if FInfoObjects[Index] = nil then
    FInfoObjects[Index] := TcxDetailInfoObject.Create;
  TcxDetailInfoObject(FInfoObjects[Index]).LinkObject := Value;
end;

{ TcxCustomDataRelation }

constructor TcxCustomDataRelation.Create(ARelationList: TcxCustomDataRelationList;
  AItem: TObject);
begin
  inherited Create;
  FItem := AItem;
  ARelationList.AddItem(Self);
end;

destructor TcxCustomDataRelation.Destroy;
begin
  if FDetailDataController <> nil then
  begin
    FDetailDataController.SetMasterMode(nil, FDetailDataController.IsPattern);
    FDetailDataController := nil;
  end;
  FRelationList.RemoveItem(Self);
  inherited Destroy;
end;

procedure TcxCustomDataRelation.Assign(ASource: TcxCustomDataRelation);
begin
end;

procedure TcxCustomDataRelation.Changed;
begin
  FRelationList.Changed(Self);
end;

procedure TcxCustomDataRelation.RemoveDataField(ADataField: TcxCustomDataField);
begin
end;

function TcxCustomDataRelation.GetDataController: TcxCustomDataController;
begin
  Result := FRelationList.DataController;
end;

function TcxCustomDataRelation.GetIndex: Integer;
begin
  Result := FRelationList.FItems.IndexOf(Self);
end;

{ TcxCustomDataRelationList }

constructor TcxCustomDataRelationList.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FItems := TList.Create;
  FDataController := ADataController;
end;

destructor TcxCustomDataRelationList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

function TcxCustomDataRelationList.Add(AItem: TObject): TcxCustomDataRelation;
begin
  Result := DataController.GetRelationClass.Create(Self, AItem);
end;

procedure TcxCustomDataRelationList.Assign(ASource: TcxCustomDataRelationList);
var
  I: Integer;
begin
  BeginUpdate;
  try
    Clear;
    for I := 0 to ASource.Count - 1 do
      Add(ASource[I].Item).Assign(ASource[I]);
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataRelationList.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxCustomDataRelationList.Clear;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := Count - 1 downto 0 do
      Items[I].Free;
  finally
    EndUpdate;
  end;
end;

function TcxCustomDataRelationList.ClearDetailObject(ARecordIndex, ARelationIndex: Integer): Boolean;
var
  ADetailObject: TcxDetailObject;
begin
  Result := False;
  DataController.CheckRecordRange(ARecordIndex);
  if Assigned(FDataField) then
  begin
    ADetailObject := GetValueAsDetailObject(ARecordIndex);
    if Assigned(ADetailObject) then
    begin
      if ARelationIndex = -1 then
        ADetailObject.Clear
      else
        ADetailObject.ClearInfoObject(ARelationIndex);
      Result := True;
    end;
  end;
end;

procedure TcxCustomDataRelationList.EndUpdate;
begin
  Dec(FLockCount);
  Changed(nil);
end;

function TcxCustomDataRelationList.FindByItem(AItem: TObject): TcxCustomDataRelation;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Items[I].Item = AItem then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TcxCustomDataRelationList.GetDetailObject(ARecordIndex: Integer): TcxDetailObject;

  procedure ResetMasterRelations(ADetailObject: TcxDetailObject);
  var
    I: Integer;
    ADetailLinkObject: TObject;
  begin
    for I := 0 to ADetailObject.LinkObjectCount - 1 do
    begin
      ADetailLinkObject := ADetailObject.LinkObjects[I];
      if ADetailLinkObject <> nil then
        DataController.GetDetailDataControllerByLinkObject(ADetailLinkObject).FMasterRelation := nil;
    end;
  end;

begin
  DataController.CheckRecordRange(ARecordIndex);
  if Assigned(FDataField) then
  begin
    Result := GetValueAsDetailObject(ARecordIndex);
    if IsEmpty then
    begin
      if Result <> nil then
      begin
        ResetMasterRelations(Result);
        Result.Free;
        Result := nil;
        DataController.SetStoredValue(ARecordIndex, FDataField,
          Integer(Result));
      end;
      Exit;
    end;
    if Result = nil then
    begin
      Result := TcxDetailObject.Create;
      Result.ActiveRelationIndex := DataController.GetDefaultActiveRelationIndex;
      DataController.SetStoredValue(ARecordIndex, FDataField,
        Integer(Result));
    end;
    Result.CorrectCount(Self);
  end
  else
    Result := nil;
end;

function TcxCustomDataRelationList.IsDetailObjectExist(ARecordIndex, ARelationIndex: Integer): Boolean;
var
  ADetailObject: TcxDetailObject;
begin
  DataController.CheckRecordRange(ARecordIndex);
  Result := False;
  if Assigned(FDataField) then
  begin
    ADetailObject := GetValueAsDetailObject(ARecordIndex);
    Result := Assigned(ADetailObject) and
      (((ARelationIndex = -1) and not ADetailObject.IsEmpty) or
       ((ARelationIndex <> -1) and (ADetailObject.LinkObjects[ARelationIndex] <> nil)));
  end;
end;

function TcxCustomDataRelationList.IsEmpty: Boolean;
var
  APatternRelations: TcxCustomDataRelationList;
  I: Integer;
begin
  Result := True;
  if DataController.GetPatternDataController <> nil then
  begin
    APatternRelations := DataController.GetPatternDataController.Relations;
    for I := 0 to APatternRelations.Count - 1 do
      if APatternRelations[I].DetailDataController <> nil then
      begin
        Result := False;
        Break;
      end;
  end;
end;

procedure TcxCustomDataRelationList.Move(ACurIndex, ANewIndex: Integer);
var
  ARelation: TcxCustomDataRelation;
begin
  if ACurIndex <> ANewIndex then
  begin
    ARelation := TcxCustomDataRelation(FItems[ACurIndex]);
    FItems.Delete(ACurIndex);
    FItems.Insert(ANewIndex, ARelation);
    Changed(nil);
  end;
end;

procedure TcxCustomDataRelationList.RemoveByItem(AItem: TObject);
var
  ARelation: TcxCustomDataRelation;
begin
  ARelation := FindByItem(AItem);
  if ARelation <> nil then
    ARelation.Free;
end;

procedure TcxCustomDataRelationList.Changed(ARelation: TcxCustomDataRelation);
begin
  if LockCount = 0 then
    Update(ARelation);
end;

function TcxCustomDataRelationList.GetValueAsDetailObject(ARecordIndex: Integer): TcxDetailObject;
var
  AValue: Variant;
begin
  AValue := DataController.GetInternalValue(ARecordIndex, FDataField);
  if VarIsNull(AValue) then
    Result := nil
  else
    Result := TcxDetailObject(Integer(AValue));
end;

procedure TcxCustomDataRelationList.RemoveDataField(ADataField: TcxCustomDataField);
var
  I: Integer;
begin
  if ADataField = FDataField then
    FDataField := nil;
  for I := 0 to Count - 1 do
    Items[I].RemoveDataField(ADataField);
end;

procedure TcxCustomDataRelationList.Update(ARelation: TcxCustomDataRelation);
begin
  DataController.BeginUpdate;
  try
    if Count = 0 then
      FDataField.Free // FDataField <- nil (in RemoveDataField method)
    else
      if FDataField <> nil then
      begin
        DataController.ClearDetails;
      end
      else
      begin
        FDataField := DataController.AddInternalField;
        FDataField.ValueTypeClass := TcxObjectValueType;
      end;
    DataController.UpdateRelations(ARelation);
  finally
    DataController.EndUpdate;
  end;
end;

procedure TcxCustomDataRelationList.AddItem(AItem: TcxCustomDataRelation);
begin
  FItems.Add(AItem);
  AItem.FRelationList := Self;
  Changed(AItem);
end;

function TcxCustomDataRelationList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxCustomDataRelationList.GetItem(Index: Integer): TcxCustomDataRelation;
begin
  Result := TcxCustomDataRelation(FItems[Index]);
end;

procedure TcxCustomDataRelationList.RemoveItem(AItem: TcxCustomDataRelation);
begin
  DataController.ClearDetailsMasterRelation(AItem);
  FItems.Remove(AItem);
  AItem.FRelationList := nil;
  Changed(AItem);
end;

{ TcxSortingFieldList }

constructor TcxSortingFieldList.Create;
begin
  inherited Create;
  FItems := TList.Create;
end;

destructor TcxSortingFieldList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TcxSortingFieldList.AppendFrom(AList: TcxSortingFieldList);
var
  I: Integer;
begin
  for I := 0 to AList.Count - 1 do
    if Find(AList[I].Field) = -1 then
      Add(AList[I].Field, AList[I].SortOrder);
end;

procedure TcxSortingFieldList.ChangeSorting(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
var
  AIndex: Integer;
begin
  AIndex := Find(AField);
  if AIndex = -1 then
  begin
    if ASortOrder <> soNone then
      Add(AField, ASortOrder);
  end
  else
    if ASortOrder = soNone then
      Delete(AIndex)
    else
      SetSortOrder(AIndex, ASortOrder);
end;

procedure TcxSortingFieldList.CheckField(AField: TcxCustomDataField);
begin
  if Find(AField) <> -1 then
    Changed;
end;

procedure TcxSortingFieldList.Clear;
begin
  while Count > 0 do
    Delete(0);
end;

function TcxSortingFieldList.SortIndexByField(AField: TcxCustomDataField): Integer;
begin
  Result := Find(AField);
end;

function TcxSortingFieldList.SortOrderByField(AField: TcxCustomDataField): TcxDataSortOrder;
var
  AIndex: Integer;
begin
  AIndex := SortIndexByField(AField);
  if AIndex <> -1 then
    Result := Items[AIndex].SortOrder
  else
    Result := soNone;
end;

procedure TcxSortingFieldList.Add(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
var
  PInfo: PcxDataSortInfo;
begin
  New(PInfo);
  PInfo.Field := AField;
  PInfo.SortOrder := ASortOrder;
  FItems.Add(PInfo);
  Changed;
end;

procedure TcxSortingFieldList.Changed;
begin
  if Assigned(FOnChanged) then FOnChanged;
end;

procedure TcxSortingFieldList.Delete(Index: Integer);
begin
  Dispose(PcxDataSortInfo(FItems[Index]));
  FItems.Delete(Index);
  Changed;
end;

function TcxSortingFieldList.Find(AField: TcxCustomDataField): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].Field = AField then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxSortingFieldList.Insert(Index: Integer; AField: TcxCustomDataField;
  ASortOrder: TcxDataSortOrder);
var
  PInfo: PcxDataSortInfo;
begin
  New(PInfo);
  PInfo.Field := AField;
  PInfo.SortOrder := ASortOrder;
  FItems.Insert(Index, PInfo);
  Changed;
end;

procedure TcxSortingFieldList.Move(ACurIndex, ANewIndex: Integer);
begin
  if ACurIndex <> ANewIndex then
  begin
    FItems.Move(ACurIndex, ANewIndex);
    Changed;
  end;
end;

procedure TcxSortingFieldList.Remove(AField: TcxCustomDataField);
var
  AIndex: Integer;
begin
  AIndex := Find(AField);
  if AIndex <> -1 then
    Delete(AIndex);
end;

procedure TcxSortingFieldList.SetSortOrder(Index: Integer; ASortOrder: TcxDataSortOrder);
begin
  if PcxDataSortInfo(FItems[Index]).SortOrder <> ASortOrder then
  begin
    PcxDataSortInfo(FItems[Index]).SortOrder := ASortOrder;
    Changed;
  end;
end;

function TcxSortingFieldList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxSortingFieldList.GetItem(Index: Integer): TcxDataSortInfo;
begin
  Result := PcxDataSortInfo(FItems[Index])^;
end;

{ TcxGroupingFieldList }

procedure TcxGroupingFieldList.ChangeGrouping(AField: TcxCustomDataField; AGroupIndex: Integer);
var
  AIndex, ANewIndex: Integer;
begin
  if AGroupIndex < 0 then
    Remove(AField)
  else
  begin
    ANewIndex := AGroupIndex;
    AIndex := Find(AField);
    if AIndex = -1 then
    begin
      if ANewIndex > Count then
        ANewIndex := Count;
      Insert(ANewIndex, AField, soAscending);
    end
    else
    begin
      if ANewIndex > (Count - 1) then
        ANewIndex := Count - 1;
      Move(AIndex, ANewIndex);
    end;
  end;
end;

procedure TcxGroupingFieldList.ChangeSorting(AField: TcxCustomDataField; ASortOrder: TcxDataSortOrder);
begin
  if ASortOrder = soNone then
    ASortOrder := soAscending;
  inherited ChangeSorting(AField, ASortOrder);
end;

function TcxGroupingFieldList.GroupIndexByField(AField: TcxCustomDataField): Integer;
begin
  Result := Find(AField);
end;

procedure TcxGroupingFieldList.UpdateSorting(ASortingFieldList: TcxSortingFieldList);
var
  I, AIndex: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    AIndex := ASortingFieldList.Find(Items[I].Field);
    if AIndex <> -1 then
      SetSortOrder(I, ASortingFieldList[AIndex].SortOrder)
    else
      SetSortOrder(I, soAscending);
  end;
end;

{ TcxDataGroups }

constructor TcxDataGroups.Create;
begin
  inherited Create;
  FFields := TList.Create;
  FItems := TList.Create;
end;

destructor TcxDataGroups.Destroy;
begin
  Clear;
  FFields.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TcxDataGroups.ChangeExpanding(ARowIndex: Integer; AExpanded, ARecursive: Boolean);
var
  AItem: TcxDataGroupInfo;
  I: Integer;
begin
  if (Find(ARowIndex, AItem) <> -1) and Assigned(AItem) then
  begin
    AItem.Expanded := AExpanded;
    if ARecursive and (AItem.Level < (LevelCount - 1)) then
    begin
      for I := AItem.BeginRecordListIndex to Count - 1 do
        if Items[I].Level > AItem.Level then
          Items[I].Expanded := AExpanded
        else
          Break;
    end;
    Rebuild;
  end;
end;

procedure TcxDataGroups.FullExpanding(AExpanded: Boolean);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Expanded := AExpanded;
  Rebuild;
end;

function TcxDataGroups.GetChildCount(AIndex: Integer): Integer;
var
  I, L: Integer;
begin
  if AIndex = -1 then
    Result := GetFirstLevelCount
  else
  begin
    Result := 0;
    if (0 <= AIndex) and (AIndex < Count) then
    begin
      L := Items[AIndex].Level + 1;
      if L = LevelCount then
        Result := Items[AIndex].EndRecordListIndex - Items[AIndex].BeginRecordListIndex + 1
      else
        for I := Items[AIndex].BeginRecordListIndex to Items[AIndex].EndRecordListIndex do
          if Items[I].Level = L then
            Inc(Result);
    end;
  end;
end;

function TcxDataGroups.GetChildIndex(AParentIndex, AIndex: Integer): Integer;
var
  I, J, L: Integer;
begin
  if AParentIndex = -1 then
    Result := GetFirstLevelIndex(AIndex)
  else
  begin
    Result := -1;
    if (0 <= AParentIndex) and (AParentIndex < Count) and
      (Items[AParentIndex].Level < (LevelCount - 1)) and
      (0 <= AIndex) and (AIndex <= (Items[AParentIndex].EndRecordListIndex - Items[AParentIndex].BeginRecordListIndex)) then
//      (Items[AParentIndex].BeginRecordListIndex <= AIndex) and
//      (AIndex <= Items[AParentIndex].EndRecordListIndex) then
    begin
      L := Items[AParentIndex].Level + 1;
      J := -1;
      for I := Items[AParentIndex].BeginRecordListIndex to Items[AParentIndex].EndRecordListIndex do
        if Items[I].Level = L then
        begin
          Inc(J);
          if J = AIndex then
          begin
            Result := I;
            Break;
          end;
        end;
    end;
  end;
end;

function TcxDataGroups.GetChildRecordListIndex(AParentIndex, AIndex: Integer): Integer;
begin
  Result := -1;
  if (0 <= AParentIndex) and (AParentIndex < Count) and
    (Items[AParentIndex].Level = (LevelCount - 1)) and
    (0 <= AIndex) and (AIndex <= (Items[AParentIndex].EndRecordListIndex - Items[AParentIndex].BeginRecordListIndex)) then
  begin
    Result := Items[AParentIndex].BeginRecordListIndex + AIndex;
  end;
end;

function TcxDataGroups.GetDataRecordListIndex(AInfo: TcxDataGroupInfo): Integer;
begin
  while AInfo.Level < LevelCount - 1 do
    AInfo := Items[AInfo.BeginRecordListIndex];
  Result := AInfo.BeginRecordListIndex;
end;

function TcxDataGroups.GetFirstLevelCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Items[I].Level = 0 then
      Inc(Result);
end;

function TcxDataGroups.GetFirstLevelIndex(AIndex: Integer): Integer;
var
  I, J: Integer;
begin
  Result := -1;
  J := -1;
  for I := 0 to Count - 1 do
    if Items[I].Level = 0 then
    begin
      Inc(J);
      if J = AIndex then
      begin
        Result := I;
        Break;
      end;
    end;  
end;

function TcxDataGroups.GetIndexByRowIndex(ARowIndex: Integer): Integer;
begin
  Result := GetIndexByRowIndexLevel(ARowIndex, -1);
end;

function TcxDataGroups.GetIndexByRowIndexLevel(ARowIndex, ALevel: Integer): Integer;
var
  AIndex: Integer;
  AItem: TcxDataGroupInfo;
begin
  Result := Find(ARowIndex, AItem);
  if (Result = -1) and (AItem <> nil) then // if it is a data row, go to the nearest top group row
  begin
    ARowIndex := AItem.RowIndex;
    Result := Find(ARowIndex, AItem);
  end;
  if (Result <> -1) and (ALevel <> -1) then
  begin
    AIndex := Result;
    Result := -1;
    if Items[AIndex].Level < ALevel then
    begin
      while AIndex < Count do
      begin
        AItem := Items[AIndex];
        if AItem.Level = ALevel then
        begin
          Result := AIndex;
          Break;
        end;
        Inc(AIndex);
      end;
    end
    else
    begin
      while AIndex >= 0 do
      begin
        AItem := Items[AIndex];
        if AItem.Level = ALevel then
        begin
          Result := AIndex;
          Break;
        end;
        Dec(AIndex);
      end;
    end;
  end;
end;

function TcxDataGroups.GetLevel(AIndex: Integer): Integer;
begin
  if (0 <= AIndex) and (AIndex < Count) then
    Result := Items[AIndex].Level
  else
    Result := -1;
end;

function TcxDataGroups.GetParentIndex(AChildIndex: Integer): Integer;
var
  ALevel: Integer;
begin
  Result := -1;
  if (0 <= AChildIndex) and (AChildIndex < Count) then
  begin
    ALevel := Items[AChildIndex].Level;
    while AChildIndex >= 0 do
    begin
      if Items[AChildIndex].Level < ALevel then
      begin
        Result := AChildIndex;
        Break;
      end
      else
        if ALevel = 0 then
          Break;
      Dec(AChildIndex);
    end;
  end;
end;

procedure TcxDataGroups.Add(const ADataGroupInfo: TcxDataGroupInfo);
begin
  with AddEmpty do
  begin
    RowIndex := ADataGroupInfo.RowIndex;
    Expanded := ADataGroupInfo.Expanded;
    Level := ADataGroupInfo.Level;
    BeginRecordListIndex := ADataGroupInfo.BeginRecordListIndex;
    EndRecordListIndex := ADataGroupInfo.EndRecordListIndex;
    SummaryValues := ADataGroupInfo.SummaryValues;
  end;
end;

procedure TcxDataGroups.AddField(AField: TcxCustomDataField);
begin
  FFields.Add(AField);
end;

function TcxDataGroups.AddEmpty: TcxDataGroupInfo;
begin
  Result := TcxDataGroupInfo.Create;
  FItems.Add(Result);
end;

procedure TcxDataGroups.Clear;
var
  I: Integer;
  AInfo: TcxDataGroupInfo;
begin
  FFields.Clear;
  for I := 0 to FItems.Count - 1 do
  begin
    AInfo := TcxDataGroupInfo(FItems[I]);
    AInfo.Free;
  end;
  FItems.Clear;
end;

function TcxDataGroups.Find(ARowIndex: Integer; var AItem: TcxDataGroupInfo): Integer;
var
  L, H, I, C: Integer;
begin
  AItem := nil;
  Result := -1;
  L := 0;
  H := Count - 1;
  if L <= H then
    repeat
      I := (L + H) div 2;
      AItem := Items[I];
      C := AItem.RowIndex - ARowIndex;
      if C = 0 then // It's Group
      begin
        AItem := GetTopVisibleItem(ARowIndex, I);
        Result := I;
        Break;
      end
      else
        if C < 0 then
          L := I + 1
        else
          H := I - 1;
      if L > H then
      begin
        AItem := Items[L - 1];
        Break;
      end;
    until False;
end;

function TcxDataGroups.FindByIndex(ARecordListIndex, ALevel: Integer): Integer;
var
  I, ALastLevel, AAnchor: Integer;
  AItem: TcxDataGroupInfo;
begin
  Result := -1;
  AAnchor := -1;
  ALastLevel := LevelCount - 1;
  for I := 0 to Count - 1 do
  begin
    AItem := Items[I];
    if AItem.Level = ALevel then
      AAnchor := I;
    if (AItem.Level = ALastLevel) and
      (AItem.BeginRecordListIndex <= ARecordListIndex) and
      (ARecordListIndex <= AItem.EndRecordListIndex) then  // only for Data rows
    begin
      Result := AAnchor;
      Break;
    end;
  end;
end;

function TcxDataGroups.IsVisible(AIndex: Integer): Boolean;
var
  I: Integer;
begin
  I := AIndex;
  GetTopVisibleItem(Items[AIndex].RowIndex, I);
  Result := I = AIndex;
end;

function TcxDataGroups.MakeVisible(AIndex: Integer; AExpand: Boolean): Boolean;

  procedure ExpandItem(AItem: TcxDataGroupInfo);
  begin
    if not AItem.Expanded then
    begin
      AItem.Expanded := True;
      Result := True;
    end;
  end;

var
  I, ALevel: Integer;
  AItem: TcxDataGroupInfo;
begin
  Result := False;
  I := AIndex;
  repeat
    AItem := Items[I];
    if AExpand then
      ExpandItem(AItem);
    AExpand := True;
    ALevel := AItem.Level;
    if ALevel = 0 then
      Break
    else
      while I > 0 do
      begin
        Dec(I);
        if Items[I].Level < ALevel then
          Break;
      end;
  until False;
  if Result then
    Rebuild;
end;

function TcxDataGroups.GetField(Index: Integer): TcxCustomDataField;
begin
  Result := TcxCustomDataField(FFields[Index]);
end;

function TcxDataGroups.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TcxDataGroups.GetItem(Index: Integer): TcxDataGroupInfo;
begin
  Result := TcxDataGroupInfo(FItems[Index]);
end;

function TcxDataGroups.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxDataGroups.GetRowCount: Integer;
var
  AItem: TcxDataGroupInfo;
  I, ARowIndex: Integer;
begin
  if Count > 0 then
  begin
    I := Count - 1;
    AItem := Items[I];
    ARowIndex := AItem.RowIndex;
    Result := ARowIndex + 1;
    AItem := GetTopVisibleItem(ARowIndex, I);
    if AItem.Expanded then
      Inc(Result, AItem.EndRecordListIndex - AItem.BeginRecordListIndex + 1); // only for Data rows
  end
  else
    Result := 0;
end;

function TcxDataGroups.GetRowInfo(ARowIndex: Integer): TcxGroupsRowInfo;
var
  AItem: TcxDataGroupInfo;
begin
  Result.Expanded := False;
  Result.Level := 0;
  Result.RecordListIndex := 0;
  if Find(ARowIndex, AItem) <> -1 then // Group
  begin
    Result.Level := AItem.Level;
    Result.Expanded := AItem.Expanded;
    Result.RecordListIndex := GetDataRecordListIndex(AItem);
  end
  else
    if AItem <> nil then
    begin
      Result.Level := LevelCount;
      Result.Expanded := False;
      Result.RecordListIndex := AItem.BeginRecordListIndex + (ARowIndex - AItem.RowIndex - 1);
    end;
end;

function TcxDataGroups.GetTopVisibleItem(ARowIndex: Integer; var ACurIndex: Integer): TcxDataGroupInfo;
var
  I, J: Integer;
  AMaxLevel: Integer;
  AItem: TcxDataGroupInfo;
begin
  I := ACurIndex;
  J := I;
  AMaxLevel := Items[I].Level;
  repeat
    AItem := Items[I];
    if AItem.RowIndex <> ARowIndex then
      Break;
    // check level
    if AItem.Level < AMaxLevel then
    begin
      AMaxLevel := AItem.Level;
      if not AItem.Expanded then
        J := I;
    end;
    if AItem.Level = 0 then
      Break;
    Dec(I);
  until False;
  Result := Items[J];
  ACurIndex := J;
end;

procedure TcxDataGroups.Rebuild;
var
  ACurIndex, ARowIndex: Integer;

  procedure SubItems(ALevel: Integer; AVisible: Boolean);
  var
    AItem: TcxDataGroupInfo;
  begin
    Inc(ACurIndex);
    while ACurIndex < Count do
    begin
      AItem := Items[ACurIndex];
      if AItem.Level = ALevel then
      begin
        AItem.RowIndex := ARowIndex;
        if AVisible and AItem.Expanded and (AItem.Level = (LevelCount - 1)) then
          Inc(ARowIndex, AItem.EndRecordListIndex - AItem.BeginRecordListIndex + 1)
        else
        begin
          if AVisible and AItem.Expanded then
            Inc(ARowIndex);
          SubItems(AItem.Level + 1, AVisible and AItem.Expanded);
        end;
      end
      else
      begin
        if AVisible then Dec(ARowIndex);
        Dec(ACurIndex);
        Break;
      end;
      Inc(ACurIndex);
      if AVisible then Inc(ARowIndex);
    end;
  end;

begin
  ACurIndex := -1;
  ARowIndex := 0;
  SubItems(0, True);
end;

procedure TcxDataGroups.SetItem(AIndex: Integer; AItem: TcxDataGroupInfo);
begin
  FItems[AIndex] := AItem;
end;

{ TcxDataFocusingInfo }

constructor TcxDataFocusingInfo.Create(ADataControllerInfo: TcxCustomDataControllerInfo);
begin
  inherited Create;
  FDataControllerInfo := ADataControllerInfo;
  FLevel := -1;
  FPrevRecordIndex := -1;
  FRecordIndex := -1;
  FRowIndex := -1;
end;

procedure TcxDataFocusingInfo.Assign(AFocusingInfo: TcxDataFocusingInfo);
begin
  FLevel := AFocusingInfo.Level;
  FPrevRecordIndex := AFocusingInfo.FPrevRecordIndex;
  FRecordIndex := AFocusingInfo.RecordIndex;
  FRowIndex := AFocusingInfo.RowIndex;
  FChangedFlag := False;
  FPrevNewItemRowFocused := False;
end;

procedure TcxDataFocusingInfo.Clear;
begin
  FLevel := -1;
  FRecordIndex := -1;
  FRowIndex := -1;
end;

function TcxDataFocusingInfo.IsEqual(AFocusingInfo: TcxDataFocusingInfo): Boolean;
begin
  Result := (Self.RecordIndex = AFocusingInfo.RecordIndex) and
    (Self.Level = AFocusingInfo.Level) {and
    (Self.RowIndex = AFocusingInfo.RowIndex)};
  if Result and (dcicSorting in FDataControllerInfo.FChanges) and
    (Self.RowIndex <> AFocusingInfo.RowIndex) then
    Result := False;
end;

procedure TcxDataFocusingInfo.ResetPos;
begin
  FLevel := -1;
  FRecordIndex := FDataControllerInfo.DataController.GetRecordIndex;
end;

procedure TcxDataFocusingInfo.SavePos;
begin
  if RowIndex <> -1 then
  begin
    Level := FDataControllerInfo.GetRowInfo(RowIndex).Level;
    RecordIndex := FDataControllerInfo.DataController.GetRecordIndex;
  end
  else
  begin
    Level := -1;
    RecordIndex := -1;
  end;
  FPrevRecordIndex := FRecordIndex;
end;

{ TcxDataExpandingInfos }

constructor TcxDataExpandingInfos.Create;
begin
  inherited Create;
  FFields := TList.Create;
  FItems := TList.Create;
end;

destructor TcxDataExpandingInfos.Destroy;
begin
  Clear;
  FItems.Free;
  FFields.Free;
  inherited Destroy;
end;

procedure TcxDataExpandingInfos.AddField(AField: TcxCustomDataField);
begin
  if Find(AField) = -1 then
  begin
    FFields.Add(AField);
    ClearValues;
  end
  else
    InvalidOperation(cxSDataItemExistError);
end;

procedure TcxDataExpandingInfos.AddItem(ALevel: Integer; const AValue: Variant;
  AState: TcxDataExpandingInfoStateSet);
var
  P: PcxDataExpandingInfo;
begin
  New(P);
  FItems.Add(P);
  P.Level := ALevel;
  P.Value := AValue;
  P.State := AState;
end;

procedure TcxDataExpandingInfos.CheckField(AField: TcxCustomDataField);
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
    if Fields[I] = AField then
    begin
      Clear;
      Exit;
    end;
end;

procedure TcxDataExpandingInfos.Clear;
begin
  ClearFields;
  ClearValues;
  FSaveStates := [];
end;

procedure TcxDataExpandingInfos.ClearFields;
begin
  FFields.Clear;
end;

procedure TcxDataExpandingInfos.ClearValues;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Dispose(PcxDataExpandingInfo(FItems[I]));
  FItems.Clear;
end;

function TcxDataExpandingInfos.Find(AField: TcxCustomDataField): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FieldCount - 1 do
    if Fields[I] = AField then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataExpandingInfos.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxDataExpandingInfos.GetEmpty: Boolean;
begin
  Result := (Count = 0) or (FieldCount = 0);
end;

function TcxDataExpandingInfos.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TcxDataExpandingInfos.GetField(Index: Integer): TcxCustomDataField;
begin
  Result := TcxCustomDataField(FFields[Index]);
end;

function TcxDataExpandingInfos.GetItem(Index: Integer): PcxDataExpandingInfo;
begin
  Result := PcxDataExpandingInfo(FItems[Index]);
end;

{ TcxDataSelection }

constructor TcxDataSelection.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
  FFields := TList.Create;
  FItems := TList.Create;
  FAnchorRowIndex := -1;
end;

destructor TcxDataSelection.Destroy;
begin
  Clear;
  FItems.Free;
  FFields.Free;
  inherited Destroy;
end;

procedure TcxDataSelection.Add(AIndex, ARowIndex, ARecordIndex, ALevel: Integer);
begin
  InternalAdd(AIndex, ARowIndex, ARecordIndex, ALevel);
  Changed;
end;

procedure TcxDataSelection.AddField(AField: TcxCustomDataField);
begin
  FFields.Add(AField);
end;

procedure TcxDataSelection.Clear;
begin
  InternalClear;
  Changed;
end;

procedure TcxDataSelection.ClearAll;
begin
  ClearAnchor;
  InternalClear;
  Changed;
end;

procedure TcxDataSelection.ClearFields;
begin
  FFields.Clear;
end;

procedure TcxDataSelection.Delete(AIndex: Integer);
begin
  InternalDelete(AIndex);
  Changed;
end;

function TcxDataSelection.FindByGroupIndex(AGroupIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (Items[I].Level = -1) {It's Group} and
      (Items[I].RecordIndex = AGroupIndex) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSelection.FindByRecordIndex(ARecordIndex: Integer): Integer;
var
  I: Integer;
begin
  // TODO: to optimize
  Result := -1;
  for I := 0 to Count - 1 do
    if (Items[I].Level <> -1) {It's Detail} and
      (Items[I].RecordIndex = ARecordIndex) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSelection.FindByRowIndex(ARowIndex: Integer; var AIndex: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  AIndex := 0;
  Result := False;
  L := 0;
  H := Count - 1;
  if L <= H then
    repeat
      I := (L + H) div 2;
      C := Items[I].RowIndex - ARowIndex;
      if C = 0 then
      begin
        AIndex := I;
        Result := True;
        Break;
      end
      else
        if C < 0 then
          L := I + 1
        else
          H := I - 1;
      if L > H then
      begin
        AIndex := L;
        Break;
      end;
    until False;
end;

function TcxDataSelection.IsRecordSelected(ARecordIndex: Integer): Boolean;
begin
  Result := FindByRecordIndex(ARecordIndex) <> -1;
end;

function TcxDataSelection.IsRowSelected(ARowIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := FindByRowIndex(ARowIndex, I);
end;

procedure TcxDataSelection.Sort;
begin
  FItems.Sort(CompareSelectionList);
end;

procedure TcxDataSelection.Changed;
begin
  if Assigned(FOnChanged) then FOnChanged;
end;

procedure TcxDataSelection.CheckAfterFiltering;
var
  I: Integer;
begin
  // TODO: opt
  for I := Count - 1 downto 0 do
    if Items[I].Level <> -1 then
      if DataController.DataControllerInfo.GetInternalRecordListIndex(Items[I].RecordIndex) = -1 then
        Delete(I);
end;

procedure TcxDataSelection.ClearAnchor;
begin
  FAnchorRowIndex := -1;
end;

procedure TcxDataSelection.InternalAdd(AIndex, ARowIndex, ARecordIndex, ALevel: Integer);
var
  P: PcxDataSelectionInfo;
begin
  New(P);
  P.Level := ALevel;
  P.RecordIndex := ARecordIndex;
  P.RowIndex := ARowIndex;
  if AIndex = -1 then
    FItems.Add(P)
  else
    FItems.Insert(AIndex, P);
end;

procedure TcxDataSelection.InternalClear;
var
  I: Integer;
begin
  ClearFields;
  for I := 0 to FItems.Count - 1 do
    Dispose(PcxDataSelectioninfo(FItems[I]));
  FItems.Clear;
end;

procedure TcxDataSelection.InternalDelete(AIndex: Integer);
var
  PInfo: PcxDataSelectioninfo;
begin
  PInfo := PcxDataSelectioninfo(FItems[AIndex]);
  if PInfo.RowIndex = FAnchorRowIndex then
    ClearAnchor;
  Dispose(PInfo);
  FItems.Delete(AIndex);
end;

procedure TcxDataSelection.SetInternalCount(ACount: Integer);
var
  I: Integer;
begin
  if ACount < Count then
  begin
    for I := Count - 1 downto ACount do
      InternalDelete(I);
  end
  else
    if ACount > Count then
    begin
      for I := Count to ACount - 1 do
       InternalAdd(-1, I, I, 0);
    end;
end;

function TcxDataSelection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxDataSelection.GetField(Index: Integer): TcxCustomDataField;
begin
  Result := TcxCustomDataField(FFields[Index]);
end;

function TcxDataSelection.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TcxDataSelection.GetItem(Index: Integer): PcxDataSelectionInfo;
begin
  Result := PcxDataSelectionInfo(FItems[Index]);
end;

{ TcxCustomDataControllerInfo }

constructor TcxCustomDataControllerInfo.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
  FRecordList := TList.Create;
  FGroupingFieldList := TcxGroupingFieldList.Create;
  FGroupingFieldList.OnChanged := GroupingChanged;
  FSortingFieldList := TcxSortingFieldList.Create;
  FSortingFieldList.OnChanged := SortingChanged;
  FTotalSortingFieldList := TcxSortingFieldList.Create;
  FDataGroups := TcxDataGroups.Create;
  FExpandingInfo := TcxDataExpandingInfos.Create;
  FFocusingInfo := TcxDataFocusingInfo.Create(Self);
  FPrevFocusingInfo := TcxDataFocusingInfo.Create(Self);
  FSelection := DataController.GetDataSelectionClass.Create(DataController);
  FSelection.OnChanged := SelectionChanged;
end;

destructor TcxCustomDataControllerInfo.Destroy;
begin
  FDataGroups.Free;
  FTotalSortingFieldList.Free;
  FSortingFieldList.Free;
  FGroupingFieldList.Free;
  FRecordList.Free;
  FFocusingInfo.Free;
  FPrevFocusingInfo.Free;
  FExpandingInfo.Free;
  FSelection.Free;
  inherited Destroy;
end;

procedure TcxCustomDataControllerInfo.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxCustomDataControllerInfo.EndUpdate;
begin
  Dec(FLockCount);
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.CheckChanges;
begin
  if (FChanges <> []) and (LockCount = 0) then
    Update;
end;

procedure TcxCustomDataControllerInfo.CheckRowIndex(ARowIndex: Integer);
begin
  if not ((0 <= ARowIndex) and (ARowIndex < GetRowCount)) then
    InvalidOperation(cxSDataRowIndexError);
end;

procedure TcxCustomDataControllerInfo.Refresh;
begin
  FChanges := FChanges + [dcicLoad];
  if not DataController.LockOnAfterSummary then
    FChanges := FChanges + [dcicSummary];
  if SortingFieldList.Count <> 0 then
    FChanges := FChanges + [dcicSorting];
  if GroupingFieldList.Count <> 0 then
    FChanges := FChanges + [dcicGrouping];
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.RefreshFocused;
begin
  FChanges := FChanges + [dcicResetFocusedRow];
  FFocusingInfo.ResetPos;
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.RefreshSummary(ARedrawOnly: Boolean);
begin
  if ARedrawOnly and not IsSortingBySummary then
    FChanges := FChanges + [dcicView]
  else
    FChanges := FChanges + [dcicSummary];
  if IsSortingBySummary then
    FChanges := FChanges + [dcicGrouping];
{  if IsSortBySummary <> FIsSortBySummary then
  begin
    FIsSortBySummary := IsSortBySummary;
    DataController.DoSortBySummaryChanged;
    //FChanges := FChanges + [dcicGrouping];
  end;}
  CheckChanges;
end;

// Notify

procedure TcxCustomDataControllerInfo.ExpandingChanged;
begin
  FChanges := FChanges + [dcicExpanding];
  FExpandingFlag := True;
end;

procedure TcxCustomDataControllerInfo.FocusedRecordChanged(AChangedFlag: Boolean);
begin
  FChanges := FChanges + [dcicFocusedRecord]; //?
  if AChangedFlag then
    FPrevFocusingInfo.FChangedFlag := True;
end;  

procedure TcxCustomDataControllerInfo.GroupingChanged;
begin
  FChanges := FChanges + [dcicSorting, dcicGrouping, dcicSummary];
end;

procedure TcxCustomDataControllerInfo.SelectionChanged;
begin
  FChanges := FChanges + [dcicSelection];
  if [soSelectedRecords, soMultipleSelectedRecords] * DataController.Summary.Options <> [] then
    FChanges := FChanges + [dcicSummary];
end;

procedure TcxCustomDataControllerInfo.SortingChanged;
begin
  FChanges := FChanges + [dcicSorting];
end;

// Structure

procedure TcxCustomDataControllerInfo.RemoveField(AField: TcxCustomDataField);
begin
  FSortingFieldList.ChangeSorting(AField, soNone);
  if FGroupingFieldList.Find(AField) <> -1 then FSelection.ClearAll;
  FGroupingFieldList.ChangeGrouping(AField, -1);
  FGroupingFieldList.UpdateSorting(FSortingFieldList);
  FExpandingInfo.CheckField(AField);
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.UpdateField(AField: TcxCustomDataField);
begin
  FChanges := FChanges + [dcicView];
  FSortingFieldList.CheckField(AField);
  if FGroupingFieldList.Find(AField) <> -1 then FSelection.ClearAll;
  FGroupingFieldList.CheckField(AField);
  FExpandingInfo.CheckField(AField);
  CheckChanges;
end;

// Sorting

procedure TcxCustomDataControllerInfo.ChangeSortIndex(AField: TcxCustomDataField; ASortIndex: Integer);
var
  ACurIndex: Integer;
begin
  ACurIndex := FSortingFieldList.Find(AField);
  if ASortIndex < 0 then ASortIndex := 0;
  if ASortIndex >= FSortingFieldList.Count then
    ASortIndex := FSortingFieldList.Count - 1;
  if ACurIndex <> ASortIndex then
  begin
    FSortingFieldList.Move(ACurIndex, ASortIndex);
    DataController.BeforeSorting;
    DataController.FSortingChanged := True;
    CheckChanges;
  end;  
end;

procedure TcxCustomDataControllerInfo.ChangeSorting(AField: TcxCustomDataField;
  ASortOrder: TcxDataSortOrder);
begin
  FSortingFieldList.ChangeSorting(AField, ASortOrder);
  FGroupingFieldList.UpdateSorting(FSortingFieldList);
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.ClearSorting(AKeepGroupedItems: Boolean);
var
  I, APrevCount: Integer;
begin
  APrevCount := FSortingFieldList.Count;
  if AKeepGroupedItems then
  begin
    for I := FSortingFieldList.Count - 1 downto 0 do
      if FGroupingFieldList.Find(FSortingFieldList[I].Field) = -1 then
        FSortingFieldList.Delete(I);
  end
  else
  begin
    FSortingFieldList.Clear;
    FGroupingFieldList.UpdateSorting(FSortingFieldList);
  end;
  if FSortingFieldList.Count <> APrevCount then
  begin
    DataController.BeforeSorting;
    DataController.FSortingChanged := True;
  end;
  CheckChanges;
end;

// Grouping

procedure TcxCustomDataControllerInfo.ChangeExpanding(ARowIndex: Integer;
  AExpanded, ARecursive: Boolean);
begin
  CheckRowIndex(ARowIndex);
  if IsGrouped and not IsAlwaysExpanded then
  begin
    // TODO: CheckBrowseMode; if needed
    if not AExpanded and (FocusedRowIndex <> -1) and
      DataController.Groups.HasAsParent(FocusedRowIndex, ARowIndex) then
      DataController.CheckBrowseMode;
    DataGroups.ChangeExpanding(ARowIndex, AExpanded, ARecursive);
    ExpandingChanged;
    BeginUpdate;
    try
      if not AExpanded then
        CheckAfterCollapsing;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.ChangeGrouping(AField: TcxCustomDataField;
  AGroupIndex: Integer);
begin
  FGroupingFieldList.ChangeGrouping(AField, AGroupIndex);
  FGroupingFieldList.UpdateSorting(FSortingFieldList);
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.ClearGrouping;
begin
  FGroupingFieldList.Clear;
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.FullCollapse;
begin
  if IsGrouped and not IsAlwaysExpanded then
  begin
    DataGroups.FullExpanding(False);
    ExpandingChanged;
    BeginUpdate;
    try
      CheckAfterCollapsing;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.FullExpand;
begin
  if IsGrouped and not IsAlwaysExpanded then
  begin
    DataGroups.FullExpanding(True);
    ExpandingChanged;
    CheckChanges;
  end;
end;

// View Data

function TcxCustomDataControllerInfo.GetNearestRowIndex(ARowIndex: Integer): Integer;
begin
  // TODO: ADeleteSelection
  CheckRowIndex(ARowIndex);
  if not IsGrouped then
  begin
    if (ARowIndex + 1) > (GetRowCount - 1) then // is last
      Result := ARowIndex - 1
    else
      Result := ARowIndex + 1;
  end
  else
  begin
    if ((ARowIndex + 1) <= (GetRowCount - 1)) and
      (GetRowInfo(ARowIndex + 1).Level = GetRowInfo(ARowIndex).Level) then
      Result := ARowIndex + 1
    else
    begin
      if ((ARowIndex - 1) >= 0) and
        (GetRowInfo(ARowIndex - 1).Level = GetRowInfo(ARowIndex).Level) then
        Result := ARowIndex - 1
      else
        if (ARowIndex + 1) <= (GetRowCount - 1) then
          Result := ARowIndex + 1
        else
          if (ARowIndex - 1) >= 0 then
            Result := ARowIndex - 1
          else
            Result := ARowIndex;
    end;
  end;
end;

function TcxCustomDataControllerInfo.GetRowCount: Integer;
begin
  if IsGrouped then
    Result := DataGroups.RowCount
  else
    Result := FRecordList.Count;
end;

function TcxCustomDataControllerInfo.GetRowIndexByRecordIndex(ARecordIndex: Integer;
  AMakeVisible: Boolean): Integer;
var
  ARecordListIndex, AGroupIndex: Integer;
begin
  Result := -1;
  ARecordListIndex := GetInternalRecordListIndex(ARecordIndex);
  if IsGrouped then
  begin
    AGroupIndex := DataGroups.FindByIndex(ARecordListIndex, DataGroups.LevelCount - 1);
    if AGroupIndex <> -1 then
      Result := LocateDetail(AGroupIndex, ARecordListIndex, AMakeVisible);
  end
  else
    Result := ARecordListIndex;
  if FExpandingFlag and AMakeVisible then
    CheckChanges;
end;

function TcxCustomDataControllerInfo.GetRowInfo(ARowIndex: Integer): TcxRowInfo;
var
  AGroupsRowInfo: TcxGroupsRowInfo;
begin
  CheckRowIndex(ARowIndex);
  if IsGrouped then
    AGroupsRowInfo := DataGroups.RowInfo[ARowIndex]
  else
  begin
    AGroupsRowInfo.Level := 0;
    AGroupsRowInfo.Expanded := False;
    AGroupsRowInfo.RecordListIndex := ARowIndex;
  end;
  Result.Expanded := AGroupsRowInfo.Expanded;
  Result.Level := AGroupsRowInfo.Level;
  Result.RecordIndex := GetInternalRecordIndex(AGroupsRowInfo.RecordListIndex);
end;

// Selection

procedure TcxCustomDataControllerInfo.ChangeRowSelection(ARowIndex: Integer; ASelection: Boolean);
var
  AIndex, AGroupIndex: Integer;
  ARowInfo: TcxRowInfo;
  AItem: TcxDataGroupInfo;
begin
  CheckRowIndex(ARowIndex);
  if Selection.FindByRowIndex(ARowIndex, AIndex) then
  begin
    if not ASelection then
      Selection.Delete(AIndex);
  end
  else
  begin
    if ASelection and DataController.CanSelectRow(ARowIndex) then
    begin
      AGroupIndex := DataGroups.Find(ARowIndex, AItem);
      if AGroupIndex <> -1 then // It's Group
        Selection.Add(AIndex, ARowIndex, AGroupIndex, -1)
      else
      begin
        ARowInfo := GetRowInfo(ARowIndex);
        Selection.Add(AIndex, ARowIndex, ARowInfo.RecordIndex, ARowInfo.Level);
      end;
    end;
  end;
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.ClearSelection;
begin
  Selection.Clear;
  CheckChanges;
end;

procedure TcxCustomDataControllerInfo.ClearSelectionAnchor;
begin
  Selection.ClearAnchor;
end;

function TcxCustomDataControllerInfo.GetSelectedCount: Integer;
begin
  Result := FSelection.Count;
end;

function TcxCustomDataControllerInfo.GetSelectedRowIndex(Index: Integer): Integer;
begin
  Result := Selection[Index].RowIndex;
end;
                                               
function TcxCustomDataControllerInfo.IsRowSelected(ARowIndex: Integer): Boolean;
begin
  CheckRowIndex(ARowIndex);
  Result := Selection.IsRowSelected(ARowIndex);
end;

function TcxCustomDataControllerInfo.CanFocusedRowChanging(ARowIndex: Integer): Boolean;
begin
  FInCanFocusedRowChanging := True;
  try
    if ARowIndex <> -1 then
      Result := DataController.CanFocusRecord(GetRowInfo(ARowIndex).RecordIndex)
    else
      Result := DataController.CanFocusRecord(-1);
  finally
    FInCanFocusedRowChanging := False;
  end;
end;

procedure TcxCustomDataControllerInfo.CorrectFocusedRow(ARowIndex: Integer);
begin
  FFocusingInfo.Clear;
  DoChangeFocusedRow(ARowIndex, False);
end;

procedure TcxCustomDataControllerInfo.DoChangeFocusedRow(AValue: Integer; AIsInternal: Boolean);

  procedure CheckFocusedRanges(AFocusingInfo: TcxDataFocusingInfo);
  begin
    if AFocusingInfo.FRowIndex > (GetRowCount - 1) then
      AFocusingInfo.FRowIndex := -1;
  end;

  procedure SaveFocusedPos;
  begin
    FFocusingInfo.SavePos;
    if (FFocusingInfo.RowIndex <> -1) and
      (GetRowInfo(FFocusingInfo.RowIndex).RecordIndex <> FFocusingInfo.RecordIndex) then
    begin
      { error locate - Tried to set focus on a row, but it turned out,
        that another row was focused (it is possible for DB, for example:
        the key field is incorrect) }
      FFocusingInfo.FRowIndex := FindFocusedRow(False);
      CheckFocusedRanges(FFocusingInfo);
    end;
  end;

var
  AAllowChangeFocusedRow: Boolean;
begin
  if AValue < -1 then AValue := -1;
  if AValue > (GetRowCount - 1) then AValue := GetRowCount - 1;
  if FFocusingInfo.RowIndex <> AValue then
  begin
    FFocusingFlag := True;
    AAllowChangeFocusedRow := False;
    try
      if not (dcicFocusedRow in FChanges) then
        FPrevFocusingInfo.Assign(FFocusingInfo);
      AAllowChangeFocusedRow := AIsInternal or CanFocusedRowChanging(AValue);
      if AAllowChangeFocusedRow then
      begin
        DataController.DoBeforeFocusedRowChange(AValue);
        FFocusingInfo.FRowIndex := AValue;
      end;  
    finally
      CheckFocusedRanges(FPrevFocusingInfo);
      CheckFocusedRanges(FFocusingInfo);
      if (FPrevFocusingInfo.FRowIndex <> -1) or AAllowChangeFocusedRow then
        SaveFocusedPos;
      if not FFocusingInfo.IsEqual(FPrevFocusingInfo) then
      begin
        FChanges := FChanges + [dcicFocusedRecord, dcicFocusedRow];
        if DataController.IsFocusedSelectedMode and
          (soSelectedRecords in DataController.Summary.Options) then
          FChanges := FChanges + [dcicSummary];
        DataController.ResetNewItemRowFocused;
        DataController.CheckDataSetCurrent;
        DataController.SyncSelected(True);
      end;
      FFocusingFlag := False;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.DoFilter;
var
  I, APrevRecordCount: Integer;
  AIsIncrementalFilter, AIsFiltering, AIsOnFilterRecord: Boolean;
begin
  AIsIncrementalFilter := DataController.IsIncrementalFilter;
  AIsFiltering := DataController.Filter.IsFiltering;
  AIsOnFilterRecord := not DataController.IsGridMode and DataController.IsFilterRecord;
  if not (AIsIncrementalFilter or AIsFiltering or AIsOnFilterRecord) then Exit;
  APrevRecordCount := FRecordList.Count;
  for I := FRecordList.Count - 1 downto 0 do
    if I <> DataController.Provider.FEditingRecordIndex then // TODO:
    begin
      if AIsOnFilterRecord and
        not DataController.DoFilterRecord(I) then
      begin
        FRecordList.Delete(I);
        Continue;
      end;
      if AIsIncrementalFilter and
        not DataController.DoIncrementalFilterRecord(I) then
      begin
        FRecordList.Delete(I);
        Continue;
      end;
      if AIsFiltering and
        not DataController.Filter.DoFilterRecord(I) then
      begin
        FRecordList.Delete(I);
        Continue;
      end;
    end;
  if FRecordList.Count <> APrevRecordCount then
  begin
    FSelection.CheckAfterFiltering;
    if DataController.FCheckFocusingAfterFilterNeeded then
    begin
      DataController.FCheckFocusingAfterFilterNeeded := False;
      DataController.FFilterChanged := True;
    end;
  end;
end;

type
  TcxDataGroupCompareInfo = record
    Info: TcxDataGroupInfo;
    RecordIndex: Integer;
  end;
  PcxDataGroupCompareInfo = ^TcxDataGroupCompareInfo;

procedure TcxCustomDataControllerInfo.DoGrouping;
var
  ACurLevels: TList;
  ARowIndex: Integer;
  ARecordIndex: Integer;
  I, J: Integer;

  procedure BeginBuilding;
  var
    I: Integer;
    ARecordIndex: Integer;
    PCompareInfo: PcxDataGroupCompareInfo;
  begin
    ACurLevels := TList.Create;
    ARecordIndex := GetInternalRecordIndex(0);
    for I := 0 to FDataGroups.LevelCount - 1 do
    begin
      New(PCompareInfo);
      PCompareInfo.RecordIndex := ARecordIndex;
      PCompareInfo.Info := DataGroups.AddEmpty;
      PCompareInfo.Info.RowIndex := ARowIndex;
      PCompareInfo.Info.Expanded := False;
      PCompareInfo.Info.Level := I;
      if I < (FDataGroups.LevelCount - 1) then
        PCompareInfo.Info.BeginRecordListIndex := I + 1
      else
        PCompareInfo.Info.BeginRecordListIndex := 0;
      ACurLevels.Add(PCompareInfo);
    end;
  end;

  procedure CloseGroups(ARecordListIndex, ALevelIndex: Integer);
  begin
    if ALevelIndex >= (FDataGroups.LevelCount - 1) then
    begin
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.EndRecordListIndex := ARecordListIndex - 1;

      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info := DataGroups.AddEmpty;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.RowIndex := ARowIndex;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.Expanded := False;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.Level := ALevelIndex;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.BeginRecordListIndex := ARecordListIndex;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).RecordIndex := ARecordIndex;
    end
    else
    begin
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.EndRecordListIndex := DataGroups.Count - 1;

      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info := DataGroups.AddEmpty;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.RowIndex := ARowIndex;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.Expanded := False;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.Level := ALevelIndex;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).Info.BeginRecordListIndex := DataGroups.Count;
      PcxDataGroupCompareInfo(ACurLevels[ALevelIndex]).RecordIndex := ARecordIndex;
      CloseGroups(ARecordListIndex, ALevelIndex + 1);
    end;
  end;

  procedure CloseBuilding;
  var
    I, AEndRecordListIndex: Integer;
  begin
    AEndRecordListIndex := FRecordList.Count - 1;
    for I := FDataGroups.LevelCount - 1 downto 0 do
    begin
      PcxDataGroupCompareInfo(ACurLevels[I]).Info.EndRecordListIndex := AEndRecordListIndex;
      if I = (FDataGroups.LevelCount - 1) then
        AEndRecordListIndex := DataGroups.Count - 1
      else
        AEndRecordListIndex := PcxDataGroupCompareInfo(ACurLevels[I]).Info.BeginRecordListIndex - 1;
    end;
  end;

  procedure EndBuilding;
  var
    I: Integer;
  begin
    for I := 0 to ACurLevels.Count - 1 do
      Dispose(PcxDataGroupCompareInfo(ACurLevels[I]));
    ACurLevels.Free;
  end;

begin
  FDataGroups.Clear;
  for I := 0 to GroupingFieldList.Count - 1 do
    FDataGroups.AddField(GroupingFieldList[I].Field);
  if (FRecordList.Count > 0) and (FDataGroups.LevelCount > 0) then
  begin
    ARowIndex := 0;
    BeginBuilding;
    try
      PrepareSorting;
      try
        for I := 1 to FRecordList.Count - 1 do
        begin
          ARecordIndex := GetInternalRecordIndex(I);
          for J := 0 to FDataGroups.LevelCount - 1 do
          begin
            if CompareGroupRecords(PcxDataGroupCompareInfo(ACurLevels[J]).RecordIndex, ARecordIndex, J) <> 0 then
            begin
              if J = 0 then Inc(ARowIndex);
              CloseGroups(I, J);
              Break;
            end;
          end;
        end;
      finally
        UnprepareSorting;
      end;
      CloseBuilding;
    finally
      EndBuilding;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.DoLoad;
var
  I: Integer;
begin
  ListSetCount(FRecordList, DataController.RecordCount);
  for I := 0 to FRecordList.Count - 1 do
    FRecordList[I] := Pointer(I);
end;

procedure TcxCustomDataControllerInfo.DoSort;
begin
  FTotalSortingFieldList.Clear;
  FTotalSortingFieldList.AppendFrom(GroupingFieldList);
  FTotalSortingFieldList.AppendFrom(SortingFieldList);
  if not DataController.IsGridMode and (FRecordList.Count > 0) then
  begin
    PrepareSorting;
    try
      if DataController.IsProviderMode and
        DataController.Provider.IsCustomSorting then
        DataController.Provider.CustomSort
      else
        QuickSortList(FRecordList.List, 0, FRecordList.Count - 1, CompareRecords);
    finally
      UnprepareSorting;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.DoBeginSummary;
begin
  // Footer Summary can be calculated before DoSort if soSelectedRecords=False
  if not IsSummaryForSelectedRecords then
    DataController.Summary.BeginCalculate;
end;

procedure TcxCustomDataControllerInfo.DoEndSummary;
begin
  if not IsSummaryForSelectedRecords then
    DataController.Summary.EndCalculate
  else
    DataController.Summary.Calculate;
end;

function TcxCustomDataControllerInfo.FindDataGroup(ARecordListIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DataGroups.Count - 1 do
    if (DataGroups[I].Level = (DataGroups.LevelCount - 1)) and
      (DataGroups[I].BeginRecordListIndex <= ARecordListIndex) and
      (ARecordListIndex <= DataGroups[I].EndRecordListIndex) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxCustomDataControllerInfo.FindFocusedRow(ANearest: Boolean): Integer;

  function FindFocused(ARecordListIndex, AGroupIndex: Integer): Integer;
  begin
    if FFocusingInfo.Level = -1 then
    begin
      if DataGroups[AGroupIndex].BeginRecordListIndex <> ARecordListIndex then // Seek Detail
        Result := LocateDetail(AGroupIndex, ARecordListIndex, True)
      else
        Result := LocateGroupByLevel(AGroupIndex, -1);
    end
    else
    begin
      if FFocusingInfo.Level = DataGroups.LevelCount then // Seek Detail
        Result := LocateDetail(AGroupIndex, ARecordListIndex, True)
      else
      begin
        if DataGroups[AGroupIndex].BeginRecordListIndex = ARecordListIndex then
          Result := LocateGroupByLevel(AGroupIndex, FFocusingInfo.Level)
        else
          Result := LocateDetail(AGroupIndex, ARecordListIndex, True)
      end;
    end;
  end;

  function FindParentGroup(AIndex, ALevel: Integer): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := AIndex downto 0 do
      if DataGroups[I].Level = ALevel then
      begin
        Result := I;
        Break;
      end;
  end;

  function FindNearest(ARecordListIndex, AGroupIndex: Integer): Integer;
  var
    I, ALevel: Integer;
    AItem: TcxDataGroupInfo;
  begin
    if AGroupIndex <> -1 then
    begin
      I := AGroupIndex;
      AItem := DataGroups.GetTopVisibleItem(DataGroups[AGroupIndex].RowIndex, I);
      ALevel := FFocusingInfo.Level;
      if ALevel = DataGroups.LevelCount then // Detail
      begin
        if (AGroupIndex = I) and DataGroups[AGroupIndex].Expanded then
        begin
          Result := AItem.RowIndex;
          Inc(Result, ARecordListIndex - AItem.BeginRecordListIndex + 1);
          Exit;
        end
        else
          Dec(ALevel);
      end;
      if (ALevel < 0) and (AGroupIndex = I) then
      begin
        Result := AItem.RowIndex;
        Exit;
      end;
      AGroupIndex := FindParentGroup(AGroupIndex, ALevel);
      if AGroupIndex <> -1 then
        Result := DataGroups[AGroupIndex].RowIndex
      else
        Result := -1;
    end
    else
      Result := -1;
  end;

var
  I: Integer;
  ARecordListIndex, AGroupIndex: Integer;
begin
  Result := -1;
  if FFocusingInfo.RecordIndex < 0 then Exit;
  ARecordListIndex := -1;
  for I := 0 to FRecordList.Count - 1 do
    if GetInternalRecordIndex(I) = FFocusingInfo.RecordIndex then
    begin
      ARecordListIndex := I;
      Break;
    end;
  if ARecordListIndex <> -1 then
    if IsGrouped then
    begin
      AGroupIndex := FindDataGroup(ARecordListIndex); // LastLevel Group
      if ANearest then
        Result := FindNearest(ARecordListIndex, AGroupIndex)
      else
        Result := FindFocused(ARecordListIndex, AGroupIndex);
    end
    else
      Result := ARecordListIndex;
end;

procedure TcxCustomDataControllerInfo.ForwardChanges;
var
  ADataControllerChanges: TcxDataControllerChanges;
begin
  ADataControllerChanges := [];
  if [dcicSorting, dcicView] * FChanges <> [] then
    ADataControllerChanges := [dccLayout];
  if [dcicLoad, dcicGrouping, dcicExpanding] * FChanges <> [] then
    ADataControllerChanges := ADataControllerChanges + [dccData];
  if [dcicFocusedRow, dcicResetFocusedRow, dcicFocusedRecord] * FChanges <> [] then
    ADataControllerChanges := ADataControllerChanges + [dccFocus];
  if dcicSelection in FChanges then
    ADataControllerChanges := ADataControllerChanges + [dccSelection];
  if dcicSummary in FChanges then
    ADataControllerChanges := ADataControllerChanges + [dccSummary];
  if DataController.FGroupingChanged then
    ADataControllerChanges := ADataControllerChanges + [dccGrouping];
  if DataController.FSortingChanged then
    ADataControllerChanges := ADataControllerChanges + [dccSorting];
  FChanges := [];
  DataController.FGroupingChanged := False;
  DataController.FSortingChanged := False;
  DataController.FFilterChanged := False;
  DataController.FSortingBySummaryChanged := False;
  DataController.Change(ADataControllerChanges);
  DataController.FLoadedStorage := False;
end;

function TcxCustomDataControllerInfo.GetInternalRecordCount: Integer;
begin
  Result := FRecordList.Count; 
end;

function TcxCustomDataControllerInfo.GetInternalRecordIndex(ARecordListIndex: Integer): Integer;
begin
  Result := Integer(FRecordList[ARecordListIndex]);
end;

function TcxCustomDataControllerInfo.GetInternalRecordListIndex(ARecordIndex: Integer): Integer;
begin
  Result := FRecordList.IndexOf(Pointer(ARecordIndex));
end;

function TcxCustomDataControllerInfo.IsAlwaysExpanded: Boolean;
begin
  Result := dcoGroupsAlwaysExpanded in DataController.Options;
end;

function TcxCustomDataControllerInfo.IsGrouped: Boolean;
begin
  Result := FDataGroups.Count > 0;
end;

function TcxCustomDataControllerInfo.IsSummaryForSelectedRecords: Boolean;
begin
  Result := (soSelectedRecords in DataController.Summary.Options) or
    ((soMultipleSelectedRecords in DataController.Summary.Options) and (GetSelectedCount > 1))
end;

function TcxCustomDataControllerInfo.LocateGroupByLevel(AGroupIndex, ALevel: Integer): Integer;

  function FindParentGroup(AIndex: Integer): Integer;
  var
    I, ALevel: Integer;
  begin
    Result := -1;
    ALevel := DataGroups[AIndex].Level - 1;
    for I := AIndex downto 0 do
      if DataGroups[I].Level = ALevel then
      begin
        Result := I;
        Break;
      end;
  end;

var
  AParentGroupIndex: Integer;
begin
  repeat
    if DataGroups[AGroupIndex].Level = ALevel then
      Break;
    AParentGroupIndex := FindParentGroup(AGroupIndex);
    if (AParentGroupIndex <> -1) and (DataGroups[AParentGroupIndex].BeginRecordListIndex = AGroupIndex) then
      AGroupIndex := AParentGroupIndex
    else
      Break;
  until False;
  if DataGroups.MakeVisible(AGroupIndex, False) then
    ExpandingChanged;
  Result := DataGroups[AGroupIndex].RowIndex;
end;

function TcxCustomDataControllerInfo.LocateDetail(AGroupIndex, ARecordListIndex: Integer;
  AMakeVisible: Boolean): Integer;
begin
  if not AMakeVisible and
    not (DataGroups.IsVisible(AGroupIndex) and DataGroups[AGroupIndex].Expanded) then
      Result := -1
  else
  begin
    if AMakeVisible and DataGroups.MakeVisible(AGroupIndex, True) then
      ExpandingChanged;
    Result := DataGroups[AGroupIndex].RowIndex +
      ARecordListIndex - DataGroups[AGroupIndex].BeginRecordListIndex + 1;
  end;
end;

procedure TcxCustomDataControllerInfo.PrepareSorting;
var
  I: Integer;
begin
  for I := 0 to FTotalSortingFieldList.Count - 1 do
    if DataController.IsConversionNeededForCompare(FTotalSortingFieldList[I].Field) then
    begin
      if DataController.IsSortByDisplayTextNeeded(FTotalSortingFieldList[I].Field) then
        FTotalSortingFieldList[I].Field.FNeedConversionFlag := 2
      else
        FTotalSortingFieldList[I].Field.FNeedConversionFlag := 1;
    end
    else
      FTotalSortingFieldList[I].Field.FNeedConversionFlag := -1;
end;

procedure TcxCustomDataControllerInfo.RecalcSelection;
var
  I: Integer;
begin
  for I := 0 to Selection.Count - 1 do
  begin
    if Selection[I].Level = -1 then // It's Group
      Selection[I].RowIndex := DataGroups[Selection[I].RecordIndex].RowIndex
    else
      Selection[I].RowIndex := GetRowIndexByRecordIndex(Selection[I].RecordIndex, False);
  end;
end;

procedure TcxCustomDataControllerInfo.ResetFocusing;
begin
  if DataController.FInNotifyControl then Exit;
  if (dcoFocusTopRowAfterSorting in DataController.Options) and
    (DataController.FGroupingChanged or DataController.FSortingChanged or
     DataController.FLoadedStorage) then
  begin
    DataController.FLoadedStorage := False;
    FFocusingInfo.Clear;
    DoChangeFocusedRow(0, False);
    if Selection.Count > 0 then
      Selection.ClearAll;
  end;
end;

procedure TcxCustomDataControllerInfo.SaveExpanding(ASaveStates: TcxDataExpandingInfoStateSet);

  function IsValidInfo: Boolean;
  var
    I: Integer;
  begin
    Result := (DataGroups.FieldCount = GroupingFieldList.Count) and
      (DataController.RecordCount > 0);
    if Result then
      for I := 0 to GroupingFieldList.Count - 1 do
        if DataGroups.Fields[I] <> GroupingFieldList[I].Field then
        begin
          Result := False;
          Break;
        end;
  end;

  procedure AddGroup(ADataGroupInfo: TcxDataGroupInfo; AGroupIndex: Integer; AExpanded: Boolean);
  var
    ARecordIndex: Integer;
    AInfo: TcxDataGroupInfo;
    AStateSet: TcxDataExpandingInfoStateSet;
  begin
    // begin proc
    AInfo := ADataGroupInfo;
    while AInfo.Level < (DataGroups.LevelCount - 1) do
      AInfo := DataGroups[AInfo.BeginRecordListIndex];
    ARecordIndex := GetInternalRecordIndex(AInfo.BeginRecordListIndex);
//    if DataController.Provider.IsInserting then // !!!
//    begin
//      if ARecordIndex >= DataController.Provider.FEditingRecordIndex then
//        Inc(ARecordIndex);
//    end;
//    if ARecordIndex >= DataController.FDeletingRecordIndex then
//      Dec(ARecordIndex); // !!!
    // end proc
    if ARecordIndex < DataController.RecordCount then
    begin
      AStateSet := [];
      if AExpanded and ((Selection.Count > 0) or not IsAlwaysExpanded) then
        AStateSet := AStateSet + [eisExpanded];
      if (eisSelected in FExpandingInfo.SaveStates) and
        (Selection.FindByGroupIndex(AGroupIndex) <> -1) then
          AStateSet := AStateSet + [eisSelected];
      if AStateSet <> [] then
        FExpandingInfo.AddItem(ADataGroupInfo.Level,
          DataController.GetComparedValue(ARecordIndex, GroupingFieldList[ADataGroupInfo.Level].Field),
          AStateSet);
    end;
  end;

  procedure AddGroups;
  var
    I, AVisibleLevel: Integer;
    ADataGroupInfo: TcxDataGroupInfo;
  begin
    I := 0;
    AVisibleLevel := 0;
    while I < DataGroups.Count do
    begin
      ADataGroupInfo := DataGroups[I];
      if ADataGroupInfo.Level <= AVisibleLevel then
      begin
        if ADataGroupInfo.Expanded then
        begin
          AddGroup(ADataGroupInfo, I, True);
          AVisibleLevel := ADataGroupInfo.Level + 1;
        end
        else
        begin
          if eisSelected in FExpandingInfo.SaveStates then
            AddGroup(ADataGroupInfo, I, False);
          AVisibleLevel := ADataGroupInfo.Level;
        end;
      end;
      Inc(I);
    end;
  end;

var
  I: Integer;
begin
  if FExpandingInfo.SaveStates <> ASaveStates then
  begin
    if (ASaveStates <> []) and IsValidInfo then
    begin
      FExpandingInfo.SaveStates := ASaveStates;
      FExpandingInfo.ClearFields;
      for I := 0 to DataGroups.FieldCount - 1 do
        FExpandingInfo.AddField(DataGroups.Fields[I]);
      if IsGrouped then
        AddGroups;
    end
    else
    begin
      FExpandingInfo.Clear;
      FExpandingInfo.SaveStates := ASaveStates;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.TruncateSelection;
var
  I, ARecordCount: Integer;
begin
  if FSelection.Count = 0 then Exit;
  ARecordCount := DataController.RecordCount;
  if ARecordCount = 0 then
    FSelection.ClearAll
  else
    if (not DataController.FInDeleteSelection or DataController.FInLoadStorage) and
      (not DataController.IsKeyNavigation or DataController.IsSmartRefresh or DataController.IsProviderMode) then
    begin
      for I := FSelection.Count - 1 downto 0 do
        if FSelection[I].RecordIndex >= ARecordCount then
          FSelection.Delete(I);
    end;
end;

procedure TcxCustomDataControllerInfo.UnprepareSorting;
var
  I: Integer;
begin
  for I := 0 to FTotalSortingFieldList.Count - 1 do
    FTotalSortingFieldList[I].Field.FNeedConversionFlag := 0;
end;

procedure TcxCustomDataControllerInfo.Update;
var
  ASummaryChanged: Boolean;
begin
  FInfoCalculation := True;
  DataController.CheckMode;
  if DataController.FSortingBySummaryChanged then
  begin
    FChanges := FChanges + [dcicSorting{, dcicGrouping, dcicSummary}];
    if not IsSortingBySummary then
      FChanges := FChanges + [dcicGrouping, dcicSummary];
  end;
  ASummaryChanged := ((dcicSummary in FChanges) {or SortBySummaryChanged}) and
    ([csDestroying, csReading] * DataController.FOwner.ComponentState = []);
  FExpandingFlag := False;
  SaveInfo;
  try
    if dcicLoad in FChanges then
    begin
      DoLoad;
      DoFilter;
    end;
    if ASummaryChanged then
      DoBeginSummary;
    if ([dcicSorting, dcicGrouping] * FChanges <> []) then
      DoSort;
    if dcicGrouping in FChanges then
    begin
      DataController.BeforeGroupingNotification;
      DoGrouping;
    end;
    if ([dcicSorting, dcicGrouping] * FChanges <> []) then
      ResetFocusing;

    CheckInfo;  // AB7162
    if ASummaryChanged then
      DoEndSummary;
    if (([dcicSorting, dcicGrouping] * FChanges <> []) or ASummaryChanged) and
      IsSortingBySummary then
    begin
      DoSortBySummary;
      CheckInfo;  // AB7162
    end;

    //CheckInfo;  AB7162
  finally
    ClearInfo;
    if FExpandingFlag then
      RecalcSelection;
    if [dcicSorting, dcicExpanding] * FChanges <> [] then
      DataController.CorrectPrevSelectionChangedInfo;
    FInfoCalculation := False;
    ForwardChanges;
  end;
end;

procedure TcxCustomDataControllerInfo.DoSortBySummary;
var
  AEngine: TcxSortingBySummaryEngine;
begin
  if DataController.GetSortingBySummaryEngineClass = nil then Exit;
  AEngine := DataController.GetSortingBySummaryEngineClass.Create(Self);
  try
    AEngine.Sort;
  finally
    AEngine.Free;
  end;
end;

function TcxCustomDataControllerInfo.IsSortingBySummary: Boolean;
var
  I: Integer;
begin
  Result := False;
  if DataController.Summary.Options * [soSelectedRecords, soMultipleSelectedRecords] <> [] then
    Exit;
  for I := 0 to GroupingFieldList.Count - 1 do
    if DataController.Summary.GroupSummaryItems[I].SortedSummaryItem <> nil then
    begin
      Result := True;
      Break;
    end;
end;

procedure TcxCustomDataControllerInfo.CheckAfterCollapsing;
var
  ANewFocusedRowIndex: Integer;
begin
  ANewFocusedRowIndex := FindFocusedRow(True);
  if FFocusingInfo.RowIndex <> ANewFocusedRowIndex then
  begin
    if DataController.IsSmartRefresh then
      CorrectFocusedRow(ANewFocusedRowIndex)
    else
      DoChangeFocusedRow(ANewFocusedRowIndex, False);
  end;
//  RecalcSelection; // TODO: check selection
end;

procedure TcxCustomDataControllerInfo.CheckExpanding;
var
  ASelectionCount, ACurIndex: Integer;

  function IsEqualFields: Boolean;
  var
    I: Integer;
  begin
    Result := FExpandingInfo.FieldCount = DataGroups.FieldCount;
    if Result then
      for I := 0 to DataGroups.FieldCount - 1 do
        if FExpandingInfo.Fields[I] <> DataGroups.Fields[I] then
        begin
          Result := False;
          Break;
        end;
  end;

  procedure PrepareSelection;
  var
    I, ALevel, ALevelCount: Integer;
  begin
    // Clear Groups
    ALevelCount := DataGroups.LevelCount;
    for I := Selection.Count - 1 downto 0 do
    begin
      ALevel := Selection[I].Level;
      if (ALevel = -1) or (ALevel <> ALevelCount) then
        Selection.Delete(I);
    end;
  end;

  function GroupNeedsRestoration(AExpandingInfo: PcxDataExpandingInfo): Boolean;
  begin
    Result :=
      (eisExpanded in AExpandingInfo.State) and (eisExpanded in FExpandingInfo.SaveStates) or
      (eisSelected in AExpandingInfo.State);
  end;

  procedure ExpandGroup(ARecordIndex, ALevel: Integer; AStateSet: TcxDataExpandingInfoStateSet);
  var
    I, ARecordListIndex: Integer;
  begin
    // begin proc
    ARecordListIndex := GetInternalRecordListIndex(ARecordIndex);
    I := DataGroups.FindByIndex(ARecordListIndex, ALevel);
    // end proc
    if I <> -1 then
    begin
      if (eisExpanded in AStateSet) and (eisExpanded in FExpandingInfo.SaveStates) then
        DataGroups[I].Expanded := True;
      if eisSelected in AStateSet then
        Selection.Add(-1, -1, I, -1);
    end;
  end;

  procedure ExpandGroups;
  var
    ALocateObject: TcxDataControllerGroupLocateObject;
    AValueDefReader: TcxValueDefUnboundReader;
    I, ARecordIndex: Integer;
    PExpandingInfo: PcxDataExpandingInfo;
  begin
    ALocateObject := TcxDataControllerGroupLocateObject.Create(DataController);
    try
      AValueDefReader := TcxValueDefUnboundReader.Create;
      try
        ALocateObject.Level := 0;
        for I := 0 to FExpandingInfo.Count - 1 do
        begin
          PExpandingInfo := FExpandingInfo[I];
          if PExpandingInfo.Level < ALocateObject.Level then
            AValueDefReader.Truncate(PExpandingInfo.Level);
          AValueDefReader.SetValue(FExpandingInfo.Fields[PExpandingInfo.Level].ValueDef,
            PExpandingInfo.Value);
          if GroupNeedsRestoration(PExpandingInfo) then
          begin
            ALocateObject.Level := PExpandingInfo.Level;
            ALocateObject.ReadData(AValueDefReader);
            ARecordIndex := ALocateObject.FindRecordIndex;
            if ARecordIndex <> -1 then
              ExpandGroup(ARecordIndex, ALocateObject.Level, PExpandingInfo.State);
          end;
        end;
      finally
        AValueDefReader.Free;
      end;
    finally
      ALocateObject.Free;
    end;
  end;

  procedure RebuildSelection;

    procedure CheckGroup(ADataGroupInfo: TcxDataGroupInfo);
    begin
      if (ADataGroupInfo.Level = (DataGroups.LevelCount - 1)) then
      begin
        // Delete Hidden
        while (ACurIndex < ASelectionCount) and
          (Selection[ACurIndex].RowIndex < ADataGroupInfo.BeginRecordListIndex) do
        begin
          Selection.Delete(ACurIndex);
          Dec(ASelectionCount);
        end;
        // Skip Visible
        if ADataGroupInfo.Expanded then
          while (ACurIndex < ASelectionCount) and
            (ADataGroupInfo.BeginRecordListIndex <= Selection[ACurIndex].RowIndex) and
            (Selection[ACurIndex].RowIndex <= ADataGroupInfo.EndRecordListIndex) do
          begin
            Selection[ACurIndex].RowIndex := ADataGroupInfo.RowIndex +
              (Selection[ACurIndex].RowIndex - ADataGroupInfo.BeginRecordListIndex + 1);
            Inc(ACurIndex);
          end;
      end;
    end;

  var
    I, AVisibleLevel, AStartIndex: Integer;
    ADataGroupInfo: TcxDataGroupInfo;
  begin
    if Selection.Count = 0 then Exit;
    {
    1 - first is groups (with RowIndex = -1), second - Data Rows (with RowIndex = RecordListIndex)
    2 - locate begin of Data Rows
    3 - process Data Rows
      if visible then correct RowIndex
      else delete
    4 - fill RowIndex for Groups (Level = -1)
      sort by RowIndex
    }
    // 1 - Sort Selection By <RecordListIndex>: write RecordListIndex -> RowIndex (temporal)
    for I := 0 to Selection.Count - 1 do
      if Selection[I].Level <> -1 then
        Selection[I].RowIndex := GetInternalRecordListIndex(Selection[I].RecordIndex)
      else
        Selection[I].RowIndex := -1;
    Selection.Sort;
    // 2 -
    ASelectionCount := Selection.Count;
    AStartIndex := ASelectionCount;
    for I := 0 to ASelectionCount - 1 do
      if Selection[I].RowIndex > -1 then
      begin
        AStartIndex := I;
        Break;
      end;
    // 3 -
    I := 0;
    ACurIndex := AStartIndex;
    AVisibleLevel := 0;
    while (I < DataGroups.Count) and (ACurIndex < ASelectionCount) do
    begin
      ADataGroupInfo := DataGroups[I];
      if ADataGroupInfo.Level <= AVisibleLevel then
      begin
        CheckGroup(ADataGroupInfo);
        if ADataGroupInfo.Expanded then
          AVisibleLevel := ADataGroupInfo.Level + 1
        else
          AVisibleLevel := ADataGroupInfo.Level;
      end;
      Inc(I);
    end;
    // Clear Hidden
    for I := ACurIndex to ASelectionCount - 1 do
    begin
      Selection.Delete(ACurIndex);
      Dec(ASelectionCount);
    end;
    // 4 -
    for I := 0 to AStartIndex - 1 do // for Group's
      Selection[I].RowIndex := DataGroups[Selection[I].RecordIndex].RowIndex;
    Selection.Sort;
  end;

  procedure RestoreRowsSelection;
  var
    I: Integer;
  begin
    if DataController.IsGridMode then Exit;
    for I := 0 to Selection.Count - 1 do
      Selection[I].RowIndex := GetInternalRecordListIndex(Selection[I].RecordIndex);
    Selection.Sort;
  end;

var
  ATempIndex: Integer;
begin
  if IsGrouped and IsAlwaysExpanded then
    DataGroups.FullExpanding(True);
  if FExpandingInfo.SaveStates <> [] then
  begin
    if IsEqualFields then
    begin
      PrepareSelection;
      if IsGrouped then
      begin
        try
//          if not IsAlwaysExpanded then
            ExpandGroups;
        finally
          if not IsAlwaysExpanded and (eisExpanded in FExpandingInfo.SaveStates) then
            DataGroups.Rebuild;
          RebuildSelection;
        end;
      end
      else
        if eisSelected in FExpandingInfo.SaveStates then
          RestoreRowsSelection;
      // check Selection Anchor
      if (Selection.AnchorRowIndex <> -1) and
        not Selection.FindByRowIndex(Selection.AnchorRowIndex, ATempIndex) then
        Selection.ClearAnchor;
    end
    else
    begin
      if eisSelected in FExpandingInfo.SaveStates then
        Selection.ClearAll;
    end;
  end;
end;

procedure TcxCustomDataControllerInfo.CheckFocusing;
var
  ANewFocusedRowIndex: Integer;
begin
  ANewFocusedRowIndex := FindFocusedRow(False);
  if FFocusingInfo.RowIndex <> ANewFocusedRowIndex then
  begin
    // check old row index
    if (0 <= FFocusingInfo.RowIndex) and (FFocusingInfo.RowIndex < GetRowCount) and
      (FFocusingInfo.RecordIndex = GetRowInfo(FFocusingInfo.RowIndex).RecordIndex) then
      // do nothing
    else
      DoChangeFocusedRow(ANewFocusedRowIndex, True);
  end;
  if (dcicFocusedRow in FChanges) and (FPrevFocusingInfo.RowIndex >= GetRowCount) then
    FPrevFocusingInfo.RowIndex := -1;

  if DataController.FFilterChanged then
    CheckFocusingAfterFilter;
end;

procedure TcxCustomDataControllerInfo.CheckFocusingAfterFilter;
begin
  if (FocusedRowIndex = -1) and not DataController.NewItemRowFocused then
  begin
    DataController.FFilterChanged := False;
    if {DataController.IsSmartRefresh and} (DataController.Provider.LocateCount = 0) then
      CorrectFocusedRow(0);
  end;
end;

procedure TcxCustomDataControllerInfo.CheckInfo;
begin
  CheckExpanding;
  CheckFocusing;
  DataController.CheckBookmarkValid(-1);
end;

procedure TcxCustomDataControllerInfo.ClearInfo;
begin
  FExpandingInfo.Clear;
end;

function TcxCustomDataControllerInfo.CompareGroupRecords(ARecordIndex1, ARecordIndex2, AIndex: Integer): Integer;
var
  AI, A1, A2: Integer;
begin
  Result := 0;
  if ARecordIndex1 = ARecordIndex2 then
    Exit;

  if DataController.Provider.FSavedRecordIndex <> 0 then
  begin
    if ARecordIndex1 = DataController.Provider.FEditingRecordIndex then
      ARecordIndex1 := DataController.Provider.FSavedRecordIndex
    else
      if ARecordIndex2 = DataController.Provider.FEditingRecordIndex then
        ARecordIndex2 := DataController.Provider.FSavedRecordIndex;
  end
  else
  begin
    // check Inserting - see CompareRecords
    A1 := DataController.Provider.FEditingRecordIndex1;
    A2 := DataController.Provider.FEditingRecordIndex2;
    if (A1 <> cxNullEditingRecordIndex) or (A2 <> cxNullEditingRecordIndex) then
    begin
      AI := DataController.Provider.FEditingRecordIndex;
      if ARecordIndex1 = AI then
      begin
        if A1 <> cxNullEditingRecordIndex then // appending
        begin
          Result := 0; // !!!
          Exit;
        end
        else // inserting
          if ARecordIndex2 = A2 then
          begin
            Result := 0; // !!!
            Exit;
          end
          else
            ARecordIndex1 := A2;
      end
      else
        if ARecordIndex2 = AI then
        begin
          if A1 <> cxNullEditingRecordIndex then // appending
          begin
            Result := 0; // !!!
            Exit;
          end
          else // inserting
            if ARecordIndex1 = A2 then
            begin
              Result := 0; // !!!
              Exit;
            end
            else
              ARecordIndex2 := A2;
        end;
    end;
  end;
  // compare
  Result := DataController.CompareRecords(ARecordIndex1, ARecordIndex2,
    FTotalSortingFieldList[AIndex], dccmGrouping);
end;

function TcxCustomDataControllerInfo.CompareRecords(ARecord1, ARecord2: Pointer): Integer;
var
  I, AI, A1, A2: Integer;
begin
  Result := 0;
  if ARecord1 = ARecord2 then
    Exit;

  // check Inserting
  A1 := DataController.Provider.FEditingRecordIndex1;
  A2 := DataController.Provider.FEditingRecordIndex2;
  if (A1 <> cxNullEditingRecordIndex) or (A2 <> cxNullEditingRecordIndex) then
  begin
    AI := DataController.Provider.FEditingRecordIndex;
    if Integer(ARecord1) = AI then
    begin
      if A1 <> cxNullEditingRecordIndex then // appending
      begin
        Result := 1;
        Exit;
      end
      else // inserting
        if Integer(ARecord2) = A2 then
        begin
          Result := -1;
          Exit;
        end
        else
          Integer(ARecord1) := A2;
    end
    else
      if Integer(ARecord2) = AI then
      begin
        if A1 <> cxNullEditingRecordIndex then // appending
        begin
          Result := -1;
          Exit;
        end
        else // inserting
          if Integer(ARecord1) = A2 then
          begin
            Result := 1;
            Exit;
          end
          else
            Integer(ARecord2) := A2;
      end;
  end;

  // compare
  for I := 0 to FTotalSortingFieldList.Count - 1 do
  begin
    Result := DataController.CompareRecords(Integer(ARecord1), Integer(ARecord2),
      FTotalSortingFieldList[I], dccmSorting);
    if Result <> 0 then Exit;
  end;
  if Result = 0 then
    Result := DataController.CompareEqualRecords(Integer(ARecord1), Integer(ARecord2));
end;

function TcxCustomDataControllerInfo.GetFocusedRecordIndex: Integer;
begin
  if FFocusingInfo.RowIndex <> -1 then
    Result := GetRowInfo(FFocusingInfo.RowIndex).RecordIndex
  else
    Result := -1;
end;

function TcxCustomDataControllerInfo.GetFocusedRowIndex: Integer;
begin
  Result := FFocusingInfo.RowIndex;
end;

function TcxCustomDataControllerInfo.GetNewItemRowFocusingChanged: Boolean;
begin
  Result := FPrevFocusingInfo.FChangedFlag;
end;

function TcxCustomDataControllerInfo.GetPrevFocusedRecordIndex: Integer;
begin
  Result := FPrevFocusingInfo.FPrevRecordIndex;
end;

function TcxCustomDataControllerInfo.GetPrevFocusedRowIndex: Integer;
begin
  Result := FPrevFocusingInfo.RowIndex;
end;

procedure TcxCustomDataControllerInfo.SaveInfo;
var
  ASaveStates: TcxDataExpandingInfoStateSet;
begin
  ASaveStates := [];
  if (dcoSaveExpanding in DataController.Options) or (Selection.Count > 0) then
  begin
    if (dcoSaveExpanding in DataController.Options) and
      ([dcicLoad, dcicGrouping] * FChanges <> []) then
      ASaveStates := ASaveStates + [eisExpanded];
    if (Selection.Count > 0) and
      ([dcicLoad, dcicGrouping, dcicSorting, dcicExpanding] * FChanges <> []) then
      ASaveStates := ASaveStates + [eisSelected];
  end;
  SaveExpanding(ASaveStates);
end;

procedure TcxCustomDataControllerInfo.SetFocusedRowIndex(Value: Integer);
begin
  DataController.BeginFullUpdate;
  //BeginUpdate;
  try
    DoChangeFocusedRow(Value, False);
  finally
//    EndUpdate;
    DataController.EndFullUpdate;
  end;
end;

{ TcxDataFilterCriteriaItem }

function TcxDataFilterCriteriaItem.GetDataValue(AData: TObject): Variant;
begin
  if Assigned(Field) then
    Result := DataController.GetFilterDataValue(Integer(AData), Field)
  else
    Result := Null;
end;

function TcxDataFilterCriteriaItem.GetFieldCaption: string;
begin
  if Assigned(Field) and (Field.Item <> nil) then
    Result := DataController.GetFilterItemFieldCaption(Field.Item)
  else
    Result := '';
end;

function TcxDataFilterCriteriaItem.GetFieldName: string;
begin
  if Assigned(Field) and (Field.Item <> nil) then
    Result := DataController.GetFilterItemFieldName(Field.Item)
  else
    Result := '';
end;

function TcxDataFilterCriteriaItem.GetItemLink: TObject;
begin
  if Assigned(Field) then
    Result := Field.Item
  else
    Result := nil; // !!!
end;

procedure TcxDataFilterCriteriaItem.SetItemLink(Value: TObject);
begin
  if not (Value is TcxCustomDataField) then
    Value := DataController.Fields.FieldByItem(Value);
  inherited;
end;

function TcxDataFilterCriteriaItem.GetDataController: TcxCustomDataController;
begin
  Result := (Criteria as TcxDataFilterCriteria).DataController;
end;

function TcxDataFilterCriteriaItem.GetField: TcxCustomDataField;
begin
  Result := inherited GetItemLink as TcxCustomDataField;
end;

{ TcxDataFilterValueList }

procedure TcxDataFilterValueList.Load(AItemIndex: Integer; AInitSortByDisplayText: Boolean = True;
  AUseFilteredValues: Boolean = False);

  procedure LoadRecords(var AUseFilteredRecords: Boolean; out ANullExists: Boolean);
  var
    AField: TcxCustomDataField;
    I, ARecordIndex: Integer;
    V: Variant;
  begin
    ANullExists := False;
    AField := DataController.Fields[AItemIndex];
    if AUseFilteredRecords and (DataController.FilteredRecordCount <> 0) then
      I := DataController.FilteredRecordCount
    else
    begin
      AUseFilteredRecords := False;
      I := DataController.RecordCount;
    end;
    for I := 0 to I - 1 do
    begin
      // TODO: ignore editing record
      if AUseFilteredRecords then
        ARecordIndex := DataController.FilteredRecordIndex[I]
      else
        ARecordIndex := I;
      V := DataController.GetFilterDataValue(ARecordIndex, AField);
      if Criteria.ValueIsNull(V) then
        ANullExists := True
      else
        Add(fviValue, V, DataController.GetFilterDisplayText(ARecordIndex, AItemIndex), False);
    end;
  end;

  function NonBlanksFilterApplied: Boolean;
  var
    ACriteriaItem: TcxFilterCriteriaItem;
  begin
    ACriteriaItem := Criteria.FindItemByItemLink(DataController.GetItem(AItemIndex));
    Result := (ACriteriaItem <> nil) and (ACriteriaItem.Operator is TcxFilterNotNullOperator);
  end;

var
  ANullExists: Boolean;
begin
  Clear;
  if AInitSortByDisplayText then
  //  SortByDisplayText := DataController.GetItemValueSource(AItemIndex) <> evsText; // TODO: Text for Lookup Field!!!
    SortByDisplayText := DataController.IsFilterItemSortByDisplayText(AItemIndex);
  Add(fviAll, Null, cxSFilterString(@cxSFilterBoxAllCaption), False);
  Add(fviCustom, Null, cxSFilterString(@cxSFilterBoxCustomCaption), False);
  if DataController.IsGridMode then
    ANullExists := True // custom loading
  else
    LoadRecords(AUseFilteredValues, ANullExists);
  if ANullExists then
    Add(fviBlanks, Null, cxSFilterString(@cxSFilterBoxBlanksCaption), False);
  if ANullExists or AUseFilteredValues and NonBlanksFilterApplied then
    Add(fviNonBlanks, Null, cxSFilterString(@cxSFilterBoxNonBlanksCaption), False);
  if Assigned((Criteria as TcxDataFilterCriteria).FOnGetValueList) then
    (Criteria as TcxDataFilterCriteria).FOnGetValueList(Criteria, AItemIndex, Self);
end;

function TcxDataFilterValueList.GetDataController: TcxCustomDataController;
begin
  Result := (Criteria as TcxDataFilterCriteria).DataController;
end;

{ TcxDataFilterCriteria }

constructor TcxDataFilterCriteria.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
  Version := cxDataFilterVersion;
end;

destructor TcxDataFilterCriteria.Destroy;
begin
  FDestroying := True;
  if (FDataController <> nil) and (FDataController.FFilters <> nil) then
    FDataController.FFilters.Remove(Self);
  Active := False;
  inherited Destroy;
end;

procedure TcxDataFilterCriteria.Assign(Source: TPersistent; AIgnoreItemNames: Boolean = False);
begin
  if Source is TcxDataFilterCriteria then
  begin
    BeginUpdate;
    try
      inherited;
      Active := TcxDataFilterCriteria(Source).Active;
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

procedure TcxDataFilterCriteria.AssignEvents(Source: TPersistent);
begin
  inherited AssignEvents(Source);
  if Source is TcxDataFilterCriteria then
    OnGetValueList := TcxDataFilterCriteria(Source).OnGetValueList;
end;

function TcxDataFilterCriteria.CreateValueList: TcxDataFilterValueList;
begin
  Result := GetValueListClass.Create(Self) as TcxDataFilterValueList;
end;

function TcxDataFilterCriteria.FindItemByItemLink(AItemLink: TObject): TcxFilterCriteriaItem;
begin
  if not (AItemLink is TcxCustomDataField) then
    AItemLink := DataController.Fields.FieldByItem(AItemLink);
  Result := inherited FindItemByItemLink(AItemLink);
end;

function TcxDataFilterCriteria.IsFiltering: Boolean;
begin
  Result := Active and not IsEmpty and not DataController.IsGridMode;
end;

procedure TcxDataFilterCriteria.RemoveItemByField(AField: TcxCustomDataField);
begin
  RemoveItemByItemLink(AField);
end;

procedure TcxDataFilterCriteria.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Criteria', ReadData, WriteData, IsStore);
end;

function TcxDataFilterCriteria.DoFilterRecord(ARecordIndex: Integer): Boolean;
begin
  Result := DoFilterData(TObject(ARecordIndex));
end;

function TcxDataFilterCriteria.GetIDByItemLink(AItemLink: TObject): Integer;
begin
  Result := DataController.GetItemID(AItemLink);
end;

function TcxDataFilterCriteria.GetNameByItemLink(AItemLink: TObject): string;
begin
  Result := DataController.GetItemName(AItemLink);
end;

function TcxDataFilterCriteria.GetItemClass: TcxFilterCriteriaItemClass;
begin
  Result := TcxDataFilterCriteriaItem;
end;

function TcxDataFilterCriteria.GetItemLinkByID(AID: Integer): TObject;
begin
  Result := DataController.FindItemByInternalID(AID);
end;

function TcxDataFilterCriteria.GetItemLinkByName(const AName: string): TObject;
begin
  Result := DataController.FindItemByName(AName);
end;

function TcxDataFilterCriteria.GetValueListClass: TcxFilterValueListClass;
begin
  Result := TcxDataFilterValueList;
end;

function TcxDataFilterCriteria.IsDestroying: Boolean;
begin
  Result := Destroying or DataController.IsDestroying;
end;

function TcxDataFilterCriteria.IsInternal: Boolean;
begin
  Result := (DataController <> nil) and (DataController.FFilters.IndexOf(Self) <> -1);
end;

function TcxDataFilterCriteria.IsLoading: Boolean;
begin
  Result := DataController.IsLoading;
end;

procedure TcxDataFilterCriteria.Update;
begin
  if not (IsInternal or IsDestroying or IsLoading) then
  begin
    if not DataController.Provider.IsDataSource then
      DataController.Post;
    DataController.FilterChanged;
    if Assigned(OnChanged) then
      OnChanged(Self);
  end;
end;

procedure TcxDataFilterCriteria.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    Changed;
  end;
end;

{ TcxDataFilterList }

procedure TcxDataFilterList.Clear;
begin
  while Count > 0 do
    Items[Count - 1].Free;
  inherited Clear;
end;

procedure TcxDataFilterList.RemoveItemByField(AField: TcxCustomDataField);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RemoveItemByField(AField);
end;

function TcxDataFilterList.GetItem(Index: Integer): TcxDataFilterCriteria;
begin
  Result := TcxDataFilterCriteria(inherited Items[Index]);
end;

{ TcxDataControllerGroups }

constructor TcxDataControllerGroups.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
end;

procedure TcxDataControllerGroups.ChangeExpanding(ARowIndex: Integer;
  AExpanded, ARecursive: Boolean);
begin
  DataControllerInfo.ChangeExpanding(ARowIndex, AExpanded, ARecursive);
end;

procedure TcxDataControllerGroups.ChangeGrouping(AItemIndex, AGroupIndex: Integer);
begin
  DataController.CheckItemRange(AItemIndex);
  if GetItemGroupIndex(AItemIndex) <> AGroupIndex then
  begin
    DataController.BeforeSorting;
    DataController.FGroupingChanged := True;
    DataControllerInfo.ChangeGrouping(DataController.Fields[AItemIndex], AGroupIndex);
  end;
end;

procedure TcxDataControllerGroups.ClearGrouping;
begin
  if GetGroupingItemCount > 0 then
  begin
    DataController.BeforeSorting;
    DataController.FGroupingChanged := True;
  end;
  DataControllerInfo.ClearGrouping;
end;

procedure TcxDataControllerGroups.FullCollapse;
begin
  DataControllerInfo.FullCollapse;
end;

procedure TcxDataControllerGroups.FullExpand;
begin
  DataControllerInfo.FullExpand;
end;

function TcxDataControllerGroups.GetDataGroupIndexByGroupValue(AParentDataGroupIndex: TcxDataGroupIndex;
  const AGroupValue: Variant): TcxDataGroupIndex;
var
  I: Integer;
  AChildDataGroupIndex: TcxDataGroupIndex;
begin
  Result := -1;
{  if (DataControllerInfo.LockCount > 0) and (DataControllerInfo.FChanges <> []) then
    Exit; // !!!}

  DataControllerInfo.PrepareSorting;
  try
    for I := 0 to ChildCount[AParentDataGroupIndex] - 1 do
    begin
      AChildDataGroupIndex := ChildDataGroupIndex[AParentDataGroupIndex, I];
      if VarEquals(GroupValues[AChildDataGroupIndex] , AGroupValue) then
      begin
        Result := AChildDataGroupIndex;
        Break;
      end;
    end;
  finally
    DataControllerInfo.UnprepareSorting;
  end;
end;

function TcxDataControllerGroups.HasAsParent(ARowIndex, AParentRowIndex: Integer): Boolean;
var
  AIndex, AParentIndex: TcxDataGroupIndex;
begin
  if LevelCount = 0 then
  begin
    Result := False;
    Exit;
  end;
  AParentIndex := DataGroupIndexByRowIndex[AParentRowIndex];
  AIndex := DataGroupIndexByRowIndex[ARowIndex];
  Result := (AParentIndex = AIndex) or
    ((Level[AParentIndex] < Level[AIndex]) and
     (DataGroups[AParentIndex].BeginRecordListIndex <= AIndex) and
     (AIndex <= DataGroups[AParentIndex].EndRecordListIndex));
end;

procedure TcxDataControllerGroups.LoadRecordIndexes(AList: TList; ADataGroupIndex: TcxDataGroupIndex);
var
  I, AChildCount: Integer;
begin
  AChildCount := ChildCount[ADataGroupIndex];
  if Level[ADataGroupIndex] < LevelCount - 1 then // It's Sub Groups
  begin
    for I := 0 to AChildCount - 1 do
      LoadRecordIndexes(AList, ChildDataGroupIndex[ADataGroupIndex, I]);
  end
  else
    for I := 0 to AChildCount - 1 do
      AList.Add(Pointer(ChildRecordIndex[ADataGroupIndex, I]));
end;

procedure TcxDataControllerGroups.LoadRecordIndexesByRowIndex(AList: TList; ARowIndex: Integer);
begin
  LoadRecordIndexes(AList, DataGroupIndexByRowIndex[ARowIndex]);
end;

function TcxDataControllerGroups.GetGroupRecordIndex(ADataGroupIndex: TcxDataGroupIndex): Integer;
var
  ARecordDataGroupIndex: TcxDataGroupIndex;
begin
  ARecordDataGroupIndex := ADataGroupIndex;
  while Level[ARecordDataGroupIndex] < LevelCount - 1 do // It's Sub Groups
    ARecordDataGroupIndex := ChildDataGroupIndex[ARecordDataGroupIndex, 0];
  Result := ChildRecordIndex[ARecordDataGroupIndex, 0];
end;

function TcxDataControllerGroups.GetChildCount(DataGroupIndex: TcxDataGroupIndex): Integer;
begin
  Result := DataControllerInfo.DataGroups.GetChildCount(DataGroupIndex);
end;

function TcxDataControllerGroups.GetChildDataGroupIndex(ParentDataGroupIndex: TcxDataGroupIndex; ChildIndex: Integer): TcxDataGroupIndex;
begin
  Result := DataControllerInfo.DataGroups.GetChildIndex(ParentDataGroupIndex, ChildIndex);
end;

function TcxDataControllerGroups.GetChildRecordIndex(ParentDataGroupIndex: TcxDataGroupIndex;
  ChildIndex: Integer): Integer;
var
  I: Integer;  
begin
  I := DataControllerInfo.DataGroups.GetChildRecordListIndex(ParentDataGroupIndex, ChildIndex);
  if I <> -1 then
    Result := DataControllerInfo.GetInternalRecordIndex(I)
  else
    Result := -1;
end;

function TcxDataControllerGroups.GetDataControllerInfo: TcxCustomDataControllerInfo;
begin
  Result := DataController.DataControllerInfo;
end;

function TcxDataControllerGroups.GetDataGroupIndexByRowIndex(RowIndex: Integer): TcxDataGroupIndex;
begin
  Result := DataControllerInfo.DataGroups.GetIndexByRowIndex(RowIndex);
end;

function TcxDataControllerGroups.GetDataGroups: TcxDataGroups;
begin
  Result := DataControllerInfo.DataGroups;
end;

function TcxDataControllerGroups.GetFieldGroupIndex(AField: TcxCustomDataField): Integer;
begin
  Result := DataControllerInfo.GroupingFieldList.GroupIndexByField(AField);
end;

function TcxDataControllerGroups.GetGroupingItemCount: Integer;
begin
  Result := DataControllerInfo.GroupingFieldList.Count;
end;

function TcxDataControllerGroups.GetGroupingItemIndex(Index: Integer): Integer;
begin
  Result := DataControllerInfo.GroupingFieldList[Index].Field.Index;
end;

function TcxDataControllerGroups.GetGroupDisplayText(ADataGroupIndex: TcxDataGroupIndex): string;
var
  ARecordIndex, ALevel: Integer;
  AField: TcxCustomDataField;
begin
  ARecordIndex := GetGroupRecordIndex(ADataGroupIndex);
  ALevel := Level[ADataGroupIndex];
  AField := DataControllerInfo.GroupingFieldList[ALevel].Field;

  Result := DataController.GetDisplayText(ARecordIndex, AField.Index);
end;

function TcxDataControllerGroups.GetGroupValue(ADataGroupIndex: TcxDataGroupIndex): Variant;
var
  ARecordIndex, ALevel: Integer;
  AField: TcxCustomDataField;
begin
  ARecordIndex := GetGroupRecordIndex(ADataGroupIndex);
  ALevel := Level[ADataGroupIndex];
  AField := DataControllerInfo.GroupingFieldList[ALevel].Field;

  Result := DataController.GetComparedValue(ARecordIndex, AField);
end;

function TcxDataControllerGroups.GetItemGroupIndex(AItemIndex: Integer): Integer;
begin
  DataController.CheckItemRange(AItemIndex);
  Result := FieldGroupIndex[DataController.Fields[AItemIndex]];
end;

function TcxDataControllerGroups.GetLevel(ADataGroupIndex: TcxDataGroupIndex): Integer;
begin
  Result := DataControllerInfo.DataGroups.GetLevel(ADataGroupIndex);
end;

function TcxDataControllerGroups.GetParentDataGroupIndex(ChildDataGroupIndex: TcxDataGroupIndex): TcxDataGroupIndex;
begin
  Result := DataControllerInfo.DataGroups.GetParentIndex(ChildDataGroupIndex);
end;

{ TcxCustomDataSummaryItem }

procedure TcxCustomDataSummaryItem.Assign(Source: TPersistent);
begin
  if Source is TcxCustomDataSummaryItem then
  begin
    ItemLink := DataController.FindProperItemLink(TcxCustomDataSummaryItem(Source).ItemLink);
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomDataSummaryItem.BeginUpdate;
begin
  if Assigned(Collection) then Collection.BeginUpdate;
end;

procedure TcxCustomDataSummaryItem.EndUpdate;
begin
  if Assigned(Collection) then Collection.EndUpdate;
end;

procedure TcxCustomDataSummaryItem.ItemLinkChanging(AField: TcxCustomDataField);
begin
end;

function TcxCustomDataSummaryItem.GetItemLink: TObject;
begin
  if Assigned(Field) then
    Result := Field.Item
  else
    Result := nil;
end;

procedure TcxCustomDataSummaryItem.SetItemLink(Value: TObject);
var
  AField: TcxCustomDataField;
begin
  if ItemLink <> Value then
  begin
    AField := DataController.Fields.FieldByItem(Value);
    BeginUpdate;
    try
      ItemLinkChanging(AField);
      FField := AField;
      Changed(True);
    finally
      EndUpdate;
    end;
  end;
end;

{ TcxDataSummaryItem }

destructor TcxDataSummaryItem.Destroy;
begin
  Sorted := False;  
  inherited Destroy;
end;

procedure TcxDataSummaryItem.Assign(Source: TPersistent);
begin
  if Source is TcxDataSummaryItem then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      Format := TcxDataSummaryItem(Source).Format;
      Kind := TcxDataSummaryItem(Source).Kind;
      Position := TcxDataSummaryItem(Source).Position;
      Sorted := TcxDataSummaryItem(Source).Sorted;
      OnGetText := TcxDataSummaryItem(Source).OnGetText;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TcxDataSummaryItem.DataField: TcxCustomDataField;
begin
  Result := Field;
end;

function TcxDataSummaryItem.FormatValue(const AValue: Variant; AIsFooter: Boolean): string;
var
  S: string;
begin
  if not VarIsNull(AValue) then
  begin
    if Kind <> skNone then
    begin
      S := Format;
      if Format = '' then
        S := SummaryItems.DefaultFormat(GetValueType(VarType(AValue)), Kind, AIsFooter);
      if (VarType(AValue) = varDate) and (Kind <> skCount) then
      begin
        if TimeOf(AValue) = 0 then
          Result := DateToStr(AValue)
        else
          if DateOf(AValue) = 0 then
            Result := TimeToStr(AValue)
          else
            Result := DateTimeToStr(AValue);
        Result := S + Result;
      end
      else
        Result := FormatFloat(S, AValue);
    end
    else
      Result := VarToStr(AValue);
  end
  else
    Result := '';
  if Assigned(FOnGetText) then
    FOnGetText(Self, AValue, AIsFooter, Result);
end;

function TcxDataSummaryItem.GetDataController: TcxCustomDataController;
begin
  Result := SummaryItems.DataController;
end;

function TcxDataSummaryItem.GetValueType(AVarType: TVarType): TcxSummaryValueType;
begin
  if IsCurrency(AVarType) then
    Result := svtCurrency
  else
  begin
    case AVarType of
      varDate:
        Result := svtDate;
    else
      Result := svtFloat;
    end;
  end;
end;

function TcxDataSummaryItem.IsCurrency(AVarType: TVarType): Boolean;
begin
  Result := VarTypeIsCurrency(AVarType);
end;

function TcxDataSummaryItem.IsDataBinded: Boolean;
begin
  Result := (DataField <> nil) or ((Kind = skCount) and (Position = spGroup));
end;

function TcxDataSummaryItem.IsPositionStored: Boolean;
begin
  Result := SummaryItems.IsPositionStored(Self);
end;

function TcxDataSummaryItem.GetPosition: TcxSummaryPosition;
begin
  Result := SummaryItems.GetItemPosition(Self);
end;

function TcxDataSummaryItem.GetSummaryItems: TcxDataSummaryItems;
begin
  if Assigned(Collection) and (Collection is TcxDataSummaryItems) then
    Result := TcxDataSummaryItems(Collection)
  else
    Result := nil;
end;

procedure TcxDataSummaryItem.SetFormat(const Value: string);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    Changed(False);
  end;
end;

procedure TcxDataSummaryItem.SetKind(Value: TcxSummaryKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Changed(True);
  end;
end;

procedure TcxDataSummaryItem.SetPosition(Value: TcxSummaryPosition);
begin
  if Position <> Value then
  begin
    FPosition := Value;
    Changed(False);
  end;
end;

procedure TcxDataSummaryItem.SetSorted(Value: Boolean);
begin
  if DataController.SortingBySummaryDataItemIndex <> -1 then Exit;
  if FSorted <> Value then
  begin
    BeginUpdate;
    try
      SummaryItems.BeforeSortingChange(Self, Value);
      FSorted := Value;
      DataController.DoSortingBySummaryChanged;
      Changed(True);
    finally
      EndUpdate;
    end;
  end;
end;

{ TcxDataSummaryItems }

constructor TcxDataSummaryItems.Create(ASummary: TcxDataSummary; AItemClass: TcxDataSummaryItemClass);
begin
  inherited Create(AItemClass);
  FSummary := ASummary;
end;

function TcxDataSummaryItems.Add: TcxDataSummaryItem;
begin
  Result := TcxDataSummaryItem(inherited Add);
end;

function TcxDataSummaryItems.Add(AItemLink: TObject; APosition: TcxSummaryPosition;
  AKind: TcxSummaryKind; const AFormat: string = ''): TcxDataSummaryItem;
begin
  BeginUpdate;
  try
    Result := Add;
    Result.ItemLink := AItemLink;
    Result.Position := APosition;
    Result.Kind := AKind;
    Result.Format := AFormat;
  finally
    EndUpdate;
  end;
end;

procedure TcxDataSummaryItems.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  AssignEvents(Source);
end;

procedure TcxDataSummaryItems.AssignEvents(Source: TPersistent);
begin
  if Source is TcxDataSummaryItems then
    OnSummary := TcxDataSummaryItems(Source).OnSummary;
end;

function TcxDataSummaryItems.DefaultFormat(AValueType: TcxSummaryValueType;
  ASummaryKind: TcxSummaryKind; AIsFooter: Boolean): string;
const
  ACurrencyFormats: array [Boolean, skSum..skAverage] of string = (
    ('SUM=%s;SUM=-%s', 'MIN=%s;MIN=-%s', 'MAX=%s;MAX=-%s', 'COUNT=0', 'AVG=%s;AVG=-%s'),
    ('%s;-%s', 'MIN=%s;MIN=-%s', 'MAX=%s;MAX=-%s', '0', 'AVG=%s;AVG=-%s'));
  ADateFormats: array [Boolean, skSum..skAverage] of string = (
    ('SUM=', 'MIN=', 'MAX=', 'COUNT=0', 'AVG='),
    ('', 'MIN=', 'MAX=', '0', 'AVG='));
  AFloatFormats: array [Boolean, skSum..skAverage] of string = (
    ('SUM=0.00;SUM=-0.00', 'MIN=0.00;MIN=-0.00', 'MAX=0.00;MAX=-0.00', 'COUNT=0', 'AVG=0.00;AVG=-0.00'),
    ('0.00;-0.00', 'MIN=0.00;MIN=-0.00', 'MAX=0.00;MAX=-0.00', '0', 'AVG=0.00;AVG=-0.00'));
var
  S: string;
begin
  Result := '';
  if ASummaryKind = skNone then Exit;
  case AValueType of
    svtCurrency:
      begin
        S := DefaultCurrencyDisplayFormat;
        Result := Format(ACurrencyFormats[AIsFooter, ASummaryKind], [S, S]);
      end;
    svtDate:
      Result := ADateFormats[AIsFooter, ASummaryKind];
  else
    Result := AFloatFormats[AIsFooter, ASummaryKind];
  end;
end;

procedure TcxDataSummaryItems.DeleteItems(AItemLink: TObject; APosition: TcxSummaryPosition);
var
  I: Integer;
  AItem: TcxDataSummaryItem;
begin
  BeginUpdate;
  try
    for I := Count - 1 downto 0 do
    begin
      AItem := Items[I];
      if (AItem.ItemLink = AItemLink) and (AItem.Position = APosition) then
        AItem.Free;
    end;
  finally
    EndUpdate;
  end;
end;

function TcxDataSummaryItems.GetGroupText(const ASummaryValues: Variant): string;
begin
  Result := '';
end;

function TcxDataSummaryItems.IndexOf(AItem: TcxDataSummaryItem): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I] = AItem then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSummaryItems.IndexOfItemLink(AItemLink: TObject): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].ItemLink = AItemLink then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSummaryItems.ItemOfItemLink(AItemLink: TObject): TcxDataSummaryItem;
var
  AIndex: Integer;
begin
  AIndex := IndexOfItemLink(AItemLink);
  if AIndex <> -1 then
    Result := Items[AIndex]
  else
    Result := nil;
end;

function TcxDataSummaryItems.GetDataItem(AItemIndex: Integer; APosition: TcxSummaryPosition;
  ACheckKind: Boolean = False; AKind: TcxSummaryKind = skNone): TcxDataSummaryItem;
var
  I: Integer;
  AField: TcxCustomDataField;
begin
  DataController.CheckItemRange(AItemIndex);
  Result := nil;
  AField := DataController.Fields[AItemIndex];
  for I := 0 to Count - 1 do
    if (Items[I].Field = AField) and (Items[I].Position = APosition) and
      (not ACheckKind or (Items[I].Kind = AKind)) then
    begin
      Result := Items[I];
      Break;
    end;
end;

function TcxDataSummaryItems.GetDataItemFormat(AItemIndex: Integer;
  APosition: TcxSummaryPosition): string;
var
  AKind: TcxSummaryKind;
  ASorted: Boolean;
begin
  GetDataItemProperties(AItemIndex, APosition, [spFormat], Result, AKind, ASorted);
end;

function TcxDataSummaryItems.GetDataItemKind(AItemIndex: Integer;
  APosition: TcxSummaryPosition): TcxSummaryKind;
var
  AFormat: string;
  ASorted: Boolean;
begin
  GetDataItemProperties(AItemIndex, APosition, [spKind], AFormat, Result, ASorted);
end;

function TcxDataSummaryItems.GetDataItemSorted(AItemIndex: Integer;
  APosition: TcxSummaryPosition): Boolean;
var
  AFormat: string;
  AKind: TcxSummaryKind;
begin
  GetDataItemProperties(AItemIndex, APosition, [spSorted], AFormat, AKind, Result);
end;

procedure TcxDataSummaryItems.SetDataItemFormat(AItemIndex: Integer;
  APosition: TcxSummaryPosition; const Value: string);
begin
  SetDataItemProperties(AItemIndex, APosition, [spFormat], Value, skNone, False);
end;

procedure TcxDataSummaryItems.SetDataItemKind(AItemIndex: Integer;
  APosition: TcxSummaryPosition; Value: TcxSummaryKind);
begin
  SetDataItemProperties(AItemIndex, APosition, [spKind], '', Value, False);
end;

procedure TcxDataSummaryItems.SetDataItemSorted(AItemIndex: Integer;
  APosition: TcxSummaryPosition; Value: Boolean);
begin
  SetDataItemProperties(AItemIndex, APosition, [spSorted], '', skNone, Value);
end;

procedure TcxDataSummaryItems.BeforeSortingChange(AItem: TcxDataSummaryItem; AValue: Boolean);
begin
end;

procedure TcxDataSummaryItems.ChangedView;
begin
  if Count > 0 then
    Update(Items[0]);
//    Items[0].Changed(False);
end;

function TcxDataSummaryItems.GetItemPosition(AItem: TcxDataSummaryItem): TcxSummaryPosition;
begin
  Result := AItem.FPosition;
end;

function TcxDataSummaryItems.IsPositionStored(AItem: TcxDataSummaryItem): Boolean;
begin
  Result := AItem.Position <> TcxSummaryPosition(0);
end;

function TcxDataSummaryItems.GetOwner: TPersistent;
begin
  Result := FSummary;
end;

function TcxDataSummaryItems.IndexOfField(AField: TcxCustomDataField): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].Field = AField then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSummaryItems.ItemOfField(AField: TcxCustomDataField): TcxDataSummaryItem;
var
  AIndex: Integer;
begin
  AIndex := IndexOfField(AField);
  if AIndex <> -1 then
    Result := Items[AIndex]
  else
    Result := nil;
end;

procedure TcxDataSummaryItems.Update(Item: TCollectionItem);
begin
  FSummary.Changed(Item <> nil);
end;

function TcxDataSummaryItems.AddDataItem(AItemIndex: Integer;
  APosition: TcxSummaryPosition): TcxDataSummaryItem;
begin
  Result := Add(DataController.GetItem(AItemIndex), APosition, skNone);
end;

procedure TcxDataSummaryItems.CheckItemEmpty(AItem: TcxDataSummaryItem);
begin
  if IsPropertiesEmpty([spFormat, spKind, spSorted], AItem.Format, AItem.Kind, AItem.Sorted) then
    AItem.Free;
  // TODO: Modified
end;

procedure TcxDataSummaryItems.GetDataItemProperties(AItemIndex: Integer; 
  APosition: TcxSummaryPosition; AProperties: TcxSummaryProperties;
  var AFormat: string; var AKind: TcxSummaryKind; var ASorted: Boolean);
var
  AItem: TcxDataSummaryItem;
begin
  AItem := GetDataItem(AItemIndex, APosition);
  if AItem <> nil then
  begin
    if spFormat in AProperties then AFormat := AItem.Format;
    if spKind in AProperties then AKind := AItem.Kind;
    if spSorted in AProperties then ASorted := AItem.Sorted;
  end
  else
  begin
    AFormat := '';
    AKind := skNone;
    ASorted := False;
  end;
end;

function TcxDataSummaryItems.IsPropertiesEmpty(AProperties: TcxSummaryProperties;
  const AFormat: string; AKind: TcxSummaryKind; ASorted: Boolean): Boolean;
begin
  Result := True;
  if (spFormat in AProperties) and (AFormat <> '') then
    Result := False;
  if (spKind in AProperties) and (AKind <> skNone) then
    Result := False;
  if (spSorted in AProperties) and ASorted then
    Result := False;
end;

procedure TcxDataSummaryItems.SetDataItemProperties(AItemIndex: Integer;
  APosition: TcxSummaryPosition; AProperties: TcxSummaryProperties;
  const AFormat: string; AKind: TcxSummaryKind; ASorted: Boolean);
var
  AItem: TcxDataSummaryItem;
begin
  AItem := GetDataItem(AItemIndex, APosition);
  if AItem <> nil then
  begin
    SetItemProperties(AItem, APosition, AProperties, AFormat, AKind, ASorted);
    CheckItemEmpty(AItem);
  end
  else
    if not IsPropertiesEmpty(AProperties, AFormat, AKind, ASorted) then
    begin
      AItem := AddDataItem(AItemIndex, APosition);
      SetItemProperties(AItem, APosition, AProperties, AFormat, AKind, ASorted);
    end;
  // TODO: Modified
end;

procedure TcxDataSummaryItems.SetItemProperties(AItem: TcxDataSummaryItem;
  APosition: TcxSummaryPosition; AProperties: TcxSummaryProperties;
  const AFormat: string; AKind: TcxSummaryKind; ASorted: Boolean);
begin
  if spFormat in AProperties then AItem.Format := AFormat;
  if spKind in AProperties then AItem.Kind := AKind;
  if spSorted in AProperties then AItem.Sorted := ASorted;
end;

function TcxDataSummaryItems.GetDataController: TcxCustomDataController;
begin
  Result := Summary.DataController;
end;

function TcxDataSummaryItems.GetItem(Index: Integer): TcxDataSummaryItem;
begin
  Result := TcxDataSummaryItem(inherited GetItem(Index));
end;

procedure TcxDataSummaryItems.SetItem(Index: Integer; Value: TcxDataSummaryItem);
begin
  inherited SetItem(Index, Value);
end;

{ TcxDataFooterSummaryItems }

function TcxDataFooterSummaryItems.GetItemPosition(AItem: TcxDataSummaryItem): TcxSummaryPosition;
begin
  Result := spFooter;
end;

function TcxDataFooterSummaryItems.IsPositionStored(AItem: TcxDataSummaryItem): Boolean;
begin
  Result := False;
end;

{ TcxDataGroupSummaryItems }

constructor TcxDataGroupSummaryItems.Create(ASummary: TcxDataSummary;
  AItemClass: TcxDataSummaryItemClass);
begin
  inherited Create(ASummary, AItemClass);
  FBeginText := stBeginText;
  FEndText := stEndText;
  FSeparator := stSeparator;
end;

procedure TcxDataGroupSummaryItems.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TcxDataGroupSummaryItems then
    with TcxDataGroupSummaryItems(Source) do
    begin
      Self.BeginText := BeginText;
      Self.EndText := EndText;
      Self.Separator := Separator;
    end;
end;

function TcxDataGroupSummaryItems.GetGroupText(const ASummaryValues: Variant): string;
var
  I: Integer;
  S: string;
begin
  Result := '';
    for I := 0 to Count - 1 do
      if Items[I].Position = spGroup then
      begin
        S := Items[I].FormatValue(ASummaryValues[I], False);
        if Result = '' then
          Result := S
        else
          Result := Result + Separator + ' ' + S;
      end;
  if Result <> '' then
  begin
    if FBeginText <> '' then
      Result := FBeginText + Result;
    if FEndText <> '' then
      Result := Result + FEndText;
  end;
end;

function TcxDataGroupSummaryItems.SortedSummaryItem: TcxDataSummaryItem;
var
  I, ASortingBySummaryDataItemIndex: Integer;
begin
  Result := nil;
  ASortingBySummaryDataItemIndex := DataController.SortingBySummaryDataItemIndex;
  if ASortingBySummaryDataItemIndex <> -1 then
    Result := ItemOfItemLink(DataController.GetItem(ASortingBySummaryDataItemIndex))
  else
    for I := 0 to Count - 1 do
      if Items[I].Sorted then
      begin
        Result := Items[I];
        Break;
      end;
end;

procedure TcxDataGroupSummaryItems.BeforeSortingChange(AItem: TcxDataSummaryItem;
  AValue: Boolean);
begin
  inherited;
  if AValue and (SortedSummaryItem <> nil) then
    SortedSummaryItem.Sorted := False;
end;

function TcxDataGroupSummaryItems.GetOwner: TPersistent;
begin
  if FOwner <> nil then
    Result := FOwner
  else
    Result := inherited GetOwner;
end;

function TcxDataGroupSummaryItems.IsBeginTextStored: Boolean;
begin
  Result := FBeginText <> stBeginText;
end;

function TcxDataGroupSummaryItems.IsEndTextStored: Boolean;
begin
  Result := FEndText <> stEndText;
end;

function TcxDataGroupSummaryItems.IsSeparatorStored: Boolean;
begin
  Result := FSeparator <> stSeparator;
end;

procedure TcxDataGroupSummaryItems.SetBeginText(const Value: string);
begin
  if FBeginText <> Value then
  begin
    FBeginText := Value;
    ChangedView;
  end;
end;

procedure TcxDataGroupSummaryItems.SetEndText(const Value: string);
begin
  if FEndText <> Value then
  begin
    FEndText := Value;
    ChangedView;
  end;
end;

procedure TcxDataGroupSummaryItems.SetSeparator(const Value: string);
begin
  if FSeparator <> Value then
  begin
    FSeparator := Value;
    ChangedView;
  end;
end;

{ TcxDataSummaryGroupItemLink }

function TcxDataSummaryGroupItemLink.GetSummaryGroupItemLinks: TcxDataSummaryGroupItemLinks;
begin
  if Assigned(Collection) and (Collection is TcxDataSummaryGroupItemLinks) then
    Result := TcxDataSummaryGroupItemLinks(Collection)
  else
    Result := nil;
end;

function TcxDataSummaryGroupItemLink.GetDataController: TcxCustomDataController;
begin
  Result := SummaryGroupItemLinks.SummaryGroup.SummaryGroups.Summary.DataController;
end;

procedure TcxDataSummaryGroupItemLink.ItemLinkChanging(AField: TcxCustomDataField);
var
  I: Integer;
  ASummaryGroups: TcxDataSummaryGroups;
  ASummaryGroup: TcxDataSummaryGroup;
  AItem: TcxDataSummaryGroupItemLink;
begin
  BeginUpdate;
  try
    ASummaryGroups := SummaryGroupItemLinks.SummaryGroup.SummaryGroups;
    for I := 0 to ASummaryGroups.Count - 1 do
    begin
      ASummaryGroup := ASummaryGroups[I];
      AItem := ASummaryGroup.Links.ItemOfField(AField);
      if AItem <> nil then
        AItem.ItemLink := nil;
    end;
  finally
    EndUpdate;
  end;
end;

{ TcxDataSummaryGroupItemLinks }

constructor TcxDataSummaryGroupItemLinks.Create(ASummaryGroup: TcxDataSummaryGroup;
  AItemClass: TcxDataSummaryGroupItemLinkClass);
begin
  inherited Create(AItemClass);
  FSummaryGroup := ASummaryGroup;
end;

function TcxDataSummaryGroupItemLinks.Add: TcxDataSummaryGroupItemLink;
begin
  Result := TcxDataSummaryGroupItemLink(inherited Add);
end;

function TcxDataSummaryGroupItemLinks.IndexOfItemLink(AItemLink: TObject): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].ItemLink = AItemLink then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSummaryGroupItemLinks.ItemOfItemLink(AItemLink: TObject): TcxDataSummaryGroupItemLink;
var
  AIndex: Integer;
begin
  AIndex := IndexOfItemLink(AItemLink);
  if AIndex <> -1 then
    Result := Items[AIndex]
  else
    Result := nil;
end;

function TcxDataSummaryGroupItemLinks.GetOwner: TPersistent;
begin
  Result := FSummaryGroup;
end;

function TcxDataSummaryGroupItemLinks.IndexOfField(AField: TcxCustomDataField): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].Field = AField then
    begin
      Result := I;
      Break;
    end;
end;

function TcxDataSummaryGroupItemLinks.ItemOfField(AField: TcxCustomDataField): TcxDataSummaryGroupItemLink;
var
  AIndex: Integer;
begin
  AIndex := IndexOfField(AField);
  if AIndex <> -1 then
    Result := Items[AIndex]
  else
    Result := nil;
end;

procedure TcxDataSummaryGroupItemLinks.Update(Item: TCollectionItem);
begin
//  FSummaryGroup.Changed(Item <> nil);
  FSummaryGroup.SummaryGroups.Update(nil);
end;

function TcxDataSummaryGroupItemLinks.GetItem(Index: Integer): TcxDataSummaryGroupItemLink;
begin
  Result := TcxDataSummaryGroupItemLink(inherited GetItem(Index));
end;

procedure TcxDataSummaryGroupItemLinks.SetItem(Index: Integer; Value: TcxDataSummaryGroupItemLink);
begin
  inherited SetItem(Index, Value);
end;

{ TcxDataSummaryGroup }

constructor TcxDataSummaryGroup.Create(Collection: TCollection);
begin
  FSummaryItems := TcxDataGroupSummaryItems.Create({SummaryGroups}(Collection as TcxDataSummaryGroups).Summary,
    {SummaryGroups}(Collection as TcxDataSummaryGroups).Summary.GetSummaryItemClass);
  FSummaryItems.FOwner := Self;
  inherited Create(Collection);
end;

destructor TcxDataSummaryGroup.Destroy;
begin
  FSummaryItems.Free;
  FSummaryItems := nil;
  FItemLinks.Free;
  FItemLinks := nil;
  inherited Destroy;
end;

procedure TcxDataSummaryGroup.Assign(Source: TPersistent);
begin
  if Source is TcxDataSummaryGroup then
  begin
    Links := TcxDataSummaryGroup(Source).Links;
    SummaryItems := TcxDataSummaryGroup(Source).SummaryItems;
  end
  else
    inherited Assign(Source);
end;

function TcxDataSummaryGroup.GetItemLinks: TcxDataSummaryGroupItemLinks;
begin
  if not Assigned(FItemLinks) then
    FItemLinks := TcxDataSummaryGroupItemLinks.Create(Self,
      {SummaryGroups}(Collection as TcxDataSummaryGroups).Summary.GetSummaryGroupItemLinkClass);
  Result := FItemLinks;
end;

function TcxDataSummaryGroup.GetSummaryGroups: TcxDataSummaryGroups;
begin
  if Assigned(Collection) and (Collection is TcxDataSummaryGroups) then
    Result := TcxDataSummaryGroups(Collection)
  else
    Result := nil;
end;

procedure TcxDataSummaryGroup.SetItemLinks(Value: TcxDataSummaryGroupItemLinks);
begin
  Links.Assign(Value);
end;

procedure TcxDataSummaryGroup.SetSummaryItems(Value: TcxDataGroupSummaryItems);
begin
  SummaryItems.Assign(Value);
end;

{ TcxDataSummaryGroups }

constructor TcxDataSummaryGroups.Create(ASummary: TcxDataSummary);
begin
  inherited Create(TcxDataSummaryGroup);
  FSummary := ASummary;
end;

function TcxDataSummaryGroups.Add: TcxDataSummaryGroup;
begin
  Result := TcxDataSummaryGroup(inherited Add);
end;

function TcxDataSummaryGroups.FindByItemLink(AItemLink: TObject): TcxDataSummaryGroup;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].Links.IndexOfItemLink(AItemLink) <> -1 then
    begin
      Result := Items[I];
      Break;
    end;
end;

function TcxDataSummaryGroups.GetOwner: TPersistent;
begin
  Result := FSummary;
end;

procedure TcxDataSummaryGroups.Update(Item: TCollectionItem);
begin
  Summary.Changed(False);
end;

function TcxDataSummaryGroups.GetItem(Index: Integer): TcxDataSummaryGroup;
begin
  Result := TcxDataSummaryGroup(inherited GetItem(Index));
end;

procedure TcxDataSummaryGroups.SetItem(Index: Integer; Value: TcxDataSummaryGroup);
begin
  inherited SetItem(Index, Value);
end;

{ TcxDataSummary }

constructor TcxDataSummary.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
  FDefaultGroupSummaryItems := TcxDataGroupSummaryItems.Create(Self, GetSummaryItemClass);
  FFooterSummaryItems := TcxDataFooterSummaryItems.Create(Self, GetSummaryItemClass);
  FSummaryGroups := TcxDataSummaryGroups.Create(Self);
end;

destructor TcxDataSummary.Destroy;
begin
  FDestroying := True;
  FDefaultGroupSummaryItems.Free;
  FDefaultGroupSummaryItems := nil;
  FFooterSummaryItems.Free;
  FFooterSummaryItems := nil;
  FSummaryGroups.Free;
  FSummaryGroups := nil;
  inherited Destroy;
end;

procedure TcxDataSummary.Assign(Source: TPersistent);
begin
  if Source is TcxDataSummary then
  begin
    BeginUpdate;
    try
      DefaultGroupSummaryItems := TcxDataSummary(Source).DefaultGroupSummaryItems;
      FooterSummaryItems := TcxDataSummary(Source).FooterSummaryItems;
      SummaryGroups := TcxDataSummary(Source).SummaryGroups;
      Options := TcxDataSummary(Source).Options;
      AssignEvents(Source); // TODO: option?
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxDataSummary.AssignEvents(Source: TPersistent);
begin
  if Source is TcxDataSummary then
    OnAfterSummary := TcxDataSummary(Source).OnAfterSummary;
end;

procedure TcxDataSummary.BeginUpdate;
begin
  DataController.BeginUpdate;
  Inc(FLockCount);
end;

procedure TcxDataSummary.BeginCalculate;
begin
  if FSetCustomSummary then Exit;
  CalculateFooterSummary;
end;

procedure TcxDataSummary.EndCalculate;
begin
  if FSetCustomSummary then Exit;
  CalculateGroupSummary;
  DoAfterSummary;
end;

procedure TcxDataSummary.Calculate;
begin
  BeginCalculate;
  EndCalculate;
end;

procedure TcxDataSummary.CalculateFooterSummary;
var
  ACountValues: TcxDataSummaryCountValues;
  ASummaryValues: TcxDataSummaryValues;
begin
  BeginCalculateSummary(FooterSummaryItems, ACountValues, ASummaryValues);
  if not DataController.IsGridMode then
    CalculateSummary(FooterSummaryItems, 0, DataController.DataControllerInfo.GetInternalRecordCount - 1,
      ACountValues, ASummaryValues, FFooterSummaryValues);
  EndCalculateSummary(FooterSummaryItems, ACountValues, ASummaryValues, FFooterSummaryValues);
end;

procedure TcxDataSummary.CalculateGroupSummary;

  procedure CalcLevel(ADataGroups: TcxDataGroups; ALevel: Integer);
  var
    ASummaryItems: TcxDataSummaryItems;
    ACurIndex, AGroupIndex: Integer;
    ACountValues: TcxDataSummaryCountValues;
    ASummaryValues: TcxDataSummaryValues;
    SV: Variant;
  begin
    ASummaryItems := GroupSummaryItems[ALevel];
    ACurIndex := 0;
    AGroupIndex := -1;
    while ACurIndex < ADataGroups.Count do
    begin
      if ADataGroups[ACurIndex].Level = ALevel then
      begin
        if AGroupIndex <> -1 then // close summary
        begin
          SV := ADataGroups[AGroupIndex].SummaryValues;
          EndCalculateSummary(ASummaryItems, ACountValues, ASummaryValues, SV);
          ADataGroups[AGroupIndex].SummaryValues := SV;
        end;
        AGroupIndex := ACurIndex;
        BeginCalculateSummary(ASummaryItems, ACountValues, ASummaryValues);
      end;
      if ADataGroups[ACurIndex].Level = (ADataGroups.LevelCount - 1) then
      begin
        SV := ADataGroups[ACurIndex].SummaryValues;
        CalculateSummary(ASummaryItems, ADataGroups[ACurIndex].BeginRecordListIndex,
          ADataGroups[ACurIndex].EndRecordListIndex, ACountValues, ASummaryValues,
          SV);
        ADataGroups[ACurIndex].SummaryValues := SV;
      end;
      Inc(ACurIndex);
    end;
    if AGroupIndex <> -1 then // close summary
    begin
      SV := ADataGroups[AGroupIndex].SummaryValues;
      EndCalculateSummary(ASummaryItems, ACountValues, ASummaryValues, SV);
      ADataGroups[AGroupIndex].SummaryValues := SV;
    end;
  end;

var
  I: Integer;
begin
  for I := 0 to DataController.DataControllerInfo.GroupingFieldList.Count - 1 do
    CalcLevel(DataController.DataControllerInfo.DataGroups, I);
end;

procedure TcxDataSummary.CancelUpdate;
begin
  DataController.EndUpdate; //?
  Dec(FLockCount);
end;

procedure TcxDataSummary.EndUpdate;
begin
  Dec(FLockCount);
  Changed(False);
  DataController.EndUpdate;
end;

function TcxDataSummary.GetGroupSummaryInfo(ARowIndex: Integer; var ASummaryItems: TcxDataSummaryItems;
  var ASummaryValues: PVariant): Boolean;
var
  ADataGroupIndex, ALevel: Integer;
begin
  ADataGroupIndex := DataController.DataControllerInfo.DataGroups.GetIndexByRowIndex(ARowIndex);
  Result := ADataGroupIndex <> -1;
  if Result then
  begin
    ALevel := DataController.DataControllerInfo.DataGroups[ADataGroupIndex].Level;
    ASummaryItems := GroupSummaryItems[ALevel];
    ASummaryValues := GetGroupSummaryValues(ADataGroupIndex);
    Result := (ASummaryItems <> nil) and (ASummaryValues <> nil) and
      not VarIsEmpty(ASummaryValues^);
  end;
end;

function TcxDataSummary.GetPatternSummaryItems(APatternSummary: TcxDataSummary;
  ASummaryItems: TcxDataSummaryItems): TcxDataSummaryItems;
begin
  if ASummaryItems = FooterSummaryItems then
    Result := APatternSummary.FooterSummaryItems
  else
    if ASummaryItems = DefaultGroupSummaryItems then
      Result := APatternSummary.DefaultGroupSummaryItems
    else
      Result := APatternSummary.SummaryGroups[(ASummaryItems.Owner as TcxDataSummaryGroup).Index].SummaryItems;
end;

procedure TcxDataSummary.Recalculate;
begin
  Changed(False);
//  BeginUpdate;
//  EndUpdate;
end;

procedure TcxDataSummary.RemoveItemByField(AField: TcxCustomDataField);

  function RemoveInSummaryItems(ASummaryItems: TcxDataSummaryItems): Boolean;
  var
    AItem: TcxDataSummaryItem;
  begin
    Result := False;
    repeat
      AItem := ASummaryItems.ItemOfField(AField);
      if AItem <> nil then
      begin
        //AItem.Free;
        AItem.FField := nil;
        Result := True;
      end;
    until AItem = nil;
  end;

  function RemoveInLinks(ALinks: TcxDataSummaryGroupItemLinks): Boolean;
  var
    AItem: TcxDataSummaryGroupItemLink;
  begin
    Result := False;
    repeat
      AItem := ALinks.ItemOfField(AField);
      if AItem <> nil then
      begin
        //AItem.Free;
        AItem.FField := nil;
        Result := True;
      end;
    until AItem = nil;
  end;

  function RemoveInSummaryGroup(ASummaryGroup: TcxDataSummaryGroup): Boolean;
  begin
    Result := False;
    if RemoveInSummaryItems(ASummaryGroup.SummaryItems) then
      Result := True;
    if RemoveInLinks(ASummaryGroup.Links) then
      Result := True;
  end;

  function RemoveInSummaryGroups: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to SummaryGroups.Count - 1 do
      if RemoveInSummaryGroup(SummaryGroups[I]) then
        Result := True;
  end;

var
  AChanged: Boolean;
begin
  BeginUpdate;
  AChanged := False;
  try
    if RemoveInSummaryItems(FooterSummaryItems) then
      AChanged := True;
    if RemoveInSummaryItems(DefaultGroupSummaryItems) then
      AChanged := True;
    if RemoveInSummaryGroups then
      AChanged := True;
  finally
    if AChanged then
      EndUpdate
    else
      CancelUpdate;
  end;
end;

procedure TcxDataSummary.BeginCalculateSummary(ASummaryItems: TcxDataSummaryItems;
  var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues);
var
  I: Integer;
begin
  SetLength(ASummaryValues, 0); // Clear
  SetLength(ACountValues, 0); // Clear
  SetLength(ASummaryValues, ASummaryItems.Count);
  SetLength(ACountValues, ASummaryItems.Count); // for Average
  for I := 0 to ASummaryItems.Count - 1 do
    ACountValues[I] := 0;
end;

procedure TcxDataSummary.CalculateSummary(ASummaryItems: TcxDataSummaryItems;
  ABeginIndex, AEndIndex: Integer; var ACountValues: TcxDataSummaryCountValues;
  var ASummaryValues: TcxDataSummaryValues; var SummaryValues: Variant);
var
  I, J, ARecordIndex: Integer;
begin
  for I := ABeginIndex to AEndIndex do
  begin
    ARecordIndex := GetRecordIndex(I);
    if ARecordIndex <> -1 then
      for J := 0 to ASummaryItems.Count - 1 do
        DoSummaryValue(ASummaryItems[J], ARecordIndex, ASummaryValues[J], ACountValues[J]);
  end;
end;

procedure TcxDataSummary.Changed(ARedrawOnly: Boolean);
begin
  if FInAfterSummary then Exit;
  if LockCount = 0 then
    Update(ARedrawOnly);
end;

procedure TcxDataSummary.DoAfterSummary;
begin
  if Assigned(FOnAfterSummary) then
  begin
    if DataController.IsLoading then
      DataController.FAfterSummaryFlag := True
    else
    begin
      DataController.FAfterSummaryFlag := False;
      FInAfterSummary := True;
      try
        if not DataController.IsPattern and not DataController.LockOnAfterSummary then
          FOnAfterSummary(Self);
      finally
        FInAfterSummary := False;
      end;
    end;
  end;
end;

procedure TcxDataSummary.DoFinishSummaryValue(ASummaryItem: TcxDataSummaryItem;
  var SummaryValue: Variant; var CountValue: Integer);
var
  AVarIsDate: Boolean;  
begin
  if not ASummaryItem.IsDataBinded then Exit;
  if VarIsEmpty(SummaryValue) then
    SummaryValue := Null;
  case ASummaryItem.Kind of
    skCount:
      SummaryValue := CountValue;
    skAverage:
      if (CountValue > 0) and not VarIsEmpty(SummaryValue) then
      begin
        AVarIsDate := VarIsDate(SummaryValue);
        SummaryValue := SummaryValue / CountValue;
        if AVarIsDate then
          VarCast(SummaryValue, SummaryValue, varDate); // WORKAROUND
      end;
  end;
end;

procedure TcxDataSummary.DoSummaryValue(ASummaryItem: TcxDataSummaryItem;
  ARecordIndex: Integer; var SummaryValue: Variant; var CountValue: Integer);
var
  AArguments: TcxSummaryEventArguments;
  AOutArguments: TcxSummaryEventOutArguments;
begin
  if not ASummaryItem.IsDataBinded then Exit;
  if ASummaryItem.DataField <> nil then
    AOutArguments.Value := DataController.GetInternalValue(ARecordIndex, ASummaryItem.DataField)
  else
    AOutArguments.Value := Null;
  AOutArguments.Done := False;
  if Assigned(ASummaryItem.SummaryItems.FOnSummary) then
  begin
    AArguments.RecordIndex := ARecordIndex;
    AArguments.SummaryItem := ASummaryItem;
    AOutArguments.SummaryValue := SummaryValue;
    AOutArguments.CountValue := CountValue;
    ASummaryItem.SummaryItems.FOnSummary(ASummaryItem.SummaryItems,
      AArguments, AOutArguments);
    SummaryValue := AOutArguments.SummaryValue;
    CountValue := AOutArguments.CountValue;
  end;
  if not AOutArguments.Done and (ASummaryItem.Kind <> skNone) and
    not ((soNullIgnore in Options) and VarIsNull(AOutArguments.Value)) then
  begin
    if VarIsEmpty(SummaryValue) then
    begin
      if ASummaryItem.Kind <> skCount then
      begin
        if not (VarIsNull(AOutArguments.Value) and (ASummaryItem.Kind in [skMin, skMax])) then
        begin
          SummaryValue := AOutArguments.Value;
          if VarIsNull(SummaryValue) and (ASummaryItem.Kind in [skSum, skAverage]) then
            SummaryValue := 0;
        end;
      end;
    end
    else
      if not VarIsNull(AOutArguments.Value) and not VarIsNull(SummaryValue) then
      begin
        case ASummaryItem.Kind of
          skSum, skAverage:
            SummaryValue := SummaryValue + AOutArguments.Value;
          skMin:
            if AOutArguments.Value < SummaryValue then
              SummaryValue := AOutArguments.Value;
          skMax:
            if AOutArguments.Value > SummaryValue then
              SummaryValue := AOutArguments.Value;
        end;
      end;
    Inc(CountValue);
  end;
end;

procedure TcxDataSummary.EndCalculateSummary(ASummaryItems: TcxDataSummaryItems;
  var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues;
  var SummaryValues: Variant);
var
  J: Integer;
begin
  for J := 0 to ASummaryItems.Count - 1 do
    DoFinishSummaryValue(ASummaryItems[J], ASummaryValues[J], ACountValues[J]);
//  {$IFDEF DELPHI5}
//  SummaryValues := Variant(ASummaryValues);
//  {$ELSE}
  if Length(ASummaryValues) = 0 then
    SummaryValues := Null
  else
    SummaryValues := Variant(ASummaryValues);
//  {$ENDIF}
end;

function TcxDataSummary.GetGroupSummaryValues(ADataGroupIndex: TcxDataGroupIndex): PVariant;
begin
  if ADataGroupIndex <> -1 then
    Result := @DataController.DataControllerInfo.DataGroups[ADataGroupIndex].SummaryValues
  else
    Result := nil;
end;

function TcxDataSummary.GetOwner: TPersistent;
begin
  Result := FDataController;
end;

function TcxDataSummary.GetRecordIndex(ARecordListIndex: Integer): Integer;
begin
  Result := DataController.DataControllerInfo.GetInternalRecordIndex(ARecordListIndex);
  if DataController.DataControllerInfo.IsSummaryForSelectedRecords then
  begin
    if DataController.IsFocusedSelectedMode then
    begin
      if Result <> DataController.DataControllerInfo.FocusedRecordIndex then
        Result := -1;
    end
    else
      if not DataController.DataControllerInfo.Selection.IsRecordSelected(Result) then
        Result := -1;
  end;
end;

function TcxDataSummary.GetSummaryItemClass: TcxDataSummaryItemClass;
begin
  Result := DataController.GetSummaryItemClass;
end;

function TcxDataSummary.GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass;
begin
  Result := DataController.GetSummaryGroupItemLinkClass;
end;

function TcxDataSummary.IsValidSummaryValuesIndex(const ASummaryValues: Variant;
  AIndex: Integer): Boolean;
begin
  Result := VarIsArray(ASummaryValues) and
    (VarArrayLowBound(ASummaryValues, 1) <= AIndex) and
    (AIndex <= VarArrayHighBound(ASummaryValues, 1));
end;

procedure TcxDataSummary.Update(ARedrawOnly: Boolean);
begin
  if not FDestroying then
    DataController.SummaryChanged(ARedrawOnly);
end;

function TcxDataSummary.GetFooterSummaryValue(Index: Integer): Variant;
begin
  Result := Null;
  if IsValidSummaryValuesIndex(FFooterSummaryValues, Index) then
    Result := FFooterSummaryValues[Index];
end;

function TcxDataSummary.GetFooterSummaryText(Index: Integer): string;
begin
  Result := FooterSummaryItems[Index].FormatValue(FooterSummaryValues[Index], True);
end;

function TcxDataSummary.GetGroupSummaryItems(Level: Integer): TcxDataGroupSummaryItems;
var
  ASummaryGroup: TcxDataSummaryGroup;
begin
  if (0 <= Level) and (Level < DataController.DataControllerInfo.GroupingFieldList.Count) then
  begin
    ASummaryGroup := SummaryGroups.FindByItemLink(DataController.DataControllerInfo.GroupingFieldList[Level].Field.Item);
//    ASummaryGroup := SummaryGroups.FindByItemLink(DataController.DataControllerInfo.DataGroups.Fields[Level].Item);
    if ASummaryGroup <> nil then
      Result := ASummaryGroup.SummaryItems
    else
      Result := DefaultGroupSummaryItems;
  end
  else
    Result := nil;
end;

function TcxDataSummary.GetGroupSummaryText(RowIndex: Integer): string;
var
  ASummaryItems: TcxDataSummaryItems;
  PSummaryValues: PVariant;
begin
  if GetGroupSummaryInfo(RowIndex, ASummaryItems, PSummaryValues) then
    Result := ASummaryItems.GetGroupText(PSummaryValues^)
  else
    Result := '';
end;

function TcxDataSummary.GetGroupSummaryDisplayValue(RowIndex, Level, Index: Integer): Variant;
var
  ADataGroupIndex: Integer;
begin
  ADataGroupIndex := DataController.DataControllerInfo.DataGroups.GetIndexByRowIndexLevel(RowIndex, Level);
  Result := GroupSummaryValues[ADataGroupIndex, Index];
end;

function TcxDataSummary.GetGroupSummaryValue(DataGroupIndex: TcxDataGroupIndex;
  Index: Integer): Variant;
var
  PSummaryValues: PVariant;
begin
  PSummaryValues := GetGroupSummaryValues(DataGroupIndex);
  if (PSummaryValues <> nil) and IsValidSummaryValuesIndex(PSummaryValues^, Index) then
    Result := PSummaryValues^[Index]
  else
    Result := Null;
end;

function TcxDataSummary.GetGroupFooterIndexOfItemLink(Level: Integer; ItemLink: TObject): Integer;
var
  ASummaryItems: TcxDataSummaryItems;
  I: Integer;
begin
  Result := -1;
  ASummaryItems := GroupSummaryItems[Level];
  if ASummaryItems <> nil then
    for I := 0 to ASummaryItems.Count - 1 do
      if (ASummaryItems[I].Position = spFooter) and (ASummaryItems[I].ItemLink = ItemLink) then
      begin
        Result := I;
        Break;
      end;
end;

function TcxDataSummary.GetGroupFooterSummaryText(RowIndex, Level, Index: Integer): string;
var
  ADataGroupIndex: Integer;
  ASummaryItems: TcxDataSummaryItems;
  PSummaryValues: PVariant;
begin
  Result := '';
  ADataGroupIndex := DataController.DataControllerInfo.DataGroups.GetIndexByRowIndexLevel(RowIndex, Level);
  if ADataGroupIndex <> -1 then
  begin
    ASummaryItems := GroupSummaryItems[Level];
    PSummaryValues := GetGroupSummaryValues(ADataGroupIndex);
    if (ASummaryItems <> nil) and (PSummaryValues <> nil) and
      IsValidSummaryValuesIndex(PSummaryValues^, Index) then
      Result := ASummaryItems[Index].FormatValue(PSummaryValues^[Index], True);
  end;
end;

function TcxDataSummary.GetOptions: TcxSummaryOptions;
begin
  Result := FOptions;
end;

procedure TcxDataSummary.SetDefaultGroupSummaryItems(Value: TcxDataGroupSummaryItems);
begin
  FDefaultGroupSummaryItems.Assign(Value);
end;

procedure TcxDataSummary.SetFooterSummaryItems(Value: TcxDataFooterSummaryItems);
begin
  FFooterSummaryItems.Assign(Value);
end;

procedure TcxDataSummary.SetFooterSummaryValue(Index: Integer; Value: Variant);
begin
  if FooterSummaryValues[Index] <> Value then
  begin
    if IsValidSummaryValuesIndex(FFooterSummaryValues, Index) then
    begin
      FSetCustomSummary := True;
      try
        FFooterSummaryValues[Index] := Value;
        Changed(True);
      finally
        FSetCustomSummary := False;
      end;
    end;
  end;
end;

procedure TcxDataSummary.SetGroupSummaryDisplayValue(RowIndex, Level, Index: Integer; const Value: Variant);
var
  ADataGroupIndex: Integer;
begin
  ADataGroupIndex := DataController.DataControllerInfo.DataGroups.GetIndexByRowIndexLevel(RowIndex, Level);
  GroupSummaryValues[ADataGroupIndex, Index] := Value;
end;

procedure TcxDataSummary.SetGroupSummaryValue(DataGroupIndex: TcxDataGroupIndex;
  Index: Integer; const Value: Variant);
var
  PSummaryValues: PVariant;
begin
  if GetGroupSummaryValue(DataGroupIndex, Index) <> Value then
  begin
    PSummaryValues := GetGroupSummaryValues(DataGroupIndex);
    if (PSummaryValues <> nil) and IsValidSummaryValuesIndex(PSummaryValues^, Index) then
    begin
      FSetCustomSummary := True;
      try
        PSummaryValues^[Index] := Value;
        Changed(True);
      finally
        FSetCustomSummary := False;
      end;
    end;
  end;
end;

procedure TcxDataSummary.SetOptions(Value: TcxSummaryOptions);
begin
  if FOptions <> Value then
  begin
    // only one: soSelectedRecords or soSelections
    if Value * [soSelectedRecords, soMultipleSelectedRecords] = [soSelectedRecords, soMultipleSelectedRecords] then
    begin
      if soMultipleSelectedRecords in FOptions then
        Value := Value - [soMultipleSelectedRecords]
      else
        Value := Value - [soSelectedRecords];
    end;
    FOptions := Value;
    Changed(False);
  end;
end;

procedure TcxDataSummary.SetSummaryGroups(Value: TcxDataSummaryGroups);
begin
  SummaryGroups.Assign(Value);
end;

{ TcxDataControllerSearch }

constructor TcxDataControllerSearch.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
end;

procedure TcxDataControllerSearch.Cancel;
begin
  if Locked then Exit;
  if DataController.FIncrementalSearching then
  begin
    DataController.FIncrementalSearchText := '';
    DataController.FIncrementalSearching := False;
    DataController.Change([dccSearch]);
  end;
end;

function TcxDataControllerSearch.Locate(AItemIndex: Integer; const ASubText: string): Boolean;
var
  AFilteredRecordIndex, AStartFilteredRecordIndex, AEndFilteredRecordIndex, AFocusedRecordIndex: Integer;
begin
  Result := False;
  if (ASubText = '') or (DataController.FilteredRecordCount = 0) then Exit;
  ItemIndex := AItemIndex;
  if DataController.IsGridMode then
    Result := DataController.DoSearchInGridMode(ASubText, True, False)
  else
  begin
    AFocusedRecordIndex := DataController.GetFocusedRecordIndex;
    if AFocusedRecordIndex < 0 then
      AStartFilteredRecordIndex := 0
    else
      AStartFilteredRecordIndex := DataController.FilteredIndexByRecordIndex[AFocusedRecordIndex];
    AFilteredRecordIndex := DoSearch(AStartFilteredRecordIndex, -1, ASubText, True);
    if AFilteredRecordIndex = -1 then
    begin
      AEndFilteredRecordIndex := AStartFilteredRecordIndex - 1;
      AStartFilteredRecordIndex := 0;
      AFilteredRecordIndex := DoSearch(AStartFilteredRecordIndex, AEndFilteredRecordIndex, ASubText, True);
    end;
    if AFilteredRecordIndex <> -1 then
    begin
      DoFocusedRecord(AFilteredRecordIndex);
      Result := True;
    end;
  end;
  if Result then
  begin
    DataController.FIncrementalSearching := True;
    DataController.FIncrementalSearchText := ASubText;
    DataController.Change([dccSearch]);
    DataController.CheckFocusedSelected;
  end;
end;

function TcxDataControllerSearch.LocateNext(AForward: Boolean): Boolean;
var
  AFilteredRecordIndex, AFocusedRecordIndex: Integer;
begin
  Result := False;
  if not Searching or (SearchText = '') or (ItemIndex = -1) or
    (DataController.FilteredRecordCount = 0) then Exit;
  if DataController.IsGridMode then
    Result := DataController.DoSearchInGridMode(SearchText, AForward, True)
  else
  begin
    AFocusedRecordIndex := DataController.GetFocusedRecordIndex;
    if AFocusedRecordIndex < 0 then Exit;
    if AForward then
    begin
      AFilteredRecordIndex := DataController.FilteredIndexByRecordIndex[AFocusedRecordIndex] + 1;
      if AFilteredRecordIndex >= DataController.FilteredRecordCount then Exit;
    end
    else
    begin
      AFilteredRecordIndex := DataController.FilteredIndexByRecordIndex[AFocusedRecordIndex] - 1;
      if AFilteredRecordIndex < 0 then Exit;
    end;
    AFilteredRecordIndex := DoSearch(AFilteredRecordIndex, -1, SearchText, AForward);
    if AFilteredRecordIndex <> -1 then
    begin
      DoFocusedRecord(AFilteredRecordIndex);
      Result := True;
    end;
  end;
  if Result then 
    DataController.CheckFocusedSelected;
end;

procedure TcxDataControllerSearch.Lock;
begin
  FLocked := True;
end;

procedure TcxDataControllerSearch.Unlock;
begin
  FLocked := False;
end;

procedure TcxDataControllerSearch.DoFocusedRecord(AFilteredRecordIndex: Integer);
var
  AFocusedRecordIndex: Integer;
begin
  AFocusedRecordIndex := DataController.FilteredRecordIndex[AFilteredRecordIndex];
  Lock;
  try
    DataController.ChangeFocusedRecordIndex(AFocusedRecordIndex);
    DataController.SyncSelectionFocusedRecord;
  finally
    Unlock;
  end;
end;

function TcxDataControllerSearch.DoSearch(AStartFilteredRecordIndex, AEndFilteredRecordIndex: Integer;
  const ASubText: string; AForward: Boolean): Integer;
var
  I, ARecordIndex, AFieldIndex: Integer;
  S: string;
begin
  Result := -1;
  if AEndFilteredRecordIndex = -1 then // auto
  begin
    if AForward then
      AEndFilteredRecordIndex := DataController.FilteredRecordCount - 1
    else
      AEndFilteredRecordIndex := 0;
  end;
  AFieldIndex := DataController.FIncrementalSearchField.Index;
  I := AStartFilteredRecordIndex;
  while (AForward and (I <= AEndFilteredRecordIndex)) or
    (not AForward and (I >= AEndFilteredRecordIndex)) do
  begin
    ARecordIndex := DataController.FilteredRecordIndex[I];
    S := DataController.GetIncrementalSearchText(ARecordIndex, AFieldIndex);
    if DataCompareText(S, ASubText, True) then
    begin
      Result := I;
      Break;
    end;
    if AForward then
      Inc(I)
    else
      Dec(I);
  end;
end;

function TcxDataControllerSearch.GetItemIndex: Integer;
begin
  if DataController.FIncrementalSearchField <> nil then
    Result := DataController.FIncrementalSearchField.Index
  else
    Result := -1;
end;

function TcxDataControllerSearch.GetSearching: Boolean;
begin
  Result := DataController.FIncrementalSearching;
end;

function TcxDataControllerSearch.GetSearchText: string;
begin
  Result := DataController.FIncrementalSearchText;
end;

procedure TcxDataControllerSearch.SetItemIndex(const Value: Integer);
begin
  DataController.CheckItemRange(Value);
  DataController.FIncrementalSearchField := DataController.Fields[Value];
end;

{ TcxFocusedRecordChangedInfo }

constructor TcxFocusedRecordChangedInfo.Create(APrevFocusedRecordIndex, AFocusedRecordIndex,
  APrevFocusedRowIndex, AFocusedRowIndex: Integer; ANewItemRowFocusingChanged: Boolean);
begin
  inherited Create;
  FFocusedRecordIndex := APrevFocusedRecordIndex;
  FPrevFocusedRecordIndex := AFocusedRecordIndex;
  FPrevFocusedRowIndex := APrevFocusedRowIndex;
  FFocusedRowIndex := AFocusedRowIndex;
  FNewItemRowFocusingChanged := ANewItemRowFocusingChanged;
end;

{ TcxFocusedRowChangedInfo }

constructor TcxFocusedRowChangedInfo.Create(APrevFocusedRowIndex, AFocusedRowIndex: Integer);
begin
  inherited Create;
  FFocusedRowIndex := AFocusedRowIndex;
  FPrevFocusedRowIndex := APrevFocusedRowIndex;
end;

{ TcxUpdateRecordInfo }

constructor TcxUpdateRecordInfo.Create(ARecordIndex: Integer);
begin
  inherited Create;
  FRecordIndex := ARecordIndex;
end;

{ TcxSelectionChangedInfo }

constructor TcxSelectionChangedInfo.Create;
begin
  inherited Create;
  FRowIndexes := TList.Create;
end;

constructor TcxSelectionChangedInfo.CreateEx(ARowIndex1, ARowIndex2: Integer);
begin
  Create;
  if ARowIndex1 <> -1 then
    FRowIndexes.Add(Pointer(ARowIndex1));
  if (ARowIndex2 <> -1) and (ARowIndex2 <> ARowIndex1) then
    FRowIndexes.Add(Pointer(ARowIndex2));
end;

destructor TcxSelectionChangedInfo.Destroy;
begin
  FRowIndexes.Free;
  inherited Destroy;
end;

function TcxSelectionChangedInfo.GetCount: Integer;
begin
  Result := FRowIndexes.Count;
end;

function TcxSelectionChangedInfo.GetRowIndex(Index: Integer): Integer;
begin
  Result := Integer(FRowIndexes[Index]);
end;

{ TcxDataControllerLocateObject }

constructor TcxDataControllerLocateObject.Create(ADataController: TcxCustomDataController);
begin
  inherited Create;
  FDataController := ADataController;
end;

destructor TcxDataControllerLocateObject.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TcxDataControllerLocateObject.Clear;
begin
  if FInternalRecordIndex < 0 then
  begin
    FDataController.DataStorage.DeleteRecord(FInternalRecordIndex);
    FInternalRecordIndex := 0;
  end;
end;

procedure TcxDataControllerLocateObject.ReadData(AValueDefReader: TcxValueDefReader);
begin
  if FInternalRecordIndex = 0 then
    FInternalRecordIndex := FDataController.DataStorage.AddInternalRecord;
  FDataController.BeginReadRecord;
  try
    FDataController.DataStorage.ReadRecord(FInternalRecordIndex, AValueDefReader);
  finally
    FDataController.EndReadRecord;
  end;
end;

{ TcxDataControllerKeyLocateObject }

constructor TcxDataControllerKeyLocateObject.Create(ADataController: TcxCustomDataController);
begin
  inherited Create(ADataController);
  FFields := TList.Create;
end;

destructor TcxDataControllerKeyLocateObject.Destroy;
begin
  Clear;
  FFields.Free;
  inherited Destroy;
end;

procedure TcxDataControllerKeyLocateObject.AddField(AField: TcxCustomDataField);
begin
  FFields.Add(AField);
end;

procedure TcxDataControllerKeyLocateObject.ClearFields;
begin
  FFields.Clear;
end;

function TcxDataControllerKeyLocateObject.FindRecordIndex: Integer;
begin
  if InternalRecordIndex < 0 then
    Result := FDataController.FindRecordByFields(InternalRecordIndex, FFields)
  else
    Result := -1;
end;

{ TcxDataControllerGroupLocateObject }

constructor TcxDataControllerGroupLocateObject.Create(ADataController: TcxCustomDataController);
var
  I: Integer;
  AField: TcxCustomDataField;
begin
  inherited Create(ADataController);
  FFields := TList.Create;
  FFindGroupRecordEnabled := True;
  for I := 0 to DataController.Groups.GroupingItemCount - 1 do
  begin
    AField := DataController.Fields[DataController.Groups.GroupingItemIndex[I]];
    FFields.Add(AField);
    if DataController.IsSortByDisplayTextNeeded(AField) then
      FFindGroupRecordEnabled := False;
  end;
  FFindFields := TList.Create;
  CorrectFindFields;
end;

destructor TcxDataControllerGroupLocateObject.Destroy;
begin
  FFindFields.Free;
  FFields.Free;
  inherited Destroy;
end;

function TcxDataControllerGroupLocateObject.FindRecordIndex: Integer;
begin
  if InternalRecordIndex < 0 then
  begin
    if FFindGroupRecordEnabled then
      Result := FDataController.FindGroupRecord(InternalRecordIndex, Level + 1)
    else
    begin
      FDataController.FInternalFindRecord := True;
      try
        Result := FDataController.FindRecordByFields(InternalRecordIndex, FFindFields);
      finally
        FDataController.FInternalFindRecord := False;
      end;
    end;
  end
  else
    Result := -1;
end;

procedure TcxDataControllerGroupLocateObject.CorrectFindFields;
var
  I: Integer;
begin
  if not FFindGroupRecordEnabled then
  begin
    ListSetCount(FFindFields, Level + 1);
    for I := 0 to FFindFields.Count - 1 do
      FFindFields[I] := FFields[I];
  end;
end;

procedure TcxDataControllerGroupLocateObject.SetLevel(Value: Integer);
begin
  if FLevel <> Value then
  begin
    FLevel := Value;
    CorrectFindFields;
  end;
end;

{ TcxValueDefUnboundReader }

constructor TcxValueDefUnboundReader.Create;
begin
  inherited Create;
  FItems := TList.Create;
  FValues := TList.Create;
end;

destructor TcxValueDefUnboundReader.Destroy;
begin
  Clear;
  FValues.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TcxValueDefUnboundReader.Clear;
begin
  Truncate(0);
end;

function TcxValueDefUnboundReader.GetValue(AValueDef: TcxValueDef): Variant;
var
  I: Integer;
  P: PVariant;
begin
  if AValueDef is TcxInternalValueDef then
    AValueDef := TcxInternalValueDef(AValueDef).GetValueDef;
  I := FItems.IndexOf(AValueDef);
  if I <> -1 then
  begin
    P := PVariant(FValues[I]);
    if P <> nil then
      Result := P^
    else
      Result := Null;
  end
  else
    Result := Null;
end;

function TcxValueDefUnboundReader.IsInternal(AValueDef: TcxValueDef): Boolean;
begin
  Result := IsValueDefInternal(AValueDef);
end;

procedure TcxValueDefUnboundReader.SetValue(AValueDef: TcxValueDef; const AValue: Variant);
var
  I: Integer;
  P: PVariant;
begin
  I := FItems.IndexOf(AValueDef);
  if I = -1 then
    I := FItems.Add(AValueDef);
  while FValues.Count < FItems.Count do
    FValues.Add(nil);
  P := PVariant(FValues[I]);
  if P = nil then
  begin
    New(P);
    FValues[I] := P;
  end;
  P^ := AValue;
end;

procedure TcxValueDefUnboundReader.Truncate(AItemCount: Integer);
var
  I: Integer;
begin
  for I := FValues.Count - 1 downto AItemCount do 
  begin
    if PVariant(FValues[I]) <> nil then
      Dispose(PVariant(FValues[I]));
    FValues.Delete(I);
  end;
end;

{ TcxValueDefRecordReader }

constructor TcxValueDefRecordReader.Create(ADataController: TcxCustomDataController;
  ARecordIndex: Integer);
begin
  inherited Create;
  FDataController := ADataController;
  FRecordIndex := ARecordIndex;
end;

function TcxValueDefRecordReader.GetDisplayText(AValueDef: TcxValueDef): string;
var
  AField: TcxCustomDataField;
begin
  AField := AValueDef.LinkObject as TcxCustomDataField;
  if not AField.IsInternal then
    Result := FDataController.GetInternalDisplayText(FRecordIndex, AField)
  else
    Result := '';
end;

function TcxValueDefRecordReader.GetValue(AValueDef: TcxValueDef): Variant;
var
  AField: TcxCustomDataField;
begin
  AField := AValueDef.LinkObject as TcxCustomDataField;
//  if not AField.IsInternal then
//    Result := FDataController.GetInternalValue(FRecordIndex, AField)
//  else
//    Result := Null;
  Result := FDataController.GetInternalValue(FRecordIndex, AField);
end;

function TcxValueDefRecordReader.IsInternal(AValueDef: TcxValueDef): Boolean;
begin
  Result := IsValueDefInternal(AValueDef);
end;

{ TcxDataControllerNotifier }

constructor TcxDataControllerNotifier.Create(AOwner: TComponent; ADataController: TcxCustomDataController);
begin
  inherited Create(AOwner);
  FDataController := ADataController;
end;

procedure TcxDataControllerNotifier.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and
    not ((AComponent = Self) and (csDestroying in ComponentState)) then
    DataController.RemoveNotification(AComponent);
end;

{ TcxSortingBySummaryEngine }

constructor TcxSortingBySummaryEngine.Create(ADataControllerInfo: TcxCustomDataControllerInfo);
begin
  inherited Create;
  FDataControllerInfo := ADataControllerInfo;
end;

function TcxSortingBySummaryEngine.GetDataController: TcxCustomDataController;
begin
  Result := FDataControllerInfo.DataController;
end;

{ TcxCustomDataController }

constructor TcxCustomDataController.Create(AOwner: TComponent);
begin
  inherited Create;
  FOwner := AOwner;
  FFocusedSelected := True;
  FOptions := [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding];
  FDataChangedListeners := TList.Create;
  FDataStorage := TcxDataStorage.Create;
  FGroups := TcxDataControllerGroups.Create(Self);
  FFields := TcxCustomDataFieldList.Create(Self);
  FFilters := TcxDataFilterList.Create;
  FFilter := GetFilterCriteriaClass.Create(Self);
  FSearch := GetSearchClass.Create(Self);
  FSummary := GetSummaryClass.Create(Self);
  FProvider := GetDataProviderClass.Create(Self);
  FDataControllerInfo := TcxCustomDataControllerInfo.Create(Self);
  FMasterRecordIndex := -1;
  FBookmarkRecordIndex := -1;
  FNearestRecordIndex := -1;
  ResetDataChangeInfo;
  FNotifier := TcxDataControllerNotifier.Create(nil, Self);
  FDataStorage.OnClearInternalRecords := DataStorageClearInternalRecords;
  UpdateUseRecordIDState;
  FListenerLinks := TList.Create;
end;

destructor TcxCustomDataController.Destroy;
begin
  Destroying; // for CLR
  FNotifier.Free;
  FNotifier := nil;
  FRelations.Free;
  FRelations := nil;
  FDataControllerInfo.Free;
  FSummary.Free;
  FSummary := nil;
  FFilter.Free;
  FFilter := nil;
  FFilters.Free;
  FFilters := nil;
  FDataStorage.Clear(False);
  FGroups.Free;
  FFields.Free;
  FDataStorage.Free;
  FProvider.Free;
  FSearch.Free;
  ClearDataChangedListeners;
  FDataChangedListeners.Free;
  NotifyListenerLinks;
  FListenerLinks.Free;
  FListenerLinks := nil;
  inherited Destroy;
end;

procedure TcxCustomDataController.Assign(Source: TPersistent);
begin
  if Source is TcxCustomDataController then
  begin
    Options := TcxCustomDataController(Source).Options;
    //Filter := TcxCustomDataController(Source).Filter;
    Filter.Assign(TcxCustomDataController(Source).Filter, True);
    Summary := TcxCustomDataController(Source).Summary;

    OnAfterCancel := TcxCustomDataController(Source).OnAfterCancel;
    OnAfterDelete := TcxCustomDataController(Source).OnAfterDelete;
    OnAfterInsert := TcxCustomDataController(Source).OnAfterInsert;
    OnAfterPost := TcxCustomDataController(Source).OnAfterPost;
    OnBeforeCancel := TcxCustomDataController(Source).OnBeforeCancel;
    OnBeforeDelete := TcxCustomDataController(Source).OnBeforeDelete;
    OnBeforeInsert := TcxCustomDataController(Source).OnBeforeInsert;
    OnBeforePost := TcxCustomDataController(Source).OnBeforePost;
    OnFilterRecord := TcxCustomDataController(Source).OnFilterRecord;
    OnNewRecord := TcxCustomDataController(Source).OnNewRecord;

    OnCompare := TcxCustomDataController(Source).OnCompare;
    OnDataChanged := TcxCustomDataController(Source).OnDataChanged;
    OnDetailCollapsing := TcxCustomDataController(Source).OnDetailCollapsing;
    OnDetailCollapsed := TcxCustomDataController(Source).OnDetailCollapsed;
    OnDetailExpanding := TcxCustomDataController(Source).OnDetailExpanding;
    OnDetailExpanded := TcxCustomDataController(Source).OnDetailExpanded;
    OnGroupingChanged := TcxCustomDataController(Source).OnGroupingChanged;
    OnRecordChanged := TcxCustomDataController(Source).OnRecordChanged;
    OnSortingChanged := TcxCustomDataController(Source).OnSortingChanged;
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomDataController.BeforeDestruction;
begin
  inherited BeforeDestruction;
  FDestroying := True;
end;

procedure TcxCustomDataController.Destroying;
begin
end;

function TcxCustomDataController.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxCustomDataController.BeginUpdate;
begin
  DataControllerInfo.BeginUpdate;
end;

procedure TcxCustomDataController.EndUpdate;
begin
  DataControllerInfo.EndUpdate;
  CheckChanges;
end;

procedure TcxCustomDataController.BeginFullUpdate;
begin
  BeginUpdate;
end;

procedure TcxCustomDataController.EndFullUpdate;
begin
  EndUpdate;
end;

procedure TcxCustomDataController.BeginUpdateFields;
begin
  Inc(FLockUpdateFieldsCount);
end;

procedure TcxCustomDataController.EndUpdateFields;
begin
  Dec(FLockUpdateFieldsCount);
  if (FLockUpdateFieldsCount = 0) and FUpdateFieldsFlag then
  begin
    FUpdateFieldsFlag := False;
    LayoutChanged([lcStructure]);
  end;
end;

procedure TcxCustomDataController.SaveKeys;
begin
  if FSaveObjectLockCount = 0 then
  begin
    BeginFullUpdate;
    FSaveObject := TcxSaveObject.Create;
    TcxSaveObject(FSaveObject).Save(Self);
  end;
  Inc(FSaveObjectLockCount);
end;

procedure TcxCustomDataController.RestoreKeys;
begin
  Dec(FSaveObjectLockCount);
  if FSaveObjectLockCount = 0 then
  begin
    try
      TcxSaveObject(FSaveObject).Restore(Self);
      FSaveObject.Free;
      FSaveObject := nil;
    finally
      EndFullUpdate;
    end;
  end;
end;

function TcxCustomDataController.CreateFilter: TcxDataFilterCriteria;
begin
  Result := GetFilterCriteriaClass.Create(Self);
  FFilters.Add(Result);
end;

function TcxCustomDataController.AddItem(AItem: TObject): TcxCustomDataField;
begin
  if (AItem <> nil) and (Fields.FieldByItem(AItem) <> nil) then
    InvalidOperation(cxSDataItemExistError);
  Result := AddField;
  Result.Item := AItem;
end;

function TcxCustomDataController.ItemPropertiesChanged(AItemIndex: Integer): Boolean;
begin
  Result := (AItemIndex = -1) or (GetItemSortOrder(AItemIndex) <> soNone);
  if Result then
    Refresh;
end;

procedure TcxCustomDataController.Loaded;
begin
  if FDataChangedFlag then
    DoDataChanged;
  if FAfterSummaryFlag then
    Summary.DoAfterSummary;
end;

procedure TcxCustomDataController.RemoveItem(AItem: TObject);
var
  AField: TcxCustomDataField;
begin
  AField := Fields.FieldByItem(AItem);
  if AField <> nil then
  begin
    BeginUpdate;
    try
      DataControllerInfo.RemoveField(AField);
      AField.Free;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataController.UpdateItemIndexes;
var
  I: Integer;
  AField: TcxCustomDataField;
begin
  for I := 0 to ItemCount - 1 do
  begin
    AField := Fields.FieldByItem(GetItem(I));
    AField.Index := I;
  end;
  Change([dccLayout]);
end;

procedure TcxCustomDataController.UpdateItems(AUpdateFields: Boolean);
begin
  if FUpdateItems then Exit;
  FUpdateItems := True;
  try
    if LockCount <> 0 then
      FStructureChanged := True;
    if IsProviderDataSource then
      UpdateStorage(AUpdateFields);
  finally
    FUpdateItems := False;
  end;
end;

function TcxCustomDataController.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := False;
end;

// Data Changed notify

procedure TcxCustomDataController.AddDataChangedListener(AInstance: TObject;
  ADataChangedEvent: TNotifyEvent);
var
  E: TNotifyEventItem;
begin
  E := TNotifyEventItem.Create;
  E.Instance := AInstance;
  E.Event := ADataChangedEvent;
  FDataChangedListeners.Add(E);
end;

procedure TcxCustomDataController.RemoveDataChangedListener(AInstance: TObject;
  ADataChangedEvent: TNotifyEvent);
var
  I: Integer;
  E: TNotifyEventItem;
begin
  for I := 0 to FDataChangedListeners.Count - 1 do
  begin
    E := TNotifyEventItem(FDataChangedListeners[I]);
    if (E.Instance = AInstance) and (@E.Event = @ADataChangedEvent) then
    begin
      E.Free;
      FDataChangedListeners.Delete(I);
      Break;
    end;
  end;
end;

procedure TcxCustomDataController.AddDataChangeRefCount;
begin
  Inc(FDataChangeRefCount);
  IsPattern := FIsPatternSave;
end;

procedure TcxCustomDataController.RemoveDataChangeRefCount;
begin
  Dec(FDataChangeRefCount);
  IsPattern := FIsPatternSave;
end;

function TcxCustomDataController.DataChangedNotifyLocked: Boolean;
begin
  Result := FDataChangedLockCount <> 0;
end;

function TcxCustomDataController.IsDataLoading: Boolean;
begin
  Result := (Provider <> nil) and (Provider.LockCount <> 0);
end;

procedure TcxCustomDataController.LockDataChangedNotify;
begin
  Inc(FDataChangedLockCount);
end;

procedure TcxCustomDataController.UnlockDataChangedNotify;
begin
  Dec(FDataChangedLockCount);
end;

procedure TcxCustomDataController.LockGridModeNotify;
begin
  Inc(FLockGridModeNotifyCount);
  Provider.BeginLocate;
end;

procedure TcxCustomDataController.UnlockGridModeNotify;
begin
  Provider.EndLocate;
  Dec(FLockGridModeNotifyCount);
end;

// Structure

procedure TcxCustomDataController.ChangeNeedConversion(AItemIndex: Integer;
  ANeedConversion: Boolean);
begin
  CheckItemRange(AItemIndex);
  if GetItemNeedConversion(AItemIndex) <> ANeedConversion then
  begin
    Fields[AItemIndex].NeedConversion := ANeedConversion;
    DataControllerInfo.UpdateField(Fields[AItemIndex]);
  end;
end;

procedure TcxCustomDataController.ChangeTextStored(AItemIndex: Integer;
  ATextStored: Boolean);
begin
  CheckItemRange(AItemIndex);
  if GetItemTextStored(AItemIndex) <> ATextStored then
  begin
    Fields[AItemIndex].TextStored := ATextStored;
    DataControllerInfo.UpdateField(Fields[AItemIndex]);
  end;
end;

procedure TcxCustomDataController.ChangeValueTypeClass(AItemIndex: Integer;
  AValueTypeClass: TcxValueTypeClass);
begin
  CheckItemRange(AItemIndex);
  if GetItemValueTypeClass(AItemIndex) <> AValueTypeClass then
  begin
    Fields[AItemIndex].ValueTypeClass := AValueTypeClass;
    if IsProviderMode then
      RestructData;
    DataControllerInfo.UpdateField(Fields[AItemIndex]);
    DoValueTypeClassChanged(AItemIndex);
  end;
end;

function TcxCustomDataController.GetItemCount: Integer;
begin
  Result := Fields.ItemCount;
end;

function TcxCustomDataController.GetItemNeedConversion(AItemIndex: Integer): Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.GetItemTextStored(AItemIndex: Integer): Boolean;
begin
  CheckItemRange(AItemIndex);
  Result := Fields[AItemIndex].TextStored;
end;

function TcxCustomDataController.GetItemValueTypeClass(AItemIndex: Integer): TcxValueTypeClass;
begin
  CheckItemRange(AItemIndex);
  Result := Fields[AItemIndex].ValueTypeClass;
end;

function TcxCustomDataController.IsDisplayFormatDefined(AItemIndex: Integer;
  AIgnoreSimpleCurrency: Boolean): Boolean;
begin
  Result := GetItemTextStored(AItemIndex);
end;

// Data

function TcxCustomDataController.AppendRecord: Integer;

  function DataStorageAppendRecord: Integer;
  begin
    Result := DataStorage.AppendRecord;
    DataChanged(dcNew, -1, -1);
  end;

begin
  if IsSmartLoad then
    Result := AppendInSmartLoad
  else
    if IsProviderMode then
      Result := Provider.AppendRecord
    else
      Result := DataStorageAppendRecord;
end;

procedure TcxCustomDataController.DeleteRecord(ARecordIndex: Integer);

  procedure DataStorageDeleteRecord(ARecordIndex: Integer);
  begin
    DataStorage.DeleteRecord(ARecordIndex);
    CorrectAfterDelete(ARecordIndex);
    CheckSelectedCount(ARecordIndex);
    CheckInternalRecordRange(ARecordIndex);
    DataChanged(dcDeleted, -1, -1);
  end;

begin
  CheckRecordRange(ARecordIndex);
  if IsSmartLoad and FInSmartLoad then
    DeleteInSmartLoad(ARecordIndex)
  else
  begin
    if Provider.EditingRecordIndex = ARecordIndex then
      Provider.FEditingRecordIndex := cxNullEditingRecordIndex; 
    if IsProviderMode and (ARecordIndex >= 0) then
      Provider.DeleteRecord(ARecordIndex)
    else
      DataStorageDeleteRecord(ARecordIndex);
  end;    
end;

function TcxCustomDataController.GetGroupValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
begin
  Result := GetInternalValue(ARecordIndex, AField);
end;

procedure TcxCustomDataController.GetGroupValues(ARecordIndex: Integer; var AValues: TcxDataSummaryValues);
var
  I: Integer;
begin
  // Clear
  SetLength(AValues, 0);
  SetLength(AValues, Groups.GroupingItemCount);
  for I := 0 to Groups.GroupingItemCount - 1 do
    AValues[I] := Null;
  // Load Values
  if (0 <= ARecordIndex) and (ARecordIndex < RecordCount) then
    for I := 0 to Groups.GroupingItemCount - 1 do
      AValues[I] := GetGroupValue(ARecordIndex, Fields[Groups.GroupingItemIndex[I]]);
end;

function TcxCustomDataController.GetDisplayText(ARecordIndex, AItemIndex: Integer): string;
begin
  CheckRange(ARecordIndex, AItemIndex);
  Result := GetInternalDisplayText(ARecordIndex, Fields[AItemIndex]);
end;

function TcxCustomDataController.GetRecordCount: Integer;
begin
{  if IsProviderMode then
    Result := Provider.GetRecordCount
  else}
    Result := DataStorage.RecordCount;
end;

function TcxCustomDataController.GetRecordId(ARecordIndex: Integer): Variant;
begin
  if not ((0 <= ARecordIndex) and (ARecordIndex < RecordCount)) then
    InvalidOperation(cxSDataRecordIndexError);
  if IsRecordID then
    Result := DataStorage.GetRecordID(ARecordIndex)
  else
  begin
    if IsProviderMode and Provider.IsRecordIdSupported then
      Result := Provider.GetRecordId(ARecordIndex)
    else
      Result := Null;
  end;    
end;

function TcxCustomDataController.GetValue(ARecordIndex, AItemIndex: Integer): Variant;
begin
  CheckRange(ARecordIndex, AItemIndex);
  Result := GetInternalValue(ARecordIndex, Fields[AItemIndex]);
end;

function TcxCustomDataController.InsertRecord(ARecordIndex: Integer): Integer;

  function DataStorageInsertRecord(ARecordIndex: Integer): Integer;
  begin
    Result := ARecordIndex;
    DataStorage.InsertRecord(ARecordIndex);
    CorrectAfterInsert(ARecordIndex);
    DataChanged(dcNew, -1, -1);
  end;

begin
  if (ARecordIndex < 0) or (ARecordIndex > RecordCount) then
    InvalidOperation(cxSDataRecordIndexError);
  if IsSmartLoad then
    Result := AppendInSmartLoad
  else
    if IsProviderMode then
      Result := Provider.InsertRecord(ARecordIndex)
    else
      Result := DataStorageInsertRecord(ARecordIndex);
end;

procedure TcxCustomDataController.Refresh;
begin
  BeginUpdate;
  try
    DataControllerInfo.Refresh;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataController.SetDisplayText(ARecordIndex, AItemIndex: Integer;
  const Value: string);
begin
  if IsGridMode then Exit;
  CheckRange(ARecordIndex, AItemIndex);
  if IsProviderMode and (ARecordIndex >= 0) then
  begin
    Provider.SetDisplayText(ARecordIndex, Fields[AItemIndex], Value);
    DataChanged(dcField, AItemIndex, ARecordIndex);
  end
  else
  begin
    if Fields[AItemIndex].ValueDef <> nil then
    begin
      DataStorage.SetDisplayText(ARecordIndex, Fields[AItemIndex].ValueDef, Value);
      DataChanged(dcField, AItemIndex, ARecordIndex);
    end;
  end;
end;

procedure TcxCustomDataController.SetRecordCount(Value: Integer);

  procedure SetDataStorageRecordCount;
  const
    DataChangeA: array[Boolean] of TcxDataChange = (dcDeleted , dcNew);
  var
    PrevRecordCount, RealRecordCount: Integer;
  begin
    PrevRecordCount := DataStorage.RecordCount;
    DataStorage.RecordCount := Value;
    RealRecordCount := DataStorage.RecordCount;
    if RealRecordCount <> PrevRecordCount then
    begin
      CheckSelectedCount(-1);
      CheckEditingRecordIndex(-1);
      DataChanged(DataChangeA[RealRecordCount > PrevRecordCount], -1, -1);
    end;
  end;

begin
  if IsGridMode then Exit;
  if Value < 0 then Value := 0;
  if RecordCount <> Value then
  begin
    if IsProviderMode then
      Provider.SetRecordCount(Value)
    else
      SetDataStorageRecordCount;
  end;
end;

procedure TcxCustomDataController.SetValue(ARecordIndex, AItemIndex: Integer; const Value: Variant);
begin
  if IsGridMode then Exit;
  CheckRange(ARecordIndex, AItemIndex);
  if IsProviderMode and (ARecordIndex >= 0) then
  begin
    Provider.SetValue(ARecordIndex, Fields[AItemIndex], Value);
    DataChanged(dcField, AItemIndex, ARecordIndex);
  end
  else
  begin
    if Fields[AItemIndex].ValueDef <> nil then
    begin
      SetStoredValue(ARecordIndex, Fields[AItemIndex], Value);
//      DataStorage.SetValue(ARecordIndex, Fields[AItemIndex].ValueDef, Value);
      DataChanged(dcField, AItemIndex, ARecordIndex);
    end;
  end;
end;

procedure TcxCustomDataController.SortByDisplayTextChanged;
begin
//  if dcoSortByDisplayText in Options then
    Refresh;
end;

// Data Editing

procedure TcxCustomDataController.Append;
begin
  if Provider.CanAppend then
    Provider.Append;
end;

procedure TcxCustomDataController.Cancel;
var
  APrevRowIndex: Integer;
begin
  if FInCancel then Exit;
  FInCancel := True;
  try
    APrevRowIndex := FocusedRowIndex;
    if Provider.IsEditing then
      Provider.Cancel;
    if APrevRowIndex > (GetRowCount - 1) then
      APrevRowIndex := (GetRowCount - 1);
    if not DataControllerInfo.FInCanFocusedRowChanging then
      FocusedRowIndex := APrevRowIndex;
  finally
    FInCancel := False;
  end;
end;

function TcxCustomDataController.CanInitEditing(AItemIndex: Integer): Boolean;
begin
  Result := False;
  CheckItemRange(AItemIndex);
  if (Provider.CanModify or Fields[AItemIndex].IsUnbound) and
    Fields[AItemIndex].CanModify(GetItemValueSource(AItemIndex)) then
    Result := Provider.CanInitEditing(EditingRecordIndex);
end;

procedure TcxCustomDataController.CheckBrowseMode;
begin
end;

procedure TcxCustomDataController.DeleteFocused;
var
  AList: TList;
  ARowIndex: Integer;
begin
  ARowIndex := GetFocusedRowIndex;
  if (ARowIndex <> -1) and Provider.CanDelete then
  begin
    Provider.BeginDeleting;
    try
      if GetRowInfo(ARowIndex).Level < Groups.LevelCount then // It's Group Row
      begin
        AList := TList.Create;
        try
          Groups.LoadRecordIndexesByRowIndex(AList, ARowIndex);
          DeleteRecords(AList);
        finally
          AList.Free;
        end;
      end
      else
        DeleteFocusedRecord;
      ClearSelection; // !!!
    finally
      Provider.EndDeleting;
    end;
  end;
end;

procedure TcxCustomDataController.DeleteSelection;
begin
  if (GetSelectedCount > 0) and Provider.CanDelete then
  begin
    Provider.BeginDeleting;
    try
      if IsFocusedSelectedMode then
        DeleteFocusedRecord
      else
        Provider.DeleteSelection;
    finally
      Provider.EndDeleting;
    end;
  end;
end;

procedure TcxCustomDataController.Edit;
begin
  if Provider.CanModify then
    Provider.Edit;
end;

procedure TcxCustomDataController.FocusControl(AItemIndex: Integer; var Done: Boolean);
begin
  Done := False;
end;

function TcxCustomDataController.GetEditValue(AItemIndex: Integer;
  AEditValueSource: TcxDataEditValueSource): Variant;
begin
  CheckItemRange(AItemIndex);
  if UseNewItemRowForEditing and NewItemRowFocused and not Provider.IsEditing then
    Result := Null
  else
    Result := Provider.GetEditValue(EditingRecordIndex, Fields[AItemIndex], AEditValueSource);
end;

function TcxCustomDataController.GetItemValueSource(AItemIndex: Integer): TcxDataEditValueSource;
begin
  Result := evsText;
end;

procedure TcxCustomDataController.Insert;
begin
  if Provider.CanInsert then
    Provider.Insert;
end;

procedure TcxCustomDataController.Post(AForcePost: Boolean);
var
  ALink: TcxDataListenerLink;
begin
  ALink := AddListenerLink(Self);
  try
    FCheckFocusingAfterFilterNeeded := True;
    if Provider.IsEditing then
      Provider.Post(AForcePost);
  finally
    if ALink.Ref <> nil then
      Provider.FInsertedRecordIndex := -1;
    RemoveListenerLink(ALink);
  end;
end;

procedure TcxCustomDataController.PostEditingData;
begin
  Provider.PostEditingData;
end;

procedure TcxCustomDataController.RefreshExternalData;
begin
end;

function TcxCustomDataController.SetEditValue(AItemIndex: Integer;
  const AValue: Variant; AEditValueSource: TcxDataEditValueSource): Boolean;
begin
  if CanInitEditing(AItemIndex) then
    Result := Provider.SetEditValue(EditingRecordIndex, Fields[AItemIndex], AValue, AEditValueSource)
  else
    Result := False;
  // Immediate Post
  if Result and IsImmediatePost then
    Post;
end;

procedure TcxCustomDataController.UpdateData;
begin
end;

// New Item Row

function TcxCustomDataController.GetEditingRecordIndex: Integer;
begin
  if Provider.FEditingRecordIndex <> cxNullEditingRecordIndex then
    Result := Provider.FEditingRecordIndex
  else
    Result := CalcEditingRecordIndex;
end;

function TcxCustomDataController.GetNewItemRecordIndex: Integer;
begin
  if FNewItemRecordIndex = 0 then
    FNewItemRecordIndex := DataStorage.AddInternalRecord;
  Result := FNewItemRecordIndex;   
end;

// Data Save/Load

procedure TcxCustomDataController.LoadFromStream(AStream: TStream);
var
  S: AnsiString;
  I, AValueCount, ADataValueCount: Integer;
  AValueDef: TcxValueDef;
  AReader: TcxReader;
begin
  if IsProviderMode then
    InvalidOperation(cxSDataProviderModeError);
  AReader := TcxReader.Create(AStream);
  try
    if AReader.ReadAnsiString <> stDataControllerSignature then
      InvalidOperation(cxSDataInvalidStreamFormat);
    // ValueCount
    AValueCount := AReader.ReadInteger;
    // ValueDefs
//    if AValueCount > 0 then
    begin
      ADataValueCount := 0;
      for I := 0 to DataStorage.ValueDefs.Count - 1 do
      begin
        AValueDef := DataStorage.ValueDefs[I];
        AValueDef.StreamStored := not IsValueDefInternal(AValueDef);
        if AValueDef.StreamStored then
          Inc(ADataValueCount);
      end;
      if ADataValueCount <> AValueCount then
        InvalidOperation(cxSDataInvalidStreamFormat);

      DataStorage.BeginStreaming(CompareByLinkObject);
      try
        // ValueDefs
        for I := 0 to DataStorage.ValueDefs.Count - 1 do
        begin
          AValueDef := DataStorage.ValueDefs[I];
          if AValueDef.StreamStored then
          begin
            ReadAnsiStringProc(AStream, S);
            if AValueDef.ValueTypeClass.ClassName <> dxAnsiStringToString(S) then
              InvalidOperation(cxSDataInvalidStreamFormat);
          end;
        end;
        BeginUpdate;
        try
          ClearSelection;
          // RecordCount
          RecordCount := AReader.ReadInteger;
          // Records
          for I := 0 to RecordCount - 1 do
            DataStorage.ReadData(I, AStream);
          DataControllerInfo.Refresh;
        finally
          EndUpdate;
        end;
      finally
        DataStorage.EndStreaming;
      end;
    end;
  finally
    AReader.Free;
  end;
end;

procedure TcxCustomDataController.SaveToStream(AStream: TStream);
var
  I, AValueCount: Integer;
  AValueDef: TcxValueDef;
  AWriter: TcxWriter;
begin
  AWriter := TcxWriter.Create(AStream);
  try
    AWriter.WriteAnsiString(stDataControllerSignature);
    // ValueCount
    AValueCount := 0;
    if not IsProviderMode then
    begin
      for I := 0 to DataStorage.ValueDefs.Count - 1 do
      begin
        AValueDef := DataStorage.ValueDefs[I];
        AValueDef.StreamStored := not IsValueDefInternal(AValueDef);
        if AValueDef.StreamStored then
          Inc(AValueCount);
      end;
    end;
    AWriter.WriteInteger(AValueCount);
//    if AValueCount > 0 then
    begin
      DataStorage.BeginStreaming(CompareByLinkObject);
      try
        // ValueDefs
        for I := 0 to DataStorage.ValueDefs.Count - 1 do
        begin
          AValueDef := DataStorage.ValueDefs[I];
          if AValueDef.StreamStored then
            AWriter.WriteAnsiString(dxStringToAnsiString(AValueDef.ValueTypeClass.ClassName));
        end;    
        // RecordCount
        AWriter.WriteInteger(RecordCount);
        // Records
        for I := 0 to RecordCount - 1 do
          DataStorage.WriteData(I, AStream);
      finally
        DataStorage.EndStreaming;
      end;
    end;
  finally
    AWriter.Free;
  end;
end;

// Master-Detail: Relations

function TcxCustomDataController.GetMasterDataController: TcxCustomDataController;
var
  AMasterRelation: TcxCustomDataRelation;
begin
  AMasterRelation := GetMasterRelation;
  if AMasterRelation <> nil then
    Result := AMasterRelation.DataController
  else
    Result := nil;
end;

function TcxCustomDataController.GetMasterRecordIndex: Integer;
begin
  Result := FMasterRecordIndex;
end;

function TcxCustomDataController.GetMasterRelation: TcxCustomDataRelation;
begin
  Result := FMasterRelation;
end;

function TcxCustomDataController.GetPatternDataController: TcxCustomDataController;

  function FindByItem(ADataController: TcxCustomDataController; AItem: TObject): TcxCustomDataController;
  var
    I: Integer;
    ARelation: TcxCustomDataRelation;
  begin
    ARelation := ADataController.Relations.FindByItem(AItem);
    if ARelation <> nil then
      Result := ARelation.DetailDataController
    else
    begin
      Result := nil;
      for I := 0 to ADataController.Relations.Count - 1 do
        if ADataController.Relations[I].DetailDataController <> nil then
        begin
          Result := FindByItem(ADataController.Relations[I].DetailDataController, AItem);
          if Result <> nil then
            Break;
        end;
    end;
  end;

begin       
  if FMasterRelation <> nil then
    Result := FindByItem(GetRootDataController, FMasterRelation.Item)
  else
    Result := Self;  
end;

function TcxCustomDataController.GetRootDataController: TcxCustomDataController;
begin
  Result := Self;
  while Result.FMasterRelation <> nil do
    Result := Result.FMasterRelation.DataController;
end;

function TcxCustomDataController.IsDetailMode: Boolean;
begin
  Result := (FMasterRelation <> nil);
end;

function TcxCustomDataController.CreateDetailLinkObject(ARelation: TcxCustomDataRelation; ARecordIndex: Integer): TObject;
begin
  Result := nil;
end;

procedure TcxCustomDataController.FocusDetails(ARecordIndex: Integer);
var
  I: Integer;
  ADataController: TcxCustomDataController;
begin
  for I := 0 to Relations.Count - 1 do
    if IsDetailDataControllerExist(ARecordIndex, I) and
      (GetDetailActiveRelationIndex(ARecordIndex) = I) then
    begin
      ADataController := GetDetailDataController(ARecordIndex, I);
      ADataController.CheckFocusedRow;
      Break;
    end;
end;

function TcxCustomDataController.GetDetailDataControllerByLinkObject(ALinkObject: TObject): TcxCustomDataController;
begin
  Result := nil;
end;

// Master-Detail: Grid Notifications

procedure TcxCustomDataController.ResetRelationByItem(AItem: TObject);

  procedure FindAndReset(ADataController: TcxCustomDataController); // TODO: ref FindAndReset + FindAndRemove
  var
    I, J: Integer;
    ARelation: TcxCustomDataRelation;
  begin
    with ADataController do
    begin
      ARelation := Relations.FindByItem(AItem);
      if ARelation <> nil then
        ClearDetails
      else
      begin
        for I := 0 to DataStorage.RecordCount - 1 do
          for J := 0 to Relations.Count - 1 do
          begin
            if IsDetailDataControllerExist(I, J) then
              FindAndReset(GetDetailDataController(I, J));
          end;
      end;
    end;
  end;

begin
  FindAndReset(Self);
end;

procedure TcxCustomDataController.SetMasterMode(AMasterRelation: TcxCustomDataRelation; AIsPattern: Boolean);
begin
  BeginFullUpdate;
  try
    SetMasterRelation(AMasterRelation, -1);
    IsPattern := AIsPattern;
  finally
    EndFullUpdate;
  end;
end;

procedure TcxCustomDataController.SetMasterRelation(AMasterRelation: TcxCustomDataRelation;
  AMasterRecordIndex: Integer);
begin
  if (AMasterRelation = nil) and (FMasterRelation = nil) and
    (AMasterRecordIndex = -1) and (FMasterRecordIndex = -1) then
    Exit;
  BeginUpdate;
  try
    if FMasterRelation <> nil then
    begin
      if (FMasterRelation.FDetailDataController = Self) and (AMasterRecordIndex = -1) then // It's Pattern
        FMasterRelation.FDetailDataController := nil
      else
        CustomDataSource := nil;
      if (FMasterRelation <> nil) and (FMasterRelation.DataController <> nil) and
        (FMasterRelation.DataController.FCreatingDataController = Self) then
        FMasterRelation.DataController.FCreatingDataController := nil;
      Relations.Changed(nil); // Reset Details
    end;
    FMasterRelation := AMasterRelation;
    if (FMasterRelation <> nil) and (AMasterRecordIndex = -1) then // It's Pattern
    begin
      FMasterRelation.FDetailDataController := Self;
      FMasterRelation.Changed;
    end;
    if (FMasterRelation <> nil) and (AMasterRecordIndex <> -1) then // Isn't Pattern
    begin
      CustomDataSource := GetPatternDataController.CustomDataSource;
      if (FMasterRelation <> nil) and (FMasterRelation.DataController <> nil) then
        FMasterRelation.DataController.FCreatingDataController := Self;
    end;
    FMasterRecordIndex := AMasterRecordIndex;
    LayoutChanged([lcData]);
  finally
    EndUpdate;
  end;
end;

// Master-Detail: View Data

procedure TcxCustomDataController.ChangeDetailActiveRelationIndex(ARecordIndex: Integer; ARelationIndex: Integer);
var
  ADetailObject: TcxDetailObject;
begin
  if GetDetailActiveRelationIndex(ARecordIndex) <> ARelationIndex then
  begin
    CheckBrowseMode;
    ADetailObject := Relations.GetDetailObject(ARecordIndex);
    if Assigned(ADetailObject) then
    begin
      ADetailObject.ActiveRelationIndex := ARelationIndex;
      Change([dccDetail]);
    end;
  end;
end;

function TcxCustomDataController.ChangeDetailExpanding(ARecordIndex: Integer;
  AExpanded: Boolean): Boolean;
var
  ADetailObject: TcxDetailObject;
begin
  if GetDetailExpanding(ARecordIndex) <> AExpanded then
  begin
    Result := False;
    FIsDetailExpanding := True;
    try
      CheckBrowseMode;
      if (0 <= ARecordIndex) and (ARecordIndex < RecordCount) then
      begin
        ADetailObject := Relations.GetDetailObject(ARecordIndex);
        if Assigned(ADetailObject) and CanChangeDetailExpanding(ARecordIndex, AExpanded) then
        begin
          ADetailObject.Expanded := AExpanded;
          Result := True;
          if (GetMasterDataController = nil) or (GetMasterDataController.LockCount = 0) then
            Change([dccDetail]);
          if AExpanded then
            DoDetailExpanded(ARecordIndex)
          else
            DoDetailCollapsed(ARecordIndex);
        end;
      end;
    finally
      FIsDetailExpanding := False;
    end;
  end
  else
    Result := True;
end;

procedure TcxCustomDataController.ClearDetailLinkObject(ARecordIndex: Integer; ARelationIndex: Integer);
begin
  if Relations.ClearDetailObject(ARecordIndex, ARelationIndex) then
    Change([dccDetail]);
end;

procedure TcxCustomDataController.ClearDetails;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to DataStorage.RecordCount - 1 do
      ClearDetailLinkObject(I, -1);
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataController.CollapseDetails;
var
  I: Integer;
  ADetailObject: TcxDetailObject;
begin
  CheckBrowseMode;
  BeginUpdate;
  try
    for I := 0 to DataStorage.RecordCount - 1 do
    begin
      ClearDetailLinkObject(I, -1);
      ADetailObject := Relations.GetDetailObject(I);
      if Assigned(ADetailObject) then
      begin
        ADetailObject.Expanded := False;
        Change([dccDetail]);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataController.ForEachDetail(AMasterRelation: TcxCustomDataRelation;
  AProc: TcxDataControllerEachDetailProc);
var
  ARelationIndexes: TList;

  procedure ForEach(ADataController: TcxCustomDataController; AIndex: Integer);
  var
    ARelationIndex, I: Integer;
    ADetailDataController: TcxCustomDataController;
  begin
    ARelationIndex := Integer(ARelationIndexes[AIndex]);
    with ADataController do
    begin
      for I := 0 to DataStorage.RecordCount - 1 do
      begin
        if IsDetailDataControllerExist(I, ARelationIndex) then
          ADetailDataController := GetDetailDataController(I, ARelationIndex)
        else
          if FCreatingDataController <> nil then
            ADetailDataController := FCreatingDataController
          else
            ADetailDataController := nil;
        if ADetailDataController <> nil then
        begin
          if AIndex = (ARelationIndexes.Count - 1) then
            AProc(ADetailDataController)
          else
            ForEach(ADetailDataController, AIndex + 1);
        end;
      end;
    end;
  end;

var
  ARootDataController: TcxCustomDataController;
begin
  ARelationIndexes := TList.Create;
  try
    ARootDataController := nil;
    while AMasterRelation <> nil do
    begin
      ARootDataController := AMasterRelation.DataController; 
      ARelationIndexes.Insert(0, Pointer(AMasterRelation.Index));
      AMasterRelation := ARootDataController.FMasterRelation;
    end;
    if ARootDataController <> nil then
      ForEach(ARootDataController, 0);
  finally
    ARelationIndexes.Free;
  end;
end;

function TcxCustomDataController.GetDetailActiveRelationIndex(ARecordIndex: Integer): Integer;
var
  ADetailObject: TcxDetailObject;
begin
  Result := -1;
  if Relations.IsEmpty then Exit;
  ADetailObject := Relations.GetDetailObject(ARecordIndex);
  if Assigned(ADetailObject) then
    Result := ADetailObject.ActiveRelationIndex;
end;

function TcxCustomDataController.GetDetailDataController(ARecordIndex: Integer; ARelationIndex: Integer): TcxCustomDataController;
begin
  Result := GetDetailDataControllerByLinkObject(GetDetailLinkObject(ARecordIndex, ARelationIndex));
end;

function TcxCustomDataController.GetDetailExpanding(ARecordIndex: Integer): Boolean;
var
  ADetailObject: TcxDetailObject;
begin
  ADetailObject := Relations.GetDetailObject(ARecordIndex);
  if Assigned(ADetailObject) then
    Result := ADetailObject.Expanded
   else
    Result := False;
{
if Result then
  if (Relations.Count > 0) and (Relations[0].DataController.GetPatternDataController.Relations[0].FDetailDataController = nil) then
  begin
    Result := False;
    Exit;
  end;
  }
end;

function TcxCustomDataController.GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean;
var
  AIsBound: Boolean;
  ADetailObject: TcxDetailObject;
  AInfoObject: TcxDetailInfoObject;
begin
  // TODO: DB!!!
  AIsBound := IsDataBound;
  if IsDetailDataControllerExist(ARecordIndex, ARelationIndex) then
    Result := GetDetailDataController(ARecordIndex, ARelationIndex).RecordCount <> 0
  else
  begin
    Result := AIsBound;
    if AIsBound then
    begin
      ADetailObject := Relations.GetDetailObject(ARecordIndex);
      if Assigned(ADetailObject) then
      begin
        AInfoObject := ADetailObject.InfoObjects[ARelationIndex];
        if AInfoObject = nil then
        begin
          AInfoObject := TcxDetailInfoObject.Create;
          ADetailObject.InfoObjects[ARelationIndex] := AInfoObject;
        end;
        if not AInfoObject.HasChildrenAssigned then
        begin
          AInfoObject.HasChildren := Provider.GetDetailHasChildren(ARecordIndex, ARelationIndex);
          AInfoObject.HasChildrenAssigned := True;
        end;  
        Result := AInfoObject.HasChildren;
      end;
    end;
  end;
end;

function TcxCustomDataController.GetDetailLinkObject(ARecordIndex: Integer; ARelationIndex: Integer): TObject;

  function IsDetailObjectDestroyed(ADetailObject: TcxDetailObject): Boolean;
  begin
    // dataset in edit mode
    Result := not ((0 <= ARecordIndex) and (ARecordIndex < RecordCount) and
      (ADetailObject = Relations.GetDetailObject(ARecordIndex)));
  end;

var
  ADetailObject: TcxDetailObject;
begin
  ADetailObject := Relations.GetDetailObject(ARecordIndex);
  if Assigned(ADetailObject) then
  begin
    Result := ADetailObject.LinkObjects[ARelationIndex];
    if Result = nil then
    begin
      if FCreatingLinkObject then Exit;
      FCreatingLinkObject := True;
      if GetPatternDataController <> nil then
        GetPatternDataController.FCreatingLinkObject := True;
      try
        Result := CreateDetailLinkObject(Relations[ARelationIndex], ARecordIndex);
        FCreatingDataController := nil; // !!!
        if IsDetailObjectDestroyed(ADetailObject) then
        begin
          Result.Free;
          Result := nil;
          // DataNotify
        end                    
        else
          ADetailObject.LinkObjects[ARelationIndex] := Result;
      finally
        if GetPatternDataController <> nil then
          GetPatternDataController.FCreatingLinkObject := False;
        FCreatingLinkObject := False;
      end;
    end;
    if (Result = nil) and not FRecreatingLinkObject then // recreate DetailObject
    begin
      FRecreatingLinkObject := True;
      try
        Result := GetDetailLinkObject(ARecordIndex, ARelationIndex);
      finally
        FRecreatingLinkObject := False;
      end;
    end;
  end
  else
    Result := nil;
end;                                

function TcxCustomDataController.IsDetailDataControllerExist(ARecordIndex: Integer; ARelationIndex: Integer): Boolean;
begin
  Result := Relations.IsDetailObjectExist(ARecordIndex, ARelationIndex);
end;

procedure TcxCustomDataController.ResetHasChildrenFlag;
var
  I: Integer;
  ADetailObject: TcxDetailObject;
  AChanged: Boolean;
begin
  AChanged := False;
  for I := 0 to RecordCount - 1 do
  begin
    ADetailObject := Relations.GetDetailObject(I);
    if Assigned(ADetailObject) then
    begin
      if ADetailObject.ClearHasChildrenFlag then
        AChanged := True;
    end;  
  end;
  if AChanged then
    Change([dccLayout]);
end;

// View Data

procedure TcxCustomDataController.ForEachRow(ASelectedRows: Boolean; AProc: TcxDataControllerEachRowProc);
var
  I, J: Integer;
begin
  if ASelectedRows then
  begin
    for I := 0 to GetSelectedCount - 1 do
    begin
      J := GetSelectedRowIndex(I);
      AProc(J, GetRowInfo(J));
    end;  
  end
  else
  begin
    for I := 0 to GetRowCount - 1 do
      AProc(I, GetRowInfo(I));
  end;
end;

function TcxCustomDataController.GetNearestRowIndex(ARowIndex: Integer): Integer;
begin
  Result := DataControllerInfo.GetNearestRowIndex(ARowIndex);
end;

function TcxCustomDataController.GetRowCount: Integer;
begin
  Result := DataControllerInfo.GetRowCount;
end;

function TcxCustomDataController.GetRowIndexByRecordIndex(ARecordIndex: Integer;
  AMakeVisible: Boolean): Integer;
begin
  CheckRecordRange(ARecordIndex);
  Result := DataControllerInfo.GetRowIndexByRecordIndex(ARecordIndex, AMakeVisible);
end;

function TcxCustomDataController.GetRowInfo(ARowIndex: Integer): TcxRowInfo;
begin
  Result := DataControllerInfo.GetRowInfo(ARowIndex);
end;

function TcxCustomDataController.GetRowDisplayText(const ARowInfo: TcxRowInfo;
  var AItemIndex: Integer): string;
begin
  if (ARowInfo.RecordIndex <> NewItemRecordIndex) and (ARowInfo.Level < Groups.GetGroupingItemCount) then
    AItemIndex := Groups.GetGroupingItemIndex(ARowInfo.Level);
  Result := GetDisplayText(ARowInfo.RecordIndex, AItemIndex);
end;

function TcxCustomDataController.GetRowValue(const ARowInfo: TcxRowInfo; AItemIndex: Integer): Variant;
begin
  if (ARowInfo.RecordIndex <> NewItemRecordIndex) and (ARowInfo.Level < Groups.GetGroupingItemCount) then
    AItemIndex := Groups.GetGroupingItemIndex(ARowInfo.Level);
  Result := GetValue(ARowInfo.RecordIndex, AItemIndex);
end;

procedure TcxCustomDataController.MakeRecordVisible(ARecordIndex: Integer);
begin
  GetRowIndexByRecordIndex(ARecordIndex, True);
end;

function TcxCustomDataController.FocusSelectedRow(ASelectedIndex: Integer): Boolean;
var
  ARowIndex: Integer;
begin
  ARowIndex := GetSelectedRowIndex(ASelectedIndex);
  FocusedRowIndex := ARowIndex;
  Result := FocusedRowIndex = ARowIndex;
end;

procedure TcxCustomDataController.RestoreDataSetPos;
begin
  Provider.RestorePos;
end;

procedure TcxCustomDataController.SaveDataSetPos;
begin
  Provider.SavePos;
end;

// Navigation

procedure TcxCustomDataController.ChangeFocusedRecordIndex(ARecordIndex: Integer);
var
  ARowIndex: Integer;
begin
  ARowIndex := GetRowIndexByRecordIndex(ARecordIndex, True);
  ChangeFocusedRowIndex(ARowIndex);
end;

function TcxCustomDataController.ChangeFocusedRowIndex(ARowIndex: Integer): Boolean;
var
  AIsFocusedRowIndexChanging: Boolean;
begin
  Result := False;
  if Provider.IsSyncMode and not Provider.FInInserting and
    (DataControllerInfo.FocusedRowIndex <> ARowIndex) and not CheckMasterBrowseMode then
    Exit;
  if DataControllerInfo.FocusedRowIndex <> ARowIndex then
    CheckDetailsBrowseMode;

  AIsFocusedRowIndexChanging := DataControllerInfo.FocusedRowIndex <> ARowIndex;
  DataControllerInfo.FocusedRowIndex := ARowIndex;
  // TODO: check
  if AIsFocusedRowIndexChanging and Provider.IsSyncMode and SyncDetailsFocusWithMaster and
    (FocusedRecordIndex <> -1) then
  begin
    FInFocusDetails := True;
    try
      FocusDetails(FocusedRecordIndex);
    finally
      FInFocusDetails := False;
    end;
  end;
  Result := True;
end;

procedure TcxCustomDataController.CheckFocusedRow;
begin
  if (FocusedRowIndex = -1) and not NewItemRowFocused then
    FocusedRowIndex := 0;
end;

function TcxCustomDataController.GetFocusedRecordIndex: Integer;
begin
  Result := DataControllerInfo.FocusedRecordIndex;
end;

function TcxCustomDataController.GetFocusedRowIndex: Integer;
begin
  Result := DataControllerInfo.FocusedRowIndex;
end;

procedure TcxCustomDataController.GotoFirst;
begin
  if IsGridMode then
    Provider.First
  else
    ChangeFocusedRowIndex(0);
end;

procedure TcxCustomDataController.GotoLast;
begin
  if IsGridMode then
    Provider.Last
  else
    ChangeFocusedRowIndex(GetRowCount - 1);
end;

procedure TcxCustomDataController.GotoNext;
var
  AFocusedRowIndex: Integer;
begin
  if IsGridMode then
    Provider.Next
  else
  begin
    AFocusedRowIndex := GetFocusedRowIndex + 1;
    ChangeFocusedRowIndex(AFocusedRowIndex);
  end;
end;

procedure TcxCustomDataController.GotoPrev;
var
  AFocusedRowIndex: Integer;
begin
  if IsGridMode then
    Provider.Prev
  else
  begin
    AFocusedRowIndex := GetFocusedRowIndex - 1;
    if AFocusedRowIndex < 0 then AFocusedRowIndex := 0;
    ChangeFocusedRowIndex(AFocusedRowIndex);
  end;  
end;

function TcxCustomDataController.IsBOF: Boolean;
begin
  if IsGridMode {and not Provider.IsInserting} then
    Result := Provider.IsBOF
  else
    Result := (GetFocusedRowIndex = 0) or (GetRowCount = 0);
end;

function TcxCustomDataController.IsEOF: Boolean;
var
  ARowCount: Integer;
begin
  if IsGridMode then
    Result := Provider.IsEOF
  else
  begin
    ARowCount := GetRowCount;
    Result := (ARowCount = 0) or
      ({(ARowCount > 1) and} (GetFocusedRowIndex = (ARowCount - 1)));
  end;  
end;

function TcxCustomDataController.IsGridMode: Boolean;
begin
  Result := Provider.IsGridMode;
end;

procedure TcxCustomDataController.MoveBy(ADistance: Integer);
var
  ARowIndex: Integer;
begin
  if IsGridMode then
    Provider.MoveBy(ADistance)
  else
  begin
    ARowIndex := GetFocusedRowIndex + ADistance;
    if ARowIndex < 0 then ARowIndex := 0;
    ChangeFocusedRowIndex(ARowIndex);
  end;  
end;

procedure TcxCustomDataController.Scroll(ADistance: Integer);
begin
  if IsGridMode then
    Provider.Scroll(ADistance);
end;

procedure TcxCustomDataController.SetFocus;
begin
end;

procedure TcxCustomDataController.ClearBookmark;
var
  APrevBookmarkAvailable: Boolean;
begin
  APrevBookmarkAvailable := IsBookmarkAvailable;
  InternalClearBookmark;
  if IsBookmarkAvailable <> APrevBookmarkAvailable then
    Change([dccBookmark]);
end;

procedure TcxCustomDataController.GotoBookmark;
begin
  if IsBookmarkAvailable then
    InternalGotoBookmark;
end;

function TcxCustomDataController.IsBookmarkAvailable: Boolean;
begin
  Result := FBookmarkRecordIndex <> -1;
end;

function TcxCustomDataController.IsBookmarkRow(ARowIndex: Integer): Boolean;
begin
  Result := IsBookmarkAvailable and
    (GetRowInfo(ARowIndex).RecordIndex = FBookmarkRecordIndex);
end;

procedure TcxCustomDataController.SaveBookmark;
begin
  if InternalSaveBookmark then
    Change([dccBookmark]);
end;

// Filtering

function TcxCustomDataController.GetFilterDataValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
begin
  Result := GetInternalValue(ARecordIndex, AField);
end;

function TcxCustomDataController.GetFilterItemFieldCaption(AItem: TObject): string;
begin
  Result := '';
end;

function TcxCustomDataController.GetFilterItemFieldName(AItem: TObject): string;
begin
  Result := GetFilterItemFieldCaption(AItem);
end;
       
// Search

function TcxCustomDataController.ChangeIncrementalFilterText(const AText: string): Boolean;
begin
  Result := Assigned(FIncrementalFilterField) and (FIncrementalFilterText <> AText);
  if Result then
    SetIncrementalFilter(FIncrementalFilterField.Index, AText);
end;

function TcxCustomDataController.FindRecordIndexByText(AStartRecordIndex, AItemIndex: Integer;
  const AText: string; APartialCompare, ACircular, AForward: Boolean): Integer;
var
  AField: TcxCustomDataField;
  ARecordCount: Integer;

  function Find(AStartIndex, AEndIndex: Integer): Integer;
  var
    I: Integer;
    S: string;
    ARecordIndex: Integer;
  begin
    Result := -1;
    I := AStartIndex;
    while (AForward and (I <= AEndIndex)) or
      (not AForward and (I >= AEndIndex)) do
    begin
      ARecordIndex := FilteredRecordIndex[I];
      S := GetInternalDisplayText(ARecordIndex, AField);
      if DataCompareText(S, AText, APartialCompare) then
      begin
        Result := ARecordIndex;
        Break;
      end;
      if AForward then
        Inc(I)
      else
        Dec(I);
    end;
  end;

begin
  CheckItemRange(AItemIndex);
  AField := Fields[AItemIndex];
  ARecordCount := FilteredRecordCount;
  Result := -1;
  if (AStartRecordIndex < 0) or (AStartRecordIndex >= ARecordCount) then Exit;
  if AForward then
  begin
    Result := Find(AStartRecordIndex, ARecordCount - 1);
    if (Result = -1) and (AStartRecordIndex <> 0) and ACircular then
      Result := Find(0, AStartRecordIndex - 1);
  end
  else
  begin
    Result := Find(AStartRecordIndex, 0);
    if (Result = -1) and (AStartRecordIndex <> 0) and ACircular then
      Result := Find(ARecordCount - 1, AStartRecordIndex + 1);
  end;
end;

function TcxCustomDataController.GetIncrementalFilterText: string;
begin
  Result := FIncrementalFilterText;
end;

function TcxCustomDataController.IsIncrementalFilter: Boolean;
begin
  Result := Assigned(FIncrementalFilterField) and (FIncrementalFilterText <> '');
end;

procedure TcxCustomDataController.ResetIncrementalFilter;
var
  AIsIncrementalFilter: Boolean;
begin
  AIsIncrementalFilter := IsIncrementalFilter;
  FIncrementalFilterField := nil;
  FIncrementalFilterText := '';
  if AIsIncrementalFilter and not (csDestroying in FOwner.ComponentState) then
    Refresh;
end;

function TcxCustomDataController.SetIncrementalFilter(AItemIndex: Integer;
  const AText: string): Integer;
begin
  CheckItemRange(AItemIndex);
  FIncrementalFilterField := Fields[AItemIndex];
  FIncrementalFilterText := AText;
  Refresh;
  if FilteredRecordCount > 0 then
    Result := FilteredRecordIndex[0]
  else
    Result := -1;
end;

// Sorting

procedure TcxCustomDataController.ChangeItemSortingIndex(AItemIndex: Integer; ASortingIndex: Integer);
begin
  CheckItemRange(AItemIndex);
  if GetItemSortingIndex(AItemIndex) <> ASortingIndex then
  begin
    BeginUpdate;
    try
      if (Groups.ItemGroupIndex[AItemIndex] <> -1) and
        (GetItemSortOrder(AItemIndex) = soAscending) and
        (ASortingIndex = -1) then
        ChangeSorting(AItemIndex, soNone)
      else
      begin
        if GetItemSortingIndex(AItemIndex) = -1 then // grouped
          ChangeSorting(AItemIndex, GetItemSortOrder(AItemIndex));
        if GetItemSortOrder(AItemIndex) <> soNone then
          DataControllerInfo.ChangeSortIndex(Fields[AItemIndex], ASortingIndex);
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataController.ChangeSorting(AItemIndex: Integer; ASortOrder: TcxDataSortOrder);
begin
  CheckItemRange(AItemIndex);
//  if GetItemSortOrder(AItemIndex) <> ASortOrder then
  if DataControllerInfo.SortingFieldList.SortOrderByField(Fields[AItemIndex]) <> ASortOrder then
  begin
    BeforeSorting;
    FSortingChanged := True;
    DataControllerInfo.ChangeSorting(Fields[AItemIndex], ASortOrder);
  end;
end;

procedure TcxCustomDataController.ClearSorting(AKeepGroupedItems: Boolean);
begin
  DataControllerInfo.ClearSorting(AKeepGroupedItems);
end;

function TcxCustomDataController.GetItemSortByDisplayText(AItemIndex: Integer;
  ASortByDisplayText: Boolean): Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.GetItemSortOrder(AItemIndex: Integer): TcxDataSortOrder;
var
  I: Integer;
begin
  CheckItemRange(AItemIndex);
  I := DataControllerInfo.SortingFieldList.SortIndexByField(Fields[AItemIndex]);
  if I <> -1 then
    Result := DataControllerInfo.SortingFieldList[I].SortOrder
  else
  begin
    I := DataControllerInfo.GroupingFieldList.SortIndexByField(Fields[AItemIndex]);
    if I <> -1 then
      Result := DataControllerInfo.GroupingFieldList[I].SortOrder
    else
      Result := soNone;
  end;
//  Result := DataControllerInfo.TotalSortingFieldList.SortOrderByField(Fields[AItemIndex]);
end;

function TcxCustomDataController.GetItemSortingIndex(AItemIndex: Integer): Integer;
begin
  CheckItemRange(AItemIndex);
  Result := DataControllerInfo.SortingFieldList.SortIndexByField(Fields[AItemIndex]);
end;

function TcxCustomDataController.GetSortingItemCount: Integer;
begin
  Result := DataControllerInfo.SortingFieldList.Count;
end;

function TcxCustomDataController.GetSortingItemIndex(Index: Integer): Integer;
begin
  Result := DataControllerInfo.SortingFieldList[Index].Field.Index;
end;

// MultiSelect

procedure TcxCustomDataController.ChangeRowSelection(ARowIndex: Integer; ASelection: Boolean);
begin
  if not MultiSelect then Exit;
  DataControllerInfo.ChangeRowSelection(ARowIndex, ASelection);
end;

procedure TcxCustomDataController.CheckFocusedSelected;
var
  ARowIndex: Integer;
begin
  if not MultiSelect then Exit;
  BeginUpdate;
  try
    ClearSelection;
    ARowIndex := GetFocusedRowIndex;
    if ARowIndex <> -1 then
      ChangeRowSelection(ARowIndex, True); 
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataController.ClearSelection;
begin
  DataControllerInfo.ClearSelection;
end;

procedure TcxCustomDataController.ClearSelectionAnchor;
begin
  DataControllerInfo.ClearSelectionAnchor;
end;

function TcxCustomDataController.GetRowId(ARowIndex: Integer): Variant;
begin
  Result := ARowIndex;
end;

function TcxCustomDataController.GetSelectedCount: Integer;
begin
  if IsFocusedSelectedMode then
  begin
    if FFocusedSelected and (GetFocusedRowIndex <> -1) then
      Result := 1
    else
      Result := 0;
  end
  else
    Result := DataControllerInfo.GetSelectedCount;
end;

function TcxCustomDataController.GetSelectedRowIndex(Index: Integer): Integer;
begin
  if IsFocusedSelectedMode then
  begin
    if FFocusedSelected and (Index = 0) then
      Result := GetFocusedRowIndex
    else
      Result := -1;
  end
  else
    Result := DataControllerInfo.GetSelectedRowIndex(Index);
end;

function TcxCustomDataController.GetSelectionAnchorRowIndex: Integer;
begin
  Result := DataControllerInfo.Selection.AnchorRowIndex;
end;

function TcxCustomDataController.IsRowSelected(ARowIndex: Integer): Boolean;
begin
  if IsFocusedSelectedMode then
    Result := FFocusedSelected and (GetFocusedRowIndex = ARowIndex) 
  else
    Result := DataControllerInfo.IsRowSelected(ARowIndex);
end;

function TcxCustomDataController.IsSelectionAnchorExist: Boolean;
begin
  Result := GetSelectionAnchorRowIndex <> -1;
end;

procedure TcxCustomDataController.SelectAll;
var
  ARowCount: Integer;
begin
  ARowCount := GetRowCount;
  if ARowCount > 0 then
    SelectRows(0, ARowCount - 1);
end;

procedure TcxCustomDataController.SelectRows(AStartRowIndex, AEndRowIndex: Integer);
var
  I: Integer;
begin
  if not MultiSelect then Exit;
  if AStartRowIndex > AEndRowIndex then
  begin
    I := AEndRowIndex;
    AEndRowIndex := AStartRowIndex;
    AStartRowIndex := I;
  end;
  BeginUpdate;
  try
    for I := AStartRowIndex to AEndRowIndex do
      ChangeRowSelection(I, True);
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomDataController.SelectFromAnchor(ARowIndex: Integer; AKeepSelection: Boolean);
var
  ASelectionAnchorRowIndex: Integer;
begin
  ASelectionAnchorRowIndex := GetSelectionAnchorRowIndex;
  if ASelectionAnchorRowIndex <> -1 then
  begin
    BeginUpdate;
    try
      if not AKeepSelection then
        ClearSelection;
      SelectRows(ASelectionAnchorRowIndex, ARowIndex);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataController.SetSelectionAnchor(ARowIndex: Integer);
begin
  // TODO: check?
  DataControllerInfo.CheckRowIndex(ARowIndex);
  DataControllerInfo.Selection.FAnchorRowIndex := ARowIndex;
end;

procedure TcxCustomDataController.SyncSelected(ASelected: Boolean);
var
  AFocusedRowIndex: Integer;
begin
  if not IsFocusedSelectedMode then Exit;
  if FFocusedSelected <> ASelected then
  begin
    FFocusedSelected := ASelected;
    AFocusedRowIndex := GetFocusedRowIndex;
    if AFocusedRowIndex <> -1 then
    begin
      FPrevSelectionChangedInfo.SelectedCount := 1;
      FPrevSelectionChangedInfo.RowIndex := AFocusedRowIndex;
      Change([dccSelection]);
    end;
  end;
end;

procedure TcxCustomDataController.SyncSelectionFocusedRecord;
var
  AFocusedRowIndex: Integer;
begin
  AFocusedRowIndex := GetFocusedRowIndex;
  if AFocusedRowIndex = -1 then
    ClearSelection
  else
  begin
    SetSelectionAnchor(AFocusedRowIndex);
    SelectFromAnchor(AFocusedRowIndex, False);
  end;
end;

// IUnknown

function TcxCustomDataController.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TcxCustomDataController._AddRef: Integer;
begin
  Result := -1;   // -1 indicates no reference counting is taking Position
end;

function TcxCustomDataController._Release: Integer;
begin
  Result := -1;   // -1 indicates no reference counting is taking Position
end;

// Based

function TcxCustomDataController.AddInternalField: TcxCustomDataField;
begin
  Result := GetFieldClass.Create(Fields);
  Result.IsInternal := True;
  Fields.Add(Result);
end;

function TcxCustomDataController.AddField: TcxCustomDataField;
begin
  Result := GetFieldClass.Create(Fields);
  Fields.Add(Result);
end;

function TcxCustomDataController.AppendInSmartLoad: Integer;
var
  AValueDefReader: TcxValueDefReader;
begin
  FInSmartLoad := True;
  try
    if IsProviderMode then
      Result := LoadRecord(CustomDataSource.AppendRecord)
    else
    begin
      AValueDefReader := Provider.GetValueDefReaderClass.Create;
      try
        Result := LoadRecord(AValueDefReader);
        DataChanged(dcNew, -1, -1);
      finally
        AValueDefReader.Free;
      end;
    end;
  finally
    FInSmartLoad := False;
  end;
end;

procedure TcxCustomDataController.BeforeSorting;
begin
  if IsEditing then
    Post; // !
end;

function TcxCustomDataController.CalcEditingRecordIndex: Integer;
begin
  if NewItemRowFocused then
    Result := NewItemRecordIndex
  else
    if GetFocusedRowIndex <> -1 then
      Result := GetRowInfo(GetFocusedRowIndex).RecordIndex
    else
      Result := cxNullEditingRecordIndex;
end;

function TcxCustomDataController.CanChangeDetailExpanding(ARecordIndex: Integer;
  AExpanded: Boolean): Boolean;
begin
  Result := True;
  if AExpanded then
    DoDetailExpanding(ARecordIndex, Result)
  else
    DoDetailCollapsing(ARecordIndex, Result);
end;

function TcxCustomDataController.CanFocusRecord(ARecordIndex: Integer): Boolean;
begin
  if not Provider.IsDataSource and (Provider.EditingRecordIndex <> ARecordIndex) then
    Post;
  Result := True;
end;

function TcxCustomDataController.CanSelectRow(ARowIndex: Integer): Boolean;
begin
  Result := True; // override in grid for Event
end;

procedure TcxCustomDataController.CheckChanges;
begin
  if LockCount = 0 then
  begin
    Unlocked;
    if FChanges <> [] then
    begin
      if FStructureChanged then
      begin
        FStructureChanged := False;
        LayoutChanged([lcStructure]);
      end;
      Update;
    end;
  end;
end;

procedure TcxCustomDataController.Change(AChanges: TcxDataControllerChanges);
begin
  FChanges := FChanges + AChanges;
  CheckChanges;
end;

procedure TcxCustomDataController.CheckBookmarkValid(ADeletedRecordIndex: Integer);
begin
  if not IsBookmarkAvailable then Exit;
  if InternalCheckBookmark(ADeletedRecordIndex) then
  begin
    InternalClearBookmark;
    Change([dccBookmark]);
  end;
end;

procedure TcxCustomDataController.CheckDataSetCurrent;
begin
end;

procedure TcxCustomDataController.CheckEditingRecordIndex(ARecordIndex: Integer);
begin
  if ((ARecordIndex >= 0) and (ARecordIndex <= Provider.EditingRecordIndex)) or
    (RecordCount <= Provider.EditingRecordIndex) then
    Provider.ResetEditing;
end;

procedure TcxCustomDataController.CheckInternalRecordRange(ARecordIndex: Integer);
begin
  if FNewItemRecordIndex = ARecordIndex then
    FNewItemRecordIndex := 0;
end;

procedure TcxCustomDataController.CheckItemRange(AItemIndex: Integer);
begin
  if not ((0 <= AItemIndex) and (AItemIndex < ItemCount)) then
    InvalidOperation(cxSDataItemIndexError);
end;

function TcxCustomDataController.CheckDetailsBrowseMode: Boolean;
var
  I, J: Integer;
  ADataController: TcxCustomDataController;
begin
  for I := 0 to RecordCount - 1 do
    for J := 0 to Relations.Count - 1 do
    begin
      if IsDetailDataControllerExist(I, J) then
      begin
        ADataController := GetDetailDataController(I, J);
        ADataController.CheckBrowseMode;
      end;
    end;
  Result := True;
end;

function TcxCustomDataController.CheckMasterBrowseMode: Boolean;
begin
  Result := True;
end;

procedure TcxCustomDataController.CheckMode;
var
  APrevGridMode: Boolean;
begin
  APrevGridMode := IsGridMode;
  Provider.FLoadAllNeeded := Groups.GroupingItemCount > 0;
  if APrevGridMode <> Provider.IsGridMode then
    RestructData;
end;

procedure TcxCustomDataController.CheckNearestFocusRow;
var
  ARecordIndex: Integer;
begin
  if FNearestRecordIndex <> -1  then // !!!
  begin
    if FNearestRecordIndex < RecordCount then
      ChangeFocusedRecordIndex(FNearestRecordIndex);
    Exit;
  end;

  if (LockCount = 0) and (GetFocusedRecordIndex = -1) then
  begin
    ARecordIndex := GetLastRecordIndex;
    ChangeFocusedRecordIndex(ARecordIndex);
  end;
end;

procedure TcxCustomDataController.CheckRange(ARecordIndex, AItemIndex: Integer);
begin
  CheckRecordRange(ARecordIndex);
  CheckItemRange(AItemIndex);
end;

procedure TcxCustomDataController.CheckRecordRange(ARecordIndex: Integer);
begin
  NewItemRecordIndex;
  if not (((0 <= ARecordIndex) and (ARecordIndex < RecordCount)) or
    (ARecordIndex = FNewItemRecordIndex) or (ARecordIndex = Provider.FSavedRecordIndex)) then
    InvalidOperation(cxSDataRecordIndexError);
end;

procedure TcxCustomDataController.CheckSelectedCount(ADeletedRecordIndex: Integer);
begin
  DataControllerInfo.TruncateSelection;
  CheckBookmarkValid(ADeletedRecordIndex);
end;

procedure TcxCustomDataController.ClearDataChangedListeners;
var
  I: Integer;
begin
  // TODO: TcxEventList?
  for I := 0 to FDataChangedListeners.Count - 1 do
    TNotifyEventItem(FDataChangedListeners[I]).Free;
  FDataChangedListeners.Clear;
end;

procedure TcxCustomDataController.ClearDetailsMasterRelation(ARelation: TcxCustomDataRelation);
var
  ARelationIndex, I: Integer;
  ADetailLinkObject: TObject;
begin
  // Relation Destroying
  ARelationIndex := ARelation.Index;
  for I := 0 to DataStorage.RecordCount - 1 do
    if IsDetailDataControllerExist(I, ARelationIndex) then
    begin
      ADetailLinkObject := GetDetailLinkObject(I, ARelationIndex);
      if ADetailLinkObject <> nil then
        GetDetailDataControllerByLinkObject(ADetailLinkObject).FMasterRelation := nil;
    end;
end;

procedure TcxCustomDataController.ProviderValueDefSetProc(AValueDef: TcxValueDef;
  AFromRecordIndex, AToRecordIndex: Integer; AValueDefReader: TcxValueDefReader);
var
  AField: TcxCustomDataField;
begin
  AField := TcxCustomDataField(AValueDef.LinkObject);
  if AField.IsValueDefInternal then Exit;
  Provider.SetValue(AToRecordIndex, AField, DataStorage.GetValue(AFromRecordIndex, AValueDef));
  if AValueDef.TextStored then
    Provider.SetDisplayText(AToRecordIndex, AField, DataStorage.GetDisplayText(AFromRecordIndex, AValueDef));
end;

procedure TcxCustomDataController.CopyRecord(AFromRecordIndex, AToRecordIndex: Integer);
var
  AValueDefReader: TcxValueDefRecordReader;
begin
  AValueDefReader := TcxValueDefRecordReader.Create(Self, AFromRecordIndex);
  try
    if IsProviderMode and (AToRecordIndex >= 0) then
      DataStorage.ReadRecordFrom(AFromRecordIndex, AToRecordIndex, AValueDefReader, ProviderValueDefSetProc)
    else
      DataStorage.ReadRecord(AToRecordIndex, AValueDefReader);
  finally
    AValueDefReader.Free;
  end;
  if AToRecordIndex >= 0 then // not internal
    DataChanged(dcRecord, -1, -1);
end;

procedure TcxCustomDataController.CorrectAfterInsert(ARecordIndex: Integer);
var
  I, J: Integer;
begin
  for I := ARecordIndex + 1 to DataStorage.RecordCount - 1 do
    for J := 0 to Relations.Count - 1 do
      if IsDetailDataControllerExist(I, J) then
        Inc(GetDetailDataController(I, J).FMasterRecordIndex);
end;

procedure TcxCustomDataController.CorrectAfterDelete(ARecordIndex: Integer);
var
  I, J: Integer;
begin
  if ARecordIndex < 0 then Exit;
  CheckEditingRecordIndex(ARecordIndex);
  if Relations.Count > 0 then
  begin
    for I := ARecordIndex {+ 1} to DataStorage.RecordCount - 1 do
      for J := 0 to Relations.Count - 1 do
        if IsDetailDataControllerExist(I, J) then
          Dec(GetDetailDataController(I, J).FMasterRecordIndex);
  end;
end;

procedure TcxCustomDataController.CorrectPrevSelectionChangedInfo;
begin
  if FPrevSelectionChangedInfo.SelectedCount = 1 then
  begin
    FPrevSelectionChangedInfo.SelectedCount := GetSelectedCount;
    if FPrevSelectionChangedInfo.SelectedCount = 1 then
      FPrevSelectionChangedInfo.RowIndex := GetSelectedRowIndex(0)
    else
      FPrevSelectionChangedInfo.RowIndex := -1;
    // TODO: flag reset?  
  end;
end;

procedure TcxCustomDataController.DeleteInSmartLoad(ARecordIndex: Integer);
begin
  if IsProviderMode then
    Provider.DeleteRecord(ARecordIndex);
  DataStorage.DeleteRecord(ARecordIndex);
end;

procedure TcxCustomDataController.Unlocked;
begin
end;

procedure TcxCustomDataController.DoAfterCancel;
begin
  if Assigned(FOnAfterCancel) then
    FOnAfterCancel(Self);
end;

procedure TcxCustomDataController.DoAfterDelete;
begin
  if Assigned(FOnAfterDelete) then
    FOnAfterDelete(Self);
end;

procedure TcxCustomDataController.DoAfterInsert;
begin
  if Assigned(FOnAfterInsert) then
    FOnAfterInsert(Self);
end;

procedure TcxCustomDataController.DoAfterPost;
begin
  if Assigned(FOnAfterPost) then
    FOnAfterPost(Self);
end;

procedure TcxCustomDataController.DoBeforeCancel;
begin
  if Assigned(FOnBeforeCancel) then
    FOnBeforeCancel(Self);
end;

procedure TcxCustomDataController.DoBeforeDelete(ARecordIndex: Integer);
begin
  if Assigned(FOnBeforeDelete) then
    FOnBeforeDelete(Self, ARecordIndex);
end;

procedure TcxCustomDataController.DoBeforeInsert;
begin
  if Assigned(FOnBeforeInsert) then
    FOnBeforeInsert(Self);
end;

procedure TcxCustomDataController.DoBeforePost;
begin
  if Assigned(FOnBeforePost) then
    FOnBeforePost(Self);
end;

function TcxCustomDataController.DoFilterRecord(ARecordIndex: Integer): Boolean;
begin
  Result := True;
  if Assigned(FOnFilterRecord) then
    FOnFilterRecord(Self, ARecordIndex, Result);
end;

function TcxCustomDataController.IsFilterRecord: Boolean;
begin
  Result := Assigned(FOnFilterRecord);
end;

procedure TcxCustomDataController.DoNewRecord(ARecordIndex: Integer);
begin
  if Assigned(FOnNewRecord) then
    FOnNewRecord(Self, ARecordIndex);
end;

procedure TcxCustomDataController.DoDataChanged;
begin
  if not (csDestroying in FOwner.ComponentState) and IsDataChangedListenersExist then
  begin
    if IsLoading then
      FDataChangedFlag := True
    else
    begin
      FDataChangedFlag := False;
      NotifyDataChangedListeners;
    end;
  end;
end;

procedure TcxCustomDataController.DoDetailExpanding(ARecordIndex: Integer; var AAllow: Boolean);
begin
  if Assigned(FOnDetailExpanding) then
    FOnDetailExpanding(Self, ARecordIndex, AAllow);
end;

procedure TcxCustomDataController.DoDetailExpanded(ARecordIndex: Integer);
begin
  if Assigned(FOnDetailExpanded) then
    FOnDetailExpanded(Self, ARecordIndex);
end;

procedure TcxCustomDataController.DoDetailCollapsing(ARecordIndex: Integer; var AAllow: Boolean);
begin
  if Assigned(FOnDetailCollapsing) then
    FOnDetailCollapsing(Self, ARecordIndex, AAllow);
end;

procedure TcxCustomDataController.DoDetailCollapsed(ARecordIndex: Integer);
begin
  if Assigned(FOnDetailCollapsed) then
    FOnDetailCollapsed(Self, ARecordIndex);
end;

function TcxCustomDataController.DoIncrementalFilterRecord(ARecordIndex: Integer): Boolean;
var
  S: string;
begin
  S := GetInternalDisplayText(ARecordIndex, FIncrementalFilterField);
  Result := DataCompareText(S, FIncrementalFilterText, True);
end;

procedure TcxCustomDataController.DoReadRecord(ARecordIndex: Integer);
begin
  Provider.CorrectRecordIndex(ARecordIndex);
end;

function TcxCustomDataController.DoSearchInGridMode(const ASubText: string;
  AForward, ANext: Boolean): Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.FindItemByInternalID(AID: Integer): TObject;
var
  I: Integer;
begin
  for I := 0 to ItemCount - 1 do
  begin
    Result := GetItem(I);
    if GetItemID(Result) = AID then
      Exit;
  end;
  Result := nil;
end;

function TcxCustomDataController.FindItemByName(const AName: string): TObject;
var
  I: Integer;
begin
  for I := 0 to ItemCount - 1 do
  begin
    Result := GetItem(I);
    if SameText(GetItemName(Result), AName) then
      Exit;
  end;
  Result := nil;
end;

function TcxCustomDataController.FindProperItemLink(AItemLink: TObject): TObject;
begin
  Result := FindItemByInternalID(GetItemID(AItemLink));
end;

function TcxCustomDataController.GetActiveRecordIndex: Integer;
begin
  Result := GetFocusedRecordIndex;
end;

function TcxCustomDataController.GetDataProviderClass: TcxCustomDataProviderClass;
begin
  Result := TcxCustomDataProvider;
end;

function TcxCustomDataController.GetDataSelectionClass: TcxDataSelectionClass;
begin
  Result := TcxDataSelection;
end;

function TcxCustomDataController.GetEditOperations: TcxDataControllerEditOperations;
begin
  Result := [];
  if Provider.CanAppend then
    Result := Result + [dceoAppend];
  if Provider.CanDelete then
    Result := Result + [dceoDelete];
  if Provider.CanModify then
    Result := Result + [dceoEdit];
  if Provider.CanInsert then
    Result := Result + [dceoInsert];
  if not Provider.IsDataSource or Provider.IsSyncMode then
    Result := Result + [dceoShowEdit];
end;

function TcxCustomDataController.GetEditState: TcxDataControllerEditState;
begin
  Result := [];
  if Provider.IsInserting then
    Result := Result + [dceInsert]
  else
    if Provider.IsEditing then
      Result := Result + [dceEdit];
  if (Result <> []) and Provider.IsChanging then
    Result := Result + [dceChanging];
  if (Result <> []) and Provider.IsModified then
    Result := Result + [dceModified];
end;

function TcxCustomDataController.GetDefaultActiveRelationIndex: Integer;
begin
  Result := 0;
end;

function TcxCustomDataController.GetFieldClass: TcxCustomDataFieldClass;
begin
  Result := TcxCustomDataField;
end;

function TcxCustomDataController.GetFilterCriteriaClass: TcxDataFilterCriteriaClass;
begin
  Result := TcxDataFilterCriteria;
end;

function TcxCustomDataController.GetInternalDisplayText(ARecordIndex: Integer;
  AField: TcxCustomDataField): string;
begin
  if (ARecordIndex >= 0) and IsProviderMode and IsDataField(AField) then
    Result := Provider.GetDisplayText(ARecordIndex, AField)
  else
    Result := GetStoredDisplayText(ARecordIndex, AField);
end;

function TcxCustomDataController.GetItemID(AItem: TObject): Integer;
begin
  Result := -1;
end;

function TcxCustomDataController.GetItemName(AItem: TObject): string;
begin
  if AItem is TComponent then
    Result := TComponent(AItem).Name
  else
    Result := '';
end;

function TcxCustomDataController.GetInternalRecordId(ARecordIndex: Integer;
  AFieldList: TList): Variant;
var
  I: Integer;
begin
  if AFieldList.Count > 0 then
  begin
    if AFieldList.Count > 1 then
    begin
      Result := VarArrayCreate([0, AFieldList.Count - 1], varVariant);
      for I := 0 to AFieldList.Count - 1 do
        Result[I] := GetInternalValue(ARecordIndex, TcxCustomDataField(AFieldList[I]));
    end
    else
      Result := GetInternalValue(ARecordIndex, TcxCustomDataField(AFieldList[0]));
  end
  else
  begin
    if IsProviderMode then
      Result := Provider.GetRecordId(ARecordIndex)
    else
      Result := Null;
  end;
end;

function TcxCustomDataController.GetInternalValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
begin
  if (ARecordIndex >= 0) and IsProviderMode and IsDataField(AField) then
    Result := Provider.GetValue(ARecordIndex, AField)
  else
    Result := GetStoredValue(ARecordIndex, AField);
end;

procedure TcxCustomDataController.GetKeyFields(AList: TList);
begin
end;

function TcxCustomDataController.GetLastRecordIndex: Integer;
var
  ARowIndex: Integer;
begin
  Result := -1;
  ARowIndex := GetRowCount - 1;
  if ARowIndex <> -1 then
    Result := GetRowInfo(ARowIndex).RecordIndex;
end;

function TcxCustomDataController.GetRecordIndex: Integer;
begin
  if Provider.IsDataSource and Provider.IsSyncMode then
    Result := Provider.GetRecordIndex
  else
    Result := DataControllerInfo.FocusedRecordIndex;
end;                                        

function TcxCustomDataController.GetRelationClass: TcxCustomDataRelationClass;
begin
  Result := TcxCustomDataRelation;
end;

function TcxCustomDataController.GetSearchClass: TcxDataControllerSearchClass;
begin
  Result := TcxDataControllerSearch;
end;

function TcxCustomDataController.GetStoredDisplayText(ARecordIndex: Integer;
  AField: TcxCustomDataField): string;
begin
//  if not AField.IsInternal and IsGridMode then
  if IsDataField(AField) and IsGridMode then
    Result := Provider.GetExternalDataDisplayText(ARecordIndex, AField)
  else
    if AField.ValueDef <> nil then
      Result := DataStorage.GetDisplayText(ARecordIndex, AField.ValueDef)
    else
      Result := '';
end;

function TcxCustomDataController.GetStoredValue(ARecordIndex: Integer;
  AField: TcxCustomDataField): Variant;
begin
//  if not AField.IsInternal and IsGridMode then
  if IsDataField(AField) and IsGridMode then
    Result := Provider.GetExternalDataValue(ARecordIndex, AField)
  else
    if AField.ValueDef <> nil then
      Result := DataStorage.GetValue(ARecordIndex, AField.ValueDef)
    else
      Result := Null;
end;

function TcxCustomDataController.GetSummaryClass: TcxDataSummaryClass;
begin
  Result := TcxDataSummary;
end;

function TcxCustomDataController.GetSummaryItemClass: TcxDataSummaryItemClass;
begin
  Result := TcxDataSummaryItem;
end;

function TcxCustomDataController.GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass;
begin
  Result := TcxDataSummaryGroupItemLink;
end;

function TcxCustomDataController.InternalCheckBookmark(ADeletedRecordIndex: Integer): Boolean;
begin
  if (ADeletedRecordIndex <> -1) and (FBookmarkRecordIndex = ADeletedRecordIndex) then
    Result := True
  else
    Result := GetFilteredIndexByRecordIndex(FBookmarkRecordIndex) = -1;
end;

procedure TcxCustomDataController.InternalClearBookmark;
begin
  FBookmarkRecordIndex := -1;
end;

procedure TcxCustomDataController.InternalGotoBookmark;
begin
  FocusedRecordIndex := FBookmarkRecordIndex;
end;

function TcxCustomDataController.InternalSaveBookmark: Boolean;
var
  ARecordIndex: Integer;
begin
  Result := False;
  ARecordIndex := FocusedRecordIndex;
  if FBookmarkRecordIndex <> ARecordIndex then
  begin
    FBookmarkRecordIndex := ARecordIndex;
    Result := True;
  end;
end;

function TcxCustomDataController.IsDataBound: Boolean;
begin
  Result := IsProviderMode or Provider.IsDataSource;
end;

function TcxCustomDataController.IsDataChangedListenersExist: Boolean;
begin
  Result := Assigned(FOnDataChanged) or Assigned(FOnRecordChanged) or
    (FDataChangedListeners.Count > 0);
end;

function TcxCustomDataController.IsDataField(AField: TcxCustomDataField): Boolean;
begin
  Result := not AField.IsInternal or
    (Assigned(AField.FReferenceField) and not AField.FReferenceField.IsInternal);
end;

function TcxCustomDataController.IsDestroying: Boolean;
begin
  Result := csDestroying in FOwner.ComponentState;
end;

function TcxCustomDataController.IsFocusedSelectedMode: Boolean;
begin
  Result := not MultiSelect{ and FFocusedSelected}; // TODO:?
end;

function TcxCustomDataController.IsImmediatePost: Boolean;
begin
  Result := (dcoImmediatePost in Options) or Provider.IsUnboundColumnMode;
end;

function TcxCustomDataController.IsKeyNavigation: Boolean;
begin
  if IsProviderMode then
    Result := Provider.IsRecordIdSupported
  else
    Result := False;
end;

function TcxCustomDataController.IsLoading: Boolean;
begin
  Result := csLoading in FOwner.ComponentState;
end;

function TcxCustomDataController.IsProviderDataSource: Boolean;
begin
  Result := IsProviderMode or FStructureRecreated;
end;

function TcxCustomDataController.IsProviderMode: Boolean;
begin
  Result := Provider.CustomDataSource <> nil;
end;

function TcxCustomDataController.IsRecordID: Boolean;
begin
  Result := IsUnboundMode and UseRecordID;
end;

function TcxCustomDataController.IsSmartLoad: Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.IsSmartRefresh: Boolean;
begin
  Result := False;
end;

function TcxCustomDataController.IsUnboundMode: Boolean;
begin
  Result := Provider.IsCustomDataSourceSupported and not IsProviderMode; // ?
end;

procedure TcxCustomDataController.LoadStorage;

  procedure LoadData;
  var
    AValueDefReader: TcxValueDefReader;
    ARecordIndex: Integer;
  begin
    with Provider do
    begin
      if IsGridMode then
      begin
        DataStorage.BeginLoad;
        try
          LoadDataBuffer;
        finally
          DataStorage.EndLoad;
        end;
      end
      else
      begin
        Freeze;
        try
          SavePos;
          First; // possible to recreate Fields in dbX and Query Reopen
          if RecreatedFieldsAfterFirst then
            UpdateFields;
          DataStorage.BeginLoad;
          try
            if IsProviderMode then
              LoadRecordHandles
            else
            begin
              AValueDefReader := GetValueDefReaderClass.Create;
              try
                while not IsEOF do
                begin
                  ARecordIndex := DataStorage.AppendRecord;
                  DataStorage.ReadRecord(ARecordIndex, AValueDefReader);
                  Self.DoReadRecord(ARecordIndex);
                  Next;
                end;
              finally
                AValueDefReader.Free;
              end;
            end;
          finally
            DataStorage.EndLoad;
          end;
          FLoadedStorage := Provider.ActiveChanging;
          RestorePos;
        finally
          Unfreeze;
        end;
      end;
    end;
  end;

  procedure CheckAfterLoad;
  begin
    FInLoadStorage := True;
    try
      CheckSelectedCount(-1);
    finally
      FInLoadStorage := False;
    end;
    UpdateFocused;
  end;

begin
  if not (IsSmartLoad and FInSmartLoad) then
    DataStorage.Clear(Provider.FDataChangedLocked);
  if Provider.IsActive and not IsSmartLoad then
  begin
    if DetailMode <> dcdmPattern then
      LoadData;
    CheckAfterLoad;
  end;
  Change([dccData]);
  SyncMasterPos;
end;

function TcxCustomDataController.IsNewItemRecordIndex(ARecordIndex: Integer): Boolean;
begin
  Result := UseNewItemRowForEditing and (ARecordIndex = NewItemRecordIndex);
end;

function TcxCustomDataController.LockOnAfterSummary: Boolean;
begin
  Result := IsGridMode and FStructureChanged;
end;

procedure TcxCustomDataController.NotifyDataChangedListeners;
var
  I: Integer;
  E: TNotifyEventItem;
begin
  if not IsPattern then
  begin
    if (FDataChangeInfo.Kind in [dcField, dcRecord]) and
      ((FDataChangeInfo.RecordIndex <> -1) or IsNewItemRecordIndex(FDataChangeInfo.RecordIndex)) then
    begin
      if Assigned(FOnRecordChanged) then
        FOnRecordChanged(Self, FDataChangeInfo.RecordIndex, FDataChangeInfo.ItemIndex);
    end;
    if Assigned(FOnDataChanged) then
      FOnDataChanged(Self);
  end;

  if IsGridMode and (Provider.LocateCount <> 0) then Exit; // TODO: !!!
  for I := 0 to FDataChangedListeners.Count - 1 do
  begin
    E := TNotifyEventItem(FDataChangedListeners[I]);
    E.Event(Self);
  end;  
end;

procedure TcxCustomDataController.NotifyDataControllers;
begin
end;

procedure TcxCustomDataController.PrepareField(AField: TcxCustomDataField);
begin
end;

procedure TcxCustomDataController.RemoveNotification(AComponent: TComponent);
begin
  Fields.RemoveNotification(AComponent);
end;

procedure TcxCustomDataController.ResetMasterHasChildrenFlag;
var
  AMasterDataController: TcxCustomDataController;
begin
  if IsDataBound then
  begin
    AMasterDataController := GetMasterDataController;
    if (AMasterDataController <> nil) and (EditState * [dceInsert, dceEdit] = []) then
      AMasterDataController.ResetHasChildrenFlag;
  end;
end;

procedure TcxCustomDataController.ResetNewItemRowFocused;
begin
  if FNewItemRowFocused then
    DataControllerInfo.FPrevFocusingInfo.FChangedFlag := True;
  FNewItemRowFocused := False;
end;

procedure TcxCustomDataController.RestructData;
begin
  //BeginUpdate;
  BeginFullUpdate;
  try
    Provider.ResetEditing;
//    if not IsUnboundMode then
    if not IsUnboundMode or (FInSetCustomDataSource and (CustomDataSource = nil)) then
      DataStorage.Clear(False);
    InternalClearBookmark;
    CheckSelectedCount(-1); // <- Clear Selection
    DataStorage.StoredValuesOnly := IsProviderMode or IsGridMode;
    UpdateUseRecordIDState;
    if CustomDataSource <> nil then
    begin
      if FRecordHandlesField = nil then
      begin
        FRecordHandlesField := AddInternalField;
        FRecordHandlesField.ValueTypeClass := TcxIntegerValueType;
      end;
    end
    else
    begin
      FRecordHandlesField.Free; // FRecordHandlesField <- nil (in RemoveDataField method)
    end;
    FStructureRecreated := True;
    LayoutChanged([lcData]);
  finally
    EndFullUpdate;
    //EndUpdate;
  end;
end;

procedure TcxCustomDataController.SetStoredValue(ARecordIndex: Integer;
  AField: TcxCustomDataField; const Value: Variant);
begin
  if AField.ValueDef <> nil then
    DataStorage.SetValue(ARecordIndex, AField.ValueDef, Value);
end;

function TcxCustomDataController.SyncDetailsFocusWithMaster: Boolean;
begin
  Result := False;
end;

procedure TcxCustomDataController.SyncMasterPos;
begin
  if DetailMode = dcdmClone then
    Change([dccSyncMasterPos]);
  NotifyDataControllers;  
end;

procedure TcxCustomDataController.UpdateFields;
var
  I: Integer;
  AField: TcxCustomDataField;
  APreparedAll: Boolean;
begin
  for I := 0 to Fields.Count - 1 do
    Fields[I].FPrepared := False;
  repeat
    Fields.FFieldDestroyed := False;
    for I := 0 to Fields.Count - 1 do
    begin
      AField := Fields[I];
      if AField.FPrepared then Continue; 
      PrepareField(AField);
      AField.FPrepared := True;
      if Fields.FFieldDestroyed then Break;
    end;
    // check Finish
    APreparedAll := True;
    for I := 0 to Fields.Count - 1 do
      if not Fields[I].FPrepared then
      begin
        APreparedAll := False;
        Break;
      end;
  until APreparedAll;
//  for I := 0 to Fields.Count - 1 do
//    PrepareField(Fields[I]);
end;

procedure TcxCustomDataController.UpdateFocused;
begin
  if (Provider.LocateCount = 0) or not DataControllerInfo.FFocusingFlag then
    DataControllerInfo.RefreshFocused;
end;

procedure TcxCustomDataController.UpdateRelations(ARelation: TcxCustomDataRelation);
var
  ARootDataController: TcxCustomDataController;
begin
  if FDestroying then Exit;
  if DetailMode = dcdmPattern then
  begin
    ARootDataController := GetRootDataController;
    if FMasterRelation <> nil then
      ARootDataController.ResetRelationByItem(FMasterRelation.Item);
  end
  else
    Change([dccData{dccDetail}]);
end;

procedure TcxCustomDataController.UpdateUseRecordIDState;
begin
  DataStorage.UseRecordID := IsRecordID;
end;

procedure TcxCustomDataController.UpdateStorage(AUpdateFields: Boolean);
begin
  BeginFullUpdate; // !!! see also 22299
  try
    if IsProviderDataSource then
    begin
      if AUpdateFields or Provider.IsActiveDataSet then
      begin
        if LockUpdateFieldsCount <> 0 then
          FUpdateFieldsFlag := True
        else
        begin
          if Provider.IsGridModeUpdating and
           ((EditState * [dceInsert] <> []) or // appending record
             FFields.FFieldDestroyed) then // Filter.OnBeforeChange
            // do nothing
          else
            UpdateFields;
        end;
      end;
      if not FStructureChanged then
        LoadStorage;
    end;
    DataControllerInfo.Refresh;
    FUpdateItems := False;
    FStructureRecreated := False;
  finally
    EndFullUpdate;
  end;
end;

function TcxCustomDataController.UseRecordID: Boolean;
begin
  Result := False;
end;

class function TcxCustomDataController.AddListenerLink(ADataController: TcxCustomDataController): TcxDataListenerLink;
begin
  Result := TcxDataListenerLink.Create;
  Result.Ref := ADataController;
  ADataController.FListenerLinks.Add(Result);
end;

class procedure TcxCustomDataController.RemoveListenerLink(ALink: TcxDataListenerLink);
begin
  if ALink.Ref <> nil then
    ALink.Ref.FListenerLinks.Remove(ALink);
  ALink.Free;  
end;

procedure TcxCustomDataController.DataStorageClearInternalRecords(Sender: TObject);
begin
  Provider.FSavedRecordIndex := 0;
  FNewItemRecordIndex := 0;
end;

procedure TcxCustomDataController.RemoveField(ADataField: TcxCustomDataField);
begin
  if FRecordHandlesField = ADataField then
    FRecordHandlesField := nil;
  if Assigned(FRelations) then
    Relations.RemoveDataField(ADataField);
  if Assigned(FFilters) then
    FFilters.RemoveItemByField(ADataField);
  if Assigned(FFilter) then
    Filter.RemoveItemByField(ADataField);
  if Assigned(FSummary) then
    Summary.RemoveItemByField(ADataField);
  if FIncrementalFilterField = ADataField then
    ResetIncrementalFilter;
  if FSortingBySummaryDataItemField = ADataField then
    SortingBySummaryDataItemIndex := -1;
  if FIncrementalSearchField = ADataField then
  begin
    Search.Cancel;
    FIncrementalSearchField := nil;
  end;
end;

procedure TcxCustomDataController.FilterChanged;
begin
// !!! filter custom!
  FCheckFocusingAfterFilterNeeded := True;
  Cancel;
  Refresh;
  CheckBookmarkValid(-1);
  CorrectPrevSelectionChangedInfo;
end;

procedure TcxCustomDataController.SummaryChanged(ARedrawOnly: Boolean);
begin
  DataControllerInfo.RefreshSummary(ARedrawOnly);
end;

procedure TcxCustomDataController.ActiveChanged(AActive: Boolean);
begin
  FActive := AActive;
  UpdateItems(Provider.IsActive);
  ResetMasterHasChildrenFlag;
end;

procedure TcxCustomDataController.DataChanged(ADataChange: TcxDataChange;
  AItemIndex, ARecordIndex: Integer);
begin
  if ((FDataChangeInfo.RecordIndex <> -1) or IsNewItemRecordIndex(FDataChangeInfo.RecordIndex)) and
    (FDataChangeInfo.RecordIndex <> ARecordIndex) then
    FDataChangeInfo.Kind := dcTotal
  else
    if (ADataChange = dcField) and (FDataChangeInfo.ItemIndex <> -1) and
      (FDataChangeInfo.ItemIndex <> AItemIndex) then
    begin
      FDataChangeInfo.Kind := dcRecord;
      AItemIndex := -1;
    end
    else
      FDataChangeInfo.Kind := ADataChange;
  FDataChangeInfo.ItemIndex := AItemIndex;
  FDataChangeInfo.RecordIndex := ARecordIndex;
  if (ADataChange = dcTotal) then
    UpdateStorage(False)
  else
  begin
    if ADataChange in [dcNew, dcDeleted] then
      DataControllerInfo.FocusedRecordChanged(False);
    DataControllerInfo.Refresh;
  end;
  ResetMasterHasChildrenFlag;
end;

procedure TcxCustomDataController.DataScrolled(ADistance: Integer);
begin
  UpdateFocused;
end;

procedure TcxCustomDataController.LayoutChanged(ADataLayoutChanges: TcxDataLayoutChanges);
begin
  UpdateItems(Provider.IsActive);
end;

procedure TcxCustomDataController.DoBeforeFocusedRowChange(ARowIndex: Integer);
begin
end;

procedure TcxCustomDataController.DoValueTypeClassChanged(AItemIndex: Integer);
begin
end;

procedure TcxCustomDataController.UpdateControl(AInfo: TcxUpdateControlInfo);
begin
  if Assigned(FOnUpdateControl) then FOnUpdateControl(AInfo);
end;

function TcxCustomDataController.GetIncrementalSearchText(ARecordIndex, AItemIndex: Integer): string;
begin
  Result := GetDisplayText(ARecordIndex, AItemIndex);
end;

function TcxCustomDataController.GetFilterDisplayText(ARecordIndex, AItemIndex: Integer): string;
begin
  Result := GetDisplayText(ARecordIndex, AItemIndex); 
end;

// Compare

function TcxCustomDataController.CompareByField(ARecordIndex1, ARecordIndex2: Integer;
  AField: TcxCustomDataField; AMode: TcxDataControllerComparisonMode): Integer;

{  function CompareStrEx(const S1, S2: string): Integer;
  begin
    if S1 = S2 then
      Result := 0
    else
      if S1 < S2 then
        Result := -1
      else
        Result := 1;
  end;}

  function StringCompare(const V1, V2: Variant): Integer;
  begin
    if dcoAnsiSort in Options then
    begin
      if dcoCaseInsensitive in Options then
        Result := AnsiCompareText(V1, V2)
      else
        Result := AnsiCompareStr(V1, V2);
    end
    else
    begin
      if dcoCaseInsensitive in Options then
        //TODO: Option -> CompareText(V1, V2);
//        Result := CompareText(AnsiUpperCase(V1), AnsiUpperCase(V2))
        Result := CompareStr(AnsiUpperCase(V1), AnsiUpperCase(V2))
//        Result := CompareStrEx(AnsiUpperCase(V1), AnsiUpperCase(V2))
      else
        Result := VarCompare(V1, V2);
    end;
  end;

var
  V1, V2: Variant;
begin
  if (Assigned(FOnCompare) and not AField.IsInternal) or IsConversionNeededForCompare(AField) then
  begin
    if not Assigned(FOnCompare) and IsProviderMode and
      Provider.CustomDataSource.IsNativeCompareFunc and
      (ARecordIndex1 >= 0) and (ARecordIndex2 >= 0) then
    begin
      Result := Provider.NativeCompareFunc(ARecordIndex1, ARecordIndex2, AField);
    end
    else
    begin
      V1 := GetComparedValue(ARecordIndex1, AField);
      V2 := GetComparedValue(ARecordIndex2, AField);
      if Assigned(FOnCompare) then
      begin
        Result := 0;
        FOnCompare(Self, ARecordIndex1, ARecordIndex2, AField.Index, V1, V2, Result);
      end
      else
      begin
        if VarIsStr(V1) and VarIsStr(V2) then
          Result := StringCompare(VarToStr(V1), VarToStr(V2))
        else
          Result := VarCompare(V1, V2);
        // 2 Result := StringCompare(VarToStr(V1), VarToStr(V2));
        { 1
        if IsStringConversionNeeded(AField) then
          Result := StringCompare(VarToStr(V1), VarToStr(V2))
        else
          Result := VarCompare(V1, V2);
        }
      end;
    end;
  end
  else
    Result := NativeCompare(ARecordIndex1, ARecordIndex2, AField);
end;

function TcxCustomDataController.CompareEqualRecords(ARecordIndex1, ARecordIndex2: Integer): Integer;
begin
  Result := ARecordIndex1 - ARecordIndex2;
end;

function TcxCustomDataController.CompareRecords(ARecordIndex1, ARecordIndex2: Integer;
  ASortInfo: TcxDataSortInfo; AMode: TcxDataControllerComparisonMode = dccmOther): Integer;
begin
  Result := CompareByField(ARecordIndex1, ARecordIndex2, ASortInfo.Field, AMode);
  if ASortInfo.SortOrder = soDescending then
    Result := -Result;
end;

function TcxCustomDataController.FindGroupRecord(ABufferRecordIndex: Integer;
  AGroupItemCount: Integer): Integer;

  function Compare(ARecordIndex, AItemIndex: Integer): Integer;
  begin
    Result := DataControllerInfo.CompareGroupRecords(ARecordIndex, ABufferRecordIndex, AItemIndex);
  end;

var
  L, H, I, C: Integer;
  J, JLast: Integer;
begin
  Result := -1;
  L := 0;
  H := DataControllerInfo.GetInternalRecordCount - 1;
  JLast := AGroupItemCount - 1;
  if L <= H then
    repeat
      I := (L + H) div 2;
      for J := 0 to AGroupItemCount - 1 do
      begin
        C := Compare(DataControllerInfo.GetInternalRecordIndex(I), J);
        if C = 0 then
        begin
          if J = JLast then
          begin
            Result := DataControllerInfo.GetInternalRecordIndex(I);
            Exit;
          end;
        end
        else
        begin
          if C < 0 then
            L := I + 1
          else
            H := I - 1;
          Break;
        end;
      end;
      if L > H then
        Break;
    until False;
end;

function TcxCustomDataController.FindRecordByFields(ABufferRecordIndex: Integer;
  AFields: TList): Integer;

  function IsEqual(ARecordIndex: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := AFields.Count > 0;
    for I := 0 to AFields.Count - 1 do
      if CompareByField(ARecordIndex, ABufferRecordIndex, TcxCustomDataField(AFields[I]), dccmOther) <> 0 then
      begin
        Result := False;
        Break;
      end;
  end;

var
  I: Integer;
begin
  Result := -1;
  DataControllerInfo.PrepareSorting;
  try
    for I := 0 to RecordCount - 1 do
      if IsEqual(I) then
      begin
        Result := I;
        Break;
      end;
  finally
    DataControllerInfo.UnprepareSorting;
  end;
end;

function TcxCustomDataController.GetComparedValue(ARecordIndex: Integer;
  AField: TcxCustomDataField): Variant;
begin
  if (AField.FNeedConversionFlag = 2) then
    Result := GetDisplayText(ARecordIndex, AField.Index)
  else
    Result := GetInternalValue(ARecordIndex, AField);
end;

function TcxCustomDataController.IsConversionNeededForCompare(AField: TcxCustomDataField): Boolean;
begin
  if AField.FNeedConversionFlag <> 0 then
  begin
    Result := AField.FNeedConversionFlag >= 1;
    Exit;
  end;
  Result := AField.NeedConversion or IsStringConversionNeeded(AField) or
    IsSortByDisplayTextNeeded(AField);
  if not Result and IsProviderMode  then
    Result := not Provider.CustomDataSource.IsNativeCompare;
end;

function TcxCustomDataController.IsFilterItemSortByDisplayText(AItemIndex: Integer): Boolean;
var
  AField: TcxCustomDataField;
begin
  Result := GetItemSortByDisplayText(AItemIndex, True);
  if not Result and (Options * [dcoAnsiSort] <> []) then
  begin
    AField := Fields[AItemIndex];
    Result := Assigned(AField.ValueDef) and AField.ValueDef.IsNeedConversion;
  end;
end;

function TcxCustomDataController.IsStringConversionNeeded(AField: TcxCustomDataField): Boolean;
begin
  Result := (Options * [dcoAnsiSort, dcoCaseInsensitive] <> []) and
    Assigned(AField.ValueDef) and AField.ValueDef.IsNeedConversion;
end;

function TcxCustomDataController.IsSortByDisplayTextNeeded(AField: TcxCustomDataField): Boolean;
begin
  Result := not FInternalFindRecord and not AField.IsInternal and
    GetItemSortByDisplayText(AField.Index, dcoSortByDisplayText in Options);
end;

function TcxCustomDataController.NativeCompare(ARecordIndex1, ARecordIndex2: Integer;
  AField: TcxCustomDataField): Integer;
begin
  if Assigned(AField.ValueDef) then
  begin
    if not IsProviderMode then
      Result := DataStorage.CompareRecords(ARecordIndex1, ARecordIndex2, AField.ValueDef)
    else
      Result := Provider.NativeCompare(ARecordIndex1, ARecordIndex2, AField);
  end
  else
    Result := 0;
end;

procedure TcxCustomDataController.DeleteFocusedRecord;
begin
  if FNearestRecordIndex >= FocusedRecordIndex then
    Dec(FNearestRecordIndex);
  try
    Provider.Delete;
  except
    FNearestRecordIndex := FocusedRecordIndex;
    raise;
  end;
end;

procedure TcxCustomDataController.DeleteRecords(AList: TList);
var
  I, J, AOldNearestRecordIndex: Integer;
begin
  // Prepare List - sort and delete duplicates
  AList.Sort(CompareIntegers);
  for I := AList.Count - 2 downto 0 do
  begin
    J := I + 1;
    if AList[I] = AList[J] then
      AList.Delete(J);
  end;

  AOldNearestRecordIndex := FNearestRecordIndex;
  if AOldNearestRecordIndex <> -1 then
  begin
    for I := 0 to AList.Count - 1 do
    begin
      if AOldNearestRecordIndex >= Integer(AList[I]) then
        Dec(FNearestRecordIndex);
    end;
  end;

  try
    Provider.DeleteRecords(AList);
  except
    FNearestRecordIndex := FocusedRecordIndex;
    raise;
  end;
end;

procedure TcxCustomDataController.BeginSmartLoad;
begin
  with Provider do
  begin
    Freeze;
    SavePos;
    DataStorage.BeginLoad;
  end;
end;

procedure TcxCustomDataController.EndSmartLoad;
begin
  with Provider do
  begin
    DataStorage.EndLoad;
    RestorePos;
    Unfreeze;
  end;
  UpdateFocused;
  DataControllerInfo.Refresh;
end;

function TcxCustomDataController.LoadRecord(AData: Pointer): Integer;
begin
  if IsProviderMode then
    Result := Provider.AddRecordHandle(AData)
  else
  begin
    Result := DataStorage.AppendRecord;
    DataStorage.ReadRecord(Result, TcxValueDefReader(AData));
    DoReadRecord(Result);
  end;
end;

procedure TcxCustomDataController.BeginReadRecord;
begin
end;

procedure TcxCustomDataController.EndReadRecord;
begin
end;

function TcxCustomDataController.GetSortingBySummaryEngineClass: TcxSortingBySummaryEngineClass;
begin
  Result := nil;
end;

function TcxCustomDataController.GetCustomDataSource: TcxCustomDataSource;
begin
  Result := Provider.CustomDataSource;
end;

function TcxCustomDataController.GetDetailMode: TcxDataControllerDetailMode;
begin
  if FMasterRelation <> nil then
  begin
    if FMasterRecordIndex <> -1 then
      Result := dcdmClone
    else
      Result := dcdmPattern;
  end
  else
    if FIsPattern then
      Result := dcdmPattern
    else
      Result := dcdmNone;
end;

function TcxCustomDataController.GetFilteredIndexByRecordIndex(Index: Integer): Integer;
begin
  Result := DataControllerInfo.GetInternalRecordListIndex(Index);
end;

function TcxCustomDataController.GetFilteredRecordCount: Integer;
begin
  Result := DataControllerInfo.GetInternalRecordCount;
end;

function TcxCustomDataController.GetFilteredRecordIndex(Index: Integer): Integer;
begin
  Result := DataControllerInfo.GetInternalRecordIndex(Index);
end;

function TcxCustomDataController.GetIsEditing: Boolean;
begin
  Result := EditState * [dceInsert, dceEdit] <> [];
  Result := Result and (Provider.FEditingRecordIndex <> cxNullEditingRecordIndex);
end;

function TcxCustomDataController.GetIsPattern: Boolean;
begin
  Result := DetailMode = dcdmPattern;
end;

function TcxCustomDataController.GetIsRowInfoValid: Boolean;
begin
  Result := not DataControllerInfo.FInfoCalculation;
end;

function TcxCustomDataController.GetLockCount: Integer;
begin
  Result := DataControllerInfo.LockCount;
end;

function TcxCustomDataController.GetNewItemRowFocused: Boolean;
begin
  Result := FNewItemRowFocused and UseNewItemRowForEditing and
    (DataControllerInfo.FocusedRecordIndex = -1);
end;

function TcxCustomDataController.GetOptions: TcxDataControllerOptions;
begin
  Result := FOptions;
end;

function TcxCustomDataController.GetRelations: TcxCustomDataRelationList;
begin
  if FRelations = nil then
    FRelations := TcxCustomDataRelationList.Create(Self);
  Result := FRelations;
end;

function TcxCustomDataController.GetSortingBySummaryDataItemIndex: Integer;
begin
  if FSortingBySummaryDataItemField <> nil then
    Result := FSortingBySummaryDataItemField.Index
  else
    Result := -1;
end;

procedure TcxCustomDataController.SetCustomDataSource(Value: TcxCustomDataSource);
begin
  Provider.CustomDataSource := Value;
end;

procedure TcxCustomDataController.SetIsPattern(Value: Boolean);
var
  APrevIsPattern: Boolean;
begin
  if Value and (FDataChangeRefCount <> 0) and (FMasterRelation <> nil) then
    raise EdxException.Create('!');
  APrevIsPattern := IsPattern;
  FIsPatternSave := Value;
  FIsPattern := FIsPatternSave and (FDataChangeRefCount = 0);
  if IsPattern <> APrevIsPattern then
    if not (csDestroying in FOwner.ComponentState) then
      RestructData;
end;

procedure TcxCustomDataController.SetFilter(Value: TcxDataFilterCriteria);
begin
  FFilter.Assign(Value);
end;

procedure TcxCustomDataController.SetFocusedRowIndex(Value: Integer);
begin
  ChangeFocusedRowIndex(Value);
end;

procedure TcxCustomDataController.SetMultiSelect(Value: Boolean);
begin
  if FMultiSelect <> Value then
  begin
    FMultiSelect := Value;
    FFocusedSelected := True; // reset
    BeginUpdate;
    try
      if not Value then
        ClearSelection
      else
        if FocusedRowIndex <> -1 then
          ChangeRowSelection(FocusedRowIndex, True);
      if [soSelectedRecords, soMultipleSelectedRecords] * Summary.Options <> [] then
        Summary.Changed(False);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomDataController.SetNewItemRowFocused(Value: Boolean);
begin
  if FNewItemRowFocused <> Value then
  begin
    BeginUpdate;
    try
      if FNewItemRowFocused then
      begin
        if not (csDestroying in FOwner.ComponentState) then
          Post;
      end
      else
        ChangeFocusedRowIndex(-1);
      DataControllerInfo.FocusedRecordChanged(True); //?
      FNewItemRowFocused := Value; // Notification
    finally
      EndUpdate;
    end;
    if (dcoInsertOnNewItemRowFocusing in Options) and
      NewItemRowFocused and not Provider.IsInserting then
      Insert;
  end;
end;

procedure TcxCustomDataController.SetOnFilterRecord(Value: TcxDataFilterRecordEvent);
begin
  if @FOnFilterRecord <> @Value then
  begin
    FOnFilterRecord := Value;
    Filter.Changed;
  end;
end;

procedure TcxCustomDataController.SetOptions(Value: TcxDataControllerOptions);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    Refresh;
  end;
end;

procedure TcxCustomDataController.SetSummary(Value: TcxDataSummary);
begin
  FSummary.Assign(Value);
end;

procedure TcxCustomDataController.SetUseNewItemRowForEditing(Value: Boolean);
begin
  if FUseNewItemRowForEditing <> Value then
  begin
    Cancel;
    ClearSelection;
    FUseNewItemRowForEditing := Value;
    Change([dccData]);
  end;
end;

procedure TcxCustomDataController.SetSortingBySummaryDataItemIndex(Value: Integer);
begin
  if GetSortingBySummaryDataItemIndex <> Value then
  begin
    if Value = -1 then
      FSortingBySummaryDataItemField := nil
    else
    begin
      CheckItemRange(Value);
      FSortingBySummaryDataItemField := Fields[Value];
    end;
    DoSortingBySummaryChanged;
  end;
end;

procedure TcxCustomDataController.Update;
var
  AChanges: TcxDataControllerChanges;
begin
  AChanges := FChanges;
  FChanges := [];
  if dccData in AChanges then
    DataNotification
  else
    if AChanges * [dccLayout, dccDetail, dccSummary] <> [] then
      LayoutNotification
    else
      if dccUpdateRecord in AChanges then
        UpdateRecordNotification;
  if dccFocus in AChanges then
    FocusedNotification;
  if dccSelection in AChanges then
    SelectionNotification;
  if dccSearch in AChanges then
    SearchNotification;
  if dccBookmark in AChanges then
    BookmarkNotification;
  // events
  if dccGrouping in AChanges then
    DoGroupingChanged;
  if dccSorting in AChanges then
    DoSortingChanged;
  // master-detail sync
  if dccSyncMasterPos in AChanges then
  begin
    if DetailMode = dcdmClone then
      GetPatternDataController.UpdateFocused;
  end;                                                                    
end;

procedure TcxCustomDataController.BeforeGroupingNotification;
begin
  NotifyControl(TcxGroupingChangingInfo.Create);
end;

procedure TcxCustomDataController.BookmarkNotification;
begin
  NotifyControl(TcxBookmarkChangedInfo.Create);
end;

procedure TcxCustomDataController.DataNotification;
var
  ADataChangedInfo: TcxDataChangedInfo;
begin
  try
    ADataChangedInfo := TcxDataChangedInfo.Create;
    if (FDataChangeInfo.Kind = dcField) and (FDataChangeInfo.ItemIndex = -1)  then
      FDataChangeInfo.Kind := dcRecord;
    if (FDataChangeInfo.Kind in [dcField, dcRecord]) and
      ((FDataChangeInfo.RecordIndex = -1) and not IsNewItemRecordIndex(FDataChangeInfo.RecordIndex)) then
      FDataChangeInfo.Kind := dcTotal;
    ADataChangedInfo.Kind := FDataChangeInfo.Kind;
    ADataChangedInfo.ItemIndex := FDataChangeInfo.ItemIndex;
    ADataChangedInfo.RecordIndex := FDataChangeInfo.RecordIndex;
    NotifyControl(ADataChangedInfo);
    DoDataChanged;
  finally
    ResetDataChangeInfo;
  end;  
end;

procedure TcxCustomDataController.DoGroupingChanged;
begin
  if [csReading{csLoading}] * FOwner.ComponentState <> [] then Exit; // TODO: collection -> lookup grid // // TODO: method IsLoading/Destroying
  if Assigned(FOnGroupingChanged) then FOnGroupingChanged(Self);
end;

procedure TcxCustomDataController.DoSortingBySummaryChanged;
begin
  if IsDestroying then
    Exit;
  FSortingBySummaryChanged := True;
  Change([dccSorting{dccGrouping}]);
end;

procedure TcxCustomDataController.DoSortingChanged;
begin
  if [csReading{csLoading}] * FOwner.ComponentState <> [] then Exit; // TODO: collection -> lookup grid // // TODO: method IsLoading/Destroying
  if FInOnSortingChanged then Exit;
  FInOnSortingChanged := True;
  try
    if Assigned(FOnSortingChanged) then FOnSortingChanged(Self);
  finally
    FInOnSortingChanged := False;
  end;
end;

procedure TcxCustomDataController.FocusedNotification;
begin
  if DataControllerInfo.PrevFocusedRowIndex <> DataControllerInfo.FocusedRowIndex then
    NotifyControl(TcxFocusedRowChangedInfo.Create(DataControllerInfo.PrevFocusedRowIndex,
      DataControllerInfo.FocusedRowIndex));
  if (DataControllerInfo.PrevFocusedRecordIndex >= 0) or
    (DataControllerInfo.FocusedRecordIndex >= 0) or
    DataControllerInfo.FPrevFocusingInfo.FChangedFlag then
  begin
// !!!
//  if (DataControllerInfo.PrevFocusedRecordIndex <> DataControllerInfo.FocusedRecordIndex) and
//    not DataControllerInfo.FPrevFocusingInfo.FChangedFlag then
    NotifyControl(TcxFocusedRecordChangedInfo.Create(DataControllerInfo.PrevFocusedRecordIndex,
      DataControllerInfo.FocusedRecordIndex, DataControllerInfo.PrevFocusedRowIndex,
      DataControllerInfo.FocusedRowIndex, DataControllerInfo.NewItemRowFocusingChanged));
    Search.Cancel;
  end;
  DataControllerInfo.FPrevFocusingInfo.Assign(DataControllerInfo.FFocusingInfo);
end;

procedure TcxCustomDataController.LayoutNotification;
begin
  NotifyControl(TcxLayoutChangedInfo.Create);
end;

procedure TcxCustomDataController.UpdateRecordNotification;
begin
  NotifyControl(TcxUpdateRecordInfo.Create(FocusedRecordIndex));
  Search.Cancel;
end;

procedure TcxCustomDataController.SearchNotification;
begin
  NotifyControl(TcxSearchChangedInfo.Create);
end;

procedure TcxCustomDataController.SelectionNotification;
var
  AInfo: TcxSelectionChangedInfo;
  ARowIndex1, ARowIndex2: Integer;
begin
  ARowIndex1 := -1;
  ARowIndex2 := -1;
  FSelectionChangedInfo.SelectedCount := GetSelectedCount;
  if FSelectionChangedInfo.SelectedCount <= 1 then
  begin
    if FSelectionChangedInfo.SelectedCount = 1 then
      FSelectionChangedInfo.RowIndex := GetSelectedRowIndex(0)
    else
      FSelectionChangedInfo.RowIndex := -1;
    if FPrevSelectionChangedInfo.SelectedCount <= 1 then
    begin
      if FPrevSelectionChangedInfo.SelectedCount = 1 then
        ARowIndex1 := FPrevSelectionChangedInfo.RowIndex
      else
        ARowIndex1 := -1;
      ARowIndex2 := FSelectionChangedInfo.RowIndex;
    end;
  end;
  AInfo := TcxSelectionChangedInfo.CreateEx(ARowIndex1, ARowIndex2);
  NotifyControl(AInfo);
  FPrevSelectionChangedInfo := FSelectionChangedInfo;
end;

procedure TcxCustomDataController.NotifyControl(AUpdateControlInfo: TcxUpdateControlInfo);
begin
  FInNotifyControl := True;
  try
    UpdateControl(AUpdateControlInfo);
  finally
    AUpdateControlInfo.Free;
    FInNotifyControl := False;
  end;
end;

procedure TcxCustomDataController.NotifyListenerLinks;
var
  I: Integer;
  ALink: TcxDataListenerLink;
begin
  for I := FListenerLinks.Count - 1 downto 0 do
  begin
    ALink := TcxDataListenerLink(FListenerLinks[I]);
    ALink.Ref := nil;
    FListenerLinks.Delete(I);
  end;
end;

procedure TcxCustomDataController.ResetDataChangeInfo;
begin
  FDataChangeInfo.Kind := dcTotal;
  FDataChangeInfo.ItemIndex := -1;
  FDataChangeInfo.RecordIndex := -1;
end;

end.
