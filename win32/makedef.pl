#!../miniperl

# Written: 10 April 1996 Gary Ng (71564.1743@compuserve.com)

# Create the export list for perl.
# Needed by WIN32 for creating perl.dll
# based on perl_exp.SH in the main perl distribution directory

# This simple program relys on 'global.sym' being up to date
# with all of the global symbols that a dynamicly link library
# might want to access.

# There is some symbol defined in global.sym and interp.sym
# that does not present in the WIN32 port but there is no easy
# way to find them so I just put a exception list here

my $CCTYPE = "MSVC";	# default

while (@ARGV)
 {
  my $flag = shift;
  $define{$1} = 1 if ($flag =~ /^-D(\w+)$/);
  $CCTYPE = $1 if ($flag =~ /^CCTYPE=(\w+)$/);
 } 

open(CFG,'config.h') || die "Cannot open config.h:$!";
while (<CFG>)
 {
  $define{$1} = 1 if /^\s*#\s*define\s+(MYMALLOC)\b/;
  $define{$1} = 1 if /^\s*#\s*define\s+(USE_THREADS)\b/;
 }
close(CFG);

warn join(' ',keys %define)."\n";

if ($define{PERL_OBJECT}) {
    print "LIBRARY PerlCore\n";
    print "DESCRIPTION 'Perl interpreter'\n";
    print "EXPORTS\n";
    output_symbol("perl_alloc");
    exit(0);
}

if ($CCTYPE ne 'GCC') 
 {
  print "LIBRARY Perl\n";
  print "DESCRIPTION 'Perl interpreter, export autogenerated'\n";
 }
else
 {
  $define{'PERL_GLOBAL_STRUCT'} = 1;
  $define{'MULTIPLICITY'} = 1;
 }

print "EXPORTS\n";

my %skip;
my %export;

sub skip_symbols
{
 my $list = shift;
 foreach my $symbol (@$list)
  {
   $skip{$symbol} = 1;
  }
}

sub emit_symbols
{
 my $list = shift;
 foreach my $symbol (@$list)
  {
   emit_symbol($symbol) unless exists $skip{$symbol};
  }
}

skip_symbols [qw(
PL_statusvalue_vms
PL_archpat_auto
PL_cryptseen
PL_DBcv
PL_generation
PL_in_clean_all
PL_in_clean_objs
PL_lastgotoprobe
PL_linestart
PL_modcount
PL_pending_ident
PL_sortcxix
PL_sublex_info
PL_timesbuf
Perl_block_type
Perl_additem
Perl_cast_ulong
Perl_check_uni
Perl_checkcomma
Perl_chsize
Perl_ck_aelem
Perl_cx_dump
Perl_do_ipcctl
Perl_do_ipcget
Perl_do_msgrcv
Perl_do_msgsnd
Perl_do_semop
Perl_do_shmio
Perl_doeval
Perl_dofindlabel
Perl_dopoptoeval
Perl_dump_eval
Perl_dump_fds
Perl_dump_form
Perl_dump_gv
Perl_dump_mstats
Perl_dump_op
Perl_dump_packsubs
Perl_dump_pm
Perl_dump_sub
Perl_expectterm
Perl_fetch_gv
Perl_fetch_io
Perl_force_ident
Perl_force_next
Perl_force_word
Perl_hv_stashpv
Perl_intuit_more
Perl_init_thread_intern
Perl_know_next
Perl_modkids
Perl_mstats
Perl_my_bzero
Perl_my_htonl
Perl_my_ntohl
Perl_my_swap
Perl_my_chsize
Perl_newXSUB
Perl_no_bareword_allowed
Perl_no_fh_allowed
Perl_no_op
Perl_nointrp
Perl_nomem
Perl_pp_cswitch
Perl_pp_entersubr
Perl_pp_evalonce
Perl_pp_interp
Perl_pp_map
Perl_pp_nswitch
Perl_q
Perl_reall_srchlen
Perl_same_dirent
Perl_saw_return
Perl_scan_const
Perl_scan_formline
Perl_scan_heredoc
Perl_scan_ident
Perl_scan_inputsymbol
Perl_scan_pat
Perl_scan_prefix
Perl_scan_str
Perl_scan_subst
Perl_scan_trans
Perl_scan_word
Perl_setenv_getix
Perl_skipspace
Perl_sort_mutex
Perl_sublex_done
Perl_sublex_start
Perl_sv_ref
Perl_sv_setptrobj
Perl_too_few_arguments
Perl_too_many_arguments
Perl_unlnk
Perl_watch
Perl_yyname
Perl_yyrule
allgvs
curblock
curcsv
lastretstr
mystack_mark
perl_init_ext
perl_requirepv
stack
Perl_safexcalloc
Perl_safexmalloc
Perl_safexfree
Perl_safexrealloc
Perl_my_memcmp
Perl_my_memset
PL_cshlen
PL_cshname
PL_opsave
)];


