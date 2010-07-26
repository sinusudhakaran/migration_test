unit KOLE2Import;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$A8}{$Z4}

interface
uses Libc;
const
  libgnomeole2 = 'libgnomeole2.so.0';
  //Comment former line and uncomment following 2 lines for static link
  //{$L 'libgnomeole2.o'}
  //libgnomeole2='';

type
  mode_t = Longword;
  ssize_t = size_t;
  off_t = Longint;
  caddr_t = Longint;

  PPPChar= ^PPChar;

  gboolean= LongBool;
  gint32= Longint;
  guint32= LongWord;
  guint8 = byte;
  pguint8 = ^guint8;
  gint = integer;
  pgint = ^gint;

  TMsOleErr = (
	MS_OLE_ERR_OK,
	MS_OLE_ERR_EXIST,
	MS_OLE_ERR_INVALID,
	MS_OLE_ERR_FORMAT,
	MS_OLE_ERR_PERM,
	MS_OLE_ERR_MEM,
	MS_OLE_ERR_SPACE,
	MS_OLE_ERR_NOTEMPTY,
	MS_OLE_ERR_BADARG
  );

  TMsOleSeek = (
	MsOleSeekSet,
	MsOleSeekCur,
	MsOleSeekEnd
  );

  TMsOleType = (
	MsOleStorageT = 1,
	MsOleStreamT  = 2,
	MsOleRootT    = 5
  );

  TMsOlePos = guint32;
  TMsOleSPos = gint32;

  _MsOleSysWrappers = record
{	int     (*open2)	(const char *pathname, int flags);
	int     (*open3)	(const char *pathname, int flags, mode_t mode);
	ssize_t (*read)		(int fd, void *buf, size_t count);
	int     (*close)	(int fd);
	ssize_t (*write)	(int fd, const void *buf, size_t count);
	off_t   (*lseek)	(int fd, off_t offset, int whence);
	int     (*isregfile)	(int fd);
	int     (*getfilesize)	(int fd, guint32 *size);

	/* Optionaly implementable */
	void   *(*mmap)         (void *start, size_t length, int prot,
				 int flags, int fd, off_t offset);
	int     (*munmap)       (void *start, size_t length);
}  end;

  TMsOleSysWrappers = _MsOleSysWrappers;
  PMsOleSysWrappers = ^TMsOleSysWrappers;

// **
// * Structure describing an OLE file
// **
  PGArray= pointer;

  _MsOle = record
    ref_count: Longint;
    ole_mmap: gboolean;
    mem: ^guint8;
    length: guint32;
    syswrap: PMsOleSysWrappers;

    mode: char;
    file_des: integer;
    dirty: integer;
    bb: PGArray;      { Big  blocks status  }
    sb: PGArray;      { Small block status  }
    sbf: PGArray;     { The small block file }
    num_pps: guint32;  { Count of number of property sets }
    pps: pointer;     { Property Storage -> struct _PPS, always 1 valid entry or NULL }
    // if memory mapped
	bbattr: pointer;  { Pointers to block structures }
    // end if memory mapped
  end;


  _MsOleStat = record
    oleType: TMsOleType;
    size: TMsOlePos;
  end;

  TMsOle            = _MsOle;
  PMsOle           = ^TMsOle;
  PPMsOle          = ^PMsOle;
  TMsOleStat        = _MsOleStat;
  PMsOleStat       = ^TMsOleStat;

/////////////////////////////////////////////////// Methods ////////////////////
  function ms_ole_open (fs: PPMsOle; const path: PChar): TMsOleErr;
  function ms_ole_open_vfs (fs: PPMsOle; const path: PChar; try_mmap: gboolean; wrappers: PMsOleSysWrappers): TMsOleErr; cdecl; external libgnomeole2;

  function ms_ole_create (fs: PPMsOle; const path: PChar): TMsOleErr;
  function ms_ole_create_vfs (fs: PPMsOle; const path: PChar; try_mmap: gboolean; wrappers: PMsOleSysWrappers): TMsOleErr; cdecl; external libgnomeole2;

  procedure ms_ole_destroy (fs: PPMsOle); cdecl; external libgnomeole2;

  function ms_ole_unlink (fs: PMsOle; const path: PChar): TMsOleErr; cdecl; external libgnomeole2;
  function ms_ole_directory (names: PPPChar; fs: PMsOle; const dirpath: PChar): TMsOleErr; cdecl; external libgnomeole2;
  function ms_ole_stat (stat: PMsOleStat;fs: PMsOle; const dirpath: PChar; const name: PChar): TMsOleErr; cdecl; external libgnomeole2;


//////////////////////////////////////////////////// Streams ///////////////////
type
   P1MsOleStream = pointer; //until a better way...

   TRead_Copy = function (stream: P1MsOleStream; ptr:  Pguint8; length: TMsOlePos): gint; cdecl;
   TRead_Ptr  = function (stream: P1MsOleStream; length: TMsOlePos):guint8; cdecl;
   TLSeek     = function (stream: P1MsOleStream; bytes: TMsOleSPos; oleType: TMsOleSeek): TMsOleSPos; cdecl;
   TTell      = function (stream: P1MsOleStream): TMsOlePos; cdecl;
   TWrite     = function (stream: P1MsOleStream; ptr:  Pguint8; length: TMsOlePos): TMsOlePos; cdecl;

  _MsOleStream = record
    size: TMsOlePos;
    read_copy: TRead_Copy;
    read_ptr : TRead_Ptr;
    lseek    : TLSeek;
    tell     : TTell;
    write    : TWrite;

    // Private.
	 _type: byte;
	afile: PMsOle;
	pps: pointer;		// Straight PPS
	blocks: pointer;        // A list of the blocks in the file
			        // if NULL: no file
	position: TMsOlePos;    // Current offset into file.
				// Points to the next byte to read
  end;

  TMsOleStream = _MsOleStream;
  PMsOleStream = ^TMsOleStream;
  PPMsOleStream =^PMsOleStream;

  function ms_ole_stream_open  (const stream: PPMsOleStream;fs: PMsOle; const dirpath: PChar; const name: PChar; mode: char): TMsOleErr; cdecl; external libgnomeole2;
  function ms_ole_stream_close (const stream: PPMsOleStream): TMsOleErr; cdecl; external libgnomeole2;
  function ms_ole_stream_duplicate (const stream_copy: PPMsOleStream; const stream: PMsOleStream): TMsOleErr; cdecl; external libgnomeole2;

  procedure ms_ole_dump (const ptr: Pguint8; len: guint32); cdecl; external libgnomeole2;
  procedure ms_ole_ref (fs: PMsOle); cdecl; external libgnomeole2;
  procedure ms_ole_unref (fs: PMsOle); cdecl; external libgnomeole2;
  procedure ms_ole_debug (fs: PMsOle); cdecl; external libgnomeole2;


implementation

function ms_ole_open (fs: PPMsOle; const path: PChar): TMsOleErr;
begin
  Result:=ms_ole_open_vfs (fs, path, True, Nil);
end;

function ms_ole_create (fs: PPMsOle; const path: PChar): TMsOleErr;
begin
  Result:=ms_ole_create_vfs (fs, path, True, Nil);
end;

end.
