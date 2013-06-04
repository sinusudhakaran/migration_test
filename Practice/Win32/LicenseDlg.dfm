object DlgLicense: TDlgLicense
  Left = 367
  Top = 332
  BorderStyle = bsDialog
  Caption = 'Licence Agreement'
  ClientHeight = 317
  ClientWidth = 549
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lRead: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 6
    Width = 517
    Height = 42
    Margins.Left = 16
    Margins.Top = 6
    Margins.Right = 16
    Align = alTop
    AutoSize = False
    Caption = 
      'Please read the following Licence Agreement. Use the scroll bar ' +
      'or press the Page Down key to view the rest of the agreement.'
    WordWrap = True
    ExplicitTop = 8
    ExplicitWidth = 505
  end
  object lAccept: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 229
    Width = 517
    Height = 41
    Margins.Left = 16
    Margins.Right = 16
    Margins.Bottom = 6
    Align = alBottom
    AutoSize = False
    Caption = 
      'Do you accept all the terms of the preceding Licence Agreement? ' +
      'If you choose No, you will not be able to login. To use BankLink' +
      ' Practice you must accept this agreement.'
    WordWrap = True
    ExplicitTop = 224
    ExplicitWidth = 509
  end
  object mmoEULA: TMemo
    AlignWithMargins = True
    Left = 16
    Top = 54
    Width = 517
    Height = 169
    Margins.Left = 16
    Margins.Right = 16
    Align = alClient
    Lines.Strings = (
      
        'Software End-User Licence Agreement for Media Transfer Services ' +
        'Limited and '
      'Media Transfer Services UK Limited'
      ''
      
        'IMPORTANT NOTICE PLEASE READ CAREFULLY BEFORE INSTALLING OR USIN' +
        'G THE SOFTWARE:'
      ''
      ''
      '1'#9'Agreement'
      ''
      
        '1.1'#9'This Software End-User Licence Agreement ('#39'Agreement'#39') is be' +
        'tween'
      #9'you and BankLink.'
      ''
      
        '1.2'#9'If you acquired this software in the United Kingdom, Austral' +
        'ia or'
      
        '        '#9'New Zealand, '#39'BankLink'#39' means Media Transfer Services L' +
        'imited.'
      ''
      
        '1.3'#9'This computer software, together with any supporting documen' +
        'tation'
      '        '#9'and any modifications or amendments made by BankLink'
      
        '        '#9'('#8216'the Software'#8217'), is owned by Media Transfer Services L' +
        'imited and'
      
        '        '#9'may be sub-licensed by Media Transfer Services UK Limit' +
        'ed.'
      
        '        '#9'Provided your copy of the Software has been lawfully ob' +
        'tained, and'
      
        '        '#9'in relation to InvoicePlus and PayablesPlus, provided y' +
        'ou are a'
      
        '        '#9'registered user of BankLink'#39's services, you are authori' +
        'sed to use'
      '        '#9'the Software in accordance with this Agreement.'
      ''
      '1.4'#9'By proceeding to install, store, load, execute and display'
      
        '        '#9'(individually or collectively, '#8216'Use'#8217') the Software, you' +
        ' agree to'
      
        '        '#9'be bound by the terms of this Agreement. If your copy o' +
        'f the'
      
        '        '#9'Software has not been legally obtained or you do not ag' +
        'ree to the'
      
        '        '#9'terms of this Agreement, BankLink is not willing to lic' +
        'ence the'
      '        '#9'Software to you and you must not Use the Software.'
      ''
      ''
      ''
      '2'#9'Grant of licence'
      ''
      
        '2.1'#9'In consideration of you agreeing to abide by the terms of th' +
        'is'
      '        '#9'Agreement BankLink hereby grants you a non-exclusive,'
      
        '        '#9'non-transferable licence to Use the Software in accorda' +
        'nce with'
      '        '#9'this Agreement.'
      ''
      
        '2.2'#9'The licence is perpetual unless terminated in accordance wit' +
        'h'
      '        '#9'clause 7.'
      ''
      
        '2.3'#9'With regard to the InvoicePlus and PayablesPlus products, yo' +
        'u may'
      '        '#9'Use one copy of the Software on a single computer.'
      ''
      ''
      ''
      '3'#9'Limitations on Use'
      ''
      '3.1'#9'The Software licence is personal to you; you cannot sell,'
      
        '        '#9'sub-licence, assign, transfer, charge, lend the Softwar' +
        'e to any'
      
        '        '#9'other person or entity or otherwise dispose of the righ' +
        'ts or'
      
        '        '#9'obligations under this Agreement without the written co' +
        'nsent of'
      '        '#9'BankLink.'
      ''
      
        '3.2'#9'You cannot copy, alter, modify or reproduce the Software, bu' +
        't you'
      
        '        '#9'may make one copy of the Software for backup purposes o' +
        'nly.'
      
        '        '#9'Except as otherwise permitted at law, you cannot revers' +
        'e assemble'
      
        '        '#9'or reverse compile or directly or indirectly allow or c' +
        'ause a'
      
        '        '#9'third party to reverse assemble or reverse compile the ' +
        'whole or'
      '        '#9'any part of the Software.'
      ' '
      
        '3.3'#9'BankLink may sell, sub-licence, assign, transfer, charge or ' +
        'lend'
      
        '        '#9'the Software to any other person or entity or otherwise' +
        ' dispose of'
      
        '        '#9'the rights or obligations under this Agreement at any t' +
        'ime without'
      '        '#9'your consent.'
      ''
      ''
      ''
      '4'#9'Title'
      ''
      
        '4.1'#9'All title and intellectual property rights in the Software r' +
        'emain'
      
        '        '#9'with BankLink (or its Licensors). You acknowledge that ' +
        'rights in'
      
        '        '#9'the Software are licensed (not sold) to you, and that y' +
        'ou have no'
      
        '        '#9'rights in, or to, the Software other than the right to ' +
        'Use the'
      
        '        '#9'Software in accordance with the terms of this Agreement' +
        '. You'
      
        '        '#9'acknowledge that you have no right to have access to th' +
        'e Software'
      
        '        '#9'in source code form or in unlocked coding or with comme' +
        'nts.'
      ''
      '4.2'#9'You will notify BankLink as soon as you become aware of any'
      
        '        '#9'infringement, suspected infringement or alleged infring' +
        'ement of'
      
        '        '#9'BankLink'#8217's intellectual property rights in the Software' +
        '.'
      ''
      ''
      ''
      '5'#9'Warranties'
      ''
      
        '5.1'#9'Except as otherwise agreed, BankLink is not obliged to suppo' +
        'rt the'
      
        '        '#9'Software, whether by providing advice, training, error-' +
        'correction,'
      
        '        '#9'modification, new releases or enhancements or otherwise' +
        '.'
      ''
      
        '5.2'#9'If you acquired this Software in the UK, to the extent permi' +
        'tted'
      
        '        '#9'by law, BankLink excludes and disclaims all and any gua' +
        'rantees'
      
        '        '#9'and/or warranties whether express, implied, statutory o' +
        'r otherwise'
      
        '        '#9'in respect of the Software and in particular, to the ex' +
        'tent that'
      
        '        '#9'they are applicable, expressly excludes the provisions ' +
        'of the Sale'
      
        '        '#9'of Goods Act 1979 and the Supply of Goods and Services ' +
        'Act 1982.'
      ''
      '5.3'#9'If you acquired this Software in New Zealand, to the extent'
      
        '        '#9'permitted by law, BankLink excludes and disclaims all a' +
        'nd any'
      
        '        '#9'guarantees and/or warranties whether express, implied, ' +
        'statutory'
      
        '        '#9'or otherwise in respect of the Software and in particul' +
        'ar, to the'
      
        '        '#9'extent that they are applicable, expressly excludes the' +
        ' provisions'
      
        '        '#9'of the New Zealand Consumer Guarantees Act 1993 pursuan' +
        't to clause'
      
        '        '#9'43(2) thereof and the provisions of the New Zealand Sal' +
        'e of Goods'
      
        '        '#9'Act 1908 pursuant to clause 56 thereof. You confirm tha' +
        't you have'
      '        '#9'acquired the Software for business purposes.'
      ''
      '5.4'#9'If you acquired this Software in Australia, to the extent'
      
        '        '#9'permitted by law, BankLink excludes and disclaims all a' +
        'nd any'
      
        '        '#9'guarantees and/or warranties whether express, implied, ' +
        'statutory'
      
        '        '#9'or otherwise in respect of the Software, except for any' +
        ' condition,'
      
        '        '#9'warranty, guarantee right or remedy under a mandatory l' +
        'aw. Nothing'
      
        '        '#9'in this clause 5 excludes, restricts or modifies any co' +
        'ndition,'
      
        '        '#9'warranty, guarantee, right or remedy under a mandatory ' +
        'law.'
      ''
      
        '5.5'#9'You acknowledge that BankLink does not warrant or promise th' +
        'at the'
      
        '        '#9'Software will meet your requirements and that you have ' +
        'solely'
      
        '        '#9'exercised and relied upon your own skill and judgment i' +
        'n'
      '        '#9'determining whether the Software meets your particular'
      '        '#9'requirements, and have not relied on any statement or'
      '        '#9'representation by or on behalf of BankLink (unless made'
      '        '#9'fraudulently).'
      ''
      '5.6'#9'BankLink is providing this Software to you "AS IS" and you'
      
        '        '#9'acknowledge that risk of loss or of damage to your comp' +
        'uter system'
      '        '#9'or data at all times remains with you.'
      ' '
      '5.7'#9'BankLink does not warrant that:'
      ''
      
        '        '#9'5.7.1'#9'Any of the data provided by or on behalf of BankL' +
        'ink and '
      #9#9'received by you for use with the Software will be accurate '
      #9#9'or virus free;'
      ''
      
        '        '#9'5.7.2'#9'The Software will operate without interruption or' +
        ' errors; or'
      ''
      
        '        '#9'5.7.3'#9'That the Software will not affect the operation o' +
        'f other '
      #9#9'installed applications.'
      ''
      ''
      ''
      '6'#9'Liability'
      ''
      
        '6.1'#9'If you acquired this Software in the UK, then subject only t' +
        'o'
      
        '        '#9'BankLink'#39's liability for death or personal injury resul' +
        'ting from'
      
        '        '#9'BankLink'#39's negligence, fraud or fraudulent misrepresent' +
        'ation (for'
      '        '#9'which there shall be no limitation or exclusions):'
      ''
      
        '        '#9'6.1.1'#9'Except as otherwise set out in this agreement, Ba' +
        'nkLink'
      
        '                '#9'will not be liable to you for any loss or damag' +
        'e of any kind'
      
        '                '#9'arising out of or in connection with this agree' +
        'ment whether'
      
        '                '#9'arising in contract, tort (including negligence' +
        '),'
      
        '                '#9'misrepresentation or otherwise, including, with' +
        'out limitation,:'
      ''
      
        '                '#9'(a)'#9'any indirect or consequential loss or damag' +
        'e of '
      #9#9#9'any kind; or'
      ''
      
        '                '#9'(b)'#9'any loss of income, loss of profits, loss o' +
        'f'
      #9#9#9'savings, loss of goodwill, loss of contracts,'
      #9#9#9'business interruption, cost of cover or loss of'
      #9#9#9'data arising from your use of or inability to use'
      #9#9#9'the Software or from errors or deficiencies in the'
      #9#9#9'Software.'
      ''
      #9'This limitation will apply even if BankLink has been advised of'
      '        '#9'the possibility of such damages.'
      ''
      
        '        '#9'6.1.2'#9'The liability of BankLink for any loss arising as' +
        ' a result'
      
        '                '#9'of or in relation to the supply by BankLink of ' +
        'the'
      
        '                '#9'Software, including any economic or consequenti' +
        'al loss'
      
        '                '#9'which may be sustained or incurred, shall be li' +
        'mited to'
      '                '#9'(at BankLink'#39's option):'
      ''
      
        '                '#9'(a)'#9'The replacement of the Software or the supp' +
        'ly of'
      #9#9#9'equivalent Software;'
      ''
      '                '#9'(b)'#9'The repair of the Software;'
      ''
      
        '                '#9'(c)'#9'The payment of the cost of replacing the So' +
        'ftware'
      #9#9#9'or acquiring equivalent Software; or'
      ''
      
        '                '#9'(d)'#9'The payment of the cost of having the Softw' +
        'are'
      #9#9#9'replaced.'
      ''
      
        '        '#9'6.1.3'#9'Nothing in this Agreement shall limit or exclude ' +
        'the'
      
        '                '#9'liability of BankLink for death or personal inj' +
        'ury'
      
        '                '#9'resulting from BankLink'#39's negligence, fraud or ' +
        'fraudulent'
      '                '#9'misrepresentation.'
      ''
      '6.2'#9'If you acquired this Software in Australia or New Zealand,'
      
        '        '#9'BankLink will not be liable to you for any loss or dama' +
        'ge'
      
        '        '#9'(including, without limitation, consequential loss or d' +
        'amage)'
      
        '        '#9'suffered by you whether arising directly or indirectly ' +
        'from the'
      
        '        '#9'Use of the Software or any data provided by or on behal' +
        'f of'
      
        '        '#9'BankLink under this Agreement or from any failure or om' +
        'ission on'
      '        '#9'the part of BankLink or otherwise.'
      ' '
      
        '6.3'#9'In no event will BankLink be liable for any remote, indirect' +
        ','
      
        '        '#9'consequential, punitive, special or incidental damages,' +
        ' including'
      
        '        '#9'without limitation, damages resulting from loss of any ' +
        'data, loss'
      
        '        '#9'of income or profits or business interruption, or cost ' +
        'of cover'
      
        '        '#9'whether based in contract, tort (including negligence),' +
        ' at law, in'
      
        '        '#9'equity, under statute or otherwise. This limitation wil' +
        'l apply'
      
        '        '#9'even if BankLink has been advised of the possibility of' +
        ' such'
      '        '#9'damages.'
      ''
      
        '6.4'#9'Where the Australian mandatory consumer protection legislati' +
        'on'
      
        '        '#9'applies, then the liability of BankLink for any loss ar' +
        'ising as a'
      
        '        '#9'result of or in relation to the supply by BankLink of t' +
        'he'
      
        '        '#9'Software, including any economic or consequential loss ' +
        'which may'
      '        '#9'be sustained or incurred, shall be limited to:'
      ''
      '        '#9'6.4.1'#9'The replacement of the Software or the supply of'
      '                '#9'equivalent Software;'
      ''
      '        '#9'6.4.2'#9'The repair of the Software;'
      ''
      
        '        '#9'6.4.3'#9'The payment of the cost of repairing or replacing' +
        ' the'
      '                '#9'Software or acquiring equivalent Software;'
      ''
      
        '        '#9'6.4.4'#9'The payment of the cost of having the Software re' +
        'placed;'
      ''
      
        '        '#9'6.4.5'#9'The payment for the reduction in value of the Sof' +
        'tware; or'
      
        '        '#9'6.4.6'#9'The cost of the refund of the Software license fe' +
        'e, if'
      
        '                '#9'any, paid by you. However, nothing in this clau' +
        'se 6'
      
        '                '#9'excludes, restricts or modifies any condition, ' +
        'warranty,'
      
        '                '#9'guarantee, right or remedy under a mandatory la' +
        'w.'
      ''
      ''
      ''
      '7'#9'Termination'
      ''
      
        '7.1'#9'Without prejudice to any other rights, BankLink may terminat' +
        'e this'
      
        '        '#9'Agreement by written notice to you with immediate effec' +
        't if you'
      
        '        '#9'fail to comply with the terms and conditions of this Ag' +
        'reement or'
      
        '        '#9'if you become bankrupt or insolvent (or suffer any simi' +
        'lar'
      '        '#9'circumstances anywhere in the world).'
      ''
      '7.2'#9'Upon termination for any reason:'
      ''
      
        '        '#9'7.2.1'#9'All rights granted to you under this Agreement sh' +
        'all'
      '                '#9'cease;'
      ''
      
        '        '#9'7.2.2'#9'You must cease all Use of the Software and any ot' +
        'her'
      '                '#9'activities authorised by this Agreement; and'
      ''
      
        '        '#9'7.2.3'#9'You must immediately uninstall the Software and d' +
        'estroy'
      
        '                '#9'all copies of the Software in your possession a' +
        'nd all its'
      '                '#9'component parts.'
      ''
      ''
      ''
      '8'#9'Miscellaneous'
      ''
      'Entire Agreement'
      ''
      
        '8.1'#9'This Agreement contains everything the parties have agreed i' +
        'n'
      
        '        '#9'relation to the subject matter it deals with. No party ' +
        'can rely on'
      
        '        '#9'an earlier written document or anything said or done by' +
        ' or on'
      
        '        '#9'behalf of another party before this agreement was execu' +
        'ted.'
      ' '
      'Variation'
      ''
      
        '8.2'#9'No variation of this agreement will be of any force or effec' +
        't'
      
        '        '#9'unless it is in writing and signed by each party to thi' +
        's'
      '        '#9'agreement.'
      ''
      'Privity of contract'
      ''
      
        '8.3'#9'A party who is not you or BankLink shall have no right to en' +
        'force'
      
        '        '#9'any term under this Agreement whether under the Contrac' +
        'ts (Rights'
      
        '        '#9'of Third Parties) Act 1999 (if you acquired this Softwa' +
        're in the'
      
        '        '#9'UK), the Contracts (Privity) Act 1982 (if you acquired ' +
        'this'
      
        '        '#9'Software in New Zealand) or any other local Act or prov' +
        'ision. This'
      
        '        '#9'clause does not affect any right or remedy of any perso' +
        'n which'
      
        '        '#9'exists, or is available, other than pursuant to the rel' +
        'evant Act.'
      ''
      'Governing law'
      ''
      
        '8.4'#9'If you acquired this Software in the UK, this Agreement and ' +
        'any'
      
        '        '#9'dispute or non- contractual obligation arising out of o' +
        'r in'
      
        '        '#9'connection with it shall be governed by and construed i' +
        'n'
      
        '        '#9'accordance with the law of England, and each party here' +
        'by submits'
      
        '        '#9'to the exclusive jurisdiction of the courts of England ' +
        'over any'
      
        '        '#9'dispute arising out of or in connection with this Agree' +
        'ment.'
      ''
      
        '8.5'#9'If you acquired this Software in Australia, this Agreement a' +
        'nd any'
      
        '        '#9'dispute or non- contractual obligation arising out of o' +
        'r in'
      
        '        '#9'connection with it shall be governed by and construed i' +
        'n'
      
        '        '#9'accordance with the laws of New South Wales, and each p' +
        'arty hereby'
      
        '        '#9'submits to the exclusive jurisdiction of the courts of ' +
        'New South'
      
        '        '#9'Wales over any dispute arising out of or in connection ' +
        'with this'
      '        '#9'Agreement.'
      ''
      
        '8.6'#9'If you acquired this Software in New Zealand, this Agreement' +
        ' and'
      
        '        '#9'any dispute or non- contractual obligation arising out ' +
        'of or in'
      
        '        '#9'connection with it shall be governed by and construed i' +
        'n'
      
        '        '#9'accordance with the laws of New Zealand, and each party' +
        ' hereby'
      
        '        '#9'submits to the exclusive jurisdiction of the courts of ' +
        'New Zealand'
      
        '        '#9'over any dispute arising out of or in connection with t' +
        'his'
      '        '#9'Agreement.'
      ''
      ''
      ''
      '9'#9'Collection of Usage Information'
      ''
      
        '        '#9'You agree that BankLink shall have the right to use, co' +
        'py, store,'
      
        '        '#9'transfer, transmit, display and analyse any electronic ' +
        'data,'
      
        '        '#9'information or material, including the menus you select' +
        ', the'
      
        '        '#9'number of times each menu is selected and the number of' +
        ' client'
      
        '        '#9'files involved, which is sourced by or through Use of t' +
        'he'
      '        '#9'Software.'
      ''
      
        '        '#9'You also agree that BankLink may collect, store, use an' +
        'd disclose'
      
        '        '#9'personal data (including personal data/information of y' +
        'ou/your'
      
        '        '#9'clients) provided by you to BankLink (including, withou' +
        't'
      
        '        '#9'limitation your/your client'#39's name and user code). Bank' +
        'Link will'
      
        '        '#9'protect the information collected against unauthorised ' +
        'access, use'
      
        '        '#9'and disclosure and shall handle the same only in accord' +
        'ance with'
      
        '        '#9'BankLink'#39's privacy policy and by use of the Software yo' +
        'u consent'
      
        '        '#9'to the collection, storage, use and disclosure of perso' +
        'nal'
      
        '        '#9'information as set out in the relevant Privacy Policy. ' +
        'BankLink'#39's'
      '        '#9'privacy policy for New Zealand can be viewed at'
      
        '        '#9'http://www.banklink.co.nz/docs/privacy.pdf or for Austr' +
        'alia at'
      
        '        '#9'http://www.banklink.com.au/docs/privacy.pdf or for the ' +
        'United'
      '        '#9'Kingdom at'
      
        '        '#9'http://www.banklink.co.uk/docs/BankLink_UK_Privacy_Poli' +
        'cy.pdf.'
      ''
      
        '        '#9'You warrant that you will not provide any personal info' +
        'rmation of'
      '        '#9'your clients to BankLink unless you:'
      
        '        '#9'(a)'#9'have the prior consent of those clients to the disc' +
        'losure;'
      '                '#9'and'
      
        '        '#9'(b)'#9'have provided the clients with a copy of the releva' +
        'nt'
      
        '                '#9'BankLink Privacy Policy and that they have acce' +
        'pted and'
      
        '                '#9'consented to the collection, storage, use and d' +
        'isclosure'
      
        '                '#9'of personal information as set out in the relev' +
        'ant'
      '                '#9'Privacy Policy.'
      ''
      
        '        '#9'You acknowledge, agree and further warrant that you wil' +
        'l collect,'
      
        '        '#9'store, use and disclose the personal information of any' +
        ' individual'
      
        '        '#9'that may be provided to you by BankLink in accordance w' +
        'ith the'
      
        '        '#9'BankLink Privacy Policy that is relevant to your jurisd' +
        'iction. '
      ''
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object mmoBankstream: TMemo
    AlignWithMargins = True
    Left = 16
    Top = 54
    Width = 517
    Height = 169
    Margins.Left = 16
    Margins.Right = 16
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'Software End-User Licence Agreement for MTS Global Limited and '
      'Media Transfer Services UK Limited'
      ''
      
        'IMPORTANT NOTICE PLEASE READ CAREFULLY BEFORE INSTALLING OR USIN' +
        'G'
      'THE SOFTWARE:'
      ''
      '1        Agreement'
      ''
      
        '1.1     This Software End-User Licence Agreement ('#39'Agreement'#39') i' +
        's between you and'
      '          MTS Global Limited ('#39'Bankstream'#39').'
      ''
      
        '1.2     This computer software, together with any supporting doc' +
        'umentation and any'
      
        '          modifications or amendments made by Bankstream ('#8216'the S' +
        'oftware'#8217'), is'
      
        '          licenced to Bankstream and may be sub-licensed by Bank' +
        'stream.  Provided'
      
        '          your copy of the Software has been lawfully obtained a' +
        'nd, in relation to'
      
        '          [InvoicePlus and PayablesPlus], provided you are a reg' +
        'istered user of'
      
        '          Bankstream'#39's services, you are authorised to use the S' +
        'oftware in'
      '          accordance with this Agreement.'
      ''
      
        '1.3     By proceeding to install, store, load, execute and displ' +
        'ay (individually'
      
        '          or collectively, '#8216'Use'#8217') the Software, you agree to be ' +
        'bound by the terms'
      
        '          of this Agreement.  If your copy of the Software has n' +
        'ot been legally'
      
        '          obtained or you do not agree to the terms of this Agre' +
        'ement, Bankstream is'
      
        '          not willing to licence the Software to you and you mus' +
        't not Use the Software.'
      ''
      ''
      '2        Grant of licence'
      ''
      
        '2.1     In consideration of you agreeing to abide by the terms o' +
        'f this Agreement'
      
        '          Bankstream hereby grants you a non-exclusive, non-tran' +
        'sferable licence to'
      '          Use the Software in accordance with this Agreement.'
      ''
      
        '2.2     The licence is perpetual unless terminated in accordance' +
        ' with clause 7.'
      ''
      
        '2.3     With regard to the [InvoicePlus and PayablesPlus] produc' +
        'ts, you may Use one'
      '          copy of the Software on a single computer.'
      ''
      ''
      '3        Limitations on Use'
      ''
      
        '3.1     The Software licence is personal to you; you cannot sell' +
        ', sub-licence,'
      
        '          assign, transfer, charge, lend the Software to any oth' +
        'er person or entity'
      
        '          or otherwise dispose of the rights or obligations unde' +
        'r this Agreement'
      '          without the written consent of Bankstream.'
      ''
      
        '3.2     You cannot copy, alter, modify or reproduce the Software' +
        ', but you may make'
      
        '          one copy of the Software for backup purposes only.  Ex' +
        'cept as otherwise'
      
        '          permitted at law, you cannot reverse assemble or rever' +
        'se compile or'
      
        '          directly or indirectly allow or cause a third party to' +
        ' reverse assemble or'
      '          reverse compile the whole or any part of the Software.'
      '        '
      
        '3.3     Bankstream may sell, sub-licence, assign, transfer, char' +
        'ge or lend the'
      
        '          Software to any other person or entity or otherwise di' +
        'spose of the rights'
      
        '          or obligations under this Agreement at any time withou' +
        't your consent.'
      ''
      ''
      '4        Intellectual Property Rights'
      ''
      
        '4.1     All intellectual property rights in the Software remain ' +
        'with Bankstream'
      
        '          (or its Licensors).  You acknowledge that rights in th' +
        'e Software are'
      
        '          licensed (not sold) to you, and that you have no right' +
        's in, or to, the'
      
        '          Software other than the right to use the Software in a' +
        'ccordance with the'
      
        '          terms of this Agreement. You acknowledge that you have' +
        ' no right to have'
      
        '          access to the Software in source code form or in unloc' +
        'ked coding or with'
      '          comments.'
      '        '
      
        '4.2     You will notify Bankstream as soon as you become aware o' +
        'f any infringement,'
      
        '          suspected infringement or alleged infringement of Bank' +
        'stream'#8217's intellectual'
      '          property rights in the Software.'
      ''
      ''
      '5        Warranties'
      ''
      
        '5.1     Except as otherwise agreed, Bankstream is not obliged to' +
        ' support the'
      
        '          Software, whether by providing advice, training, error' +
        '-correction,'
      
        '          modification, new releases or enhancements or otherwis' +
        'e.'
      '        '
      
        '5.2     To the extent permitted by law, Bankstream excludes and ' +
        'disclaims all and'
      
        '          any guarantees and/or warranties whether express, impl' +
        'ied, statutory or'
      
        '          otherwise in respect of the Software and in particular' +
        ', to the extent that'
      
        '          they are applicable, expressly excludes the provisions' +
        ' of the Sale of'
      
        '          Goods Act 1979 and the Supply of Goods and Services Ac' +
        't 1982.'
      ''
      
        '5.3     You acknowledge that Bankstream does not warrant or prom' +
        'ise that the'
      
        '          Software will meet your requirements and that you have' +
        ' solely exercised'
      
        '          and relied upon your own skill and judgment in determi' +
        'ning whether the'
      
        '          Software meets your particular requirements, and have ' +
        'not relied on any'
      
        '          statement or representation by or on behalf of Bankstr' +
        'eam (unless made'
      '          fraudulently).'
      ''
      
        '5.4     Bankstream is providing this Software to you "AS IS" and' +
        ' you acknowledge'
      
        '          that risk of loss or of damage to your computer system' +
        ' or data at all times'
      '          remains with you.'
      '        '
      '5.5     Bankstream does not warrant that:'
      ''
      
        '          5.5.1     Any of the data provided by or on behalf of ' +
        'Bankstream and received'
      
        '                       by you for use with the Software will be ' +
        'accurate or virus free;'
      ''
      
        '          5.5.2     The Software will operate without interrupti' +
        'on or errors; or'
      ''
      
        '          5.5.3     That the Software will not affect the operat' +
        'ion of other installed'
      '                       applications.'
      ''
      ''
      '6        Liability'
      ''
      
        '6.1     Subject only to Bankstream'#39's liability for death or pers' +
        'onal injury'
      
        '          resulting from Bankstream'#39's negligence, fraud or fraud' +
        'ulent'
      
        '          misrepresentation (for which there shall be no limitat' +
        'ion or exclusions):'
      ''
      
        '          6.1.1     Except as otherwise set out in this agreemen' +
        't, Bankstream will not'
      
        '                       be liable to you for any loss or damage o' +
        'f any kind arising out of'
      
        '                       or in connection with this agreement whet' +
        'her arising in contract,'
      
        '                       tort (including negligence), misrepresent' +
        'ation or otherwise,'
      '                       including, without limitation:'
      ' '
      
        '                       (a)     any indirect or consequential los' +
        's or damage of any kind; or'
      ' '
      
        '                       (b)     any loss of income, loss of profi' +
        'ts, loss of savings, loss'
      
        '                                of goodwill, loss of contracts, ' +
        'business interruption, cost'
      
        '                                of cover or loss of data arising' +
        ' from your use of or'
      
        '                                inability to use the Software or' +
        ' from errors or'
      '                                deficiencies in the Software.'
      '                        '
      
        '          6.1.2     This limitation will apply even if Bankstrea' +
        'm has been advised of'
      '                       the possibility of such damages.'
      ''
      
        '          6.1.3     The liability of Bankstream for any loss ari' +
        'sing as a result of or'
      
        '                       in relation to the supply by Bankstream o' +
        'f the Software, including'
      
        '                       any economic or consequential loss which ' +
        'may be sustained or'
      
        '                       incurred, shall be limited to (at Bankstr' +
        'eam'#39's option):'
      ''
      
        '                       (a)     The replacement of the Software o' +
        'r the supply of equivalent'
      '                                Software;'
      ''
      '                       (b)     The repair of the Software;'
      ''
      
        '                       (c)     The payment of the cost of replac' +
        'ing the Software or'
      
        '                                acquiring equivalent Software; o' +
        'r'
      '                         '
      
        '                       (d)     The payment of the cost of having' +
        ' the Software replaced.'
      '                '
      
        '          6.1.4     Nothing in this Agreement shall limit or exc' +
        'lude the liability of'
      
        '                       Bankstream for death or personal injury r' +
        'esulting from Bankstream'#39's'
      
        '                       negligence, fraud or fraudulent misrepres' +
        'entation.'
      ''
      ''
      '7        Termination'
      ''
      
        '7.1     Without prejudice to any other rights, Bankstream may te' +
        'rminate this'
      
        '          Agreement by written notice to you with immediate effe' +
        'ct if you fail to'
      
        '          comply with the terms and conditions of this Agreement' +
        ' or if you become'
      
        '          bankrupt or insolvent (or suffer any similar circumsta' +
        'nces anywhere in the'
      '          world).'
      '        '
      '7.2     Upon termination for any reason:'
      ''
      
        '          7.2.1     All rights granted to you under this Agreeme' +
        'nt shall cease;'
      ''
      
        '          7.2.2     You must cease all Use of the Software and a' +
        'ny other activities'
      '                       authorised by this Agreement; and'
      ''
      
        '          7.2.3     You must immediately uninstall the Software ' +
        'and destroy all copies'
      
        '                       of the Software in your possession and al' +
        'l its component parts.'
      ''
      ''
      '8        Miscellaneous'
      ''
      'Entire Agreement'
      ''
      
        '8.1     This Agreement contains everything the parties have agre' +
        'ed in relation to'
      
        '          the subject matter it deals with.  No party can rely o' +
        'n an earlier written'
      
        '          document or anything said or done by or on behalf of a' +
        'nother party before'
      '          this agreement was executed.'
      ''
      'Variation'
      ''
      
        '8.2     No variation of this agreement will be of any force or e' +
        'ffect unless it is'
      '          in writing and signed by each party to this agreement.'
      ''
      'Privity of contract'
      ''
      
        '8.3     A party who is not you or Bankstream shall have no right' +
        ' to enforce any'
      '          term under this Agreement whether under the Contracts'
      
        '          (Rights of Third Parties) Act 1999 or any other local ' +
        'Act or provision.'
      
        '          This clause does not affect any right or remedy of any' +
        ' person which exists,'
      
        '          or is available, other than pursuant to the relevant A' +
        'ct.'
      ''
      'Governing law'
      ''
      
        '8.4     If you acquired this Software in the UK, this Agreement ' +
        'and any dispute or'
      
        '          non-contractual obligation arising out of or in connec' +
        'tion with it shall be'
      
        '          governed by and construed in accordance with the law o' +
        'f England, and each'
      
        '          party hereby submits to the exclusive jurisdiction of ' +
        'the courts of England'
      
        '          over any dispute arising out of or in connection with ' +
        'this Agreement.'
      ''
      ''
      '9        Collection of Usage Information'
      ''
      
        '9.1     You agree that Bankstream shall have the right to use, c' +
        'opy, store,'
      
        '          transfer, transmit, display and analyse any electronic' +
        ' data, information'
      
        '          or material, including the menus you select, the numbe' +
        'r of times each menu'
      
        '          is selected and the number of client files involved, w' +
        'hich is sourced by or'
      '          through Use of the Software.'
      '        '
      
        '9.2     You also agree that Bankstream may record personal data ' +
        'provided by you to'
      
        '          Bankstream (including, without limitation your name an' +
        'd user code).'
      
        '          Bankstream will protect the information collected agai' +
        'nst unauthorised'
      
        '          access, use and disclosure and shall process the same ' +
        'only in accordance'
      
        '          with Bankstream'#39's privacy policy.  Bankstream'#39's privac' +
        'y policy can be'
      '          viewed at www.bankstream.co.uk')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
    WordWrap = False
  end
  object pBtn: TPanel
    Left = 0
    Top = 276
    Width = 549
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnNo: TButton
      Left = 458
      Top = 10
      Width = 75
      Height = 25
      Caption = '&No'
      ModalResult = 7
      TabOrder = 0
    end
    object btnYes: TButton
      Left = 370
      Top = 10
      Width = 75
      Height = 25
      Caption = '&Yes'
      ModalResult = 6
      TabOrder = 1
    end
  end
end