if ($define{'MYMALLOC'})
 {
  skip_symbols [qw(
    Perl_safefree
    Perl_safemalloc
    Perl_saferealloc
    Perl_safecalloc)];
  emit_symbols [qw(
    Perl_malloc
    Perl_free
    Perl_realloc
    Perl_calloc)];
 }
else
 {
  skip_symbols [qw(
    Perl_malloced_size)];
 }

unless ($define{'USE_THREADS'})
 {
  skip_symbols [qw(
PL_thr_key
PL_sv_mutex
PL_cred_mutex
PL_strtab_mutex
PL_svref_mutex
PL_malloc_mutex
PL_eval_mutex
PL_eval_cond
PL_eval_owner
PL_threads_mutex
PL_nthreads
PL_nthreads_cond
PL_threadnum
PL_threadsv_names
PL_thrsv
Perl_vtbl_mutex
Perl_getTHR
Perl_setTHR
Perl_condpair_magic
Perl_new_struct_thread
Perl_per_thread_magicals
Perl_thread_create
Perl_find_threadsv
Perl_unlock_condpair
Perl_magic_mutexfree
Perl_sv_iv
Perl_sv_nv
Perl_sv_true
Perl_sv_uv
Perl_sv_pvn
)];
 }

unless ($define{'FAKE_THREADS'})
 {
  skip_symbols [qw(PL_curthr)];
 }

