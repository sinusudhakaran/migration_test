// Include File: HPPFIX.INC
// USED BY UNIT WPRTEDEFS

  TWPNeedRepaintParLin = packed record
    par: TParagraph;
    lin: Integer;
  end;
  {$NODEFINE TWPNeedRepaintParLin}
  (*$HPPEMIT 'typedef struct { void *par;  int lin;} TWPNeedRepaintParLin;'*)

  TWPDroppedTextMarkers = packed record
    RTFDataBlock: TWPRTFDataBlock;
    PosInPar: Integer;
    ThePar: TParagraph;
  end;
  {$NODEFINE  TWPDroppedTextMarkers}
  (*$HPPEMIT 'typedef struct { void *RTFDataBlock; int PosInPar; void * ThePar; } TWPDroppedTextMarkers;'*)
