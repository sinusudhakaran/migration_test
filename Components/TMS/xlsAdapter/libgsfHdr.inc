//************************************************************************************//
//  File created automatically by LibGen.xls                                 //
//  Do not modify by hand                                                             //
//************************************************************************************//

  procedure gsf_init ( ); cdecl; external libgsf;
  procedure gsf_shutdown ( ); cdecl; external libgsf;
  function gsf_infile_msole_new (source: PGsfInput;  err: PPGError ): PGsfInfile; cdecl; external libgsf;
  function gsf_outfile_msole_new (sink: PGsfOutput ): PGsfOutfile; cdecl; external libgsf;
  function gsf_output_name (gOutput: PGsfOutput ): Pchar; cdecl; external libgsf;
  function gsf_output_container (gOutput: PGsfOutput ): PGsfOutfile; cdecl; external libgsf;
  function gsf_output_size (gOutput: PGsfOutput ): gsf_off_t; cdecl; external libgsf;
  function gsf_output_close (gOutput: PGsfOutput ): gboolean; cdecl; external libgsf;
  function gsf_output_is_closed (gOutput: PGsfOutput ): gboolean; cdecl; external libgsf;
  function gsf_output_tell (gOutput: PGsfOutput ): gsf_off_t; cdecl; external libgsf;
  function gsf_output_seek (gOutput: PGsfOutput; offset: gsf_off_t; whence: GSeekType ): gboolean; cdecl; external libgsf;
  function gsf_output_write (gOutput: PGsfOutput;num_bytes: size_t; data: pointer ): gboolean; cdecl; external libgsf;
  function gsf_input_name (gInput: PGsfInput ): Pchar; cdecl; external libgsf;
  function gsf_input_container (gInput: PGsfInput ): PGsfInfile; cdecl; external libgsf;
  function gsf_input_size (gInput: PGsfInput ): gsf_off_t; cdecl; external libgsf;
  function gsf_input_eof (gInput: PGsfInput ): gboolean; cdecl; external libgsf;
  function gsf_input_tell (gInput: PGsfInput ): gsf_off_t; cdecl; external libgsf;
  function gsf_input_seek (gInput: PGsfInput; offset: gsf_off_t; whence: GSeekType ): gboolean; cdecl; external libgsf;
  function gsf_input_read (gInput: PGsfInput;num_bytes: size_t; data: pointer ): gboolean; cdecl; external libgsf;
  function gsf_outfile_new_child (outfile: PGsfOutfile; name: Pchar; is_dir: gboolean ): PGsfOutput; cdecl; external libgsf;
  function gsf_infile_num_children (infile: PGsfInfile ): integer; cdecl; external libgsf;
  function gsf_infile_name_by_index (infile: PGsfInfile; i: Longint ): Pchar; cdecl; external libgsf;
  function gsf_infile_child_by_index (infile: PGsfInfile; i: Longint ): PGsfInput; cdecl; external libgsf;
  function gsf_infile_child_by_name (infile: PGsfInfile; Name: PChar ): PGsfInput; cdecl; external libgsf;
  function gsf_output_stdio_new (filename: Pchar; err:PPGError ): PGsfOutput; cdecl; external libgsf;
  function gsf_input_stdio_new (filename: Pchar; err:PPGError ): PGsfInput; cdecl; external libgsf;
  function gsf_output_memory_new ( ): PGsfOutput; cdecl; external libgsf;
  function gsf_output_memory_get_bytes  (mem: PGsfOutput ): pointer; cdecl; external libgsf;
  function gsf_input_memory_new (const buff: pointer; length: gsf_off_t; needs_free: boolean ): PGsfInput; cdecl; external libgsf;
