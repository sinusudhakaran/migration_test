{===============================================================================
  RzDesignEditors Unit

  Raize Components - Design Editor Source Unit

  Copyright © 1995-2007 by Raize Software, Inc.  All Rights Reserved.


  Design Editors
  ---------------------------------------------------------------------------
  TRzComponentEditor
    TComponentEditor descendant--implements EditPropertyByName and
    MenuBitmapResourceName methods.

  TRzDefaultEditor
    TDefaultEditor descendant--implements EditPropertyByName and
    MenuBitmapResourceName methods.

  TRzFrameControllerEditor
    Adds context menu to quickly change all connected controls to underline
    style.

  TRzStatusBarEditor
    Adds context menu to quickly add status panes.

  TRzGroupBoxEditor
    Adds context menu to TRzGroupBox to quickly change styles

  TRzPageControlEditor
    Adds context menu to add new pages, and to cycle through existing pages.

  TRzTabControlEditor
    Adds context menu to cycle through existing tabs.

  TRzSizePanelEditor
    Adds context menu to TRzSizePanel component.

  TRzCheckBoxEditor
    Adds context menu to set Checked property.

  TRzRadioButtonEditor
    Adds context menu to set Checked property.

  TRzMemoEditor
    Adds context menu to TRzMemo component.

  TRzRichEditEditor
    Adds context menu to TRzRichEdit component.

  TRzListBoxEditor
    Adds context menu to TRzListBox component.

  TRzRankListBoxEditor
    Adds context menu to TRzRankListBox component.

  TRzMRUComboBoxEditor
    Adds context menu to TRzMRUComboBox component.

  TRzImageComboBoxEditor
    Adds context menu to TRzImageComboBox component.

  TRzListViewEditor
    Adds context menu to TRzListView component.

  TRzTreeViewEditor
    Adds context menu to TRzTreeView component.

  TRzCheckTreeEditor
    Adds context menu to TRzCheckTree component.

  TRzBackgroundEditor
    Adds context menu to TRzBackground component.

  TRzTrackBarEditor
    Adds context menu to TRzTrackBar component.

  TRzProgressBarEditor
    Adds context menu to TRzProgressBar component.

  TRzFontListEditor
    Adds context menu to TRzFontComboBox and TRzFontListBox components.

  TRzEditControlEditor
    Adds context menu to TRzEdit component.

  TRzButtonEditEditor
    Adds context menu to TRzButtonEdit component.

  TRzNumericEditEditor
    Adds context menu to TRzNumericEdit component.

  TRzSpinEditEditor
    Adds context menu to TRzSpinEdit component.

  TRzSpinnerEditor
    Adds context menu to TRzSpinner component.

  TRzLookupDialogEditor
    Adds context menu to TRzLookupDialog component.

  TRzDialogButtonsEditor
    Adds context menu to TRzDialogButtons component.

  TRzFormEditor
    Adds context menu to TForm components to quickly add splitters, toolbars,
    status bars, etc.

  TRzFrameEditor
    Adds context menu to TFrame components to quickly add splitters, toolbars,
    status bars, etc.

  TRzDateTimeEditEditor
    Adds context menu to TRzDateTimeEdit component to switch EditType.

  TRzCalendarEditor
    Adds context menu to TRzCalendar component.

  TRzTimePickerEditor
    Adds context menu to TRzTimePicker component.

  TRzColorPickerEditor
    Adds context menu to TRzColorPicker component.

  TRzColorEditEditor
    Adds context menu to TRzColorEdit component.

  TRzLEDDisplayEditor
    Adds context menu to TRzLEDDisplay component.

  TRzStatusPaneEditor
    Adds context menu to TRzStatusPane component.

  TRzGlyphStatusEditor
    Adds context menu to TRzGlyphStatus component.

  TRzMarqueeStatusEditor
    Adds context menu to TRzMarqueeStatus component.

  TRzClockStatusEditor
    Adds context menu to TRzClockStatus component.

  TRzKeyStatusEditor
    Adds context menu to TRzKeyStatus component.

  TRzVersionInfoStatusEditor
    Adds context menu to TRzVersionInfoStatus component.

  TRzResourceStatusEditor
    Adds context menu to TRzResourceStatus component.

  TRzLineEditor
    Adds context menu to TRzLine component.

  TRzCustomColorsEditor
    Adds context menu to TRzCustomColors component.

  TRzShapeButtonEditor
    Adds context menu to TRzShapeButton component.

  TRzFormStateEditor
    Adds context menu to TRzFormState component.

  TRzBorderEditor
    Adds context menu to TRzBorder component.

  TRzTrayIconEditor
    Adds context menu to TRzTrayIcon component.

  TRzAnimatorEditor
    Adds context menu to TRzAnimator component.

  TRzSeparatorEditor
    Adds context menu to TRzSeparator component.

  TRzSpacerEditor
    Adds context menu to TRzSpacer component.

  TRzBalloonHintsEditor
    Adds context menu to TRzBalloonHints component.

  TRzStringGridEditor
    Adds context menu to TRzStringGrid component.

  ----

  TRzFrameStyleProperty
    Displays list of frames styles along with a sample of each style.

  TRzComboBoxTextProperty
    Displays list of strings in the Items property.

  TRzActivePageProperty
    Provides list of available pages on the current TRzPageControl.

  TRzDateTimeFormatProperty
    Provides list of format strings for changing date and time formats.

  TRzClockStatusFormatProperty
    Provides list of format strings for changing date and time format in
    TRzClockStatus.

  TRzDTPFormatProperty
    Provides list of format strings for controlling the display of date and time.

  TRzSpinValueProperty
    Applies Decimals property to new value assigned to Value property.

  TRzSpinnerGlyphProperty
    Prevents the user from editing the old GlyphPlus and GlyphMinus properties
    since we can't remove them from the component.

  TRzFileNameProperty
    Uses common dialog to select a program or file to launch.

  TRzActionProperty
    Displays a list of possible actions (e.g. Open, Explore, Print).

  TRzCustomColorsProperty
    Uses a common Color dialog to specify new custom colors.

  TRzAlignProperty
  TRzBooleanProperty

  TRzPaletteSep
    Empty component used for adding a separator to component palette.


  Modification History
  ------------------------------------------------------------------------------
  4.1    (15 Dec 2006)
    * Added menu items to create Action List, Main Menu, Popup Menu, and Menu
      Controller components to the TForm component editor.
    * Updated TRzSpinValueProperty editor to prevent resetting IntegersOnly to
      True if the user enters an integer value into the Value property while the
      Decimals property non zero.
  ------------------------------------------------------------------------------
  4.0    (23 Dec 2005)
    * Changed ancestor of TRzPageControlSprig and TRzTabSheetSprig from
      TComponentSprig to TWinControlSprig to allow other controls to be dragged
      and dropped onto TRzTabSheets from within the Object TreeView.
    * Simplified designer context menu for TRzStatusBar by moving all status
      panes that can be created into a cascading menu item.
    * Added VisualStyle and GradientColorStyle menu items to designer context
      menu of TRzStatusBar.
    * Re-organized the designer context menus for the TRzFormEditor.
    * Added new "Quick Design Form" menu item to TRzFormEditor. This menu item
      results in a cascading menu with several options for adding several
      controls at once to create certain common styles of forms.
  ------------------------------------------------------------------------------
  3.1    (04 Aug 2005)
    * Added menu item to select new tsBackSlant tab style for the TRzPageControl
      and TRzTabControl components.
  ------------------------------------------------------------------------------
  3.0.10 (26 Dec 2003)
    * Added TRzPageControlSprig and TRzTabSheetSprig classes to handle
      displaying the tab sheets in a TRzPageControl appropriately in the Object
      Tree View.
  ------------------------------------------------------------------------------
  3.0.9  (22 Sep 2003)
    * Added TRzDateTimeFormatProperty editor which handles displaying date and
      time format strings in a dropdown list for TRzDateTimeEdit and
      TRzTimePicker controls.
  ------------------------------------------------------------------------------
  3.0.8  (29 Aug 2003)
    * Fixed problem where Traditional Style context menu item had no effect on a
      TRzGlyphStatus.
    * Fixed problem where TRzFormShape component editor would not update form
      designer of changes.
    * Added "Remove Border" item to TRzBorderEditor.
    * Fixed problem where Show Color Hints and Auto Size menu items for
      TRzColorPicker did not show correct state.
    * Added TRzStringGridEditor.
    * Added "Add a Size Panel" item to TRzFormEditor.
    * Added TRzFrameEditor, which is similar to the TRzFormEditor in that it
      provides a quick way to add various controls to the frame.
    * Added "Add a Group Bar" and "Add a Panel" items to TRzSizePanelEditor.
    * Fixed problem where TRzPageControl tab sheets (TRzTabSheet) were not
      selectable when the page control was created on a TFrame.
    * Added "Show Groups" item to TRzListBoxEditor and to TRzRankListBoxEditor.
  ------------------------------------------------------------------------------
  3.0    (20 Dec 2002)  * Initial release.
===============================================================================}

{$I RzComps.inc}

unit RzDesignEditors;

interface

uses
  {$IFDEF USE_CS}
  CodeSiteLogging,
  {$ENDIF}
  Windows,
  Classes,
  Controls,
  Graphics,
  ImgList,
  Menus,
  Forms,
  ExtCtrls,
  ActnList,
  {$IFDEF VCL60_OR_HIGHER}
  DesignIntf,
  DesignEditors,
  VCLEditors,
  VCLSprigs,
  DesignMenus,
  TreeIntf,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  RzCommon,
  RzEdit,
  RzStatus,
  RzLabel,
  RzLstBox,
  RzLine,
  RzTabs,
  RzRadChk,
  RzCmboBx,
  RzPanel,
  RzSplit,
  RzListVw,
  RzTreeVw,
  RzDlgBtn,
  RzBckgnd,
  RzBorder,
  RzTrkBar,
  RzPrgres,
  RzBtnEdt,
  RzSpnEdt,
  RzTray,
  RzForms,
  RzPopups,
  RzAnimtr,
  RzBHints,
  RzGrids;

const
  ppRaizePanels  = 'Raize Panels';
  ppRaizeEdits   = 'Raize Edits';
  ppRaizeLists   = 'Raize Lists';
  ppRaizeButtons = 'Raize Buttons';
  ppRaizeDisplay = 'Raize Display';
  ppRaizeShell   = 'Raize Shell';
  ppRaizeWidgets = 'Raize Widgets';

  RC_SettingsKey = 'Software\Raize\Raize Components\4.0';
  RegisterSection = 'Register';