sub readvar
{
 my $file = shift;
 open(VARS,$file) || die "Cannot open $file:$!";
 my @syms;
 while (<VARS>)
  {
   # All symbols have a Perl_ prefix because that's what embed.h
   # sticks in front of them.
   push(@syms,"PL_".$1) if (/\bPERLVARI?C?\([IGT](\w+)/);
  } 
 close(VARS); 
 return \@syms;
}

if ($define{'USE_THREADS'} || $define{'MULTIPLICITY'})
 {
  my $thrd = readvar("../thrdvar.h");
  skip_symbols $thrd;
 } 

if ($define{'MULTIPLICITY'})
 {
  my $interp = readvar("../intrpvar.h");
  skip_symbols $interp;
 } 

if ($define{'PERL_GLOBAL_STRUCT'})
 {
  my $global = readvar("../perlvars.h");
  skip_symbols $global;
  emit_symbols [qw(Perl_GetVars)];
  emit_symbols [qw(PL_Vars PL_VarsPtr)] unless $CCTYPE eq 'GCC';
 } 

unless ($define{'DEBUGGING'})
 {
  skip_symbols [qw(
    Perl_deb
    Perl_deb_growlevel
    Perl_debop
    Perl_debprofdump
    Perl_debstack
    Perl_debstackptrs
    Perl_runops_debug
    Perl_sv_peek
    Perl_watchaddr
    Perl_watchok)];
 }

if ($define{'HAVE_DES_FCRYPT'})
 {
  emit_symbols [qw(win32_crypt)];
 }

open (GLOBAL, "<../global.sym") || die "failed to open global.sym" . $!;
while (<GLOBAL>) 
 {
  next if (!/^[A-Za-z]/);
  next if (/_amg[ \t]*$/);
  # All symbols have a Perl_ prefix because that's what embed.h
  # sticks in front of them.
  chomp($_);
  my $symbol = "Perl_$_";
  emit_symbol($symbol) unless exists $skip{$symbol};
 }
close(GLOBAL);

# also add symbols from interp.sym
# They are only needed if -DMULTIPLICITY is not set but it
# doesn't hurt to include them anyway.
# these don't have Perl prefix

unless ($define{'PERL_GLOBAL_STRUCT'})
 {
  my $glob = readvar("../perlvars.h");
  emit_symbols $glob;
 } 

unless ($define{'MULTIPLICITY'})
 {
  my $glob = readvar("../intrpvar.h");
  emit_symbols $glob;
 } 

unless ($define{'MULTIPLICITY'} || $define{'USE_THREADS'})
 {
  my $glob = readvar("../thrdvar.h");
  emit_symbols $glob;
 } 

while (<DATA>) {
	my $symbol;
	next if (!/^[A-Za-z]/);
	next if (/^#/);
        s/\r//g;
        chomp($_);
	$symbol = $_;
    	next if exists $skip{$symbol};
	emit_symbol($symbol);
}

foreach my $symbol (sort keys %export)
 {
   output_symbol($symbol);
 }

sub emit_symbol {
	my $symbol = shift;
        chomp($symbol); 
	$export{$symbol} = 1;
}

sub output_symbol {
    my $symbol = shift;
    if ($CCTYPE eq "BORLAND") {
	    # workaround Borland quirk by exporting both the straight
	    # name and a name with leading underscore.  Note the
	    # alias *must* come after the symbol itself, if both
	    # are to be exported. (Linker bug?)
	    print "\t_$symbol\n";
	    print "\t$symbol = _$symbol\n";
    }
    elsif ($CCTYPE eq 'GCC') {
	    # Symbols have leading _ whole process is $%�"% slow
	    # so skip aliases for now
	    print "\t$symbol\n";
    }
    else {
	    # for binary coexistence, export both the symbol and
	    # alias with leading underscore
	    print "\t$symbol\n";
	    print "\t_$symbol = $symbol\n";
    }
}

1;
__DATA__
# extra globals not included above.
perl_init_i18nl10n
perl_init_ext
perl_alloc
perl_atexit
perl_construct
perl_destruct
perl_free
perl_parse
perl_run
perl_get_sv
perl_get_av
perl_get_hv
perl_get_cv
perl_call_argv
perl_call_pv
perl_call_method
perl_call_sv
perl_require_pv
perl_eval_pv
perl_eval_sv
perl_new_ctype
perl_new_collate
perl_new_numeric
perl_set_numeric_standard
perl_set_numeric_local
boot_DynaLoader
Perl_thread_create
win32_errno
win32_environ
win32_stdin
win32_stdout
win32_stderr
win32_ferror
win32_feof
win32_strerror
win32_fprintf
win32_printf
win32_vfprintf
win32_vprintf
win32_fread
win32_fwrite
win32_fopen
win32_fdopen
win32_freopen
win32_fclose
win32_fputs
win32_fputc
win32_ungetc
win32_getc
win32_fileno
win32_clearerr
win32_fflush
win32_ftell
win32_fseek
win32_fgetpos
win32_fsetpos
win32_rewind
win32_tmpfile
win32_abort
win32_fstat
win32_stat
win32_pipe
win32_popen
win32_pclose
win32_rename
win32_setmode
win32_lseek
win32_tell
win32_dup
win32_dup2
win32_open
win32_close
win32_eof
win32_read
win32_write
win32_spawnvp
win32_mkdir
win32_rmdir
win32_chdir
win32_flock
win32_execv
win32_execvp
win32_htons
win32_ntohs
win32_htonl
win32_ntohl
win32_inet_addr
win32_inet_ntoa
win32_socket
win32_bind
win32_listen
win32_accept
win32_connect
win32_send
win32_sendto
win32_recv
win32_recvfrom
win32_shutdown
win32_closesocket
win32_ioctlsocket
win32_setsockopt
win32_getsockopt
win32_getpeername
win32_getsockname
win32_gethostname
win32_gethostbyname
win32_gethostbyaddr
win32_getprotobyname
win32_getprotobynumber
win32_getservbyname
win32_getservbyport
win32_select
win32_endhostent
win32_endnetent
win32_endprotoent
win32_endservent
win32_getnetent
win32_getnetbyname
win32_getnetbyaddr
win32_getprotoent
win32_getservent
win32_sethostent
win32_setnetent
win32_setprotoent
win32_setservent
win32_getenv
win32_putenv
win32_perror
win32_setbuf
win32_setvbuf
win32_flushall
win32_fcloseall
win32_fgets
win32_gets
win32_fgetc
win32_putc
win32_puts
win32_getchar
win32_putchar
win32_malloc
win32_calloc
win32_realloc
win32_free
win32_sleep
win32_times
win32_alarm
win32_open_osfhandle
win32_get_osfhandle
win32_ioctl
win32_unlink
win32_utime
win32_uname
win32_wait
win32_waitpid
win32_kill
win32_str_os_error
win32_opendir
win32_readdir
win32_telldir
win32_seekdir
win32_rewinddir
win32_closedir
win32_longpath
Perl_win32_init
Perl_init_os_extras
Perl_getTHR
Perl_setTHR
RunPerl
