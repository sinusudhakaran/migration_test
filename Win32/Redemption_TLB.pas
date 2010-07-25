unit Redemption_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 8291 $
// File generated on 19/10/2007 5:13:30 p.m. from Type Library described below.

// ************************************************************************  //
// Type Lib: \\banklink-fp\Develpmt\Matthew\CODE\bk5\BK5NZ\bkExtMapi.dll (1)
// LIBID: {2D5E2D34-BED5-4B9F-9793-A31E26E6806E}
// LCID: 0
// Helpfile: 
// HelpString: Redemption Outlook Library. Version 4.4
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// Errors:
//   Hint: Member 'Class' of 'IAttachment' changed to 'Class_'
//   Hint: Parameter 'Class' of IAttachment.Class changed to 'Class_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IAttachment.Type changed to 'Type_'
//   Hint: Member 'Class' of 'IAttachments' changed to 'Class_'
//   Hint: Parameter 'Class' of IAttachments.Class changed to 'Class_'
//   Hint: Parameter 'Type' of IAttachments.Add changed to 'Type_'
//   Hint: Member 'Class' of 'IAddressEntry' changed to 'Class_'
//   Hint: Parameter 'Class' of IAddressEntry.Class changed to 'Class_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IAddressEntry.Type changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IAddressEntry.Type changed to 'Type_'
//   Hint: Member 'Class' of 'IAddressEntries' changed to 'Class_'
//   Hint: Parameter 'Class' of IAddressEntries.Class changed to 'Class_'
//   Hint: Parameter 'Type' of IAddressEntries.Add changed to 'Type_'
//   Hint: Parameter 'Property' of IAddressEntries.Sort changed to 'Property_'
//   Hint: Member 'Class' of 'ISafeRecipient' changed to 'Class_'
//   Hint: Parameter 'Class' of ISafeRecipient.Class changed to 'Class_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of ISafeRecipient.Type changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of ISafeRecipient.Type changed to 'Type_'
//   Hint: Member 'Class' of 'ISafeRecipients' changed to 'Class_'
//   Hint: Parameter 'Type' of ISafeRecipients.AddEx changed to 'Type_'
//   Hint: Parameter 'Type' of _ISafeItem.Import changed to 'Type_'
//   Hint: Parameter 'Type' of _ISafeItem.SaveAs changed to 'Type_'
//   Hint: Member 'To' of 'ISafeMailItem' changed to 'To_'
//   Hint: Parameter 'To' of ISafeMailItem.To changed to 'To_'
//   Hint: Member 'Class' of 'ISafeItems' changed to 'Class_'
//   Hint: Parameter 'Type' of ISafeItems.Add changed to 'Type_'
//   Hint: Member 'Class' of 'IMessageItem' changed to 'Class_'
//   Hint: Member 'To' of 'IMessageItem' changed to 'To_'
//   Hint: Parameter 'Type' of IMessageItem.SaveAs changed to 'Type_'
//   Hint: Parameter 'Type' of IMessageItem.Import changed to 'Type_'
//   Hint: Member 'GoTo' of '_IMAPITable' changed to 'GoTo_'
//   Hint: Parameter 'Property' of _IMAPITable.Sort changed to 'Property_'
//   Hint: Member 'Protected' of 'ITextAttributes' changed to 'Protected_'
//   Hint: Member 'Protected' of 'IConsistentAttributes' changed to 'Protected_'
//   Hint: Member 'To' of 'IRDOMail' changed to 'To_'
//   Hint: Parameter 'Type' of IRDOMail.Import changed to 'Type_'
//   Hint: Parameter 'Type' of IRDOMail.SaveAs changed to 'Type_'
//   Hint: Parameter 'Type' of IRDOItems.Add changed to 'Type_'
//   Hint: Parameter 'Property' of IRDOItems.Sort changed to 'Property_'
//   Hint: Parameter 'Type' of IRDOFolders.Add changed to 'Type_'
//   Hint: Parameter 'Type' of IRDOFolders.AddSearchFolder changed to 'Type_'
//   Hint: Parameter 'Type' of IRDOAttachments.Add changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IRDORecipients.AddEx changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IRDORecipient.Type changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IRDORecipient.Type changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IRDOAddressEntry.Type changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IRDOAddressEntry.Type changed to 'Type_'
//   Hint: Enum Member 'olRFC822' of 'rdoSaveAsType' changed to 'olRFC822_'
//   Hint: Enum Member 'olTNEF' of 'rdoSaveAsType' changed to 'olTNEF_'
//   Hint: Symbol 'Assign' renamed to 'Assign_'
//   Hint: Parameter 'Type' of IImportExport.SaveAs changed to 'Type_'
//   Hint: Parameter 'Type' of IImportExport.Import changed to 'Type_'
//   Hint: Parameter 'Type' of IRDOFolderFields.Add changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Member 'End' of 'IRDOAppointmentItem' changed to 'End_'
//   Hint: Member 'End' of 'IRDOJournalItem' changed to 'End_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Member 'End' of 'IRDOFreeBusyRange' changed to 'End_'
//   Hint: Member 'End' of 'IRDOFreeBusySlot' changed to 'End_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  RedemptionMajorVersion = 4;
  RedemptionMinorVersion = 4;

  LIBID_Redemption: TGUID = '{2D5E2D34-BED5-4B9F-9793-A31E26E6806E}';

  IID_IAttachment: TGUID = '{47146231-B550-4B13-B9E7-4257F740F39D}';
  IID_IAttachments: TGUID = '{82B58FCB-73F3-46DC-A52D-74D3FE359702}';
  IID_IAddressEntry: TGUID = '{78412EB9-E06B-4484-BC85-0B1594F6E23A}';
  IID_IAddressEntries: TGUID = '{C1DFD382-E253-434D-B22D-2E47233B6147}';
  IID_ISafeRecipient: TGUID = '{5C61669E-F0CE-4126-B365-316588E6228F}';
  CLASS_SafeRecipient: TGUID = '{D79392C4-324D-47CF-8400-C6B654283119}';
  IID_ISafeRecipients: TGUID = '{CACB61E0-AEEA-404D-88E1-7F3BCA8B8726}';
  CLASS_SafeRecipients: TGUID = '{094E97DD-AD9E-48E5-A01B-2B05B150CD64}';
  IID__IBaseItem: TGUID = '{F71D2854-2609-4A63-B4BF-BF2BA61A61CF}';
  CLASS__BaseItem: TGUID = '{81BDE41B-2202-4695-9B39-5ADC50ACF195}';
  IID__ISafeItem: TGUID = '{DBCAD616-BFD4-4C72-8D87-C5926921D378}';
  CLASS__SafeItem: TGUID = '{48E02FAA-1994-4FE1-AEB8-CE4BBB6AF8EC}';
  IID_ISafeContactItem: TGUID = '{3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}';
  CLASS_SafeContactItem: TGUID = '{4FD5C4D3-6C15-4EA0-9EB9-EEE8FC74A91B}';
  IID_ISafeAppointmentItem: TGUID = '{35EFAD55-134A-47BF-912A-44A9D9FD556F}';
  CLASS_SafeAppointmentItem: TGUID = '{620D55B0-F2FB-464E-A278-B4308DB1DB2B}';
  IID_ISafeMailItem: TGUID = '{0A95BE2D-1543-46BE-AD6D-18653034BF87}';
  CLASS_SafeMailItem: TGUID = '{741BEEFD-AEC0-4AFF-84AF-4F61D15F5526}';
  IID_ISafeTaskItem: TGUID = '{F961CE9D-AE2B-4CFB-887C-3A055FF685C9}';
  CLASS_SafeTaskItem: TGUID = '{7A41359E-0407-470F-B3F7-7C6A0F7C449A}';
  IID_ISafeJournalItem: TGUID = '{E3EC74BB-5522-462D-A00F-2728C53FCA04}';
  CLASS_SafeJournalItem: TGUID = '{C5AA36A1-8BD1-47E0-90F8-47E7239C6EA1}';
  IID_ISafeMeetingItem: TGUID = '{F7919641-3978-4668-8388-7310329C800E}';
  CLASS_SafeMeetingItem: TGUID = '{FA2CBAFB-F7B1-4F41-9B7A-73329A6C1CB7}';
  IID_ISafePostItem: TGUID = '{6A5D680A-8F9F-4752-A056-2C0273F60B4E}';
  CLASS_SafePostItem: TGUID = '{11E2BC0C-5D4F-4E0C-B438-501FFE05A382}';
  IID_IMAPIUtils: TGUID = '{D45B0772-5801-4E61-9CBA-84120557A4D7}';
  DIID_IMAPIUtilsEvents: TGUID = '{359A062F-CDA8-4A9C-9B28-588446D35098}';
  CLASS_MAPIUtils: TGUID = '{4A5E947E-C407-4DCC-A0B5-5658E457153B}';
  CLASS_AddressEntry: TGUID = '{65CFBFC8-2A9A-4FA6-8AAC-9E71ED326C4E}';
  CLASS_AddressEntries: TGUID = '{47127D67-4DDD-4563-A3C3-AD16D0ADF17A}';
  CLASS_Attachment: TGUID = '{0A6881C9-176C-4029-A97F-6CFAAA81D18C}';
  CLASS_Attachments: TGUID = '{3A21A2BF-2A1C-4F83-9F59-26EC1D0C5511}';
  IID_ISafeMAPIFolder: TGUID = '{31CE2164-4D5C-4508-BCA7-B10E11D08E6B}';
  CLASS_MAPIFolder: TGUID = '{03C4C5F4-1893-444C-B8D8-002F0034DA92}';
  IID_ISafeCurrentUser: TGUID = '{D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}';
  CLASS_SafeCurrentUser: TGUID = '{7ED1E9B1-CB57-4FA0-84E8-FAE653FE8E6B}';
  IID_ISafeTable: TGUID = '{CD5B9523-6EAF-4D63-8FE8-C081C51D1673}';
  CLASS_SafeTable: TGUID = '{CA6E7A81-E98D-4DFE-8911-6CE3A3EE4C8A}';
  IID_ISafeDistList: TGUID = '{EBB4EBA9-D546-4C85-A05A-167BF875FB83}';
  CLASS_SafeDistList: TGUID = '{7C4A630A-DE98-4E3E-8093-E8F5E159BB72}';
  IID_IAddressLists: TGUID = '{86797248-1A4E-41D0-A0C3-2175A36B3D0E}';
  CLASS_AddressLists: TGUID = '{37587889-FC28-4507-B6D3-8557305F7511}';
  IID_IAddressList: TGUID = '{38F95B22-32BF-4378-B3EC-47B2C09DE1F5}';
  CLASS_AddressList: TGUID = '{05399290-4D82-4023-9F99-EA711220896C}';
  IID_ISafeItems: TGUID = '{D80AC53D-E102-4A55-A265-529A626515E5}';
  CLASS_SafeItems: TGUID = '{6FF57EB8-7E65-43E8-B3AD-7DB82AE60897}';
  IID_IMessageItem: TGUID = '{C18D120C-B7AB-4499-8BDC-0CD2BD0861FD}';
  CLASS_MessageItem: TGUID = '{B33FAB24-AC87-4EB7-8B4A-46451B23ED6E}';
  IID__IMAPITable: TGUID = '{6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}';
  CLASS_MAPITable: TGUID = '{A6931B16-90FA-4D69-A49F-3ABFA2C04060}';
  IID_IDeletedItems: TGUID = '{FFBBDECE-4363-4B4D-B35E-39EFF228C723}';
  CLASS_DeletedItems: TGUID = '{9F705F1E-00BD-46AD-AB0F-2BA438E0FE91}';
  IID__IRestriction: TGUID = '{45128C11-A7E5-46D2-A164-3D1273E92C44}';
  IID__IRestrictionCollection: TGUID = '{919DF860-D321-4D02-AC3D-1C25EFAE551A}';
  IID_IRestrictionAnd: TGUID = '{60E5F55E-236F-422D-A5F9-560F1778CCD4}';
  CLASS_RestrictionAnd: TGUID = '{C9D96090-F015-4E70-8DE6-66D35F6A7BDA}';
  IID_IRestrictionBitmask: TGUID = '{C52D8C84-C5DD-457B-993B-04E997B330E5}';
  CLASS_RestrictionBitmask: TGUID = '{90DBEDC1-248D-4D4A-9FF8-0554EA5AFD56}';
  IID_IRestrictionCompareProps: TGUID = '{2D91877A-468C-4802-8CD7-21F6BF776790}';
  CLASS_RestrictionCompareProps: TGUID = '{DC08CE98-06E3-4001-A3F8-EB915350E14E}';
  IID_IRestrictionContent: TGUID = '{AA6CCB5D-0F97-4A37-A077-8B49FB5BC60D}';
  CLASS_RestrictionContent: TGUID = '{C211FBE1-47F7-412B-8042-810B6F24209F}';
  IID_IRestrictionExist: TGUID = '{6CDD1F89-FC3B-401C-B1F1-932C48F45EB5}';
  CLASS_RestrictionExist: TGUID = '{49C430D2-C04A-451E-B273-6589C538F234}';
  IID_IRestrictionNot: TGUID = '{2B539D9C-127A-4F10-855F-EF31C83D2007}';
  CLASS_RestrictionNot: TGUID = '{3C1DB2AB-87E0-437E-9FE9-577CD03CB43D}';
  IID_IRestrictionOr: TGUID = '{278EAD7A-2A45-4D4E-ACB4-A1A4AD9BB54B}';
  CLASS_RestrictionOr: TGUID = '{BC38DDD9-2E98-4A70-B4CE-A5D053B6703B}';
  IID_IRestrictionProperty: TGUID = '{3D177BA8-BF8C-45E2-8CA2-20ACA6269A68}';
  CLASS_RestrictionProperty: TGUID = '{EA494FFC-D2CA-4150-B2E7-E51918245357}';
  IID_IRestrictionSize: TGUID = '{E16F1874-C5B1-4400-A9F0-08E7FD4D3F8C}';
  CLASS_RestrictionSize: TGUID = '{25E46A34-9630-4137-81C3-5C482EB212DF}';
  IID_IRestrictionSub: TGUID = '{62B6A513-3764-42CD-8410-9B81E8DFF135}';
  CLASS_RestrictionSub: TGUID = '{6EE92F5C-8FC2-48F5-A3C8-4AE56CE8515F}';
  IID_ITableFilter: TGUID = '{0B8EDB8D-4575-4942-9C34-55591E415909}';
  CLASS_TableFilter: TGUID = '{73897A34-F150-46F3-8600-F65EDA105ECF}';
  CLASS__Restriction: TGUID = '{834CFAC3-D0D8-4D72-954A-935B47F54544}';
  CLASS__RestrictionCollection: TGUID = '{0E9A0E43-9703-408B-AF08-FC5CD5661293}';
  IID_INamedProperty: TGUID = '{3E1392BB-3B66-4A39-BBD0-259FC2BDC979}';
  CLASS_NamedProperty: TGUID = '{6B7162DF-7EEF-4DA2-AA69-74B35A52CB75}';
  IID_IPropList: TGUID = '{7EE495F3-345B-4CC1-AAB7-A255ED85EED2}';
  CLASS_PropList: TGUID = '{9717E1EF-2DBE-4B87-94CA-DFC6CFFA510F}';
  IID_ISafeReportItem: TGUID = '{03C3860D-86B7-4F36-924C-3B1AD93B4C79}';
  CLASS_SafeReportItem: TGUID = '{D46BA7B2-899F-4F60-85C7-4DF5713F6F18}';
  IID_ISafeInspector: TGUID = '{6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}';
  CLASS_SafeInspector: TGUID = '{ED323630-B4FD-4628-BC6A-D4CC44AE3F00}';
  IID_IPlainTextEditor: TGUID = '{52EB94F3-545B-4EF0-BEE7-50537E704EFB}';
  CLASS_PlainTextEditor: TGUID = '{E07CB99C-BDBD-4DE3-9A22-3A742C3119BD}';
  IID_IRTFEditor: TGUID = '{E206FB9D-3F15-4130-A977-3FCAD9CE1188}';
  CLASS_RTFEditor: TGUID = '{DD04CEFA-0BF8-456C-8621-6E3D7A12591A}';
  IID_ITextAttributes: TGUID = '{4D0A6803-18D2-4EAC-BA33-137F10AC8710}';
  CLASS_TextAttributes: TGUID = '{A7032819-F323-4539-B13A-26E32168E4F2}';
  IID_IFontStyle: TGUID = '{7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}';
  CLASS_FontStyle: TGUID = '{4BB0E9CA-4218-43F0-AB4B-92BA7589958E}';
  IID_IConsistentAttributes: TGUID = '{CDA81541-363F-4CBF-97FB-FD138F4D102D}';
  CLASS_ConsistentAttributes: TGUID = '{1CEFB688-FD1E-4956-87C5-88A3F7518F27}';
  IID_IParagraphAttributes: TGUID = '{13FFAB29-AE8F-473C-9F21-5ED4664BE98F}';
  CLASS_ParagraphAttributes: TGUID = '{05E2DCFB-2F74-43AE-B59B-1713AAA4E7BB}';
  IID_IRDOSession: TGUID = '{E54C5168-AA8C-405F-9C14-A4037302BD9D}';
  DIID_IRDOSessionEvents: TGUID = '{BFFCC45C-D97E-48A1-9548-6796FA0334EC}';
  IID_iRDOStores: TGUID = '{8AE3D19C-C58A-4AF0-94D3-9255F3417E33}';
  DIID_IRDOStoresEvents: TGUID = '{002DACC3-FE8F-44CE-A877-24BA0CEB9057}';
  IID__MAPIProp: TGUID = '{CF7DE094-FF99-4700-B9EF-258A1D23B798}';
  IID_IRDOFolder: TGUID = '{15B8597F-0A55-4361-AE8B-1F690BC61EE4}';
  IID_IRDOAddressBook: TGUID = '{3F5393D1-F833-4224-822E-68B3674F30C1}';
  CLASS_RDOAddressBook: TGUID = '{A7CE6B87-B4DD-4735-ACDC-A7895D578760}';
  DIID_IRDOFolderEvents: TGUID = '{D27B50F3-C404-423D-96E6-4EADFBB83571}';
  IID_IRDOStore: TGUID = '{1EDC0526-2A75-4DBC-B532-B3402B699B1B}';
  IID_IRDOPstStore: TGUID = '{B78DFF17-ABA1-4DC6-8FBD-F9C17E82033F}';
  DIID_IRDOStoreEvents: TGUID = '{4304377A-587C-4CB0-A951-03491A74467D}';
  IID_IRDOExchangeStore: TGUID = '{D5C6EDF7-8FDB-4CB4-8063-4C497581C92E}';
  IID_IRDOExchangeMailboxStore: TGUID = '{0AE11A9E-C488-4FD8-9BF9-CA1702266607}';
  CLASS_RDOExchangeMailboxStore: TGUID = '{66423950-304C-4BD0-B436-6D8C49D1FD47}';
  CLASS_RDOExchangeStore: TGUID = '{D700275D-EF52-478B-8E88-E6096D8766DE}';
  CLASS_RDOPstStore: TGUID = '{1610B46D-DE35-4F66-9CDA-B2C50D64F10E}';
  IID_IRDOMail: TGUID = '{D85047E0-7767-4D48-86B6-28BDB5728ABB}';
  DIID_IRDOMailEvents: TGUID = '{0D00E38E-315D-49D5-9331-80BC1559C0E7}';
  IID_IRDOExchangePublicFoldersStore: TGUID = '{C4E7A620-38A0-4EB3-9F1E-0317BF6BC665}';
  CLASS_RDOExchangePublicFoldersStore: TGUID = '{075A5334-BB7E-4352-AEC0-78403B8DFD0E}';
  IID_IRDOItems: TGUID = '{F8408EB8-6B65-4704-810C-29795E67C0DD}';
  DIID_IRDOItemsEvents: TGUID = '{0E5B5CD0-7C63-4E3F-B806-5372C68243CA}';
  IID_IRDOFolders: TGUID = '{E7707B13-1256-4BB0-A1AB-A59F1B6EEF9C}';
  DIID_IRDOFoldersEvents: TGUID = '{45157DD1-CEF5-4EFC-99F8-7970934CC55D}';
  IID_IRDOAttachments: TGUID = '{9ED8DA28-908D-4DA3-B7AC-8DF8587A9DD0}';
  CLASS_RDOAttachments: TGUID = '{259B58EA-BD3B-4306-9F30-51F6750ACB1A}';
  IID_IRDOAttachment: TGUID = '{5C3D4791-B887-490E-8253-CCC0BC7E15C9}';
  CLASS_RDOAttachment: TGUID = '{E0FC7366-49E3-4A2E-A5DE-5650352FF707}';
  IID_IRDORecipients: TGUID = '{F17B2E04-2E64-4A50-86A3-BEC908D58097}';
  CLASS_RDORecipients: TGUID = '{B32BED47-05E6-402A-9B58-01CA29EA8A83}';
  IID_IRDORecipient: TGUID = '{6E4D07F9-3E3F-4469-9181-6E09593A03D2}';
  CLASS_RDORecipient: TGUID = '{85DF5E8D-E157-49B0-ABCE-8783903BF44F}';
  IID_IRDOAddressEntry: TGUID = '{4819D689-AFDF-4A6D-8CD5-6B0D484FE9D1}';
  CLASS_RDOAddressEntry: TGUID = '{3E9F4A2A-155A-4D47-96C4-79DE84A8BEE9}';
  IID_IRDOAddressEntries: TGUID = '{31AEB3B1-8CB7-490F-A0DC-AB76F0C56483}';
  CLASS_RDOAddressEntries: TGUID = '{4F930441-C7B0-42BF-801A-7BFB122065CC}';
  IID_IRDOAddressList: TGUID = '{EB3836E5-3937-4E85-9FF9-93F7E659052C}';
  CLASS_RDOAddressList: TGUID = '{6746EBD0-DDD2-42B4-BE2C-5826D089FCA5}';
  IID_IRDOAddressLists: TGUID = '{C8E7C686-F6C5-4023-82F6-F53C9EFAC528}';
  CLASS_RDOAddressLists: TGUID = '{5F6C2D55-E32B-4FF7-B176-3F6F0F276C70}';
  IID_IRDOAddressBookSearchPath: TGUID = '{EBCB6987-CB48-4083-87DA-D5EDA11FA2C3}';
  CLASS_RDOAddressBookSearchPath: TGUID = '{E87FAC31-A258-475D-80E4-357B4B37FD30}';
  IID_IRDODeletedItems: TGUID = '{E22045A6-092A-4CCC-860D-0C93CD6AB778}';
  CLASS_RDODeletedItems: TGUID = '{AFEA08D7-DA26-4046-839F-CE6D11C16144}';
  IID_IRDOSearchFolder: TGUID = '{3E8341D4-E4A2-4071-B9AD-E2D793136647}';
  CLASS_RDOSearchFolder: TGUID = '{F8DF12F3-F50E-4D78-BCF7-9B298CBCE05B}';
  IID_IRDOFolderSearchCriteria: TGUID = '{E521CAC7-3A02-4BF4-91BD-4B409C3B8655}';
  CLASS_RDOFolderSearchCriteria: TGUID = '{A16E63FB-A057-4056-9103-4E40F02BA9A2}';
  IID_IRDOSearchContainersList: TGUID = '{BB039345-30DF-4E1A-ADC5-7542CB083924}';
  CLASS_RDOSearchContainersList: TGUID = '{3FC58952-26A9-44F5-B74B-6DAD03EDF7C3}';
  IID_IRDOACL: TGUID = '{8EA8008E-2C1D-4BE2-97D5-ABB9CEAB7CB3}';
  CLASS_RDOACL: TGUID = '{3FCF1B2C-4061-4A2C-BE84-F88D00AF5C8D}';
  IID_IRDOACE: TGUID = '{90A06D07-4034-40FA-B259-04A0214352DB}';
  CLASS_RDOACE: TGUID = '{E75416E6-3E8E-4A3A-86B2-DB9EA0100D53}';
  IID_IRDOOutOfOfficeAssistant: TGUID = '{94D01B27-C94A-4C66-92EF-7C2339AB4585}';
  CLASS_RDOOutOfOfficeAssistant: TGUID = '{7EDECD67-AF6F-4F90-A957-E951CADBE5C1}';
  IID_IRDOReminders: TGUID = '{BE5243B8-827F-4391-BCDF-443C6898617D}';
  CLASS_RDOReminders: TGUID = '{5A17B9EB-ADA3-4DEE-954D-208B547AEAE1}';
  IID_IRDOReminder: TGUID = '{C2A1BF29-7F9E-406C-BA70-83B433366213}';
  CLASS_RDOReminder: TGUID = '{F9BE3B14-ECB2-4C36-A19C-298D2E4330C8}';
  IID_IRDOAccounts: TGUID = '{FF711B41-292B-4DE7-9F0E-96467A4E0D35}';
  DIID_IRDOAccountsEvents: TGUID = '{6B8E3F2F-8AAE-4482-8492-4BBBF71000CE}';
  IID_IRDOAccount: TGUID = '{396D96A3-D780-48B2-9556-866E1F1604D6}';
  CLASS_RDOAccount: TGUID = '{355967D8-07A0-4CC6-8D27-D1EB12011726}';
  IID_IRDOPOP3Account: TGUID = '{EA7B67A0-E213-49BD-9369-3E9970245286}';
  IID_IRDOMAPIAccount: TGUID = '{26BA706B-B151-4E19-BEC2-77E382739ECC}';
  CLASS_RDOPOP3Account: TGUID = '{C9DEB266-5B97-4381-8934-CE1E743CEDF7}';
  CLASS_RDOMAPIAccount: TGUID = '{0246DC57-6D13-4C12-99F1-F3AC082226AE}';
  IID_IRDOIMAPAccount: TGUID = '{9059EE9C-E410-4F05-9DE8-3C955BC281D5}';
  CLASS_RDOIMAPAccount: TGUID = '{47A3FE8A-277E-447F-8330-0B3B485A904E}';
  IID_IRDOHTTPAccount: TGUID = '{3A967384-6CAB-4A29-9F9F-E47C2626880A}';
  CLASS_RDOHTTPAccount: TGUID = '{819F2602-9ABC-45B3-A377-ADDA0E8C6C54}';
  IID_IRDOLDAPAccount: TGUID = '{D4714885-2180-45F1-8C65-D97C20C184AB}';
  CLASS_RDOLDAPAccount: TGUID = '{AF61D502-C0AB-4650-818D-4AFAC98AC8F8}';
  IID_IRDOAccountOrderList: TGUID = '{2486178B-171F-4BDF-A880-1359E642AC3F}';
  CLASS_RDOAccountOrderList: TGUID = '{1864A529-02E8-4B95-B5DD-51F750097EB1}';
  CLASS_RDOSession: TGUID = '{29AB7A12-B531-450E-8F7A-EA94C2F3C05F}';
  CLASS_RDOStore: TGUID = '{5AE15ACD-5870-40AD-AA45-BD989EAB4A30}';
  CLASS_RDOFolder: TGUID = '{B50F4209-31A5-4A96-98E6-6234898D41B7}';
  CLASS_RDOMail: TGUID = '{02ABB20A-FB8A-4433-8D66-135C6CCD0F32}';
  CLASS_RDOItems: TGUID = '{B07F6617-FEC1-47B9-87AC-264CAE52C366}';
  CLASS_RDOFolders: TGUID = '{6F468BD6-2BD8-4984-ABB1-CEADA5D47A97}';
  CLASS_RDOStores: TGUID = '{34AF0D4D-1CD4-4A59-B393-A17AA7C8201B}';
  CLASS_RDOAccounts: TGUID = '{0A883FFD-5A50-4F5F-8BA9-8B09398CB5F5}';
  IID_IRDODistListItem: TGUID = '{9995A36B-B5D7-4613-A6C7-3A245E74FFDF}';
  CLASS_RDODistListItem: TGUID = '{66E08E94-5F78-4460-A3A6-0AADE8BDFBC5}';
  IID_IRDOContactItem: TGUID = '{DA18E730-205D-4CED-9E61-4DBBC35D2EE5}';
  CLASS_RDOContactItem: TGUID = '{55CF8FC9-DD9A-43FC-9777-27BCFEF1BDE5}';
  IID_IRDOFolder2: TGUID = '{4A34CF03-DB62-4D32-829A-B0079E16E28C}';
  CLASS_RDOFolder2: TGUID = '{45837C2C-0004-4DD1-BB4B-B69A1E41848F}';
  IID_IRDONoteItem: TGUID = '{5BA25695-866B-4043-8387-5E523079EB9A}';
  CLASS_RDONoteItem: TGUID = '{4DA18158-5702-4874-8E0A-1285378B6E18}';
  IID_IRDOPostItem: TGUID = '{64B69367-C437-4F24-ADBE-0A22CF0EA1FE}';
  CLASS_RDOPostItem: TGUID = '{F0C98335-3EB1-4F76-84F6-1A077BE81A20}';
  IID_IRDOLinks: TGUID = '{263FD351-546E-4CE8-BDB4-C7F1856B428B}';
  IID_IRDOLink: TGUID = '{B1442519-608B-4607-8168-DDC2A983525B}';
  CLASS_RDOLinks: TGUID = '{7BF8D62E-D141-4459-8923-0F0892451DC9}';
  CLASS_RDOLink: TGUID = '{2E89E7F5-1E71-4BBF-B35D-8DAAB4A1B97B}';
  IID_IRDOTaskItem: TGUID = '{19C7D2A9-DCF8-4459-A142-11AC87397917}';
  CLASS_RDOTaskItem: TGUID = '{F9AFD2A9-120C-4AAC-A0BA-E9BB5E5FF504}';
  IID_IRDORecurrencePattern: TGUID = '{DDA08E39-CDEF-4E2A-B4C9-909766E8233D}';
  CLASS_RDORecurrencePattern: TGUID = '{B82F3915-0BB0-44F2-BD3B-E038D7B50864}';
  IID_IImportExport: TGUID = '{3B23E05F-7999-4888-B15C-5AADA0BA0649}';
  IID_IRDOReportItem: TGUID = '{2689148B-BB6B-4603-8DDD-126BF33451B5}';
  CLASS_RDOReportItem: TGUID = '{E3083AEA-0B53-4847-85E2-CC2B24A4DA87}';
  IID_IRDOFolderFields: TGUID = '{3765DFB0-1F1A-420D-8E8D-7A4671CB8B5B}';
  IID_IRDOFolderField: TGUID = '{A73C2100-ABBF-4A7F-98D6-D90129EFEAC8}';
  CLASS_RDOFolderFields: TGUID = '{992B0FCD-954B-4859-B50D-BD6C7C4A6873}';
  CLASS_RDOFolderField: TGUID = '{1347DD66-952B-482B-94AF-B9D3173DB713}';
  IID_IRDOTaskRequestItem: TGUID = '{202A5098-5551-4F67-934F-B1747040507C}';
  CLASS_RDOTaskRequestItem: TGUID = '{793E44A2-1708-45FD-AE94-1643D9CFF14C}';
  IID_IRDOTimezones: TGUID = '{B947D1ED-3F3C-4E70-AAE7-57C36AF61ED6}';
  IID_IRDOTimezone: TGUID = '{39C8B828-B3AD-42CF-AFAF-81C872FB21B3}';
  CLASS_RDOTimeZones: TGUID = '{30D01F12-0BBB-47D7-B8BB-93CABD8CBF52}';
  CLASS_RDOTimeZone: TGUID = '{F8460E54-C6DF-49D5-A9FC-9FE7496E13BC}';
  IID_IRDOProfiles: TGUID = '{C561C41C-31CE-43CD-9115-6BDFD8FB5849}';
  CLASS_RDOProfiles: TGUID = '{72D1FC2D-69EA-41FB-8514-EB690C9DBAE2}';
  IID_IRDORules: TGUID = '{4195C7B7-BD63-42A5-931B-1BAAD3FF1771}';
  IID_IRDORule: TGUID = '{84803847-45F6-4281-B1E1-7D9D31044420}';
  IID_IRDORuleActions: TGUID = '{A0883C05-8208-417D-9B03-4AB708C02062}';
  IID_IRDORuleConditions: TGUID = '{491ED4E6-EA33-461E-9F21-D5773917A71E}';
  CLASS_RDORules: TGUID = '{A1E2E0E1-3617-4A6E-B9C7-B4E8FDB8A691}';
  CLASS_RDORule: TGUID = '{55D5F088-6D48-46C2-8397-230F8CBFEE84}';
  CLASS_RDORuleActions: TGUID = '{7B9F9BED-F919-4E9D-B02E-555E82F9BC20}';
  CLASS_RDORuleConditions: TGUID = '{53EF3469-949F-417E-A1D8-63519DC9C16E}';
  IID_IRDORuleAction: TGUID = '{A93C5BC9-CC2D-42C2-8092-90E7E003956A}';
  CLASS_RDORuleAction: TGUID = '{AC594F99-1586-476E-8D70-BCFB14F9D415}';
  IID_IRDORuleActionMoveOrCopy: TGUID = '{41EA114A-7096-4BDE-9FFA-A7A5F6ABADD4}';
  CLASS_RDORuleActionMoveorCopy: TGUID = '{49A2D676-3973-4BB8-8698-19ECBA59C602}';
  IID_IRDORuleActionSend: TGUID = '{7734C205-1168-4EBA-8BC6-0289813EAF6B}';
  CLASS_RDORuleActionSend: TGUID = '{E8B6ED55-F610-4AFC-9FED-087343BBF43D}';
  IID_IRDORuleActionTemplate: TGUID = '{0FEA820A-2315-4A4E-8088-01EA3F72DA55}';
  CLASS_RDORuleActionTemplate: TGUID = '{E9B4D2C4-A097-4F4B-B984-D45FDD791723}';
  IID_IRDORuleActionDefer: TGUID = '{C249766A-D8D3-400B-9201-71EDCB391A97}';
  CLASS_RDORuleActionDefer: TGUID = '{96F1FCA5-B155-4DED-B2CF-9EC947D173DE}';
  IID_IRDORuleActionBounce: TGUID = '{EA29CFAC-42E1-4756-BF39-A4CC44C927A3}';
  CLASS_RDORuleActionBounce: TGUID = '{380D8DD4-1BFD-4D72-BC47-D9C838CDA5FA}';
  IID_IRDORuleActionSensitivity: TGUID = '{23A15647-58F4-46E8-A188-D96C69C29D66}';
  CLASS_RDORuleActionSensitivity: TGUID = '{E4C4EE10-4F0A-4B0C-9666-53B35F34DEC6}';
  IID_IRDORuleActionImportance: TGUID = '{3EDD9B2B-1C2A-4764-9421-4CCE16A60D2E}';
  CLASS_RDORuleActionImportance: TGUID = '{4F0CDE41-41AC-495C-AB7C-EDF6FABB1F51}';
  IID_IRDORuleActionAssignToCategory: TGUID = '{3E530FE8-33A5-4385-9D16-E6CC0AC5D884}';
  CLASS_RDORuleActionAssignToCategory: TGUID = '{750782B8-7ECA-450B-956E-3B90BD4B68F5}';
  IID_IRDORuleActionTag: TGUID = '{10C262E8-3195-4674-9ABE-92B240D52C30}';
  CLASS_RDORuleActionTag: TGUID = '{E7D129C0-4C87-47B9-9E62-3B834871260B}';
  IID_IRDOActions: TGUID = '{5DB66C43-F720-49F7-8BE5-0CB4C537D713}';
  IID_IRDOAction: TGUID = '{EAD0659F-52DF-48E4-B758-5E4C05996DCC}';
  CLASS_RDOActions: TGUID = '{891A615A-03DA-4D35-9788-0768699F2857}';
  CLASS_RDOAction: TGUID = '{582965E2-39BD-4D69-91C2-6D5E50B16A84}';
  IID_IRDORuleCondition: TGUID = '{27D4339B-BFD4-4999-8A11-69B738B6AF62}';
  CLASS_RDORuleCondition: TGUID = '{722CD43E-ADAC-4D1A-ABCD-D02EE38AD34C}';
  IID_IRDORuleConditionImportance: TGUID = '{3054CE9A-E6C3-4890-A679-11A43A113425}';
  CLASS_RDORuleConditionImportance: TGUID = '{E9F0EFDE-70CD-45D9-8DF5-BC75B3DEAE77}';
  IID_IRDORuleConditionText: TGUID = '{2D457800-C7BE-40F2-9129-350B33A97B78}';
  CLASS_RDORuleConditionText: TGUID = '{972500B9-A533-4E5B-8788-046064901212}';
  IID_IRDORuleConditionCategory: TGUID = '{C71E784C-C77B-4E83-8EFD-9C891423F734}';
  CLASS_RDORuleConditionCategory: TGUID = '{E5CB45FD-5E90-4115-80B2-E5CDC74F697B}';
  IID_IRDORuleConditionFormName: TGUID = '{CB365B3A-A1D3-4811-A91C-8C5B928CDF20}';
  CLASS_RDORuleConditionFormName: TGUID = '{6A655607-2991-4E07-ADAB-93D000DCECF7}';
  IID_IRDORuleConditionToOrFrom: TGUID = '{F1D70F51-5493-46F0-959E-5E10AC55F398}';
  CLASS_RDORuleConditionToOrFrom: TGUID = '{5B8998BA-22ED-4E8D-AFCE-F34B1B1401B2}';
  IID_IRDORuleConditionAddress: TGUID = '{BD812A14-4C54-4AE7-88B2-62AF50FB5C08}';
  CLASS_RDORuleConditionAddress: TGUID = '{9FDD182F-9055-4A5A-A9F5-1A053DF623C6}';
  IID_IRDORuleConditionSenderInAddressList: TGUID = '{4C42C3D2-174D-4C64-B6A6-6E00F780DD2E}';
  CLASS_RDORuleConditionSenderInAddressList: TGUID = '{3D9FEF8D-E45C-4CD4-863F-44FA90944270}';
  IID_IRestrictionComment: TGUID = '{205C0C08-8FD8-49E4-BC1C-8DB84092A954}';
  CLASS_RestrictionComment: TGUID = '{DCF5E6C2-A47A-46B0-9794-9C3CDCE21558}';
  IID_IPropValueList: TGUID = '{B0A3D43B-CCD5-4743-85F2-ECCFBEB42B2A}';
  CLASS_PropValueList: TGUID = '{4DCCB961-1A76-421B-A1BE-369ECF2A7DF8}';
  IID_IPropValue: TGUID = '{82B2E238-1870-4E6B-853D-FB6AE7639DF2}';
  CLASS_PropValue: TGUID = '{DB124AD1-C7F2-41D6-8BF3-A6348AEE49BB}';
  IID_IRDOAppointmentItem: TGUID = '{4959BA11-F9D0-4E57-AA7E-125636EEE44A}';
  CLASS_RDOAppointmentItem: TGUID = '{CFCA4F05-AC2C-4E02-8B23-2487893B9386}';
  IID_IRDOConflicts: TGUID = '{F14C4E51-1921-454B-B194-8C58148F168D}';
  IID_IRDOConflict: TGUID = '{7BBC05F5-8DB5-4C42-9899-C709EDD52742}';
  CLASS_RDOConflict: TGUID = '{864FB971-A0B2-47BD-956D-FD957DAF7848}';
  CLASS_RDOConflicts: TGUID = '{0B32F99A-18DE-4443-8F81-C2F1F3A87868}';
  IID_IRDOMeetingItem: TGUID = '{3FE12D4F-CD08-4DAC-9DBB-D3107C63A169}';
  CLASS_RDOMeetingItem: TGUID = '{A09E9CD2-8D1A-4BBF-944A-298A9E094F31}';
  IID_IRDODeletedFolders: TGUID = '{4E78349E-594E-4523-A91B-9995E8C89C23}';
  CLASS_RDODeletedFolders: TGUID = '{004C5EDB-95BF-4FCB-BDA7-820A2D45787D}';
  IID_IRDOExceptions: TGUID = '{6C22A322-0020-42AF-9B5A-ECCBCEB6F64B}';
  IID_IRDOException: TGUID = '{570BBE99-2D82-4C86-9920-951F494C6DB0}';
  CLASS_RDOException: TGUID = '{0F7DAE2D-A8CF-4F6A-BDAD-5EF3873AEFB7}';
  CLASS_RDOExceptions: TGUID = '{0D3244E6-1CD9-4DB1-A577-F22E82A1BE35}';
  IID_IRDOJournalItem: TGUID = '{82BD1792-2C5A-404F-895A-4B765B3FE344}';
  CLASS_RDOJournalItem: TGUID = '{7A565955-2895-4E43-ABED-7CE7C0EF81BB}';
  IID_IRDOCalendarOptions: TGUID = '{8D381511-EE3D-43AC-A5C4-93632DEFE6A7}';
  CLASS_RDOCalendarOptions: TGUID = '{42739172-07E8-4619-9766-3ECEDF3E7089}';
  IID_IRDOFreeBusyRange: TGUID = '{2F2F7C8C-FE44-49DF-9B24-AD22A9937652}';
  CLASS_RDOFreeBusyRange: TGUID = '{65B1F7C5-5BF6-4C77-9DB2-62D4FC58C5E5}';
  IID_IRDOFreeBusySlot: TGUID = '{DDC5A298-B9CE-4CCA-B733-185D2EDF5857}';
  CLASS_RDOFreeBusySlot: TGUID = '{1AD9A6AF-5736-472C-9C72-6D317D56F6C6}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum FlushQueuesEnum
type
  FlushQueuesEnum = TOleEnum;
const
  fqUpload = $00000001;
  fqDownload = $00000002;
  fqUploadDownload = $00000003;
  fqShowProgress = $00000004;
  fqAsync = $00000008;

// Constants for enum RedemptionSaveAsType
type
  RedemptionSaveAsType = TOleEnum;
const
  olRFC822 = $00000400;
  olTNEF = $00000401;

// Constants for enum RestrictionKind
type
  RestrictionKind = TOleEnum;
const
  RES_AND = $00000000;
  RES_BITMASK = $00000006;
  RES_COMPAREPROPS = $00000005;
  RES_CONTENT = $00000003;
  RES_EXIST = $00000008;
  RES_NOT = $00000002;
  RES_OR = $00000001;
  RES_PROPERTY = $00000004;
  RES_SIZE = $00000007;
  RES_SUBRESTRICTION = $00000009;
  RES_COMMENT = $0000000A;

// Constants for enum BitmaskBMR
type
  BitmaskBMR = TOleEnum;
const
  BMR_EQZ = $00000000;
  BMR_NEZ = $00000001;

// Constants for enum PropsRelop
type
  PropsRelop = TOleEnum;
const
  RELOP_GE = $00000003;
  RELOP_GT = $00000002;
  RELOP_LE = $00000001;
  RELOP_LT = $00000000;
  RELOP_NE = $00000005;
  RELOP_RE = $00000006;
  RELOP_EQ = $00000004;

// Constants for enum ContentFuzzyLevel
type
  ContentFuzzyLevel = TOleEnum;
const
  FL_FULLSTRING = $00000000;
  FL_PREFIX = $00000002;
  FL_SUBSTRING = $00000001;
  FL_IGNORECASE = $00010000;
  FL_IGNORENONSPACE = $00020000;
  FL_LOOSE = $00040000;

// Constants for enum SubRestrictionProp
type
  SubRestrictionProp = TOleEnum;
const
  PR_MESSAGE_RECIPIENTS = $0E12000D;
  PR_MESSAGE_ATTACHMENTS = $0E13000D;

// Constants for enum FontPitch
type
  FontPitch = TOleEnum;
const
  fpDefault = $00000000;
  fpVariable = $00000001;
  fpFixed = $00000002;

// Constants for enum TextAlignment
type
  TextAlignment = TOleEnum;
const
  taLeftJustify = $00000000;
  taCenter = $00000001;
  taRightJustify = $00000002;

// Constants for enum NumberingStyle
type
  NumberingStyle = TOleEnum;
const
  nsNone = $00000000;
  nsBullet = $00000001;

// Constants for enum TxStoreKind
type
  TxStoreKind = TOleEnum;
const
  skUnknown = $00000000;
  skPstAnsi = $00000001;
  skPstUnicode = $00000002;
  skPrimaryExchangeMailbox = $00000003;
  skDelegateExchangeMailbox = $00000004;
  skPublicFolders = $00000005;
  skBCM = $00000006;

// Constants for enum redDeleteFlags
type
  redDeleteFlags = TOleEnum;
const
  dfSoftDelete = $00000000;
  dfMoveToDeletedItems = $00000001;
  dfHardDelete = $00000002;

// Constants for enum rdoAccessRights
type
  rdoAccessRights = TOleEnum;
const
  RIGHTS_EDIT_OWN = $00000008;
  RIGHTS_EDIT_ALL = $00000020;
  RIGHTS_DELETE_OWN = $00000010;
  RIGHTS_DELETE_ALL = $00000040;
  RIGHTS_READ_ITEMS = $00000001;
  RIGHTS_CREATE_ITEMS = $00000002;
  RIGHTS_CREATE_SUBFOLDERS = $00000080;
  RIGHTS_FOLDER_OWNER = $00000100;
  RIGHTS_FOLDER_CONTACT = $00000200;
  RIGHTS_FOLDER_VISIBLE = $00000400;
  RIGHTS_NONE = $00000000;
  RIGHTS_ALL = $000005FB;
  ROLE_OWNER = $000007FB;
  ROLE_PUBLISH_EDITOR = $000004FB;
  ROLE_EDITOR = $0000047B;
  ROLE_PUBLISH_AUTHOR = $0000049B;
  ROLE_AUTHOR = $0000041B;
  ROLE_NONEDITING_AUTHOR = $00000413;
  ROLE_REVIEWER = $00000401;
  ROLE_CONTRIBUTOR = $00000402;
  ROLE_NONE = $00000400;

// Constants for enum rdoFolderKind
type
  rdoFolderKind = TOleEnum;
const
  fkRoot = $00000000;
  fkGeneric = $00000001;
  fkSearch = $00000002;

// Constants for enum rdoDefaultFolders
type
  rdoDefaultFolders = TOleEnum;
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
  olFolderDrafts = $00000010;
  olPublicFoldersAllPublicFolders = $00000012;
  olFolderConflicts = $00000013;
  olFolderSyncIssues = $00000014;
  olFolderLocalFailures = $00000015;
  olFolderServerFailures = $00000016;
  olFolderJunk = $00000017;
  olFolderRssSubscriptions = $00000019;
  olFolderToDo = $0000001C;
  olFolderManagedEmail = $0000001D;
  olPublicFoldersFavorites = $00002345;

// Constants for enum rdoSaveAsType
type
  rdoSaveAsType = TOleEnum;
const
  olTXT = $00000000;
  olRTF = $00000001;
  olTemplate = $00000002;
  olMSG = $00000003;
  olDoc = $00000004;
  olHTML = $00000005;
  olVCard = $00000006;
  olVCal = $00000007;
  olICal = $00000008;
  olMSGUnicode = $00000009;
  olRFC822_ = $00000400;
  olTNEF_ = $00000401;
  olRTFNoHeaders = $00000402;

// Constants for enum rdoItemType
type
  rdoItemType = TOleEnum;
const
  olMailItem = $00000000;
  olAppointmentItem = $00000001;
  olContactItem = $00000002;
  olTaskItem = $00000003;
  olJournalItem = $00000004;
  olNoteItem = $00000005;
  olPostItem = $00000006;
  olDistributionListItem = $00000007;

// Constants for enum rdoBodyFormat
type
  rdoBodyFormat = TOleEnum;
const
  olFormatUnspecified = $00000000;
  olFormatPlain = $00000001;
  olFormatHTML = $00000002;
  olFormatRichText = $00000003;

// Constants for enum rdoFlagIcon
type
  rdoFlagIcon = TOleEnum;
const
  olNoFlagIcon = $00000000;
  olPurpleFlagIcon = $00000001;
  olOrangeFlagIcon = $00000002;
  olGreenFlagIcon = $00000003;
  olYellowFlagIcon = $00000004;
  olBlueFlagIcon = $00000005;
  olRedFlagIcon = $00000006;

// Constants for enum rdoTrackingStatus
type
  rdoTrackingStatus = TOleEnum;
const
  olTrackingNone = $00000000;
  olTrackingDelivered = $00000001;
  olTrackingNotDelivered = $00000002;
  olTrackingNotRead = $00000003;
  olTrackingRecallFailure = $00000004;
  olTrackingRecallSuccess = $00000005;
  olTrackingRead = $00000006;
  olTrackingReplied = $00000007;

// Constants for enum rdoMessageAction
type
  rdoMessageAction = TOleEnum;
const
  maOpen = $00000000;
  maReply = $00000065;
  maReplyAll = $00000067;
  maForward = $00000068;
  maPrint = $00000069;
  maSaveAs = $0000006A;
  maReplyToFolder = $0000006C;
  maDesignForm = $00000216;

// Constants for enum rdoAccountType
type
  rdoAccountType = TOleEnum;
const
  atPOP3 = $00000000;
  atIMAP = $00000001;
  atHTTP = $00000002;
  atExchange = $00000003;
  atMAPI = $00000004;
  atLDAP = $00000005;
  atOther = $00000006;

// Constants for enum rdoAccountCategory
type
  rdoAccountCategory = TOleEnum;
const
  acStore = $00000001;
  acMail = $00000002;
  acAddressBook = $00000004;

// Constants for enum rdoSMTPLogonKind
type
  rdoSMTPLogonKind = TOleEnum;
const
  lkSameAsIncoming = $00000000;
  lkUseSMTPCredentials = $00000001;
  lkLogToIncomingFirst = $00000002;

// Constants for enum rdoAddressType
type
  rdoAddressType = TOleEnum;
const
  atEmail1 = $00000000;
  atEmail2 = $00000001;
  atEmail3 = $00000002;
  atBusinessFax = $00000003;
  atHomeFax = $00000004;
  atOtherFax = $00000005;

// Constants for enum rdoGender
type
  rdoGender = TOleEnum;
const
  rdoUnspecified = $00000000;
  rdoMale = $00000002;
  rdoFemale = $00000001;

// Constants for enum rdoMailingAddress
type
  rdoMailingAddress = TOleEnum;
const
  rdoNone = $00000000;
  rdoHome = $00000001;
  rdoBusiness = $00000002;
  rdoOther = $00000003;

// Constants for enum rdoMailRecipientType
type
  rdoMailRecipientType = TOleEnum;
const
  olOriginator = $00000000;
  olTo = $00000001;
  olCC = $00000002;
  olBCC = $00000003;

// Constants for enum rdoPstEncryption
type
  rdoPstEncryption = TOleEnum;
const
  psteCompressableEncryption = $00000001;
  psteBestEncryption = $00000002;
  psteNoEncryption = $00000000;

// Constants for enum rdoNoteColor
type
  rdoNoteColor = TOleEnum;
const
  olBlue = $00000000;
  olGreen = $00000001;
  olPink = $00000002;
  olYellow = $00000003;
  olWhite = $00000004;

// Constants for enum rdoTaskDelegationState
type
  rdoTaskDelegationState = TOleEnum;
const
  olTaskNotDelegated = $00000000;
  olTaskDelegationUnknown = $00000001;
  olTaskDelegationAccepted = $00000002;
  lTaskDelegationDeclined = $00000003;

// Constants for enum rdoTaskOwnership
type
  rdoTaskOwnership = TOleEnum;
const
  olNewTask = $00000000;
  olDelegatedTask = $00000001;
  olOwnTask = $00000002;

// Constants for enum rdoTaskResponse
type
  rdoTaskResponse = TOleEnum;
const
  olTaskSimple = $00000000;
  olTaskAssign = $00000001;
  olTaskAccept = $00000002;
  olTaskDecline = $00000003;

// Constants for enum rdoTaskStatus
type
  rdoTaskStatus = TOleEnum;
const
  olTaskNotStarted = $00000000;
  olTaskInProgress = $00000001;
  olTaskComplete = $00000002;
  olTaskWaiting = $00000003;
  olTaskDeferred = $00000004;

// Constants for enum rdoDaysOfWeek
type
  rdoDaysOfWeek = TOleEnum;
const
  olSunday = $00000001;
  olMonday = $00000002;
  olTuesday = $00000004;
  olWednesday = $00000008;
  olThursday = $00000010;
  olFriday = $00000020;
  olSaturday = $00000040;

// Constants for enum rdoRecurrenceType
type
  rdoRecurrenceType = TOleEnum;
const
  olRecursDaily = $00000000;
  olRecursWeekly = $00000001;
  olRecursMonthly = $00000002;
  olRecursMonthNth = $00000003;
  olRecursYearly = $00000005;
  olRecursYearNth = $00000006;

// Constants for enum rdoRecurrenceState
type
  rdoRecurrenceState = TOleEnum;
const
  olApptNotRecurring = $00000000;
  olApptMaster = $00000001;
  olApptOccurrence = $00000002;
  olApptException = $00000003;

// Constants for enum rdoFileUnderId
type
  rdoFileUnderId = TOleEnum;
const
  fasAdHoc = $00000000;
  fasLastFirstMiddle = $00000001;
  fasFirstMiddleLastSuffix = $00000002;
  fasCompany = $00000003;
  fasLastFirstMiddleCompany = $00000004;
  fasCompanyLastFirstMiddle = $00000005;

// Constants for enum rdoUserPropertyType
type
  rdoUserPropertyType = TOleEnum;
const
  olOutlookInternal = $00000000;
  olText = $00000001;
  olNumber = $0000000C;
  olDateTime = $00000005;
  olYesNo = $00000006;
  olDuration = $00000007;
  olKeywords = $0000000B;
  olPercent = $0000000D;
  olCurrency = $0000000E;
  olFormula = $00000012;
  olCombination = $00000013;
  olInteger = $00000003;

// Constants for enum rdoTaskRequestType
type
  rdoTaskRequestType = TOleEnum;
const
  trRequest = $00000000;
  trAccept = $00000001;
  trDecline = $00000002;
  trUpdate = $00000003;

// Constants for enum rdoRuleActionType
type
  rdoRuleActionType = TOleEnum;
const
  olRuleActionUnknown = $00000000;
  olRuleActionMoveToFolder = $00000001;
  olRuleActionAssignToCategory = $00000002;
  olRuleActionDelete = $00000003;
  olRuleActionDeletePermanently = $00000004;
  olRuleActionCopyToFolder = $00000005;
  olRuleActionForward = $00000006;
  olRuleActionForwardAsAttachment = $00000007;
  olRuleActionServerReply = $00000009;
  olRuleActionImportance = $0000000E;
  olRuleActionSensitivity = $0000000F;
  olRuleActionRedirect = $00000008;
  olRuleActionMarkRead = $00000013;
  olRuleActionDefer = $0000001C;
  olRuleActionBounce = $00000400;
  olRuleActionTag = $00000401;

// Constants for enum rdoBounceCode
type
  rdoBounceCode = TOleEnum;
const
  bcMessageSizeTooLarge = $0000000D;
  bcFormsMismatch = $0000001F;
  bcAccessDenied = $00000026;

// Constants for enum rdoImportance
type
  rdoImportance = TOleEnum;
const
  olImportanceLow = $00000000;
  olImportanceNormal = $00000001;
  olImportanceHigh = $00000002;

// Constants for enum rdoSensitivity
type
  rdoSensitivity = TOleEnum;
const
  olNormal = $00000000;
  olPersonal = $00000001;
  olPrivate = $00000002;
  olConfidential = $00000003;

// Constants for enum rdoActionCopyLike
type
  rdoActionCopyLike = TOleEnum;
const
  olReply = $00000000;
  olReplyAll = $00000001;
  olForward = $00000002;
  olReplyFolder = $00000003;
  olRespond = $00000004;

// Constants for enum rdoActionReplyStyle
type
  rdoActionReplyStyle = TOleEnum;
const
  olOmitOriginalText = $00000000;
  olEmbedOriginalItem = $00000001;
  olIncludeOriginalText = $00000002;
  olIndentOriginalText = $00000003;
  olLinkOriginalItem = $00000004;
  olUserPreference = $00000005;
  olReplyTickOriginalText = $000003E8;

// Constants for enum rdoActionResponseStyle
type
  rdoActionResponseStyle = TOleEnum;
const
  olOpen = $00000000;
  olSend = $00000001;
  olPrompt = $00000002;

// Constants for enum rdoActionShowOn
type
  rdoActionShowOn = TOleEnum;
const
  olDontShow = $00000000;
  olMenu = $00000001;
  olMenuAndToolbar = $00000002;

// Constants for enum rdoRuleConditionType
type
  rdoRuleConditionType = TOleEnum;
const
  olConditionUnknown = $00000000;
  olConditionFrom = $00000001;
  olConditionSubject = $00000002;
  olConditionAccount = $00000003;
  olConditionOnlyToMe = $00000004;
  olConditionTo = $00000005;
  olConditionImportance = $00000006;
  olConditionSensitivity = $00000007;
  olConditionFlaggedForAction = $00000008;
  olConditionCc = $00000009;
  olConditionToOrCc = $0000000A;
  olConditionNotTo = $0000000B;
  olConditionSentTo = $0000000C;
  olConditionBody = $0000000D;
  olConditionBodyOrSubject = $0000000E;
  olConditionMessageHeader = $0000000F;
  olConditionRecipientAddress = $00000010;
  olConditionSenderAddress = $00000011;
  olConditionCategory = $00000012;
  olConditionOOF = $00000013;
  olConditionHasAttachment = $00000014;
  olConditionSizeRange = $00000015;
  olConditionDateRange = $00000016;
  olConditionFormName = $00000017;
  olConditionProperty = $00000018;
  olConditionSenderInAddressBook = $00000019;
  olConditionMeetingInviteOrUpdate = $0000001A;
  olConditionLocalMachineOnly = $0000001B;
  olConditionOtherMachine = $0000001C;
  olConditionAnyCategory = $0000001D;
  olConditionFromRssFeed = $0000001E;
  olConditionFromAnyRssFeed = $0000001F;

// Constants for enum rdoBusyStatus
type
  rdoBusyStatus = TOleEnum;
const
  olFree = $00000000;
  olTentative = $00000001;
  olBusy = $00000002;
  olOutOfOffice = $00000003;

// Constants for enum rdoMeetingStatus
type
  rdoMeetingStatus = TOleEnum;
const
  olNonMeeting = $00000000;
  olMeeting = $00000001;
  olMeetingReceived = $00000003;
  olMeetingCanceled = $00000005;

// Constants for enum rdoNetMeetingType
type
  rdoNetMeetingType = TOleEnum;
const
  olNetMeeting = $00000000;
  olNetShow = $00000001;
  olExchangeConferencing = $00000002;

// Constants for enum rdoResponseStatus
type
  rdoResponseStatus = TOleEnum;
const
  olResponseNone = $00000000;
  olResponseOrganized = $00000001;
  olResponseTentative = $00000002;
  olResponseAccepted = $00000003;
  olResponseDeclined = $00000004;
  olResponseNotResponded = $00000005;

// Constants for enum rdoMeetingResponse
type
  rdoMeetingResponse = TOleEnum;
const
  olMeetingTentative = $00000000;
  olMeetingAccepted = $00000001;
  olMeetingDeclined = $00000002;

// Constants for enum rdoMeetingRequestType
type
  rdoMeetingRequestType = TOleEnum;
const
  mrRequest = $00000000;
  mrAccept = $00000001;
  mrDecline = $00000002;
  mrTentative = $00000003;

// Constants for enum rdoExchangeConnectionMode
type
  rdoExchangeConnectionMode = TOleEnum;
const
  olNoExchange = $00000000;
  olOffline = $00000064;
  olCachedOffline = $000000C8;
  olDisconnected = $0000012C;
  olCachedDisconnected = $00000190;
  olCachedConnectedHeaders = $000001F4;
  olCachedConnectedDrizzle = $00000258;
  olCachedConnectedFull = $000002BC;
  olOnline = $00000320;

// Constants for enum rdoStoreType
type
  rdoStoreType = TOleEnum;
const
  olStoreDefault = $00000001;
  olStoreUnicode = $00000002;
  olStoreANSI = $00000003;

// Constants for enum rdoAttachmentType
type
  rdoAttachmentType = TOleEnum;
const
  olByValue = $00000001;
  olByReference = $00000004;
  olEmbeddedItem = $00000005;
  olOLE = $00000006;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAttachment = interface;
  IAttachmentDisp = dispinterface;
  IAttachments = interface;
  IAttachmentsDisp = dispinterface;
  IAddressEntry = interface;
  IAddressEntryDisp = dispinterface;
  IAddressEntries = interface;
  IAddressEntriesDisp = dispinterface;
  ISafeRecipient = interface;
  ISafeRecipientDisp = dispinterface;
  ISafeRecipients = interface;
  ISafeRecipientsDisp = dispinterface;
  _IBaseItem = interface;
  _IBaseItemDisp = dispinterface;
  _ISafeItem = interface;
  _ISafeItemDisp = dispinterface;
  ISafeContactItem = interface;
  ISafeContactItemDisp = dispinterface;
  ISafeAppointmentItem = interface;
  ISafeAppointmentItemDisp = dispinterface;
  ISafeMailItem = interface;
  ISafeMailItemDisp = dispinterface;
  ISafeTaskItem = interface;
  ISafeTaskItemDisp = dispinterface;
  ISafeJournalItem = interface;
  ISafeJournalItemDisp = dispinterface;
  ISafeMeetingItem = interface;
  ISafeMeetingItemDisp = dispinterface;
  ISafePostItem = interface;
  ISafePostItemDisp = dispinterface;
  IMAPIUtils = interface;
  IMAPIUtilsDisp = dispinterface;
  IMAPIUtilsEvents = dispinterface;
  ISafeMAPIFolder = interface;
  ISafeMAPIFolderDisp = dispinterface;
  ISafeCurrentUser = interface;
  ISafeCurrentUserDisp = dispinterface;
  ISafeTable = interface;
  ISafeTableDisp = dispinterface;
  ISafeDistList = interface;
  ISafeDistListDisp = dispinterface;
  IAddressLists = interface;
  IAddressListsDisp = dispinterface;
  IAddressList = interface;
  IAddressListDisp = dispinterface;
  ISafeItems = interface;
  ISafeItemsDisp = dispinterface;
  IMessageItem = interface;
  IMessageItemDisp = dispinterface;
  _IMAPITable = interface;
  _IMAPITableDisp = dispinterface;
  IDeletedItems = interface;
  IDeletedItemsDisp = dispinterface;
  _IRestriction = interface;
  _IRestrictionDisp = dispinterface;
  _IRestrictionCollection = interface;
  _IRestrictionCollectionDisp = dispinterface;
  IRestrictionAnd = interface;
  IRestrictionAndDisp = dispinterface;
  IRestrictionBitmask = interface;
  IRestrictionBitmaskDisp = dispinterface;
  IRestrictionCompareProps = interface;
  IRestrictionComparePropsDisp = dispinterface;
  IRestrictionContent = interface;
  IRestrictionContentDisp = dispinterface;
  IRestrictionExist = interface;
  IRestrictionExistDisp = dispinterface;
  IRestrictionNot = interface;
  IRestrictionNotDisp = dispinterface;
  IRestrictionOr = interface;
  IRestrictionOrDisp = dispinterface;
  IRestrictionProperty = interface;
  IRestrictionPropertyDisp = dispinterface;
  IRestrictionSize = interface;
  IRestrictionSizeDisp = dispinterface;
  IRestrictionSub = interface;
  IRestrictionSubDisp = dispinterface;
  ITableFilter = interface;
  ITableFilterDisp = dispinterface;
  INamedProperty = interface;
  INamedPropertyDisp = dispinterface;
  IPropList = interface;
  IPropListDisp = dispinterface;
  ISafeReportItem = interface;
  ISafeReportItemDisp = dispinterface;
  ISafeInspector = interface;
  ISafeInspectorDisp = dispinterface;
  IPlainTextEditor = interface;
  IPlainTextEditorDisp = dispinterface;
  IRTFEditor = interface;
  IRTFEditorDisp = dispinterface;
  ITextAttributes = interface;
  ITextAttributesDisp = dispinterface;
  IFontStyle = interface;
  IFontStyleDisp = dispinterface;
  IConsistentAttributes = interface;
  IConsistentAttributesDisp = dispinterface;
  IParagraphAttributes = interface;
  IParagraphAttributesDisp = dispinterface;
  IRDOSession = interface;
  IRDOSessionDisp = dispinterface;
  IRDOSessionEvents = dispinterface;
  iRDOStores = interface;
  iRDOStoresDisp = dispinterface;
  IRDOStoresEvents = dispinterface;
  _MAPIProp = interface;
  _MAPIPropDisp = dispinterface;
  IRDOFolder = interface;
  IRDOFolderDisp = dispinterface;
  IRDOAddressBook = interface;
  IRDOAddressBookDisp = dispinterface;
  IRDOFolderEvents = dispinterface;
  IRDOStore = interface;
  IRDOStoreDisp = dispinterface;
  IRDOPstStore = interface;
  IRDOPstStoreDisp = dispinterface;
  IRDOStoreEvents = dispinterface;
  IRDOExchangeStore = interface;
  IRDOExchangeStoreDisp = dispinterface;
  IRDOExchangeMailboxStore = interface;
  IRDOExchangeMailboxStoreDisp = dispinterface;
  IRDOMail = interface;
  IRDOMailDisp = dispinterface;
  IRDOMailEvents = dispinterface;
  IRDOExchangePublicFoldersStore = interface;
  IRDOExchangePublicFoldersStoreDisp = dispinterface;
  IRDOItems = interface;
  IRDOItemsDisp = dispinterface;
  IRDOItemsEvents = dispinterface;
  IRDOFolders = interface;
  IRDOFoldersDisp = dispinterface;
  IRDOFoldersEvents = dispinterface;
  IRDOAttachments = interface;
  IRDOAttachmentsDisp = dispinterface;
  IRDOAttachment = interface;
  IRDOAttachmentDisp = dispinterface;
  IRDORecipients = interface;
  IRDORecipientsDisp = dispinterface;
  IRDORecipient = interface;
  IRDORecipientDisp = dispinterface;
  IRDOAddressEntry = interface;
  IRDOAddressEntryDisp = dispinterface;
  IRDOAddressEntries = interface;
  IRDOAddressEntriesDisp = dispinterface;
  IRDOAddressList = interface;
  IRDOAddressListDisp = dispinterface;
  IRDOAddressLists = interface;
  IRDOAddressListsDisp = dispinterface;
  IRDOAddressBookSearchPath = interface;
  IRDOAddressBookSearchPathDisp = dispinterface;
  IRDODeletedItems = interface;
  IRDODeletedItemsDisp = dispinterface;
  IRDOSearchFolder = interface;
  IRDOSearchFolderDisp = dispinterface;
  IRDOFolderSearchCriteria = interface;
  IRDOFolderSearchCriteriaDisp = dispinterface;
  IRDOSearchContainersList = interface;
  IRDOSearchContainersListDisp = dispinterface;
  IRDOACL = interface;
  IRDOACLDisp = dispinterface;
  IRDOACE = interface;
  IRDOACEDisp = dispinterface;
  IRDOOutOfOfficeAssistant = interface;
  IRDOOutOfOfficeAssistantDisp = dispinterface;
  IRDOReminders = interface;
  IRDORemindersDisp = dispinterface;
  IRDOReminder = interface;
  IRDOReminderDisp = dispinterface;
  IRDOAccounts = interface;
  IRDOAccountsDisp = dispinterface;
  IRDOAccountsEvents = dispinterface;
  IRDOAccount = interface;
  IRDOAccountDisp = dispinterface;
  IRDOPOP3Account = interface;
  IRDOPOP3AccountDisp = dispinterface;
  IRDOMAPIAccount = interface;
  IRDOMAPIAccountDisp = dispinterface;
  IRDOIMAPAccount = interface;
  IRDOIMAPAccountDisp = dispinterface;
  IRDOHTTPAccount = interface;
  IRDOHTTPAccountDisp = dispinterface;
  IRDOLDAPAccount = interface;
  IRDOLDAPAccountDisp = dispinterface;
  IRDOAccountOrderList = interface;
  IRDOAccountOrderListDisp = dispinterface;
  IRDODistListItem = interface;
  IRDODistListItemDisp = dispinterface;
  IRDOContactItem = interface;
  IRDOContactItemDisp = dispinterface;
  IRDOFolder2 = interface;
  IRDOFolder2Disp = dispinterface;
  IRDONoteItem = interface;
  IRDONoteItemDisp = dispinterface;
  IRDOPostItem = interface;
  IRDOPostItemDisp = dispinterface;
  IRDOLinks = interface;
  IRDOLinksDisp = dispinterface;
  IRDOLink = interface;
  IRDOLinkDisp = dispinterface;
  IRDOTaskItem = interface;
  IRDOTaskItemDisp = dispinterface;
  IRDORecurrencePattern = interface;
  IRDORecurrencePatternDisp = dispinterface;
  IImportExport = interface;
  IRDOReportItem = interface;
  IRDOReportItemDisp = dispinterface;
  IRDOFolderFields = interface;
  IRDOFolderFieldsDisp = dispinterface;
  IRDOFolderField = interface;
  IRDOFolderFieldDisp = dispinterface;
  IRDOTaskRequestItem = interface;
  IRDOTaskRequestItemDisp = dispinterface;
  IRDOTimezones = interface;
  IRDOTimezonesDisp = dispinterface;
  IRDOTimezone = interface;
  IRDOTimezoneDisp = dispinterface;
  IRDOProfiles = interface;
  IRDOProfilesDisp = dispinterface;
  IRDORules = interface;
  IRDORulesDisp = dispinterface;
  IRDORule = interface;
  IRDORuleDisp = dispinterface;
  IRDORuleActions = interface;
  IRDORuleActionsDisp = dispinterface;
  IRDORuleConditions = interface;
  IRDORuleConditionsDisp = dispinterface;
  IRDORuleAction = interface;
  IRDORuleActionDisp = dispinterface;
  IRDORuleActionMoveOrCopy = interface;
  IRDORuleActionMoveOrCopyDisp = dispinterface;
  IRDORuleActionSend = interface;
  IRDORuleActionSendDisp = dispinterface;
  IRDORuleActionTemplate = interface;
  IRDORuleActionTemplateDisp = dispinterface;
  IRDORuleActionDefer = interface;
  IRDORuleActionDeferDisp = dispinterface;
  IRDORuleActionBounce = interface;
  IRDORuleActionBounceDisp = dispinterface;
  IRDORuleActionSensitivity = interface;
  IRDORuleActionSensitivityDisp = dispinterface;
  IRDORuleActionImportance = interface;
  IRDORuleActionImportanceDisp = dispinterface;
  IRDORuleActionAssignToCategory = interface;
  IRDORuleActionAssignToCategoryDisp = dispinterface;
  IRDORuleActionTag = interface;
  IRDORuleActionTagDisp = dispinterface;
  IRDOActions = interface;
  IRDOActionsDisp = dispinterface;
  IRDOAction = interface;
  IRDOActionDisp = dispinterface;
  IRDORuleCondition = interface;
  IRDORuleConditionDisp = dispinterface;
  IRDORuleConditionImportance = interface;
  IRDORuleConditionImportanceDisp = dispinterface;
  IRDORuleConditionText = interface;
  IRDORuleConditionTextDisp = dispinterface;
  IRDORuleConditionCategory = interface;
  IRDORuleConditionCategoryDisp = dispinterface;
  IRDORuleConditionFormName = interface;
  IRDORuleConditionFormNameDisp = dispinterface;
  IRDORuleConditionToOrFrom = interface;
  IRDORuleConditionToOrFromDisp = dispinterface;
  IRDORuleConditionAddress = interface;
  IRDORuleConditionAddressDisp = dispinterface;
  IRDORuleConditionSenderInAddressList = interface;
  IRDORuleConditionSenderInAddressListDisp = dispinterface;
  IRestrictionComment = interface;
  IRestrictionCommentDisp = dispinterface;
  IPropValueList = interface;
  IPropValueListDisp = dispinterface;
  IPropValue = interface;
  IPropValueDisp = dispinterface;
  IRDOAppointmentItem = interface;
  IRDOAppointmentItemDisp = dispinterface;
  IRDOConflicts = interface;
  IRDOConflictsDisp = dispinterface;
  IRDOConflict = interface;
  IRDOConflictDisp = dispinterface;
  IRDOMeetingItem = interface;
  IRDOMeetingItemDisp = dispinterface;
  IRDODeletedFolders = interface;
  IRDODeletedFoldersDisp = dispinterface;
  IRDOExceptions = interface;
  IRDOExceptionsDisp = dispinterface;
  IRDOException = interface;
  IRDOExceptionDisp = dispinterface;
  IRDOJournalItem = interface;
  IRDOJournalItemDisp = dispinterface;
  IRDOCalendarOptions = interface;
  IRDOCalendarOptionsDisp = dispinterface;
  IRDOFreeBusyRange = interface;
  IRDOFreeBusyRangeDisp = dispinterface;
  IRDOFreeBusySlot = interface;
  IRDOFreeBusySlotDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SafeRecipient = ISafeRecipient;
  SafeRecipients = ISafeRecipients;
  _BaseItem = _IBaseItem;
  _SafeItem = _ISafeItem;
  SafeContactItem = ISafeContactItem;
  SafeAppointmentItem = ISafeAppointmentItem;
  SafeMailItem = ISafeMailItem;
  SafeTaskItem = ISafeTaskItem;
  SafeJournalItem = ISafeJournalItem;
  SafeMeetingItem = ISafeMeetingItem;
  SafePostItem = ISafePostItem;
  MAPIUtils = IMAPIUtils;
  AddressEntry = IAddressEntry;
  AddressEntries = IAddressEntries;
  Attachment = IAttachment;
  Attachments = IAttachments;
  MAPIFolder = ISafeMAPIFolder;
  SafeCurrentUser = ISafeCurrentUser;
  SafeTable = ISafeTable;
  SafeDistList = ISafeDistList;
  AddressLists = IAddressLists;
  AddressList = IAddressList;
  SafeItems = ISafeItems;
  MessageItem = IMessageItem;
  MAPITable = _IMAPITable;
  DeletedItems = IDeletedItems;
  RestrictionAnd = IRestrictionAnd;
  RestrictionBitmask = IRestrictionBitmask;
  RestrictionCompareProps = IRestrictionCompareProps;
  RestrictionContent = IRestrictionContent;
  RestrictionExist = IRestrictionExist;
  RestrictionNot = IRestrictionNot;
  RestrictionOr = IRestrictionOr;
  RestrictionProperty = IRestrictionProperty;
  RestrictionSize = IRestrictionSize;
  RestrictionSub = IRestrictionSub;
  TableFilter = ITableFilter;
  _Restriction = _IRestriction;
  _RestrictionCollection = _IRestrictionCollection;
  NamedProperty = INamedProperty;
  PropList = IPropList;
  SafeReportItem = ISafeReportItem;
  SafeInspector = ISafeInspector;
  PlainTextEditor = IPlainTextEditor;
  RTFEditor = IRTFEditor;
  TextAttributes = ITextAttributes;
  FontStyle = IFontStyle;
  ConsistentAttributes = IConsistentAttributes;
  ParagraphAttributes = IParagraphAttributes;
  RDOAddressBook = IRDOAddressBook;
  RDOExchangeMailboxStore = IRDOExchangeMailboxStore;
  RDOExchangeStore = IRDOExchangeStore;
  RDOPstStore = IRDOPstStore;
  RDOExchangePublicFoldersStore = IRDOExchangePublicFoldersStore;
  RDOAttachments = IRDOAttachments;
  RDOAttachment = IRDOAttachment;
  RDORecipients = IRDORecipients;
  RDORecipient = IRDORecipient;
  RDOAddressEntry = IRDOAddressEntry;
  RDOAddressEntries = IRDOAddressEntries;
  RDOAddressList = IRDOAddressList;
  RDOAddressLists = IRDOAddressLists;
  RDOAddressBookSearchPath = IRDOAddressBookSearchPath;
  RDODeletedItems = IRDODeletedItems;
  RDOSearchFolder = IRDOSearchFolder;
  RDOFolderSearchCriteria = IRDOFolderSearchCriteria;
  RDOSearchContainersList = IRDOSearchContainersList;
  RDOACL = IRDOACL;
  RDOACE = IRDOACE;
  RDOOutOfOfficeAssistant = IRDOOutOfOfficeAssistant;
  RDOReminders = IRDOReminders;
  RDOReminder = IRDOReminder;
  RDOAccount = IRDOAccount;
  RDOPOP3Account = IRDOPOP3Account;
  RDOMAPIAccount = IRDOMAPIAccount;
  RDOIMAPAccount = IRDOIMAPAccount;
  RDOHTTPAccount = IRDOHTTPAccount;
  RDOLDAPAccount = IRDOLDAPAccount;
  RDOAccountOrderList = IRDOAccountOrderList;
  RDOSession = IRDOSession;
  RDOStore = IRDOStore;
  RDOFolder = IRDOFolder;
  RDOMail = IRDOMail;
  RDOItems = IRDOItems;
  RDOFolders = IRDOFolders;
  RDOStores = iRDOStores;
  RDOAccounts = IRDOAccounts;
  RDODistListItem = IRDODistListItem;
  RDOContactItem = IRDOContactItem;
  RDOFolder2 = IRDOFolder2;
  RDONoteItem = IRDONoteItem;
  RDOPostItem = IRDOPostItem;
  RDOLinks = IRDOLinks;
  RDOLink = IRDOLink;
  RDOTaskItem = IRDOTaskItem;
  RDORecurrencePattern = IRDORecurrencePattern;
  RDOReportItem = IRDOReportItem;
  RDOFolderFields = IRDOFolderFields;
  RDOFolderField = IRDOFolderField;
  RDOTaskRequestItem = IRDOTaskRequestItem;
  RDOTimeZones = IRDOTimezones;
  RDOTimeZone = IRDOTimezone;
  RDOProfiles = IRDOProfiles;
  RDORules = IRDORules;
  RDORule = IRDORule;
  RDORuleActions = IRDORuleActions;
  RDORuleConditions = IRDORuleConditions;
  RDORuleAction = IRDORuleAction;
  RDORuleActionMoveorCopy = IRDORuleActionMoveOrCopy;
  RDORuleActionSend = IRDORuleActionSend;
  RDORuleActionTemplate = IRDORuleActionTemplate;
  RDORuleActionDefer = IRDORuleActionDefer;
  RDORuleActionBounce = IRDORuleActionBounce;
  RDORuleActionSensitivity = IRDORuleActionSensitivity;
  RDORuleActionImportance = IRDORuleActionImportance;
  RDORuleActionAssignToCategory = IRDORuleActionAssignToCategory;
  RDORuleActionTag = IRDORuleActionTag;
  RDOActions = IRDOActions;
  RDOAction = IRDOAction;
  RDORuleCondition = IRDORuleCondition;
  RDORuleConditionImportance = IRDORuleConditionImportance;
  RDORuleConditionText = IRDORuleConditionText;
  RDORuleConditionCategory = IRDORuleConditionCategory;
  RDORuleConditionFormName = IRDORuleConditionFormName;
  RDORuleConditionToOrFrom = IRDORuleConditionToOrFrom;
  RDORuleConditionAddress = IRDORuleConditionAddress;
  RDORuleConditionSenderInAddressList = IRDORuleConditionSenderInAddressList;
  RestrictionComment = IRestrictionComment;
  PropValueList = IPropValueList;
  PropValue = IPropValue;
  RDOAppointmentItem = IRDOAppointmentItem;
  RDOConflict = IRDOConflict;
  RDOConflicts = IRDOConflicts;
  RDOMeetingItem = IRDOMeetingItem;
  RDODeletedFolders = IRDODeletedFolders;
  RDOException = IRDOException;
  RDOExceptions = IRDOExceptions;
  RDOJournalItem = IRDOJournalItem;
  RDOCalendarOptions = IRDOCalendarOptions;
  RDOFreeBusyRange = IRDOFreeBusyRange;
  RDOFreeBusySlot = IRDOFreeBusySlot;


// *********************************************************************//
// Interface: IAttachment
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47146231-B550-4B13-B9E7-4257F740F39D}
// *********************************************************************//
  IAttachment = interface(IDispatch)
    ['{47146231-B550-4B13-B9E7-4257F740F39D}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const DisplayName: WideString); safecall;
    function Get_FileName: WideString; safecall;
    function Get_Index: Integer; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    function Get_PathName: WideString; safecall;
    function Get_Position: Integer; safecall;
    procedure Set_Position(Position: Integer); safecall;
    function Get_type_: Integer; safecall;
    procedure Delete; safecall;
    procedure SaveAsFile(const Path: WideString); safecall;
    function Get_AsText: WideString; safecall;
    procedure Set_AsText(const Value: WideString); safecall;
    function Get_AsArray: OleVariant; safecall;
    procedure Set_AsArray(Value: OleVariant); safecall;
    function Get_Size: Integer; safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant); safecall;
    function Get_EmbeddedMsg: IMessageItem; safecall;
    function Get_OleStorage: IUnknown; safecall;
    function Get_FileSize: Integer; safecall;
    function Get_LastModificationTime: TDateTime; safecall;
    function Get_CreationTime: TDateTime; safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property DisplayName: WideString read Get_DisplayName write Set_DisplayName;
    property FileName: WideString read Get_FileName;
    property Index: Integer read Get_Index;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT;
    property PathName: WideString read Get_PathName;
    property Position: Integer read Get_Position write Set_Position;
    property type_: Integer read Get_type_;
    property AsText: WideString read Get_AsText write Set_AsText;
    property AsArray: OleVariant read Get_AsArray write Set_AsArray;
    property Size: Integer read Get_Size;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property EmbeddedMsg: IMessageItem read Get_EmbeddedMsg;
    property OleStorage: IUnknown read Get_OleStorage;
    property FileSize: Integer read Get_FileSize;
    property LastModificationTime: TDateTime read Get_LastModificationTime;
    property CreationTime: TDateTime read Get_CreationTime;
  end;

// *********************************************************************//
// DispIntf:  IAttachmentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47146231-B550-4B13-B9E7-4257F740F39D}
// *********************************************************************//
  IAttachmentDisp = dispinterface
    ['{47146231-B550-4B13-B9E7-4257F740F39D}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 113;
    property DisplayName: WideString dispid 12289;
    property FileName: WideString readonly dispid 14084;
    property Index: Integer readonly dispid 91;
    property MAPIOBJECT: IUnknown readonly dispid 61696;
    property PathName: WideString readonly dispid 14088;
    property Position: Integer dispid 114;
    property type_: Integer readonly dispid 14085;
    procedure Delete; dispid 105;
    procedure SaveAsFile(const Path: WideString); dispid 104;
    property AsText: WideString dispid 1;
    property AsArray: OleVariant dispid 2;
    property Size: Integer readonly dispid 3;
    property Fields[PropTag: Integer]: OleVariant dispid 4;
    property EmbeddedMsg: IMessageItem readonly dispid 5;
    property OleStorage: IUnknown readonly dispid 6;
    property FileSize: Integer readonly dispid 1610743832;
    property LastModificationTime: TDateTime readonly dispid 1610743833;
    property CreationTime: TDateTime readonly dispid 1610743834;
  end;

// *********************************************************************//
// Interface: IAttachments
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82B58FCB-73F3-46DC-A52D-74D3FE359702}
// *********************************************************************//
  IAttachments = interface(IDispatch)
    ['{82B58FCB-73F3-46DC-A52D-74D3FE359702}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant): IAttachment; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get__Item(Index: OleVariant): IAttachment; safecall;
    function Item(Index: OleVariant): IAttachment; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property _Item[Index: OleVariant]: IAttachment read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IAttachmentsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82B58FCB-73F3-46DC-A52D-74D3FE359702}
// *********************************************************************//
  IAttachmentsDisp = dispinterface
    ['{82B58FCB-73F3-46DC-A52D-74D3FE359702}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Count: Integer readonly dispid 80;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant): IAttachment; dispid 101;
    procedure Remove(Index: Integer); dispid 84;
    property RawTable: IUnknown readonly dispid 1;
    property _Item[Index: OleVariant]: IAttachment readonly dispid 0; default;
    function Item(Index: OleVariant): IAttachment; dispid 4;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IAddressEntry
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {78412EB9-E06B-4484-BC85-0B1594F6E23A}
// *********************************************************************//
  IAddressEntry = interface(IDispatch)
    ['{78412EB9-E06B-4484-BC85-0B1594F6E23A}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Address: WideString; safecall;
    procedure Set_Address(const Address: WideString); safecall;
    function Get_DisplayType: Integer; safecall;
    function Get_ID: WideString; safecall;
    function Get_Manager: IAddressEntry; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    procedure Set_MAPIOBJECT(const MAPIOBJECT: IUnknown); safecall;
    function Get_Members: IDispatch; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Name: WideString); safecall;
    function Get_type_: WideString; safecall;
    procedure Set_type_(const Type_: WideString); safecall;
    procedure Delete; safecall;
    procedure Details(HWnd: OleVariant); safecall;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; safecall;
    procedure Update(MakePermanent: OleVariant; Refresh: OleVariant); safecall;
    procedure UpdateFreeBusy; safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant); safecall;
    procedure Cleanup; safecall;
    function Get_SMTPAddress: WideString; safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Address: WideString read Get_Address write Set_Address;
    property DisplayType: Integer read Get_DisplayType;
    property ID: WideString read Get_ID;
    property Manager: IAddressEntry read Get_Manager;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property Members: IDispatch read Get_Members;
    property Name: WideString read Get_Name write Set_Name;
    property type_: WideString read Get_type_ write Set_type_;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property SMTPAddress: WideString read Get_SMTPAddress;
  end;

// *********************************************************************//
// DispIntf:  IAddressEntryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {78412EB9-E06B-4484-BC85-0B1594F6E23A}
// *********************************************************************//
  IAddressEntryDisp = dispinterface
    ['{78412EB9-E06B-4484-BC85-0B1594F6E23A}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Address: WideString dispid 12291;
    property DisplayType: Integer readonly dispid 14592;
    property ID: WideString readonly dispid 61470;
    property Manager: IAddressEntry readonly dispid 771;
    property MAPIOBJECT: IUnknown dispid 61696;
    property Members: IDispatch readonly dispid 772;
    property Name: WideString dispid 12289;
    property type_: WideString dispid 12290;
    procedure Delete; dispid 770;
    procedure Details(HWnd: OleVariant); dispid 769;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 774;
    procedure Update(MakePermanent: OleVariant; Refresh: OleVariant); dispid 768;
    procedure UpdateFreeBusy; dispid 775;
    property Fields[PropTag: Integer]: OleVariant dispid 1;
    procedure Cleanup; dispid 2;
    property SMTPAddress: WideString readonly dispid 1610743832;
  end;

// *********************************************************************//
// Interface: IAddressEntries
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C1DFD382-E253-434D-B22D-2E47233B6147}
// *********************************************************************//
  IAddressEntries = interface(IDispatch)
    ['{C1DFD382-E253-434D-B22D-2E47233B6147}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Add(const Type_: WideString; Name: OleVariant; Address: OleVariant): IAddressEntry; safecall;
    function GetFirst: IAddressEntry; safecall;
    function GetLast: IAddressEntry; safecall;
    function GetNext: IAddressEntry; safecall;
    function GetPrevious: IAddressEntry; safecall;
    procedure Sort(Property_: OleVariant; Order: OleVariant); safecall;
    function Get__Item(Index: OleVariant): IAddressEntry; safecall;
    function Item(Index: OleVariant): IAddressEntry; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property _Item[Index: OleVariant]: IAddressEntry read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IAddressEntriesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C1DFD382-E253-434D-B22D-2E47233B6147}
// *********************************************************************//
  IAddressEntriesDisp = dispinterface
    ['{C1DFD382-E253-434D-B22D-2E47233B6147}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Count: Integer readonly dispid 80;
    property RawTable: IUnknown readonly dispid 90;
    function Add(const Type_: WideString; Name: OleVariant; Address: OleVariant): IAddressEntry; dispid 95;
    function GetFirst: IAddressEntry; dispid 86;
    function GetLast: IAddressEntry; dispid 88;
    function GetNext: IAddressEntry; dispid 87;
    function GetPrevious: IAddressEntry; dispid 89;
    procedure Sort(Property_: OleVariant; Order: OleVariant); dispid 97;
    property _Item[Index: OleVariant]: IAddressEntry readonly dispid 0; default;
    function Item(Index: OleVariant): IAddressEntry; dispid 2;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 3;
  end;

// *********************************************************************//
// Interface: ISafeRecipient
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C61669E-F0CE-4126-B365-316588E6228F}
// *********************************************************************//
  ISafeRecipient = interface(IDispatch)
    ['{5C61669E-F0CE-4126-B365-316588E6228F}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Address: WideString; safecall;
    function Get_AddressEntry: IAddressEntry; safecall;
    procedure _Set_AddressEntry(const AddressEntry: IAddressEntry); safecall;
    function Get_DisplayType: Integer; safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Index: Integer; safecall;
    function Get_Name: WideString; safecall;
    function Get_Resolved: WordBool; safecall;
    function Get_type_: Integer; safecall;
    procedure Set_type_(Type_: Integer); safecall;
    procedure Delete; safecall;
    function Resolve(ShowDialog: WordBool): WordBool; safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant); safecall;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; safecall;
    function Get_TrackingStatus: Integer; safecall;
    procedure Set_TrackingStatus(retVal: Integer); safecall;
    function Get_TrackingStatusTime: TDateTime; safecall;
    procedure Set_TrackingStatusTime(retVal: TDateTime); safecall;
    function Get_SendRichInfo: WordBool; safecall;
    procedure Set_SendRichInfo(retVal: WordBool); safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Address: WideString read Get_Address;
    property AddressEntry: IAddressEntry read Get_AddressEntry write _Set_AddressEntry;
    property DisplayType: Integer read Get_DisplayType;
    property EntryID: WideString read Get_EntryID;
    property Index: Integer read Get_Index;
    property Name: WideString read Get_Name;
    property Resolved: WordBool read Get_Resolved;
    property type_: Integer read Get_type_ write Set_type_;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property TrackingStatus: Integer read Get_TrackingStatus write Set_TrackingStatus;
    property TrackingStatusTime: TDateTime read Get_TrackingStatusTime write Set_TrackingStatusTime;
    property SendRichInfo: WordBool read Get_SendRichInfo write Set_SendRichInfo;
  end;

// *********************************************************************//
// DispIntf:  ISafeRecipientDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C61669E-F0CE-4126-B365-316588E6228F}
// *********************************************************************//
  ISafeRecipientDisp = dispinterface
    ['{5C61669E-F0CE-4126-B365-316588E6228F}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 109;
    property Address: WideString readonly dispid 12291;
    property AddressEntry: IAddressEntry dispid 121;
    property DisplayType: Integer readonly dispid 14592;
    property EntryID: WideString readonly dispid 61470;
    property Index: Integer readonly dispid 91;
    property Name: WideString readonly dispid 12289;
    property Resolved: WordBool readonly dispid 100;
    property type_: Integer dispid 3093;
    procedure Delete; dispid 110;
    function Resolve(ShowDialog: WordBool): WordBool; dispid 113;
    property Fields[PropTag: Integer]: OleVariant dispid 1;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 2;
    property TrackingStatus: Integer dispid 1610743827;
    property TrackingStatusTime: TDateTime dispid 1610743829;
    property SendRichInfo: WordBool dispid 1610743831;
  end;

// *********************************************************************//
// Interface: ISafeRecipients
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CACB61E0-AEEA-404D-88E1-7F3BCA8B8726}
// *********************************************************************//
  ISafeRecipients = interface(IDispatch)
    ['{CACB61E0-AEEA-404D-88E1-7F3BCA8B8726}']
    function Get_Count: Integer; safecall;
    function Add(const Name: WideString): ISafeRecipient; safecall;
    function Item(Index: Integer): ISafeRecipient; safecall;
    procedure Remove(Index: Integer); safecall;
    function ResolveAll: WordBool; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get__Item(Index: Integer): ISafeRecipient; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function AddEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant; 
                   Type_: OleVariant): ISafeRecipient; safecall;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property _NewEnum: IUnknown read Get__NewEnum;
    property _Item[Index: Integer]: ISafeRecipient read Get__Item; default;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  ISafeRecipientsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CACB61E0-AEEA-404D-88E1-7F3BCA8B8726}
// *********************************************************************//
  ISafeRecipientsDisp = dispinterface
    ['{CACB61E0-AEEA-404D-88E1-7F3BCA8B8726}']
    property Count: Integer readonly dispid 80;
    function Add(const Name: WideString): ISafeRecipient; dispid 111;
    function Item(Index: Integer): ISafeRecipient; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
    function ResolveAll: WordBool; dispid 126;
    property RawTable: IUnknown readonly dispid 1;
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property _NewEnum: IUnknown readonly dispid -4;
    property _Item[Index: Integer]: ISafeRecipient readonly dispid 0; default;
    property MAPITable: _IMAPITable readonly dispid 2;
    function AddEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant; 
                   Type_: OleVariant): ISafeRecipient; dispid 3;
  end;

// *********************************************************************//
// Interface: _IBaseItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F71D2854-2609-4A63-B4BF-BF2BA61A61CF}
// *********************************************************************//
  _IBaseItem = interface(IDispatch)
    ['{F71D2854-2609-4A63-B4BF-BF2BA61A61CF}']
    function Get_Item: IDispatch; safecall;
    procedure Set_Item(const Value: IDispatch); safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant); safecall;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; safecall;
    function Get_Version: WideString; safecall;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
  end;

// *********************************************************************//
// DispIntf:  _IBaseItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F71D2854-2609-4A63-B4BF-BF2BA61A61CF}
// *********************************************************************//
  _IBaseItemDisp = dispinterface
    ['{F71D2854-2609-4A63-B4BF-BF2BA61A61CF}']
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: _ISafeItem
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {DBCAD616-BFD4-4C72-8D87-C5926921D378}
// *********************************************************************//
  _ISafeItem = interface(_IBaseItem)
    ['{DBCAD616-BFD4-4C72-8D87-C5926921D378}']
    function Get_RTFBody: WideString; safecall;
    procedure Set_RTFBody(const Value: WideString); safecall;
    procedure Send; safecall;
    function Get_Recipients: ISafeRecipients; safecall;
    function Get_Attachments: IAttachments; safecall;
    procedure Set_AuthKey(const Param1: WideString); safecall;
    procedure Import(const Path: WideString; Type_: Integer); safecall;
    function Get_Body: WideString; safecall;
    procedure Set_Body(const Value: WideString); safecall;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); safecall;
    function Get_Sender: IAddressEntry; safecall;
    procedure CopyTo(Item: OleVariant); safecall;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Body: WideString read Get_Body write Set_Body;
    property Sender: IAddressEntry read Get_Sender;
  end;

// *********************************************************************//
// DispIntf:  _ISafeItemDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {DBCAD616-BFD4-4C72-8D87-C5926921D378}
// *********************************************************************//
  _ISafeItemDisp = dispinterface
    ['{DBCAD616-BFD4-4C72-8D87-C5926921D378}']
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeContactItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}
// *********************************************************************//
  ISafeContactItem = interface(_ISafeItem)
    ['{3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}']
    function Get_Email1Address: WideString; safecall;
    function Get_Email1AddressType: WideString; safecall;
    function Get_Email1DisplayName: WideString; safecall;
    function Get_Email1EntryID: WideString; safecall;
    function Get_Email2Address: WideString; safecall;
    function Get_Email2AddressType: WideString; safecall;
    function Get_Email2DisplayName: WideString; safecall;
    function Get_Email2EntryID: WideString; safecall;
    function Get_Email3Address: WideString; safecall;
    function Get_Email3AddressType: WideString; safecall;
    function Get_Email3DisplayName: WideString; safecall;
    function Get_Email3EntryID: WideString; safecall;
    function Get_NetMeetingAlias: WideString; safecall;
    function Get_ReferredBy: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    function Get_IMAddress: WideString; safecall;
    property Email1Address: WideString read Get_Email1Address;
    property Email1AddressType: WideString read Get_Email1AddressType;
    property Email1DisplayName: WideString read Get_Email1DisplayName;
    property Email1EntryID: WideString read Get_Email1EntryID;
    property Email2Address: WideString read Get_Email2Address;
    property Email2AddressType: WideString read Get_Email2AddressType;
    property Email2DisplayName: WideString read Get_Email2DisplayName;
    property Email2EntryID: WideString read Get_Email2EntryID;
    property Email3Address: WideString read Get_Email3Address;
    property Email3AddressType: WideString read Get_Email3AddressType;
    property Email3DisplayName: WideString read Get_Email3DisplayName;
    property Email3EntryID: WideString read Get_Email3EntryID;
    property NetMeetingAlias: WideString read Get_NetMeetingAlias;
    property ReferredBy: WideString read Get_ReferredBy;
    property HTMLBody: WideString read Get_HTMLBody;
    property IMAddress: WideString read Get_IMAddress;
  end;

// *********************************************************************//
// DispIntf:  ISafeContactItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}
// *********************************************************************//
  ISafeContactItemDisp = dispinterface
    ['{3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}']
    property Email1Address: WideString readonly dispid 32899;
    property Email1AddressType: WideString readonly dispid 32898;
    property Email1DisplayName: WideString readonly dispid 32896;
    property Email1EntryID: WideString readonly dispid 32901;
    property Email2Address: WideString readonly dispid 32915;
    property Email2AddressType: WideString readonly dispid 32914;
    property Email2DisplayName: WideString readonly dispid 32912;
    property Email2EntryID: WideString readonly dispid 32917;
    property Email3Address: WideString readonly dispid 32931;
    property Email3AddressType: WideString readonly dispid 32930;
    property Email3DisplayName: WideString readonly dispid 32928;
    property Email3EntryID: WideString readonly dispid 32933;
    property NetMeetingAlias: WideString readonly dispid 32863;
    property ReferredBy: WideString readonly dispid 14919;
    property HTMLBody: WideString readonly dispid 62468;
    property IMAddress: WideString readonly dispid 32866;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeAppointmentItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {35EFAD55-134A-47BF-912A-44A9D9FD556F}
// *********************************************************************//
  ISafeAppointmentItem = interface(_ISafeItem)
    ['{35EFAD55-134A-47BF-912A-44A9D9FD556F}']
    function Get_Organizer: WideString; safecall;
    function Get_RequiredAttendees: WideString; safecall;
    function Get_OptionalAttendees: WideString; safecall;
    function Get_Resources: WideString; safecall;
    function Get_NetMeetingOrganizerAlias: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    function Get_SendAsICal: WordBool; safecall;
    procedure Set_SendAsICal(retVal: WordBool); safecall;
    property Organizer: WideString read Get_Organizer;
    property RequiredAttendees: WideString read Get_RequiredAttendees;
    property OptionalAttendees: WideString read Get_OptionalAttendees;
    property Resources: WideString read Get_Resources;
    property NetMeetingOrganizerAlias: WideString read Get_NetMeetingOrganizerAlias;
    property HTMLBody: WideString read Get_HTMLBody;
    property SendAsICal: WordBool read Get_SendAsICal write Set_SendAsICal;
  end;

// *********************************************************************//
// DispIntf:  ISafeAppointmentItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {35EFAD55-134A-47BF-912A-44A9D9FD556F}
// *********************************************************************//
  ISafeAppointmentItemDisp = dispinterface
    ['{35EFAD55-134A-47BF-912A-44A9D9FD556F}']
    property Organizer: WideString readonly dispid 66;
    property RequiredAttendees: WideString readonly dispid 3588;
    property OptionalAttendees: WideString readonly dispid 3587;
    property Resources: WideString readonly dispid 3586;
    property NetMeetingOrganizerAlias: WideString readonly dispid 33347;
    property HTMLBody: WideString readonly dispid 62468;
    property SendAsICal: WordBool dispid 1610874886;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeMailItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0A95BE2D-1543-46BE-AD6D-18653034BF87}
// *********************************************************************//
  ISafeMailItem = interface(_ISafeItem)
    ['{0A95BE2D-1543-46BE-AD6D-18653034BF87}']
    function Get_SentOnBehalfOfName: WideString; safecall;
    function Get_SenderName: WideString; safecall;
    function Get_ReceivedByName: WideString; safecall;
    function Get_ReceivedOnBehalfOfName: WideString; safecall;
    function Get_ReplyRecipientNames: WideString; safecall;
    function Get_To_: WideString; safecall;
    function Get_CC: WideString; safecall;
    function Get_BCC: WideString; safecall;
    function Get_ReplyRecipients: ISafeRecipients; safecall;
    function Get_HTMLBody: WideString; safecall;
    function Get_SenderEmailAddress: WideString; safecall;
    property SentOnBehalfOfName: WideString read Get_SentOnBehalfOfName;
    property SenderName: WideString read Get_SenderName;
    property ReceivedByName: WideString read Get_ReceivedByName;
    property ReceivedOnBehalfOfName: WideString read Get_ReceivedOnBehalfOfName;
    property ReplyRecipientNames: WideString read Get_ReplyRecipientNames;
    property To_: WideString read Get_To_;
    property CC: WideString read Get_CC;
    property BCC: WideString read Get_BCC;
    property ReplyRecipients: ISafeRecipients read Get_ReplyRecipients;
    property HTMLBody: WideString read Get_HTMLBody;
    property SenderEmailAddress: WideString read Get_SenderEmailAddress;
  end;

// *********************************************************************//
// DispIntf:  ISafeMailItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0A95BE2D-1543-46BE-AD6D-18653034BF87}
// *********************************************************************//
  ISafeMailItemDisp = dispinterface
    ['{0A95BE2D-1543-46BE-AD6D-18653034BF87}']
    property SentOnBehalfOfName: WideString readonly dispid 66;
    property SenderName: WideString readonly dispid 3098;
    property ReceivedByName: WideString readonly dispid 64;
    property ReceivedOnBehalfOfName: WideString readonly dispid 68;
    property ReplyRecipientNames: WideString readonly dispid 80;
    property To_: WideString readonly dispid 3588;
    property CC: WideString readonly dispid 3587;
    property BCC: WideString readonly dispid 3586;
    property ReplyRecipients: ISafeRecipients readonly dispid 61459;
    property HTMLBody: WideString readonly dispid 62468;
    property SenderEmailAddress: WideString readonly dispid 3103;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeTaskItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F961CE9D-AE2B-4CFB-887C-3A055FF685C9}
// *********************************************************************//
  ISafeTaskItem = interface(_ISafeItem)
    ['{F961CE9D-AE2B-4CFB-887C-3A055FF685C9}']
    function Get_ContactNames: WideString; safecall;
    function Get_Contacts: OleVariant; safecall;
    function Get_Delegator: WideString; safecall;
    function Get_Owner: WideString; safecall;
    function Get_StatusUpdateRecipients: WideString; safecall;
    function Get_StatusOnCompletionRecipients: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    property ContactNames: WideString read Get_ContactNames;
    property Contacts: OleVariant read Get_Contacts;
    property Delegator: WideString read Get_Delegator;
    property Owner: WideString read Get_Owner;
    property StatusUpdateRecipients: WideString read Get_StatusUpdateRecipients;
    property StatusOnCompletionRecipients: WideString read Get_StatusOnCompletionRecipients;
    property HTMLBody: WideString read Get_HTMLBody;
  end;

// *********************************************************************//
// DispIntf:  ISafeTaskItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F961CE9D-AE2B-4CFB-887C-3A055FF685C9}
// *********************************************************************//
  ISafeTaskItemDisp = dispinterface
    ['{F961CE9D-AE2B-4CFB-887C-3A055FF685C9}']
    property ContactNames: WideString readonly dispid 34108;
    property Contacts: OleVariant readonly dispid 34106;
    property Delegator: WideString readonly dispid 33057;
    property Owner: WideString readonly dispid 33055;
    property StatusUpdateRecipients: WideString readonly dispid 3587;
    property StatusOnCompletionRecipients: WideString readonly dispid 3586;
    property HTMLBody: WideString readonly dispid 62468;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeJournalItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E3EC74BB-5522-462D-A00F-2728C53FCA04}
// *********************************************************************//
  ISafeJournalItem = interface(_ISafeItem)
    ['{E3EC74BB-5522-462D-A00F-2728C53FCA04}']
    function Get_ContactNames: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    property ContactNames: WideString read Get_ContactNames;
    property HTMLBody: WideString read Get_HTMLBody;
  end;

// *********************************************************************//
// DispIntf:  ISafeJournalItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E3EC74BB-5522-462D-A00F-2728C53FCA04}
// *********************************************************************//
  ISafeJournalItemDisp = dispinterface
    ['{E3EC74BB-5522-462D-A00F-2728C53FCA04}']
    property ContactNames: WideString readonly dispid 3588;
    property HTMLBody: WideString readonly dispid 62468;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeMeetingItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F7919641-3978-4668-8388-7310329C800E}
// *********************************************************************//
  ISafeMeetingItem = interface(_ISafeItem)
    ['{F7919641-3978-4668-8388-7310329C800E}']
    function Get_SenderName: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    property SenderName: WideString read Get_SenderName;
    property HTMLBody: WideString read Get_HTMLBody;
  end;

// *********************************************************************//
// DispIntf:  ISafeMeetingItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F7919641-3978-4668-8388-7310329C800E}
// *********************************************************************//
  ISafeMeetingItemDisp = dispinterface
    ['{F7919641-3978-4668-8388-7310329C800E}']
    property SenderName: WideString readonly dispid 3098;
    property HTMLBody: WideString readonly dispid 62468;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafePostItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6A5D680A-8F9F-4752-A056-2C0273F60B4E}
// *********************************************************************//
  ISafePostItem = interface(_ISafeItem)
    ['{6A5D680A-8F9F-4752-A056-2C0273F60B4E}']
    function Get_SenderName: WideString; safecall;
    function Get_HTMLBody: WideString; safecall;
    property SenderName: WideString read Get_SenderName;
    property HTMLBody: WideString read Get_HTMLBody;
  end;

// *********************************************************************//
// DispIntf:  ISafePostItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6A5D680A-8F9F-4752-A056-2C0273F60B4E}
// *********************************************************************//
  ISafePostItemDisp = dispinterface
    ['{6A5D680A-8F9F-4752-A056-2C0273F60B4E}']
    property SenderName: WideString readonly dispid 3098;
    property HTMLBody: WideString readonly dispid 62468;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: IMAPIUtils
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D45B0772-5801-4E61-9CBA-84120557A4D7}
// *********************************************************************//
  IMAPIUtils = interface(IDispatch)
    ['{D45B0772-5801-4E61-9CBA-84120557A4D7}']
    function HrGetOneProp(const MAPIProp: IUnknown; PropTag: Integer): OleVariant; safecall;
    function HrSetOneProp(const MAPIProp: IUnknown; PropTag: Integer; Value: OleVariant; 
                          bSave: WordBool): Integer; safecall;
    function GetIDsFromNames(const MAPIProp: IUnknown; const GUID: WideString; ID: OleVariant; 
                             bCreate: WordBool): Integer; safecall;
    procedure DeliverNow(Flags: Integer; ParentWndHandle: Integer); safecall;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant; 
                         CcLabel: OleVariant; BccLabel: OleVariant; ParentWindow: OleVariant): ISafeRecipients; safecall;
    function CompareIDs(const ID1: WideString; const ID2: WideString): WordBool; safecall;
    procedure Set_AuthKey(const Param1: WideString); safecall;
    function GetAddressEntryFromID(const ID: WideString): IAddressEntry; safecall;
    procedure Cleanup; safecall;
    function Get_Version: WideString; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    procedure Set_MAPIOBJECT(const Value: IUnknown); safecall;
    function Get_AddressBookFilter: WideString; safecall;
    procedure Set_AddressBookFilter(const Value: WideString); safecall;
    function GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem; safecall;
    function CreateRecipient(const Name: WideString; ShowDialog: WordBool; ParentWnd: Integer): ISafeRecipient; safecall;
    function Get_CurrentProfileName: WideString; safecall;
    function HrArrayToString(InputArray: OleVariant): WideString; safecall;
    function HrStringToArray(const InputString: WideString): OleVariant; safecall;
    function HrLocalToGMT(Value: TDateTime): TDateTime; safecall;
    function HrGMTToLocal(Value: TDateTime): TDateTime; safecall;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; safecall;
    function HrGetPropList(const Obj: IUnknown; UseUnicode: WordBool): IPropList; safecall;
    function GetItemFromMsgFile(const FileName: WideString; CreateNew: WordBool): IMessageItem; safecall;
    function Get_DefaultABListEntryID: WideString; safecall;
    procedure Set_DefaultABListEntryID(const Value: WideString); safecall;
    function GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IMessageItem; safecall;
    function ScCreateConversationIndex(const ParentConversationIndex: WideString): WideString; safecall;
    property AuthKey: WideString write Set_AuthKey;
    property Version: WideString read Get_Version;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property AddressBookFilter: WideString read Get_AddressBookFilter write Set_AddressBookFilter;
    property CurrentProfileName: WideString read Get_CurrentProfileName;
    property DefaultABListEntryID: WideString read Get_DefaultABListEntryID write Set_DefaultABListEntryID;
  end;

// *********************************************************************//
// DispIntf:  IMAPIUtilsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D45B0772-5801-4E61-9CBA-84120557A4D7}
// *********************************************************************//
  IMAPIUtilsDisp = dispinterface
    ['{D45B0772-5801-4E61-9CBA-84120557A4D7}']
    function HrGetOneProp(const MAPIProp: IUnknown; PropTag: Integer): OleVariant; dispid 1;
    function HrSetOneProp(const MAPIProp: IUnknown; PropTag: Integer; Value: OleVariant; 
                          bSave: WordBool): Integer; dispid 2;
    function GetIDsFromNames(const MAPIProp: IUnknown; const GUID: WideString; ID: OleVariant; 
                             bCreate: WordBool): Integer; dispid 3;
    procedure DeliverNow(Flags: Integer; ParentWndHandle: Integer); dispid 4;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant; 
                         CcLabel: OleVariant; BccLabel: OleVariant; ParentWindow: OleVariant): ISafeRecipients; dispid 5;
    function CompareIDs(const ID1: WideString; const ID2: WideString): WordBool; dispid 6;
    property AuthKey: WideString writeonly dispid 7;
    function GetAddressEntryFromID(const ID: WideString): IAddressEntry; dispid 8;
    procedure Cleanup; dispid 9;
    property Version: WideString readonly dispid 10;
    property MAPIOBJECT: IUnknown dispid 11;
    property AddressBookFilter: WideString dispid 12;
    function GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem; dispid 14;
    function CreateRecipient(const Name: WideString; ShowDialog: WordBool; ParentWnd: Integer): ISafeRecipient; dispid 13;
    property CurrentProfileName: WideString readonly dispid 15;
    function HrArrayToString(InputArray: OleVariant): WideString; dispid 16;
    function HrStringToArray(const InputString: WideString): OleVariant; dispid 17;
    function HrLocalToGMT(Value: TDateTime): TDateTime; dispid 18;
    function HrGMTToLocal(Value: TDateTime): TDateTime; dispid 19;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 20;
    function HrGetPropList(const Obj: IUnknown; UseUnicode: WordBool): IPropList; dispid 21;
    function GetItemFromMsgFile(const FileName: WideString; CreateNew: WordBool): IMessageItem; dispid 22;
    property DefaultABListEntryID: WideString dispid 23;
    function GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IMessageItem; dispid 24;
    function ScCreateConversationIndex(const ParentConversationIndex: WideString): WideString; dispid 1610743835;
  end;

// *********************************************************************//
// DispIntf:  IMAPIUtilsEvents
// Flags:     (4096) Dispatchable
// GUID:      {359A062F-CDA8-4A9C-9B28-588446D35098}
// *********************************************************************//
  IMAPIUtilsEvents = dispinterface
    ['{359A062F-CDA8-4A9C-9B28-588446D35098}']
    procedure NewMail(const Item: IDispatch); dispid 1;
  end;

// *********************************************************************//
// Interface: ISafeMAPIFolder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31CE2164-4D5C-4508-BCA7-B10E11D08E6B}
// *********************************************************************//
  ISafeMAPIFolder = interface(_IBaseItem)
    ['{31CE2164-4D5C-4508-BCA7-B10E11D08E6B}']
    function Get_MAPIOBJECT: IUnknown; safecall;
    function Get_HiddenItems: ISafeItems; safecall;
    function Get_Items: ISafeItems; safecall;
    function Get_DeletedItems: IDeletedItems; safecall;
    procedure SetMAPIOBJECT(const Folder: IUnknown); safecall;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT;
    property HiddenItems: ISafeItems read Get_HiddenItems;
    property Items: ISafeItems read Get_Items;
    property DeletedItems: IDeletedItems read Get_DeletedItems;
  end;

// *********************************************************************//
// DispIntf:  ISafeMAPIFolderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31CE2164-4D5C-4508-BCA7-B10E11D08E6B}
// *********************************************************************//
  ISafeMAPIFolderDisp = dispinterface
    ['{31CE2164-4D5C-4508-BCA7-B10E11D08E6B}']
    property MAPIOBJECT: IUnknown readonly dispid 12245938;
    property HiddenItems: ISafeItems readonly dispid 64109;
    property Items: ISafeItems readonly dispid 1;
    property DeletedItems: IDeletedItems readonly dispid 2;
    procedure SetMAPIOBJECT(const Folder: IUnknown); dispid 3;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeCurrentUser
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}
// *********************************************************************//
  ISafeCurrentUser = interface(IAddressEntry)
    ['{D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}']
  end;

// *********************************************************************//
// DispIntf:  ISafeCurrentUserDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}
// *********************************************************************//
  ISafeCurrentUserDisp = dispinterface
    ['{D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Session: IDispatch readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Address: WideString dispid 12291;
    property DisplayType: Integer readonly dispid 14592;
    property ID: WideString readonly dispid 61470;
    property Manager: IAddressEntry readonly dispid 771;
    property MAPIOBJECT: IUnknown dispid 61696;
    property Members: IDispatch readonly dispid 772;
    property Name: WideString dispid 12289;
    property type_: WideString dispid 12290;
    procedure Delete; dispid 770;
    procedure Details(HWnd: OleVariant); dispid 769;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 774;
    procedure Update(MakePermanent: OleVariant; Refresh: OleVariant); dispid 768;
    procedure UpdateFreeBusy; dispid 775;
    property Fields[PropTag: Integer]: OleVariant dispid 1;
    procedure Cleanup; dispid 2;
    property SMTPAddress: WideString readonly dispid 1610743832;
  end;

// *********************************************************************//
// Interface: ISafeTable
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CD5B9523-6EAF-4D63-8FE8-C081C51D1673}
// *********************************************************************//
  ISafeTable = interface(IDispatch)
    ['{CD5B9523-6EAF-4D63-8FE8-C081C51D1673}']
    function Get_Count: Integer; safecall;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  ISafeTableDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CD5B9523-6EAF-4D63-8FE8-C081C51D1673}
// *********************************************************************//
  ISafeTableDisp = dispinterface
    ['{CD5B9523-6EAF-4D63-8FE8-C081C51D1673}']
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: ISafeDistList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EBB4EBA9-D546-4C85-A05A-167BF875FB83}
// *********************************************************************//
  ISafeDistList = interface(_ISafeItem)
    ['{EBB4EBA9-D546-4C85-A05A-167BF875FB83}']
    function GetMember(Index: Integer): ISafeRecipient; safecall;
    procedure AddMember(Recipient: OleVariant); safecall;
    procedure AddMembers(Recipients: OleVariant); safecall;
    procedure RemoveMember(Recipient: OleVariant); safecall;
    procedure RemoveMembers(Recipients: OleVariant); safecall;
    function Get_MemberCount: Integer; safecall;
    procedure RemoveMemberEx(Index: Integer); safecall;
    function AddMemberEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant): ISafeRecipient; safecall;
    property MemberCount: Integer read Get_MemberCount;
  end;

// *********************************************************************//
// DispIntf:  ISafeDistListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EBB4EBA9-D546-4C85-A05A-167BF875FB83}
// *********************************************************************//
  ISafeDistListDisp = dispinterface
    ['{EBB4EBA9-D546-4C85-A05A-167BF875FB83}']
    function GetMember(Index: Integer): ISafeRecipient; dispid 63749;
    procedure AddMember(Recipient: OleVariant); dispid 64140;
    procedure AddMembers(Recipients: OleVariant); dispid 63744;
    procedure RemoveMember(Recipient: OleVariant); dispid 64141;
    procedure RemoveMembers(Recipients: OleVariant); dispid 63745;
    property MemberCount: Integer readonly dispid 32843;
    procedure RemoveMemberEx(Index: Integer); dispid 2;
    function AddMemberEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant): ISafeRecipient; dispid 3;
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: IAddressLists
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {86797248-1A4E-41D0-A0C3-2175A36B3D0E}
// *********************************************************************//
  IAddressLists = interface(IDispatch)
    ['{86797248-1A4E-41D0-A0C3-2175A36B3D0E}']
    function Item(Index: OleVariant): IAddressList; safecall;
    function Get_Count: Integer; safecall;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IAddressListsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {86797248-1A4E-41D0-A0C3-2175A36B3D0E}
// *********************************************************************//
  IAddressListsDisp = dispinterface
    ['{86797248-1A4E-41D0-A0C3-2175A36B3D0E}']
    function Item(Index: OleVariant): IAddressList; dispid 0;
    property Count: Integer readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IAddressList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {38F95B22-32BF-4378-B3EC-47B2C09DE1F5}
// *********************************************************************//
  IAddressList = interface(_IBaseItem)
    ['{38F95B22-32BF-4378-B3EC-47B2C09DE1F5}']
    function Get_AddressEntries: IAddressEntries; safecall;
    function Get_IsReadOnly: WordBool; safecall;
    function Get_ID: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    property AddressEntries: IAddressEntries read Get_AddressEntries;
    property IsReadOnly: WordBool read Get_IsReadOnly;
    property ID: WideString read Get_ID;
    property Name: WideString read Get_Name;
    property Default: WordBool read Get_Default write Set_Default;
  end;

// *********************************************************************//
// DispIntf:  IAddressListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {38F95B22-32BF-4378-B3EC-47B2C09DE1F5}
// *********************************************************************//
  IAddressListDisp = dispinterface
    ['{38F95B22-32BF-4378-B3EC-47B2C09DE1F5}']
    property AddressEntries: IAddressEntries readonly dispid 2;
    property IsReadOnly: WordBool readonly dispid 3;
    property ID: WideString readonly dispid 4;
    property Name: WideString readonly dispid 5;
    property Default: WordBool dispid 1;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeItems
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D80AC53D-E102-4A55-A265-529A626515E5}
// *********************************************************************//
  ISafeItems = interface(IDispatch)
    ['{D80AC53D-E102-4A55-A265-529A626515E5}']
    function Get_Application: IDispatch; safecall;
    function Get_Class_: Integer; safecall;
    function Get_Count: Integer; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IDispatch; safecall;
    function Add(Type_: OleVariant): IMessageItem; safecall;
    function GetFirst: IDispatch; safecall;
    function GetLast: IDispatch; safecall;
    function GetNext: IDispatch; safecall;
    function GetPrevious: IDispatch; safecall;
    function Item(Index: OleVariant): IMessageItem; safecall;
    procedure Remove(Index: Integer); safecall;
    function _Item(Index: OleVariant): IMessageItem; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Count: Integer read Get_Count;
    property Parent: IDispatch read Get_Parent;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IDispatch read Get_Session;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  ISafeItemsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D80AC53D-E102-4A55-A265-529A626515E5}
// *********************************************************************//
  ISafeItemsDisp = dispinterface
    ['{D80AC53D-E102-4A55-A265-529A626515E5}']
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Count: Integer readonly dispid 80;
    property Parent: IDispatch readonly dispid 61441;
    property RawTable: IUnknown readonly dispid 90;
    property Session: IDispatch readonly dispid 61451;
    function Add(Type_: OleVariant): IMessageItem; dispid 95;
    function GetFirst: IDispatch; dispid 86;
    function GetLast: IDispatch; dispid 88;
    function GetNext: IDispatch; dispid 87;
    function GetPrevious: IDispatch; dispid 89;
    function Item(Index: OleVariant): IMessageItem; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
    function _Item(Index: OleVariant): IMessageItem; dispid 0;
    property MAPITable: _IMAPITable readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IMessageItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C18D120C-B7AB-4499-8BDC-0CD2BD0861FD}
// *********************************************************************//
  IMessageItem = interface(IDispatch)
    ['{C18D120C-B7AB-4499-8BDC-0CD2BD0861FD}']
    function Get_Application: IDispatch; safecall;
    function Get_Attachments: IAttachments; safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Res: OleVariant); safecall;
    function Get_BCC: WideString; safecall;
    function Get_Body: WideString; safecall;
    procedure Set_Body(const Value: WideString); safecall;
    function Get_CC: WideString; safecall;
    function Get_Class_: Integer; safecall;
    function Get_CreationTime: TDateTime; safecall;
    function Get_DeferredDeliveryTime: TDateTime; safecall;
    procedure Set_DeferredDeliveryTime(Value: TDateTime); safecall;
    function Get_DeleteAfterSubmit: WordBool; safecall;
    procedure Set_DeleteAfterSubmit(Value: WordBool); safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Importance: Integer; safecall;
    procedure Set_Importance(Value: Integer); safecall;
    function Get_LastModificationTime: TDateTime; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    function Get_MessageClass: WideString; safecall;
    procedure Set_MessageClass(const Value: WideString); safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_ReceivedTime: TDateTime; safecall;
    function Get_Recipients: ISafeRecipients; safecall;
    function Get_SenderName: WideString; safecall;
    function Get_Sent: WordBool; safecall;
    function Get_SentOn: TDateTime; safecall;
    function Get_Session: IDispatch; safecall;
    function Get_Size: Integer; safecall;
    function Get_Subject: WideString; safecall;
    procedure Set_Subject(const Value: WideString); safecall;
    function Get_Submitted: WordBool; safecall;
    function Get_To_: WideString; safecall;
    function Get_UnRead: WordBool; safecall;
    procedure Set_UnRead(Value: WordBool); safecall;
    procedure Save; safecall;
    procedure Delete; safecall;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; safecall;
    function Get_ReplyRecipients: ISafeRecipients; safecall;
    function Get_Version: WideString; safecall;
    procedure Send; safecall;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); safecall;
    function Get_Sender: IAddressEntry; safecall;
    function Get__Deprecated1: WideString; safecall;
    procedure Import(const Path: WideString; Type_: Integer); safecall;
    function Get_HTMLBody: WideString; safecall;
    procedure Set_HTMLBody(const Value: WideString); safecall;
    procedure CopyTo(Item: OleVariant); safecall;
    function Get_BodyFormat: Integer; safecall;
    procedure Set_BodyFormat(Value: Integer); safecall;
    function Get_RTFBody: WideString; safecall;
    procedure Set_RTFBody(const Value: WideString); safecall;
    property Application: IDispatch read Get_Application;
    property Attachments: IAttachments read Get_Attachments;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property BCC: WideString read Get_BCC;
    property Body: WideString read Get_Body write Set_Body;
    property CC: WideString read Get_CC;
    property Class_: Integer read Get_Class_;
    property CreationTime: TDateTime read Get_CreationTime;
    property DeferredDeliveryTime: TDateTime read Get_DeferredDeliveryTime write Set_DeferredDeliveryTime;
    property DeleteAfterSubmit: WordBool read Get_DeleteAfterSubmit write Set_DeleteAfterSubmit;
    property EntryID: WideString read Get_EntryID;
    property Importance: Integer read Get_Importance write Set_Importance;
    property LastModificationTime: TDateTime read Get_LastModificationTime;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT;
    property MessageClass: WideString read Get_MessageClass write Set_MessageClass;
    property Parent: IDispatch read Get_Parent;
    property ReceivedTime: TDateTime read Get_ReceivedTime;
    property Recipients: ISafeRecipients read Get_Recipients;
    property SenderName: WideString read Get_SenderName;
    property Sent: WordBool read Get_Sent;
    property SentOn: TDateTime read Get_SentOn;
    property Session: IDispatch read Get_Session;
    property Size: Integer read Get_Size;
    property Subject: WideString read Get_Subject write Set_Subject;
    property Submitted: WordBool read Get_Submitted;
    property To_: WideString read Get_To_;
    property UnRead: WordBool read Get_UnRead write Set_UnRead;
    property ReplyRecipients: ISafeRecipients read Get_ReplyRecipients;
    property Version: WideString read Get_Version;
    property Sender: IAddressEntry read Get_Sender;
    property _Deprecated1: WideString read Get__Deprecated1;
    property HTMLBody: WideString read Get_HTMLBody write Set_HTMLBody;
    property BodyFormat: Integer read Get_BodyFormat write Set_BodyFormat;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
  end;

// *********************************************************************//
// DispIntf:  IMessageItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C18D120C-B7AB-4499-8BDC-0CD2BD0861FD}
// *********************************************************************//
  IMessageItemDisp = dispinterface
    ['{C18D120C-B7AB-4499-8BDC-0CD2BD0861FD}']
    property Application: IDispatch readonly dispid 1;
    property Attachments: IAttachments readonly dispid 2;
    property Fields[PropTag: Integer]: OleVariant dispid 3;
    property BCC: WideString readonly dispid 4;
    property Body: WideString dispid 5;
    property CC: WideString readonly dispid 6;
    property Class_: Integer readonly dispid 7;
    property CreationTime: TDateTime readonly dispid 8;
    property DeferredDeliveryTime: TDateTime dispid 9;
    property DeleteAfterSubmit: WordBool dispid 10;
    property EntryID: WideString readonly dispid 11;
    property Importance: Integer dispid 12;
    property LastModificationTime: TDateTime readonly dispid 13;
    property MAPIOBJECT: IUnknown readonly dispid 14;
    property MessageClass: WideString dispid 15;
    property Parent: IDispatch readonly dispid 16;
    property ReceivedTime: TDateTime readonly dispid 17;
    property Recipients: ISafeRecipients readonly dispid 18;
    property SenderName: WideString readonly dispid 19;
    property Sent: WordBool readonly dispid 20;
    property SentOn: TDateTime readonly dispid 21;
    property Session: IDispatch readonly dispid 22;
    property Size: Integer readonly dispid 23;
    property Subject: WideString dispid 24;
    property Submitted: WordBool readonly dispid 25;
    property To_: WideString readonly dispid 26;
    property UnRead: WordBool dispid 27;
    procedure Save; dispid 28;
    procedure Delete; dispid 29;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 30;
    property ReplyRecipients: ISafeRecipients readonly dispid 31;
    property Version: WideString readonly dispid 32;
    procedure Send; dispid 33;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 34;
    property Sender: IAddressEntry readonly dispid 36;
    property _Deprecated1: WideString readonly dispid 62468;
    procedure Import(const Path: WideString; Type_: Integer); dispid 35;
    property HTMLBody: WideString dispid 37;
    procedure CopyTo(Item: OleVariant); dispid 38;
    property BodyFormat: Integer dispid 39;
    property RTFBody: WideString dispid 40;
  end;

// *********************************************************************//
// Interface: _IMAPITable
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}
// *********************************************************************//
  _IMAPITable = interface(IDispatch)
    ['{6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}']
    function Get_Item: IUnknown; safecall;
    procedure Set_Item(const Value: IUnknown); safecall;
    function Get_RowCount: Integer; safecall;
    function Get_Columns: OleVariant; safecall;
    procedure Set_Columns(Value: OleVariant); safecall;
    procedure GoToFirst; safecall;
    procedure GoToLast; safecall;
    procedure GoTo_(Index: Integer); safecall;
    function GetRow: OleVariant; safecall;
    function GetRows(Count: Integer): OleVariant; safecall;
    function Get_Filter: ITableFilter; safecall;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); safecall;
    function Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function ExecSQL(const SQLCommand: WideString): IDispatch; safecall;
    property Item: IUnknown read Get_Item write Set_Item;
    property RowCount: Integer read Get_RowCount;
    property Columns: OleVariant read Get_Columns write Set_Columns;
    property Filter: ITableFilter read Get_Filter;
    property Position: Integer read Get_Position write Set_Position;
  end;

// *********************************************************************//
// DispIntf:  _IMAPITableDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}
// *********************************************************************//
  _IMAPITableDisp = dispinterface
    ['{6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}']
    property Item: IUnknown dispid 1;
    property RowCount: Integer readonly dispid 2;
    property Columns: OleVariant dispid 3;
    procedure GoToFirst; dispid 4;
    procedure GoToLast; dispid 5;
    procedure GoTo_(Index: Integer); dispid 6;
    function GetRow: OleVariant; dispid 7;
    function GetRows(Count: Integer): OleVariant; dispid 8;
    property Filter: ITableFilter readonly dispid 9;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); dispid 10;
    property Position: Integer dispid 11;
    function ExecSQL(const SQLCommand: WideString): IDispatch; dispid 1610743822;
  end;

// *********************************************************************//
// Interface: IDeletedItems
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FFBBDECE-4363-4B4D-B35E-39EFF228C723}
// *********************************************************************//
  IDeletedItems = interface(ISafeItems)
    ['{FFBBDECE-4363-4B4D-B35E-39EFF228C723}']
    procedure Restore(Index: OleVariant); safecall;
  end;

// *********************************************************************//
// DispIntf:  IDeletedItemsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FFBBDECE-4363-4B4D-B35E-39EFF228C723}
// *********************************************************************//
  IDeletedItemsDisp = dispinterface
    ['{FFBBDECE-4363-4B4D-B35E-39EFF228C723}']
    procedure Restore(Index: OleVariant); dispid 2;
    property Application: IDispatch readonly dispid 61440;
    property Class_: Integer readonly dispid 61450;
    property Count: Integer readonly dispid 80;
    property Parent: IDispatch readonly dispid 61441;
    property RawTable: IUnknown readonly dispid 90;
    property Session: IDispatch readonly dispid 61451;
    function Add(Type_: OleVariant): IMessageItem; dispid 95;
    function GetFirst: IDispatch; dispid 86;
    function GetLast: IDispatch; dispid 88;
    function GetNext: IDispatch; dispid 87;
    function GetPrevious: IDispatch; dispid 89;
    function Item(Index: OleVariant): IMessageItem; dispid 81;
    procedure Remove(Index: Integer); dispid 84;
    function _Item(Index: OleVariant): IMessageItem; dispid 0;
    property MAPITable: _IMAPITable readonly dispid 1;
  end;

// *********************************************************************//
// Interface: _IRestriction
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {45128C11-A7E5-46D2-A164-3D1273E92C44}
// *********************************************************************//
  _IRestriction = interface(IDispatch)
    ['{45128C11-A7E5-46D2-A164-3D1273E92C44}']
    function Get_Kind: RestrictionKind; safecall;
    property Kind: RestrictionKind read Get_Kind;
  end;

// *********************************************************************//
// DispIntf:  _IRestrictionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {45128C11-A7E5-46D2-A164-3D1273E92C44}
// *********************************************************************//
  _IRestrictionDisp = dispinterface
    ['{45128C11-A7E5-46D2-A164-3D1273E92C44}']
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: _IRestrictionCollection
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {919DF860-D321-4D02-AC3D-1C25EFAE551A}
// *********************************************************************//
  _IRestrictionCollection = interface(_IRestriction)
    ['{919DF860-D321-4D02-AC3D-1C25EFAE551A}']
    function Get_Count: Integer; safecall;
    function Add(Kind: RestrictionKind): _IRestriction; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure Clear; safecall;
    function Get__Item(Index: Integer): _IRestriction; safecall;
    function Item(Index: Integer): _IRestriction; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: _IRestriction read Get__Item; default;
  end;

// *********************************************************************//
// DispIntf:  _IRestrictionCollectionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {919DF860-D321-4D02-AC3D-1C25EFAE551A}
// *********************************************************************//
  _IRestrictionCollectionDisp = dispinterface
    ['{919DF860-D321-4D02-AC3D-1C25EFAE551A}']
    property Count: Integer readonly dispid 10;
    function Add(Kind: RestrictionKind): _IRestriction; dispid 2;
    procedure Delete(Index: Integer); dispid 3;
    procedure Clear; dispid 4;
    property _Item[Index: Integer]: _IRestriction readonly dispid 0; default;
    function Item(Index: Integer): _IRestriction; dispid 6;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionAnd
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60E5F55E-236F-422D-A5F9-560F1778CCD4}
// *********************************************************************//
  IRestrictionAnd = interface(_IRestrictionCollection)
    ['{60E5F55E-236F-422D-A5F9-560F1778CCD4}']
  end;

// *********************************************************************//
// DispIntf:  IRestrictionAndDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60E5F55E-236F-422D-A5F9-560F1778CCD4}
// *********************************************************************//
  IRestrictionAndDisp = dispinterface
    ['{60E5F55E-236F-422D-A5F9-560F1778CCD4}']
    property Count: Integer readonly dispid 10;
    function Add(Kind: RestrictionKind): _IRestriction; dispid 2;
    procedure Delete(Index: Integer); dispid 3;
    procedure Clear; dispid 4;
    property _Item[Index: Integer]: _IRestriction readonly dispid 0; default;
    function Item(Index: Integer): _IRestriction; dispid 6;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionBitmask
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C52D8C84-C5DD-457B-993B-04E997B330E5}
// *********************************************************************//
  IRestrictionBitmask = interface(_IRestriction)
    ['{C52D8C84-C5DD-457B-993B-04E997B330E5}']
    function Get_relBMR: BitmaskBMR; safecall;
    procedure Set_relBMR(Value: BitmaskBMR); safecall;
    function Get_ulPropTag: Integer; safecall;
    procedure Set_ulPropTag(Value: Integer); safecall;
    function Get_ulMask: Integer; safecall;
    procedure Set_ulMask(Value: Integer); safecall;
    property relBMR: BitmaskBMR read Get_relBMR write Set_relBMR;
    property ulPropTag: Integer read Get_ulPropTag write Set_ulPropTag;
    property ulMask: Integer read Get_ulMask write Set_ulMask;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionBitmaskDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C52D8C84-C5DD-457B-993B-04E997B330E5}
// *********************************************************************//
  IRestrictionBitmaskDisp = dispinterface
    ['{C52D8C84-C5DD-457B-993B-04E997B330E5}']
    property relBMR: BitmaskBMR dispid 10;
    property ulPropTag: Integer dispid 2;
    property ulMask: Integer dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionCompareProps
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2D91877A-468C-4802-8CD7-21F6BF776790}
// *********************************************************************//
  IRestrictionCompareProps = interface(_IRestriction)
    ['{2D91877A-468C-4802-8CD7-21F6BF776790}']
    function Get_relop: PropsRelop; safecall;
    procedure Set_relop(Value: PropsRelop); safecall;
    function Get_ulPropTag1: Integer; safecall;
    procedure Set_ulPropTag1(Value: Integer); safecall;
    function Get_ulPropTag2: Integer; safecall;
    procedure Set_ulPropTag2(Value: Integer); safecall;
    property relop: PropsRelop read Get_relop write Set_relop;
    property ulPropTag1: Integer read Get_ulPropTag1 write Set_ulPropTag1;
    property ulPropTag2: Integer read Get_ulPropTag2 write Set_ulPropTag2;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionComparePropsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2D91877A-468C-4802-8CD7-21F6BF776790}
// *********************************************************************//
  IRestrictionComparePropsDisp = dispinterface
    ['{2D91877A-468C-4802-8CD7-21F6BF776790}']
    property relop: PropsRelop dispid 10;
    property ulPropTag1: Integer dispid 2;
    property ulPropTag2: Integer dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionContent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AA6CCB5D-0F97-4A37-A077-8B49FB5BC60D}
// *********************************************************************//
  IRestrictionContent = interface(_IRestriction)
    ['{AA6CCB5D-0F97-4A37-A077-8B49FB5BC60D}']
    function Get_ulFuzzyLevel: ContentFuzzyLevel; safecall;
    procedure Set_ulFuzzyLevel(Value: ContentFuzzyLevel); safecall;
    function Get_ulPropTag: Integer; safecall;
    procedure Set_ulPropTag(Value: Integer); safecall;
    function Get_lpProp: OleVariant; safecall;
    procedure Set_lpProp(Value: OleVariant); safecall;
    property ulFuzzyLevel: ContentFuzzyLevel read Get_ulFuzzyLevel write Set_ulFuzzyLevel;
    property ulPropTag: Integer read Get_ulPropTag write Set_ulPropTag;
    property lpProp: OleVariant read Get_lpProp write Set_lpProp;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionContentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AA6CCB5D-0F97-4A37-A077-8B49FB5BC60D}
// *********************************************************************//
  IRestrictionContentDisp = dispinterface
    ['{AA6CCB5D-0F97-4A37-A077-8B49FB5BC60D}']
    property ulFuzzyLevel: ContentFuzzyLevel dispid 10;
    property ulPropTag: Integer dispid 2;
    property lpProp: OleVariant dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionExist
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6CDD1F89-FC3B-401C-B1F1-932C48F45EB5}
// *********************************************************************//
  IRestrictionExist = interface(_IRestriction)
    ['{6CDD1F89-FC3B-401C-B1F1-932C48F45EB5}']
    function Get_ulPropTag: Integer; safecall;
    procedure Set_ulPropTag(Value: Integer); safecall;
    property ulPropTag: Integer read Get_ulPropTag write Set_ulPropTag;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionExistDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6CDD1F89-FC3B-401C-B1F1-932C48F45EB5}
// *********************************************************************//
  IRestrictionExistDisp = dispinterface
    ['{6CDD1F89-FC3B-401C-B1F1-932C48F45EB5}']
    property ulPropTag: Integer dispid 10;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionNot
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2B539D9C-127A-4F10-855F-EF31C83D2007}
// *********************************************************************//
  IRestrictionNot = interface(_IRestriction)
    ['{2B539D9C-127A-4F10-855F-EF31C83D2007}']
    function Get_Restriction: _IRestriction; safecall;
    function SetKind(Kind: RestrictionKind): _IRestriction; safecall;
    property Restriction: _IRestriction read Get_Restriction;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionNotDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2B539D9C-127A-4F10-855F-EF31C83D2007}
// *********************************************************************//
  IRestrictionNotDisp = dispinterface
    ['{2B539D9C-127A-4F10-855F-EF31C83D2007}']
    property Restriction: _IRestriction readonly dispid 10;
    function SetKind(Kind: RestrictionKind): _IRestriction; dispid 2;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionOr
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {278EAD7A-2A45-4D4E-ACB4-A1A4AD9BB54B}
// *********************************************************************//
  IRestrictionOr = interface(_IRestrictionCollection)
    ['{278EAD7A-2A45-4D4E-ACB4-A1A4AD9BB54B}']
  end;

// *********************************************************************//
// DispIntf:  IRestrictionOrDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {278EAD7A-2A45-4D4E-ACB4-A1A4AD9BB54B}
// *********************************************************************//
  IRestrictionOrDisp = dispinterface
    ['{278EAD7A-2A45-4D4E-ACB4-A1A4AD9BB54B}']
    property Count: Integer readonly dispid 10;
    function Add(Kind: RestrictionKind): _IRestriction; dispid 2;
    procedure Delete(Index: Integer); dispid 3;
    procedure Clear; dispid 4;
    property _Item[Index: Integer]: _IRestriction readonly dispid 0; default;
    function Item(Index: Integer): _IRestriction; dispid 6;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionProperty
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D177BA8-BF8C-45E2-8CA2-20ACA6269A68}
// *********************************************************************//
  IRestrictionProperty = interface(_IRestriction)
    ['{3D177BA8-BF8C-45E2-8CA2-20ACA6269A68}']
    function Get_relop: PropsRelop; safecall;
    procedure Set_relop(Value: PropsRelop); safecall;
    function Get_ulPropTag: Integer; safecall;
    procedure Set_ulPropTag(Value: Integer); safecall;
    function Get_lpProp: OleVariant; safecall;
    procedure Set_lpProp(Value: OleVariant); safecall;
    property relop: PropsRelop read Get_relop write Set_relop;
    property ulPropTag: Integer read Get_ulPropTag write Set_ulPropTag;
    property lpProp: OleVariant read Get_lpProp write Set_lpProp;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionPropertyDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D177BA8-BF8C-45E2-8CA2-20ACA6269A68}
// *********************************************************************//
  IRestrictionPropertyDisp = dispinterface
    ['{3D177BA8-BF8C-45E2-8CA2-20ACA6269A68}']
    property relop: PropsRelop dispid 10;
    property ulPropTag: Integer dispid 2;
    property lpProp: OleVariant dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionSize
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E16F1874-C5B1-4400-A9F0-08E7FD4D3F8C}
// *********************************************************************//
  IRestrictionSize = interface(_IRestriction)
    ['{E16F1874-C5B1-4400-A9F0-08E7FD4D3F8C}']
    function Get_relop: PropsRelop; safecall;
    procedure Set_relop(Value: PropsRelop); safecall;
    function Get_ulPropTag: Integer; safecall;
    procedure Set_ulPropTag(Value: Integer); safecall;
    function Get_cb: Integer; safecall;
    procedure Set_cb(Value: Integer); safecall;
    property relop: PropsRelop read Get_relop write Set_relop;
    property ulPropTag: Integer read Get_ulPropTag write Set_ulPropTag;
    property cb: Integer read Get_cb write Set_cb;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionSizeDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E16F1874-C5B1-4400-A9F0-08E7FD4D3F8C}
// *********************************************************************//
  IRestrictionSizeDisp = dispinterface
    ['{E16F1874-C5B1-4400-A9F0-08E7FD4D3F8C}']
    property relop: PropsRelop dispid 10;
    property ulPropTag: Integer dispid 2;
    property cb: Integer dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IRestrictionSub
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {62B6A513-3764-42CD-8410-9B81E8DFF135}
// *********************************************************************//
  IRestrictionSub = interface(_IRestriction)
    ['{62B6A513-3764-42CD-8410-9B81E8DFF135}']
    function Get_Restriction: _IRestriction; safecall;
    function SetKind(Kind: RestrictionKind): _IRestriction; safecall;
    function Get_ulSubObject: SubRestrictionProp; safecall;
    procedure Set_ulSubObject(Value: SubRestrictionProp); safecall;
    property Restriction: _IRestriction read Get_Restriction;
    property ulSubObject: SubRestrictionProp read Get_ulSubObject write Set_ulSubObject;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionSubDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {62B6A513-3764-42CD-8410-9B81E8DFF135}
// *********************************************************************//
  IRestrictionSubDisp = dispinterface
    ['{62B6A513-3764-42CD-8410-9B81E8DFF135}']
    property Restriction: _IRestriction readonly dispid 10;
    function SetKind(Kind: RestrictionKind): _IRestriction; dispid 2;
    property ulSubObject: SubRestrictionProp dispid 3;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: ITableFilter
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0B8EDB8D-4575-4942-9C34-55591E415909}
// *********************************************************************//
  ITableFilter = interface(IDispatch)
    ['{0B8EDB8D-4575-4942-9C34-55591E415909}']
    procedure Clear; safecall;
    function SetKind(Kind: RestrictionKind): _IRestriction; safecall;
    function Get_Restriction: _IRestriction; safecall;
    procedure Restrict; safecall;
    function FindFirst(Forward: WordBool): WordBool; safecall;
    function FindLast(Forward: WordBool): WordBool; safecall;
    function FindNext(Forward: WordBool): WordBool; safecall;
    property Restriction: _IRestriction read Get_Restriction;
  end;

// *********************************************************************//
// DispIntf:  ITableFilterDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0B8EDB8D-4575-4942-9C34-55591E415909}
// *********************************************************************//
  ITableFilterDisp = dispinterface
    ['{0B8EDB8D-4575-4942-9C34-55591E415909}']
    procedure Clear; dispid 1;
    function SetKind(Kind: RestrictionKind): _IRestriction; dispid 2;
    property Restriction: _IRestriction readonly dispid 3;
    procedure Restrict; dispid 4;
    function FindFirst(Forward: WordBool): WordBool; dispid 5;
    function FindLast(Forward: WordBool): WordBool; dispid 6;
    function FindNext(Forward: WordBool): WordBool; dispid 7;
  end;

// *********************************************************************//
// Interface: INamedProperty
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E1392BB-3B66-4A39-BBD0-259FC2BDC979}
// *********************************************************************//
  INamedProperty = interface(IDispatch)
    ['{3E1392BB-3B66-4A39-BBD0-259FC2BDC979}']
    function Get_GUID: WideString; safecall;
    function Get_ID: OleVariant; safecall;
    property GUID: WideString read Get_GUID;
    property ID: OleVariant read Get_ID;
  end;

// *********************************************************************//
// DispIntf:  INamedPropertyDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E1392BB-3B66-4A39-BBD0-259FC2BDC979}
// *********************************************************************//
  INamedPropertyDisp = dispinterface
    ['{3E1392BB-3B66-4A39-BBD0-259FC2BDC979}']
    property GUID: WideString readonly dispid 1;
    property ID: OleVariant readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IPropList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7EE495F3-345B-4CC1-AAB7-A255ED85EED2}
// *********************************************************************//
  IPropList = interface(IDispatch)
    ['{7EE495F3-345B-4CC1-AAB7-A255ED85EED2}']
    function Get_Count: Integer; safecall;
    function Get_Item(Index: Integer): Integer; safecall;
    property Count: Integer read Get_Count;
    property Item[Index: Integer]: Integer read Get_Item; default;
  end;

// *********************************************************************//
// DispIntf:  IPropListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7EE495F3-345B-4CC1-AAB7-A255ED85EED2}
// *********************************************************************//
  IPropListDisp = dispinterface
    ['{7EE495F3-345B-4CC1-AAB7-A255ED85EED2}']
    property Count: Integer readonly dispid 1;
    property Item[Index: Integer]: Integer readonly dispid 0; default;
  end;

// *********************************************************************//
// Interface: ISafeReportItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03C3860D-86B7-4F36-924C-3B1AD93B4C79}
// *********************************************************************//
  ISafeReportItem = interface(_ISafeItem)
    ['{03C3860D-86B7-4F36-924C-3B1AD93B4C79}']
  end;

// *********************************************************************//
// DispIntf:  ISafeReportItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03C3860D-86B7-4F36-924C-3B1AD93B4C79}
// *********************************************************************//
  ISafeReportItemDisp = dispinterface
    ['{03C3860D-86B7-4F36-924C-3B1AD93B4C79}']
    property RTFBody: WideString dispid 12245935;
    procedure Send; dispid 61557;
    property Recipients: ISafeRecipients readonly dispid 63508;
    property Attachments: IAttachments readonly dispid 63509;
    property AuthKey: WideString writeonly dispid 1;
    procedure Import(const Path: WideString; Type_: Integer); dispid 12245936;
    property Body: WideString dispid 37120;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 61521;
    property Sender: IAddressEntry readonly dispid 12245930;
    procedure CopyTo(Item: OleVariant); dispid 12245938;
    property Item: IDispatch dispid 12245934;
    property Fields[PropTag: Integer]: OleVariant dispid 12245937;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 12245933;
    property Version: WideString readonly dispid 12245939;
  end;

// *********************************************************************//
// Interface: ISafeInspector
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}
// *********************************************************************//
  ISafeInspector = interface(IDispatch)
    ['{6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}']
    function Get_Item: IDispatch; safecall;
    procedure Set_Item(const Value: IDispatch); safecall;
    function Get_HTMLEditor: IDispatch; safecall;
    function Get_WordEditor: IDispatch; safecall;
    function Get_SelText: WideString; safecall;
    procedure Set_SelText(const Value: WideString); safecall;
    function Get_PlainTextEditor: IPlainTextEditor; safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_RTFEditor: IRTFEditor; safecall;
    property Item: IDispatch read Get_Item write Set_Item;
    property HTMLEditor: IDispatch read Get_HTMLEditor;
    property WordEditor: IDispatch read Get_WordEditor;
    property SelText: WideString read Get_SelText write Set_SelText;
    property PlainTextEditor: IPlainTextEditor read Get_PlainTextEditor;
    property Text: WideString read Get_Text write Set_Text;
    property RTFEditor: IRTFEditor read Get_RTFEditor;
  end;

// *********************************************************************//
// DispIntf:  ISafeInspectorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}
// *********************************************************************//
  ISafeInspectorDisp = dispinterface
    ['{6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}']
    property Item: IDispatch dispid 12245934;
    property HTMLEditor: IDispatch readonly dispid 8462;
    property WordEditor: IDispatch readonly dispid 8463;
    property SelText: WideString dispid 3;
    property PlainTextEditor: IPlainTextEditor readonly dispid 4;
    property Text: WideString dispid 5;
    property RTFEditor: IRTFEditor readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IPlainTextEditor
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {52EB94F3-545B-4EF0-BEE7-50537E704EFB}
// *********************************************************************//
  IPlainTextEditor = interface(IDispatch)
    ['{52EB94F3-545B-4EF0-BEE7-50537E704EFB}']
    procedure Clear; safecall;
    procedure ClearSelection; safecall;
    procedure ClearUndo; safecall;
    procedure CopyToClipboard; safecall;
    procedure CutToClipboard; safecall;
    procedure PasteFromClipboard; safecall;
    procedure SelectAll; safecall;
    procedure Undo; safecall;
    function Get_CaretPosX: Integer; safecall;
    procedure Set_CaretPosX(Value: Integer); safecall;
    function Get_CaretPosY: Integer; safecall;
    procedure Set_CaretPosY(Value: Integer); safecall;
    function Get_CanUndo: WordBool; safecall;
    function Get_HideSelection: WordBool; safecall;
    procedure Set_HideSelection(Value: WordBool); safecall;
    function Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function Get_SelLength: Integer; safecall;
    procedure Set_SelLength(Value: Integer); safecall;
    function Get_SelStart: Integer; safecall;
    procedure Set_SelStart(Value: Integer); safecall;
    function Get_SelText: WideString; safecall;
    procedure Set_SelText(const Value: WideString); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Handle: OLE_HANDLE; safecall;
    property CaretPosX: Integer read Get_CaretPosX write Set_CaretPosX;
    property CaretPosY: Integer read Get_CaretPosY write Set_CaretPosY;
    property CanUndo: WordBool read Get_CanUndo;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
    property Handle: OLE_HANDLE read Get_Handle;
  end;

// *********************************************************************//
// DispIntf:  IPlainTextEditorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {52EB94F3-545B-4EF0-BEE7-50537E704EFB}
// *********************************************************************//
  IPlainTextEditorDisp = dispinterface
    ['{52EB94F3-545B-4EF0-BEE7-50537E704EFB}']
    procedure Clear; dispid 1;
    procedure ClearSelection; dispid 2;
    procedure ClearUndo; dispid 4;
    procedure CopyToClipboard; dispid 5;
    procedure CutToClipboard; dispid 6;
    procedure PasteFromClipboard; dispid 7;
    procedure SelectAll; dispid 8;
    procedure Undo; dispid 9;
    property CaretPosX: Integer dispid 11;
    property CaretPosY: Integer dispid 12;
    property CanUndo: WordBool readonly dispid 16;
    property HideSelection: WordBool dispid 17;
    property ReadOnly: WordBool dispid 19;
    property SelLength: Integer dispid 20;
    property SelStart: Integer dispid 21;
    property SelText: WideString dispid 22;
    property Text: WideString dispid 23;
    property Handle: OLE_HANDLE readonly dispid 100;
  end;

// *********************************************************************//
// Interface: IRTFEditor
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E206FB9D-3F15-4130-A977-3FCAD9CE1188}
// *********************************************************************//
  IRTFEditor = interface(IPlainTextEditor)
    ['{E206FB9D-3F15-4130-A977-3FCAD9CE1188}']
    function Get_RTFSelText: WideString; safecall;
    procedure Set_RTFSelText(const Value: WideString); safecall;
    function Get_RTFText: WideString; safecall;
    procedure Set_RTFText(const Value: WideString); safecall;
    function Get_DefAttributes: ITextAttributes; safecall;
    function Get_SelAttributes: ITextAttributes; safecall;
    function Get_ParagraphAttributes: IParagraphAttributes; safecall;
    property RTFSelText: WideString read Get_RTFSelText write Set_RTFSelText;
    property RTFText: WideString read Get_RTFText write Set_RTFText;
    property DefAttributes: ITextAttributes read Get_DefAttributes;
    property SelAttributes: ITextAttributes read Get_SelAttributes;
    property ParagraphAttributes: IParagraphAttributes read Get_ParagraphAttributes;
  end;

// *********************************************************************//
// DispIntf:  IRTFEditorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E206FB9D-3F15-4130-A977-3FCAD9CE1188}
// *********************************************************************//
  IRTFEditorDisp = dispinterface
    ['{E206FB9D-3F15-4130-A977-3FCAD9CE1188}']
    property RTFSelText: WideString dispid 1000;
    property RTFText: WideString dispid 1001;
    property DefAttributes: ITextAttributes readonly dispid 3;
    property SelAttributes: ITextAttributes readonly dispid 10;
    property ParagraphAttributes: IParagraphAttributes readonly dispid 13;
    procedure Clear; dispid 1;
    procedure ClearSelection; dispid 2;
    procedure ClearUndo; dispid 4;
    procedure CopyToClipboard; dispid 5;
    procedure CutToClipboard; dispid 6;
    procedure PasteFromClipboard; dispid 7;
    procedure SelectAll; dispid 8;
    procedure Undo; dispid 9;
    property CaretPosX: Integer dispid 11;
    property CaretPosY: Integer dispid 12;
    property CanUndo: WordBool readonly dispid 16;
    property HideSelection: WordBool dispid 17;
    property ReadOnly: WordBool dispid 19;
    property SelLength: Integer dispid 20;
    property SelStart: Integer dispid 21;
    property SelText: WideString dispid 22;
    property Text: WideString dispid 23;
    property Handle: OLE_HANDLE readonly dispid 100;
  end;

// *********************************************************************//
// Interface: ITextAttributes
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4D0A6803-18D2-4EAC-BA33-137F10AC8710}
// *********************************************************************//
  ITextAttributes = interface(IDispatch)
    ['{4D0A6803-18D2-4EAC-BA33-137F10AC8710}']
    function Get_Charset: Integer; safecall;
    procedure Set_Charset(Value: Integer); safecall;
    function Get_Color: OLE_COLOR; safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Pitch: FontPitch; safecall;
    procedure Set_Pitch(Value: FontPitch); safecall;
    function Get_Protected_: WordBool; safecall;
    procedure Set_Protected_(Value: WordBool); safecall;
    function Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function Get_Style: IFontStyle; safecall;
    function Get_ConsistentAttributes: IConsistentAttributes; safecall;
    property Charset: Integer read Get_Charset write Set_Charset;
    property Color: OLE_COLOR read Get_Color write Set_Color;
    property Height: Integer read Get_Height write Set_Height;
    property Name: WideString read Get_Name write Set_Name;
    property Pitch: FontPitch read Get_Pitch write Set_Pitch;
    property Protected_: WordBool read Get_Protected_ write Set_Protected_;
    property Size: Integer read Get_Size write Set_Size;
    property Style: IFontStyle read Get_Style;
    property ConsistentAttributes: IConsistentAttributes read Get_ConsistentAttributes;
  end;

// *********************************************************************//
// DispIntf:  ITextAttributesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4D0A6803-18D2-4EAC-BA33-137F10AC8710}
// *********************************************************************//
  ITextAttributesDisp = dispinterface
    ['{4D0A6803-18D2-4EAC-BA33-137F10AC8710}']
    property Charset: Integer dispid 1;
    property Color: OLE_COLOR dispid 2;
    property Height: Integer dispid 3;
    property Name: WideString dispid 4;
    property Pitch: FontPitch dispid 5;
    property Protected_: WordBool dispid 6;
    property Size: Integer dispid 7;
    property Style: IFontStyle readonly dispid 8;
    property ConsistentAttributes: IConsistentAttributes readonly dispid 9;
  end;

// *********************************************************************//
// Interface: IFontStyle
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}
// *********************************************************************//
  IFontStyle = interface(IDispatch)
    ['{7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}']
    function Get_Bold: WordBool; safecall;
    procedure Set_Bold(Value: WordBool); safecall;
    function Get_Italic: WordBool; safecall;
    procedure Set_Italic(Value: WordBool); safecall;
    function Get_Underline: WordBool; safecall;
    procedure Set_Underline(Value: WordBool); safecall;
    function Get_Strikeout: WordBool; safecall;
    procedure Set_Strikeout(Value: WordBool); safecall;
    property Bold: WordBool read Get_Bold write Set_Bold;
    property Italic: WordBool read Get_Italic write Set_Italic;
    property Underline: WordBool read Get_Underline write Set_Underline;
    property Strikeout: WordBool read Get_Strikeout write Set_Strikeout;
  end;

// *********************************************************************//
// DispIntf:  IFontStyleDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}
// *********************************************************************//
  IFontStyleDisp = dispinterface
    ['{7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}']
    property Bold: WordBool dispid 1;
    property Italic: WordBool dispid 2;
    property Underline: WordBool dispid 3;
    property Strikeout: WordBool dispid 4;
  end;

// *********************************************************************//
// Interface: IConsistentAttributes
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CDA81541-363F-4CBF-97FB-FD138F4D102D}
// *********************************************************************//
  IConsistentAttributes = interface(IDispatch)
    ['{CDA81541-363F-4CBF-97FB-FD138F4D102D}']
    function Get_Bold: WordBool; safecall;
    function Get_Color: WordBool; safecall;
    function Get_Face: WordBool; safecall;
    function Get_Italic: WordBool; safecall;
    function Get_Size: WordBool; safecall;
    function Get_Strikeout: WordBool; safecall;
    function Get_Underline: WordBool; safecall;
    function Get_Protected_: WordBool; safecall;
    property Bold: WordBool read Get_Bold;
    property Color: WordBool read Get_Color;
    property Face: WordBool read Get_Face;
    property Italic: WordBool read Get_Italic;
    property Size: WordBool read Get_Size;
    property Strikeout: WordBool read Get_Strikeout;
    property Underline: WordBool read Get_Underline;
    property Protected_: WordBool read Get_Protected_;
  end;

// *********************************************************************//
// DispIntf:  IConsistentAttributesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CDA81541-363F-4CBF-97FB-FD138F4D102D}
// *********************************************************************//
  IConsistentAttributesDisp = dispinterface
    ['{CDA81541-363F-4CBF-97FB-FD138F4D102D}']
    property Bold: WordBool readonly dispid 1;
    property Color: WordBool readonly dispid 2;
    property Face: WordBool readonly dispid 3;
    property Italic: WordBool readonly dispid 4;
    property Size: WordBool readonly dispid 5;
    property Strikeout: WordBool readonly dispid 6;
    property Underline: WordBool readonly dispid 7;
    property Protected_: WordBool readonly dispid 8;
  end;

// *********************************************************************//
// Interface: IParagraphAttributes
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {13FFAB29-AE8F-473C-9F21-5ED4664BE98F}
// *********************************************************************//
  IParagraphAttributes = interface(IDispatch)
    ['{13FFAB29-AE8F-473C-9F21-5ED4664BE98F}']
    function Get_Alignment: TextAlignment; safecall;
    procedure Set_Alignment(Value: TextAlignment); safecall;
    function Get_FirstIndent: Integer; safecall;
    procedure Set_FirstIndent(Value: Integer); safecall;
    function Get_LeftIndent: Integer; safecall;
    procedure Set_LeftIndent(Value: Integer); safecall;
    function Get_RightIndent: Integer; safecall;
    procedure Set_RightIndent(Value: Integer); safecall;
    function Get_Numbering: NumberingStyle; safecall;
    procedure Set_Numbering(Value: NumberingStyle); safecall;
    property Alignment: TextAlignment read Get_Alignment write Set_Alignment;
    property FirstIndent: Integer read Get_FirstIndent write Set_FirstIndent;
    property LeftIndent: Integer read Get_LeftIndent write Set_LeftIndent;
    property RightIndent: Integer read Get_RightIndent write Set_RightIndent;
    property Numbering: NumberingStyle read Get_Numbering write Set_Numbering;
  end;

// *********************************************************************//
// DispIntf:  IParagraphAttributesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {13FFAB29-AE8F-473C-9F21-5ED4664BE98F}
// *********************************************************************//
  IParagraphAttributesDisp = dispinterface
    ['{13FFAB29-AE8F-473C-9F21-5ED4664BE98F}']
    property Alignment: TextAlignment dispid 1;
    property FirstIndent: Integer dispid 2;
    property LeftIndent: Integer dispid 3;
    property RightIndent: Integer dispid 4;
    property Numbering: NumberingStyle dispid 5;
  end;

// *********************************************************************//
// Interface: IRDOSession
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E54C5168-AA8C-405F-9C14-A4037302BD9D}
// *********************************************************************//
  IRDOSession = interface(IDispatch)
    ['{E54C5168-AA8C-405F-9C14-A4037302BD9D}']
    function Get_ProfileName: WideString; safecall;
    function Get_LoggedOn: WordBool; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    procedure Set_MAPIOBJECT(const Value: IUnknown); safecall;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant; ParentWindowHandle: OleVariant; NoMail: OleVariant); safecall;
    procedure LogonExchangeMailbox(const User: WideString; const ServerName: WideString); safecall;
    function Get_Stores: iRDOStores; safecall;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; safecall;
    function Get_AddressBook: IRDOAddressBook; safecall;
    function GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant; 
                              Flags: OleVariant): IRDOMail; safecall;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IRDOFolder; safecall;
    function GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore; safecall;
    function GetAddressEntryFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressEntry; safecall;
    function Get_CurrentUser: IRDOAddressEntry; safecall;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; safecall;
    function GetAddressListFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressList; safecall;
    function GetSharedDefaultFolder(NameOrAddressOrObject: OleVariant; 
                                    rdoDefaultFolder: rdoDefaultFolders): IRDOFolder; safecall;
    function GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore; safecall;
    procedure Logoff; safecall;
    function Get_Accounts: IRDOAccounts; safecall;
    function GetMessageFromMsgFile(const FileName: WideString; CreateNew: WordBool): IRDOMail; safecall;
    procedure Set_AuthKey(const Param1: WideString); safecall;
    function GetFolderFromPath(const FolderPath: WideString): IRDOFolder; safecall;
    function Get_TimeZones: IRDOTimezones; safecall;
    function Get_Profiles: IRDOProfiles; safecall;
    procedure SetLocaleIDs(LocaleID: Integer; CodePageID: Integer); safecall;
    function Get_ExchangeConnectionMode: rdoExchangeConnectionMode; safecall;
    function Get_ExchangeMailboxServerName: WideString; safecall;
    function Get_ExchangeMailboxServerVersion: WideString; safecall;
    function Get_OutlookVersion: WideString; safecall;
    property ProfileName: WideString read Get_ProfileName;
    property LoggedOn: WordBool read Get_LoggedOn;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property Stores: iRDOStores read Get_Stores;
    property AddressBook: IRDOAddressBook read Get_AddressBook;
    property CurrentUser: IRDOAddressEntry read Get_CurrentUser;
    property Accounts: IRDOAccounts read Get_Accounts;
    property AuthKey: WideString write Set_AuthKey;
    property TimeZones: IRDOTimezones read Get_TimeZones;
    property Profiles: IRDOProfiles read Get_Profiles;
    property ExchangeConnectionMode: rdoExchangeConnectionMode read Get_ExchangeConnectionMode;
    property ExchangeMailboxServerName: WideString read Get_ExchangeMailboxServerName;
    property ExchangeMailboxServerVersion: WideString read Get_ExchangeMailboxServerVersion;
    property OutlookVersion: WideString read Get_OutlookVersion;
  end;

// *********************************************************************//
// DispIntf:  IRDOSessionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E54C5168-AA8C-405F-9C14-A4037302BD9D}
// *********************************************************************//
  IRDOSessionDisp = dispinterface
    ['{E54C5168-AA8C-405F-9C14-A4037302BD9D}']
    property ProfileName: WideString readonly dispid 1;
    property LoggedOn: WordBool readonly dispid 2;
    property MAPIOBJECT: IUnknown dispid 3;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant; ParentWindowHandle: OleVariant; NoMail: OleVariant); dispid 4;
    procedure LogonExchangeMailbox(const User: WideString; const ServerName: WideString); dispid 5;
    property Stores: iRDOStores readonly dispid 6;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 7;
    property AddressBook: IRDOAddressBook readonly dispid 8;
    function GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant; 
                              Flags: OleVariant): IRDOMail; dispid 9;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IRDOFolder; dispid 10;
    function GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore; dispid 11;
    function GetAddressEntryFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressEntry; dispid 12;
    property CurrentUser: IRDOAddressEntry readonly dispid 13;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 14;
    function GetAddressListFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressList; dispid 15;
    function GetSharedDefaultFolder(NameOrAddressOrObject: OleVariant; 
                                    rdoDefaultFolder: rdoDefaultFolders): IRDOFolder; dispid 16;
    function GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore; dispid 17;
    procedure Logoff; dispid 18;
    property Accounts: IRDOAccounts readonly dispid 19;
    function GetMessageFromMsgFile(const FileName: WideString; CreateNew: WordBool): IRDOMail; dispid 20;
    property AuthKey: WideString writeonly dispid 21;
    function GetFolderFromPath(const FolderPath: WideString): IRDOFolder; dispid 1610743830;
    property TimeZones: IRDOTimezones readonly dispid 1610743831;
    property Profiles: IRDOProfiles readonly dispid 1610743832;
    procedure SetLocaleIDs(LocaleID: Integer; CodePageID: Integer); dispid 1610743833;
    property ExchangeConnectionMode: rdoExchangeConnectionMode readonly dispid 1610743834;
    property ExchangeMailboxServerName: WideString readonly dispid 1610743835;
    property ExchangeMailboxServerVersion: WideString readonly dispid 1610743836;
    property OutlookVersion: WideString readonly dispid 1610743837;
  end;

// *********************************************************************//
// DispIntf:  IRDOSessionEvents
// Flags:     (4096) Dispatchable
// GUID:      {BFFCC45C-D97E-48A1-9548-6796FA0334EC}
// *********************************************************************//
  IRDOSessionEvents = dispinterface
    ['{BFFCC45C-D97E-48A1-9548-6796FA0334EC}']
    procedure OnNewMail(const EntryID: WideString); dispid 1;
  end;

// *********************************************************************//
// Interface: iRDOStores
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8AE3D19C-C58A-4AF0-94D3-9255F3417E33}
// *********************************************************************//
  iRDOStores = interface(IDispatch)
    ['{8AE3D19C-C58A-4AF0-94D3-9255F3417E33}']
    function Get__Item(Index: OleVariant): IRDOStore; safecall;
    function Item(Index: OleVariant; OpenFlags: OleVariant): IRDOStore; safecall;
    function Get_DefaultStore: IRDOStore; safecall;
    procedure Set_DefaultStore(const Value: IRDOStore); safecall;
    function AddPSTStore(const Path: WideString; Format: OleVariant; DisplayName: OleVariant): IRDOPstStore; safecall;
    function AddDelegateExchangeMailBoxStore(const UserNameOrAddress: WideString): IRDOStore; safecall;
    function FindExchangePublicFoldersStore: IRDOStore; safecall;
    function GetDefaultFolder(rdoDefaultFolder: Integer): IRDOFolder; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Count: Integer; safecall;
    function GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore; safecall;
    function GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function AddPstStoreWithPassword(const Path: WideString; Format: OleVariant; 
                                     DisplayName: OleVariant; Password: OleVariant; 
                                     RememberPassword: OleVariant; Encryption: OleVariant): IRDOPstStore; safecall;
    property _Item[Index: OleVariant]: IRDOStore read Get__Item; default;
    property DefaultStore: IRDOStore read Get_DefaultStore write Set_DefaultStore;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  iRDOStoresDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8AE3D19C-C58A-4AF0-94D3-9255F3417E33}
// *********************************************************************//
  iRDOStoresDisp = dispinterface
    ['{8AE3D19C-C58A-4AF0-94D3-9255F3417E33}']
    property _Item[Index: OleVariant]: IRDOStore readonly dispid 0; default;
    function Item(Index: OleVariant; OpenFlags: OleVariant): IRDOStore; dispid 3;
    property DefaultStore: IRDOStore dispid 4;
    function AddPSTStore(const Path: WideString; Format: OleVariant; DisplayName: OleVariant): IRDOPstStore; dispid 5;
    function AddDelegateExchangeMailBoxStore(const UserNameOrAddress: WideString): IRDOStore; dispid 6;
    function FindExchangePublicFoldersStore: IRDOStore; dispid 7;
    function GetDefaultFolder(rdoDefaultFolder: Integer): IRDOFolder; dispid 9;
    property _NewEnum: IUnknown readonly dispid -4;
    property Count: Integer readonly dispid 2;
    function GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore; dispid 1;
    function GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore; dispid 8;
    property RawTable: IUnknown readonly dispid 10;
    property MAPITable: _IMAPITable readonly dispid 11;
    function AddPstStoreWithPassword(const Path: WideString; Format: OleVariant; 
                                     DisplayName: OleVariant; Password: OleVariant; 
                                     RememberPassword: OleVariant; Encryption: OleVariant): IRDOPstStore; dispid 1610743822;
  end;

// *********************************************************************//
// DispIntf:  IRDOStoresEvents
// Flags:     (4096) Dispatchable
// GUID:      {002DACC3-FE8F-44CE-A877-24BA0CEB9057}
// *********************************************************************//
  IRDOStoresEvents = dispinterface
    ['{002DACC3-FE8F-44CE-A877-24BA0CEB9057}']
    procedure StoreChange(const Store: IRDOStore); dispid 1;
    procedure StoreAdd(const Store: IRDOStore); dispid 2;
    procedure StoreRemove(const InstanceKey: WideString); dispid 3;
    procedure CollectionModified; dispid 4;
  end;

// *********************************************************************//
// Interface: _MAPIProp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {CF7DE094-FF99-4700-B9EF-258A1D23B798}
// *********************************************************************//
  _MAPIProp = interface(IDispatch)
    ['{CF7DE094-FF99-4700-B9EF-258A1D23B798}']
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; safecall;
    function Get_Fields(PropTag: OleVariant): OleVariant; safecall;
    procedure Set_Fields(PropTag: OleVariant; Res: OleVariant); safecall;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; safecall;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; safecall;
    procedure CopyTo(DestObj: OleVariant); safecall;
    procedure Save; safecall;
    function Get_MAPIOBJECT: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    property Fields[PropTag: OleVariant]: OleVariant read Get_Fields write Set_Fields;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT;
    property Session: IRDOSession read Get_Session;
  end;

// *********************************************************************//
// DispIntf:  _MAPIPropDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {CF7DE094-FF99-4700-B9EF-258A1D23B798}
// *********************************************************************//
  _MAPIPropDisp = dispinterface
    ['{CF7DE094-FF99-4700-B9EF-258A1D23B798}']
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOFolder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {15B8597F-0A55-4361-AE8B-1F690BC61EE4}
// *********************************************************************//
  IRDOFolder = interface(_MAPIProp)
    ['{15B8597F-0A55-4361-AE8B-1F690BC61EE4}']
    function Get_DefaultMessageClass: WideString; safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Parent: IRDOFolder; safecall;
    function Get_StoreID: WideString; safecall;
    function Get_UnReadItemCount: Integer; safecall;
    function Get_Items: IRDOItems; safecall;
    function Get_Folders: IRDOFolders; safecall;
    procedure Delete; safecall;
    function MoveTo(const DestinationFolder: IRDOFolder): IRDOFolder; safecall;
    function Get_HiddenItems: IRDOItems; safecall;
    function Get_Store: IRDOStore; safecall;
    function Get_AddressBookName: WideString; safecall;
    procedure Set_AddressBookName(const Value: WideString); safecall;
    function Get_ShowAsOutlookAB: WordBool; safecall;
    procedure Set_ShowAsOutlookAB(Value: WordBool); safecall;
    function Get_DefaultItemType: Integer; safecall;
    function Get_WebViewAllowNavigation: WordBool; safecall;
    procedure Set_WebViewAllowNavigation(Value: WordBool); safecall;
    function Get_WebViewOn: WordBool; safecall;
    procedure Set_WebViewOn(Value: WordBool); safecall;
    function Get_WebViewURL: WideString; safecall;
    procedure Set_WebViewURL(const Value: WideString); safecall;
    function Get_DeletedItems: IRDODeletedItems; safecall;
    function Get_FolderKind: rdoFolderKind; safecall;
    function Get_ACL: IRDOACL; safecall;
    property DefaultMessageClass: WideString read Get_DefaultMessageClass;
    property Description: WideString read Get_Description write Set_Description;
    property EntryID: WideString read Get_EntryID;
    property Name: WideString read Get_Name write Set_Name;
    property Parent: IRDOFolder read Get_Parent;
    property StoreID: WideString read Get_StoreID;
    property UnReadItemCount: Integer read Get_UnReadItemCount;
    property Items: IRDOItems read Get_Items;
    property Folders: IRDOFolders read Get_Folders;
    property HiddenItems: IRDOItems read Get_HiddenItems;
    property Store: IRDOStore read Get_Store;
    property AddressBookName: WideString read Get_AddressBookName write Set_AddressBookName;
    property ShowAsOutlookAB: WordBool read Get_ShowAsOutlookAB write Set_ShowAsOutlookAB;
    property DefaultItemType: Integer read Get_DefaultItemType;
    property WebViewAllowNavigation: WordBool read Get_WebViewAllowNavigation write Set_WebViewAllowNavigation;
    property WebViewOn: WordBool read Get_WebViewOn write Set_WebViewOn;
    property WebViewURL: WideString read Get_WebViewURL write Set_WebViewURL;
    property DeletedItems: IRDODeletedItems read Get_DeletedItems;
    property FolderKind: rdoFolderKind read Get_FolderKind;
    property ACL: IRDOACL read Get_ACL;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {15B8597F-0A55-4361-AE8B-1F690BC61EE4}
// *********************************************************************//
  IRDOFolderDisp = dispinterface
    ['{15B8597F-0A55-4361-AE8B-1F690BC61EE4}']
    property DefaultMessageClass: WideString readonly dispid 7;
    property Description: WideString dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 0;
    property Parent: IRDOFolder readonly dispid 11;
    property StoreID: WideString readonly dispid 12;
    property UnReadItemCount: Integer readonly dispid 13;
    property Items: IRDOItems readonly dispid 17;
    property Folders: IRDOFolders readonly dispid 18;
    procedure Delete; dispid 20;
    function MoveTo(const DestinationFolder: IRDOFolder): IRDOFolder; dispid 21;
    property HiddenItems: IRDOItems readonly dispid 23;
    property Store: IRDOStore readonly dispid 14;
    property AddressBookName: WideString dispid 15;
    property ShowAsOutlookAB: WordBool dispid 16;
    property DefaultItemType: Integer readonly dispid 22;
    property WebViewAllowNavigation: WordBool dispid 25;
    property WebViewOn: WordBool dispid 26;
    property WebViewURL: WideString dispid 27;
    property DeletedItems: IRDODeletedItems readonly dispid 19;
    property FolderKind: rdoFolderKind readonly dispid 124;
    property ACL: IRDOACL readonly dispid 128;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOAddressBook
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3F5393D1-F833-4224-822E-68B3674F30C1}
// *********************************************************************//
  IRDOAddressBook = interface(_MAPIProp)
    ['{3F5393D1-F833-4224-822E-68B3674F30C1}']
    function Get_SearchPath: IRDOAddressBookSearchPath; safecall;
    function AddressLists(ShallowTraversal: OleVariant): IRDOAddressLists; safecall;
    function Get_DefaultAddressList: IRDOAddressList; safecall;
    procedure Set_DefaultAddressList(const Value: IRDOAddressList); safecall;
    function Get_PAB: IRDOAddressList; safecall;
    function Get_GAL: IRDOAddressList; safecall;
    function GetAddressListFromID(const EntryID: WideString): IRDOAddressList; safecall;
    function GetAddressEntryFromID(const EntryID: WideString): IRDOAddressEntry; safecall;
    function ShowAddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                             ForceResolution: OleVariant; RecipLists: OleVariant; 
                             ToLabel: OleVariant; CcLabel: OleVariant; BccLabel: OleVariant; 
                             ParentWindow: OleVariant): IRDORecipients; safecall;
    function ResolveName(const Name: WideString; ShowDialog: OleVariant; ParentWnd: OleVariant): IRDOAddressEntry; safecall;
    function CreateOneOffEntryID(const Name: WideString; const AddressType: WideString; 
                                 const Address: WideString; SendRichInfo: WordBool; 
                                 UseUnicode: WordBool): WideString; safecall;
    property SearchPath: IRDOAddressBookSearchPath read Get_SearchPath;
    property DefaultAddressList: IRDOAddressList read Get_DefaultAddressList write Set_DefaultAddressList;
    property PAB: IRDOAddressList read Get_PAB;
    property GAL: IRDOAddressList read Get_GAL;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressBookDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3F5393D1-F833-4224-822E-68B3674F30C1}
// *********************************************************************//
  IRDOAddressBookDisp = dispinterface
    ['{3F5393D1-F833-4224-822E-68B3674F30C1}']
    property SearchPath: IRDOAddressBookSearchPath readonly dispid 101;
    function AddressLists(ShallowTraversal: OleVariant): IRDOAddressLists; dispid 102;
    property DefaultAddressList: IRDOAddressList dispid 103;
    property PAB: IRDOAddressList readonly dispid 104;
    property GAL: IRDOAddressList readonly dispid 107;
    function GetAddressListFromID(const EntryID: WideString): IRDOAddressList; dispid 8;
    function GetAddressEntryFromID(const EntryID: WideString): IRDOAddressEntry; dispid 9;
    function ShowAddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                             ForceResolution: OleVariant; RecipLists: OleVariant; 
                             ToLabel: OleVariant; CcLabel: OleVariant; BccLabel: OleVariant; 
                             ParentWindow: OleVariant): IRDORecipients; dispid 10;
    function ResolveName(const Name: WideString; ShowDialog: OleVariant; ParentWnd: OleVariant): IRDOAddressEntry; dispid 7;
    function CreateOneOffEntryID(const Name: WideString; const AddressType: WideString; 
                                 const Address: WideString; SendRichInfo: WordBool; 
                                 UseUnicode: WordBool): WideString; dispid 1610809354;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolderEvents
// Flags:     (4096) Dispatchable
// GUID:      {D27B50F3-C404-423D-96E6-4EADFBB83571}
// *********************************************************************//
  IRDOFolderEvents = dispinterface
    ['{D27B50F3-C404-423D-96E6-4EADFBB83571}']
    procedure OnModified; dispid 1;
    procedure OnDeleted; dispid 2;
    procedure OnMoved; dispid 3;
    procedure OnSearchComplete; dispid 4;
    procedure OnMovedEx(const OldParentEntryId: WideString; const NewParentEntryID: WideString); dispid 5;
  end;

// *********************************************************************//
// Interface: IRDOStore
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1EDC0526-2A75-4DBC-B532-B3402B699B1B}
// *********************************************************************//
  IRDOStore = interface(_MAPIProp)
    ['{1EDC0526-2A75-4DBC-B532-B3402B699B1B}']
    function Get_StoreKind: TxStoreKind; safecall;
    function Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function Get_RootFolder: IRDOFolder; safecall;
    function Get_IPMRootFolder: IRDOFolder; safecall;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; safecall;
    procedure AbortSubmit(const MessageEntryID: WideString); safecall;
    function Get_SearchRootFolder: IRDOFolder; safecall;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; safecall;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; safecall;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure Remove; safecall;
    function Get_Reminders: IRDOReminders; safecall;
    function Get_StoreAccount: IRDOAccount; safecall;
    property StoreKind: TxStoreKind read Get_StoreKind;
    property Default: WordBool read Get_Default write Set_Default;
    property RootFolder: IRDOFolder read Get_RootFolder;
    property IPMRootFolder: IRDOFolder read Get_IPMRootFolder;
    property SearchRootFolder: IRDOFolder read Get_SearchRootFolder;
    property EntryID: WideString read Get_EntryID;
    property Name: WideString read Get_Name write Set_Name;
    property Reminders: IRDOReminders read Get_Reminders;
    property StoreAccount: IRDOAccount read Get_StoreAccount;
  end;

// *********************************************************************//
// DispIntf:  IRDOStoreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1EDC0526-2A75-4DBC-B532-B3402B699B1B}
// *********************************************************************//
  IRDOStoreDisp = dispinterface
    ['{1EDC0526-2A75-4DBC-B532-B3402B699B1B}']
    property StoreKind: TxStoreKind readonly dispid 101;
    property Default: WordBool dispid 102;
    property RootFolder: IRDOFolder readonly dispid 103;
    property IPMRootFolder: IRDOFolder readonly dispid 104;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 105;
    procedure AbortSubmit(const MessageEntryID: WideString); dispid 106;
    property SearchRootFolder: IRDOFolder readonly dispid 107;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 108;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; dispid 7;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 10;
    procedure Remove; dispid 11;
    property Reminders: IRDOReminders readonly dispid 1012;
    property StoreAccount: IRDOAccount readonly dispid 5012;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOPstStore
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B78DFF17-ABA1-4DC6-8FBD-F9C17E82033F}
// *********************************************************************//
  IRDOPstStore = interface(IRDOStore)
    ['{B78DFF17-ABA1-4DC6-8FBD-F9C17E82033F}']
    function Get_PstPath: WideString; safecall;
    property PstPath: WideString read Get_PstPath;
  end;

// *********************************************************************//
// DispIntf:  IRDOPstStoreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B78DFF17-ABA1-4DC6-8FBD-F9C17E82033F}
// *********************************************************************//
  IRDOPstStoreDisp = dispinterface
    ['{B78DFF17-ABA1-4DC6-8FBD-F9C17E82033F}']
    property PstPath: WideString readonly dispid 2001;
    property StoreKind: TxStoreKind readonly dispid 101;
    property Default: WordBool dispid 102;
    property RootFolder: IRDOFolder readonly dispid 103;
    property IPMRootFolder: IRDOFolder readonly dispid 104;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 105;
    procedure AbortSubmit(const MessageEntryID: WideString); dispid 106;
    property SearchRootFolder: IRDOFolder readonly dispid 107;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 108;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; dispid 7;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 10;
    procedure Remove; dispid 11;
    property Reminders: IRDOReminders readonly dispid 1012;
    property StoreAccount: IRDOAccount readonly dispid 5012;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// DispIntf:  IRDOStoreEvents
// Flags:     (4096) Dispatchable
// GUID:      {4304377A-587C-4CB0-A951-03491A74467D}
// *********************************************************************//
  IRDOStoreEvents = dispinterface
    ['{4304377A-587C-4CB0-A951-03491A74467D}']
    procedure OnNewMail(const EntryID: WideString); dispid 1;
    procedure OnMessageCreated(const EntryID: WideString); dispid 2;
    procedure OnFolderCreated(const EntryID: WideString); dispid 3;
    procedure OnMessageCopied(const EntryID: WideString); dispid 4;
    procedure OnFolderCopied(const EntryID: WideString); dispid 5;
    procedure OnMessageDeleted(const EntryID: WideString); dispid 6;
    procedure OnFolderDeleted(const EntryID: WideString); dispid 7;
    procedure OnMessageModified(const EntryID: WideString); dispid 8;
    procedure OnFolderModified(const EntryID: WideString); dispid 9;
    procedure OnMessageMoved(const EntryID: WideString); dispid 10;
    procedure OnFolderMoved(const EntryID: WideString); dispid 11;
    procedure OnSearchComplete(const EntryID: WideString); dispid 12;
    procedure OnFolderMovedEx(const EntryID: WideString; const OldParentEntryId: WideString; 
                              const NewParentEntryID: WideString); dispid 28;
    procedure OnMessageMovedEx(const EntryID: WideString; const OldParentEntryId: WideString; 
                               const NewParentEntryID: WideString); dispid 29;
  end;

// *********************************************************************//
// Interface: IRDOExchangeStore
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D5C6EDF7-8FDB-4CB4-8063-4C497581C92E}
// *********************************************************************//
  IRDOExchangeStore = interface(IRDOStore)
    ['{D5C6EDF7-8FDB-4CB4-8063-4C497581C92E}']
    function Get_ServerDN: WideString; safecall;
    property ServerDN: WideString read Get_ServerDN;
  end;

// *********************************************************************//
// DispIntf:  IRDOExchangeStoreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D5C6EDF7-8FDB-4CB4-8063-4C497581C92E}
// *********************************************************************//
  IRDOExchangeStoreDisp = dispinterface
    ['{D5C6EDF7-8FDB-4CB4-8063-4C497581C92E}']
    property ServerDN: WideString readonly dispid 2001;
    property StoreKind: TxStoreKind readonly dispid 101;
    property Default: WordBool dispid 102;
    property RootFolder: IRDOFolder readonly dispid 103;
    property IPMRootFolder: IRDOFolder readonly dispid 104;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 105;
    procedure AbortSubmit(const MessageEntryID: WideString); dispid 106;
    property SearchRootFolder: IRDOFolder readonly dispid 107;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 108;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; dispid 7;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 10;
    procedure Remove; dispid 11;
    property Reminders: IRDOReminders readonly dispid 1012;
    property StoreAccount: IRDOAccount readonly dispid 5012;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOExchangeMailboxStore
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0AE11A9E-C488-4FD8-9BF9-CA1702266607}
// *********************************************************************//
  IRDOExchangeMailboxStore = interface(IRDOExchangeStore)
    ['{0AE11A9E-C488-4FD8-9BF9-CA1702266607}']
    function Get_Owner: IRDOAddressEntry; safecall;
    function Get_OutOfOfficeAssistant: IRDOOutOfOfficeAssistant; safecall;
    function Get_IsCached: WordBool; safecall;
    procedure Set_IsCached(retVal: WordBool); safecall;
    function Get_OstPath: WideString; safecall;
    function Get_Rules: IRDORules; safecall;
    function GetFolderFromSourceKey(SourceKey: OleVariant): IRDOFolder; safecall;
    function GetMessageFromSourceKey(FolderSourceKey: OleVariant; MessageSourceKey: OleVariant): IRDOMail; safecall;
    function Get_CalendarOptions: IRDOCalendarOptions; safecall;
    property Owner: IRDOAddressEntry read Get_Owner;
    property OutOfOfficeAssistant: IRDOOutOfOfficeAssistant read Get_OutOfOfficeAssistant;
    property IsCached: WordBool read Get_IsCached write Set_IsCached;
    property OstPath: WideString read Get_OstPath;
    property Rules: IRDORules read Get_Rules;
    property CalendarOptions: IRDOCalendarOptions read Get_CalendarOptions;
  end;

// *********************************************************************//
// DispIntf:  IRDOExchangeMailboxStoreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0AE11A9E-C488-4FD8-9BF9-CA1702266607}
// *********************************************************************//
  IRDOExchangeMailboxStoreDisp = dispinterface
    ['{0AE11A9E-C488-4FD8-9BF9-CA1702266607}']
    property Owner: IRDOAddressEntry readonly dispid 3001;
    property OutOfOfficeAssistant: IRDOOutOfOfficeAssistant readonly dispid 12;
    property IsCached: WordBool dispid 1610940418;
    property OstPath: WideString readonly dispid 1610940420;
    property Rules: IRDORules readonly dispid 1610940421;
    function GetFolderFromSourceKey(SourceKey: OleVariant): IRDOFolder; dispid 1610940422;
    function GetMessageFromSourceKey(FolderSourceKey: OleVariant; MessageSourceKey: OleVariant): IRDOMail; dispid 1610940423;
    property CalendarOptions: IRDOCalendarOptions readonly dispid 1610940424;
    property ServerDN: WideString readonly dispid 2001;
    property StoreKind: TxStoreKind readonly dispid 101;
    property Default: WordBool dispid 102;
    property RootFolder: IRDOFolder readonly dispid 103;
    property IPMRootFolder: IRDOFolder readonly dispid 104;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 105;
    procedure AbortSubmit(const MessageEntryID: WideString); dispid 106;
    property SearchRootFolder: IRDOFolder readonly dispid 107;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 108;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; dispid 7;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 10;
    procedure Remove; dispid 11;
    property Reminders: IRDOReminders readonly dispid 1012;
    property StoreAccount: IRDOAccount readonly dispid 5012;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOMail
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D85047E0-7767-4D48-86B6-28BDB5728ABB}
// *********************************************************************//
  IRDOMail = interface(_MAPIProp)
    ['{D85047E0-7767-4D48-86B6-28BDB5728ABB}']
    function Get_EntryID: WideString; safecall;
    function Get_Subject: WideString; safecall;
    procedure Set_Subject(const Value: WideString); safecall;
    function Get_AlternateRecipientAllowed: WordBool; safecall;
    procedure Set_AlternateRecipientAllowed(Value: WordBool); safecall;
    function Get_AutoForwarded: WordBool; safecall;
    procedure Set_AutoForwarded(Value: WordBool); safecall;
    function Get_BCC: WideString; safecall;
    procedure Set_BCC(const Value: WideString); safecall;
    function Get_BillingInformation: WideString; safecall;
    procedure Set_BillingInformation(const Value: WideString); safecall;
    function Get_Body: WideString; safecall;
    procedure Set_Body(const Value: WideString); safecall;
    function Get_BodyFormat: Integer; safecall;
    procedure Set_BodyFormat(Value: Integer); safecall;
    function Get_Categories: WideString; safecall;
    procedure Set_Categories(const Value: WideString); safecall;
    function Get_CC: WideString; safecall;
    procedure Set_CC(const Value: WideString); safecall;
    function Get_Companies: WideString; safecall;
    procedure Set_Companies(const Value: WideString); safecall;
    function Get_ConversationIndex: WideString; safecall;
    procedure Set_ConversationIndex(const Value: WideString); safecall;
    function Get_ConversationTopic: WideString; safecall;
    procedure Set_ConversationTopic(const Value: WideString); safecall;
    function Get_CreationTime: TDateTime; safecall;
    function Get_DeferredDeliveryTime: TDateTime; safecall;
    procedure Set_DeferredDeliveryTime(Value: TDateTime); safecall;
    function Get_DeleteAfterSubmit: WordBool; safecall;
    procedure Set_DeleteAfterSubmit(Value: WordBool); safecall;
    function Get_ExpiryTime: TDateTime; safecall;
    procedure Set_ExpiryTime(Value: TDateTime); safecall;
    function Get_FlagDueBy: TDateTime; safecall;
    procedure Set_FlagDueBy(Value: TDateTime); safecall;
    function Get_FlagIcon: Integer; safecall;
    procedure Set_FlagIcon(Value: Integer); safecall;
    function Get_FlagRequest: WideString; safecall;
    procedure Set_FlagRequest(const Value: WideString); safecall;
    function Get_FlagStatus: Integer; safecall;
    procedure Set_FlagStatus(Value: Integer); safecall;
    function Get_HTMLBody: WideString; safecall;
    procedure Set_HTMLBody(const Value: WideString); safecall;
    function Get_Importance: Integer; safecall;
    procedure Set_Importance(Value: Integer); safecall;
    function Get_InternetCodepage: Integer; safecall;
    procedure Set_InternetCodepage(Value: Integer); safecall;
    function Get_LastModificationTime: TDateTime; safecall;
    function Get_MessageClass: WideString; safecall;
    procedure Set_MessageClass(const Value: WideString); safecall;
    function Get_Mileage: WideString; safecall;
    procedure Set_Mileage(const Value: WideString); safecall;
    function Get_NoAging: WordBool; safecall;
    procedure Set_NoAging(Value: WordBool); safecall;
    function Get_OriginatorDeliveryReportRequested: WordBool; safecall;
    procedure Set_OriginatorDeliveryReportRequested(Value: WordBool); safecall;
    function Get_OutlookInternalVersion: Integer; safecall;
    function Get_OutlookVersion: WideString; safecall;
    function Get_ReadReceiptRequested: WordBool; safecall;
    procedure Set_ReadReceiptRequested(Value: WordBool); safecall;
    function Get_ReceivedByEntryID: WideString; safecall;
    procedure Set_ReceivedByEntryID(const Value: WideString); safecall;
    function Get_ReceivedByName: WideString; safecall;
    procedure Set_ReceivedByName(const Value: WideString); safecall;
    function Get_ReceivedOnBehalfOfEntryID: WideString; safecall;
    procedure Set_ReceivedOnBehalfOfEntryID(const Value: WideString); safecall;
    function Get_ReceivedOnBehalfOfName: WideString; safecall;
    procedure Set_ReceivedOnBehalfOfName(const Value: WideString); safecall;
    function Get_ReceivedTime: TDateTime; safecall;
    procedure Set_ReceivedTime(Value: TDateTime); safecall;
    function Get_RecipientReassignmentProhibited: WordBool; safecall;
    procedure Set_RecipientReassignmentProhibited(Value: WordBool); safecall;
    function Get_ReminderOverrideDefault: WordBool; safecall;
    procedure Set_ReminderOverrideDefault(Value: WordBool); safecall;
    function Get_ReminderPlaySound: WordBool; safecall;
    procedure Set_ReminderPlaySound(Value: WordBool); safecall;
    function Get_ReminderSet: WordBool; safecall;
    procedure Set_ReminderSet(Value: WordBool); safecall;
    function Get_ReminderSoundFile: WideString; safecall;
    procedure Set_ReminderSoundFile(const Value: WideString); safecall;
    function Get_ReminderTime: TDateTime; safecall;
    procedure Set_ReminderTime(Value: TDateTime); safecall;
    function Get_ReplyRecipientNames: WideString; safecall;
    function Get_SaveSentMessageFolder: OleVariant; safecall;
    procedure Set_SaveSentMessageFolder(Value: OleVariant); safecall;
    function Get_SenderEmailAddress: WideString; safecall;
    procedure Set_SenderEmailAddress(const Value: WideString); safecall;
    function Get_SenderEmailType: WideString; safecall;
    procedure Set_SenderEmailType(const Value: WideString); safecall;
    function Get_SenderName: WideString; safecall;
    procedure Set_SenderName(const Value: WideString); safecall;
    function Get_SenderEntryID: WideString; safecall;
    procedure Set_SenderEntryID(const Value: WideString); safecall;
    function Get_Sensitivity: Integer; safecall;
    procedure Set_Sensitivity(Value: Integer); safecall;
    function Get_Sent: WordBool; safecall;
    procedure Set_Sent(Value: WordBool); safecall;
    function Get_SentOn: TDateTime; safecall;
    procedure Set_SentOn(Value: TDateTime); safecall;
    function Get_SentOnBehalfOfName: WideString; safecall;
    procedure Set_SentOnBehalfOfName(const Value: WideString); safecall;
    function Get_SentOnBehalfOfEmailAddress: WideString; safecall;
    procedure Set_SentOnBehalfOfEmailAddress(const Value: WideString); safecall;
    function Get_SentOnBehalfOfEmailType: WideString; safecall;
    procedure Set_SentOnBehalfOfEmailType(const Value: WideString); safecall;
    function Get_SentOnBehalfOfEntryID: WideString; safecall;
    procedure Set_SentOnBehalfOfEntryID(const Value: WideString); safecall;
    function Get_Size: Integer; safecall;
    function Get_Submitted: WordBool; safecall;
    function Get_To_: WideString; safecall;
    procedure Set_To_(const Value: WideString); safecall;
    function Get_UnRead: WordBool; safecall;
    procedure Set_UnRead(Value: WordBool); safecall;
    function Get_VotingResponse: WideString; safecall;
    procedure Set_VotingResponse(const Value: WideString); safecall;
    function Get_RTFBody: WideString; safecall;
    procedure Set_RTFBody(const Value: WideString); safecall;
    procedure Send; safecall;
    procedure Import(const Path: WideString; Type_: OleVariant); safecall;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); safecall;
    function Get_Attachments: IRDOAttachments; safecall;
    procedure Delete(DeleteFlags: OleVariant); safecall;
    function Move(const DestFolder: IRDOFolder): IRDOMail; safecall;
    function Reply: IRDOMail; safecall;
    function ReplyAll: IRDOMail; safecall;
    function Forward: IRDOMail; safecall;
    function Get_Recipients: IRDORecipients; safecall;
    procedure Set_Recipients(const Value: IRDORecipients); safecall;
    function Get_HidePaperClip: WordBool; safecall;
    procedure Set_HidePaperClip(Value: WordBool); safecall;
    function Get_Sender: IRDOAddressEntry; safecall;
    procedure Set_Sender(const Value: IRDOAddressEntry); safecall;
    function Get_SentOnBehalfOf: IRDOAddressEntry; safecall;
    procedure Set_SentOnBehalfOf(const Value: IRDOAddressEntry); safecall;
    function Get_Store: IRDOStore; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_ReplyRecipients: IRDORecipients; safecall;
    procedure Set_ReplyRecipients(const Value: IRDORecipients); safecall;
    procedure AbortSubmit; safecall;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); safecall;
    procedure PrintOut(ParentWnd: OleVariant); safecall;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); safecall;
    procedure DesignForm(ParentWnd: OleVariant); safecall;
    function Get_Account: IRDOAccount; safecall;
    procedure Set_Account(const Value: IRDOAccount); safecall;
    function Get_Links: IRDOLinks; safecall;
    function Get_VotingOptions: WideString; safecall;
    procedure Set_VotingOptions(const retVal: WideString); safecall;
    function Get__Reserved3: Integer; safecall;
    procedure Set__Reserved3(retVal: Integer); safecall;
    function Get__Reserved4: Integer; safecall;
    procedure Set__Reserved4(retVal: Integer); safecall;
    function Get__Reserved5: Integer; safecall;
    procedure Set__Reserved5(retVal: Integer); safecall;
    function Get_Actions: IRDOActions; safecall;
    procedure MarkRead(SuppressReceipt: WordBool); safecall;
    function Get_Conflicts: IRDOConflicts; safecall;
    procedure _ReservedMethod4; safecall;
    procedure _ReservedMethod5; safecall;
    property EntryID: WideString read Get_EntryID;
    property Subject: WideString read Get_Subject write Set_Subject;
    property AlternateRecipientAllowed: WordBool read Get_AlternateRecipientAllowed write Set_AlternateRecipientAllowed;
    property AutoForwarded: WordBool read Get_AutoForwarded write Set_AutoForwarded;
    property BCC: WideString read Get_BCC write Set_BCC;
    property BillingInformation: WideString read Get_BillingInformation write Set_BillingInformation;
    property Body: WideString read Get_Body write Set_Body;
    property BodyFormat: Integer read Get_BodyFormat write Set_BodyFormat;
    property Categories: WideString read Get_Categories write Set_Categories;
    property CC: WideString read Get_CC write Set_CC;
    property Companies: WideString read Get_Companies write Set_Companies;
    property ConversationIndex: WideString read Get_ConversationIndex write Set_ConversationIndex;
    property ConversationTopic: WideString read Get_ConversationTopic write Set_ConversationTopic;
    property CreationTime: TDateTime read Get_CreationTime;
    property DeferredDeliveryTime: TDateTime read Get_DeferredDeliveryTime write Set_DeferredDeliveryTime;
    property DeleteAfterSubmit: WordBool read Get_DeleteAfterSubmit write Set_DeleteAfterSubmit;
    property ExpiryTime: TDateTime read Get_ExpiryTime write Set_ExpiryTime;
    property FlagDueBy: TDateTime read Get_FlagDueBy write Set_FlagDueBy;
    property FlagIcon: Integer read Get_FlagIcon write Set_FlagIcon;
    property FlagRequest: WideString read Get_FlagRequest write Set_FlagRequest;
    property FlagStatus: Integer read Get_FlagStatus write Set_FlagStatus;
    property HTMLBody: WideString read Get_HTMLBody write Set_HTMLBody;
    property Importance: Integer read Get_Importance write Set_Importance;
    property InternetCodepage: Integer read Get_InternetCodepage write Set_InternetCodepage;
    property LastModificationTime: TDateTime read Get_LastModificationTime;
    property MessageClass: WideString read Get_MessageClass write Set_MessageClass;
    property Mileage: WideString read Get_Mileage write Set_Mileage;
    property NoAging: WordBool read Get_NoAging write Set_NoAging;
    property OriginatorDeliveryReportRequested: WordBool read Get_OriginatorDeliveryReportRequested write Set_OriginatorDeliveryReportRequested;
    property OutlookInternalVersion: Integer read Get_OutlookInternalVersion;
    property OutlookVersion: WideString read Get_OutlookVersion;
    property ReadReceiptRequested: WordBool read Get_ReadReceiptRequested write Set_ReadReceiptRequested;
    property ReceivedByEntryID: WideString read Get_ReceivedByEntryID write Set_ReceivedByEntryID;
    property ReceivedByName: WideString read Get_ReceivedByName write Set_ReceivedByName;
    property ReceivedOnBehalfOfEntryID: WideString read Get_ReceivedOnBehalfOfEntryID write Set_ReceivedOnBehalfOfEntryID;
    property ReceivedOnBehalfOfName: WideString read Get_ReceivedOnBehalfOfName write Set_ReceivedOnBehalfOfName;
    property ReceivedTime: TDateTime read Get_ReceivedTime write Set_ReceivedTime;
    property RecipientReassignmentProhibited: WordBool read Get_RecipientReassignmentProhibited write Set_RecipientReassignmentProhibited;
    property ReminderOverrideDefault: WordBool read Get_ReminderOverrideDefault write Set_ReminderOverrideDefault;
    property ReminderPlaySound: WordBool read Get_ReminderPlaySound write Set_ReminderPlaySound;
    property ReminderSet: WordBool read Get_ReminderSet write Set_ReminderSet;
    property ReminderSoundFile: WideString read Get_ReminderSoundFile write Set_ReminderSoundFile;
    property ReminderTime: TDateTime read Get_ReminderTime write Set_ReminderTime;
    property ReplyRecipientNames: WideString read Get_ReplyRecipientNames;
    property SaveSentMessageFolder: OleVariant read Get_SaveSentMessageFolder write Set_SaveSentMessageFolder;
    property SenderEmailAddress: WideString read Get_SenderEmailAddress write Set_SenderEmailAddress;
    property SenderEmailType: WideString read Get_SenderEmailType write Set_SenderEmailType;
    property SenderName: WideString read Get_SenderName write Set_SenderName;
    property SenderEntryID: WideString read Get_SenderEntryID write Set_SenderEntryID;
    property Sensitivity: Integer read Get_Sensitivity write Set_Sensitivity;
    property Sent: WordBool read Get_Sent write Set_Sent;
    property SentOn: TDateTime read Get_SentOn write Set_SentOn;
    property SentOnBehalfOfName: WideString read Get_SentOnBehalfOfName write Set_SentOnBehalfOfName;
    property SentOnBehalfOfEmailAddress: WideString read Get_SentOnBehalfOfEmailAddress write Set_SentOnBehalfOfEmailAddress;
    property SentOnBehalfOfEmailType: WideString read Get_SentOnBehalfOfEmailType write Set_SentOnBehalfOfEmailType;
    property SentOnBehalfOfEntryID: WideString read Get_SentOnBehalfOfEntryID write Set_SentOnBehalfOfEntryID;
    property Size: Integer read Get_Size;
    property Submitted: WordBool read Get_Submitted;
    property To_: WideString read Get_To_ write Set_To_;
    property UnRead: WordBool read Get_UnRead write Set_UnRead;
    property VotingResponse: WideString read Get_VotingResponse write Set_VotingResponse;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Attachments: IRDOAttachments read Get_Attachments;
    property Recipients: IRDORecipients read Get_Recipients write Set_Recipients;
    property HidePaperClip: WordBool read Get_HidePaperClip write Set_HidePaperClip;
    property Sender: IRDOAddressEntry read Get_Sender write Set_Sender;
    property SentOnBehalfOf: IRDOAddressEntry read Get_SentOnBehalfOf write Set_SentOnBehalfOf;
    property Store: IRDOStore read Get_Store;
    property Parent: IDispatch read Get_Parent;
    property ReplyRecipients: IRDORecipients read Get_ReplyRecipients write Set_ReplyRecipients;
    property Account: IRDOAccount read Get_Account write Set_Account;
    property Links: IRDOLinks read Get_Links;
    property VotingOptions: WideString read Get_VotingOptions write Set_VotingOptions;
    property _Reserved3: Integer read Get__Reserved3 write Set__Reserved3;
    property _Reserved4: Integer read Get__Reserved4 write Set__Reserved4;
    property _Reserved5: Integer read Get__Reserved5 write Set__Reserved5;
    property Actions: IRDOActions read Get_Actions;
    property Conflicts: IRDOConflicts read Get_Conflicts;
  end;

// *********************************************************************//
// DispIntf:  IRDOMailDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D85047E0-7767-4D48-86B6-28BDB5728ABB}
// *********************************************************************//
  IRDOMailDisp = dispinterface
    ['{D85047E0-7767-4D48-86B6-28BDB5728ABB}']
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// DispIntf:  IRDOMailEvents
// Flags:     (4096) Dispatchable
// GUID:      {0D00E38E-315D-49D5-9331-80BC1559C0E7}
// *********************************************************************//
  IRDOMailEvents = dispinterface
    ['{0D00E38E-315D-49D5-9331-80BC1559C0E7}']
    procedure OnModified; dispid 1;
    procedure OnDeleted; dispid 2;
    procedure OnMoved; dispid 3;
    procedure OnClose; dispid 4;
    procedure OnMovedEx(const OldParentEntryId: WideString; const NewParentEntryID: WideString); dispid 5;
  end;

// *********************************************************************//
// Interface: IRDOExchangePublicFoldersStore
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C4E7A620-38A0-4EB3-9F1E-0317BF6BC665}
// *********************************************************************//
  IRDOExchangePublicFoldersStore = interface(IRDOExchangeStore)
    ['{C4E7A620-38A0-4EB3-9F1E-0317BF6BC665}']
    function Get_IsCached: WordBool; safecall;
    procedure Set_IsCached(retVal: WordBool); safecall;
    property IsCached: WordBool read Get_IsCached write Set_IsCached;
  end;

// *********************************************************************//
// DispIntf:  IRDOExchangePublicFoldersStoreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C4E7A620-38A0-4EB3-9F1E-0317BF6BC665}
// *********************************************************************//
  IRDOExchangePublicFoldersStoreDisp = dispinterface
    ['{C4E7A620-38A0-4EB3-9F1E-0317BF6BC665}']
    property IsCached: WordBool dispid 1610940416;
    property ServerDN: WideString readonly dispid 2001;
    property StoreKind: TxStoreKind readonly dispid 101;
    property Default: WordBool dispid 102;
    property RootFolder: IRDOFolder readonly dispid 103;
    property IPMRootFolder: IRDOFolder readonly dispid 104;
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder; dispid 105;
    procedure AbortSubmit(const MessageEntryID: WideString); dispid 106;
    property SearchRootFolder: IRDOFolder readonly dispid 107;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool; dispid 108;
    function GetMessageFromID(const EntryID: WideString; Flags: OleVariant): IRDOMail; dispid 7;
    function GetFolderFromID(const EntryID: WideString; Flags: OleVariant): IRDOFolder; dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 10;
    procedure Remove; dispid 11;
    property Reminders: IRDOReminders readonly dispid 1012;
    property StoreAccount: IRDOAccount readonly dispid 5012;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOItems
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F8408EB8-6B65-4704-810C-29795E67C0DD}
// *********************************************************************//
  IRDOItems = interface(IDispatch)
    ['{F8408EB8-6B65-4704-810C-29795E67C0DD}']
    function Get_Count: Integer; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    function Add(Type_: OleVariant): IRDOMail; safecall;
    function GetFirst: IRDOMail; safecall;
    function GetLast: IRDOMail; safecall;
    function GetNext: IRDOMail; safecall;
    function GetPrevious: IRDOMail; safecall;
    function Item(Index: OleVariant): IRDOMail; safecall;
    function Get__Item(Index: OleVariant): IRDOMail; safecall;
    procedure Remove(Index: Integer; DeleteFlags: OleVariant); safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function _Restore(Index: OleVariant): IRDOMail; safecall;
    function Find(const Filter: WideString): IRDOMail; safecall;
    function FindNext: IRDOMail; safecall;
    function Restrict(const Filter: WideString): IRDOItems; safecall;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); safecall;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IRDOSession read Get_Session;
    property _Item[Index: OleVariant]: IRDOMail read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOItemsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F8408EB8-6B65-4704-810C-29795E67C0DD}
// *********************************************************************//
  IRDOItemsDisp = dispinterface
    ['{F8408EB8-6B65-4704-810C-29795E67C0DD}']
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function Add(Type_: OleVariant): IRDOMail; dispid 4;
    function GetFirst: IRDOMail; dispid 5;
    function GetLast: IRDOMail; dispid 6;
    function GetNext: IRDOMail; dispid 7;
    function GetPrevious: IRDOMail; dispid 8;
    function Item(Index: OleVariant): IRDOMail; dispid 9;
    property _Item[Index: OleVariant]: IRDOMail readonly dispid 0; default;
    procedure Remove(Index: Integer; DeleteFlags: OleVariant); dispid 11;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
    function _Restore(Index: OleVariant): IRDOMail; dispid 1610743821;
    function Find(const Filter: WideString): IRDOMail; dispid 1610743822;
    function FindNext: IRDOMail; dispid 1610743823;
    function Restrict(const Filter: WideString): IRDOItems; dispid 1610743824;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); dispid 1610743825;
  end;

// *********************************************************************//
// DispIntf:  IRDOItemsEvents
// Flags:     (4096) Dispatchable
// GUID:      {0E5B5CD0-7C63-4E3F-B806-5372C68243CA}
// *********************************************************************//
  IRDOItemsEvents = dispinterface
    ['{0E5B5CD0-7C63-4E3F-B806-5372C68243CA}']
    procedure ItemChange(const Item: IRDOMail); dispid 1;
    procedure ItemAdd(const Item: IRDOMail); dispid 2;
    procedure ItemRemove(const InstanceKey: WideString); dispid 3;
    procedure CollectionModified; dispid 4;
  end;

// *********************************************************************//
// Interface: IRDOFolders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E7707B13-1256-4BB0-A1AB-A59F1B6EEF9C}
// *********************************************************************//
  IRDOFolders = interface(IDispatch)
    ['{E7707B13-1256-4BB0-A1AB-A59F1B6EEF9C}']
    function Get_Count: Integer; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    function Add(const Name: WideString; Type_: OleVariant): IRDOFolder; safecall;
    function GetFirst: IRDOFolder; safecall;
    function GetLast: IRDOFolder; safecall;
    function GetNext: IRDOFolder; safecall;
    function GetPrevious: IRDOFolder; safecall;
    function Item(Index: OleVariant): IRDOFolder; safecall;
    function Get__Item(Index: OleVariant): IRDOFolder; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function AddSearchFolder(const Name: WideString; Type_: OleVariant): IRDOSearchFolder; safecall;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IRDOSession read Get_Session;
    property _Item[Index: OleVariant]: IRDOFolder read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOFoldersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E7707B13-1256-4BB0-A1AB-A59F1B6EEF9C}
// *********************************************************************//
  IRDOFoldersDisp = dispinterface
    ['{E7707B13-1256-4BB0-A1AB-A59F1B6EEF9C}']
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function Add(const Name: WideString; Type_: OleVariant): IRDOFolder; dispid 4;
    function GetFirst: IRDOFolder; dispid 5;
    function GetLast: IRDOFolder; dispid 6;
    function GetNext: IRDOFolder; dispid 7;
    function GetPrevious: IRDOFolder; dispid 8;
    function Item(Index: OleVariant): IRDOFolder; dispid 9;
    property _Item[Index: OleVariant]: IRDOFolder readonly dispid 0; default;
    procedure Remove(Index: Integer); dispid 11;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
    function AddSearchFolder(const Name: WideString; Type_: OleVariant): IRDOSearchFolder; dispid 10;
  end;

// *********************************************************************//
// DispIntf:  IRDOFoldersEvents
// Flags:     (4096) Dispatchable
// GUID:      {45157DD1-CEF5-4EFC-99F8-7970934CC55D}
// *********************************************************************//
  IRDOFoldersEvents = dispinterface
    ['{45157DD1-CEF5-4EFC-99F8-7970934CC55D}']
    procedure FolderChange(const Folder: IRDOFolder); dispid 1;
    procedure FolderAdd(const Folder: IRDOFolder); dispid 2;
    procedure FolderRemove(const InstanceKey: WideString); dispid 3;
    procedure CollectionModified; dispid 4;
  end;

// *********************************************************************//
// Interface: IRDOAttachments
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9ED8DA28-908D-4DA3-B7AC-8DF8587A9DD0}
// *********************************************************************//
  IRDOAttachments = interface(IDispatch)
    ['{9ED8DA28-908D-4DA3-B7AC-8DF8587A9DD0}']
    function Get_Session: IRDOSession; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant): IRDOAttachment; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get__Item(Index: OleVariant): IRDOAttachment; safecall;
    function Item(Index: OleVariant): IRDOAttachment; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    procedure Clear; safecall;
    function GetFirst: IRDOAttachment; safecall;
    function GetLast: IRDOAttachment; safecall;
    function GetNext: IRDOAttachment; safecall;
    function GetPrevious: IRDOAttachment; safecall;
    property Session: IRDOSession read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property _Item[Index: OleVariant]: IRDOAttachment read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOAttachmentsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9ED8DA28-908D-4DA3-B7AC-8DF8587A9DD0}
// *********************************************************************//
  IRDOAttachmentsDisp = dispinterface
    ['{9ED8DA28-908D-4DA3-B7AC-8DF8587A9DD0}']
    property Session: IRDOSession readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Count: Integer readonly dispid 80;
    function Add(Source: OleVariant; Type_: OleVariant; Position: OleVariant; 
                 DisplayName: OleVariant): IRDOAttachment; dispid 101;
    procedure Remove(Index: Integer); dispid 84;
    property RawTable: IUnknown readonly dispid 1;
    property _Item[Index: OleVariant]: IRDOAttachment readonly dispid 0; default;
    function Item(Index: OleVariant): IRDOAttachment; dispid 4;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 2;
    procedure Clear; dispid 3;
    function GetFirst: IRDOAttachment; dispid 1610743819;
    function GetLast: IRDOAttachment; dispid 1610743820;
    function GetNext: IRDOAttachment; dispid 1610743821;
    function GetPrevious: IRDOAttachment; dispid 1610743822;
  end;

// *********************************************************************//
// Interface: IRDOAttachment
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C3D4791-B887-490E-8253-CCC0BC7E15C9}
// *********************************************************************//
  IRDOAttachment = interface(_MAPIProp)
    ['{5C3D4791-B887-490E-8253-CCC0BC7E15C9}']
    function Get_Parent: IRDOMail; safecall;
    function Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function Get_PathName: WideString; safecall;
    procedure Set_PathName(const Value: WideString); safecall;
    function Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function Get_type_: rdoAttachmentType; safecall;
    procedure Delete; safecall;
    procedure SaveAsFile(const Path: WideString); safecall;
    function Get_AsText: WideString; safecall;
    procedure Set_AsText(const Value: WideString); safecall;
    function Get_AsArray: OleVariant; safecall;
    procedure Set_AsArray(Value: OleVariant); safecall;
    function Get_Size: Integer; safecall;
    function Get_EmbeddedMsg: IRDOMail; safecall;
    function Get_OleStorage: IUnknown; safecall;
    function Get_Hidden: WordBool; safecall;
    procedure Set_Hidden(Value: WordBool); safecall;
    function Get_FileSize: Integer; safecall;
    function Get_CreationTime: TDateTime; safecall;
    function Get_LastModificationTime: TDateTime; safecall;
    property Parent: IRDOMail read Get_Parent;
    property DisplayName: WideString read Get_DisplayName write Set_DisplayName;
    property FileName: WideString read Get_FileName write Set_FileName;
    property PathName: WideString read Get_PathName write Set_PathName;
    property Position: Integer read Get_Position write Set_Position;
    property type_: rdoAttachmentType read Get_type_;
    property AsText: WideString read Get_AsText write Set_AsText;
    property AsArray: OleVariant read Get_AsArray write Set_AsArray;
    property Size: Integer read Get_Size;
    property EmbeddedMsg: IRDOMail read Get_EmbeddedMsg;
    property OleStorage: IUnknown read Get_OleStorage;
    property Hidden: WordBool read Get_Hidden write Set_Hidden;
    property FileSize: Integer read Get_FileSize;
    property CreationTime: TDateTime read Get_CreationTime;
    property LastModificationTime: TDateTime read Get_LastModificationTime;
  end;

// *********************************************************************//
// DispIntf:  IRDOAttachmentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C3D4791-B887-490E-8253-CCC0BC7E15C9}
// *********************************************************************//
  IRDOAttachmentDisp = dispinterface
    ['{5C3D4791-B887-490E-8253-CCC0BC7E15C9}']
    property Parent: IRDOMail readonly dispid 102;
    property DisplayName: WideString dispid 103;
    property FileName: WideString dispid 104;
    property PathName: WideString dispid 7;
    property Position: Integer dispid 8;
    property type_: rdoAttachmentType readonly dispid 9;
    procedure Delete; dispid 10;
    procedure SaveAsFile(const Path: WideString); dispid 11;
    property AsText: WideString dispid 12;
    property AsArray: OleVariant dispid 13;
    property Size: Integer readonly dispid 14;
    property EmbeddedMsg: IRDOMail readonly dispid 15;
    property OleStorage: IUnknown readonly dispid 16;
    property Hidden: WordBool dispid 17;
    property FileSize: Integer readonly dispid 1610809365;
    property CreationTime: TDateTime readonly dispid 1610809366;
    property LastModificationTime: TDateTime readonly dispid 1610809367;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDORecipients
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F17B2E04-2E64-4A50-86A3-BEC908D58097}
// *********************************************************************//
  IRDORecipients = interface(IDispatch)
    ['{F17B2E04-2E64-4A50-86A3-BEC908D58097}']
    function Get_Session: IRDOSession; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Add(Source: OleVariant): IRDORecipient; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get__Item(Index: OleVariant): IRDORecipient; safecall;
    function Item(Index: OleVariant): IRDORecipient; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function AddEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant; 
                   Type_: OleVariant): IRDORecipient; safecall;
    function ResolveAll(ShowDialog: OleVariant; ParentWndHandle: OleVariant): WordBool; safecall;
    procedure Clear; safecall;
    function GetFirst: IRDORecipient; safecall;
    function GetLast: IRDORecipient; safecall;
    function GetNext: IRDORecipient; safecall;
    function GetPrevious: IRDORecipient; safecall;
    property Session: IRDOSession read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property _Item[Index: OleVariant]: IRDORecipient read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDORecipientsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F17B2E04-2E64-4A50-86A3-BEC908D58097}
// *********************************************************************//
  IRDORecipientsDisp = dispinterface
    ['{F17B2E04-2E64-4A50-86A3-BEC908D58097}']
    property Session: IRDOSession readonly dispid 61451;
    property Parent: IDispatch readonly dispid 61441;
    property Count: Integer readonly dispid 80;
    function Add(Source: OleVariant): IRDORecipient; dispid 101;
    procedure Remove(Index: Integer); dispid 84;
    property RawTable: IUnknown readonly dispid 1;
    property _Item[Index: OleVariant]: IRDORecipient readonly dispid 0; default;
    function Item(Index: OleVariant): IRDORecipient; dispid 4;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 2;
    function AddEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant; 
                   Type_: OleVariant): IRDORecipient; dispid 3;
    function ResolveAll(ShowDialog: OleVariant; ParentWndHandle: OleVariant): WordBool; dispid 5;
    procedure Clear; dispid 6;
    function GetFirst: IRDORecipient; dispid 1610743821;
    function GetLast: IRDORecipient; dispid 1610743822;
    function GetNext: IRDORecipient; dispid 1610743823;
    function GetPrevious: IRDORecipient; dispid 1610743824;
  end;

// *********************************************************************//
// Interface: IRDORecipient
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E4D07F9-3E3F-4469-9181-6E09593A03D2}
// *********************************************************************//
  IRDORecipient = interface(IDispatch)
    ['{6E4D07F9-3E3F-4469-9181-6E09593A03D2}']
    function Get_Session: IRDOSession; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_AddressEntry: IRDOAddressEntry; safecall;
    function Get_DisplayType: Integer; safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Index: Integer; safecall;
    function Get_Resolved: WordBool; safecall;
    function Get_type_: Integer; safecall;
    procedure Set_type_(Type_: Integer); safecall;
    procedure Delete; safecall;
    function Resolve(ShowDialog: OleVariant; ParentWndHandle: OleVariant): WordBool; safecall;
    function Get_Fields(PropTag: OleVariant): OleVariant; safecall;
    procedure Set_Fields(PropTag: OleVariant; Value: OleVariant); safecall;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; safecall;
    function Get_AutoResponse: WideString; safecall;
    procedure Set_AutoResponse(const Value: WideString); safecall;
    function Get_MeetingResponseStatus: Integer; safecall;
    function Get_TrackingStatus: Integer; safecall;
    procedure Set_TrackingStatus(Value: Integer); safecall;
    function Get_TrackingStatusTime: TDateTime; safecall;
    procedure Set_TrackingStatusTime(Value: TDateTime); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Address: WideString; safecall;
    procedure Set_Address(const Value: WideString); safecall;
    function Get_SendRichInfo: WordBool; safecall;
    procedure Set_SendRichInfo(retVal: WordBool); safecall;
    property Session: IRDOSession read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property AddressEntry: IRDOAddressEntry read Get_AddressEntry;
    property DisplayType: Integer read Get_DisplayType;
    property EntryID: WideString read Get_EntryID;
    property Index: Integer read Get_Index;
    property Resolved: WordBool read Get_Resolved;
    property type_: Integer read Get_type_ write Set_type_;
    property Fields[PropTag: OleVariant]: OleVariant read Get_Fields write Set_Fields;
    property AutoResponse: WideString read Get_AutoResponse write Set_AutoResponse;
    property MeetingResponseStatus: Integer read Get_MeetingResponseStatus;
    property TrackingStatus: Integer read Get_TrackingStatus write Set_TrackingStatus;
    property TrackingStatusTime: TDateTime read Get_TrackingStatusTime write Set_TrackingStatusTime;
    property Name: WideString read Get_Name write Set_Name;
    property Address: WideString read Get_Address write Set_Address;
    property SendRichInfo: WordBool read Get_SendRichInfo write Set_SendRichInfo;
  end;

// *********************************************************************//
// DispIntf:  IRDORecipientDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E4D07F9-3E3F-4469-9181-6E09593A03D2}
// *********************************************************************//
  IRDORecipientDisp = dispinterface
    ['{6E4D07F9-3E3F-4469-9181-6E09593A03D2}']
    property Session: IRDOSession readonly dispid 61451;
    property Parent: IDispatch readonly dispid 109;
    property AddressEntry: IRDOAddressEntry readonly dispid 121;
    property DisplayType: Integer readonly dispid 14592;
    property EntryID: WideString readonly dispid 61470;
    property Index: Integer readonly dispid 91;
    property Resolved: WordBool readonly dispid 100;
    property type_: Integer dispid 3093;
    procedure Delete; dispid 110;
    function Resolve(ShowDialog: OleVariant; ParentWndHandle: OleVariant): WordBool; dispid 113;
    property Fields[PropTag: OleVariant]: OleVariant dispid 1;
    function FreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 2;
    property AutoResponse: WideString dispid 3;
    property MeetingResponseStatus: Integer readonly dispid 4;
    property TrackingStatus: Integer dispid 5;
    property TrackingStatusTime: TDateTime dispid 6;
    property Name: WideString dispid 7;
    property Address: WideString dispid 8;
    property SendRichInfo: WordBool dispid 1610743833;
  end;

// *********************************************************************//
// Interface: IRDOAddressEntry
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4819D689-AFDF-4A6D-8CD5-6B0D484FE9D1}
// *********************************************************************//
  IRDOAddressEntry = interface(_MAPIProp)
    ['{4819D689-AFDF-4A6D-8CD5-6B0D484FE9D1}']
    function Get_Address: WideString; safecall;
    procedure Set_Address(const Address: WideString); safecall;
    function Get_DisplayType: Integer; safecall;
    function Get_EntryID: WideString; safecall;
    function Get_Manager: IRDOAddressEntry; safecall;
    function Get_Members: IRDOAddressEntries; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Name: WideString); safecall;
    function Get_type_: WideString; safecall;
    procedure Set_type_(const Type_: WideString); safecall;
    procedure Delete; safecall;
    procedure Details(HWnd: OleVariant); safecall;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; safecall;
    procedure UpdateFreeBusy; safecall;
    function Get_SMTPAddress: WideString; safecall;
    function Get_IsMemberOfDL: IRDOAddressEntries; safecall;
    function Get_IsDelegateFor: IRDOAddressEntries; safecall;
    function Get_Delegates: IRDOAddressEntries; safecall;
    function Get_Reports: IRDOAddressEntries; safecall;
    function GetContact: IRDOContactItem; safecall;
    function Get_FreeBusyList: IRDOFreeBusyRange; safecall;
    property Address: WideString read Get_Address write Set_Address;
    property DisplayType: Integer read Get_DisplayType;
    property EntryID: WideString read Get_EntryID;
    property Manager: IRDOAddressEntry read Get_Manager;
    property Members: IRDOAddressEntries read Get_Members;
    property Name: WideString read Get_Name write Set_Name;
    property type_: WideString read Get_type_ write Set_type_;
    property SMTPAddress: WideString read Get_SMTPAddress;
    property IsMemberOfDL: IRDOAddressEntries read Get_IsMemberOfDL;
    property IsDelegateFor: IRDOAddressEntries read Get_IsDelegateFor;
    property Delegates: IRDOAddressEntries read Get_Delegates;
    property Reports: IRDOAddressEntries read Get_Reports;
    property FreeBusyList: IRDOFreeBusyRange read Get_FreeBusyList;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressEntryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4819D689-AFDF-4A6D-8CD5-6B0D484FE9D1}
// *********************************************************************//
  IRDOAddressEntryDisp = dispinterface
    ['{4819D689-AFDF-4A6D-8CD5-6B0D484FE9D1}']
    property Address: WideString dispid 12291;
    property DisplayType: Integer readonly dispid 14592;
    property EntryID: WideString readonly dispid 61470;
    property Manager: IRDOAddressEntry readonly dispid 771;
    property Members: IRDOAddressEntries readonly dispid 772;
    property Name: WideString dispid 0;
    property type_: WideString dispid 12290;
    procedure Delete; dispid 770;
    procedure Details(HWnd: OleVariant); dispid 769;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; dispid 774;
    procedure UpdateFreeBusy; dispid 775;
    property SMTPAddress: WideString readonly dispid 7;
    property IsMemberOfDL: IRDOAddressEntries readonly dispid 8;
    property IsDelegateFor: IRDOAddressEntries readonly dispid 9;
    property Delegates: IRDOAddressEntries readonly dispid 10;
    property Reports: IRDOAddressEntries readonly dispid 11;
    function GetContact: IRDOContactItem; dispid 1610809363;
    property FreeBusyList: IRDOFreeBusyRange readonly dispid 1610809364;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOAddressEntries
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31AEB3B1-8CB7-490F-A0DC-AB76F0C56483}
// *********************************************************************//
  IRDOAddressEntries = interface(IDispatch)
    ['{31AEB3B1-8CB7-490F-A0DC-AB76F0C56483}']
    function Get_Count: Integer; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    function GetFirst: IRDOAddressEntry; safecall;
    function GetLast: IRDOAddressEntry; safecall;
    function GetNext: IRDOAddressEntry; safecall;
    function GetPrevious: IRDOAddressEntry; safecall;
    function Item(Index: OleVariant): IRDOAddressEntry; safecall;
    function Get__Item(Index: OleVariant): IRDOAddressEntry; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IRDOSession read Get_Session;
    property _Item[Index: OleVariant]: IRDOAddressEntry read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressEntriesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31AEB3B1-8CB7-490F-A0DC-AB76F0C56483}
// *********************************************************************//
  IRDOAddressEntriesDisp = dispinterface
    ['{31AEB3B1-8CB7-490F-A0DC-AB76F0C56483}']
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function GetFirst: IRDOAddressEntry; dispid 5;
    function GetLast: IRDOAddressEntry; dispid 6;
    function GetNext: IRDOAddressEntry; dispid 7;
    function GetPrevious: IRDOAddressEntry; dispid 8;
    function Item(Index: OleVariant): IRDOAddressEntry; dispid 9;
    property _Item[Index: OleVariant]: IRDOAddressEntry readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
  end;

// *********************************************************************//
// Interface: IRDOAddressList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EB3836E5-3937-4E85-9FF9-93F7E659052C}
// *********************************************************************//
  IRDOAddressList = interface(_MAPIProp)
    ['{EB3836E5-3937-4E85-9FF9-93F7E659052C}']
    function Get_EntryID: WideString; safecall;
    function Get_AddressEntries: IRDOAddressEntries; safecall;
    function Get_AddressLists: IRDOAddressLists; safecall;
    function Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_IsReadOnly: WordBool; safecall;
    function ResolveName(const Name: WideString): IRDOAddressEntry; safecall;
    function GetContactsFolder: IRDOFolder; safecall;
    property EntryID: WideString read Get_EntryID;
    property AddressEntries: IRDOAddressEntries read Get_AddressEntries;
    property AddressLists: IRDOAddressLists read Get_AddressLists;
    property Default: WordBool read Get_Default write Set_Default;
    property Name: WideString read Get_Name write Set_Name;
    property IsReadOnly: WordBool read Get_IsReadOnly;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EB3836E5-3937-4E85-9FF9-93F7E659052C}
// *********************************************************************//
  IRDOAddressListDisp = dispinterface
    ['{EB3836E5-3937-4E85-9FF9-93F7E659052C}']
    property EntryID: WideString readonly dispid 7;
    property AddressEntries: IRDOAddressEntries readonly dispid 8;
    property AddressLists: IRDOAddressLists readonly dispid 9;
    property Default: WordBool dispid 10;
    property Name: WideString dispid 11;
    property IsReadOnly: WordBool readonly dispid 12;
    function ResolveName(const Name: WideString): IRDOAddressEntry; dispid 13;
    function GetContactsFolder: IRDOFolder; dispid 1610809353;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOAddressLists
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C8E7C686-F6C5-4023-82F6-F53C9EFAC528}
// *********************************************************************//
  IRDOAddressLists = interface(IDispatch)
    ['{C8E7C686-F6C5-4023-82F6-F53C9EFAC528}']
    function Get_Count: Integer; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    function GetFirst: IRDOAddressList; safecall;
    function GetLast: IRDOAddressList; safecall;
    function GetNext: IRDOAddressList; safecall;
    function GetPrevious: IRDOAddressList; safecall;
    function Item(Index: OleVariant): IRDOAddressList; safecall;
    function Get__Item(Index: OleVariant): IRDOAddressList; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    property Count: Integer read Get_Count;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IRDOSession read Get_Session;
    property _Item[Index: OleVariant]: IRDOAddressList read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressListsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C8E7C686-F6C5-4023-82F6-F53C9EFAC528}
// *********************************************************************//
  IRDOAddressListsDisp = dispinterface
    ['{C8E7C686-F6C5-4023-82F6-F53C9EFAC528}']
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function GetFirst: IRDOAddressList; dispid 5;
    function GetLast: IRDOAddressList; dispid 6;
    function GetNext: IRDOAddressList; dispid 7;
    function GetPrevious: IRDOAddressList; dispid 8;
    function Item(Index: OleVariant): IRDOAddressList; dispid 9;
    property _Item[Index: OleVariant]: IRDOAddressList readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
  end;

// *********************************************************************//
// Interface: IRDOAddressBookSearchPath
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EBCB6987-CB48-4083-87DA-D5EDA11FA2C3}
// *********************************************************************//
  IRDOAddressBookSearchPath = interface(IDispatch)
    ['{EBCB6987-CB48-4083-87DA-D5EDA11FA2C3}']
    function Get_Item(Index: Integer): IRDOAddressList; safecall;
    function Get_Count: Integer; safecall;
    procedure Add(AddressListOrEntryID: OleVariant); safecall;
    procedure Remove(AddressListOrEntryIdOrIndex: OleVariant); safecall;
    function IndexOf(AddressListOrEntryID: OleVariant): Integer; safecall;
    procedure SetIndex(AddressListOrEntryID: OleVariant; Index: Integer); safecall;
    property Item[Index: Integer]: IRDOAddressList read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IRDOAddressBookSearchPathDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EBCB6987-CB48-4083-87DA-D5EDA11FA2C3}
// *********************************************************************//
  IRDOAddressBookSearchPathDisp = dispinterface
    ['{EBCB6987-CB48-4083-87DA-D5EDA11FA2C3}']
    property Item[Index: Integer]: IRDOAddressList readonly dispid 0; default;
    property Count: Integer readonly dispid 2;
    procedure Add(AddressListOrEntryID: OleVariant); dispid 4;
    procedure Remove(AddressListOrEntryIdOrIndex: OleVariant); dispid 5;
    function IndexOf(AddressListOrEntryID: OleVariant): Integer; dispid 6;
    procedure SetIndex(AddressListOrEntryID: OleVariant; Index: Integer); dispid 7;
  end;

// *********************************************************************//
// Interface: IRDODeletedItems
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E22045A6-092A-4CCC-860D-0C93CD6AB778}
// *********************************************************************//
  IRDODeletedItems = interface(IRDOItems)
    ['{E22045A6-092A-4CCC-860D-0C93CD6AB778}']
    function Restore(Index: OleVariant): IRDOMail; safecall;
  end;

// *********************************************************************//
// DispIntf:  IRDODeletedItemsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E22045A6-092A-4CCC-860D-0C93CD6AB778}
// *********************************************************************//
  IRDODeletedItemsDisp = dispinterface
    ['{E22045A6-092A-4CCC-860D-0C93CD6AB778}']
    function Restore(Index: OleVariant): IRDOMail; dispid 12;
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function Add(Type_: OleVariant): IRDOMail; dispid 4;
    function GetFirst: IRDOMail; dispid 5;
    function GetLast: IRDOMail; dispid 6;
    function GetNext: IRDOMail; dispid 7;
    function GetPrevious: IRDOMail; dispid 8;
    function Item(Index: OleVariant): IRDOMail; dispid 9;
    property _Item[Index: OleVariant]: IRDOMail readonly dispid 0; default;
    procedure Remove(Index: Integer; DeleteFlags: OleVariant); dispid 11;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
    function _Restore(Index: OleVariant): IRDOMail; dispid 1610743821;
    function Find(const Filter: WideString): IRDOMail; dispid 1610743822;
    function FindNext: IRDOMail; dispid 1610743823;
    function Restrict(const Filter: WideString): IRDOItems; dispid 1610743824;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); dispid 1610743825;
  end;

// *********************************************************************//
// Interface: IRDOSearchFolder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E8341D4-E4A2-4071-B9AD-E2D793136647}
// *********************************************************************//
  IRDOSearchFolder = interface(IRDOFolder)
    ['{3E8341D4-E4A2-4071-B9AD-E2D793136647}']
    function Get_SearchCriteria: IRDOFolderSearchCriteria; safecall;
    function Get_SearchContainers: IRDOSearchContainersList; safecall;
    function Get_IsRecursiveSearch: WordBool; safecall;
    procedure Set_IsRecursiveSearch(Value: WordBool); safecall;
    function Get_IsForegroundSearch: WordBool; safecall;
    procedure Set_IsForegroundSearch(Value: WordBool); safecall;
    procedure Start; safecall;
    procedure Stop; safecall;
    function Get_IsRunning: WordBool; safecall;
    function Get_IsRebuild: WordBool; safecall;
    function Get_FolderPath: WideString; safecall;
    property SearchCriteria: IRDOFolderSearchCriteria read Get_SearchCriteria;
    property SearchContainers: IRDOSearchContainersList read Get_SearchContainers;
    property IsRecursiveSearch: WordBool read Get_IsRecursiveSearch write Set_IsRecursiveSearch;
    property IsForegroundSearch: WordBool read Get_IsForegroundSearch write Set_IsForegroundSearch;
    property IsRunning: WordBool read Get_IsRunning;
    property IsRebuild: WordBool read Get_IsRebuild;
    property FolderPath: WideString read Get_FolderPath;
  end;

// *********************************************************************//
// DispIntf:  IRDOSearchFolderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E8341D4-E4A2-4071-B9AD-E2D793136647}
// *********************************************************************//
  IRDOSearchFolderDisp = dispinterface
    ['{3E8341D4-E4A2-4071-B9AD-E2D793136647}']
    property SearchCriteria: IRDOFolderSearchCriteria readonly dispid 24;
    property SearchContainers: IRDOSearchContainersList readonly dispid 28;
    property IsRecursiveSearch: WordBool dispid 31;
    property IsForegroundSearch: WordBool dispid 32;
    procedure Start; dispid 33;
    procedure Stop; dispid 34;
    property IsRunning: WordBool readonly dispid 35;
    property IsRebuild: WordBool readonly dispid 36;
    property FolderPath: WideString readonly dispid 1610874890;
    property DefaultMessageClass: WideString readonly dispid 7;
    property Description: WideString dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 0;
    property Parent: IRDOFolder readonly dispid 11;
    property StoreID: WideString readonly dispid 12;
    property UnReadItemCount: Integer readonly dispid 13;
    property Items: IRDOItems readonly dispid 17;
    property Folders: IRDOFolders readonly dispid 18;
    procedure Delete; dispid 20;
    function MoveTo(const DestinationFolder: IRDOFolder): IRDOFolder; dispid 21;
    property HiddenItems: IRDOItems readonly dispid 23;
    property Store: IRDOStore readonly dispid 14;
    property AddressBookName: WideString dispid 15;
    property ShowAsOutlookAB: WordBool dispid 16;
    property DefaultItemType: Integer readonly dispid 22;
    property WebViewAllowNavigation: WordBool dispid 25;
    property WebViewOn: WordBool dispid 26;
    property WebViewURL: WideString dispid 27;
    property DeletedItems: IRDODeletedItems readonly dispid 19;
    property FolderKind: rdoFolderKind readonly dispid 124;
    property ACL: IRDOACL readonly dispid 128;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOFolderSearchCriteria
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E521CAC7-3A02-4BF4-91BD-4B409C3B8655}
// *********************************************************************//
  IRDOFolderSearchCriteria = interface(IDispatch)
    ['{E521CAC7-3A02-4BF4-91BD-4B409C3B8655}']
    procedure Clear; safecall;
    function Get_Restriction: _IRestriction; safecall;
    function SetKind(Kind: RestrictionKind): _IRestriction; safecall;
    function Get_AsSQL: WideString; safecall;
    procedure Set_AsSQL(const retVal: WideString); safecall;
    property Restriction: _IRestriction read Get_Restriction;
    property AsSQL: WideString read Get_AsSQL write Set_AsSQL;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolderSearchCriteriaDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E521CAC7-3A02-4BF4-91BD-4B409C3B8655}
// *********************************************************************//
  IRDOFolderSearchCriteriaDisp = dispinterface
    ['{E521CAC7-3A02-4BF4-91BD-4B409C3B8655}']
    procedure Clear; dispid 1;
    property Restriction: _IRestriction readonly dispid 3;
    function SetKind(Kind: RestrictionKind): _IRestriction; dispid 4;
    property AsSQL: WideString dispid 1610743811;
  end;

// *********************************************************************//
// Interface: IRDOSearchContainersList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BB039345-30DF-4E1A-ADC5-7542CB083924}
// *********************************************************************//
  IRDOSearchContainersList = interface(IDispatch)
    ['{BB039345-30DF-4E1A-ADC5-7542CB083924}']
    function Get_Count: Integer; safecall;
    procedure Add(FolderOrEntryID: OleVariant); safecall;
    function Get__Item(Index: Integer): IRDOFolder; safecall;
    function Item(Index: Integer): IRDOFolder; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOFolder read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOSearchContainersListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BB039345-30DF-4E1A-ADC5-7542CB083924}
// *********************************************************************//
  IRDOSearchContainersListDisp = dispinterface
    ['{BB039345-30DF-4E1A-ADC5-7542CB083924}']
    property Count: Integer readonly dispid 1;
    procedure Add(FolderOrEntryID: OleVariant); dispid 3;
    property _Item[Index: Integer]: IRDOFolder readonly dispid 0; default;
    function Item(Index: Integer): IRDOFolder; dispid 5;
    procedure Remove(Index: Integer); dispid 6;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOACL
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8EA8008E-2C1D-4BE2-97D5-ABB9CEAB7CB3}
// *********************************************************************//
  IRDOACL = interface(IDispatch)
    ['{8EA8008E-2C1D-4BE2-97D5-ABB9CEAB7CB3}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: Integer): IRDOACE; safecall;
    function Item(Index: Integer): IRDOACE; safecall;
    function Add(AddressEntryObjOrEntryID: OleVariant): IRDOACE; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Folder: IRDOFolder; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_Session: IRDOSession; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function ACEofAddressEntry(AddressEntryObjOrEntryID: OleVariant): IRDOACE; safecall;
    function GetFirst: IRDOACE; safecall;
    function GetLast: IRDOACE; safecall;
    function GetNext: IRDOACE; safecall;
    function GetPrevious: IRDOACE; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOACE read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Folder: IRDOFolder read Get_Folder;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IRDOSession read Get_Session;
    property MAPITable: _IMAPITable read Get_MAPITable;
  end;

// *********************************************************************//
// DispIntf:  IRDOACLDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8EA8008E-2C1D-4BE2-97D5-ABB9CEAB7CB3}
// *********************************************************************//
  IRDOACLDisp = dispinterface
    ['{8EA8008E-2C1D-4BE2-97D5-ABB9CEAB7CB3}']
    property Count: Integer readonly dispid 1;
    property _Item[Index: Integer]: IRDOACE readonly dispid 0; default;
    function Item(Index: Integer): IRDOACE; dispid 3;
    function Add(AddressEntryObjOrEntryID: OleVariant): IRDOACE; dispid 4;
    procedure Remove(Index: Integer); dispid 5;
    property _NewEnum: IUnknown readonly dispid -4;
    property Folder: IRDOFolder readonly dispid 7;
    property RawTable: IUnknown readonly dispid 8;
    property Session: IRDOSession readonly dispid 9;
    property MAPITable: _IMAPITable readonly dispid 10;
    function ACEofAddressEntry(AddressEntryObjOrEntryID: OleVariant): IRDOACE; dispid 11;
    function GetFirst: IRDOACE; dispid 1610743819;
    function GetLast: IRDOACE; dispid 1610743820;
    function GetNext: IRDOACE; dispid 1610743821;
    function GetPrevious: IRDOACE; dispid 1610743822;
  end;

// *********************************************************************//
// Interface: IRDOACE
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {90A06D07-4034-40FA-B259-04A0214352DB}
// *********************************************************************//
  IRDOACE = interface(IDispatch)
    ['{90A06D07-4034-40FA-B259-04A0214352DB}']
    function Get_MemberID: Int64; safecall;
    function Get_EntryID: WideString; safecall;
    function Get_AddressEntry: IRDOAddressEntry; safecall;
    procedure Delete; safecall;
    function Get_Name: WideString; safecall;
    function Get_Rights: rdoAccessRights; safecall;
    procedure Set_Rights(Value: rdoAccessRights); safecall;
    function Get_CanEditOwn: WordBool; safecall;
    procedure Set_CanEditOwn(Value: WordBool); safecall;
    function Get_CanDeleteOwn: WordBool; safecall;
    procedure Set_CanDeleteOwn(Value: WordBool); safecall;
    function Get_CanEditAll: WordBool; safecall;
    procedure Set_CanEditAll(Value: WordBool); safecall;
    function Get_CanDeleteAll: WordBool; safecall;
    procedure Set_CanDeleteAll(Value: WordBool); safecall;
    function Get_CanReadItems: WordBool; safecall;
    procedure Set_CanReadItems(Value: WordBool); safecall;
    function Get_CanCreateItems: WordBool; safecall;
    procedure Set_CanCreateItems(Value: WordBool); safecall;
    function Get_CanCreateSubFolders: WordBool; safecall;
    procedure Set_CanCreateSubFolders(Value: WordBool); safecall;
    function Get_IsFolderOwner: WordBool; safecall;
    procedure Set_IsFolderOwner(Value: WordBool); safecall;
    function Get_IsFolderContact: WordBool; safecall;
    procedure Set_IsFolderContact(Value: WordBool); safecall;
    function Get_IsFolderVisible: WordBool; safecall;
    procedure Set_IsFolderVisible(Value: WordBool); safecall;
    property MemberID: Int64 read Get_MemberID;
    property EntryID: WideString read Get_EntryID;
    property AddressEntry: IRDOAddressEntry read Get_AddressEntry;
    property Name: WideString read Get_Name;
    property Rights: rdoAccessRights read Get_Rights write Set_Rights;
    property CanEditOwn: WordBool read Get_CanEditOwn write Set_CanEditOwn;
    property CanDeleteOwn: WordBool read Get_CanDeleteOwn write Set_CanDeleteOwn;
    property CanEditAll: WordBool read Get_CanEditAll write Set_CanEditAll;
    property CanDeleteAll: WordBool read Get_CanDeleteAll write Set_CanDeleteAll;
    property CanReadItems: WordBool read Get_CanReadItems write Set_CanReadItems;
    property CanCreateItems: WordBool read Get_CanCreateItems write Set_CanCreateItems;
    property CanCreateSubFolders: WordBool read Get_CanCreateSubFolders write Set_CanCreateSubFolders;
    property IsFolderOwner: WordBool read Get_IsFolderOwner write Set_IsFolderOwner;
    property IsFolderContact: WordBool read Get_IsFolderContact write Set_IsFolderContact;
    property IsFolderVisible: WordBool read Get_IsFolderVisible write Set_IsFolderVisible;
  end;

// *********************************************************************//
// DispIntf:  IRDOACEDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {90A06D07-4034-40FA-B259-04A0214352DB}
// *********************************************************************//
  IRDOACEDisp = dispinterface
    ['{90A06D07-4034-40FA-B259-04A0214352DB}']
    property MemberID: {??Int64}OleVariant readonly dispid 1;
    property EntryID: WideString readonly dispid 2;
    property AddressEntry: IRDOAddressEntry readonly dispid 3;
    procedure Delete; dispid 4;
    property Name: WideString readonly dispid 5;
    property Rights: rdoAccessRights dispid 6;
    property CanEditOwn: WordBool dispid 7;
    property CanDeleteOwn: WordBool dispid 8;
    property CanEditAll: WordBool dispid 9;
    property CanDeleteAll: WordBool dispid 10;
    property CanReadItems: WordBool dispid 11;
    property CanCreateItems: WordBool dispid 12;
    property CanCreateSubFolders: WordBool dispid 13;
    property IsFolderOwner: WordBool dispid 14;
    property IsFolderContact: WordBool dispid 15;
    property IsFolderVisible: WordBool dispid 16;
  end;

// *********************************************************************//
// Interface: IRDOOutOfOfficeAssistant
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {94D01B27-C94A-4C66-92EF-7C2339AB4585}
// *********************************************************************//
  IRDOOutOfOfficeAssistant = interface(IDispatch)
    ['{94D01B27-C94A-4C66-92EF-7C2339AB4585}']
    function Get_OutOfOfficeText: WideString; safecall;
    procedure Set_OutOfOfficeText(const Value: WideString); safecall;
    function Get_OutOfOffice: WordBool; safecall;
    procedure Set_OutOfOffice(Value: WordBool); safecall;
    function Get_OutOfOfficeMessage: IRDOMail; safecall;
    property OutOfOfficeText: WideString read Get_OutOfOfficeText write Set_OutOfOfficeText;
    property OutOfOffice: WordBool read Get_OutOfOffice write Set_OutOfOffice;
    property OutOfOfficeMessage: IRDOMail read Get_OutOfOfficeMessage;
  end;

// *********************************************************************//
// DispIntf:  IRDOOutOfOfficeAssistantDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {94D01B27-C94A-4C66-92EF-7C2339AB4585}
// *********************************************************************//
  IRDOOutOfOfficeAssistantDisp = dispinterface
    ['{94D01B27-C94A-4C66-92EF-7C2339AB4585}']
    property OutOfOfficeText: WideString dispid 1;
    property OutOfOffice: WordBool dispid 2;
    property OutOfOfficeMessage: IRDOMail readonly dispid 3;
  end;

// *********************************************************************//
// Interface: IRDOReminders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BE5243B8-827F-4391-BCDF-443C6898617D}
// *********************************************************************//
  IRDOReminders = interface(IDispatch)
    ['{BE5243B8-827F-4391-BCDF-443C6898617D}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: Integer): IRDOReminder; safecall;
    function Item(Index: Integer): IRDOReminder; safecall;
    function Get_SearchFolder: IRDOSearchFolder; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get_Store: IRDOStore; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOReminder read Get__Item; default;
    property SearchFolder: IRDOSearchFolder read Get_SearchFolder;
    property Store: IRDOStore read Get_Store;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDORemindersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BE5243B8-827F-4391-BCDF-443C6898617D}
// *********************************************************************//
  IRDORemindersDisp = dispinterface
    ['{BE5243B8-827F-4391-BCDF-443C6898617D}']
    property Count: Integer readonly dispid 2;
    property _Item[Index: Integer]: IRDOReminder readonly dispid 0; default;
    function Item(Index: Integer): IRDOReminder; dispid 4;
    property SearchFolder: IRDOSearchFolder readonly dispid 5;
    procedure Remove(Index: Integer); dispid 6;
    property Store: IRDOStore readonly dispid 7;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOReminder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C2A1BF29-7F9E-406C-BA70-83B433366213}
// *********************************************************************//
  IRDOReminder = interface(IDispatch)
    ['{C2A1BF29-7F9E-406C-BA70-83B433366213}']
    function Get_Caption: WideString; safecall;
    function Get_IsVisible: WordBool; safecall;
    function Get_Item: IRDOMail; safecall;
    function Get_NextReminderDate: TDateTime; safecall;
    function Get_OriginalReminderDate: TDateTime; safecall;
    procedure Dismiss; safecall;
    procedure Snooze(SnoozeTime: OleVariant); safecall;
    property Caption: WideString read Get_Caption;
    property IsVisible: WordBool read Get_IsVisible;
    property Item: IRDOMail read Get_Item;
    property NextReminderDate: TDateTime read Get_NextReminderDate;
    property OriginalReminderDate: TDateTime read Get_OriginalReminderDate;
  end;

// *********************************************************************//
// DispIntf:  IRDOReminderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C2A1BF29-7F9E-406C-BA70-83B433366213}
// *********************************************************************//
  IRDOReminderDisp = dispinterface
    ['{C2A1BF29-7F9E-406C-BA70-83B433366213}']
    property Caption: WideString readonly dispid 1;
    property IsVisible: WordBool readonly dispid 2;
    property Item: IRDOMail readonly dispid 3;
    property NextReminderDate: TDateTime readonly dispid 4;
    property OriginalReminderDate: TDateTime readonly dispid 5;
    procedure Dismiss; dispid 6;
    procedure Snooze(SnoozeTime: OleVariant); dispid 7;
  end;

// *********************************************************************//
// Interface: IRDOAccounts
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FF711B41-292B-4DE7-9F0E-96467A4E0D35}
// *********************************************************************//
  IRDOAccounts = interface(IDispatch)
    ['{FF711B41-292B-4DE7-9F0E-96467A4E0D35}']
    function Get_Session: IRDOSession; safecall;
    function Get_Count: Integer; safecall;
    function Item(Index: OleVariant): IRDOAccount; safecall;
    function Get__Item(Index: OleVariant): IRDOAccount; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Remove(Index: OleVariant); safecall;
    function GetOrder(AccountCategory: rdoAccountCategory): IRDOAccountOrderList; safecall;
    property Session: IRDOSession read Get_Session;
    property Count: Integer read Get_Count;
    property _Item[Index: OleVariant]: IRDOAccount read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOAccountsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FF711B41-292B-4DE7-9F0E-96467A4E0D35}
// *********************************************************************//
  IRDOAccountsDisp = dispinterface
    ['{FF711B41-292B-4DE7-9F0E-96467A4E0D35}']
    property Session: IRDOSession readonly dispid 1;
    property Count: Integer readonly dispid 3;
    function Item(Index: OleVariant): IRDOAccount; dispid 4;
    property _Item[Index: OleVariant]: IRDOAccount readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Remove(Index: OleVariant); dispid 7;
    function GetOrder(AccountCategory: rdoAccountCategory): IRDOAccountOrderList; dispid 2;
  end;

// *********************************************************************//
// DispIntf:  IRDOAccountsEvents
// Flags:     (4096) Dispatchable
// GUID:      {6B8E3F2F-8AAE-4482-8492-4BBBF71000CE}
// *********************************************************************//
  IRDOAccountsEvents = dispinterface
    ['{6B8E3F2F-8AAE-4482-8492-4BBBF71000CE}']
    procedure AccountChange(const Account: IRDOAccount); dispid 1;
    procedure AccountAdd(const Account: IRDOAccount); dispid 2;
    procedure AccountRemove(AccountID: Integer); dispid 3;
    procedure AccountBeforeRemove(const Account: IRDOAccount); dispid 4;
    procedure AccountOrderChange; dispid 5;
  end;

// *********************************************************************//
// Interface: IRDOAccount
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {396D96A3-D780-48B2-9556-866E1F1604D6}
// *********************************************************************//
  IRDOAccount = interface(IDispatch)
    ['{396D96A3-D780-48B2-9556-866E1F1604D6}']
    function Get_Session: IRDOSession; safecall;
    function Get_AccountType: rdoAccountType; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_ID: Integer; safecall;
    function Get_Stamp: WideString; safecall;
    function Get_SendStamp: WideString; safecall;
    function Get_IsExchange: WordBool; safecall;
    procedure Delete; safecall;
    function Get_Fields(PropTag: Integer): OleVariant; safecall;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant); safecall;
    procedure Save; safecall;
    function Get_AccountCategories: Integer; safecall;
    function Get_AccountTypeStr: WideString; safecall;
    function Get__ReserverdProp1: Integer; safecall;
    procedure Set__ReserverdProp1(Value: Integer); safecall;
    function Get__ReservedProp2: Integer; safecall;
    procedure Set__ReservedProp2(Value: Integer); safecall;
    function Get__ReservedProp3: Integer; safecall;
    procedure Set__ReservedProp3(Value: Integer); safecall;
    function Get__ReservedProp4: Integer; safecall;
    procedure Set__ReservedProp4(Value: Integer); safecall;
    function Get__ReservedProp5: Integer; safecall;
    procedure Set__ReservedProp5(Value: Integer); safecall;
    procedure _ReservedMethod1; safecall;
    procedure _ReservedMethod2; safecall;
    procedure _ReservedMethod3; safecall;
    procedure _ReservedMethod4; safecall;
    procedure _ReservedMethod5; safecall;
    property Session: IRDOSession read Get_Session;
    property AccountType: rdoAccountType read Get_AccountType;
    property Name: WideString read Get_Name write Set_Name;
    property ID: Integer read Get_ID;
    property Stamp: WideString read Get_Stamp;
    property SendStamp: WideString read Get_SendStamp;
    property IsExchange: WordBool read Get_IsExchange;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property AccountCategories: Integer read Get_AccountCategories;
    property AccountTypeStr: WideString read Get_AccountTypeStr;
    property _ReserverdProp1: Integer read Get__ReserverdProp1 write Set__ReserverdProp1;
    property _ReservedProp2: Integer read Get__ReservedProp2 write Set__ReservedProp2;
    property _ReservedProp3: Integer read Get__ReservedProp3 write Set__ReservedProp3;
    property _ReservedProp4: Integer read Get__ReservedProp4 write Set__ReservedProp4;
    property _ReservedProp5: Integer read Get__ReservedProp5 write Set__ReservedProp5;
  end;

// *********************************************************************//
// DispIntf:  IRDOAccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {396D96A3-D780-48B2-9556-866E1F1604D6}
// *********************************************************************//
  IRDOAccountDisp = dispinterface
    ['{396D96A3-D780-48B2-9556-866E1F1604D6}']
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOPOP3Account
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA7B67A0-E213-49BD-9369-3E9970245286}
// *********************************************************************//
  IRDOPOP3Account = interface(IRDOAccount)
    ['{EA7B67A0-E213-49BD-9369-3E9970245286}']
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_SMTPAddress: WideString; safecall;
    procedure Set_SMTPAddress(const Value: WideString); safecall;
    function Get_POP3_Server: WideString; safecall;
    procedure Set_POP3_Server(const Value: WideString); safecall;
    function Get_POP3_UserName: WideString; safecall;
    procedure Set_POP3_UserName(const Value: WideString); safecall;
    function Get_ReplyAddress: WideString; safecall;
    procedure Set_ReplyAddress(const Value: WideString); safecall;
    function Get_POP3_Port: Integer; safecall;
    procedure Set_POP3_Port(Value: Integer); safecall;
    function Get_POP3_UseSSL: WordBool; safecall;
    procedure Set_POP3_UseSSL(Value: WordBool); safecall;
    function Get_POP3_RememberPassword: WordBool; safecall;
    procedure Set_POP3_RememberPassword(Value: WordBool); safecall;
    function Get_Organization: WideString; safecall;
    procedure Set_Organization(const Value: WideString); safecall;
    function Get_POP3_UseSPA: WordBool; safecall;
    procedure Set_POP3_UseSPA(Value: WordBool); safecall;
    function Get_SMTP_Server: WideString; safecall;
    procedure Set_SMTP_Server(const Value: WideString); safecall;
    function Get_SMTP_Port: Integer; safecall;
    procedure Set_SMTP_Port(Value: Integer); safecall;
    function Get_SMTP_UseSSL: WordBool; safecall;
    procedure Set_SMTP_UseSSL(Value: WordBool); safecall;
    function Get_SMTP_UseAuth: WordBool; safecall;
    procedure Set_SMTP_UseAuth(Value: WordBool); safecall;
    function Get_SMTP_UserName: WideString; safecall;
    procedure Set_SMTP_UserName(const Value: WideString); safecall;
    function Get_SMTP_UseSPA: WordBool; safecall;
    procedure Set_SMTP_UseSPA(Value: WordBool); safecall;
    function Get_TimeOut: Integer; safecall;
    procedure Set_TimeOut(Value: Integer); safecall;
    function Get_LeaveMessagesOnServer: WordBool; safecall;
    procedure Set_LeaveMessagesOnServer(Value: WordBool); safecall;
    function Get_DeleteFromServerWhenDeletedLocally: WordBool; safecall;
    procedure Set_DeleteFromServerWhenDeletedLocally(Value: WordBool); safecall;
    function Get_DeleteFromServerAfterXDays: WordBool; safecall;
    procedure Set_DeleteFromServerAfterXDays(Value: WordBool); safecall;
    function Get_DaysBeforeDelete: Integer; safecall;
    procedure Set_DaysBeforeDelete(Value: Integer); safecall;
    function Get_SMTP_LogonKind: rdoSMTPLogonKind; safecall;
    procedure Set_SMTP_LogonKind(Value: rdoSMTPLogonKind); safecall;
    property UserName: WideString read Get_UserName write Set_UserName;
    property SMTPAddress: WideString read Get_SMTPAddress write Set_SMTPAddress;
    property POP3_Server: WideString read Get_POP3_Server write Set_POP3_Server;
    property POP3_UserName: WideString read Get_POP3_UserName write Set_POP3_UserName;
    property ReplyAddress: WideString read Get_ReplyAddress write Set_ReplyAddress;
    property POP3_Port: Integer read Get_POP3_Port write Set_POP3_Port;
    property POP3_UseSSL: WordBool read Get_POP3_UseSSL write Set_POP3_UseSSL;
    property POP3_RememberPassword: WordBool read Get_POP3_RememberPassword write Set_POP3_RememberPassword;
    property Organization: WideString read Get_Organization write Set_Organization;
    property POP3_UseSPA: WordBool read Get_POP3_UseSPA write Set_POP3_UseSPA;
    property SMTP_Server: WideString read Get_SMTP_Server write Set_SMTP_Server;
    property SMTP_Port: Integer read Get_SMTP_Port write Set_SMTP_Port;
    property SMTP_UseSSL: WordBool read Get_SMTP_UseSSL write Set_SMTP_UseSSL;
    property SMTP_UseAuth: WordBool read Get_SMTP_UseAuth write Set_SMTP_UseAuth;
    property SMTP_UserName: WideString read Get_SMTP_UserName write Set_SMTP_UserName;
    property SMTP_UseSPA: WordBool read Get_SMTP_UseSPA write Set_SMTP_UseSPA;
    property TimeOut: Integer read Get_TimeOut write Set_TimeOut;
    property LeaveMessagesOnServer: WordBool read Get_LeaveMessagesOnServer write Set_LeaveMessagesOnServer;
    property DeleteFromServerWhenDeletedLocally: WordBool read Get_DeleteFromServerWhenDeletedLocally write Set_DeleteFromServerWhenDeletedLocally;
    property DeleteFromServerAfterXDays: WordBool read Get_DeleteFromServerAfterXDays write Set_DeleteFromServerAfterXDays;
    property DaysBeforeDelete: Integer read Get_DaysBeforeDelete write Set_DaysBeforeDelete;
    property SMTP_LogonKind: rdoSMTPLogonKind read Get_SMTP_LogonKind write Set_SMTP_LogonKind;
  end;

// *********************************************************************//
// DispIntf:  IRDOPOP3AccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA7B67A0-E213-49BD-9369-3E9970245286}
// *********************************************************************//
  IRDOPOP3AccountDisp = dispinterface
    ['{EA7B67A0-E213-49BD-9369-3E9970245286}']
    property UserName: WideString dispid 1003;
    property SMTPAddress: WideString dispid 1005;
    property POP3_Server: WideString dispid 1010;
    property POP3_UserName: WideString dispid 1011;
    property ReplyAddress: WideString dispid 1017;
    property POP3_Port: Integer dispid 1018;
    property POP3_UseSSL: WordBool dispid 1019;
    property POP3_RememberPassword: WordBool dispid 1020;
    property Organization: WideString dispid 1021;
    property POP3_UseSPA: WordBool dispid 1022;
    property SMTP_Server: WideString dispid 1023;
    property SMTP_Port: Integer dispid 1024;
    property SMTP_UseSSL: WordBool dispid 1025;
    property SMTP_UseAuth: WordBool dispid 1026;
    property SMTP_UserName: WideString dispid 1027;
    property SMTP_UseSPA: WordBool dispid 1028;
    property TimeOut: Integer dispid 1029;
    property LeaveMessagesOnServer: WordBool dispid 1030;
    property DeleteFromServerWhenDeletedLocally: WordBool dispid 1031;
    property DeleteFromServerAfterXDays: WordBool dispid 1032;
    property DaysBeforeDelete: Integer dispid 1033;
    property SMTP_LogonKind: rdoSMTPLogonKind dispid 1034;
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOMAPIAccount
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {26BA706B-B151-4E19-BEC2-77E382739ECC}
// *********************************************************************//
  IRDOMAPIAccount = interface(IRDOAccount)
    ['{26BA706B-B151-4E19-BEC2-77E382739ECC}']
    function Get_ServiceUID: WideString; safecall;
    function Get_ServiceName: WideString; safecall;
    property ServiceUID: WideString read Get_ServiceUID;
    property ServiceName: WideString read Get_ServiceName;
  end;

// *********************************************************************//
// DispIntf:  IRDOMAPIAccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {26BA706B-B151-4E19-BEC2-77E382739ECC}
// *********************************************************************//
  IRDOMAPIAccountDisp = dispinterface
    ['{26BA706B-B151-4E19-BEC2-77E382739ECC}']
    property ServiceUID: WideString readonly dispid 1003;
    property ServiceName: WideString readonly dispid 1022;
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOIMAPAccount
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9059EE9C-E410-4F05-9DE8-3C955BC281D5}
// *********************************************************************//
  IRDOIMAPAccount = interface(IRDOAccount)
    ['{9059EE9C-E410-4F05-9DE8-3C955BC281D5}']
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_SMTPAddress: WideString; safecall;
    procedure Set_SMTPAddress(const Value: WideString); safecall;
    function Get_IMAP_Server: WideString; safecall;
    procedure Set_IMAP_Server(const Value: WideString); safecall;
    function Get_IMAP_UserName: WideString; safecall;
    procedure Set_IMAP_UserName(const Value: WideString); safecall;
    function Get_ReplyAddress: WideString; safecall;
    procedure Set_ReplyAddress(const Value: WideString); safecall;
    function Get_IMAP_Port: Integer; safecall;
    procedure Set_IMAP_Port(Value: Integer); safecall;
    function Get_IMAP_UseSSL: WordBool; safecall;
    procedure Set_IMAP_UseSSL(Value: WordBool); safecall;
    function Get_IMAP_RememberPassword: WordBool; safecall;
    procedure Set_IMAP_RememberPassword(Value: WordBool); safecall;
    function Get_Organization: WideString; safecall;
    procedure Set_Organization(const Value: WideString); safecall;
    function Get_IMAP_UseSPA: WordBool; safecall;
    procedure Set_IMAP_UseSPA(Value: WordBool); safecall;
    function Get_SMTP_Server: WideString; safecall;
    procedure Set_SMTP_Server(const Value: WideString); safecall;
    function Get_SMTP_Port: Integer; safecall;
    procedure Set_SMTP_Port(Value: Integer); safecall;
    function Get_SMTP_UseSSL: WordBool; safecall;
    procedure Set_SMTP_UseSSL(Value: WordBool); safecall;
    function Get_SMTP_UseAuth: WordBool; safecall;
    procedure Set_SMTP_UseAuth(Value: WordBool); safecall;
    function Get_SMTP_UserName: WideString; safecall;
    procedure Set_SMTP_UserName(const Value: WideString); safecall;
    function Get_SMTP_UseSPA: WordBool; safecall;
    procedure Set_SMTP_UseSPA(Value: WordBool); safecall;
    function Get_TimeOut: Integer; safecall;
    procedure Set_TimeOut(Value: Integer); safecall;
    function Get_SMTP_LogonKind: rdoSMTPLogonKind; safecall;
    procedure Set_SMTP_LogonKind(Value: rdoSMTPLogonKind); safecall;
    function Get_IMAP_RootPath: WideString; safecall;
    procedure Set_IMAP_RootPath(const Value: WideString); safecall;
    function Get_Store: IRDOStore; safecall;
    property UserName: WideString read Get_UserName write Set_UserName;
    property SMTPAddress: WideString read Get_SMTPAddress write Set_SMTPAddress;
    property IMAP_Server: WideString read Get_IMAP_Server write Set_IMAP_Server;
    property IMAP_UserName: WideString read Get_IMAP_UserName write Set_IMAP_UserName;
    property ReplyAddress: WideString read Get_ReplyAddress write Set_ReplyAddress;
    property IMAP_Port: Integer read Get_IMAP_Port write Set_IMAP_Port;
    property IMAP_UseSSL: WordBool read Get_IMAP_UseSSL write Set_IMAP_UseSSL;
    property IMAP_RememberPassword: WordBool read Get_IMAP_RememberPassword write Set_IMAP_RememberPassword;
    property Organization: WideString read Get_Organization write Set_Organization;
    property IMAP_UseSPA: WordBool read Get_IMAP_UseSPA write Set_IMAP_UseSPA;
    property SMTP_Server: WideString read Get_SMTP_Server write Set_SMTP_Server;
    property SMTP_Port: Integer read Get_SMTP_Port write Set_SMTP_Port;
    property SMTP_UseSSL: WordBool read Get_SMTP_UseSSL write Set_SMTP_UseSSL;
    property SMTP_UseAuth: WordBool read Get_SMTP_UseAuth write Set_SMTP_UseAuth;
    property SMTP_UserName: WideString read Get_SMTP_UserName write Set_SMTP_UserName;
    property SMTP_UseSPA: WordBool read Get_SMTP_UseSPA write Set_SMTP_UseSPA;
    property TimeOut: Integer read Get_TimeOut write Set_TimeOut;
    property SMTP_LogonKind: rdoSMTPLogonKind read Get_SMTP_LogonKind write Set_SMTP_LogonKind;
    property IMAP_RootPath: WideString read Get_IMAP_RootPath write Set_IMAP_RootPath;
    property Store: IRDOStore read Get_Store;
  end;

// *********************************************************************//
// DispIntf:  IRDOIMAPAccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9059EE9C-E410-4F05-9DE8-3C955BC281D5}
// *********************************************************************//
  IRDOIMAPAccountDisp = dispinterface
    ['{9059EE9C-E410-4F05-9DE8-3C955BC281D5}']
    property UserName: WideString dispid 1003;
    property SMTPAddress: WideString dispid 1005;
    property IMAP_Server: WideString dispid 1010;
    property IMAP_UserName: WideString dispid 1011;
    property ReplyAddress: WideString dispid 1017;
    property IMAP_Port: Integer dispid 1018;
    property IMAP_UseSSL: WordBool dispid 1019;
    property IMAP_RememberPassword: WordBool dispid 1020;
    property Organization: WideString dispid 1021;
    property IMAP_UseSPA: WordBool dispid 1022;
    property SMTP_Server: WideString dispid 1023;
    property SMTP_Port: Integer dispid 1024;
    property SMTP_UseSSL: WordBool dispid 1025;
    property SMTP_UseAuth: WordBool dispid 1026;
    property SMTP_UserName: WideString dispid 1027;
    property SMTP_UseSPA: WordBool dispid 1028;
    property TimeOut: Integer dispid 1029;
    property SMTP_LogonKind: rdoSMTPLogonKind dispid 1034;
    property IMAP_RootPath: WideString dispid 1035;
    property Store: IRDOStore readonly dispid 22;
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOHTTPAccount
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3A967384-6CAB-4A29-9F9F-E47C2626880A}
// *********************************************************************//
  IRDOHTTPAccount = interface(IRDOAccount)
    ['{3A967384-6CAB-4A29-9F9F-E47C2626880A}']
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_SMTPAddress: WideString; safecall;
    procedure Set_SMTPAddress(const Value: WideString); safecall;
    function Get_Server: WideString; safecall;
    procedure Set_Server(const Value: WideString); safecall;
    function Get_LoginName: WideString; safecall;
    procedure Set_LoginName(const Value: WideString); safecall;
    function Get_ReplyAddress: WideString; safecall;
    procedure Set_ReplyAddress(const Value: WideString); safecall;
    function Get_RememberPassword: WordBool; safecall;
    procedure Set_RememberPassword(Value: WordBool); safecall;
    function Get_Organization: WideString; safecall;
    procedure Set_Organization(const Value: WideString); safecall;
    function Get_UseSPA: WordBool; safecall;
    procedure Set_UseSPA(Value: WordBool); safecall;
    function Get_Store: IRDOStore; safecall;
    property UserName: WideString read Get_UserName write Set_UserName;
    property SMTPAddress: WideString read Get_SMTPAddress write Set_SMTPAddress;
    property Server: WideString read Get_Server write Set_Server;
    property LoginName: WideString read Get_LoginName write Set_LoginName;
    property ReplyAddress: WideString read Get_ReplyAddress write Set_ReplyAddress;
    property RememberPassword: WordBool read Get_RememberPassword write Set_RememberPassword;
    property Organization: WideString read Get_Organization write Set_Organization;
    property UseSPA: WordBool read Get_UseSPA write Set_UseSPA;
    property Store: IRDOStore read Get_Store;
  end;

// *********************************************************************//
// DispIntf:  IRDOHTTPAccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3A967384-6CAB-4A29-9F9F-E47C2626880A}
// *********************************************************************//
  IRDOHTTPAccountDisp = dispinterface
    ['{3A967384-6CAB-4A29-9F9F-E47C2626880A}']
    property UserName: WideString dispid 1003;
    property SMTPAddress: WideString dispid 1005;
    property Server: WideString dispid 1010;
    property LoginName: WideString dispid 1011;
    property ReplyAddress: WideString dispid 1017;
    property RememberPassword: WordBool dispid 1020;
    property Organization: WideString dispid 1021;
    property UseSPA: WordBool dispid 1022;
    property Store: IRDOStore readonly dispid 22;
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOLDAPAccount
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D4714885-2180-45F1-8C65-D97C20C184AB}
// *********************************************************************//
  IRDOLDAPAccount = interface(IRDOMAPIAccount)
    ['{D4714885-2180-45F1-8C65-D97C20C184AB}']
    function Get_ServerName: WideString; safecall;
    procedure Set_ServerName(const Value: WideString); safecall;
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_UseSPA: WordBool; safecall;
    procedure Set_UseSPA(Value: WordBool); safecall;
    function Get_Port: Integer; safecall;
    procedure Set_Port(Value: Integer); safecall;
    function Get_UseSSL: WordBool; safecall;
    procedure Set_UseSSL(Value: WordBool); safecall;
    function Get_SearchTimeout: Integer; safecall;
    procedure Set_SearchTimeout(Value: Integer); safecall;
    function Get_MaxResults: Integer; safecall;
    procedure Set_MaxResults(Value: Integer); safecall;
    function Get_SearchBase: WideString; safecall;
    procedure Set_SearchBase(const Value: WideString); safecall;
    function Get_SearchTemplate: WideString; safecall;
    procedure Set_SearchTemplate(const Value: WideString); safecall;
    property ServerName: WideString read Get_ServerName write Set_ServerName;
    property UserName: WideString read Get_UserName write Set_UserName;
    property UseSPA: WordBool read Get_UseSPA write Set_UseSPA;
    property Port: Integer read Get_Port write Set_Port;
    property UseSSL: WordBool read Get_UseSSL write Set_UseSSL;
    property SearchTimeout: Integer read Get_SearchTimeout write Set_SearchTimeout;
    property MaxResults: Integer read Get_MaxResults write Set_MaxResults;
    property SearchBase: WideString read Get_SearchBase write Set_SearchBase;
    property SearchTemplate: WideString read Get_SearchTemplate write Set_SearchTemplate;
  end;

// *********************************************************************//
// DispIntf:  IRDOLDAPAccountDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D4714885-2180-45F1-8C65-D97C20C184AB}
// *********************************************************************//
  IRDOLDAPAccountDisp = dispinterface
    ['{D4714885-2180-45F1-8C65-D97C20C184AB}']
    property ServerName: WideString dispid 2022;
    property UserName: WideString dispid 2023;
    property UseSPA: WordBool dispid 2024;
    property Port: Integer dispid 2025;
    property UseSSL: WordBool dispid 2026;
    property SearchTimeout: Integer dispid 2027;
    property MaxResults: Integer dispid 2029;
    property SearchBase: WideString dispid 2030;
    property SearchTemplate: WideString dispid 2031;
    property ServiceUID: WideString readonly dispid 1003;
    property ServiceName: WideString readonly dispid 1022;
    property Session: IRDOSession readonly dispid 1;
    property AccountType: rdoAccountType readonly dispid 2;
    property Name: WideString dispid 4;
    property ID: Integer readonly dispid 6;
    property Stamp: WideString readonly dispid 7;
    property SendStamp: WideString readonly dispid 8;
    property IsExchange: WordBool readonly dispid 9;
    procedure Delete; dispid 12;
    property Fields[PropTag: Integer]: OleVariant dispid 13;
    procedure Save; dispid 14;
    property AccountCategories: Integer readonly dispid 15;
    property AccountTypeStr: WideString readonly dispid 16;
    property _ReserverdProp1: Integer dispid 3;
    property _ReservedProp2: Integer dispid 5;
    property _ReservedProp3: Integer dispid 10;
    property _ReservedProp4: Integer dispid 11;
    property _ReservedProp5: Integer dispid 28;
    procedure _ReservedMethod1; dispid 17;
    procedure _ReservedMethod2; dispid 18;
    procedure _ReservedMethod3; dispid 19;
    procedure _ReservedMethod4; dispid 20;
    procedure _ReservedMethod5; dispid 21;
  end;

// *********************************************************************//
// Interface: IRDOAccountOrderList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2486178B-171F-4BDF-A880-1359E642AC3F}
// *********************************************************************//
  IRDOAccountOrderList = interface(IDispatch)
    ['{2486178B-171F-4BDF-A880-1359E642AC3F}']
    function Get__Item(Index: Integer): IRDOAccount; safecall;
    function Item(Index: Integer): IRDOAccount; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property _Item[Index: Integer]: IRDOAccount read Get__Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOAccountOrderListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2486178B-171F-4BDF-A880-1359E642AC3F}
// *********************************************************************//
  IRDOAccountOrderListDisp = dispinterface
    ['{2486178B-171F-4BDF-A880-1359E642AC3F}']
    property _Item[Index: Integer]: IRDOAccount readonly dispid 0; default;
    function Item(Index: Integer): IRDOAccount; dispid 2;
    property Count: Integer readonly dispid 3;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDODistListItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9995A36B-B5D7-4613-A6C7-3A245E74FFDF}
// *********************************************************************//
  IRDODistListItem = interface(IRDOMail)
    ['{9995A36B-B5D7-4613-A6C7-3A245E74FFDF}']
    function Get_CheckSum: Integer; safecall;
    procedure Set_CheckSum(retVal: Integer); safecall;
    function Get_DLName: WideString; safecall;
    procedure Set_DLName(const retVal: WideString); safecall;
    function Get_MemberCount: Integer; safecall;
    function Get_Members: IRDOAddressEntries; safecall;
    function Get_OneOffMembers: IRDOAddressEntries; safecall;
    procedure AddMember(RecipientOrAddressentryOrName: OleVariant); safecall;
    procedure AddMembers(Recipients: OleVariant); safecall;
    function GetMember(Index: Integer): IRDOAddressEntry; safecall;
    procedure RemoveMember(Index: Integer); safecall;
    procedure AddMemberEx(const Name: WideString; const Address: WideString; 
                          const AddressType: WideString); safecall;
    procedure AddContact(const ContactItem: IDispatch; AddressType: rdoAddressType); safecall;
    property CheckSum: Integer read Get_CheckSum write Set_CheckSum;
    property DLName: WideString read Get_DLName write Set_DLName;
    property MemberCount: Integer read Get_MemberCount;
    property Members: IRDOAddressEntries read Get_Members;
    property OneOffMembers: IRDOAddressEntries read Get_OneOffMembers;
  end;

// *********************************************************************//
// DispIntf:  IRDODistListItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9995A36B-B5D7-4613-A6C7-3A245E74FFDF}
// *********************************************************************//
  IRDODistListItemDisp = dispinterface
    ['{9995A36B-B5D7-4613-A6C7-3A245E74FFDF}']
    property CheckSum: Integer dispid 1610874880;
    property DLName: WideString dispid 1610874882;
    property MemberCount: Integer readonly dispid 1610874884;
    property Members: IRDOAddressEntries readonly dispid 1610874885;
    property OneOffMembers: IRDOAddressEntries readonly dispid 1610874886;
    procedure AddMember(RecipientOrAddressentryOrName: OleVariant); dispid 1610874887;
    procedure AddMembers(Recipients: OleVariant); dispid 1610874888;
    function GetMember(Index: Integer): IRDOAddressEntry; dispid 1610874889;
    procedure RemoveMember(Index: Integer); dispid 1610874890;
    procedure AddMemberEx(const Name: WideString; const Address: WideString; 
                          const AddressType: WideString); dispid 1610874891;
    procedure AddContact(const ContactItem: IDispatch; AddressType: rdoAddressType); dispid 1610874892;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOContactItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DA18E730-205D-4CED-9E61-4DBBC35D2EE5}
// *********************************************************************//
  IRDOContactItem = interface(IRDOMail)
    ['{DA18E730-205D-4CED-9E61-4DBBC35D2EE5}']
    function Get_ContactAccount: WideString; safecall;
    procedure Set_ContactAccount(const retVal: WideString); safecall;
    function Get_Anniversary: TDateTime; safecall;
    procedure Set_Anniversary(retVal: TDateTime); safecall;
    function Get_AssistantName: WideString; safecall;
    procedure Set_AssistantName(const retVal: WideString); safecall;
    function Get_AssistantTelephoneNumber: WideString; safecall;
    procedure Set_AssistantTelephoneNumber(const retVal: WideString); safecall;
    function Get_Birthday: TDateTime; safecall;
    procedure Set_Birthday(retVal: TDateTime); safecall;
    function Get_Business2TelephoneNumber: WideString; safecall;
    procedure Set_Business2TelephoneNumber(const retVal: WideString); safecall;
    function Get_BusinessAddress: WideString; safecall;
    procedure Set_BusinessAddress(const retVal: WideString); safecall;
    function Get_BusinessAddressCity: WideString; safecall;
    procedure Set_BusinessAddressCity(const retVal: WideString); safecall;
    function Get_BusinessAddressCountry: WideString; safecall;
    procedure Set_BusinessAddressCountry(const retVal: WideString); safecall;
    function Get_BusinessAddressPostalCode: WideString; safecall;
    procedure Set_BusinessAddressPostalCode(const retVal: WideString); safecall;
    function Get_BusinessAddressPostOfficeBox: WideString; safecall;
    procedure Set_BusinessAddressPostOfficeBox(const retVal: WideString); safecall;
    function Get_BusinessAddressState: WideString; safecall;
    procedure Set_BusinessAddressState(const retVal: WideString); safecall;
    function Get_BusinessAddressStreet: WideString; safecall;
    procedure Set_BusinessAddressStreet(const retVal: WideString); safecall;
    function Get_BusinessFaxNumber: WideString; safecall;
    procedure Set_BusinessFaxNumber(const retVal: WideString); safecall;
    function Get_BusinessHomePage: WideString; safecall;
    procedure Set_BusinessHomePage(const retVal: WideString); safecall;
    function Get_BusinessTelephoneNumber: WideString; safecall;
    procedure Set_BusinessTelephoneNumber(const retVal: WideString); safecall;
    function Get_CallbackTelephoneNumber: WideString; safecall;
    procedure Set_CallbackTelephoneNumber(const retVal: WideString); safecall;
    function Get_CarTelephoneNumber: WideString; safecall;
    procedure Set_CarTelephoneNumber(const retVal: WideString); safecall;
    function Get_Children: WideString; safecall;
    procedure Set_Children(const retVal: WideString); safecall;
    function Get_CompanyAndFullName: WideString; safecall;
    function Get_CompanyLastFirstNoSpace: WideString; safecall;
    function Get_CompanyLastFirstSpaceOnly: WideString; safecall;
    function Get_CompanyMainTelephoneNumber: WideString; safecall;
    procedure Set_CompanyMainTelephoneNumber(const retVal: WideString); safecall;
    function Get_CompanyName: WideString; safecall;
    procedure Set_CompanyName(const retVal: WideString); safecall;
    function Get_ComputerNetworkName: WideString; safecall;
    procedure Set_ComputerNetworkName(const retVal: WideString); safecall;
    function Get_CustomerID: WideString; safecall;
    procedure Set_CustomerID(const retVal: WideString); safecall;
    function Get_Department: WideString; safecall;
    procedure Set_Department(const retVal: WideString); safecall;
    function Get_Email1Address: WideString; safecall;
    procedure Set_Email1Address(const retVal: WideString); safecall;
    function Get_Email1AddressType: WideString; safecall;
    procedure Set_Email1AddressType(const retVal: WideString); safecall;
    function Get_Email1EntryID: WideString; safecall;
    procedure Set_Email1EntryID(const retVal: WideString); safecall;
    function Get_Email2Address: WideString; safecall;
    procedure Set_Email2Address(const retVal: WideString); safecall;
    function Get_Email2AddressType: WideString; safecall;
    procedure Set_Email2AddressType(const retVal: WideString); safecall;
    function Get_Email2DisplayName: WideString; safecall;
    procedure Set_Email2DisplayName(const retVal: WideString); safecall;
    function Get_Email2EntryID: WideString; safecall;
    procedure Set_Email2EntryID(const retVal: WideString); safecall;
    function Get_Email3Address: WideString; safecall;
    procedure Set_Email3Address(const retVal: WideString); safecall;
    function Get_Email3AddressType: WideString; safecall;
    procedure Set_Email3AddressType(const retVal: WideString); safecall;
    function Get_Email3DisplayName: WideString; safecall;
    procedure Set_Email3DisplayName(const retVal: WideString); safecall;
    function Get_Email3EntryID: WideString; safecall;
    procedure Set_Email3EntryID(const retVal: WideString); safecall;
    function Get_FileAs: WideString; safecall;
    procedure Set_FileAs(const retVal: WideString); safecall;
    function Get_FirstName: WideString; safecall;
    procedure Set_FirstName(const retVal: WideString); safecall;
    function Get_FTPSite: WideString; safecall;
    procedure Set_FTPSite(const retVal: WideString); safecall;
    function Get_FullName: WideString; safecall;
    procedure Set_FullName(const retVal: WideString); safecall;
    function Get_FullNameAndCompany: WideString; safecall;
    function Get_Gender: rdoGender; safecall;
    procedure Set_Gender(retVal: rdoGender); safecall;
    function Get_GovernmentIDNumber: WideString; safecall;
    procedure Set_GovernmentIDNumber(const retVal: WideString); safecall;
    function Get_HasPicture: WordBool; safecall;
    function Get_Hobby: WideString; safecall;
    procedure Set_Hobby(const retVal: WideString); safecall;
    function Get_Home2TelephoneNumber: WideString; safecall;
    procedure Set_Home2TelephoneNumber(const retVal: WideString); safecall;
    function Get_HomeAddress: WideString; safecall;
    procedure Set_HomeAddress(const retVal: WideString); safecall;
    function Get_HomeAddressCity: WideString; safecall;
    procedure Set_HomeAddressCity(const retVal: WideString); safecall;
    function Get_HomeAddressCountry: WideString; safecall;
    procedure Set_HomeAddressCountry(const retVal: WideString); safecall;
    function Get_HomeAddressPostalCode: WideString; safecall;
    procedure Set_HomeAddressPostalCode(const retVal: WideString); safecall;
    function Get_HomeAddressPostOfficeBox: WideString; safecall;
    procedure Set_HomeAddressPostOfficeBox(const retVal: WideString); safecall;
    function Get_HomeAddressState: WideString; safecall;
    procedure Set_HomeAddressState(const retVal: WideString); safecall;
    function Get_HomeAddressStreet: WideString; safecall;
    procedure Set_HomeAddressStreet(const retVal: WideString); safecall;
    function Get_HomeFaxNumber: WideString; safecall;
    procedure Set_HomeFaxNumber(const retVal: WideString); safecall;
    function Get_HomeTelephoneNumber: WideString; safecall;
    procedure Set_HomeTelephoneNumber(const retVal: WideString); safecall;
    function Get_IMAddress: WideString; safecall;
    procedure Set_IMAddress(const retVal: WideString); safecall;
    function Get_Initials: WideString; safecall;
    procedure Set_Initials(const retVal: WideString); safecall;
    function Get_InternetFreeBusyAddress: WideString; safecall;
    procedure Set_InternetFreeBusyAddress(const retVal: WideString); safecall;
    function Get_ISDNNumber: WideString; safecall;
    procedure Set_ISDNNumber(const retVal: WideString); safecall;
    function Get_JobTitle: WideString; safecall;
    procedure Set_JobTitle(const retVal: WideString); safecall;
    function Get_Journal: WordBool; safecall;
    procedure Set_Journal(retVal: WordBool); safecall;
    function Get_Language: WideString; safecall;
    procedure Set_Language(const retVal: WideString); safecall;
    function Get_LastFirstAndSuffix: WideString; safecall;
    function Get_LastFirstNoSpace: WideString; safecall;
    function Get_LastFirstNoSpaceAndSuffix: WideString; safecall;
    function Get_LastFirstNoSpaceCompany: WideString; safecall;
    function Get_LastFirstSpaceOnly: WideString; safecall;
    function Get_LastFirstSpaceOnlyCompany: WideString; safecall;
    function Get_LastName: WideString; safecall;
    procedure Set_LastName(const retVal: WideString); safecall;
    function Get_LastNameAndFirstName: WideString; safecall;
    function Get_MailingAddress: WideString; safecall;
    procedure Set_MailingAddress(const retVal: WideString); safecall;
    function Get_MailingAddressCity: WideString; safecall;
    procedure Set_MailingAddressCity(const retVal: WideString); safecall;
    function Get_MailingAddressCountry: WideString; safecall;
    procedure Set_MailingAddressCountry(const retVal: WideString); safecall;
    function Get_MailingAddressPostalCode: WideString; safecall;
    procedure Set_MailingAddressPostalCode(const retVal: WideString); safecall;
    function Get_MailingAddressPostOfficeBox: WideString; safecall;
    procedure Set_MailingAddressPostOfficeBox(const retVal: WideString); safecall;
    function Get_MailingAddressState: WideString; safecall;
    procedure Set_MailingAddressState(const retVal: WideString); safecall;
    function Get_MailingAddressStreet: WideString; safecall;
    procedure Set_MailingAddressStreet(const retVal: WideString); safecall;
    function Get_ManagerName: WideString; safecall;
    procedure Set_ManagerName(const retVal: WideString); safecall;
    function Get_MiddleName: WideString; safecall;
    procedure Set_MiddleName(const retVal: WideString); safecall;
    function Get_MobileTelephoneNumber: WideString; safecall;
    procedure Set_MobileTelephoneNumber(const retVal: WideString); safecall;
    function Get_NetMeetingAlias: WideString; safecall;
    procedure Set_NetMeetingAlias(const retVal: WideString); safecall;
    function Get_NetMeetingServer: WideString; safecall;
    procedure Set_NetMeetingServer(const retVal: WideString); safecall;
    function Get_NickName: WideString; safecall;
    procedure Set_NickName(const retVal: WideString); safecall;
    function Get_OfficeLocation: WideString; safecall;
    procedure Set_OfficeLocation(const retVal: WideString); safecall;
    function Get_OrganizationalIDNumber: WideString; safecall;
    procedure Set_OrganizationalIDNumber(const retVal: WideString); safecall;
    function Get_OtherAddress: WideString; safecall;
    procedure Set_OtherAddress(const retVal: WideString); safecall;
    function Get_OtherAddressCity: WideString; safecall;
    procedure Set_OtherAddressCity(const retVal: WideString); safecall;
    function Get_OtherAddressCountry: WideString; safecall;
    procedure Set_OtherAddressCountry(const retVal: WideString); safecall;
    function Get_OtherAddressPostalCode: WideString; safecall;
    procedure Set_OtherAddressPostalCode(const retVal: WideString); safecall;
    function Get_OtherAddressPostOfficeBox: WideString; safecall;
    procedure Set_OtherAddressPostOfficeBox(const retVal: WideString); safecall;
    function Get_OtherAddressState: WideString; safecall;
    procedure Set_OtherAddressState(const retVal: WideString); safecall;
    function Get_OtherAddressStreet: WideString; safecall;
    procedure Set_OtherAddressStreet(const retVal: WideString); safecall;
    function Get_OtherFaxNumber: WideString; safecall;
    procedure Set_OtherFaxNumber(const retVal: WideString); safecall;
    function Get_OtherTelephoneNumber: WideString; safecall;
    procedure Set_OtherTelephoneNumber(const retVal: WideString); safecall;
    function Get_PagerNumber: WideString; safecall;
    procedure Set_PagerNumber(const retVal: WideString); safecall;
    function Get_PersonalHomePage: WideString; safecall;
    procedure Set_PersonalHomePage(const retVal: WideString); safecall;
    function Get_PrimaryTelephoneNumber: WideString; safecall;
    procedure Set_PrimaryTelephoneNumber(const retVal: WideString); safecall;
    function Get_Profession: WideString; safecall;
    procedure Set_Profession(const retVal: WideString); safecall;
    function Get_RadioTelephoneNumber: WideString; safecall;
    procedure Set_RadioTelephoneNumber(const retVal: WideString); safecall;
    function Get_ReferredBy: WideString; safecall;
    procedure Set_ReferredBy(const retVal: WideString); safecall;
    function Get_SelectedMailingAddress: rdoMailingAddress; safecall;
    procedure Set_SelectedMailingAddress(retVal: rdoMailingAddress); safecall;
    function Get_Spouse: WideString; safecall;
    procedure Set_Spouse(const retVal: WideString); safecall;
    function Get_Suffix: WideString; safecall;
    procedure Set_Suffix(const retVal: WideString); safecall;
    function Get_TelexNumber: WideString; safecall;
    procedure Set_TelexNumber(const retVal: WideString); safecall;
    function Get_Title: WideString; safecall;
    procedure Set_Title(const retVal: WideString); safecall;
    function Get_TTYTDDTelephoneNumber: WideString; safecall;
    procedure Set_TTYTDDTelephoneNumber(const retVal: WideString); safecall;
    function Get_User1: WideString; safecall;
    procedure Set_User1(const retVal: WideString); safecall;
    function Get_User2: WideString; safecall;
    procedure Set_User2(const retVal: WideString); safecall;
    function Get_User3: WideString; safecall;
    procedure Set_User3(const retVal: WideString); safecall;
    function Get_User4: WideString; safecall;
    procedure Set_User4(const retVal: WideString); safecall;
    function Get_UserCertificate: WideString; safecall;
    procedure Set_UserCertificate(const retVal: WideString); safecall;
    function Get_WebPage: WideString; safecall;
    procedure Set_WebPage(const retVal: WideString); safecall;
    function Get_YomiCompanyName: WideString; safecall;
    procedure Set_YomiCompanyName(const retVal: WideString); safecall;
    function Get_YomiFirstName: WideString; safecall;
    procedure Set_YomiFirstName(const retVal: WideString); safecall;
    function Get_YomiLastName: WideString; safecall;
    procedure Set_YomiLastName(const retVal: WideString); safecall;
    procedure AddPicture(const Path: WideString); safecall;
    function ForwardAsVCard: IRDOMail; safecall;
    procedure RemovePicture; safecall;
    function Get_Email1DisplayName: WideString; safecall;
    procedure Set_Email1DisplayName(const retVal: WideString); safecall;
    function Get_FileUnderId: rdoFileUnderId; safecall;
    procedure Set_FileUnderId(retVal: rdoFileUnderId); safecall;
    property ContactAccount: WideString read Get_ContactAccount write Set_ContactAccount;
    property Anniversary: TDateTime read Get_Anniversary write Set_Anniversary;
    property AssistantName: WideString read Get_AssistantName write Set_AssistantName;
    property AssistantTelephoneNumber: WideString read Get_AssistantTelephoneNumber write Set_AssistantTelephoneNumber;
    property Birthday: TDateTime read Get_Birthday write Set_Birthday;
    property Business2TelephoneNumber: WideString read Get_Business2TelephoneNumber write Set_Business2TelephoneNumber;
    property BusinessAddress: WideString read Get_BusinessAddress write Set_BusinessAddress;
    property BusinessAddressCity: WideString read Get_BusinessAddressCity write Set_BusinessAddressCity;
    property BusinessAddressCountry: WideString read Get_BusinessAddressCountry write Set_BusinessAddressCountry;
    property BusinessAddressPostalCode: WideString read Get_BusinessAddressPostalCode write Set_BusinessAddressPostalCode;
    property BusinessAddressPostOfficeBox: WideString read Get_BusinessAddressPostOfficeBox write Set_BusinessAddressPostOfficeBox;
    property BusinessAddressState: WideString read Get_BusinessAddressState write Set_BusinessAddressState;
    property BusinessAddressStreet: WideString read Get_BusinessAddressStreet write Set_BusinessAddressStreet;
    property BusinessFaxNumber: WideString read Get_BusinessFaxNumber write Set_BusinessFaxNumber;
    property BusinessHomePage: WideString read Get_BusinessHomePage write Set_BusinessHomePage;
    property BusinessTelephoneNumber: WideString read Get_BusinessTelephoneNumber write Set_BusinessTelephoneNumber;
    property CallbackTelephoneNumber: WideString read Get_CallbackTelephoneNumber write Set_CallbackTelephoneNumber;
    property CarTelephoneNumber: WideString read Get_CarTelephoneNumber write Set_CarTelephoneNumber;
    property Children: WideString read Get_Children write Set_Children;
    property CompanyAndFullName: WideString read Get_CompanyAndFullName;
    property CompanyLastFirstNoSpace: WideString read Get_CompanyLastFirstNoSpace;
    property CompanyLastFirstSpaceOnly: WideString read Get_CompanyLastFirstSpaceOnly;
    property CompanyMainTelephoneNumber: WideString read Get_CompanyMainTelephoneNumber write Set_CompanyMainTelephoneNumber;
    property CompanyName: WideString read Get_CompanyName write Set_CompanyName;
    property ComputerNetworkName: WideString read Get_ComputerNetworkName write Set_ComputerNetworkName;
    property CustomerID: WideString read Get_CustomerID write Set_CustomerID;
    property Department: WideString read Get_Department write Set_Department;
    property Email1Address: WideString read Get_Email1Address write Set_Email1Address;
    property Email1AddressType: WideString read Get_Email1AddressType write Set_Email1AddressType;
    property Email1EntryID: WideString read Get_Email1EntryID write Set_Email1EntryID;
    property Email2Address: WideString read Get_Email2Address write Set_Email2Address;
    property Email2AddressType: WideString read Get_Email2AddressType write Set_Email2AddressType;
    property Email2DisplayName: WideString read Get_Email2DisplayName write Set_Email2DisplayName;
    property Email2EntryID: WideString read Get_Email2EntryID write Set_Email2EntryID;
    property Email3Address: WideString read Get_Email3Address write Set_Email3Address;
    property Email3AddressType: WideString read Get_Email3AddressType write Set_Email3AddressType;
    property Email3DisplayName: WideString read Get_Email3DisplayName write Set_Email3DisplayName;
    property Email3EntryID: WideString read Get_Email3EntryID write Set_Email3EntryID;
    property FileAs: WideString read Get_FileAs write Set_FileAs;
    property FirstName: WideString read Get_FirstName write Set_FirstName;
    property FTPSite: WideString read Get_FTPSite write Set_FTPSite;
    property FullName: WideString read Get_FullName write Set_FullName;
    property FullNameAndCompany: WideString read Get_FullNameAndCompany;
    property Gender: rdoGender read Get_Gender write Set_Gender;
    property GovernmentIDNumber: WideString read Get_GovernmentIDNumber write Set_GovernmentIDNumber;
    property HasPicture: WordBool read Get_HasPicture;
    property Hobby: WideString read Get_Hobby write Set_Hobby;
    property Home2TelephoneNumber: WideString read Get_Home2TelephoneNumber write Set_Home2TelephoneNumber;
    property HomeAddress: WideString read Get_HomeAddress write Set_HomeAddress;
    property HomeAddressCity: WideString read Get_HomeAddressCity write Set_HomeAddressCity;
    property HomeAddressCountry: WideString read Get_HomeAddressCountry write Set_HomeAddressCountry;
    property HomeAddressPostalCode: WideString read Get_HomeAddressPostalCode write Set_HomeAddressPostalCode;
    property HomeAddressPostOfficeBox: WideString read Get_HomeAddressPostOfficeBox write Set_HomeAddressPostOfficeBox;
    property HomeAddressState: WideString read Get_HomeAddressState write Set_HomeAddressState;
    property HomeAddressStreet: WideString read Get_HomeAddressStreet write Set_HomeAddressStreet;
    property HomeFaxNumber: WideString read Get_HomeFaxNumber write Set_HomeFaxNumber;
    property HomeTelephoneNumber: WideString read Get_HomeTelephoneNumber write Set_HomeTelephoneNumber;
    property IMAddress: WideString read Get_IMAddress write Set_IMAddress;
    property Initials: WideString read Get_Initials write Set_Initials;
    property InternetFreeBusyAddress: WideString read Get_InternetFreeBusyAddress write Set_InternetFreeBusyAddress;
    property ISDNNumber: WideString read Get_ISDNNumber write Set_ISDNNumber;
    property JobTitle: WideString read Get_JobTitle write Set_JobTitle;
    property Journal: WordBool read Get_Journal write Set_Journal;
    property Language: WideString read Get_Language write Set_Language;
    property LastFirstAndSuffix: WideString read Get_LastFirstAndSuffix;
    property LastFirstNoSpace: WideString read Get_LastFirstNoSpace;
    property LastFirstNoSpaceAndSuffix: WideString read Get_LastFirstNoSpaceAndSuffix;
    property LastFirstNoSpaceCompany: WideString read Get_LastFirstNoSpaceCompany;
    property LastFirstSpaceOnly: WideString read Get_LastFirstSpaceOnly;
    property LastFirstSpaceOnlyCompany: WideString read Get_LastFirstSpaceOnlyCompany;
    property LastName: WideString read Get_LastName write Set_LastName;
    property LastNameAndFirstName: WideString read Get_LastNameAndFirstName;
    property MailingAddress: WideString read Get_MailingAddress write Set_MailingAddress;
    property MailingAddressCity: WideString read Get_MailingAddressCity write Set_MailingAddressCity;
    property MailingAddressCountry: WideString read Get_MailingAddressCountry write Set_MailingAddressCountry;
    property MailingAddressPostalCode: WideString read Get_MailingAddressPostalCode write Set_MailingAddressPostalCode;
    property MailingAddressPostOfficeBox: WideString read Get_MailingAddressPostOfficeBox write Set_MailingAddressPostOfficeBox;
    property MailingAddressState: WideString read Get_MailingAddressState write Set_MailingAddressState;
    property MailingAddressStreet: WideString read Get_MailingAddressStreet write Set_MailingAddressStreet;
    property ManagerName: WideString read Get_ManagerName write Set_ManagerName;
    property MiddleName: WideString read Get_MiddleName write Set_MiddleName;
    property MobileTelephoneNumber: WideString read Get_MobileTelephoneNumber write Set_MobileTelephoneNumber;
    property NetMeetingAlias: WideString read Get_NetMeetingAlias write Set_NetMeetingAlias;
    property NetMeetingServer: WideString read Get_NetMeetingServer write Set_NetMeetingServer;
    property NickName: WideString read Get_NickName write Set_NickName;
    property OfficeLocation: WideString read Get_OfficeLocation write Set_OfficeLocation;
    property OrganizationalIDNumber: WideString read Get_OrganizationalIDNumber write Set_OrganizationalIDNumber;
    property OtherAddress: WideString read Get_OtherAddress write Set_OtherAddress;
    property OtherAddressCity: WideString read Get_OtherAddressCity write Set_OtherAddressCity;
    property OtherAddressCountry: WideString read Get_OtherAddressCountry write Set_OtherAddressCountry;
    property OtherAddressPostalCode: WideString read Get_OtherAddressPostalCode write Set_OtherAddressPostalCode;
    property OtherAddressPostOfficeBox: WideString read Get_OtherAddressPostOfficeBox write Set_OtherAddressPostOfficeBox;
    property OtherAddressState: WideString read Get_OtherAddressState write Set_OtherAddressState;
    property OtherAddressStreet: WideString read Get_OtherAddressStreet write Set_OtherAddressStreet;
    property OtherFaxNumber: WideString read Get_OtherFaxNumber write Set_OtherFaxNumber;
    property OtherTelephoneNumber: WideString read Get_OtherTelephoneNumber write Set_OtherTelephoneNumber;
    property PagerNumber: WideString read Get_PagerNumber write Set_PagerNumber;
    property PersonalHomePage: WideString read Get_PersonalHomePage write Set_PersonalHomePage;
    property PrimaryTelephoneNumber: WideString read Get_PrimaryTelephoneNumber write Set_PrimaryTelephoneNumber;
    property Profession: WideString read Get_Profession write Set_Profession;
    property RadioTelephoneNumber: WideString read Get_RadioTelephoneNumber write Set_RadioTelephoneNumber;
    property ReferredBy: WideString read Get_ReferredBy write Set_ReferredBy;
    property SelectedMailingAddress: rdoMailingAddress read Get_SelectedMailingAddress write Set_SelectedMailingAddress;
    property Spouse: WideString read Get_Spouse write Set_Spouse;
    property Suffix: WideString read Get_Suffix write Set_Suffix;
    property TelexNumber: WideString read Get_TelexNumber write Set_TelexNumber;
    property Title: WideString read Get_Title write Set_Title;
    property TTYTDDTelephoneNumber: WideString read Get_TTYTDDTelephoneNumber write Set_TTYTDDTelephoneNumber;
    property User1: WideString read Get_User1 write Set_User1;
    property User2: WideString read Get_User2 write Set_User2;
    property User3: WideString read Get_User3 write Set_User3;
    property User4: WideString read Get_User4 write Set_User4;
    property UserCertificate: WideString read Get_UserCertificate write Set_UserCertificate;
    property WebPage: WideString read Get_WebPage write Set_WebPage;
    property YomiCompanyName: WideString read Get_YomiCompanyName write Set_YomiCompanyName;
    property YomiFirstName: WideString read Get_YomiFirstName write Set_YomiFirstName;
    property YomiLastName: WideString read Get_YomiLastName write Set_YomiLastName;
    property Email1DisplayName: WideString read Get_Email1DisplayName write Set_Email1DisplayName;
    property FileUnderId: rdoFileUnderId read Get_FileUnderId write Set_FileUnderId;
  end;

// *********************************************************************//
// DispIntf:  IRDOContactItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DA18E730-205D-4CED-9E61-4DBBC35D2EE5}
// *********************************************************************//
  IRDOContactItemDisp = dispinterface
    ['{DA18E730-205D-4CED-9E61-4DBBC35D2EE5}']
    property ContactAccount: WideString dispid 1610874880;
    property Anniversary: TDateTime dispid 1610874882;
    property AssistantName: WideString dispid 1610874884;
    property AssistantTelephoneNumber: WideString dispid 1610874886;
    property Birthday: TDateTime dispid 1610874888;
    property Business2TelephoneNumber: WideString dispid 1610874890;
    property BusinessAddress: WideString dispid 1610874892;
    property BusinessAddressCity: WideString dispid 1610874894;
    property BusinessAddressCountry: WideString dispid 1610874896;
    property BusinessAddressPostalCode: WideString dispid 1610874898;
    property BusinessAddressPostOfficeBox: WideString dispid 1610874900;
    property BusinessAddressState: WideString dispid 1610874902;
    property BusinessAddressStreet: WideString dispid 1610874904;
    property BusinessFaxNumber: WideString dispid 1610874906;
    property BusinessHomePage: WideString dispid 1610874908;
    property BusinessTelephoneNumber: WideString dispid 1610874910;
    property CallbackTelephoneNumber: WideString dispid 1610874912;
    property CarTelephoneNumber: WideString dispid 1610874914;
    property Children: WideString dispid 1610874916;
    property CompanyAndFullName: WideString readonly dispid 1610874920;
    property CompanyLastFirstNoSpace: WideString readonly dispid 1610874921;
    property CompanyLastFirstSpaceOnly: WideString readonly dispid 1610874922;
    property CompanyMainTelephoneNumber: WideString dispid 1610874923;
    property CompanyName: WideString dispid 1610874925;
    property ComputerNetworkName: WideString dispid 1610874927;
    property CustomerID: WideString dispid 1610874929;
    property Department: WideString dispid 1610874931;
    property Email1Address: WideString dispid 1610874933;
    property Email1AddressType: WideString dispid 1610874935;
    property Email1EntryID: WideString dispid 1610874937;
    property Email2Address: WideString dispid 1610874939;
    property Email2AddressType: WideString dispid 1610874941;
    property Email2DisplayName: WideString dispid 1610874943;
    property Email2EntryID: WideString dispid 1610874945;
    property Email3Address: WideString dispid 1610874947;
    property Email3AddressType: WideString dispid 1610874949;
    property Email3DisplayName: WideString dispid 1610874951;
    property Email3EntryID: WideString dispid 1610874953;
    property FileAs: WideString dispid 1610874955;
    property FirstName: WideString dispid 1610874957;
    property FTPSite: WideString dispid 1610874959;
    property FullName: WideString dispid 1610874961;
    property FullNameAndCompany: WideString readonly dispid 1610874963;
    property Gender: rdoGender dispid 1610874964;
    property GovernmentIDNumber: WideString dispid 1610874966;
    property HasPicture: WordBool readonly dispid 1610874968;
    property Hobby: WideString dispid 1610874969;
    property Home2TelephoneNumber: WideString dispid 1610874971;
    property HomeAddress: WideString dispid 1610874973;
    property HomeAddressCity: WideString dispid 1610874975;
    property HomeAddressCountry: WideString dispid 1610874977;
    property HomeAddressPostalCode: WideString dispid 1610874979;
    property HomeAddressPostOfficeBox: WideString dispid 1610874981;
    property HomeAddressState: WideString dispid 1610874983;
    property HomeAddressStreet: WideString dispid 1610874985;
    property HomeFaxNumber: WideString dispid 1610874987;
    property HomeTelephoneNumber: WideString dispid 1610874989;
    property IMAddress: WideString dispid 1610874991;
    property Initials: WideString dispid 1610874993;
    property InternetFreeBusyAddress: WideString dispid 1610874995;
    property ISDNNumber: WideString dispid 1610874997;
    property JobTitle: WideString dispid 1610874999;
    property Journal: WordBool dispid 1610875001;
    property Language: WideString dispid 1610875003;
    property LastFirstAndSuffix: WideString readonly dispid 1610875005;
    property LastFirstNoSpace: WideString readonly dispid 1610875006;
    property LastFirstNoSpaceAndSuffix: WideString readonly dispid 1610875007;
    property LastFirstNoSpaceCompany: WideString readonly dispid 1610875008;
    property LastFirstSpaceOnly: WideString readonly dispid 1610875009;
    property LastFirstSpaceOnlyCompany: WideString readonly dispid 1610875010;
    property LastName: WideString dispid 1610875011;
    property LastNameAndFirstName: WideString readonly dispid 1610875013;
    property MailingAddress: WideString dispid 1610875014;
    property MailingAddressCity: WideString dispid 1610875016;
    property MailingAddressCountry: WideString dispid 1610875018;
    property MailingAddressPostalCode: WideString dispid 1610875020;
    property MailingAddressPostOfficeBox: WideString dispid 1610875022;
    property MailingAddressState: WideString dispid 1610875024;
    property MailingAddressStreet: WideString dispid 1610875026;
    property ManagerName: WideString dispid 1610875028;
    property MiddleName: WideString dispid 1610875030;
    property MobileTelephoneNumber: WideString dispid 1610875032;
    property NetMeetingAlias: WideString dispid 1610875034;
    property NetMeetingServer: WideString dispid 1610875036;
    property NickName: WideString dispid 1610875038;
    property OfficeLocation: WideString dispid 1610875040;
    property OrganizationalIDNumber: WideString dispid 1610875042;
    property OtherAddress: WideString dispid 1610875044;
    property OtherAddressCity: WideString dispid 1610875046;
    property OtherAddressCountry: WideString dispid 1610875048;
    property OtherAddressPostalCode: WideString dispid 1610875050;
    property OtherAddressPostOfficeBox: WideString dispid 1610875052;
    property OtherAddressState: WideString dispid 1610875054;
    property OtherAddressStreet: WideString dispid 1610875056;
    property OtherFaxNumber: WideString dispid 1610875058;
    property OtherTelephoneNumber: WideString dispid 1610875060;
    property PagerNumber: WideString dispid 1610875062;
    property PersonalHomePage: WideString dispid 1610875064;
    property PrimaryTelephoneNumber: WideString dispid 1610875066;
    property Profession: WideString dispid 1610875068;
    property RadioTelephoneNumber: WideString dispid 1610875070;
    property ReferredBy: WideString dispid 1610875072;
    property SelectedMailingAddress: rdoMailingAddress dispid 1610875074;
    property Spouse: WideString dispid 1610875076;
    property Suffix: WideString dispid 1610875078;
    property TelexNumber: WideString dispid 1610875080;
    property Title: WideString dispid 1610875082;
    property TTYTDDTelephoneNumber: WideString dispid 1610875084;
    property User1: WideString dispid 1610875086;
    property User2: WideString dispid 1610875088;
    property User3: WideString dispid 1610875090;
    property User4: WideString dispid 1610875092;
    property UserCertificate: WideString dispid 1610875094;
    property WebPage: WideString dispid 1610875096;
    property YomiCompanyName: WideString dispid 1610875098;
    property YomiFirstName: WideString dispid 1610875100;
    property YomiLastName: WideString dispid 1610875102;
    procedure AddPicture(const Path: WideString); dispid 1610875104;
    function ForwardAsVCard: IRDOMail; dispid 1610875105;
    procedure RemovePicture; dispid 1610875106;
    property Email1DisplayName: WideString dispid 1610875107;
    property FileUnderId: rdoFileUnderId dispid 1610875109;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOFolder2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4A34CF03-DB62-4D32-829A-B0079E16E28C}
// *********************************************************************//
  IRDOFolder2 = interface(IRDOFolder)
    ['{4A34CF03-DB62-4D32-829A-B0079E16E28C}']
    procedure SetAsDefaultFolder(FolderType: Integer); safecall;
    function Get_FolderPath: WideString; safecall;
    procedure AddToPFFavorites; safecall;
    procedure RemoveFromPFFavorites; safecall;
    function Get_FolderFields: IRDOFolderFields; safecall;
    function Get_IsInPFFavorites: WordBool; safecall;
    function FindPFFavoritesCopy: IRDOFolder2; safecall;
    function Get_DeletedFolders: IRDODeletedFolders; safecall;
    function GetActivitiesForTimeRange(StartTime: TDateTime; EndTime: TDateTime; 
                                       SortAscending: WordBool): IRDOItems; safecall;
    procedure EmptyFolder(DeleteHiddenMessages: OleVariant); safecall;
    property FolderPath: WideString read Get_FolderPath;
    property FolderFields: IRDOFolderFields read Get_FolderFields;
    property IsInPFFavorites: WordBool read Get_IsInPFFavorites;
    property DeletedFolders: IRDODeletedFolders read Get_DeletedFolders;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolder2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4A34CF03-DB62-4D32-829A-B0079E16E28C}
// *********************************************************************//
  IRDOFolder2Disp = dispinterface
    ['{4A34CF03-DB62-4D32-829A-B0079E16E28C}']
    procedure SetAsDefaultFolder(FolderType: Integer); dispid 1610874880;
    property FolderPath: WideString readonly dispid 1610874881;
    procedure AddToPFFavorites; dispid 1610874882;
    procedure RemoveFromPFFavorites; dispid 1610874883;
    property FolderFields: IRDOFolderFields readonly dispid 1610874884;
    property IsInPFFavorites: WordBool readonly dispid 1610874885;
    function FindPFFavoritesCopy: IRDOFolder2; dispid 1610874886;
    property DeletedFolders: IRDODeletedFolders readonly dispid 1610874887;
    function GetActivitiesForTimeRange(StartTime: TDateTime; EndTime: TDateTime; 
                                       SortAscending: WordBool): IRDOItems; dispid 1610874888;
    procedure EmptyFolder(DeleteHiddenMessages: OleVariant); dispid 1610874889;
    property DefaultMessageClass: WideString readonly dispid 7;
    property Description: WideString dispid 8;
    property EntryID: WideString readonly dispid 9;
    property Name: WideString dispid 0;
    property Parent: IRDOFolder readonly dispid 11;
    property StoreID: WideString readonly dispid 12;
    property UnReadItemCount: Integer readonly dispid 13;
    property Items: IRDOItems readonly dispid 17;
    property Folders: IRDOFolders readonly dispid 18;
    procedure Delete; dispid 20;
    function MoveTo(const DestinationFolder: IRDOFolder): IRDOFolder; dispid 21;
    property HiddenItems: IRDOItems readonly dispid 23;
    property Store: IRDOStore readonly dispid 14;
    property AddressBookName: WideString dispid 15;
    property ShowAsOutlookAB: WordBool dispid 16;
    property DefaultItemType: Integer readonly dispid 22;
    property WebViewAllowNavigation: WordBool dispid 25;
    property WebViewOn: WordBool dispid 26;
    property WebViewURL: WideString dispid 27;
    property DeletedItems: IRDODeletedItems readonly dispid 19;
    property FolderKind: rdoFolderKind readonly dispid 124;
    property ACL: IRDOACL readonly dispid 128;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDONoteItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5BA25695-866B-4043-8387-5E523079EB9A}
// *********************************************************************//
  IRDONoteItem = interface(IRDOMail)
    ['{5BA25695-866B-4043-8387-5E523079EB9A}']
    function Get_Width: Integer; safecall;
    procedure Set_Width(retVal: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(retVal: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(retVal: Integer); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(retVal: Integer); safecall;
    function Get_Color: rdoNoteColor; safecall;
    procedure Set_Color(retVal: rdoNoteColor); safecall;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Top: Integer read Get_Top write Set_Top;
    property Left: Integer read Get_Left write Set_Left;
    property Color: rdoNoteColor read Get_Color write Set_Color;
  end;

// *********************************************************************//
// DispIntf:  IRDONoteItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5BA25695-866B-4043-8387-5E523079EB9A}
// *********************************************************************//
  IRDONoteItemDisp = dispinterface
    ['{5BA25695-866B-4043-8387-5E523079EB9A}']
    property Width: Integer dispid 1610874880;
    property Height: Integer dispid 1610874882;
    property Top: Integer dispid 1610874884;
    property Left: Integer dispid 1610874886;
    property Color: rdoNoteColor dispid 1610874888;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOPostItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {64B69367-C437-4F24-ADBE-0A22CF0EA1FE}
// *********************************************************************//
  IRDOPostItem = interface(IRDOMail)
    ['{64B69367-C437-4F24-ADBE-0A22CF0EA1FE}']
  end;

// *********************************************************************//
// DispIntf:  IRDOPostItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {64B69367-C437-4F24-ADBE-0A22CF0EA1FE}
// *********************************************************************//
  IRDOPostItemDisp = dispinterface
    ['{64B69367-C437-4F24-ADBE-0A22CF0EA1FE}']
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOLinks
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {263FD351-546E-4CE8-BDB4-C7F1856B428B}
// *********************************************************************//
  IRDOLinks = interface(IDispatch)
    ['{263FD351-546E-4CE8-BDB4-C7F1856B428B}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: OleVariant): IRDOLink; safecall;
    function Item(Index: OleVariant): IRDOLink; safecall;
    function Add(const Item: IDispatch): IRDOLink; safecall;
    procedure Remove(Index: OleVariant); safecall;
    procedure Clear; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: OleVariant]: IRDOLink read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOLinksDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {263FD351-546E-4CE8-BDB4-C7F1856B428B}
// *********************************************************************//
  IRDOLinksDisp = dispinterface
    ['{263FD351-546E-4CE8-BDB4-C7F1856B428B}']
    property Count: Integer readonly dispid 1610743808;
    property _Item[Index: OleVariant]: IRDOLink readonly dispid 0; default;
    function Item(Index: OleVariant): IRDOLink; dispid 1610743810;
    function Add(const Item: IDispatch): IRDOLink; dispid 1610743811;
    procedure Remove(Index: OleVariant); dispid 1610743812;
    procedure Clear; dispid 1610743813;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOLink
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1442519-608B-4607-8168-DDC2A983525B}
// *********************************************************************//
  IRDOLink = interface(IDispatch)
    ['{B1442519-608B-4607-8168-DDC2A983525B}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const retVal: WideString); safecall;
    function Get_Item: IDispatch; safecall;
    procedure Delete; safecall;
    function Get_EntryID: WideString; safecall;
    procedure Set_EntryID(const retVal: WideString); safecall;
    function Get_SearchKey: WideString; safecall;
    procedure Set_SearchKey(const retVal: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Item: IDispatch read Get_Item;
    property EntryID: WideString read Get_EntryID write Set_EntryID;
    property SearchKey: WideString read Get_SearchKey write Set_SearchKey;
  end;

// *********************************************************************//
// DispIntf:  IRDOLinkDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1442519-608B-4607-8168-DDC2A983525B}
// *********************************************************************//
  IRDOLinkDisp = dispinterface
    ['{B1442519-608B-4607-8168-DDC2A983525B}']
    property Name: WideString dispid 1610743808;
    property Item: IDispatch readonly dispid 1610743810;
    procedure Delete; dispid 1610743811;
    property EntryID: WideString dispid 1610743812;
    property SearchKey: WideString dispid 1610743814;
  end;

// *********************************************************************//
// Interface: IRDOTaskItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {19C7D2A9-DCF8-4459-A142-11AC87397917}
// *********************************************************************//
  IRDOTaskItem = interface(IRDOMail)
    ['{19C7D2A9-DCF8-4459-A142-11AC87397917}']
    function Get_ActualWork: Integer; safecall;
    procedure Set_ActualWork(retVal: Integer); safecall;
    function Get_CardData: WideString; safecall;
    procedure Set_CardData(const retVal: WideString); safecall;
    function Get_Complete: WordBool; safecall;
    procedure Set_Complete(retVal: WordBool); safecall;
    function Get_ContactNames: WideString; safecall;
    function Get_Contacts: PSafeArray; safecall;
    function Get_DateCompleted: TDateTime; safecall;
    procedure Set_DateCompleted(retVal: TDateTime); safecall;
    function Get_DelegationState: rdoTaskDelegationState; safecall;
    procedure Set_DelegationState(retVal: rdoTaskDelegationState); safecall;
    function Get_Delegator: WideString; safecall;
    function Get_DueDate: TDateTime; safecall;
    procedure Set_DueDate(retVal: TDateTime); safecall;
    function Get_IsRecurring: WordBool; safecall;
    function Get_Ordinal: Integer; safecall;
    procedure Set_Ordinal(retVal: Integer); safecall;
    function Get_Owner: WideString; safecall;
    procedure Set_Owner(const retVal: WideString); safecall;
    function Get_Ownership_: rdoTaskOwnership; safecall;
    function Get_PercentComplete: Integer; safecall;
    procedure Set_PercentComplete(retVal: Integer); safecall;
    function Get_ResponseState: rdoTaskResponse; safecall;
    function Get_Role: WideString; safecall;
    procedure Set_Role(const retVal: WideString); safecall;
    function Get_SchedulePlusPriority: WideString; safecall;
    procedure Set_SchedulePlusPriority(const retVal: WideString); safecall;
    function Get_StartDate: TDateTime; safecall;
    procedure Set_StartDate(retVal: TDateTime); safecall;
    function Get_Status: rdoTaskStatus; safecall;
    procedure Set_Status(retVal: rdoTaskStatus); safecall;
    function Get_StatusOnCompletionRecipients: WideString; safecall;
    procedure Set_StatusOnCompletionRecipients(const retVal: WideString); safecall;
    function Get_StatusUpdateRecipients: WideString; safecall;
    procedure Set_StatusUpdateRecipients(const retVal: WideString); safecall;
    function Get_TeamTask: WordBool; safecall;
    procedure Set_TeamTask(retVal: WordBool); safecall;
    function Get_TotalWork: Integer; safecall;
    procedure Set_TotalWork(retVal: Integer); safecall;
    function Assign_: IRDOTaskItem; safecall;
    procedure cancelResponseState; safecall;
    procedure ClearRecurrencePattern; safecall;
    function GetRecurrencePattern: IRDORecurrencePattern; safecall;
    procedure MarkComplete; safecall;
    function Respond(Response: rdoTaskResponse; fNoUI: OleVariant; fAdditionalTextDialog: OleVariant): IRDOTaskItem; safecall;
    procedure SkipRecurrence; safecall;
    function StatusReport: IDispatch; safecall;
    function Get_RecurrenceState: rdoRecurrenceState; safecall;
    property ActualWork: Integer read Get_ActualWork write Set_ActualWork;
    property CardData: WideString read Get_CardData write Set_CardData;
    property Complete: WordBool read Get_Complete write Set_Complete;
    property ContactNames: WideString read Get_ContactNames;
    property Contacts: PSafeArray read Get_Contacts;
    property DateCompleted: TDateTime read Get_DateCompleted write Set_DateCompleted;
    property DelegationState: rdoTaskDelegationState read Get_DelegationState write Set_DelegationState;
    property Delegator: WideString read Get_Delegator;
    property DueDate: TDateTime read Get_DueDate write Set_DueDate;
    property IsRecurring: WordBool read Get_IsRecurring;
    property Ordinal: Integer read Get_Ordinal write Set_Ordinal;
    property Owner: WideString read Get_Owner write Set_Owner;
    property Ownership_: rdoTaskOwnership read Get_Ownership_;
    property PercentComplete: Integer read Get_PercentComplete write Set_PercentComplete;
    property ResponseState: rdoTaskResponse read Get_ResponseState;
    property Role: WideString read Get_Role write Set_Role;
    property SchedulePlusPriority: WideString read Get_SchedulePlusPriority write Set_SchedulePlusPriority;
    property StartDate: TDateTime read Get_StartDate write Set_StartDate;
    property Status: rdoTaskStatus read Get_Status write Set_Status;
    property StatusOnCompletionRecipients: WideString read Get_StatusOnCompletionRecipients write Set_StatusOnCompletionRecipients;
    property StatusUpdateRecipients: WideString read Get_StatusUpdateRecipients write Set_StatusUpdateRecipients;
    property TeamTask: WordBool read Get_TeamTask write Set_TeamTask;
    property TotalWork: Integer read Get_TotalWork write Set_TotalWork;
    property RecurrenceState: rdoRecurrenceState read Get_RecurrenceState;
  end;

// *********************************************************************//
// DispIntf:  IRDOTaskItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {19C7D2A9-DCF8-4459-A142-11AC87397917}
// *********************************************************************//
  IRDOTaskItemDisp = dispinterface
    ['{19C7D2A9-DCF8-4459-A142-11AC87397917}']
    property ActualWork: Integer dispid 1610874880;
    property CardData: WideString dispid 1610874882;
    property Complete: WordBool dispid 1610874884;
    property ContactNames: WideString readonly dispid 1610874886;
    property Contacts: {??PSafeArray}OleVariant readonly dispid 1610874888;
    property DateCompleted: TDateTime dispid 1610874890;
    property DelegationState: rdoTaskDelegationState dispid 1610874892;
    property Delegator: WideString readonly dispid 1610874894;
    property DueDate: TDateTime dispid 1610874897;
    property IsRecurring: WordBool readonly dispid 1610874899;
    property Ordinal: Integer dispid 1610874900;
    property Owner: WideString dispid 1610874902;
    property Ownership_: rdoTaskOwnership readonly dispid 1610874904;
    property PercentComplete: Integer dispid 1610874905;
    property ResponseState: rdoTaskResponse readonly dispid 1610874907;
    property Role: WideString dispid 1610874908;
    property SchedulePlusPriority: WideString dispid 1610874910;
    property StartDate: TDateTime dispid 1610874912;
    property Status: rdoTaskStatus dispid 1610874914;
    property StatusOnCompletionRecipients: WideString dispid 1610874916;
    property StatusUpdateRecipients: WideString dispid 1610874918;
    property TeamTask: WordBool dispid 1610874920;
    property TotalWork: Integer dispid 1610874922;
    function Assign_: IRDOTaskItem; dispid 1610874924;
    procedure cancelResponseState; dispid 1610874925;
    procedure ClearRecurrencePattern; dispid 1610874926;
    function GetRecurrencePattern: IRDORecurrencePattern; dispid 1610874927;
    procedure MarkComplete; dispid 1610874928;
    function Respond(Response: rdoTaskResponse; fNoUI: OleVariant; fAdditionalTextDialog: OleVariant): IRDOTaskItem; dispid 1610874929;
    procedure SkipRecurrence; dispid 1610874930;
    function StatusReport: IDispatch; dispid 1610874931;
    property RecurrenceState: rdoRecurrenceState readonly dispid 1610874932;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDORecurrencePattern
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DDA08E39-CDEF-4E2A-B4C9-909766E8233D}
// *********************************************************************//
  IRDORecurrencePattern = interface(IDispatch)
    ['{DDA08E39-CDEF-4E2A-B4C9-909766E8233D}']
    function Get_DayOfMonth: Integer; safecall;
    procedure Set_DayOfMonth(retVal: Integer); safecall;
    function Get_DayOfWeekMask: Integer; safecall;
    procedure Set_DayOfWeekMask(retVal: Integer); safecall;
    function Get_Duration: Integer; safecall;
    procedure Set_Duration(retVal: Integer); safecall;
    function Get_EndTime: TDateTime; safecall;
    procedure Set_EndTime(retVal: TDateTime); safecall;
    function Get_Exceptions: IRDOExceptions; safecall;
    function Get_Instance: Integer; safecall;
    procedure Set_Instance(retVal: Integer); safecall;
    function Get_Interval: Integer; safecall;
    procedure Set_Interval(retVal: Integer); safecall;
    function Get_MonthOfYear: Integer; safecall;
    procedure Set_MonthOfYear(retVal: Integer); safecall;
    function Get_NoEndDate: WordBool; safecall;
    procedure Set_NoEndDate(retVal: WordBool); safecall;
    function Get_Occurrences: Integer; safecall;
    procedure Set_Occurrences(retVal: Integer); safecall;
    function Get_PatternEndDate: TDateTime; safecall;
    procedure Set_PatternEndDate(retVal: TDateTime); safecall;
    function Get_PatternStartDate: TDateTime; safecall;
    procedure Set_PatternStartDate(retVal: TDateTime); safecall;
    function Get_RecurrenceType: rdoRecurrenceType; safecall;
    procedure Set_RecurrenceType(retVal: rdoRecurrenceType); safecall;
    function Get_REgenerate: WordBool; safecall;
    procedure Set_REgenerate(retVal: WordBool); safecall;
    function Get_StartTime: TDateTime; safecall;
    procedure Set_StartTime(retVal: TDateTime); safecall;
    function GetOccurence(StartDateOrIndex: OleVariant): IRDOMail; safecall;
    property DayOfMonth: Integer read Get_DayOfMonth write Set_DayOfMonth;
    property DayOfWeekMask: Integer read Get_DayOfWeekMask write Set_DayOfWeekMask;
    property Duration: Integer read Get_Duration write Set_Duration;
    property EndTime: TDateTime read Get_EndTime write Set_EndTime;
    property Exceptions: IRDOExceptions read Get_Exceptions;
    property Instance: Integer read Get_Instance write Set_Instance;
    property Interval: Integer read Get_Interval write Set_Interval;
    property MonthOfYear: Integer read Get_MonthOfYear write Set_MonthOfYear;
    property NoEndDate: WordBool read Get_NoEndDate write Set_NoEndDate;
    property Occurrences: Integer read Get_Occurrences write Set_Occurrences;
    property PatternEndDate: TDateTime read Get_PatternEndDate write Set_PatternEndDate;
    property PatternStartDate: TDateTime read Get_PatternStartDate write Set_PatternStartDate;
    property RecurrenceType: rdoRecurrenceType read Get_RecurrenceType write Set_RecurrenceType;
    property REgenerate: WordBool read Get_REgenerate write Set_REgenerate;
    property StartTime: TDateTime read Get_StartTime write Set_StartTime;
  end;

// *********************************************************************//
// DispIntf:  IRDORecurrencePatternDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DDA08E39-CDEF-4E2A-B4C9-909766E8233D}
// *********************************************************************//
  IRDORecurrencePatternDisp = dispinterface
    ['{DDA08E39-CDEF-4E2A-B4C9-909766E8233D}']
    property DayOfMonth: Integer dispid 1610743808;
    property DayOfWeekMask: Integer dispid 1610743810;
    property Duration: Integer dispid 1610743812;
    property EndTime: TDateTime dispid 1610743814;
    property Exceptions: IRDOExceptions readonly dispid 1610743816;
    property Instance: Integer dispid 1610743817;
    property Interval: Integer dispid 1610743819;
    property MonthOfYear: Integer dispid 1610743821;
    property NoEndDate: WordBool dispid 1610743823;
    property Occurrences: Integer dispid 1610743825;
    property PatternEndDate: TDateTime dispid 1610743827;
    property PatternStartDate: TDateTime dispid 1610743829;
    property RecurrenceType: rdoRecurrenceType dispid 1610743831;
    property REgenerate: WordBool dispid 1610743833;
    property StartTime: TDateTime dispid 1610743835;
    function GetOccurence(StartDateOrIndex: OleVariant): IRDOMail; dispid 1610743837;
  end;

// *********************************************************************//
// Interface: IImportExport
// Flags:     (128) NonExtensible
// GUID:      {3B23E05F-7999-4888-B15C-5AADA0BA0649}
// *********************************************************************//
  IImportExport = interface(IUnknown)
    ['{3B23E05F-7999-4888-B15C-5AADA0BA0649}']
    function SaveAs(const Stream: IUnknown; Type_: Integer): HResult; stdcall;
    function Import(const Stream: IUnknown; Type_: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IRDOReportItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2689148B-BB6B-4603-8DDD-126BF33451B5}
// *********************************************************************//
  IRDOReportItem = interface(IRDOMail)
    ['{2689148B-BB6B-4603-8DDD-126BF33451B5}']
    function Get_ReportText: WideString; safecall;
    function FindOriginalItem: IRDOMail; safecall;
    property ReportText: WideString read Get_ReportText;
  end;

// *********************************************************************//
// DispIntf:  IRDOReportItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2689148B-BB6B-4603-8DDD-126BF33451B5}
// *********************************************************************//
  IRDOReportItemDisp = dispinterface
    ['{2689148B-BB6B-4603-8DDD-126BF33451B5}']
    property ReportText: WideString readonly dispid 1610874880;
    function FindOriginalItem: IRDOMail; dispid 1610874881;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOFolderFields
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3765DFB0-1F1A-420D-8E8D-7A4671CB8B5B}
// *********************************************************************//
  IRDOFolderFields = interface(IDispatch)
    ['{3765DFB0-1F1A-420D-8E8D-7A4671CB8B5B}']
    function Get__Item(Index: Integer): IRDOFolderField; safecall;
    function Item(Index: Integer): IRDOFolderField; safecall;
    function Get_Count: Integer; safecall;
    function Add(const Name: WideString; Type_: OleVariant; GUID: OleVariant; 
                 DisplayFormat: OleVariant): IRDOFolderField; safecall;
    procedure Remove(Index: Integer); safecall;
    procedure Save; safecall;
    function Get_RawMessage: IRDOMail; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property _Item[Index: Integer]: IRDOFolderField read Get__Item; default;
    property Count: Integer read Get_Count;
    property RawMessage: IRDOMail read Get_RawMessage;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolderFieldsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3765DFB0-1F1A-420D-8E8D-7A4671CB8B5B}
// *********************************************************************//
  IRDOFolderFieldsDisp = dispinterface
    ['{3765DFB0-1F1A-420D-8E8D-7A4671CB8B5B}']
    property _Item[Index: Integer]: IRDOFolderField readonly dispid 0; default;
    function Item(Index: Integer): IRDOFolderField; dispid 1610743809;
    property Count: Integer readonly dispid 1610743810;
    function Add(const Name: WideString; Type_: OleVariant; GUID: OleVariant; 
                 DisplayFormat: OleVariant): IRDOFolderField; dispid 1610743811;
    procedure Remove(Index: Integer); dispid 1610743812;
    procedure Save; dispid 1610743813;
    property RawMessage: IRDOMail readonly dispid 1610743814;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOFolderField
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A73C2100-ABBF-4A7F-98D6-D90129EFEAC8}
// *********************************************************************//
  IRDOFolderField = interface(IDispatch)
    ['{A73C2100-ABBF-4A7F-98D6-D90129EFEAC8}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const retVal: WideString); safecall;
    function Get_type_: rdoUserPropertyType; safecall;
    procedure Set_type_(retVal: rdoUserPropertyType); safecall;
    function Get_GUID: WideString; safecall;
    procedure Set_GUID(const retVal: WideString); safecall;
    function Get_DisplayFormat: Integer; safecall;
    procedure Set_DisplayFormat(retVal: Integer); safecall;
    procedure Delete; safecall;
    function Get_Formula: WideString; safecall;
    procedure Set_Formula(const retVal: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property type_: rdoUserPropertyType read Get_type_ write Set_type_;
    property GUID: WideString read Get_GUID write Set_GUID;
    property DisplayFormat: Integer read Get_DisplayFormat write Set_DisplayFormat;
    property Formula: WideString read Get_Formula write Set_Formula;
  end;

// *********************************************************************//
// DispIntf:  IRDOFolderFieldDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A73C2100-ABBF-4A7F-98D6-D90129EFEAC8}
// *********************************************************************//
  IRDOFolderFieldDisp = dispinterface
    ['{A73C2100-ABBF-4A7F-98D6-D90129EFEAC8}']
    property Name: WideString dispid 1610743808;
    property type_: rdoUserPropertyType dispid 1610743810;
    property GUID: WideString dispid 1610743812;
    property DisplayFormat: Integer dispid 1610743814;
    procedure Delete; dispid 1610743816;
    property Formula: WideString dispid 1610743817;
  end;

// *********************************************************************//
// Interface: IRDOTaskRequestItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {202A5098-5551-4F67-934F-B1747040507C}
// *********************************************************************//
  IRDOTaskRequestItem = interface(IRDOMail)
    ['{202A5098-5551-4F67-934F-B1747040507C}']
    function GetAssociatedTask(AddToTaskList: WordBool): IRDOTaskItem; safecall;
    function Get_RequestType: rdoTaskRequestType; safecall;
    property RequestType: rdoTaskRequestType read Get_RequestType;
  end;

// *********************************************************************//
// DispIntf:  IRDOTaskRequestItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {202A5098-5551-4F67-934F-B1747040507C}
// *********************************************************************//
  IRDOTaskRequestItemDisp = dispinterface
    ['{202A5098-5551-4F67-934F-B1747040507C}']
    function GetAssociatedTask(AddToTaskList: WordBool): IRDOTaskItem; dispid 1610874880;
    property RequestType: rdoTaskRequestType readonly dispid 1610874881;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOTimezones
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B947D1ED-3F3C-4E70-AAE7-57C36AF61ED6}
// *********************************************************************//
  IRDOTimezones = interface(IDispatch)
    ['{B947D1ED-3F3C-4E70-AAE7-57C36AF61ED6}']
    function Get_Count: Integer; safecall;
    function Item(Index: OleVariant): IRDOTimezone; safecall;
    function Get__Item(Index: OleVariant): IRDOTimezone; safecall;
    function ConvertTime(SourceDateTime: TDateTime; const SourceTimeZone: IRDOTimezone; 
                         const DestinationTimeZone: IRDOTimezone): TDateTime; safecall;
    function LocalTimeToUTC(Value: TDateTime): TDateTime; safecall;
    function UTCToLocalTime(Value: TDateTime): TDateTime; safecall;
    function Get_CurrentTimeZone: IRDOTimezone; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: OleVariant]: IRDOTimezone read Get__Item; default;
    property CurrentTimeZone: IRDOTimezone read Get_CurrentTimeZone;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOTimezonesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B947D1ED-3F3C-4E70-AAE7-57C36AF61ED6}
// *********************************************************************//
  IRDOTimezonesDisp = dispinterface
    ['{B947D1ED-3F3C-4E70-AAE7-57C36AF61ED6}']
    property Count: Integer readonly dispid 1610743808;
    function Item(Index: OleVariant): IRDOTimezone; dispid 1610743809;
    property _Item[Index: OleVariant]: IRDOTimezone readonly dispid 0; default;
    function ConvertTime(SourceDateTime: TDateTime; const SourceTimeZone: IRDOTimezone; 
                         const DestinationTimeZone: IRDOTimezone): TDateTime; dispid 1610743811;
    function LocalTimeToUTC(Value: TDateTime): TDateTime; dispid 1610743812;
    function UTCToLocalTime(Value: TDateTime): TDateTime; dispid 1610743813;
    property CurrentTimeZone: IRDOTimezone readonly dispid 1610743814;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOTimezone
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {39C8B828-B3AD-42CF-AFAF-81C872FB21B3}
// *********************************************************************//
  IRDOTimezone = interface(IDispatch)
    ['{39C8B828-B3AD-42CF-AFAF-81C872FB21B3}']
    function Get_Bias: Integer; safecall;
    function Get_DaylightBias: Integer; safecall;
    function Get_DaylightDate: TDateTime; safecall;
    function Get_DaylightDesignation: WideString; safecall;
    function Get_ID: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_StandardBias: Integer; safecall;
    function Get_StandardDate: TDateTime; safecall;
    function Get_StandardDesignation: WideString; safecall;
    function Get_ObservesDaylight: WordBool; safecall;
    function LocalTimeToUTC(Value: TDateTime): TDateTime; safecall;
    function UTCToLocalTime(Value: TDateTime): TDateTime; safecall;
    function DaylightDateForYear(YearOrDate: OleVariant): TDateTime; safecall;
    function StandardDateForYear(YearOrDate: OleVariant): TDateTime; safecall;
    property Bias: Integer read Get_Bias;
    property DaylightBias: Integer read Get_DaylightBias;
    property DaylightDate: TDateTime read Get_DaylightDate;
    property DaylightDesignation: WideString read Get_DaylightDesignation;
    property ID: WideString read Get_ID;
    property Name: WideString read Get_Name;
    property StandardBias: Integer read Get_StandardBias;
    property StandardDate: TDateTime read Get_StandardDate;
    property StandardDesignation: WideString read Get_StandardDesignation;
    property ObservesDaylight: WordBool read Get_ObservesDaylight;
  end;

// *********************************************************************//
// DispIntf:  IRDOTimezoneDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {39C8B828-B3AD-42CF-AFAF-81C872FB21B3}
// *********************************************************************//
  IRDOTimezoneDisp = dispinterface
    ['{39C8B828-B3AD-42CF-AFAF-81C872FB21B3}']
    property Bias: Integer readonly dispid 1610743808;
    property DaylightBias: Integer readonly dispid 1610743809;
    property DaylightDate: TDateTime readonly dispid 1610743810;
    property DaylightDesignation: WideString readonly dispid 1610743811;
    property ID: WideString readonly dispid 1610743812;
    property Name: WideString readonly dispid 1610743813;
    property StandardBias: Integer readonly dispid 1610743814;
    property StandardDate: TDateTime readonly dispid 1610743815;
    property StandardDesignation: WideString readonly dispid 1610743816;
    property ObservesDaylight: WordBool readonly dispid 1610743817;
    function LocalTimeToUTC(Value: TDateTime): TDateTime; dispid 1610743818;
    function UTCToLocalTime(Value: TDateTime): TDateTime; dispid 1610743819;
    function DaylightDateForYear(YearOrDate: OleVariant): TDateTime; dispid 1610743820;
    function StandardDateForYear(YearOrDate: OleVariant): TDateTime; dispid 1610743821;
  end;

// *********************************************************************//
// Interface: IRDOProfiles
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C561C41C-31CE-43CD-9115-6BDFD8FB5849}
// *********************************************************************//
  IRDOProfiles = interface(IDispatch)
    ['{C561C41C-31CE-43CD-9115-6BDFD8FB5849}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: Integer): WideString; safecall;
    function Item(Index: Integer): WideString; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_DefaultProfileName: WideString; safecall;
    procedure Set_DefaultProfileName(const retVal: WideString); safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: WideString read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property DefaultProfileName: WideString read Get_DefaultProfileName write Set_DefaultProfileName;
  end;

// *********************************************************************//
// DispIntf:  IRDOProfilesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C561C41C-31CE-43CD-9115-6BDFD8FB5849}
// *********************************************************************//
  IRDOProfilesDisp = dispinterface
    ['{C561C41C-31CE-43CD-9115-6BDFD8FB5849}']
    property Count: Integer readonly dispid 1610743808;
    property _Item[Index: Integer]: WideString readonly dispid 0; default;
    function Item(Index: Integer): WideString; dispid 1610743810;
    property _NewEnum: IUnknown readonly dispid -4;
    property DefaultProfileName: WideString dispid 1610743812;
  end;

// *********************************************************************//
// Interface: IRDORules
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4195C7B7-BD63-42A5-931B-1BAAD3FF1771}
// *********************************************************************//
  IRDORules = interface(IDispatch)
    ['{4195C7B7-BD63-42A5-931B-1BAAD3FF1771}']
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Remove(Index: OleVariant); safecall;
    procedure Save; safecall;
    function Create(const Name: WideString): IRDORule; safecall;
    function Get_RawTable: IUnknown; safecall;
    function Get_MAPITable: _IMAPITable; safecall;
    function Get_Session: IRDOSession; safecall;
    function GetFirst: IRDORule; safecall;
    function GetLast: IRDORule; safecall;
    function GetNext: IRDORule; safecall;
    function GetPrevious: IRDORule; safecall;
    function Item(Index: OleVariant): IRDORule; safecall;
    function Get__Item(Index: OleVariant): IRDORule; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property RawTable: IUnknown read Get_RawTable;
    property MAPITable: _IMAPITable read Get_MAPITable;
    property Session: IRDOSession read Get_Session;
    property _Item[Index: OleVariant]: IRDORule read Get__Item; default;
  end;

// *********************************************************************//
// DispIntf:  IRDORulesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4195C7B7-BD63-42A5-931B-1BAAD3FF1771}
// *********************************************************************//
  IRDORulesDisp = dispinterface
    ['{4195C7B7-BD63-42A5-931B-1BAAD3FF1771}']
    property Count: Integer readonly dispid 1610743808;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Remove(Index: OleVariant); dispid 1610743810;
    procedure Save; dispid 1610743811;
    function Create(const Name: WideString): IRDORule; dispid 1610743812;
    property RawTable: IUnknown readonly dispid 1610743813;
    property MAPITable: _IMAPITable readonly dispid 1610743814;
    property Session: IRDOSession readonly dispid 1610743815;
    function GetFirst: IRDORule; dispid 1610743816;
    function GetLast: IRDORule; dispid 1610743817;
    function GetNext: IRDORule; dispid 1610743818;
    function GetPrevious: IRDORule; dispid 1610743819;
    function Item(Index: OleVariant): IRDORule; dispid 1610743820;
    property _Item[Index: OleVariant]: IRDORule readonly dispid 0; default;
  end;

// *********************************************************************//
// Interface: IRDORule
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {84803847-45F6-4281-B1E1-7D9D31044420}
// *********************************************************************//
  IRDORule = interface(IDispatch)
    ['{84803847-45F6-4281-B1E1-7D9D31044420}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const retVal: WideString); safecall;
    function Get_ExecutionOrder: Integer; safecall;
    procedure Set_ExecutionOrder(retVal: Integer); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(retVal: WordBool); safecall;
    function Get_Actions: IRDORuleActions; safecall;
    function Get_Conditions: IRDORuleConditions; safecall;
    function Get_Exceptions: IRDORuleConditions; safecall;
    function Get_Provider: WideString; safecall;
    procedure Set_Provider(const retVal: WideString); safecall;
    procedure Delete; safecall;
    procedure Save; safecall;
    function Get_OnlyWhenOOF: WordBool; safecall;
    procedure Set_OnlyWhenOOF(retVal: WordBool); safecall;
    function Get_KeepOOFHistory: WordBool; safecall;
    procedure Set_KeepOOFHistory(retVal: WordBool); safecall;
    function Get_RawConditions: _IRestriction; safecall;
    function SetRawConditionsKind(Kind: RestrictionKind): _IRestriction; safecall;
    function Get_StopProcessingOtherRules: WordBool; safecall;
    procedure Set_StopProcessingOtherRules(retVal: WordBool); safecall;
    function Get_ConditionsAsSQL: WideString; safecall;
    procedure Set_ConditionsAsSQL(const retVal: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property ExecutionOrder: Integer read Get_ExecutionOrder write Set_ExecutionOrder;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Actions: IRDORuleActions read Get_Actions;
    property Conditions: IRDORuleConditions read Get_Conditions;
    property Exceptions: IRDORuleConditions read Get_Exceptions;
    property Provider: WideString read Get_Provider write Set_Provider;
    property OnlyWhenOOF: WordBool read Get_OnlyWhenOOF write Set_OnlyWhenOOF;
    property KeepOOFHistory: WordBool read Get_KeepOOFHistory write Set_KeepOOFHistory;
    property RawConditions: _IRestriction read Get_RawConditions;
    property StopProcessingOtherRules: WordBool read Get_StopProcessingOtherRules write Set_StopProcessingOtherRules;
    property ConditionsAsSQL: WideString read Get_ConditionsAsSQL write Set_ConditionsAsSQL;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {84803847-45F6-4281-B1E1-7D9D31044420}
// *********************************************************************//
  IRDORuleDisp = dispinterface
    ['{84803847-45F6-4281-B1E1-7D9D31044420}']
    property Name: WideString dispid 1610743808;
    property ExecutionOrder: Integer dispid 1610743810;
    property Enabled: WordBool dispid 1610743812;
    property Actions: IRDORuleActions readonly dispid 1610743814;
    property Conditions: IRDORuleConditions readonly dispid 1610743815;
    property Exceptions: IRDORuleConditions readonly dispid 1610743816;
    property Provider: WideString dispid 1610743817;
    procedure Delete; dispid 1610743819;
    procedure Save; dispid 1610743820;
    property OnlyWhenOOF: WordBool dispid 1610743821;
    property KeepOOFHistory: WordBool dispid 1610743823;
    property RawConditions: _IRestriction readonly dispid 1610743825;
    function SetRawConditionsKind(Kind: RestrictionKind): _IRestriction; dispid 1610743826;
    property StopProcessingOtherRules: WordBool dispid 1610743827;
    property ConditionsAsSQL: WideString dispid 1610743829;
  end;

// *********************************************************************//
// Interface: IRDORuleActions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A0883C05-8208-417D-9B03-4AB708C02062}
// *********************************************************************//
  IRDORuleActions = interface(IDispatch)
    ['{A0883C05-8208-417D-9B03-4AB708C02062}']
    function Get_Count: Integer; safecall;
    function Item(Index: Integer): IRDORuleAction; safecall;
    function Get__Item(Index: Integer): IRDORuleAction; safecall;
    function Get_CopyToFolder: IRDORuleActionMoveOrCopy; safecall;
    function Get_MoveToFolder: IRDORuleActionMoveOrCopy; safecall;
    function Get_Forward: IRDORuleActionSend; safecall;
    function Get_ForwardAsAttachment: IRDORuleActionSend; safecall;
    function Get_Delete: IRDORuleAction; safecall;
    function Get_Redirect: IRDORuleActionSend; safecall;
    function Get_Reply: IRDORuleActionTemplate; safecall;
    function Get_DeletePermanently: IRDORuleAction; safecall;
    function Get_AssignToCategory: IRDORuleActionAssignToCategory; safecall;
    function Get_Importance: IRDORuleActionImportance; safecall;
    function Get_Sensitivity: IRDORuleActionSensitivity; safecall;
    function Get_MarkAsRead: IRDORuleAction; safecall;
    function Get_Defer: IRDORuleActionDefer; safecall;
    function Get_Bounce: IRDORuleActionBounce; safecall;
    function Get_Tag: IRDORuleActionTag; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDORuleAction read Get__Item; default;
    property CopyToFolder: IRDORuleActionMoveOrCopy read Get_CopyToFolder;
    property MoveToFolder: IRDORuleActionMoveOrCopy read Get_MoveToFolder;
    property Forward: IRDORuleActionSend read Get_Forward;
    property ForwardAsAttachment: IRDORuleActionSend read Get_ForwardAsAttachment;
    property Delete: IRDORuleAction read Get_Delete;
    property Redirect: IRDORuleActionSend read Get_Redirect;
    property Reply: IRDORuleActionTemplate read Get_Reply;
    property DeletePermanently: IRDORuleAction read Get_DeletePermanently;
    property AssignToCategory: IRDORuleActionAssignToCategory read Get_AssignToCategory;
    property Importance: IRDORuleActionImportance read Get_Importance;
    property Sensitivity: IRDORuleActionSensitivity read Get_Sensitivity;
    property MarkAsRead: IRDORuleAction read Get_MarkAsRead;
    property Defer: IRDORuleActionDefer read Get_Defer;
    property Bounce: IRDORuleActionBounce read Get_Bounce;
    property Tag: IRDORuleActionTag read Get_Tag;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A0883C05-8208-417D-9B03-4AB708C02062}
// *********************************************************************//
  IRDORuleActionsDisp = dispinterface
    ['{A0883C05-8208-417D-9B03-4AB708C02062}']
    property Count: Integer readonly dispid 1610743808;
    function Item(Index: Integer): IRDORuleAction; dispid 1610743809;
    property _Item[Index: Integer]: IRDORuleAction readonly dispid 0; default;
    property CopyToFolder: IRDORuleActionMoveOrCopy readonly dispid 1610743811;
    property MoveToFolder: IRDORuleActionMoveOrCopy readonly dispid 1610743812;
    property Forward: IRDORuleActionSend readonly dispid 1610743813;
    property ForwardAsAttachment: IRDORuleActionSend readonly dispid 1610743814;
    property Delete: IRDORuleAction readonly dispid 1610743815;
    property Redirect: IRDORuleActionSend readonly dispid 1610743816;
    property Reply: IRDORuleActionTemplate readonly dispid 1610743817;
    property DeletePermanently: IRDORuleAction readonly dispid 1610743818;
    property AssignToCategory: IRDORuleActionAssignToCategory readonly dispid 1610743819;
    property Importance: IRDORuleActionImportance readonly dispid 1610743820;
    property Sensitivity: IRDORuleActionSensitivity readonly dispid 1610743821;
    property MarkAsRead: IRDORuleAction readonly dispid 1610743822;
    property Defer: IRDORuleActionDefer readonly dispid 1610743823;
    property Bounce: IRDORuleActionBounce readonly dispid 1610743824;
    property Tag: IRDORuleActionTag readonly dispid 1610743825;
  end;

// *********************************************************************//
// Interface: IRDORuleConditions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {491ED4E6-EA33-461E-9F21-D5773917A71E}
// *********************************************************************//
  IRDORuleConditions = interface(IDispatch)
    ['{491ED4E6-EA33-461E-9F21-D5773917A71E}']
    function Get_Count: Integer; safecall;
    function Item(Index: Integer): IRDORuleCondition; safecall;
    function Get_HasAttachment: IRDORuleCondition; safecall;
    function Get_Importance: IRDORuleConditionImportance; safecall;
    function Get_MeetingInviteOrUpdate: IRDORuleCondition; safecall;
    function Get_OnlyToMe: IRDORuleCondition; safecall;
    function Get_Body: IRDORuleConditionText; safecall;
    function Get_BodyOrSubject: IRDORuleConditionText; safecall;
    function Get_Category: IRDORuleConditionCategory; safecall;
    function Get_FormName: IRDORuleConditionFormName; safecall;
    function Get_From: IRDORuleConditionToOrFrom; safecall;
    function Get_MessageHeader: IRDORuleConditionText; safecall;
    function Get_RecipientAddress: IRDORuleConditionAddress; safecall;
    function Get_SenderAddress: IRDORuleConditionAddress; safecall;
    function Get_SenderInAddressList: IRDORuleConditionSenderInAddressList; safecall;
    function Get_Subject: IRDORuleConditionText; safecall;
    function Get_SentTo: IRDORuleConditionToOrFrom; safecall;
    function Get_AnyCategory: IRDORuleCondition; safecall;
    procedure Clear; safecall;
    function Get__Item(Index: Integer): IRDORuleCondition; safecall;
    property Count: Integer read Get_Count;
    property HasAttachment: IRDORuleCondition read Get_HasAttachment;
    property Importance: IRDORuleConditionImportance read Get_Importance;
    property MeetingInviteOrUpdate: IRDORuleCondition read Get_MeetingInviteOrUpdate;
    property OnlyToMe: IRDORuleCondition read Get_OnlyToMe;
    property Body: IRDORuleConditionText read Get_Body;
    property BodyOrSubject: IRDORuleConditionText read Get_BodyOrSubject;
    property Category: IRDORuleConditionCategory read Get_Category;
    property FormName: IRDORuleConditionFormName read Get_FormName;
    property From: IRDORuleConditionToOrFrom read Get_From;
    property MessageHeader: IRDORuleConditionText read Get_MessageHeader;
    property RecipientAddress: IRDORuleConditionAddress read Get_RecipientAddress;
    property SenderAddress: IRDORuleConditionAddress read Get_SenderAddress;
    property SenderInAddressList: IRDORuleConditionSenderInAddressList read Get_SenderInAddressList;
    property Subject: IRDORuleConditionText read Get_Subject;
    property SentTo: IRDORuleConditionToOrFrom read Get_SentTo;
    property AnyCategory: IRDORuleCondition read Get_AnyCategory;
    property _Item[Index: Integer]: IRDORuleCondition read Get__Item; default;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {491ED4E6-EA33-461E-9F21-D5773917A71E}
// *********************************************************************//
  IRDORuleConditionsDisp = dispinterface
    ['{491ED4E6-EA33-461E-9F21-D5773917A71E}']
    property Count: Integer readonly dispid 1610743808;
    function Item(Index: Integer): IRDORuleCondition; dispid 1610743809;
    property HasAttachment: IRDORuleCondition readonly dispid 1610743810;
    property Importance: IRDORuleConditionImportance readonly dispid 1610743811;
    property MeetingInviteOrUpdate: IRDORuleCondition readonly dispid 1610743812;
    property OnlyToMe: IRDORuleCondition readonly dispid 1610743813;
    property Body: IRDORuleConditionText readonly dispid 1610743814;
    property BodyOrSubject: IRDORuleConditionText readonly dispid 1610743815;
    property Category: IRDORuleConditionCategory readonly dispid 1610743816;
    property FormName: IRDORuleConditionFormName readonly dispid 1610743817;
    property From: IRDORuleConditionToOrFrom readonly dispid 1610743818;
    property MessageHeader: IRDORuleConditionText readonly dispid 1610743819;
    property RecipientAddress: IRDORuleConditionAddress readonly dispid 1610743820;
    property SenderAddress: IRDORuleConditionAddress readonly dispid 1610743821;
    property SenderInAddressList: IRDORuleConditionSenderInAddressList readonly dispid 1610743822;
    property Subject: IRDORuleConditionText readonly dispid 1610743823;
    property SentTo: IRDORuleConditionToOrFrom readonly dispid 1610743824;
    property AnyCategory: IRDORuleCondition readonly dispid 1610743825;
    procedure Clear; dispid 1610743826;
    property _Item[Index: Integer]: IRDORuleCondition readonly dispid 0; default;
  end;

// *********************************************************************//
// Interface: IRDORuleAction
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A93C5BC9-CC2D-42C2-8092-90E7E003956A}
// *********************************************************************//
  IRDORuleAction = interface(IDispatch)
    ['{A93C5BC9-CC2D-42C2-8092-90E7E003956A}']
    function Get_ActionType: rdoRuleActionType; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(retVal: WordBool); safecall;
    property ActionType: rdoRuleActionType read Get_ActionType;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A93C5BC9-CC2D-42C2-8092-90E7E003956A}
// *********************************************************************//
  IRDORuleActionDisp = dispinterface
    ['{A93C5BC9-CC2D-42C2-8092-90E7E003956A}']
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionMoveOrCopy
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {41EA114A-7096-4BDE-9FFA-A7A5F6ABADD4}
// *********************************************************************//
  IRDORuleActionMoveOrCopy = interface(IRDORuleAction)
    ['{41EA114A-7096-4BDE-9FFA-A7A5F6ABADD4}']
    function Get_Folder: IRDOFolder; safecall;
    procedure Set_Folder(const retVal: IRDOFolder); safecall;
    property Folder: IRDOFolder read Get_Folder write Set_Folder;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionMoveOrCopyDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {41EA114A-7096-4BDE-9FFA-A7A5F6ABADD4}
// *********************************************************************//
  IRDORuleActionMoveOrCopyDisp = dispinterface
    ['{41EA114A-7096-4BDE-9FFA-A7A5F6ABADD4}']
    property Folder: IRDOFolder dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionSend
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7734C205-1168-4EBA-8BC6-0289813EAF6B}
// *********************************************************************//
  IRDORuleActionSend = interface(IRDORuleAction)
    ['{7734C205-1168-4EBA-8BC6-0289813EAF6B}']
    function Get_Recipients: IRDORecipients; safecall;
    property Recipients: IRDORecipients read Get_Recipients;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionSendDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7734C205-1168-4EBA-8BC6-0289813EAF6B}
// *********************************************************************//
  IRDORuleActionSendDisp = dispinterface
    ['{7734C205-1168-4EBA-8BC6-0289813EAF6B}']
    property Recipients: IRDORecipients readonly dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionTemplate
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0FEA820A-2315-4A4E-8088-01EA3F72DA55}
// *********************************************************************//
  IRDORuleActionTemplate = interface(IRDORuleAction)
    ['{0FEA820A-2315-4A4E-8088-01EA3F72DA55}']
    function Get_TemplateMessage: IRDOMail; safecall;
    procedure Set_TemplateMessage(const retVal: IRDOMail); safecall;
    property TemplateMessage: IRDOMail read Get_TemplateMessage write Set_TemplateMessage;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionTemplateDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0FEA820A-2315-4A4E-8088-01EA3F72DA55}
// *********************************************************************//
  IRDORuleActionTemplateDisp = dispinterface
    ['{0FEA820A-2315-4A4E-8088-01EA3F72DA55}']
    property TemplateMessage: IRDOMail dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionDefer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C249766A-D8D3-400B-9201-71EDCB391A97}
// *********************************************************************//
  IRDORuleActionDefer = interface(IRDORuleAction)
    ['{C249766A-D8D3-400B-9201-71EDCB391A97}']
    function Get_Data: WideString; safecall;
    procedure Set_Data(const retVal: WideString); safecall;
    property Data: WideString read Get_Data write Set_Data;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionDeferDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C249766A-D8D3-400B-9201-71EDCB391A97}
// *********************************************************************//
  IRDORuleActionDeferDisp = dispinterface
    ['{C249766A-D8D3-400B-9201-71EDCB391A97}']
    property Data: WideString dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionBounce
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA29CFAC-42E1-4756-BF39-A4CC44C927A3}
// *********************************************************************//
  IRDORuleActionBounce = interface(IRDORuleAction)
    ['{EA29CFAC-42E1-4756-BF39-A4CC44C927A3}']
    function Get_BounceCode: rdoBounceCode; safecall;
    procedure Set_BounceCode(retVal: rdoBounceCode); safecall;
    property BounceCode: rdoBounceCode read Get_BounceCode write Set_BounceCode;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionBounceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA29CFAC-42E1-4756-BF39-A4CC44C927A3}
// *********************************************************************//
  IRDORuleActionBounceDisp = dispinterface
    ['{EA29CFAC-42E1-4756-BF39-A4CC44C927A3}']
    property BounceCode: rdoBounceCode dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionSensitivity
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {23A15647-58F4-46E8-A188-D96C69C29D66}
// *********************************************************************//
  IRDORuleActionSensitivity = interface(IRDORuleAction)
    ['{23A15647-58F4-46E8-A188-D96C69C29D66}']
    function Get_Sensitivity: rdoSensitivity; safecall;
    procedure Set_Sensitivity(retVal: rdoSensitivity); safecall;
    property Sensitivity: rdoSensitivity read Get_Sensitivity write Set_Sensitivity;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionSensitivityDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {23A15647-58F4-46E8-A188-D96C69C29D66}
// *********************************************************************//
  IRDORuleActionSensitivityDisp = dispinterface
    ['{23A15647-58F4-46E8-A188-D96C69C29D66}']
    property Sensitivity: rdoSensitivity dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionImportance
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3EDD9B2B-1C2A-4764-9421-4CCE16A60D2E}
// *********************************************************************//
  IRDORuleActionImportance = interface(IRDORuleAction)
    ['{3EDD9B2B-1C2A-4764-9421-4CCE16A60D2E}']
    function Get_Importance: rdoImportance; safecall;
    procedure Set_Importance(retVal: rdoImportance); safecall;
    property Importance: rdoImportance read Get_Importance write Set_Importance;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionImportanceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3EDD9B2B-1C2A-4764-9421-4CCE16A60D2E}
// *********************************************************************//
  IRDORuleActionImportanceDisp = dispinterface
    ['{3EDD9B2B-1C2A-4764-9421-4CCE16A60D2E}']
    property Importance: rdoImportance dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionAssignToCategory
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E530FE8-33A5-4385-9D16-E6CC0AC5D884}
// *********************************************************************//
  IRDORuleActionAssignToCategory = interface(IRDORuleAction)
    ['{3E530FE8-33A5-4385-9D16-E6CC0AC5D884}']
    function Get_Categories: WideString; safecall;
    procedure Set_Categories(const retVal: WideString); safecall;
    property Categories: WideString read Get_Categories write Set_Categories;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionAssignToCategoryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3E530FE8-33A5-4385-9D16-E6CC0AC5D884}
// *********************************************************************//
  IRDORuleActionAssignToCategoryDisp = dispinterface
    ['{3E530FE8-33A5-4385-9D16-E6CC0AC5D884}']
    property Categories: WideString dispid 1610809344;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDORuleActionTag
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {10C262E8-3195-4674-9ABE-92B240D52C30}
// *********************************************************************//
  IRDORuleActionTag = interface(IRDORuleAction)
    ['{10C262E8-3195-4674-9ABE-92B240D52C30}']
    function Get_PropTag: Integer; safecall;
    procedure Set_PropTag(retVal: Integer); safecall;
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(retVal: OleVariant); safecall;
    property PropTag: Integer read Get_PropTag write Set_PropTag;
    property Value: OleVariant read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleActionTagDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {10C262E8-3195-4674-9ABE-92B240D52C30}
// *********************************************************************//
  IRDORuleActionTagDisp = dispinterface
    ['{10C262E8-3195-4674-9ABE-92B240D52C30}']
    property PropTag: Integer dispid 1610809344;
    property Value: OleVariant dispid 1610809346;
    property ActionType: rdoRuleActionType readonly dispid 1610743808;
    property Enabled: WordBool dispid 1610743809;
  end;

// *********************************************************************//
// Interface: IRDOActions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5DB66C43-F720-49F7-8BE5-0CB4C537D713}
// *********************************************************************//
  IRDOActions = interface(IDispatch)
    ['{5DB66C43-F720-49F7-8BE5-0CB4C537D713}']
    function Get_Count: Integer; safecall;
    function Add: IRDOAction; safecall;
    function Item(Index: OleVariant): IRDOAction; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get__Item(Index: Integer): IRDOAction; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOAction read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOActionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5DB66C43-F720-49F7-8BE5-0CB4C537D713}
// *********************************************************************//
  IRDOActionsDisp = dispinterface
    ['{5DB66C43-F720-49F7-8BE5-0CB4C537D713}']
    property Count: Integer readonly dispid 1610743808;
    function Add: IRDOAction; dispid 1610743809;
    function Item(Index: OleVariant): IRDOAction; dispid 1610743810;
    procedure Remove(Index: Integer); dispid 1610743811;
    property _Item[Index: Integer]: IRDOAction readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOAction
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAD0659F-52DF-48E4-B758-5E4C05996DCC}
// *********************************************************************//
  IRDOAction = interface(IDispatch)
    ['{EAD0659F-52DF-48E4-B758-5E4C05996DCC}']
    function Get_CopyLike: rdoActionCopyLike; safecall;
    procedure Set_CopyLike(retVal: rdoActionCopyLike); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(retVal: WordBool); safecall;
    function Get_MessageClass: WideString; safecall;
    procedure Set_MessageClass(const retVal: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const retVal: WideString); safecall;
    function Get_Prefix: WideString; safecall;
    procedure Set_Prefix(const retVal: WideString); safecall;
    function Get_ReplyStyle: rdoActionReplyStyle; safecall;
    procedure Set_ReplyStyle(retVal: rdoActionReplyStyle); safecall;
    function Get_ResponseStyle: rdoActionResponseStyle; safecall;
    procedure Set_ResponseStyle(retVal: rdoActionResponseStyle); safecall;
    function Get_ShowOn: rdoActionShowOn; safecall;
    procedure Set_ShowOn(retVal: rdoActionShowOn); safecall;
    function Get_FormName: WideString; safecall;
    procedure Set_FormName(const retVal: WideString); safecall;
    procedure Delete; safecall;
    property CopyLike: rdoActionCopyLike read Get_CopyLike write Set_CopyLike;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property MessageClass: WideString read Get_MessageClass write Set_MessageClass;
    property Name: WideString read Get_Name write Set_Name;
    property Prefix: WideString read Get_Prefix write Set_Prefix;
    property ReplyStyle: rdoActionReplyStyle read Get_ReplyStyle write Set_ReplyStyle;
    property ResponseStyle: rdoActionResponseStyle read Get_ResponseStyle write Set_ResponseStyle;
    property ShowOn: rdoActionShowOn read Get_ShowOn write Set_ShowOn;
    property FormName: WideString read Get_FormName write Set_FormName;
  end;

// *********************************************************************//
// DispIntf:  IRDOActionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAD0659F-52DF-48E4-B758-5E4C05996DCC}
// *********************************************************************//
  IRDOActionDisp = dispinterface
    ['{EAD0659F-52DF-48E4-B758-5E4C05996DCC}']
    property CopyLike: rdoActionCopyLike dispid 1610743808;
    property Enabled: WordBool dispid 1610743810;
    property MessageClass: WideString dispid 1610743812;
    property Name: WideString dispid 1610743814;
    property Prefix: WideString dispid 1610743816;
    property ReplyStyle: rdoActionReplyStyle dispid 1610743818;
    property ResponseStyle: rdoActionResponseStyle dispid 1610743820;
    property ShowOn: rdoActionShowOn dispid 1610743822;
    property FormName: WideString dispid 1610743824;
    procedure Delete; dispid 1610743826;
  end;

// *********************************************************************//
// Interface: IRDORuleCondition
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {27D4339B-BFD4-4999-8A11-69B738B6AF62}
// *********************************************************************//
  IRDORuleCondition = interface(IDispatch)
    ['{27D4339B-BFD4-4999-8A11-69B738B6AF62}']
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(retVal: WordBool); safecall;
    function Get_ConditionType: rdoRuleConditionType; safecall;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property ConditionType: rdoRuleConditionType read Get_ConditionType;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {27D4339B-BFD4-4999-8A11-69B738B6AF62}
// *********************************************************************//
  IRDORuleConditionDisp = dispinterface
    ['{27D4339B-BFD4-4999-8A11-69B738B6AF62}']
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionImportance
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3054CE9A-E6C3-4890-A679-11A43A113425}
// *********************************************************************//
  IRDORuleConditionImportance = interface(IRDORuleCondition)
    ['{3054CE9A-E6C3-4890-A679-11A43A113425}']
    function Get_Importance: rdoImportance; safecall;
    procedure Set_Importance(retVal: rdoImportance); safecall;
    property Importance: rdoImportance read Get_Importance write Set_Importance;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionImportanceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3054CE9A-E6C3-4890-A679-11A43A113425}
// *********************************************************************//
  IRDORuleConditionImportanceDisp = dispinterface
    ['{3054CE9A-E6C3-4890-A679-11A43A113425}']
    property Importance: rdoImportance dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionText
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2D457800-C7BE-40F2-9129-350B33A97B78}
// *********************************************************************//
  IRDORuleConditionText = interface(IRDORuleCondition)
    ['{2D457800-C7BE-40F2-9129-350B33A97B78}']
    function Get_Text: WideString; safecall;
    procedure Set_Text(const retVal: WideString); safecall;
    property Text: WideString read Get_Text write Set_Text;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionTextDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2D457800-C7BE-40F2-9129-350B33A97B78}
// *********************************************************************//
  IRDORuleConditionTextDisp = dispinterface
    ['{2D457800-C7BE-40F2-9129-350B33A97B78}']
    property Text: WideString dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionCategory
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C71E784C-C77B-4E83-8EFD-9C891423F734}
// *********************************************************************//
  IRDORuleConditionCategory = interface(IRDORuleCondition)
    ['{C71E784C-C77B-4E83-8EFD-9C891423F734}']
    function Get_Categories: OleVariant; safecall;
    procedure Set_Categories(retVal: OleVariant); safecall;
    property Categories: OleVariant read Get_Categories write Set_Categories;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionCategoryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C71E784C-C77B-4E83-8EFD-9C891423F734}
// *********************************************************************//
  IRDORuleConditionCategoryDisp = dispinterface
    ['{C71E784C-C77B-4E83-8EFD-9C891423F734}']
    property Categories: OleVariant dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionFormName
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CB365B3A-A1D3-4811-A91C-8C5B928CDF20}
// *********************************************************************//
  IRDORuleConditionFormName = interface(IRDORuleCondition)
    ['{CB365B3A-A1D3-4811-A91C-8C5B928CDF20}']
    function Get_FormName: WideString; safecall;
    procedure Set_FormName(const retVal: WideString); safecall;
    property FormName: WideString read Get_FormName write Set_FormName;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionFormNameDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CB365B3A-A1D3-4811-A91C-8C5B928CDF20}
// *********************************************************************//
  IRDORuleConditionFormNameDisp = dispinterface
    ['{CB365B3A-A1D3-4811-A91C-8C5B928CDF20}']
    property FormName: WideString dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionToOrFrom
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F1D70F51-5493-46F0-959E-5E10AC55F398}
// *********************************************************************//
  IRDORuleConditionToOrFrom = interface(IRDORuleCondition)
    ['{F1D70F51-5493-46F0-959E-5E10AC55F398}']
    function Get_Recipients: IRDORecipients; safecall;
    property Recipients: IRDORecipients read Get_Recipients;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionToOrFromDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F1D70F51-5493-46F0-959E-5E10AC55F398}
// *********************************************************************//
  IRDORuleConditionToOrFromDisp = dispinterface
    ['{F1D70F51-5493-46F0-959E-5E10AC55F398}']
    property Recipients: IRDORecipients readonly dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionAddress
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BD812A14-4C54-4AE7-88B2-62AF50FB5C08}
// *********************************************************************//
  IRDORuleConditionAddress = interface(IRDORuleCondition)
    ['{BD812A14-4C54-4AE7-88B2-62AF50FB5C08}']
    function Get_Address: OleVariant; safecall;
    procedure Set_Address(retVal: OleVariant); safecall;
    property Address: OleVariant read Get_Address write Set_Address;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionAddressDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BD812A14-4C54-4AE7-88B2-62AF50FB5C08}
// *********************************************************************//
  IRDORuleConditionAddressDisp = dispinterface
    ['{BD812A14-4C54-4AE7-88B2-62AF50FB5C08}']
    property Address: OleVariant dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDORuleConditionSenderInAddressList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4C42C3D2-174D-4C64-B6A6-6E00F780DD2E}
// *********************************************************************//
  IRDORuleConditionSenderInAddressList = interface(IRDORuleCondition)
    ['{4C42C3D2-174D-4C64-B6A6-6E00F780DD2E}']
    function Get_AddressList: IRDOAddressList; safecall;
    procedure _Set_AddressList(const retVal: IRDOAddressList); safecall;
    property AddressList: IRDOAddressList read Get_AddressList write _Set_AddressList;
  end;

// *********************************************************************//
// DispIntf:  IRDORuleConditionSenderInAddressListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4C42C3D2-174D-4C64-B6A6-6E00F780DD2E}
// *********************************************************************//
  IRDORuleConditionSenderInAddressListDisp = dispinterface
    ['{4C42C3D2-174D-4C64-B6A6-6E00F780DD2E}']
    property AddressList: IRDOAddressList dispid 1610809344;
    property Enabled: WordBool dispid 1610743808;
    property ConditionType: rdoRuleConditionType readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRestrictionComment
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {205C0C08-8FD8-49E4-BC1C-8DB84092A954}
// *********************************************************************//
  IRestrictionComment = interface(_IRestriction)
    ['{205C0C08-8FD8-49E4-BC1C-8DB84092A954}']
    function Get_Restriction: _IRestriction; safecall;
    function SetKind(Kind: RestrictionKind): _IRestriction; safecall;
    function Get_PropValueList: IPropValueList; safecall;
    property Restriction: _IRestriction read Get_Restriction;
    property PropValueList: IPropValueList read Get_PropValueList;
  end;

// *********************************************************************//
// DispIntf:  IRestrictionCommentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {205C0C08-8FD8-49E4-BC1C-8DB84092A954}
// *********************************************************************//
  IRestrictionCommentDisp = dispinterface
    ['{205C0C08-8FD8-49E4-BC1C-8DB84092A954}']
    property Restriction: _IRestriction readonly dispid 1610809344;
    function SetKind(Kind: RestrictionKind): _IRestriction; dispid 1610809345;
    property PropValueList: IPropValueList readonly dispid 1610809346;
    property Kind: RestrictionKind readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IPropValueList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B0A3D43B-CCD5-4743-85F2-ECCFBEB42B2A}
// *********************************************************************//
  IPropValueList = interface(IDispatch)
    ['{B0A3D43B-CCD5-4743-85F2-ECCFBEB42B2A}']
    function Get_Count: Integer; safecall;
    function Item(Index: Integer): IPropValue; safecall;
    procedure Clear; safecall;
    function Get__Item(Index: Integer): IPropValue; safecall;
    function Add(PropTag: Integer; Value: OleVariant): IPropValue; safecall;
    procedure Remove(Index: Integer); safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IPropValue read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IPropValueListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B0A3D43B-CCD5-4743-85F2-ECCFBEB42B2A}
// *********************************************************************//
  IPropValueListDisp = dispinterface
    ['{B0A3D43B-CCD5-4743-85F2-ECCFBEB42B2A}']
    property Count: Integer readonly dispid 1610743808;
    function Item(Index: Integer): IPropValue; dispid 1610743809;
    procedure Clear; dispid 1610743810;
    property _Item[Index: Integer]: IPropValue readonly dispid 0; default;
    function Add(PropTag: Integer; Value: OleVariant): IPropValue; dispid 1610743812;
    procedure Remove(Index: Integer); dispid 1610743813;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IPropValue
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82B2E238-1870-4E6B-853D-FB6AE7639DF2}
// *********************************************************************//
  IPropValue = interface(IDispatch)
    ['{82B2E238-1870-4E6B-853D-FB6AE7639DF2}']
    function Get_PropTag: Integer; safecall;
    procedure Set_PropTag(retVal: Integer); safecall;
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(retVal: OleVariant); safecall;
    property PropTag: Integer read Get_PropTag write Set_PropTag;
    property Value: OleVariant read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IPropValueDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82B2E238-1870-4E6B-853D-FB6AE7639DF2}
// *********************************************************************//
  IPropValueDisp = dispinterface
    ['{82B2E238-1870-4E6B-853D-FB6AE7639DF2}']
    property PropTag: Integer dispid 1610743808;
    property Value: OleVariant dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDOAppointmentItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4959BA11-F9D0-4E57-AA7E-125636EEE44A}
// *********************************************************************//
  IRDOAppointmentItem = interface(IRDOMail)
    ['{4959BA11-F9D0-4E57-AA7E-125636EEE44A}']
    function Get_AllDayEvent: WordBool; safecall;
    procedure Set_AllDayEvent(retVal: WordBool); safecall;
    function Get_BusyStatus: rdoBusyStatus; safecall;
    procedure Set_BusyStatus(retVal: rdoBusyStatus); safecall;
    function Get_ConferenceServerAllowExternal: WordBool; safecall;
    procedure Set_ConferenceServerAllowExternal(retVal: WordBool); safecall;
    function Get_ConferenceServerPassword: WideString; safecall;
    procedure Set_ConferenceServerPassword(const retVal: WideString); safecall;
    function Get_Duration: Integer; safecall;
    procedure Set_Duration(retVal: Integer); safecall;
    function Get_End_: TDateTime; safecall;
    procedure Set_End_(retVal: TDateTime); safecall;
    function Get_EndInEndTimeZone: TDateTime; safecall;
    procedure Set_EndInEndTimeZone(retVal: TDateTime); safecall;
    function Get_EndTimeZone: IRDOTimezone; safecall;
    function Get_EndUTC: TDateTime; safecall;
    procedure Set_EndUTC(retVal: TDateTime); safecall;
    function Get_ForceUpdateToAllAttendees: WordBool; safecall;
    procedure Set_ForceUpdateToAllAttendees(retVal: WordBool); safecall;
    function Get_GlobalAppointmentID: WideString; safecall;
    procedure Set_GlobalAppointmentID(const retVal: WideString); safecall;
    function Get_IsOnlineMeeting: WordBool; safecall;
    procedure Set_IsOnlineMeeting(retVal: WordBool); safecall;
    function Get_IsRecurring: WordBool; safecall;
    function Get_MeetingStatus: rdoMeetingStatus; safecall;
    procedure Set_MeetingStatus(retVal: rdoMeetingStatus); safecall;
    function Get_MeetingWorkspaceURL: WideString; safecall;
    procedure Set_MeetingWorkspaceURL(const retVal: WideString); safecall;
    function Get_NetMeetingAutoStart: WordBool; safecall;
    procedure Set_NetMeetingAutoStart(retVal: WordBool); safecall;
    function Get_NetMeetingDocPathName: WideString; safecall;
    procedure Set_NetMeetingDocPathName(const retVal: WideString); safecall;
    function Get_NetMeetingOrganizerAlias: WideString; safecall;
    procedure Set_NetMeetingOrganizerAlias(const retVal: WideString); safecall;
    function Get_NetMeetingServer: WideString; safecall;
    procedure Set_NetMeetingServer(const retVal: WideString); safecall;
    function Get_NetMeetingType: rdoNetMeetingType; safecall;
    procedure Set_NetMeetingType(retVal: rdoNetMeetingType); safecall;
    function Get_NetShowURL: WideString; safecall;
    procedure Set_NetShowURL(const retVal: WideString); safecall;
    function Get_OptionalAttendees: WideString; safecall;
    procedure Set_OptionalAttendees(const retVal: WideString); safecall;
    procedure Set_EndTimeZone(const retVal: IRDOTimezone); safecall;
    function Get_Organizer: WideString; safecall;
    function Get_RecurrenceState: rdoRecurrenceState; safecall;
    function Get_ReminderMinutesBeforeStart: Integer; safecall;
    procedure Set_ReminderMinutesBeforeStart(retVal: Integer); safecall;
    function Get_ReplyTime: TDateTime; safecall;
    procedure Set_ReplyTime(retVal: TDateTime); safecall;
    function Get_RequiredAttendees: WideString; safecall;
    procedure Set_RequiredAttendees(const retVal: WideString); safecall;
    function Get_Resources: WideString; safecall;
    procedure Set_Resources(const retVal: WideString); safecall;
    function Get_ResponseRequested: WordBool; safecall;
    procedure Set_ResponseRequested(retVal: WordBool); safecall;
    function Get_ResponseStatus: rdoResponseStatus; safecall;
    function Get_Start: TDateTime; safecall;
    procedure Set_Start(retVal: TDateTime); safecall;
    function Get_StartInStartTimeZone: TDateTime; safecall;
    procedure Set_StartInStartTimeZone(retVal: TDateTime); safecall;
    function Get_StartTimeZone: IRDOTimezone; safecall;
    procedure Set_StartTimeZone(const retVal: IRDOTimezone); safecall;
    function Get_StartUTC: TDateTime; safecall;
    procedure Set_StartUTC(retVal: TDateTime); safecall;
    procedure ClearRecurrencePattern; safecall;
    function GetRecurrencePattern: IRDORecurrencePattern; safecall;
    procedure Respond(Response: rdoMeetingResponse; fNoUI: OleVariant; 
                      fAdditionalTextDialog: OleVariant); safecall;
    function Get_Location: WideString; safecall;
    procedure Set_Location(const retVal: WideString); safecall;
    function Get_SendAsICal: WordBool; safecall;
    procedure Set_SendAsICal(retVal: WordBool); safecall;
    property AllDayEvent: WordBool read Get_AllDayEvent write Set_AllDayEvent;
    property BusyStatus: rdoBusyStatus read Get_BusyStatus write Set_BusyStatus;
    property ConferenceServerAllowExternal: WordBool read Get_ConferenceServerAllowExternal write Set_ConferenceServerAllowExternal;
    property ConferenceServerPassword: WideString read Get_ConferenceServerPassword write Set_ConferenceServerPassword;
    property Duration: Integer read Get_Duration write Set_Duration;
    property End_: TDateTime read Get_End_ write Set_End_;
    property EndInEndTimeZone: TDateTime read Get_EndInEndTimeZone write Set_EndInEndTimeZone;
    property EndTimeZone: IRDOTimezone read Get_EndTimeZone write Set_EndTimeZone;
    property EndUTC: TDateTime read Get_EndUTC write Set_EndUTC;
    property ForceUpdateToAllAttendees: WordBool read Get_ForceUpdateToAllAttendees write Set_ForceUpdateToAllAttendees;
    property GlobalAppointmentID: WideString read Get_GlobalAppointmentID write Set_GlobalAppointmentID;
    property IsOnlineMeeting: WordBool read Get_IsOnlineMeeting write Set_IsOnlineMeeting;
    property IsRecurring: WordBool read Get_IsRecurring;
    property MeetingStatus: rdoMeetingStatus read Get_MeetingStatus write Set_MeetingStatus;
    property MeetingWorkspaceURL: WideString read Get_MeetingWorkspaceURL write Set_MeetingWorkspaceURL;
    property NetMeetingAutoStart: WordBool read Get_NetMeetingAutoStart write Set_NetMeetingAutoStart;
    property NetMeetingDocPathName: WideString read Get_NetMeetingDocPathName write Set_NetMeetingDocPathName;
    property NetMeetingOrganizerAlias: WideString read Get_NetMeetingOrganizerAlias write Set_NetMeetingOrganizerAlias;
    property NetMeetingServer: WideString read Get_NetMeetingServer write Set_NetMeetingServer;
    property NetMeetingType: rdoNetMeetingType read Get_NetMeetingType write Set_NetMeetingType;
    property NetShowURL: WideString read Get_NetShowURL write Set_NetShowURL;
    property OptionalAttendees: WideString read Get_OptionalAttendees write Set_OptionalAttendees;
    property Organizer: WideString read Get_Organizer;
    property RecurrenceState: rdoRecurrenceState read Get_RecurrenceState;
    property ReminderMinutesBeforeStart: Integer read Get_ReminderMinutesBeforeStart write Set_ReminderMinutesBeforeStart;
    property ReplyTime: TDateTime read Get_ReplyTime write Set_ReplyTime;
    property RequiredAttendees: WideString read Get_RequiredAttendees write Set_RequiredAttendees;
    property Resources: WideString read Get_Resources write Set_Resources;
    property ResponseRequested: WordBool read Get_ResponseRequested write Set_ResponseRequested;
    property ResponseStatus: rdoResponseStatus read Get_ResponseStatus;
    property Start: TDateTime read Get_Start write Set_Start;
    property StartInStartTimeZone: TDateTime read Get_StartInStartTimeZone write Set_StartInStartTimeZone;
    property StartTimeZone: IRDOTimezone read Get_StartTimeZone write Set_StartTimeZone;
    property StartUTC: TDateTime read Get_StartUTC write Set_StartUTC;
    property Location: WideString read Get_Location write Set_Location;
    property SendAsICal: WordBool read Get_SendAsICal write Set_SendAsICal;
  end;

// *********************************************************************//
// DispIntf:  IRDOAppointmentItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4959BA11-F9D0-4E57-AA7E-125636EEE44A}
// *********************************************************************//
  IRDOAppointmentItemDisp = dispinterface
    ['{4959BA11-F9D0-4E57-AA7E-125636EEE44A}']
    property AllDayEvent: WordBool dispid 1610874880;
    property BusyStatus: rdoBusyStatus dispid 1610874882;
    property ConferenceServerAllowExternal: WordBool dispid 1610874884;
    property ConferenceServerPassword: WideString dispid 1610874886;
    property Duration: Integer dispid 1610874888;
    property End_: TDateTime dispid 1610874890;
    property EndInEndTimeZone: TDateTime dispid 1610874892;
    property EndTimeZone: IRDOTimezone dispid 1610874894;
    property EndUTC: TDateTime dispid 1610874895;
    property ForceUpdateToAllAttendees: WordBool dispid 1610874897;
    property GlobalAppointmentID: WideString dispid 1610874899;
    property IsOnlineMeeting: WordBool dispid 1610874901;
    property IsRecurring: WordBool readonly dispid 1610874903;
    property MeetingStatus: rdoMeetingStatus dispid 1610874906;
    property MeetingWorkspaceURL: WideString dispid 1610874908;
    property NetMeetingAutoStart: WordBool dispid 1610874910;
    property NetMeetingDocPathName: WideString dispid 1610874912;
    property NetMeetingOrganizerAlias: WideString dispid 1610874914;
    property NetMeetingServer: WideString dispid 1610874916;
    property NetMeetingType: rdoNetMeetingType dispid 1610874918;
    property NetShowURL: WideString dispid 1610874920;
    property OptionalAttendees: WideString dispid 1610874922;
    property Organizer: WideString readonly dispid 1610874925;
    property RecurrenceState: rdoRecurrenceState readonly dispid 1610874926;
    property ReminderMinutesBeforeStart: Integer dispid 1610874927;
    property ReplyTime: TDateTime dispid 1610874937;
    property RequiredAttendees: WideString dispid 1610874939;
    property Resources: WideString dispid 1610874941;
    property ResponseRequested: WordBool dispid 1610874943;
    property ResponseStatus: rdoResponseStatus readonly dispid 1610874945;
    property Start: TDateTime dispid 1610874946;
    property StartInStartTimeZone: TDateTime dispid 1610874948;
    property StartTimeZone: IRDOTimezone dispid 1610874950;
    property StartUTC: TDateTime dispid 1610874952;
    procedure ClearRecurrencePattern; dispid 1610874954;
    function GetRecurrencePattern: IRDORecurrencePattern; dispid 1610874955;
    procedure Respond(Response: rdoMeetingResponse; fNoUI: OleVariant; 
                      fAdditionalTextDialog: OleVariant); dispid 1610874956;
    property Location: WideString dispid 1610874953;
    property SendAsICal: WordBool dispid 1610874949;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOConflicts
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F14C4E51-1921-454B-B194-8C58148F168D}
// *********************************************************************//
  IRDOConflicts = interface(IDispatch)
    ['{F14C4E51-1921-454B-B194-8C58148F168D}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: Integer): IRDOConflict; safecall;
    function Item(Index: Integer): IRDOConflict; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOConflict read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IRDOConflictsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F14C4E51-1921-454B-B194-8C58148F168D}
// *********************************************************************//
  IRDOConflictsDisp = dispinterface
    ['{F14C4E51-1921-454B-B194-8C58148F168D}']
    property Count: Integer readonly dispid 1610743808;
    property _Item[Index: Integer]: IRDOConflict readonly dispid 0; default;
    function Item(Index: Integer): IRDOConflict; dispid 1610743810;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRDOConflict
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7BBC05F5-8DB5-4C42-9899-C709EDD52742}
// *********************************************************************//
  IRDOConflict = interface(IDispatch)
    ['{7BBC05F5-8DB5-4C42-9899-C709EDD52742}']
    function Get_Item: IRDOMail; safecall;
    function Get_Name: WideString; safecall;
    function Get_EntryID: WideString; safecall;
    property Item: IRDOMail read Get_Item;
    property Name: WideString read Get_Name;
    property EntryID: WideString read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IRDOConflictDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7BBC05F5-8DB5-4C42-9899-C709EDD52742}
// *********************************************************************//
  IRDOConflictDisp = dispinterface
    ['{7BBC05F5-8DB5-4C42-9899-C709EDD52742}']
    property Item: IRDOMail readonly dispid 1610743808;
    property Name: WideString readonly dispid 0;
    property EntryID: WideString readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDOMeetingItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3FE12D4F-CD08-4DAC-9DBB-D3107C63A169}
// *********************************************************************//
  IRDOMeetingItem = interface(IRDOMail)
    ['{3FE12D4F-CD08-4DAC-9DBB-D3107C63A169}']
    function GetAssociatedAppointment(AddToCalendar: WordBool): IRDOAppointmentItem; safecall;
    function Get_RequestType: rdoMeetingRequestType; safecall;
    property RequestType: rdoMeetingRequestType read Get_RequestType;
  end;

// *********************************************************************//
// DispIntf:  IRDOMeetingItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3FE12D4F-CD08-4DAC-9DBB-D3107C63A169}
// *********************************************************************//
  IRDOMeetingItemDisp = dispinterface
    ['{3FE12D4F-CD08-4DAC-9DBB-D3107C63A169}']
    function GetAssociatedAppointment(AddToCalendar: WordBool): IRDOAppointmentItem; dispid 1610874880;
    property RequestType: rdoMeetingRequestType readonly dispid 1610874881;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDODeletedFolders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4E78349E-594E-4523-A91B-9995E8C89C23}
// *********************************************************************//
  IRDODeletedFolders = interface(IRDOFolders)
    ['{4E78349E-594E-4523-A91B-9995E8C89C23}']
    function Restore(Index: OleVariant; DestinationFolder: OleVariant; Move: OleVariant): IRDOFolder; safecall;
  end;

// *********************************************************************//
// DispIntf:  IRDODeletedFoldersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4E78349E-594E-4523-A91B-9995E8C89C23}
// *********************************************************************//
  IRDODeletedFoldersDisp = dispinterface
    ['{4E78349E-594E-4523-A91B-9995E8C89C23}']
    function Restore(Index: OleVariant; DestinationFolder: OleVariant; Move: OleVariant): IRDOFolder; dispid 1610809344;
    property Count: Integer readonly dispid 1;
    property RawTable: IUnknown readonly dispid 2;
    property Session: IRDOSession readonly dispid 3;
    function Add(const Name: WideString; Type_: OleVariant): IRDOFolder; dispid 4;
    function GetFirst: IRDOFolder; dispid 5;
    function GetLast: IRDOFolder; dispid 6;
    function GetNext: IRDOFolder; dispid 7;
    function GetPrevious: IRDOFolder; dispid 8;
    function Item(Index: OleVariant): IRDOFolder; dispid 9;
    property _Item[Index: OleVariant]: IRDOFolder readonly dispid 0; default;
    procedure Remove(Index: Integer); dispid 11;
    property _NewEnum: IUnknown readonly dispid -4;
    property MAPITable: _IMAPITable readonly dispid 13;
    function AddSearchFolder(const Name: WideString; Type_: OleVariant): IRDOSearchFolder; dispid 10;
  end;

// *********************************************************************//
// Interface: IRDOExceptions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6C22A322-0020-42AF-9B5A-ECCBCEB6F64B}
// *********************************************************************//
  IRDOExceptions = interface(IDispatch)
    ['{6C22A322-0020-42AF-9B5A-ECCBCEB6F64B}']
    function Item(Index: OleVariant): IRDOException; safecall;
    function Get__Item(Index: OleVariant): IRDOException; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Count: Integer; safecall;
    property _Item[Index: OleVariant]: IRDOException read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IRDOExceptionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6C22A322-0020-42AF-9B5A-ECCBCEB6F64B}
// *********************************************************************//
  IRDOExceptionsDisp = dispinterface
    ['{6C22A322-0020-42AF-9B5A-ECCBCEB6F64B}']
    function Item(Index: OleVariant): IRDOException; dispid 1610743808;
    property _Item[Index: OleVariant]: IRDOException readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
    property Count: Integer readonly dispid 1610743811;
  end;

// *********************************************************************//
// Interface: IRDOException
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {570BBE99-2D82-4C86-9920-951F494C6DB0}
// *********************************************************************//
  IRDOException = interface(IDispatch)
    ['{570BBE99-2D82-4C86-9920-951F494C6DB0}']
    function Get_Item: IRDOMail; safecall;
    function Get_Deleted: WordBool; safecall;
    function Get_OriginalDate: TDateTime; safecall;
    property Item: IRDOMail read Get_Item;
    property Deleted: WordBool read Get_Deleted;
    property OriginalDate: TDateTime read Get_OriginalDate;
  end;

// *********************************************************************//
// DispIntf:  IRDOExceptionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {570BBE99-2D82-4C86-9920-951F494C6DB0}
// *********************************************************************//
  IRDOExceptionDisp = dispinterface
    ['{570BBE99-2D82-4C86-9920-951F494C6DB0}']
    property Item: IRDOMail readonly dispid 1610743808;
    property Deleted: WordBool readonly dispid 1610743809;
    property OriginalDate: TDateTime readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: IRDOJournalItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82BD1792-2C5A-404F-895A-4B765B3FE344}
// *********************************************************************//
  IRDOJournalItem = interface(IRDOMail)
    ['{82BD1792-2C5A-404F-895A-4B765B3FE344}']
    function Get_ContactNames: WideString; safecall;
    function Get_DocPosted: WordBool; safecall;
    procedure Set_DocPosted(retVal: WordBool); safecall;
    function Get_DocPrinted: WordBool; safecall;
    procedure Set_DocPrinted(retVal: WordBool); safecall;
    function Get_DocRouted: WordBool; safecall;
    procedure Set_DocRouted(retVal: WordBool); safecall;
    function Get_DocSaved: WordBool; safecall;
    procedure Set_DocSaved(retVal: WordBool); safecall;
    function Get_Duration: Integer; safecall;
    procedure Set_Duration(retVal: Integer); safecall;
    function Get_End_: TDateTime; safecall;
    procedure Set_End_(retVal: TDateTime); safecall;
    function Get_Start: TDateTime; safecall;
    procedure Set_Start(retVal: TDateTime); safecall;
    function Get_type_: WideString; safecall;
    procedure Set_type_(const retVal: WideString); safecall;
    property ContactNames: WideString read Get_ContactNames;
    property DocPosted: WordBool read Get_DocPosted write Set_DocPosted;
    property DocPrinted: WordBool read Get_DocPrinted write Set_DocPrinted;
    property DocRouted: WordBool read Get_DocRouted write Set_DocRouted;
    property DocSaved: WordBool read Get_DocSaved write Set_DocSaved;
    property Duration: Integer read Get_Duration write Set_Duration;
    property End_: TDateTime read Get_End_ write Set_End_;
    property Start: TDateTime read Get_Start write Set_Start;
    property type_: WideString read Get_type_ write Set_type_;
  end;

// *********************************************************************//
// DispIntf:  IRDOJournalItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {82BD1792-2C5A-404F-895A-4B765B3FE344}
// *********************************************************************//
  IRDOJournalItemDisp = dispinterface
    ['{82BD1792-2C5A-404F-895A-4B765B3FE344}']
    property ContactNames: WideString readonly dispid 1610874880;
    property DocPosted: WordBool dispid 1610874881;
    property DocPrinted: WordBool dispid 1610874883;
    property DocRouted: WordBool dispid 1610874885;
    property DocSaved: WordBool dispid 1610874887;
    property Duration: Integer dispid 1610874889;
    property End_: TDateTime dispid 1610874891;
    property Start: TDateTime dispid 1610874893;
    property type_: WideString dispid 1610874895;
    property EntryID: WideString readonly dispid 201;
    property Subject: WideString dispid 0;
    property AlternateRecipientAllowed: WordBool dispid 7;
    property AutoForwarded: WordBool dispid 8;
    property BCC: WideString dispid 9;
    property BillingInformation: WideString dispid 10;
    property Body: WideString dispid 11;
    property BodyFormat: Integer dispid 12;
    property Categories: WideString dispid 13;
    property CC: WideString dispid 14;
    property Companies: WideString dispid 15;
    property ConversationIndex: WideString dispid 16;
    property ConversationTopic: WideString dispid 17;
    property CreationTime: TDateTime readonly dispid 18;
    property DeferredDeliveryTime: TDateTime dispid 19;
    property DeleteAfterSubmit: WordBool dispid 20;
    property ExpiryTime: TDateTime dispid 21;
    property FlagDueBy: TDateTime dispid 22;
    property FlagIcon: Integer dispid 23;
    property FlagRequest: WideString dispid 24;
    property FlagStatus: Integer dispid 25;
    property HTMLBody: WideString dispid 26;
    property Importance: Integer dispid 27;
    property InternetCodepage: Integer dispid 28;
    property LastModificationTime: TDateTime readonly dispid 29;
    property MessageClass: WideString dispid 30;
    property Mileage: WideString dispid 31;
    property NoAging: WordBool dispid 32;
    property OriginatorDeliveryReportRequested: WordBool dispid 33;
    property OutlookInternalVersion: Integer readonly dispid 34;
    property OutlookVersion: WideString readonly dispid 35;
    property ReadReceiptRequested: WordBool dispid 36;
    property ReceivedByEntryID: WideString dispid 37;
    property ReceivedByName: WideString dispid 38;
    property ReceivedOnBehalfOfEntryID: WideString dispid 39;
    property ReceivedOnBehalfOfName: WideString dispid 40;
    property ReceivedTime: TDateTime dispid 41;
    property RecipientReassignmentProhibited: WordBool dispid 42;
    property ReminderOverrideDefault: WordBool dispid 43;
    property ReminderPlaySound: WordBool dispid 44;
    property ReminderSet: WordBool dispid 45;
    property ReminderSoundFile: WideString dispid 46;
    property ReminderTime: TDateTime dispid 47;
    property ReplyRecipientNames: WideString readonly dispid 48;
    property SaveSentMessageFolder: OleVariant dispid 49;
    property SenderEmailAddress: WideString dispid 50;
    property SenderEmailType: WideString dispid 51;
    property SenderName: WideString dispid 52;
    property SenderEntryID: WideString dispid 53;
    property Sensitivity: Integer dispid 54;
    property Sent: WordBool dispid 56;
    property SentOn: TDateTime dispid 57;
    property SentOnBehalfOfName: WideString dispid 58;
    property SentOnBehalfOfEmailAddress: WideString dispid 59;
    property SentOnBehalfOfEmailType: WideString dispid 60;
    property SentOnBehalfOfEntryID: WideString dispid 61;
    property Size: Integer readonly dispid 62;
    property Submitted: WordBool readonly dispid 63;
    property To_: WideString dispid 64;
    property UnRead: WordBool dispid 65;
    property VotingResponse: WideString dispid 67;
    property RTFBody: WideString dispid 69;
    procedure Send; dispid 70;
    procedure Import(const Path: WideString; Type_: OleVariant); dispid 71;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); dispid 72;
    property Attachments: IRDOAttachments readonly dispid 73;
    procedure Delete(DeleteFlags: OleVariant); dispid 55;
    function Move(const DestFolder: IRDOFolder): IRDOMail; dispid 68;
    function Reply: IRDOMail; dispid 74;
    function ReplyAll: IRDOMail; dispid 75;
    function Forward: IRDOMail; dispid 76;
    property Recipients: IRDORecipients dispid 77;
    property HidePaperClip: WordBool dispid 78;
    property Sender: IRDOAddressEntry dispid 79;
    property SentOnBehalfOf: IRDOAddressEntry dispid 80;
    property Store: IRDOStore readonly dispid 81;
    property Parent: IDispatch readonly dispid 82;
    property ReplyRecipients: IRDORecipients dispid 66;
    procedure AbortSubmit; dispid 83;
    procedure Display(Modal: OleVariant; ParentWnd: OleVariant); dispid 84;
    procedure PrintOut(ParentWnd: OleVariant); dispid 85;
    procedure DoAction(Action: rdoMessageAction; ParentWnd: OleVariant); dispid 86;
    procedure DesignForm(ParentWnd: OleVariant); dispid 87;
    property Account: IRDOAccount dispid 89;
    property Links: IRDOLinks readonly dispid 1610809488;
    property VotingOptions: WideString dispid 1610809489;
    property _Reserved3: Integer dispid 1610809491;
    property _Reserved4: Integer dispid 1610809493;
    property _Reserved5: Integer dispid 1610809495;
    property Actions: IRDOActions readonly dispid 1610809502;
    procedure MarkRead(SuppressReceipt: WordBool); dispid 1610809498;
    property Conflicts: IRDOConflicts readonly dispid 1610809503;
    procedure _ReservedMethod4; dispid 1610809500;
    procedure _ReservedMethod5; dispid 1610809501;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer; dispid 2;
    property Fields[PropTag: OleVariant]: OleVariant dispid 3;
    function GetPropList(Flags: Integer; UseUnicode: OleVariant): IPropList; dispid 4;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty; dispid 1;
    procedure CopyTo(DestObj: OleVariant); dispid 5;
    procedure Save; dispid 6;
    property MAPIOBJECT: IUnknown readonly dispid 2007;
    property Session: IRDOSession readonly dispid 1007;
  end;

// *********************************************************************//
// Interface: IRDOCalendarOptions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8D381511-EE3D-43AC-A5C4-93632DEFE6A7}
// *********************************************************************//
  IRDOCalendarOptions = interface(IDispatch)
    ['{8D381511-EE3D-43AC-A5C4-93632DEFE6A7}']
    function Get_PublishMonths: Integer; safecall;
    procedure Set_PublishMonths(retVal: Integer); safecall;
    function Get_FreeBusyList: IRDOFreeBusyRange; safecall;
    function Get_AutoAccept: WordBool; safecall;
    procedure Set_AutoAccept(retVal: WordBool); safecall;
    function Get_AutoDeclineConflict: WordBool; safecall;
    procedure Set_AutoDeclineConflict(retVal: WordBool); safecall;
    function Get_AutoDeclineRecurring: WordBool; safecall;
    procedure Set_AutoDeclineRecurring(retVal: WordBool); safecall;
    property PublishMonths: Integer read Get_PublishMonths write Set_PublishMonths;
    property FreeBusyList: IRDOFreeBusyRange read Get_FreeBusyList;
    property AutoAccept: WordBool read Get_AutoAccept write Set_AutoAccept;
    property AutoDeclineConflict: WordBool read Get_AutoDeclineConflict write Set_AutoDeclineConflict;
    property AutoDeclineRecurring: WordBool read Get_AutoDeclineRecurring write Set_AutoDeclineRecurring;
  end;

// *********************************************************************//
// DispIntf:  IRDOCalendarOptionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8D381511-EE3D-43AC-A5C4-93632DEFE6A7}
// *********************************************************************//
  IRDOCalendarOptionsDisp = dispinterface
    ['{8D381511-EE3D-43AC-A5C4-93632DEFE6A7}']
    property PublishMonths: Integer dispid 1610743810;
    property FreeBusyList: IRDOFreeBusyRange readonly dispid 1610743812;
    property AutoAccept: WordBool dispid 1610743818;
    property AutoDeclineConflict: WordBool dispid 1610743820;
    property AutoDeclineRecurring: WordBool dispid 1610743822;
  end;

// *********************************************************************//
// Interface: IRDOFreeBusyRange
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F2F7C8C-FE44-49DF-9B24-AD22A9937652}
// *********************************************************************//
  IRDOFreeBusyRange = interface(IDispatch)
    ['{2F2F7C8C-FE44-49DF-9B24-AD22A9937652}']
    function Get_Count: Integer; safecall;
    function Get__Item(Index: Integer): IRDOFreeBusySlot; safecall;
    function Item(Index: Integer): IRDOFreeBusySlot; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Start: TDateTime; safecall;
    function Get_End_: TDateTime; safecall;
    function Get_LastUpdated: TDateTime; safecall;
    property Count: Integer read Get_Count;
    property _Item[Index: Integer]: IRDOFreeBusySlot read Get__Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Start: TDateTime read Get_Start;
    property End_: TDateTime read Get_End_;
    property LastUpdated: TDateTime read Get_LastUpdated;
  end;

// *********************************************************************//
// DispIntf:  IRDOFreeBusyRangeDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F2F7C8C-FE44-49DF-9B24-AD22A9937652}
// *********************************************************************//
  IRDOFreeBusyRangeDisp = dispinterface
    ['{2F2F7C8C-FE44-49DF-9B24-AD22A9937652}']
    property Count: Integer readonly dispid 1610743808;
    property _Item[Index: Integer]: IRDOFreeBusySlot readonly dispid 0; default;
    function Item(Index: Integer): IRDOFreeBusySlot; dispid 1610743810;
    property _NewEnum: IUnknown readonly dispid -4;
    property Start: TDateTime readonly dispid 1610743812;
    property End_: TDateTime readonly dispid 1610743813;
    property LastUpdated: TDateTime readonly dispid 1610743814;
  end;

// *********************************************************************//
// Interface: IRDOFreeBusySlot
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DDC5A298-B9CE-4CCA-B733-185D2EDF5857}
// *********************************************************************//
  IRDOFreeBusySlot = interface(IDispatch)
    ['{DDC5A298-B9CE-4CCA-B733-185D2EDF5857}']
    function Get_Start: TDateTime; safecall;
    function Get_End_: TDateTime; safecall;
    function Get_BusyStatus: rdoBusyStatus; safecall;
    property Start: TDateTime read Get_Start;
    property End_: TDateTime read Get_End_;
    property BusyStatus: rdoBusyStatus read Get_BusyStatus;
  end;

// *********************************************************************//
// DispIntf:  IRDOFreeBusySlotDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DDC5A298-B9CE-4CCA-B733-185D2EDF5857}
// *********************************************************************//
  IRDOFreeBusySlotDisp = dispinterface
    ['{DDC5A298-B9CE-4CCA-B733-185D2EDF5857}']
    property Start: TDateTime readonly dispid 1610743808;
    property End_: TDateTime readonly dispid 1610743809;
    property BusyStatus: rdoBusyStatus readonly dispid 1610743810;
  end;

// *********************************************************************//
// The Class CoSafeRecipient provides a Create and CreateRemote method to          
// create instances of the default interface ISafeRecipient exposed by              
// the CoClass SafeRecipient. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeRecipient = class
    class function Create: ISafeRecipient;
    class function CreateRemote(const MachineName: string): ISafeRecipient;
  end;

// *********************************************************************//
// The Class CoSafeRecipients provides a Create and CreateRemote method to          
// create instances of the default interface ISafeRecipients exposed by              
// the CoClass SafeRecipients. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeRecipients = class
    class function Create: ISafeRecipients;
    class function CreateRemote(const MachineName: string): ISafeRecipients;
  end;

// *********************************************************************//
// The Class Co_BaseItem provides a Create and CreateRemote method to          
// create instances of the default interface _IBaseItem exposed by              
// the CoClass _BaseItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co_BaseItem = class
    class function Create: _IBaseItem;
    class function CreateRemote(const MachineName: string): _IBaseItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : T_BaseItem
// Help String      : 
// Default Interface: _IBaseItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  T_BaseItemProperties= class;
{$ENDIF}
  T_BaseItem = class(TOleServer)
  private
    FIntf: _IBaseItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: T_BaseItemProperties;
    function GetServerProperties: T_BaseItemProperties;
{$ENDIF}
    function GetDefaultInterface: _IBaseItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _IBaseItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    property DefaultInterface: _IBaseItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: T_BaseItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : T_BaseItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 T_BaseItemProperties = class(TPersistent)
  private
    FServer:    T_BaseItem;
    function    GetDefaultInterface: _IBaseItem;
    constructor Create(AServer: T_BaseItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
  public
    property DefaultInterface: _IBaseItem read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class Co_SafeItem provides a Create and CreateRemote method to          
// create instances of the default interface _ISafeItem exposed by              
// the CoClass _SafeItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co_SafeItem = class
    class function Create: _ISafeItem;
    class function CreateRemote(const MachineName: string): _ISafeItem;
  end;

// *********************************************************************//
// The Class CoSafeContactItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeContactItem exposed by              
// the CoClass SafeContactItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeContactItem = class
    class function Create: ISafeContactItem;
    class function CreateRemote(const MachineName: string): ISafeContactItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeContactItem
// Help String      : 
// Default Interface: ISafeContactItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeContactItemProperties= class;
{$ENDIF}
  TSafeContactItem = class(TOleServer)
  private
    FIntf: ISafeContactItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeContactItemProperties;
    function GetServerProperties: TSafeContactItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeContactItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_Email1Address: WideString;
    function Get_Email1AddressType: WideString;
    function Get_Email1DisplayName: WideString;
    function Get_Email1EntryID: WideString;
    function Get_Email2Address: WideString;
    function Get_Email2AddressType: WideString;
    function Get_Email2DisplayName: WideString;
    function Get_Email2EntryID: WideString;
    function Get_Email3Address: WideString;
    function Get_Email3AddressType: WideString;
    function Get_Email3DisplayName: WideString;
    function Get_Email3EntryID: WideString;
    function Get_NetMeetingAlias: WideString;
    function Get_ReferredBy: WideString;
    function Get_HTMLBody: WideString;
    function Get_IMAddress: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeContactItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeContactItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property Email1Address: WideString read Get_Email1Address;
    property Email1AddressType: WideString read Get_Email1AddressType;
    property Email1DisplayName: WideString read Get_Email1DisplayName;
    property Email1EntryID: WideString read Get_Email1EntryID;
    property Email2Address: WideString read Get_Email2Address;
    property Email2AddressType: WideString read Get_Email2AddressType;
    property Email2DisplayName: WideString read Get_Email2DisplayName;
    property Email2EntryID: WideString read Get_Email2EntryID;
    property Email3Address: WideString read Get_Email3Address;
    property Email3AddressType: WideString read Get_Email3AddressType;
    property Email3DisplayName: WideString read Get_Email3DisplayName;
    property Email3EntryID: WideString read Get_Email3EntryID;
    property NetMeetingAlias: WideString read Get_NetMeetingAlias;
    property ReferredBy: WideString read Get_ReferredBy;
    property HTMLBody: WideString read Get_HTMLBody;
    property IMAddress: WideString read Get_IMAddress;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeContactItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeContactItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeContactItemProperties = class(TPersistent)
  private
    FServer:    TSafeContactItem;
    function    GetDefaultInterface: ISafeContactItem;
    constructor Create(AServer: TSafeContactItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_Email1Address: WideString;
    function Get_Email1AddressType: WideString;
    function Get_Email1DisplayName: WideString;
    function Get_Email1EntryID: WideString;
    function Get_Email2Address: WideString;
    function Get_Email2AddressType: WideString;
    function Get_Email2DisplayName: WideString;
    function Get_Email2EntryID: WideString;
    function Get_Email3Address: WideString;
    function Get_Email3AddressType: WideString;
    function Get_Email3DisplayName: WideString;
    function Get_Email3EntryID: WideString;
    function Get_NetMeetingAlias: WideString;
    function Get_ReferredBy: WideString;
    function Get_HTMLBody: WideString;
    function Get_IMAddress: WideString;
  public
    property DefaultInterface: ISafeContactItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeAppointmentItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeAppointmentItem exposed by              
// the CoClass SafeAppointmentItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeAppointmentItem = class
    class function Create: ISafeAppointmentItem;
    class function CreateRemote(const MachineName: string): ISafeAppointmentItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeAppointmentItem
// Help String      : 
// Default Interface: ISafeAppointmentItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeAppointmentItemProperties= class;
{$ENDIF}
  TSafeAppointmentItem = class(TOleServer)
  private
    FIntf: ISafeAppointmentItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeAppointmentItemProperties;
    function GetServerProperties: TSafeAppointmentItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeAppointmentItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_Organizer: WideString;
    function Get_RequiredAttendees: WideString;
    function Get_OptionalAttendees: WideString;
    function Get_Resources: WideString;
    function Get_NetMeetingOrganizerAlias: WideString;
    function Get_HTMLBody: WideString;
    function Get_SendAsICal: WordBool;
    procedure Set_SendAsICal(retVal: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeAppointmentItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeAppointmentItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property Organizer: WideString read Get_Organizer;
    property RequiredAttendees: WideString read Get_RequiredAttendees;
    property OptionalAttendees: WideString read Get_OptionalAttendees;
    property Resources: WideString read Get_Resources;
    property NetMeetingOrganizerAlias: WideString read Get_NetMeetingOrganizerAlias;
    property HTMLBody: WideString read Get_HTMLBody;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
    property SendAsICal: WordBool read Get_SendAsICal write Set_SendAsICal;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeAppointmentItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeAppointmentItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeAppointmentItemProperties = class(TPersistent)
  private
    FServer:    TSafeAppointmentItem;
    function    GetDefaultInterface: ISafeAppointmentItem;
    constructor Create(AServer: TSafeAppointmentItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_Organizer: WideString;
    function Get_RequiredAttendees: WideString;
    function Get_OptionalAttendees: WideString;
    function Get_Resources: WideString;
    function Get_NetMeetingOrganizerAlias: WideString;
    function Get_HTMLBody: WideString;
    function Get_SendAsICal: WordBool;
    procedure Set_SendAsICal(retVal: WordBool);
  public
    property DefaultInterface: ISafeAppointmentItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
    property SendAsICal: WordBool read Get_SendAsICal write Set_SendAsICal;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeMailItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeMailItem exposed by              
// the CoClass SafeMailItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeMailItem = class
    class function Create: ISafeMailItem;
    class function CreateRemote(const MachineName: string): ISafeMailItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeMailItem
// Help String      : Safe Replica of the Outlook's MailItem
// Default Interface: ISafeMailItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeMailItemProperties= class;
{$ENDIF}
  TSafeMailItem = class(TOleServer)
  private
    FIntf: ISafeMailItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeMailItemProperties;
    function GetServerProperties: TSafeMailItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeMailItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SentOnBehalfOfName: WideString;
    function Get_SenderName: WideString;
    function Get_ReceivedByName: WideString;
    function Get_ReceivedOnBehalfOfName: WideString;
    function Get_ReplyRecipientNames: WideString;
    function Get_To_: WideString;
    function Get_CC: WideString;
    function Get_BCC: WideString;
    function Get_ReplyRecipients: ISafeRecipients;
    function Get_HTMLBody: WideString;
    function Get_SenderEmailAddress: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeMailItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeMailItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property SentOnBehalfOfName: WideString read Get_SentOnBehalfOfName;
    property SenderName: WideString read Get_SenderName;
    property ReceivedByName: WideString read Get_ReceivedByName;
    property ReceivedOnBehalfOfName: WideString read Get_ReceivedOnBehalfOfName;
    property ReplyRecipientNames: WideString read Get_ReplyRecipientNames;
    property To_: WideString read Get_To_;
    property CC: WideString read Get_CC;
    property BCC: WideString read Get_BCC;
    property ReplyRecipients: ISafeRecipients read Get_ReplyRecipients;
    property HTMLBody: WideString read Get_HTMLBody;
    property SenderEmailAddress: WideString read Get_SenderEmailAddress;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeMailItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeMailItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeMailItemProperties = class(TPersistent)
  private
    FServer:    TSafeMailItem;
    function    GetDefaultInterface: ISafeMailItem;
    constructor Create(AServer: TSafeMailItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SentOnBehalfOfName: WideString;
    function Get_SenderName: WideString;
    function Get_ReceivedByName: WideString;
    function Get_ReceivedOnBehalfOfName: WideString;
    function Get_ReplyRecipientNames: WideString;
    function Get_To_: WideString;
    function Get_CC: WideString;
    function Get_BCC: WideString;
    function Get_ReplyRecipients: ISafeRecipients;
    function Get_HTMLBody: WideString;
    function Get_SenderEmailAddress: WideString;
  public
    property DefaultInterface: ISafeMailItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeTaskItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeTaskItem exposed by              
// the CoClass SafeTaskItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeTaskItem = class
    class function Create: ISafeTaskItem;
    class function CreateRemote(const MachineName: string): ISafeTaskItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeTaskItem
// Help String      : 
// Default Interface: ISafeTaskItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeTaskItemProperties= class;
{$ENDIF}
  TSafeTaskItem = class(TOleServer)
  private
    FIntf: ISafeTaskItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeTaskItemProperties;
    function GetServerProperties: TSafeTaskItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeTaskItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_ContactNames: WideString;
    function Get_Contacts: OleVariant;
    function Get_Delegator: WideString;
    function Get_Owner: WideString;
    function Get_StatusUpdateRecipients: WideString;
    function Get_StatusOnCompletionRecipients: WideString;
    function Get_HTMLBody: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeTaskItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeTaskItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property ContactNames: WideString read Get_ContactNames;
    property Contacts: OleVariant read Get_Contacts;
    property Delegator: WideString read Get_Delegator;
    property Owner: WideString read Get_Owner;
    property StatusUpdateRecipients: WideString read Get_StatusUpdateRecipients;
    property StatusOnCompletionRecipients: WideString read Get_StatusOnCompletionRecipients;
    property HTMLBody: WideString read Get_HTMLBody;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeTaskItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeTaskItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeTaskItemProperties = class(TPersistent)
  private
    FServer:    TSafeTaskItem;
    function    GetDefaultInterface: ISafeTaskItem;
    constructor Create(AServer: TSafeTaskItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_ContactNames: WideString;
    function Get_Contacts: OleVariant;
    function Get_Delegator: WideString;
    function Get_Owner: WideString;
    function Get_StatusUpdateRecipients: WideString;
    function Get_StatusOnCompletionRecipients: WideString;
    function Get_HTMLBody: WideString;
  public
    property DefaultInterface: ISafeTaskItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeJournalItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeJournalItem exposed by              
// the CoClass SafeJournalItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeJournalItem = class
    class function Create: ISafeJournalItem;
    class function CreateRemote(const MachineName: string): ISafeJournalItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeJournalItem
// Help String      : 
// Default Interface: ISafeJournalItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeJournalItemProperties= class;
{$ENDIF}
  TSafeJournalItem = class(TOleServer)
  private
    FIntf: ISafeJournalItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeJournalItemProperties;
    function GetServerProperties: TSafeJournalItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeJournalItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_ContactNames: WideString;
    function Get_HTMLBody: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeJournalItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeJournalItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property ContactNames: WideString read Get_ContactNames;
    property HTMLBody: WideString read Get_HTMLBody;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeJournalItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeJournalItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeJournalItemProperties = class(TPersistent)
  private
    FServer:    TSafeJournalItem;
    function    GetDefaultInterface: ISafeJournalItem;
    constructor Create(AServer: TSafeJournalItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_ContactNames: WideString;
    function Get_HTMLBody: WideString;
  public
    property DefaultInterface: ISafeJournalItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeMeetingItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeMeetingItem exposed by              
// the CoClass SafeMeetingItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeMeetingItem = class
    class function Create: ISafeMeetingItem;
    class function CreateRemote(const MachineName: string): ISafeMeetingItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeMeetingItem
// Help String      : 
// Default Interface: ISafeMeetingItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeMeetingItemProperties= class;
{$ENDIF}
  TSafeMeetingItem = class(TOleServer)
  private
    FIntf: ISafeMeetingItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeMeetingItemProperties;
    function GetServerProperties: TSafeMeetingItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeMeetingItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SenderName: WideString;
    function Get_HTMLBody: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeMeetingItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeMeetingItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property SenderName: WideString read Get_SenderName;
    property HTMLBody: WideString read Get_HTMLBody;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeMeetingItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeMeetingItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeMeetingItemProperties = class(TPersistent)
  private
    FServer:    TSafeMeetingItem;
    function    GetDefaultInterface: ISafeMeetingItem;
    constructor Create(AServer: TSafeMeetingItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SenderName: WideString;
    function Get_HTMLBody: WideString;
  public
    property DefaultInterface: ISafeMeetingItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafePostItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafePostItem exposed by              
// the CoClass SafePostItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafePostItem = class
    class function Create: ISafePostItem;
    class function CreateRemote(const MachineName: string): ISafePostItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafePostItem
// Help String      : 
// Default Interface: ISafePostItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafePostItemProperties= class;
{$ENDIF}
  TSafePostItem = class(TOleServer)
  private
    FIntf: ISafePostItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafePostItemProperties;
    function GetServerProperties: TSafePostItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafePostItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SenderName: WideString;
    function Get_HTMLBody: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafePostItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafePostItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property SenderName: WideString read Get_SenderName;
    property HTMLBody: WideString read Get_HTMLBody;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafePostItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafePostItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafePostItemProperties = class(TPersistent)
  private
    FServer:    TSafePostItem;
    function    GetDefaultInterface: ISafePostItem;
    constructor Create(AServer: TSafePostItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_SenderName: WideString;
    function Get_HTMLBody: WideString;
  public
    property DefaultInterface: ISafePostItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoMAPIUtils provides a Create and CreateRemote method to          
// create instances of the default interface IMAPIUtils exposed by              
// the CoClass MAPIUtils. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMAPIUtils = class
    class function Create: IMAPIUtils;
    class function CreateRemote(const MachineName: string): IMAPIUtils;
  end;

  TMAPIUtilsNewMail = procedure(ASender: TObject; const Item: IDispatch) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMAPIUtils
// Help String      : 
// Default Interface: IMAPIUtils
// Def. Intf. DISP? : No
// Event   Interface: IMAPIUtilsEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMAPIUtilsProperties= class;
{$ENDIF}
  TMAPIUtils = class(TOleServer)
  private
    FOnNewMail: TMAPIUtilsNewMail;
    FIntf: IMAPIUtils;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMAPIUtilsProperties;
    function GetServerProperties: TMAPIUtilsProperties;
{$ENDIF}
    function GetDefaultInterface: IMAPIUtils;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Version: WideString;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const Value: IUnknown);
    function Get_AddressBookFilter: WideString;
    procedure Set_AddressBookFilter(const Value: WideString);
    function Get_CurrentProfileName: WideString;
    function Get_DefaultABListEntryID: WideString;
    procedure Set_DefaultABListEntryID(const Value: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IMAPIUtils);
    procedure Disconnect; override;
    function HrGetOneProp(const MAPIProp: IUnknown; PropTag: Integer): OleVariant;
    function HrSetOneProp(const MAPIProp: IUnknown; PropTag: Integer; Value: OleVariant; 
                          bSave: WordBool): Integer;
    function GetIDsFromNames(const MAPIProp: IUnknown; const GUID: WideString; ID: OleVariant; 
                             bCreate: WordBool): Integer;
    procedure DeliverNow(Flags: Integer; ParentWndHandle: Integer);
    function AddressBook: ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant; 
                         CcLabel: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant; 
                         CcLabel: OleVariant; BccLabel: OleVariant): ISafeRecipients; overload;
    function AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                         ForceResolution: OleVariant; RecipLists: OleVariant; ToLabel: OleVariant; 
                         CcLabel: OleVariant; BccLabel: OleVariant; ParentWindow: OleVariant): ISafeRecipients; overload;
    function CompareIDs(const ID1: WideString; const ID2: WideString): WordBool;
    function GetAddressEntryFromID(const ID: WideString): IAddressEntry;
    procedure Cleanup;
    function GetItemFromID(const EntryIDItem: WideString): IMessageItem; overload;
    function GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem; overload;
    function CreateRecipient(const Name: WideString; ShowDialog: WordBool; ParentWnd: Integer): ISafeRecipient;
    function HrArrayToString(InputArray: OleVariant): WideString;
    function HrStringToArray(const InputString: WideString): OleVariant;
    function HrLocalToGMT(Value: TDateTime): TDateTime;
    function HrGMTToLocal(Value: TDateTime): TDateTime;
    function GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty;
    function HrGetPropList(const Obj: IUnknown; UseUnicode: WordBool): IPropList;
    function GetItemFromMsgFile(const FileName: WideString; CreateNew: WordBool): IMessageItem;
    function GetItemFromIDEx(const EntryIDItem: WideString): IMessageItem; overload;
    function GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem; overload;
    function GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IMessageItem; overload;
    function ScCreateConversationIndex(const ParentConversationIndex: WideString): WideString;
    property DefaultInterface: IMAPIUtils read GetDefaultInterface;
    property AuthKey: WideString write Set_AuthKey;
    property Version: WideString read Get_Version;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property CurrentProfileName: WideString read Get_CurrentProfileName;
    property AddressBookFilter: WideString read Get_AddressBookFilter write Set_AddressBookFilter;
    property DefaultABListEntryID: WideString read Get_DefaultABListEntryID write Set_DefaultABListEntryID;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMAPIUtilsProperties read GetServerProperties;
{$ENDIF}
    property OnNewMail: TMAPIUtilsNewMail read FOnNewMail write FOnNewMail;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMAPIUtils
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMAPIUtilsProperties = class(TPersistent)
  private
    FServer:    TMAPIUtils;
    function    GetDefaultInterface: IMAPIUtils;
    constructor Create(AServer: TMAPIUtils);
  protected
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Version: WideString;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const Value: IUnknown);
    function Get_AddressBookFilter: WideString;
    procedure Set_AddressBookFilter(const Value: WideString);
    function Get_CurrentProfileName: WideString;
    function Get_DefaultABListEntryID: WideString;
    procedure Set_DefaultABListEntryID(const Value: WideString);
  public
    property DefaultInterface: IMAPIUtils read GetDefaultInterface;
  published
    property AddressBookFilter: WideString read Get_AddressBookFilter write Set_AddressBookFilter;
    property DefaultABListEntryID: WideString read Get_DefaultABListEntryID write Set_DefaultABListEntryID;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoAddressEntry provides a Create and CreateRemote method to          
// create instances of the default interface IAddressEntry exposed by              
// the CoClass AddressEntry. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddressEntry = class
    class function Create: IAddressEntry;
    class function CreateRemote(const MachineName: string): IAddressEntry;
  end;

// *********************************************************************//
// The Class CoAddressEntries provides a Create and CreateRemote method to          
// create instances of the default interface IAddressEntries exposed by              
// the CoClass AddressEntries. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddressEntries = class
    class function Create: IAddressEntries;
    class function CreateRemote(const MachineName: string): IAddressEntries;
  end;

// *********************************************************************//
// The Class CoAttachment provides a Create and CreateRemote method to          
// create instances of the default interface IAttachment exposed by              
// the CoClass Attachment. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAttachment = class
    class function Create: IAttachment;
    class function CreateRemote(const MachineName: string): IAttachment;
  end;

// *********************************************************************//
// The Class CoAttachments provides a Create and CreateRemote method to          
// create instances of the default interface IAttachments exposed by              
// the CoClass Attachments. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAttachments = class
    class function Create: IAttachments;
    class function CreateRemote(const MachineName: string): IAttachments;
  end;

// *********************************************************************//
// The Class CoMAPIFolder provides a Create and CreateRemote method to          
// create instances of the default interface ISafeMAPIFolder exposed by              
// the CoClass MAPIFolder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMAPIFolder = class
    class function Create: ISafeMAPIFolder;
    class function CreateRemote(const MachineName: string): ISafeMAPIFolder;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMAPIFolder
// Help String      : 
// Default Interface: ISafeMAPIFolder
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMAPIFolderProperties= class;
{$ENDIF}
  TMAPIFolder = class(TOleServer)
  private
    FIntf: ISafeMAPIFolder;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMAPIFolderProperties;
    function GetServerProperties: TMAPIFolderProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeMAPIFolder;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_MAPIOBJECT: IUnknown;
    function Get_HiddenItems: ISafeItems;
    function Get_Items: ISafeItems;
    function Get_DeletedItems: IDeletedItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeMAPIFolder);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure SetMAPIOBJECT(const Folder: IUnknown);
    property DefaultInterface: ISafeMAPIFolder read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT;
    property HiddenItems: ISafeItems read Get_HiddenItems;
    property Items: ISafeItems read Get_Items;
    property DeletedItems: IDeletedItems read Get_DeletedItems;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMAPIFolderProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMAPIFolder
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMAPIFolderProperties = class(TPersistent)
  private
    FServer:    TMAPIFolder;
    function    GetDefaultInterface: ISafeMAPIFolder;
    constructor Create(AServer: TMAPIFolder);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_MAPIOBJECT: IUnknown;
    function Get_HiddenItems: ISafeItems;
    function Get_Items: ISafeItems;
    function Get_DeletedItems: IDeletedItems;
  public
    property DefaultInterface: ISafeMAPIFolder read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeCurrentUser provides a Create and CreateRemote method to          
// create instances of the default interface ISafeCurrentUser exposed by              
// the CoClass SafeCurrentUser. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeCurrentUser = class
    class function Create: ISafeCurrentUser;
    class function CreateRemote(const MachineName: string): ISafeCurrentUser;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeCurrentUser
// Help String      : 
// Default Interface: ISafeCurrentUser
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeCurrentUserProperties= class;
{$ENDIF}
  TSafeCurrentUser = class(TOleServer)
  private
    FIntf: ISafeCurrentUser;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeCurrentUserProperties;
    function GetServerProperties: TSafeCurrentUserProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeCurrentUser;
  protected
    procedure InitServerData; override;
    function Get_Application: IDispatch;
    function Get_Class_: Integer;
    function Get_Session: IDispatch;
    function Get_Parent: IDispatch;
    function Get_Address: WideString;
    procedure Set_Address(const Address: WideString);
    function Get_DisplayType: Integer;
    function Get_ID: WideString;
    function Get_Manager: IAddressEntry;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const MAPIOBJECT: IUnknown);
    function Get_Members: IDispatch;
    function Get_Name: WideString;
    procedure Set_Name(const Name: WideString);
    function Get_type_: WideString;
    procedure Set_type_(const Type_: WideString);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_SMTPAddress: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeCurrentUser);
    procedure Disconnect; override;
    procedure Delete;
    procedure Details; overload;
    procedure Details(HWnd: OleVariant); overload;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer): WideString; overload;
    function GetFreeBusy(Start: TDateTime; MinPerChar: Integer; CompleteFormat: OleVariant): WideString; overload;
    procedure Update; overload;
    procedure Update(MakePermanent: OleVariant); overload;
    procedure Update(MakePermanent: OleVariant; Refresh: OleVariant); overload;
    procedure UpdateFreeBusy;
    procedure Cleanup;
    property DefaultInterface: ISafeCurrentUser read GetDefaultInterface;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Session: IDispatch read Get_Session;
    property Parent: IDispatch read Get_Parent;
    property DisplayType: Integer read Get_DisplayType;
    property ID: WideString read Get_ID;
    property Manager: IAddressEntry read Get_Manager;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property Members: IDispatch read Get_Members;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property SMTPAddress: WideString read Get_SMTPAddress;
    property Address: WideString read Get_Address write Set_Address;
    property Name: WideString read Get_Name write Set_Name;
    property type_: WideString read Get_type_ write Set_type_;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeCurrentUserProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeCurrentUser
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeCurrentUserProperties = class(TPersistent)
  private
    FServer:    TSafeCurrentUser;
    function    GetDefaultInterface: ISafeCurrentUser;
    constructor Create(AServer: TSafeCurrentUser);
  protected
    function Get_Application: IDispatch;
    function Get_Class_: Integer;
    function Get_Session: IDispatch;
    function Get_Parent: IDispatch;
    function Get_Address: WideString;
    procedure Set_Address(const Address: WideString);
    function Get_DisplayType: Integer;
    function Get_ID: WideString;
    function Get_Manager: IAddressEntry;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const MAPIOBJECT: IUnknown);
    function Get_Members: IDispatch;
    function Get_Name: WideString;
    procedure Set_Name(const Name: WideString);
    function Get_type_: WideString;
    procedure Set_type_(const Type_: WideString);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_SMTPAddress: WideString;
  public
    property DefaultInterface: ISafeCurrentUser read GetDefaultInterface;
  published
    property Address: WideString read Get_Address write Set_Address;
    property Name: WideString read Get_Name write Set_Name;
    property type_: WideString read Get_type_ write Set_type_;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeTable provides a Create and CreateRemote method to          
// create instances of the default interface ISafeTable exposed by              
// the CoClass SafeTable. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeTable = class
    class function Create: ISafeTable;
    class function CreateRemote(const MachineName: string): ISafeTable;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeTable
// Help String      : 
// Default Interface: ISafeTable
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeTableProperties= class;
{$ENDIF}
  TSafeTable = class(TOleServer)
  private
    FIntf: ISafeTable;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeTableProperties;
    function GetServerProperties: TSafeTableProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeTable;
  protected
    procedure InitServerData; override;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeTable);
    procedure Disconnect; override;
    property DefaultInterface: ISafeTable read GetDefaultInterface;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeTableProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeTable
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeTableProperties = class(TPersistent)
  private
    FServer:    TSafeTable;
    function    GetDefaultInterface: ISafeTable;
    constructor Create(AServer: TSafeTable);
  protected
    function Get_Count: Integer;
  public
    property DefaultInterface: ISafeTable read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeDistList provides a Create and CreateRemote method to          
// create instances of the default interface ISafeDistList exposed by              
// the CoClass SafeDistList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeDistList = class
    class function Create: ISafeDistList;
    class function CreateRemote(const MachineName: string): ISafeDistList;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeDistList
// Help String      : 
// Default Interface: ISafeDistList
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeDistListProperties= class;
{$ENDIF}
  TSafeDistList = class(TOleServer)
  private
    FIntf: ISafeDistList;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeDistListProperties;
    function GetServerProperties: TSafeDistListProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeDistList;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_MemberCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeDistList);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    function GetMember(Index: Integer): ISafeRecipient;
    procedure AddMember(Recipient: OleVariant);
    procedure AddMembers(Recipients: OleVariant);
    procedure RemoveMember(Recipient: OleVariant);
    procedure RemoveMembers(Recipients: OleVariant);
    procedure RemoveMemberEx(Index: Integer);
    function AddMemberEx(const Name: WideString; Address: OleVariant; AddressType: OleVariant): ISafeRecipient;
    property DefaultInterface: ISafeDistList read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property MemberCount: Integer read Get_MemberCount;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeDistListProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeDistList
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeDistListProperties = class(TPersistent)
  private
    FServer:    TSafeDistList;
    function    GetDefaultInterface: ISafeDistList;
    constructor Create(AServer: TSafeDistList);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
    function Get_MemberCount: Integer;
  public
    property DefaultInterface: ISafeDistList read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoAddressLists provides a Create and CreateRemote method to          
// create instances of the default interface IAddressLists exposed by              
// the CoClass AddressLists. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddressLists = class
    class function Create: IAddressLists;
    class function CreateRemote(const MachineName: string): IAddressLists;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TAddressLists
// Help String      : 
// Default Interface: IAddressLists
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TAddressListsProperties= class;
{$ENDIF}
  TAddressLists = class(TOleServer)
  private
    FIntf: IAddressLists;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TAddressListsProperties;
    function GetServerProperties: TAddressListsProperties;
{$ENDIF}
    function GetDefaultInterface: IAddressLists;
  protected
    procedure InitServerData; override;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAddressLists);
    procedure Disconnect; override;
    function Item(Index: OleVariant): IAddressList;
    property DefaultInterface: IAddressLists read GetDefaultInterface;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TAddressListsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TAddressLists
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TAddressListsProperties = class(TPersistent)
  private
    FServer:    TAddressLists;
    function    GetDefaultInterface: IAddressLists;
    constructor Create(AServer: TAddressLists);
  protected
    function Get_Count: Integer;
  public
    property DefaultInterface: IAddressLists read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoAddressList provides a Create and CreateRemote method to          
// create instances of the default interface IAddressList exposed by              
// the CoClass AddressList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddressList = class
    class function Create: IAddressList;
    class function CreateRemote(const MachineName: string): IAddressList;
  end;

// *********************************************************************//
// The Class CoSafeItems provides a Create and CreateRemote method to          
// create instances of the default interface ISafeItems exposed by              
// the CoClass SafeItems. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeItems = class
    class function Create: ISafeItems;
    class function CreateRemote(const MachineName: string): ISafeItems;
  end;

// *********************************************************************//
// The Class CoMessageItem provides a Create and CreateRemote method to          
// create instances of the default interface IMessageItem exposed by              
// the CoClass MessageItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMessageItem = class
    class function Create: IMessageItem;
    class function CreateRemote(const MachineName: string): IMessageItem;
  end;

// *********************************************************************//
// The Class CoMAPITable provides a Create and CreateRemote method to          
// create instances of the default interface _IMAPITable exposed by              
// the CoClass MAPITable. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMAPITable = class
    class function Create: _IMAPITable;
    class function CreateRemote(const MachineName: string): _IMAPITable;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMAPITable
// Help String      : 
// Default Interface: _IMAPITable
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMAPITableProperties= class;
{$ENDIF}
  TMAPITable = class(TOleServer)
  private
    FIntf: _IMAPITable;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMAPITableProperties;
    function GetServerProperties: TMAPITableProperties;
{$ENDIF}
    function GetDefaultInterface: _IMAPITable;
  protected
    procedure InitServerData; override;
    function Get_Item: IUnknown;
    procedure Set_Item(const Value: IUnknown);
    function Get_RowCount: Integer;
    function Get_Columns: OleVariant;
    procedure Set_Columns(Value: OleVariant);
    function Get_Filter: ITableFilter;
    function Get_Position: Integer;
    procedure Set_Position(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _IMAPITable);
    procedure Disconnect; override;
    procedure GoToFirst;
    procedure GoToLast;
    procedure GoTo_(Index: Integer);
    function GetRow: OleVariant;
    function GetRows(Count: Integer): OleVariant;
    procedure Sort(Property_: OleVariant); overload;
    procedure Sort(Property_: OleVariant; Descending: OleVariant); overload;
    function ExecSQL(const SQLCommand: WideString): IDispatch;
    property DefaultInterface: _IMAPITable read GetDefaultInterface;
    property Item: IUnknown read Get_Item write Set_Item;
    property RowCount: Integer read Get_RowCount;
    property Columns: OleVariant read Get_Columns write Set_Columns;
    property Filter: ITableFilter read Get_Filter;
    property Position: Integer read Get_Position write Set_Position;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMAPITableProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMAPITable
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMAPITableProperties = class(TPersistent)
  private
    FServer:    TMAPITable;
    function    GetDefaultInterface: _IMAPITable;
    constructor Create(AServer: TMAPITable);
  protected
    function Get_Item: IUnknown;
    procedure Set_Item(const Value: IUnknown);
    function Get_RowCount: Integer;
    function Get_Columns: OleVariant;
    procedure Set_Columns(Value: OleVariant);
    function Get_Filter: ITableFilter;
    function Get_Position: Integer;
    procedure Set_Position(Value: Integer);
  public
    property DefaultInterface: _IMAPITable read GetDefaultInterface;
  published
    property Position: Integer read Get_Position write Set_Position;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeletedItems provides a Create and CreateRemote method to          
// create instances of the default interface IDeletedItems exposed by              
// the CoClass DeletedItems. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeletedItems = class
    class function Create: IDeletedItems;
    class function CreateRemote(const MachineName: string): IDeletedItems;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeletedItems
// Help String      : 
// Default Interface: IDeletedItems
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeletedItemsProperties= class;
{$ENDIF}
  TDeletedItems = class(TOleServer)
  private
    FIntf: IDeletedItems;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeletedItemsProperties;
    function GetServerProperties: TDeletedItemsProperties;
{$ENDIF}
    function GetDefaultInterface: IDeletedItems;
  protected
    procedure InitServerData; override;
    function Get_Application: IDispatch;
    function Get_Class_: Integer;
    function Get_Count: Integer;
    function Get_Parent: IDispatch;
    function Get_RawTable: IUnknown;
    function Get_Session: IDispatch;
    function Get_MAPITable: _IMAPITable;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeletedItems);
    procedure Disconnect; override;
    function Add(Type_: OleVariant): IMessageItem;
    function GetFirst: IDispatch;
    function GetLast: IDispatch;
    function GetNext: IDispatch;
    function GetPrevious: IDispatch;
    function Item(Index: OleVariant): IMessageItem;
    procedure Remove(Index: Integer);
    function _Item(Index: OleVariant): IMessageItem;
    procedure Restore(Index: OleVariant);
    property DefaultInterface: IDeletedItems read GetDefaultInterface;
    property Application: IDispatch read Get_Application;
    property Class_: Integer read Get_Class_;
    property Count: Integer read Get_Count;
    property Parent: IDispatch read Get_Parent;
    property RawTable: IUnknown read Get_RawTable;
    property Session: IDispatch read Get_Session;
    property MAPITable: _IMAPITable read Get_MAPITable;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeletedItemsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeletedItems
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeletedItemsProperties = class(TPersistent)
  private
    FServer:    TDeletedItems;
    function    GetDefaultInterface: IDeletedItems;
    constructor Create(AServer: TDeletedItems);
  protected
    function Get_Application: IDispatch;
    function Get_Class_: Integer;
    function Get_Count: Integer;
    function Get_Parent: IDispatch;
    function Get_RawTable: IUnknown;
    function Get_Session: IDispatch;
    function Get_MAPITable: _IMAPITable;
  public
    property DefaultInterface: IDeletedItems read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoRestrictionAnd provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionAnd exposed by              
// the CoClass RestrictionAnd. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionAnd = class
    class function Create: IRestrictionAnd;
    class function CreateRemote(const MachineName: string): IRestrictionAnd;
  end;

// *********************************************************************//
// The Class CoRestrictionBitmask provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionBitmask exposed by              
// the CoClass RestrictionBitmask. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionBitmask = class
    class function Create: IRestrictionBitmask;
    class function CreateRemote(const MachineName: string): IRestrictionBitmask;
  end;

// *********************************************************************//
// The Class CoRestrictionCompareProps provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionCompareProps exposed by              
// the CoClass RestrictionCompareProps. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionCompareProps = class
    class function Create: IRestrictionCompareProps;
    class function CreateRemote(const MachineName: string): IRestrictionCompareProps;
  end;

// *********************************************************************//
// The Class CoRestrictionContent provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionContent exposed by              
// the CoClass RestrictionContent. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionContent = class
    class function Create: IRestrictionContent;
    class function CreateRemote(const MachineName: string): IRestrictionContent;
  end;

// *********************************************************************//
// The Class CoRestrictionExist provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionExist exposed by              
// the CoClass RestrictionExist. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionExist = class
    class function Create: IRestrictionExist;
    class function CreateRemote(const MachineName: string): IRestrictionExist;
  end;

// *********************************************************************//
// The Class CoRestrictionNot provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionNot exposed by              
// the CoClass RestrictionNot. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionNot = class
    class function Create: IRestrictionNot;
    class function CreateRemote(const MachineName: string): IRestrictionNot;
  end;

// *********************************************************************//
// The Class CoRestrictionOr provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionOr exposed by              
// the CoClass RestrictionOr. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionOr = class
    class function Create: IRestrictionOr;
    class function CreateRemote(const MachineName: string): IRestrictionOr;
  end;

// *********************************************************************//
// The Class CoRestrictionProperty provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionProperty exposed by              
// the CoClass RestrictionProperty. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionProperty = class
    class function Create: IRestrictionProperty;
    class function CreateRemote(const MachineName: string): IRestrictionProperty;
  end;

// *********************************************************************//
// The Class CoRestrictionSize provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionSize exposed by              
// the CoClass RestrictionSize. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionSize = class
    class function Create: IRestrictionSize;
    class function CreateRemote(const MachineName: string): IRestrictionSize;
  end;

// *********************************************************************//
// The Class CoRestrictionSub provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionSub exposed by              
// the CoClass RestrictionSub. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionSub = class
    class function Create: IRestrictionSub;
    class function CreateRemote(const MachineName: string): IRestrictionSub;
  end;

// *********************************************************************//
// The Class CoTableFilter provides a Create and CreateRemote method to          
// create instances of the default interface ITableFilter exposed by              
// the CoClass TableFilter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTableFilter = class
    class function Create: ITableFilter;
    class function CreateRemote(const MachineName: string): ITableFilter;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TTableFilter
// Help String      : 
// Default Interface: ITableFilter
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TTableFilterProperties= class;
{$ENDIF}
  TTableFilter = class(TOleServer)
  private
    FIntf: ITableFilter;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TTableFilterProperties;
    function GetServerProperties: TTableFilterProperties;
{$ENDIF}
    function GetDefaultInterface: ITableFilter;
  protected
    procedure InitServerData; override;
    function Get_Restriction: _IRestriction;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ITableFilter);
    procedure Disconnect; override;
    procedure Clear;
    function SetKind(Kind: RestrictionKind): _IRestriction;
    procedure Restrict;
    function FindFirst(Forward: WordBool): WordBool;
    function FindLast(Forward: WordBool): WordBool;
    function FindNext(Forward: WordBool): WordBool;
    property DefaultInterface: ITableFilter read GetDefaultInterface;
    property Restriction: _IRestriction read Get_Restriction;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TTableFilterProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TTableFilter
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TTableFilterProperties = class(TPersistent)
  private
    FServer:    TTableFilter;
    function    GetDefaultInterface: ITableFilter;
    constructor Create(AServer: TTableFilter);
  protected
    function Get_Restriction: _IRestriction;
  public
    property DefaultInterface: ITableFilter read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class Co_Restriction provides a Create and CreateRemote method to          
// create instances of the default interface _IRestriction exposed by              
// the CoClass _Restriction. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co_Restriction = class
    class function Create: _IRestriction;
    class function CreateRemote(const MachineName: string): _IRestriction;
  end;

// *********************************************************************//
// The Class Co_RestrictionCollection provides a Create and CreateRemote method to          
// create instances of the default interface _IRestrictionCollection exposed by              
// the CoClass _RestrictionCollection. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co_RestrictionCollection = class
    class function Create: _IRestrictionCollection;
    class function CreateRemote(const MachineName: string): _IRestrictionCollection;
  end;

// *********************************************************************//
// The Class CoNamedProperty provides a Create and CreateRemote method to          
// create instances of the default interface INamedProperty exposed by              
// the CoClass NamedProperty. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoNamedProperty = class
    class function Create: INamedProperty;
    class function CreateRemote(const MachineName: string): INamedProperty;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TNamedProperty
// Help String      : 
// Default Interface: INamedProperty
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TNamedPropertyProperties= class;
{$ENDIF}
  TNamedProperty = class(TOleServer)
  private
    FIntf: INamedProperty;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TNamedPropertyProperties;
    function GetServerProperties: TNamedPropertyProperties;
{$ENDIF}
    function GetDefaultInterface: INamedProperty;
  protected
    procedure InitServerData; override;
    function Get_GUID: WideString;
    function Get_ID: OleVariant;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: INamedProperty);
    procedure Disconnect; override;
    property DefaultInterface: INamedProperty read GetDefaultInterface;
    property GUID: WideString read Get_GUID;
    property ID: OleVariant read Get_ID;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TNamedPropertyProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TNamedProperty
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TNamedPropertyProperties = class(TPersistent)
  private
    FServer:    TNamedProperty;
    function    GetDefaultInterface: INamedProperty;
    constructor Create(AServer: TNamedProperty);
  protected
    function Get_GUID: WideString;
    function Get_ID: OleVariant;
  public
    property DefaultInterface: INamedProperty read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoPropList provides a Create and CreateRemote method to          
// create instances of the default interface IPropList exposed by              
// the CoClass PropList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPropList = class
    class function Create: IPropList;
    class function CreateRemote(const MachineName: string): IPropList;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TPropList
// Help String      : 
// Default Interface: IPropList
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TPropListProperties= class;
{$ENDIF}
  TPropList = class(TOleServer)
  private
    FIntf: IPropList;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TPropListProperties;
    function GetServerProperties: TPropListProperties;
{$ENDIF}
    function GetDefaultInterface: IPropList;
  protected
    procedure InitServerData; override;
    function Get_Count: Integer;
    function Get_Item(Index: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IPropList);
    procedure Disconnect; override;
    property DefaultInterface: IPropList read GetDefaultInterface;
    property Count: Integer read Get_Count;
    property Item[Index: Integer]: Integer read Get_Item; default;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TPropListProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TPropList
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TPropListProperties = class(TPersistent)
  private
    FServer:    TPropList;
    function    GetDefaultInterface: IPropList;
    constructor Create(AServer: TPropList);
  protected
    function Get_Count: Integer;
    function Get_Item(Index: Integer): Integer;
  public
    property DefaultInterface: IPropList read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeReportItem provides a Create and CreateRemote method to          
// create instances of the default interface ISafeReportItem exposed by              
// the CoClass SafeReportItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeReportItem = class
    class function Create: ISafeReportItem;
    class function CreateRemote(const MachineName: string): ISafeReportItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeReportItem
// Help String      : 
// Default Interface: ISafeReportItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeReportItemProperties= class;
{$ENDIF}
  TSafeReportItem = class(TOleServer)
  private
    FIntf: ISafeReportItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeReportItemProperties;
    function GetServerProperties: TSafeReportItemProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeReportItem;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeReportItem);
    procedure Disconnect; override;
    function GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
    procedure Send;
    procedure Import(const Path: WideString; Type_: Integer);
    procedure SaveAs(const Path: WideString); overload;
    procedure SaveAs(const Path: WideString; Type_: OleVariant); overload;
    procedure CopyTo(Item: OleVariant);
    property DefaultInterface: ISafeReportItem read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property Fields[PropTag: Integer]: OleVariant read Get_Fields write Set_Fields;
    property Version: WideString read Get_Version;
    property Recipients: ISafeRecipients read Get_Recipients;
    property Attachments: IAttachments read Get_Attachments;
    property AuthKey: WideString write Set_AuthKey;
    property Sender: IAddressEntry read Get_Sender;
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeReportItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeReportItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeReportItemProperties = class(TPersistent)
  private
    FServer:    TSafeReportItem;
    function    GetDefaultInterface: ISafeReportItem;
    constructor Create(AServer: TSafeReportItem);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_Fields(PropTag: Integer): OleVariant;
    procedure Set_Fields(PropTag: Integer; Value: OleVariant);
    function Get_Version: WideString;
    function Get_RTFBody: WideString;
    procedure Set_RTFBody(const Value: WideString);
    function Get_Recipients: ISafeRecipients;
    function Get_Attachments: IAttachments;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_Body: WideString;
    procedure Set_Body(const Value: WideString);
    function Get_Sender: IAddressEntry;
  public
    property DefaultInterface: ISafeReportItem read GetDefaultInterface;
  published
    property RTFBody: WideString read Get_RTFBody write Set_RTFBody;
    property Body: WideString read Get_Body write Set_Body;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSafeInspector provides a Create and CreateRemote method to          
// create instances of the default interface ISafeInspector exposed by              
// the CoClass SafeInspector. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSafeInspector = class
    class function Create: ISafeInspector;
    class function CreateRemote(const MachineName: string): ISafeInspector;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSafeInspector
// Help String      : 
// Default Interface: ISafeInspector
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSafeInspectorProperties= class;
{$ENDIF}
  TSafeInspector = class(TOleServer)
  private
    FIntf: ISafeInspector;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSafeInspectorProperties;
    function GetServerProperties: TSafeInspectorProperties;
{$ENDIF}
    function GetDefaultInterface: ISafeInspector;
  protected
    procedure InitServerData; override;
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_HTMLEditor: IDispatch;
    function Get_WordEditor: IDispatch;
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_PlainTextEditor: IPlainTextEditor;
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_RTFEditor: IRTFEditor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISafeInspector);
    procedure Disconnect; override;
    property DefaultInterface: ISafeInspector read GetDefaultInterface;
    property Item: IDispatch read Get_Item write Set_Item;
    property HTMLEditor: IDispatch read Get_HTMLEditor;
    property WordEditor: IDispatch read Get_WordEditor;
    property PlainTextEditor: IPlainTextEditor read Get_PlainTextEditor;
    property RTFEditor: IRTFEditor read Get_RTFEditor;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSafeInspectorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSafeInspector
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSafeInspectorProperties = class(TPersistent)
  private
    FServer:    TSafeInspector;
    function    GetDefaultInterface: ISafeInspector;
    constructor Create(AServer: TSafeInspector);
  protected
    function Get_Item: IDispatch;
    procedure Set_Item(const Value: IDispatch);
    function Get_HTMLEditor: IDispatch;
    function Get_WordEditor: IDispatch;
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_PlainTextEditor: IPlainTextEditor;
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_RTFEditor: IRTFEditor;
  public
    property DefaultInterface: ISafeInspector read GetDefaultInterface;
  published
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoPlainTextEditor provides a Create and CreateRemote method to          
// create instances of the default interface IPlainTextEditor exposed by              
// the CoClass PlainTextEditor. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPlainTextEditor = class
    class function Create: IPlainTextEditor;
    class function CreateRemote(const MachineName: string): IPlainTextEditor;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TPlainTextEditor
// Help String      : 
// Default Interface: IPlainTextEditor
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TPlainTextEditorProperties= class;
{$ENDIF}
  TPlainTextEditor = class(TOleServer)
  private
    FIntf: IPlainTextEditor;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TPlainTextEditorProperties;
    function GetServerProperties: TPlainTextEditorProperties;
{$ENDIF}
    function GetDefaultInterface: IPlainTextEditor;
  protected
    procedure InitServerData; override;
    function Get_CaretPosX: Integer;
    procedure Set_CaretPosX(Value: Integer);
    function Get_CaretPosY: Integer;
    procedure Set_CaretPosY(Value: Integer);
    function Get_CanUndo: WordBool;
    function Get_HideSelection: WordBool;
    procedure Set_HideSelection(Value: WordBool);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_SelLength: Integer;
    procedure Set_SelLength(Value: Integer);
    function Get_SelStart: Integer;
    procedure Set_SelStart(Value: Integer);
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_Handle: OLE_HANDLE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IPlainTextEditor);
    procedure Disconnect; override;
    procedure Clear;
    procedure ClearSelection;
    procedure ClearUndo;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure Undo;
    property DefaultInterface: IPlainTextEditor read GetDefaultInterface;
    property CanUndo: WordBool read Get_CanUndo;
    property Handle: OLE_HANDLE read Get_Handle;
    property CaretPosX: Integer read Get_CaretPosX write Set_CaretPosX;
    property CaretPosY: Integer read Get_CaretPosY write Set_CaretPosY;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TPlainTextEditorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TPlainTextEditor
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TPlainTextEditorProperties = class(TPersistent)
  private
    FServer:    TPlainTextEditor;
    function    GetDefaultInterface: IPlainTextEditor;
    constructor Create(AServer: TPlainTextEditor);
  protected
    function Get_CaretPosX: Integer;
    procedure Set_CaretPosX(Value: Integer);
    function Get_CaretPosY: Integer;
    procedure Set_CaretPosY(Value: Integer);
    function Get_CanUndo: WordBool;
    function Get_HideSelection: WordBool;
    procedure Set_HideSelection(Value: WordBool);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_SelLength: Integer;
    procedure Set_SelLength(Value: Integer);
    function Get_SelStart: Integer;
    procedure Set_SelStart(Value: Integer);
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_Handle: OLE_HANDLE;
  public
    property DefaultInterface: IPlainTextEditor read GetDefaultInterface;
  published
    property CaretPosX: Integer read Get_CaretPosX write Set_CaretPosX;
    property CaretPosY: Integer read Get_CaretPosY write Set_CaretPosY;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoRTFEditor provides a Create and CreateRemote method to          
// create instances of the default interface IRTFEditor exposed by              
// the CoClass RTFEditor. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRTFEditor = class
    class function Create: IRTFEditor;
    class function CreateRemote(const MachineName: string): IRTFEditor;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TRTFEditor
// Help String      : 
// Default Interface: IRTFEditor
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TRTFEditorProperties= class;
{$ENDIF}
  TRTFEditor = class(TOleServer)
  private
    FIntf: IRTFEditor;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TRTFEditorProperties;
    function GetServerProperties: TRTFEditorProperties;
{$ENDIF}
    function GetDefaultInterface: IRTFEditor;
  protected
    procedure InitServerData; override;
    function Get_CaretPosX: Integer;
    procedure Set_CaretPosX(Value: Integer);
    function Get_CaretPosY: Integer;
    procedure Set_CaretPosY(Value: Integer);
    function Get_CanUndo: WordBool;
    function Get_HideSelection: WordBool;
    procedure Set_HideSelection(Value: WordBool);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_SelLength: Integer;
    procedure Set_SelLength(Value: Integer);
    function Get_SelStart: Integer;
    procedure Set_SelStart(Value: Integer);
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_Handle: OLE_HANDLE;
    function Get_RTFSelText: WideString;
    procedure Set_RTFSelText(const Value: WideString);
    function Get_RTFText: WideString;
    procedure Set_RTFText(const Value: WideString);
    function Get_DefAttributes: ITextAttributes;
    function Get_SelAttributes: ITextAttributes;
    function Get_ParagraphAttributes: IParagraphAttributes;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IRTFEditor);
    procedure Disconnect; override;
    procedure Clear;
    procedure ClearSelection;
    procedure ClearUndo;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure Undo;
    property DefaultInterface: IRTFEditor read GetDefaultInterface;
    property CanUndo: WordBool read Get_CanUndo;
    property Handle: OLE_HANDLE read Get_Handle;
    property DefAttributes: ITextAttributes read Get_DefAttributes;
    property SelAttributes: ITextAttributes read Get_SelAttributes;
    property ParagraphAttributes: IParagraphAttributes read Get_ParagraphAttributes;
    property CaretPosX: Integer read Get_CaretPosX write Set_CaretPosX;
    property CaretPosY: Integer read Get_CaretPosY write Set_CaretPosY;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
    property RTFSelText: WideString read Get_RTFSelText write Set_RTFSelText;
    property RTFText: WideString read Get_RTFText write Set_RTFText;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TRTFEditorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TRTFEditor
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TRTFEditorProperties = class(TPersistent)
  private
    FServer:    TRTFEditor;
    function    GetDefaultInterface: IRTFEditor;
    constructor Create(AServer: TRTFEditor);
  protected
    function Get_CaretPosX: Integer;
    procedure Set_CaretPosX(Value: Integer);
    function Get_CaretPosY: Integer;
    procedure Set_CaretPosY(Value: Integer);
    function Get_CanUndo: WordBool;
    function Get_HideSelection: WordBool;
    procedure Set_HideSelection(Value: WordBool);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_SelLength: Integer;
    procedure Set_SelLength(Value: Integer);
    function Get_SelStart: Integer;
    procedure Set_SelStart(Value: Integer);
    function Get_SelText: WideString;
    procedure Set_SelText(const Value: WideString);
    function Get_Text: WideString;
    procedure Set_Text(const Value: WideString);
    function Get_Handle: OLE_HANDLE;
    function Get_RTFSelText: WideString;
    procedure Set_RTFSelText(const Value: WideString);
    function Get_RTFText: WideString;
    procedure Set_RTFText(const Value: WideString);
    function Get_DefAttributes: ITextAttributes;
    function Get_SelAttributes: ITextAttributes;
    function Get_ParagraphAttributes: IParagraphAttributes;
  public
    property DefaultInterface: IRTFEditor read GetDefaultInterface;
  published
    property CaretPosX: Integer read Get_CaretPosX write Set_CaretPosX;
    property CaretPosY: Integer read Get_CaretPosY write Set_CaretPosY;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property Text: WideString read Get_Text write Set_Text;
    property RTFSelText: WideString read Get_RTFSelText write Set_RTFSelText;
    property RTFText: WideString read Get_RTFText write Set_RTFText;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoTextAttributes provides a Create and CreateRemote method to          
// create instances of the default interface ITextAttributes exposed by              
// the CoClass TextAttributes. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTextAttributes = class
    class function Create: ITextAttributes;
    class function CreateRemote(const MachineName: string): ITextAttributes;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TTextAttributes
// Help String      : 
// Default Interface: ITextAttributes
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TTextAttributesProperties= class;
{$ENDIF}
  TTextAttributes = class(TOleServer)
  private
    FIntf: ITextAttributes;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TTextAttributesProperties;
    function GetServerProperties: TTextAttributesProperties;
{$ENDIF}
    function GetDefaultInterface: ITextAttributes;
  protected
    procedure InitServerData; override;
    function Get_Charset: Integer;
    procedure Set_Charset(Value: Integer);
    function Get_Color: OLE_COLOR;
    procedure Set_Color(Value: OLE_COLOR);
    function Get_Height: Integer;
    procedure Set_Height(Value: Integer);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Pitch: FontPitch;
    procedure Set_Pitch(Value: FontPitch);
    function Get_Protected_: WordBool;
    procedure Set_Protected_(Value: WordBool);
    function Get_Size: Integer;
    procedure Set_Size(Value: Integer);
    function Get_Style: IFontStyle;
    function Get_ConsistentAttributes: IConsistentAttributes;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ITextAttributes);
    procedure Disconnect; override;
    property DefaultInterface: ITextAttributes read GetDefaultInterface;
    property Style: IFontStyle read Get_Style;
    property ConsistentAttributes: IConsistentAttributes read Get_ConsistentAttributes;
    property Charset: Integer read Get_Charset write Set_Charset;
    property Color: OLE_COLOR read Get_Color write Set_Color;
    property Height: Integer read Get_Height write Set_Height;
    property Name: WideString read Get_Name write Set_Name;
    property Pitch: FontPitch read Get_Pitch write Set_Pitch;
    property Protected_: WordBool read Get_Protected_ write Set_Protected_;
    property Size: Integer read Get_Size write Set_Size;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TTextAttributesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TTextAttributes
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TTextAttributesProperties = class(TPersistent)
  private
    FServer:    TTextAttributes;
    function    GetDefaultInterface: ITextAttributes;
    constructor Create(AServer: TTextAttributes);
  protected
    function Get_Charset: Integer;
    procedure Set_Charset(Value: Integer);
    function Get_Color: OLE_COLOR;
    procedure Set_Color(Value: OLE_COLOR);
    function Get_Height: Integer;
    procedure Set_Height(Value: Integer);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Pitch: FontPitch;
    procedure Set_Pitch(Value: FontPitch);
    function Get_Protected_: WordBool;
    procedure Set_Protected_(Value: WordBool);
    function Get_Size: Integer;
    procedure Set_Size(Value: Integer);
    function Get_Style: IFontStyle;
    function Get_ConsistentAttributes: IConsistentAttributes;
  public
    property DefaultInterface: ITextAttributes read GetDefaultInterface;
  published
    property Charset: Integer read Get_Charset write Set_Charset;
    property Color: OLE_COLOR read Get_Color write Set_Color;
    property Height: Integer read Get_Height write Set_Height;
    property Name: WideString read Get_Name write Set_Name;
    property Pitch: FontPitch read Get_Pitch write Set_Pitch;
    property Protected_: WordBool read Get_Protected_ write Set_Protected_;
    property Size: Integer read Get_Size write Set_Size;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFontStyle provides a Create and CreateRemote method to          
// create instances of the default interface IFontStyle exposed by              
// the CoClass FontStyle. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFontStyle = class
    class function Create: IFontStyle;
    class function CreateRemote(const MachineName: string): IFontStyle;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFontStyle
// Help String      : 
// Default Interface: IFontStyle
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFontStyleProperties= class;
{$ENDIF}
  TFontStyle = class(TOleServer)
  private
    FIntf: IFontStyle;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFontStyleProperties;
    function GetServerProperties: TFontStyleProperties;
{$ENDIF}
    function GetDefaultInterface: IFontStyle;
  protected
    procedure InitServerData; override;
    function Get_Bold: WordBool;
    procedure Set_Bold(Value: WordBool);
    function Get_Italic: WordBool;
    procedure Set_Italic(Value: WordBool);
    function Get_Underline: WordBool;
    procedure Set_Underline(Value: WordBool);
    function Get_Strikeout: WordBool;
    procedure Set_Strikeout(Value: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFontStyle);
    procedure Disconnect; override;
    property DefaultInterface: IFontStyle read GetDefaultInterface;
    property Bold: WordBool read Get_Bold write Set_Bold;
    property Italic: WordBool read Get_Italic write Set_Italic;
    property Underline: WordBool read Get_Underline write Set_Underline;
    property Strikeout: WordBool read Get_Strikeout write Set_Strikeout;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFontStyleProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFontStyle
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFontStyleProperties = class(TPersistent)
  private
    FServer:    TFontStyle;
    function    GetDefaultInterface: IFontStyle;
    constructor Create(AServer: TFontStyle);
  protected
    function Get_Bold: WordBool;
    procedure Set_Bold(Value: WordBool);
    function Get_Italic: WordBool;
    procedure Set_Italic(Value: WordBool);
    function Get_Underline: WordBool;
    procedure Set_Underline(Value: WordBool);
    function Get_Strikeout: WordBool;
    procedure Set_Strikeout(Value: WordBool);
  public
    property DefaultInterface: IFontStyle read GetDefaultInterface;
  published
    property Bold: WordBool read Get_Bold write Set_Bold;
    property Italic: WordBool read Get_Italic write Set_Italic;
    property Underline: WordBool read Get_Underline write Set_Underline;
    property Strikeout: WordBool read Get_Strikeout write Set_Strikeout;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoConsistentAttributes provides a Create and CreateRemote method to          
// create instances of the default interface IConsistentAttributes exposed by              
// the CoClass ConsistentAttributes. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoConsistentAttributes = class
    class function Create: IConsistentAttributes;
    class function CreateRemote(const MachineName: string): IConsistentAttributes;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TConsistentAttributes
// Help String      : 
// Default Interface: IConsistentAttributes
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TConsistentAttributesProperties= class;
{$ENDIF}
  TConsistentAttributes = class(TOleServer)
  private
    FIntf: IConsistentAttributes;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TConsistentAttributesProperties;
    function GetServerProperties: TConsistentAttributesProperties;
{$ENDIF}
    function GetDefaultInterface: IConsistentAttributes;
  protected
    procedure InitServerData; override;
    function Get_Bold: WordBool;
    function Get_Color: WordBool;
    function Get_Face: WordBool;
    function Get_Italic: WordBool;
    function Get_Size: WordBool;
    function Get_Strikeout: WordBool;
    function Get_Underline: WordBool;
    function Get_Protected_: WordBool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IConsistentAttributes);
    procedure Disconnect; override;
    property DefaultInterface: IConsistentAttributes read GetDefaultInterface;
    property Bold: WordBool read Get_Bold;
    property Color: WordBool read Get_Color;
    property Face: WordBool read Get_Face;
    property Italic: WordBool read Get_Italic;
    property Size: WordBool read Get_Size;
    property Strikeout: WordBool read Get_Strikeout;
    property Underline: WordBool read Get_Underline;
    property Protected_: WordBool read Get_Protected_;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TConsistentAttributesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TConsistentAttributes
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TConsistentAttributesProperties = class(TPersistent)
  private
    FServer:    TConsistentAttributes;
    function    GetDefaultInterface: IConsistentAttributes;
    constructor Create(AServer: TConsistentAttributes);
  protected
    function Get_Bold: WordBool;
    function Get_Color: WordBool;
    function Get_Face: WordBool;
    function Get_Italic: WordBool;
    function Get_Size: WordBool;
    function Get_Strikeout: WordBool;
    function Get_Underline: WordBool;
    function Get_Protected_: WordBool;
  public
    property DefaultInterface: IConsistentAttributes read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoParagraphAttributes provides a Create and CreateRemote method to          
// create instances of the default interface IParagraphAttributes exposed by              
// the CoClass ParagraphAttributes. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoParagraphAttributes = class
    class function Create: IParagraphAttributes;
    class function CreateRemote(const MachineName: string): IParagraphAttributes;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TParagraphAttributes
// Help String      : 
// Default Interface: IParagraphAttributes
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TParagraphAttributesProperties= class;
{$ENDIF}
  TParagraphAttributes = class(TOleServer)
  private
    FIntf: IParagraphAttributes;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TParagraphAttributesProperties;
    function GetServerProperties: TParagraphAttributesProperties;
{$ENDIF}
    function GetDefaultInterface: IParagraphAttributes;
  protected
    procedure InitServerData; override;
    function Get_Alignment: TextAlignment;
    procedure Set_Alignment(Value: TextAlignment);
    function Get_FirstIndent: Integer;
    procedure Set_FirstIndent(Value: Integer);
    function Get_LeftIndent: Integer;
    procedure Set_LeftIndent(Value: Integer);
    function Get_RightIndent: Integer;
    procedure Set_RightIndent(Value: Integer);
    function Get_Numbering: NumberingStyle;
    procedure Set_Numbering(Value: NumberingStyle);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IParagraphAttributes);
    procedure Disconnect; override;
    property DefaultInterface: IParagraphAttributes read GetDefaultInterface;
    property Alignment: TextAlignment read Get_Alignment write Set_Alignment;
    property FirstIndent: Integer read Get_FirstIndent write Set_FirstIndent;
    property LeftIndent: Integer read Get_LeftIndent write Set_LeftIndent;
    property RightIndent: Integer read Get_RightIndent write Set_RightIndent;
    property Numbering: NumberingStyle read Get_Numbering write Set_Numbering;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TParagraphAttributesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TParagraphAttributes
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TParagraphAttributesProperties = class(TPersistent)
  private
    FServer:    TParagraphAttributes;
    function    GetDefaultInterface: IParagraphAttributes;
    constructor Create(AServer: TParagraphAttributes);
  protected
    function Get_Alignment: TextAlignment;
    procedure Set_Alignment(Value: TextAlignment);
    function Get_FirstIndent: Integer;
    procedure Set_FirstIndent(Value: Integer);
    function Get_LeftIndent: Integer;
    procedure Set_LeftIndent(Value: Integer);
    function Get_RightIndent: Integer;
    procedure Set_RightIndent(Value: Integer);
    function Get_Numbering: NumberingStyle;
    procedure Set_Numbering(Value: NumberingStyle);
  public
    property DefaultInterface: IParagraphAttributes read GetDefaultInterface;
  published
    property Alignment: TextAlignment read Get_Alignment write Set_Alignment;
    property FirstIndent: Integer read Get_FirstIndent write Set_FirstIndent;
    property LeftIndent: Integer read Get_LeftIndent write Set_LeftIndent;
    property RightIndent: Integer read Get_RightIndent write Set_RightIndent;
    property Numbering: NumberingStyle read Get_Numbering write Set_Numbering;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoRDOAddressBook provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressBook exposed by              
// the CoClass RDOAddressBook. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressBook = class
    class function Create: IRDOAddressBook;
    class function CreateRemote(const MachineName: string): IRDOAddressBook;
  end;

// *********************************************************************//
// The Class CoRDOExchangeMailboxStore provides a Create and CreateRemote method to          
// create instances of the default interface IRDOExchangeMailboxStore exposed by              
// the CoClass RDOExchangeMailboxStore. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOExchangeMailboxStore = class
    class function Create: IRDOExchangeMailboxStore;
    class function CreateRemote(const MachineName: string): IRDOExchangeMailboxStore;
  end;

// *********************************************************************//
// The Class CoRDOExchangeStore provides a Create and CreateRemote method to          
// create instances of the default interface IRDOExchangeStore exposed by              
// the CoClass RDOExchangeStore. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOExchangeStore = class
    class function Create: IRDOExchangeStore;
    class function CreateRemote(const MachineName: string): IRDOExchangeStore;
  end;

// *********************************************************************//
// The Class CoRDOPstStore provides a Create and CreateRemote method to          
// create instances of the default interface IRDOPstStore exposed by              
// the CoClass RDOPstStore. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOPstStore = class
    class function Create: IRDOPstStore;
    class function CreateRemote(const MachineName: string): IRDOPstStore;
  end;

// *********************************************************************//
// The Class CoRDOExchangePublicFoldersStore provides a Create and CreateRemote method to          
// create instances of the default interface IRDOExchangePublicFoldersStore exposed by              
// the CoClass RDOExchangePublicFoldersStore. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOExchangePublicFoldersStore = class
    class function Create: IRDOExchangePublicFoldersStore;
    class function CreateRemote(const MachineName: string): IRDOExchangePublicFoldersStore;
  end;

// *********************************************************************//
// The Class CoRDOAttachments provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAttachments exposed by              
// the CoClass RDOAttachments. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAttachments = class
    class function Create: IRDOAttachments;
    class function CreateRemote(const MachineName: string): IRDOAttachments;
  end;

// *********************************************************************//
// The Class CoRDOAttachment provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAttachment exposed by              
// the CoClass RDOAttachment. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAttachment = class
    class function Create: IRDOAttachment;
    class function CreateRemote(const MachineName: string): IRDOAttachment;
  end;

// *********************************************************************//
// The Class CoRDORecipients provides a Create and CreateRemote method to          
// create instances of the default interface IRDORecipients exposed by              
// the CoClass RDORecipients. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORecipients = class
    class function Create: IRDORecipients;
    class function CreateRemote(const MachineName: string): IRDORecipients;
  end;

// *********************************************************************//
// The Class CoRDORecipient provides a Create and CreateRemote method to          
// create instances of the default interface IRDORecipient exposed by              
// the CoClass RDORecipient. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORecipient = class
    class function Create: IRDORecipient;
    class function CreateRemote(const MachineName: string): IRDORecipient;
  end;

// *********************************************************************//
// The Class CoRDOAddressEntry provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressEntry exposed by              
// the CoClass RDOAddressEntry. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressEntry = class
    class function Create: IRDOAddressEntry;
    class function CreateRemote(const MachineName: string): IRDOAddressEntry;
  end;

// *********************************************************************//
// The Class CoRDOAddressEntries provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressEntries exposed by              
// the CoClass RDOAddressEntries. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressEntries = class
    class function Create: IRDOAddressEntries;
    class function CreateRemote(const MachineName: string): IRDOAddressEntries;
  end;

// *********************************************************************//
// The Class CoRDOAddressList provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressList exposed by              
// the CoClass RDOAddressList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressList = class
    class function Create: IRDOAddressList;
    class function CreateRemote(const MachineName: string): IRDOAddressList;
  end;

// *********************************************************************//
// The Class CoRDOAddressLists provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressLists exposed by              
// the CoClass RDOAddressLists. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressLists = class
    class function Create: IRDOAddressLists;
    class function CreateRemote(const MachineName: string): IRDOAddressLists;
  end;

// *********************************************************************//
// The Class CoRDOAddressBookSearchPath provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAddressBookSearchPath exposed by              
// the CoClass RDOAddressBookSearchPath. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAddressBookSearchPath = class
    class function Create: IRDOAddressBookSearchPath;
    class function CreateRemote(const MachineName: string): IRDOAddressBookSearchPath;
  end;

// *********************************************************************//
// The Class CoRDODeletedItems provides a Create and CreateRemote method to          
// create instances of the default interface IRDODeletedItems exposed by              
// the CoClass RDODeletedItems. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDODeletedItems = class
    class function Create: IRDODeletedItems;
    class function CreateRemote(const MachineName: string): IRDODeletedItems;
  end;

// *********************************************************************//
// The Class CoRDOSearchFolder provides a Create and CreateRemote method to          
// create instances of the default interface IRDOSearchFolder exposed by              
// the CoClass RDOSearchFolder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOSearchFolder = class
    class function Create: IRDOSearchFolder;
    class function CreateRemote(const MachineName: string): IRDOSearchFolder;
  end;

// *********************************************************************//
// The Class CoRDOFolderSearchCriteria provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolderSearchCriteria exposed by              
// the CoClass RDOFolderSearchCriteria. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolderSearchCriteria = class
    class function Create: IRDOFolderSearchCriteria;
    class function CreateRemote(const MachineName: string): IRDOFolderSearchCriteria;
  end;

// *********************************************************************//
// The Class CoRDOSearchContainersList provides a Create and CreateRemote method to          
// create instances of the default interface IRDOSearchContainersList exposed by              
// the CoClass RDOSearchContainersList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOSearchContainersList = class
    class function Create: IRDOSearchContainersList;
    class function CreateRemote(const MachineName: string): IRDOSearchContainersList;
  end;

// *********************************************************************//
// The Class CoRDOACL provides a Create and CreateRemote method to          
// create instances of the default interface IRDOACL exposed by              
// the CoClass RDOACL. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOACL = class
    class function Create: IRDOACL;
    class function CreateRemote(const MachineName: string): IRDOACL;
  end;

// *********************************************************************//
// The Class CoRDOACE provides a Create and CreateRemote method to          
// create instances of the default interface IRDOACE exposed by              
// the CoClass RDOACE. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOACE = class
    class function Create: IRDOACE;
    class function CreateRemote(const MachineName: string): IRDOACE;
  end;

// *********************************************************************//
// The Class CoRDOOutOfOfficeAssistant provides a Create and CreateRemote method to          
// create instances of the default interface IRDOOutOfOfficeAssistant exposed by              
// the CoClass RDOOutOfOfficeAssistant. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOOutOfOfficeAssistant = class
    class function Create: IRDOOutOfOfficeAssistant;
    class function CreateRemote(const MachineName: string): IRDOOutOfOfficeAssistant;
  end;

// *********************************************************************//
// The Class CoRDOReminders provides a Create and CreateRemote method to          
// create instances of the default interface IRDOReminders exposed by              
// the CoClass RDOReminders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOReminders = class
    class function Create: IRDOReminders;
    class function CreateRemote(const MachineName: string): IRDOReminders;
  end;

// *********************************************************************//
// The Class CoRDOReminder provides a Create and CreateRemote method to          
// create instances of the default interface IRDOReminder exposed by              
// the CoClass RDOReminder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOReminder = class
    class function Create: IRDOReminder;
    class function CreateRemote(const MachineName: string): IRDOReminder;
  end;

// *********************************************************************//
// The Class CoRDOAccount provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAccount exposed by              
// the CoClass RDOAccount. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAccount = class
    class function Create: IRDOAccount;
    class function CreateRemote(const MachineName: string): IRDOAccount;
  end;

// *********************************************************************//
// The Class CoRDOPOP3Account provides a Create and CreateRemote method to          
// create instances of the default interface IRDOPOP3Account exposed by              
// the CoClass RDOPOP3Account. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOPOP3Account = class
    class function Create: IRDOPOP3Account;
    class function CreateRemote(const MachineName: string): IRDOPOP3Account;
  end;

// *********************************************************************//
// The Class CoRDOMAPIAccount provides a Create and CreateRemote method to          
// create instances of the default interface IRDOMAPIAccount exposed by              
// the CoClass RDOMAPIAccount. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOMAPIAccount = class
    class function Create: IRDOMAPIAccount;
    class function CreateRemote(const MachineName: string): IRDOMAPIAccount;
  end;

// *********************************************************************//
// The Class CoRDOIMAPAccount provides a Create and CreateRemote method to          
// create instances of the default interface IRDOIMAPAccount exposed by              
// the CoClass RDOIMAPAccount. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOIMAPAccount = class
    class function Create: IRDOIMAPAccount;
    class function CreateRemote(const MachineName: string): IRDOIMAPAccount;
  end;

// *********************************************************************//
// The Class CoRDOHTTPAccount provides a Create and CreateRemote method to          
// create instances of the default interface IRDOHTTPAccount exposed by              
// the CoClass RDOHTTPAccount. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOHTTPAccount = class
    class function Create: IRDOHTTPAccount;
    class function CreateRemote(const MachineName: string): IRDOHTTPAccount;
  end;

// *********************************************************************//
// The Class CoRDOLDAPAccount provides a Create and CreateRemote method to          
// create instances of the default interface IRDOLDAPAccount exposed by              
// the CoClass RDOLDAPAccount. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOLDAPAccount = class
    class function Create: IRDOLDAPAccount;
    class function CreateRemote(const MachineName: string): IRDOLDAPAccount;
  end;

// *********************************************************************//
// The Class CoRDOAccountOrderList provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAccountOrderList exposed by              
// the CoClass RDOAccountOrderList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAccountOrderList = class
    class function Create: IRDOAccountOrderList;
    class function CreateRemote(const MachineName: string): IRDOAccountOrderList;
  end;

// *********************************************************************//
// The Class CoRDOSession provides a Create and CreateRemote method to          
// create instances of the default interface IRDOSession exposed by              
// the CoClass RDOSession. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOSession = class
    class function Create: IRDOSession;
    class function CreateRemote(const MachineName: string): IRDOSession;
  end;

  TRDOSessionOnNewMail = procedure(ASender: TObject; const EntryID: WideString) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TRDOSession
// Help String      : RDOSession object is the top level object in the RDO object hierarchy from which all other objects are retrieved. To be able to use RDOSession object properties and methods, log on to a MAPI session first by either setting the MAPIOBJECT property or calling Logon or LogonExchangeMailbox methods.
// Default Interface: IRDOSession
// Def. Intf. DISP? : No
// Event   Interface: IRDOSessionEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TRDOSessionProperties= class;
{$ENDIF}
  TRDOSession = class(TOleServer)
  private
    FOnNewMail: TRDOSessionOnNewMail;
    FIntf: IRDOSession;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TRDOSessionProperties;
    function GetServerProperties: TRDOSessionProperties;
{$ENDIF}
    function GetDefaultInterface: IRDOSession;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_ProfileName: WideString;
    function Get_LoggedOn: WordBool;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const Value: IUnknown);
    function Get_Stores: iRDOStores;
    function Get_AddressBook: IRDOAddressBook;
    function Get_CurrentUser: IRDOAddressEntry;
    function Get_Accounts: IRDOAccounts;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_TimeZones: IRDOTimezones;
    function Get_Profiles: IRDOProfiles;
    function Get_ExchangeConnectionMode: rdoExchangeConnectionMode;
    function Get_ExchangeMailboxServerName: WideString;
    function Get_ExchangeMailboxServerVersion: WideString;
    function Get_OutlookVersion: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IRDOSession);
    procedure Disconnect; override;
    procedure Logon; overload;
    procedure Logon(ProfileName: OleVariant); overload;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant); overload;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant); overload;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant); overload;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant; ParentWindowHandle: OleVariant); overload;
    procedure Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                    NewSession: OleVariant; ParentWindowHandle: OleVariant; NoMail: OleVariant); overload;
    procedure LogonExchangeMailbox(const User: WideString; const ServerName: WideString);
    function GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder;
    function GetMessageFromID(const EntryIDMessage: WideString): IRDOMail; overload;
    function GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant): IRDOMail; overload;
    function GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant; 
                              Flags: OleVariant): IRDOMail; overload;
    function GetFolderFromID(const EntryIDFolder: WideString): IRDOFolder; overload;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant): IRDOFolder; overload;
    function GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant; 
                             Flags: OleVariant): IRDOFolder; overload;
    function GetStoreFromID(const EntryIDStore: WideString): IRDOStore; overload;
    function GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore; overload;
    function GetAddressEntryFromID(const EntryID: WideString): IRDOAddressEntry; overload;
    function GetAddressEntryFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressEntry; overload;
    function CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool;
    function GetAddressListFromID(const EntryID: WideString): IRDOAddressList; overload;
    function GetAddressListFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressList; overload;
    function GetSharedDefaultFolder(NameOrAddressOrObject: OleVariant; 
                                    rdoDefaultFolder: rdoDefaultFolders): IRDOFolder;
    function GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore;
    procedure Logoff;
    function GetMessageFromMsgFile(const FileName: WideString; CreateNew: WordBool): IRDOMail;
    function GetFolderFromPath(const FolderPath: WideString): IRDOFolder;
    procedure SetLocaleIDs(LocaleID: Integer; CodePageID: Integer);
    property DefaultInterface: IRDOSession read GetDefaultInterface;
    property ProfileName: WideString read Get_ProfileName;
    property LoggedOn: WordBool read Get_LoggedOn;
    property MAPIOBJECT: IUnknown read Get_MAPIOBJECT write Set_MAPIOBJECT;
    property Stores: iRDOStores read Get_Stores;
    property AddressBook: IRDOAddressBook read Get_AddressBook;
    property CurrentUser: IRDOAddressEntry read Get_CurrentUser;
    property Accounts: IRDOAccounts read Get_Accounts;
    property AuthKey: WideString write Set_AuthKey;
    property TimeZones: IRDOTimezones read Get_TimeZones;
    property Profiles: IRDOProfiles read Get_Profiles;
    property ExchangeConnectionMode: rdoExchangeConnectionMode read Get_ExchangeConnectionMode;
    property ExchangeMailboxServerName: WideString read Get_ExchangeMailboxServerName;
    property ExchangeMailboxServerVersion: WideString read Get_ExchangeMailboxServerVersion;
    property OutlookVersion: WideString read Get_OutlookVersion;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TRDOSessionProperties read GetServerProperties;
{$ENDIF}
    property OnNewMail: TRDOSessionOnNewMail read FOnNewMail write FOnNewMail;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TRDOSession
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TRDOSessionProperties = class(TPersistent)
  private
    FServer:    TRDOSession;
    function    GetDefaultInterface: IRDOSession;
    constructor Create(AServer: TRDOSession);
  protected
    function Get_ProfileName: WideString;
    function Get_LoggedOn: WordBool;
    function Get_MAPIOBJECT: IUnknown;
    procedure Set_MAPIOBJECT(const Value: IUnknown);
    function Get_Stores: iRDOStores;
    function Get_AddressBook: IRDOAddressBook;
    function Get_CurrentUser: IRDOAddressEntry;
    function Get_Accounts: IRDOAccounts;
    procedure Set_AuthKey(const Param1: WideString);
    function Get_TimeZones: IRDOTimezones;
    function Get_Profiles: IRDOProfiles;
    function Get_ExchangeConnectionMode: rdoExchangeConnectionMode;
    function Get_ExchangeMailboxServerName: WideString;
    function Get_ExchangeMailboxServerVersion: WideString;
    function Get_OutlookVersion: WideString;
  public
    property DefaultInterface: IRDOSession read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoRDOStore provides a Create and CreateRemote method to          
// create instances of the default interface IRDOStore exposed by              
// the CoClass RDOStore. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOStore = class
    class function Create: IRDOStore;
    class function CreateRemote(const MachineName: string): IRDOStore;
  end;

// *********************************************************************//
// The Class CoRDOFolder provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolder exposed by              
// the CoClass RDOFolder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolder = class
    class function Create: IRDOFolder;
    class function CreateRemote(const MachineName: string): IRDOFolder;
  end;

// *********************************************************************//
// The Class CoRDOMail provides a Create and CreateRemote method to          
// create instances of the default interface IRDOMail exposed by              
// the CoClass RDOMail. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOMail = class
    class function Create: IRDOMail;
    class function CreateRemote(const MachineName: string): IRDOMail;
  end;

// *********************************************************************//
// The Class CoRDOItems provides a Create and CreateRemote method to          
// create instances of the default interface IRDOItems exposed by              
// the CoClass RDOItems. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOItems = class
    class function Create: IRDOItems;
    class function CreateRemote(const MachineName: string): IRDOItems;
  end;

// *********************************************************************//
// The Class CoRDOFolders provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolders exposed by              
// the CoClass RDOFolders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolders = class
    class function Create: IRDOFolders;
    class function CreateRemote(const MachineName: string): IRDOFolders;
  end;

// *********************************************************************//
// The Class CoRDOStores provides a Create and CreateRemote method to          
// create instances of the default interface iRDOStores exposed by              
// the CoClass RDOStores. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOStores = class
    class function Create: iRDOStores;
    class function CreateRemote(const MachineName: string): iRDOStores;
  end;

// *********************************************************************//
// The Class CoRDOAccounts provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAccounts exposed by              
// the CoClass RDOAccounts. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAccounts = class
    class function Create: IRDOAccounts;
    class function CreateRemote(const MachineName: string): IRDOAccounts;
  end;

// *********************************************************************//
// The Class CoRDODistListItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDODistListItem exposed by              
// the CoClass RDODistListItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDODistListItem = class
    class function Create: IRDODistListItem;
    class function CreateRemote(const MachineName: string): IRDODistListItem;
  end;

// *********************************************************************//
// The Class CoRDOContactItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOContactItem exposed by              
// the CoClass RDOContactItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOContactItem = class
    class function Create: IRDOContactItem;
    class function CreateRemote(const MachineName: string): IRDOContactItem;
  end;

// *********************************************************************//
// The Class CoRDOFolder2 provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolder2 exposed by              
// the CoClass RDOFolder2. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolder2 = class
    class function Create: IRDOFolder2;
    class function CreateRemote(const MachineName: string): IRDOFolder2;
  end;

// *********************************************************************//
// The Class CoRDONoteItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDONoteItem exposed by              
// the CoClass RDONoteItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDONoteItem = class
    class function Create: IRDONoteItem;
    class function CreateRemote(const MachineName: string): IRDONoteItem;
  end;

// *********************************************************************//
// The Class CoRDOPostItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOPostItem exposed by              
// the CoClass RDOPostItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOPostItem = class
    class function Create: IRDOPostItem;
    class function CreateRemote(const MachineName: string): IRDOPostItem;
  end;

// *********************************************************************//
// The Class CoRDOLinks provides a Create and CreateRemote method to          
// create instances of the default interface IRDOLinks exposed by              
// the CoClass RDOLinks. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOLinks = class
    class function Create: IRDOLinks;
    class function CreateRemote(const MachineName: string): IRDOLinks;
  end;

// *********************************************************************//
// The Class CoRDOLink provides a Create and CreateRemote method to          
// create instances of the default interface IRDOLink exposed by              
// the CoClass RDOLink. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOLink = class
    class function Create: IRDOLink;
    class function CreateRemote(const MachineName: string): IRDOLink;
  end;

// *********************************************************************//
// The Class CoRDOTaskItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOTaskItem exposed by              
// the CoClass RDOTaskItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOTaskItem = class
    class function Create: IRDOTaskItem;
    class function CreateRemote(const MachineName: string): IRDOTaskItem;
  end;

// *********************************************************************//
// The Class CoRDORecurrencePattern provides a Create and CreateRemote method to          
// create instances of the default interface IRDORecurrencePattern exposed by              
// the CoClass RDORecurrencePattern. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORecurrencePattern = class
    class function Create: IRDORecurrencePattern;
    class function CreateRemote(const MachineName: string): IRDORecurrencePattern;
  end;

// *********************************************************************//
// The Class CoRDOReportItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOReportItem exposed by              
// the CoClass RDOReportItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOReportItem = class
    class function Create: IRDOReportItem;
    class function CreateRemote(const MachineName: string): IRDOReportItem;
  end;

// *********************************************************************//
// The Class CoRDOFolderFields provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolderFields exposed by              
// the CoClass RDOFolderFields. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolderFields = class
    class function Create: IRDOFolderFields;
    class function CreateRemote(const MachineName: string): IRDOFolderFields;
  end;

// *********************************************************************//
// The Class CoRDOFolderField provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFolderField exposed by              
// the CoClass RDOFolderField. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFolderField = class
    class function Create: IRDOFolderField;
    class function CreateRemote(const MachineName: string): IRDOFolderField;
  end;

// *********************************************************************//
// The Class CoRDOTaskRequestItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOTaskRequestItem exposed by              
// the CoClass RDOTaskRequestItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOTaskRequestItem = class
    class function Create: IRDOTaskRequestItem;
    class function CreateRemote(const MachineName: string): IRDOTaskRequestItem;
  end;

// *********************************************************************//
// The Class CoRDOTimeZones provides a Create and CreateRemote method to          
// create instances of the default interface IRDOTimezones exposed by              
// the CoClass RDOTimeZones. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOTimeZones = class
    class function Create: IRDOTimezones;
    class function CreateRemote(const MachineName: string): IRDOTimezones;
  end;

// *********************************************************************//
// The Class CoRDOTimeZone provides a Create and CreateRemote method to          
// create instances of the default interface IRDOTimezone exposed by              
// the CoClass RDOTimeZone. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOTimeZone = class
    class function Create: IRDOTimezone;
    class function CreateRemote(const MachineName: string): IRDOTimezone;
  end;

// *********************************************************************//
// The Class CoRDOProfiles provides a Create and CreateRemote method to          
// create instances of the default interface IRDOProfiles exposed by              
// the CoClass RDOProfiles. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOProfiles = class
    class function Create: IRDOProfiles;
    class function CreateRemote(const MachineName: string): IRDOProfiles;
  end;

// *********************************************************************//
// The Class CoRDORules provides a Create and CreateRemote method to          
// create instances of the default interface IRDORules exposed by              
// the CoClass RDORules. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORules = class
    class function Create: IRDORules;
    class function CreateRemote(const MachineName: string): IRDORules;
  end;

// *********************************************************************//
// The Class CoRDORule provides a Create and CreateRemote method to          
// create instances of the default interface IRDORule exposed by              
// the CoClass RDORule. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORule = class
    class function Create: IRDORule;
    class function CreateRemote(const MachineName: string): IRDORule;
  end;

// *********************************************************************//
// The Class CoRDORuleActions provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActions exposed by              
// the CoClass RDORuleActions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActions = class
    class function Create: IRDORuleActions;
    class function CreateRemote(const MachineName: string): IRDORuleActions;
  end;

// *********************************************************************//
// The Class CoRDORuleConditions provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditions exposed by              
// the CoClass RDORuleConditions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditions = class
    class function Create: IRDORuleConditions;
    class function CreateRemote(const MachineName: string): IRDORuleConditions;
  end;

// *********************************************************************//
// The Class CoRDORuleAction provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleAction exposed by              
// the CoClass RDORuleAction. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleAction = class
    class function Create: IRDORuleAction;
    class function CreateRemote(const MachineName: string): IRDORuleAction;
  end;

// *********************************************************************//
// The Class CoRDORuleActionMoveorCopy provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionMoveOrCopy exposed by              
// the CoClass RDORuleActionMoveorCopy. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionMoveorCopy = class
    class function Create: IRDORuleActionMoveOrCopy;
    class function CreateRemote(const MachineName: string): IRDORuleActionMoveOrCopy;
  end;

// *********************************************************************//
// The Class CoRDORuleActionSend provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionSend exposed by              
// the CoClass RDORuleActionSend. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionSend = class
    class function Create: IRDORuleActionSend;
    class function CreateRemote(const MachineName: string): IRDORuleActionSend;
  end;

// *********************************************************************//
// The Class CoRDORuleActionTemplate provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionTemplate exposed by              
// the CoClass RDORuleActionTemplate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionTemplate = class
    class function Create: IRDORuleActionTemplate;
    class function CreateRemote(const MachineName: string): IRDORuleActionTemplate;
  end;

// *********************************************************************//
// The Class CoRDORuleActionDefer provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionDefer exposed by              
// the CoClass RDORuleActionDefer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionDefer = class
    class function Create: IRDORuleActionDefer;
    class function CreateRemote(const MachineName: string): IRDORuleActionDefer;
  end;

// *********************************************************************//
// The Class CoRDORuleActionBounce provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionBounce exposed by              
// the CoClass RDORuleActionBounce. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionBounce = class
    class function Create: IRDORuleActionBounce;
    class function CreateRemote(const MachineName: string): IRDORuleActionBounce;
  end;

// *********************************************************************//
// The Class CoRDORuleActionSensitivity provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionSensitivity exposed by              
// the CoClass RDORuleActionSensitivity. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionSensitivity = class
    class function Create: IRDORuleActionSensitivity;
    class function CreateRemote(const MachineName: string): IRDORuleActionSensitivity;
  end;

// *********************************************************************//
// The Class CoRDORuleActionImportance provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionImportance exposed by              
// the CoClass RDORuleActionImportance. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionImportance = class
    class function Create: IRDORuleActionImportance;
    class function CreateRemote(const MachineName: string): IRDORuleActionImportance;
  end;

// *********************************************************************//
// The Class CoRDORuleActionAssignToCategory provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionAssignToCategory exposed by              
// the CoClass RDORuleActionAssignToCategory. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionAssignToCategory = class
    class function Create: IRDORuleActionAssignToCategory;
    class function CreateRemote(const MachineName: string): IRDORuleActionAssignToCategory;
  end;

// *********************************************************************//
// The Class CoRDORuleActionTag provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleActionTag exposed by              
// the CoClass RDORuleActionTag. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleActionTag = class
    class function Create: IRDORuleActionTag;
    class function CreateRemote(const MachineName: string): IRDORuleActionTag;
  end;

// *********************************************************************//
// The Class CoRDOActions provides a Create and CreateRemote method to          
// create instances of the default interface IRDOActions exposed by              
// the CoClass RDOActions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOActions = class
    class function Create: IRDOActions;
    class function CreateRemote(const MachineName: string): IRDOActions;
  end;

// *********************************************************************//
// The Class CoRDOAction provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAction exposed by              
// the CoClass RDOAction. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAction = class
    class function Create: IRDOAction;
    class function CreateRemote(const MachineName: string): IRDOAction;
  end;

// *********************************************************************//
// The Class CoRDORuleCondition provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleCondition exposed by              
// the CoClass RDORuleCondition. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleCondition = class
    class function Create: IRDORuleCondition;
    class function CreateRemote(const MachineName: string): IRDORuleCondition;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionImportance provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionImportance exposed by              
// the CoClass RDORuleConditionImportance. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionImportance = class
    class function Create: IRDORuleConditionImportance;
    class function CreateRemote(const MachineName: string): IRDORuleConditionImportance;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionText provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionText exposed by              
// the CoClass RDORuleConditionText. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionText = class
    class function Create: IRDORuleConditionText;
    class function CreateRemote(const MachineName: string): IRDORuleConditionText;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionCategory provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionCategory exposed by              
// the CoClass RDORuleConditionCategory. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionCategory = class
    class function Create: IRDORuleConditionCategory;
    class function CreateRemote(const MachineName: string): IRDORuleConditionCategory;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionFormName provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionFormName exposed by              
// the CoClass RDORuleConditionFormName. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionFormName = class
    class function Create: IRDORuleConditionFormName;
    class function CreateRemote(const MachineName: string): IRDORuleConditionFormName;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionToOrFrom provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionToOrFrom exposed by              
// the CoClass RDORuleConditionToOrFrom. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionToOrFrom = class
    class function Create: IRDORuleConditionToOrFrom;
    class function CreateRemote(const MachineName: string): IRDORuleConditionToOrFrom;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionAddress provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionAddress exposed by              
// the CoClass RDORuleConditionAddress. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionAddress = class
    class function Create: IRDORuleConditionAddress;
    class function CreateRemote(const MachineName: string): IRDORuleConditionAddress;
  end;

// *********************************************************************//
// The Class CoRDORuleConditionSenderInAddressList provides a Create and CreateRemote method to          
// create instances of the default interface IRDORuleConditionSenderInAddressList exposed by              
// the CoClass RDORuleConditionSenderInAddressList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDORuleConditionSenderInAddressList = class
    class function Create: IRDORuleConditionSenderInAddressList;
    class function CreateRemote(const MachineName: string): IRDORuleConditionSenderInAddressList;
  end;

// *********************************************************************//
// The Class CoRestrictionComment provides a Create and CreateRemote method to          
// create instances of the default interface IRestrictionComment exposed by              
// the CoClass RestrictionComment. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRestrictionComment = class
    class function Create: IRestrictionComment;
    class function CreateRemote(const MachineName: string): IRestrictionComment;
  end;

// *********************************************************************//
// The Class CoPropValueList provides a Create and CreateRemote method to          
// create instances of the default interface IPropValueList exposed by              
// the CoClass PropValueList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPropValueList = class
    class function Create: IPropValueList;
    class function CreateRemote(const MachineName: string): IPropValueList;
  end;

// *********************************************************************//
// The Class CoPropValue provides a Create and CreateRemote method to          
// create instances of the default interface IPropValue exposed by              
// the CoClass PropValue. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPropValue = class
    class function Create: IPropValue;
    class function CreateRemote(const MachineName: string): IPropValue;
  end;

// *********************************************************************//
// The Class CoRDOAppointmentItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOAppointmentItem exposed by              
// the CoClass RDOAppointmentItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOAppointmentItem = class
    class function Create: IRDOAppointmentItem;
    class function CreateRemote(const MachineName: string): IRDOAppointmentItem;
  end;

// *********************************************************************//
// The Class CoRDOConflict provides a Create and CreateRemote method to          
// create instances of the default interface IRDOConflict exposed by              
// the CoClass RDOConflict. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOConflict = class
    class function Create: IRDOConflict;
    class function CreateRemote(const MachineName: string): IRDOConflict;
  end;

// *********************************************************************//
// The Class CoRDOConflicts provides a Create and CreateRemote method to          
// create instances of the default interface IRDOConflicts exposed by              
// the CoClass RDOConflicts. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOConflicts = class
    class function Create: IRDOConflicts;
    class function CreateRemote(const MachineName: string): IRDOConflicts;
  end;

// *********************************************************************//
// The Class CoRDOMeetingItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOMeetingItem exposed by              
// the CoClass RDOMeetingItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOMeetingItem = class
    class function Create: IRDOMeetingItem;
    class function CreateRemote(const MachineName: string): IRDOMeetingItem;
  end;

// *********************************************************************//
// The Class CoRDODeletedFolders provides a Create and CreateRemote method to          
// create instances of the default interface IRDODeletedFolders exposed by              
// the CoClass RDODeletedFolders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDODeletedFolders = class
    class function Create: IRDODeletedFolders;
    class function CreateRemote(const MachineName: string): IRDODeletedFolders;
  end;

// *********************************************************************//
// The Class CoRDOException provides a Create and CreateRemote method to          
// create instances of the default interface IRDOException exposed by              
// the CoClass RDOException. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOException = class
    class function Create: IRDOException;
    class function CreateRemote(const MachineName: string): IRDOException;
  end;

// *********************************************************************//
// The Class CoRDOExceptions provides a Create and CreateRemote method to          
// create instances of the default interface IRDOExceptions exposed by              
// the CoClass RDOExceptions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOExceptions = class
    class function Create: IRDOExceptions;
    class function CreateRemote(const MachineName: string): IRDOExceptions;
  end;

// *********************************************************************//
// The Class CoRDOJournalItem provides a Create and CreateRemote method to          
// create instances of the default interface IRDOJournalItem exposed by              
// the CoClass RDOJournalItem. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOJournalItem = class
    class function Create: IRDOJournalItem;
    class function CreateRemote(const MachineName: string): IRDOJournalItem;
  end;

// *********************************************************************//
// The Class CoRDOCalendarOptions provides a Create and CreateRemote method to          
// create instances of the default interface IRDOCalendarOptions exposed by              
// the CoClass RDOCalendarOptions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOCalendarOptions = class
    class function Create: IRDOCalendarOptions;
    class function CreateRemote(const MachineName: string): IRDOCalendarOptions;
  end;

// *********************************************************************//
// The Class CoRDOFreeBusyRange provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFreeBusyRange exposed by              
// the CoClass RDOFreeBusyRange. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFreeBusyRange = class
    class function Create: IRDOFreeBusyRange;
    class function CreateRemote(const MachineName: string): IRDOFreeBusyRange;
  end;

// *********************************************************************//
// The Class CoRDOFreeBusySlot provides a Create and CreateRemote method to          
// create instances of the default interface IRDOFreeBusySlot exposed by              
// the CoClass RDOFreeBusySlot. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRDOFreeBusySlot = class
    class function Create: IRDOFreeBusySlot;
    class function CreateRemote(const MachineName: string): IRDOFreeBusySlot;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoSafeRecipient.Create: ISafeRecipient;
begin
  Result := CreateComObject(CLASS_SafeRecipient) as ISafeRecipient;
end;

class function CoSafeRecipient.CreateRemote(const MachineName: string): ISafeRecipient;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeRecipient) as ISafeRecipient;
end;

class function CoSafeRecipients.Create: ISafeRecipients;
begin
  Result := CreateComObject(CLASS_SafeRecipients) as ISafeRecipients;
end;

class function CoSafeRecipients.CreateRemote(const MachineName: string): ISafeRecipients;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeRecipients) as ISafeRecipients;
end;

class function Co_BaseItem.Create: _IBaseItem;
begin
  Result := CreateComObject(CLASS__BaseItem) as _IBaseItem;
end;

class function Co_BaseItem.CreateRemote(const MachineName: string): _IBaseItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__BaseItem) as _IBaseItem;
end;

procedure T_BaseItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{81BDE41B-2202-4695-9B39-5ADC50ACF195}';
    IntfIID:   '{F71D2854-2609-4A63-B4BF-BF2BA61A61CF}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure T_BaseItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _IBaseItem;
  end;
end;

procedure T_BaseItem.ConnectTo(svrIntf: _IBaseItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure T_BaseItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function T_BaseItem.GetDefaultInterface: _IBaseItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor T_BaseItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := T_BaseItemProperties.Create(Self);
{$ENDIF}
end;

destructor T_BaseItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function T_BaseItem.GetServerProperties: T_BaseItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function T_BaseItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure T_BaseItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function T_BaseItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure T_BaseItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function T_BaseItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function T_BaseItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor T_BaseItemProperties.Create(AServer: T_BaseItem);
begin
  inherited Create;
  FServer := AServer;
end;

function T_BaseItemProperties.GetDefaultInterface: _IBaseItem;
begin
  Result := FServer.DefaultInterface;
end;

function T_BaseItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure T_BaseItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function T_BaseItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure T_BaseItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function T_BaseItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

{$ENDIF}

class function Co_SafeItem.Create: _ISafeItem;
begin
  Result := CreateComObject(CLASS__SafeItem) as _ISafeItem;
end;

class function Co_SafeItem.CreateRemote(const MachineName: string): _ISafeItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__SafeItem) as _ISafeItem;
end;

class function CoSafeContactItem.Create: ISafeContactItem;
begin
  Result := CreateComObject(CLASS_SafeContactItem) as ISafeContactItem;
end;

class function CoSafeContactItem.CreateRemote(const MachineName: string): ISafeContactItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeContactItem) as ISafeContactItem;
end;

procedure TSafeContactItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{4FD5C4D3-6C15-4EA0-9EB9-EEE8FC74A91B}';
    IntfIID:   '{3120A5E4-552D-4EDF-8C48-70C5D5FF22D2}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeContactItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeContactItem;
  end;
end;

procedure TSafeContactItem.ConnectTo(svrIntf: ISafeContactItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeContactItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeContactItem.GetDefaultInterface: ISafeContactItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeContactItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeContactItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeContactItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeContactItem.GetServerProperties: TSafeContactItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeContactItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeContactItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeContactItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeContactItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeContactItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeContactItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeContactItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeContactItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeContactItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeContactItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeContactItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeContactItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeContactItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeContactItem.Get_Email1Address: WideString;
begin
    Result := DefaultInterface.Email1Address;
end;

function TSafeContactItem.Get_Email1AddressType: WideString;
begin
    Result := DefaultInterface.Email1AddressType;
end;

function TSafeContactItem.Get_Email1DisplayName: WideString;
begin
    Result := DefaultInterface.Email1DisplayName;
end;

function TSafeContactItem.Get_Email1EntryID: WideString;
begin
    Result := DefaultInterface.Email1EntryID;
end;

function TSafeContactItem.Get_Email2Address: WideString;
begin
    Result := DefaultInterface.Email2Address;
end;

function TSafeContactItem.Get_Email2AddressType: WideString;
begin
    Result := DefaultInterface.Email2AddressType;
end;

function TSafeContactItem.Get_Email2DisplayName: WideString;
begin
    Result := DefaultInterface.Email2DisplayName;
end;

function TSafeContactItem.Get_Email2EntryID: WideString;
begin
    Result := DefaultInterface.Email2EntryID;
end;

function TSafeContactItem.Get_Email3Address: WideString;
begin
    Result := DefaultInterface.Email3Address;
end;

function TSafeContactItem.Get_Email3AddressType: WideString;
begin
    Result := DefaultInterface.Email3AddressType;
end;

function TSafeContactItem.Get_Email3DisplayName: WideString;
begin
    Result := DefaultInterface.Email3DisplayName;
end;

function TSafeContactItem.Get_Email3EntryID: WideString;
begin
    Result := DefaultInterface.Email3EntryID;
end;

function TSafeContactItem.Get_NetMeetingAlias: WideString;
begin
    Result := DefaultInterface.NetMeetingAlias;
end;

function TSafeContactItem.Get_ReferredBy: WideString;
begin
    Result := DefaultInterface.ReferredBy;
end;

function TSafeContactItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeContactItem.Get_IMAddress: WideString;
begin
    Result := DefaultInterface.IMAddress;
end;

function TSafeContactItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeContactItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeContactItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeContactItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeContactItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeContactItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeContactItemProperties.Create(AServer: TSafeContactItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeContactItemProperties.GetDefaultInterface: ISafeContactItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeContactItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeContactItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeContactItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeContactItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeContactItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeContactItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeContactItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeContactItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeContactItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeContactItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeContactItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeContactItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeContactItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeContactItemProperties.Get_Email1Address: WideString;
begin
    Result := DefaultInterface.Email1Address;
end;

function TSafeContactItemProperties.Get_Email1AddressType: WideString;
begin
    Result := DefaultInterface.Email1AddressType;
end;

function TSafeContactItemProperties.Get_Email1DisplayName: WideString;
begin
    Result := DefaultInterface.Email1DisplayName;
end;

function TSafeContactItemProperties.Get_Email1EntryID: WideString;
begin
    Result := DefaultInterface.Email1EntryID;
end;

function TSafeContactItemProperties.Get_Email2Address: WideString;
begin
    Result := DefaultInterface.Email2Address;
end;

function TSafeContactItemProperties.Get_Email2AddressType: WideString;
begin
    Result := DefaultInterface.Email2AddressType;
end;

function TSafeContactItemProperties.Get_Email2DisplayName: WideString;
begin
    Result := DefaultInterface.Email2DisplayName;
end;

function TSafeContactItemProperties.Get_Email2EntryID: WideString;
begin
    Result := DefaultInterface.Email2EntryID;
end;

function TSafeContactItemProperties.Get_Email3Address: WideString;
begin
    Result := DefaultInterface.Email3Address;
end;

function TSafeContactItemProperties.Get_Email3AddressType: WideString;
begin
    Result := DefaultInterface.Email3AddressType;
end;

function TSafeContactItemProperties.Get_Email3DisplayName: WideString;
begin
    Result := DefaultInterface.Email3DisplayName;
end;

function TSafeContactItemProperties.Get_Email3EntryID: WideString;
begin
    Result := DefaultInterface.Email3EntryID;
end;

function TSafeContactItemProperties.Get_NetMeetingAlias: WideString;
begin
    Result := DefaultInterface.NetMeetingAlias;
end;

function TSafeContactItemProperties.Get_ReferredBy: WideString;
begin
    Result := DefaultInterface.ReferredBy;
end;

function TSafeContactItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeContactItemProperties.Get_IMAddress: WideString;
begin
    Result := DefaultInterface.IMAddress;
end;

{$ENDIF}

class function CoSafeAppointmentItem.Create: ISafeAppointmentItem;
begin
  Result := CreateComObject(CLASS_SafeAppointmentItem) as ISafeAppointmentItem;
end;

class function CoSafeAppointmentItem.CreateRemote(const MachineName: string): ISafeAppointmentItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeAppointmentItem) as ISafeAppointmentItem;
end;

procedure TSafeAppointmentItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{620D55B0-F2FB-464E-A278-B4308DB1DB2B}';
    IntfIID:   '{35EFAD55-134A-47BF-912A-44A9D9FD556F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeAppointmentItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeAppointmentItem;
  end;
end;

procedure TSafeAppointmentItem.ConnectTo(svrIntf: ISafeAppointmentItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeAppointmentItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeAppointmentItem.GetDefaultInterface: ISafeAppointmentItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeAppointmentItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeAppointmentItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeAppointmentItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeAppointmentItem.GetServerProperties: TSafeAppointmentItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeAppointmentItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeAppointmentItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeAppointmentItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeAppointmentItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeAppointmentItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeAppointmentItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeAppointmentItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeAppointmentItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeAppointmentItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeAppointmentItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeAppointmentItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeAppointmentItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeAppointmentItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeAppointmentItem.Get_Organizer: WideString;
begin
    Result := DefaultInterface.Organizer;
end;

function TSafeAppointmentItem.Get_RequiredAttendees: WideString;
begin
    Result := DefaultInterface.RequiredAttendees;
end;

function TSafeAppointmentItem.Get_OptionalAttendees: WideString;
begin
    Result := DefaultInterface.OptionalAttendees;
end;

function TSafeAppointmentItem.Get_Resources: WideString;
begin
    Result := DefaultInterface.Resources;
end;

function TSafeAppointmentItem.Get_NetMeetingOrganizerAlias: WideString;
begin
    Result := DefaultInterface.NetMeetingOrganizerAlias;
end;

function TSafeAppointmentItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeAppointmentItem.Get_SendAsICal: WordBool;
begin
    Result := DefaultInterface.SendAsICal;
end;

procedure TSafeAppointmentItem.Set_SendAsICal(retVal: WordBool);
begin
  DefaultInterface.Set_SendAsICal(retVal);
end;

function TSafeAppointmentItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeAppointmentItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeAppointmentItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeAppointmentItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeAppointmentItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeAppointmentItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeAppointmentItemProperties.Create(AServer: TSafeAppointmentItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeAppointmentItemProperties.GetDefaultInterface: ISafeAppointmentItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeAppointmentItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeAppointmentItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeAppointmentItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeAppointmentItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeAppointmentItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeAppointmentItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeAppointmentItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeAppointmentItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeAppointmentItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeAppointmentItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeAppointmentItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeAppointmentItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeAppointmentItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeAppointmentItemProperties.Get_Organizer: WideString;
begin
    Result := DefaultInterface.Organizer;
end;

function TSafeAppointmentItemProperties.Get_RequiredAttendees: WideString;
begin
    Result := DefaultInterface.RequiredAttendees;
end;

function TSafeAppointmentItemProperties.Get_OptionalAttendees: WideString;
begin
    Result := DefaultInterface.OptionalAttendees;
end;

function TSafeAppointmentItemProperties.Get_Resources: WideString;
begin
    Result := DefaultInterface.Resources;
end;

function TSafeAppointmentItemProperties.Get_NetMeetingOrganizerAlias: WideString;
begin
    Result := DefaultInterface.NetMeetingOrganizerAlias;
end;

function TSafeAppointmentItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeAppointmentItemProperties.Get_SendAsICal: WordBool;
begin
    Result := DefaultInterface.SendAsICal;
end;

procedure TSafeAppointmentItemProperties.Set_SendAsICal(retVal: WordBool);
begin
  DefaultInterface.Set_SendAsICal(retVal);
end;

{$ENDIF}

class function CoSafeMailItem.Create: ISafeMailItem;
begin
  Result := CreateComObject(CLASS_SafeMailItem) as ISafeMailItem;
end;

class function CoSafeMailItem.CreateRemote(const MachineName: string): ISafeMailItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeMailItem) as ISafeMailItem;
end;

procedure TSafeMailItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{741BEEFD-AEC0-4AFF-84AF-4F61D15F5526}';
    IntfIID:   '{0A95BE2D-1543-46BE-AD6D-18653034BF87}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeMailItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeMailItem;
  end;
end;

procedure TSafeMailItem.ConnectTo(svrIntf: ISafeMailItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeMailItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeMailItem.GetDefaultInterface: ISafeMailItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeMailItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeMailItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeMailItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeMailItem.GetServerProperties: TSafeMailItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeMailItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeMailItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeMailItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeMailItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeMailItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeMailItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeMailItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeMailItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeMailItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeMailItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeMailItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeMailItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeMailItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeMailItem.Get_SentOnBehalfOfName: WideString;
begin
    Result := DefaultInterface.SentOnBehalfOfName;
end;

function TSafeMailItem.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafeMailItem.Get_ReceivedByName: WideString;
begin
    Result := DefaultInterface.ReceivedByName;
end;

function TSafeMailItem.Get_ReceivedOnBehalfOfName: WideString;
begin
    Result := DefaultInterface.ReceivedOnBehalfOfName;
end;

function TSafeMailItem.Get_ReplyRecipientNames: WideString;
begin
    Result := DefaultInterface.ReplyRecipientNames;
end;

function TSafeMailItem.Get_To_: WideString;
begin
    Result := DefaultInterface.To_;
end;

function TSafeMailItem.Get_CC: WideString;
begin
    Result := DefaultInterface.CC;
end;

function TSafeMailItem.Get_BCC: WideString;
begin
    Result := DefaultInterface.BCC;
end;

function TSafeMailItem.Get_ReplyRecipients: ISafeRecipients;
begin
    Result := DefaultInterface.ReplyRecipients;
end;

function TSafeMailItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeMailItem.Get_SenderEmailAddress: WideString;
begin
    Result := DefaultInterface.SenderEmailAddress;
end;

function TSafeMailItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeMailItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeMailItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeMailItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeMailItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeMailItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeMailItemProperties.Create(AServer: TSafeMailItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeMailItemProperties.GetDefaultInterface: ISafeMailItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeMailItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeMailItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeMailItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeMailItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeMailItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeMailItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeMailItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeMailItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeMailItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeMailItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeMailItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeMailItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeMailItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeMailItemProperties.Get_SentOnBehalfOfName: WideString;
begin
    Result := DefaultInterface.SentOnBehalfOfName;
end;

function TSafeMailItemProperties.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafeMailItemProperties.Get_ReceivedByName: WideString;
begin
    Result := DefaultInterface.ReceivedByName;
end;

function TSafeMailItemProperties.Get_ReceivedOnBehalfOfName: WideString;
begin
    Result := DefaultInterface.ReceivedOnBehalfOfName;
end;

function TSafeMailItemProperties.Get_ReplyRecipientNames: WideString;
begin
    Result := DefaultInterface.ReplyRecipientNames;
end;

function TSafeMailItemProperties.Get_To_: WideString;
begin
    Result := DefaultInterface.To_;
end;

function TSafeMailItemProperties.Get_CC: WideString;
begin
    Result := DefaultInterface.CC;
end;

function TSafeMailItemProperties.Get_BCC: WideString;
begin
    Result := DefaultInterface.BCC;
end;

function TSafeMailItemProperties.Get_ReplyRecipients: ISafeRecipients;
begin
    Result := DefaultInterface.ReplyRecipients;
end;

function TSafeMailItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeMailItemProperties.Get_SenderEmailAddress: WideString;
begin
    Result := DefaultInterface.SenderEmailAddress;
end;

{$ENDIF}

class function CoSafeTaskItem.Create: ISafeTaskItem;
begin
  Result := CreateComObject(CLASS_SafeTaskItem) as ISafeTaskItem;
end;

class function CoSafeTaskItem.CreateRemote(const MachineName: string): ISafeTaskItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeTaskItem) as ISafeTaskItem;
end;

procedure TSafeTaskItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{7A41359E-0407-470F-B3F7-7C6A0F7C449A}';
    IntfIID:   '{F961CE9D-AE2B-4CFB-887C-3A055FF685C9}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeTaskItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeTaskItem;
  end;
end;

procedure TSafeTaskItem.ConnectTo(svrIntf: ISafeTaskItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeTaskItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeTaskItem.GetDefaultInterface: ISafeTaskItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeTaskItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeTaskItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeTaskItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeTaskItem.GetServerProperties: TSafeTaskItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeTaskItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeTaskItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeTaskItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeTaskItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeTaskItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeTaskItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeTaskItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeTaskItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeTaskItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeTaskItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeTaskItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeTaskItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeTaskItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeTaskItem.Get_ContactNames: WideString;
begin
    Result := DefaultInterface.ContactNames;
end;

function TSafeTaskItem.Get_Contacts: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Contacts;
end;

function TSafeTaskItem.Get_Delegator: WideString;
begin
    Result := DefaultInterface.Delegator;
end;

function TSafeTaskItem.Get_Owner: WideString;
begin
    Result := DefaultInterface.Owner;
end;

function TSafeTaskItem.Get_StatusUpdateRecipients: WideString;
begin
    Result := DefaultInterface.StatusUpdateRecipients;
end;

function TSafeTaskItem.Get_StatusOnCompletionRecipients: WideString;
begin
    Result := DefaultInterface.StatusOnCompletionRecipients;
end;

function TSafeTaskItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeTaskItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeTaskItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeTaskItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeTaskItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeTaskItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeTaskItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeTaskItemProperties.Create(AServer: TSafeTaskItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeTaskItemProperties.GetDefaultInterface: ISafeTaskItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeTaskItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeTaskItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeTaskItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeTaskItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeTaskItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeTaskItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeTaskItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeTaskItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeTaskItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeTaskItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeTaskItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeTaskItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeTaskItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeTaskItemProperties.Get_ContactNames: WideString;
begin
    Result := DefaultInterface.ContactNames;
end;

function TSafeTaskItemProperties.Get_Contacts: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Contacts;
end;

function TSafeTaskItemProperties.Get_Delegator: WideString;
begin
    Result := DefaultInterface.Delegator;
end;

function TSafeTaskItemProperties.Get_Owner: WideString;
begin
    Result := DefaultInterface.Owner;
end;

function TSafeTaskItemProperties.Get_StatusUpdateRecipients: WideString;
begin
    Result := DefaultInterface.StatusUpdateRecipients;
end;

function TSafeTaskItemProperties.Get_StatusOnCompletionRecipients: WideString;
begin
    Result := DefaultInterface.StatusOnCompletionRecipients;
end;

function TSafeTaskItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

{$ENDIF}

class function CoSafeJournalItem.Create: ISafeJournalItem;
begin
  Result := CreateComObject(CLASS_SafeJournalItem) as ISafeJournalItem;
end;

class function CoSafeJournalItem.CreateRemote(const MachineName: string): ISafeJournalItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeJournalItem) as ISafeJournalItem;
end;

procedure TSafeJournalItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{C5AA36A1-8BD1-47E0-90F8-47E7239C6EA1}';
    IntfIID:   '{E3EC74BB-5522-462D-A00F-2728C53FCA04}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeJournalItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeJournalItem;
  end;
end;

procedure TSafeJournalItem.ConnectTo(svrIntf: ISafeJournalItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeJournalItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeJournalItem.GetDefaultInterface: ISafeJournalItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeJournalItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeJournalItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeJournalItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeJournalItem.GetServerProperties: TSafeJournalItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeJournalItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeJournalItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeJournalItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeJournalItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeJournalItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeJournalItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeJournalItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeJournalItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeJournalItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeJournalItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeJournalItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeJournalItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeJournalItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeJournalItem.Get_ContactNames: WideString;
begin
    Result := DefaultInterface.ContactNames;
end;

function TSafeJournalItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeJournalItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeJournalItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeJournalItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeJournalItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeJournalItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeJournalItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeJournalItemProperties.Create(AServer: TSafeJournalItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeJournalItemProperties.GetDefaultInterface: ISafeJournalItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeJournalItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeJournalItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeJournalItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeJournalItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeJournalItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeJournalItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeJournalItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeJournalItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeJournalItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeJournalItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeJournalItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeJournalItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeJournalItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeJournalItemProperties.Get_ContactNames: WideString;
begin
    Result := DefaultInterface.ContactNames;
end;

function TSafeJournalItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

{$ENDIF}

class function CoSafeMeetingItem.Create: ISafeMeetingItem;
begin
  Result := CreateComObject(CLASS_SafeMeetingItem) as ISafeMeetingItem;
end;

class function CoSafeMeetingItem.CreateRemote(const MachineName: string): ISafeMeetingItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeMeetingItem) as ISafeMeetingItem;
end;

procedure TSafeMeetingItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{FA2CBAFB-F7B1-4F41-9B7A-73329A6C1CB7}';
    IntfIID:   '{F7919641-3978-4668-8388-7310329C800E}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeMeetingItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeMeetingItem;
  end;
end;

procedure TSafeMeetingItem.ConnectTo(svrIntf: ISafeMeetingItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeMeetingItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeMeetingItem.GetDefaultInterface: ISafeMeetingItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeMeetingItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeMeetingItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeMeetingItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeMeetingItem.GetServerProperties: TSafeMeetingItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeMeetingItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeMeetingItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeMeetingItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeMeetingItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeMeetingItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeMeetingItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeMeetingItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeMeetingItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeMeetingItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeMeetingItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeMeetingItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeMeetingItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeMeetingItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeMeetingItem.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafeMeetingItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafeMeetingItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeMeetingItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeMeetingItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeMeetingItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeMeetingItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeMeetingItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeMeetingItemProperties.Create(AServer: TSafeMeetingItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeMeetingItemProperties.GetDefaultInterface: ISafeMeetingItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeMeetingItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeMeetingItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeMeetingItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeMeetingItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeMeetingItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeMeetingItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeMeetingItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeMeetingItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeMeetingItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeMeetingItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeMeetingItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeMeetingItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeMeetingItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeMeetingItemProperties.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafeMeetingItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

{$ENDIF}

class function CoSafePostItem.Create: ISafePostItem;
begin
  Result := CreateComObject(CLASS_SafePostItem) as ISafePostItem;
end;

class function CoSafePostItem.CreateRemote(const MachineName: string): ISafePostItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafePostItem) as ISafePostItem;
end;

procedure TSafePostItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{11E2BC0C-5D4F-4E0C-B438-501FFE05A382}';
    IntfIID:   '{6A5D680A-8F9F-4752-A056-2C0273F60B4E}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafePostItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafePostItem;
  end;
end;

procedure TSafePostItem.ConnectTo(svrIntf: ISafePostItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafePostItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafePostItem.GetDefaultInterface: ISafePostItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafePostItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafePostItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafePostItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafePostItem.GetServerProperties: TSafePostItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafePostItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafePostItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafePostItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafePostItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafePostItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafePostItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafePostItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafePostItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafePostItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafePostItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafePostItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafePostItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafePostItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafePostItem.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafePostItem.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

function TSafePostItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafePostItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafePostItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafePostItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafePostItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafePostItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafePostItemProperties.Create(AServer: TSafePostItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafePostItemProperties.GetDefaultInterface: ISafePostItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafePostItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafePostItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafePostItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafePostItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafePostItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafePostItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafePostItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafePostItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafePostItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafePostItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafePostItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafePostItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafePostItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafePostItemProperties.Get_SenderName: WideString;
begin
    Result := DefaultInterface.SenderName;
end;

function TSafePostItemProperties.Get_HTMLBody: WideString;
begin
    Result := DefaultInterface.HTMLBody;
end;

{$ENDIF}

class function CoMAPIUtils.Create: IMAPIUtils;
begin
  Result := CreateComObject(CLASS_MAPIUtils) as IMAPIUtils;
end;

class function CoMAPIUtils.CreateRemote(const MachineName: string): IMAPIUtils;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MAPIUtils) as IMAPIUtils;
end;

procedure TMAPIUtils.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{4A5E947E-C407-4DCC-A0B5-5658E457153B}';
    IntfIID:   '{D45B0772-5801-4E61-9CBA-84120557A4D7}';
    EventIID:  '{359A062F-CDA8-4A9C-9B28-588446D35098}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMAPIUtils.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IMAPIUtils;
  end;
end;

procedure TMAPIUtils.ConnectTo(svrIntf: IMAPIUtils);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TMAPIUtils.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TMAPIUtils.GetDefaultInterface: IMAPIUtils;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMAPIUtils.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMAPIUtilsProperties.Create(Self);
{$ENDIF}
end;

destructor TMAPIUtils.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMAPIUtils.GetServerProperties: TMAPIUtilsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TMAPIUtils.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnNewMail) then
         FOnNewMail(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

procedure TMAPIUtils.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TMAPIUtils.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TMAPIUtils.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TMAPIUtils.Set_MAPIOBJECT(const Value: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(Value);
end;

function TMAPIUtils.Get_AddressBookFilter: WideString;
begin
    Result := DefaultInterface.AddressBookFilter;
end;

procedure TMAPIUtils.Set_AddressBookFilter(const Value: WideString);
  { Warning: The property AddressBookFilter has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AddressBookFilter := Value;
end;

function TMAPIUtils.Get_CurrentProfileName: WideString;
begin
    Result := DefaultInterface.CurrentProfileName;
end;

function TMAPIUtils.Get_DefaultABListEntryID: WideString;
begin
    Result := DefaultInterface.DefaultABListEntryID;
end;

procedure TMAPIUtils.Set_DefaultABListEntryID(const Value: WideString);
  { Warning: The property DefaultABListEntryID has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DefaultABListEntryID := Value;
end;

function TMAPIUtils.HrGetOneProp(const MAPIProp: IUnknown; PropTag: Integer): OleVariant;
begin
  Result := DefaultInterface.HrGetOneProp(MAPIProp, PropTag);
end;

function TMAPIUtils.HrSetOneProp(const MAPIProp: IUnknown; PropTag: Integer; Value: OleVariant; 
                                 bSave: WordBool): Integer;
begin
  Result := DefaultInterface.HrSetOneProp(MAPIProp, PropTag, Value, bSave);
end;

function TMAPIUtils.GetIDsFromNames(const MAPIProp: IUnknown; const GUID: WideString; 
                                    ID: OleVariant; bCreate: WordBool): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(MAPIProp, GUID, ID, bCreate);
end;

procedure TMAPIUtils.DeliverNow(Flags: Integer; ParentWndHandle: Integer);
begin
  DefaultInterface.DeliverNow(Flags, ParentWndHandle);
end;

function TMAPIUtils.AddressBook: ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(EmptyParam, EmptyParam, EmptyParam, EmptyParam, 
                                         EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, EmptyParam, EmptyParam, EmptyParam, 
                                         EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, EmptyParam, EmptyParam, EmptyParam, 
                                         EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, EmptyParam, EmptyParam, 
                                         EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant; RecipLists: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         RecipLists, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant; RecipLists: OleVariant; 
                                ToLabel: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         RecipLists, ToLabel, EmptyParam, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant; RecipLists: OleVariant; 
                                ToLabel: OleVariant; CcLabel: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         RecipLists, ToLabel, CcLabel, EmptyParam, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant; RecipLists: OleVariant; 
                                ToLabel: OleVariant; CcLabel: OleVariant; BccLabel: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         RecipLists, ToLabel, CcLabel, BccLabel, EmptyParam);
end;

function TMAPIUtils.AddressBook(Recipients: OleVariant; Title: OleVariant; OneAddress: OleVariant; 
                                ForceResolution: OleVariant; RecipLists: OleVariant; 
                                ToLabel: OleVariant; CcLabel: OleVariant; BccLabel: OleVariant; 
                                ParentWindow: OleVariant): ISafeRecipients;
begin
  Result := DefaultInterface.AddressBook(Recipients, Title, OneAddress, ForceResolution, 
                                         RecipLists, ToLabel, CcLabel, BccLabel, ParentWindow);
end;

function TMAPIUtils.CompareIDs(const ID1: WideString; const ID2: WideString): WordBool;
begin
  Result := DefaultInterface.CompareIDs(ID1, ID2);
end;

function TMAPIUtils.GetAddressEntryFromID(const ID: WideString): IAddressEntry;
begin
  Result := DefaultInterface.GetAddressEntryFromID(ID);
end;

procedure TMAPIUtils.Cleanup;
begin
  DefaultInterface.Cleanup;
end;

function TMAPIUtils.GetItemFromID(const EntryIDItem: WideString): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromID(EntryIDItem, EmptyParam);
end;

function TMAPIUtils.GetItemFromID(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromID(EntryIDItem, EntryIDStore);
end;

function TMAPIUtils.CreateRecipient(const Name: WideString; ShowDialog: WordBool; ParentWnd: Integer): ISafeRecipient;
begin
  Result := DefaultInterface.CreateRecipient(Name, ShowDialog, ParentWnd);
end;

function TMAPIUtils.HrArrayToString(InputArray: OleVariant): WideString;
begin
  Result := DefaultInterface.HrArrayToString(InputArray);
end;

function TMAPIUtils.HrStringToArray(const InputString: WideString): OleVariant;
begin
  Result := DefaultInterface.HrStringToArray(InputString);
end;

function TMAPIUtils.HrLocalToGMT(Value: TDateTime): TDateTime;
begin
  Result := DefaultInterface.HrLocalToGMT(Value);
end;

function TMAPIUtils.HrGMTToLocal(Value: TDateTime): TDateTime;
begin
  Result := DefaultInterface.HrGMTToLocal(Value);
end;

function TMAPIUtils.GetNamesFromIDs(const MAPIProp: IUnknown; PropTag: Integer): INamedProperty;
begin
  Result := DefaultInterface.GetNamesFromIDs(MAPIProp, PropTag);
end;

function TMAPIUtils.HrGetPropList(const Obj: IUnknown; UseUnicode: WordBool): IPropList;
begin
  Result := DefaultInterface.HrGetPropList(Obj, UseUnicode);
end;

function TMAPIUtils.GetItemFromMsgFile(const FileName: WideString; CreateNew: WordBool): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromMsgFile(FileName, CreateNew);
end;

function TMAPIUtils.GetItemFromIDEx(const EntryIDItem: WideString): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromIDEx(EntryIDItem, EmptyParam, EmptyParam);
end;

function TMAPIUtils.GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromIDEx(EntryIDItem, EntryIDStore, EmptyParam);
end;

function TMAPIUtils.GetItemFromIDEx(const EntryIDItem: WideString; EntryIDStore: OleVariant; 
                                    Flags: OleVariant): IMessageItem;
begin
  Result := DefaultInterface.GetItemFromIDEx(EntryIDItem, EntryIDStore, Flags);
end;

function TMAPIUtils.ScCreateConversationIndex(const ParentConversationIndex: WideString): WideString;
begin
  Result := DefaultInterface.ScCreateConversationIndex(ParentConversationIndex);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMAPIUtilsProperties.Create(AServer: TMAPIUtils);
begin
  inherited Create;
  FServer := AServer;
end;

function TMAPIUtilsProperties.GetDefaultInterface: IMAPIUtils;
begin
  Result := FServer.DefaultInterface;
end;

procedure TMAPIUtilsProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TMAPIUtilsProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TMAPIUtilsProperties.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TMAPIUtilsProperties.Set_MAPIOBJECT(const Value: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(Value);
end;

function TMAPIUtilsProperties.Get_AddressBookFilter: WideString;
begin
    Result := DefaultInterface.AddressBookFilter;
end;

procedure TMAPIUtilsProperties.Set_AddressBookFilter(const Value: WideString);
  { Warning: The property AddressBookFilter has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AddressBookFilter := Value;
end;

function TMAPIUtilsProperties.Get_CurrentProfileName: WideString;
begin
    Result := DefaultInterface.CurrentProfileName;
end;

function TMAPIUtilsProperties.Get_DefaultABListEntryID: WideString;
begin
    Result := DefaultInterface.DefaultABListEntryID;
end;

procedure TMAPIUtilsProperties.Set_DefaultABListEntryID(const Value: WideString);
  { Warning: The property DefaultABListEntryID has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DefaultABListEntryID := Value;
end;

{$ENDIF}

class function CoAddressEntry.Create: IAddressEntry;
begin
  Result := CreateComObject(CLASS_AddressEntry) as IAddressEntry;
end;

class function CoAddressEntry.CreateRemote(const MachineName: string): IAddressEntry;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddressEntry) as IAddressEntry;
end;

class function CoAddressEntries.Create: IAddressEntries;
begin
  Result := CreateComObject(CLASS_AddressEntries) as IAddressEntries;
end;

class function CoAddressEntries.CreateRemote(const MachineName: string): IAddressEntries;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddressEntries) as IAddressEntries;
end;

class function CoAttachment.Create: IAttachment;
begin
  Result := CreateComObject(CLASS_Attachment) as IAttachment;
end;

class function CoAttachment.CreateRemote(const MachineName: string): IAttachment;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Attachment) as IAttachment;
end;

class function CoAttachments.Create: IAttachments;
begin
  Result := CreateComObject(CLASS_Attachments) as IAttachments;
end;

class function CoAttachments.CreateRemote(const MachineName: string): IAttachments;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Attachments) as IAttachments;
end;

class function CoMAPIFolder.Create: ISafeMAPIFolder;
begin
  Result := CreateComObject(CLASS_MAPIFolder) as ISafeMAPIFolder;
end;

class function CoMAPIFolder.CreateRemote(const MachineName: string): ISafeMAPIFolder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MAPIFolder) as ISafeMAPIFolder;
end;

procedure TMAPIFolder.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{03C4C5F4-1893-444C-B8D8-002F0034DA92}';
    IntfIID:   '{31CE2164-4D5C-4508-BCA7-B10E11D08E6B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMAPIFolder.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeMAPIFolder;
  end;
end;

procedure TMAPIFolder.ConnectTo(svrIntf: ISafeMAPIFolder);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TMAPIFolder.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TMAPIFolder.GetDefaultInterface: ISafeMAPIFolder;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMAPIFolder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMAPIFolderProperties.Create(Self);
{$ENDIF}
end;

destructor TMAPIFolder.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMAPIFolder.GetServerProperties: TMAPIFolderProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TMAPIFolder.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TMAPIFolder.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TMAPIFolder.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TMAPIFolder.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TMAPIFolder.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TMAPIFolder.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

function TMAPIFolder.Get_HiddenItems: ISafeItems;
begin
    Result := DefaultInterface.HiddenItems;
end;

function TMAPIFolder.Get_Items: ISafeItems;
begin
    Result := DefaultInterface.Items;
end;

function TMAPIFolder.Get_DeletedItems: IDeletedItems;
begin
    Result := DefaultInterface.DeletedItems;
end;

function TMAPIFolder.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TMAPIFolder.SetMAPIOBJECT(const Folder: IUnknown);
begin
  DefaultInterface.SetMAPIOBJECT(Folder);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMAPIFolderProperties.Create(AServer: TMAPIFolder);
begin
  inherited Create;
  FServer := AServer;
end;

function TMAPIFolderProperties.GetDefaultInterface: ISafeMAPIFolder;
begin
  Result := FServer.DefaultInterface;
end;

function TMAPIFolderProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TMAPIFolderProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TMAPIFolderProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TMAPIFolderProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TMAPIFolderProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TMAPIFolderProperties.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

function TMAPIFolderProperties.Get_HiddenItems: ISafeItems;
begin
    Result := DefaultInterface.HiddenItems;
end;

function TMAPIFolderProperties.Get_Items: ISafeItems;
begin
    Result := DefaultInterface.Items;
end;

function TMAPIFolderProperties.Get_DeletedItems: IDeletedItems;
begin
    Result := DefaultInterface.DeletedItems;
end;

{$ENDIF}

class function CoSafeCurrentUser.Create: ISafeCurrentUser;
begin
  Result := CreateComObject(CLASS_SafeCurrentUser) as ISafeCurrentUser;
end;

class function CoSafeCurrentUser.CreateRemote(const MachineName: string): ISafeCurrentUser;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeCurrentUser) as ISafeCurrentUser;
end;

procedure TSafeCurrentUser.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{7ED1E9B1-CB57-4FA0-84E8-FAE653FE8E6B}';
    IntfIID:   '{D7E6FB7C-A22F-4A9D-A89D-653D1AA37324}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeCurrentUser.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeCurrentUser;
  end;
end;

procedure TSafeCurrentUser.ConnectTo(svrIntf: ISafeCurrentUser);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeCurrentUser.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeCurrentUser.GetDefaultInterface: ISafeCurrentUser;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeCurrentUser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeCurrentUserProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeCurrentUser.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeCurrentUser.GetServerProperties: TSafeCurrentUserProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeCurrentUser.Get_Application: IDispatch;
begin
    Result := DefaultInterface.Application;
end;

function TSafeCurrentUser.Get_Class_: Integer;
begin
    Result := DefaultInterface.Class_;
end;

function TSafeCurrentUser.Get_Session: IDispatch;
begin
    Result := DefaultInterface.Session;
end;

function TSafeCurrentUser.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TSafeCurrentUser.Get_Address: WideString;
begin
    Result := DefaultInterface.Address;
end;

procedure TSafeCurrentUser.Set_Address(const Address: WideString);
  { Warning: The property Address has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Address := Address;
end;

function TSafeCurrentUser.Get_DisplayType: Integer;
begin
    Result := DefaultInterface.DisplayType;
end;

function TSafeCurrentUser.Get_ID: WideString;
begin
    Result := DefaultInterface.ID;
end;

function TSafeCurrentUser.Get_Manager: IAddressEntry;
begin
    Result := DefaultInterface.Manager;
end;

function TSafeCurrentUser.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TSafeCurrentUser.Set_MAPIOBJECT(const MAPIOBJECT: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(MAPIOBJECT);
end;

function TSafeCurrentUser.Get_Members: IDispatch;
begin
    Result := DefaultInterface.Members;
end;

function TSafeCurrentUser.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TSafeCurrentUser.Set_Name(const Name: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := Name;
end;

function TSafeCurrentUser.Get_type_: WideString;
begin
    Result := DefaultInterface.type_;
end;

procedure TSafeCurrentUser.Set_type_(const Type_: WideString);
  { Warning: The property type_ has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.type_ := Type_;
end;

function TSafeCurrentUser.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeCurrentUser.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeCurrentUser.Get_SMTPAddress: WideString;
begin
    Result := DefaultInterface.SMTPAddress;
end;

procedure TSafeCurrentUser.Delete;
begin
  DefaultInterface.Delete;
end;

procedure TSafeCurrentUser.Details;
begin
  DefaultInterface.Details(EmptyParam);
end;

procedure TSafeCurrentUser.Details(HWnd: OleVariant);
begin
  DefaultInterface.Details(HWnd);
end;

function TSafeCurrentUser.GetFreeBusy(Start: TDateTime; MinPerChar: Integer): WideString;
begin
  Result := DefaultInterface.GetFreeBusy(Start, MinPerChar, EmptyParam);
end;

function TSafeCurrentUser.GetFreeBusy(Start: TDateTime; MinPerChar: Integer; 
                                      CompleteFormat: OleVariant): WideString;
begin
  Result := DefaultInterface.GetFreeBusy(Start, MinPerChar, CompleteFormat);
end;

procedure TSafeCurrentUser.Update;
begin
  DefaultInterface.Update(EmptyParam, EmptyParam);
end;

procedure TSafeCurrentUser.Update(MakePermanent: OleVariant);
begin
  DefaultInterface.Update(MakePermanent, EmptyParam);
end;

procedure TSafeCurrentUser.Update(MakePermanent: OleVariant; Refresh: OleVariant);
begin
  DefaultInterface.Update(MakePermanent, Refresh);
end;

procedure TSafeCurrentUser.UpdateFreeBusy;
begin
  DefaultInterface.UpdateFreeBusy;
end;

procedure TSafeCurrentUser.Cleanup;
begin
  DefaultInterface.Cleanup;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeCurrentUserProperties.Create(AServer: TSafeCurrentUser);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeCurrentUserProperties.GetDefaultInterface: ISafeCurrentUser;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeCurrentUserProperties.Get_Application: IDispatch;
begin
    Result := DefaultInterface.Application;
end;

function TSafeCurrentUserProperties.Get_Class_: Integer;
begin
    Result := DefaultInterface.Class_;
end;

function TSafeCurrentUserProperties.Get_Session: IDispatch;
begin
    Result := DefaultInterface.Session;
end;

function TSafeCurrentUserProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TSafeCurrentUserProperties.Get_Address: WideString;
begin
    Result := DefaultInterface.Address;
end;

procedure TSafeCurrentUserProperties.Set_Address(const Address: WideString);
  { Warning: The property Address has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Address := Address;
end;

function TSafeCurrentUserProperties.Get_DisplayType: Integer;
begin
    Result := DefaultInterface.DisplayType;
end;

function TSafeCurrentUserProperties.Get_ID: WideString;
begin
    Result := DefaultInterface.ID;
end;

function TSafeCurrentUserProperties.Get_Manager: IAddressEntry;
begin
    Result := DefaultInterface.Manager;
end;

function TSafeCurrentUserProperties.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TSafeCurrentUserProperties.Set_MAPIOBJECT(const MAPIOBJECT: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(MAPIOBJECT);
end;

function TSafeCurrentUserProperties.Get_Members: IDispatch;
begin
    Result := DefaultInterface.Members;
end;

function TSafeCurrentUserProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TSafeCurrentUserProperties.Set_Name(const Name: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := Name;
end;

function TSafeCurrentUserProperties.Get_type_: WideString;
begin
    Result := DefaultInterface.type_;
end;

procedure TSafeCurrentUserProperties.Set_type_(const Type_: WideString);
  { Warning: The property type_ has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.type_ := Type_;
end;

function TSafeCurrentUserProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeCurrentUserProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeCurrentUserProperties.Get_SMTPAddress: WideString;
begin
    Result := DefaultInterface.SMTPAddress;
end;

{$ENDIF}

class function CoSafeTable.Create: ISafeTable;
begin
  Result := CreateComObject(CLASS_SafeTable) as ISafeTable;
end;

class function CoSafeTable.CreateRemote(const MachineName: string): ISafeTable;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeTable) as ISafeTable;
end;

procedure TSafeTable.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{CA6E7A81-E98D-4DFE-8911-6CE3A3EE4C8A}';
    IntfIID:   '{CD5B9523-6EAF-4D63-8FE8-C081C51D1673}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeTable.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeTable;
  end;
end;

procedure TSafeTable.ConnectTo(svrIntf: ISafeTable);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeTable.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeTable.GetDefaultInterface: ISafeTable;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeTableProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeTable.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeTable.GetServerProperties: TSafeTableProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeTable.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeTableProperties.Create(AServer: TSafeTable);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeTableProperties.GetDefaultInterface: ISafeTable;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeTableProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoSafeDistList.Create: ISafeDistList;
begin
  Result := CreateComObject(CLASS_SafeDistList) as ISafeDistList;
end;

class function CoSafeDistList.CreateRemote(const MachineName: string): ISafeDistList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeDistList) as ISafeDistList;
end;

procedure TSafeDistList.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{7C4A630A-DE98-4E3E-8093-E8F5E159BB72}';
    IntfIID:   '{EBB4EBA9-D546-4C85-A05A-167BF875FB83}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeDistList.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeDistList;
  end;
end;

procedure TSafeDistList.ConnectTo(svrIntf: ISafeDistList);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeDistList.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeDistList.GetDefaultInterface: ISafeDistList;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeDistList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeDistListProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeDistList.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeDistList.GetServerProperties: TSafeDistListProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeDistList.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeDistList.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeDistList.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeDistList.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeDistList.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeDistList.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeDistList.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeDistList.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeDistList.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeDistList.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeDistList.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeDistList.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeDistList.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeDistList.Get_MemberCount: Integer;
begin
    Result := DefaultInterface.MemberCount;
end;

function TSafeDistList.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeDistList.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeDistList.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeDistList.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeDistList.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeDistList.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

function TSafeDistList.GetMember(Index: Integer): ISafeRecipient;
begin
  Result := DefaultInterface.GetMember(Index);
end;

procedure TSafeDistList.AddMember(Recipient: OleVariant);
begin
  DefaultInterface.AddMember(Recipient);
end;

procedure TSafeDistList.AddMembers(Recipients: OleVariant);
begin
  DefaultInterface.AddMembers(Recipients);
end;

procedure TSafeDistList.RemoveMember(Recipient: OleVariant);
begin
  DefaultInterface.RemoveMember(Recipient);
end;

procedure TSafeDistList.RemoveMembers(Recipients: OleVariant);
begin
  DefaultInterface.RemoveMembers(Recipients);
end;

procedure TSafeDistList.RemoveMemberEx(Index: Integer);
begin
  DefaultInterface.RemoveMemberEx(Index);
end;

function TSafeDistList.AddMemberEx(const Name: WideString; Address: OleVariant; 
                                   AddressType: OleVariant): ISafeRecipient;
begin
  Result := DefaultInterface.AddMemberEx(Name, Address, AddressType);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeDistListProperties.Create(AServer: TSafeDistList);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeDistListProperties.GetDefaultInterface: ISafeDistList;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeDistListProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeDistListProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeDistListProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeDistListProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeDistListProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeDistListProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeDistListProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeDistListProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeDistListProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeDistListProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeDistListProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeDistListProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeDistListProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeDistListProperties.Get_MemberCount: Integer;
begin
    Result := DefaultInterface.MemberCount;
end;

{$ENDIF}

class function CoAddressLists.Create: IAddressLists;
begin
  Result := CreateComObject(CLASS_AddressLists) as IAddressLists;
end;

class function CoAddressLists.CreateRemote(const MachineName: string): IAddressLists;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddressLists) as IAddressLists;
end;

procedure TAddressLists.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{37587889-FC28-4507-B6D3-8557305F7511}';
    IntfIID:   '{86797248-1A4E-41D0-A0C3-2175A36B3D0E}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TAddressLists.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAddressLists;
  end;
end;

procedure TAddressLists.ConnectTo(svrIntf: IAddressLists);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TAddressLists.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TAddressLists.GetDefaultInterface: IAddressLists;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TAddressLists.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TAddressListsProperties.Create(Self);
{$ENDIF}
end;

destructor TAddressLists.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TAddressLists.GetServerProperties: TAddressListsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TAddressLists.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TAddressLists.Item(Index: OleVariant): IAddressList;
begin
  Result := DefaultInterface.Item(Index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TAddressListsProperties.Create(AServer: TAddressLists);
begin
  inherited Create;
  FServer := AServer;
end;

function TAddressListsProperties.GetDefaultInterface: IAddressLists;
begin
  Result := FServer.DefaultInterface;
end;

function TAddressListsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoAddressList.Create: IAddressList;
begin
  Result := CreateComObject(CLASS_AddressList) as IAddressList;
end;

class function CoAddressList.CreateRemote(const MachineName: string): IAddressList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddressList) as IAddressList;
end;

class function CoSafeItems.Create: ISafeItems;
begin
  Result := CreateComObject(CLASS_SafeItems) as ISafeItems;
end;

class function CoSafeItems.CreateRemote(const MachineName: string): ISafeItems;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeItems) as ISafeItems;
end;

class function CoMessageItem.Create: IMessageItem;
begin
  Result := CreateComObject(CLASS_MessageItem) as IMessageItem;
end;

class function CoMessageItem.CreateRemote(const MachineName: string): IMessageItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MessageItem) as IMessageItem;
end;

class function CoMAPITable.Create: _IMAPITable;
begin
  Result := CreateComObject(CLASS_MAPITable) as _IMAPITable;
end;

class function CoMAPITable.CreateRemote(const MachineName: string): _IMAPITable;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MAPITable) as _IMAPITable;
end;

procedure TMAPITable.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{A6931B16-90FA-4D69-A49F-3ABFA2C04060}';
    IntfIID:   '{6CCD925E-E833-4BE3-A62E-D3C8838C5D6D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMAPITable.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _IMAPITable;
  end;
end;

procedure TMAPITable.ConnectTo(svrIntf: _IMAPITable);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TMAPITable.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TMAPITable.GetDefaultInterface: _IMAPITable;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMAPITable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMAPITableProperties.Create(Self);
{$ENDIF}
end;

destructor TMAPITable.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMAPITable.GetServerProperties: TMAPITableProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TMAPITable.Get_Item: IUnknown;
begin
    Result := DefaultInterface.Item;
end;

procedure TMAPITable.Set_Item(const Value: IUnknown);
begin
  DefaultInterface.Set_Item(Value);
end;

function TMAPITable.Get_RowCount: Integer;
begin
    Result := DefaultInterface.RowCount;
end;

function TMAPITable.Get_Columns: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Columns;
end;

procedure TMAPITable.Set_Columns(Value: OleVariant);
begin
  DefaultInterface.Set_Columns(Value);
end;

function TMAPITable.Get_Filter: ITableFilter;
begin
    Result := DefaultInterface.Filter;
end;

function TMAPITable.Get_Position: Integer;
begin
    Result := DefaultInterface.Position;
end;

procedure TMAPITable.Set_Position(Value: Integer);
begin
  DefaultInterface.Set_Position(Value);
end;

procedure TMAPITable.GoToFirst;
begin
  DefaultInterface.GoToFirst;
end;

procedure TMAPITable.GoToLast;
begin
  DefaultInterface.GoToLast;
end;

procedure TMAPITable.GoTo_(Index: Integer);
begin
  DefaultInterface.GoTo_(Index);
end;

function TMAPITable.GetRow: OleVariant;
begin
  Result := DefaultInterface.GetRow;
end;

function TMAPITable.GetRows(Count: Integer): OleVariant;
begin
  Result := DefaultInterface.GetRows(Count);
end;

procedure TMAPITable.Sort(Property_: OleVariant);
begin
  DefaultInterface.Sort(Property_, EmptyParam);
end;

procedure TMAPITable.Sort(Property_: OleVariant; Descending: OleVariant);
begin
  DefaultInterface.Sort(Property_, Descending);
end;

function TMAPITable.ExecSQL(const SQLCommand: WideString): IDispatch;
begin
  Result := DefaultInterface.ExecSQL(SQLCommand);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMAPITableProperties.Create(AServer: TMAPITable);
begin
  inherited Create;
  FServer := AServer;
end;

function TMAPITableProperties.GetDefaultInterface: _IMAPITable;
begin
  Result := FServer.DefaultInterface;
end;

function TMAPITableProperties.Get_Item: IUnknown;
begin
    Result := DefaultInterface.Item;
end;

procedure TMAPITableProperties.Set_Item(const Value: IUnknown);
begin
  DefaultInterface.Set_Item(Value);
end;

function TMAPITableProperties.Get_RowCount: Integer;
begin
    Result := DefaultInterface.RowCount;
end;

function TMAPITableProperties.Get_Columns: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Columns;
end;

procedure TMAPITableProperties.Set_Columns(Value: OleVariant);
begin
  DefaultInterface.Set_Columns(Value);
end;

function TMAPITableProperties.Get_Filter: ITableFilter;
begin
    Result := DefaultInterface.Filter;
end;

function TMAPITableProperties.Get_Position: Integer;
begin
    Result := DefaultInterface.Position;
end;

procedure TMAPITableProperties.Set_Position(Value: Integer);
begin
  DefaultInterface.Set_Position(Value);
end;

{$ENDIF}

class function CoDeletedItems.Create: IDeletedItems;
begin
  Result := CreateComObject(CLASS_DeletedItems) as IDeletedItems;
end;

class function CoDeletedItems.CreateRemote(const MachineName: string): IDeletedItems;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeletedItems) as IDeletedItems;
end;

procedure TDeletedItems.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{9F705F1E-00BD-46AD-AB0F-2BA438E0FE91}';
    IntfIID:   '{FFBBDECE-4363-4B4D-B35E-39EFF228C723}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeletedItems.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeletedItems;
  end;
end;

procedure TDeletedItems.ConnectTo(svrIntf: IDeletedItems);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeletedItems.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeletedItems.GetDefaultInterface: IDeletedItems;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeletedItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeletedItemsProperties.Create(Self);
{$ENDIF}
end;

destructor TDeletedItems.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeletedItems.GetServerProperties: TDeletedItemsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeletedItems.Get_Application: IDispatch;
begin
    Result := DefaultInterface.Application;
end;

function TDeletedItems.Get_Class_: Integer;
begin
    Result := DefaultInterface.Class_;
end;

function TDeletedItems.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TDeletedItems.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TDeletedItems.Get_RawTable: IUnknown;
begin
    Result := DefaultInterface.RawTable;
end;

function TDeletedItems.Get_Session: IDispatch;
begin
    Result := DefaultInterface.Session;
end;

function TDeletedItems.Get_MAPITable: _IMAPITable;
begin
    Result := DefaultInterface.MAPITable;
end;

function TDeletedItems.Add(Type_: OleVariant): IMessageItem;
begin
  Result := DefaultInterface.Add(Type_);
end;

function TDeletedItems.GetFirst: IDispatch;
begin
  Result := DefaultInterface.GetFirst;
end;

function TDeletedItems.GetLast: IDispatch;
begin
  Result := DefaultInterface.GetLast;
end;

function TDeletedItems.GetNext: IDispatch;
begin
  Result := DefaultInterface.GetNext;
end;

function TDeletedItems.GetPrevious: IDispatch;
begin
  Result := DefaultInterface.GetPrevious;
end;

function TDeletedItems.Item(Index: OleVariant): IMessageItem;
begin
  Result := DefaultInterface.Item(Index);
end;

procedure TDeletedItems.Remove(Index: Integer);
begin
  DefaultInterface.Remove(Index);
end;

function TDeletedItems._Item(Index: OleVariant): IMessageItem;
begin
  Result := DefaultInterface._Item(Index);
end;

procedure TDeletedItems.Restore(Index: OleVariant);
begin
  DefaultInterface.Restore(Index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeletedItemsProperties.Create(AServer: TDeletedItems);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeletedItemsProperties.GetDefaultInterface: IDeletedItems;
begin
  Result := FServer.DefaultInterface;
end;

function TDeletedItemsProperties.Get_Application: IDispatch;
begin
    Result := DefaultInterface.Application;
end;

function TDeletedItemsProperties.Get_Class_: Integer;
begin
    Result := DefaultInterface.Class_;
end;

function TDeletedItemsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TDeletedItemsProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TDeletedItemsProperties.Get_RawTable: IUnknown;
begin
    Result := DefaultInterface.RawTable;
end;

function TDeletedItemsProperties.Get_Session: IDispatch;
begin
    Result := DefaultInterface.Session;
end;

function TDeletedItemsProperties.Get_MAPITable: _IMAPITable;
begin
    Result := DefaultInterface.MAPITable;
end;

{$ENDIF}

class function CoRestrictionAnd.Create: IRestrictionAnd;
begin
  Result := CreateComObject(CLASS_RestrictionAnd) as IRestrictionAnd;
end;

class function CoRestrictionAnd.CreateRemote(const MachineName: string): IRestrictionAnd;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionAnd) as IRestrictionAnd;
end;

class function CoRestrictionBitmask.Create: IRestrictionBitmask;
begin
  Result := CreateComObject(CLASS_RestrictionBitmask) as IRestrictionBitmask;
end;

class function CoRestrictionBitmask.CreateRemote(const MachineName: string): IRestrictionBitmask;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionBitmask) as IRestrictionBitmask;
end;

class function CoRestrictionCompareProps.Create: IRestrictionCompareProps;
begin
  Result := CreateComObject(CLASS_RestrictionCompareProps) as IRestrictionCompareProps;
end;

class function CoRestrictionCompareProps.CreateRemote(const MachineName: string): IRestrictionCompareProps;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionCompareProps) as IRestrictionCompareProps;
end;

class function CoRestrictionContent.Create: IRestrictionContent;
begin
  Result := CreateComObject(CLASS_RestrictionContent) as IRestrictionContent;
end;

class function CoRestrictionContent.CreateRemote(const MachineName: string): IRestrictionContent;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionContent) as IRestrictionContent;
end;

class function CoRestrictionExist.Create: IRestrictionExist;
begin
  Result := CreateComObject(CLASS_RestrictionExist) as IRestrictionExist;
end;

class function CoRestrictionExist.CreateRemote(const MachineName: string): IRestrictionExist;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionExist) as IRestrictionExist;
end;

class function CoRestrictionNot.Create: IRestrictionNot;
begin
  Result := CreateComObject(CLASS_RestrictionNot) as IRestrictionNot;
end;

class function CoRestrictionNot.CreateRemote(const MachineName: string): IRestrictionNot;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionNot) as IRestrictionNot;
end;

class function CoRestrictionOr.Create: IRestrictionOr;
begin
  Result := CreateComObject(CLASS_RestrictionOr) as IRestrictionOr;
end;

class function CoRestrictionOr.CreateRemote(const MachineName: string): IRestrictionOr;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionOr) as IRestrictionOr;
end;

class function CoRestrictionProperty.Create: IRestrictionProperty;
begin
  Result := CreateComObject(CLASS_RestrictionProperty) as IRestrictionProperty;
end;

class function CoRestrictionProperty.CreateRemote(const MachineName: string): IRestrictionProperty;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionProperty) as IRestrictionProperty;
end;

class function CoRestrictionSize.Create: IRestrictionSize;
begin
  Result := CreateComObject(CLASS_RestrictionSize) as IRestrictionSize;
end;

class function CoRestrictionSize.CreateRemote(const MachineName: string): IRestrictionSize;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionSize) as IRestrictionSize;
end;

class function CoRestrictionSub.Create: IRestrictionSub;
begin
  Result := CreateComObject(CLASS_RestrictionSub) as IRestrictionSub;
end;

class function CoRestrictionSub.CreateRemote(const MachineName: string): IRestrictionSub;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionSub) as IRestrictionSub;
end;

class function CoTableFilter.Create: ITableFilter;
begin
  Result := CreateComObject(CLASS_TableFilter) as ITableFilter;
end;

class function CoTableFilter.CreateRemote(const MachineName: string): ITableFilter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TableFilter) as ITableFilter;
end;

procedure TTableFilter.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{73897A34-F150-46F3-8600-F65EDA105ECF}';
    IntfIID:   '{0B8EDB8D-4575-4942-9C34-55591E415909}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TTableFilter.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ITableFilter;
  end;
end;

procedure TTableFilter.ConnectTo(svrIntf: ITableFilter);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TTableFilter.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TTableFilter.GetDefaultInterface: ITableFilter;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TTableFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TTableFilterProperties.Create(Self);
{$ENDIF}
end;

destructor TTableFilter.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TTableFilter.GetServerProperties: TTableFilterProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TTableFilter.Get_Restriction: _IRestriction;
begin
    Result := DefaultInterface.Restriction;
end;

procedure TTableFilter.Clear;
begin
  DefaultInterface.Clear;
end;

function TTableFilter.SetKind(Kind: RestrictionKind): _IRestriction;
begin
  Result := DefaultInterface.SetKind(Kind);
end;

procedure TTableFilter.Restrict;
begin
  DefaultInterface.Restrict;
end;

function TTableFilter.FindFirst(Forward: WordBool): WordBool;
begin
  Result := DefaultInterface.FindFirst(Forward);
end;

function TTableFilter.FindLast(Forward: WordBool): WordBool;
begin
  Result := DefaultInterface.FindLast(Forward);
end;

function TTableFilter.FindNext(Forward: WordBool): WordBool;
begin
  Result := DefaultInterface.FindNext(Forward);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TTableFilterProperties.Create(AServer: TTableFilter);
begin
  inherited Create;
  FServer := AServer;
end;

function TTableFilterProperties.GetDefaultInterface: ITableFilter;
begin
  Result := FServer.DefaultInterface;
end;

function TTableFilterProperties.Get_Restriction: _IRestriction;
begin
    Result := DefaultInterface.Restriction;
end;

{$ENDIF}

class function Co_Restriction.Create: _IRestriction;
begin
  Result := CreateComObject(CLASS__Restriction) as _IRestriction;
end;

class function Co_Restriction.CreateRemote(const MachineName: string): _IRestriction;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__Restriction) as _IRestriction;
end;

class function Co_RestrictionCollection.Create: _IRestrictionCollection;
begin
  Result := CreateComObject(CLASS__RestrictionCollection) as _IRestrictionCollection;
end;

class function Co_RestrictionCollection.CreateRemote(const MachineName: string): _IRestrictionCollection;
begin
  Result := CreateRemoteComObject(MachineName, CLASS__RestrictionCollection) as _IRestrictionCollection;
end;

class function CoNamedProperty.Create: INamedProperty;
begin
  Result := CreateComObject(CLASS_NamedProperty) as INamedProperty;
end;

class function CoNamedProperty.CreateRemote(const MachineName: string): INamedProperty;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_NamedProperty) as INamedProperty;
end;

procedure TNamedProperty.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{6B7162DF-7EEF-4DA2-AA69-74B35A52CB75}';
    IntfIID:   '{3E1392BB-3B66-4A39-BBD0-259FC2BDC979}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TNamedProperty.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as INamedProperty;
  end;
end;

procedure TNamedProperty.ConnectTo(svrIntf: INamedProperty);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TNamedProperty.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TNamedProperty.GetDefaultInterface: INamedProperty;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TNamedProperty.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TNamedPropertyProperties.Create(Self);
{$ENDIF}
end;

destructor TNamedProperty.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TNamedProperty.GetServerProperties: TNamedPropertyProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TNamedProperty.Get_GUID: WideString;
begin
    Result := DefaultInterface.GUID;
end;

function TNamedProperty.Get_ID: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ID;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TNamedPropertyProperties.Create(AServer: TNamedProperty);
begin
  inherited Create;
  FServer := AServer;
end;

function TNamedPropertyProperties.GetDefaultInterface: INamedProperty;
begin
  Result := FServer.DefaultInterface;
end;

function TNamedPropertyProperties.Get_GUID: WideString;
begin
    Result := DefaultInterface.GUID;
end;

function TNamedPropertyProperties.Get_ID: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ID;
end;

{$ENDIF}

class function CoPropList.Create: IPropList;
begin
  Result := CreateComObject(CLASS_PropList) as IPropList;
end;

class function CoPropList.CreateRemote(const MachineName: string): IPropList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PropList) as IPropList;
end;

procedure TPropList.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{9717E1EF-2DBE-4B87-94CA-DFC6CFFA510F}';
    IntfIID:   '{7EE495F3-345B-4CC1-AAB7-A255ED85EED2}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TPropList.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IPropList;
  end;
end;

procedure TPropList.ConnectTo(svrIntf: IPropList);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TPropList.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TPropList.GetDefaultInterface: IPropList;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TPropList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TPropListProperties.Create(Self);
{$ENDIF}
end;

destructor TPropList.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TPropList.GetServerProperties: TPropListProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TPropList.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TPropList.Get_Item(Index: Integer): Integer;
begin
    Result := DefaultInterface.Item[Index];
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TPropListProperties.Create(AServer: TPropList);
begin
  inherited Create;
  FServer := AServer;
end;

function TPropListProperties.GetDefaultInterface: IPropList;
begin
  Result := FServer.DefaultInterface;
end;

function TPropListProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TPropListProperties.Get_Item(Index: Integer): Integer;
begin
    Result := DefaultInterface.Item[Index];
end;

{$ENDIF}

class function CoSafeReportItem.Create: ISafeReportItem;
begin
  Result := CreateComObject(CLASS_SafeReportItem) as ISafeReportItem;
end;

class function CoSafeReportItem.CreateRemote(const MachineName: string): ISafeReportItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeReportItem) as ISafeReportItem;
end;

procedure TSafeReportItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{D46BA7B2-899F-4F60-85C7-4DF5713F6F18}';
    IntfIID:   '{03C3860D-86B7-4F36-924C-3B1AD93B4C79}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeReportItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeReportItem;
  end;
end;

procedure TSafeReportItem.ConnectTo(svrIntf: ISafeReportItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeReportItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeReportItem.GetDefaultInterface: ISafeReportItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeReportItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeReportItemProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeReportItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeReportItem.GetServerProperties: TSafeReportItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeReportItem.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeReportItem.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeReportItem.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeReportItem.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeReportItem.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeReportItem.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeReportItem.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeReportItem.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeReportItem.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeReportItem.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeReportItem.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeReportItem.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeReportItem.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

function TSafeReportItem.GetIDsFromNames(const GUID: WideString; ID: OleVariant): Integer;
begin
  Result := DefaultInterface.GetIDsFromNames(GUID, ID);
end;

procedure TSafeReportItem.Send;
begin
  DefaultInterface.Send;
end;

procedure TSafeReportItem.Import(const Path: WideString; Type_: Integer);
begin
  DefaultInterface.Import(Path, Type_);
end;

procedure TSafeReportItem.SaveAs(const Path: WideString);
begin
  DefaultInterface.SaveAs(Path, EmptyParam);
end;

procedure TSafeReportItem.SaveAs(const Path: WideString; Type_: OleVariant);
begin
  DefaultInterface.SaveAs(Path, Type_);
end;

procedure TSafeReportItem.CopyTo(Item: OleVariant);
begin
  DefaultInterface.CopyTo(Item);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeReportItemProperties.Create(AServer: TSafeReportItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeReportItemProperties.GetDefaultInterface: ISafeReportItem;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeReportItemProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeReportItemProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeReportItemProperties.Get_Fields(PropTag: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Fields[PropTag];
end;

procedure TSafeReportItemProperties.Set_Fields(PropTag: Integer; Value: OleVariant);
begin
  DefaultInterface.Fields[PropTag] := Value;
end;

function TSafeReportItemProperties.Get_Version: WideString;
begin
    Result := DefaultInterface.Version;
end;

function TSafeReportItemProperties.Get_RTFBody: WideString;
begin
    Result := DefaultInterface.RTFBody;
end;

procedure TSafeReportItemProperties.Set_RTFBody(const Value: WideString);
  { Warning: The property RTFBody has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFBody := Value;
end;

function TSafeReportItemProperties.Get_Recipients: ISafeRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TSafeReportItemProperties.Get_Attachments: IAttachments;
begin
    Result := DefaultInterface.Attachments;
end;

procedure TSafeReportItemProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TSafeReportItemProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TSafeReportItemProperties.Set_Body(const Value: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := Value;
end;

function TSafeReportItemProperties.Get_Sender: IAddressEntry;
begin
    Result := DefaultInterface.Sender;
end;

{$ENDIF}

class function CoSafeInspector.Create: ISafeInspector;
begin
  Result := CreateComObject(CLASS_SafeInspector) as ISafeInspector;
end;

class function CoSafeInspector.CreateRemote(const MachineName: string): ISafeInspector;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SafeInspector) as ISafeInspector;
end;

procedure TSafeInspector.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{ED323630-B4FD-4628-BC6A-D4CC44AE3F00}';
    IntfIID:   '{6E4C6020-2932-4DDD-BDA8-998AE4CDF50D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSafeInspector.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISafeInspector;
  end;
end;

procedure TSafeInspector.ConnectTo(svrIntf: ISafeInspector);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSafeInspector.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSafeInspector.GetDefaultInterface: ISafeInspector;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSafeInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSafeInspectorProperties.Create(Self);
{$ENDIF}
end;

destructor TSafeInspector.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSafeInspector.GetServerProperties: TSafeInspectorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSafeInspector.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeInspector.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeInspector.Get_HTMLEditor: IDispatch;
begin
    Result := DefaultInterface.HTMLEditor;
end;

function TSafeInspector.Get_WordEditor: IDispatch;
begin
    Result := DefaultInterface.WordEditor;
end;

function TSafeInspector.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TSafeInspector.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TSafeInspector.Get_PlainTextEditor: IPlainTextEditor;
begin
    Result := DefaultInterface.PlainTextEditor;
end;

function TSafeInspector.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TSafeInspector.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TSafeInspector.Get_RTFEditor: IRTFEditor;
begin
    Result := DefaultInterface.RTFEditor;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSafeInspectorProperties.Create(AServer: TSafeInspector);
begin
  inherited Create;
  FServer := AServer;
end;

function TSafeInspectorProperties.GetDefaultInterface: ISafeInspector;
begin
  Result := FServer.DefaultInterface;
end;

function TSafeInspectorProperties.Get_Item: IDispatch;
begin
    Result := DefaultInterface.Item;
end;

procedure TSafeInspectorProperties.Set_Item(const Value: IDispatch);
begin
  DefaultInterface.Set_Item(Value);
end;

function TSafeInspectorProperties.Get_HTMLEditor: IDispatch;
begin
    Result := DefaultInterface.HTMLEditor;
end;

function TSafeInspectorProperties.Get_WordEditor: IDispatch;
begin
    Result := DefaultInterface.WordEditor;
end;

function TSafeInspectorProperties.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TSafeInspectorProperties.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TSafeInspectorProperties.Get_PlainTextEditor: IPlainTextEditor;
begin
    Result := DefaultInterface.PlainTextEditor;
end;

function TSafeInspectorProperties.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TSafeInspectorProperties.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TSafeInspectorProperties.Get_RTFEditor: IRTFEditor;
begin
    Result := DefaultInterface.RTFEditor;
end;

{$ENDIF}

class function CoPlainTextEditor.Create: IPlainTextEditor;
begin
  Result := CreateComObject(CLASS_PlainTextEditor) as IPlainTextEditor;
end;

class function CoPlainTextEditor.CreateRemote(const MachineName: string): IPlainTextEditor;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PlainTextEditor) as IPlainTextEditor;
end;

procedure TPlainTextEditor.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{E07CB99C-BDBD-4DE3-9A22-3A742C3119BD}';
    IntfIID:   '{52EB94F3-545B-4EF0-BEE7-50537E704EFB}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TPlainTextEditor.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IPlainTextEditor;
  end;
end;

procedure TPlainTextEditor.ConnectTo(svrIntf: IPlainTextEditor);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TPlainTextEditor.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TPlainTextEditor.GetDefaultInterface: IPlainTextEditor;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TPlainTextEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TPlainTextEditorProperties.Create(Self);
{$ENDIF}
end;

destructor TPlainTextEditor.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TPlainTextEditor.GetServerProperties: TPlainTextEditorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TPlainTextEditor.Get_CaretPosX: Integer;
begin
    Result := DefaultInterface.CaretPosX;
end;

procedure TPlainTextEditor.Set_CaretPosX(Value: Integer);
begin
  DefaultInterface.Set_CaretPosX(Value);
end;

function TPlainTextEditor.Get_CaretPosY: Integer;
begin
    Result := DefaultInterface.CaretPosY;
end;

procedure TPlainTextEditor.Set_CaretPosY(Value: Integer);
begin
  DefaultInterface.Set_CaretPosY(Value);
end;

function TPlainTextEditor.Get_CanUndo: WordBool;
begin
    Result := DefaultInterface.CanUndo;
end;

function TPlainTextEditor.Get_HideSelection: WordBool;
begin
    Result := DefaultInterface.HideSelection;
end;

procedure TPlainTextEditor.Set_HideSelection(Value: WordBool);
begin
  DefaultInterface.Set_HideSelection(Value);
end;

function TPlainTextEditor.Get_ReadOnly: WordBool;
begin
    Result := DefaultInterface.ReadOnly;
end;

procedure TPlainTextEditor.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.Set_ReadOnly(Value);
end;

function TPlainTextEditor.Get_SelLength: Integer;
begin
    Result := DefaultInterface.SelLength;
end;

procedure TPlainTextEditor.Set_SelLength(Value: Integer);
begin
  DefaultInterface.Set_SelLength(Value);
end;

function TPlainTextEditor.Get_SelStart: Integer;
begin
    Result := DefaultInterface.SelStart;
end;

procedure TPlainTextEditor.Set_SelStart(Value: Integer);
begin
  DefaultInterface.Set_SelStart(Value);
end;

function TPlainTextEditor.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TPlainTextEditor.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TPlainTextEditor.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TPlainTextEditor.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TPlainTextEditor.Get_Handle: OLE_HANDLE;
begin
    Result := DefaultInterface.Handle;
end;

procedure TPlainTextEditor.Clear;
begin
  DefaultInterface.Clear;
end;

procedure TPlainTextEditor.ClearSelection;
begin
  DefaultInterface.ClearSelection;
end;

procedure TPlainTextEditor.ClearUndo;
begin
  DefaultInterface.ClearUndo;
end;

procedure TPlainTextEditor.CopyToClipboard;
begin
  DefaultInterface.CopyToClipboard;
end;

procedure TPlainTextEditor.CutToClipboard;
begin
  DefaultInterface.CutToClipboard;
end;

procedure TPlainTextEditor.PasteFromClipboard;
begin
  DefaultInterface.PasteFromClipboard;
end;

procedure TPlainTextEditor.SelectAll;
begin
  DefaultInterface.SelectAll;
end;

procedure TPlainTextEditor.Undo;
begin
  DefaultInterface.Undo;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TPlainTextEditorProperties.Create(AServer: TPlainTextEditor);
begin
  inherited Create;
  FServer := AServer;
end;

function TPlainTextEditorProperties.GetDefaultInterface: IPlainTextEditor;
begin
  Result := FServer.DefaultInterface;
end;

function TPlainTextEditorProperties.Get_CaretPosX: Integer;
begin
    Result := DefaultInterface.CaretPosX;
end;

procedure TPlainTextEditorProperties.Set_CaretPosX(Value: Integer);
begin
  DefaultInterface.Set_CaretPosX(Value);
end;

function TPlainTextEditorProperties.Get_CaretPosY: Integer;
begin
    Result := DefaultInterface.CaretPosY;
end;

procedure TPlainTextEditorProperties.Set_CaretPosY(Value: Integer);
begin
  DefaultInterface.Set_CaretPosY(Value);
end;

function TPlainTextEditorProperties.Get_CanUndo: WordBool;
begin
    Result := DefaultInterface.CanUndo;
end;

function TPlainTextEditorProperties.Get_HideSelection: WordBool;
begin
    Result := DefaultInterface.HideSelection;
end;

procedure TPlainTextEditorProperties.Set_HideSelection(Value: WordBool);
begin
  DefaultInterface.Set_HideSelection(Value);
end;

function TPlainTextEditorProperties.Get_ReadOnly: WordBool;
begin
    Result := DefaultInterface.ReadOnly;
end;

procedure TPlainTextEditorProperties.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.Set_ReadOnly(Value);
end;

function TPlainTextEditorProperties.Get_SelLength: Integer;
begin
    Result := DefaultInterface.SelLength;
end;

procedure TPlainTextEditorProperties.Set_SelLength(Value: Integer);
begin
  DefaultInterface.Set_SelLength(Value);
end;

function TPlainTextEditorProperties.Get_SelStart: Integer;
begin
    Result := DefaultInterface.SelStart;
end;

procedure TPlainTextEditorProperties.Set_SelStart(Value: Integer);
begin
  DefaultInterface.Set_SelStart(Value);
end;

function TPlainTextEditorProperties.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TPlainTextEditorProperties.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TPlainTextEditorProperties.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TPlainTextEditorProperties.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TPlainTextEditorProperties.Get_Handle: OLE_HANDLE;
begin
    Result := DefaultInterface.Handle;
end;

{$ENDIF}

class function CoRTFEditor.Create: IRTFEditor;
begin
  Result := CreateComObject(CLASS_RTFEditor) as IRTFEditor;
end;

class function CoRTFEditor.CreateRemote(const MachineName: string): IRTFEditor;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RTFEditor) as IRTFEditor;
end;

procedure TRTFEditor.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{DD04CEFA-0BF8-456C-8621-6E3D7A12591A}';
    IntfIID:   '{E206FB9D-3F15-4130-A977-3FCAD9CE1188}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TRTFEditor.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IRTFEditor;
  end;
end;

procedure TRTFEditor.ConnectTo(svrIntf: IRTFEditor);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TRTFEditor.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TRTFEditor.GetDefaultInterface: IRTFEditor;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TRTFEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TRTFEditorProperties.Create(Self);
{$ENDIF}
end;

destructor TRTFEditor.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TRTFEditor.GetServerProperties: TRTFEditorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TRTFEditor.Get_CaretPosX: Integer;
begin
    Result := DefaultInterface.CaretPosX;
end;

procedure TRTFEditor.Set_CaretPosX(Value: Integer);
begin
  DefaultInterface.Set_CaretPosX(Value);
end;

function TRTFEditor.Get_CaretPosY: Integer;
begin
    Result := DefaultInterface.CaretPosY;
end;

procedure TRTFEditor.Set_CaretPosY(Value: Integer);
begin
  DefaultInterface.Set_CaretPosY(Value);
end;

function TRTFEditor.Get_CanUndo: WordBool;
begin
    Result := DefaultInterface.CanUndo;
end;

function TRTFEditor.Get_HideSelection: WordBool;
begin
    Result := DefaultInterface.HideSelection;
end;

procedure TRTFEditor.Set_HideSelection(Value: WordBool);
begin
  DefaultInterface.Set_HideSelection(Value);
end;

function TRTFEditor.Get_ReadOnly: WordBool;
begin
    Result := DefaultInterface.ReadOnly;
end;

procedure TRTFEditor.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.Set_ReadOnly(Value);
end;

function TRTFEditor.Get_SelLength: Integer;
begin
    Result := DefaultInterface.SelLength;
end;

procedure TRTFEditor.Set_SelLength(Value: Integer);
begin
  DefaultInterface.Set_SelLength(Value);
end;

function TRTFEditor.Get_SelStart: Integer;
begin
    Result := DefaultInterface.SelStart;
end;

procedure TRTFEditor.Set_SelStart(Value: Integer);
begin
  DefaultInterface.Set_SelStart(Value);
end;

function TRTFEditor.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TRTFEditor.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TRTFEditor.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TRTFEditor.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TRTFEditor.Get_Handle: OLE_HANDLE;
begin
    Result := DefaultInterface.Handle;
end;

function TRTFEditor.Get_RTFSelText: WideString;
begin
    Result := DefaultInterface.RTFSelText;
end;

procedure TRTFEditor.Set_RTFSelText(const Value: WideString);
  { Warning: The property RTFSelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFSelText := Value;
end;

function TRTFEditor.Get_RTFText: WideString;
begin
    Result := DefaultInterface.RTFText;
end;

procedure TRTFEditor.Set_RTFText(const Value: WideString);
  { Warning: The property RTFText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFText := Value;
end;

function TRTFEditor.Get_DefAttributes: ITextAttributes;
begin
    Result := DefaultInterface.DefAttributes;
end;

function TRTFEditor.Get_SelAttributes: ITextAttributes;
begin
    Result := DefaultInterface.SelAttributes;
end;

function TRTFEditor.Get_ParagraphAttributes: IParagraphAttributes;
begin
    Result := DefaultInterface.ParagraphAttributes;
end;

procedure TRTFEditor.Clear;
begin
  DefaultInterface.Clear;
end;

procedure TRTFEditor.ClearSelection;
begin
  DefaultInterface.ClearSelection;
end;

procedure TRTFEditor.ClearUndo;
begin
  DefaultInterface.ClearUndo;
end;

procedure TRTFEditor.CopyToClipboard;
begin
  DefaultInterface.CopyToClipboard;
end;

procedure TRTFEditor.CutToClipboard;
begin
  DefaultInterface.CutToClipboard;
end;

procedure TRTFEditor.PasteFromClipboard;
begin
  DefaultInterface.PasteFromClipboard;
end;

procedure TRTFEditor.SelectAll;
begin
  DefaultInterface.SelectAll;
end;

procedure TRTFEditor.Undo;
begin
  DefaultInterface.Undo;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TRTFEditorProperties.Create(AServer: TRTFEditor);
begin
  inherited Create;
  FServer := AServer;
end;

function TRTFEditorProperties.GetDefaultInterface: IRTFEditor;
begin
  Result := FServer.DefaultInterface;
end;

function TRTFEditorProperties.Get_CaretPosX: Integer;
begin
    Result := DefaultInterface.CaretPosX;
end;

procedure TRTFEditorProperties.Set_CaretPosX(Value: Integer);
begin
  DefaultInterface.Set_CaretPosX(Value);
end;

function TRTFEditorProperties.Get_CaretPosY: Integer;
begin
    Result := DefaultInterface.CaretPosY;
end;

procedure TRTFEditorProperties.Set_CaretPosY(Value: Integer);
begin
  DefaultInterface.Set_CaretPosY(Value);
end;

function TRTFEditorProperties.Get_CanUndo: WordBool;
begin
    Result := DefaultInterface.CanUndo;
end;

function TRTFEditorProperties.Get_HideSelection: WordBool;
begin
    Result := DefaultInterface.HideSelection;
end;

procedure TRTFEditorProperties.Set_HideSelection(Value: WordBool);
begin
  DefaultInterface.Set_HideSelection(Value);
end;

function TRTFEditorProperties.Get_ReadOnly: WordBool;
begin
    Result := DefaultInterface.ReadOnly;
end;

procedure TRTFEditorProperties.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.Set_ReadOnly(Value);
end;

function TRTFEditorProperties.Get_SelLength: Integer;
begin
    Result := DefaultInterface.SelLength;
end;

procedure TRTFEditorProperties.Set_SelLength(Value: Integer);
begin
  DefaultInterface.Set_SelLength(Value);
end;

function TRTFEditorProperties.Get_SelStart: Integer;
begin
    Result := DefaultInterface.SelStart;
end;

procedure TRTFEditorProperties.Set_SelStart(Value: Integer);
begin
  DefaultInterface.Set_SelStart(Value);
end;

function TRTFEditorProperties.Get_SelText: WideString;
begin
    Result := DefaultInterface.SelText;
end;

procedure TRTFEditorProperties.Set_SelText(const Value: WideString);
  { Warning: The property SelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SelText := Value;
end;

function TRTFEditorProperties.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

procedure TRTFEditorProperties.Set_Text(const Value: WideString);
  { Warning: The property Text has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Text := Value;
end;

function TRTFEditorProperties.Get_Handle: OLE_HANDLE;
begin
    Result := DefaultInterface.Handle;
end;

function TRTFEditorProperties.Get_RTFSelText: WideString;
begin
    Result := DefaultInterface.RTFSelText;
end;

procedure TRTFEditorProperties.Set_RTFSelText(const Value: WideString);
  { Warning: The property RTFSelText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFSelText := Value;
end;

function TRTFEditorProperties.Get_RTFText: WideString;
begin
    Result := DefaultInterface.RTFText;
end;

procedure TRTFEditorProperties.Set_RTFText(const Value: WideString);
  { Warning: The property RTFText has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RTFText := Value;
end;

function TRTFEditorProperties.Get_DefAttributes: ITextAttributes;
begin
    Result := DefaultInterface.DefAttributes;
end;

function TRTFEditorProperties.Get_SelAttributes: ITextAttributes;
begin
    Result := DefaultInterface.SelAttributes;
end;

function TRTFEditorProperties.Get_ParagraphAttributes: IParagraphAttributes;
begin
    Result := DefaultInterface.ParagraphAttributes;
end;

{$ENDIF}

class function CoTextAttributes.Create: ITextAttributes;
begin
  Result := CreateComObject(CLASS_TextAttributes) as ITextAttributes;
end;

class function CoTextAttributes.CreateRemote(const MachineName: string): ITextAttributes;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TextAttributes) as ITextAttributes;
end;

procedure TTextAttributes.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{A7032819-F323-4539-B13A-26E32168E4F2}';
    IntfIID:   '{4D0A6803-18D2-4EAC-BA33-137F10AC8710}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TTextAttributes.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ITextAttributes;
  end;
end;

procedure TTextAttributes.ConnectTo(svrIntf: ITextAttributes);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TTextAttributes.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TTextAttributes.GetDefaultInterface: ITextAttributes;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TTextAttributes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TTextAttributesProperties.Create(Self);
{$ENDIF}
end;

destructor TTextAttributes.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TTextAttributes.GetServerProperties: TTextAttributesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TTextAttributes.Get_Charset: Integer;
begin
    Result := DefaultInterface.Charset;
end;

procedure TTextAttributes.Set_Charset(Value: Integer);
begin
  DefaultInterface.Set_Charset(Value);
end;

function TTextAttributes.Get_Color: OLE_COLOR;
begin
    Result := DefaultInterface.Color;
end;

procedure TTextAttributes.Set_Color(Value: OLE_COLOR);
begin
  DefaultInterface.Set_Color(Value);
end;

function TTextAttributes.Get_Height: Integer;
begin
    Result := DefaultInterface.Height;
end;

procedure TTextAttributes.Set_Height(Value: Integer);
begin
  DefaultInterface.Set_Height(Value);
end;

function TTextAttributes.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TTextAttributes.Set_Name(const Value: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := Value;
end;

function TTextAttributes.Get_Pitch: FontPitch;
begin
    Result := DefaultInterface.Pitch;
end;

procedure TTextAttributes.Set_Pitch(Value: FontPitch);
begin
  DefaultInterface.Set_Pitch(Value);
end;

function TTextAttributes.Get_Protected_: WordBool;
begin
    Result := DefaultInterface.Protected_;
end;

procedure TTextAttributes.Set_Protected_(Value: WordBool);
begin
  DefaultInterface.Set_Protected_(Value);
end;

function TTextAttributes.Get_Size: Integer;
begin
    Result := DefaultInterface.Size;
end;

procedure TTextAttributes.Set_Size(Value: Integer);
begin
  DefaultInterface.Set_Size(Value);
end;

function TTextAttributes.Get_Style: IFontStyle;
begin
    Result := DefaultInterface.Style;
end;

function TTextAttributes.Get_ConsistentAttributes: IConsistentAttributes;
begin
    Result := DefaultInterface.ConsistentAttributes;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TTextAttributesProperties.Create(AServer: TTextAttributes);
begin
  inherited Create;
  FServer := AServer;
end;

function TTextAttributesProperties.GetDefaultInterface: ITextAttributes;
begin
  Result := FServer.DefaultInterface;
end;

function TTextAttributesProperties.Get_Charset: Integer;
begin
    Result := DefaultInterface.Charset;
end;

procedure TTextAttributesProperties.Set_Charset(Value: Integer);
begin
  DefaultInterface.Set_Charset(Value);
end;

function TTextAttributesProperties.Get_Color: OLE_COLOR;
begin
    Result := DefaultInterface.Color;
end;

procedure TTextAttributesProperties.Set_Color(Value: OLE_COLOR);
begin
  DefaultInterface.Set_Color(Value);
end;

function TTextAttributesProperties.Get_Height: Integer;
begin
    Result := DefaultInterface.Height;
end;

procedure TTextAttributesProperties.Set_Height(Value: Integer);
begin
  DefaultInterface.Set_Height(Value);
end;

function TTextAttributesProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TTextAttributesProperties.Set_Name(const Value: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := Value;
end;

function TTextAttributesProperties.Get_Pitch: FontPitch;
begin
    Result := DefaultInterface.Pitch;
end;

procedure TTextAttributesProperties.Set_Pitch(Value: FontPitch);
begin
  DefaultInterface.Set_Pitch(Value);
end;

function TTextAttributesProperties.Get_Protected_: WordBool;
begin
    Result := DefaultInterface.Protected_;
end;

procedure TTextAttributesProperties.Set_Protected_(Value: WordBool);
begin
  DefaultInterface.Set_Protected_(Value);
end;

function TTextAttributesProperties.Get_Size: Integer;
begin
    Result := DefaultInterface.Size;
end;

procedure TTextAttributesProperties.Set_Size(Value: Integer);
begin
  DefaultInterface.Set_Size(Value);
end;

function TTextAttributesProperties.Get_Style: IFontStyle;
begin
    Result := DefaultInterface.Style;
end;

function TTextAttributesProperties.Get_ConsistentAttributes: IConsistentAttributes;
begin
    Result := DefaultInterface.ConsistentAttributes;
end;

{$ENDIF}

class function CoFontStyle.Create: IFontStyle;
begin
  Result := CreateComObject(CLASS_FontStyle) as IFontStyle;
end;

class function CoFontStyle.CreateRemote(const MachineName: string): IFontStyle;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FontStyle) as IFontStyle;
end;

procedure TFontStyle.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{4BB0E9CA-4218-43F0-AB4B-92BA7589958E}';
    IntfIID:   '{7D2EA1D8-E8F9-482A-9D08-BBE5CECC3772}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFontStyle.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFontStyle;
  end;
end;

procedure TFontStyle.ConnectTo(svrIntf: IFontStyle);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFontStyle.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFontStyle.GetDefaultInterface: IFontStyle;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFontStyle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFontStyleProperties.Create(Self);
{$ENDIF}
end;

destructor TFontStyle.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFontStyle.GetServerProperties: TFontStyleProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFontStyle.Get_Bold: WordBool;
begin
    Result := DefaultInterface.Bold;
end;

procedure TFontStyle.Set_Bold(Value: WordBool);
begin
  DefaultInterface.Set_Bold(Value);
end;

function TFontStyle.Get_Italic: WordBool;
begin
    Result := DefaultInterface.Italic;
end;

procedure TFontStyle.Set_Italic(Value: WordBool);
begin
  DefaultInterface.Set_Italic(Value);
end;

function TFontStyle.Get_Underline: WordBool;
begin
    Result := DefaultInterface.Underline;
end;

procedure TFontStyle.Set_Underline(Value: WordBool);
begin
  DefaultInterface.Set_Underline(Value);
end;

function TFontStyle.Get_Strikeout: WordBool;
begin
    Result := DefaultInterface.Strikeout;
end;

procedure TFontStyle.Set_Strikeout(Value: WordBool);
begin
  DefaultInterface.Set_Strikeout(Value);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFontStyleProperties.Create(AServer: TFontStyle);
begin
  inherited Create;
  FServer := AServer;
end;

function TFontStyleProperties.GetDefaultInterface: IFontStyle;
begin
  Result := FServer.DefaultInterface;
end;

function TFontStyleProperties.Get_Bold: WordBool;
begin
    Result := DefaultInterface.Bold;
end;

procedure TFontStyleProperties.Set_Bold(Value: WordBool);
begin
  DefaultInterface.Set_Bold(Value);
end;

function TFontStyleProperties.Get_Italic: WordBool;
begin
    Result := DefaultInterface.Italic;
end;

procedure TFontStyleProperties.Set_Italic(Value: WordBool);
begin
  DefaultInterface.Set_Italic(Value);
end;

function TFontStyleProperties.Get_Underline: WordBool;
begin
    Result := DefaultInterface.Underline;
end;

procedure TFontStyleProperties.Set_Underline(Value: WordBool);
begin
  DefaultInterface.Set_Underline(Value);
end;

function TFontStyleProperties.Get_Strikeout: WordBool;
begin
    Result := DefaultInterface.Strikeout;
end;

procedure TFontStyleProperties.Set_Strikeout(Value: WordBool);
begin
  DefaultInterface.Set_Strikeout(Value);
end;

{$ENDIF}

class function CoConsistentAttributes.Create: IConsistentAttributes;
begin
  Result := CreateComObject(CLASS_ConsistentAttributes) as IConsistentAttributes;
end;

class function CoConsistentAttributes.CreateRemote(const MachineName: string): IConsistentAttributes;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ConsistentAttributes) as IConsistentAttributes;
end;

procedure TConsistentAttributes.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{1CEFB688-FD1E-4956-87C5-88A3F7518F27}';
    IntfIID:   '{CDA81541-363F-4CBF-97FB-FD138F4D102D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TConsistentAttributes.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IConsistentAttributes;
  end;
end;

procedure TConsistentAttributes.ConnectTo(svrIntf: IConsistentAttributes);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TConsistentAttributes.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TConsistentAttributes.GetDefaultInterface: IConsistentAttributes;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TConsistentAttributes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TConsistentAttributesProperties.Create(Self);
{$ENDIF}
end;

destructor TConsistentAttributes.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TConsistentAttributes.GetServerProperties: TConsistentAttributesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TConsistentAttributes.Get_Bold: WordBool;
begin
    Result := DefaultInterface.Bold;
end;

function TConsistentAttributes.Get_Color: WordBool;
begin
    Result := DefaultInterface.Color;
end;

function TConsistentAttributes.Get_Face: WordBool;
begin
    Result := DefaultInterface.Face;
end;

function TConsistentAttributes.Get_Italic: WordBool;
begin
    Result := DefaultInterface.Italic;
end;

function TConsistentAttributes.Get_Size: WordBool;
begin
    Result := DefaultInterface.Size;
end;

function TConsistentAttributes.Get_Strikeout: WordBool;
begin
    Result := DefaultInterface.Strikeout;
end;

function TConsistentAttributes.Get_Underline: WordBool;
begin
    Result := DefaultInterface.Underline;
end;

function TConsistentAttributes.Get_Protected_: WordBool;
begin
    Result := DefaultInterface.Protected_;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TConsistentAttributesProperties.Create(AServer: TConsistentAttributes);
begin
  inherited Create;
  FServer := AServer;
end;

function TConsistentAttributesProperties.GetDefaultInterface: IConsistentAttributes;
begin
  Result := FServer.DefaultInterface;
end;

function TConsistentAttributesProperties.Get_Bold: WordBool;
begin
    Result := DefaultInterface.Bold;
end;

function TConsistentAttributesProperties.Get_Color: WordBool;
begin
    Result := DefaultInterface.Color;
end;

function TConsistentAttributesProperties.Get_Face: WordBool;
begin
    Result := DefaultInterface.Face;
end;

function TConsistentAttributesProperties.Get_Italic: WordBool;
begin
    Result := DefaultInterface.Italic;
end;

function TConsistentAttributesProperties.Get_Size: WordBool;
begin
    Result := DefaultInterface.Size;
end;

function TConsistentAttributesProperties.Get_Strikeout: WordBool;
begin
    Result := DefaultInterface.Strikeout;
end;

function TConsistentAttributesProperties.Get_Underline: WordBool;
begin
    Result := DefaultInterface.Underline;
end;

function TConsistentAttributesProperties.Get_Protected_: WordBool;
begin
    Result := DefaultInterface.Protected_;
end;

{$ENDIF}

class function CoParagraphAttributes.Create: IParagraphAttributes;
begin
  Result := CreateComObject(CLASS_ParagraphAttributes) as IParagraphAttributes;
end;

class function CoParagraphAttributes.CreateRemote(const MachineName: string): IParagraphAttributes;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ParagraphAttributes) as IParagraphAttributes;
end;

procedure TParagraphAttributes.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{05E2DCFB-2F74-43AE-B59B-1713AAA4E7BB}';
    IntfIID:   '{13FFAB29-AE8F-473C-9F21-5ED4664BE98F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TParagraphAttributes.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IParagraphAttributes;
  end;
end;

procedure TParagraphAttributes.ConnectTo(svrIntf: IParagraphAttributes);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TParagraphAttributes.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TParagraphAttributes.GetDefaultInterface: IParagraphAttributes;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TParagraphAttributes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TParagraphAttributesProperties.Create(Self);
{$ENDIF}
end;

destructor TParagraphAttributes.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TParagraphAttributes.GetServerProperties: TParagraphAttributesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TParagraphAttributes.Get_Alignment: TextAlignment;
begin
    Result := DefaultInterface.Alignment;
end;

procedure TParagraphAttributes.Set_Alignment(Value: TextAlignment);
begin
  DefaultInterface.Set_Alignment(Value);
end;

function TParagraphAttributes.Get_FirstIndent: Integer;
begin
    Result := DefaultInterface.FirstIndent;
end;

procedure TParagraphAttributes.Set_FirstIndent(Value: Integer);
begin
  DefaultInterface.Set_FirstIndent(Value);
end;

function TParagraphAttributes.Get_LeftIndent: Integer;
begin
    Result := DefaultInterface.LeftIndent;
end;

procedure TParagraphAttributes.Set_LeftIndent(Value: Integer);
begin
  DefaultInterface.Set_LeftIndent(Value);
end;

function TParagraphAttributes.Get_RightIndent: Integer;
begin
    Result := DefaultInterface.RightIndent;
end;

procedure TParagraphAttributes.Set_RightIndent(Value: Integer);
begin
  DefaultInterface.Set_RightIndent(Value);
end;

function TParagraphAttributes.Get_Numbering: NumberingStyle;
begin
    Result := DefaultInterface.Numbering;
end;

procedure TParagraphAttributes.Set_Numbering(Value: NumberingStyle);
begin
  DefaultInterface.Set_Numbering(Value);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TParagraphAttributesProperties.Create(AServer: TParagraphAttributes);
begin
  inherited Create;
  FServer := AServer;
end;

function TParagraphAttributesProperties.GetDefaultInterface: IParagraphAttributes;
begin
  Result := FServer.DefaultInterface;
end;

function TParagraphAttributesProperties.Get_Alignment: TextAlignment;
begin
    Result := DefaultInterface.Alignment;
end;

procedure TParagraphAttributesProperties.Set_Alignment(Value: TextAlignment);
begin
  DefaultInterface.Set_Alignment(Value);
end;

function TParagraphAttributesProperties.Get_FirstIndent: Integer;
begin
    Result := DefaultInterface.FirstIndent;
end;

procedure TParagraphAttributesProperties.Set_FirstIndent(Value: Integer);
begin
  DefaultInterface.Set_FirstIndent(Value);
end;

function TParagraphAttributesProperties.Get_LeftIndent: Integer;
begin
    Result := DefaultInterface.LeftIndent;
end;

procedure TParagraphAttributesProperties.Set_LeftIndent(Value: Integer);
begin
  DefaultInterface.Set_LeftIndent(Value);
end;

function TParagraphAttributesProperties.Get_RightIndent: Integer;
begin
    Result := DefaultInterface.RightIndent;
end;

procedure TParagraphAttributesProperties.Set_RightIndent(Value: Integer);
begin
  DefaultInterface.Set_RightIndent(Value);
end;

function TParagraphAttributesProperties.Get_Numbering: NumberingStyle;
begin
    Result := DefaultInterface.Numbering;
end;

procedure TParagraphAttributesProperties.Set_Numbering(Value: NumberingStyle);
begin
  DefaultInterface.Set_Numbering(Value);
end;

{$ENDIF}

class function CoRDOAddressBook.Create: IRDOAddressBook;
begin
  Result := CreateComObject(CLASS_RDOAddressBook) as IRDOAddressBook;
end;

class function CoRDOAddressBook.CreateRemote(const MachineName: string): IRDOAddressBook;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressBook) as IRDOAddressBook;
end;

class function CoRDOExchangeMailboxStore.Create: IRDOExchangeMailboxStore;
begin
  Result := CreateComObject(CLASS_RDOExchangeMailboxStore) as IRDOExchangeMailboxStore;
end;

class function CoRDOExchangeMailboxStore.CreateRemote(const MachineName: string): IRDOExchangeMailboxStore;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOExchangeMailboxStore) as IRDOExchangeMailboxStore;
end;

class function CoRDOExchangeStore.Create: IRDOExchangeStore;
begin
  Result := CreateComObject(CLASS_RDOExchangeStore) as IRDOExchangeStore;
end;

class function CoRDOExchangeStore.CreateRemote(const MachineName: string): IRDOExchangeStore;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOExchangeStore) as IRDOExchangeStore;
end;

class function CoRDOPstStore.Create: IRDOPstStore;
begin
  Result := CreateComObject(CLASS_RDOPstStore) as IRDOPstStore;
end;

class function CoRDOPstStore.CreateRemote(const MachineName: string): IRDOPstStore;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOPstStore) as IRDOPstStore;
end;

class function CoRDOExchangePublicFoldersStore.Create: IRDOExchangePublicFoldersStore;
begin
  Result := CreateComObject(CLASS_RDOExchangePublicFoldersStore) as IRDOExchangePublicFoldersStore;
end;

class function CoRDOExchangePublicFoldersStore.CreateRemote(const MachineName: string): IRDOExchangePublicFoldersStore;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOExchangePublicFoldersStore) as IRDOExchangePublicFoldersStore;
end;

class function CoRDOAttachments.Create: IRDOAttachments;
begin
  Result := CreateComObject(CLASS_RDOAttachments) as IRDOAttachments;
end;

class function CoRDOAttachments.CreateRemote(const MachineName: string): IRDOAttachments;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAttachments) as IRDOAttachments;
end;

class function CoRDOAttachment.Create: IRDOAttachment;
begin
  Result := CreateComObject(CLASS_RDOAttachment) as IRDOAttachment;
end;

class function CoRDOAttachment.CreateRemote(const MachineName: string): IRDOAttachment;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAttachment) as IRDOAttachment;
end;

class function CoRDORecipients.Create: IRDORecipients;
begin
  Result := CreateComObject(CLASS_RDORecipients) as IRDORecipients;
end;

class function CoRDORecipients.CreateRemote(const MachineName: string): IRDORecipients;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORecipients) as IRDORecipients;
end;

class function CoRDORecipient.Create: IRDORecipient;
begin
  Result := CreateComObject(CLASS_RDORecipient) as IRDORecipient;
end;

class function CoRDORecipient.CreateRemote(const MachineName: string): IRDORecipient;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORecipient) as IRDORecipient;
end;

class function CoRDOAddressEntry.Create: IRDOAddressEntry;
begin
  Result := CreateComObject(CLASS_RDOAddressEntry) as IRDOAddressEntry;
end;

class function CoRDOAddressEntry.CreateRemote(const MachineName: string): IRDOAddressEntry;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressEntry) as IRDOAddressEntry;
end;

class function CoRDOAddressEntries.Create: IRDOAddressEntries;
begin
  Result := CreateComObject(CLASS_RDOAddressEntries) as IRDOAddressEntries;
end;

class function CoRDOAddressEntries.CreateRemote(const MachineName: string): IRDOAddressEntries;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressEntries) as IRDOAddressEntries;
end;

class function CoRDOAddressList.Create: IRDOAddressList;
begin
  Result := CreateComObject(CLASS_RDOAddressList) as IRDOAddressList;
end;

class function CoRDOAddressList.CreateRemote(const MachineName: string): IRDOAddressList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressList) as IRDOAddressList;
end;

class function CoRDOAddressLists.Create: IRDOAddressLists;
begin
  Result := CreateComObject(CLASS_RDOAddressLists) as IRDOAddressLists;
end;

class function CoRDOAddressLists.CreateRemote(const MachineName: string): IRDOAddressLists;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressLists) as IRDOAddressLists;
end;

class function CoRDOAddressBookSearchPath.Create: IRDOAddressBookSearchPath;
begin
  Result := CreateComObject(CLASS_RDOAddressBookSearchPath) as IRDOAddressBookSearchPath;
end;

class function CoRDOAddressBookSearchPath.CreateRemote(const MachineName: string): IRDOAddressBookSearchPath;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAddressBookSearchPath) as IRDOAddressBookSearchPath;
end;

class function CoRDODeletedItems.Create: IRDODeletedItems;
begin
  Result := CreateComObject(CLASS_RDODeletedItems) as IRDODeletedItems;
end;

class function CoRDODeletedItems.CreateRemote(const MachineName: string): IRDODeletedItems;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDODeletedItems) as IRDODeletedItems;
end;

class function CoRDOSearchFolder.Create: IRDOSearchFolder;
begin
  Result := CreateComObject(CLASS_RDOSearchFolder) as IRDOSearchFolder;
end;

class function CoRDOSearchFolder.CreateRemote(const MachineName: string): IRDOSearchFolder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOSearchFolder) as IRDOSearchFolder;
end;

class function CoRDOFolderSearchCriteria.Create: IRDOFolderSearchCriteria;
begin
  Result := CreateComObject(CLASS_RDOFolderSearchCriteria) as IRDOFolderSearchCriteria;
end;

class function CoRDOFolderSearchCriteria.CreateRemote(const MachineName: string): IRDOFolderSearchCriteria;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolderSearchCriteria) as IRDOFolderSearchCriteria;
end;

class function CoRDOSearchContainersList.Create: IRDOSearchContainersList;
begin
  Result := CreateComObject(CLASS_RDOSearchContainersList) as IRDOSearchContainersList;
end;

class function CoRDOSearchContainersList.CreateRemote(const MachineName: string): IRDOSearchContainersList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOSearchContainersList) as IRDOSearchContainersList;
end;

class function CoRDOACL.Create: IRDOACL;
begin
  Result := CreateComObject(CLASS_RDOACL) as IRDOACL;
end;

class function CoRDOACL.CreateRemote(const MachineName: string): IRDOACL;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOACL) as IRDOACL;
end;

class function CoRDOACE.Create: IRDOACE;
begin
  Result := CreateComObject(CLASS_RDOACE) as IRDOACE;
end;

class function CoRDOACE.CreateRemote(const MachineName: string): IRDOACE;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOACE) as IRDOACE;
end;

class function CoRDOOutOfOfficeAssistant.Create: IRDOOutOfOfficeAssistant;
begin
  Result := CreateComObject(CLASS_RDOOutOfOfficeAssistant) as IRDOOutOfOfficeAssistant;
end;

class function CoRDOOutOfOfficeAssistant.CreateRemote(const MachineName: string): IRDOOutOfOfficeAssistant;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOOutOfOfficeAssistant) as IRDOOutOfOfficeAssistant;
end;

class function CoRDOReminders.Create: IRDOReminders;
begin
  Result := CreateComObject(CLASS_RDOReminders) as IRDOReminders;
end;

class function CoRDOReminders.CreateRemote(const MachineName: string): IRDOReminders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOReminders) as IRDOReminders;
end;

class function CoRDOReminder.Create: IRDOReminder;
begin
  Result := CreateComObject(CLASS_RDOReminder) as IRDOReminder;
end;

class function CoRDOReminder.CreateRemote(const MachineName: string): IRDOReminder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOReminder) as IRDOReminder;
end;

class function CoRDOAccount.Create: IRDOAccount;
begin
  Result := CreateComObject(CLASS_RDOAccount) as IRDOAccount;
end;

class function CoRDOAccount.CreateRemote(const MachineName: string): IRDOAccount;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAccount) as IRDOAccount;
end;

class function CoRDOPOP3Account.Create: IRDOPOP3Account;
begin
  Result := CreateComObject(CLASS_RDOPOP3Account) as IRDOPOP3Account;
end;

class function CoRDOPOP3Account.CreateRemote(const MachineName: string): IRDOPOP3Account;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOPOP3Account) as IRDOPOP3Account;
end;

class function CoRDOMAPIAccount.Create: IRDOMAPIAccount;
begin
  Result := CreateComObject(CLASS_RDOMAPIAccount) as IRDOMAPIAccount;
end;

class function CoRDOMAPIAccount.CreateRemote(const MachineName: string): IRDOMAPIAccount;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOMAPIAccount) as IRDOMAPIAccount;
end;

class function CoRDOIMAPAccount.Create: IRDOIMAPAccount;
begin
  Result := CreateComObject(CLASS_RDOIMAPAccount) as IRDOIMAPAccount;
end;

class function CoRDOIMAPAccount.CreateRemote(const MachineName: string): IRDOIMAPAccount;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOIMAPAccount) as IRDOIMAPAccount;
end;

class function CoRDOHTTPAccount.Create: IRDOHTTPAccount;
begin
  Result := CreateComObject(CLASS_RDOHTTPAccount) as IRDOHTTPAccount;
end;

class function CoRDOHTTPAccount.CreateRemote(const MachineName: string): IRDOHTTPAccount;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOHTTPAccount) as IRDOHTTPAccount;
end;

class function CoRDOLDAPAccount.Create: IRDOLDAPAccount;
begin
  Result := CreateComObject(CLASS_RDOLDAPAccount) as IRDOLDAPAccount;
end;

class function CoRDOLDAPAccount.CreateRemote(const MachineName: string): IRDOLDAPAccount;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOLDAPAccount) as IRDOLDAPAccount;
end;

class function CoRDOAccountOrderList.Create: IRDOAccountOrderList;
begin
  Result := CreateComObject(CLASS_RDOAccountOrderList) as IRDOAccountOrderList;
end;

class function CoRDOAccountOrderList.CreateRemote(const MachineName: string): IRDOAccountOrderList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAccountOrderList) as IRDOAccountOrderList;
end;

class function CoRDOSession.Create: IRDOSession;
begin
  Result := CreateComObject(CLASS_RDOSession) as IRDOSession;
end;

class function CoRDOSession.CreateRemote(const MachineName: string): IRDOSession;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOSession) as IRDOSession;
end;

procedure TRDOSession.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{29AB7A12-B531-450E-8F7A-EA94C2F3C05F}';
    IntfIID:   '{E54C5168-AA8C-405F-9C14-A4037302BD9D}';
    EventIID:  '{BFFCC45C-D97E-48A1-9548-6796FA0334EC}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TRDOSession.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IRDOSession;
  end;
end;

procedure TRDOSession.ConnectTo(svrIntf: IRDOSession);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TRDOSession.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TRDOSession.GetDefaultInterface: IRDOSession;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TRDOSession.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TRDOSessionProperties.Create(Self);
{$ENDIF}
end;

destructor TRDOSession.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TRDOSession.GetServerProperties: TRDOSessionProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TRDOSession.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnNewMail) then
         FOnNewMail(Self, Params[0] {const WideString});
  end; {case DispID}
end;

function TRDOSession.Get_ProfileName: WideString;
begin
    Result := DefaultInterface.ProfileName;
end;

function TRDOSession.Get_LoggedOn: WordBool;
begin
    Result := DefaultInterface.LoggedOn;
end;

function TRDOSession.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TRDOSession.Set_MAPIOBJECT(const Value: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(Value);
end;

function TRDOSession.Get_Stores: iRDOStores;
begin
    Result := DefaultInterface.Stores;
end;

function TRDOSession.Get_AddressBook: IRDOAddressBook;
begin
    Result := DefaultInterface.AddressBook;
end;

function TRDOSession.Get_CurrentUser: IRDOAddressEntry;
begin
    Result := DefaultInterface.CurrentUser;
end;

function TRDOSession.Get_Accounts: IRDOAccounts;
begin
    Result := DefaultInterface.Accounts;
end;

procedure TRDOSession.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TRDOSession.Get_TimeZones: IRDOTimezones;
begin
    Result := DefaultInterface.TimeZones;
end;

function TRDOSession.Get_Profiles: IRDOProfiles;
begin
    Result := DefaultInterface.Profiles;
end;

function TRDOSession.Get_ExchangeConnectionMode: rdoExchangeConnectionMode;
begin
    Result := DefaultInterface.ExchangeConnectionMode;
end;

function TRDOSession.Get_ExchangeMailboxServerName: WideString;
begin
    Result := DefaultInterface.ExchangeMailboxServerName;
end;

function TRDOSession.Get_ExchangeMailboxServerVersion: WideString;
begin
    Result := DefaultInterface.ExchangeMailboxServerVersion;
end;

function TRDOSession.Get_OutlookVersion: WideString;
begin
    Result := DefaultInterface.OutlookVersion;
end;

procedure TRDOSession.Logon;
begin
  DefaultInterface.Logon(EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant; Password: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, Password, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, Password, ShowDialog, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                            NewSession: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, Password, ShowDialog, NewSession, EmptyParam, EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                            NewSession: OleVariant; ParentWindowHandle: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, Password, ShowDialog, NewSession, ParentWindowHandle, 
                         EmptyParam);
end;

procedure TRDOSession.Logon(ProfileName: OleVariant; Password: OleVariant; ShowDialog: OleVariant; 
                            NewSession: OleVariant; ParentWindowHandle: OleVariant; 
                            NoMail: OleVariant);
begin
  DefaultInterface.Logon(ProfileName, Password, ShowDialog, NewSession, ParentWindowHandle, NoMail);
end;

procedure TRDOSession.LogonExchangeMailbox(const User: WideString; const ServerName: WideString);
begin
  DefaultInterface.LogonExchangeMailbox(User, ServerName);
end;

function TRDOSession.GetDefaultFolder(FolderType: rdoDefaultFolders): IRDOFolder;
begin
  Result := DefaultInterface.GetDefaultFolder(FolderType);
end;

function TRDOSession.GetMessageFromID(const EntryIDMessage: WideString): IRDOMail;
begin
  Result := DefaultInterface.GetMessageFromID(EntryIDMessage, EmptyParam, EmptyParam);
end;

function TRDOSession.GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant): IRDOMail;
begin
  Result := DefaultInterface.GetMessageFromID(EntryIDMessage, EntryIDStore, EmptyParam);
end;

function TRDOSession.GetMessageFromID(const EntryIDMessage: WideString; EntryIDStore: OleVariant; 
                                      Flags: OleVariant): IRDOMail;
begin
  Result := DefaultInterface.GetMessageFromID(EntryIDMessage, EntryIDStore, Flags);
end;

function TRDOSession.GetFolderFromID(const EntryIDFolder: WideString): IRDOFolder;
begin
  Result := DefaultInterface.GetFolderFromID(EntryIDFolder, EmptyParam, EmptyParam);
end;

function TRDOSession.GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant): IRDOFolder;
begin
  Result := DefaultInterface.GetFolderFromID(EntryIDFolder, EntryIDStore, EmptyParam);
end;

function TRDOSession.GetFolderFromID(const EntryIDFolder: WideString; EntryIDStore: OleVariant; 
                                     Flags: OleVariant): IRDOFolder;
begin
  Result := DefaultInterface.GetFolderFromID(EntryIDFolder, EntryIDStore, Flags);
end;

function TRDOSession.GetStoreFromID(const EntryIDStore: WideString): IRDOStore;
begin
  Result := DefaultInterface.GetStoreFromID(EntryIDStore, EmptyParam);
end;

function TRDOSession.GetStoreFromID(const EntryIDStore: WideString; Flags: OleVariant): IRDOStore;
begin
  Result := DefaultInterface.GetStoreFromID(EntryIDStore, Flags);
end;

function TRDOSession.GetAddressEntryFromID(const EntryID: WideString): IRDOAddressEntry;
begin
  Result := DefaultInterface.GetAddressEntryFromID(EntryID, EmptyParam);
end;

function TRDOSession.GetAddressEntryFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressEntry;
begin
  Result := DefaultInterface.GetAddressEntryFromID(EntryID, Flags);
end;

function TRDOSession.CompareEntryIDs(const EntryID1: WideString; const EntryID2: WideString): WordBool;
begin
  Result := DefaultInterface.CompareEntryIDs(EntryID1, EntryID2);
end;

function TRDOSession.GetAddressListFromID(const EntryID: WideString): IRDOAddressList;
begin
  Result := DefaultInterface.GetAddressListFromID(EntryID, EmptyParam);
end;

function TRDOSession.GetAddressListFromID(const EntryID: WideString; Flags: OleVariant): IRDOAddressList;
begin
  Result := DefaultInterface.GetAddressListFromID(EntryID, Flags);
end;

function TRDOSession.GetSharedDefaultFolder(NameOrAddressOrObject: OleVariant; 
                                            rdoDefaultFolder: rdoDefaultFolders): IRDOFolder;
begin
  Result := DefaultInterface.GetSharedDefaultFolder(NameOrAddressOrObject, rdoDefaultFolder);
end;

function TRDOSession.GetSharedMailbox(NameOrAddressOrObject: OleVariant): IRDOStore;
begin
  Result := DefaultInterface.GetSharedMailbox(NameOrAddressOrObject);
end;

procedure TRDOSession.Logoff;
begin
  DefaultInterface.Logoff;
end;

function TRDOSession.GetMessageFromMsgFile(const FileName: WideString; CreateNew: WordBool): IRDOMail;
begin
  Result := DefaultInterface.GetMessageFromMsgFile(FileName, CreateNew);
end;

function TRDOSession.GetFolderFromPath(const FolderPath: WideString): IRDOFolder;
begin
  Result := DefaultInterface.GetFolderFromPath(FolderPath);
end;

procedure TRDOSession.SetLocaleIDs(LocaleID: Integer; CodePageID: Integer);
begin
  DefaultInterface.SetLocaleIDs(LocaleID, CodePageID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TRDOSessionProperties.Create(AServer: TRDOSession);
begin
  inherited Create;
  FServer := AServer;
end;

function TRDOSessionProperties.GetDefaultInterface: IRDOSession;
begin
  Result := FServer.DefaultInterface;
end;

function TRDOSessionProperties.Get_ProfileName: WideString;
begin
    Result := DefaultInterface.ProfileName;
end;

function TRDOSessionProperties.Get_LoggedOn: WordBool;
begin
    Result := DefaultInterface.LoggedOn;
end;

function TRDOSessionProperties.Get_MAPIOBJECT: IUnknown;
begin
    Result := DefaultInterface.MAPIOBJECT;
end;

procedure TRDOSessionProperties.Set_MAPIOBJECT(const Value: IUnknown);
begin
  DefaultInterface.Set_MAPIOBJECT(Value);
end;

function TRDOSessionProperties.Get_Stores: iRDOStores;
begin
    Result := DefaultInterface.Stores;
end;

function TRDOSessionProperties.Get_AddressBook: IRDOAddressBook;
begin
    Result := DefaultInterface.AddressBook;
end;

function TRDOSessionProperties.Get_CurrentUser: IRDOAddressEntry;
begin
    Result := DefaultInterface.CurrentUser;
end;

function TRDOSessionProperties.Get_Accounts: IRDOAccounts;
begin
    Result := DefaultInterface.Accounts;
end;

procedure TRDOSessionProperties.Set_AuthKey(const Param1: WideString);
  { Warning: The property AuthKey has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AuthKey := Param1;
end;

function TRDOSessionProperties.Get_TimeZones: IRDOTimezones;
begin
    Result := DefaultInterface.TimeZones;
end;

function TRDOSessionProperties.Get_Profiles: IRDOProfiles;
begin
    Result := DefaultInterface.Profiles;
end;

function TRDOSessionProperties.Get_ExchangeConnectionMode: rdoExchangeConnectionMode;
begin
    Result := DefaultInterface.ExchangeConnectionMode;
end;

function TRDOSessionProperties.Get_ExchangeMailboxServerName: WideString;
begin
    Result := DefaultInterface.ExchangeMailboxServerName;
end;

function TRDOSessionProperties.Get_ExchangeMailboxServerVersion: WideString;
begin
    Result := DefaultInterface.ExchangeMailboxServerVersion;
end;

function TRDOSessionProperties.Get_OutlookVersion: WideString;
begin
    Result := DefaultInterface.OutlookVersion;
end;

{$ENDIF}

class function CoRDOStore.Create: IRDOStore;
begin
  Result := CreateComObject(CLASS_RDOStore) as IRDOStore;
end;

class function CoRDOStore.CreateRemote(const MachineName: string): IRDOStore;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOStore) as IRDOStore;
end;

class function CoRDOFolder.Create: IRDOFolder;
begin
  Result := CreateComObject(CLASS_RDOFolder) as IRDOFolder;
end;

class function CoRDOFolder.CreateRemote(const MachineName: string): IRDOFolder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolder) as IRDOFolder;
end;

class function CoRDOMail.Create: IRDOMail;
begin
  Result := CreateComObject(CLASS_RDOMail) as IRDOMail;
end;

class function CoRDOMail.CreateRemote(const MachineName: string): IRDOMail;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOMail) as IRDOMail;
end;

class function CoRDOItems.Create: IRDOItems;
begin
  Result := CreateComObject(CLASS_RDOItems) as IRDOItems;
end;

class function CoRDOItems.CreateRemote(const MachineName: string): IRDOItems;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOItems) as IRDOItems;
end;

class function CoRDOFolders.Create: IRDOFolders;
begin
  Result := CreateComObject(CLASS_RDOFolders) as IRDOFolders;
end;

class function CoRDOFolders.CreateRemote(const MachineName: string): IRDOFolders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolders) as IRDOFolders;
end;

class function CoRDOStores.Create: iRDOStores;
begin
  Result := CreateComObject(CLASS_RDOStores) as iRDOStores;
end;

class function CoRDOStores.CreateRemote(const MachineName: string): iRDOStores;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOStores) as iRDOStores;
end;

class function CoRDOAccounts.Create: IRDOAccounts;
begin
  Result := CreateComObject(CLASS_RDOAccounts) as IRDOAccounts;
end;

class function CoRDOAccounts.CreateRemote(const MachineName: string): IRDOAccounts;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAccounts) as IRDOAccounts;
end;

class function CoRDODistListItem.Create: IRDODistListItem;
begin
  Result := CreateComObject(CLASS_RDODistListItem) as IRDODistListItem;
end;

class function CoRDODistListItem.CreateRemote(const MachineName: string): IRDODistListItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDODistListItem) as IRDODistListItem;
end;

class function CoRDOContactItem.Create: IRDOContactItem;
begin
  Result := CreateComObject(CLASS_RDOContactItem) as IRDOContactItem;
end;

class function CoRDOContactItem.CreateRemote(const MachineName: string): IRDOContactItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOContactItem) as IRDOContactItem;
end;

class function CoRDOFolder2.Create: IRDOFolder2;
begin
  Result := CreateComObject(CLASS_RDOFolder2) as IRDOFolder2;
end;

class function CoRDOFolder2.CreateRemote(const MachineName: string): IRDOFolder2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolder2) as IRDOFolder2;
end;

class function CoRDONoteItem.Create: IRDONoteItem;
begin
  Result := CreateComObject(CLASS_RDONoteItem) as IRDONoteItem;
end;

class function CoRDONoteItem.CreateRemote(const MachineName: string): IRDONoteItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDONoteItem) as IRDONoteItem;
end;

class function CoRDOPostItem.Create: IRDOPostItem;
begin
  Result := CreateComObject(CLASS_RDOPostItem) as IRDOPostItem;
end;

class function CoRDOPostItem.CreateRemote(const MachineName: string): IRDOPostItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOPostItem) as IRDOPostItem;
end;

class function CoRDOLinks.Create: IRDOLinks;
begin
  Result := CreateComObject(CLASS_RDOLinks) as IRDOLinks;
end;

class function CoRDOLinks.CreateRemote(const MachineName: string): IRDOLinks;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOLinks) as IRDOLinks;
end;

class function CoRDOLink.Create: IRDOLink;
begin
  Result := CreateComObject(CLASS_RDOLink) as IRDOLink;
end;

class function CoRDOLink.CreateRemote(const MachineName: string): IRDOLink;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOLink) as IRDOLink;
end;

class function CoRDOTaskItem.Create: IRDOTaskItem;
begin
  Result := CreateComObject(CLASS_RDOTaskItem) as IRDOTaskItem;
end;

class function CoRDOTaskItem.CreateRemote(const MachineName: string): IRDOTaskItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOTaskItem) as IRDOTaskItem;
end;

class function CoRDORecurrencePattern.Create: IRDORecurrencePattern;
begin
  Result := CreateComObject(CLASS_RDORecurrencePattern) as IRDORecurrencePattern;
end;

class function CoRDORecurrencePattern.CreateRemote(const MachineName: string): IRDORecurrencePattern;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORecurrencePattern) as IRDORecurrencePattern;
end;

class function CoRDOReportItem.Create: IRDOReportItem;
begin
  Result := CreateComObject(CLASS_RDOReportItem) as IRDOReportItem;
end;

class function CoRDOReportItem.CreateRemote(const MachineName: string): IRDOReportItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOReportItem) as IRDOReportItem;
end;

class function CoRDOFolderFields.Create: IRDOFolderFields;
begin
  Result := CreateComObject(CLASS_RDOFolderFields) as IRDOFolderFields;
end;

class function CoRDOFolderFields.CreateRemote(const MachineName: string): IRDOFolderFields;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolderFields) as IRDOFolderFields;
end;

class function CoRDOFolderField.Create: IRDOFolderField;
begin
  Result := CreateComObject(CLASS_RDOFolderField) as IRDOFolderField;
end;

class function CoRDOFolderField.CreateRemote(const MachineName: string): IRDOFolderField;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFolderField) as IRDOFolderField;
end;

class function CoRDOTaskRequestItem.Create: IRDOTaskRequestItem;
begin
  Result := CreateComObject(CLASS_RDOTaskRequestItem) as IRDOTaskRequestItem;
end;

class function CoRDOTaskRequestItem.CreateRemote(const MachineName: string): IRDOTaskRequestItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOTaskRequestItem) as IRDOTaskRequestItem;
end;

class function CoRDOTimeZones.Create: IRDOTimezones;
begin
  Result := CreateComObject(CLASS_RDOTimeZones) as IRDOTimezones;
end;

class function CoRDOTimeZones.CreateRemote(const MachineName: string): IRDOTimezones;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOTimeZones) as IRDOTimezones;
end;

class function CoRDOTimeZone.Create: IRDOTimezone;
begin
  Result := CreateComObject(CLASS_RDOTimeZone) as IRDOTimezone;
end;

class function CoRDOTimeZone.CreateRemote(const MachineName: string): IRDOTimezone;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOTimeZone) as IRDOTimezone;
end;

class function CoRDOProfiles.Create: IRDOProfiles;
begin
  Result := CreateComObject(CLASS_RDOProfiles) as IRDOProfiles;
end;

class function CoRDOProfiles.CreateRemote(const MachineName: string): IRDOProfiles;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOProfiles) as IRDOProfiles;
end;

class function CoRDORules.Create: IRDORules;
begin
  Result := CreateComObject(CLASS_RDORules) as IRDORules;
end;

class function CoRDORules.CreateRemote(const MachineName: string): IRDORules;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORules) as IRDORules;
end;

class function CoRDORule.Create: IRDORule;
begin
  Result := CreateComObject(CLASS_RDORule) as IRDORule;
end;

class function CoRDORule.CreateRemote(const MachineName: string): IRDORule;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORule) as IRDORule;
end;

class function CoRDORuleActions.Create: IRDORuleActions;
begin
  Result := CreateComObject(CLASS_RDORuleActions) as IRDORuleActions;
end;

class function CoRDORuleActions.CreateRemote(const MachineName: string): IRDORuleActions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActions) as IRDORuleActions;
end;

class function CoRDORuleConditions.Create: IRDORuleConditions;
begin
  Result := CreateComObject(CLASS_RDORuleConditions) as IRDORuleConditions;
end;

class function CoRDORuleConditions.CreateRemote(const MachineName: string): IRDORuleConditions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditions) as IRDORuleConditions;
end;

class function CoRDORuleAction.Create: IRDORuleAction;
begin
  Result := CreateComObject(CLASS_RDORuleAction) as IRDORuleAction;
end;

class function CoRDORuleAction.CreateRemote(const MachineName: string): IRDORuleAction;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleAction) as IRDORuleAction;
end;

class function CoRDORuleActionMoveorCopy.Create: IRDORuleActionMoveOrCopy;
begin
  Result := CreateComObject(CLASS_RDORuleActionMoveorCopy) as IRDORuleActionMoveOrCopy;
end;

class function CoRDORuleActionMoveorCopy.CreateRemote(const MachineName: string): IRDORuleActionMoveOrCopy;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionMoveorCopy) as IRDORuleActionMoveOrCopy;
end;

class function CoRDORuleActionSend.Create: IRDORuleActionSend;
begin
  Result := CreateComObject(CLASS_RDORuleActionSend) as IRDORuleActionSend;
end;

class function CoRDORuleActionSend.CreateRemote(const MachineName: string): IRDORuleActionSend;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionSend) as IRDORuleActionSend;
end;

class function CoRDORuleActionTemplate.Create: IRDORuleActionTemplate;
begin
  Result := CreateComObject(CLASS_RDORuleActionTemplate) as IRDORuleActionTemplate;
end;

class function CoRDORuleActionTemplate.CreateRemote(const MachineName: string): IRDORuleActionTemplate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionTemplate) as IRDORuleActionTemplate;
end;

class function CoRDORuleActionDefer.Create: IRDORuleActionDefer;
begin
  Result := CreateComObject(CLASS_RDORuleActionDefer) as IRDORuleActionDefer;
end;

class function CoRDORuleActionDefer.CreateRemote(const MachineName: string): IRDORuleActionDefer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionDefer) as IRDORuleActionDefer;
end;

class function CoRDORuleActionBounce.Create: IRDORuleActionBounce;
begin
  Result := CreateComObject(CLASS_RDORuleActionBounce) as IRDORuleActionBounce;
end;

class function CoRDORuleActionBounce.CreateRemote(const MachineName: string): IRDORuleActionBounce;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionBounce) as IRDORuleActionBounce;
end;

class function CoRDORuleActionSensitivity.Create: IRDORuleActionSensitivity;
begin
  Result := CreateComObject(CLASS_RDORuleActionSensitivity) as IRDORuleActionSensitivity;
end;

class function CoRDORuleActionSensitivity.CreateRemote(const MachineName: string): IRDORuleActionSensitivity;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionSensitivity) as IRDORuleActionSensitivity;
end;

class function CoRDORuleActionImportance.Create: IRDORuleActionImportance;
begin
  Result := CreateComObject(CLASS_RDORuleActionImportance) as IRDORuleActionImportance;
end;

class function CoRDORuleActionImportance.CreateRemote(const MachineName: string): IRDORuleActionImportance;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionImportance) as IRDORuleActionImportance;
end;

class function CoRDORuleActionAssignToCategory.Create: IRDORuleActionAssignToCategory;
begin
  Result := CreateComObject(CLASS_RDORuleActionAssignToCategory) as IRDORuleActionAssignToCategory;
end;

class function CoRDORuleActionAssignToCategory.CreateRemote(const MachineName: string): IRDORuleActionAssignToCategory;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionAssignToCategory) as IRDORuleActionAssignToCategory;
end;

class function CoRDORuleActionTag.Create: IRDORuleActionTag;
begin
  Result := CreateComObject(CLASS_RDORuleActionTag) as IRDORuleActionTag;
end;

class function CoRDORuleActionTag.CreateRemote(const MachineName: string): IRDORuleActionTag;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleActionTag) as IRDORuleActionTag;
end;

class function CoRDOActions.Create: IRDOActions;
begin
  Result := CreateComObject(CLASS_RDOActions) as IRDOActions;
end;

class function CoRDOActions.CreateRemote(const MachineName: string): IRDOActions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOActions) as IRDOActions;
end;

class function CoRDOAction.Create: IRDOAction;
begin
  Result := CreateComObject(CLASS_RDOAction) as IRDOAction;
end;

class function CoRDOAction.CreateRemote(const MachineName: string): IRDOAction;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAction) as IRDOAction;
end;

class function CoRDORuleCondition.Create: IRDORuleCondition;
begin
  Result := CreateComObject(CLASS_RDORuleCondition) as IRDORuleCondition;
end;

class function CoRDORuleCondition.CreateRemote(const MachineName: string): IRDORuleCondition;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleCondition) as IRDORuleCondition;
end;

class function CoRDORuleConditionImportance.Create: IRDORuleConditionImportance;
begin
  Result := CreateComObject(CLASS_RDORuleConditionImportance) as IRDORuleConditionImportance;
end;

class function CoRDORuleConditionImportance.CreateRemote(const MachineName: string): IRDORuleConditionImportance;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionImportance) as IRDORuleConditionImportance;
end;

class function CoRDORuleConditionText.Create: IRDORuleConditionText;
begin
  Result := CreateComObject(CLASS_RDORuleConditionText) as IRDORuleConditionText;
end;

class function CoRDORuleConditionText.CreateRemote(const MachineName: string): IRDORuleConditionText;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionText) as IRDORuleConditionText;
end;

class function CoRDORuleConditionCategory.Create: IRDORuleConditionCategory;
begin
  Result := CreateComObject(CLASS_RDORuleConditionCategory) as IRDORuleConditionCategory;
end;

class function CoRDORuleConditionCategory.CreateRemote(const MachineName: string): IRDORuleConditionCategory;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionCategory) as IRDORuleConditionCategory;
end;

class function CoRDORuleConditionFormName.Create: IRDORuleConditionFormName;
begin
  Result := CreateComObject(CLASS_RDORuleConditionFormName) as IRDORuleConditionFormName;
end;

class function CoRDORuleConditionFormName.CreateRemote(const MachineName: string): IRDORuleConditionFormName;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionFormName) as IRDORuleConditionFormName;
end;

class function CoRDORuleConditionToOrFrom.Create: IRDORuleConditionToOrFrom;
begin
  Result := CreateComObject(CLASS_RDORuleConditionToOrFrom) as IRDORuleConditionToOrFrom;
end;

class function CoRDORuleConditionToOrFrom.CreateRemote(const MachineName: string): IRDORuleConditionToOrFrom;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionToOrFrom) as IRDORuleConditionToOrFrom;
end;

class function CoRDORuleConditionAddress.Create: IRDORuleConditionAddress;
begin
  Result := CreateComObject(CLASS_RDORuleConditionAddress) as IRDORuleConditionAddress;
end;

class function CoRDORuleConditionAddress.CreateRemote(const MachineName: string): IRDORuleConditionAddress;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionAddress) as IRDORuleConditionAddress;
end;

class function CoRDORuleConditionSenderInAddressList.Create: IRDORuleConditionSenderInAddressList;
begin
  Result := CreateComObject(CLASS_RDORuleConditionSenderInAddressList) as IRDORuleConditionSenderInAddressList;
end;

class function CoRDORuleConditionSenderInAddressList.CreateRemote(const MachineName: string): IRDORuleConditionSenderInAddressList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDORuleConditionSenderInAddressList) as IRDORuleConditionSenderInAddressList;
end;

class function CoRestrictionComment.Create: IRestrictionComment;
begin
  Result := CreateComObject(CLASS_RestrictionComment) as IRestrictionComment;
end;

class function CoRestrictionComment.CreateRemote(const MachineName: string): IRestrictionComment;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RestrictionComment) as IRestrictionComment;
end;

class function CoPropValueList.Create: IPropValueList;
begin
  Result := CreateComObject(CLASS_PropValueList) as IPropValueList;
end;

class function CoPropValueList.CreateRemote(const MachineName: string): IPropValueList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PropValueList) as IPropValueList;
end;

class function CoPropValue.Create: IPropValue;
begin
  Result := CreateComObject(CLASS_PropValue) as IPropValue;
end;

class function CoPropValue.CreateRemote(const MachineName: string): IPropValue;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PropValue) as IPropValue;
end;

class function CoRDOAppointmentItem.Create: IRDOAppointmentItem;
begin
  Result := CreateComObject(CLASS_RDOAppointmentItem) as IRDOAppointmentItem;
end;

class function CoRDOAppointmentItem.CreateRemote(const MachineName: string): IRDOAppointmentItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOAppointmentItem) as IRDOAppointmentItem;
end;

class function CoRDOConflict.Create: IRDOConflict;
begin
  Result := CreateComObject(CLASS_RDOConflict) as IRDOConflict;
end;

class function CoRDOConflict.CreateRemote(const MachineName: string): IRDOConflict;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOConflict) as IRDOConflict;
end;

class function CoRDOConflicts.Create: IRDOConflicts;
begin
  Result := CreateComObject(CLASS_RDOConflicts) as IRDOConflicts;
end;

class function CoRDOConflicts.CreateRemote(const MachineName: string): IRDOConflicts;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOConflicts) as IRDOConflicts;
end;

class function CoRDOMeetingItem.Create: IRDOMeetingItem;
begin
  Result := CreateComObject(CLASS_RDOMeetingItem) as IRDOMeetingItem;
end;

class function CoRDOMeetingItem.CreateRemote(const MachineName: string): IRDOMeetingItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOMeetingItem) as IRDOMeetingItem;
end;

class function CoRDODeletedFolders.Create: IRDODeletedFolders;
begin
  Result := CreateComObject(CLASS_RDODeletedFolders) as IRDODeletedFolders;
end;

class function CoRDODeletedFolders.CreateRemote(const MachineName: string): IRDODeletedFolders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDODeletedFolders) as IRDODeletedFolders;
end;

class function CoRDOException.Create: IRDOException;
begin
  Result := CreateComObject(CLASS_RDOException) as IRDOException;
end;

class function CoRDOException.CreateRemote(const MachineName: string): IRDOException;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOException) as IRDOException;
end;

class function CoRDOExceptions.Create: IRDOExceptions;
begin
  Result := CreateComObject(CLASS_RDOExceptions) as IRDOExceptions;
end;

class function CoRDOExceptions.CreateRemote(const MachineName: string): IRDOExceptions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOExceptions) as IRDOExceptions;
end;

class function CoRDOJournalItem.Create: IRDOJournalItem;
begin
  Result := CreateComObject(CLASS_RDOJournalItem) as IRDOJournalItem;
end;

class function CoRDOJournalItem.CreateRemote(const MachineName: string): IRDOJournalItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOJournalItem) as IRDOJournalItem;
end;

class function CoRDOCalendarOptions.Create: IRDOCalendarOptions;
begin
  Result := CreateComObject(CLASS_RDOCalendarOptions) as IRDOCalendarOptions;
end;

class function CoRDOCalendarOptions.CreateRemote(const MachineName: string): IRDOCalendarOptions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOCalendarOptions) as IRDOCalendarOptions;
end;

class function CoRDOFreeBusyRange.Create: IRDOFreeBusyRange;
begin
  Result := CreateComObject(CLASS_RDOFreeBusyRange) as IRDOFreeBusyRange;
end;

class function CoRDOFreeBusyRange.CreateRemote(const MachineName: string): IRDOFreeBusyRange;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFreeBusyRange) as IRDOFreeBusyRange;
end;

class function CoRDOFreeBusySlot.Create: IRDOFreeBusySlot;
begin
  Result := CreateComObject(CLASS_RDOFreeBusySlot) as IRDOFreeBusySlot;
end;

class function CoRDOFreeBusySlot.CreateRemote(const MachineName: string): IRDOFreeBusySlot;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RDOFreeBusySlot) as IRDOFreeBusySlot;
end;

procedure Register;
begin
  RegisterComponents(dtlServerPage, [T_BaseItem, TSafeContactItem, TSafeAppointmentItem, TSafeMailItem, 
    TSafeTaskItem, TSafeJournalItem, TSafeMeetingItem, TSafePostItem, TMAPIUtils, 
    TMAPIFolder, TSafeCurrentUser, TSafeTable, TSafeDistList, TAddressLists, 
    TMAPITable, TDeletedItems, TTableFilter, TNamedProperty, TPropList, 
    TSafeReportItem, TSafeInspector, TPlainTextEditor, TRTFEditor, TTextAttributes, 
    TFontStyle, TConsistentAttributes, TParagraphAttributes, TRDOSession]);
end;

end.