type
  {== Base Component Editors ==================================================}

  {==========================================}
  {== TRzComponentEditor Class Declaration ==}
  {==========================================}

  TRzComponentEditor = class( TComponentEditor )
  private
    FPropName: string;
    FContinue: Boolean;
    {$IFDEF VCL60_OR_HIGHER}
    FPropEditor: IProperty;
    procedure EnumPropertyEditors( const PropertyEditor: IProperty );
    procedure TestPropertyEditor( const PropertyEditor: IProperty;
                                  var Continue: Boolean );
    {$ELSE}
    FPropEditor: TPropertyEditor;
    procedure EnumPropertyEditors( PropertyEditor: TPropertyEditor );
    procedure TestPropertyEditor( PropertyEditor: TPropertyEditor;
                                  var Continue, FreeEditor: Boolean );
    {$ENDIF}
    procedure AlignMenuHandler( Sender: TObject );
    procedure ImageListMenuHandler( Sender: TObject );
    procedure RegIniFileMenuHandler( Sender: TObject );
  protected
    procedure DesignerModified;
    procedure EditPropertyByName( const APropName: string );
    function AlignMenuIndex: Integer; virtual;
    function MenuBitmapResourceName( Index: Integer ): string; virtual;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; virtual;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); virtual;
  public
    {$IFDEF VER13x}
    procedure PrepareItem( Index: Integer; const AItem: TMenuItem ); override;
    {$ENDIF}
    {$IFDEF VCL60_OR_HIGHER}
    procedure PrepareItem( Index: Integer; const AItem: IMenuItem ); override;
    {$ENDIF}
  end;


  {========================================}
  {== TRzDefaultEditor Class Declaration ==}
  {========================================}

  TRzDefaultEditor = class( TDefaultEditor )
  private
    FPropName: string;
    FContinue: Boolean;
    {$IFDEF VCL60_OR_HIGHER}
    FPropEditor: IProperty;
    procedure EnumPropertyEditors( const PropertyEditor: IProperty );
    procedure TestPropertyEditor( const PropertyEditor: IProperty;
                                  var Continue: Boolean );
    {$ELSE}
    FPropEditor: TPropertyEditor;
    procedure EnumPropertyEditors( PropertyEditor: TPropertyEditor );
    procedure TestPropertyEditor( PropertyEditor: TPropertyEditor;
                                  var Continue, FreeEditor: Boolean );
    {$ENDIF}
    procedure AlignMenuHandler( Sender: TObject );
    procedure ImageListMenuHandler( Sender: TObject );
    procedure RegIniFileMenuHandler( Sender: TObject );
  protected
    procedure DesignerModified;
    procedure EditPropertyByName( const APropName: string );
    function AlignMenuIndex: Integer; virtual;
    function MenuBitmapResourceName( Index: Integer ): string; virtual;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; virtual;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); virtual;
  public
    {$IFDEF VER13x}
    procedure PrepareItem( Index: Integer; const AItem: TMenuItem ); override;
    {$ENDIF}
    {$IFDEF VCL60_OR_HIGHER}
    procedure PrepareItem( Index: Integer; const AItem: IMenuItem ); override;
    {$ENDIF}
  end;


  {== Component Editors =======================================================}

  {================================================}
  {== TRzFrameControllerEditor Class Declaration ==}
  {================================================}

  TRzFrameControllerEditor = class( TRzComponentEditor )
  protected
    function FrameController: TRzFrameController;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzStatusBarEditor Class Declaration ==}
  {==========================================}

  TRzStatusBarEditor = class( TRzComponentEditor )
  protected
    function StatusBar: TRzStatusBar;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure AddPaneMenuHandler( Sender: TObject );
    procedure VisualStyleMenuHandler( Sender: TObject );
    procedure GradientColorStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure Edit; override;
  end;


  {=========================================}
  {== TRzGroupBoxEditor Class Declaration ==}
  {=========================================}

  TRzGroupBoxEditor = class( TRzDefaultEditor )
  protected
    function GroupBox: TRzGroupBox;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure GroupStyleMenuHandler( Sender: TObject );
    procedure VisualStyleMenuHandler( Sender: TObject );
    procedure GradientColorStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
  end;


  {============================================}
  {== TRzPageControlEditor Class Declaration ==}
  {============================================}

  TRzPageControlEditor = class( TRzDefaultEditor )
  protected
    function PageControl: TRzPageControl;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure StyleMenuHandler( Sender: TObject );
    procedure OrientationMenuHandler( Sender: TObject );
    procedure ImageListMenuHandler( Sender: TObject );
    procedure AlignMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;

  {$IFDEF VCL60_OR_HIGHER}

  TRzPageControlSprig = class( TWinControlSprig )
  public
    constructor Create( AItem: TPersistent ); override;
    function SortByIndex: Boolean; override;
  end;


  TRzTabSheetSprig = class( TWinControlSprig )
  public
    constructor Create( AItem: TPersistent ); override;
    function Caption: string; override;
    function ItemIndex: Integer; override;
    function Hidden: Boolean; override;
  end;

  {$ENDIF}

  {===========================================}
  {== TRzTabControlEditor Class Declaration ==}
  {===========================================}

  TRzTabControlEditor = class( TRzDefaultEditor )
  private
    procedure Skip( Next: Boolean );
  protected
    function TabControl: TRzTabControl;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure StyleMenuHandler( Sender: TObject );
    procedure OrientationMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzSizePanelEditor Class Declaration ==}
  {==========================================}

  TRzSizePanelEditor = class( TRzComponentEditor )
  protected
    function SizePanel: TRzSizePanel;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzCheckBoxEditor Class Declaration ==}
  {=========================================}

  TRzCheckBoxEditor = class( TRzDefaultEditor )
  protected
    function CheckBox: TRzCheckBox;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzRadioButtonEditor Class Declaration ==}
  {============================================}

  TRzRadioButtonEditor = class( TRzDefaultEditor )
  protected
    function RadioButton: TRzRadioButton;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=====================================}
  {== TRzMemoEditor Class Declaration ==}
  {=====================================}

  TRzMemoEditor = class( TRzDefaultEditor )
  protected
    function GetWordWrap: Boolean; virtual;
    procedure SetWordWrap( Value: Boolean ); virtual;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;

    property WordWrap: Boolean
      read GetWordWrap
      write SetWordWrap;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzRichEditEditor Class Declaration ==}
  {=========================================}

  TRzRichEditEditor = class( TRzMemoEditor )
  protected
    function GetWordWrap: Boolean; override;
    procedure SetWordWrap( Value: Boolean ); override;
  end;


  {========================================}
  {== TRzListBoxEditor Class Declaration ==}
  {========================================}

  TRzListBoxEditor = class( TRzDefaultEditor )
  protected
    function ListBox: TRzListBox;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzRankListBoxEditor Class Declaration ==}
  {============================================}

  TRzRankListBoxEditor = class( TRzDefaultEditor )
  protected
    function ListBox: TRzRankListBox;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzMRUComboBoxEditor Class Declaration ==}
  {============================================}

  TRzMRUComboBoxEditor = class( TRzDefaultEditor )
  protected
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==============================================}
  {== TRzImageComboBoxEditor Class Declaration ==}
  {==============================================}

  TRzImageComboBoxEditor = class( TRzDefaultEditor )
  protected
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
  end;


  {=========================================}
  {== TRzListViewEditor Class Declaration ==}
  {=========================================}

  TRzListViewEditor = class( TRzDefaultEditor )
  protected
    function ListView: TRzListView;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ViewStyleMenuHandler( Sender: TObject );
    procedure SmallImagesMenuHandler( Sender: TObject );
    procedure LargeImagesMenuHandler( Sender: TObject );
    procedure StateImagesMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzTreeViewEditor Class Declaration ==}
  {=========================================}

  TRzTreeViewEditor = class( TRzComponentEditor )
  protected
    function TreeView: TRzTreeView;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure ImagesMenuHandler( Sender: TObject );
    procedure StateImagesMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzCheckTreeEditor Class Declaration ==}
  {==========================================}

  TRzCheckTreeEditor = class( TRzTreeViewEditor )
  protected
    function CheckTree: TRzCheckTree;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;

  {===========================================}
  {== TRzBackgroundEditor Class Declaration ==}
  {===========================================}

  TRzBackgroundEditor = class( TRzDefaultEditor )
  protected
    function Background: TRzBackground;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure GradientDirectionMenuHandler( Sender: TObject );
    procedure ImageStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzTrackBarEditor Class Declaration ==}
  {=========================================}

  TRzTrackBarEditor = class( TRzDefaultEditor )
  protected
    function TrackBar: TRzTrackBar;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ThumbStyleMenuHandler( Sender: TObject );
    procedure TickStepMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzProgressBarEditor Class Declaration ==}
  {============================================}

  TRzProgressBarEditor = class( TRzDefaultEditor )
  protected
    function ProgressBar: TRzProgressBar;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzFontListEditor Class Declaration ==}
  {=========================================}

  TRzFontListEditor = class( TRzDefaultEditor )
  protected
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ShowStyleMenuHandler( Sender: TObject );
    procedure FontTypeMenuHandler( Sender: TObject );
    procedure FontDeviceMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzEditControlEditor Class Declaration ==}
  {============================================}

  TRzEditControlEditor = class( TRzDefaultEditor )
  protected
    function EditControl: TRzCustomEdit;
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===========================================}
  {== TRzButtonEditEditor Class Declaration ==}
  {===========================================}

  TRzButtonEditEditor = class( TRzDefaultEditor )
  protected
    function ButtonEdit: TRzButtonEdit;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ButtonKindMenuHandler( Sender: TObject );
    procedure AltBtnKindMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzNumericEditEditor Class Declaration ==}
  {============================================}

  TRzNumericEditEditor = class( TRzDefaultEditor )
  protected
    function NumericEdit: TRzNumericEdit;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzSpinEditEditor Class Declaration ==}
  {=========================================}

  TRzSpinEditEditor = class( TRzDefaultEditor )
  protected
    function SpinEdit: TRzSpinEdit;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure DirectionMenuHandler( Sender: TObject );
    procedure OrientationMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzSpinButtonsEditor Class Declaration ==}
  {============================================}

  TRzSpinButtonsEditor = class( TRzDefaultEditor )
  protected
    function SpinButtons: TRzSpinButtons;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure DirectionMenuHandler( Sender: TObject );
    procedure OrientationMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {========================================}
  {== TRzSpinnerEditor Class Declaration ==}
  {========================================}

  TRzSpinnerEditor = class( TRzDefaultEditor )
  protected
    function Spinner: TRzSpinner;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=============================================}
  {== TRzLookupDialogEditor Class Declaration ==}
  {=============================================}

  TRzLookupDialogEditor = class( TRzComponentEditor )
  protected
    function MenuBitmapResourceName( Index: Integer ): string; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==============================================}
  {== TRzDialogButtonsEditor Class Declaration ==}
  {==============================================}

  TRzDialogButtonsEditor = class( TRzDefaultEditor )
  protected
    function DialogButtons: TRzDialogButtons;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=====================================}
  {== TRzFormEditor Class Declaration ==}
  {=====================================}

  TRzFormEditor = class( TRzDefaultEditor )
  protected
    function Form: TForm;
    {$IFNDEF VCL60_OR_HIGHER}
    function MenuBitmapResourceName( Index: Integer ): string; override;
    {$ENDIF}
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    {$IFDEF VCL60_OR_HIGHER}
    procedure QuickDesignFormMenuHandler( Sender: TObject );
    procedure AddControlMenuHandler( Sender: TObject );
    procedure AddComponentMenuHandler( Sender: TObject );
    {$ENDIF}
    procedure UIStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    {$IFNDEF VCL60_OR_HIGHER}
    procedure ExecuteVerb( Index: Integer ); override;
    {$ENDIF}
  end;


  {======================================}
  {== TRzFrameEditor Class Declaration ==}
  {======================================}

  TRzFrameEditor = class( TRzDefaultEditor )
  protected
    function Frame: TFrame;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure StyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=============================================}
  {== TRzDateTimeEditEditor Class Declaration ==}
  {=============================================}

  TRzDateTimeEditEditor = class( TRzDefaultEditor )
  protected
    function DateTimeEdit: TRzDateTimeEdit;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ElementsMenuHandler( Sender: TObject );
    procedure FirstDayOfWeekMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzCalendarEditor Class Declaration ==}
  {=========================================}

  TRzCalendarEditor = class( TRzDefaultEditor )
  protected
    function Calendar: TRzCalendar;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ElementsMenuHandler( Sender: TObject );
    procedure FirstDayOfWeekMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===========================================}
  {== TRzTimePickerEditor Class Declaration ==}
  {===========================================}

  TRzTimePickerEditor = class( TRzDefaultEditor )
  protected
    function TimePicker: TRzTimePicker;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;



  {============================================}
  {== TRzColorPickerEditor Class Declaration ==}
  {============================================}

  TRzColorPickerEditor = class( TRzDefaultEditor )
  protected
    function ColorPicker: TRzColorPicker;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure CustomColorsMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzColorEditEditor Class Declaration ==}
  {==========================================}

  TRzColorEditEditor = class( TRzDefaultEditor )
  protected
    function ColorEdit: TRzColorEdit;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure CustomColorsMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===========================================}
  {== TRzLEDDisplayEditor Class Declaration ==}
  {===========================================}

  TRzLEDDisplayEditor = class( TRzDefaultEditor )
  protected
    function LEDDisplay: TRzLEDDisplay;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===========================================}
  {== TRzStatusPaneEditor Class Declaration ==}
  {===========================================}

  TRzStatusPaneEditor = class( TRzComponentEditor )
  protected
    function FlatStyleMenuIndex: Integer; virtual;
    function TraditionalStyleMenuIndex: Integer; virtual;
    function AutoSizeMenuIndex: Integer; virtual;
    function AlignmentMenuIndex: Integer; virtual;
    function BlinkingMenuIndex: Integer; virtual;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure AlignmentMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzGlyphStatusEditor Class Declaration ==}
  {============================================}

  TRzGlyphStatusEditor = class( TRzStatusPaneEditor )
  protected
    function GlyphStatus: TRzGlyphStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure GlyphAlignmentMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==============================================}
  {== TRzMarqueeStatusEditor Class Declaration ==}
  {==============================================}

  TRzMarqueeStatusEditor = class( TRzStatusPaneEditor )
  protected
    function MarqueeStatus: TRzMarqueeStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzClockStatusEditor Class Declaration ==}
  {============================================}

  TRzClockStatusEditor = class( TRzStatusPaneEditor )
  protected
    function ClockStatus: TRzClockStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ClockMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
  end;


  {==========================================}
  {== TRzKeyStatusEditor Class Declaration ==}
  {==========================================}

  TRzKeyStatusEditor = class( TRzStatusPaneEditor )
  protected
    function KeyStatus: TRzKeyStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==================================================}
  {== TRzVersionInfoStatusEditor Class Declaration ==}
  {==================================================}

  TRzVersionInfoStatusEditor = class( TRzStatusPaneEditor )
  protected
    function VersionInfoStatus: TRzVersionInfoStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure VersionInfoMenuHandler( Sender: TObject );
    procedure FieldMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
  end;


  {===============================================}
  {== TRzResourceStatusEditor Class Declaration ==}
  {===============================================}

  TRzResourceStatusEditor = class( TRzStatusPaneEditor )
  protected
    function ResourceStatus: TRzResourceStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===============================================}
  {== TRzProgressStatusEditor Class Declaration ==}
  {===============================================}

  TRzProgressStatusEditor = class( TRzStatusPaneEditor )
  protected
    function ProgressStatus: TRzProgressStatus;
    function FlatStyleMenuIndex: Integer; override;
    function TraditionalStyleMenuIndex: Integer; override;
    function AutoSizeMenuIndex: Integer; override;
    function AlignmentMenuIndex: Integer; override;
    function BlinkingMenuIndex: Integer; override;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;

  
  
  {=====================================}
  {== TRzLineEditor Class Declaration ==}
  {=====================================}

  TRzLineEditor = class( TRzComponentEditor )
  protected
    function Line: TRzLine;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ShowArrowsMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=============================================}
  {== TRzCustomColorsEditor Class Declaration ==}
  {=============================================}

  TRzCustomColorsEditor = class( TRzComponentEditor )
  protected
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {============================================}
  {== TRzShapeButtonEditor Class Declaration ==}
  {============================================}

  TRzShapeButtonEditor = class( TRzDefaultEditor )
  protected
    function MenuBitmapResourceName( Index: Integer ): string; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzFormStateEditor Class Declaration ==}
  {==========================================}

  TRzFormStateEditor = class( TRzComponentEditor )
  protected
    function FormState: TRzFormState;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
  end;


  {==========================================}
  {== TRzFormShapeEditor Class Declaration ==}
  {==========================================}

  TRzFormShapeEditor = class( TRzComponentEditor )
  protected
    function FormShape: TRzFormShape;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=======================================}
  {== TRzBorderEditor Class Declaration ==}
  {=======================================}

  TRzBorderEditor = class( TRzDefaultEditor )
  protected
    function Border: TRzBorder;
    function AlignMenuIndex: Integer; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ): string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzTrayIconEditor Class Declaration ==}
  {=========================================}

  TRzTrayIconEditor = class( TRzComponentEditor )
  protected
    function TrayIcon: TRzTrayIcon;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure IconsMenuHandler( Sender: TObject );
    procedure PopupMenuMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=========================================}
  {== TRzAnimatorEditor Class Declaration ==}
  {=========================================}

  TRzAnimatorEditor = class( TRzComponentEditor )
  protected
    function Animator: TRzAnimator;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    function GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                             var CompRefPropName: string;
                             var CompRefMenuHandler: TNotifyEvent ): Boolean; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ImageListMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzSeparatorEditor Class Declaration ==}
  {==========================================}

  TRzSeparatorEditor = class( TRzComponentEditor )
  protected
    function Separator: TRzSeparator;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure HighlightLocationMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=======================================}
  {== TRzSpacerEditor Class Declaration ==}
  {=======================================}

  TRzSpacerEditor = class( TRzComponentEditor )
  protected
    function Spacer: TRzSpacer;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {=============================================}
  {== TRzBalloonHintsEditor Class Declaration ==}
  {=============================================}

  TRzBalloonHintsEditor = class( TRzComponentEditor )
  protected
    function BalloonHints: TRzBalloonHints;
    function MenuBitmapResourceName( Index: Integer ): string; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure CornerMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {===========================================}
  {== TRzStringGridEditor Class Declaration ==}
  {===========================================}

  TRzStringGridEditor = class( TRzDefaultEditor )
  protected
    function Grid: TRzStringGrid;
    function AlignMenuIndex: Integer; override;
    function MenuBitmapResourceName( Index: Integer ): string; override;
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {$IFDEF VCL100_OR_HIGHER}

  {==========================================}
  {== TRzFlowPanelEditor Class Declaration ==}
  {==========================================}

  TRzFlowPanelEditor = class( TRzDefaultEditor )
  protected
    function FlowPanel: TRzFlowPanel;
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure FlowStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;


  {==========================================}
  {== TRzGridPanelEditor Class Declaration ==}
  {==========================================}

  TRzGridPanelEditor = class( TRzDefaultEditor )
  protected
    function GridPanel: TRzGridPanel;
    function AlignMenuIndex: Integer; override;
    procedure PrepareMenuItem( Index: Integer; const Item: TMenuItem ); override;
    procedure ExpandStyleMenuHandler( Sender: TObject );
  public
    function GetVerbCount: Integer; override;
    function GetVerb( Index: Integer ) : string; override;
    procedure ExecuteVerb( Index: Integer ); override;
  end;

  {$ENDIF}


  {== Property Editors ========================================================}

  {=============================================}
  {== TRzFrameStyleProperty Class Declaration ==}
  {=============================================}

  {$IFDEF VCL60_OR_HIGHER}

  TRzFrameStyleProperty = class( TEnumProperty, ICustomPropertyDrawing, ICustomPropertyListDrawing )
  private
    FDrawingPropertyValue: Boolean;
  public
    // ICustomPropertyListDrawing
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer );
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer );
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean );

    // ICustomPropertyDrawing
    procedure PropDrawName( ACanvas: TCanvas; const ARect: TRect;
                            ASelected: Boolean );
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean );
  end;


  TRzAlignProperty = class( TEnumProperty, ICustomPropertyDrawing, ICustomPropertyListDrawing )
  private
    FDrawingPropertyValue: Boolean;
  public
    // ICustomPropertyListDrawing
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer );
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer );
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean );

    // ICustomPropertyDrawing
    procedure PropDrawName( ACanvas: TCanvas; const ARect: TRect;
                            ASelected: Boolean );
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean );
  end;

  TRzBooleanProperty = class( TEnumProperty, ICustomPropertyDrawing, ICustomPropertyListDrawing )
  public
    // ICustomPropertyListDrawing
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer );
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer );
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean );

    // ICustomPropertyDrawing
    procedure PropDrawName( ACanvas: TCanvas; const ARect: TRect;
                            ASelected: Boolean );
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean );
  end;

  {$ENDIF}

  {$IFDEF VER13x}

  TRzFrameStyleProperty = class( TEnumProperty )
  private
    FDrawingPropertyValue: Boolean;
  public
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer ); override;
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer ); override;
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean ); override;
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean ); override;
  end;

  TRzAlignProperty = class( TEnumProperty )
  private
    FDrawingPropertyValue: Boolean;
  public
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer ); override;
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer ); override;
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean ); override;
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean ); override;
  end;

  TRzBooleanProperty = class( TEnumProperty )
  public
    procedure ListMeasureHeight( const Value: string; ACanvas: TCanvas;
                                 var AHeight: Integer ); override;
    procedure ListMeasureWidth( const Value: string; ACanvas: TCanvas;
                                var AWidth: Integer ); override;
    procedure ListDrawValue( const Value: string; ACanvas: TCanvas;
                             const ARect: TRect; ASelected: Boolean ); override;
    procedure PropDrawValue( ACanvas: TCanvas; const ARect: TRect;
                             ASelected: Boolean ); override;
  end;

  {$ENDIF}


  {=============================================}
  {== TRzActivePageProperty Class Declaration ==}
  {=============================================}

  TRzActivePageProperty = class( TComponentProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues( Proc: TGetStrProc ); override;
  end;


  {=================================================}
  {== TRzDateTimeFormatProperty Class Declaration ==}
  {=================================================}

  TRzDateTimeFormatFilter = ( ffAll, ffDates, ffTimes );

  TRzDateTimeFormatProperty = class( TStringProperty )
  protected
    function FormatFilter: TRzDateTimeFormatFilter; virtual;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues( Proc: TGetStrProc ); override;
  end;


  {====================================================}
  {== TRzClockStatusFormatProperty Class Declaration ==}
  {====================================================}

  TRzClockStatusFormatProperty = class( TRzDateTimeFormatProperty )
  protected
    function FormatFilter: TRzDateTimeFormatFilter; override;
  end;


  {============================================}
  {== TRzDTPFormatProperty Class Declaration ==}
  {============================================}

  TRzDTPFormatProperty = class( TStringProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues( Proc: TGetStrProc ); override;
  end;


  {============================================}
  {== TRzSpinValueProperty Class Declaration ==}
  {============================================}

  TRzSpinValueProperty = class( TFloatProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure SetValue( const Value: string ); override;
  end;


  {===============================================}
  {== TRzSpinnerGlyphProperty Class Declaration ==}
  {===============================================}

  TRzSpinnerGlyphProperty = class( TFloatProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;


  {===========================================}
  {== TRzFileNameProperty Class Declaration ==}
  {===========================================}

  TRzFileNameProperty = class( TStringProperty )
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;


  {=========================================}
  {== TRzActionProperty Class Declaration ==}
  {=========================================}

  TRzActionProperty = class( TStringProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues( Proc: TGetStrProc ); override;
  end;


  {===============================================}
  {== TRzCustomColorsProperty Class Declaration ==}
  {===============================================}

  TRzCustomColorsProperty = class( TClassProperty )
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;


  {== Category Classes ========================================================}

  {$IFDEF VER13x}

  TRzCustomFramingCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzHotSpotCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzBorderStyleCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzCustomGlyphsCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzTextStyleCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzTrackStyleCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzPrimaryButtonCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzAlternateButtonCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  TRzSplitterCategory = class( TPropertyCategory )
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

  {$ENDIF}


  {$IFDEF VCL100_OR_HIGHER}

  {== Designer Guidelines =====================================================}

  TRzCustomButtonGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;
  
  TRzButtonGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;
  
  TRzToolButtonGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  TRzCaptionGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  TRzLabelGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  TRzPanelGuidelines = class( TControlGuidelines )
  protected
    function GetCount: Integer; override;
    function GetDesignerGuideType(Index: Integer): TDesignerGuideType; override;
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  TRzPageControlGuidelines = class( TControlGuidelines )
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  TRzTabControlGuidelines = class( TControlGuidelines )
    function GetDesignerGuideOffset(Index: Integer): Integer; override;
  end;

  {$ENDIF}


{$IFDEF VCL60_OR_HIGHER}
resourcestring
  sRzCustomFramingCategoryName = 'Custom Framing';
  sRzHotSpotCategoryName = 'HotSpot';
  sRzBorderStyleCategoryName = 'Border Style';
  sRzCustomGlyphsCategoryName = 'Custom Glyphs';
  sRzTextStyleCategoryName = 'Text Style';
  sRzTrackStyleCategoryName = 'Track Style';
  sRzPrimaryButtonCategoryName = 'Button - Primary';
  sRzAlternateButtonCategoryName = 'Button - Alternate';
  sRzSplitterCategoryName = 'Splitter Style';
{$ENDIF}


type
  TRzPaletteSep = class( TComponent )
  public
    constructor Create( AOwner: TComponent ); override;
  end;

  TRzPaletteSep_Panels = class( TRzPaletteSep );
  TRzPaletteSep_Edits = class( TRzPaletteSep );
  TRzPaletteSep_Lists = class( TRzPaletteSep );
  TRzPaletteSep_Buttons = class( TRzPaletteSep );
  TRzPaletteSep_Display = class( TRzPaletteSep );
  TRzPaletteSep_Shell = class( TRzPaletteSep );
  TRzPaletteSep_Widgets = class( TRzPaletteSep );


function UniqueName( AComponent: TComponent ): string;

procedure CreateVisualStyleMenuItem( Item: TMenuItem;
                                     VisualStyle, CurrentVisualStyle: TRzVisualStyle;
                                     EventHandler: TNotifyEvent );

procedure CreateGradientColorStyleMenuItem( Item: TMenuItem;
                                            GradientColorStyle, CurrentGradientColorStyle: TRzGradientColorStyle;
                                            EventHandler: TNotifyEvent );

procedure CreateGroupStyleMenuItem( Item: TMenuItem;
                                    GroupStyle, CurrentGroupStyle: TRzGroupBoxStyle;
                                    EventHandler: TNotifyEvent );

implementation

uses
  SysUtils,
  TypInfo,
  StdCtrls,
  ComCtrls,
  Dialogs,
  RzGrafx,
  RzButton,
  RzLookup,
  RzRadGrp,
  RzGroupBar;

{$R RzDesignEditors.res}    // Link in  bitmaps for component editors


{=====================}
{== Support Methods ==}
{=====================}

// There is no UniqueName method for TFormDesigner in Delphi 1, so we need our
// own equivalent.  The local UniqueName function is also used for Delphi 2/3
// because it makes the names nicer by removing the 'cs' prefix normally
// included (by TFormDesigner.UniqueName) for objects of type TRzTabSheet.

// Test a component name for uniqueness and return True if it is unique or False
// if there is another component with the same name.

function TryName( const AName: string; AComponent: TComponent ): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AComponent.ComponentCount - 1 do
  begin
    if CompareText( AComponent.Components[ I ].Name, AName ) = 0 then
      Exit;
  end;
  Result := True;
end;


// Generate a unique name for a component.  Use the standard Delphi rules,
// e.g., <type><number>, where <type> is the component's class name without
// a leading 'T', and <number> is an integer to make the name unique.

function UniqueName( AComponent: TComponent ): string;
var
  I: Integer;
  Fmt: string;
begin
  // Create a Format string to use as a name template.
  if CompareText( Copy( AComponent.ClassName, 1, 3 ), 'TRz' ) = 0 then
    Fmt := Copy( AComponent.ClassName, 4, 255 ) + '%d'
  else
    Fmt := AComponent.ClassName + '%d';

  if AComponent.Owner = nil then
  begin
    // No owner; any name is unique. Use 1.
    Result := Format( Fmt, [ 1 ] );
    Exit;
  end
  else
  begin
    // Try all possible numbers until we find a unique name.
    for I := 1 to High( Integer ) do
    begin
      Result := Format( Fmt, [ I ] );
      if TryName( Result, AComponent.Owner ) then
        Exit;
    end;
  end;

  // This should never happen, but just in case...
  raise Exception.CreateFmt('Cannot create unique name for %s.', [ AComponent.ClassName ] );
end;


{======================================}
{== CreateVisualStyleMenuItem Method ==}
{======================================}

procedure CreateVisualStyleMenuItem( Item: TMenuItem;
                                     VisualStyle, CurrentVisualStyle: TRzVisualStyle;
                                     EventHandler: TNotifyEvent );
var
  NewItem: TMenuItem;
begin
  NewItem := TMenuItem.Create( Item );
  case VisualStyle of
    vsClassic:  NewItem.Caption := 'Classic';
    vsWinXP:    NewItem.Caption := 'WinXP';
    vsGradient: NewItem.Caption := 'Gradient';
  end;
  NewItem.Tag := Ord( VisualStyle );
  NewItem.Checked := CurrentVisualStyle = VisualStyle;
  NewItem.OnClick := EventHandler;
  Item.Add( NewItem );
end;


{=============================================}
{== CreateGradientColorStyleMenuItem Method ==}
{=============================================}

procedure CreateGradientColorStyleMenuItem( Item: TMenuItem;
                                            GradientColorStyle, CurrentGradientColorStyle: TRzGradientColorStyle;
                                            EventHandler: TNotifyEvent );
var
  NewItem: TMenuItem;
begin
  NewItem := TMenuItem.Create( Item );
  case GradientColorStyle of
    gcsSystem:   NewItem.Caption := 'System';
    gcsMSOffice: NewItem.Caption := 'MS Office';
    gcsCustom:   NewItem.Caption := 'Custom';
  end;
  NewItem.Tag := Ord( GradientColorStyle );
  NewItem.Checked := CurrentGradientColorStyle = GradientColorStyle;
  NewItem.OnClick := EventHandler;
  Item.Add( NewItem );
end;


{=====================================}
{== CreateGroupStyleMenuItem Method ==}
{=====================================}

procedure CreateGroupStyleMenuItem( Item: TMenuItem;
                                    GroupStyle, CurrentGroupStyle: TRzGroupBoxStyle;
                                    EventHandler: TNotifyEvent );
var
  NewItem: TMenuItem;
begin
  NewItem := TMenuItem.Create( Item );
  NewItem.Tag := Ord( GroupStyle );
  NewItem.Checked := CurrentGroupStyle = GroupStyle;
  case GroupStyle of
    gsStandard:
    begin
      NewItem.Caption := 'Standard';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_STANDARD' );
    end;

    gsCustom:
    begin
      NewItem.Caption := 'Custom';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_CUSTOM' );
    end;

    gsTopLine:
    begin
      NewItem.Caption := 'Top Line';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_TOPLINE' );
    end;

    gsFlat:
    begin
      NewItem.Caption := 'Flat';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_FLAT' );
    end;

    gsBanner:
    begin
      NewItem.Caption := 'Banner';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_BANNER' );
    end;

    gsUnderline:
    begin
      NewItem.Caption := 'Underline';
      NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBOX_UNDERLINE' );
    end;
  end;
  NewItem.OnClick := EventHandler;
  Item.Add( NewItem );
end;



{== Base Component Editors ====================================================}

{================================}
{== TRzComponentEditor Methods ==}
{================================}

{$IFDEF VCL60_OR_HIGHER}

procedure TRzComponentEditor.EnumPropertyEditors( const PropertyEditor: IProperty );
begin
  if FContinue then
    TestPropertyEditor( PropertyEditor, FContinue );
end;


procedure TRzComponentEditor.TestPropertyEditor( const PropertyEditor: IProperty;
                                                 var Continue: Boolean );
begin
  if not Assigned( FPropEditor ) and
     ( CompareText( PropertyEditor.GetName, FPropName ) = 0 ) then
  begin
    Continue := False;
    FPropEditor := PropertyEditor;
  end;
end;


procedure TRzComponentEditor.EditPropertyByName( const APropName: string );
var
  Components: IDesignerSelections;
begin
  Components := TDesignerSelections.Create;
  FContinue := True;
  FPropName := APropName;
  Components.Add( Component );
  FPropEditor := nil;
  try
    GetComponentProperties( Components, tkAny, Designer, EnumPropertyEditors );
    if Assigned( FPropEditor ) then
      FPropEditor.Edit;
  finally
    FPropEditor := nil;
  end;
end;

{$ELSE}

procedure TRzComponentEditor.EnumPropertyEditors( PropertyEditor: TPropertyEditor );
var
  FreeEditor: Boolean;
begin
  FreeEditor := True;
  try
    if FContinue then
      TestPropertyEditor( PropertyEditor, FContinue, FreeEditor );
  finally
    if FreeEditor then
      PropertyEditor.Free;
  end;
end;


procedure TRzComponentEditor.TestPropertyEditor( PropertyEditor: TPropertyEditor;
                                                 var Continue, FreeEditor: Boolean );
begin
  if not Assigned( FPropEditor ) and
     ( CompareText( PropertyEditor.GetName, FPropName ) = 0 ) then
  begin
    FreeEditor := False;
    Continue := False;
    FPropEditor := PropertyEditor;
  end;
end;


procedure TRzComponentEditor.EditPropertyByName( const APropName: string );
var
  Components: TDesignerSelectionList;
begin
  Components := TDesignerSelectionList.Create;
  try
    FContinue := True;
    FPropName := APropName;
    Components.Add( Component );
    FPropEditor := nil;
    try
      GetComponentProperties( Components, tkAny, Designer, EnumPropertyEditors );
      if Assigned( FPropEditor ) then
        FPropEditor.Edit;
    finally
      if Assigned( FPropEditor ) then
        FPropEditor.Free;
    end;
  finally
    Components.Free;
  end;
end;

{$ENDIF}


procedure TRzComponentEditor.DesignerModified;
begin
  if Designer <> nil then
    Designer.Modified;
end;


function TRzComponentEditor.AlignMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzComponentEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := '';
end;


function TRzComponentEditor.GetCompRefData( Index: Integer;
                                            var CompRefClass: TComponentClass;
                                            var CompRefPropName: string;
                                            var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
end;


procedure TRzComponentEditor.PrepareMenuItem( Index: Integer;
                                              const Item: TMenuItem );
var
  ResName: string;
  I, CompRefCount: Integer;
  CompOwner: TComponent;
  CompRefClass: TComponentClass;
  CompRefPropName: string;
  CompRefMenuHandler: TNotifyEvent;

  procedure CreateAlignItem( AlignValue: TAlign; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( AlignValue );
    NewItem.Checked := TControl( Component ).Align = AlignValue;
    case AlignValue of
      alNone:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_NONE' );
      alTop:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_TOP' );
      alBottom: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_BOTTOM' );
      alLeft:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_LEFT' );
      alRight:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_RIGHT' );
      alClient: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_CLIENT' );
    end;
    NewItem.OnClick := AlignMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateCompRefMenu( CompRef: TComponent; const CompRefPropName: string; CompRefMenuHandler: TNotifyEvent );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.AutoHotkeys := maManual;
    NewItem.Caption := CompRef.Name;
    NewItem.Checked := GetObjectProp( Component, CompRefPropName ) = CompRef;
    NewItem.OnClick := CompRefMenuHandler;
    Item.Add( NewItem );
  end;

begin {= TRzComponentEditor.PrepareMenuItem =}
  // Descendant classes override this method to consistently handle preparing menu items in
  // Delphi 5, Delphi 6 and higher.

  ResName := MenuBitmapResourceName( Index );
  if ResName <> '' then
    Item.Bitmap.LoadFromResourceName( HInstance, ResName );

  if Index = AlignMenuIndex then
  begin
    case TControl( Component ).Align of
      alNone:   Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_NONE' );
      alTop:    Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_TOP' );
      alBottom: Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_BOTTOM' );
      alLeft:   Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_LEFT' );
      alRight:  Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_RIGHT' );
      alClient: Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_CLIENT' );
    end;

    CreateAlignItem( alClient, 'Client' );
    CreateAlignItem( alLeft, 'Left' );
    CreateAlignItem( alTop, 'Top' );
    CreateAlignItem( alRight, 'Right' );
    CreateAlignItem( alBottom, 'Bottom' );
    CreateAlignItem( alNone, 'None' );
  end;

  if GetCompRefData( Index, CompRefClass, CompRefPropName, CompRefMenuHandler ) then
  begin
    Item.AutoHotkeys := maManual;
    CompRefCount := 0;
    CompOwner := Designer.GetRoot;

    if not Assigned( CompRefMenuHandler ) then
    begin
      if CompRefClass = TCustomImageList then
        CompRefMenuHandler := ImageListMenuHandler
      else if CompRefClass = TRzRegIniFile then
        CompRefMenuHandler := RegIniFileMenuHandler;
    end;

    if CompOwner <> nil then
    begin
      for I := 0 to CompOwner.ComponentCount - 1 do
      begin
        if CompOwner.Components[ I ] is CompRefClass then
        begin
          Inc( CompRefCount );
          CreateCompRefMenu( CompOwner.Components[ I ], CompRefPropName,
                             CompRefMenuHandler );
        end;
      end;
    end;
    Item.Enabled := CompRefCount > 0;
  end;

end; {= TRzComponentEditor.PrepareMenuItem =}


{$IFDEF VER13x}

procedure TRzComponentEditor.PrepareItem( Index: Integer; const AItem: TMenuItem );
begin
  PrepareMenuItem( Index, AItem );
end; {= TRzComponentEditor.PrepareItem =}

{$ENDIF}

{$IFDEF VCL60_OR_HIGHER}

procedure TRzComponentEditor.PrepareItem( Index: Integer; const AItem: IMenuItem );
var
  CompRef: IInterfaceComponentReference;
  MenuItem: TMenuItem;
begin
  CompRef := AItem as IInterfaceComponentReference;
  MenuItem := CompRef.GetComponent as TMenuItem;
  PrepareMenuItem( Index, MenuItem );
end;

{$ENDIF}


procedure TRzComponentEditor.AlignMenuHandler( Sender: TObject );
begin
  TControl( Component ).Align := TAlign( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzComponentEditor.ImageListMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'Images', ImageList );
    DesignerModified;
  end;
end;


procedure TRzComponentEditor.RegIniFileMenuHandler( Sender: TObject );
var
  S: string;
  RegIniFile: TRzRegIniFile;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    RegIniFile := Designer.GetRoot.FindComponent( S ) as TRzRegIniFile;
    SetObjectProp( Component, 'RegIniFile', RegIniFile );
    DesignerModified;
  end;
end;


{==============================}
{== TRzDefaultEditor Methods ==}
{==============================}

{$IFDEF VCL60_OR_HIGHER}

procedure TRzDefaultEditor.EnumPropertyEditors( const PropertyEditor: IProperty );
begin
  if FContinue then
    TestPropertyEditor( PropertyEditor, FContinue );
end;


procedure TRzDefaultEditor.TestPropertyEditor( const PropertyEditor: IProperty;
                                               var Continue: Boolean );
begin
  if not Assigned( FPropEditor ) and
     ( CompareText( PropertyEditor.GetName, FPropName ) = 0 ) then
  begin
    Continue := False;
    FPropEditor := PropertyEditor;
  end;
end;


procedure TRzDefaultEditor.EditPropertyByName( const APropName: string );
var
  Components: IDesignerSelections;
begin
  Components := TDesignerSelections.Create;
  FContinue := True;
  FPropName := APropName;
  Components.Add( Component );
  FPropEditor := nil;
  try
    GetComponentProperties( Components, tkAny, Designer, EnumPropertyEditors );
    if Assigned( FPropEditor ) then
      FPropEditor.Edit;
  finally
    FPropEditor := nil;
  end;
end;

{$ELSE}

procedure TRzDefaultEditor.EnumPropertyEditors( PropertyEditor: TPropertyEditor );
var
  FreeEditor: Boolean;
begin
  FreeEditor := True;
  try
    if FContinue then
      TestPropertyEditor( PropertyEditor, FContinue, FreeEditor );
  finally
    if FreeEditor then
      PropertyEditor.Free;
  end;
end;


procedure TRzDefaultEditor.TestPropertyEditor( PropertyEditor: TPropertyEditor;
                                               var Continue, FreeEditor: Boolean );
begin
  if not Assigned( FPropEditor ) and
     ( CompareText( PropertyEditor.GetName, FPropName ) = 0 ) then
  begin
    FreeEditor := False;
    Continue := False;
    FPropEditor := PropertyEditor;
  end;
end;


procedure TRzDefaultEditor.EditPropertyByName( const APropName: string );
var
  Components: TDesignerSelectionList;
begin
  Components := TDesignerSelectionList.Create;
  try
    FContinue := True;
    FPropName := APropName;
    Components.Add( Component );
    FPropEditor := nil;
    try
      GetComponentProperties( Components, tkAny, Designer, EnumPropertyEditors );
      if Assigned( FPropEditor ) then
        FPropEditor.Edit;
    finally
      if Assigned( FPropEditor ) then
        FPropEditor.Free;
    end;
  finally
    Components.Free;
  end;
end;

{$ENDIF}


procedure TRzDefaultEditor.DesignerModified;
begin
  if Designer <> nil then
    Designer.Modified;
end;


function TRzDefaultEditor.AlignMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzDefaultEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := '';
end;


function TRzDefaultEditor.GetCompRefData( Index: Integer;
                                          var CompRefClass: TComponentClass;
                                          var CompRefPropName: string;
                                          var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
end;


procedure TRzDefaultEditor.PrepareMenuItem( Index: Integer;
                                            const Item: TMenuItem );
var
  ResName: string;
  I, CompRefCount: Integer;
  CompOwner: TComponent;
  CompRefClass: TComponentClass;
  CompRefPropName: string;
  CompRefMenuHandler: TNotifyEvent;

  procedure CreateAlignItem( AlignValue: TAlign; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( AlignValue );
    NewItem.Checked := TControl( Component ).Align = AlignValue;
    case AlignValue of
      alNone:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_NONE' );
      alTop:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_TOP' );
      alBottom: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_BOTTOM' );
      alLeft:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_LEFT' );
      alRight:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_RIGHT' );
      alClient: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_CLIENT' );
    end;
    NewItem.OnClick := AlignMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateCompRefMenu( CompRef: TComponent; const CompRefPropName: string;
                               CompRefMenuHandler: TNotifyEvent );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.AutoHotkeys := maManual;
    NewItem.Caption := CompRef.Name;
    NewItem.Checked := GetObjectProp( Component, CompRefPropName ) = CompRef;
    NewItem.OnClick := CompRefMenuHandler;
    Item.Add( NewItem );
  end;

begin {= TRzDefaultEditor.PrepareMenuItem =}
  // Descendant classes override this method to consistently handle preparing
  // menu items in Delphi 5, Delphi 6 and higher.

  ResName := MenuBitmapResourceName( Index );
  if ResName <> '' then
    Item.Bitmap.LoadFromResourceName( HInstance, ResName );

  if Index = AlignMenuIndex then
  begin
    Item.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN' );

    CreateAlignItem( alClient, 'Client' );
    CreateAlignItem( alLeft, 'Left' );
    CreateAlignItem( alTop, 'Top' );
    CreateAlignItem( alRight, 'Right' );
    CreateAlignItem( alBottom, 'Bottom' );
    CreateAlignItem( alNone, 'None' );
  end;

  if GetCompRefData( Index, CompRefClass, CompRefPropName, CompRefMenuHandler ) then
  begin
    Item.AutoHotkeys := maManual;
    CompRefCount := 0;
    CompOwner := Designer.GetRoot;

    if not Assigned( CompRefMenuHandler ) then
    begin
      if CompRefClass = TCustomImageList then
        CompRefMenuHandler := ImageListMenuHandler
      else if CompRefClass = TRzRegIniFile then
        CompRefMenuHandler := RegIniFileMenuHandler;
    end;

    if CompOwner <> nil then
    begin
      for I := 0 to CompOwner.ComponentCount - 1 do
      begin
        if CompOwner.Components[ I ] is CompRefClass then
        begin
          Inc( CompRefCount );
          CreateCompRefMenu( CompOwner.Components[ I ], CompRefPropName,
                             CompRefMenuHandler );
        end;
      end;
    end;
    Item.Enabled := CompRefCount > 0;
  end;

end;


{$IFDEF VER13x}

procedure TRzDefaultEditor.PrepareItem( Index: Integer; const AItem: TMenuItem );
begin
  PrepareMenuItem( Index, AItem );
end;

{$ENDIF}

{$IFDEF VCL60_OR_HIGHER}

procedure TRzDefaultEditor.PrepareItem( Index: Integer; const AItem: IMenuItem );
var
  CompRef: IInterfaceComponentReference;
  MenuItem: TMenuItem;
begin
  CompRef := AItem as IInterfaceComponentReference;
  MenuItem := CompRef.GetComponent as TMenuItem;
  PrepareMenuItem( Index, MenuItem );
end;

{$ENDIF}


procedure TRzDefaultEditor.AlignMenuHandler( Sender: TObject );
begin
  TControl( Component ).Align := TAlign( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzDefaultEditor.ImageListMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'Images', ImageList );
    DesignerModified;
  end;
end;


procedure TRzDefaultEditor.RegIniFileMenuHandler( Sender: TObject );
var
  S: string;
  RegIniFile: TRzRegIniFile;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    RegIniFile := Designer.GetRoot.FindComponent( S ) as TRzRegIniFile;
    SetObjectProp( Component, 'RegIniFile', RegIniFile );
    DesignerModified;
  end;
end;


{== Component Editors =========================================================}


{======================================}
{== TRzFrameControllerEditor Methods ==}
{======================================}

function TRzFrameControllerEditor.FrameController: TRzFrameController;
begin
  Result := Component as TRzFrameController;
end;


function TRzFrameControllerEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzFrameControllerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Frame Visible';
    1: Result := 'Underline Controls';
    2: Result := '-';
    3: Result := 'Set RegIniFile';
  end;
end;


function TRzFrameControllerEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_FRAME_VISIBLE';
    1: Result := 'RZDESIGNEDITORS_FRAME_UNDERLINE';
    3: Result := 'RZDESIGNEDITORS_REGINIFILE';
  end;
end;


function TRzFrameControllerEditor.GetCompRefData( Index: Integer;
                                                  var CompRefClass: TComponentClass;
                                                  var CompRefPropName: string;
                                                  var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 3 then
  begin
    CompRefClass := TRzRegIniFile;
    CompRefPropName := 'RegIniFile';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


procedure TRzFrameControllerEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
    begin
      FrameController.FrameVisible := True;
      DesignerModified;
    end;

    1:
    begin
      FrameController.FrameVisible := True;
      FrameController.FrameSides := [ sdBottom ];
      DesignerModified;
    end;

  end;
end;


{================================}
{== TRzStatusBarEditor Methods ==}
{================================}

function TRzStatusBarEditor.StatusBar: TRzStatusBar;
begin
  Result := Component as TRzStatusBar;
end;


function TRzStatusBarEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzStatusBarEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Add Pane';
    1: Result := '-';
    2: Result := 'Visual Style';
    3: Result := 'Gradient Color Style';
  end;
end;


function TRzStatusBarEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_STATUS';
  end;
end;


procedure TRzStatusBarEditor.PrepareMenuItem( Index: Integer;
                                              const Item: TMenuItem );

  procedure CreateAddPaneMenu( PaneType: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := PaneType;
    case PaneType of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS' );
      1: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_FIELD' );
      2: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_GLYPH' );
      3: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_PROGRESS' );
      4: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_MARQUEE' );
      5: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_CLOCK' );
      6: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_KEY' );
      7: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_RESOURCE' );
      8: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_VERSIONINFO' );
      9: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_DB' );
      10: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUS_DBSTATE' );
    end;
    NewItem.OnClick := AddPaneMenuHandler;
    Item.Add( NewItem );
  end;

begin {= TRzStatusBar.PrepareMenuItem =}
  inherited;

  case Index of
    0: // Add Pane
    begin
      CreateAddPaneMenu( 0, 'Text' );
      CreateAddPaneMenu( 1, 'Field-Label' );
      CreateAddPaneMenu( 2, 'Glyph' );
      CreateAddPaneMenu( 3, 'Progress' );
      CreateAddPaneMenu( 4, 'Marquee' );
      CreateAddPaneMenu( 5, 'Clock' );
      CreateAddPaneMenu( 6, 'Key' );
      CreateAddPaneMenu( 7, 'Resource' );
      CreateAddPaneMenu( 8, 'Version Info' );
      CreateAddPaneMenu( 9, 'Data-Aware' );
      CreateAddPaneMenu( 10, 'DB State' );
    end;

    2: // VisualStyle
    begin
      CreateVisualStyleMenuItem( Item, vsClassic, StatusBar.VisualStyle,
                                 VisualStyleMenuHandler );
      CreateVisualStyleMenuItem( Item, vsWinXP, StatusBar.VisualStyle,
                                 VisualStyleMenuHandler );
      CreateVisualStyleMenuItem( Item, vsGradient, StatusBar.VisualStyle,
                                 VisualStyleMenuHandler );
    end;

    3: // GradientColorStyle
    begin
      CreateGradientColorStyleMenuItem( Item, gcsSystem, StatusBar.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
      CreateGradientColorStyleMenuItem( Item, gcsMSOffice, StatusBar.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
      CreateGradientColorStyleMenuItem( Item, gcsCustom, StatusBar.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
    end;
  end;
end; {= TRzStatusBarEditor.PrepareMenuItem =}


procedure TRzStatusBarEditor.AddPaneMenuHandler( Sender: TObject );
var
  CompOwner: TComponent;
  BaseName: string;
  Ref: TPersistentClass;
  C: TControl;
  {$IFDEF VCL60_OR_HIGHER}
  OldGroup: TPersistentClass;
  {$ENDIF}
begin
  BaseName := 'RzStatusPane';

  {$IFDEF VCL60_OR_HIGHER}
  OldGroup := ActivateClassGroup( TControl );
  try
  {$ENDIF}

  case TMenuItem( Sender ).Tag of
    0: BaseName := 'RzStatusPane';
    1: BaseName := 'RzFieldStatus';
    2: BaseName := 'RzGlyphStatus';
    3: BaseName := 'RzProgressStatus';
    4: BaseName := 'RzMarqueeStatus';
    5: BaseName := 'RzClockStatus';
    6: BaseName := 'RzKeyStatus';
    7: BaseName := 'RzResourceStatus';
    8: BaseName := 'RzVersionInfoStatus';
    9: BaseName := 'RzDBStatusPane';
    10: BaseName := 'RzDBStateStatus';
  end;
  Ref := GetClass( 'T' + BaseName );

  {$IFDEF VCL60_OR_HIGHER}
  finally
    ActivateClassGroup( OldGroup );
  end;
  {$ENDIF}

  CompOwner := Designer.GetRoot;
  if CompOwner <> nil then
  begin
    C := TControlClass( Ref ).Create( CompOwner );
    C.Parent := TWinControl( Component );

    StatusBar.SimpleStatus := False;

    C.Left := C.Parent.Width;
    C.Align := alLeft;

    C.Name := GetNewComponentName( CompOwner, BaseName, False );
    DesignerModified;
  end;
end; {= TRzStatusBarEditor.AddPaneMenuHandler =}



procedure TRzStatusBarEditor.VisualStyleMenuHandler( Sender: TObject );
begin
  StatusBar.VisualStyle := TRzVisualStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzStatusBarEditor.GradientColorStyleMenuHandler( Sender: TObject );
begin
  StatusBar.GradientColorStyle := TRzGradientColorStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzStatusBarEditor.Edit;
begin
  // Do not add a new status pane (item 1) on double-click
end;


{===============================}
{== TRzGroupBoxEditor Methods ==}
{===============================}

function TRzGroupBoxEditor.GroupBox: TRzGroupBox;
begin
  Result := Component as TRzGroupBox;
end;


function TRzGroupBoxEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzGroupBoxEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Group Style';
    1: Result := '-';
    2: Result := 'Visual Style';
    3: Result := 'Gradient Color Style';
  end;
end;


procedure TRzGroupBoxEditor.PrepareMenuItem( Index: Integer;
                                             const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: // GroupStyle
    begin
      CreateGroupStyleMenuItem( Item, gsFlat, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
      CreateGroupStyleMenuItem( Item, gsStandard, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
      CreateGroupStyleMenuItem( Item, gsTopLine, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
      CreateGroupStyleMenuItem( Item, gsBanner, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
      CreateGroupStyleMenuItem( Item, gsUnderline, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
      CreateGroupStyleMenuItem( Item, gsCustom, GroupBox.GroupStyle,
                                GroupStyleMenuHandler );
    end;

    2: // VisualStyle
    begin
      CreateVisualStyleMenuItem( Item, vsClassic, GroupBox.VisualStyle,
                                 VisualStyleMenuHandler );
      CreateVisualStyleMenuItem( Item, vsWinXP, GroupBox.VisualStyle,
                                 VisualStyleMenuHandler );
      CreateVisualStyleMenuItem( Item, vsGradient, GroupBox.VisualStyle,
                                 VisualStyleMenuHandler );
    end;

    3: // GradientColorStyle
    begin
      CreateGradientColorStyleMenuItem( Item, gcsSystem, GroupBox.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
      CreateGradientColorStyleMenuItem( Item, gcsMSOffice, GroupBox.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
      CreateGradientColorStyleMenuItem( Item, gcsCustom, GroupBox.GradientColorStyle,
                                        GradientColorStyleMenuHandler );
    end;
  end;
end;


procedure TRzGroupBoxEditor.GroupStyleMenuHandler( Sender: TObject );
begin
  GroupBox.GroupStyle := TRzGroupBoxStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzGroupBoxEditor.VisualStyleMenuHandler( Sender: TObject );
begin
  GroupBox.VisualStyle := TRzVisualStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzGroupBoxEditor.GradientColorStyleMenuHandler( Sender: TObject );
begin
  GroupBox.GradientColorStyle := TRzGradientColorStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{==================================}
{== TRzPageControlEditor Methods ==}
{==================================}

function TRzPageControlEditor.PageControl: TRzPageControl;
begin
  if Component is TRzPageControl then
    Result := TRzPageControl( Component )
  else if Component is TRzTabSheet then
    Result := TRzTabSheet( Component ).PageControl
  else
    raise Exception.Create( 'Invalid Component type for editor' );
end;


function TRzPageControlEditor.GetVerbCount: Integer;
begin
  if Component is TRzTabSheet then
    Result := 17
  else
    Result := 15;
end;


function TRzPageControlEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'New Page';
    1: Result := '-';
    2: Result := 'Next Page';
    3: Result := 'Previous Page';
    4: Result := '-';
    5: Result := 'Style';
    6: Result := 'Orientation';
    7: Result := '-';
    8: Result := 'Hide All Tabs';
    9: Result := 'Show All Tabs';
    10: Result := '-';
    11: Result := 'Align';
    12: Result := 'XP Colors';
    13: Result := '-';
    14: Result := 'Set ImageList';
    15: Result := 'Select Image...';
    16: Result := 'Select Disabled Image...';
  end;
end;


function TRzPageControlEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_PAGE_NEW';
    2: Result := 'RZDESIGNEDITORS_PAGE_NEXT';
    3: Result := 'RZDESIGNEDITORS_PAGE_PREVIOUS';

    5: // Style
    begin
      case PageControl.TabStyle of
        tsSingleSlant:  Result := 'RZDESIGNEDITORS_TABSTYLE_SINGLESLANT';
        tsDoubleSlant:  Result := 'RZDESIGNEDITORS_TABSTYLE_DOUBLESLANT';
        tsCutCorner:    Result := 'RZDESIGNEDITORS_TABSTYLE_CUTCORNER';
        tsRoundCorners: Result := 'RZDESIGNEDITORS_TABSTYLE_ROUNDCORNERS';
        tsBackSlant:    Result := 'RZDESIGNEDITORS_TABSTYLE_BACKSLANT';
      end;
    end;

    6: // Orientation
    begin
      case PageControl.TabOrientation of
        toTop:    Result := 'RZDESIGNEDITORS_TABORIENTATION_TOP';
        toBottom: Result := 'RZDESIGNEDITORS_TABORIENTATION_BOTTOM';
        toLeft:   Result := 'RZDESIGNEDITORS_TABORIENTATION_LEFT';
        toRight:  Result := 'RZDESIGNEDITORS_TABORIENTATION_RIGHT';
      end;
    end;

    11: // Align
    begin
      case PageControl.Align of
        alNone:   Result := 'RZDESIGNEDITORS_ALIGN_NONE';
        alTop:    Result := 'RZDESIGNEDITORS_ALIGN_TOP';
        alBottom: Result := 'RZDESIGNEDITORS_ALIGN_BOTTOM';
        alLeft:   Result := 'RZDESIGNEDITORS_ALIGN_LEFT';
        alRight:  Result := 'RZDESIGNEDITORS_ALIGN_RIGHT';
        alClient: Result := 'RZDESIGNEDITORS_ALIGN_CLIENT';
      end;
    end;

    12: Result := 'RZDESIGNEDITORS_XPCOLORS';
    14: Result := 'RZDESIGNEDITORS_IMAGELIST';
    15: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
    16: Result := 'RZDESIGNEDITORS_SELECT_DISABLED_IMAGE';
  end;
end;


procedure TRzPageControlEditor.PrepareMenuItem( Index: Integer;
                                                const Item: TMenuItem );
var
  I, ImageListCount: Integer;
  CompOwner: TComponent;

  procedure CreateStyleMenu( Style: TRzTabStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := PageControl.TabStyle = Style;
    case Style of
      tsSingleSlant:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_SINGLESLANT' );
      tsDoubleSlant:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_DOUBLESLANT' );
      tsCutCorner:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_CUTCORNER' );
      tsRoundCorners: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_ROUNDCORNERS' );
      tsBackSlant:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_BACKSLANT' );
    end;
    NewItem.OnClick := StyleMenuHandler;
    Item.Add( NewItem );
  end;


  procedure CreateOrientationMenu( Orientation: TRzTabOrientation;
                                   const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Orientation );
    NewItem.Checked := PageControl.TabOrientation = Orientation;
    case Orientation of
      toTop:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_TOP' );
      toBottom: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_BOTTOM' );
      toLeft:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_LEFT' );
      toRight:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_RIGHT' );
    end;
    NewItem.OnClick := OrientationMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateImageListMenu( ImageList: TCustomImageList );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.AutoHotkeys := maManual;
    NewItem.Caption := ImageList.Name;
    NewItem.Checked := GetObjectProp( PageControl, 'Images' ) = ImageList;
    NewItem.OnClick := ImageListMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateAlignItem( AlignValue: TAlign; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( AlignValue );
    NewItem.Checked := PageControl.Align = AlignValue;
    case AlignValue of
      alNone:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_NONE' );
      alTop:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_TOP' );
      alBottom: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_BOTTOM' );
      alLeft:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_LEFT' );
      alRight:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_RIGHT' );
      alClient: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_ALIGN_CLIENT' );
    end;
    NewItem.OnClick := AlignMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0:
    begin
      // Only allow user to add new pages if the page control is NOT being edited in an inline frame
      // (i.e. a frame instance).
      Item.Enabled := not IsInInlined;
    end;

    5:
    begin
      CreateStyleMenu( tsSingleSlant, 'Single Slant' );
      CreateStyleMenu( tsBackSlant, 'Back Slant' );
      CreateStyleMenu( tsDoubleSlant, 'Double Slant' );
      CreateStyleMenu( tsCutCorner, 'Cut Corner' );
      CreateStyleMenu( tsRoundCorners, 'Round Corners' );
    end;

    6:
    begin
      CreateOrientationMenu( toTop, 'Top' );
      CreateOrientationMenu( toBottom, 'Bottom' );
      CreateOrientationMenu( toLeft, 'Left' );
      CreateOrientationMenu( toRight, 'Right' );
    end;

    11:
    begin
      CreateAlignItem( alClient, 'Client' );
      CreateAlignItem( alLeft, 'Left' );
      CreateAlignItem( alTop, 'Top' );
      CreateAlignItem( alRight, 'Right' );
      CreateAlignItem( alBottom, 'Bottom' );
      CreateAlignItem( alNone, 'None' );
    end;

    14:
    begin
      Item.AutoHotkeys := maManual;
      ImageListCount := 0;
      CompOwner := Designer.GetRoot;
      if CompOwner <> nil then
      begin
        for I := 0 to CompOwner.ComponentCount - 1 do
        begin
          if CompOwner.Components[ I ] is TCustomImageList then
          begin
            Inc( ImageListCount );
            CreateImageListMenu( TCustomImageList( CompOwner.Components[ I ] ) );
          end;
        end;
      end;
      Item.Enabled := ImageListCount > 0;
    end;
  end;
end;


procedure TRzPageControlEditor.ExecuteVerb( Index: Integer );
var
  APageControl: TRzPageControl;
  Page: TRzTabSheet;
  {$IFDEF VCL60_OR_HIGHER}
  Designer: IDesigner;
  {$ELSE}
  Designer: IFormDesigner;
  {$ENDIF}
begin
  if Component is TRzTabSheet then
    APageControl := TRzTabSheet( Component ).PageControl
  else
    APageControl := TRzPageControl( Component );

  if APageControl <> nil then
  begin
    Designer := Self.Designer;

    case Index of
      0:                                    // New Page
      begin
        {$IFDEF VCL60_OR_HIGHER}
        Page := TRzTabSheet.Create( Designer.Root );
        {$ELSE}
        Page := TRzTabSheet.Create( Designer.GetRoot );
        {$ENDIF}
        try
          // Generate unique name
          Page.Name := UniqueName( Page );
          Page.PageControl := APageControl;
        except
          Page.Free;
          raise;
        end;

        APageControl.ActivePage := Page;
        Designer.SelectComponent( Page );
        DesignerModified;
      end;

      2, 3:                                                // Next/Previous Page
      begin
        Page := APageControl.FindNextPage( APageControl.ActivePage, Index = 2 {Next}, False );
        if ( Page <> nil ) and ( Page <> APageControl.ActivePage ) then
        begin
          APageControl.ActivePage := Page;
          if Component is TRzTabSheet then
            Designer.SelectComponent( Page );
          DesignerModified;
        end;
      end;

      8: // Hide All Tabs
      begin
        APageControl.HideAllTabs;
        APageControl.ShowShadow := False;
        DesignerModified;
      end;

      9: // Show All Tabs
      begin
        APageControl.ShowAllTabs;
        DesignerModified;
      end;

      12: // XP Colors
      begin
        APageControl.HotTrackColorType := htctActual;
        APageControl.HotTrackColor := xpHotTrackColor;
        APageControl.TabColors.HighlightBar := xpHotTrackColor;
        APageControl.FlatColor := xpTabControlFrameColor;
        APageControl.Color := xpTabControlColor;
        APageControl.ShowShadow := True;
        DesignerModified;
      end;

      15:
      begin
        // This will only get used if we are on a TRzTabSheet
        EditPropertyByName( 'ImageIndex' );
      end;

      16:
      begin
        // This will only get used if we are on a TRzTabSheet
        EditPropertyByName( 'DisabledIndex' );
      end;
    end;
  end;
end; {= TRzPageControlEditor.ExecuteVerb =}


procedure TRzPageControlEditor.StyleMenuHandler( Sender: TObject );
begin
  PageControl.TabStyle := TRzTabStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzPageControlEditor.OrientationMenuHandler( Sender: TObject );
begin
  PageControl.TabOrientation := TRzTabOrientation( TMenuItem( Sender ).Tag );
  case PageControl.TabOrientation of
    toTop, toBottom:
    begin
      PageControl.TextOrientation := orHorizontal;
      PageControl.ImagePosition := ipLeft;
    end;

    toLeft, toRight:
    begin
      PageControl.TextOrientation := orVertical;
      if PageControl.TabOrientation = toRight then
        PageControl.ImagePosition := ipTop
      else
        PageControl.ImagePosition := ipBottom;
    end;
  end;
  DesignerModified;
end;



procedure TRzPageControlEditor.ImageListMenuHandler( Sender: TObject );
var
  S: string;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    PageControl.Images := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    DesignerModified;
  end;
end;


procedure TRzPageControlEditor.AlignMenuHandler( Sender: TObject );
begin
  PageControl.Align := TAlign( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{$IFDEF VCL60_OR_HIGHER}

{=================================}
{== TRzPageControlSprig Methods ==}
{=================================}

constructor TRzPageControlSprig.Create( AItem: TPersistent );
begin
  inherited;
  ImageIndex := CUIControlSprigImage;
end;


function TRzPageControlSprig.SortByIndex: Boolean;
begin
  Result := True;
end;


{==============================}
{== TRzTabSheetSprig Methods ==}
{==============================}

constructor TRzTabSheetSprig.Create( AItem: TPersistent );
begin
  inherited;
  ImageIndex := CUIContainerSprigImage;
end;


function TRzTabSheetSprig.Caption: string;
begin
  Result := CaptionFor( TRzTabSheet( Item ).Caption, TRzTabSheet( Item ).Name );
end;


function TRzTabSheetSprig.ItemIndex: Integer;
begin
  Result := TRzTabSheet( Item ).PageIndex;
end;


function TRzTabSheetSprig.Hidden: Boolean;
begin
  Result := True;
end;

{$ENDIF}

{=================================}
{== TRzTabControlEditor Methods ==}
{=================================}

function TRzTabControlEditor.TabControl: TRzTabControl;
begin
  Result := Component as TRzTabControl;
end;


function TRzTabControlEditor.GetVerbCount: Integer;
begin
  Result := 15;
end;


function TRzTabControlEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Tabs...';
    1: Result := '-';
    2: Result := 'Next Tab';
    3: Result := 'Previous Tab';
    4: Result := '-';
    5: Result := 'Style';
    6: Result := 'Orientation';
    7: Result := '-';
    8: Result := 'Hide All Tabs';
    9: Result := 'Show All Tabs';
    10: Result := '-';
    11: Result := 'Align';
    12: Result := 'XP Colors';
    13: Result := '-';
    14: Result := 'Set ImageList';
  end;
end;


function TRzTabControlEditor.AlignMenuIndex: Integer;
begin
  Result := 11;
end;


function TRzTabControlEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT';
    2: Result := 'RZDESIGNEDITORS_PAGE_NEXT';
    3: Result := 'RZDESIGNEDITORS_PAGE_PREVIOUS';

    5: // Style
    begin
      case TabControl.TabStyle of
        tsSingleSlant:  Result := 'RZDESIGNEDITORS_TABSTYLE_SINGLESLANT';
        tsDoubleSlant:  Result := 'RZDESIGNEDITORS_TABSTYLE_DOUBLESLANT';
        tsCutCorner:    Result := 'RZDESIGNEDITORS_TABSTYLE_CUTCORNER';
        tsRoundCorners: Result := 'RZDESIGNEDITORS_TABSTYLE_ROUNDCORNERS';
        tsBackSlant:    Result := 'RZDESIGNEDITORS_TABSTYLE_BACKSLANT';
      end;
    end;

    6: // Orientation
    begin
      case TabControl.TabOrientation of
        toTop:    Result := 'RZDESIGNEDITORS_TABORIENTATION_TOP';
        toBottom: Result := 'RZDESIGNEDITORS_TABORIENTATION_BOTTOM';
        toLeft:   Result := 'RZDESIGNEDITORS_TABORIENTATION_LEFT';
        toRight:  Result := 'RZDESIGNEDITORS_TABORIENTATION_RIGHT';
      end;
    end;

    12: Result := 'RZDESIGNEDITORS_XPCOLORS';
    14: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzTabControlEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                             var CompRefPropName: string;
                                             var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 14 then
  begin
    CompRefClass := TCustomImageList;
    CompRefPropName := 'Images';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


procedure TRzTabControlEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateStyleMenu( Style: TRzTabStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := TabControl.TabStyle = Style;
    case Style of
      tsSingleSlant:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_SINGLESLANT' );
      tsDoubleSlant:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_DOUBLESLANT' );
      tsCutCorner:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_CUTCORNER' );
      tsRoundCorners: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_ROUNDCORNERS' );
      tsBackSlant:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABSTYLE_BACKSLANT' );
    end;
    NewItem.OnClick := StyleMenuHandler;
    Item.Add( NewItem );
  end;


  procedure CreateOrientationMenu( Orientation: TRzTabOrientation; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Orientation );
    NewItem.Checked := TabControl.TabOrientation = Orientation;
    case Orientation of
      toTop:    NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_TOP' );
      toBottom: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_BOTTOM' );
      toLeft:   NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_LEFT' );
      toRight:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TABORIENTATION_RIGHT' );
    end;
    NewItem.OnClick := OrientationMenuHandler;
    Item.Add( NewItem );
  end;


begin
  inherited;

  if Index = 0 then
  begin
    // Only allow user to edit tabs if the tab control is NOT being edited in an inline frame (i.e. a frame instance).
    Item.Enabled := not IsInInlined;
  end;

  if Index = 5 then
  begin
    CreateStyleMenu( tsSingleSlant, 'Single Slant' );
    CreateStyleMenu( tsBackSlant, 'Back Slant' );
    CreateStyleMenu( tsDoubleSlant, 'Double Slant' );
    CreateStyleMenu( tsCutCorner, 'Cut Corner' );
    CreateStyleMenu( tsRoundCorners, 'Round Corners' );
  end;

  if Index = 6 then
  begin
    CreateOrientationMenu( toTop, 'Top' );
    CreateOrientationMenu( toBottom, 'Bottom' );
    CreateOrientationMenu( toLeft, 'Left' );
    CreateOrientationMenu( toRight, 'Right' );
  end;
end;


procedure TRzTabControlEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Tabs' );
    2: Skip( True );  // Next
    3: Skip( False ); // Previous

    8: // Hide All Tabs;
    begin
      TabControl.HideAllTabs;
      TabControl.ShowShadow := False;
      DesignerModified;
    end;

    9: // Show All Tabs;
    begin
      TabControl.ShowAllTabs;
      DesignerModified;
    end;

    12: // XP Colors
    begin
      TabControl.HotTrackColorType := htctActual;
      TabControl.HotTrackColor := xpHotTrackColor;
      TabControl.TabColors.HighlightBar := xpHotTrackColor;
      TabControl.FlatColor := xpTabControlFrameColor;
      TabControl.Color := xpTabControlColor;
      TabControl.ShowShadow := True;
      DesignerModified;
    end;
  end;
end;


procedure TRzTabControlEditor.Skip( Next: Boolean );
var
  NewTabIndex, InitialTabIndex: Integer;
begin
  with TRzCollectionTabControl( Component ) do
  begin
    if Tabs.Count = 0 then
      Exit;

    if TabIndex >= 0 then
      NewTabIndex := TabIndex
    else
      if Next then
        NewTabIndex := Tabs.Count - 1       // next tab will be first tab
      else
        NewTabIndex := 0;                   // previous tab will be last tab
    InitialTabIndex := NewTabIndex;

    // Skip to the next visible tab in the specified direction
    repeat
      if Next then
      begin
        if NewTabIndex = Tabs.Count - 1 then
          NewTabIndex := 0
        else
          Inc( NewTabIndex );
      end
      else if NewTabIndex = 0 then
        NewTabIndex := Tabs.Count - 1
      else
        Dec( NewTabIndex );
    until Tabs[ NewTabIndex ].Visible or ( NewTabIndex = InitialTabIndex );

    if NewTabIndex <> TabIndex then
    begin
      TabIndex := NewTabIndex;
      DesignerModified;
    end;
  end;
end;


procedure TRzTabControlEditor.StyleMenuHandler( Sender: TObject );
begin
  TabControl.TabStyle := TRzTabStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzTabControlEditor.OrientationMenuHandler( Sender: TObject );
begin
  TabControl.TabOrientation := TRzTabOrientation( TMenuItem( Sender ).Tag );
  case TabControl.TabOrientation of
    toTop, toBottom:
      TabControl.TextOrientation := orHorizontal;

    toLeft, toRight:
      TabControl.TextOrientation := orVertical;
  end;
  DesignerModified;
end;



{================================}
{== TRzSizePanelEditor Methods ==}
{================================}

function TRzSizePanelEditor.SizePanel: TRzSizePanel;
begin
  Result := Component as TRzSizePanel;
end;


function TRzSizePanelEditor.GetVerbCount: Integer;
begin
  Result := 7;
end;


function TRzSizePanelEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := '-';
    2: Result := 'Show HotSpot';
    3: Result := 'Real-Time Dragging';
    4: Result := '-';
    5: Result := 'Add a Group Bar';
    6: Result := 'Add a Panel';
  end;
end;


function TRzSizePanelEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


function TRzSizePanelEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    2:
    begin
      if SizePanel.Align in [ alLeft, alRight ] then
        Result := 'RZDESIGNEDITORS_SPLIT_HOTSPOT_HORIZONTAL'
      else
        Result := 'RZDESIGNEDITORS_SPLIT_HOTSPOT_VERTICAL';
    end;

    5: Result := 'RZDESIGNEDITORS_GROUPBAR_CATEGORYVIEW';
    6: Result := 'RZDESIGNEDITORS_PANEL';
  end;
end; {= TRzSizePanelEditor.MenuBitmapResourceName =}


procedure TRzSizePanelEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    2: Item.Checked := SizePanel.HotSpotVisible;
    3: Item.Checked := SizePanel.RealTimeDrag;
  end;
end;


procedure TRzSizePanelEditor.ExecuteVerb( Index: Integer );
var
  GroupBar: TRzGroupBar;
  Panel: TRzPanel;
begin
  case Index of
    2: SizePanel.HotSpotVisible := not SizePanel.HotSpotVisible;
    3: SizePanel.RealTimeDrag := not SizePanel.RealTimeDrag;

    5:
    begin
      GroupBar := Designer.CreateComponent( TRzGroupBar, SizePanel, 10, 10, 100, 100 ) as TRzGroupBar;
      GroupBar.Align := alClient;
      SizePanel.Color := clBtnShadow;
      SizePanel.SizeBarStyle := ssGroupBar;
    end;

    6:
    begin
      Panel := Designer.CreateComponent( TRzPanel, SizePanel, 10, 10, 100, 100 ) as TRzPanel;
      Panel.Align := alClient;
      Panel.BorderOuter := fsLowered;
    end;
  end;
  if Index in [ 2, 3, 5, 6 ] then
    DesignerModified;
end;


{===============================}
{== TRzCheckBoxEditor Methods ==}
{===============================}

function TRzCheckBoxEditor.CheckBox: TRzCheckBox;
begin
  Result := Component as TRzCheckBox;
end;


function TRzCheckBoxEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzCheckBoxEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0:
    begin
      if CheckBox.Checked then
        Result := 'Uncheck'
      else
        Result := 'Check';
    end;

    1: Result := 'HotTrack';
    2: Result := 'XP Colors';
  end;
end;


function TRzCheckBoxEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0:
    begin
      if CheckBox.Checked then
        Result := 'RZDESIGNEDITORS_CHECKBOX_UNCHECK'
      else
        Result := 'RZDESIGNEDITORS_CHECKBOX_CHECK';
    end;

    1: Result := 'RZDESIGNEDITORS_HOTTRACK';
    2: Result := 'RZDESIGNEDITORS_XPCOLORS';
  end;
end;


procedure TRzCheckBoxEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    1: Item.Checked := CheckBox.HotTrack;
  end;
end;


procedure TRzCheckBoxEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: CheckBox.Checked := not CheckBox.Checked;
    1: CheckBox.HotTrack := not CheckBox.HotTrack;

    2: // XP Colors
    begin
      CheckBox.HotTrackColorType := htctActual;
      CheckBox.HotTrack := True;
      CheckBox.HighlightColor := xpRadChkMarkColor;
      CheckBox.HotTrackColor := xpHotTrackColor;
      CheckBox.FrameColor := xpRadChkFrameColor;
    end;
  end;
  if Index in [ 0, 1, 2 ] then
    DesignerModified;
end;


{==================================}
{== TRzRadioButtonEditor Methods ==}
{==================================}

function TRzRadioButtonEditor.RadioButton: TRzRadioButton;
begin
  Result := Component as TRzRadioButton;
end;


function TRzRadioButtonEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzRadioButtonEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Check';
    1: Result := 'HotTrack';
    2: Result := 'XP Colors';
  end;
end;


function TRzRadioButtonEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_RADIOBUTTON_CHECK';
    1: Result := 'RZDESIGNEDITORS_HOTTRACK';
    2: Result := 'RZDESIGNEDITORS_XPCOLORS';
  end;
end;


procedure TRzRadioButtonEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    1: Item.Checked := RadioButton.HotTrack;
  end;
end;


procedure TRzRadioButtonEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: RadioButton.Checked := True;
    1: RadioButton.HotTrack := not RadioButton.HotTrack;

    2: // XP Colors
    begin
      RadioButton.HotTrackColorType := htctActual;
      RadioButton.HotTrack := True;
      RadioButton.HighlightColor := xpRadChkMarkColor;
      RadioButton.HotTrackColor := xpHotTrackColor;
      RadioButton.FrameColor := xpRadChkFrameColor;
    end;

  end;
  if Index in [ 0, 1, 2 ] then
    DesignerModified;
end;


{===========================}
{== TRzMemoEditor Methods ==}
{===========================}

function TRzMemoEditor.GetWordWrap: Boolean;
begin
  Result := ( Component as TRzMemo ).WordWrap;
end;


procedure TRzMemoEditor.SetWordWrap( Value: Boolean );
begin
  ( Component as TRzMemo ).WordWrap := Value;
end;


function TRzMemoEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzMemoEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Lines...';
    1: Result := 'Align';
    2: Result := '-';
    3: Result := 'Word Wrap';
  end;
end;


function TRzMemoEditor.AlignMenuIndex: Integer;
begin
  Result := 1;
end;


function TRzMemoEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
    3: Result := 'RZDESIGNEDITORS_WORDWRAP';
  end;
end;


procedure TRzMemoEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    3: Item.Checked := WordWrap;
  end;
end;


procedure TRzMemoEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Lines' );

    3:
    begin
      WordWrap := not WordWrap;
      DesignerModified;
    end;
  end;
end;


{===============================}
{== TRzRichEditEditor Methods ==}
{===============================}

function TRzRichEditEditor.GetWordWrap: Boolean;
begin
  Result := ( Component as TRzRichEdit ).WordWrap;
end;


procedure TRzRichEditEditor.SetWordWrap( Value: Boolean );
begin
  ( Component as TRzRichEdit ).WordWrap := Value;
end;



{==============================}
{== TRzListBoxEditor Methods ==}
{==============================}

function TRzListBoxEditor.ListBox: TRzListBox;
begin
  Result := Component as TRzListBox;
end;


function TRzListBoxEditor.GetVerbCount: Integer;
begin
  Result := 6;
end;


function TRzListBoxEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Edit Items...';
    1: Result := 'Align';
    2: Result := '-';
    3: Result := 'Show Groups';
    4: Result := 'Sorted';
    5: Result := 'MultiSelect';
  end;
end;


function TRzListBoxEditor.AlignMenuIndex: Integer;
begin
  Result := 1;
end;


function TRzListBoxEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
  end;
end;


procedure TRzListBoxEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    3: Item.Checked := ListBox.ShowGroups;
    4: Item.Checked := ListBox.Sorted;
    5: Item.Checked := ListBox.MultiSelect;
  end;
end;


procedure TRzListBoxEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
      EditPropertyByName( 'Items' );

    3:
    begin
      ListBox.ShowGroups := not ListBox.ShowGroups;
      DesignerModified;
    end;

    4:
    begin
      ListBox.Sorted := not ListBox.Sorted;
      DesignerModified;
    end;

    5:
    begin
      ListBox.MultiSelect := not ListBox.MultiSelect;
      DesignerModified;
    end;
  end;
end;


{==================================}
{== TRzRankListBoxEditor Methods ==}
{==================================}

function TRzRankListBoxEditor.ListBox: TRzRankListBox;
begin
  Result := Component as TRzRankListBox;
end;


function TRzRankListBoxEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzRankListBoxEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Edit Items...';
    1: Result := 'Align';
    2: Result := '-';
    3: Result := 'Show Groups';
  end;
end;


function TRzRankListBoxEditor.AlignMenuIndex: Integer;
begin
  Result := 1;
end;


function TRzRankListBoxEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
  end;
end;


procedure TRzRankListBoxEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    3: Item.Checked := ListBox.ShowGroups;
  end;
end;


procedure TRzRankListBoxEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Items' );

    3:
    begin
      ListBox.ShowGroups := not ListBox.ShowGroups;
      DesignerModified;
    end;

  end;
end;


{==================================}
{== TRzMRUComboBoxEditor Methods ==}
{==================================}

function TRzMRUComboBoxEditor.GetVerbCount: Integer;
begin
  Result := 6;
end;


function TRzMRUComboBoxEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Items...';
    1: Result := '-';
    2: Result := 'csDropDown Style';
    3: Result := 'csDropDownList Style';
    4: Result := '-';
    5: Result := 'AllowEdit';
  end;
end;


function TRzMRUComboBoxEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
  end;
end;


procedure TRzMRUComboBoxEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    2: Item.Checked := GetOrdProp( Component, 'Style' ) = Ord( csDropDown );
    3: Item.Checked := GetOrdProp( Component, 'Style' ) = Ord( csDropDownList );
    5: Item.Checked := GetOrdProp( Component, 'AllowEdit' ) = 1;
  end;
end;


procedure TRzMRUComboBoxEditor.ExecuteVerb( Index: Integer );
var
  B: Boolean;
begin
  case Index of
    0: EditPropertyByName( 'Items' );

    2: SetOrdProp( Component, 'Style', Ord( csDropDown ) );
    3: SetOrdProp( Component, 'Style', Ord( csDropDownList ) );

    5:
    begin
      B := GetOrdProp( Component, 'AllowEdit' ) = 1;
      SetOrdProp( Component, 'AllowEdit', Ord( not B ) );
    end;

  end;
  if Index in [ 2, 3, 5 ] then
    DesignerModified;
end;



{====================================}
{== TRzImageComboBoxEditor Methods ==}
{====================================}

function TRzImageComboBoxEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


function TRzImageComboBoxEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Set ImageList';
  end;
end;


function TRzImageComboBoxEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzImageComboBoxEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                                var CompRefPropName: string;
                                                var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  case Index of
    0:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'Images';
      CompRefMenuHandler := nil;
      Result := True;
    end;
  end;
end;


{===============================}
{== TRzListViewEditor Methods ==}
{===============================}

function TRzListViewEditor.ListView: TRzListView;
begin
  Result := Component as TRzListView;
end;


function TRzListViewEditor.GetVerbCount: Integer;
begin
  Result := 10;
end;


function TRzListViewEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Columns...';
    1: Result := 'Edit Items...';
    2: Result := '-';
    3: Result := 'Align';
    4: Result := '-';
    5: Result := 'Set SmallImages';
    6: Result := 'Set LargeImages';
    7: Result := 'Set StateImages';
    8: Result := '-';
    9: Result := 'View Style';
  end;
end;


function TRzListViewEditor.AlignMenuIndex: Integer;
begin
  Result := 3;
end;


function TRzListViewEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_COLUMNS';
    1: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
    5: Result := 'RZDESIGNEDITORS_IMAGELIST';
    6: Result := 'RZDESIGNEDITORS_IMAGELIST';
    7: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzListViewEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                           var CompRefPropName: string;
                                           var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  case Index of
    5:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'SmallImages';
      CompRefMenuHandler := SmallImagesMenuHandler;
      Result := True;
    end;

    6:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'LargeImages';
      CompRefMenuHandler := LargeImagesMenuHandler;
      Result := True;
    end;

    7:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'StateImages';
      CompRefMenuHandler := StateImagesMenuHandler;
      Result := True;
    end;
  end;
end;


procedure TRzListViewEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateViewStyleMenu( Style: TViewStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := ListView.ViewStyle = Style;
    NewItem.OnClick := ViewStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  if Index = 9 then
  begin
    CreateViewStyleMenu( vsIcon, 'Icons' );
    CreateViewStyleMenu( vsSmallIcon, 'Small Icons' );
    CreateViewStyleMenu( vsList, 'List' );
    CreateViewStyleMenu( vsReport, 'Report' );
  end;
end;


procedure TRzListViewEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Columns' );
    1: EditPropertyByName( 'Items' );
  end;
end;


procedure TRzListViewEditor.ViewStyleMenuHandler( Sender: TObject );
begin
  ListView.ViewStyle := TViewStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzListViewEditor.SmallImagesMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'SmallImages', ImageList );
    DesignerModified;
  end;
end;


procedure TRzListViewEditor.LargeImagesMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'LargeImages', ImageList );
    DesignerModified;
  end;
end;


procedure TRzListViewEditor.StateImagesMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'StateImages', ImageList );
    DesignerModified;
  end;
end;


{===============================}
{== TRzTreeViewEditor Methods ==}
{===============================}

function TRzTreeViewEditor.TreeView: TRzTreeView;
begin
  Result := Component as TRzTreeView;
end;


function TRzTreeViewEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;


function TRzTreeViewEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Items...';
    1: Result := 'Align';
    2: Result := '-';
    3: Result := 'Set Images';
    4: Result := 'Set StateImages';
  end;
end;


function TRzTreeViewEditor.AlignMenuIndex: Integer;
begin
  Result := 1;
end;


function TRzTreeViewEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_ITEMS';
    3: Result := 'RZDESIGNEDITORS_IMAGELIST';
    4: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzTreeViewEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                           var CompRefPropName: string;
                                           var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  case Index of
    3:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'Images';
      CompRefMenuHandler := ImagesMenuHandler;
      Result := True;
    end;

    4:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'StateImages';
      CompRefMenuHandler := StateImagesMenuHandler;
      Result := True;
    end;
  end;
end;


procedure TRzTreeViewEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
      EditPropertyByName( 'Items' );
  end;
end;


procedure TRzTreeViewEditor.ImagesMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'Images', ImageList );
    DesignerModified;
  end;
end;


procedure TRzTreeViewEditor.StateImagesMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'StateImages', ImageList );
    DesignerModified;
  end;
end;



{================================}
{== TRzCheckTreeEditor Methods ==}
{================================}

function TRzCheckTreeEditor.CheckTree: TRzCheckTree;
begin
  Result := Component as TRzCheckTree;
end;


function TRzCheckTreeEditor.GetVerbCount: Integer;
begin
  Result := inherited GetVerbCount + 2;
end;


function TRzCheckTreeEditor.GetVerb(Index: Integer): string;
begin
  Result := inherited GetVerb( Index );
  case Index of
    5: Result := '-';
    6: Result := 'Cascade Checks';
  end;
end;


procedure TRzCheckTreeEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  if Index = 6 then
    Item.Checked := CheckTree.CascadeChecks;
end;


procedure TRzCheckTreeEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    6:
    begin
      CheckTree.CascadeChecks := not CheckTree.CascadeChecks;
      DesignerModified;
    end;
  end;
end;



{=================================}
{== TRzBackgroundEditor Methods ==}
{=================================}

function TRzBackgroundEditor.Background: TRzBackground;
begin
  Result := Component as TRzBackground;
end;


function TRzBackgroundEditor.GetVerbCount: Integer;
begin
  Result := 11;
end;


function TRzBackgroundEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := '-';
    2: Result := 'Show Gradient';
    3: Result := 'Gradient Direction';
    4: Result := '-';
    5: Result := 'Show Texture';
    6: Result := 'Select Texture...';
    7: Result := '-';
    8: Result := 'Show Image';
    9: Result := 'Select Image...';
    10: Result := 'Image Style';

  end;
end;


function TRzBackgroundEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


function TRzBackgroundEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    6: Result := 'RZDESIGNEDITORS_SELECT_TEXTURE';
    9: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
  end;
end;


procedure TRzBackgroundEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateGradientDirectionMenu( Direction: TGradientDirection; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Direction );
    NewItem.Checked := Background.GradientDirection = Direction;
    NewItem.OnClick := GradientDirectionMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateImageStyleMenu( Style: TImageStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := Background.ImageStyle = Style;
    NewItem.OnClick := ImageStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    2: Item.Checked := Background.ShowGradient;

    3:
    begin
      CreateGradientDirectionMenu( gdDiagonalUp, 'Diagonal Up' );
      CreateGradientDirectionMenu( gdDiagonalDown, 'Diagonal Down' );
      CreateGradientDirectionMenu( gdHorizontalEnd, 'Horizontal End' );
      CreateGradientDirectionMenu( gdHorizontalCenter, 'Horizontal Center' );
      CreateGradientDirectionMenu( gdHorizontalBox, 'Horizontal Box' );
      CreateGradientDirectionMenu( gdVerticalEnd, 'Vertical End' );
      CreateGradientDirectionMenu( gdVerticalCenter, 'Vertical Center' );
      CreateGradientDirectionMenu( gdVerticalBox, 'Vertical Box' );
      CreateGradientDirectionMenu( gdSquareBox, 'Square Box' );
      CreateGradientDirectionMenu( gdBigSquareBox, 'Big Square Box' );
    end;

    5: Item.Checked := Background.ShowTexture;

    8: Item.Checked := Background.ShowImage;

    10:
    begin
      CreateImageStyleMenu( isCenter, 'Center' );
      CreateImageStyleMenu( isClip, 'Clip' );
      CreateImageStyleMenu( isFill, 'Fill' );
      CreateImageStyleMenu( isStretch, 'Stretch' );
      CreateImageStyleMenu( isTiled, 'Tiled' );
    end;
  end;
end;


procedure TRzBackgroundEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Columns' );
    1: EditPropertyByName( 'Items' );
    2: Background.ShowGradient := not Background.ShowGradient;
    5: Background.ShowTexture := not Background.ShowTexture;
    6: EditPropertyByName( 'Texture' );
    8: Background.ShowImage := not Background.ShowImage;
    9: EditPropertyByName( 'Image' );
  end;
  if Index in [ 2, 5, 8 ] then
    DesignerModified;
end;


procedure TRzBackgroundEditor.GradientDirectionMenuHandler( Sender: TObject );
begin
  Background.GradientDirection := TGradientDirection( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzBackgroundEditor.ImageStyleMenuHandler( Sender: TObject );
begin
  Background.ImageStyle := TImageStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{===============================}
{== TRzTrackBarEditor Methods ==}
{===============================}

function TRzTrackBarEditor.TrackBar: TRzTrackBar;
begin
  Result := Component as TRzTrackBar;
end;


function TRzTrackBarEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;


function TRzTrackBarEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Thumb Style';
    1: Result := 'Tick Step';
    2: Result := '-';
    3: Result := 'Show Tick Marks';
    4: Result := 'Show Focus Rect';
  end;
end;


procedure TRzTrackBarEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateThumbStyleMenu( Style: TThumbStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := TrackBar.ThumbStyle = Style;
    NewItem.OnClick := ThumbStyleMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateTickStepMenu( Step: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Step;
    NewItem.Checked := TrackBar.TickStep = Step;
    NewItem.OnClick := TickStepMenuHandler;
    Item.Add( NewItem );
  end;


begin
  inherited;

  case Index of
    0:
    begin
      CreateThumbStyleMenu( tsBox, 'Box' );
      CreateThumbStyleMenu( tsCustom, 'Custom' );
      CreateThumbStyleMenu( tsMixer , 'Mixer ' );
      CreateThumbStyleMenu( tsPointer, 'Pointer' );
      CreateThumbStyleMenu( tsFlat, 'Flat' );
      CreateThumbStyleMenu( tsXPPointer, 'XP Pointer' );
      CreateThumbStyleMenu( tsXPBox, 'XP Box' );
    end;

    1:
    begin
      CreateTickStepMenu( 1, '1' );
      CreateTickStepMenu( 2, '2' );
      CreateTickStepMenu( 5, '5' );
      CreateTickStepMenu( 10, '10' );
      CreateTickStepMenu( 15, '15' );
      CreateTickStepMenu( 20, '20' );
      CreateTickStepMenu( 25, '25' );
      CreateTickStepMenu( 30, '30' );
      CreateTickStepMenu( 50, '50' );
      CreateTickStepMenu( 90, '90' );
      CreateTickStepMenu( 100, '100' );
    end;

    3: Item.Checked := TrackBar.ShowTicks;

    4: Item.Checked := TrackBar.ShowFocusRect;
  end;
end;


procedure TRzTrackBarEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    3: TrackBar.ShowTicks := not TrackBar.ShowTicks;
    4: TrackBar.ShowFocusRect := not TrackBar.ShowFocusRect;
  end;
  if Index in [ 3, 4 ] then
    DesignerModified;
end;


procedure TRzTrackBarEditor.ThumbStyleMenuHandler( Sender: TObject );
begin
  TrackBar.ThumbStyle := TThumbStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzTrackBarEditor.TickStepMenuHandler( Sender: TObject );
begin
  TrackBar.TickStep := TMenuItem( Sender ).Tag;
  DesignerModified;
end;


{==================================}
{== TRzProgressBarEditor Methods ==}
{==================================}

function TRzProgressBarEditor.ProgressBar: TRzProgressBar;
begin
  Result := Component as TRzProgressBar;
end;


function TRzProgressBarEditor.GetVerbCount: Integer;
begin
  Result := 9;
end;


function TRzProgressBarEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Traditional Bar Style';
    1: Result := 'LED Bar Style';
    2: Result := 'Gradient Bar Style';
    3: Result := '-';
    4: Result := 'Show Percent';
    5: Result := '-';
    6: Result := 'Status Pane - Flat Style';
    7: Result := 'Status Pane - Traditional Style';
    8: Result := 'Progress Bar Style';
  end;
end;


function TRzProgressBarEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_PROGRESS_TRADITIONAL';
    1: Result := 'RZDESIGNEDITORS_PROGRESS_LED';
    2: Result := 'RZDESIGNEDITORS_PROGRESS_GRADIENT';
    6: Result := 'RZDESIGNEDITORS_STATUS_FLAT';
  end;
end;


procedure TRzProgressBarEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := ProgressBar.BarStyle = bsTraditional;
    1: Item.Checked := ProgressBar.BarStyle = bsLED;
    2: Item.Checked := ProgressBar.BarStyle = bsGradient;
    4: Item.Checked := ProgressBar.ShowPercent;
  end;
end;


type
  TWinControlAccess = class( TWinControl );


procedure TRzProgressBarEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: ProgressBar.BarStyle := bsTraditional;
    1: ProgressBar.BarStyle := bsLED;
    2: ProgressBar.BarStyle := bsGradient;
    4: ProgressBar.ShowPercent := not ProgressBar.ShowPercent;

    6:
    begin
      ProgressBar.BorderInner := fsFlat;
      ProgressBar.BorderOuter := fsNone;
      ProgressBar.BorderWidth := 1;
      if ProgressBar.Parent <> nil then
        ProgressBar.BackColor := TWinControlAccess( ProgressBar.Parent ).Color;
    end;

    7:
    begin
      ProgressBar.BorderInner := fsStatus;
      ProgressBar.BorderOuter := fsNone;
      ProgressBar.BorderWidth := 1;
      if ProgressBar.Parent <> nil then
        ProgressBar.BackColor := TWinControlAccess( ProgressBar.Parent ).Color;
    end;

    8:
    begin
      ProgressBar.BorderInner := fsNone;
      ProgressBar.BorderOuter := fsLowered;
      ProgressBar.BorderWidth := 0;
      ProgressBar.BackColor := clWhite;
    end;
  end;
  if Index in [ 0, 1, 2, 4, 6, 7, 8 ] then
    DesignerModified;
end;



{===============================}
{== TRzFontListEditor Methods ==}
{===============================}

function TRzFontListEditor.GetVerbCount: Integer;
begin
  Result := 9;
end;


function TRzFontListEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Show Style';
    1: Result := '-';
    2: Result := 'Font Type';
    3: Result := 'Font Device';
    4: Result := 'Show Symbol Fonts';
    5: Result := '-';
    6: Result := 'Maintain MRU Fonts';
    7: Result := '-';
    8: Result := 'Align';
  end;
end;


function TRzFontListEditor.AlignMenuIndex: Integer;
begin
  Result := 8;
end;


procedure TRzFontListEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateShowStyleMenu( Style: TRzShowStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Style );
    NewItem.Checked := GetOrdProp( Component, 'ShowStyle' ) = Ord( Style );
    NewItem.OnClick := ShowStyleMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateFontTypeMenu( FontType: TRzFontType; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( FontType );
    NewItem.Checked := GetOrdProp( Component, 'FontType' ) = Ord( FontType );
    NewItem.OnClick := FontTypeMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateFontDeviceMenu( Device: TRzFontDevice; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Device );
    NewItem.Checked := GetOrdProp( Component, 'FontDevice' ) = Ord( Device );
    NewItem.OnClick := FontDeviceMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: // Show Style
    begin
      CreateShowStyleMenu( ssFontName, 'Font Name' );
      CreateShowStyleMenu( ssFontSample, 'Font Sample' );
      CreateShowStyleMenu( ssFontNameAndSample, 'Font Name and Sample' );
      CreateShowStyleMenu( ssFontPreview, 'Font Preview' );
    end;

    2: // Font Type
    begin
      CreateFontTypeMenu( ftAll, 'All Fonts' );
      CreateFontTypeMenu( ftTrueType, 'True Type Fonts' );
      CreateFontTypeMenu( ftFixedPitch, 'Fixed Pitch Fonts' );
      CreateFontTypeMenu( ftPrinter, 'Printer Fonts' );
    end;

    3: // Font Device
    begin
      CreateFontDeviceMenu( RzCmboBx.fdScreen, 'Screen' );
      CreateFontDeviceMenu( RzCmboBx.fdPrinter, 'Printer' );
    end;

    4: Item.Checked := GetOrdProp( Component, 'ShowSymbolFonts' ) = 1;
    6: Item.Checked := GetOrdProp( Component, 'MaintainMRUFonts' ) = 1;
  end;
end;


procedure TRzFontListEditor.ExecuteVerb( Index: Integer );
var
  B: Boolean;
begin
  case Index of
    4:
    begin
      B := GetOrdProp( Component, 'ShowSymbolFonts' ) = 1;
      SetOrdProp( Component, 'ShowSymbolFonts', Ord( not B ) );
    end;

    6:
    begin
      B := GetOrdProp( Component, 'MaintainMRUFonts' ) = 1;
      SetOrdProp( Component, 'MaintainMRUFonts', Ord( not B ) );
    end;
  end;
  if Index in [ 4, 6 ] then
    DesignerModified;
end;


procedure TRzFontListEditor.ShowStyleMenuHandler( Sender: TObject );
begin
  SetOrdProp( Component, 'ShowStyle', TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzFontListEditor.FontTypeMenuHandler( Sender: TObject );
begin
  SetOrdProp( Component, 'FontType', TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzFontListEditor.FontDeviceMenuHandler( Sender: TObject );
begin
  SetOrdProp( Component, 'FontDevice', TMenuItem( Sender ).Tag );
  DesignerModified;
end;

{==================================}
{== TRzEditControlEditor Methods ==}
{==================================}

function TRzEditControlEditor.EditControl: TRzCustomEdit;
begin
  Result := Component as TRzCustomEdit;
end;


function TRzEditControlEditor.GetVerbCount: Integer;
begin
  Result := 8;
end;


function TRzEditControlEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Left Justify';
    1: Result := 'Right Justify';
    2: Result := '-';
    3: Result := 'Normal Case';
    4: Result := 'Upper Case';
    5: Result := 'Lower Case';
    6: Result := '-';
    7: Result := 'Align';
  end;
end;


function TRzEditControlEditor.AlignMenuIndex: Integer;
begin
  Result := 7;
end;


type
  TRzCustomEditAccess = class( TRzCustomEdit );

procedure TRzEditControlEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := TRzCustomEditAccess( EditControl ).Alignment = taLeftJustify;
    1: Item.Checked := TRzCustomEditAccess( EditControl ).Alignment = taRightJustify;
    3: Item.Checked := TRzCustomEditAccess( EditControl ).CharCase = ecNormal;
    4: Item.Checked := TRzCustomEditAccess( EditControl ).CharCase = ecUpperCase;
    5: Item.Checked := TRzCustomEditAccess( EditControl ).CharCase = ecLowerCase;
  end;
end;


procedure TRzEditControlEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: TRzCustomEditAccess( EditControl ).Alignment := taLeftJustify;
    1: TRzCustomEditAccess( EditControl ).Alignment := taRightJustify;
    3: TRzCustomEditAccess( EditControl ).CharCase := ecNormal;
    4: TRzCustomEditAccess( EditControl ).CharCase := ecUpperCase;
    5: TRzCustomEditAccess( EditControl ).CharCase := ecLowerCase;
  end;
  if Index in [ 0, 1, 3..5 ] then
    DesignerModified;
end;



{=================================}
{== TRzButtonEditEditor Methods ==}
{=================================}

function TRzButtonEditEditor.ButtonEdit: TRzButtonEdit;
begin
  Result := Component as TRzButtonEdit;
end;


function TRzButtonEditEditor.GetVerbCount: Integer;
begin
  Result := 8;
end;


function TRzButtonEditEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Show Button';
    1: Result := 'Button Kind';
    2: Result := '-';
    3: Result := 'Show Alternate Button';
    4: Result := 'Alternate Button Kind';
    5: Result := '-';
    6: Result := 'Flat Buttons';
    7: Result := 'Allow Key Edit';
  end;
end;


procedure TRzButtonEditEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateButtonKindMenu( Kind: TButtonKind; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Kind );
    NewItem.Checked := ButtonEdit.ButtonKind = Kind;
    NewItem.OnClick := ButtonKindMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateAltBtnKindMenu( Kind: TButtonKind; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Kind );
    NewItem.Checked := ButtonEdit.AltBtnKind = Kind;
    NewItem.OnClick := AltBtnKindMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := ButtonEdit.ButtonVisible;

    1: // ButtonKind
    begin
      CreateButtonKindMenu( bkCustom, 'Custom' );
      CreateButtonKindMenu( bkLookup, 'Lookup' );
      CreateButtonKindMenu( bkDropDown, 'DropDown' );
      CreateButtonKindMenu( bkCalendar, 'Calendar' );
      CreateButtonKindMenu( bkAccept, 'Accept' );
      CreateButtonKindMenu( bkReject, 'Reject' );
      CreateButtonKindMenu( bkFolder, 'Folder' );
      CreateButtonKindMenu( bkFind, 'Find' );
      CreateButtonKindMenu( bkSearch, 'Search' );
    end;

    3: Item.Checked := ButtonEdit.AltBtnVisible;

    4: // AltBtnKind
    begin
      CreateAltBtnKindMenu( bkCustom, 'Custom' );
      CreateAltBtnKindMenu( bkLookup, 'Lookup' );
      CreateAltBtnKindMenu( bkDropDown, 'DropDown' );
      CreateAltBtnKindMenu( bkCalendar, 'Calendar' );
      CreateAltBtnKindMenu( bkAccept, 'Accept' );
      CreateAltBtnKindMenu( bkReject, 'Reject' );
      CreateAltBtnKindMenu( bkFolder, 'Folder' );
      CreateAltBtnKindMenu( bkFind, 'Find' );
      CreateAltBtnKindMenu( bkSearch, 'Search' );
    end;

    6: Item.Checked := ButtonEdit.FlatButtons;
    7: Item.Checked := ButtonEdit.AllowKeyEdit;
  end;
end;


procedure TRzButtonEditEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: ButtonEdit.ButtonVisible := not ButtonEdit.ButtonVisible;
    3: ButtonEdit.AltBtnVisible := not ButtonEdit.AltBtnVisible;
    6: ButtonEdit.FlatButtons := not ButtonEdit.FlatButtons;
    7: ButtonEdit.AllowKeyEdit := not ButtonEdit.AllowKeyEdit;
  end;
  if Index in [ 0, 3, 6, 7 ] then
    DesignerModified;
end;


procedure TRzButtonEditEditor.ButtonKindMenuHandler( Sender: TObject );
begin
  ButtonEdit.ButtonKind := TButtonKind( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzButtonEditEditor.AltBtnKindMenuHandler( Sender: TObject );
begin
  ButtonEdit.AltBtnKind := TButtonKind( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{==================================}
{== TRzNumericEditEditor Methods ==}
{==================================}

function TRzNumericEditEditor.NumericEdit: TRzNumericEdit;
begin
  Result := Component as TRzNumericEdit;
end;


function TRzNumericEditEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzNumericEditEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Integers Only';
    1: Result := 'Check Range';
    2: Result := 'Allow Blank';
  end;
end;


procedure TRzNumericEditEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := NumericEdit.IntegersOnly;
    1: Item.Checked := NumericEdit.CheckRange;
    2: Item.Checked := NumericEdit.AllowBlank;
  end;
end;


procedure TRzNumericEditEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: NumericEdit.IntegersOnly := not NumericEdit.IntegersOnly;
    1: NumericEdit.CheckRange := not NumericEdit.CheckRange;
    2: NumericEdit.AllowBlank := not NumericEdit.AllowBlank;
  end;
  if Index in [ 0, 1, 2 ] then
    DesignerModified;
end;



{===============================}
{== TRzSpinEditEditor Methods ==}
{===============================}

function TRzSpinEditEditor.SpinEdit: TRzSpinEdit;
begin
  Result := Component as TRzSpinEdit;
end;


function TRzSpinEditEditor.GetVerbCount: Integer;
begin
  Result := 8;
end;


function TRzSpinEditEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Integers Only';
    1: Result := 'Allow Key Edit';
    2: Result := 'Check Range';
    3: Result := 'Allow Blank';
    4: Result := '-';
    5: Result := 'Flat Buttons';
    6: Result := 'Direction';
    7: Result := 'Orientation';
  end;
end;


procedure TRzSpinEditEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateDirectionMenu( Direction: TSpinDirection; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Direction );
    NewItem.Checked := SpinEdit.Direction = Direction;
    NewItem.OnClick := DirectionMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateOrientationMenu( Orientation: TOrientation; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Orientation );
    NewItem.Checked := SpinEdit.Orientation = Orientation;
    NewItem.OnClick := OrientationMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := SpinEdit.IntegersOnly;
    1: Item.Checked := SpinEdit.AllowKeyEdit;
    2: Item.Checked := SpinEdit.CheckRange;
    3: Item.Checked := SpinEdit.AllowBlank;
    5: Item.Checked := SpinEdit.FlatButtons;

    6: // Direction
    begin
      CreateDirectionMenu( sdUpDown, 'Up/Down' );
      CreateDirectionMenu( sdLeftRight, 'Left/Right' );
    end;

    7: // Orientation
    begin
      CreateOrientationMenu( orHorizontal, 'Horizontal' );
      CreateOrientationMenu( orVertical, 'Vertical' );
    end;
  end;
end;


procedure TRzSpinEditEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: SpinEdit.IntegersOnly := not SpinEdit.IntegersOnly;
    1: SpinEdit.AllowKeyEdit := not SpinEdit.AllowKeyEdit;
    2: SpinEdit.CheckRange := not SpinEdit.CheckRange;
    3: SpinEdit.AllowBlank := not SpinEdit.AllowBlank;
    5: SpinEdit.FlatButtons := not SpinEdit.FlatButtons;
  end;
  if Index in [ 0, 1, 2, 3, 5 ] then
    DesignerModified;
end;


procedure TRzSpinEditEditor.DirectionMenuHandler( Sender: TObject );
begin
  SpinEdit.Direction := TSpinDirection( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzSpinEditEditor.OrientationMenuHandler( Sender: TObject );
begin
  SpinEdit.Orientation := TOrientation( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{==================================}
{== TRzSpinButtonsEditor Methods ==}
{==================================}

function TRzSpinButtonsEditor.SpinButtons: TRzSpinButtons;
begin
  Result := Component as TRzSpinButtons;
end;


function TRzSpinButtonsEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzSpinButtonsEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Flat Buttons';
    1: Result := 'Direction';
    2: Result := 'Orientation';
  end;
end;


procedure TRzSpinButtonsEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateDirectionMenu( Direction: TSpinDirection; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Direction );
    NewItem.Checked := SpinButtons.Direction = Direction;
    NewItem.OnClick := DirectionMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateOrientationMenu( Orientation: TOrientation; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Orientation );
    NewItem.Checked := SpinButtons.Orientation = Orientation;
    NewItem.OnClick := OrientationMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := SpinButtons.Flat;

    1: // Direction
    begin
      CreateDirectionMenu( sdUpDown, 'Up/Down' );
      CreateDirectionMenu( sdLeftRight, 'Left/Right' );
    end;

    2: // Orientation
    begin
      CreateOrientationMenu( orHorizontal, 'Horizontal' );
      CreateOrientationMenu( orVertical, 'Vertical' );
    end;
  end;
end;


procedure TRzSpinButtonsEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
    begin
      SpinButtons.Flat := not SpinButtons.Flat;
      DesignerModified;
    end;
  end;
end;


procedure TRzSpinButtonsEditor.DirectionMenuHandler( Sender: TObject );
begin
  SpinButtons.Direction := TSpinDirection( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


procedure TRzSpinButtonsEditor.OrientationMenuHandler( Sender: TObject );
begin
  SpinButtons.Orientation := TOrientation( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{==============================}
{== TRzSpinnerEditor Methods ==}
{==============================}

function TRzSpinnerEditor.Spinner: TRzSpinner;
begin
  Result := Component as TRzSpinner;
end;


function TRzSpinnerEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;


function TRzSpinnerEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Check Range';
    1: Result := '-';
    2: Result := 'Set ImageList';
    3: Result := 'Select Plus Image...';
    4: Result := 'Select Minus Image...';
  end;
end;


function TRzSpinnerEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    2: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzSpinnerEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                          var CompRefPropName: string;
                                          var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 2 then
  begin
    CompRefClass := TCustomImageList;
    CompRefPropName := 'Images';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


procedure TRzSpinnerEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := Spinner.CheckRange;
  end;
end;


procedure TRzSpinnerEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
    begin
      Spinner.CheckRange := not Spinner.CheckRange;
      DesignerModified;
    end;

    3: EditPropertyByName( 'ImageIndexPlus' );
    4: EditPropertyByName( 'ImageIndexMinus' );
  end;
end;



{===================================}
{== TRzLookupDialogEditor Methods ==}
{===================================}

function TRzLookupDialogEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


function TRzLookupDialogEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Preview Dialog';
  end;
end;


function TRzLookupDialogEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_PREVIEW_DIALOG';
  end;
end;


procedure TRzLookupDialogEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
    begin
      if Component is TRzLookupDialog then
        TRzLookupDialog( Component ).Execute;
      DesignerModified;
    end;
  end;
end;



{====================================}
{== TRzDialogButtonsEditor Methods ==}
{====================================}

function TRzDialogButtonsEditor.DialogButtons: TRzDialogButtons;
begin
  Result := Component as TRzDialogButtons;
end;


function TRzDialogButtonsEditor.GetVerbCount: Integer;
begin
  Result := 8;
end;


function TRzDialogButtonsEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := '-';
    2: Result := 'Show OK Button';
    3: Result := 'Show Cancel Button';
    4: Result := 'Show Help Button';
    5: Result := '-';
    6: Result := 'HotTrack';
    7: Result := 'XP Colors';
  end;
end;


function TRzDialogButtonsEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


function TRzDialogButtonsEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    6: Result := 'RZDESIGNEDITORS_HOTTRACK';
    7: Result := 'RZDESIGNEDITORS_XPCOLORS';
  end;
end;


procedure TRzDialogButtonsEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    2: Item.Checked := DialogButtons.ShowOkButton;
    3: Item.Checked := DialogButtons.ShowCancelButton;
    4: Item.Checked := DialogButtons.ShowHelpButton;
    6: Item.Checked := DialogButtons.HotTrack;
  end;
end;


procedure TRzDialogButtonsEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    2: DialogButtons.ShowOkButton := not DialogButtons.ShowOkButton;
    3: DialogButtons.ShowCancelButton := not DialogButtons.ShowCancelButton;
    4: DialogButtons.ShowHelpButton := not DialogButtons.ShowHelpButton;
    6: DialogButtons.HotTrack := not DialogButtons.HotTrack;

    7: // XP Colors
    begin
      DialogButtons.HotTrackColorType := htctActual;
      DialogButtons.HotTrack := True;
      DialogButtons.HotTrackColor := xpHotTrackColor;
      DialogButtons.HighlightColor := clHighlight;
      DialogButtons.ButtonColor := xpButtonFaceColor;
      DialogButtons.ButtonFrameColor := xpButtonFrameColor;
    end;

  end;
  if Index in [ 2, 3, 4, 6, 7 ] then
    DesignerModified;
end;


{================================}
{== ChangeUI Support Procedure ==}
{================================}

procedure ChangeUI( Root: TComponent; Style: Integer );
var
  I: Integer;
  C: TComponent;


  procedure SetIntProp( C: TComponent; const PropName: string; Value: Integer );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Value );
    end;
  end;

  procedure SetBooleanProp( C: TComponent; const PropName: string; Value: Boolean );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Ord( Value ) );
    end;
  end;

  procedure SetStyleProp( C: TComponent; const PropName: string; Value: TFrameStyle );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Ord( Value ) );
    end;
  end;

  procedure SetPreferenceProp( C: TComponent; const PropName: string; Value: TFramingPreference );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Ord( Value ) );
    end;
  end;

  procedure SetHotTrackColorTypeProp( C: TComponent; const PropName: string; Value: TRzHotTrackColorType );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Ord( Value ) );
    end;
  end;

  procedure SetColorProp( C: TComponent; const PropName: string; Value: TColor );
  begin
    if C <> nil then
    begin
      if IsPublishedProp( C, PropName ) then
        SetOrdProp( C, PropName, Value );
    end;
  end;

  procedure SetFrameSidesProp( C: TComponent );
  var
    Side: TSide;
    SidesSet: Cardinal;
    PropInfo: PPropInfo;
  begin
    if C <> nil then
    begin
      PropInfo := GetPropInfo( PTypeInfo( C.ClassInfo), 'FrameSides' );
      if PropInfo <> nil then
      begin
        if GetTypeData( PropInfo^.PropType^ )^.CompType^.Kind <> tkEnumeration then
          Exit;

        SidesSet := 0;
        for Side := RzCommon.sdLeft to RzCommon.sdBottom do
          SidesSet := SidesSet or ( 1 shl Ord( Side ) );

        SetOrdProp( C, PropInfo, SidesSet );
      end;
    end;
  end;


begin {= ChangeUI =}
  for I := 0 to Root.ComponentCount - 1 do
  begin
    C := Root.Components[ I ];

    // First Check from Custom Framing

    if IsPublishedProp( C, 'FrameController' ) and not ( C is TRzCustomButton ) then
    begin
      if GetObjectProp( C, 'FrameController' ) = nil then
      begin
        SetBooleanProp( C, 'FlatButtons', True );
        if Style = 1 then
          SetColorProp( C, 'FrameColor', xpEditFrameColor )
        else
          SetColorProp( C, 'FrameColor', clBtnShadow );
        SetFrameSidesProp( C );
        SetStyleProp( C, 'FrameStyle', fsFlat );
        SetBooleanProp( C, 'FrameVisible', Style <> 2 );
        SetPreferenceProp( C, 'FramingPreference', fpXPThemes );
      end;
    end
    else if ( C is TRzCustomButton ) or ( C is TRzDialogButtons ) then
    begin
      SetBooleanProp( C, 'HotTrack', Style <> 2 );

      if Style = 1 then
      begin
        SetColorProp( C, 'HotTrackColor', xpHotTrackColor );
        SetHotTrackColorTypeProp( C, 'HotTrackColorType', htctActual );

        if C is TRzCustomGlyphButton then
        begin
          SetColorProp( C, 'HighlightColor', xpRadChkMarkColor );
          SetColorProp( C, 'FrameColor', xpRadChkFrameColor );
        end
        else if C is TRzDialogButtons then
        begin
          SetColorProp( C, 'HighlightColor', clHighlight );
          SetColorProp( C, 'ButtonColor', xpButtonFaceColor );
          SetColorProp( C, 'ButtonFrameColor', xpButtonFrameColor );
        end
        else
        begin
          SetColorProp( C, 'HighlightColor', clHighlight );
          SetColorProp( C, 'Color', xpButtonFaceColor );
          SetColorProp( C, 'FrameColor', xpButtonFrameColor );
        end;
      end
      else
      begin
        SetColorProp( C, 'HotTrackColor', xpHotTrackColor );
        SetHotTrackColorTypeProp( C, 'HotTrackColorType', htctActual );

        if C is TRzCustomGlyphButton then
        begin
          SetColorProp( C, 'HighlightColor', clHighlight );
          SetColorProp( C, 'FrameColor', clBtnShadow );
        end
        else if C is TRzDialogButtons then
        begin
          SetColorProp( C, 'HighlightColor', clHighlight );
          SetColorProp( C, 'ButtonColor', clBtnFace );
          SetColorProp( C, 'ButtonFrameColor', cl3DDkShadow );
        end
        else
        begin
          SetColorProp( C, 'HighlightColor', clHighlight );
          SetColorProp( C, 'Color', clBtnFace );
          SetColorProp( C, 'FrameColor', cl3DDkShadow );
        end;
      end;
    end
    else if ( C is TRzCustomRadioGroup ) or ( C is TRzCustomCheckGroup ) then
    begin
      SetBooleanProp( C, 'ItemHotTrack', Style <> 2 );
    end
    else if ( C is TRzCalendar ) or ( C is TRzTimePicker ) or ( C is TRzColorPicker ) then
    begin
      if Style = 2 then
        SetStyleProp( C, 'BorderOuter', fsLowered )
      else
        SetStyleProp( C, 'BorderOuter', fsFlat );
      if Style = 1 then
      begin
        SetColorProp( C, 'FlatColor', xpEditFrameColor );
        SetIntProp( C, 'FlatColorAdjustment', 0 );
      end
      else
      begin
        SetColorProp( C, 'FlatColor', clBtnShadow );
        SetIntProp( C, 'FlatColorAdjustment', 30 );
      end;
    end
    else if ( C is TRzPageControl ) or ( C is TRzTabControl ) then
    begin
      if Style = 1 then
      begin
        SetHotTrackColorTypeProp( C, 'HotTrackColorType', htctActual );
        SetColorProp( C, 'HotTrackColor', xpHotTrackColor );
        if C is TRzPageControl then
          TRzPageControl( C ).TabColors.HighlightBar := xpHotTrackColor
        else
          TRzTabControl( C ).TabColors.HighlightBar := xpHotTrackColor;
        SetColorProp( C, 'FlatColor', xpTabControlFrameColor );
        SetColorProp( C, 'Color', xpTabControlColor );
        SetBooleanProp( C, 'ShowShadow', True );
      end
      else
      begin
        SetHotTrackColorTypeProp( C, 'HotTrackColorType', htctActual );
        SetColorProp( C, 'HotTrackColor', xpHotTrackColor );
        if C is TRzPageControl then
          TRzPageControl( C ).TabColors.HighlightBar := clHighlight
        else
          TRzTabControl( C ).TabColors.HighlightBar := clHighlight;
        SetColorProp( C, 'FlatColor', clBtnShadow );
        SetColorProp( C, 'Color', clBtnFace );
        SetBooleanProp( C, 'ShowShadow', True );
      end;
    end;
  end;
end; {= ChangeUI =}





{===========================}
{== TRzFormEditor Methods ==}
{===========================}

function TRzFormEditor.Form: TForm;
begin
  Result := Component as TForm;
end;


function TRzFormEditor.GetVerbCount: Integer;
begin
  {$IFDEF VCL60_OR_HIGHER}
  Result := 6;
  {$ELSE}
  Result := 13;
  {$ENDIF}
end;


function TRzFormEditor.GetVerb( Index: Integer ): string;
begin
  {$IFDEF VCL60_OR_HIGHER}
  case Index of
    0: Result := 'Quick-Design Form';
    1: Result := '-';
    2: Result := 'Add Control';
    3: Result := 'Add Component';
    4: Result := '-';
    5: Result := 'Change UI Style';
  end;
  {$ELSE}
  case Index of
    0: Result := 'Add a Group Bar';
    1: Result := 'Add a Toolbar';
    2: Result := 'Add a Status Bar';
    3: Result := 'Add a Splitter';
    4: Result := 'Add a Size Panel';
    5: Result := 'Add a Panel';
    6: Result := '-';
    7: Result := 'Add an Image List';
    8: Result := 'Add a Frame Controller';
    9: Result := 'Add a Form State component';
    10: Result := 'Add a RegIniFile component';
    11: Result := '-';
    12: Result := 'Change UI Style';
  end;
  {$ENDIF}
end;


{$IFNDEF VCL60_OR_HIGHER}

function TRzFormEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_GROUPBAR_CATEGORYVIEW';
    1: Result := 'RZDESIGNEDITORS_TOOLBAR_STYLE_NOCAPTIONS';
    2: Result := 'RZDESIGNEDITORS_STATUSBAR';
    3: Result := 'RZDESIGNEDITORS_SPLIT_HORIZONTAL';
    4: Result := 'RZDESIGNEDITORS_SIZEPANEL';
    5: Result := 'RZDESIGNEDITORS_PANEL';
    7: Result := 'RZDESIGNEDITORS_IMAGELIST';
    8: Result := 'RZDESIGNEDITORS_FRAME_CONTROLLER';
    9: Result := 'RZDESIGNEDITORS_FORM_STATE';
    10: Result := 'RZDESIGNEDITORS_REGINIFILE';
  end;
end;

{$ENDIF}

var
  ImgListOffset: Integer = 0;


{$IFDEF VCL60_OR_HIGHER}

procedure TRzFormEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );


  procedure CreateQuickDesignFormMenu( TemplateType: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := TemplateType;
    NewItem.OnClick := QuickDesignFormMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateAddControlMenu( ControlType: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := ControlType;
    case ControlType of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_GROUPBAR_CATEGORYVIEW' );
      1: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_TOOLBAR_STYLE_NOCAPTIONS' );
      2: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_STATUSBAR' );
      3: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_SPLIT_HORIZONTAL' );
      4: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_SIZEPANEL' );
      5: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_PANEL' );
    end;
    NewItem.OnClick := AddControlMenuHandler;
    Item.Add( NewItem );
  end;


  procedure CreateAddComponentMenu( ComponentType: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := ComponentType;
    case ComponentType of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_IMAGELIST' );
      5: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_FRAME_CONTROLLER' );
      6: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_FORM_STATE' );
      7: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_REGINIFILE' );
    end;
    NewItem.OnClick := AddComponentMenuHandler;
    Item.Add( NewItem );
  end;


  procedure CreateUIStyleMenu( Style: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Style;
    case Style of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_FLAT' );
      1: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_XP' );
      2: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_DEFAULT' );
    end;
    NewItem.OnClick := UIStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: // Add Template
    begin
      CreateQuickDesignFormMenu( 0, 'Main Form' );
      CreateQuickDesignFormMenu( 1, 'Main Form (w/ GroupBar)' );
      CreateQuickDesignFormMenu( 2, 'Main Form (w/ Splitter)' );
      CreateQuickDesignFormMenu( 3, 'Dialog' );
      CreateQuickDesignFormMenu( 4, 'Tabbed Dialog' );
    end;

    2: // Add Control
    begin
      CreateAddControlMenu( 0, 'Group Bar' );
      CreateAddControlMenu( 1, 'Toolbar' );
      CreateAddControlMenu( 2, 'Status Bar' );
      CreateAddControlMenu( 3, 'Splitter' );
      CreateAddControlMenu( 4, 'Size Panel' );
      CreateAddControlMenu( 5, 'Panel' );
    end;

    3: // Add Component
    begin
      CreateAddComponentMenu( 0, 'Image List' );
      CreateAddComponentMenu( 1, 'Action List' );
      CreateAddComponentMenu( 2, 'Main Menu' );
      CreateAddComponentMenu( 3, 'Popup Menu' );
      CreateAddComponentMenu( 4, 'Menu Controller' );
      CreateAddComponentMenu( 5, 'Frame Controller' );
      CreateAddComponentMenu( 6, 'Form State' );
      CreateAddComponentMenu( 7, 'RegIniFile' );
    end;

    5: // UI Style
    begin
      CreateUIStyleMenu( 0, 'Flat' );
      CreateUIStyleMenu( 1, 'Flat (XP Coloring)' );
      CreateUIStyleMenu( 2, 'Default' );
    end;
  end;
end; {= TRzFormEditor.PrepareMenuItem =}

{$ELSE}

procedure TRzFormEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateStyleMenu( Style: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Style;
    case Style of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_FLAT' );
      1: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_XP' );
      2: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_DEFAULT' );
    end;
    NewItem.OnClick := UIStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    12:
    begin
      CreateStyleMenu( 0, 'Flat' );
      CreateStyleMenu( 1, 'Flat (XP Coloring)' );
      CreateStyleMenu( 2, 'Default' );
    end;
  end;
end; {= TRzFormEditor.PrepareMenuItem =}


procedure TRzFormEditor.ExecuteVerb( Index: Integer );
var
  Splitter: TRzSplitter;
begin
  case Index of
    0: Designer.CreateComponent( TRzGroupBar, Form, 10, 10, 0, 0 );
    1: Designer.CreateComponent( TRzToolbar, Form, 10, 10, 0, 0 );
    2: Designer.CreateComponent( TRzStatusBar, Form, 10, 10, 0, 0 );

    3:
    begin
      Splitter := Designer.CreateComponent( TRzSplitter, Form, 10, 10, 0, 0 ) as TRzSplitter;
      Splitter.Align := alClient;
    end;

    4: Designer.CreateComponent( TRzSizePanel, Form, 10, 10, 168, 100 );
    5: Designer.CreateComponent( TRzPanel, Form, 200, 128, 100, 100 );

    7: // ImageList
    begin
      Designer.CreateComponent( TImageList, Form, 200 + ( ImgListOffset * 28 ), 48, 24, 24 );
      Inc( ImgListOffset );
      if ImgListOffset > 10 then
        ImgListOffset := 0;
    end;

    8: Designer.CreateComponent( TRzFrameController, Form, 200, 84, 24, 24 );
    9: Designer.CreateComponent( TRzFormState, Form, 228, 84, 24, 24 );
    10: Designer.CreateComponent( TRzRegIniFile, Form, 256, 84, 24, 24 );
  end;

  if Index in [ 0..5, 7..10 ] then
    DesignerModified;
end; {= TRzFormEditor.ExecuteVerb =}

{$ENDIF}

{$IFDEF VCL60_OR_HIGHER}

procedure TRzFormEditor.QuickDesignFormMenuHandler( Sender: TObject );
var
  CompOwner: TComponent;
  PageControl: TRzPageControl;
  DlgButtons: TRzDialogButtons;
  TabSheet: TRzTabSheet;
  Splitter: TRzSplitter;
  Toolbar: TRzToolbar;
  StatusBar: TRzStatusBar;
  GroupBar: TRzGroupBar;
begin
  case TMenuItem( Sender ).Tag of
    0: // Main Form (Toolbar + Status Bar)
    begin
      StatusBar := Designer.CreateComponent( TRzStatusBar, Form, 10, 10, 0, 0 ) as TRzStatusBar;
      StatusBar.VisualStyle := vsGradient;
      Toolbar := Designer.CreateComponent( TRzToolbar, Form, 10, 10, 0, 0 ) as TRzToolbar;
      Toolbar.Parent := Form;
      Toolbar.VisualStyle := vsGradient;
    end;

    1: // Main Form (w/ Group Bar)
    begin
      StatusBar := Designer.CreateComponent( TRzStatusBar, Form, 10, 10, 0, 0 ) as TRzStatusBar;
      StatusBar.Parent := Form;
      StatusBar.VisualStyle := vsGradient;
      GroupBar := Designer.CreateComponent( TRzGroupBar, Form, 10, 50, 0, 0 ) as TRzGroupBar;
      GroupBar.Parent := Form;
      Toolbar := Designer.CreateComponent( TRzToolbar, Form, 10, 10, 0, 0 ) as TRzToolbar;
      Toolbar.Parent := Form;
      Toolbar.VisualStyle := vsGradient;
    end;

    2: // Main Form (w/ Splitter)
    begin
      StatusBar := Designer.CreateComponent( TRzStatusBar, Form, 10, 10, 0, 0 ) as TRzStatusBar;
      StatusBar.Parent := Form;
      StatusBar.VisualStyle := vsGradient;
      Splitter := Designer.CreateComponent( TRzSplitter, Form, 10, 10, 0, 0 ) as TRzSplitter;
      Splitter.Parent := Form;
      Splitter.Align := alClient;
      Splitter.Position := Splitter.Width div 2;
      Toolbar := Designer.CreateComponent( TRzToolbar, Form, 10, 10, 0, 0 ) as TRzToolbar;
      Toolbar.Parent := Form;
      Toolbar.VisualStyle := vsGradient;
    end;

    3: // Dialog
    begin
      DlgButtons := Designer.CreateComponent( TRzDialogButtons, Form, 10, 10, 0, 0 ) as TRzDialogButtons;
      DlgButtons.HotTrack := True;
      Form.BorderStyle := bsDialog;
    end;

    4: // Tabbed Dialog
    begin
      CompOwner := Designer.GetRoot;
      if CompOwner <> nil then
      begin
        DlgButtons := Designer.CreateComponent( TRzDialogButtons, Form, 10, 10, 0, 0 ) as TRzDialogButtons;
        DlgButtons.HotTrack := True;
        Form.BorderStyle := bsDialog;

        PageControl := Designer.CreateComponent( TRzPageControl, Form, 8, 8,
                                                 Form.ClientWidth - 16,
                                                 Form.ClientHeight - 8 - DlgButtons.Height ) as TRzPageControl;
        PageControl.Anchors := [ akLeft, akTop, akRight, akBottom ];

        TabSheet := Designer.CreateComponent( TRzTabSheet, PageControl, 10, 10, 0, 0 ) as TRzTabSheet;
        TabSheet.PageControl := PageControl;
        TabSheet.Caption := 'Page One';

        TabSheet := Designer.CreateComponent( TRzTabSheet, PageControl, 10, 10, 0, 0 ) as TRzTabSheet;
        TabSheet.PageControl := PageControl;
        TabSheet.Caption := 'Page Two';

        PageControl.TabIndex := 0;
        Designer.SelectComponent( PageControl );
      end;
    end;
  end;
  if Designer <> nil then
    DesignerModified;
end; {= TRzFormEditor.QuickDesignFormMenuHandler =}


procedure TRzFormEditor.AddControlMenuHandler( Sender: TObject );
var
  Splitter: TRzSplitter;
begin
  case TMenuItem( Sender ).Tag of
    0: Designer.CreateComponent( TRzGroupBar, Form, 10, 10, 0, 0 );
    1: Designer.CreateComponent( TRzToolbar, Form, 10, 10, 0, 0 );
    2: Designer.CreateComponent( TRzStatusBar, Form, 10, 10, 0, 0 );

    3:
    begin
      Splitter := Designer.CreateComponent( TRzSplitter, Form, 10, 10, 0, 0 ) as TRzSplitter;
      Splitter.Align := alClient;
    end;

    4: Designer.CreateComponent( TRzSizePanel, Form, 10, 10, 168, 100 );
    5: Designer.CreateComponent( TRzPanel, Form, 200, 128, 100, 100 );
  end;
  if Designer <> nil then
    DesignerModified;
end;


procedure TRzFormEditor.AddComponentMenuHandler( Sender: TObject );
begin
  case TMenuItem( Sender ).Tag of
    0: // ImageList
    begin
      Designer.CreateComponent( TImageList, Form, 200 + ( ImgListOffset * 28 ),
                                48, 24, 24 );
      Inc( ImgListOffset );
      if ImgListOffset > 10 then
        ImgListOffset := 0;
    end;

    1: Designer.CreateComponent( TActionList, Form, 200, 120, 24, 24 );
    2: Designer.CreateComponent( TMainMenu, Form, 228, 120, 24, 24 );
    3: Designer.CreateComponent( TPopupMenu, Form, 256, 120, 24, 24 );
    4: Designer.CreateComponent( TRzMenuController, Form, 284, 120, 24, 24 );

    5: Designer.CreateComponent( TRzFrameController, Form, 200, 84, 24, 24 );
    6: Designer.CreateComponent( TRzFormState, Form, 228, 84, 24, 24 );
    7: Designer.CreateComponent( TRzRegIniFile, Form, 256, 84, 24, 24 );
  end;
  if Designer <> nil then
    DesignerModified;
end;

{$ENDIF}

procedure TRzFormEditor.UIStyleMenuHandler( Sender: TObject );
begin
  ChangeUI( Form, TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{============================}
{== TRzFrameEditor Methods ==}
{============================}

function TRzFrameEditor.Frame: TFrame;
begin
  Result := Component as TFrame;
end;


function TRzFrameEditor.GetVerbCount: Integer;
begin
  Result := 11;
end;


function TRzFrameEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Change UI Style';
    1: Result := '-';
    2: Result := 'Add a Group Bar';
    3: Result := 'Add a Toolbar';
    4: Result := 'Add a Status Bar';
    5: Result := 'Add a Splitter';
    6: Result := 'Add a Size Panel';
    7: Result := 'Add a Panel';
    8: Result := '-';
    9: Result := 'Add an Image List';
    10: Result := 'Add a Frame Controller';
  end;
end;


function TRzFrameEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    2: Result := 'RZDESIGNEDITORS_GROUPBAR_CATEGORYVIEW';
    3: Result := 'RZDESIGNEDITORS_TOOLBAR_STYLE_NOCAPTIONS';
    4: Result := 'RZDESIGNEDITORS_STATUSBAR';
    5: Result := 'RZDESIGNEDITORS_SPLIT_HORIZONTAL';
    6: Result := 'RZDESIGNEDITORS_SIZEPANEL';
    7: Result := 'RZDESIGNEDITORS_PANEL';
    9: Result := 'RZDESIGNEDITORS_IMAGELIST';
    10: Result := 'RZDESIGNEDITORS_FRAME_CONTROLLER';
  end;
end;


procedure TRzFrameEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateStyleMenu( Style: Integer; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Style;
    case Style of
      0: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_FLAT' );
      1: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_XP' );
      2: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_UISTYLE_DEFAULT' );
    end;
    NewItem.OnClick := StyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0:
    begin
      CreateStyleMenu( 0, 'Flat' );
      CreateStyleMenu( 1, 'Flat (XP Coloring)' );
      CreateStyleMenu( 2, 'Default' );
    end;
  end;
end;


procedure TRzFrameEditor.ExecuteVerb( Index: Integer );
var
  Splitter: TRzSplitter;
begin
  case Index of
    2: Designer.CreateComponent( TRzGroupBar, Frame, 10, 10, 0, 0 );
    3: Designer.CreateComponent( TRzToolbar, Frame, 10, 10, 0, 0 );
    4: Designer.CreateComponent( TRzStatusBar, Frame, 10, 10, 0, 0 );

    5:
    begin
      Splitter := Designer.CreateComponent( TRzSplitter, Frame, 10, 10, 0, 0 ) as TRzSplitter;
      Splitter.Align := alClient;
    end;

    6: Designer.CreateComponent( TRzSizePanel, Frame, 10, 10, 168, 100 );
    7: Designer.CreateComponent( TRzPanel, Frame, 200, 128, 100, 100 );

    9: // ImageList
    begin
      Designer.CreateComponent( TImageList, Frame, 200 + ( ImgListOffset * 28 ), 48, 24, 24 );
      Inc( ImgListOffset );
      if ImgListOffset > 10 then
        ImgListOffset := 0;
    end;

    10: Designer.CreateComponent( TRzFrameController, Frame, 200, 84, 24, 24 );
  end;
  if Index in [ 2..7, 9, 10 ] then
    DesignerModified;
end; {= TRzFrameEditor.ExecuteVerb =}


procedure TRzFrameEditor.StyleMenuHandler( Sender: TObject );
begin
  ChangeUI( Frame, TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{===================================}
{== TRzDateTimeEditEditor Methods ==}
{===================================}

function TRzDateTimeEditEditor.DateTimeEdit: TRzDateTimeEdit;
begin
  Result := Component as TRzDateTimeEdit;
end;


function TRzDateTimeEditEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;


function TRzDateTimeEditEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Date';
    1: Result := 'Time';
    2: Result := '-';
    3:
    begin
      if DateTimeEdit.EditType = etDate then
        Result := 'Visible Elements'
      else
        Result := 'Restrict Minutes (by 5)';
    end;

    4:
    begin
      if DateTimeEdit.EditType = etDate then
        Result := 'First Day of Week'
      else
        Result := 'Show How to Select Time Hint';
    end;
  end;
end;


function TRzDateTimeEditEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_DATE';
    1: Result := 'RZDESIGNEDITORS_TIME';
  end;
end;


procedure TRzDateTimeEditEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateElementsMenu( Element: TRzCalendarElement; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Element );
    NewItem.Checked := Element in DateTimeEdit.CalendarElements;
    NewItem.OnClick := ElementsMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateFirstDayOfWeekMenu( DOW: TRzFirstDayOfWeek; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( DOW );
    NewItem.Checked := DateTimeEdit.FirstDayOfWeek = DOW;
    NewItem.OnClick := FirstDayOfWeekMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := DateTimeEdit.EditType = etDate;
    1: Item.Checked := DateTimeEdit.EditType = etTime;

    3:
    begin
      if DateTimeEdit.EditType = etDate then
      begin
        CreateElementsMenu( ceYear, 'Year' );
        CreateElementsMenu( ceMonth, 'Month' );
        CreateElementsMenu( ceArrows, 'Arrows' );
        CreateElementsMenu( ceWeekNumbers, 'Week Numbers' );
        CreateElementsMenu( ceDaysOfWeek, 'Days of the Week' );
        CreateElementsMenu( ceFillDays, 'Fill Days' );
        CreateElementsMenu( ceTodayButton, 'Today Button' );
        CreateElementsMenu( ceClearButton, 'Clear Button' );
      end
      else
      begin
        Item.Checked := DateTimeEdit.RestrictMinutes;
      end;
    end;

    4:
    begin
      if DateTimeEdit.EditType = etDate then
      begin
        CreateFirstDayOfWeekMenu( fdowMonday, 'Monday' );
        CreateFirstDayOfWeekMenu( fdowTuesday, 'Tuesday' );
        CreateFirstDayOfWeekMenu( fdowWednesday, 'Wednesday' );
        CreateFirstDayOfWeekMenu( fdowThursday, 'Thursday' );
        CreateFirstDayOfWeekMenu( fdowFriday, 'Friday' );
        CreateFirstDayOfWeekMenu( fdowSaturday, 'Saturday' );
        CreateFirstDayOfWeekMenu( fdowSunday, 'Sunday' );
        CreateFirstDayOfWeekMenu( fdowLocale, 'Locale' );
      end
      else
      begin
        Item.Checked := DateTimeEdit.ShowHowToUseHint;
      end;
    end;
  end;
end;


procedure TRzDateTimeEditEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: DateTimeEdit.EditType := etDate;
    1: DateTimeEdit.EditType := etTime;

    3:
    begin
      if DateTimeEdit.EditType = etTime then
        DateTimeEdit.RestrictMinutes := not DateTimeEdit.RestrictMinutes;
    end;

    4:
    begin
      if DateTimeEdit.EditType = etTime then
        DateTimeEdit.ShowHowToUseHint := not DateTimeEdit.ShowHowToUseHint;
    end;
  end;
  if Index in [ 0, 1, 3, 4 ] then
    DesignerModified;
end;


procedure TRzDateTimeEditEditor.ElementsMenuHandler( Sender: TObject );
var
  MI: TMenuItem;
  Element: TRzCalendarElement;
begin
  MI := TMenuItem( Sender );
  Element := TRzCalendarElement( MI.Tag );
  // Remove the element if checked, b/c menu has not yet been updated to remove the check
  if MI.Checked then
    DateTimeEdit.CalendarElements := DateTimeEdit.CalendarElements - [ Element ]
  else
    DateTimeEdit.CalendarElements := DateTimeEdit.CalendarElements + [ Element ];
  DesignerModified;
end;


procedure TRzDateTimeEditEditor.FirstDayOfWeekMenuHandler( Sender: TObject );
begin
  DateTimeEdit.FirstDayOfWeek := TRzFirstDayOfWeek( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{===============================}
{== TRzCalendarEditor Methods ==}
{===============================}

function TRzCalendarEditor.Calendar: TRzCalendar;
begin
  Result := Component as TRzCalendar;
end;


function TRzCalendarEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzCalendarEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Visible Elements';
    1: Result := 'First Day of Week';
    2: Result := 'AutoSize';
  end;
end;


procedure TRzCalendarEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateElementsMenu( Element: TRzCalendarElement; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Element );
    NewItem.Checked := Element in Calendar.Elements;
    NewItem.OnClick := ElementsMenuHandler;
    Item.Add( NewItem );
  end;

  procedure CreateFirstDayOfWeekMenu( DOW: TRzFirstDayOfWeek; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( DOW );
    NewItem.Checked := Calendar.FirstDayOfWeek = DOW;
    NewItem.OnClick := FirstDayOfWeekMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0:
    begin
      CreateElementsMenu( ceYear, 'Year' );
      CreateElementsMenu( ceMonth, 'Month' );
      CreateElementsMenu( ceArrows, 'Arrows' );
      CreateElementsMenu( ceWeekNumbers, 'Week Numbers' );
      CreateElementsMenu( ceDaysOfWeek, 'Days of the Week' );
      CreateElementsMenu( ceFillDays, 'Fill Days' );
      CreateElementsMenu( ceTodayButton, 'Today Button' );
      CreateElementsMenu( ceClearButton, 'Clear Button' );
    end;

    1:
    begin
      CreateFirstDayOfWeekMenu( fdowMonday, 'Monday' );
      CreateFirstDayOfWeekMenu( fdowTuesday, 'Tuesday' );
      CreateFirstDayOfWeekMenu( fdowWednesday, 'Wednesday' );
      CreateFirstDayOfWeekMenu( fdowThursday, 'Thursday' );
      CreateFirstDayOfWeekMenu( fdowFriday, 'Friday' );
      CreateFirstDayOfWeekMenu( fdowSaturday, 'Saturday' );
      CreateFirstDayOfWeekMenu( fdowSunday, 'Sunday' );
      CreateFirstDayOfWeekMenu( fdowLocale, 'Locale' );
    end;

    2: Item.Checked := Calendar.AutoSize;
  end;
end;


procedure TRzCalendarEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    2:
    begin
      Calendar.AutoSize := not Calendar.AutoSize;
      DesignerModified;
    end;
  end;
end;


procedure TRzCalendarEditor.ElementsMenuHandler( Sender: TObject );
var
  MI: TMenuItem;
  Element: TRzCalendarElement;
begin
  MI := TMenuItem( Sender );
  Element := TRzCalendarElement( MI.Tag );
  // Remove the element if checked, b/c menu has not yet been updated to remove the check
  if MI.Checked then
    Calendar.Elements := Calendar.Elements - [ Element ]
  else
    Calendar.Elements := Calendar.Elements + [ Element ];
  DesignerModified;
end;


procedure TRzCalendarEditor.FirstDayOfWeekMenuHandler( Sender: TObject );
begin
  Calendar.FirstDayOfWeek := TRzFirstDayOfWeek( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{=================================}
{== TRzTimePickerEditor Methods ==}
{=================================}

function TRzTimePickerEditor.TimePicker: TRzTimePicker;
begin
  Result := Component as TRzTimePicker;
end;


function TRzTimePickerEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;


function TRzTimePickerEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := Format( 'Restrict Minutes (by %d)', [ TimePicker.RestrictMinutesBy ] );
    1: Result := 'Show How to Use Hint';
    2: Result := 'AutoSize';
  end;
end;


procedure TRzTimePickerEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := TimePicker.RestrictMinutes;
    1: Item.Checked := TimePicker.ShowHowToUseHint;
    2: Item.Checked := TimePicker.AutoSize;
  end;
end;


procedure TRzTimePickerEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: TimePicker.RestrictMinutes := not TimePicker.RestrictMinutes;
    1: TimePicker.ShowHowToUseHint := not TimePicker.ShowHowToUseHint;
    2: TimePicker.AutoSize := not TimePicker.AutoSize;
  end;
  if Index in [ 0..2 ] then
    DesignerModified;
end;


{==================================}
{== TRzColorPickerEditor Methods ==}
{==================================}

function TRzColorPickerEditor.ColorPicker: TRzColorPicker;
begin
  Result := Component as TRzColorPicker;
end;


function TRzColorPickerEditor.GetVerbCount: Integer;
begin
  Result := 11;
end;


function TRzColorPickerEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Show All Areas';
    1: Result := '-';
    2: Result := 'Show No Color Area';
    3: Result := 'Show Default Color';
    4: Result := 'Show Custom Color Area';
    5: Result := 'Show System Colors';
    6: Result := '-';
    7: Result := 'Show Color Hints';
    8: Result := 'AutoSize';
    9: Result := '-';
    10: Result := 'Set CustomColors';
  end;
end;


function TRzColorPickerEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    10: Result := 'RZDESIGNEDITORS_EDIT_COLORS';
  end;
end;


function TRzColorPickerEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                              var CompRefPropName: string;
                                              var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 10 then
  begin
    CompRefClass := TRzCustomColors;
    CompRefPropName := 'CustomColors';
    CompRefMenuHandler := CustomColorsMenuHandler;
    Result := True;
  end
end;


procedure TRzColorPickerEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    2: Item.Checked := ColorPicker.ShowNoColor;
    3: Item.Checked := ColorPicker.ShowDefaultColor;
    4: Item.Checked := ColorPicker.ShowCustomColor;
    5: Item.Checked := ColorPicker.ShowSystemColors;
    7: Item.Checked := ColorPicker.ShowColorHints;
    8: Item.Checked := ColorPicker.AutoSize;
  end;
end;


procedure TRzColorPickerEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0:
    begin
      ColorPicker.ShowNoColor := True;
      ColorPicker.ShowDefaultColor := True;
      ColorPicker.ShowCustomColor := True;
      ColorPicker.ShowSystemColors := True;
    end;

    2: ColorPicker.ShowNoColor := not ColorPicker.ShowNoColor;
    3: ColorPicker.ShowDefaultColor := not ColorPicker.ShowDefaultColor;
    4: ColorPicker.ShowCustomColor := not ColorPicker.ShowCustomColor;
    5: ColorPicker.ShowSystemColors := not ColorPicker.ShowSystemColors;
    7: ColorPicker.ShowColorHints := not ColorPicker.ShowColorHints;
    8: ColorPicker.AutoSize := not ColorPicker.AutoSize;
  end;
  if Index in [ 0, 2..5, 7, 8 ] then
    DesignerModified
end;


procedure TRzColorPickerEditor.CustomColorsMenuHandler( Sender: TObject );
var
  S: string;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ColorPicker.CustomColors := Designer.GetRoot.FindComponent( S ) as TRzCustomColors;
    DesignerModified;
  end;
end;


{================================}
{== TRzColorEditEditor Methods ==}
{================================}

function TRzColorEditEditor.ColorEdit: TRzColorEdit;
begin
  Result := Component as TRzColorEdit;
end;


function TRzColorEditEditor.GetVerbCount: Integer;
begin
  Result := 7;
end;


function TRzColorEditEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Show No Color Area';
    1: Result := 'Show Default Color';
    2: Result := 'Show Custom Color Area';
    3: Result := 'Show System Colors';
    4: Result := 'Show Color Hints';
    5: Result := '-';
    6: Result := 'Set CustomColors';
  end;
end;


function TRzColorEditEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    6: Result := 'RZDESIGNEDITORS_EDIT_COLORS';
  end;
end;


function TRzColorEditEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                            var CompRefPropName: string;
                                            var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 6 then
  begin
    CompRefClass := TRzCustomColors;
    CompRefPropName := 'CustomColors';
    CompRefMenuHandler := CustomColorsMenuHandler;
    Result := True;
  end
end;


procedure TRzColorEditEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := ColorEdit.ShowNoColor;
    1: Item.Checked := ColorEdit.ShowDefaultColor;
    2: Item.Checked := ColorEdit.ShowCustomColor;
    3: Item.Checked := ColorEdit.ShowSystemColors;
    4: Item.Checked := ColorEdit.ShowColorHints;
  end;
end;


procedure TRzColorEditEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: ColorEdit.ShowNoColor := not ColorEdit.ShowNoColor;
    1: ColorEdit.ShowDefaultColor := not ColorEdit.ShowDefaultColor;
    2: ColorEdit.ShowCustomColor := not ColorEdit.ShowCustomColor;
    3: ColorEdit.ShowSystemColors := not ColorEdit.ShowSystemColors;
    4: ColorEdit.ShowColorHints := not ColorEdit.ShowColorHints;
  end;
  if Index in [ 0..4 ] then
    DesignerModified;
end;


procedure TRzColorEditEditor.CustomColorsMenuHandler( Sender: TObject );
var
  S: string;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ColorEdit.CustomColors := Designer.GetRoot.FindComponent( S ) as TRzCustomColors;
    DesignerModified;
  end;
end;


{=================================}
{== TRzLEDDisplayEditor Methods ==}
{=================================}

function TRzLEDDisplayEditor.LEDDisplay: TRzLEDDisplay;
begin
  Result := Component as TRzLEDDisplay;
end;


function TRzLEDDisplayEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzLEDDisplayEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Scroll Display';
    1: Result := '-';
    2: Result := 'Scroll Left';
    3: Result := 'Scroll Right';
  end;
end;


function TRzLEDDisplayEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    2: Result := 'RZDESIGNEDITORS_SCROLL_LEFT';
    3: Result := 'RZDESIGNEDITORS_SCROLL_RIGHT';
  end;
end;


procedure TRzLEDDisplayEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := LEDDisplay.Scrolling;
    2: Item.Checked := LEDDisplay.ScrollType = stRightToLeft;
    3: Item.Checked := LEDDisplay.ScrollType = stLeftToRight;
  end;
end;


procedure TRzLEDDisplayEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: LEDDisplay.Scrolling := not LEDDisplay.Scrolling;
    2: LEDDisplay.ScrollType := stRightToLeft;
    3: LEDDisplay.ScrollType := stLeftToRight;
  end;
  if Index in [ 0, 2, 3 ] then
    DesignerModified;
end;



{=================================}
{== TRzStatusPaneEditor Methods ==}
{=================================}

function TRzStatusPaneEditor.GetVerbCount: Integer;
begin
  Result := 8;
end;


function TRzStatusPaneEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Flat Style';
    1: Result := 'Traditional Style';
    2: Result := '-';
    3: Result := 'AutoSize';
    4: Result := 'Alignment';
    5: Result := 'Blinking';
    6: Result := '-';
    7: Result := 'Align';
  end;
end;


function TRzStatusPaneEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 0;
end;


function TRzStatusPaneEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 1;
end;


function TRzStatusPaneEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 3;
end;


function TRzStatusPaneEditor.AlignmentMenuIndex: Integer;
begin
  Result := 4;
end;


function TRzStatusPaneEditor.BlinkingMenuIndex: Integer;
begin
  Result := 5;
end;


function TRzStatusPaneEditor.AlignMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzStatusPaneEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  if Index = FlatStyleMenuIndex then
    Result := 'RZDESIGNEDITORS_STATUS_FLAT'
  else if Index = TraditionalStyleMenuIndex then
    Result := 'RZDESIGNEDITORS_STATUS_TRADITIONAL';
end;


procedure TRzStatusPaneEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateAlignmentMenu( Alignment: TAlignment; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Alignment );
    NewItem.Checked := GetOrdProp( Component, 'Alignment' ) = Ord( Alignment );
    NewItem.OnClick := AlignmentMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  if Index = FlatStyleMenuIndex then
    Item.Checked := GetOrdProp( Component, 'FrameStyle' ) = Ord( fsFlat )
  else if Index = TraditionalStyleMenuIndex then
    Item.Checked := GetOrdProp( Component, 'FrameStyle' ) = Ord( fsStatus )
  else if Index = AutoSizeMenuIndex then
    Item.Checked := GetOrdProp( Component, 'AutoSize' ) = 1
  else if Index = AlignmentMenuIndex then
  begin
    CreateAlignmentMenu( taLeftJustify, 'Left Justify' );
    CreateAlignmentMenu( taRightJustify, 'Right Justify' );
    CreateAlignmentMenu( taCenter, 'Center' );
  end
  else if Index = BlinkingMenuIndex then
    Item.Checked := GetOrdProp( Component, 'Blinking' ) = 1;
end;


procedure TRzStatusPaneEditor.ExecuteVerb( Index: Integer );
var
  B: Boolean;
begin
  inherited;

  if Index = FlatStyleMenuIndex then
  begin
    SetOrdProp( Component, 'FrameStyle', Ord( fsFlat ) );
    DesignerModified;
  end
  else if Index = TraditionalStyleMenuIndex then
  begin
    SetOrdProp( Component, 'FrameStyle', Ord( fsStatus ) );
    DesignerModified;
  end
  else if Index = AutoSizeMenuIndex then
  begin
    B := GetOrdProp( Component, 'AutoSize' ) = 1;
    SetOrdProp( Component, 'AutoSize', Ord( not B ) );
    DesignerModified;
  end
  else if Index = BlinkingMenuIndex then
  begin
    B := GetOrdProp( Component, 'Blinking' ) = 1;
    SetOrdProp( Component, 'Blinking', Ord( not B ) );
    DesignerModified;
  end;
end;


procedure TRzStatusPaneEditor.AlignmentMenuHandler( Sender: TObject );
begin
  SetOrdProp( Component, 'Alignment', TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{==================================}
{== TRzGlyphStatusEditor Methods ==}
{==================================}

function TRzGlyphStatusEditor.GlyphStatus: TRzGlyphStatus;
begin
  Result := Component as TRzGlyphStatus;
end;


function TRzGlyphStatusEditor.GetVerbCount: Integer;
begin
  Result := 15;
end;


function TRzGlyphStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Select Image...';
    1: Result := 'Select Disabled Image...';
    2: Result := 'Set ImageList';
    3: Result := '-';
    4: Result := 'Show Glyph';
    5: Result := 'Glyph Alignment';
    6: Result := '-';
    7: Result := 'Flat Style';
    8: Result := 'Traditional Style';
    9: Result := '-';
    10: Result := 'AutoSize';
    11: Result := 'Alignment';
    12: Result := 'Blinking';
    13: Result := '-';
    14: Result := 'Align';
  end;
end;


function TRzGlyphStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzGlyphStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 8;
end;


function TRzGlyphStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 10;
end;


function TRzGlyphStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 11;
end;


function TRzGlyphStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 12;
end;


function TRzGlyphStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 14;
end;


function TRzGlyphStatusEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := inherited MenuBitmapResourceName( Index );

  case Index of
    0: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
    1: Result := 'RZDESIGNEDITORS_SELECT_DISABLED_IMAGE';
    2: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzGlyphStatusEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                              var CompRefPropName: string;
                                              var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 2 then
  begin
    CompRefClass := TCustomImageList;
    CompRefPropName := 'Images';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


procedure TRzGlyphStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateGlyphAlignmentMenu( GlyphAlignment: TGlyphAlignment; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( GlyphAlignment );
    NewItem.Checked := GlyphStatus.GlyphAlignment = GlyphAlignment;
    NewItem.OnClick := GlyphAlignmentMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    4: Item.Checked := GlyphStatus.ShowGlyph;
    5:
    begin
      CreateGlyphAlignmentMenu( gaLeft, 'Left' );
      CreateGlyphAlignmentMenu( gaRight, 'Right' );
    end;
  end;
end;


procedure TRzGlyphStatusEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    0: EditPropertyByName( 'ImageIndex' );
    1: EditPropertyByName( 'DisabledIndex' );
    4: GlyphStatus.ShowGlyph := not GlyphStatus.ShowGlyph;
  end;
  if Index in [ 0, 1, 4 ] then
    DesignerModified;
end;


procedure TRzGlyphStatusEditor.GlyphAlignmentMenuHandler( Sender: TObject );
begin
  GlyphStatus.GlyphAlignment := TGlyphAlignment( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{====================================}
{== TRzMarqueeStatusEditor Methods ==}
{====================================}

function TRzMarqueeStatusEditor.MarqueeStatus: TRzMarqueeStatus;
begin
  Result := Component as TRzMarqueeStatus;
end;


function TRzMarqueeStatusEditor.GetVerbCount: Integer;
begin
  Result := 13;
end;


function TRzMarqueeStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Scroll Caption';
    1: Result := '-';
    2: Result := 'Scroll Left';
    3: Result := 'Scroll Right';
    4: Result := '-';
    5: Result := 'Flat Style';
    6: Result := 'Traditional Style';
    7: Result := '-';
    8: Result := 'AutoSize';
    9: Result := 'Alignment';
    10: Result := 'Blinking';
    11: Result := '-';
    12: Result := 'Align';
  end;
end;


function TRzMarqueeStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 5;
end;


function TRzMarqueeStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzMarqueeStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 8;
end;


function TRzMarqueeStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 9;
end;


function TRzMarqueeStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 10;
end;


function TRzMarqueeStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 12;
end;


function TRzMarqueeStatusEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := inherited MenuBitmapResourceName( Index );

  case Index of
    2: Result := 'RZDESIGNEDITORS_SCROLL_LEFT';
    3: Result := 'RZDESIGNEDITORS_SCROLL_RIGHT';
  end;
end;


procedure TRzMarqueeStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := MarqueeStatus.ScrollType = RzCommon.stNone;
    2: Item.Checked := MarqueeStatus.ScrollType = RzCommon.stRightToLeft;
    3: Item.Checked := MarqueeStatus.ScrollType = RzCommon.stLeftToRight;
  end;
end;


procedure TRzMarqueeStatusEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    0: MarqueeStatus.ScrollType := RzCommon.stNone;
    2: MarqueeStatus.ScrollType := RzCommon.stRightToLeft;
    3: MarqueeStatus.ScrollType := RzCommon.stLeftToRight;
  end;
  if Index in [ 0, 2, 3 ] then
    DesignerModified;
end;


{==================================}
{== TRzClockStatusEditor Methods ==}
{==================================}

function TRzClockStatusEditor.ClockStatus: TRzClockStatus;
begin
  Result := Component as TRzClockStatus;
end;


function TRzClockStatusEditor.GetVerbCount: Integer;
begin
  Result := 10;
end;


function TRzClockStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Format';
    1: Result := '-';
    2: Result := 'Flat Style';
    3: Result := 'Traditional Style';
    4: Result := '-';
    5: Result := 'AutoSize';
    6: Result := 'Alignment';
    7: Result := 'Blinking';
    8: Result := '-';
    9: Result := 'Align';
  end;
end;


function TRzClockStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 2;
end;


function TRzClockStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 3;
end;


function TRzClockStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 5;
end;


function TRzClockStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzClockStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzClockStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 9;
end;


procedure TRzClockStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateFormatMenu( const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.AutoHotkeys := maManual;
    NewItem.Caption := Caption;
    NewItem.Checked := ClockStatus.Format = Caption;
    NewItem.OnClick := ClockMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: // Format
    begin
      Item.AutoHotKeys := maManual;
      CreateFormatMenu( 'c' );
      CreateFormatMenu( 't' );
      CreateFormatMenu( 'tt' );
      CreateFormatMenu( 'ddddd' );
      CreateFormatMenu( 'dddddd' );
      CreateFormatMenu( 'ddddd t' );
      CreateFormatMenu( 'ddddd tt' );
      CreateFormatMenu( 'dddddd tt' );
      CreateFormatMenu( 'm/d/yy' );
      CreateFormatMenu( 'mm/dd/yy' );
      CreateFormatMenu( 'd/m/yy');
      CreateFormatMenu( 'dd/mm/yy');
      CreateFormatMenu( 'dd/mm/yyyy');
      CreateFormatMenu( 'h:n:s' );
      CreateFormatMenu( 'h:n:s a/p' );
      CreateFormatMenu( 'h:nn:ss' );
      CreateFormatMenu( 'h:nn:ss am/pm');
      CreateFormatMenu( 'hh:nn:ss' );
      CreateFormatMenu( 'hh:nn:ss am/pm' );
    end;
  end;
end;


procedure TRzClockStatusEditor.ClockMenuHandler( Sender: TObject );
begin
  ClockStatus.Format := TMenuItem( Sender ).Caption;
  DesignerModified;
end;



{================================}
{== TRzKeyStatusEditor Methods ==}
{================================}

function TRzKeyStatusEditor.KeyStatus: TRzKeyStatus;
begin
  Result := Component as TRzKeyStatus;
end;


function TRzKeyStatusEditor.GetVerbCount: Integer;
begin
  Result := 13;
end;


function TRzKeyStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Caps Lock';
    1: Result := 'Num Lock';
    2: Result := 'Scroll Lock';
    3: Result := 'Insert';
    4: Result := '-';
    5: Result := 'Flat Style';
    6: Result := 'Traditional Style';
    7: Result := '-';
    8: Result := 'AutoSize';
    9: Result := 'Alignment';
    10: Result := 'Blinking';
    11: Result := '-';
    12: Result := 'Align';
  end;
end;


function TRzKeyStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 5;
end;


function TRzKeyStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzKeyStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 8;
end;


function TRzKeyStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 9;
end;


function TRzKeyStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 10;
end;


function TRzKeyStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 12;
end;


procedure TRzKeyStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := KeyStatus.Key = tkCapsLock;
    1: Item.Checked := KeyStatus.Key = tkNumLock;
    2: Item.Checked := KeyStatus.Key = tkScrollLock;
    3: Item.Checked := KeyStatus.Key = tkInsert;
  end;
end;


procedure TRzKeyStatusEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    0: KeyStatus.Key := tkCapsLock;
    1: KeyStatus.Key := tkNumLock;
    2: KeyStatus.Key := tkScrollLock;
    3: KeyStatus.Key := tkInsert;
  end;
  if Index in [ 0, 1, 2, 3 ] then
    DesignerModified;
end;


{========================================}
{== TRzVersionInfoStatusEditor Methods ==}
{========================================}

function TRzVersionInfoStatusEditor.VersionInfoStatus: TRzVersionInfoStatus;
begin
  Result := Component as TRzVersionInfoStatus;
end;


function TRzVersionInfoStatusEditor.GetVerbCount: Integer;
begin
  Result := 11;
end;


function TRzVersionInfoStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Set VersionInfo';
    1: Result := 'Select Field';
    2: Result := '-';
    3: Result := 'Flat Style';
    4: Result := 'Traditional Style';
    5: Result := '-';
    6: Result := 'AutoSize';
    7: Result := 'Alignment';
    8: Result := 'Blinking';
    9: Result := '-';
    10: Result := 'Align';
  end;
end;


function TRzVersionInfoStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 3;
end;


function TRzVersionInfoStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 4;
end;


function TRzVersionInfoStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzVersionInfoStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzVersionInfoStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 8;
end;


function TRzVersionInfoStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 10;
end;


function TRzVersionInfoStatusEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                                    var CompRefPropName: string;
                                                    var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 0 then
  begin
    CompRefClass := TRzVersionInfo;
    CompRefPropName := 'VersionInfo';
    CompRefMenuHandler := VersionInfoMenuHandler;
    Result := True;
  end
end;


procedure TRzVersionInfoStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateFieldMenu( Field: TRzVersionInfoField; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Field );
    NewItem.Checked := VersionInfoStatus.Field = Field;
    NewItem.OnClick := FieldMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  if Index = 1 then
  begin
    CreateFieldMenu( vifCompanyName, 'CompanyName' );
    CreateFieldMenu( vifFileDescription, 'FileDescription' );
    CreateFieldMenu( vifFileVersion, 'FileVersion' );
    CreateFieldMenu( vifInternalName, 'InternalName' );
    CreateFieldMenu( vifCopyright, 'Copyright' );
    CreateFieldMenu( vifTrademarks, 'Trademarks' );
    CreateFieldMenu( vifOriginalFilename, 'OriginalFilename' );
    CreateFieldMenu( vifProductName, 'ProductName' );
    CreateFieldMenu( vifProductVersion, 'ProductVersion' );
    CreateFieldMenu( vifComments, 'Comments' );
  end;
end;


procedure TRzVersionInfoStatusEditor.VersionInfoMenuHandler( Sender: TObject );
var
  S: string;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    VersionInfoStatus.VersionInfo := Designer.GetRoot.FindComponent( S ) as TRzVersionInfo;
    DesignerModified;
  end;
end;


procedure TRzVersionInfoStatusEditor.FieldMenuHandler( Sender: TObject );
begin
  VersionInfoStatus.Field := TRzVersionInfoField( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{=====================================}
{== TRzResourceStatusEditor Methods ==}
{=====================================}

function TRzResourceStatusEditor.ResourceStatus: TRzResourceStatus;
begin
  Result := Component as TRzResourceStatus;
end;


function TRzResourceStatusEditor.GetVerbCount: Integer;
begin
  Result := 13;
end;


function TRzResourceStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Traditional Bar Style';
    1: Result := 'LED Bar Style';
    2: Result := 'Gradient Bar Style';
    3: Result := '-';
    4: Result := 'Show Percent';
    5: Result := '-';
    6: Result := 'Flat Style';
    7: Result := 'Traditional Style';
    8: Result := '-';
    9: Result := 'Alignment';
    10: Result := 'Blinking';
    11: Result := '-';
    12: Result := 'Align';
  end;
end;


function TRzResourceStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzResourceStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzResourceStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzResourceStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := 9;
end;


function TRzResourceStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := 10;
end;


function TRzResourceStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 12;
end;


function TRzResourceStatusEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := inherited MenuBitmapResourceName( Index );

  case Index of
    0: Result := 'RZDESIGNEDITORS_PROGRESS_TRADITIONAL';
    1: Result := 'RZDESIGNEDITORS_PROGRESS_LED';
    2: Result := 'RZDESIGNEDITORS_PROGRESS_GRADIENT';
  end;
end;


procedure TRzResourceStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := ResourceStatus.BarStyle = bsTraditional;
    1: Item.Checked := ResourceStatus.BarStyle = bsLED;
    2: Item.Checked := ResourceStatus.BarStyle = bsGradient;
    4: Item.Checked := ResourceStatus.ShowPercent;
  end;
end;


procedure TRzResourceStatusEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    0: ResourceStatus.BarStyle := bsTraditional;
    1: ResourceStatus.BarStyle := bsLED;
    2: ResourceStatus.BarStyle := bsGradient;
    4: ResourceStatus.ShowPercent := not ResourceStatus.ShowPercent;
  end;
  if Index in [ 0, 1, 2, 4 ] then
    DesignerModified;
end;


{=====================================}
{== TRzProgressStatusEditor Methods ==}
{=====================================}

function TRzProgressStatusEditor.ProgressStatus: TRzProgressStatus;
begin
  Result := Component as TRzProgressStatus;
end;


function TRzProgressStatusEditor.GetVerbCount: Integer;
begin
  Result := 10;
end;


function TRzProgressStatusEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Traditional Bar Style';
    1: Result := 'LED Bar Style';
    2: Result := 'Gradient Bar Style';
    3: Result := '-';
    4: Result := 'Show Percent';
    5: Result := '-';
    6: Result := 'Flat Style';
    7: Result := 'Traditional Style';
    8: Result := '-';
    9: Result := 'Align';
  end;
end;


function TRzProgressStatusEditor.FlatStyleMenuIndex: Integer;
begin
  Result := 6;
end;


function TRzProgressStatusEditor.TraditionalStyleMenuIndex: Integer;
begin
  Result := 7;
end;


function TRzProgressStatusEditor.AutoSizeMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzProgressStatusEditor.AlignmentMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzProgressStatusEditor.BlinkingMenuIndex: Integer;
begin
  Result := -1;
end;


function TRzProgressStatusEditor.AlignMenuIndex: Integer;
begin
  Result := 9;
end;


function TRzProgressStatusEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  Result := inherited MenuBitmapResourceName( Index );

  case Index of
    0: Result := 'RZDESIGNEDITORS_PROGRESS_TRADITIONAL';
    1: Result := 'RZDESIGNEDITORS_PROGRESS_LED';
    2: Result := 'RZDESIGNEDITORS_PROGRESS_GRADIENT';
  end;
end;


procedure TRzProgressStatusEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := ProgressStatus.BarStyle = bsTraditional;
    1: Item.Checked := ProgressStatus.BarStyle = bsLED;
    2: Item.Checked := ProgressStatus.BarStyle = bsGradient;
    4: Item.Checked := ProgressStatus.ShowPercent;
  end;
end;


procedure TRzProgressStatusEditor.ExecuteVerb( Index: Integer );
begin
  inherited;

  case Index of
    0: ProgressStatus.BarStyle := bsTraditional;
    1: ProgressStatus.BarStyle := bsLED;
    2: ProgressStatus.BarStyle := bsGradient;
    4: ProgressStatus.ShowPercent := not ProgressStatus.ShowPercent;
  end;
  if Index in [ 0, 1, 2, 4 ] then
    DesignerModified;
end;


{===========================}
{== TRzLineEditor Methods ==}
{===========================}

function TRzLineEditor.Line: TRzLine;
begin
  Result := Component as TRzLine;
end;


function TRzLineEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzLineEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Slope Down';
    1: Result := 'Slope Up';
    2: Result := '-';
    3: Result := 'Show Arrows';
  end;
end;


procedure TRzLineEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateShowArrowsMenu( ShowArrows: TRzShowArrows; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( ShowArrows );
    NewItem.Checked := Line.ShowArrows = ShowArrows;
    NewItem.OnClick := ShowArrowsMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := Line.LineSlope = lsDown;
    1: Item.Checked := Line.LineSlope = lsUp;

    3:
    begin
      CreateShowArrowsMenu( saNone, 'No Arrows' );
      CreateShowArrowsMenu( saStart, 'Arrow at Start' );
      CreateShowArrowsMenu( saEnd, 'Arrow at End' );
      CreateShowArrowsMenu( saBoth, 'Arrows at Both Ends' );
    end;
  end;
end;


procedure TRzLineEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: Line.LineSlope := lsDown;
    1: Line.LineSlope := lsUp;
  end;
  DesignerModified;
end;


procedure TRzLineEditor.ShowArrowsMenuHandler( Sender: TObject );
begin
  Line.ShowArrows := TRzShowArrows( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{===================================}
{== TRzCustomColorsEditor Methods ==}
{===================================}

function TRzCustomColorsEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;


function TRzCustomColorsEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Edit Custom Colors';
    1: Result := 'Set RegIniFile';
  end;
end;


function TRzCustomColorsEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_EDIT_COLORS';
    1: Result := 'RZDESIGNEDITORS_REGINIFILE';
  end;
end;


function TRzCustomColorsEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                               var CompRefPropName: string;
                                               var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 1 then
  begin
    CompRefClass := TRzRegIniFile;
    CompRefPropName := 'RegIniFile';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


procedure TRzCustomColorsEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Colors' );
  end;
end;


{==================================}
{== TRzShapeButtonEditor Methods ==}
{==================================}

function TRzShapeButtonEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


function TRzShapeButtonEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Select Bitmap...';
  end;
end;


function TRzShapeButtonEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
  end;
end;


procedure TRzShapeButtonEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Bitmap' );
  end;
end;


{================================}
{== TRzFormStateEditor Methods ==}
{================================}

function TRzFormStateEditor.FormState: TRzFormState;
begin
  Result := Component as TRzFormState;
end;


function TRzFormStateEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


function TRzFormStateEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Set RegIniFile';
  end;
end;


function TRzFormStateEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_REGINIFILE';
  end;
end;


function TRzFormStateEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                                  var CompRefPropName: string;
                                                  var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 0 then
  begin
    CompRefClass := TRzRegIniFile;
    CompRefPropName := 'RegIniFile';
    CompRefMenuHandler := nil;
    Result := True;
  end
end;


{================================}
{== TRzFormShapeEditor Methods ==}
{================================}

function TRzFormShapeEditor.FormShape: TRzFormShape;
begin
  Result := Component as TRzFormShape;
end;


function TRzFormShapeEditor.GetVerbCount: Integer;
begin
  Result := 9;
end;


function TRzFormShapeEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Picture...';
    1: Result := '-';
    2: Result := 'AllowFormDraw';
    3: Result := 'Transparent';
    4: Result := 'Proportional';
    5: Result := 'Stretch';
    6: Result := 'Center';
    7: Result := '-';
    8: Result := 'Align';
  end;
end;


function TRzFormShapeEditor.AlignMenuIndex: Integer;
begin
  Result := 8;
end;


function TRzFormShapeEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
  end;
end;


procedure TRzFormShapeEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    2: Item.Checked := FormShape.AllowFormDrag;
    3: Item.Checked := FormShape.Transparent;
    4:
    begin
      {$IFDEF VCL60_OR_HIGHER}
      Item.Checked := FormShape.Proportional;
      {$ELSE}
      Item.Enabled := False;
      {$ENDIF}
    end;
    5: Item.Checked := FormShape.Stretch;
    6: Item.Checked := FormShape.Center;
  end;
end;


procedure TRzFormShapeEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'Picture' );
    2: FormShape.AllowFormDrag := not FormShape.AllowFormDrag;
    3: FormShape.Transparent := not FormShape.Transparent;
    {$IFDEF VCL60_OR_HIGHER}
    4: FormShape.Proportional := not FormShape.Proportional;
    {$ENDIF}
    5: FormShape.Stretch := not FormShape.Stretch;
    6: FormShape.Center := not FormShape.Center;
  end;
  if Index in [ 2..6 ] then
    DesignerModified;
end;


{=============================}
{== TRzBorderEditor Methods ==}
{=============================}

function TRzBorderEditor.Border: TRzBorder;
begin
  Result := Component as TRzBorder;
end;


function TRzBorderEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;


function TRzBorderEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := 'Remove Border';
  end;
end;


function TRzBorderEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


procedure TRzBorderEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    1:
    begin
      Border.BorderOuter := fsNone;
      Border.BorderInner := fsNone;
      Border.BorderWidth := 0;
      DesignerModified;
    end;
  end;
end;


{===============================}
{== TRzTrayIconEditor Methods ==}
{===============================}

function TRzTrayIconEditor.TrayIcon: TRzTrayIcon;
begin
  Result := Component as TRzTrayIcon;
end;


function TRzTrayIconEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzTrayIconEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Select Icon...';
    1: Result := 'Set Icons (ImageList)';
    2: Result := '-';
    3: Result := 'Set PopupMenu';
  end;
end;


function TRzTrayIconEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
    1: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzTrayIconEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                           var CompRefPropName: string;
                                           var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  if Index = 1 then
  begin
    CompRefClass := TCustomImageList;
    CompRefPropName := 'Icons';
    CompRefMenuHandler := IconsMenuHandler;
    Result := True;
  end
  else if Index = 3 then
  begin
    CompRefClass := TPopupMenu;
    CompRefPropName := 'PopupMenu';
    CompRefMenuHandler := PopupMenuMenuHandler;
    Result := True;
  end;
end;


procedure TRzTrayIconEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'IconIndex' );
  end;
end;


procedure TRzTrayIconEditor.IconsMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'Icons', ImageList );
    DesignerModified;
  end;
end;


procedure TRzTrayIconEditor.PopupMenuMenuHandler( Sender: TObject );
var
  S: string;
  PM: TPopupMenu;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    PM := Designer.GetRoot.FindComponent( S ) as TPopupMenu;
    SetObjectProp( Component, 'PopupMenu', PM );
    DesignerModified;
  end;
end;


{===============================}
{== TRzAnimatorEditor Methods ==}
{===============================}

function TRzAnimatorEditor.Animator: TRzAnimator;
begin
  Result := Component as TRzAnimator;
end;


function TRzAnimatorEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzAnimatorEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Select Image...';
    1: Result := 'Set ImageList';
    2: Result := '-';
    3: Result := 'Animate';
  end;
end;


function TRzAnimatorEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_SELECT_IMAGE';
    1: Result := 'RZDESIGNEDITORS_IMAGELIST';
  end;
end;


function TRzAnimatorEditor.GetCompRefData( Index: Integer; var CompRefClass: TComponentClass;
                                           var CompRefPropName: string;
                                           var CompRefMenuHandler: TNotifyEvent ): Boolean;
begin
  Result := False;
  case Index of
    1:
    begin
      CompRefClass := TCustomImageList;
      CompRefPropName := 'ImageList';
      CompRefMenuHandler := ImageListMenuHandler;
      Result := True;
    end;
  end;
end;


procedure TRzAnimatorEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    3: Item.Checked := Animator.Animate;
  end;
end;


procedure TRzAnimatorEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: EditPropertyByName( 'ImageIndex' );

    3:
    begin
      Animator.Animate := not Animator.Animate;
      DesignerModified;
    end;
  end;
end;


procedure TRzAnimatorEditor.ImageListMenuHandler( Sender: TObject );
var
  S: string;
  ImageList: TCustomImageList;
begin
  if Designer.GetRoot <> nil then
  begin
    S := TMenuItem( Sender ).Caption;
    ImageList := Designer.GetRoot.FindComponent( S ) as TCustomImageList;
    SetObjectProp( Component, 'ImageList', ImageList );
    DesignerModified;
  end;
end;



{================================}
{== TRzSeparatorEditor Methods ==}
{================================}

function TRzSeparatorEditor.Separator: TRzSeparator;
begin
  Result := Component as TRzSeparator;
end;


function TRzSeparatorEditor.GetVerbCount: Integer;
begin
  Result := 6;
end;


function TRzSeparatorEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Horizontal';
    1: Result := 'Vertical';
    2: Result := '-';
    3: Result := 'Highlight Location';
    4: Result := '-';
    5: Result := 'Align';
  end;
end;


function TRzSeparatorEditor.AlignMenuIndex: Integer;
begin
  Result := 5;
end;


function TRzSeparatorEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_SEPARATOR_HORIZONTAL';
    1: Result := 'RZDESIGNEDITORS_SEPARATOR_VERTICAL';
  end;
end;


procedure TRzSeparatorEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateHighlightLocationMenu( Location: TRzHighlightLocation; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Location );
    NewItem.Checked := Separator.HighlightLocation = Location;
    NewItem.OnClick := HighlightLocationMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := Separator.Orientation = orHorizontal;
    1: Item.Checked := Separator.Orientation = orVertical;

    3:
    begin
      CreateHighlightLocationMenu( hlCenter, 'Center' );
      CreateHighlightLocationMenu( hlUpperLeft, 'Upper-Left' );
      CreateHighlightLocationMenu( hlLowerRight, 'Lower-Right' );
    end;
  end;
end;


procedure TRzSeparatorEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: Separator.Orientation := orHorizontal;
    1: Separator.Orientation := orVertical;
  end;
  if Index in [ 0, 1 ] then
    DesignerModified;
end;


procedure TRzSeparatorEditor.HighlightLocationMenuHandler( Sender: TObject );
begin
  Separator.HighlightLocation := TRzHighlightLocation( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{=============================}
{== TRzSpacerEditor Methods ==}
{=============================}

function TRzSpacerEditor.Spacer: TRzSpacer;
begin
  Result := Component as TRzSpacer;
end;


function TRzSpacerEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzSpacerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Grooved';
    1: Result := '-';
    2: Result := 'Horizontal';
    3: Result := 'Vertical';
  end;
end;


procedure TRzSpacerEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );
begin
  inherited;

  case Index of
    0: Item.Checked := Spacer.Grooved;
    2: Item.Checked := Spacer.Orientation = orHorizontal;
    3: Item.Checked := Spacer.Orientation = orVertical;
  end;
end;


procedure TRzSpacerEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: Spacer.Grooved := not Spacer.Grooved;
    2: Spacer.Orientation := orHorizontal;
    3: Spacer.Orientation := orVertical;
  end;
  if Index in [ 0, 2, 3 ] then
    DesignerModified;
end;




{===================================}
{== TRzBalloonHintsEditor Methods ==}
{===================================}

function TRzBalloonHintsEditor.BalloonHints: TRzBalloonHints;
begin
  Result := Component as TRzBalloonHints;
end;


function TRzBalloonHintsEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TRzBalloonHintsEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Balloon Style';
    1: Result := 'Traditional Style';
    2: Result := '-';
    3: Result := 'Corner';
  end;
end;


function TRzBalloonHintsEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    0: Result := 'RZDESIGNEDITORS_BALLOONHINTS';
    1: Result := 'RZDESIGNEDITORS_BALLOONHINTS_NOPOINT';
    3: // Corner
    begin
      case BalloonHints.Corner of
        hcLowerRight: Result := 'RZDESIGNEDITORS_BALLOONHINTS_LOWERRIGHT';
        hcLowerLeft:  Result := 'RZDESIGNEDITORS_BALLOONHINTS_LOWERLEFT';
        hcUpperLeft:  Result := 'RZDESIGNEDITORS_BALLOONHINTS_UPPERLEFT';
        hcUpperRight: Result := 'RZDESIGNEDITORS_BALLOONHINTS_UPPERRIGHT';
      end;
    end;
  end;
end;


procedure TRzBalloonHintsEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateCornerMenu( Corner: TRzHintCorner; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( Corner );
    NewItem.Checked := BalloonHints.Corner = Corner;
    case Corner of
      hcLowerRight: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_BALLOONHINTS_LOWERRIGHT' );
      hcLowerLeft:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_BALLOONHINTS_LOWERLEFT' );
      hcUpperLeft:  NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_BALLOONHINTS_UPPERLEFT' );
      hcUpperRight: NewItem.Bitmap.LoadFromResourceName( HInstance, 'RZDESIGNEDITORS_BALLOONHINTS_UPPERRIGHT' );
    end;
    NewItem.OnClick := CornerMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    0: Item.Checked := BalloonHints.ShowBalloon;
    1: Item.Checked := not BalloonHints.ShowBalloon;

    3:
    begin
      CreateCornerMenu( hcLowerRight, 'Lower-Right' );
      CreateCornerMenu( hcLowerLeft, 'Lower-Left' );
      CreateCornerMenu( hcUpperLeft, 'Upper-Left' );
      CreateCornerMenu( hcUpperRight, 'Upper-Right' );
      CreateCornerMenu( RzBHints.hcNone, 'None' );
    end;
  end;
end;


procedure TRzBalloonHintsEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    0: BalloonHints.ShowBalloon := True;
    1: BalloonHints.ShowBalloon := False;
  end;
  if Index in [ 0, 1 ] then
    DesignerModified;
end;


procedure TRzBalloonHintsEditor.CornerMenuHandler( Sender: TObject );
begin
  BalloonHints.Corner := TRzHintCorner( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{=================================}
{== TRzStringGridEditor Methods ==}
{=================================}

function TRzStringGridEditor.Grid: TRzStringGrid;
begin
  Result := Component as TRzStringGrid;
end;


function TRzStringGridEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;


function TRzStringGridEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := 'XP Colors';
  end;
end;


function TRzStringGridEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


function TRzStringGridEditor.MenuBitmapResourceName( Index: Integer ): string;
begin
  case Index of
    1: Result := 'RZDESIGNEDITORS_XPCOLORS';
  end;
end;


procedure TRzStringGridEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    1: // XP Colors
    begin
      Grid.FixedColor := clInactiveCaptionText;
      Grid.LineColor := clInactiveCaption;
      Grid.FixedLineColor := xpEditFrameColor;
      Grid.FrameColor := xpEditFrameColor;
      Grid.FrameVisible := True;
      DesignerModified;
    end;
  end;
end;


{$IFDEF VCL100_OR_HIGHER}

{================================}
{== TRzFlowPanelEditor Methods ==}
{================================}

function TRzFlowPanelEditor.FlowPanel: TRzFlowPanel;
begin
  Result := Component as TRzFlowPanel;
end;


function TRzFlowPanelEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;


function TRzFlowPanelEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := 'Remove Border';
    2: Result := '-';
    3: Result := 'Auto Wrap';
    4: Result := 'Flow Style';
  end;
end;


function TRzFlowPanelEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


procedure TRzFlowPanelEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateFlowStyleMenu( FlowStyle: TFlowStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( FlowStyle );
    NewItem.Checked := FlowPanel.FlowStyle = FlowStyle;
    NewItem.OnClick := FlowStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    3: Item.Checked := FlowPanel.AutoWrap;

    4:
    begin
      CreateFlowStyleMenu( fsLeftRightTopBottom, 'Left->Right / Top->Bottom' );
      CreateFlowStyleMenu( fsRightLeftTopBottom, 'Right->Left / Top->Bottom' );
      CreateFlowStyleMenu( fsLeftRightBottomTop, 'Left->Right / Bottom->Top' );
      CreateFlowStyleMenu( fsRightLeftBottomTop, 'Right->Left / Bottom->Top' );
      CreateFlowStyleMenu( fsTopBottomLeftRight, 'Top->Bottom / Left->Right' );
      CreateFlowStyleMenu( fsBottomTopLeftRight, 'Bottom->Top / Left->Right' );
      CreateFlowStyleMenu( fsTopBottomRightLeft, 'Top->Bottom / Right->Left' );
      CreateFlowStyleMenu( fsBottomTopRightLeft, 'Bottom->Top / Right->Left' );
    end;
  end;
end;


procedure TRzFlowPanelEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    1:
    begin
      FlowPanel.BorderOuter := fsNone;
      FlowPanel.BorderInner := fsNone;
      FlowPanel.BorderWidth := 0;
    end;

    3: FlowPanel.AutoWrap := not FlowPanel.AutoWrap;
  end;
  if Index in [ 1, 3 ] then
    DesignerModified;
end;


procedure TRzFlowPanelEditor.FlowStyleMenuHandler( Sender: TObject );
begin
  FlowPanel.FlowStyle := TFlowStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;



{================================}
{== TRzGridPanelEditor Methods ==}
{================================}

function TRzGridPanelEditor.GridPanel: TRzGridPanel;
begin
  Result := Component as TRzGridPanel;
end;


function TRzGridPanelEditor.GetVerbCount: Integer;
begin
  Result := 7;
end;


function TRzGridPanelEditor.GetVerb( Index: Integer ): string;
begin
  case Index of
    0: Result := 'Align';
    1: Result := 'Remove Border';
    2: Result := '-';
    3: Result := 'Column Collection...';
    4: Result := 'Row Collection...';
    5: Result := '-';
    6: Result := 'Expand Style';
  end;
end;


function TRzGridPanelEditor.AlignMenuIndex: Integer;
begin
  Result := 0;
end;


procedure TRzGridPanelEditor.PrepareMenuItem( Index: Integer; const Item: TMenuItem );

  procedure CreateExpandStyleMenu( ExpandStyle: TExpandStyle; const Caption: string );
  var
    NewItem: TMenuItem;
  begin
    NewItem := TMenuItem.Create( Item );
    NewItem.Caption := Caption;
    NewItem.Tag := Ord( ExpandStyle );
    NewItem.Checked := GridPanel.ExpandStyle = ExpandStyle;
    NewItem.OnClick := ExpandStyleMenuHandler;
    Item.Add( NewItem );
  end;

begin
  inherited;

  case Index of
    6:
    begin
      CreateExpandStyleMenu( emAddRows, 'Add Rows' );
      CreateExpandStyleMenu( emAddColumns, 'Add Columns' );
      CreateExpandStyleMenu( emFixedSize, 'Fixed Size' );
    end;
  end;
end;


procedure TRzGridPanelEditor.ExecuteVerb( Index: Integer );
begin
  case Index of
    1:
    begin
      GridPanel.BorderOuter := fsNone;
      GridPanel.BorderInner := fsNone;
      GridPanel.BorderWidth := 0;
    end;

    3: EditPropertyByName( 'ColumnCollection' );
    4: EditPropertyByName( 'RowCollection' );
  end;
  if Index in [ 1 ] then
    DesignerModified;
end;


procedure TRzGridPanelEditor.ExpandStyleMenuHandler( Sender: TObject );
begin
  GridPanel.ExpandStyle := TExpandStyle( TMenuItem( Sender ).Tag );
  DesignerModified;
end;


{$ENDIF}



{== Property Editors ==========================================================}

{===================================}
{== TRzFrameStyleProperty Methods ==}
{===================================}

procedure TRzFrameStyleProperty.ListMeasureHeight( const Value: string; ACanvas: TCanvas; var AHeight: Integer );
begin
  AHeight := Max( ACanvas.TextHeight( 'Yy' ), 28 );
end;

procedure TRzFrameStyleProperty.ListMeasureWidth( const Value: string; ACanvas: TCanvas; var AWidth: Integer );
begin
  AWidth := AWidth + 28;
end;


{$IFDEF VCL60_OR_HIGHER}
procedure TRzFrameStyleProperty.PropDrawName( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  DefaultPropertyDrawName( Self, ACanvas, ARect );
end;
{$ENDIF}


procedure TRzFrameStyleProperty.PropDrawValue( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  if GetVisualValue <> '' then
  begin
    FDrawingPropertyValue := True;
    try
      ListDrawValue( GetVisualValue, ACanvas, ARect, ASelected );
    finally
      FDrawingPropertyValue := False;
    end;
  end
  else
    {$IFDEF VCL60_OR_HIGHER}
    DefaultPropertyDrawValue( Self, ACanvas, ARect );
    {$ELSE}
    inherited PropDrawValue( ACanvas, ARect, ASelected );
    {$ENDIF}
end;


procedure TRzFrameStyleProperty.ListDrawValue( const Value: string; ACanvas: TCanvas; const ARect: TRect;
                                               ASelected: Boolean );
var
  R: TRect;
  TextStart: Integer;
  OldBrushColor: TColor;
  FrameStyleEx: TFrameStyleEx;
begin
  R := ARect;
  R.Right := R.Left + ( R.Bottom - R.Top );
  TextStart := R.Right;
  with ACanvas do
  begin
    try
      OldBrushColor := Brush.Color;
      Brush.Color := clBtnFace;
      FillRect( R );

      if FDrawingPropertyValue then
        InflateRect( R, -1, -1 )
      else
        InflateRect( R, -2, -2 );

      FrameStyleEx := TFrameStyleEx( GetEnumValue( GetPropInfo^.PropType^, Value ) );
      if FrameStyleEx <> fsFlatRounded then
        DrawBorder( ACanvas, R, TFrameStyle( FrameStyleEx ) )
      else
        DrawRoundedFlatBorder( ACanvas, R, clBtnShadow, sdAllSides );


      // Restore Canvas Settings
      Brush.Color := OldBrushColor;
    finally
      {$IFDEF VCL60_OR_HIGHER}
      DefaultPropertyListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ELSE}
      inherited ListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ENDIF}
    end;
  end;
end;


{==============================}
{== TRzAlignProperty Methods ==}
{==============================}

procedure TRzAlignProperty.ListMeasureHeight( const Value: string; ACanvas: TCanvas; var AHeight: Integer );
begin
  AHeight := Max( ACanvas.TextHeight( 'Yy' ), 24 );
end;


procedure TRzAlignProperty.ListMeasureWidth( const Value: string; ACanvas: TCanvas; var AWidth: Integer );
begin
  AWidth := AWidth + 24;
end;


{$IFDEF VCL60_OR_HIGHER}
procedure TRzAlignProperty.PropDrawName( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  DefaultPropertyDrawName( Self, ACanvas, ARect );
end;
{$ENDIF}


procedure TRzAlignProperty.PropDrawValue( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  if GetVisualValue <> '' then
  begin
    FDrawingPropertyValue := True;
    try
      ListDrawValue( GetVisualValue, ACanvas, ARect, ASelected );
    finally
      FDrawingPropertyValue := False;
    end;
  end
  else
  begin
    {$IFDEF VCL60_OR_HIGHER}
    DefaultPropertyDrawValue( Self, ACanvas, ARect );
    {$ELSE}
    inherited PropDrawValue( ACanvas, ARect, ASelected );
    {$ENDIF}
  end;
end;


procedure TRzAlignProperty.ListDrawValue( const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
var
  R: TRect;
  TextStart: Integer;
  Align: TAlign;
  Bmp, AlignBmp: TBitmap;
  TransparentColor: TColor;
  DestRct, SrcRct: TRect;
  BmpOffset: Integer;
begin
  R := ARect;
  R.Right := R.Left + ( R.Bottom - R.Top );
  TextStart := R.Right;
  with ACanvas do
  begin
    Bmp := TBitmap.Create;
    AlignBmp := TBitmap.Create;
    try
      FillRect( R );

      Bmp.Canvas.Brush.Color := ACanvas.Brush.Color;
      TransparentColor := clAqua;

      Align := TAlign( GetEnumValue( GetPropInfo^.PropType^, Value ) );

      if FDrawingPropertyValue then
      begin
        DestRct := Classes.Rect( 0, 0, 11, 11 );
        SrcRct := DestRct;
        BmpOffset := ( ( R.Bottom - R.Top ) - 11 ) div 2;

        { Don't Forget to Set the Width and Height of Destination Bitmap }
        Bmp.Width := 11;
        Bmp.Height := 11;

        case Align of
          alNone:    AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_NONE' );
          alTop:     AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_TOP' );
          alBottom:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_BOTTOM' );
          alLeft:    AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_LEFT' );
          alRight:   AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_RIGHT' );
          alClient:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_CLIENT' );
          {$IFDEF VCL60_OR_HIGHER}
          alCustom:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGNPROP_CUSTOM' );
          {$ENDIF}
        end;
      end
      else
      begin
        DestRct := Classes.Rect( 0, 0, 16, 16 );
        SrcRct := DestRct;
        BmpOffset := ( ( R.Bottom - R.Top ) - 16 ) div 2;

        { Don't Forget to Set the Width and Height of Destination Bitmap }
        Bmp.Width := 16;
        Bmp.Height := 16;

        case Align of
          alNone:    AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_NONE' );
          alTop:     AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_TOP' );
          alBottom:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_BOTTOM' );
          alLeft:    AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_LEFT' );
          alRight:   AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_RIGHT' );
          alClient:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN_CLIENT' );
          {$IFDEF VCL60_OR_HIGHER}
          alCustom:  AlignBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_ALIGN' );
          {$ENDIF}
        end;
      end;

      Bmp.Canvas.BrushCopy( DestRct, AlignBmp, SrcRct, TransparentColor );
      Draw( R.Left + 2, R.Top + BmpOffset, Bmp );
    finally
      Bmp.Free;
      AlignBmp.Free;

      {$IFDEF VCL60_OR_HIGHER}
      DefaultPropertyListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ELSE}
      inherited ListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ENDIF}
    end;
  end;
end;


{================================}
{== TRzBooleanProperty Methods ==}
{================================}

procedure TRzBooleanProperty.ListMeasureHeight( const Value: string; ACanvas: TCanvas; var AHeight: Integer );
begin
  AHeight := Max( AHeight, 15 );
end;

procedure TRzBooleanProperty.ListMeasureWidth( const Value: string; ACanvas: TCanvas; var AWidth: Integer );
begin
  AWidth := AWidth + 15;
end;


{$IFDEF VCL60_OR_HIGHER}
procedure TRzBooleanProperty.PropDrawName( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  DefaultPropertyDrawName( Self, ACanvas, ARect );
end;
{$ENDIF}


procedure TRzBooleanProperty.PropDrawValue( ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
begin
  if GetVisualValue <> '' then
    ListDrawValue( GetVisualValue, ACanvas, ARect, ASelected )
  else
  begin
    {$IFDEF VCL60_OR_HIGHER}
    DefaultPropertyDrawValue( Self, ACanvas, ARect );
    {$ELSE}
    inherited PropDrawValue( ACanvas, ARect, ASelected );
    {$ENDIF}
  end;
end;


procedure TRzBooleanProperty.ListDrawValue( const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean );
var
  R: TRect;
  TextStart: Integer;
  BoolValue: Boolean;
  Bmp, CheckBoxBmp: TBitmap;
  TransparentColor: TColor;
  DestRct, SrcRct: TRect;
  BmpOffset: Integer;
begin
  R := ARect;
  R.Right := R.Left + ( R.Bottom - R.Top );
  TextStart := R.Right;
  with ACanvas do
  begin
    Bmp := TBitmap.Create;
    CheckBoxBmp := TBitmap.Create;
    try
      FillRect( R );

      DestRct := Classes.Rect( 0, 0, 11, 11 );
      SrcRct := DestRct;
      BmpOffset := ( ( R.Bottom - R.Top ) - 11 ) div 2;

      { Don't Forget to Set the Width and Height of Destination Bitmap }
      Bmp.Width := 11;
      Bmp.Height := 11;

      Bmp.Canvas.Brush.Color := ACanvas.Brush.Color;

      TransparentColor := clOlive;

      BoolValue := Boolean( GetEnumValue( GetPropInfo^.PropType^, Value ) );
      case BoolValue of
        False:
          CheckBoxBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_BOOLEAN_FALSE' );

        True:
          CheckBoxBmp.Handle := LoadBitmap( HInstance, 'RZDESIGNEDITORS_BOOLEAN_TRUE' );
      end;
      Bmp.Canvas.BrushCopy( DestRct, CheckBoxBmp, SrcRct, TransparentColor );
      Draw( R.Left + 2, R.Top + BmpOffset, Bmp );
    finally
      Bmp.Free;
      CheckBoxBmp.Free;

      {$IFDEF VCL60_OR_HIGHER}
      DefaultPropertyListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ELSE}
      inherited ListDrawValue( Value, ACanvas, Rect( TextStart, ARect.Top, ARect.Right, ARect.Bottom ), ASelected );
      {$ENDIF}
    end;
  end;
end;



{===================================}
{== TRzActivePageProperty Methods ==}
{===================================}

function TRzActivePageProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paValueList ];
end;


procedure TRzActivePageProperty.GetValues( Proc: TGetStrProc );
var
  I: Integer;
  APageControl: TRzPageControl;
begin
  APageControl := TRzPageControl( GetComponent( 0 ) );
  for I := 0 to APageControl.PageCount - 1 do
  begin
    if APageControl.Pages[ I ].Name <> '' then
      Proc( APageControl.Pages[ I ].Name );
  end;
end;



{=======================================}
{== TRzDateTimeFormatProperty Methods ==}
{=======================================}

function TRzDateTimeFormatProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paValueList, paMultiSelect, paAutoUpdate ];
end;


function TRzDateTimeFormatProperty.FormatFilter: TRzDateTimeFormatFilter;
var
  C: TPersistent;
begin
  Result := ffAll;
  C := GetComponent( 0 );
  if C is TRzTimePicker then
    Result := ffTimes
  else if C is TRzDateTimeEdit then
  begin
    if TRzDateTimeEdit( C ).EditType = etTime then
      Result := ffTimes
    else
      Result := ffDates;
  end;
end;


procedure TRzDateTimeFormatProperty.GetValues( Proc: TGetStrProc );
var
  F: TRzDateTimeFormatFilter;
begin
  F := FormatFilter;

  if F = ffAll then
  begin
    Proc( 'c' );
    Proc( 'ddddd t' );
    Proc( 'ddddd tt' );
    Proc( 'dddddd tt' );
  end;

  if ( F = ffDates ) or ( F = ffAll ) then
  begin
    Proc( 'ddddd' );
    Proc( 'dddddd' );
    Proc( 'm/d/yyyy' );
    Proc( 'mm/dd/yyyy' );
    Proc( 'd/m/yyyy');
    Proc( 'dd/mm/yyyy');
  end;

  if ( F = ffTimes ) or ( F = ffAll ) then
  begin
    Proc( 't' );
    Proc( 'tt' );
    Proc( 'h:nn am/pm' );
    Proc( 'hh:nn am/pm' );
    Proc( 'h:nn:ss am/pm');
    Proc( 'hh:nn:ss am/pm' );
    Proc( 'h:nn' );
    Proc( 'hh:nn' );
    Proc( 'h:nn:ss' );
    Proc( 'hh:nn:ss' );
  end;
end;



{==========================================}
{== TRzClockStatusFormatProperty Methods ==}
{==========================================}

function TRzClockStatusFormatProperty.FormatFilter: TRzDateTimeFormatFilter;
begin
  Result := ffAll;
end;




{==================================}
{== TRzDTPFormatProperty Methods ==}
{==================================}

function TRzDTPFormatProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paValueList, paMultiSelect, paAutoUpdate ];
end;


procedure TRzDTPFormatProperty.GetValues( Proc: TGetStrProc );
begin
  Proc( 'M/dd/yyyy' );
  Proc( 'MM/dd/yyyy' );
  Proc( 'MMM dd, yyyy' );
  Proc( 'd/MM/yyyy');
  Proc( 'dd/MM/yyyy' );
  Proc( 'd MMM yyyy');
  Proc( 'h:mm tt' );
  Proc( 'h:mm:ss tt' );
  Proc( 'H:mm' );
  Proc( 'HH:mm:ss' );
end;



{==================================}
{== TRzSpinValueProperty Methods ==}
{==================================}

function TRzSpinValueProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ ];
end;


procedure TRzSpinValueProperty.SetValue( const Value: string );
var
  P: Integer;
  D, SaveDecimals: Byte;
  N: Single;
begin
  SaveDecimals := TRzSpinEdit( GetComponent( 0 ) ).Decimals;
  
  P := Pos( '.', Value );
  if P = 0 then
    D := 0
  else
    D := Length( Value ) - P;

  if D > SaveDecimals then
    TRzSpinEdit( GetComponent( 0 ) ).Decimals := D;
  
  try
    N := StrToFloat( Value );
  except
    on EConvertError do
    begin
      TRzSpinEdit( GetComponent( 0 ) ).Decimals := SaveDecimals;
      raise;
    end;
  end;

  SetFloatValue( N );
end;



{=====================================}
{== TRzSpinnerGlyphProperty Methods ==}
{=====================================}

function TRzSpinnerGlyphProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paReadOnly ];
end;


function TRzSpinnerGlyphProperty.GetValue: string;
begin
  Result := 'Deprecated--Do Not Use.';
end;

{=================================}
{== TRzFileNameProperty Methods ==}
{=================================}

procedure TRzFileNameProperty.Edit;
var
  DlgOpen: TOpenDialog;
begin
  DlgOpen := TOpenDialog.Create( Application );
  DlgOpen.FileName := GetValue;
  DlgOpen.Filter := 'Executables|*.EXE;*.BAT;*.COM;*.PIF|All Files|*.*';
  DlgOpen.Options := DlgOpen.Options + [ofPathMustExist, ofFileMustExist];
  try
    if DlgOpen.Execute then
      SetValue( DlgOpen.FileName );
  finally
    DlgOpen.Free;
  end;
end;


function TRzFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paDialog, paRevertable ];
end;


{===============================}
{== TRzActionProperty Methods ==}
{===============================}

function TRzActionProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paValueList, paMultiSelect ];
end;


procedure TRzActionProperty.GetValues( Proc: TGetStrProc );
begin
  Proc( 'Open' );
  Proc( 'Print' );
  Proc( 'Explore' );
end;



{=====================================}
{== TRzCustomColorsProperty Methods ==}
{=====================================}

procedure TRzCustomColorsProperty.Edit;
var
  DlgColor: TColorDialog;
begin
  DlgColor := TColorDialog.Create( Application );
  try
    DlgColor.CustomColors := TStrings( GetOrdValue );
    DlgColor.Options := [ cdFullOpen ];
    if DlgColor.Execute then
      SetOrdValue( Longint( DlgColor.CustomColors ) );
  finally
    DlgColor.Free;
  end;
end;


function TRzCustomColorsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paDialog ];
end;



{== Category Classes ==========================================================}


{$IFDEF VER13x}

{======================================}
{== TRzCustomFramingCategory Methods ==}
{======================================}

class function TRzCustomFramingCategory.Name: string;
begin
  Result := 'Custom Framing';
end;

class function TRzCustomFramingCategory.Description: string;
begin
  Result := 'Custom Framing Category';
end;


{================================}
{== TRzHotSpotCategory Methods ==}
{================================}

class function TRzHotSpotCategory.Name: string;
begin
  Result := 'HotSpot';
end;

class function TRzHotSpotCategory.Description: string;
begin
  Result := 'HotSpot Category';
end;


{====================================}
{== TRzBorderStyleCategory Methods ==}
{====================================}

class function TRzBorderStyleCategory.Name: string;
begin
  Result := 'Border Style';
end;

class function TRzBorderStyleCategory.Description: string;
begin
  Result := 'Border Style Category';
end;


{=====================================}
{== TRzCustomGlyphsCategory Methods ==}
{=====================================}

class function TRzCustomGlyphsCategory.Name: string;
begin
  Result := 'Custom Glyphs';
end;

class function TRzCustomGlyphsCategory.Description: string;
begin
  Result := 'Custom Glyphs Category';
end;


{==================================}
{== TRzTextStyleCategory Methods ==}
{==================================}

class function TRzTextStyleCategory.Name: string;
begin
  Result := 'Text Style';
end;

class function TRzTextStyleCategory.Description: string;
begin
  Result := 'Text Style Category';
end;


{===================================}
{== TRzTrackStyleCategory Methods ==}
{===================================}

class function TRzTrackStyleCategory.Name: string;
begin
  Result := 'Track Style';
end;

class function TRzTrackStyleCategory.Description: string;
begin
  Result := 'Track Style Category';
end;


{======================================}
{== TRzPrimaryButtonCategory Methods ==}
{======================================}

class function TRzPrimaryButtonCategory.Name: string;
begin
  Result := 'Button - Primary';
end;

class function TRzPrimaryButtonCategory.Description: string;
begin
  Result := 'Primary Button Category';
end;


{========================================}
{== TRzAlternateButtonCategory Methods ==}
{========================================}

class function TRzAlternateButtonCategory.Name: string;
begin
  Result := 'Button - Alternate';
end;

class function TRzAlternateButtonCategory.Description: string;
begin
  Result := 'Alternate Button Category';
end;


{=================================}
{== TRzSplitterCategory Methods ==}
{=================================}

class function TRzSplitterCategory.Name: string;
begin
  Result := 'Splitter Style';
end;

class function TRzSplitterCategory.Description: string;
begin
  Result := 'Splitter Style Category';
end;

{$ENDIF}


{===========================}
{== TRzPaletteSep Methods ==}
{===========================}

constructor TRzPaletteSep.Create( AOwner: TComponent );
begin
  raise Exception.Create( 'Palette Separator - Only for use on Component Palette' );
end;


{$IFDEF VCL100_OR_HIGHER}

{== Designer Guidelines =======================================================}


type
  TRzOpenCustomButton = class( TRzCustomButton )
  end;

  TRzOpenButton = class( TRzButton )
  end;


{=======================================}
{== TRzCustomButtonGuidelines Methods ==}
{=======================================}

function TRzCustomButtonGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzCustomButtonGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  Button: TRzCustomButton;
  TextLayout: TTextLayout;
begin
  if Index >= inherited GetCount then
  begin
    Button := Component as TRzCustomButton;
    TextLayout := TTextLayout( Ord( TRzOpenCustomButton( Button ).AlignmentVertical ) );
    Result := GetTextBaseline( Button, TextLayout );
    case TextLayout of
      tlTop:    Inc( Result );
      tlBottom: Dec( Result, 2 );
    end;
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzCustomButtonGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;


{=================================}
{== TRzButtonGuidelines Methods ==}
{=================================}

function TRzButtonGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzButtonGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  Button: TRzButton;
  TextLayout: TTextLayout;
  R: TRect;
begin
  if Index >= inherited GetCount then
  begin
    Button := Component as TRzButton;
    TextLayout := TTextLayout( Ord( TRzOpenButton( Button ).AlignmentVertical ) );
    Result := GetTextBaseline( Button, TextLayout );
    R := TRzOpenButton( Button ).GetCaptionRect;
    case TextLayout of
      tlTop:    Result := Result + R.Top;
      tlBottom: Result := Result -
                          ( ( Button.Height - ( R.Bottom - R.Top ) ) div 2 ) - 1;
    end;
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzButtonGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;



{=====================================}
{== TRzToolButtonGuidelines Methods ==}
{=====================================}

function TRzToolButtonGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzToolButtonGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  ToolButton: TRzToolButton;
begin
  if Index >= inherited GetCount then
  begin
    ToolButton := Component as TRzToolButton;
    Result := GetTextBaseline( ToolButton, tlCenter );
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzToolButtonGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;


{==================================}
{== TRzCaptionGuidelines Methods ==}
{==================================}

function TRzCaptionGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzCaptionGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
begin
  if Index >= inherited GetCount then
  begin
    Result := GetTextBaseline( Component as TControl, tlCenter );
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzCaptionGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;


{================================}
{== TRzLabelGuidelines Methods ==}
{================================}

type
  TRzOpenLabel = class( TRzLabel )
  end;


function TRzLabelGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzLabelGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  lbl: TRzLabel;
  R: TRect;
begin
  if Index >= inherited GetCount then
  begin
    lbl := Component as TRzLabel;
    Result := GetTextBaseline( lbl, lbl.Layout );

    R := lbl.ClientRect;
    TRzOpenLabel( lbl ).FixClientRect( R, True );

    case lbl.Layout of
      tlTop:    Result := Result + R.Top;
      tlBottom: Result := R.Bottom - 1;
    end;
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzLabelGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;


{================================}
{== TRzPanelGuidelines Methods ==}
{================================}

type
  TRzOpenPanel = class( TRzPanel )
  end;


function TRzPanelGuidelines.GetCount: Integer;
begin
  Result := inherited GetCount + 1;
end;


function TRzPanelGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  Pnl: TRzPanel;
  R: TRect;
  TextLayout: TTextLayout;
begin
  if Index >= inherited GetCount then
  begin
    Pnl := Component as TRzPanel;
    TextLayout := TTextLayout( Ord( Pnl.AlignmentVertical ) );
    Result := GetTextBaseline( Pnl, TextLayout );

    R := Pnl.ClientRect;
    TRzOpenPanel( Pnl ).FixClientRect( R, True );

    case TextLayout of
      tlTop:    Result := Result + R.Top;
      tlBottom: Result := R.Bottom - 2;
    end;
  end
  else
  begin
    Result := inherited GetDesignerGuideOffset( Index )
  end;
end;


function TRzPanelGuidelines.GetDesignerGuideType( Index: Integer ): TDesignerGuideType;
begin
  if Index >= inherited GetCount then
    Result := gtBaseline
  else
    Result := inherited GetDesignerGuideType( Index );
end;



{======================================}
{== TRzPageControlGuidelines Methods ==}
{======================================}

function TRzPageControlGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  PC: TRzPageControl;
begin
  Result := inherited GetDesignerGuideOffset( Index );

  case Index of
    2, 3:
    begin
      PC := Component as TRzPageControl;
      if PC.ShowShadow then
        Result := Result - 2;
    end;
  end;
end;


{=====================================}
{== TRzTabControlGuidelines Methods ==}
{=====================================}

function TRzTabControlGuidelines.GetDesignerGuideOffset( Index: Integer ): Integer;
var
  TC: TRzTabControl;
begin
  Result := inherited GetDesignerGuideOffset( Index );

  case Index of
    2, 3:
    begin
      TC := Component as TRzTabControl;
      if TC.ShowShadow then
        Result := Result - 2;
    end;
  end;
end;


{$ENDIF}

end.
