#!/usr/bin/perl
 $en_trace = 0;  # 1 to Log ChipVault Internal Events to trace.txt logfile
#-  ***************************************************************************
#-        _________                                                           
#-       |         |         ChipVault   Version 2014.04                    
#-       |      o  |                                                        
#-       |       \ |         Copyright (C) 2014 Kevin M. Hubbard             
#-        ---------    
#-         |     |
#-
#-   This program is free software; you can redistribute it and/or modify
#-   it under the terms of the GNU General Public License as published by
#-   the Free Software Foundation; either version 2 of the License, or
#-   (at your option) any later version.
#-
#-   ALL MATERIALS ARE PROVIDED 'AS IS'. YOU ASSUME THE ENTIRE RISK AS TO THE 
#-   USE, QUALITY AND PERFORMANCE OF THIS SOFTWARE AND ANY CIRCUITRY GENERATED.
#-
#-   In no event will the Author, Kevin M. Hubbard be liable for direct, 
#-   indirect, special, incidental, or consequential damages resulting from the
#-   use of this software, even if advised of the possibility of such damages.
#-
#-   Use of this software in the design or control of machinery involved in 
#-   'HIGH-RISK' activities, i.e. activities where failure of this software 
#-   could reasonably be expected to cause DEATH, INJURY or the RELEASE OF 
#-   HAZARDOUS MATERIALS, IS NOT PERMITTED.
#-
#-   This program is distributed in the hope that it will be useful,
#-   but WITHOUT ANY WARRANTY; without even the implied warranty of
#-   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#-   GNU General Public License for more details.
#-
#-   You should have received a copy of the GNU General Public License
#-   along with this program; if not, write to the Free Software
#-   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#-
#-  Source file: cv.pl    
#-  Date:    10/04/01
#-  Author:  Kevin M. Hubbard
#-  Description: This is a VHDL/Verilog Hierarchy Viewer and revision control 
#-               system. Use it for managing your design files. It performs
#-               simple CheckIn/CheckOuts and also advanced features such as
#-               bottom-up compiles, Issue Tracking, Report Generation, etc.
#-    
#-  Special Credits To: Larry Wall (Mr.Perl), Linus Torvalds (Mr.Linux),
#-               Richard Stallman "RMS", (Mr.GNU, author of gcc,gdb,emacs....)
#-               What these 3 talented developers created and
#-               gave to the world definitely contributed more to 
#-               ChipVault working than the 400,000 random keys the
#-               Author recklessly (and/or reclusely) typed in creating 
#-               ChipVault source. Buy their books "Just for Fun" and
#-               "Camel", every bookshelf needs them. Support the FSF
#-                (Free Software Foundation) via donations at www.gnu.org
#-               Thank you Jacquie, Adrienne and Danielle for your 
#-               patience in my passion to design and create thangs, 
#-               both on and off the clock.
#-
#-  Inputs:  Command line argument
#-         ARGV[0] : filename   ( hlist.txt, top.vhd or null)
#-         ARGV[1] : optional -c Flag for Batch Mode
#-         ARGV[2] : optional command to execute after -c Flag
#- 
#-  Example Envocation: 
#-   1) 1st Time use for a project:
#-      %cv.pl top.vhd
#-      This will read in top.vhd and find all children files in the same
#-      subdir that end in *.vhd (VHDL) or *.v (Verilog). This will
#-      generate a hlist.txt for which stores the design hierarchy and is
#-      read in by ChipVault on subsequent envocations.
#-
#-      Win32 users - enter "top <enter> *.vhd <enter>" when prompted
#-
#-   2) Subsequent use for a project:
#-      %cv.pl 
#-
#-   3) Project with multiple views (ie RTL,Netlist)
#-      %cv.pl hlist.txt 
#-      %cv.pl rtl_hlist.txt 
#-      %cv.pl net_hlist.txt 
#- 
#-   4) Batch mode for doing a bottom-up on all files
#-      %cv.pl hlist.txt -c "ls -l FILE_NAME"
#-
#-  Example hlist.txt Hierarchy File:
#-   (ModuleName)    (FileName)      (Optional 3rd Column)
#-    "top"
#-    top              top.vhd          u_top
#-      mid1           mid1.vhd         GOTO_LINE= 100
#-        leafa        leafa.vhd        
#-    # This line will be ignored as char-1 is a pound.
#-          subleaf    sublead.vA       GOTO_TAG= end component;
#-        leafb        leafb.v
#-      mid2           mid2.v
#-        leafc        leafc.vhd
#-
#-  Example comments.txt File:
#-    "top"
#-      This text is displayed when cursor is over "top" in hlist
#-    "foo"
#- 
#-  Outputs: STDOUT Status 
#- 
#- Compilation Options: None. Perl-5 Interpreted. Don't know about Perl-4 or 6.
#-
#- BUG_LIST:
#-  0001 : extra "," and ";" on VHDL Port Declarations and Mappings
#-
#-
#_ Revision History:
#_ Ver     When      Who  What
#_ ----    --------  ---  ----------------------------------------------------
#_ 01.10a  10/15/01  KMH  Created
#_ 01.10   10/18/01  KMH  Ported to ActivePerl for Win32 platforms.
#_ 2001.10 10/19/01  KMH  Uploading to SourceForge                  
#_       b 10/21/01  KMH  Fixed flashing on Terminals that return 0 on nokey
#_         10/24/01  KMH  Fixed report file name to support MOD_NAME tags   
#_         10/24/01  KMH  Fixed tool assignment string for UNIX Shell       
#_         10/24/01  KMH  Oops. I accidentally disable batch mode. Fixedit. 
#_         10/26/01  KMH  Enhanced to handle single netlist files which dont
#_                        have top declared 1st (ie they start with a subblock)
#_         10/31/01  KMH  Added Curses support for Mouse on Linux/UNIX and  
#_                        faster screen draws.
#_         11/05/01  KMH  Moved chomp into my_get_line
#_         11/05/01  KMH  Started adding issue list stuff. 
#_         11/05/01  KMH  Added macro key capability.
#_         11/05/01  KMH  Fixed TarBalling ( added (list) option to tools )
#_         11/06/01  KMH  Fixed hierarchy_solver for 1 mod with no child 
#_         11/06/01  KMH  Added Email capability to issue_list_add(),check_in
#_         11/08/01  KMH  Added support for hlist includes 
#_ 2001.11 11/08/01  KMH  2001.11 Release
#_         11/09/01  KMH  Changed log_file to username_log_file for group work
#_         11/15/01  KMH  Changed shell error from 3sec wait to keypress wait 
#_         11/27/01  KMH  scroll_box can pan left/right now.
#_         11/27/01  KMH  Starting adding children block view
#_         11/27/01  KMH  Replaced 80s in dialog_box with maxx. Now support
#_                        screens wider than 80. Great for child block view.
#_         11/27/01  KMH  Added undef $left_str, $right_str to port_solver to
#_                        fix stale outputs from being used on blocks with no
#_                        outs. Still doesnt work!
#_         11/29/01  KMH  Removed cd from $tcap->Trequire(qw(cl cm cd)) as 
#_                        telnet from Win to Solaris failed on cd. Not needed
#_         11/29/01  KMH  Prettied up issue_list_view
#_         11/29/01  KMH  Improved Verilog Generation and Port Mapping
#_         11/29/01  KMH  Problem. Mouse doesnt work on Win2K only WinNT and98
#_         11/29/01  KMH  Stopped calling Vim from Solaris. Assume Vi proper.
#_         11/29/01  KMH  Fixed Win32 trying to "rm" instead of "del" on checkin
#_         11/30/01  KMH  Added fork for allowing Win32 to spawn Editors
#_         11/30/01  KMH  Forking is unreliable on Win32, commented out 
#_         11/30/01  KMH  Added make_pdf for Docs and Schematic Printing
#_         11/30/01  KMH  2001.12 PreRelease in case @home goes away
#_         12/01/01  KMH  Added horiz scroll bar. Not sure if I like or not.
#_         12/01/01  KMH  Added user.ini file for storing run-time config   
#_         12/03/01  KMH  Major Verilog Improvements to hierarchy_solver()  
#_         12/03/01  KMH  Major Verilog Improvements to port_map()
#_         12/03/01  KMH  Added hlist checksumming for ini loading
#_         12/04/01  KMH  Fixed Finding and Launching notepad.exe from Win98
#_         12/04/01  KMH  Fixed Printing PDF PRoblem with global var
#_         12/04/01  KMH  Fixed <right_shift> problem on win32
#_         12/04/01  KMH  Added cv_viewer and cv_rtl_viewer features.
#_ 2001.12 12/04/01  KMH  2001.12 Release 
#_         12/05/01  KMH  Added tool line for call cv_log.pl
#_         12/05/01  KMH  Auto Log File Clearing, etc and terminating cv_log
#_         12/06/01  KMH  Started a PerlTk Port
#_         12/07/01  KMH  PerlTk scroll_box working
#_         12/09/01  KMH  Command Consolidation      
#_         12/09/01  KMH  TODO: Why does down arrow come out as <P> on Win98?
#_         12/09/01  KMH  DONE: Window resizing under POSIX not working.     
#_         12/10/01  KMH  Added page-down capability for ToolMenu     
#_         12/10/01  KMH  Xterm spawning from Tk crash. Why?          
#_         12/10/01  KMH  Fixed Posix Resizing          
#_         12/11/01  KMH  Fixed white space from null issue_list_view fields
#_         12/11/01  KMH  TODO: Enter on issue_list_view off by one line
#_         12/11/01  KMH  Added Tk scroll bars 
#_         12/12/01  KMH  tweaked make_pdf() for better slash support and fix
#_                        colorspace problem.
#_         12/12/01  KMH  fixed cursor going away after Tk scrolling
#_         12/12/01  KMH  added tk settings to ini file.
#_         12/13/01  KMH  Tk support for win32 on sie_perl 
#_         12/16/01  KMH  Added cv_to_go feature.
#_         12/17/01  KMH  Fixed messy too wide error message on ext cmd fails
#_         12/17/01  KMH  Added enable_confirm_checkin safety feature
#_         12/17/01  KMH  Turned off tk for cv_rtl_viewer
#_         12/18/01  KMH  Improved hierarchy_solver() to report refdes's
#_         12/18/01  KMH  Added rotate_view for showing refdes and filenames
#_         12/21/01  KMH  Changed port_solver $left_str to @left_str, fix stale
#_         12/21/01  KMH  Added disable for Curses mouse as messed up pasting  
#_         12/21/01  KMH  Fixed Tar,etc getting called twice after tool_menu   
#_         12/27/01  KMH  txt2pdb() from GPLd bibelot.pl (c) John Fulmer
#_         01/01/02  KMH  Fixed win32 dialog entry being 1 line off via Flush()
#_ 2002.1  01/01/02  KMH  2002.1 Release 
#_         01/08/02  KMH  Mod'd hierarchy_solver to ignore everything after -- 
#_         01/08/02  KMH  Added prompt on operating on Mainline of checkedout 
#_         01/08/02  KMH  Fixed hierarchy_solver() prob w/ filenames > 20.    
#_         01/09/02  KMH  Added "[if_user] username" feature for hlists        
#_         01/10/02  KMH  Fixed hierarchy_solver() using old mod on 2nd RTLgen
#_         01/15/02  KMH  Fixed Send_Author_Email                             
#_         01/15/02  KMH  Fixed wip_exists not clearing on (hier) jobs        
#_         01/15/02  KMH  Fixed cv_tk spin problem with sleep_loop.           
#_         01/16/02  KMH  Added enforce_checkouts feature for protecting main 
#_         01/18/02  KMH  Added report_analysis for generating area estimates 
#_                        and flip-flop counts for report views.
#_         01/20/02  KMH  Enhanced CVtogo for including file sizes and checksum
#_         01/21/02  KMH  MTI path is now /modelsim/username/work for multiuser
#_         01/22/02  KMH  Added file modification timestamp report
#_         01/22/02  KMH  Added command line for executing UNIX scripts <x>
#_         01/27/02  KMH  Added cv_to_go_imp. Basic op, no merging capbility
#_         01/29/02  KMH  Added solve_wip_name for supporting paths         
#_                        NOTE: Reports doesnt work for paths other than ""
#_         02/05/02  KMH  Added a clock
#_         02/12/02  KMH  Fixed <Enter> on issue_list_view. Actually works now.
#_         02/12/02  KMH  Removed <ENTER> prompt on Win32 no editor warning.
#_         02/12/02  KMH  Support for repeating last change history with NULL.
#_         02/20/02  KMH  Display Warning when checkin/out on invalid location.
#_         02/20/02  KMH  Fixed VHDL "foo:" prob in hierarchy_solv+port_solv   
#_         02/21/02  KMH  Added $draw_main2wip_line_en feature.
#_         02/21/02  KMH  Added umask(000) so that gen TARs are a+w permission.
#_         02/25/02  KMH  Cleared edit_sel on @Macros as 1st checkouts ran Vi.  
#_         02/27/02  KMH  Added FAT Table for CVtogo exporting
#_         03/04/02  KMH  Added sorted issue order for CVtogo exporting.
#_         03/22/02  KMH  Extra params around getpwuid for 5.003 support
#_         03/25/02  KMH  Removed error checkin on TAR as UNIX/Linux dont play
#_         04/27/02  Chad VHDL Port_Solver Changes from Chad.
#_         04/29/02  KMH  Added System Call Logging for Batch File Creation
#_         06/07/02  KMH  Added trace log for fellow ChipVault SW developers
#_         06/07/02  KMH  tool_menu_skip hack to fix TAR problem.
#_         06/07/02  KMH  Added TIMESTAMP option for Release TARs
#_         06/10/02  KMH  Fixed a PARAM1 issue.
#_         06/24/02  KMH  Inserted a default tool selection for DOS VIM
#_         08/01/02  KMH  Fixed Win32 not having a ReadOnly Editor Assigned
#_         08/26/02  KMH  Fixed port_map signal_full_list@ not clearing and
#_                        making multiple calls to gen_rtl() append last sig
#_         08/26/02  KMH  Added hlist generation wizard
#_         08/26/02  KMH  <tab> key bound to check_in_out feature (does both)
#_ 2002.8  08/26/02  KMH  2002.8 Release 
#_         09/03/02  KMH  Support for VIM flags under Win32 (ie screen setting)
#_         09/04/02  KMH  WhiteSpace pad the selected filename to 80chars
#_         09/09/02  KMH  Added Search feature via / and ? Keys
#_         09/09/02  KMH  Added @goto_line_array [], GOTO_LINE=, GOTO_TAG=
#_                        ChipVault is now Self Hosting!
#_         09/10/02  KMH  Recalc MOD_NAME and FILE_NAME for UNIX calls all time
#_         09/10/02  KMH  Added label_release feature for history log anttng
#_         09/10/02  KMH  Added Diff COd feature with slog_file under cv_view
#_         09/10/02  KMH  Option to generate RTL to slog_file instead of foo..
#_         09/11/02  KMH  Enhanced label_release feature
#_         09/11/02  KMH  Fixed (list) option to truly do entire list(invis-2)
#_         09/13/02  KMH  Improve Morphing to match line numbers and also allow
#_                        for whitespace compression. Saves up to 150KB.
#_         09/13/02  KMH  Added create_branch() feature.
#_         09/14/02  KMH  Added tool_info feature (active Help for Tool Menu).
#_         09/18/02  KMH  Added internal TAR capability for Win32 RCS tarring.
#_         09/18/02  KMH  Added check_restore for extracting WIPs from TAR file
#_         09/18/02  KMH  Commented k_restore for extracting WIPs from TAR file
#_         09/18/02  KMH  Support INI specified editor(Joe uses Vi,Bob emacs)
#_         09/19/02  KMH  Generate CV.lnk file for Win32 console setup.      
#_         09/27/02  KMH  Added subdir_import() function (ie Renoir importing)
#_         09/27/02  KMH  Added solve_slash for fixing win32 slash problems
#_         09/30/02  KMH  Added build_vlib to generate ModelSim work directory
#_         09/30/02  KMH  Added win32 color schemes
#_         10/02/02  KMH  Try ENV{"USER","LOGNAME"} when getlogin() fails.
#_         10/02/02  KMH  Replace ' ' with '_' on label_release labels.
#_         10/04/02  KMH  Happy 1st Birthday ChipVault!
#_         10/08/02  KMH  cv_include inclusion for libraries, etc
#_         10/08/02  KMH  depricated (list) option with (hier_exp)
#_         10/09/02  KMH  fixed tar calls in tool list from -cvf to -rvf(appnd)
#_ beta    10/17/02  KMH  Added display styles and world greetings. 
#_                        moved call to read_user_ini()
#_         10/17/02  KMH  Worked on toolbox.
#_         10/17/02  KMH  Save Solaris Screen size to uni file
#_         10/17/02  KMH  Removed old cv_log stuff for cv_log.pl. Depricated.
#_         10/18/02  KMH  Added new Tool Bar (Tabbing)
#_         10/18/02  KMH  Removed Curses and Tk subroutines. Stopped supporting
#_         10/18/02  KMH  Added about box. Stopped morphing cv_posix. use cv
#_         10/20/02  KMH  Worked on tools. 
#_ beta    10/21/02  KMH  enforce_checkout now checks for "Edit" string
#_         10/22/02  KMH  Added split_display mode. Lichen it.
#_         10/22/02  KMH  Added horizontal for split_display when x > 160.
#_         10/24/02  KMH  Added split_display scrolling and log file mode.
#_         10/24/02  KMH  Improved Emacs support.
#_         10/24/02  KMH  Added search capability to cv_viewer()
#_         10/25/02  KMH  Added inferrable RAM to VHDL template 
#_         10/25/02  KMH  Added Web Page Reading for CV Change List check
#_         10/29/02  KMH  Removed extra space in KMH favorite theme
#_         10/31/02  KMH  Enhanced Split Display and bound to <s>  
#_         10/31/02  KMH  Gave UNIX 3-char keys (arrows) a 256 offset as
#_                        up_array and 'A' are both 65.
#_         11/01/02  KMH  Option to import subdirs of RTL files only
#_         11/01/02  KMH  Got Arrow Cursor keys working for gnome-terminal
#_         11/01/02  KMH  set_title() for xterm titles. Added vt100 color
#_         11/01/02  KMH  added chomp after vi / emacs user entry to fix CR
#_         11/04/02  KMH  added web page version checking. rewrote get_web_page
#_         11/05/02  KMH  added proxy server web access via LWP
#_         11/05/02  KMH  added hlist support of external files on the web.
#_                        for group design support.
#_         11/06/02  KMH  added Blowfish encryption support .
#_         11/06/02  KMH  hlist now supports white-space lines.
#_         11/08/02  KMH  finally switched my_tool from hash to array
#_         11/08/02  KMH  added Xilinx + Altera Synth Script Generation
#_         11/08/02  KMH  int_tool now parsed from 2nd words, not 1st  
#_         11/09/02  KMH  Added log file viewing
#_         11/10/02  KMH  Worked on Tutorial
#_         11/11/02  KMH  list_user_vars(), build_vlib() toolbar       
#_         11/11/02  KMH  Removed CVtogo and Palm Document Interface   
#_ 2002.11 11/12/02  KMH  2002.11 Release
#_         11/12/02  KMH  oops. fixed log_file and slog_file for split_display
#_         12/12/02  KMH  starting work on 2003.01 beta
#_                   KMH  Added showme function. Cached set_title env_term
#_                         to speed up Xterm title setting
#_         12/16/02  KMH  Removed 5second wait on aborted checkins
#_         01/23/03  KMH  Started X-Windows Mouse Support
#_         07/31/03  KMH  Added MTI_WORK_PATH to INI file 
#_         07/31/03  KMH  Set ENV var MODELSIM points to ini file in work area
#_         09/04/03  KMH  Removed Web Access and Blowfish Encryption. 
#_         09/04/03  KMH  Removed Script generator for Xilinx,Altera,Synplify
#_         10/06/03  KMH  Tried binding <del> key to check-abandon, works but
#_                        required <ENTER> be pressed.
#_         10/06/03  KMH  Support for more than 1 key binding per command.   
#_         10/06/03  KMH  Support for <ins> and <del> keys on Linux.
#_         10/06/03  KMH  Added pre_trace storage.
#_         11/19/03  KMH  Started archive_release_path stuff.
#_         11/19/03  KMH  Acroreader support.
#_         11/19/03  KMH  skip_missing change. all option added
#_         05/02/04  KMH  Added found_port_start to fix nets with port in them.
#_         01/07/05  KMH  Improved port_solver() for Verilog. Support input[7:0]
#_         01/12/05  KMH  Added a hack that calls vlog in place of vcom if file 
#_                        ends in .v
#_         09.14/05  KMH  Bind <end> to diff instead of CheckIn
#_         12.06/05  KMH  Support for mouse scroll wheel 
#_         01.13.06  KMH  added a .cv_trash_can for abandoned checkout files
#_         05.31.06  KMH  port_solver on Verilog was very slow on big files.
#_                        added close on 1st always encountered.  Helps mucho
#_         06.08.06  KMH  Verilog fix in port_solver to show bus widths     
#_                        Added another split screen option for more ports
#_         07.08.06  KMH  added rtl_analyzer() for analyzing verilog rtl.       
#_ 2006.07 07.08.06  KMH  release
#_         08.02.06  KMH  Oops - rtl_analyzer() was <a>, which is scroll port
#_         10.10.06  KMH  Improved port_solver() for Verilog. Comments, 2001 
#_         12.04.08  KMH  Fix for RHEL5 <home> and <end> scan codes
#_         12.09.09  KMH  Support for IcarusVerilog solve_wip_name()
#_         01.28.10  KMH  WIP timestamp checking added
#_         04.28.10  KMH  Minor xterm title fix
#_ 2010.04 04.28.10  KMH  check_wip_status after running Vi
#_         05.11.10  KMH  Support for "MyLabel" and whitespace in hlist
#_         05.27.10  KMH  Added -time for vlog to always display somethin
#_         06.07.10  KMH  Disabled x_mouse by default
#_ 2010.07 07.30.10  KMH  Added comments.txt descriptions for "MyLabel"
#_         03.23.11  KMH  Added $redraw_on_scroll=1. 
#_                        Set_title( uname + hostname ) on exit.
#_         04.15.11  KMH  Switched from getlogin() to getpwuid($<) for my_name
#_         04.20.11  KMH  Cached port_solver results
#_         05.06.11  KMH  Change to dialog_box_display() to switch on no_border
#_                        and remove extra "  " before each line of cv_view()
#_         09.19.11  KMH  Changed hierarchy togl to only expand down one level.
#_         09.28.11  KMH  added support for willsie array_8x8 type in VHDL.
#_         06.05.12  KMH  change port_solver(), only diplay _p of diff pairs.
#_ 2013.01 01.03.13  KMH  "MyLabel" so comments.txt must be specfd in hlist.
#_         03.28.13  KMH  Patched report_analysis to not read each file (slow)
#_ 2013.11 11.01.13  KMH  Fix for MyLabel to not require ending label
#_ 2014.04 04.26.14  KMH  Adding Subversion interface
#_
#_ TODO:!! Checksum Problem. See:  ( files are differnet, checksum the same)
#_    Aug  7 16:44 khubbard_cv.bad
#_    Aug  7 16:44 khubbard_cv.bad2
#_
#_                                   --- END_CHANGE_LIST ---
#_ TODOLIST:
#_ TODO: issue with win32 putting CtrlM after PROXY_USER and mucking thangs
#_ TODO: Note: There are still some issues with leading paths on file gens   
#_             ie history logs, etc.
#_ TODO: Major Snafu on using Global $rts for dialog_box instead of local.
#_       when array of params are used. 
#_  0001 : Verilog Module Generation
#_         NO_EXT doesn't work! $ext_null must be set to ".vhd" or ".v"
#_  0002 : Use seek() function (PerlCookBook pg.283) to watch STDOUT live
#_         during VCOMs
#_  0003 : VIM from Win32 doesnt work on files w/ paths
#- ***************************************************************************
###############################################################################
# ChipVault Internal Function List
#############
# Main
#   main()
#############
# Revision Control (Library)
#   check_out() check_in() check_abandon() check_restore() label_release()
#   archive() archive_restore() 
#############
# USER I/O 
#   my_get_key() scroll_box() banner_message() readkey() clear_screen() gotoxy()
#   display_ports_parent() display_ports_kids() display_main() cbreak() cooked()
#   leave_now() screen_sizing() process_keys() display_tool_menu()
#   cv_view() cv_rtl_view() display_help() scroll_box_rtl() dialog_box()
#   dialog_box_display() dialog_box_input() my_get_line() my_print()
#   display_cursor() curses_refresh() read_user_ini()
#############
# Misc
#   get_hlist() init() finish() dump()
#############
# Design Issue DataBase
#   issue_list_add() issue_list_view()
#############
# RTL Analysis and Generation
#   call_hierarchy_solver() report_analysis() hierarchy_solver() show_children()
#   port_solver() port_map() make_rtl() generate_rtl()
#############
# OS Interfaces
#   send_email() by_word_n 
#   my_glob() solve_wip_name() solve_file()
#   solve_path()
#############
# PDF Generation
#   make_pdf() pdf_text_horizontal() pdf_text_horizontal_cont() 
#   pdf_close_horizontal_cont() pdf_text_vertical() pdf_color_line() 
#   pdf_header() pdf_start_page() pdf_finish_page() pdf_footer()
###############################################################################
$version = "2013.11                  "; # Note Whitespace needed for banner bug
# [pdf_on]
# [pdf_text_size] 40
#        ChipVault
#         2006.07 
# [pdf_break]
# [pdf_text_size] 10
# [pdf_off]


use Sys::Hostname;

#use HotKey;
# use Term::ANSIColor;        # Note: Only on Linux
#print color("red"), "Stop!\n", color("reset");
#exit;
#use Term::Size;

## Text Compression: Enabling these will reduce the RunTime footprint of
## ChipVault by approximately 50%. IE, your ChipVault executable will 
## be 200KB instead of 400KB.

$whitespace_compression   = 0 ; # Compress ChipVault by Removing White Spaces
$comment_line_removal     = 0 ; # Remove Commented Lines
$vhdl_template_removal    = 0 ; # Remove Lines beginning w/ #T
$verilog_template_removal = 0 ; # Remove Lines beginning w/ #V
$help_text_removal        = 0 ; # Remove Lines beginning w/ #H
$tutorial_removal         = 0 ; # Remove Lines beginning w/ #H
$changelog_removal        = 0 ; # Remove Lines beginning w/ #_
$gpl_license_removal      = 0 ; # Remove Lines beginning w/ #L
$dont_check_for_xterm     = 1 ; # Disable XTERM Check

$curses_on = 0;
$morph = 1; # Generate Curses, Win32 versions of SW
$cv_is_installed = 0 ; # Disables Unpacking

# SELF_MODIFY_SECTION_START CODE_TK     OFF NULL
# use Tk;
# use Tk::Xlib;
# use Tk::Dialog;
# use Tk::TextList;
# $tk_on = 1;
# SELF_MODIFY_SECTION_STOP  CODE_TK     OFF NULL

# SELF_MODIFY_SECTION_START CODE_CURSES OFF NULL
# use Curses;
# $curses_on = 1;
# $curses_mouse_enable = 0 ; # May screw up Xterm Pasting via Mouse
# $morph = 0;
# SELF_MODIFY_SECTION_STOP  CODE_CURSES OFF NULL

# SELF_MODIFY_SECTION_START CODE_WIN32  OFF NULL
# use Win32;
# use Win32::Console;
# use Win32::Process;
# $morph = 0;
# $win32_enabled = 1;
# SELF_MODIFY_SECTION_STOP  CODE_WIN32  OFF NULL

# shift; # $ARGV[0] <- $ARGV[1]

$os = "unix"; # Assume were running on a real OS until told otherwise.

$os_title = lc( $^O ) ; # See Camel Pg.137
if ( ( $os_title =~ m/win/go ) ) { $os = "win32"; }
  else                           { $os = "unix";  }

if ( $os eq "unix") { umask (000); } # Make sure Gen Tars are a+w

#print "$os_title\n";
#exit;

$app_title = $0;
$maxx = 80 ; # Default needed for opening banner
$maxy = 24 ; # Default needed for opening banner
$comment_line = 0; # Default
push @pre_trace_opened, "Starting ChipVault Trace File...\n";

if ( ( $os eq "win32" ) && ($cv_is_installed != 1 ) )
{
##########################################################
# Generate Platform specific version of application for
# using on Win32 and UNIX+Curses.
##########################################################
    $win32_morph  = "cv_win32.pl";  # ActivePerl port for Win32

  if ( $morph == 1 )
   {
    # select STDOUT; $| = 1 ; # Turn off STDOUT Buffering (Normally buffs lines)
    print "\nGenerating PDF Documentation..\n";
    print "Unpacking $win32_morph  : Port for Win32 OSs\n";
    print "                         (Console-App. Beware of W2K console)\n";
    make_pdf( $app_title, "cv.pdf", "parse");
    open( input_file , "<" . $app_title );  # This is me
    open( output1_file, ">" . $win32_morph );
    while ( $_ = <input_file> )
     {
       chomp $_; # Strip CR
       if ( $whitespace_compression == 1 ) { s/^\s*//; } # Leading WhiteSpace
       $out_str = $_ . "\n"; # Add CR

       ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $_ ,5) ; #Parse
       if    ($F2 eq "[tk_section_on]" )  { $tk_section  = 1; }
       elsif ($F2 eq "[tk_section_off]" ) { $tk_section  = 0; }

       $remove_comment_line=0; 
       if ( 
            ( $comment_line_removal     == 1 ) ||
            ( $vhdl_template_removal    == 1 ) ||
            ( $verilog_template_removal == 1 ) ||
            ( $help_text_removal        == 1 ) ||
            ( $tutorial_removal         == 1 ) ||
            ( $changelog_removal        == 1 ) ||
            ( $gpl_license_removal      == 1 ) 
          )
        {
         if ( substr($F1,0,1) eq "#") 
           {
            if    (($vhdl_template_removal==1) && (substr($F1,1,1) eq "T"))
             { $remove_comment_line=1; }
            if (($verilog_template_removal==1) && (substr($F1,1,1) eq "V"))
             { $remove_comment_line=1; }
            if (($help_text_removal       ==1) && (substr($F1,1,1) eq "H"))
             { $remove_comment_line=1; }
            if (($changelog_removal       ==1) && (substr($F1,1,1) eq "_"))
             { $remove_comment_line=1; }
            if (($tutorial_removal        ==1) && (substr($F1,1,1) eq "Z"))
             { $remove_comment_line=1; }
            if (($gpl_license_removal     ==1) && (substr($F1,1,1) eq "L"))
             { $remove_comment_line=1; }
            if (($comment_line_removal    ==1) && (substr($_ ,1,1) eq " "))
             { $remove_comment_line=1; }
            if (($comment_line_removal    ==1) && (substr($_ ,1,1) eq "#"))
             { $remove_comment_line=1; }
           }# if ( substr($F1,0,1) eq "#") 
        }

       if ( $F1 eq "\$cv_is_installed" )
        {
         print output1_file "\$cv_is_installed = 1;\n";
        }
       elsif ( $F2 eq "SELF_MODIFY_SECTION_START" )
        {
         print output1_file $out_str;
         if (  $F3 eq "CODE_WIN32" )
           { 
            if ( $F4 eq "OFF" ) 
             { 
              $win32_morphing = 1; 
              $out_str = "$F1 $F2 $F3 ON $ETC";
              print "..";
             }
           }
         elsif (  $F3 eq "CODE_CURSES" )
           { 
            if ( $F4 eq "OFF")  
             { 
              $curses_morphing = 1; 
              $out_str = "$F1 $F2 $F3 ON $ETC";
              print "..";
             }
           }
         elsif (  $F3 eq "CODE_TK" )
           { 
            if ( $F4 eq "OFF")  
             { 
              $tk_morphing = 1; 
              $out_str = "$F1 $F2 $F3 ON $ETC";
              print "..";
             }
           }
        }
       elsif ( $F2 eq "SELF_MODIFY_SECTION_STOP" )
        {
         # if ( $morphing == 1 ) { $morphing = 0 ; } 
         if ( $curses_morphing == 1 ) { $curses_morphing = 0 ; } 
         if (  $win32_morphing == 1 ) {  $win32_morphing = 0 ; } 
         if (  $tk_morphing    == 1 ) {  $tk_morphing    = 0 ; } 
         print output1_file $out_str;
        }
       elsif ( ($win32_morphing == 1) )
        {
         ($null_str, $out_str) = split (' ', $_ , 2 );
         print output1_file $out_str;
         print "..";
        }
       elsif ( ( $curses_morphing == 1 ) )
        {
         print output1_file $out_str;
         ($null_str, $out_str) = split (' ', $_ , 2 );
         print "..";
        }
       elsif ( ( $tk_morphing == 1 ) )
        {
         print output1_file $out_str;
         ($null_str, $out_str) = split (' ', $_ , 2 );
         print "..";
        }
       else
        {
         if ( $remove_comment_line == 1 )
          {
           $out_str = "#\n"; # Compress, but keep line numbers same
          } # if ( $comment_line == 0 )
           print output1_file $out_str;
        }
    } # while

   close input_file;
   close output1_file;
   print "\n";

   print STDOUT "NOTE: Installation for Win32 Complete. Run cv_win32.pl \n";

    }# if ( $morph == 1 )

  if ( $os eq "win32" && ( $win32_enabled != 1 ) )
   {
    print STDOUT "\n------------------------------------------------\n";
    print STDOUT "NOTE: Generated cv_win32.pl file                  \n";
    print STDOUT " I detected you are running on a Win32 OS.        \n";
    print STDOUT " Win32 is not POSIX Terminal IO compliant. I have \n";
    print STDOUT " generated a new file for you to execute called   \n";
    print STDOUT " cv_win32.pl which will make native Win32 calls   \n";
    print STDOUT " instead of POSIX Terminal IO calls.            \n\n";
    print STDOUT "NOTE: Decent_Editor_Required                      \n";
    print STDOUT " You will most likely need a decent editor        \n";
    print STDOUT " on Windows. I'll assume VIM is in c:\vim         \n";
    print STDOUT " If you need it, go to www.vim.org (free)       \n\n";
    print STDOUT " Press <ENTER> for Win32 Console Setup Information\n";
    print STDOUT "------------------------------------------------\n";
    $rts = my_get_line();
    print STDOUT "NOTE: Generated Win2K cv.lnk file                 \n";
    print STDOUT " Windows-Console apps have bad defaults which     \n";
    print STDOUT " take away cursor key bindings. I have generated  \n";
    print STDOUT " a cv.lnk file for you which launches ChipVault   \n";
    print STDOUT " cv_win32.pl in a console 80x60 which supports    \n";
    print STDOUT " cursor key navigation. Double-Click on cv.lnk    \n";
    print STDOUT " to start ChipVault under Windows. Right-Click    \n";
    print STDOUT " on cv.lnk to change Properties such as Window    \n";
    print STDOUT " size, startup directory, etc.                    \n";
    print STDOUT "NOTE: If the generated cv.lnk file doesn't work   \n";
    print STDOUT " on your particular flavor of Windows, generate a \n";
    print STDOUT " link file from the Windows Desktop with the parms\n";
    print STDOUT " [Shortcut]\n";
    print STDOUT "  Target     : perl.exe cv_win32.pl\n";
    print STDOUT "  Start in   : Your_Design_Path_Containing_hlist.txt\n";
    print STDOUT " [Layout]\n";
    print STDOUT "  ScreenBufferWidth  : 80\n";
    print STDOUT "  ScreenBufferHeight : 60\n";
    print STDOUT "  Window Size Width  : 80\n";
    print STDOUT "  Window Size Height : 60\n";
    print STDOUT "------------------------------------------------\n";
    print STDOUT " Press <ENTER> to exit this POSIX Application.    \n";
    $rts = my_get_line();
    gen_win32_lnk(); # Go Ahead and generate the Win32 link for everybody
    exit ( -10 );
   }


} # if ( $cv_is_installed != 1 )



##########################################################
# Not all UNIX Terminals support cursor control. Check for xterm and warn
##########################################################
if ( ( $os eq "unix") && ( $dont_check_for_xterm != 1 ) )
 {
  $user_screen_type = lc( $ENV{"TERM"} );

  if ( lc($ENV{"TERM"}) ne "xterm" )
   {
    if ( lc($ENV{"TERM"}) eq "sun-cmd" )
    {
     print STDOUT "WARNING: cmdtool and shelltool dont work   \n";
     print STDOUT "WARNING: please use xterm or gnome-terminal\n";
    }
    print STDOUT "WARNING: I did not detect an xterm terminal in use\n";
    print STDOUT " Terminal Type ". $ENV{"TERM"} ." may or may not work with\n";
    print STDOUT " POSIX compliant Terminal Escape Codes for cursor\n";
    print STDOUT " positioning. If the text formatting after this is\n";
    print STDOUT " scrambled, press <q> key and restart application \n";
    print STDOUT " inside an xterm.                                  \n";
    print STDOUT " Note: You can avoid this check in the future by   \n";
    print STDOUT "       setting the variable dont_check_for_xterm   \n";
    print STDOUT " Thank you. Please Press <ENTER> to begin ChipVault.\n";
    $rts = my_get_line();  
   }
 }

if ( $os eq "unix" )
 {
  # Send the Xterm Escape chars for setting terminal title. Note that this
  $xterm_title = "ChipVault " . $version;
  set_title($xterm_title);

  use Cwd;  # For Finding Current Directory Name
  use Term::Cap;
  use POSIX qw(:termios_h);

  $pwd = cwd(); # Current Working directory for default project name
  $proj_name = $pwd;
  ( $proj_name =~ s/\//_/go ); # Replace / with _ 

  $fd_stdin = fileno(STDIN);
  $term     = POSIX::Termios->new();
  $term->getattr($fd_stdin);
  $oterm     = $term->getlflag();

   $echo    = ECHO | ECHOK | ICANON;
   $noecho  = $oterm & ~$echo;
  }

if ( $os eq "unix" )
  {
   $filecat       = "/" ;
   $cp_cmd        = "cp ";
   $rm_cmd        = "rm ";
   $trash_can_cmd = "mv ";
   $trash_can_dir = ".cv_trash_can";
   $mkdir_cmd     = "mkdir -p"; # Note -p creates parent dirs when needed
   $gzip_cmd      = "gzip ";
   $gunzip_cmd    = "gunzip ";
   $gzip_dir_cmd  = "gzip -r ";
  }
elsif ( $os eq "win32" )
  {
   $filecat       = "\\" ;
   $cp_cmd        = "copy ";
   $rm_cmd        = "del ";
   $trash_can_cmd = "del ";
   $mkdir_cmd     = "mkdir ";
   $gzip_cmd      = "";
   $gunzip_cmd    = "";
   $gzip_dir_cmd  = "";
  }

#if ( $my_name eq "" ) { $my_name = getlogin(); }
 if ( $my_name eq "" ) { $my_name = getpwuid($<); }
 if ( $my_name eq "" ) { $my_name =  $ENV{"LOGNAME"}; }
 if ( $my_name eq "" ) { $my_name =  $ENV{"USER"}; }
 if ( $my_name eq "" ) 
  {
#   print "WARNING: getlogin() failed\n";
    print "WARNING: getpwuid() failed\n";
    print "         Perl was unable to deliver your login name\n";
    print "         Please type it in followed by <ENTER>\n";
    $my_name = my_get_line();  
  }




# [pdf_on]
# [pdf_text_size] 20
# User Definable Flag Options:
# [pdf_text_size] 10
# [pdf_line_number]

# [user_vars_start]
#############################################################################
# User INI File Settings:   
  $user_ini_enable =  1;                 # Turn Off to speed up start/quit

#  $user_ini_file   = ".USER_NAME_cv.ini"; # Hidden User Config
  $user_ini_file   = "USER_NAME_cv.ini";   # Visible User Config

  ( $user_ini_file =~ s/USER_NAME/$my_name/go ); # Search+Replace Tag
  $notify_on_hlist_change = 1 ;          # Tell user when hlist.txt changes
#############################################################################
  push @pre_trace_opened, "Assigning feature enables...\n";
# Advanced Feature Enables:
  $disp_tool_opts          = 0;  # Display the Tool Options in the Tool Menu
  $disp_tool_bindings      = 1;  # Display the Key bindings in the Tool Menu
  $disp_file_in_main       = 1;  # Display the Select Filename in Main Window
  $disp_file_xterm_title   = 1;  # Display the Select Filename in Xterm Title
  $enable_split_display    = 1;  # Split Display in 2 for simultan port views
  $split_display_size      = 1;  # Default Split Display Sizing
  $split_display_mode      = 0;  # Default Split Display Mode (Port vs Log)
  $enable_archives         = 1;  # Make 0 if you don't want TARs made
  $enable_history          = 1;  # Make 0 if you don't want History Logs
  $enable_vt100_color      = 0;  # Make 0 if you don't want UNIX VT100 Color
  $newbie                  = 0;  # Turns on annoying hints and stuff    
  $enable_confirm_checkin  = 1;  # Make 0 if you don't confirmation prompting
  $enforce_checkouts       = 0;  # Prohibits running editor on mainline files
# $enforce_checkouts       = 1;  # Prohibits running editor on mainline files
  $enforce_checkouts_truly = 0;  # Uses CVs RTL Viewer instead of vi -R      
  $enforce_warn_time       = 1;  # How many seconds to display warning dialog
  $redraw_on_scroll        = 0;  # Always redraw the screen on a scroll op
  $dynamic_resize_checking = 0 ; # Allow for dynamic window resizing
                                 # Turn on for really fast systems 
                                 # Then you don't need to press <r>esize key.
  $hide_scroll_border    = 1;    # Scroll Border makes mouse copying a problem
  $stty_pipe_doesnt_work = 0;    # Set 1 to not call stty for screen size
  $default_noise_filter  = "";   # Null is default as it forces Prompt Popup
  $license_banner        = 1;    # Set to 1 to make popup last 1 second
  $license_banner_quit   = 1;    # Set to 1 to make popup last 1 second
  $draw_main2wip_line_en = 1;    # ASCII Line connecting Mainline file to WIP
  $win32_mouse_enable    = 1;    # Enables Mouse Support on win32 
  $x_mouse_enable        = 0;    # Enables Mouse Support on X Windows
  $x_mouse_wheel_enable  = 0;    # Enables Mouse Wheel Support on X Windows
  $vim_lines             = 80;   # Defines VIM Screen Line Size under Win32
  $disp_select           = 0;    # Set 0 for module, 1 for file, 2 for refdes
  $gates_per_cell_area   = 40;   # For report_analysys, this tries to 
                                 # correlate Synopsys Cell Area with Gate cnt
                                 # This will change for every tech library.
  $enable_clock          = 1;    # Display the clock on screen or not
  $gzip_branched_files   = "?";  # Gzip the branched files or leave in clear
  $unix_tar_en           = 1;    # Use UNIX tar instead of internal TAR
  $unix_gzip_en          = 1;    # Use UNIX gzip to compress TAR files 
  $author_email          = "khubbard\@users.sourceforge.net";
  $power_flop_cap        = 0.07; # pF
  $power_voltage         = 1.8;  # Volts
  $power_freq            = 100;  # MHz
  $power_activity        = 0.2;  # Toggle Rate
  $power_clk_ratio       = 0.2;  # Clock Tree Power Relative to Flop Power
  $power_combo_ratio     = 2.0;  # Combo Power Relative to Flop Power
  $gate_density          = 40000;# Routed Gates per mm^2

# [user_vars_stop]

  $style = 0;
  @style_flag_expanded [$style] = " -  ";     # Classic
  @style_flag_collapsed[$style] = " +  ";    
  @style_flag_nokids   [$style] = "    ";    
  $style++;  
  @style_flag_expanded [$style] = "[-] ";   # KMH Favorite
  @style_flag_collapsed[$style] = "[+] ";    
  @style_flag_nokids   [$style] = "    ";    
  $style++;  
  @style_flag_expanded [$style] = "[-] ";   # Minor Variation
  @style_flag_collapsed[$style] = "[+] ";    
  @style_flag_nokids   [$style] = " \\ ";  
  $style++;  
  @style_flag_expanded [$style] = "\(-\) "; # 
  @style_flag_collapsed[$style] = "\(+\) ";    
  @style_flag_nokids   [$style] = "    ";    
  $style++;  
  @style_flag_expanded [$style] = "<-> ";   # 
  @style_flag_collapsed[$style] = "<+> ";    
  @style_flag_nokids   [$style] = "    ";    
  $style++;  
  @style_array[$style] = "end";

  $style = 1;                    # Specify the Default Style
  update_style($style);
  

# Win32 users under Active-Perl can pick some different stock color schemes
  @win32_color_array[0]  = ($FG_BLACK | $BG_WHITE );
  @win32_color_array[1]  = ($FG_WHITE | $BG_BLACK );
  @win32_color_array[2]  = ($FG_WHITE | $BG_BLUE  );
  @win32_color_array[3]  = ($FG_GRAY  | $BG_BLUE  );
  @win32_color_array[4]  = ($FG_GRAY  | $BG_BLACK );
  @win32_color_array[5]  = ($FG_GREEN | $BG_BLACK );
  $win32_color_select = 0; 
  $win32_color_scheme = @win32_color_array[$win32_color_select];

# VT100 users can pick some different stock color schemes
  @vt100_color_array[0]  = "           ";
  @vt100_color_array[1]  = "black white";
  @vt100_color_array[2]  = "white black";
  @vt100_color_array[3]  = "white blue";
  @vt100_color_array[4]  = "green black";
  @vt100_color_array[5]  = "blue  black";
  $win32_color_select = 0; 
  $vt100_color_scheme = @vt100_color_array[$win32_color_select];


if ( $os ne "unix" )
   {
     $unix_tar_en        = 0;    # Use UNIX tar instead of internal TAR
     $unix_gzip_en       = 0;    # Use UNIX gzip to compress TAR files 
   }



# Ignore this stuff. Just author specific prefs 
if ( $my_name eq "khubbard" )
 {
  $disp_file_in_main     = 1;  # Display the Select Filename in Main Window
  $disp_file_xterm_title = 1;  # Display the Select Filename in Xterm Title
  $license_banner        = 1;    # Set to 1 to make popup last 1 seconds only
  $license_banner_quit   = 1;    # Set to 1 to make popup last 1 seconds only
 }

# [user_vars_start]
  # Set this to NULL if you want no web access for checking versions.
  $web_page_url       = "http://chipvault.sourceforge.net";
  $change_list_url    = $web_page_url . "/change_list.txt";

  $cv_include_var     = "CV_INCLUDE";        # Environment variable for libs
  $cv_include_file    = ".cv_include";       # Home Hidden file for libs

  $issue_file         = "issues.txt";        # Issue Tracking DataBase
  $print_file         = "print.txt";         # Text Printout of Blocks
  $pdf_file           = "print.pdf";         # PDF  Printout of Blocks
  $branches_subdir    = "branches";          # Subdir to put branches in
  $log_file_tag       = "USER_NAME_log.txt"; # Standard Output Log File
  $log_file           = $log_file_tag;
  ( $log_file         =~ s/USER_NAME/$my_name/go ); # Search+Replace Tag
  $slog_file_tag      = "USER_NAME_slog.txt"; # Standard Output Small Log File
  $slog_file          = $slog_file_tag;
  $trace_file         = "cv_trace.txt";       # Software Debug Trace File
  ( $slog_file        =~ s/USER_NAME/$my_name/go ); # Search+Replace Tag


  $sys_file_tag       = "USER_NAME_syslog.sh";      # Batch Log File
  $sys_file           = $sys_file_tag ;
  ( $sys_file         =~ s/USER_NAME/$my_name/go ); # Search+Replace Tag


  $rel_path_to_src    = "../src/";           # Relative Path from Xilinx to Src

#############################################################################
# Admin Setup : Admin users can change file Write Permissions from ChipVault.
  $admin_hash {"khubbard"} = 1;
  $admin_hash {"hunt"}     = 1;
  $company_name = "Acme ASIC Design";
  $acroread_path = "/usr/local/Acrobat5/bin/acroread";

#############################################################################
# Email Setup : This allows for automatic Email notification to entire
#               group on file Checkins.
  $email_domain     = ""; # ie "\@foo.com" Can be kept null oftentimes.
  @email_list       = ("khubbard","khubbard") ; # This is for checkins.
  $send_email_on_check_in = 0;   # Annoying. Some people like this.
  $send_email_allowed     = 1;   # Security feature Email enabling.

if ( $os eq "unix" ) # Configure Browser for Webbing to ChipVault WebSite
 {  $browser         = "netscape"; }
else
 {  $browser         = "iexplore.exe"; }


#############################################################################
# Shared Library Component Modules : These are like hlist.txt files but they
#                                    contain common building block components
#                                    for designers to browse and use in their
#                                    designs.
@lib_list   = ("/home/asic/group/examples/vhdl/library.txt",
               "/home/asic/group/examples/verilog/library.txt" );
 
#############################################################################
# File Name Formats:
#$wip_header      = "wip.";          # Defines Name for CheckedOut Files. 
$wip_header      = "./wip";          # Defines Subdir for CheckedOut Files. 
                                     # ie "wip/foo.vhd"
$tar_header      = ".archive.";      # I like this hidden. 
$tar_list_header = ".archive_list."; # Remove 1st dot to make these visible
$tar_list_footer = ".txt";           # 

$hist_log_header = ".history_log.";  # I like this hidden
$hist_log_footer = ".txt";           # 


#############################################################################
# Misc Options:     
# $archive_release_path = "/tmp";  # Where Releases get copied to
$archive_release_path = "/home/asic/z_proj/cv_archive";  # Where Releases get copied to

$bell    = chr(7); # Warning Bell. I find them annoying. Set to "" instead.
$x_scale = 2;      # Defines the number of spaces between hierarchy levels
                   # for shallow hierarchy designs, you might want this to
                   # be 4 to give more spacing. For really deep designs,
                   # you'll want this to be 1 so all levels fit on the screen
$activate_tool_once_selected = 1 ;   # Once you pick a new tool, use it now

$horiz_scroll_bar_option = 1 ; # Enables drawing horizontal scroll bar.
# [user_vars_stop]


#############################################################################

# [pdf_break]
# [pdf_line_number]
#############################################################################
# KeyCodes: These work for my machine, which means 1% chance they'll work on
#           yours. Envoke cv.pl DEBUG to see your key codes.
  push @pre_trace_opened, "Defining Key Codes...\n";
$k_ctrl_d = 4 ;
$k_ctrl_u = 21 ;

if ( $os eq "unix" )
 {
  $k_up  = 65 + 256; # Note: 256 is my offset out of ASCII range for 3-char key
  $k_dn  = 66 + 256;
  $k_lf  = 68 + 256;
  $k_rt  = 67 + 256;
  $k_cr  = 10;
  $k_tab = 9;
  $k_del  = 307; # This is Linux, how about Solaris?
  $k_del2 = 127; # This is Solaris
  $k_ins  = 306; # This is Linux, how about Solaris?
  $k_end  = 308; # This is Linux, how about Solaris?
  $k_home = 305; # This is Linux, how about Solaris?
  $k_end2  = 326; # This is Linux, how about Solaris?
  $k_home2 = 328; # This is Linux, how about Solaris?
  $k_pu    = 309; # This is Linux, how about Solaris?
  $k_pd    = 310; # This is Linux, how about Solaris?
  $k_esc = 27;
 }
else
 {
  $k_cr = 13;
  $k_up = 72; # Win32 ScanCodes
  $k_dn = 80;
  $k_lf = 75;
  $k_rt = 77;
  $k_tab = 9;
  $k_esc = 27;
 }

$k_sp = 32;
$k_p = 112;
$k_q = 113;
$k_a = ord("a");
$k_e = ord("e");
$k_h = ord("h");
$k_z = ord("z");
$k_1 = ord( "1");
$k_2 = ord( "2");
$k_3 = ord( "3");
$k_4 = ord( "4");
$k_5 = ord( "5");
$k_6 = ord( "6");
$k_7 = ord( "7");
$k_8 = ord( "8");
$k_9 = ord( "9");

$k_mouse_double_click_togl = -1;
$k_mouse_double_click_edit = -2;
$k_mouse_port_view         = -3;

# Create the WIP directory if its a directory
if ( substr($wip_header,0,2) eq "./" )
{
   if ( -e $wip_header ) {}
   else
   {
    $cmd = "$mkdir_cmd $wip_header";
    @run_shell     = solve_slash("$cmd");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
    if ( $rc != 0 )
     {
       $perl_line = __LINE__;
       dialog_box(3,"ERROR $perl_line:$bell# Unable to : $cmd ");
       exit( 10 );
     }
   }
}

# Create a TrashCan for placing check_abandon files in
if ( $os eq "unix" )
{
   $cmd = "$mkdir_cmd $trash_can_dir";
   @run_shell     = solve_slash("$cmd");
   if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
   $rc = 0xffff & system (@run_shell);
   if ( $rc != 0 )
    {
      $perl_line = __LINE__;
      dialog_box(3,"ERROR $perl_line:$bell# Unable to : $cmd ");
      exit  (10 );
    }
}


# Create a Subversion directory one-up from cwd
if ( $os eq "unix" )
{
 $dir = "../subversion";
 if ( -e $dir )
 {
 }
else
{
   $cmd = "$mkdir_cmd $dir";
   @run_shell     = solve_slash("$cmd");
   if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
   $rc = 0xffff & system (@run_shell);
   if ( $rc != 0 )
   {
     $perl_line = __LINE__;
     dialog_box(3,"ERROR $perl_line:$bell# Unable to : $cmd ");
   }
  open( output_file , ">" . "$dir/setup.sh" );
  push @str_ary,"svnadmin create repos";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;

  open( output_file , ">" . "$dir/import.sh" );
  @str_ary = ();
  push @str_ary,"# Import directories into Subversion";
  push @str_ary,"svn import ../src    file://`pwd`/repos/src    -m 'import'";
  push @str_ary,"svn import ../xilinx file://`pwd`/repos/xilinx -m 'import'";
  push @str_ary,"# Move Original directories here for safe keeping";
  push @str_ary,"mkdir orgs";
  push @str_ary,"mv  ../src    ./orgs";
  push @str_ary,"mv  ../xilinx ./orgs";
  push @str_ary,"# Checkout the the Mainline src from Subversion into ./src";
  push @str_ary,"svn checkout -r HEAD file://`pwd`/repos/src    ../src";
  push @str_ary,"svn checkout -r HEAD file://`pwd`/repos/xilinx ../xilinx";
  push @str_ary,"# Now copy original files back in to preserve timestamps";
  push @str_ary,"/bin/cp -r -p ./orgs/src/*    ../src/";
  push @str_ary,"/bin/cp -r -p ./orgs/xilinx/* ../xilinx/";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;

  open( output_file , ">" . "$dir/checkin.sh" );
  @str_ary = ();
  push @str_ary,"#!/bin/csh";
  push @str_ary,"svn diff   ../src";
  push @str_ary,"svn status ../src";
  push @str_ary,"svn commit ../src     -m \$1";
  push @str_ary,"svn update ../src";
  push @str_ary,"svn commit ../xilinx  -m \$1";
  push @str_ary,"svn update ../xilinx";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;

  open( output_file , ">" . "$dir/checkout.sh" );
  @str_ary = ();
  push @str_ary,"# replace HEAD with 2 for Revision 2 etc";
  push @str_ary,"mkdir ./restored";
  push @str_ary,"svn checkout -r HEAD file://`pwd`/repos/src    ./restored/src";
  push @str_ary,"svn checkout -r HEAD file://`pwd`/repos/xilinx ./restored/xilinx";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;

  open( output_file , ">" . "$dir/log.sh" );
  @str_ary = ();
  push @str_ary,"svn log ../src";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;

  open( output_file , ">" . "$dir/README.txt" );
  @str_ary = ();
  push @str_ary,"Step-1) source setup.sh to create subversion repository";
  push @str_ary,"Step-2) source import.sh to import src and xilinx directories";
  push @str_ary,"Step-3) inside ChipVault press <a> to archive to repository";
  foreach $_ ( @str_ary ) { print output_file "$_\n"; }
  close output_file;
# OY
} # if doesnt exist
} #if ( $os eq "unix" )


# Now Load the User Preferences
  push @pre_trace_opened, "Reading User INI File...\n";
  read_user_ini(); # Yuck. Call this twice, 1st time for Editor Selection
                   # but the HLIST hasn't been read in yet, so checksum fails

# [pdf_break]
# [pdf_text_size] 20
# User Definable Editor and Tool Assignment:
# [pdf_text_size] 10
# [pdf_line_number]
########################################

$j=1;
# Note : enforce_checkouts will only check for tool#2 being used against
#        a non WIP file, so the 1st tool assigned after this "Edit Tools"
#        label will be the only one checked.
#                 ----Display-----       # -- UNIX Command --
####################################################################
 push @pre_trace_opened, "Defining Tools...\n";
# @my_tool[$j++] = "- Edit Tools ---------  #                   ";
@my_tool[$j++] = "- Editors ------------  #                   ";


## Assign your editor and Tools Here             
if ( 
     ( ( $my_editor_unix_bin eq "" )  && ( $os eq "unix" ) ) ||
     ( ( $my_editor_win32_bin eq "" ) && ( $os eq "win32" ) )
   )
 {
   # $def_editor = "emacs";
   if ( $os eq "unix" ) { $def_editor = "vi"; } 
    else  { $def_editor = "c:\\vim\\gvim.exe -c \"set lines=$vim_lines\""; }

   print STDOUT "Please select your default editor\n";
   print STDOUT "(ie 'vi<enter>' or 'emacs<enter>'\n";
   print STDOUT "NULL<enter> will select $def_editor.\n";
   $rts = my_get_line();
   chomp $rts;

   if ( $os eq "unix" )
    {
     if ( $rts eq "" )  { $my_editor_unix_bin = $def_editor;} 
     else               { $my_editor_unix_bin = $rts ; }
    }
   else
    {
     if ( $rts eq "" )  { $my_editor_win32_bin = $def_editor;} 
     else               { $my_editor_win32_bin = $rts ; }
    }

   print STDOUT "Thank You. Your default editor is now ";
   print STDOUT "$my_editor_bin and will be saved in your";
   print STDOUT "$user_ini_file file.";
 }# if ( $my_editor eq "" )

if ( $os eq "unix" )
 {
  if ( $os_title eq "linux" )
   {
    # Assume VIM
    # $my_editor = " " . $my_editor_unix_bin . " -c \"set noeb\" -c \"set vb t_vb=\" ";
    $my_editor = " " . $my_editor_unix_bin . " "; # Assume Vanilla Vi or Emacs
     @my_tool[$j++] = " Edit               <e> # $my_editor +LINE_NUM FILE_NAME";
   }
  else
   {
    $my_editor = " " . $my_editor_unix_bin . " "; # Assume Vanilla Vi or Emacs
    @my_tool[$j++] = " Edit               <e> # $my_editor +LINE_NUM FILE_NAME";
   }


  if ( $my_editor_unix_bin eq "vi" )
  {
   @my_tool[$j++] = " Edit ReadOnly       # $my_editor +LINE_NUM -R FILE_NAME";
   $read_only_viewer = $j-1;
  }
  else
  {
   @my_tool[$j++] = " Edit ReadOnly       # less +LINE_NUM FILE_NAME";
   $read_only_viewer = $j-1;
  }


#  $macro_hash  { ord( "e" ) } = $j-1; # Assign a Macro Key to Tool
 }
else
 {
  $my_editor = " " . $my_editor_win32_bin . " "; 
  @my_tool[$j++] = " Edit               <e> # $my_editor FILE_NAME";
  @my_tool[$j++] = " Edit ReadOnly          # $my_editor FILE_NAME";
  $read_only_viewer = $j-1;
 }

$macro=0;
@tool_macro[$macro++] = $j-1 ;           # PreLoad Macro with Editor

@my_tool[$j++]=" cv_viewer        (int)    <v>    # cv_viewer ";
@tool_macro[$macro++] = $j-1 ;                      # PreLoad Macro 
@my_tool[$j++]=" cv_rtl_viewer    (int)           # cv_rtl_viewer ";
@tool_macro[$macro++] = $j-1 ;            # PreLoad Macro 
@my_tool[$j++]=" Edit_fork_xterm+vi               # xterm -T ChipVault-FILE_NAME -e vi FILE_NAME & ";  
@my_tool[$j++]=" Edit_Vi-Text                     # vi           FILE_NAME";
@my_tool[$j++]=" Edit_Emacs-Text                  # emacs -nw    FILE_NAME";
@my_tool[$j++]=" Edit_Emacs-GUI                   # emacs        FILE_NAME";
@my_tool[$j++]=" Edit_DOS_Vim                     # c:\\vim\\gvim.exe FILE_NAME";
@my_tool[$j++]=" Edit_log_file                    # $my_editor $log_file ";
@tool_macro[$macro++] = $j-1 ;                      # PreLoad Macro 


# Note: This Number of leading - dashes designates the hierarchy of
#       the folders. The 1st space after the last - dash is important!
####################################################################
## Note: A word about key bindings. A tool key binding is like <a>
#        which binds the "a" key to the specified tool. If you want
#        to use a Tk button, but not have a key bindiny, declare
#        a non-key value for the hash table to lookup. My example
#        is <0x01> for check_out and <0x02> for check_in. These can
#        actually be any non-key values as long as they are unique
####################################################################
$tee = " | tee $slog_file >> $log_file "; # Generate Standard Logs using tee

@my_tool[$j++]="- RTL Tools  ------------        #                   ";
@my_tool[$j++]=" cv_rtl_analyzer  (int)    <R>    # cv_rtl_analyzer ";
@my_tool[$j++]="--  Library Tools --------        #                   ";
@my_tool[$j++]=" check_out      (int)    <0x01>   # check_out";
@tool_macro[$macro++] = $j-1 ;
@my_tool[$j++]=" check_in       (int)    <0x02>   # check_in";
@tool_macro[$macro++] = $j-1 ;
@my_tool[$j++]=" check_abandon  (int) <del>       # check_abandon";
@my_tool[$j++]=" check_restore  (int)             # check_restore";
@my_tool[$j++]=" check_in_out   (int) <tab> <ins> # check_in_out";    
@my_tool[$j++]=" archive_to_rcs   (int)    <a>    # archive_to_rcs";
# @my_tool[$j++]=" Diff_COd_file (results) <ins>    # diff FILE_NAME " . 
#                    $wip_header . "FILE_NAME $tee";
@my_tool[$j++]=" Diff_COd_file (results) <end>    # diff " 
                  . "FILE_NAME FILE_NAME_NO_WIP $tee";
@my_tool[$j++]="--  Issue Tracking -------        #                   ";
@my_tool[$j++]=" Issue_List_Add  (int)            # Issue_List_Add";
@my_tool[$j++]=" Issue_List_View (int)    <0x04>  # Issue_List_View";
@my_tool[$j++]=" Issue_List_Modify                # $my_editor $issue_file ";
@my_tool[$j++]="--  RTL Generation -------        #                   ";
@my_tool[$j++]=" generate_VHDL  (int)     <0x05>  # generate_VHDL";
@my_tool[$j++]=" generate_Verilog (int)   <0x06>  # generate_Verilog";
@my_tool[$j++]="--  Port Viewing ----             #                   ";
@my_tool[$j++]=" port_view_parent (int)    <p>    # port_view_parent  ";
@my_tool[$j++]=" port_view_kids   (int)    <b>    # port_view_kids    ";
@my_tool[$j++]="--  ShowMe ---------------        #                   ";
@my_tool[$j++]="--- ShowMe VHDL for ------        #                   ";
@my_tool[$j++]=" Reserved Word List        (int)  # showme vhdl_words     ";
@my_tool[$j++]=" Complete Module           (int)  # showme vhdl_module    ";
@my_tool[$j++]=" Clocked Process           (int)  # showme vhdl_clk       ";
@my_tool[$j++]=" CASE Statement            (int)  # showme vhdl_case      ";
@my_tool[$j++]=" Signal Declarations       (int)  # showme vhdl_signal_dec";
@my_tool[$j++]=" Finite State Machine      (int)  # showme vhdl_fsm       ";
@my_tool[$j++]=" Inferrable Synch RAM      (int)  # showme vhdl_ram_infer ";
@my_tool[$j++]=" Component Instantiation   (int)  # showme vhdl_instant   ";
@my_tool[$j++]=" Verilog versus VHDL Ops   (int)  # showme veri_vs_vhdl_ops";
@my_tool[$j++]="--- ShowMe Verilog for ---        #                       ";
@my_tool[$j++]=" Reserved Word List        (int)  # showme veri_words     ";
@my_tool[$j++]=" Complete Module           (int)  # showme veri_fsm       ";
@my_tool[$j++]=" Clocked Process           (int)  # showme veri_clk       ";
@my_tool[$j++]=" CASE Statement            (int)  # showme veri_fsm       ";
@my_tool[$j++]=" Finite State Machine      (int)  # showme veri_fsm       ";
@my_tool[$j++]=" Signal Declarations       (int)  # showme veri_signal_dec";
@my_tool[$j++]=" Verilog versus VHDL Ops   (int)  # showme veri_vs_vhdl_ops";
@my_tool[$j++]="- Release_Tools ----------        #                   ";
@my_tool[$j++]=" archive_release       (hier_exp) # tar -rvf $archive_release_path/LABEL_RELEASE.tar FILE_LIST >> $log_file";
# @my_tool[$j++]=" archive_release       (list)     # tar -rvf $archive_release_path/LABEL_RELEASE.tar FILE_LIST >> $log_file";
@my_tool[$j++]=" label_release  (int)             # label_release";    

#@my_tool[$j++]=" create_branch (int)              # create_branch";
####################################################################

@my_tool[$j++]="- EDA Tools ------------          #                   ";
@my_tool[$j++]="-- ModelSim    ------------       #                   ";
## Note: The following are ModelSim specific Configurations. Change accordingly
 if ( $mti_work_path eq "" )
 {
  $mti_work_path="../modelsim/". $my_name ."/work"; #Relative Path to MTI 
  $ENV{"MODELSIM"} = substr($mti_work_path,0,-4)."modelsim.ini";# Set ini loc
 }

if ( $os eq "unix" )
 {
@my_tool[$j++] = " Vcom    (results)(hier)    <c>   # vcom -explicit FILE_NAME -work $mti_work_path $tee";
@my_tool[$j++] = " Build MTI Work Directory (int)   # build_vlib";

@my_tool[$j++] = " Vsim_Simulate                    # vsim MOD_NAME -lib $mti_work_path $tee";

 }
else
 {
@my_tool[$j++] = " Compile (hier)         # d:\\mti5.4e\\win32\\vcom.exe  FILE_NAME -work $mti_work_path >> $log_file ";
@my_tool[$j++] = " Simulate               # d:\\mti5.4e\\win32\\vsim.exe MOD_NAME -lib $mti_work_path >> $log_file ";
  }

@my_tool[$j++]="-- Cadence     ------------       #                   ";
@my_tool[$j++]=" TBD     (results)(hier)          # foo FILE_NAME $tee";
@my_tool[$j++]="-- Synopsys    ------------       #                   ";
@my_tool[$j++] = " Synthesize (fork)(hier)(results) # synth.sh MOD_NAME $tee";
@my_tool[$j++]="-- GCC         ------------       #                   ";
@my_tool[$j++]=" C-Compile (results)(hier)        # gcc -c FILE_NAME $tee";
@my_tool[$j++]=" C-Linker  (results)              # link.sh $tee";
@my_tool[$j++]="-- Misc        ------------       #                   ";
@my_tool[$j++]=" block_print   (hier)(int)        # block_print";


####################################################################
@my_tool[$j++] = "- UNIX Tools ------------        #                   ";
@my_tool[$j++] = " View_All_Processes   (results)   # ps -aux $tee";
@my_tool[$j++] = " View_My_Processes    (results)   # ps -ux $tee";
@my_tool[$j++] = " View_Disk_Quota  (results)       # quota -v $tee";
@my_tool[$j++] = " Execute_Script (results)  <x>    # FILE_NAME $tee";
@my_tool[$j++] = " UNIX_Shell (fork)                # xterm -T UNIX_Shell &";  
# @my_tool[$j++] = " UNIX Shell (fork)      # gnome-terminal -sdf-name UNIX_Shell >> $log_file &";  


@my_tool[$j++] = " Make_TarBall (hier_exp)(results) # tar -rvf PARAM1.tar FILE_LIST $tee";
$my_tool_param{($j-1)} = "#PARAM1 = Tar File Name (no ext, ie foo)#:";

@my_tool[$j++] = " View_TarBall (results)           # tar -tf PARAM1.tar $tee";
$my_tool_param{($j-1)} = "#PARAM1 = Tar File Name (no ext, ie foo)#:";

@my_tool[$j++] = " File_List (hier)(results)        # ls -l FILE_NAME $tee";

####################################################################
@my_tool[$j++] = " Grep (hier)(results)             # grep PARAM1 FILE_NAME $tee";
$my_tool_param{($j-1)} = "#PARAM1 = Search Pattern :".
                         "";

####################################################################
if ( $admin_hash{$my_name} == 1 )
  {
@my_tool[$j++] = "--  Admin Tools -------           #                   ";
@my_tool[$j++] = " chmod_ReadOnly (hier)            # chmod a-w FILE_NAME >>$log_file";
@my_tool[$j++] = " chmod_ReadWrite (hier)           # chmod a+w FILE_NAME >>$log_file";
 
  } # Note: These tools only show up for 'admin' users

####################################################################
# ... Insert more tools here:
@my_tool[$j++] = "- User Defined ----------        #                   ";
@my_tool[$j++]=" a_user_tool                      # a_user_tool FILE_NAME";
@my_tool[$j++]="--  Example Ext Tools ----        #                   ";
@my_tool[$j++]=" InsertNet in VHDL(hier)          # insert_net.pl FILE_NAME FILE_NAME PARAM1 PARAM2 PARAM3";
# This Describes the params that the above tool needs:
$my_tool_param{($j-1)} = "#PARAM1 = Net Name      (ie foo)   :".
                         "#PARAM2 = Net Direction (ie inout) :".
                         "#PARAM3 = Net Width     (ie 32)    :".
                         "";

####################################################################
@my_tool[$j++]="- CV_Options        --            #                   ";
@my_tool[$j++]="--  Display Options ---           #                   ";
@my_tool[$j++]=" rotate_view     (int)    <0x07>  # rotate_view       ";
@my_tool[$j++]=" rotate_style     (int)           # rotate_style      ";
@my_tool[$j++]=" rotate_x_scale   (int)           # rotate_x_scale    ";
@my_tool[$j++]=" resize_display   (int)    <r>    # resize_display    ";
@my_tool[$j++]=" split_display_size_adj (int) <S> # split_display_size_adj ";
@my_tool[$j++]=" split_display_mode_adj (int) <s> # split_display_mode_adj ";
@my_tool[$j++]=" change_color     (int)           # change_color      ";
@my_tool[$j++]="--  Configuration Options    --   #                   ";
@my_tool[$j++]=" List User Variables (int)        # list_user_vars    ";
@my_tool[$j++]=" View User INI File               # $my_editor $user_ini_file";
@my_tool[$j++]="--  CV Debug+Develop         --   #                   ";
@my_tool[$j++]=" Enable Trace Log    (int)        # enable_trace_log";
@my_tool[$j++]=" View Trace Log                   # $my_editor $trace_file";
@my_tool[$j++]=" Expand_CV_Source    (int)        # expand_cv_source  ";
@my_tool[$j++]="--  Contact ChipVault             #                   ";
@my_tool[$j++]=" Send_Author_Email (int)          # Send_Author_Email ";
@my_tool[$j++]=" Web to chipvault.sourceforge.net # $browser chipvault.sourceforge.net ";
# @my_tool[$j++]="--"; # This is a Pragma to set the level
@my_tool[$j++]=" about            (int)           # about             ";
####################################################################
@my_tool[$j++]="-"; # This is a Pragma to set the level back to root
@my_tool[$j++]=" View Long Log File               # $my_editor $log_file";
@my_tool[$j++]=" View Short Log File              # $my_editor $slog_file";
@my_tool[$j++]=" tool_menu        (int)    <t>    # tool_menu         ";
@my_tool[$j++]=" help             (int)    <h>    # help              ";
@my_tool[$j++]=" quit             (int)    <q>    # quit              ";
# [pdf_off]

@my_tool[0]    = $j  ; # Pointer to the Last Tool (allows -- wrap )
####################################################################
$tool_help_hash{"check_in"}          ="Renames " . $wip_header ."FILE_NAME ".
                                     "#to FILE_NAME and prompts for a change ".
                                     "#log entry." ;
$tool_help_hash{"check_out"}         ="Copies FILE_NAME to " . $wip_header .
                                     "#FILE_NAME which you may then edit.";
$tool_help_hash{"check_in_out"}      ="Performs either check_in or check_out" .
                                     "#depending on cursor position. Usually ".
                                     "#this is bound to <tab> or <ins> keys.";

$tool_help_hash{"check_abandon"}     ="Deletes " . $wip_header ."FILE_NAME ".
                                     "#, abandoning any changes. This is ";
                                     "# bound to <del> key on Linux.     ";
$tool_help_hash{"check_restore"}     ="Extracts a file from the TAR archive".
                                     "#and makes it the current WIP file.".
                                     "#This will popup a scroll box with ".
                                     "#all the archived copies of the    ".
                                     "#selected file displayed. Select   ".
                                     "#the desired version and it will be".
                                     "#automatically deTARd and made WIP.";
$tool_help_hash{"Diff_COd_file"}     ="Compares " . $wip_header ."FILE_NAME ".
                                     "#to FILE_NAME and displays any deltas.".
                                     "#using UNIX diff.".
                                     "#Place Cursor on mainline file for ".
                                     "#this operation.                   ";

$tool_help_hash{"help"}              ="Displays on-line help documentation.";

$tool_help_hash{"port_view_parent"}  ="Creates and displays a schematic port ".
                                     "#view representation of selected block. ".
                                     "#Useful for rapidly exploring a design ".
                                     "#for getting a feel of the hierarchy ".
                                     "#interconnection.";
                 
$tool_help_hash{"port_view_kids"}    ="Creates and displays a schematic port ".
                                     "#view representation of all the ".
                                     "#children of the selected block.";
$tool_help_hash{"rotate_view"}       ="By default, each module block is " .
                                     "#displayed as the module name (foo). " .
                                     "#This function rotates thru alternate ".
                                     "#display names (foo.v, u_foo).";
$tool_help_hash{"split_display_size_adj"} ="Changes the split screen display " .
                                     "#settings for simultaneously showing " .
                                     "#hierarchy view and port view.";
$tool_help_hash{"split_display_mode_adj"} ="Changes the split screen display " .
                                     "#mode from displaying Ports to Log   " .
                                     "#files.";
$tool_help_hash{"rotate_style"}      ="Change the display style, ie:       ".
                                     "# [+] foo                            " .
                                     "#  \\   bar                          " .
                                     "#                                    " .
                                     "#  +  foo                            " .
                                     "#       bar                          " ;
$tool_help_hash{"rotate_x_scale"}    ="Change the spacing between module   ".
                                     "# hierarchy, ie:                     " .
                                     "# [+] foo                            " .
                                     "#      bar                           " .
                                     "#       yoyo                         " .
                                     "#                                    " .
                                     "# [+] foo                            " .
                                     "#          bar                       " .
                                     "#               yoyo                 " .
                                     "#                                    " ;
$tool_help_hash{"enable_trace_log"}  ="Turns on Software Tracing. This logs   ".
                                     "#CV events to trace file for debugging.";
$tool_help_hash{"tool_menu"}         ="Displays the tool_menu, allowing for a ".
                                     "#tool to be selected via a scroll list.";

$tool_help_hash{"list_user_vars"}    ="Displays a list of User Definable Perl ".
                                     "#variables in the CV source code.      ";

$tool_help_hash{"resize_display"}    ="This is used for resizing CV window " .
                                     "#size to match the size of your Xterm ".
                                     "#on OS's which are able to detect your ".
                                     "#Xterm size automatically. By setting  ".
                                     "#the variable dynamic_resize_checking,".
                                     "#CV will autoadjust on every keystroke.".
                                     "#This feature can be slow on some OS's,".
                                     "#so the default is to require manual ".
                                     "#resizing.";
$tool_help_hash{"quit"}              ="Quits ChipVault.";

$tool_help_hash{"label_release"}     ="This is used for annotating which " .
                                     "#version of a source file belongs to a ".
                                     "#release. Activating the label_release ".
                                     "#command will prompt for a release ".
                                     "#label, which is then applied to the ".
                                     "#change history log for each file ";
$tool_help_hash{"archive_release"}   ="This generates a TAR file with the ".
                                     "#name of the label_release. The TAR ".
                                     "#file generated contains all of the ".
                                     "#files in the hlist.";
$tool_help_hash{"create_branch"}     ="This creates a subdirectory with the ".
                                     "#name of the label_release. All of the ".
                                     "#files in the hlist are then copied ".  
                                     "#into this subdirectory. If the " .
                                     "#variable gzip_branched_files is set, ".
                                     "#the files will be gzipped w/o prompt.";

$tool_help_hash{"Issue_List_Add"}    ="This allows the user to log an issue ".
                                     "#against a module in a design. ".
                                     "#ChipVault generates a $issue_file ".
                                     "#which contains a database of all  ".
                                     "#issues logged. The user can then  ".
                                     "#sort and search on issues. ";

$tool_help_hash{"Issue_List_View"}   ="This allows the user to view and sort ".
                                     "#all issues that have been logged.";

$tool_help_hash{"Issue_List_Modify"} ="This launches the default editor on ".  
                                     "#the issue database file $issue_file so ".
                                     "#that it may be manually altered.";

$tool_help_hash{"generate_VHDL"}     ="This generates a template VHDL file. ".  
                                     "#The user is prompted to enter ports to ".
                                     "#be added to the template. When ".
                                     "#activated on an existing module, the ".
                                     "#user has the option of instantiating ".
                                     "#the existing module inside the newly ".
                                     "#generated module. This feature is a  ".
                                     "#tremendous time saver by automating ".
                                     "#structural RTL entry.";

$tool_help_hash{"generate_Verilog"}  ="This generates a template Verilog file.".
                                     "#The user is prompted to enter ports to ".
                                     "#be added to the template. When ".
                                     "#activated on an existing module, the ".
                                     "#user has the option of instantiating ".
                                     "#the existing module inside the newly ".
                                     "#generated module. This feature is a  ".
                                     "#tremendous time saver by automating ".
                                     "#structural RTL entry.";

$tool_help_hash{"InsertNet"}         ="This is an example of how ChipVault can".
                                     "# be used for launching other tools. " .
                                     "#ChipVault can be configured to prompt ".
                                     "#and pass along parameters to other ".
                                     "#tools.";

$tool_help_hash{"Compile"}           ="This is used for compiling a single ".
                                     "#file or optionally perform a bottom " .
                                     "#up compile of an entire design. By ".
                                     "#collapsing all children, only the ".
                                     "#selected file is compiled.";

$tool_help_hash{"Simulate"}          ="Launches an external simulator.";

$tool_help_hash{"Synthesize"}        ="This is used for synthesizing a single ".
                                     "#file or optionally perform a bottom " .
                                     "#up synthesis of an entire design. By ".
                                     "#collapsing all children, only the ".
                                     "#selected file is synthesized.";
$tool_help_hash{"Execute_Script"}    ="This is used for executing a file in ".
                                     "#the hlist which is a script.";
$tool_help_hash{"C-Compile"}         ="This is used for compiling a single ".
                                     "#C file or optionally perform a bottom " .
                                     "#up compile of an entire design. By ".
                                     "#collapsing all children, only the ".
                                     "#selected file is compiled.";
$tool_help_hash{"C-Link"}            ="This is used for linking a C based  ".
                                     "#design into an executable file.";
$tool_help_hash{"expand_cv_source"}  ="This builds a text file of each Perl ".
                                     "#function inside the CV Source.";
$tool_help_hash{"build_vlib"}        ="This builds a ModelSim work directory".
                                     "#which is unique for each user.";
$tool_help_hash{"block_print"}       ="This generates a PDF document of ".
                                     "#schematic port views for all modules.";
$tool_help_hash{"UNIX_Shell"}        ="This spawns a UNIX Xterm shell.";
$tool_help_hash{"Create_TarBall"}    ="This creates a TAR file containing a ".
                                     "#portion of a hlist.";
$tool_help_hash{"View_TarBall"}      ="This views the contents of a TAR file.";
$tool_help_hash{"File_List"}         ="UNIX ls on a file to retrieve attribs.";
$tool_help_hash{"Grep"}              ="Grep one or more files with a pattern.";
$tool_help_hash{"chmod_ReadOnly"}    ="UNIX chmod";
$tool_help_hash{"chmod_ReadWrite"}   ="UNIX chmod";

#############################################
## Setup a Hash Table for Tool Shortcut Keys
#############################################
  for( $i = 1; $i < @my_tool[0] ; $i++ )
   {
       ($tool_str,$tool_exe,$ETC )=split('#',@my_tool[$i], 3);

#       ($preETC,$tool_key,$ETC )=split('<',$tool_str,3); # Parse <a>
#       ($tool_key,$ETC )=split('>',$tool_key,2);         # Parse <a>
#       if ($tool_key ne "" )
#        {
#         # Either a key ie <a> or a hash ie <0x01>
#         if ( length ($tool_key) == 1 ) { $macro_hash{ ord($tool_key)} = $i; }
#         else                           { $macro_hash{     $tool_key } = $i; }
#        } # if tool_key 

# FOOBAR
     $tmp_tool_str = $tool_str;
     do
      {
       ($preETC,$tmp_tool_str)=split('<',$tmp_tool_str,2);   # Parse out <a>
       ($tool_key,$tmp_tool_str)=split('>',$tmp_tool_str,2); # Parse <a>
       if ($tool_key ne "" )
        {
         # Either a key ie <a> or a hash ie <0x01>
         if ( length ($tool_key) == 1 ) { $macro_hash{ ord($tool_key)} = $i; }
         else                           { $macro_hash{     $tool_key } = $i; }
         ($tmp, $null) = split(' ', @my_tool[$i],2) ;
         push @pre_trace_opened, "Binding Key $tool_key to Tool $tmp\n";
        } # if tool_key 
      } until ( $tool_key eq "" );

   } # for ( $i = 1; $i < @my_tool[0] ; $i++ )

$edit_sel = 1; # 1st Tool Selected is...
($tool_str, $tool_exe, $ETC ) = split ('#', @my_tool[$edit_sel] , 3);
# Hide the tool_str options
($tool_str, $ETC ) = split (' ', $tool_str , 2 ); # NEW 12-09

# $help_str1 =  "<h>elp  <q>uit  <ENTER>=Exe  <1>.<9><SPACE>=Exp/Clps";
# $help_str1 = $help_str1 . "  Cursor=<ijkl> Ports=<p,P>";

# $help_str1 =  "<h>elp    <ENTER>=ExeTool    <1>.<9><SPACE>=Exp/Clps";
# $help_str1 = $help_str1 . "    Cursor=<ijkl>     <q>uit";
$help_str1 =  "<h>elp   <ENTER>=ExeTool   <SPACE>=Exp/Clps  <TAB>=Ci/Co";
$help_str1 = $help_str1 . "  <ijkl>=Cursor   <q>uit";

$help_str2 =  "<t>ool=".substr($tool_str,0,20);


########################################
## Make your Own Key Assignments Here
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
 $k_nav_up_hash    { $k_up } = 1;
 $k_nav_up_hash    { ord( "i" ) } = 1;

 $k_nav_dn_hash    { $k_dn } = 1;
 $k_nav_dn_hash    { ord( "k" ) } = 1;

 $k_nav_lf_hash    { $k_lf } = 1;
 $k_nav_lf_hash    { ord( "j" ) } = 1;
 $k_tool_help      { ord( "h" ) } = 1;

 $k_nav_rt_hash    { $k_rt } = 1;
 $k_nav_rt_hash    { ord( "l" ) } = 1;
 $k_search_dn_hash { ord( "/" ) } = 1;
 $k_search_up_hash { ord( "?" ) } = 1;

 $k_enter_hash     { $k_cr  }     = 1;
 $k_enter_hash     { $k_mouse_double_click_edit } = 1;
 $k_hist_hash      { ord( "!" ) } = 1;
 $k_macro_hash     { ord( "@" ) } = 1;
 $k_togl_hash      { $k_sp  } = 1;
 $k_togl_hash      { $k_mouse_double_click_togl } = 1;
 $k_debug_hash     { ord( "d" ) } = 1;
 $k_test_hash      { ord( "u" ) } = 1;
 $k_pg_up_hash     { $k_ctrl_u  } = 1;
 $k_pg_dn_hash     { $k_ctrl_d  } = 1;

 $k_split_up_hash     { ord( "a" ) } = 1;
 $k_split_dn_hash     { ord( "z" ) } = 1;
 $k_split_pg_up_hash  { ord( "A" ) } = 1;
 $k_split_pg_dn_hash  { ord( "Z" ) } = 1;

#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
########################################

# [pdf_on]
# [pdf_break]
# [pdf_text_size] 20
# User Definable Report File Associations:
# [pdf_text_size] 10
# [pdf_line_number]
##################################################
## Define Reports to View in right columns
##################################################
$j=2; # Note. 0&1 taken already for Source
##################
$report_filename_title [ $j   ] = "File Modification Time Stamp"; # Title
$report_function       [ $j   ] = "time_stamp";
$report_filename_rule  [ $j++ ] = "FILE_NAME";
##################
$report_filename_title [ $j   ] = "HistoryLog";  # Title
$report_filename_rule  [ $j++ ] = $hist_log_header."FILE_NAME".$hist_log_footer;
##################
$report_filename_title [ $j   ] = "TAR-Ball Archive List";  # Title
$report_filename_rule  [ $j++ ] = $tar_list_header ."FILE_NAME".$tar_list_footer;
##################
$report_filename_title [ $j   ] = "Synopsys Netlist"; # Title
$report_filename_rule  [ $j++ ] = "../synopsys/map/vhdl/MOD_NAME.vhd";
##################
$report_filename_title [ $j   ] = "Synopsys Area Report"; # Title
$report_filename_rule  [ $j++ ] = "../synopsys/report/MOD_NAME.area.report";
##################
$report_filename_title [ $j   ] = "Gate Estimate Analysis"; # Title
$report_function       [ $j   ] = "gate_estimate";
$report_filename_rule  [ $j++ ] = "../synopsys/report/MOD_NAME.area.report";
##################
$report_filename_title [ $j   ] = "Flip-Flop Count Analysis"; # Title
$report_function       [ $j   ] = "flop_count";
$report_filename_rule  [ $j++ ] = "../synopsys/map/vhdl/MOD_NAME.vhd";
##################
$report_filename_title [ $j   ] = "Worst Slack Analysis"; # Title
$report_function       [ $j   ] = "worst_slack";
$report_filename_rule  [ $j++ ] = "../synopsys/report/MOD_NAME.verbosetiming.report";
##################
$report_filename_title [ $j   ] = "Synopsys Timing Report"; # Title
$report_filename_rule  [ $j++ ] = "../synopsys/report/MOD_NAME.verbosetiming.report";
##################
$report_filename_title [ $j   ] = "Synopsys Timing Report"; # Title
$report_filename_rule  [ $j++ ] = "../synopsys/report/MOD_NAME.registertiming.report";
##################
# [pdf_off]

# [pdf_on]
# [pdf_break]
# [pdf_text_size] 20
# User Definable VHDL Template:
# [pdf_text_size] 10
# [pdf_line_number]
############################################################################
## This is the VHDL Template. Go ahead and change everything but the #T's    
############################################################################
#T-- *****************************************************************************
#T-- (C) Copyright 2006 #COMPANY_NAME#
#T-- All rights reserved.
#T--
#T-- Source file: #FILENAME#
#T-- Date:        #DATE#
#T-- Author:      #AUTHOR#
#T-- Description: #DESCRIPTION# 
#T--
#T-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY        
#T-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT           
#T-- LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND   
#T-- FITNESS FOR A PARTICULAR PURPOSE.                           
#T--
#T-- In no event will the Author, Kevin M. Hubbard be liable for direct, 
#T-- indirect, special, incidental, or consequential damages resulting from the
#T-- use of this RTL template, even if advised of the possibility of such damages.
#T--
#T-- Use of this RTL template in the design or control of machinery involved in 
#T-- 'HIGH-RISK' activities, i.e. activities where failure of this software 
#T-- could reasonably be expected to cause DEATH, INJURY or the RELEASE OF 
#T-- HAZARDOUS MATERIALS, IS NOT PERMITTED.
#T--
#T-- Revision History:
#T-- Ver#  When      Who      What
#T-- ----  --------  -------- ----------------------------------------------------
#T-- 0.1             #AUTHOR# Created.
#T-- *****************************************************************************
#T LIBRARY ieee ;
#T USE ieee.std_logic_1164.all;
#T USE ieee.std_logic_arith.all;
#T USE ieee.std_logic_unsigned.all;
#T-- USE ieee.std_logic_textio.all;
#T-- LIBRARY std ;
#T-- USE std.textio.all;
#T
#T entity #MOD_NAME# is
#T port
#T  (
#T #LOCATION_PORT_DECLARATION_LOCATION#
#T    #SIG_NAME# : #SIG_DIR# #SIG_WIDTH# ;
#T    ETC ETC ETC...............
#T   );
#T
#T end #MOD_NAME#;
#T
#T architecture #ARCH_TYPE# of #MOD_NAME# is
#T
#T --#CHILD_LINE#component #CHILD_NAME# 
#T --#CHILD_LINE#port
#T --#CHILD_LINE# (
#T --#CHILD_LINE#  #LOCATION_CHILDREN_COMPONENT_DECLARATION_LOCATION#
#T --#CHILD_LINE# );
#T --#CHILD_LINE#end component ; -- #CHILD_NAME# 
#T
#T  type state_type is
#T    (
#T      s0_idle,
#T      s1_busy
#T    );
#T
#T type ram_type is array (511 downto 0 ) of std_logic_vector ( 7 downto 0 );
#T attribute state_vector                : string;
#T attribute state_vector of #ARCH_TYPE# : architecture is "current_state" ;
#T signal    current_state, next_state   : state_type ;
#T
#T #LOCATION_SIGNAL_DECLARATION_LOCATION#
#T -- signal #SIG_NAME# : #SIG_WIDTH# ;
#T signal clk                            : std_logic;
#T signal reset                          : std_logic;
#T signal foo                            : std_logic_vector ( 7 downto 0 ) ;
#T signal ram                            : ram_type  ;
#T signal read_addr                      : std_logic_vector ( 8 downto 0 ) ;
#T
#T begin
#T
#T--------------------------------------------------------------------------------
#T-- Process
#T--------------------------------------------------------------------------------
#T foo_proc : process ( clk )
#T begin
#T  if ( clk'event and clk = '1' ) then
#T    if ( reset   = '1' ) then
#T      foo <= ( others => '0' );
#T    else
#T      foo <= foo ( 7 downto 0 );
#T    end if;-- if ( reset   = '1' ) then
#T  end if;-- if ( clk'event and clk = '1' ) then
#T end process foo_proc; 
#T
#T clocked_fsm : process ( clk )
#T begin
#T   if ( clk'event and clk = '1' ) then
#T    if ( reset = '1' ) then
#T      current_state <= s0_idle;
#T    else
#T      current_state <= next_state;
#T    end if;-- reset
#T  end if;-- clk
#T end process clocked_fsm;
#T
#T----------------------------------------------------------------------------
#T-- nextstate assignment based on inputs and current_state
#T----------------------------------------------------------------------------
#T nextstate : process ( current_state , reset )
#T begin
#T  case current_state is
#T      when s0_idle =>
#T        if ( reset = '1' ) then
#T          next_state <= s1_busy;
#T        else
#T          next_state <= s0_idle;
#T         end if;
#T      when others =>
#T         next_state <= s0_idle;
#T  end case;
#T end process nextstate;
#T
#T----------------------------------------------------------------------------
#T-- Infer a RAM for the FPGA guys  
#T----------------------------------------------------------------------------
#T ram_proc : process ( clk )
#T begin
#T  if ( clk'event and clk = '1' ) then
#T   if ( we = '1' ) then
#T     ram(conv_integer(addr) ) <= di  ( 7 downto 0 );
#T   end if; 
#T   read_addr <= addr ( 8 downto 0 );
#T  end if;
#T end process ram_proc;
#T do <= ram ( conv_integer( read_addr ) );
#T   
#T
#T
#T #LOCATION_INSTANTIATE_CHILDREN_LOCATION#
#T
#T end #ARCH_TYPE#;
############################################################################

# [pdf_break]
# [pdf_text_size] 20
# User Definable Verilog Template:
# [pdf_text_size] 10
# [pdf_line_number]
############################################################################
## This is the Verilog Template. Go ahead and change everything but the #V's    
############################################################################
#V// *****************************************************************************
#V// (C) Copyright 2006 #YOUR_COMPANY_NAME#
#V// All rights reserved.
#V//
#V// Source file: #FILENAME#
#V// Date:        #DATE#
#V// Author:      #AUTHOR#
#V// Description: #DESCRIPTION# 
#V//
#V// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY        
#V// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT           
#V// LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND   
#V// FITNESS FOR A PARTICULAR PURPOSE.                           
#V//
#V// In no event will the Author, Kevin M. Hubbard be liable for direct, 
#V// indirect, special, incidental, or consequential damages resulting from the
#V// use of this RTL template, even if advised of the possibility of such damages.
#V//
#V// Use of this RTL template in the design or control of machinery involved in 
#V// 'HIGH-RISK' activities, i.e. activities where failure of this software 
#V// could reasonably be expected to cause DEATH, INJURY or the RELEASE OF 
#V// HAZARDOUS MATERIALS, IS NOT PERMITTED.
#V//
#V// Revision History:
#V// Ver#  When      Who      What
#V// ----  --------  -------- ----------------------------------------------------
#V// 0.1             #AUTHOR# Created.
#V//
#Vmodule #MOD_NAME#(
#V                    #SIG_NAME#,
#V                    #LOCATION_PORT_DECLARATION_LOCATION#
#V                   ETC ETC ETC.....
#V                   );
#V
#V #SIG_DIR# #SIG_WIDTH# #SIG_NAME# ;
#V #LOCATION_SIGNAL_DECLARATION_LOCATION#
#V
#V input         foo_clk ;
#V output        foo_out ;
#V input  [31:0] foo_bus ;
#V reg           foo ;
#V wire          bar ;
#V
#V always @(posedge clk)
#V   begin
#V     foo <= bar ;
#V   end
#V          
#V foo u_foo
#V  (
#V    .clk(                              clk                                ),
#V    .reset(                            reset                              )
#V  );
#V          
#V #LOCATION_INSTANTIATE_CHILDREN_LOCATION#
#V          
#Vendmodule
# [pdf_off]




#############################################################################
# If no ARGV or -H -h -? is passed, display banner as HELP.
#############################################################################
if ( $ARGV[0] =~ /(-h|-\?|-H)/o )
{open( input_file , "<" . $0 ); while ( $_ = <input_file> ) { if ( m/\A#-/o ){print;}}exit;
}
    $interrupted = 0;
    $SIG{INT} = sub { ++$interrupted };
   

############################################################################
# GUI
# CODE_STARTS_HERE
###########################################################################
if ( $ARGV[1] eq "-c" ) 
  { 
   $batch_cmd = $ARGV[2]; 
   $batch_mode = 1;
   print "ChipVault : Batch Mode\n"; 
   main();                     # Main Loop
   print "ChipVault : Done.     \n"; 
  }
  else
  {
   $batch_cmd = "";      
   $batch_mode = 0;
   open( output_file , ">" . $sys_file );
     print output_file "#!/bin/csh\n";
     print output_file "# CV Created System Call File\n";
   close output_file;

   open( output_file , ">" . $log_file );
     print output_file "[NEW_CV_LOG]\n";
   close output_file;
   init();                     # Initialize Term::Cap.
   main();                     # Main Loop
   finish();                   # Clean up afterward.
  }

  exit();

############################################################################
# Main 
###########################################################################
sub main {
  if ( $en_trace == 1 ) { open( trace_file , ">" . "$trace_file" ); } 


  if ( $en_trace == 1 ) 
  { 
    print trace_file "main()\n";
    foreach $_ ( @pre_trace_opened ) { print trace_file $_; }
  }
  if ( $en_trace == 1 )  
   {
     print trace_file "UNIX Environment Variables:\n";
     print trace_file " Term=         ".$ENV{"TERM"       }."\n"; 
     print trace_file " ColorTerm=    ".$ENV{"COLORTERM"  }."\n"; 
     print trace_file " MachType=     ".$ENV{"MACHTYPE"   }."\n"; 
     print trace_file " Display=      ".$ENV{"DISPLAY"    }."\n"; 
     print trace_file " Shell=        ".$ENV{"SHELL"      }."\n"; 
     print trace_file " OSType=       ".$ENV{"OSTYPE"     }."\n"; 
     print trace_file " PWD=          ".$ENV{"PWD"        }."\n"; 
     print trace_file "os_title       ".$os_title          ."\n"; 
   }# if ( $en_trace == 1 )  

  clear_screen(); 

  screen_sizing();

   banner_message( $license_banner );

   if ( $new_version_for_user == 1 ) 
   {
    new_version_message( 10 );
    $newbie = 1;
   }
 #  clear_screen();

 $top_mod   = "";
 $glob_name = "";
 $hlist_name = "";
 $noise_filter = $default_noise_filter;

 ##################################################################
 # Check to see if ARG0 is top.vhd instead of hlist.txt. If it is
 # try and figure out the details and generate a hlist.txt file.
 ##################################################################
 if ((substr($ARGV[0],-2,2) eq ".v") || (substr($ARGV[0],-4,4) eq ".vhd"))
  {
    $rts = dialog_box(-1,"Note: RTL provided instead of hlist.txt         ".
                        "#                                                ". 
                        "# I will attempt to generate a hlist.txt file    ". 
                        "# given the top.vhd file you provided me.        ". 
                        "#                                                ". 
                        "#Note: Next time you run ChipVault, try using the". 
                        "# generated hlist.txt file (default arg). It will". 
                        "# start up much faster. <Press Any Key>          ". 
                        "");
      $glob_name    = $ARGV[0]; # Only look in given file.
      # Find out the top module name.
      if ( $ARGV[1] eq "" )
       {
          $rts = dialog_box(1,
          "Note:                                                         ".
          "#Executing hierarchy_solver.pl to solve who is top module:    ".
          "#Please be patient....(this might take a minute or so).....   ");
        $top_mod = hierarchy_solver( "#"     , $glob_name, $noise_filter,-1 );
       }
      else
       {
        $top_mod = $ARGV[1];
       }

      $noise_filter = 10;

      ( $top_mod =~ s/ //go ); # Remove All white space 
       chomp $top_mod;
      if ( $top_mod eq "#" ) 
        {
         $perl_line = __LINE__;
         $rts = dialog_box(-1, "ERROR $perl_line:# I failed to locate the module name!".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit ( 10 );
        }
      $glob_name = "*.v*"; # Glob Both VHDL and Verilog for Mixed Designs
      clear_screen(); 
      $hlist_name = "hlist.txt"; # Default
      call_hierarchy_solver();
  }
else
  {
   ##################################################################
   # Lets assume we were given either a hlist.txt file , or null    "
   ##################################################################
   $hlist_name = $ARGV[0];
   if ( $hlist_name eq "" ) { $hlist_name = "hlist.txt"; } # Default
 
   if ( -e $hlist_name )
   {
   }# if ( -e $hlist_name )
   else
   { 
     clear_screen(); 
#     build_vlib(); # Assume ModelSim work directories isn't created yet.
     clear_screen(); 
     $rts = dialog_box(-1,
       "WARNING:  Hierarchy List File (hlist.txt) Missing! ".
       "# I was unable to locate a required hlist.txt file.".
       "#If you like, I can attempt to build one for you given enough ".
       "#information. ".
       "#Press <y> to continue on to the hlist generation wizard.     ".
       "#Press <n> to run ChipVault without an hlist.                 ".
       "");
        clear_screen();

      if ( $rts == ord ("y" ) )
       {
        $single_file = dialog_box(-1,
       "WHAT_SHOULD_CV_IMPORT?:".
       "#Press <1> to import a single netlist file:           ie:    ".
       "#     .\\netlist.v                                            ".
       "#Press <2> to import and analyze a collection of RTL files    ".
       "#    in the current directory ( ChipVault will attempt to     ".
       "#    determine the design hierarchy ).                 ie:    ".
       "#     .\\top.vhd                                               ".
       "#     .\\foo.v                                                 ".
       "#     .\\bar.v                                                 ".
       "#Press <3> to import a subdirectory tree of RTL files. ie:    ".
       "#     .\\dir1\\top.vhd                                          ".
       "#     .\\dir1\\foo.v                                            ".
       "#     .\\dir2\\bar.v                                            ".
       "#Press <4> to import a subdirectory tree of all files. ie:    ".
       "#     .\\dir1\\top.vhd                                          ".
       "#     .\\dir1\\top.txt                                          ".
       "#     .\\dir2\\bar.rpt                                          ".
       "");
        clear_screen();

     if ( $single_file == ord ("1" ) || $single_file == ord("2") )
     {
      if ( $single_file == ord ("1" ) )
       {
        $rts = dialog_box(-2,
        "FILE_NAME:".
        "#Please enter the exact file name to read in                  ".
        "");
        clear_screen();
        $glob_name    = $rts[0] ;
       }
      elsif ( $single_file == ord ("2" ) )
       {
        $glob_name    = "*.v*";
        $glob_or_not = dialog_box(-1,
       "FILE_GLOBBING:".                  
       "#By default I will glob on files $glob_name                   ".
       "#Press <y> to Glob on this, or <n> to enter your own glob     ".
       "");
        clear_screen();
        if ( $glob_or_not == ord ("n" ) )
         {
          $rts = dialog_box(-2,
           "GLOB:#".
           "# VHDL/Verilog Files (ie *.v*  or *.vhd )  :");
           $glob_name    = $rts[0] ;
           clear_screen();
         }# if ( $glob_or_not == ord ("n" ) )
       }# if ( $single_file == ord ("1" ) )

      $rts = dialog_box(-2,
        "MODULE_NAME:".
        "#Please enter the name of your top hierarchy module           ".
        "#(this should be 'top' not 'top.vhd' )                        ".
        "");
        clear_screen();
        $top_mod      = $rts[0] ;

       call_hierarchy_solver(); # Generate new hlist.txt file
     }# if ( $single_file == ord ("1" ) || $single_file == ord("2") )
    else
     {
      $rts = dialog_box(1, "Building $hlist_name:#Scanning Subdirectories..");
      if ( $single_file == ord("3") ) { $get_rtl_files_only=1; }
        else                          { $get_rtl_files_only=0; }
      subdir_import( $hlist_name , $get_rtl_files_only );
     }# if ( $single_file == ord ("1" ) || $single_file == ord("2") )

    }#  if ( $rts == ord ("y" ) )
   else
    {
         clear_screen();
         $rts = dialog_box(-1 ,
          "#WARNING: Eventually you'll need a hlist.txt file.            ". 
          "# It should look like this:                                   ".
          "#  top           top.vhd                                      ". 
          "#   bar1         bar1_rtl.vhd                                 ". 
          "#    gabooh      gabooh_struct.vhd                            ". 
          "#    elephant    elephant.vhd                                 ". 
          "#    lunchmeat   lunchmeat.vhd                                ". 
          "#   bar2         bar2_rtl.vhd                                 ". 
          "#  foobee        foobee.v      http://www.remote.com/foobee.v ". 
          "#                                                             ". 
          "#Note: left side space defines the hierarchy structure.       ". 
          "#Note: Any line beginning with a Pound Sign is ignored.       ". 
          "#                   <Press Any Key>                           ");
           clear_screen();
           # exit 0;
     }#  if ( $rts == ord ("y" ) )
    }# if ( -e $hlist_name )
  }# if ((substr($ARGV[0],-2,2) eq ".v") || (substr($ARGV[0],-4,4) eq ".vhd"))



##################################################
# Read in the Hierarchy File
# I'll support 3 types.
# Type-1:
#   top.vhd
#    foo.vhd
# Type-2:
#   top            top.vhd
#    foo           foo.vhd
# Type-3:
#   top            top.c      GOTO_LINE= 515
#    foo           foo.pl     GOTO_TAG= sub foobar
#    bar           bar.v      http://www.remote.com/bar.v
#   ^^  
#    |- Note: These White Spaces are CRITICAL!!!
#
# I prefer Type-2 as it allows for netlist viewing
# even if all modules exist in a single file.
##################################################
#open( input_file , "<" . $hlist_name );
$level      = 0;
$position   = 0;
$last_position = 0;
 $level_hash { 0 } = 0; 
$recursion_cnt = 0;

 # 1st is standard current directory hlist file
 get_hlist( $hlist_name );  

 # 2nd is any library lists specified in a Environment Variable
# $cv_inc = $ENV{"$cv_include_var" };
# while( ( $cv_inc_loc , $cv_inc ) = split(' ',$cv_inc,2) )
# {
#  get_hlist( $cv_inc_loc ); 
# }

 # 3rd is any /home/.cv_include hidden file
# if ( -e  $ENV{"HOME"} . $filecat . $cv_include_file )
# {
#  get_hlist( $ENV{"HOME"} . $filecat . $cv_include_file );
# }

 foreach $_ ( @recurs_array )
{
 
 # Ignore Comment Lines and white-space lines
 if ( 
      ( substr($_,0,1) ne "#") && 
      ( m/\S/ )
    ) 
 {
   $line++;
  @flag_array[ $line ] = 0; # Assume No Children

 ($F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $ETC ) = split (' ', $_ , 10); #Parse
   # This extracts the position of $F1 in $_. See Camel P.199
  ($_ =~ m/$F1/g) ;       # This locates $F1 in $_.
  $position = ( pos $_ ); # This provides position of right side of string
  $position = $position - length($F1) ; # Convert Pos to left side of string

  # Support for "MyLabel" in hlist
  if ( (/"/io ) )
  {
#  $_ =~ s/^\s+|\s+$//g ;# remove both leading and trailing whitespace 
#  ($F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $ETC ) = split (' ',' ',10);
#  $F1 = $_;
   ($F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $ETC ) = split (' ',$_,10);
  }


  if ( $position > $last_position )
    {
      $level++;
      $level_hash { $position } = $level;
      @flag_array[ $line - 1 ] = 1; # Found Children!
    }
  if ( $position == $last_position )
    {
      $level = $level;
    }
  if ( $position < $last_position )
    {
      $level = $level_hash { $position } ;
      if ( $level eq "" )
       { 
        $perl_line = __LINE__;
        dialog_box(-1, "ERROR $perl_line: Invalid hlist.txt file".
                      "#Hierarchy Misalignment in $hlist_name Line=$line !".
                      "#Please fix your hierarchy alignment  in $hlist_name".
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
        exit (-14);
       }
    }

  $last_position = $position;
  # print "$F1 $level " . "\n";
  # Make our DataBase

   ( $F1 =~ s/USER_NAME/$my_name/go );  # Search+Replace Tag
   ( $F2 =~ s/USER_NAME/$my_name/go );  # Search+Replace Tag

   @modname_array    [ $line ] = $F1;
   @filename_array   [ $line ] = $F2;
   @ref_des_array    [ $line ] = $F3;

   if ( $F2 eq "" )
    {
     @filename_array   [ $line ] = $F1;
     @ref_des_array    [ $line ] = $F1;
    }
   
   @arg1_array   [ $line ] = $F2;
   @arg2_array   [ $line ] = $F3;
   @arg3_array   [ $line ] = $F4;
   @arg4_array   [ $line ] = $F5;
   @arg5_array   [ $line ] = $F6;
   @arg6_array   [ $line ] = $F7;
   @arg7_array   [ $line ] = $F8;
   @arg8_array   [ $line ] = $F9;

   @level_array  [ $line ] = $level;   # Which level this module is on 
   @show_array   [ $line ] = 1;        # Default to show entire hierarchy
   @y_loc_array  [ $line ] = $line-1 ; # Position inside Virtual Screen

   @goto_line_array [ $line ] = "";
   @goto_tag_array  [ $line ] = "";
   chomp $_;  
   ($F1, $F2, $F3, $ETC ) = split (' ', $_ , 4); #Parse
   if    ( $F3 eq "GOTO_LINE=" ) { @goto_line_array [ $line ] = $ETC; } 
   elsif ( $F3 eq "GOTO_TAG=" )  { @goto_tag_array  [ $line ] = $ETC; } 

   ###########################################################
   # Generate pointers to report files given provided rules 
   ###########################################################
   for( $x = 2 ; $x < 100; $x++ )
    { 
     $file_name   = $report_filename_rule  [ $x ] ;
     $mod_name    = @modname_array    [ $line ] ;
     $cur_name = @filename_array[$line];
     $cur_name_no_ext = $cur_name;
     ( $cur_name_no_ext =~ m/$path_null(.*)$ext_null/o ); # Strip Path and Ext from File Name

     ( $file_name =~ s/FILE_NAME_NO_EXT/$cur_name_no_ext/go ); # Search+Replace Tag
     ( $file_name =~ s/FILE_NAME/$cur_name/go ); # Search+Replace Tag
     ( $file_name =~ s/MOD_NAME/$mod_name/go ); # NEW: Does this work?
     ( $file_name =~ s/USER_NAME/$my_name/go );  # Search+Replace Tag

     ( $file_name =~ s/ARG1/@arg1_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG2/@arg2_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG3/@arg3_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG4/@arg4_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG5/@arg5_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG6/@arg6_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG7/@arg7_array[$line]/go ); # Search+Replace Tag
     ( $file_name =~ s/ARG8/@arg8_array[$line]/go ); # Search+Replace Tag

     @report_filename [ ($line * 100) + ($x) ] = $file_name; # 2D Array
    }# for( $x = 2 ; $x < 100; $x++ )
 
 }#if ( (substr($_,0,1) ne "#") ) # Ignore Comment Lines
}# while ( $_ = <input_file> )
close input_file;

 $array_size = $line + 1; # KMH NEW 10-17


############################################################
#               Virtual Screen 
#             ____________________ 
#            |                    |   Physcial Screen
#            |                    |   ____________
#            |  View Port         |  |            |
#            |  __________        |  |            |
#            | |          |       |  |            |
#            | |          |       |  |            |
#            | |          |       |  |            |
#            | |__________|       |  |____________|
#            |                    |
#            |____________________|
#############################################################


#    $y_screen_offset     = 2;  # Dont draw Viewport right at Physical 0.
    $y_screen_offset     = $y_screen_start ; 

#    $cur_y = $y_screen_offset ;
    if ( $batch_mode != 1 ) { $redraw = 1; }
    
    $check_for_resizing = 1; # Must do this Once at least
    $force_resize       = 1; # Must do this Once at least
    $cur_x = 0;
    $debug_mode = -1; # OFF 
    $check_wip_status = 1; # See if new WIP files exist 



##################################################
# Loop here till the end of time
##################################################
   $redraw = 1;
   $key_val="";

# Now Load the User Preferences
   read_user_ini(); # Yuck. Call this twice, since no HLIST is present

   $check_for_resizing = 1; 
   screen_sizing();
   clear_screen();
   display_main();
   $redraw = 0;

 do
 {
   $key_val_p1 = $key_val; # Remember for ESC stuff


    # Interactive Mode Wait for Key. Batch Mode, Blast thru once.
    if ( $batch_mode != 1 ) 
      { 
       if ( $new_tool_selected == 1 && $activate_tool_once_selected == 1 ) 
        {  
         $new_tool_selected = 0;
         $key_val = $k_cr ; # Activate the tool just picked
        }
       else
        {
         $key_val = my_get_key(); 
#        print "key_val = $key_val\n"; # HACK
         if    ( $key_val == $k_tab  ) { $key_val = "tab"  ; }
         elsif ( $key_val == $k_del  ) { $key_val = "del"  ; } 
         elsif ( $key_val == $k_del2 ) { $key_val = "del"  ; } 
         elsif ( $key_val == $k_ins  ) { $key_val = "ins"  ; } 
         elsif ( $key_val == $k_end  ) { $key_val = "end"  ; } 
         elsif ( $key_val == $k_end2 ) { $key_val = "end"  ; } 
         elsif ( $key_val == $k_home ) { $key_val = "home" ; } 
         elsif ( $key_val == $k_home2) { $key_val = "home" ; } 
         elsif ( $key_val == $k_esc  ) { $key_val = "esc"  ; }
        }
      }
    else 
      { 
        $key_val = $k_cr ; # Blast thru once and SeeYa 
      }

     process_keys();

  } until $interrupted;
}# sub main()

#############################################################################


##################################################
# Read a hlist file, supporting recursion
#  into other files if [include] flag is found
sub get_hlist {
  my ( $my_file_loc ) = @_;
  my $F1_loc, $F2_loc, $ETC_loc;
  my $line_loc;
  local *file_handle ; # Allows recursion. Camel-pg.51
  dialog_box(0,"NOTE: Reading HLIST $my_file_loc");

  open( file_handle , "<" . $my_file_loc );
  if ($en_trace==1){print trace_file "get_hlist() Time=".localtime(time)."\n";}

  while ( $line_loc = <file_handle> )
  {
   ($F1_loc, $F2_loc, $ETC_loc ) = split(' ', $line_loc , 3 );
   if ( (substr($F1_loc,0,1) ne "#") ) # Ignore Comment Lines
   {
    if ( lc( $F1_loc ) eq "[if_user]" )
     {
      if ( $my_name eq $F2_loc ) 
        {
          $line_loc = $ETC_loc; # Strip away "[if_user] username"
         ($F1_loc, $F2_loc, $ETC_loc ) = split(' ', $line_loc , 3 );
        }# if ( $my_name eq $F2_loc ) 
      else
       {
        $F1_loc = "#"; # Forces following code to ignore line
       }# if ( $my_name eq $F2_loc ) 
     }# if ( lc( $F1_loc ) eq "[if_user]" )
   }# if ( (substr($F1_loc,0,1) ne "#") ) # Ignore Comment Lines

   if ( (substr($F1_loc,0,1) ne "#") ) # Ignore Comment Lines
   {
    if ( lc( $F1_loc ) eq "[include]" )
     {
       $recursion_cnt++;
       if ( $recursion_cnt < 256 )
        {
         get_hlist( $F2_loc );
        }
       else
        {
         print "Self Imposed FileOpen Recursion Limit of 256 Hit!\n";
         exit ( -1 );
        }
     } # if include
    else
     {
       push @recurs_array, $line_loc; # Use Global as I'm LAZY!
     }# if ( lc( $F1 ) eq "[include]" )
   } # if
  } # while
 close file_handle ;
  if ($en_trace==1){print trace_file "            Time=".localtime(time)."\n";}
 return;
} # get_hlist


##################################################
# Figure out the Hiearchy of a design    
##################################################
sub call_hierarchy_solver {    
   if ( $en_trace == 1 ){print trace_file "call_hierarchy_solver()\n";}
   if   ( $default_noise_filter eq "" )    
     {
         $rts = dialog_box(-2,
          "Filter Selection for small children:                          ".
          "#                                                             ".
          "#If you want, I can automatically filter out small children   ".
          "#from appearing in your hierarchy view (ie IOs, FlipFlops).   ".
          "#                                                             ".
          "#Enter in a filter value or just press <ENTER> to bypass.     ".
          "# ie, 10 will filter out all children with 10 ports or less.  ".
          "#                                                             ".
          "#Note: Bypass this irritating Pop-up by setting the variable  ".
          "#      \$default_noise_filter to a non null value.             ".
          "# Filter Value:");
          $noise_filter = $rts[0];
          #chomp $noise_filter;
          clear_screen();
     }

   $rts = dialog_box(1,
          "Note:                                                         ".
          "#Executing hierarchy_solver.pl with the following options:    ".
          "#$top_mod                                                     ".
          "#$glob_name                                                   ".
          "#$noise_filter                                                ".
          "#Please be patient....(this might take a minute or so).....   ");

      $rts = hierarchy_solver( $top_mod, $glob_name, $noise_filter, 0 );

      open( output_file , ">" . $hlist_name );
      print output_file "# This is a hlist.txt file for ChipVault (cv.pl)\n";
      print output_file $hlist_name . "\n";  # Nice to include for browsing
      print output_file $rts;
      foreach $_ ( @lib_list )
       {
        print output_file "[include] $_\n";
       }

      print output_file "[if_user] khubbard";
      print output_file " DailyNotes   /home/khubbard/private/jan02.txt\n";

      print output_file "$issue_file\n";       # Nice for reports             
      print output_file "$log_file_tag\n";     # Nice for reports             
      close output_file;
     # dialog_box(0,"$rts");
}# sub call_hierarchy_solver {    

##############################
# ShowMe Hints
##############################
sub showme
{
  my ( $str ) = @_;
  my $showme_section = 0;
  my $showme_block   = 0;
  $i = 0;
  ( $str =~ s/ //go ); # Remove All white space 
  open( input_file , "<" . $app_title );  # This is me
  while ( $_ = <input_file> )
   {
     chomp $_; # Strip CR
     ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $_ ,5) ; #Parse
     if    ($F2 eq "[showme_on]" )  { $showme_section= 1; }
     elsif ( $showme_section == 1 )
       {
         if ( $F2 eq "[showme_off]" ) { $showme_section= 0; }
         elsif ($F2 eq "[showme]" )    
           {
              if    ($F3 eq $str )        { $showme_block  = 1; }
              else                        { $showme_block  = 0; }
           }
         elsif ( $showme_block == 1 )
           {
             $showme_lines[ $i++ ] = substr($_,1); # Strip leading #
           }
       }# elsif ( $showme_section == 1 )
   } # while
  close input_file;
  $start_line =  0;
  $width = 75;
  scroll_box  ( $start_line, $width , @showme_lines );
  $redraw = 1;
}# sub showme {


# ###################
# [showme_on]
# [showme] vhdl_module
# entity mod_name is
# port
#  (
#    foo : in std_logic;
#    bar : out std_logic 
#  );
# end mod_name;
# architecture rtl of mod_name is
#  signal a                              : std_logic;
# begin
#  bar <= foo;
# end rtl;
# ###################
# [showme] vhdl_clk 
# flop_proc : process ( clk, reset )
# begin
#  if ( clk'event and clk = '1' ) then
#    if ( reset = '1' ) then
#      foo <= ( others => '0' );
#    else
#      foo <= bar;
#    end if;-- if (reset = '1')
#  end if;-- if (clk'event and clk = '1')
# end process bus_proc;
#
# [showme] end        
# ###################
# [showme] vhdl_case
# combo_proc : process ( input_foo , reset )
# begin
#   case input_foo is
#     when "00" =>
#       bar <= '1';
#     when others =>
#       bar <= '0';
#   end case;
# end process combo_proc;
#
# [showme] end        
# ###################
# [showme] vhdl_fsm 
#  type state_type is ( s0_idle, s1_busy );
#  attribute state_vector                : string;
#  attribute state_vector of rtl         : architecture is "current_state";
#  signal current_state, next_state      : state_type ;
# clocked_fsm : process ( clk )
# begin
#   if ( clk'event and clk = '1' ) then
#    if ( reset = '1' ) then
#      current_state <= s0_idle;
#    else
#      current_state <= next_state;
#    end if;-- reset
#  end if;-- clk
# end process clocked_fsm;
#
# nextstate : process ( current_state , reset )
# begin
#  case current_state is
#    when s0_idle =>
#      if ( reset = '1' ) then
#        next_state <= s1_busy;
#      else
#        next_state <= s0_idle;
#      end if;
#    when others =>
#      next_state <= s0_idle;
#  end case;
# end process nextstate;
# [showme] end        
# ###################
# [showme] vhdl_signal_dec
#  type state_type is ( s0_idle, s1_busy );
#  type ram_type is array (511 downto 0 ) of std_logic_vector ( 7 downto 0 );
#  attribute state_vector                : string;
#  attribute state_vector of rtl         : architecture is "current_state";
#  signal current_state, next_state      : state_type ;
#  signal clk                            : std_logic;
#  signal foo                            : std_logic_vector ( 7 downto 0 ) ;
#  signal ram                            : ram_type  ;
# [showme] end        
# ###################
# [showme] vhdl_ram_infer
#  type ram_type is array (511 downto 0 ) of std_logic_vector ( 7 downto 0 );
#  signal ram                            : ram_type  ;
# ram_proc : process ( clk )
# begin
#  if ( clk'event and clk = '1' ) then
#   if ( we = '1' ) then
#     ram(conv_integer(addr) ) <= di  ( 7 downto 0 );
#   end if;
#   read_addr <= addr ( 8 downto 0 );
#  end if;
# end process ram_proc;
# do <= ram ( conv_integer( read_addr ) );
# [showme] end        
# ###################
# [showme] vhdl_words
# VHDL Reserved Words
# abs          configuration impure    null        rem         type
# access       constant      in        of          report      unaffected
# after        disconnect    inertial  on          return      units
# alias        downto        inout     open        rol         until
# all          else          is        or          ror         use
# and          elsif         label     others      select      variable
# architecture end           library   out         severity    wait
# array        entity        linkage   package     signal      when
# assert       exit          literal   port        shared      while
# attribute    file          loop      postponed   sla         with
# begin        for           map       procedure   sll         xnor
# block        function      mod       process     sra         xor
# body         generate      nand      pure        srl
# buffer       generic       new       range       subtype
# bus          group         next      record      then
# case         guarded       nor       register    to
# component    if            not       reject      transport
# [showme] end        
# ###################
# [showme] veri_words
# Verilog Reserved Keywords.
# always    end           ifnone       or          rpmos         tranif1
# and       endcase       initial      output      rtran         tri
# assign    endmodule     inout        parameter   rtranif0      tri0
# begin     endfunction   input        pmos        rtranif1      tri1
# buf       endprimitive  integer      posedge     scalared      triand
# bufif0    endspecify    join         primitive   small         trior
# bufif1    endtable      large        pull0       specify       trireg
# case      endtask       macromodule  pull1       specparam     vectored
# casex     event         medium       pullup      strong0       wait
# casez     for           module       pulldown    strong1       wand
# cmos      force         nand         rcmos       supply0       weak0
# deassign  forever       negedge      real        supply1       weak1
# default   for           nmos         realtime    table         while
# defparam  function      nor          reg         task          wire
# disable   highz0        not          release     time          wor
# edge      highz1        notif0       repeat      tran          xnor
# else      if            notif1       rnmos       tranif0       xor
# [showme] end        
# ###################
# [showme] veri_clk
# always @(posedge clk)
#  begin
#   foo <= bar;
#  end
# [showme] end        
# ###################
# [showme] veri_signal_dec
# input        foo_clk ;
# output       foo_out ;
# input [31:0] foo_bus ;
# reg          foo     ;
# wire         bar     ;
# [showme] end        
# ###################
# [showme] veri_fsm 
# module fsm1 (clk,reset,a_bus,b_bus,foo,bar);
#  input         clk, reset,foo;
#  input  [31:0] a_bus ;
#  output        bar;
#  output [31:0] b_bus ;
#  reg           bar;
#  reg    [31:0] b_bus;
#
# parameter (1:0) st0=0,st1=1,st2=2,st3=3;
# reg       (1:0) current_state,next_state;
#
# always @(posedge clk)
#  begin: clocked_proc 
#   if ( reset )
#    current_state = st0;
#   else
#    current_state = next_state;
#    b_bus         = a_bus;
#   end
#
# always @(current_state)
# begin: combo_proc
#  case ( current_state )
#    st0:
#     begin
#       bar        = 0;
#       next_state = st1;
#     end   
#    st1:
#     begin
#       bar        = 1;
#       next_state = st2;
#     end   
#    default:
#     begin
#       bar        = 0;
#       next_state = st0;
#     end   
#  endcase
# end
# endmodule
# [showme] end        
# ###################
# [showme] veri_vs_vhdl_ops
#                                   VHDL       Verilog
# Logical Bit Ops        
#   NOT                             not        ~
#   AND                             and        &
#   OR                              or         |
#   NAND                            nand        
#   NOR                             nor         
#   XOR                             xor        ^
#   XNOR                            xnor       ^~
# Logical Compare Ops    
#   Equal                           =          ==
#   Not-Equal                       /=         !=
#   less                            <          < 
#   greater                         >          > 
#   less-or-equal                   <=         <=
#   greater-or-equal                >=         >=
#   NOT                             not        !
#   AND                             and        &&
#   OR                              or         ||
# Math Ops               
#   addition                        +          + 
#   subtraction                     -          - 
#   multiplication                  *          * 
#   division                        /          / 
#   exponential                     **           
#   modulus                         mod        % 
#   remainder                       rem        
#   absolute_value                  abs        
# Shift Ops              
#   logical-shift-left              sll        <<
#   logical-shift-right             srl        >>
#   math-shift-left                 sla        
#   math-shift-right                sra        
#   logical-rotate-left             rol        
#   logical-rotate-right            ror        
# Concatination                     &          {}
# [showme] end        
# ###################
# ###################
# [showme_off]

##################################################
# Read INI vars from a user INI file     
##################################################
sub read_user_ini
{    
    # Read in any store user config data
    $proj_crypt_key           = $default_crypt_key;#Default until INI overwrite
   

    if ( $user_ini_enable == 1 )
    {
     if ( $en_trace == 1 ){print trace_file "read_user_init()\n";}
     open( input_file, "<" . $user_ini_file );
     while ( $_ = <input_file> )
      {
       ($F1, $ETC ) = split (' ', $_ ,2) ; #Parse
       chomp $ETC;  # Remove CR
       if ( $F1 eq "[HLIST_CHECKSUM]" )
        {
         $stored_checksum = $ETC;
         $checksum = 0;
         foreach $tmp_var (@recurs_array)
          {
           $checksum += unpack( "%32C*", $tmp_var );
          } # foreach
        }# if ( $F1 eq "[HLIST_CHECKSUM]" )
       elsif ( $F1 eq "[CV_VERSION]" )
        {
         $last_version = $ETC; 
         if ( $version ne $last_version )
          {
           $new_version_for_user = 1;
          }
        }
 elsif ($F1 eq "[STYLE]" )                   {$style=$ETC;update_style($style);}
 elsif ($F1 eq "[X_SCALE]" )                 { $x_scale = $ETC; }
 elsif ($F1 eq "[SPLIT_DISPLAY_SIZE]" )      { $split_display_size = $ETC; }
 elsif ($F1 eq "[SPLIT_DISPLAY_MODE]" )      { $split_display_mode = $ETC; }
 elsif ($F1 eq "[USER_SPECD_SCREEN_SIZE]" )  { $user_specd_screen_size = $ETC; }
 elsif ($F1 eq "[USER_SCREEN_TYPE]"       )  { $last_user_screen_type  = $ETC; }
 elsif ($F1 eq "[UNIX_EDITOR]" )             { $my_editor_unix_bin = $ETC; }
 elsif ($F1 eq "[WIN32_EDITOR]" )            { $my_editor_win32_bin = $ETC; }
 elsif ($F1 eq "[ARCHIVE_RELEASE_PATH]" )    { $archive_release_path = $ETC; }
 elsif ($F1 eq "[PROJECT_NAME]" )            { $proj_name            = $ETC; }
 elsif ($F1 eq "[MTI_WORK_PATH]"    )        
   {  
      $mti_work_path      = $ETC; 
      $ENV{"MODELSIM"} = substr($mti_work_path,0,-4)."modelsim.ini" ;  # Strip /work
   }


       if ( $stored_checksum == $checksum )
       {
        if ( $F1 eq "[FLAG_ARRAY]" )
         {
          $i = 1;
          while ( ($F1, $ETC ) = split (' ', $ETC ,2))
          {
           @flag_array[$i++] = $F1;
          }#while
         }#if
        elsif ( $F1 eq "[SHOW_ARRAY]" )
         {
          $i = 1;
          while ( ($F1, $ETC ) = split (' ', $ETC ,2))
          {
           @show_array[$i++] = $F1;
          }#while
         }#if
                 
        }# if ( $store_checksum == $checksum )

      }#while
      close input_file;
    } #if ( $user_ini_enable == 1 )

  if ( 
      ( $notify_on_hlist_change == 1 ) &&
      ( $stored_checksum != $checksum )
     )
    {
     #dialog_box(2,"NOTE:# hlist file has changed ");
     #print STDOUT "NOTE: hlist file has changed $checksum $stored_checksum \n";
     # sleep(2);
    }
}# sub read_user_ini

##################################################
# Dump INI vars to a user INI file     
##################################################
sub write_user_ini
{
    open( output_file, ">" . $user_ini_file );

    $checksum = 0;
     foreach $tmp_var (@recurs_array)
      {
       $checksum += unpack( "%32C*", $tmp_var );
      } # foreach

  # Save user Configuration to a file
    $flag_array_str = "";
    $show_array_str = "";
    for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
     {
      $flag_array_str = $flag_array_str . " " . @flag_array[$i];
      $show_array_str = $show_array_str . " " . @show_array[$i];
     }
     print output_file "[CV_INI_START]\n";
     print output_file "## Note: CV is very controlling regarding this file\n";
     print output_file "##       CV reads this file in on startup and then \n";
     print output_file "##       creates a new one on exit. This means if \n";
     print output_file "##       you do anything to it other than change\n";
     print output_file "##       some values, your changes will be tossed. \n";
     print output_file "[HLIST_CHECKSUM]         $checksum\n";
     print output_file "[CV_VERSION]             $version\n";
     print output_file "[FLAG_ARRAY]             $flag_array_str\n";
     print output_file "[SHOW_ARRAY]             $show_array_str\n";
     print output_file "[STYLE]                  $style\n";
     print output_file "[X_SCALE]                $x_scale\n";
     print output_file "[SPLIT_DISPLAY_SIZE]     $split_display_size\n";
     print output_file "[SPLIT_DISPLAY_MODE]     $split_display_mode\n";
     print output_file "[USER_SPECD_SCREEN_SIZE] $user_specd_screen_size\n";
     print output_file "[USER_SCREEN_TYPE]       $user_screen_type\n";
     print output_file "[UNIX_EDITOR]            $my_editor_unix_bin\n";
     print output_file "[MTI_WORK_PATH]          $mti_work_path\n";
     print output_file "[ARCHIVE_RELEASE_PATH]   $archive_release_path\n";
     print output_file "[PROJECT_NAME]           $proj_name\n";
     print output_file "[WIN32_EDITOR]           $my_editor_win32_bin\n";
     print output_file @licenses;
     print output_file "[CV_INI_END]\n";

     close output_file;
}# sub write_user_ini

##################################################
# List the User Definable Variables    
##################################################
sub list_user_vars
{
  my $list_on = 0;
  my @text_lines;
  if ( $en_trace == 1 ){print trace_file "list_user_vars()\n";}
   open( input_file , "<" . $0 );  # This is me, ChipVault cv.pl
   while ( $_ = <input_file> ) 
    { 
     if ( substr($_,0,1) eq "#" )
      {
       ($F1,$F2,$F3,$ETC)=split(' ',$_,4);
       if    ( $F2 eq "[user_vars_start]" ) { $list_on = 1; }
       elsif ( $F2 eq "[user_vars_stop]" ) { $list_on = 0; }
      }
     elsif ( $list_on == 1 ) 
      {
       chomp $_; # Remove CR;
       ( $_ =~ s/#/*/go ); # Replace ALL '#' with '*';
       ( $_ =~ s/\r//go ); # Replace ALL CarriageRet with ''
       push @text_lines, $_;
      }
    } # while
   my $start_line =  0;
   my $width = $maxx-4;
   scroll_box  ( $start_line, $width , @text_lines );
}# sub list_user_vars

##################################################
# Expand_CV_Source : This rips thru the CV source
# code and generates a separate file called func.txt
# for each function. Basically makes it easier to
# browse and modify CV source.
##################################################
sub expand_cv_source
{
  my $list_on = 1;
  my @text_lines;
  my $comment_lines;
  if ( $en_trace == 1 ){print trace_file "expand_cv_source()\n";}
  open( input_file , "<" . $0 );  # This is me, ChipVault cv.pl
  open( output_file , ">" . "cv.txt"); 

  while ( $_ = <input_file> ) 
   { 
    if ( $list_on == 1 ) { print output_file $_; }
    else                 { $comment_lines .= $_; } # if list_on

    ($F1,$F2,$F3,$ETC)=split(' ',$_,4);
    if ( $F1 eq "sub" )
     {
      close output_file;
      $list_on = 1;
      open( output_file , ">" . $F2.".txt" ); # F2 = name of function
      print output_file $comment_lines;
      $comment_lines = "";
     } 
    elsif ( $F1 eq "}#" && $F2 eq "sub" )
     {
      $list_on = 0; # End of Subroutine. Start capturing comment header for nxt
     }
   } # while
 close output_file;
}# sub expand_cv_source


##################################################
# Build a ModelSim VLIB Directory      
##################################################
sub build_vlib
{
  if ( ( $mti_work_path ne "" ) && !( -e $mti_work_path ) )
   {
           $rc = 0;
           @run_shell = ("$mkdir_cmd $mti_work_path"); 
           $rc += 0xffff & system (@run_shell); 
           @run_shell = ("vlib $mti_work_path"); 
           $rc += 0xffff & system (@run_shell); 
           @run_shell = ("vmap work $mti_work_path"); 
           $rc += 0xffff & system (@run_shell); 
           if ( $rc != 0 )
            {
              $perl_line = __LINE__;
              $rts = dialog_box(-1,
               "#ERROR $perl_line: $mti_work_path generation failed!        ".
               "# <Press Any Key> " );
            }# if ( $rc != 0 )
           else
            {
              $rts = dialog_box(-1,
               "#NOTE: $mti_work_path created. ".
               "# <Press Any Key> " );
            }
   }# if ( ( $mti_work_path ne "" ) && !( -e $mti_work_path ) )
}# sub build_vlib   

sub leave_now {
  if ( $en_trace == 1 ){print trace_file "leave_now()\n";}
  # We're Leaving Now
  clear_screen();
  banner_message( ( $license_banner_quit ) ); # ByeBye
  print STDOUT "\n";
  
  if ( $user_ini_enable == 1 )
   {
    write_user_ini();
   }# if ( $user_ini_enable == 1 )

   set_color("normal", "" , "" );
#  set_title(" ");
#  set_title( getlogin() . "@" . hostname() );
   set_title( $my_name . "@" . hostname() );
  if ( $x_mouse_enable == 1 ) { x_mouse_off(); }
   ++$interrupted ; 
 exit ;
}

sub x_mouse_off {
  system "stty", 'icanon';
  system "stty", 'eol', '^@'; # ascii null
  system "stty", 'echo';
  print STDOUT "\e[?9l" ; # Turn OFF the Mouse
}# sub x_mouse_off {

sub x_mouse_on  {
  print STDOUT "\e[?9h"; # Turn on the Mouse
  system "stty", '-icanon';
  system "stty", 'eol', "\001";
  system "stty", '-echo';
}# sub x_mouse_on  {



##########################################################################

sub screen_sizing {
    if ( $en_trace == 1 ){print trace_file "screen_sizing()\n";}
    if ( ( $dynamic_resize_checking == 1 ) )  
     {
      $check_for_resizing = 1; # Recheck size every time ; 
     }

    if ( $check_for_resizing == 1 )
    {
##################################################
# See if Screen Dimension have changed
##################################################
#       @termsize    = GetTerminalSize;
#       $maxx        = $termsize[0]-1;
#       $maxy        = $termsize[1];
#       # Note: This doesnt work. Always return 80x24
#      # ($maxy  , $maxx  ) = ($tcap->{_li} - 1, $tcap->{_co} - 1);
       if ( $stty_pipe_doesnt_work == 0 )
       {

        if ( $os eq "unix" )
         {
          open STATUS, "stty -a |" or die "Cant Fork: $!";
          while ( <STATUS> ) { $ret_str = $ret_str . $_; }
          close STATUS ;  
          ($ret_str =~ s/=//g );#Remove '='. UNIX "rows = 24;". Linux "rows 24;"
          ($ret_str =~ s/;//g );#Remove ';'
           $maxx = 0;
           $maxy = 0;
           while ( ($F1, $ret_str ) = split (' ', $ret_str , 2) )
            {
              $F1_p2 = $F1_p1;
              $F1_p1 = $F1;
              if ( lc ( $F1_p2 ) eq "columns" ) { $maxx = $F1_p1;}
              if ( lc ( $F1_p2 ) eq "rows"    ) { $maxy = $F1_p1;}
            }

           if ( ($maxx < 80) && ($maxx != 0) )
             {
              $perl_line = __LINE__;
              $rts = dialog_box(-1,
               "#ERROR $perl_line: Screen too Narrow ( $maxx )              ".
               "# I need at least 80columns to get the job done. ".
               "# Please press <ANY_KEY>, resize your window to  ".
               "# 80 columns or wider and press <r>esize key.    ".           
               ""); 
             }# if ( $maxx < 80 )
         }# if ( $os eq "unix" )
       else
         {
          ($maxx, $maxy) = $STDOUT->MaxWindow(); # Win32
          $maxy--; # Dont know why .
         }

        if ( ( $maxx > 0 ) && ( $maxy > 0 ) )
          {
            $stty_pipe_doesnt_work = 0;
          }
        elsif ( ( $user_specd_screen_size ne "" ) && 
                ( $user_screen_type eq $last_user_screen_type  )
              )
          {
            $maxx = 80; # Assign Defaults
            $maxy = $user_specd_screen_size;
          }
        else
          {
            $maxx = 80; # Assign Defaults
            $rts = dialog_box(-2,
          "#Note-Unable to Determine Screen Size:                        ".
          "#I tried to autodetect your screen size but was unable to.    ".
          "#Press <ENTER> to accept default height of 24 or enter a      ".
          "#larger value if your terminal is larger.                     ".
          "#You may change this anytime with the <r>esize key.           ".
          "#I will forevermore save this value in your ini file.         ".
          "#Terminal Height".
          "#:  ".
          "#   ");
            $maxy = $rts[0];
            if ( $maxy < 24 ) { $maxy = 24; }
            $user_specd_screen_size = $maxy;
           #  $stty_pipe_doesnt_work = 1;
           }

       if ( ($last_maxx != $maxx)||($last_maxy != $maxy)||($force_resize==1))
        {
         # Screen Size has changed. Recalc Everything
         $redraw = 1;


         # Defaults
         $page_size = $maxy - 4; # Reserve 2 on Top, 2 on Bottom

         # y_screen_start and stop used for comparing against cursor position
         $y_screen_start  = 2;                               # Physical Screen

         $split_display_on = 0;
         $split_display_scroll_pos = 0;
         if ( $enable_split_display == 1 )
           {
            if ( $maxy > 50 ) 
             {
               if    ( $split_display_size == 0 ||
                       $split_display_mode == 5   
                     )
                {
                 # Go With Defaults
                }
               elsif ( $split_display_size == 1 )
                {
                 $page_size       = int( $maxy * 0.75 ) - 4; # 3/4s for Hier
                 $y_screen_start  = int( $maxy * 0.25 ) + 2; 
         
                 $y_split_size    = int( $maxy * 0.25 ) - 4; 
                 $y_split_offset  = 2;
                 $x_split_offset  = 0;
                 $split_display_on = 1;
                }
               elsif ( $split_display_size == 2 )
                {
                 $page_size       = int( $maxy * 0.66 ) - 4; # 2/3s for Hier
                 $y_screen_start  = int( $maxy * 0.33 ) + 2; 
         
                 $y_split_size    = int( $maxy * 0.33 ) - 4; 
                 $y_split_offset  = 2;
                 $x_split_offset  = 0;
                 $split_display_on = 1;
                }
               elsif ( $split_display_size == 3 )
                {
                 $page_size       = int( $maxy * 0.50 ) - 4; # 1/2  for Hier
                 $y_screen_start  = int( $maxy * 0.50 ) + 2; 
         
                 $y_split_size    = int( $maxy * 0.50 ) - 4; 
                 $y_split_offset  = 2;
                 $x_split_offset  = 0;
                 $split_display_on = 1;
                }
               elsif ( $split_display_size == 4 )
                {
                 $page_size       = int( $maxy * 0.25 ) - 4; # 1/4s for Hier
                 $y_screen_start  = int( $maxy * 0.75 ) + 2;
                                                                                
                 $y_split_size    = int( $maxy * 0.75 ) - 4;
                 $y_split_offset  = 2;
                 $x_split_offset  = 0;
                 $split_display_on = 1;
                }
               elsif ( $split_display_size == 5 )
                {
                 $y_split_size    = int( $maxy * 0.66 ) - 4; # 2/3s for Hier
                 $y_split_offset  = int( $maxy * 0.33 ) + 2; 
                 $x_split_offset  = 0;
         
                 $page_size       = int( $maxy * 0.33 ) - 4; 
                 $y_screen_start  = 2;
                 $split_display_on = 1;
                }
               elsif ( $split_display_size == 6 )
                {
                 $y_split_size    = int( $maxy * 0.50 ) - 4; # 1/2  for Hier
                 $y_split_offset  = int( $maxy * 0.50 ) + 2; 
                 $x_split_offset  = 0;
         
                 $page_size       = int( $maxy * 0.50 ) - 4; 
                 $y_screen_start  = 2;
                 $split_display_on = 1;
                }
             }# if ( $maxy > 50 ) 

             if ( $maxx > 160 )
              {
                $page_size = $maxy - 4; # Reserve 2 on Top, 2 on Bottom
                $y_screen_start  = 2;   # Physical Screen
                 $y_split_size    = $page_size;
                 $y_split_offset  = $y_screen_start;
                 $x_split_offset  = 81;
              }
           }# if ( $enable_split_display == 1 )

    


         $y_screen_offset = $y_screen_start ;
         $y_screen_stop   = $y_screen_start + $page_size-1 ; # Physical Screen

         if ( ( $last_maxx != $maxx ) || ( $last_maxy != $maxy ) )
          {
           $cur_y = $y_screen_offset ;
          }

         $last_maxx = $maxx;
         $last_maxy = $maxy;

         $status_x_loc = 70;
         $clock_x_loc  = 75;
         $tool_x_loc   = 15;

         # ViewPort start and stop defines section of Virtual Screen to draw
         $y_view_port_start = 0;  # Virtual  Screen
         $y_view_port_stop  = $y_view_port_start + $page_size-1 ; # Virtual

         clear_screen(); 
         $redraw = 1;

        }
       }# if ( $stty_pipe_doesnt_work == 0 )
      $check_for_resizing = 0;
      $force_resize       = 0;
    } # if $check_for_resizing
}# sub screen_sizing ()

##################################################
# Process Keypresses
##################################################
sub process_keys {
  if ( $en_trace == 1){print trace_file "process_keys( $key_val )\n";}

    # Check for DoubleClick Mouse and either Edit File or Hierarchy Toggle
     if ( $key_val eq "single_click" )
       {
         $cur_y = $mouse_y;
         if ( $cur_x == 0 || $cur_x == 1 )
          {
           if ( $mouse_x > $status_x_loc ) {$cur_x=1;} else {$cur_x=0;}
          } # if ( $cur_x == 0 || $cur_x == 1 )
       }
     elsif ( $key_val eq "double_click" )
       {
        $plus_position = (@level_array[ $select_index ]*$x_scale) ;
        if ( ( $mouse_x < $plus_position+2 )  )
         { $key_val = $k_mouse_double_click_togl; }
        elsif ( ( $mouse_y > 1                ) &&
                ( $mouse_x > $plus_position+2 ) &&
                ( $mouse_x < $plus_position+10 )   )
         { $key_val = $k_mouse_double_click_edit; }
        else
         { $key_val = 0; }
       }# if ( $key_val eq "double_click" )
##################################################
# Check for Fast Macro Keys for Rapidly selecting
#  tools
##################################################
   if ( $macro_hash { $key_val }  ne "" )
    {
     $edit_sel = $macro_hash{ $key_val };
     ($tool_str, $tool_exe, $ETC ) = split ('#', @my_tool[$edit_sel] , 3);
     $key_val = $k_cr;
     $redraw = 1; 
    }

##################################################
# Display Bang History List  
##################################################
   if ( ( $k_hist_hash   {$key_val}  == 1 ) ||
        ( $k_macro_hash  {$key_val}  == 1 )
      )
    {
      if ( $k_hist_hash {$key_val}== 1 ) 
        {(@tool_lookup) = @tool_history; $tmp_str = "Bang History:"; }
      else 
        {(@tool_lookup) = @tool_macro ; $tmp_str = "Tool Macros:";}

      $i = 1;
      $tmp_str = $tmp_str . "#Press <1>..<9> to Activate Tool or";
      $tmp_str = $tmp_str . "#           <0> to escape out";
      foreach $old_tool_sel ( @tool_lookup )
      {
        my ($tmp_tool_str,$tmp_tool_exe,$ETC)=split('#',@my_tool[$old_tool_sel],3);
        $tmp_str = $tmp_str . "#" ."<$i> $tmp_tool_str";
        $i++;
      }# foreach $old_tool_sel ( @tool_lookup  )
       $key_val = dialog_box(-1,$tmp_str);
       $sel = 0;
      if ( $key_val == $k_1 ) { $sel = 1 ; }
      if ( $key_val == $k_2 ) { $sel = 2 ; }
      if ( $key_val == $k_3 ) { $sel = 3 ; }
      if ( $key_val == $k_4 ) { $sel = 4 ; }
      if ( $key_val == $k_5 ) { $sel = 5 ; }
      if ( $key_val == $k_6 ) { $sel = 6 ; }
      if ( $key_val == $k_7 ) { $sel = 7 ; }
      if ( $key_val == $k_8 ) { $sel = 8 ; }
      if ( $key_val == $k_9 ) { $sel = 9 ; }

      if ( $sel != 0 )
       {
        ($tool_str, $tool_exe, $ETC ) = split ('#', 
                          @my_tool[ @tool_lookup[$sel-1] ] , 3);
        $tool_param = $my_tool_param {$edit_sel}; 
        $key_val = $k_cr; # This mocks an Enter on Exit for Command Now
        $edit_sel = 0; 
       }
      else
       {
        $key_val = "";
       }
     $redraw = 1;
    }# if ( $k_hist_hash  {$key_val}  == 1 )


    
##############################
# Scroll Up  
##############################
    if ( $k_nav_up_hash{$key_val}  == 1 ) 
      { 
       $cur_y--;
       if ( ( $cur_y            < $y_screen_start) && 
            ( $y_view_port_start > 0                ) )
         {
          $cur_y++;
          $y_view_port_start--;
          $y_view_port_stop--;
          $redraw = 1;
         }
       elsif ( ( $cur_y             < $y_screen_start) && 
               ( $y_view_port_start <= 0                ) )
         {
          $cur_y++;
          my_print($bell);  # Warning Bell
          $redraw = 1;
         }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
       }# if ( $k_nav_up_hash{$key_val}  == 1 ) 

##############################
# Scroll Down
##############################
    elsif ( $k_nav_dn_hash{$key_val}  == 1 ) 
      { 
       $cur_y++;
       if ( ( $cur_y            > $y_screen_stop ) && 
            ( $y_view_port_start < 65535            ) )
         {
          $cur_y--;
          $y_view_port_start++;
          $y_view_port_stop++;
          $redraw = 1;
         }
       elsif ( ( $cur_y             > $y_screen_stop) && 
               ( $y_view_port_start >= 65535           ) )
         {
          $cur_y--;
          my_print($bell);  # Warning Bell
          $redraw = 1;
         }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
       }# if ( $k_nav_dn_hash{$key_val}  == 1 ) 

##############################
# Scroll Left
##############################
    elsif ( $k_nav_lf_hash{$key_val}  == 1 ) 
      { 
       $cur_x--;
       if ( $cur_x < 0 ) { $cur_x =  0 ; }
       if ( $cur_x == 1 ) { $redraw = 1; }
       if ( $cur_x > 1  ) { $redraw = 1; }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }

##############################
# Scroll Right
##############################
    elsif ( $k_nav_rt_hash{$key_val}  == 1 ) 
      { 
       $cur_x++;
       if ( $cur_x > 100 ) { $cur_x =  100 ; }
       if ( $cur_x > 1 ) { $redraw = 1; }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }

##############################
# Page Down  
##############################
    elsif ( $k_pg_dn_hash {$key_val}  == 1 ) 
      { 
        if ( $y_view_port_start + $page_size < 65535 )
         {
          $y_view_port_start += $page_size;
          $y_view_port_stop  += $page_size;
          $redraw = 1;
         }
        else
         {
          my_print($bell);  # Warning Bell
         }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }# if ( $k_pg_dn_hash{$key_val}  == 1 ) 

##############################
# Page Up    
##############################
    elsif ( $k_pg_up_hash {$key_val}  == 1 ) 
      { 
        if ( $y_view_port_start - $page_size >= 0 )
         {
          $y_view_port_start -= $page_size;
          $y_view_port_stop  -= $page_size;
          $redraw = 1;
         }
        else
         {
          $y_view_port_start = 0;
          $y_view_port_stop  = 0 + $page_size;
          my_print($bell);  # Warning Bell
          $redraw = 1;
         }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }# if ( $k_pg_dn_hash{$key_val}  == 1 ) 
##############################
# Split Scroll Up
##############################
    elsif ( $k_split_up_hash{$key_val}  == 1 ) 
      { 
       $split_display_scroll_pos--;  
       if ( $split_display_scroll_pos < 0 ) { $split_display_scroll_pos=0; }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }
##############################
# Split Scroll Down
##############################
    elsif ( $k_split_dn_hash{$key_val}  == 1 ) 
      { 
       $split_display_scroll_pos++;  
#       if ( $split_display_scroll_pos > TBD ) { $split_display_scroll_pos--;}
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }
##############################
# Split Page Up
##############################
    elsif ( $k_split_pg_up_hash{$key_val}  == 1 ) 
      { 
       $split_display_scroll_pos -= $y_split_size;
       if ( $split_display_scroll_pos < 0 ) { $split_display_scroll_pos=0; }
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }

##############################
# Split Page Down
##############################
    elsif ( $k_split_pg_dn_hash{$key_val}  == 1 ) 
      { 
       $split_display_scroll_pos += $y_split_size;
#       if ( $split_display_scroll_pos > TBD ) { $split_display_scroll_pos--;}
       if ( $redraw_on_scroll == 1 ) { $redraw = 1; }
      }
##############################
# Search     
##############################
    elsif ( ( $k_search_dn_hash{$key_val}  == 1 ) ||
            ( $k_search_up_hash{$key_val}  == 1 )  )
      { 
        $rts = dialog_box(-2, "Search_For [NULL=$last_search]#:");
        if ( $rts[0] eq "" )  { $rts[0] = $last_search; }
        $last_search = $rts[0];


    $search_start = $select_index;
    if ( $k_search_dn_hash{$key_val}  == 1 ) 
     {
      $search_stop = $array_size;
      $search_dir  = +1;
     }
    elsif ( $k_search_up_hash{$key_val}  == 1 ) 
     {
      $search_stop = 1 ; 
      $search_dir  = -1;
     }
    $search_complete = 0;

    # Loop thru all entries
    for ( $i = $search_start ; 
          ($i != $search_stop ) && ( $search_complete != 1 ) ;
          $i+= $search_dir )
     {

      if ( @modname_array[ $i ] =~ m/$rts[0]/g ) 
       {
         # ViewPort start and stop defines section of Virtual Screen to draw

         # If the HLIST is bigger than the screen, scroll the ViewPort
         if ( $array_size >= $page_size )
          {
           $y_view_port_start = $i  ;  # Virtual  Screen
           $y_view_port_stop  = $y_view_port_start + $page_size - 1 ; # Virtual
           $cur_y = $y_screen_offset  ;
          }
         else
          {
           $cur_y = $i + $y_screen_offset - 1 ; # HLIST is smaller than screen
          }
         $search_complete = 1;
         $redraw = 1;
       }
     } # for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries

     # If we found our search pattern, expand everything so its visible 4sure
    if ( $search_complete == 1 )
      {
       for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
        {
         @show_array[ $i ] = 1 ;  # Show Everybody
         # + Expand   All Children that have children
         if ( @flag_array[ $i ] != 0 ) { @flag_array[$i] = +1 ;}  # -
        } # for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
      }# if ( $search_complete == 1 )
    else
     {
        $rts = dialog_box(1, "MESSAGE:# Search failed on $rts[0]");
        $redraw = 1;
     }# if ( $search_complete == 1 )

       } # elsif ( $k_search_hash{$key_val}  == 1 ) 

##############################
# Launch Tools  
##############################
    elsif ( $k_enter_hash{$key_val}  == 1 )
    {

##############################
# Shell to UNIX Tools
##############################
#     else
#     {
        $tool_menu_skip = 0;
        $tool_param_cnt = 0;
        if ( $en_trace == 1 ){print trace_file "LAUNCH_TOOLS_ON_ENTER\n";}

        # Turn off mouse code capture so mouse works for pasting in Vi,etc
        if ( $x_mouse_enable == 1 ) { x_mouse_off(); }

         $wip_exists = 0;
         if ( $batch_mode == 1 ) 
          { $tool_exe = $batch_cmd ;
            $tool_str = "(hier)";
            $cur_x = 0;
            $select_index = 1;
          }

          $internal_tool_option = 0;
          $results_option = 0;
          $int_tool = "";
          $pipe_option    = 0;
          $hier_option    = 0;
          $list_option    = 0;
          $print_option   = 0;
          $fork_option    = 0;
          $cv_viewer      = 0;
          $cv_rtl_viewer  = 0;
          $cv_rtl_analyzer= 0;
          if ( ($tool_str =~ m/\(int\)/g ) )       { $internal_tool_option= 1;}
          if ( ($tool_str =~ m/\(results\)/g))     { $results_option = 1; }
          if ( ($tool_str =~ m/\(pipe\)/g ) )      { $pipe_option   = 1; }
          if ( ($tool_str =~ m/\(hier\)/g ) )      { $hier_option   = 1; }
          if ( ($tool_str =~ m/\(hier_exp\)/g ) )  { $hier_exp_option   = 1; }
          if ( ($tool_str =~ m/\(list\)/g ) )      { $list_option       = 1; }
          if ( ($tool_str =~ m/\(fork\)/g ) )      { $fork_option   = 1; }
          if ( ($tool_str =~ m/block_print/g ) )   { $print_option   = 1; }
          if ( ($tool_str =~ m/cv_viewer/g ) )     { $cv_viewer  = 1; }
          if ( ($tool_str =~ m/cv_rtl_viewer/g ) ) { $cv_rtl_viewer  = 1; }
          if ( ($tool_str =~ m/cv_rtl_analyzer/g ) ) { $cv_rtl_analyzer= 1; }
          $type_list = $list_option;

         if ( 
             ($enforce_checkouts==1) && ($cur_x==0) && ($tool_str=~ m/Edit/g ) 
            )
         {
           if ( $enforce_checkouts_truly == 1 )
            {
             $internal_tool_option = 1;
             $cv_rtl_viewer  = 1; 
            }  
           else
            {
             $edit_sel = $read_only_viewer; # This will hopefully be a Viewer 
             # But it may only be vi -R (which can be overrided with w!)
             ($tool_str, $tool_exe, $ETC ) = split ('#', @my_tool[$edit_sel],3);
            }#if ( $enforce_checkouts_truly == 1 )

            $rts = dialog_box($enforce_warn_time,
                                 "#Note: enforce_checkouts is enabled".
                                 "#      Using editor on mainline has".
                                 "#      been prohibited. Using a    ".
                                 "#      Read Only Viewer instead.   ".
                                 "");
            $enforce_warn_time--; # Reduce dialog time as to not annoy
            if ($enforce_warn_time<0){$enforce_warn_time=0;}
         }# if ( ($enforce_checkouts==1) && ($edit_sel==2) && ($cur_x==0) )

        if ( $internal_tool_option == 1 )
         {
          $wip_exists = -1;

#           ( $int_tool, $ETC ) = split ( ' ', $tool_str, 2 );
            ( $int_tool, $ETC ) = split ( ' ', $tool_exe, 2 );

           set_title("$int_tool $ETC");

           if    ( $int_tool eq "help"        ) { display_help(); }
           elsif ( $int_tool eq "about"       ) { banner_message(3); }
           elsif ( $int_tool eq "quit"        ) { leave_now();    }
           elsif ( $int_tool eq "port_view_parent"){display_ports_parent();}
           elsif ( $int_tool eq "archive_to_rcs"  ){archive_to_rcs();      }
           elsif ( $int_tool eq "port_view_kids"  ){display_ports_kids();   }
           elsif ( $int_tool eq "build_vlib"      ){build_vlib();           }
           elsif ( $int_tool eq "expand_cv_source"){expand_cv_source();     }
           elsif ( $int_tool eq "list_user_vars"  ){list_user_vars();       }
           elsif ( $int_tool eq "showme"      )    { showme($ETC); }
           elsif ( $int_tool eq "enable_trace_log" )
            {
             $en_trace = 1;
             open( trace_file , ">" . "$trace_file" ); 
            }

           elsif ( ($int_tool eq "check_out") )
             { if ($cur_x==0) {check_out(); } else
                 { dialog_box(2,"ERR $.: Invalid Cursor Location for CheckOut");}
             }
           elsif ( ($int_tool eq "label_release") )
             { if ($cur_x==0) {label_release(); } else
                 { dialog_box(2,"ERR $.: Invalid Cursor Location for Release");}
             }
           elsif ( ($int_tool eq "create_branch") ) { create_branch() ; }
           elsif ( ($int_tool eq "check_in") )
             { if ($cur_x==1) {check_in(); } else
                 { dialog_box(2,"ERR $.: Invalid Cursor Location for CheckIn ");}
             }
           elsif ( ($int_tool eq "check_in_out") )
             { 
               if    ($cur_x==0) {check_out(); } 
               elsif ($cur_x==1) {check_in() ; } else
                 { dialog_box(2,"ERR $.: Invalid Cursor Location for CheckInOut");}
             }
           elsif ( ($int_tool eq "check_abandon") && ($cur_x==1)) 
              {check_abandon();  }
           elsif ( ($int_tool eq "generate_VHDL" ) && ( $cur_x < 2  ) ||
                   ($int_tool eq "generate_Verilog" ) && ( $cur_x < 2  ) )
              { make_rtl(); }
           elsif ( ($int_tool eq "check_restore") )
             { 
               if    ($cur_x==0) {check_restore(); } 
               elsif ($cur_x==1) 
                 {dialog_box(2,"ERR $.:Invalid Cursor Location for CheckRestore");}
             }
           elsif ( ($int_tool eq "resize_display") )
              {
               $check_for_resizing = 1; # Resize ; 
               $force_resize       = 1; # Resize ; 
               $check_wip_status = 1; # See if new WIP files exist 
              }
           elsif ( ($int_tool eq "change_color") )
              {
               $win32_color_select++;
               if ( $win32_color_select == 6 ) {$win32_color_select = 0; }
               $win32_color_scheme = @win32_color_array[$win32_color_select];
               clear_screen(); 
               $redraw = 1;
              }
           elsif ( ($int_tool eq "rotate_view") )
              {
               $disp_select++; 
               if ( $disp_select == 3 ) { $disp_select = 0 ; }
               $redraw = 1;
              }
           elsif ( ($int_tool eq "split_display_size_adj"))
              {
               $split_display_size++;
               if ( $split_display_size == 7 ) { $split_display_size = 0 ;}
               $check_for_resizing = 1; # For a Resize as layout changes
               $force_resize       = 1; # Resize ; 
               $redraw = 1;
              }
           elsif ( ($int_tool eq "split_display_mode_adj"))
              {
               $split_display_mode++;
               if ( $split_display_mode == 6 ) { $split_display_mode = 0 ;}

               if ( $split_display_mode == 5 ) { $enable_split_display = 0 ;}
                 else                          { $enable_split_display = 1 ;}

               $check_for_resizing = 1; # For a Resize as layout changes
               $force_resize       = 1; # Resize ; 
               $redraw = 1;
              }
           elsif ( ($int_tool eq "rotate_style") )
              {
               if ( @style_array[ $style+1 ] eq "end" ) { $style = 0 ; }
               else                                     { $style++   ; }
               update_style( $style );
               $redraw = 1;
              }
           elsif ( ($int_tool eq "rotate_x_scale") )
              {
               if ( $x_scale == 5 )                     { $x_scale = 1 ; }
               else                                     { $x_scale++   ; }
               $redraw = 1;
              }

     elsif ( ($int_tool eq "Issue_List_Add" ) )
     {
        $mod_name  = @modname_array [ $select_index ] ;
        $file_name = @filename_array[ $select_index ];
        $rts = issue_list_add ( $my_name, $mod_name, $file_name );
        $redraw = 1; 
     }
     elsif ( ($int_tool eq "Issue_List_View" ) )
     {
        $mod_name  = @modname_array [ $select_index ] ;
        $file_name = @filename_array[ $select_index ];
        $rts = issue_list_view ( $my_name, $mod_name, $file_name ,"",0);
        $redraw = 1; 
     }
     elsif ( ($int_tool eq "Send_Author_Email" ) )
     {
       if ( $os eq "unix" )
        { 
          $to      = $author_email;
          $from    = "";
          $subject = "Greeting from a ChipVault user";
          $body    = "No Message";
          $rts = dialog_box(-4,
         "Issue_List:    #                                        ".
         "# Please fill in the following fields                   ".
         "# or just hit <ENTER> on a field to use default.        ".
         "# To       :   ( $to )    ".
         "# From     :   ( $from ) ". 
         "# Subject  :   ( $subject ) ". 
         "# Message  :   ". 
         "");
        clear_screen();

         if ( $rts[0] ne "" ) { $from           = $rts[0] ; }
         if ( $rts[1] ne "" ) { $subject        = $rts[1] ; }
         if ( $rts[2] ne "" ) { $body           = $rts[2] ; }

         $send_email_question = dialog_box(-1,
             "Send Email:".
             "# Note: I'll cc $from so you can verify Email ".
             "# from ChipVault is working.  If you don't receive ".
             "# any response from the Author in 24 hours, you    ".
             "# should send Email from your normal Email tool    ".
             "# as the gateway outside company Email systems    ".
             "# doesn't always work.                            ".
             "# Would you like me to send the Email now ? ".
             "# (y/n) :". 
             "");
           if ( $send_email_question == ord ("y" ) )
            {
              send_email( $to,   $from, $subject , $body);
              send_email( $from, $from, $subject , $body);
            }# if ( $send_email_question == ord ("y" ) )
          $redraw = 1; 
         }# if ( os == unix )
     }# elsif ( ($int_tool eq "Send_Author_Email" ) )
     elsif ( $int_tool eq "tool_menu"       )
      {
       display_tool_menu();   
       $tool_menu_skip = 1;
       if ( $en_trace == 1 ){print trace_file "rts_from display_tool_menu()\n";}
      }
   }# if ( $internal_tool_option == 1 )
        
       #  print "$tool_exe\n";
       #  exit;

  #     ($tool_exe =~ s/ARG1/@arg1_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG2/@arg2_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG3/@arg3_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG4/@arg4_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG5/@arg5_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG6/@arg6_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG7/@arg7_array[$select_index]/go );#SearchReplace Tag
  #     ($tool_exe =~ s/ARG8/@arg8_array[$select_index]/go );#SearchReplace Tag


   if ( $en_trace == 1 ){print trace_file "switch on tool_menu_skip\n";}
######################
######################
   if ( $tool_menu_skip == 0 )
   {
        if ( $en_trace == 1 ){print trace_file " was 0\n";}
       $run_tool_exe = $tool_exe;

     if ( $print_option == 1 )
      {
        open( output_print_file , ">" . $print_file );
        # print output_print_file "[PAGE_BREAK]\n" ;
        $text_size = ( 600 / $array_size ); # Scale for Really Big Designs
        $text_size = int ( $text_size );
        if ( $text_size > 10 ) { $text_size = 10 ; } #Dont let fonts get too big
        if ( $text_size < 4  ) { $text_size =  4 ; } # Dont let fonts too small
        
        print output_print_file "# [pdf_text_size] $text_size\n" ;

          # Go down hierarchy and generate a printout      
        $loop_index = 1;
          while ( ( $loop_index <= $array_size )  )
            {
              my $level_tmp = @level_array[ $loop_index ];
              my $name_tmp  = @modname_array[ $loop_index ]; # Pick 1
              # my $name_tmp  = @filename_array[ $loop_index ]; # of these 2
              $tmp_str = pack "A".($level_tmp*2)."", ""; # Pad to show hierarchy
              $tmp_str = $tmp_str . $name_tmp ; 
              print output_print_file "$tmp_str";
              if ( $loop_index == $select_index )
               {
                print output_print_file " <----";
               }
              print output_print_file "\n";
              $loop_index++ ;
            }  # while
        print output_print_file "# [pdf_text_size] 10 \n" ;
        close output_print_file;
      }# if ( $print_option == 1 )

       if ( ($run_tool_exe =~ /TIMESTAMP/go) )
        { 
          if ( $en_trace == 1 ){print trace_file "TIMESTAMP\n";}
         # Create a Filename from Time+Data
         $my_time = localtime(time); # Create a unique name via time
         ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
         ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'
          ( $run_tool_exe =~ s/TIMESTAMP/$my_time/go );# Search and Replace Tag
        }# if ( ($run_tool_exe =~ /TIMESTAMP/go) )

       if ( ($run_tool_exe =~ /LABEL_RELEASE/go) )
       {
        if ( $release_title eq "" )
         {
           $my_time = localtime(time); # Create timestamp with no spaces.
           ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
           ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'

          $rts = dialog_box(-2,"Release:#Please enter short " .
          "title for this release followed by <ENTER> key.#".
          "(NULL for generic RELEASE_" . $my_time ." )".
          "#:");

          if ( $rts[0] eq "" ) { $release_title = "RELEASE_" . $my_time; }
          else                 {  $release_title = $rts[0];    }
          ( $release_title =~ s/ /_/go ); # Remove All ' ' with '__'
         }# if ( $release_title eq "" )
         $tmp_var = $proj_name ."_".$release_title; 
         ($run_tool_exe =~ s/LABEL_RELEASE/$tmp_var/go );# S and R
       }# if ( ($run_tool_exe =~ /LABEL_RELEASE/go) )

       while ( ($tool_param =~ /PARAM/go) )  { $tool_param_cnt++; } # Count

       if ( $tool_param_cnt > 0 )
         {
           $str = "Parameters Required" . $tool_param;
           $rts = dialog_box(( ( $tool_param_cnt * - 1 ) -1), $str );
          #chomp $rts[0] ;
          #chomp $rts[1] ;
          #chomp $rts[2] ;
          #chomp $rts[3] ;
          $PARAM1 = $rts[0];
          $PARAM2 = $rts[1];
          $PARAM3 = $rts[2];
          $PARAM4 = $rts[3];
          ( $run_tool_exe =~ s/PARAM1/$PARAM1/go ); # Search and Replace Tag
          ( $run_tool_exe =~ s/PARAM2/$PARAM2/go ); # Search and Replace Tag
          ( $run_tool_exe =~ s/PARAM3/$PARAM3/go ); # Search and Replace Tag
          ( $run_tool_exe =~ s/PARAM4/$PARAM4/go ); # Search and Replace Tag
          $tool_param = ""; # Done w/ this. Clear it
         }


         # Look to see if the tool has the +LINE_NUM option in it, if so
         # determine the proper line number to use
         if ( $run_tool_exe =~ m/LINE_NUM/g ) 
         {
           $line_num = 0; # Default Line Number to Edit
           # A Search String was specified, so find line number of string
           if ( @goto_tag_array [ $select_index ] ne "" )
            {
             open( tmp_input_file , "<" . @filename_array[ $select_index ] );
             $line_cnt = 0;
             while ( ($_ = <tmp_input_file> ) && ( $line_num == 0 ) ) 
              { 
               $line_cnt++;
               if ( $_ =~ m/@goto_tag_array[ $select_index ]/g ) 
                {
                 $line_num = $line_cnt;
                }# if ( $_ =~ m/@goto_tag_array[ $select_index ]/g ) 
              }# while ( ($_ = <input_file> ) && ( $line_num == 0 ) ) 
             close tmp_input_file;
            }# if ( @goto_tag_array [ $select_index ] ne "" )

           # A Line Number was specified so use it
           if ( @goto_line_array [ $select_index ] ne "" )
            {
             $line_num = int( @goto_line_array [ $select_index ] );
            }# if ( @goto_line_array [ $select_index ] ne "" )
            ( $run_tool_exe =~ s/LINE_NUM/$line_num/go ); # Search+Replace Tag
         }# if ( $run_tool_exe =~ m/LINE_NUM/g ) 


       if ( ($cur_x == 0 ) && ($hier_option == 1 ) )
         { $type_hier = 1; } else { $type_hier = 0 };

       if ( ($cur_x == 0 ) && ($hier_exp_option == 1 ) )
         { $type_hier_exp = 1; } else { $type_hier_exp = 0 };

 
       if ( $type_hier == 1 )
         {
          $loop_index = $select_index+1; #1st Child. 

          # Go down hierarchy finding all visible children.
          while ( 
              ( @level_array[ $loop_index ] > @level_array[ $select_index ] ) &&
              ( @show_array [ $loop_index ] == 1            ) &&
              ( $loop_index <= $array_size )                )
            {
              $loop_index++ ;
            }  # while
          $last_visible_child = $loop_index-1;
          $start_point = $select_index;
         }
       elsif ( $type_hier_exp == 1 )
         {
          $loop_index = $select_index+1; #1st Child. 

          # Go down hierarchy finding all children, visible and invisible.
          while ( 
              ( @level_array[ $loop_index ] > @level_array[ $select_index ] ) &&
              ( $loop_index <= $array_size )                )
            {
              $loop_index++ ;
            }  # while
          $last_visible_child = $loop_index-1;
          $start_point = $select_index;
         }
      elsif ( $type_list == 1 )
         {
          $start_point = 1; # 1st Entry in Array
          $last_visible_child = $array_size; # Last Entry in Array
                   $rts = dialog_box(-1,"YOYOYOYO");
         }
       else
         {
          $start_point = $select_index;
          $last_visible_child = $select_index;  # Single. Not Hierarchy
         }

          # Now Execute Bottom Up (for compiling, etc)
          my $file_hier_list = "";
          $ret_str = "";
          $rc = 0;
          for ( $lp_i = $last_visible_child; $lp_i >= $start_point; $lp_i-- )
            {
              $cmd = $run_tool_exe;
              # Only Recalculate FileNames if were 1st columdn and hier op
              if ( ($type_hier == 1) || ($type_list == 1) || 
                   ($type_hier_exp == 1)
                 )
                {
                 $file_name = @filename_array[ $lp_i ];  
                 $mod_name  = @modname_array [ $lp_i ];  
                }
              $file_hier_list = $file_hier_list . " " . $file_name;

              $ret_str = $ret_str . "#" . $file_name . ": ";

            $file_name_no_ext = $filename;
            ($file_name_no_ext =~ m/$path_null(.*)$ext_null/o );#Strip Path+Ext 

            ( $cmd =~ s/FILE_LIST_NO_EXT/$file_name_no_ext/g );# SandR Tag
            ( $cmd =~ s/FILE_LIST/$file_name/g ); # SandR Tag

# HACK VLOG instead of VCOM HERE
             $this_is_verilog = 0; $this_is_vhdl = 0;
             if ( substr($file_name,-2,2) eq ".v")   { $this_is_verilog = 1 ; }
             if ( substr($file_name,-4,4) eq ".vhd") { $this_is_vhdl    = 1 ; }
             if ( $this_is_verilog == 1 )
              {
               # -time will force clean compiles to still output something
               ( $cmd =~ s/vcom/vcom -time/g ); # SandR Tag
               ( $cmd =~ s/vcom/vlog/g ); # SandR Tag
               ( $cmd =~ s/-explicit/ /g ); # SandR Tag
              }


#            if ( $file_name eq "file_not_found" ) { $skip_missing = 1 ; }
#              else { $skip_missing = 0 ; }

             if ( $en_trace == 1 ){print trace_file " :: $file_name\n";}

#            if ( -e $file_name ) {$skip_missing=0;} else { $skip_missing = 1; }

#           if ( ( $type_list == 1 ) && ($lp_i == $select_index) )
#             {
#              ( $cmd =~ s/FILE_LIST/$file_hier_list/go ); # SandR Tag
#             }
#            else 
#             {
              ( $cmd =~ s/MOD_NAME/$mod_name/go ); # Search and Replace Tag

              # Strip "wip." if FILE_NAME_NO_WIP tag is found
              $file_name_no_wip = 
                   solve_remove_wip_from_name($file_name,$wip_header); 
              ( $cmd =~ s/FILE_NAME_NO_WIP/$file_name_no_wip/go );

              if ( ( $cmd =~ s/FILE_NAME/$file_name/go ) )# Search Replace Tag
              {
               $wip_filename = solve_wip_name( $file_name, $wip_header);
               if ( $wip_exists != -1 )
                {
                 if ( -e $wip_filename ) # Check for WIP Existance. Camel Pg.85
                  {
                   $wip_exists = 1;
                  }# if ( -e $wip_filename ) 
                 else
                  {
                   $wip_exists = 0;
                  }
                }# if ( $wip_exists != -1 )
               }# if ( $cmd =~ s/FILE_NAME/$file_name/go ) ) ; 
#             }# if ( ( $type_list == 1 ) && ($lp_i == $select_index) )

            if ( $wip_exists == 1 )
              {
                   $rts = dialog_box(-1,"WARNING: File Checked Out  ".
                     "# File $file_name is currently checked out. ".
                     "# Press <y> to continue operation on $file_name ".
                     "# Press <n> to abort operation ".
                     "");
                    if ( $rts != ord("y") ) { $cmd = ""; }
              }# if ( $wip_exists == 1 )

            if ( (  ( $type_list == 1 ) && ( $lp_i == $select_index) ) ||
                 (    $type_list == 0                                 ) 
               )
             {
 
              # Execute an internal command
              # if ( ($tool_str =~ m/\(int\)/go ) )
              if ( $internal_tool_option == 1 ) 
               {
                # if ( ($tool_exe =~ m/block_print/go) )
                if ( $print_option == 1 )
                 {
                  dialog_box(0,"NOTE:# Printing $file_name          ");
                  @ret_str = port_solver( $file_name, $mod_name );
                  open( output_print_file , ">>" . $print_file );
                  print output_print_file "[PAGE_BREAK]\n" ;
                  foreach $tmp_str ( @ret_str )
                   {
                    print output_print_file $tmp_str . "\n" ;
                   }
                  close output_print_file;
                 }# if ( ($tool_str =~ m/\(int\)/go ) )
                elsif ( $cv_viewer == 1 )
                 {
                  set_title("$int_tool $file_name");
                  cv_view ( $file_name );
                 }# if ( ($tool_str =~ m/\(int\)/go ) )
                elsif ( $cv_rtl_viewer == 1 )
                 {
                  set_title("$int_tool $file_name");
                  cv_rtl_view ( $file_name );
                 }# if ( ($tool_str =~ m/\(int\)/go ) )
                elsif ( $cv_rtl_analyzer == 1 )
# HERE
                 {
                  @foo1_str = rtl_analyzer( $file_name );
                  $foo_str = "";
                  foreach $foo ( @foo1_str )
                  {
                   $foo_str .= "#" . $foo ;
                  }
                  $foo_str .= "# <Press Any Key> ";
                  dialog_box(-1,$foo_str);
                 }# if ( ($tool_str =~ m/\(int\)/go ) )

               }

              # Execute a UNIX Command using Pipe Method
              # elsif ( ($tool_str =~ m/\(pipe\)/go ) )
              elsif ( $pipe_option == 1 )
               {
                #  dialog_box(+1,"Executing: $cmd");
                open STATUS, "$cmd | " or die "Cant Fork: $!";
                while ( <STATUS> ) { $ret_str = $ret_str . $_ . "#"; }
                close STATUS ;  
               }

              # Straight Execute a UNIX Command.
              else
               {
                  # dialog_box(+1,"Executing: $cmd");
#                 if ( $os eq "win32" )
#                  {
#                   ( $win_exe, $win_file, $win_etc ) = split ( ' ', $cmd, 3 );
#                   # $win_no_exe = substr($win_exe,-4,4);
#                   $win_no_exe = "";
#
#                   dialog_box(-1,"Executing:#".
#                                 "#$cmd".
#                                 "#$win_exe".
#                                 "#$win_no_exe".
#                                 "#$win_file".
#                                 "");
#                   Win32::Process::Create($ProcessObj,
#                          "$win_exe",
#                          "$win_no_exe $win_file",
##                          "c:\\windows\\notepad.exe",
##                          "notepad foo.txt",
#                          0,
#                          NORMAL_PRIORITY_CLASS,
#                          ".")|| die "Fork Failed. WinSucks";
#                  } # if ( $os eq "win32" )

                #else
                #  {
                
                $fork_failed = 1; # Forking was killing PerlTk
                if ( ($fork_option == 1) && ( $os eq "unix") )
                {
# Stick with & as forking was killing PerlTk 
#                   if ( $pid = fork )
#                    {
#                     # Parent Process.
#                     $fork_failed = 0; 
#                    }
#                   elsif ( defined $pid )
#                   {
#                    # Child;
#                   @run_shell = ("$cmd"); $rc += 0xffff & system (@run_shell); 
#                    exit;
#                   }
#                  else
#                   {
#                    dialog_box(+1,"WARNING: Fork Failed: $cmd");
#                    $fork_failed = 1; 
#                   }
                }# if ( $fork_option == 1 )

                # Forking is problematic on win32
                if ( $os eq "win32" ) { $fork_failed = 1 ; }

                if ( ($fork_option == 0) || ( $fork_failed == 1 ) )
                  {
                    if ( $skip_missing != 1 )
                    {
                     $short_cmd = substr($cmd,0,50);
                     dialog_box(+0,"Executing: $short_cmd");
                     open( output_file , ">>" . $sys_file );
                       print output_file "$cmd\n";
                     close output_file;
                     @run_shell = solve_slash("$cmd"); 
                     if ( $en_trace == 1 ){print trace_file "system( $cmd )\n";}

                     set_title("ChipVault: $cmd"); # Set Xterm title 
#                      set_title("EXE");
                     $rc += 0xffff & system (@run_shell); 
                     set_title($xterm_title);
#                   Win32::Process::Create($ProcessObj,
#                          "$cmd",
#                          "iexplore.exe",
#                          "iexplore",
#                          0,
#                          NORMAL_PRIORITY_CLASS,"." );
                    }# if ( $skip_missing != 1 )
                   $skip_missing = 0 ; 
                  }

               }# elsif ( $pipe_option == 1 )

             }# if ( ($tool_str =~ m/\(int\)/go ) )

            } # for

           if ( ($tool_str =~ m/\(pipe\)/go ) )
             {
              scroll_box(0, 75, $ret_str );
             }
           else
             {
              if ($rc != 0) 
                {
                 $cmd_str = substr($cmd,0,50) . "...";
                 $perl_line = __LINE__;
                 dialog_box(-1,"ERROR $perl_line:$bell#Failed on/before:$cmd_str".
                                          "#<Press any Key>");
                }# if ($rc != 0) 
             }# if ( ($tool_str =~ m/\(pipe\)/go ) )
    } # if ( $tool_menu_skip == 0 )
     if ( ( $results_option == 1 ) && 
          ( $last_visible_child == $select_index )
        )
      {
        cv_view ( $slog_file ); # View Short Log if single file
      }# if ( $results_option == 1 )
       $redraw = 1;
       $check_wip_status = 1; # See if new WIP files exist 
       $key_val="";
      if ( $batch_mode == 1 ) { ++$interrupted; }
      if ( $print_option == 1 ) { make_pdf( $print_file, $pdf_file, "" ); }
      if ( $x_mouse_enable == 1 ) { x_mouse_on(); }
   } # Enter Key

##################################################
# Test HACK            
##################################################
  elsif ( $k_test_hash{$key_val}  == 1 )
    { 
     $rts = dialog_box( -1, "Press a Key" );
     dialog_box( 4 , "Pressed $rts " );
     $redraw = 1;
    }

##################################################
# Toggle Debug Setting
##################################################
    elsif ( $k_debug_hash{$key_val}  == 1 )
    {
     $debug_mode = $debug_mode * -1;
    }# 
##################################################
# Expand/Collapse Key handling
##################################################
    elsif ( ( $k_togl_hash{$key_val}  == 1 ) && 
         ( @flag_array[ $select_index ] != 0 )   )
 {
      $i = $select_index + 1; #1st Child
      $vis = @show_array[ $i ] * -1;

      # 1st Toggle the Parents Flag
      if (    ( $vis == 1 ) )
        {
          @flag_array[ $select_index ] = +1; # - : Expand for Visible
        }
      elsif ( ( $vis == -1 ) )
        {
          @flag_array[ $select_index ] = -1; # + : Collapse and Hide Children
        }

      # Now Take Care of the Children
      while (
              ( @level_array[ $i ] >  @level_array[ $select_index ] ) &&
              ( $i < $array_size )                                            )
       {
       # Collapse All down to leaf
       if ( $vis == -1 )
       {
        if ( @level_array[ $i ] > @level_array[ $select_index ] )
         {
           # Set/Clr Visibility Flag for all parents
           @show_array[ $i ] = $vis;
           if (    ( $vis == 1 ) && ( @flag_array[ $i ] != 0 ) )
              {
               @flag_array[ $i ]  = +1 ; # -
              }
           elsif ( ( $vis == -1 ) && ( @flag_array[ $i ] != 0 ) )
              {
               @flag_array[ $i ]  = -1 ; # +  Collapse them all
              }

         }# if ( @level_array[ $i ] > @level_array[ $select_index ] )
        } else
        # Expand one level only. Don't expand to leaf
        {
         if ( @level_array[ $i ] == @level_array[ $select_index ]+1 )
         {
           # Set/Clr Visibility Flag for all parents
           @show_array[ $i ] = $vis;
           if (    ( $vis == 1 ) && ( @flag_array[ $i ] != 0 ) )
              {
               @flag_array[ $i ]  = -1 ; # -
              }
          }# if ( @level_array[ $i ] > @level_array[ $select_index ] )
        }# if ( $vis == -1 )
        $i++;
       } # While
      $redraw = 1;
    }# if ( $key_val == $k_sp )  # Expand/Collapse


##################################################
# Expand to # and Collapse below #               #
# ie <3> Will view level 1-3 only.               #
##################################################
    elsif ( ( $key_val >= $k_1 ) && ( $key_val <= $k_9 ) )
    {
      if ( $key_val == $k_1 ) { $sel = 1 ; }
      if ( $key_val == $k_2 ) { $sel = 2 ; }
      if ( $key_val == $k_3 ) { $sel = 3 ; }
      if ( $key_val == $k_4 ) { $sel = 4 ; }
      if ( $key_val == $k_5 ) { $sel = 5 ; }
      if ( $key_val == $k_6 ) { $sel = 6 ; }
      if ( $key_val == $k_7 ) { $sel = 7 ; }
      if ( $key_val == $k_8 ) { $sel = 8 ; }
      if ( $key_val == $k_9 ) { $sel = 9 ; }

      for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
        {
         if ( @level_array[ $i ] < $sel )
          {
           @show_array[ $i ] = 1 ;  # Show
           # + Expand   All Children that have children
           if ( @flag_array[ $i ] != 0 ) { @flag_array[$i] = +1 ;}  # -
          }
         elsif ( @level_array[ $i ] == $sel )
          {
           @show_array[ $i ] = 1 ;  # Show
           # + Collapse All Children that have children
           if ( @flag_array[ $i ] != 0 ) { @flag_array[$i] = -1 ;} 
          }
         else
          {
           @show_array[ $i ] = -1 ; # Hide   
          }
        } # For

      $cur_y = $y_screen_offset ;
      $redraw = 1;
    }# if ( $key_val == $k_sp )  # Expand/Collapse


   screen_sizing();
   display_main();
   return; 
}# sub process_keys()


##################################################
# Toggle thru Tool Selections
##################################################
sub display_tool_menu {
  my $tool_disp_level = 1;
  my @parent_stack;
if ( $en_trace == 1 ){print trace_file "display_tool_menu()\n";}

  $tool_win_size = 10 ; # HACK. Size of Tool Window. Make small so cascadable

       $edit_start = 1; # Always Start at the Top
       $edit_end   = @my_tool[0];
       # In case we bail
       $old_edit_sel = $edit_sel;
       $old_tool_str = $tool_str;

       $rts_key = 0;
       $dsp_start = 1;
       $edit_selected = 1;
       $parent = $edit_start;
       $kid_level = -1;
        $parent_level = 0;

       # This Generates a scrollable list box.
       # while ( ($rts_key != $k_cr)&&($rts_key != $k_q )&&($rts_key != $k_sp) )
       $break_outer_loop = 0;
       while ( ($break_outer_loop==0)&&($rts_key != $k_q) )
       {
        $is_kid = 0;
        $parent_level = $tool_disp_level -1 ;

          # Display the Current Selection at the Top of the Screen
           $tool_exe = ""; $tool_str = "";
          ($tool_str, $tool_exe, $ETC )=split('#', @my_tool[$edit_selected],3);
           ( $tool_str =~ s/-//go ); # Remove All the - and replace with nul
          ($tool_str_disp, $ETC ) = split (' ', $tool_str,2 );
           $tool_str_disp = pack "A20", "$tool_str_disp"; # Pad to right
           $help_str2 =  "<t>ool=".substr($tool_str_disp,0,20);
           gotoxy($tool_x_loc ,0);
           my_print($help_str2);

          # Build a string of what exists at this level of hierarchy
          $edit_pos   = $edit_start; # Starting Index in Tool List
          $break_loop = 0;
          $tmp_i      = 1;

#         if ( $en_trace == 1 ){print trace_file "DSP_L : $tool_disp_level\n";}
          while ( $break_loop == 0 )
          {
           ($tool_str, $tool_exe, $ETC ) = split ('#', @my_tool[$edit_pos], 3);
            if ( substr($tool_str,0,1) eq "-" )
             {
              ($F1,$F2) = split (' ', $tool_str, 2 );
               $parent_level = length($F1); # How Many - Dashes represent level
               $is_kid = 0;
               $kid_level = -1;
#              if ( $en_trace == 1 ){print trace_file "PARENT: $parent_level $tool_str\n";}
               if ( $parent_level < $tool_disp_level) {$break_loop=1; }# Outside
               if ( $F2 eq "" ) { $parent_level--; }

             }
            else
             {
               $kid_level = $parent_level+1;
               $is_kid = 1;
#               if ( $en_trace == 1 ){print trace_file "KID   : $kid_level $tool_str\n";}
             }# if ( substr($tool_str,0,1) eq "-" )

            # if ( ($parent_level != 0) && ($parent_level < $tool_disp_level))
            #  {$break_loop=1; }# Outside

            if ( ( ( $parent_level == $tool_disp_level ) && ($is_kid == 0 )) ||
                 ( $kid_level    == $tool_disp_level )
               )
             {
#               if ( $en_trace == 1 ){print trace_file "KEEP  : $tool_str\n";}
              @my_tool_disp [$tmp_i] = @my_tool[$edit_pos];
              @my_tool_loc  [$tmp_i] = $edit_pos;
              if ( $is_kid == 1 ) { @my_tool_level[$tmp_i] = 255 ; }
              else                { @my_tool_level[$tmp_i] = $parent_level;}
              $tmp_i++; # Count it
             }# if ( $level == $tool_disp_level )
            $edit_pos++;
            if ( $edit_pos == $edit_end )  { $break_loop = 1; }
          }# while ( $break_loop == 0 )

          $dsp_stop = $tmp_i; # Mark the End

          # Build the display string to scroll thru
          $tmp_i = $dsp_start;
          $dsp_lines = 0; # How many lines have been displayed
          $str = "#";
          $break_loop = 0;
          while ( $break_loop == 0 )
          {
           ($tool_str, $tool_exe, $ETC)=split('#',@my_tool_disp[$tmp_i], 3);
            if ($disp_tool_bindings==1)
              {
                ($preETC,$tool_key,$ETC )=split('<',$tool_str,3); # Parse <a>
                ($tool_key,$ETC )=split('>',$tool_key,2);         # Parse <a>
                if ( $tool_key ne "" )
                 {
                  $tool_key = "<".$tool_key.">";
                 }
              }
            else
              {
                $tool_key = "   ";
              }
            if ($disp_tool_opts==0){($tool_str,$ETC)=split('\(',$tool_str);}
            $tool_str = $tool_str . $tool_key ."                             ";
            ( $tool_str =~ s/-//go ); # Remove All the - and replace with nul

            if (@my_tool_level[$tmp_i] != 255) { $tool_str="[+] ".$tool_str; }

            $tool_str = substr( $tool_str, 0, 25); # Make all Len Same
#            $tool_str = substr( $tool_str, 0, 30); # Make all Len Same
            $str = $str . $tool_str . "#"; 
            $tmp_i++;
            $dsp_lines++; # Lines Displayed
            if ( $dsp_lines == $tool_win_size) { $break_loop = 1; }
            if ( $tmp_i     == $dsp_stop )     { $break_loop = 1; }
          }# while ( $break_loop == 0 )

          # Pad to End
          while ( $dsp_lines++ < $tool_win_size) { $str=$str.pack "A25","#";}

          $str=$str.substr("#<ENTER>=Select  <h>=Info       ",0,25); 
          $str=$str.substr("#<^/v>=Navigate  <q>=Bail       ",0,25); 

          # Draw the Cascading Dialog Box and get a key
          $rts_key = dialog_box(-1,$str,15+(($tool_disp_level-1)*4 ),
                                        1+(($tool_disp_level-1)*3) );

          # Process the Key Input
          if ( ( $rts_key == $k_cr ) || ( $k_nav_rt_hash{$rts_key}  == 1 ) ||
               ( $k_togl_hash {$rts_key}  == 1 ) )
            {
              if ( ( $rts_key == $k_cr ) && (@my_tool_level[$dsp_start]==255))
               {
                $break_outer_loop = 1; # At the Leaf Level, so exit and select
               }
              elsif ( @my_tool_level[$dsp_start] != 255 )
               {
                 push @parent_stack, $edit_start;
                 push @parent_stack, $edit_selected;
                 $edit_start    = @my_tool_loc [$dsp_start]+1;
                 $edit_selected = $edit_start;
                 push @parent_stack, $dsp_start;
                 $dsp_start     = 1; 
                 $tool_disp_level++; 
                 push @parent_stack, $parent;
                 $parent = $edit_start;
               #  $parent_level = $parent_level++;
               }
            }

          elsif ( $k_nav_dn_hash{$rts_key}  == 1 ) 
            { 
             $dsp_start++; 
             if ( $dsp_start == $dsp_stop ) { $dsp_start--; }
             $edit_selected = @my_tool_loc [$dsp_start];
            }
          elsif ( ( $k_nav_up_hash{$rts_key}  == 1 ) ||
                  ( $k_nav_lf_hash{$rts_key}  == 1 )    )
            { 
             $dsp_start--; 
             if ( ( $dsp_start == 0 ) || ( $k_nav_lf_hash{$rts_key}  == 1 ) )
              { 
               # Erase Last Dialog Box
               $dsp_lines=-2; $str = "";
               while ( $dsp_lines++ <$tool_win_size){$str=$str.pack "A25","#";}
               dialog_box(0,$str,15+(($tool_disp_level-1)*4),
                                  1+(($tool_disp_level-1)*3) , 1 );
               $tool_disp_level--; 
               $edit_start    = pop( @parent_stack );
               $dsp_start     = pop( @parent_stack );
               $edit_selected = pop( @parent_stack );
               $edit_start    = pop( @parent_stack );
               if ( $en_trace == 1 ){print trace_file "pop $edit_start\n";}
               if ( $tool_disp_level == 0 ) { $break_outer_loop = 1; }
              }
             $edit_selected = @my_tool_loc [$dsp_start];
            }
          elsif ( $k_tool_help{$rts_key}  == 1 ) 
           {
#             $edit_sel = $edit_start; # Remember Selection
             $edit_sel = @my_tool_loc [$dsp_start];
             ($tool_str, $tool_exe, $ETC ) = split('#', @my_tool[$edit_sel],3);

            ($F1, $ETC) = split (' ', $tool_str, 2 );
            $dsp_str = $tool_help_hash{$F1} ;
           
            if ( $dsp_str eq "" ) 
            {
             ($F1, $ETC) = split (' ', $tool_exe, 2 );
             $dsp_str = $tool_help_hash{$F1} ;
            }

            if ( $dsp_str ne "" )
             {
                 dialog_box(-1,"Tool_Info: $F1".
                                "#$tool_help_hash{$F1}".
                                "#<Press any Key>");
                 clear_screen();
             }# if ( $tool_help_hash{$F1} ne "" )
            else
             {
                 dialog_box(-1,"Tool_Info: $F1".
                                "#Sorry, Help currently not available for $F1".
                                "#<Press any Key>");
                 clear_screen();
             }
           }# elsif ( $k_tool_help{$rts_key}  == 1 ) 

        }# while ( ($rts_key != $k_cr) 

      if ( $rts_key == $k_cr )
      {
        $edit_selected = @my_tool_loc [$dsp_start];
        $edit_start = $edit_selected;
        $edit_sel = $edit_start; # Remember Selection
        ($tool_str, $tool_exe, $ETC ) = split ('#', @my_tool[$edit_sel] , 3);
        # ( $tool_str =~ s/ //go ); # Strip whitespace
        $tool_param = $my_tool_param {$edit_sel}; 
        $new_tool_selected = 1;
       } #if ( $rts_key == $k_cr )
     else
       { 
        $key_val = ""; # We Bailed, so kill the space bar entry
        $edit_sel = $old_edit_sel;
        $tool_str = $old_tool_str;
       } #if ( $rts_key == $k_cr )

     
     if ( $edit_sel == @tool_history[0] )
      { 
       # nothing to do. We used this tool last time
      }
     else
      {
        # Push new tool on the history list
        for ( my $my_i = 8; $my_i > 0 ; $my_i-- )
          {
           @tool_history[ $my_i ] = @tool_history[ $my_i-1];
          }
         @tool_history[ 0 ] = $edit_sel;
      }# if ( $edit_sel == @tool_history[0] )

     $redraw = 1;
}# sub display_tool_menu {


##################################################
# Change the Display Style
##################################################
sub update_style {
 my($style) = @_;
 if ( $en_trace == 1 ){print trace_file "update_style()\n";}
   $flag_expanded   = @style_flag_expanded [$style];    
   $flag_collapsed  = @style_flag_collapsed[$style];    
   $flag_nokids     = @style_flag_nokids   [$style];    
#  $x_scale         = @style_x_scale       [$style];
}# sub update_style {


##################################################
# View the Help Page
##################################################
sub display_help {
 if ( $en_trace == 1 ){print trace_file "display_help()\n";}
      open( input_file , "<" . $0 ); 
      $i = 0;
      $help_lines = "";
      while ( $_ = <input_file> ) 
      { 
       if (
            (substr($_,0,2) eq "#-") ||
            (substr($_,0,2) eq "#_") ||
            (substr($_,0,2) eq "#H") ||
            (substr($_,0,2) eq "#L") ||
            (substr($_,0,2) eq "#Z")
          )
        {
         ( $_ =~ s/\A#H//go ); # Replace ALL '#H' with null
         ( $_ =~ s/\A#L//go ); # Replace ALL '#L' with null
         ( $_ =~ s/\A#-//go ); # Replace ALL '#-' with null
         ( $_ =~ s/\A#_//go ); # Replace ALL '#_' with null
         ( $_ =~ s/\A#Z//go ); # Replace ALL '#Z' with null
         chomp $_; # Remove CR;
          $help_lines[ $i++] = $_ ;
        }
      }# while ( $_ = <input_file> ) 
      close input_file;

       $max_lines = $i;
       $start_line =  0;

      for ( $i = 0 ; $i < $max_lines; $i++ )
       {
         if ( ( $help_lines[$i] =~ m/ChipVault Help/go )) # Find Start Page
          {
           $start_line =  $i;
          }
       }
      $width = 75;
      scroll_box  ( $start_line, $width , @help_lines );
      $redraw = 1;

}# sub display_help()

##############################
# make_rtl  
##############################
sub make_rtl {
  if ( $en_trace == 1 ){print trace_file "make_rtl()\n";}
        $file_name = @filename_array[ $select_index ];
        if ( $int_tool eq "generate_VHDL"    )       { $rtl_type = "vhdl"; }
          else                                       { $rtl_type = "verilog"; }
        $rts = generate_rtl( $file_name, $rtl_type );
        if ( $rts ne "" )
        {
          # Add new entry to visible array (not hlist.txt)
          ( $mod_name, $child_name ) = split ( ' ', $rts, 2 );
          @modname_array    [ $array_size ] = $mod_name;
          @filename_array   [ $array_size ] = $child_name;
          @level_array      [ $array_size ] = 1;  # Which level this module on 
          @show_array       [ $array_size ] = 1;  # Default to show
          @flag_array       [ $array_size ] = 0;  # No Children
          $array_size++;
        }
        $redraw = 1; 
}# sub make_rtl()

##############################
# label_release a Design. This function rips thru all of the history log
# files for the entire design and annotates a release revision for each
# files' log file.
##############################
sub label_release {
  if ( $en_trace == 1 ){print trace_file "label_release()\n";}
  if ( $enable_history == 1 )
    { 
        $my_time = localtime(time); # Create timestamp with no spaces.
         ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
         ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'

       $rts = dialog_box(-2,"Release:#Please enter short " . 
         "title for this release followed by <ENTER> key.#".
         "(NULL for generic RELEASE_" . $my_time ." )".
         "#:");
             
       if ( $rts[0] eq "" ) { $release_title = "RELEASE_" . $my_time; }
       else                 {  $release_title = $rts[0];    }
       ( $release_title =~ s/ /_/go ); # Remove All ' ' with '__'

    for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
     {
        $new_filename =   @filename_array[ $i ];
        $history_filename=solve_path($new_filename) . $hist_log_header.
                          solve_file($new_filename) . $hist_log_footer;

        $rc = open( history_output_file , ">>" . $history_filename );#Apnd

        # Note: stat returns: dev,ino,mode,nlink,uid,gid,rdev, size,atime,mtime,
        $mtime = ( stat $new_filename  ) [ 9 ] ; # Modify Time since Epoch
        if ( $mtime > 0 )
         {
          $mtime = localtime( $mtime); # Create a unique name via time
          ( $mtime =~ s/ /__/go ); # Remove All ' ' with '__'
          ( $mtime =~ s/:/_/go ); # Remove All ':' with '_'
         }
        else
         {
          $mtime = $my_time; # Use Current time if it doesnt exist.
         }
        $rc = print history_output_file $my_time."  ".$my_name." : ".
          " RELEASE " . $release_title ." : " . $mtime."\n" ;
        $rc += close history_output_file ;
     } # for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
   $rts = dialog_box(2, "Note:# Label Release $release_title Completed."); 
   }# if ( $enable_history == 1 )
  else
  {
   $perl_line = __LINE__;
   dialog_box(2 ,"ERROR $perl_line:$bell#enable_history veriable must be enabled!");
  }# if ( $enable_history == 1 )
}# sub label_release {


##############################
# create_branch. This function creates a lower subdir which contains copies
# of all the current files.
##############################
sub create_branch {
  if ( $en_trace == 1 ){print trace_file "create_branch()\n";}
     $my_time = localtime(time); # Create timestamp with no spaces.
     ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
     ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'

    if ( $release_title eq "" )
     {
       $rts = dialog_box(-2,"Release:#Please enter short " . 
         "title for this release followed by <ENTER> key.#".
         "(NULL for generic RELEASE_" . $my_time ." )".
         "#:");
             
       if ( $rts[0] eq "" ) { $release_title = "RELEASE_" . $my_time; }
       else                 { $release_title = $rts[0];    }
     }# if ( $release_title ne "" )

# If the Branch Directory doesnt exist, create it
    if ( -e $branches_subdir )
     {
     }
    else
     {
        @run_shell = solve_slash("$mkdir_cmd $branches_subdir");
        if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
        $rc = 0xffff & system (@run_shell);
        if ( $rc != 0 )
         {
           $perl_line = __LINE__;
           dialog_box(-1, "ERROR $perl_line:$bell# Unable to Create $branches_subdir!\n".
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
           exit  (10 );
         }# if ( $rc != 0 )
     }# if ( -e $branches_subdir )

# If the Release Directory under Branch Directory doesnt exist, create it
    $dest_dir = $branches_subdir . $filecat . $release_title ;
    if ( -e $dest_dir )
     {
     }
    else
     {
        @run_shell = solve_slash("$mkdir_cmd $dest_dir");
        if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
        $rc = 0xffff & system (@run_shell);
        if ( $rc != 0 )
         {
           $perl_line = __LINE__;
           dialog_box(-1, "ERROR $perl_line:$bell# Unable to Create $dest_dir!\n".
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
           exit  (10 );
         }# if ( $rc != 0 )
     }# if ( -e $dest_dir )

  if ( $gzip_branched_files eq "?" )
   {
      $rts = dialog_box(-1,
             "GZIP Files:".
             "# Would you like me to GZIP all the branched files? ".
             "# (y/n) :" );
    if ( $rts == ord ("y" ) ) { $gzip_branched_files = 1;}
   }


# Now copy all the files over
    for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
     {
      $org_filename =   @filename_array[ $i ];
      if ( -e $org_filename )
      {
        if ( $org_filename ne solve_file($org_filename) )
         {
          dialog_box(-1, "WARNING:# Your hlist contains a path to the file  ".
                         "#$org_filename which is ".
                        "#not portable to the generated branch directory. The ".
                        "#original file will be copied, but the hlist will ".
                        "#either still point to the original file (hard path)".
                        "#or else point to an invalid relative path name.".
                        "#Please adjust your hlist accordingly.".
                        "#<Press any Key>");
         } # if ( $org_filename ne solve_file($org_filename) )

        $new_filename =   $dest_dir . $filecat . solve_file( $org_filename );
        @run_shell = solve_slash("$cp_cmd $org_filename $new_filename");
        if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
        $rc = 0xffff & system (@run_shell);
        if ( $rc != 0 )
         {
           $perl_line = __LINE__;
           dialog_box(-1, "ERROR $perl_line:$bell# Unable to Copy $org_filename to $new_filename!\n". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
           exit  (10 );
         }# if ( $rc != 0 )
      }# if ( $org_filename ne "file_not_found" )
     else
      {
       dialog_box(1, "WARNING:# file_not_found for ".@modname_array[$i]."!" );
      }
     } # for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries

        if ( ($gzip_branched_files == 1 ) && ( $gzip_dir_cmd ne "" ) )
         {
          # @run_shell = ("$gzip_cmd $new_filename");
          @run_shell = solve_slash("$gzip_dir_cmd $dest_dir");
          if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
          $rc = 0xffff & system (@run_shell);
          if ( $rc != 0 )
           {
             $perl_line = __LINE__;
             dialog_box(3, "ERROR $perl_line:$bell# Unable to GZIP $dest_dir!\n");
           }# if ( $rc != 0 )
         }# if ( $gzip_branched_files == 1 )
   $rts = dialog_box(2, "Note:# Branch Directory $dest_dir Completed."); 
}# sub create_branch()

##############################
# check_restore file
##############################
sub check_restore {
  if ( $en_trace == 1 ){print trace_file "check_restore()\n";}
     $cmd = $cp_cmd;
     $org_filename = @filename_array[ $select_index ];
     $wip_filename = solve_wip_name( $org_filename, $wip_header );

     if ( $enable_archives == 1 ) 
       { archive_restore ( $org_filename, $wip_filename ); }
     $redraw = 1; 
     $check_wip_status = 1; # See if new WIP files exist 
}# sub check_restore()


##############################
# check_out file
##############################
sub check_out {
  if ( $en_trace == 1 ){print trace_file "check_out()\n";}
      $check_wip_status = 1; # See if new WIP files exist 
      $uname = @wip_owner_array[ $select_index ] ;
      if ( $uname eq "" )
      {
        $cmd = $cp_cmd;
        $org_filename = @filename_array[ $select_index ];
        $wip_filename = solve_wip_name( $org_filename, $wip_header );

        # Create 2 Copies. One for editting_WIP, one for tarring
        @run_cp_shell     = solve_slash("$cmd $org_filename $wip_filename");
        if ( $en_trace == 1 ){print trace_file "system(@run_cp_shell)\n";}
        $rc = 0xffff & system (@run_cp_shell);
        if ( $rc != 0 )
         {
           $perl_line = __LINE__;
           dialog_box(-1, "ERROR $perl_line:$bell# Unable to Copy $org_filename!\n". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
           exit  (10 );
         }
        else
         {
          if ( $enable_archives == 1 ) { archive( $org_filename ); }
         }
      }
      else
      {
        dialog_box(3,"WARNING:$bell# I'm sorry. This is checked out by $uname");
      }
      $redraw = 1; 

}# sub check_out


##############################
# check_in file
##############################
sub check_in {
  if ( $en_trace == 1 ){print trace_file "check_in()\n";}
      $check_wip_status = 1; # See if new WIP files exist 
      if ( $os eq "unix" ) { $uname = @wip_owner_array[ $select_index ] ; }
      else                 { $uname = $my_name ; } #Win32 must assume ownership

      $new_filename =               @filename_array[ $select_index ];
      $org_filename=solve_wip_name(@filename_array[$select_index],$wip_header);


      if ( $enable_confirm_checkin == 1 )
       { 
           $confirm_checkin = dialog_box(-1,
             "Confirm Checkin:".
             "# Are you sure you want me to checkin $org_filename? ".
             "# Doing so will ERASE the existing $new_filename. " .
             "# (Note: Remove this prompting with enable_confirm_checkin=0) ".
             "# Please Confirm Checkin (y/n) :". 
             "");
       }
      else
       {
        $confirm_checkin = "y";
       }
      # dialog_box(5, "Pressed $confirm_checkin");

      if ( ( $uname eq $my_name) && ( $confirm_checkin eq ord("y") ) )
        {
         if ( $enable_archives == 1 ) { archive($org_filename); }
         
         $cmd = $cp_cmd;
         $cmd = $cmd . $org_filename . " " . $new_filename;

         @run_shell     = solve_slash("$cmd");
         if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
         $rc = 0xffff & system (@run_shell);
         if ( $rc != 0 )
          {
            $perl_line = __LINE__;
            dialog_box(-1,"ERROR $perl_line:$bell# Unable to Copy : $cmd ". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
            exit  (10 );
          } 

         $cmd = "$rm_cmd $org_filename";
         @run_shell     = solve_slash("$cmd");
         if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
         $rc = 0xffff & system (@run_shell);
         if ( $rc != 0 )
           {
             $perl_line = __LINE__;
             dialog_box(3,"ERROR $perl_line:$bell# Unable to Delete: $cmd ");
             exit  (10 );
           }

         if ( $enable_history == 1 )
          { 
            $rts = dialog_box(-2,"ChangeHistory:#Please enter short " . 
                  "description of changes made followed by <ENTER> key.#".
                  "(NULL to reuse last '". substr($change_history,0,40)."..'". 
                  "#:");
             
            if ( $rts[0] ne "" ) 
             {
              $change_history = $rts[0]; 
             }

            $history_filename=solve_path($new_filename) . $hist_log_header.
                              solve_file($new_filename) . $hist_log_footer;


            $rc = open( history_output_file , ">>" . $history_filename );#Apnd
            if ( $rc == 0 ) 
             {
              $perl_line = __LINE__;
              dialog_box(-1,"ERROR $perl_line:$bell# Can't Append to $history_filename ". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
              exit ( 10 );
             }
            $my_time = localtime(time); # Create timestamp with no spaces.
            ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
            ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'
 
            $rc = print history_output_file $my_time."  ".$my_name." : ".
                                      $change_history."\n" ;
            $rc += close history_output_file ;
           }# if ( $enable_history == 1 )

         if ( ($send_email_on_check_in == 1) && ($os eq "unix") )
          { 
           $send_email_question = dialog_box(-1,
             "Send Email:".
             "# Would you like me to send email notification of the ".
             "# Check In of $new_filename ?".
             "# (y/n) :". 
             "");
           if ( $send_email_question == ord ("y" ) )
            {
              foreach $to ( @email_list )
              {
                $to   = $to      . $email_domain;
                $from = $my_name . $email_domain;
                $subject = "CheckIn $new_filename"; 
                $body    = "";
                send_email( $to, $from, $subject , $body);
              } # for each
            }# if ( $send_email_question == ord ("y" ) )
          }# if ( $send_email_on_check_in == 1 )

         }# if ( $uname eq $my_name )
        else
         {
          dialog_box(-1,"WARNING:$bell Checkin aborted". 
                     "# $my_name doesnt have this checked out".
                     "# <Press Any Key> " );
         }

      $redraw = 1; 
       
}# sub check_in

##############################
# check_abandon file
##############################
sub check_abandon {
  if ( $en_trace == 1 ){print trace_file "check_abandon()\n";}
#     elsif ( ($tool_str eq "check_abandon" ) && ( $cur_x < 2  ) )
#     {
      $check_wip_status = 1; # See if new WIP files exist 
      $uname = @wip_owner_array[ $select_index ] ;
      if ( $uname eq $my_name )
        {
          $file_name_tmp = @filename_array[ $select_index ];
         # $file_name = $wip_header . $file_name_tmp;
          $file_name = solve_wip_name($file_name_tmp, $wip_header);
          $key_val_confirm = dialog_box(-1," Delete changes to $file_name? <Y>es <N>o ");
          if ( $key_val_confirm == ord ("y") )
          {
           $cmd = $trash_can_cmd . $file_name . " " . $trash_can_dir;
           @run_shell     = solve_slash("$cmd");
           if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
           $rc = 0xffff & system (@run_shell);
           if ( $rc != 0 )
            {  
              $perl_line = __LINE__; 
              dialog_box(-1,"ERROR $perl_line:$bell Unable to Delete : $cmd". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
              exit  (10 );
            }
          }# if ( $key_val_confirm == ord ("y") )
        }#if ( $uname eq $my_name )
        $redraw = 1; 
}# sub check_abandon {


##################################################
# Run RCS archiving script
##################################################
sub archive_to_rcs {
  if ( $en_trace == 1 ){print trace_file "archive_to_rcs()\n";}
  clear_screen();
  $my_time = localtime(time); # Create timestamp with no spaces.
  ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
  ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'

  $rts = dialog_box(-2,"Release:#Please enter short " . 
  "title for this release followed by <ENTER> key.#".
  "(NULL for generic RELEASE_" . $my_time ." )".
  "#:");
  clear_screen();
  if ( $rts[0] eq "" ) { $release_title = "RELEASE_" . $my_time; }
  else                 {  $release_title = $rts[0];    }
  ( $release_title =~ s/ /_/go ); # Remove All ' ' with '__'

# @run_shell = ("../subversion/checkin.sh $release_title");
  $cmd = "csh -b ../subversion/checkin.sh $release_title";
  @run_shell = ( $cmd );
  if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
  $rc = 0xffff & system (@run_shell);
  if ( $rc != 0 )
  {
    $perl_line = __LINE__; 
    dialog_box(-1, "ERROR @run_shell Failed $perl_line". "# <Press Any Key> ");
  }
  else
  {
    dialog_box(-1, "RCS Results". "# <Press Any Key> ");
  }
  clear_screen();
  $redraw = 1;
# OY
}# sub archive_to_rcs();

##################################################

##################################################
# View the Ports of the Parent Block 
##################################################
sub display_ports_parent {
  if ( $en_trace == 1 ){print trace_file "display_ports_parent()\n";}
     clear_screen();
      @ret_str = port_solver( $file_name, $mod_name );
     scroll_box(0, 75, @ret_str );
     clear_screen();
      $redraw = 1;
}# sub display_ports_parents();

##################################################
# View the Child Blocks of the current Block
##################################################
sub display_ports_kids {
  if ( $en_trace == 1 ){print trace_file "display_ports_kids()\n";}
     clear_screen();
     $my_i = $select_index+1; #1st Child.
      undef @display_line_array; # clear old
      @display_line_array[0] = "[Children Block View] (Scroll Right/Left) ";
      @display_line_array[1] = " ";
     # Go down hierarchy finding all visible children at this level.
     # Stop at end of hierarchy or when we've reached the next parent
      while ( 
              ( $my_i <= $array_size ) &&
              ( @level_array[ $my_i ] > @level_array[ $select_index ] ) 
            )
            {
              if ( @level_array[ $my_i ] == @level_array[ $select_index+1 ] ) 
               {
                @ret_str = port_solver( $filename_array[ $my_i ],
                                        $modname_array[ $my_i ]   );
                   # This below hack makes all have 255 lines and limits net
                   # count to 255 per module. Lame!
                   while ( @ret_str < 255 ) # HACK!! FIX FIX FIX
                    {
                     push @ret_str, " ";
                    }
                $my_k = 2; # 1st 2 lines are ID and whitespace
                foreach $_ ( @ret_str )
                 {
                  $_ = pack "A80", $_; # Pad right 80 wide
                  @display_line_array[$my_k] = @display_line_array[$my_k] . $_ ;
                  $my_k++;
                 }
               }# if (@level_array[ $my_i ]==@level_array[ $select_index+1 ] ) 
              $my_i++ ;
            }  # while ( $my_i <= $array_size )

     scroll_box(0, ($maxx-4), @display_line_array );
     clear_screen();
      $redraw = 1;
}# sub display_ports_kids {



##################################################
# Draw the Display Screen
##################################################
sub display_main {
  if ( $en_trace == 1 ){print trace_file "display_main()\n";}
       if ( $debug_mode == 1 ) 
        {
         gotoxy(60,0);
         # my_print( "Key=$key_val $mouse_x $mouse_y   ");  
         my_print( "ToolBut=@my_tool[$tk_tool_but_select] ");
        }

########################
# Display Banner Stuff 
########################
    if ( ($redraw == 1) && ( $batch_mode != 1 ) ) 
    { 
       clear_screen(); 
       gotoxy(0,0);
       my_print("ChipVault");

       ($tool_str_disp, $ETC ) = split (' ', $tool_str,2 );
       # $help_str2 =  " <t>ool=".$tool_str_disp."         ";
       $tool_str_disp = pack "A20", "$tool_str_disp"; # Pad to right
       $help_str2 =  "<t>ool=".substr($tool_str_disp,0,20);

       gotoxy($tool_x_loc ,0);        my_print($help_str2);
       gotoxy(0 ,($maxy-1)); my_print($help_str1);
       gotoxy(0 ,($maxy-2)); my_print($help_str3);

      if ( $cur_x >= 2 )
        {
          gotoxy(2 ,1 );
          my_print("[ $cur_x ".$report_filename_title [ $cur_x ]."]") ;
          gotoxy( $status_x_loc-2 , 0 );
          my_print("          ");
        }
      else
        {
          gotoxy(0, ($y_screen_offset-1) );
          if    ( $disp_select == 0 ) { $disp_select_str = " Main-Line "; }
          elsif ( $disp_select == 1 ) { $disp_select_str = "Source File"; }
          elsif ( $disp_select == 2 ) { $disp_select_str = "Ref-Des    "; }
          my_print("[$disp_select_str]");

          gotoxy( $status_x_loc-2, ($y_screen_offset-1) );
          my_print("[WorkInProg]");
        }# if ( $cur_x >= 2 )
     }# if ( ($redraw == 1) && ( $batch_mode != 1 ) ) 


     # Display Clock in lower right whenever the time changes.
     if ( $enable_clock == 1 )
       {
           $my_clock = localtime(time); # Create timestamp with no spaces.
           ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $my_clock ,5) ; #Parse
           ($F1, $F2, $F3, $ETC ) = split (':', $F4,4) ; #Parse
           $my_clock = "$F1:$F2"; # Just Hours and Minutes
           if ( $my_clock ne $old_my_clock )
           {
           # gotoxy( ($clock_x_loc) , ($maxy-2) );
             gotoxy( ($clock_x_loc) , 0 );
             my_print("$my_clock");
             $old_my_clock = $my_clock;
           }# if ( $my_clock ne $old_my_clock )
       }# if ( $enable_clock == 1 )

    $lines_drawn = 0;
    $y_pos = $y_screen_offset;
    $select_index = 0;

##################################################
# Recalculate Y location of all entries based on
# Their visibility. If OFF, force to -1. If ON
# then they get last shown location +1
##################################################
    $last_visible = 0;
    for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
     {
       if ( @show_array [ $i ] == -1 ) 
        {
         @y_loc_array[$i] = -1;
        }

       if ( @show_array [ $i ] == 1 ) 
        {
         $last_visible++;
         @y_loc_array[$i] = $last_visible;
        }
     } # For

##################################################
# Check to See if a Work In Progress File Exists
# Note: I used to search on all the files all the
# time, which worked fine on UNIX, but became dog
# slow on Win32 systems. Now I only look for visible
# an I look periodically every few key strokes.
##################################################
 for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
 {
 if ( ( $check_wip_status == 1 ) )
  {
   $wip_filename = solve_wip_name(@filename_array[$i] , $wip_header);
   if ( -e $wip_filename ) # Check for File Existance. See Camel Pg.85
   {
    # Make sure WIP file has a newer timestamp than mainline
    $main_mtime = ( stat @filename_array[$i] ) [ 9 ] ; # mtime
    $wip_mtime  = ( stat $wip_filename  ) [ 9 ] ; # mtime
    if ( $main_mtime > $wip_mtime )
     {
        $mainline = @filename_array[$i];
        $main_mtime = localtime( $main_mtime );
        $wip_mtime  = localtime(  $wip_mtime );
        dialog_box(-1, 
        "WARNING timestamp for $wip_filename is older than mainline file." .
        "# " . $main_mtime . " " . $mainline .
        "# " . $wip_mtime . " " . $wip_filename .
        "# This will happen if mainline is modified outside of ChipVault.".
        "# Please resolve any discrepancies between the files before checking".
        "# in $wip_filename to prevent mods to mainline being lost." .
        "# <Press Any Key> " );
     }

    # Note: stat returns: dev,ino,mode,nlink,uid,gid,rdev, size,atime,mtime,
    $uid = ( stat $wip_filename  ) [ 4 ] ; # Get Decimal UID
    if ( ($uname = $uname_cache_hash{ $uid }) eq "" )
     {
      # /etc/passwd translation from uid to uname is REALLY slow, so create
      # a cache of entries already looked up.
      if ( $os eq "unix" )
       {
        $uname = $uname_cache_hash{ $uid } = ( getpwuid ( $uid ) ) [0] ;
       }
      else
       {
        $uname = $uname_cache_hash{ $uid } = "USER"; # win32
       }
     }
    @wip_owner_array[ $i ] = $uname;
    }# if ( -e $wip_filename )
   else
    {
     @wip_owner_array[ $i ] = ""; # File is NOT checked out
    }
   @status_array[ $i ] = @wip_owner_array[ $i ];
  }# if ( @show_array [ $i ] == 1 )
 } # For
   $check_wip_status = 0;

if ( $batch_mode != 1 )
 {
##################################################
# Draw Each Block Name when visible
##################################################
    for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
     {
      if ( ( @y_loc_array[ $i ] >= $y_view_port_start )  &&     
           ( @y_loc_array[ $i ] <= $y_view_port_stop  )     )      

       {
        if ( @show_array [ $i ] == 1 )
          {
             if ( $y_pos == $cur_y )
              {
               $select_index = $i;
              }
           if ( ( $redraw == 1 ) && ( $cur_x < 2 ) )
            {
             if ( @flag_array[ $i ] == 1 )
              {
               $flag = $flag_expanded;    # $flag = "- ";
              }
             elsif ( @flag_array[ $i ] == -1 )
              {
               $flag = $flag_collapsed;   # $flag = "+ ";
              }
             else
              {
               $flag = $flag_nokids;      # $flag = "  "; # No Children
              }

             # Support for "MyLabel"
             $_ = @modname_array[ $i ];
             # Look for " in $_
#            if ( (/\"/io ) )
#            {
#               $flag = "";
#            }


               if    ( $disp_select == 0 )
                { $disp = "" . $flag . @modname_array[ $i ] . "  "; }
               elsif ( $disp_select == 1 )
                { $disp = "" . $flag . @filename_array[ $i ] . "  "; }
               elsif ( $disp_select == 2 )
                { $disp = "" . $flag . @ref_des_array [ $i ] . "  "; }
               if ( $disp eq "" ) 
                { $disp = "" . $flag . @modname_array[ $i ] . "  "; }

              # Support for "" Whitespace label
              ( $disp =~ s/\"\"//go ); # Remove All "" and replace with nul
        
               gotoxy( (@level_array[ $i ]*$x_scale) , $y_pos );
               my_print($disp); # Print Everything;

               # Display WIP Owner
               if ( @status_array[$i] ne "" ) 
               {
                 gotoxy( $status_x_loc , $y_pos );
                 my_print(@status_array[$i]); # Display WIP Owner

                 if ( $draw_main2wip_line_en == 1 )
                  {
                   $tmp_x = ( 
                             ( @level_array[ $i ]*$x_scale ) +
                             ( length ( $disp )            ) 
                            );

                    $tmp_str = "----->";
                    gotoxy(  $tmp_x, $y_pos );
                    my_print($tmp_str);

                  } # if ( $draw_main2wip_line_en == 1 )
                }# if ( @status_array[$i] ne "" ) 

             } # if redraw
           elsif ( ( $redraw == 1 ) && ( $cur_x >= 2 ) )
            {
# TODO: vvv  This SECTION IS REPEATED 3 TIMES I THINK!! FIX vvvv
              $file_name = @filename_array[ $i ];  
              $file_name_no_ext = $file_name;
              ( $file_name_no_ext =~ m/$path_null(.*)$ext_null/o ); 
              $mod_name  = @modname_array[ $i ];  
# FOOBAR
              $report_name = @report_filename [ ($i * 100) + $cur_x ] ;
              ( $report_name =~ s/FILE_NAME/$file_name/go ); # Srch+Rplc Tag
              ( $report_name =~ s/MOD_NAME/$mod_name/go );   # Srch+Rplc Tag
              ( $report_name =~ s/FILE_NAME_NO_EXT/$file_name_no_ext/go ); # 
               if ( $report_name ne "" )
               {
                 if ( -e $report_name ) #TODO: This will be SLOW on Win32
                  {
                   gotoxy( (@level_array[ $i ]*$x_scale) , $y_pos );
                   my_print($report_name);
                   if ( $report_function [ $cur_x ] ne "" ) 
                    {
                     $rts = report_analysis( $report_name , 
                                             $report_function [$cur_x]);
                     gotoxy( $status_x_loc , $y_pos );
                     my_print( $rts ); # Display report_analysis results
                    }# if ( $report_function [ $cur_x ] ne "" ) 
                  }# if ( -e $report_name ) #TODO: This will be SLOW on Win32
               }# if ( $report_name ne "" )
             }# elsif ( ( $redraw == 1 ) && ( $cur_x >= 2 ) )
# TODO: ^^^  This SECTION IS REPEATED 3 TIMES I THINK!! FIX ^^^^
             $y_pos++;
          }#if show
       }# if viewport
     }# for
 }# if ( $batch_mode != 1 )
else
 {
  $select_index = 0;
 }# if ( $batch_mode != 1 )

##################################################
# Display Current Selected File 
##################################################
   ## Decide which file is currently selected. Main,WIP,Reports 
   if ( $cur_x == 0 )    ## Mainline
#    { $file_name = @filename_array[ $select_index ]; } 
     { 
       $file_name = @filename_array[ $select_index ]; 
       $mod_name  = @modname_array[ $select_index ]; 
     } 
   elsif ( $cur_x == 1 ) ## WIP
     { $file_name=solve_wip_name(@filename_array[$select_index],$wip_header);}
   elsif ( $cur_x >= 2 ) ## Reports    
     { 
# TODO: vvvv THIS IS REPEATED MANY TIMES!!! vvvvv
       $report_name = @report_filename [ ($select_index * 100) + $cur_x ] ;
       $file_name = @filename_array[ $select_index ];  
       $file_name_no_ext = $file_name;
       ( $file_name_no_ext =~ m/$path_null(.*)$ext_null/o ); 
       $mod_name  = @modname_array[ $select_index ];  
       ( $report_name =~ s/FILE_NAME/$file_name/go ); # Srch+Rplc Tag
       ( $report_name =~ s/MOD_NAME/$mod_name/go );   # Srch+Rplc Tag
       ( $report_name =~ s/FILE_NAME_NO_EXT/$file_name_no_ext/go ); # 
       $file_name = $report_name;
     }

   $file_name_padded = substr((pack "A80","file= $file_name "),0,44);
   if ( $disp_file_in_main == 1 ) 
    {   
     gotoxy($tool_x_loc ,($y_screen_offset-1) );
     my_print($file_name_padded);
    }

   if ( $disp_file_xterm_title == 1 ) 
    {   
#    $xterm_title = "ChipVault " . $version . $file_name;
#    $xterm_title = "ChipVault " . $file_name;
     $vers_nowhite = $version;
     ( $vers_nowhite =~ s/ //go ); # Strip whitespace
     $xterm_title = "ChipVault " . $vers_nowhite;
     set_title($xterm_title);
    }

   $displayed_filename_last_time = 1;


 

##############################
# Draw Port View if in Split Display Mode. Split display mode splits the 
# display in half. One half shows the usual hierarchy display. The other 
# half shows selected information about the current file ( such as port 
# view, stats, etc ).
##############################
  if ( ( $split_display_on == 1 ) && ( $split_display_size != 0 ) )
   { 
     $last_split_file = $split_file;
     
     if ( $split_display_mode == 0 )
     {
       $mode_txt = "Port View";
       $split_file = $file_name;
       # Cache the results and retrieve existing if exists
       $port_cache_hash{$split_file} = ""; # HACK TO DISABLE CACHE
       if ( $port_cache_hash{$split_file} eq "" )
       {
        @ret_str = port_solver( $split_file, $mod_name );
        $rts = "";
        foreach $_ ( @ret_str )
        {
         $rts = $rts . $_ . "#";
        }
        $port_cache_hash{$split_file} = $rts;
       }
       else
       {
        undef @ret_str;
        push @ret_str, "Cache";
        $ETC = $port_cache_hash{$split_file};
        while ( (($F1, $ETC ) = split ('#', $ETC , 2)) )
        {
          push @ret_str, $F1;
        } # while
       }
     }
     elsif ( $split_display_mode == 1 )
     {
       $mode_txt = "Port View";
       $split_file = $file_name;
       @ret_str = rtl_analyzer( $split_file );
     }
     else
     {
      if ( $split_display_mode == 2 )
       {
         $mode_txt = "RTL File ";
         $split_file = $file_name;
         open( input_file , "<" . $split_file ); 
       }
      elsif ( $split_display_mode == 3 )
       {
         $mode_txt = "Log File ";
         $split_file = $log_file;
         open( input_file , "<" . $split_file ); 
       }
      else
        {
         $mode_txt = "Slog File";
         $split_file = $slog_file;
         open( input_file , "<" . $split_file ); 
        }# if ( $split_display_mode == 1 )

      undef @ret_str;
      while ( $_ = <input_file> ) 
       { 
        chomp $_; # Remove CR;
        ( $_ =~ s/#/*/go ); # Replace ALL '#' with '*';
        ( $_ =~ s/\r//go ); # Replace ALL CarriageRet with ''
        push @ret_str, $_;
       }# while ( $_ = <input_file> ) 
      close input_file;
     }# if ( $split_display_mode == 1 )

      if ( $last_split_file ne $split_file )
       {
        $split_display_scroll_pos = 0;
       } 

      $i = $split_display_scroll_pos; # scroll offset into array
      for ( $y = $y_split_offset; $y < ($y_split_offset + $y_split_size);$y++ )
      {
       gotoxy( $x_split_offset, $y );
       $str = pack "A80", @ret_str[$i++];
       if ( $x_split_offset > 10 ) {$str = "| ".$str; }
       my_print( $str );
      }# for ( $y = ($maxy+2); $y < (($maxy*2)-2); $y++ )
       gotoxy( $x_split_offset, ++$y );
       my_print("----------".
      " <s>plit display $mode_txt : scroll <a>/<z> <A>/<Z>  : <S>ize --------");
   }# if ( $split_display_on == 1 )

##############################
# Display Cursor at Current Loc
##############################
    if ( $cur_x != 1 )
     { 
      gotoxy( (@level_array[ $select_index ]*$x_scale)+1 , $cur_y); # Cursor
     }
    elsif ( $cur_x == 1 )
     { 
      gotoxy( $status_x_loc,                           , $cur_y); # Cursor
     }
    display_cursor();
   $redraw = 0;

 return;
}# sub display_main()


# [pdf_on]
# [pdf_break]
# [pdf_text_size] 20
# On-Line Help:
# [pdf_text_size] 10
####################### THIS IS THE EMBEDDED HELP ############
#H **********************************************************
#HChipVault Help:  (Ctrl-D to page down)
#H  
#H   ---------------------------------------------------------------
#H   Disclaimer and Terms of Use:                          
#H   This program is distributed in the hope that it will be useful, 
#H   but WITHOUT ANY WARRANTY; without even the implied warranty of
#H   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#H   enclosed GNU General Public License for more details.             
#H
#H   In no event will the Author, Kevin M. Hubbard be liable for 
#H   direct, indirect, special, incidental, or consequential damages
#H   resulting from the use of this software, even if advised of the 
#H   possibility of such damages.
#H
#H   Use of this software in the design or control of machinery 
#H   involved in 'HIGH-RISK' activities, i.e. activities where 
#H   failure of this software could reasonably be expected to cause 
#H   DEATH, INJURY or the RELEASE OF HAZARDOUS MATERIALS, IS
#H   NOT PERMITTED.
#H   ---------------------------------------------------------------
#H   Web-Site: http://chipvault.sourceforge.net
#H   Please email the author at khubbard@users.sourceforge.net
#H    to let him know you have tried ChipVault and what you
#H    like/dislike about it. The author is always looking for
#H    improvement ideas.
#H
#H  Table of Contents:
#H    i) Key Codes
#H   ii) Vi+Emacs Help   
#H  iii) FAQ
#H   iv) Author Info
#H    v) GPL License 
#H 
#H **********************************************************
#H i) Key Codes:
#H 

## Note: This is for using Vi Non-Friendly Cursors
#H  [ Navigation                     ]      
#H  <UP>    or <i>     : Navigate Up Hierarchy
#H  <CTRL-U>           : Navigate Page Up Hierarchy
#H  <DOWN>  or <k>     : Navigate Down Hierarchy
#H  <CTRL-D>           : Navigate Page Down Hierarchy
#H
#H  <LEFT>  or <j>     : Navigate Left
#H  <RIGHT> or <l>     : Navigate Right
#H
#H  </>                : Search forward on Module Name
#H  <?>                : Search backward on Module Name

## Note: This is for using Vi Friendly Cursors
# #H  <UP>    or <k>     : Navigate Up Hierarchy
# #H  <CTRL-U>           : Navigate Page Up Hierarchy
# #H  <DOWN>  or <j>     : Navigate Down Hierarchy
# #H  <CTRL-D>           : Navigate Page Down Hierarchy
# #H
# #H  <LEFT>  or <h>     : Navigate Left
# #H  <RIGHT> or <l>     : Navigate Right

#H  [ Hierarchy Expanding/Collapsing ]      
#H  <SPACE>            : Expand and Collapse hierarchy Views.
#H  <1> to <9>         : Collapse all below level < >.
#H
#H  [ Schematic'ish Block Viewing    ]      
#H  <p>                : View Ports into each Block. 
#H                       Inputs on the left an 
#H                       outputs and bidis on the right.
#H  <b>                : View Children Blocks. Same as <p> but 
#H                       shows all the children instantiated 
#H                       by the current block.
#H
#H  [ Tool Control                   ]      
#H  <ENTER> : Perform Tool Bar Operation on File (Edit, CheckIn,etc)
#H  <t>     : Tool Popup Scroll Menu. Select tool and press <ENTER>
#H  <!>     : Bang History. Recall prior used tools via <1>..<9>
#H  <@>     : Macro Tools. Call pre-assigned tools via <1>..<9>
#H
#H  [ Misc                           ]      
#H  <r>     : Resize Screen and Redraw.           
#H  <s>     : Toggle Split Display Modes.         
#H  <d>     : Toggle Debug Mode. Useful for displaying key codes.
#H  <q>     : Quit                                    
#H
#H  [ Macro Assigned Keys            ]      
#H  <c>     : Compile
#H  <e>     : Edit   
#H  <end>   : Diff WIP file with Mainline
#H  <del>   : Delete the WIP file
#H  <v>     : View Log File
#H  <ins>   : Checkfile In/Out
#H  <tab>   : Checkfile In/Out
#H **********************************************************
#H ii) Vi + Emacs Help 
#H Vi Help (Brief):
#H
#H  [Saving and Exitting]
#H  ":w"     : Write file to disk                       
#H  ":q"     : Quit Vi. (use :q! to abandon edits)      
#H  ":w foo" : Write file foo to disk                       
#H  ":r foo" : Read and Insert file foo from disk           
#H  ":e foo" : Edit file foo
#H
#H  [Switching between Commands and Edit modes]
#H  "<ESC>": Switch from text edit mode to command mode. 
#H  "i"    : Start inserting   text at current cursor position 
#H  "R"    : Start overwriting text at current cursor position 
#H  "A"    : Start overwriting text at end of current line 
#H
#H  [Cut and Paste]
#H  "2yy"  : Yank-Yank 2 Lines (Copy) at current cursor position
#H  "3dd"  : Delete-Delete 3 Lines (Cut) at current cursor position
#H  "p"    : Paste Yanked or Deleted line(s) to current cursor.
#H  "dw"   : Delete Word right of the cursor.
#H  "d5<sp>: Delete 5 characters right of the cursor. 
#H  "d$"   : Delete to end of the line. 
#H
#H  [Scrolling]
#H  ":1"   : Go to Line 1     (Top of File)           
#H  ":n"   : Go to Line n     
#H  ":$"   : Go to Last Line  (End of File)           
#H  ":set number" : Display Line Numbers
#H 
#H  [Search]
#H  "/foo" : Search forward in file for "foo"
#H  "?foo" : Search backward in file for "foo"
#H
#H  [Search and Replace]
#H  ":.,+8s/foo/bar/g" : Replace "foo" with "bar" on the next 8 lines.
#H
#H  [Block Move]
#H    (Yes a mouse would be nice here.) 
#H    1) Position Cursor at top of block, leftmost column.
#H    2) "ma~".
#H    3) Position Cursor at bottom of block, leftmost column.
#H    4) "ms\".
#H    5) "`sd`a" (can sub "d" for "y" for Yanking instead of Deleting).
#H    6) Paste ( "p" ) at desired location.
#H
#H (End VI Help)

#H **********************************************************
#H Emacs Help (Brief):
#H
#H  [Saving and Exitting]
#H  "Ctrl-X Ctrl-S" : Save 
#H  "Ctrl-X Ctrl-C" : Quit 
#H
#H  [Navigating]
#H  "Ctrl-A"        : Start of Line
#H  "Ctrl-E"        : End of Line
#H
#H  [Cut and Paste]
#H  "Ctrl-Space"    : Set Mark
#H  "Ctrl-W"        : Cut Mark to Cursor
#H  "Ctrl-Y"        : Paste
#H  "Ctrl-X U"      : Undo
#H  "Ctrl-K"        : Delete Cursor to End of Line
#H
#H (End Emacs Help)



# [pdf_break]
# [pdf_text_size] 20
# On-Line FAQ:
# [pdf_text_size] 10
#H **********************************************************
#H iii) Frequently Asked Questions (FAQ)
#H
#H 1) What is ChipVault?
#H    ChipVault is an interactive Perl program for controlling
#H    hierarchy of a chip design. It can handle both VHDL and
#H    Verilog, or any clear text design effort that may be 
#H    sorted by hierarchy.
#H
#H 2) What are the main features?
#H  a) Hierarchy Organization of Source Files.
#H  b) Simple Revision Control for Group Projects.   
#H  c) Instant Port Views for VHDL sublocks.  
#H  d) Issue Tracking Database.                
#H  e) Auto Instantiate VHDL and Verilog blocks.   
#H  f) Hardware and OS Flexible.
#H  g) Free (Open-Source GPL'd).
#H
#H
#H   a) Hierarchy Organization of Source Files:
#H     ChipVault organizes your source files via hierarchy and
#H     allows you to rapidly navigate thru hundreds of source
#H     files deep into a design. CV can be used to launch your
#H     favorite editor like Vi or Emacs. ChipVault is fully
#H     customizable allowing you to launch other tools such as
#H     compilers, Synthesis, Perl scripts, Lints, etc. 
#H
#H     Since ChipVault knows the hierarchy of your design, any
#H     tool you configure for launching from CV may be launched
#H     for bottom up hierarchy execution.
#H
#H  b) Simple Revision Control for Group Projects.   
#H     ChipVault provides a Check_Out and Check_In feature for
#H     source files. Checking a file out generates a copy of 
#H     the file for you to edit. The original file remains 
#H     untouched until you check in your changes, allowing 
#H     a group of designers to share the same source tree.
#H 
#H     WhatThisIsnt : This isnt RCS,CVS, etc.           . IMHO
#H     those tools are great for big SW project, but overkill
#H     for HW designs and they slow down the design effort with
#H     an extra layer of complexity.  Revision Control in 
#H     ChipVault is tailored for HW designers. Only one designer
#H     may check out a file at a time.
#H
#H     HowThisWorks : When you check out "foo.vhd", ChipVault
#H     creates a copy called "wip.foo.vhd". So long as 
#H     "wip.foo.vhd" exists, no one else may check out foo.vhd.
#H     The mainline foo.vhd still exists and will exists until
#H     you check "wip.foo.vhd" back in. When you check the file
#H     back in, you are prompted to describe the changes made
#H     which is then automatically added to a ChangeLog file.
#H     When file archiving is enabled (default), every time a
#H     user checks a file in or out, the file is automatically
#H     added to a hidden gzip'd tarball file. RTL is highly 
#H     compressable, so it is practical to archive everything.
#H
#H  c) Instant Port Views for VHDL sublocks.  
#H     One of ChipVaults built-in tools is a VHDL reader for 
#H     reading entity declarations and deciphering port 
#H     declarations. ChipVault uses this information to draw
#H     a block diagram of all signals going in and out of a 
#H     block.
#H
#H  d) Issue Tracking Database.                
#H     ChipVault will generate a data base for you for tracking
#H     issues that come up during your design phase. Issues
#H     can be sorted by ID, Reporter, AssignTo, Title,etc.
#H     Everything is stored in a readable text file issues.txt.
#H
#H  e) Auto Instantiate VHDL and Verilog Blocks.
#H     ChipVault has the ability to read in your existing RTL 
#H     blocks and generate new template files on the fly which
#H     instantiate your existing block.
#H
#H  f) Hardware and OS Flexible.
#H     ChipVault runs on UNIX,Linux and Windows. The UserInterface
#H     scales from a dumb terminal 80x24 Telnet display to 1280x1024
#H     (or 160x128) making it an ideal tool for large designs as well
#H     as dialup access.
#H      
#H  g) Free (Open-Source GPL'd).
#H     ChipVault is Open-Source GPL'd, meaning all are free to 
#H     download ChipVault from http://chipvault.sourceforge.net
#H     and execute ChipVault without having to pay any license
#H     fees. The author maintains copyrights to the ChipVault
#H     source, preventing 3rd parties from modifying the source
#H     and then selling a compiled commercialized application.
#H     Please read the full enclosed GNU General Public License
#H     for full details on license agreement.
#H 
#H 3) Which version should I use?
#H      For serious work, the UNIX/Linux port of course.
#H      The author uses the basic POSIX console version on a day
#H      to day basis.  Linux appears to offers the fastest User 
#H      Interface response time. The standard xterm executable offers
#H      the best POSIX compatability and font sizes. The author avoids
#H      gnome-term (large anti-aliased fonts) and cmd-tool and sticks
#H      with xterm.
#H
#H      A Curses version existed once which is slightly faster
#H      than POSIX. It was removed as installing Curses libs for
#H      Perl wasnt trivial and the benefits (like mouse support)
#H      were minor compared to the overhead of supporting. 
#H   
#H      Win32 users now only have the Console version for   
#H      ActivePerl. 
#H      but Caveot Emptor, different versions of Win32 OSs out
#H      of Redmond tend to have different Console IO behaviors
#H      running the same version of ActivePerl. The author runs
#H      on Win2K but the Console has to be setup for BufferSize
#H      equal to ScreenSize. By default, the Console window has
#H      a buffer larger than the screen which then maps the 
#H      cursor keys for scrolling the buffer (and ChipVault 
#H      never hears the key presses). The author generates a 
#H      shortcut which has the Buffer set to 25 lines.
#H
#H      ie: ShortCut Properties which work for win2K
#H      The Tab Buttons are represented via [] brackets.
#H      [Shortcut]
#H        Target     : perl.exe cv_win32.pl
#H        Start in   : Your_Design_Path_Containing_hlist.txt
#H      [Layout]
#H        ScreenBufferWidth  : 80
#H        ScreenBufferHeight : 25
#H        Window Size Width  : 80
#H        Window Size Height : 25
#H
#H      Once this shortcut is created, you can double-click to 
#H      start ChipVault on your desired design with the Console
#H      set properly.
#H
#H 4) I hate all GUIs. What good is ChipVault to me?
#H      Use ChipVault in batch mode for doing bottom-up stuff
#H      like Compiling and Synthesis.
#H      ie:  %cv.pl hlist.txt -c "cp FILE_NAME FILE_NAME.foobak"
#H      will make a foobak copy of every file in your design.
#H      Insert a Pound inside your hlist.txt for files to skip.
#H
#H 5) I don't want to use the ChipVault GUI but I need to
#H    participate on a group project using ChipVaults simple
#H    Revision Control System. How do I check files in and out
#H    via the UNIX command line?
#H    
#H    Thats easy. 
#H    To see who has what already checked out:
#H      "ls -l wip.*.vhd"
#H
#H    To check out a file:
#H      "cp foo.vhd wip.foo.vhd"
#H
#H    To check a file back in:
#H      "cp wip.foo.vhd foo.vhd"
#H    
#H    Note: Auto-archiving will not be performed using this
#H    this method. You'll need to manually add the files to
#H    existing TAR-balls if you need an archive.
#H
#H 6) How do I assign my own tools for the tool bar?     
#H    Grep on my_tool assignments and copy examples.
#H    Tags like FILE_NAME get replaced by current selected
#H    file. 
#H    
#H 7) What is/is_not supported in the Win32 port?        
#H    The author tried in ernest to make ChipVault portable 
#H    over to a Win32 environment. 
#H    Unfortunately POSIX terminal emulation is
#H    spotty for Win32 ports of Perl, so the native          
#H    Win32 console interface instead. To run on a Win32 system
#H    you need to install ActivePerl from www.activestate.com.
#H    This is a port of standard Perl5 with some hooks to Win32
#H    routines.
#H    By definition, Win32 is lacking in features that come 
#H    standard in UNIX environments. ChipVault on Win32 does 
#H    Not Supported:
#H        o GZIPping.
#H        o File ownership information. (checked out files
#H            will be listed as owned by "USER" )
#H        o Email notifications on CheckIns, New Issues.
#H        o etc,etc,etc.
#H
#H     On a plus side, the Win32 port does have some limited
#H      mouse support. Double-Click on "+" and "-" to expand
#H      and collapse views. Double-Click on Module Names to
#H      activate tool. Single Click to change cursor position.
#H      For some reason, when system calls are made and fail
#H      (ie compiling or something), the mouse seems to break.
#H       
#H     So, in-short, ChipVault was written for UNIX/Linux, but
#H     it seems to work on Win32 too, so here it is.
#H
#H 8) Why is my Win32 window so small?                   
#H     ChipVault runs as a console app on Win32. Win32 defaults
#H     to 24 lines. Change your window properties for more lines
#H     after starting ChipVault then press <r>esize. Also see the
#H     generated cv.lnk file.
#H
#H 9) How do I assign my own keyboard macros to avoid the tool bar?
#H     Grep on macro_hash to see examples of setting up macros.
#H
#H 10) How do I get Mouse support on Linux/UNIX?
#H     Mouse support once existed under Curses but was removed as
#H     the author never used it and the overhead to support
#H     Curses wasn't worth the hassle. ChipVault is much like
#H     Vi, Pine, MidnightCommander - fast and efficient via
#H     rapid keystrokes.
#H
#H 11) How do I enable Email Notification on file CheckIns?
#H     Email notification on file CheckIns is turned off by default.
#H     To turn this feature on, you need to set up the email_list   
#H     array with all the people to Email to. Then set the variable
#H     send_email_on_check_in to 1.
#H
#H 12) How do I setup a component library for all designers to have
#H     access to?
#H     Fill in the lib_list array to point to other hlist.txt files
#H     that you want read in. Or manually insert a line like
#H     [include] foo.txt
#H     in your hlist.txt file. When ChipVault reads in hlist.txt
#H     it will spot the [include] tag and automatically read in
#H     foo.txt as well. 
#H
#H 13) Why is ChipVault slow on screen refreshes on my machine? 
#H     Believe it or not, this isn't because ChipVault is interpreted
#H     by Perl rather than compiled into machine code. On some 
#H     machines, the User Interface may be slow as ChipVault uses
#H     POSIX compliant terminal IO commands (think VT100) for doing
#H     things like cursor placement, screen erases, etc. On some 
#H     OS's this can be really slow. I've noticed that a SunUltra60
#H     is sluggish, but my AMD AthlonXP-2000 Linux box just screams. 
#H     If you are stuck with a slow OS, you can still speed things up
#H     my giving ChipVault less to draw on every keystroke.
#H
#H     Ways to speed up the UI are:
#H      o) Disable Split-Display Mode with:
#H         $enable_split_display = 0; (or press <s> until it goes away)
#H      o) Turn off "file=" window with:
#H         $disp_file_in_main = 0;
#H         $disp_file_xterm_title = 0;
#H      o) Shrink your window size (ie 25 or 50 lines instead of 120).
#H      o) Switch from Solaris to Linux.
#H
#H 14) How do I import libraries for browsing?
#H     Either explicitly type an [include] lib.txt into your hlist
#H     file, or set the CV_INCLUDE environment variable to lib.txt.
#H     ie:
#H     setenv CV_INCLUDE /home/me/foo.txt;/home/you/bar.txt will 
#H     automatically append the 2 libraries foo and bar to your CV
#H     hlist session.
#H
#H 15) What is split_display?
#H     When your Xterm screen is sufficiently large in either the 
#H     X or Y direction, ChipVault will enable split_display and   
#H     simultaneously display your hierarchy view alongside a port
#H     view of the block the cursor is on.
#H
#H 16) How can I Help the ChipVault project?  
#H     o) Use ChipVault and spread the word. The author's marketing
#H        budget for last year was $0.00, so word-of-mouth is key.
#H     o) Send author Email feedback on problems and feature requests.
#H     o) Fix bugs and send author patches to be included in future
#H        releases.
#H
# [pdf_break]
# [pdf_text_size] 20
# Tutorial Text:
# [pdf_text_size] 10
#Z*****************************************************************
#Z iv) Tutorial Text:
#Z ChipVault Tutorial 11-12-2002
#Z
#Z This Tutorial is a quick 10 minute walk-thru of the major 
#Z features in ChipVault. You will need to de-tar the example files
#Z from http:\\chipvault.sourceforge.net\tutorial.tar.gz 
#Z   %gunzip tutorial.tar.gz
#Z   %tar -xvf tutorial.tar
#Z 
#Z Index:
#Z  Step-1)  File Setup
#Z  Step-2)  Reading in an existing Design and generating a hlist.txt file
#Z  Step-3)  Navigating the ChipVault Hierarchy Interface
#Z  Step-4)  Port Viewing 
#Z  Step-5)  File Editting
#Z  Step-6)  Tool Bar
#Z  Step-7)  Revision Control. CheckIn/CheckOut
#Z  Step-8)  Issue List 
#Z  Step-9)  VHDL Module Generation
#Z  Step-10) Bottom Up Compiles
#Z  Step-11) Schematic Block Printing
#Z  Step-12) RTL Viewer 
#Z  Step-13) Admin Control of Checkins
#Z  Step-14) Netlist Viewing
#Z 
#Z 
#Z Step-1) File Setup
#Z o) Copy cv.pl into the tutorial/src directory
#Z o) %cd tutorial/src
#Z 
#Z Step-2) Reading in an existing Design and generating a hlist.txt file
#Z o) %perl cv.pl top.vhd<ENTER>
#Z    This will read in the top.vhd file and find all the children by
#Z    scanning thru the *.vhd and *.v files in the same subdirectory.
#Z o) Press <ENTER> when prompted for the Filter Value.
#Z 
#Z    If the VHDL and Verilog files were read in OK, you should now
#Z    see a hierarchy tree of the example design.
#Z
#Z o) Quit ChipVault by pressing <q>. Look at the hlist.txt file that CV 
#Z    built and then restart ChipVault in the normal fast mode:
#Z o) %perl cv.pl<ENTER>  (or just %cv.pl if perl is in path and chmod +x)
#Z 
#Z Step-3) Navigating the ChipVault Hierarchy Interface
#Z o) Use the cursors keys (or <i,j,k,l> to go up and down the hierachy.
#Z    Note the "file=" box will display the actual file name you are on.
#Z
#Z o) Navigate to "german" and press <SPACE> bar. This should collapse
#Z    the "german" module and all of its children modules should now
#Z    be invisible.
#Z    Press <SPACE> bar again, and the child modules should re-appear.
#Z 
#Z o) Press <3>. This will collapse everything below 3 levels deep.
#Z 
#Z o) Press (4). This will collapse everything below 4 levels deep.
#Z 
#Z Step-4) Port Viewing 
#Z o) Navigate to module "top" and press the <p> key.
#Z    This will display all the port I/O to this module. Press <SPACE>.
#Z 
#Z Step-5) File Editting
#Z o) Navigate to module "metrics" and press <ENTER> key.
#Z    This should launch VI and open metrics.vhd.
#Z o) Type <:> <q> to exit VI and go back to ChipVault.
#Z 
#Z Step-6) Tool Bar
#Z o) Press <t> to bring the Tool Bar up.
#Z 
#Z o) Scroll thru the Tool Bar window using up and down cursor keys
#Z    ( or <i> and <k> ) until "Edit (Emacs)" under "Editors" appears
#Z    and press <ENTER>.
#Z 
#Z    This should bring up "metrics.vhd" in a Emacs Edit window.
#Z    The <ENTER> key is now assigned to "Edit (Emacs)" as indicated
#Z    by the top line of the ChipVault screen.
#Z 
#Z o) Quit Emacs and Cursor down to "modelo" and press <ENTER> and 
#Z    another instance of Emaces will be launched, but with modelo.vhd.
#Z
#Z o) Quit Emacs and Cursor down to "german" and <t>ool to Edit (fork)
#Z    This will launch Vi and send the process in the background, keeping
#Z    ChipVault active.
#Z
#Z o) Press <!> to bring up Bang History. Press <2> to select the Emacs.
#Z 
#Z o) Press <@> to bring up Macro Tool. Press <1> to select Edit.     
#Z 
#Z Step-7) Revision Control. CheckIn/CheckOut
#Z a) Check Out a File
#Z o) Cursor back to "metrics", hit <t> for tool and select
#Z    "check_out" <ENTER>. ( or just press <TAB> key over metrics )
#Z 
#Z    You should have just checked out the file metrics.vhd .
#Z    If this worked, to the right of "metrics" you should see your
#Z    user name in the "CheckedOut" column.
#Z 
#Z o) Cursor over to your user name and you should see "wip.metrics.vhd"
#Z    at the bottom-left of the screen instead of original "metrics.vhd".
#Z 
#Z    This Work-In-Progress (wip) file is a copy of metrics.vhd for you
#Z    to work on.
#Z 
#Z o) Press <e> to make changes to wip.metrics.vhd using your default editor.
#Z 
#Z b) Diff your Checked Out file
#Z o) Cursor back to the left column over "metrics" and press <t> and 
#Z    select "Diff CO'd file". 
#Z    You should get an error message from Diff. Cursor down to "log.txt"
#Z    and select "Edit" from the tool bar to view the diff output.
#Z 
#Z c) Check In a File
#Z o) Cursor back up to your username under the CheckedOut column to the 
#Z    right of "metrics". Tool Bar select "check_in".
#Z     ( or just press <TAB> key over username )
#Z 
#Z o) When prompted, type a short sentence about the change you made.
#Z    ChipVault will now copy "wip.metrics.vhd" to "metrics.vhd"
#Z    In the process it will destroy the original "metrics.vhd" and 
#Z    create a tar archive of the new "metrics.vhd" you modified.
#Z 
#Z d) View Change Log
#Z o) Cursor to "metrics" then cursor right twice.
#Z    The top-left should show [ 2 HistoryLog ] and your cursor should
#Z    be on history_log.metrics.vhd.txt.
#Z 
#Z o) Select "Edit" from your tool bar and view the history change file.
#Z 
#Z e) View Archive Log
#Z o) Cursor right again 
#Z    The top-left should show [ 3 TAR-Ball Archive List ] 
#Z    View the archive_list.metrics.vhd.txt file to see what archives have
#Z    been auto-generated by ChipVault.
#Z 
#Z 
#Z Step-8) Issue List 
#Z o)  Select Issue_List_View from the Tool Bar.
#Z     Press <1> to sort the issues by issue number.
#Z     Press <2> to sort the issues by Reporter.
#Z     Press <3> to sort the issues by AssignTo.
#Z     Press <4> to sort the issues by Module name.
#Z     Scroll to a desired issue and press <ENTER> to view the full
#Z     description.
#Z 
#Z o)  Select tool bar from the main screen and walk thru the
#Z     issue generation process.
#Z 
#Z Step-9) VHDL/Verilog Module Generation
#Z o)  Cursor over to "grolsch" and tool-bar select "generate_VHDL"
#Z 
#Z o)  Type in "austrian" <ENTER> <ENTER> <ENTER>
#Z 
#Z o)  Type <y> when prompted for instantiating "grolsch.vhd"
#Z 
#Z o)  Type "foo" <ENTER> 16 <ENTER> in <ENTER> for adding new foo(15:0).
#Z o)  Type "bar" <ENTER> <ENTER> <ENTER> for new net bar(15:0).
#Z o)  Type "bob" <ENTER> 1 <ENTER>  out <ENTER> for new net bob.
#Z o)  Type <ENTER> <ENTER> <ENTER> to exit this loop.
#Z 
#Z o)  Cursor to the bottom of the ChipVault screen and edit "austrian"
#Z     module at the very bottom. This should be a new VHDL module with
#Z     the nets you described and it should instantiate "grolsch.vhd".
#Z 
#Z o)  You've added a new module, now you need to place it in the design
#Z     hierarchy. You could edit "beers", add "austrian" insantiations,
#Z     delete the original hlist.txt file and start-over from step-1
#Z     OR
#Z o)  cursor up to top of the screen to hlist.txt and edit. 
#Z     Type a new line above "german" with "austrian" and "austrian.vhd"
#Z     The cursor position of the 1st "a" of austrian MUST be at the same
#Z     spot as the "g" of "german". This is how ChipVault knows the design
#Z     hierarchy. Yank and Pase the grolsch line from under "german" and
#Z     place it under "austrian".
#Z 
#Z o)  Quit ChipVault (<q>) and restart chip vault with no params.
#Z     %perl cv.pl
#Z 
#Z     You should see your new module in the correct place in hiearchy
#Z     Note: Module Generation allows you to instantiate Verilog from VHDL
#Z           and vice-versa.
#Z 
#Z 
#Z Step-10) Bottom Up Compiles
#Z o)   Get ModelSim stuff setup properly (see example).
#Z 
#Z o)   Cursor to "german" and press <SPACE> to collapse.
#Z o)   ToolBar select "Compile".
#Z      This will vcom german.vhd. Any errors will dump to log.txt
#Z 
#Z o)   Cursor to "german" and press <SPACE> to expand.  
#Z o)   ToolBar select "Compile".
#Z      This will vcom cap.v, light.vhd, dark.vhd, amstel, heini, becks
#Z      and then finally german.
#Z
#Z Step-11) Schematic Block Printing
#Z o)   Place the cursor on the top of the architecture you want a printout of.
#Z      Select block_print from the ToolBar EDA Tools list.
#Z 
#Z o)   The current directory will now contain print.txt and print.pdf 
#Z      suitable for printing. Note: Adobe-Acrobat likes to cache pdf files
#Z      so you often need to quit and restart Acrobat if you re-gen print.pdf.
#Z 
#Z Step-12) RTL Viewer
#Z o)   Place cursor on component "top" and select tool cv_rtl_viewer.
#Z o)   Cursor up,down left and right thru the top.vhd file. 
#Z o)   Page-Up and Page-Down using Ctrl-U and Ctrl-D.
#Z o)   Position cursor on the line:
#Z         "v component metrics"
#Z o)   Press <space> to expand the component declaration for metrics.
#Z o)   Repeat the same for foo_proc, u_metrics, etc.
#Z
#Z Step-13) Admin Control of Checkins
#Z o)   Place cursor on the top of the hierarchy you want to make ReadOnly.    
#Z      Toggle expand/collapse so that all files are visible which you wish
#Z      to chmod. Scroll to admin tools on the tool bar and select ReadOnly.
#Z 
#Z o)   To allow a user to checkin a file, place cursor on the mainbranch
#Z      version of that file, collapse the view so that his children are not
#Z      visible. Scroll to admin tools on the tool bar and select ReadWrite.
#Z      The user may now checkin his file over the mainline file. After the
#Z      checkin, you'll want to set the permission back to ReadOnly.
#Z 
#Z Step-14) Netlist Viewing 
#Z o)   Start ChipVault as before but in a directory with only your netlist.
#Z      /tutorial/netlist/% cv.pl top.vhd
#Z 
#Z o)   Select a decent filter value of say 10 or 20 so that you won't have
#Z      a hierarchy view full of ANDs and Flops. 
#Z 
#Z o)   You should now have a hierarchy view of all the large netlist blocks.
#Z 
#Z TheEnd.  See the on-line Help FAQ for more info.
#Z (end)
# [pdf_break]
# [pdf_text_size] 20
# About the Author:
# [pdf_text_size] 10
#H*****************************************************************
#Hiv) Author Info:
#H  The Author's name is Kevin Hubbard. He is an ASIC designer 
#H  living in Issaquah, Washington, USA and may be contacted at
#H       khubbard@users.sourceforge.net
#H
#H Please drop the author a brief Email after you've tried 
#H  ChipVault and let him know if you intend to use it. 
#H  If nobody uses ChipVault, maintenance will be stopped.
#H 
#H Email with contributions, suggestions, requests for new 
#H features, etc is also welcome. The author is also compiling a
#H world map of ChipVault users. Please send an Email indicating
#H the country and city of your location.
#H
#H Contributions : Please support the open-source community by
#H    1) Using OpenSource software. Linux/GNU software is more reliable
#H       and higher performance than all other OSs I've used. Try it.
#H       Even Microsoft has good things to say about Linux these days.
#H       http://www.opensource.org/halloween/halloween7.php
#H        
#H    2) Contributing OpenSource software.
#H       Distributing OpenSource software is incredibly easy. 
#H       Check out www.sourceforge.net for details.
#H
#H    3) Buying books of open-source developers so that they
#H       may see ~some~ financial rewards for their efforts.
#H
#H Recommended Book Reading List:
#H  Non-Fiction:
#H   Just for Fun: The Story of an Accidental Revolutionary
#H    by Linus Torvalds, David Diamond
#H    ISBN: 0066620724
#H    http://www.amazon.com/exec/obidos/search-handle-form/103-0109863-7405479
#H   (how the Linux Revolution came to being)
#H
#H   The Cathedral and the Bazaar: 
#H      Musings on Linux and Open Source by an Accidental Revolutionary
#H    by Eric S. Raymond, Bob Young
#H    ISBN: 0596001088
#H    http://www.amazon.com/exec/obidos/search-handle-form/103-0109863-7405479
#H   (why quality of open-source software is superior to closed proprietary)
#H
#H   The Future of Ideas: The Fate of the Commons in a Connected World
#H    by Lawrence Lessig
#H    ISBN: 0375726446
#H    http://www.amazon.com/exec/obidos/ASIN/0375726446/qid=1030395035/sr=2-2/ref=sr_2_2/103-0109863-7405479
#H    (how large corporate titans have influenced Copyright and Patent laws
#H     to guarantee their survival while stifling outside innovation)
#H
#H  Fiction:
#H   Everything by Philip K. Dick
#H
#H
# [pdf_break]
# [pdf_text_size] 20
# Software License:
# [pdf_text_size] 10
#L******************************************************************
#Lv) License:    
#L		    GNU GENERAL PUBLIC LICENSE
#L		       Version 2, June 1991
#L
#L Copyright (C) 1989, 1991 Free Software Foundation, Inc.
#L           59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#L Everyone is permitted to copy and distribute verbatim copies
#L of this license document, but changing it is not allowed.
#L
#L			    Preamble
#L
#L  The licenses for most software are designed to take away your
#Lfreedom to share and change it.  By contrast, the GNU General Public
#LLicense is intended to guarantee your freedom to share and change free
#Lsoftware--to make sure the software is free for all its users.  This
#LGeneral Public License applies to most of the Free Software
#LFoundation's software and to any other program whose authors commit to
#Lusing it.  (Some other Free Software Foundation software is covered by
#Lthe GNU Library General Public License instead.)  You can apply it to
#Lyour programs, too.
#L
#L  When we speak of free software, we are referring to freedom, not
#Lprice.  Our General Public Licenses are designed to make sure that you
#Lhave the freedom to distribute copies of free software (and charge for
#Lthis service if you wish), that you receive source code or can get it
#Lif you want it, that you can change the software or use pieces of it
#Lin new free programs; and that you know you can do these things.
#L
#L  To protect your rights, we need to make restrictions that forbid
#Lanyone to deny you these rights or to ask you to surrender the rights.
#LThese restrictions translate to certain responsibilities for you if you
#Ldistribute copies of the software, or if you modify it.
#L
#L  For example, if you distribute copies of such a program, whether
#Lgratis or for a fee, you must give the recipients all the rights that
#Lyou have.  You must make sure that they, too, receive or can get the
#Lsource code.  And you must show them these terms so they know their
#Lrights.
#L
#L  We protect your rights with two steps: (1) copyright the software, and
#L(2) offer you this license which gives you legal permission to copy,
#Ldistribute and/or modify the software.
#L
#L  Also, for each author's protection and ours, we want to make certain
#Lthat everyone understands that there is no warranty for this free
#Lsoftware.  If the software is modified by someone else and passed on, we
#Lwant its recipients to know that what they have is not the original, so
#Lthat any problems introduced by others will not reflect on the original
#Lauthors' reputations.
#L
#L  Finally, any free program is threatened constantly by software
#Lpatents.  We wish to avoid the danger that redistributors of a free
#Lprogram will individually obtain patent licenses, in effect making the
#Lprogram proprietary.  To prevent this, we have made it clear that any
#Lpatent must be licensed for everyone's free use or not licensed at all.
#L
#L  The precise terms and conditions for copying, distribution and
#Lmodification follow.
#L
#L		    GNU GENERAL PUBLIC LICENSE
#L   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#L
#L  0. This License applies to any program or other work which contains
#La notice placed by the copyright holder saying it may be distributed
#Lunder the terms of this General Public License.  The "Program", below,
#Lrefers to any such program or work, and a "work based on the Program"
#Lmeans either the Program or any derivative work under copyright law:
#Lthat is to say, a work containing the Program or a portion of it,
#Leither verbatim or with modifications and/or translated into another
#Llanguage.  (Hereinafter, translation is included without limitation in
#Lthe term "modification".)  Each licensee is addressed as "you".
#L
#LActivities other than copying, distribution and modification are not
#Lcovered by this License; they are outside its scope.  The act of
#Lrunning the Program is not restricted, and the output from the Program
#Lis covered only if its contents constitute a work based on the
#LProgram (independent of having been made by running the Program).
#LWhether that is true depends on what the Program does.
#L
#L  1. You may copy and distribute verbatim copies of the Program's
#Lsource code as you receive it, in any medium, provided that you
#Lconspicuously and appropriately publish on each copy an appropriate
#Lcopyright notice and disclaimer of warranty; keep intact all the
#Lnotices that refer to this License and to the absence of any warranty;
#Land give any other recipients of the Program a copy of this License
#Lalong with the Program.
#L
#LYou may charge a fee for the physical act of transferring a copy, and
#Lyou may at your option offer warranty protection in exchange for a fee.
#L
#L  2. You may modify your copy or copies of the Program or any portion
#Lof it, thus forming a work based on the Program, and copy and
#Ldistribute such modifications or work under the terms of Section 1
#Labove, provided that you also meet all of these conditions:
#L
#L    a) You must cause the modified files to carry prominent notices
#L    stating that you changed the files and the date of any change.
#L
#L    b) You must cause any work that you distribute or publish, that in
#L    whole or in part contains or is derived from the Program or any
#L    part thereof, to be licensed as a whole at no charge to all third
#L    parties under the terms of this License.
#L
#L    c) If the modified program normally reads commands interactively
#L    when run, you must cause it, when started running for such
#L    interactive use in the most ordinary way, to print or display an
#L    announcement including an appropriate copyright notice and a
#L    notice that there is no warranty (or else, saying that you provide
#L    a warranty) and that users may redistribute the program under
#L    these conditions, and telling the user how to view a copy of this
#L    License.  (Exception: if the Program itself is interactive but
#L    does not normally print such an announcement, your work based on
#L    the Program is not required to print an announcement.)
#L
#LThese requirements apply to the modified work as a whole.  If
#Lidentifiable sections of that work are not derived from the Program,
#Land can be reasonably considered independent and separate works in
#Lthemselves, then this License, and its terms, do not apply to those
#Lsections when you distribute them as separate works.  But when you
#Ldistribute the same sections as part of a whole which is a work based
#Lon the Program, the distribution of the whole must be on the terms of
#Lthis License, whose permissions for other licensees extend to the
#Lentire whole, and thus to each and every part regardless of who wrote it.
#L
#LThus, it is not the intent of this section to claim rights or contest
#Lyour rights to work written entirely by you; rather, the intent is to
#Lexercise the right to control the distribution of derivative or
#Lcollective works based on the Program.
#L
#LIn addition, mere aggregation of another work not based on the Program
#Lwith the Program (or with a work based on the Program) on a volume of
#La storage or distribution medium does not bring the other work under
#Lthe scope of this License.
#L
#L  3. You may copy and distribute the Program (or a work based on it,
#Lunder Section 2) in object code or executable form under the terms of
#LSections 1 and 2 above provided that you also do one of the following:
#L
#L    a) Accompany it with the complete corresponding machine-readable
#L    source code, which must be distributed under the terms of Sections
#L    1 and 2 above on a medium customarily used for software interchange; or,
#L
#L    b) Accompany it with a written offer, valid for at least three
#L    years, to give any third party, for a charge no more than your
#L    cost of physically performing source distribution, a complete
#L    machine-readable copy of the corresponding source code, to be
#L    distributed under the terms of Sections 1 and 2 above on a medium
#L    customarily used for software interchange; or,
#L
#L    c) Accompany it with the information you received as to the offer
#L    to distribute corresponding source code.  (This alternative is
#L    allowed only for noncommercial distribution and only if you
#L    received the program in object code or executable form with such
#L    an offer, in accord with Subsection b above.)
#L
#LThe source code for a work means the preferred form of the work for
#Lmaking modifications to it.  For an executable work, complete source
#Lcode means all the source code for all modules it contains, plus any
#Lassociated interface definition files, plus the scripts used to
#Lcontrol compilation and installation of the executable.  However, as a
#Lspecial exception, the source code distributed need not include
#Lanything that is normally distributed (in either source or binary
#Lform) with the major components (compiler, kernel, and so on) of the
#Loperating system on which the executable runs, unless that component
#Litself accompanies the executable.
#L
#LIf distribution of executable or object code is made by offering
#Laccess to copy from a designated place, then offering equivalent
#Laccess to copy the source code from the same place counts as
#Ldistribution of the source code, even though third parties are not
#Lcompelled to copy the source along with the object code.
#L
#L  4. You may not copy, modify, sublicense, or distribute the Program
#Lexcept as expressly provided under this License.  Any attempt
#Lotherwise to copy, modify, sublicense or distribute the Program is
#Lvoid, and will automatically terminate your rights under this License.
#LHowever, parties who have received copies, or rights, from you under
#Lthis License will not have their licenses terminated so long as such
#Lparties remain in full compliance.
#L
#L  5. You are not required to accept this License, since you have not
#Lsigned it.  However, nothing else grants you permission to modify or
#Ldistribute the Program or its derivative works.  These actions are
#Lprohibited by law if you do not accept this License.  Therefore, by
#Lmodifying or distributing the Program (or any work based on the
#LProgram), you indicate your acceptance of this License to do so, and
#Lall its terms and conditions for copying, distributing or modifying
#Lthe Program or works based on it.
#L
#L  6. Each time you redistribute the Program (or any work based on the
#LProgram), the recipient automatically receives a license from the
#Loriginal licensor to copy, distribute or modify the Program subject to
#Lthese terms and conditions.  You may not impose any further
#Lrestrictions on the recipients' exercise of the rights granted herein.
#LYou are not responsible for enforcing compliance by third parties to
#Lthis License.
#L
#L  7. If, as a consequence of a court judgment or allegation of patent
#Linfringement or for any other reason (not limited to patent issues),
#Lconditions are imposed on you (whether by court order, agreement or
#Lotherwise) that contradict the conditions of this License, they do not
#Lexcuse you from the conditions of this License.  If you cannot
#Ldistribute so as to satisfy simultaneously your obligations under this
#LLicense and any other pertinent obligations, then as a consequence you
#Lmay not distribute the Program at all.  For example, if a patent
#Llicense would not permit royalty-free redistribution of the Program by
#Lall those who receive copies directly or indirectly through you, then
#Lthe only way you could satisfy both it and this License would be to
#Lrefrain entirely from distribution of the Program.
#L
#LIf any portion of this section is held invalid or unenforceable under
#Lany particular circumstance, the balance of the section is intended to
#Lapply and the section as a whole is intended to apply in other
#Lcircumstances.
#L
#LIt is not the purpose of this section to induce you to infringe any
#Lpatents or other property right claims or to contest validity of any
#Lsuch claims; this section has the sole purpose of protecting the
#Lintegrity of the free software distribution system, which is
#Limplemented by public license practices.  Many people have made
#Lgenerous contributions to the wide range of software distributed
#Lthrough that system in reliance on consistent application of that
#Lsystem; it is up to the author/donor to decide if he or she is willing
#Lto distribute software through any other system and a licensee cannot
#Limpose that choice.
#L
#LThis section is intended to make thoroughly clear what is believed to
#Lbe a consequence of the rest of this License.
#L
#L  8. If the distribution and/or use of the Program is restricted in
#Lcertain countries either by patents or by copyrighted interfaces, the
#Loriginal copyright holder who places the Program under this License
#Lmay add an explicit geographical distribution limitation excluding
#Lthose countries, so that distribution is permitted only in or among
#Lcountries not thus excluded.  In such case, this License incorporates
#Lthe limitation as if written in the body of this License.
#L
#L  9. The Free Software Foundation may publish revised and/or new versions
#Lof the General Public License from time to time.  Such new versions will
#Lbe similar in spirit to the present version, but may differ in detail to
#Laddress new problems or concerns.
#L
#LEach version is given a distinguishing version number.  If the Program
#Lspecifies a version number of this License which applies to it and "any
#Llater version", you have the option of following the terms and conditions
#Leither of that version or of any later version published by the Free
#LSoftware Foundation.  If the Program does not specify a version number of
#Lthis License, you may choose any version ever published by the Free Software
#LFoundation.
#L
#L  10. If you wish to incorporate parts of the Program into other free
#Lprograms whose distribution conditions are different, write to the author
#Lto ask for permission.  For software which is copyrighted by the Free
#LSoftware Foundation, write to the Free Software Foundation; we sometimes
#Lmake exceptions for this.  Our decision will be guided by the two goals
#Lof preserving the free status of all derivatives of our free software and
#Lof promoting the sharing and reuse of software generally.
#L
#L			    NO WARRANTY
#L
#L  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
#LFOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
#LOTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
#LPROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
#LOR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#LMERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
#LTO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
#LPROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
#LREPAIR OR CORRECTION.
#L
#L  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
#LWILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
#LREDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
#LINCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
#LOUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
#LTO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
#LYOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
#LPROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
#LPOSSIBILITY OF SUCH DAMAGES.
#L
#L		     END OF TERMS AND CONDITIONS
#L
#L	    How to Apply These Terms to Your New Programs
#L
#L  If you develop a new program, and you want it to be of the greatest
#Lpossible use to the public, the best way to achieve this is to make it
#Lfree software which everyone can redistribute and change under these terms.
#L
#L  To do so, attach the following notices to the program.  It is safest
#Lto attach them to the start of each source file to most effectively
#Lconvey the exclusion of warranty; and each file should have at least
#Lthe "copyright" line and a pointer to where the full notice is found.
#L
#L    <one line to give the program's name and a brief idea of what it does.>
#L    Copyright (C) 19yy  <name of author>
#L
#L    This program is free software; you can redistribute it and/or modify
#L    it under the terms of the GNU General Public License as published by
#L    the Free Software Foundation; either version 2 of the License, or
#L    (at your option) any later version.
#L
#L    This program is distributed in the hope that it will be useful,
#L    but WITHOUT ANY WARRANTY; without even the implied warranty of
#L    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#L    GNU General Public License for more details.
#L
#L    You should have received a copy of the GNU General Public License
#L    along with this program; if not, write to the Free Software
#L    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#L
#L
#LAlso add information on how to contact you by electronic and paper mail.
#L
#LIf the program is interactive, make it output a short notice like this
#Lwhen it starts in an interactive mode:
#L
#L    Gnomovision version 69, Copyright (C) 19yy name of author
#L    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
#L    This is free software, and you are welcome to redistribute it
#L    under certain conditions; type `show c' for details.
#L
#LThe hypothetical commands `show w' and `show c' should show the appropriate
#Lparts of the General Public License.  Of course, the commands you use may
#Lbe called something other than `show w' and `show c'; they could even be
#Lmouse-clicks or menu items--whatever suits your program.
#L
#LYou should also get your employer (if you work as a programmer) or your
#Lschool, if any, to sign a "copyright disclaimer" for the program, if
#Lnecessary.  Here is a sample; alter the names:
#L
#L  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
#L  `Gnomovision' (which makes passes at compilers) written by James Hacker.
#L
#L  <signature of Ty Coon>, 1 April 1989
#L  Ty Coon, President of Vice
#L
#LThis General Public License does not permit incorporating your program into
#Lproprietary programs.  If your program is a subroutine library, you may
#Lconsider it more useful to permit linking proprietary applications with the
#Llibrary.  If this is what you want to do, use the GNU Library General
#LPublic License instead of this License.
#L******************************************************************
# [pdf_off]


###########################
# Terminal Routines
##########################
sub cbreak {
     if ( $os eq "unix" )
      {
        $term->setlflag($noecho);  # ok, so i don't want echo either
        $term->setcc(VTIME, 1);
        $term->setattr($fd_stdin, TCSANOW);
      }

    }

sub cooked {
     if ( $os eq "unix" )
      {
        $term->setlflag($oterm);
        $term->setcc(VTIME, 0);
        $term->setattr($fd_stdin, TCSANOW);
      }
    }

sub readkey {
        my $key = '';
        cbreak();
        sysread(STDIN, $key, 1);
        cooked();
        return $key;
    }

########################################################
# Send escape chars to set the xterm title
#######################################################
sub set_title {
my ($title) = @_;
 if ( $en_trace == 1 ){print trace_file "set_title()\n";}
 if ( $os eq "unix" )
  {
#   if ( lc($ENV{"TERM"}) eq "xterm" )
   if ( $env_term eq "" )
     {
      $env_term = lc($ENV{"TERM"});
     }
   if ( $env_term eq "xterm" )
    {
     # if ( $title eq "" )  {$title = $ENV{"TERM"};}
     $ch_esc  = sprintf("%c",27);
     $ch_bell = sprintf("%c", 7);
     print $ch_esc ."]0;" . $title . $ch_bell;   # Set Xterm Icon and Title
    }
  }
}# sub set_title
  
########################################################
# Set Foreground and Background Colors using VT100 codes
#######################################################
sub set_color {
my ($mode, $fg, $bg ) = @_;
 if ( $en_trace == 1 ){print trace_file "set_color( $mode $fg $bg)\n";}
 if ( ( $os eq "unix" ) && ( $enable_vt100_color == 1)  )
  {
    $md_hash{"normal"    } = 0;
    $md_hash{"bold"      } = 1;
    $md_hash{"dim"       } = 2;
    $md_hash{"underline" } = 3;
    $md_hash{"blink"     } = 4;
    $md_hash{"reverse"   } = 5;
    $md_hash{"hidden"    } = 6;

    $fg_hash{"black"     } = 30;
    $fg_hash{"red"       } = 31;
    $fg_hash{"green"     } = 32;
    $fg_hash{"yellow"    } = 33;
    $fg_hash{"blue"      } = 34;
    $fg_hash{"magenta"   } = 35;
    $fg_hash{"cyan"      } = 36;
    $fg_hash{"white"     } = 37;

    $bg_hash{"black"     } = 40;
    $bg_hash{"red"       } = 41;
    $bg_hash{"green"     } = 42;
    $bg_hash{"yellow"    } = 43;
    $bg_hash{"blue"      } = 44;
    $bg_hash{"magenta"   } = 45;
    $bg_hash{"cyan"      } = 46;
    $bg_hash{"white"     } = 47;

     $ch_esc  = sprintf("%c",27);
     my_print($ch_esc ."[". $md_hash{$mode}.";".
                                $fg_hash{$fg  }.";".
                                $bg_hash{$bg  }."m");
  } # if $os eq unix
}# sub set_color 

##########################################################
# Two convenience functions.  clear_screen is obvious, and
# clear_end clears to the end of the screen.
##########################################################
sub clear_screen {
 if ( $en_trace == 1 ){print trace_file "clear_screen()\n";}
 if ( $batch_mode != 1 )
 {
  if ( $os eq "unix" )
   {
    $vt100_color_scheme = @vt100_color_array[$win32_color_select];
    ($fg, $bg) = split (' ', $vt100_color_scheme );
    $tcap->Tputs('cl', 1, *STDOUT);
    set_color("normal",$fg,$bg);
   }
  else
   {
    $STDOUT->Attr( $win32_color_scheme );
    $STDOUT->Cls( $win32_color_scheme );
   }
 }
 }
#sub clear_end    { 
# $tcap->Tputs('cd', 1, *STDOUT)
# }

# Move the cursor to a particular location.
sub gotoxy {
# if ( $en_trace == 1 ){print trace_file "gotoxy()\n";}
 if ( $batch_mode != 1 )
 {
    my($x, $y) = @_;
    $x = int ( $x );
    $y = int ( $y );

     if ( $os eq "unix" )
      {
       $tcap->Tgoto('cm', $x, $y, *STDOUT);
      }
     else
      {
       $STDOUT->Cursor($x, $y); # Set position only
      }
 }# if ( $batch_mode != 1 )
}# sub gotoxy {

##################################################
# A cheap viewer for poor Win32 users
##################################################
sub cv_view {
   my ( $input_file ) = @_;
   if ( lc(solve_ext( $input_file )) eq ".pdf" )
  {
    @run_shell     = solve_slash("$acroread_path $input_file");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
    if ( $rc != 0 )
      {
        $perl_line = __LINE__; 
        dialog_box(-1, "ERROR $perl_line:$bell# Acroreader Not Found : $cmd ". 
          "# Please check your acroread_path variable setting $acroread_path ".
          "# <Press Any Key> " );
      }
  }
  else
  {
   open( input_file , "<" . $input_file ); 
   my @text_lines;
   if ( $en_trace == 1 ){print trace_file "cv_view()\n";}
   if ($newbie== 1){dialog_box(2,"NewbieNote: Ctrl-u/d to scroll. <q> to quit");}
   while ( $_ = <input_file> ) 
    { 
      chomp $_; # Remove CR;
      ( $_ =~ s/#/*/go ); # Replace ALL '#' with '*';
      ( $_ =~ s/\r//go ); # Replace ALL CarriageRet with ''
      push @text_lines, $_;
    }# while ( $_ = <input_file> ) 
   close input_file;

   my $start_line =  0;
#  my $width = $maxx-4;
   my $width = $maxx; # NEW 05.06.2011
   scroll_box  ( $start_line, $width , @text_lines );
  } # if PDF
   $redraw = 1;
}# sub cv_view


##################################################
# A RTL viewer 
##################################################
sub cv_rtl_view {
   my ( $input_file ) = @_;
   open( input_file , "<" . $input_file ); 
   my @text_lines;
   if ( $en_trace == 1 ){print trace_file "cv_rtl_view()\n";}
   while ( $_ = <input_file> ) 
    { 
      chomp $_; # Remove CR;
      ( $_ =~ s/#/*/go ); # Replace ALL '#' with '*';
      ( $_ =~ s/\r//go ); # Replace ALL CarriageRet with ''
      push @text_lines, $_;
    }# while ( $_ = <input_file> ) 
   close input_file;

   my $start_line =  0;
   my $width = $maxx-4;
   scroll_box_rtl  ( $start_line, $width , @text_lines );
   $redraw = 1;
}# sub cv_view


#########################################
# scroll_box_rtl : Identical to scroll_box
#   but interprets VHDL and Verilog for
#   expanding/collapsing processes
#########################################
sub scroll_box_rtl {
  my( $start_line, $width , @scroll_list ) = @_;
  my @rtl_scroll_view ;
   if ( $en_trace == 1 ){print trace_file "scroll_box_rtl()\n";}

  $last_line = @scroll_list ; # Get Length of List
  # dialog_box( -1, "$max_lines");

  # This Generates a scrollable list box.
  $rts = 0;
  $bye = 0;
  $str = "";
  $left_right = 0;
  $longest_line_len = 0;
  my $i = 0;
  my $in_proc = 0;
  my $in_port_map = 0;
  my $in_comp_declare = 0;
  my $this_is_vhdl = 0;
  my $this_is_verilog = 0;

  # Parse VHDL/Verilog looking for process start/top and mark  
  # the sections for expanding/collapsing
  foreach $tmp_str ( @scroll_list )
   {
     if ( ($in_proc==1) || ( $in_port_map==1 ) || ($in_comp_declare==1 ) )
      { 
       @rtl_scroll_view[ $i ] = "-"; # Default Invisible
      }
     else
      {
       @rtl_scroll_view[ $i ] = " "; # Visible Uncompressable Text
      }


     $tmp_str_lc = " " . lc ( $tmp_str ) . " ";# Needed for /m\W as I chmpd CRs
     if ( (substr($tmp_str,0,2) ne "--") && 
          (substr($tmp_str,0,2) ne "//") 
        )
     {
      # Note \W means a non a-Z,0-9 character
#### VHDL    ##############################
      if ( $this_is_vhdl == 1 )
       {
        # Find Start and Stop of processes
        if ( $tmp_str_lc =~ m/\Wend process\W/go ) 
         { 
          @rtl_scroll_view[ $i ] = "^";
          $in_proc = 0; 
         }
        elsif ( $tmp_str_lc =~ m/\Wprocess\W/go )
         { 
          @rtl_scroll_view[ $i ] = "v";
          $in_proc = 1; 
         } # if ( $tmp_str_lc =~ m/\Wend process\W/go ) 

        # Find Start and Stop of Component Declrations
        if ( $in_comp_declare == 1 )
         {
          if ( $tmp_str_lc =~ m/end component/go ) 
           { 
            @rtl_scroll_view[ $i ] = "^";
            $in_comp_declare = 0; 
           }
         }
        elsif ( $tmp_str_lc =~ m/component\W/go )
         { 
          @rtl_scroll_view[ $i ] = "v";
          $in_comp_declare = 1; 
         }# if ( $in_port_map == 1 )

        # Find Start and Stop of Port Mappings
        if ( $in_port_map == 1 )
         {
          if ( $tmp_str_lc =~ m/\);/go ) 
           { 
            @rtl_scroll_view[ $i ] = "^";
            $in_port_map = 0; 
           }
         }
        elsif ( $tmp_str_lc =~ m/\Wport map\W/go )
         { 
          @rtl_scroll_view[ $i ] = "v";
          $in_port_map = 1; 
         }# if ( $in_port_map == 1 )

       } # if ( $this_is_vhdl == 1 )
#### Verilog ##############################
      elsif ( $this_is_verilog == 1 )
       {
        if ( $tmp_str_lc =~ m/\Wend\W/go ) 
         { 
          @rtl_scroll_view[ $i ] = "^";
          $in_proc = 0; 
         }
        elsif ( $tmp_str_lc =~ m/\Wbegin\W/go )
         { 
          @rtl_scroll_view[ $i ] = "v";
          $in_proc = 1; 
         } # if ( $tmp_str_lc =~ m/\Wend\W/go ) 
       } # if ( $this_is_vhdl == 1 )
     } # if not comment line
     else
     {
        # This is pretty lame. I use a comment line to determine if the 
        # file is VHDL or Verilog. 
        if    (substr($tmp_str,0,2) eq "--") { $this_is_vhdl    = 1 ; }
        elsif (substr($tmp_str,0,2) eq "//") { $this_is_verilog = 1 ; }
     }# if ( (substr($tmp_str,0,2) ne "--") && 

     $i++;
   }# foreach $tmp_str ( @scroll_list )



  # Figure out how long the longest line is so we can calculate
  # the scroll bar position.  
  foreach $tmp_str ( @scroll_list )
  {
    if ( length ($tmp_str) > $longest_line_len )
     {
      $longest_line_len = length ($tmp_str) + 2;
     }# if ( length ($tmp_str) > $longest_line_len )
   }# foreach $tmp_str ( @scroll_list )
  $enable_horiz_scroll = 0;

  if ( ( $longest_line_len > $width ) && ( $horiz_scroll_bar_option == 1 ) )
    { $enable_horiz_scroll = 1 ; }

  # Stay in this loop until non scroll key is hit
  while ( $bye == 0 )
    {
      $str = "";
      # $left_right = 0; # Hack
      
      $current_line = $start_line;

      for ( $tmp_i = 0 ; $tmp_i < $maxy-5;  )
       {
        if ( @rtl_scroll_view[$current_line] ne "-" )
        {
            $back = @rtl_scroll_view[$current_line] . " " .
                    @scroll_list[$current_line] ;
            ( $back =~ s/\n$//go ); # Replace ALL CRs with null  
           # This Scrolls LEft and Right Grab Section starting at left_right
           # of length width-2
            $str = $str . substr($back,$left_right,($width-2));
            $str = $str . "#"; 
            $tmp_i++;
        }# if ( @rtl_scroll_view[$current_line] ne "-" )
        $current_line++;
       }# for ( $tmp_i = 0 ; $tmp_i < $maxy-5;  )

        ( $str =~ s/\n$//go ); # Replace ALL CRs with null  
      if ( $enable_horiz_scroll == 1 )
      {
        $horiz_scroll_pos = int(( $width * $left_right ) / $longest_line_len);
        $str = $str . "<"; 
        for ( $tmp_i = 0 ; $tmp_i < ($width-5) ; $tmp_i++ )
         {
          if ($tmp_i == $horiz_scroll_pos ) { $str = $str . "[]"; } 
          $str = $str . "-"; # This is really lame. Sue me.
         }
        $str = $str . ">"; 
       }# if ( $enable_horiz_scroll == 1 )
      else
       {
        for ( $tmp_i = 0 ; $tmp_i < ($width-1) ; $tmp_i++ )
         {
          $str = $str . " "; # This is really lame. Sue me.
         }
       }# if ( $enable_horiz_scroll == 1 )

       $rts = dialog_box(-1,$str,0,0,$hide_scroll_border);
       clear_screen();
       $redraw = 1;

       if    ( $k_togl_hash{$rts}  == 1 ) 
        { 
          # Toggle betweeen expanded and collapsed process views
          if ( @rtl_scroll_view[ $start_line+1] eq "v" )
          {
           $current_line = $start_line+2;
           if ( @rtl_scroll_view[ $current_line ] eq "-" ) {$new_state = "|";}
           else                                            {$new_state = "-";}
           while ( 
                  ( $rtl_scroll_view[ $current_line] eq "-" ) ||
                  ( $rtl_scroll_view[ $current_line] eq "|" ) 
                )
            {
              $rtl_scroll_view[ $current_line] = $new_state;
              $current_line++;
            }
          }# if ( @rtl_scroll_view[ $start_line+1] eq "v" )
        }# if    ( $k_togl_hash{$rts}  == 1 ) 
       elsif    ( $k_nav_dn_hash{$rts}  == 1 ) 
        { 
         $start_line++; 
          while ( @rtl_scroll_view[ $start_line ] eq "-" ) 
           {
            $start_line++; # Keep scrolling till we hit a visible line 
           }

         #if ($current_line > $last_line )
         #  { $start_line--; }
         }
       elsif ( $k_pg_dn_hash {$rts}  == 1 ) 
        { 
         $start_line+=($maxy-6);
         # if ($current_line > $last_line )
         #  { $start_line-= ($maxy-6); }
         } 
       elsif ( $k_nav_rt_hash{$rts}  == 1 ) { $left_right+=20; }
       elsif ( $k_nav_lf_hash{$rts}   == 1 ) { $left_right-=20; }
       elsif ( $k_nav_up_hash{$rts}  == 1 ) 
         { 
          $start_line--;  
          while ( @rtl_scroll_view[ $start_line ] eq "-" ) 
           {
            $start_line--; # Keep scrolling till we hit a visible line 
           }
         }
       elsif ( $k_pg_up_hash {$rts}  == 1 ) { $start_line-=($maxy-6); } 
       else                                 { $bye = 1; }
       if ( $start_line < 0 ) { $start_line = 0 ; }
       if ( $left_right < 0 ) { $left_right = 0 ; }
     } # while ( $bye == 0 )
  return ( $rts, $start_line );
} # scroll_box_rtl()


########################################################################
# Display a Dialog Box 
# int : 0 for flash display.
# int : 1+ for sleeping # Seconds
# int : -1 for waiting for single keypress.
# int : -2 for waiting for 1 text entry line
# int : -3 for waiting for 2 text entry line, etc.
# str : Text String to Display. # separates lines
############################################
# Examples:
#   Dialog Box Example of timed delay with no key entry
#   dialog_box(5, "ERROR $perl_line:$bell# Unable to Tar: FOO");
#
#   Dialog Box Example of single keypress confirmation
#   $rts = dialog_box(0,"Question:#Would you like to play a game? <Y>/<N>");
#   dialog_box(3, "You Typed $rts");
#
#   Dialog Box Example of Text Entry Fields
#   $rts = dialog_box(-4,"Note:# Please Fill in the following 3 Lines,".
#            " pressing <ENTER> after each line#Line1:#Line2:#Line3:#");
#   dialog_box(0, "You Typed:#$rts[0] #$rts[1] #$rts[2] ");
#
########################################################################
sub dialog_box {
 my($wait_mode, $str,$x_absolute, $y_absolute, $no_border ) = @_;
# my $rts;
 if ( $en_trace == 1 ){print trace_file "dialog_box( " .
      substr($str,0,10) .  " )\n";}

    $wait_mode_tmp1 = $wait_mode;
    dialog_box_display ( $wait_mode_tmp1, $str, $x_absolute, $y_absolute ,
                         $no_border);
    $wait_mode_tmp2 = $wait_mode;
    $rts = dialog_box_input   ( $wait_mode_tmp2, $str );
    return $rts;
}# sub dialog_box()


sub dialog_box_display {
    my($wait_mode, $str, $x_absolute, $y_absolute, $no_border ) = @_;
    
    my $str1 = "";
    if ( $en_trace == 1 ){print trace_file "dialog_box_display()\n";}

    if ( $batch_mode == 1 ) { return ; } # Batch Mode
    $str_tmp = $str;
    $str_cnt = 0;
    $max_len = 0;
    while ( (($F1, $str_tmp ) = split ('#', $str_tmp , 2)) )
     {
      $str_cnt++; # Count the Lines separated by $.
      if ( length ( $F1 ) > $max_len ) { $max_len = length ( $F1 ) ; } 
     } # while

    $max_len+=4; # Make room for box sides and white space.

    if ( $max_len > $maxx ) { $max_len = $maxx ; }

    $x_start = ($maxx - $max_len ) / 2; # Center
    $y_start = 1 ;

    if ( $x_absolute ne "" ) 
      { 
       $x_start = $x_absolute;
       $y_start = $y_absolute;
      }
    
    $x = $x_start;
    $y = $y_start;
   
    $right_edge = $x_start + $max_len; 

    
    # Print Box Top
      $str1 = " "; 
      if ( $no_border == 1 ) { $str2 = " "; } else { $str2 = "_"; }
      for ( $tmp_i = 0 ; $tmp_i <($max_len-1); $tmp_i++) {$str1=$str1.$str2;}
      $str1 = $str1 . " "; 
      gotoxy ( $x, $y++ );
      my_print($str1); 
    

      while ( ($F1, $str ) = split ('#', $str , 2) )
      {
        if ( $curses_on != 1 )
         {
         # if ( $x > 5 )
         #   {
         #    gotoxy ( $x-4, $y ); $str1 = "    |"; my_print ($str1);# Left Side
         #   }
         # else
         #   {
              gotoxy ( $x, $y ); $str1 = "|"; 
              if ( $no_border == 1 ) { $str1 = " "; }
              my_print ($str1); # Left Side
         #   }
         }

        # Print String
         if ( $no_border == 1 ) { gotoxy(($x+0),$y); $str1 = substr($F1,0,80);}
#    if ( $no_border == 1 ) { gotoxy(($x+0),$y); $str1 = substr($F1,0,81)."A";}
         else                   { gotoxy(($x+1),$y); $str1 = substr($F1,0,75);}
         $x_wid = length ( $str1 ); # Remember for Cursor Placement
        # Clear to end of the line         
         for ( $tmp_i = $x_wid ;$tmp_i < $max_len; $tmp_i++){$str1=$str1." ";}
         if ( $no_border == 1 ) { my_print (      $str1      ); }
         else                   { my_print (" " . $str1 . " "); }

       if ( $curses_on != 1 )
       {
          if ( $no_border == 1 ) { $str1 = " "; } else { $str1 = "|"; }
          if ( $right_edge+5 < $maxx )
            {
             gotoxy ( $right_edge , $y );  my_print ($str1."    "); # Right Side
            }
          else
            {
             gotoxy ( $right_edge , $y );  my_print ($str1); # Right Side
            }
        }
       $y++;
      } # while

    # Print Box Bottom
      if ( $no_border == 1 ) { $str3 = " "; } else { $str3 = "|"; }
      if ( $no_border == 1 ) { $str2 = " "; } else { $str2 = "_"; }
      $str1 = $str3;
      for ( $tmp_i = 0 ; $tmp_i <($max_len-1); $tmp_i++) {$str1=$str1.$str2; }
      $str1 = $str1 . $str3; 
      if ( $right_edge+5 < $maxx )
        {
           $str1 = $str1 . "     "; 
        }
      gotoxy ( $x, $y++ );
      my_print($str1); 
      if ( $y < $maxy )
       {
        $str1 = " "; 
        for ( $tmp_i = 0 ; $tmp_i <($max_len-1); $tmp_i++) {$str1=$str1." "; }
        $str1 = $str1 . " "; 
        if ( $right_edge+5 < $maxx )
         {
           $str1 = $str1 . "     "; 
         }
        gotoxy ( $x, $y++ );
        my_print($str1); 
       }

} # dialog_box_display()

sub dialog_box_input {    
   my($wait_mode, $str ) = @_;
#   my $rts;
   if ( $en_trace == 1 ){print trace_file "dialog_box_input()\n";}
   # No Key Input. Just Sleep
    if ( $wait_mode >= 0 )
     {
      sleep ( $wait_mode );      # Wait Specified Seconds
      $rts = 0;
     } 
   # Single Keypress
   elsif ( $wait_mode == -1 )
     {
      gotoxy ( ($x_start+1), ( $y_start+2) ); # Position for Scroll Boxes
      $key_val = my_get_key();
      $rts =  $key_val ;
     }

   # Line Input       
   elsif ( $wait_mode < -1  )
     {
      $loop_cnt = abs ( $wait_mode + 1 );

      for ( $tmp_i = 0 ; $tmp_i < $loop_cnt ; $tmp_i++) 
       { 
        gotoxy ( ($x+$x_wid+2) , ($y-2-$loop_cnt+$tmp_i ) );
        $rts[$tmp_i] =  my_get_line();
       }# for ( $tmp_i = 0 ; $tmp_i < $loop_cnt ; $tmp_i++) 
     }# elsif ( $wait_mode < -1  )
   return $rts;
} # dialog_box_input();



#########################################
# Read Keyboard Line  
#########################################
sub my_get_line() {
my $rts = "";
my $key = "";

    if ( $os eq "win32" )
     {
      # close STDIN;
      # open STDIN;
     }
    $rts =  <STDIN> ; # Wait for TEXT Input

chomp $rts; 
if ( $en_trace == 1 ){print trace_file "my_get_line( rts $rts )\n";}
return $rts;

}

#########################################
# Print Function        
#########################################
sub my_print {
 my ($str) = @_;

  if ( $os eq "unix" )
   {
     print $str;
   }
  else
   {
     print $str;
   }
}

#########################################
# display_cursor        
#########################################
sub display_cursor {
  my $x1,$x2, $y1,$y2;
}# sub display_cursor {


#########################################
# Read Keyboard Input
#########################################
sub my_get_key() {

  if ( $os eq "unix" )
   {
      while ( ($key_val = ord( readkey() )) == 0 ){;} # Needed for non-Xterms

      if ( $en_trace == 1 ){print trace_file "my_get_key() Key=$key_val()\n";}
      if ( $key_val == 27 ) 
       {
        $key_val = ord( readkey() );
        if ($en_trace==1){print trace_file "ESC          Key=$key_val()\n";}
        # Note: xterm passes 91 for Arrows, gnome-term passes 79
        if ( $key_val == 91 || $key_val == 79 ) 
        {
         $key_val = 256 + ord( readkey() );# Speed up 3-char keys like arrows
         if ( $en_trace == 1 ){print trace_file " 3-key code Key=$key_val()\n";}

         # Check for a 4-char keys ( Ins,Del,Hom,End,PgUp,PgDn) and remove the
         # trailing 126 code.
         if ( $key_val >= 305  && $key_val <= 310 )
          {
           $null = ord( readkey() );
           $perl_line = __LINE__; 
           if ( $null != 126 && $en_trace==1){print trace_file "ERROR $perl_line: Expected 126 code\n";}
          }

         # Check for Mouse Code of 77
         if ( ( $x_mouse_enable == 1 ) && ( $key_val == (256+77) ) ) 
          {
            $mouse_button = ord(readkey()) -32+1; # 1 = Left,2=Middle,3=Right
            # Check for scroll wheel
            if ( $x_mouse_wheel_enable == 1 ) 
            {
             if ( $mouse_button == 65 || $mouse_button == 66 )
              {
               if ( $mouse_button == 65 ) { $key_val = $k_up; }
               if ( $mouse_button == 66 ) { $key_val = $k_dn; }
               return $key_val;
              }
            }# if ( $x_mouse_wheel_enable == 1 ) 
          
            $mouse_x = ord(readkey()) -32 - 1;
            $mouse_y = ord(readkey()) -32 - 1;
            $key_val = "";
            if ( $en_trace == 1 )
              {print trace_file " Mouse $mouse_button $mouse_x $mouse_y\n"; }

           # Check for Double-Click
           if ( ( $mouse_y_p1 == $mouse_y ) &&
                ( $mouse_x_p1-1 <= $mouse_x ) &&
                ( $mouse_x_p1+1 >= $mouse_x ) 
              )
             {
              return "double_click";
             }
           else
            {
             $cur_y = $mouse_y ;
             $mouse_x_p1 = $mouse_x;
             $mouse_y_p1 = $mouse_y;
             return 0; # Just Move the cursor
            }

          }
         if ($en_trace==1){print trace_file "91/79        Key=$key_val()\n";}
         # As the cursor gets updated 1/3 the time
        }
       }

   }
  else
   {
     # Wacky Win32 Event Stuff
     @event[0] = 0;
     $key_direction = 0;
     # Stay in Loop if CTRL key (8) is pressed or KeyUp event
     while ( 
               (@event[0] != 1)      ||   # Stay While Note KeyEvent
               ($key_direction == 0) ||   # Stay While KeyUp Event
               ( ( $key_ctrl_key == 8) && ( $key_ascii == 0 ) ) 
           )
     {
       @event = $STDIN->Input(); # This waits for an event to happen
       $STDIN->Flush(); # Now flush that event so it doesnt mess with next

       $key_direction  = @event[1]; # 1=Down, 0=Up
       $key_repeat_cnt = @event[2];
       $key_keycode    = @event[3];
       $key_scancode   = @event[4];
       $key_ascii      = @event[5];
       $key_ctrl_key   = @event[6]; # SHIFT= CTRL= ALT=

       if ( $key_ascii != 0 ) { $key_val = $key_ascii ; }
       elsif ( 
                ($key_scancode == $k_cr) ||
                ($key_scancode == $k_up) ||
                ($key_scancode == $k_dn) ||
                ($key_scancode == $k_lf) ||
                ($key_scancode == $k_rt) 
             )
         { $key_val = $key_scancode ; } # for Arrows
       else
         { $key_val = ""; } # Ignore Shift Keys

       # Check for Mouse Click
     if ( $win32_mouse_enable == 1 )
     {
       if ( (@event[0] == 2) )
       {
        $mouse_button_p1 = $mouse_button; # Rember to detect double clicks
        $mouse_x        = @event[1];
        $mouse_y        = @event[2];
        $mouse_button   = @event[3]; # Left=1,Rt=2, Mid=4
        $mouse_ctrl_key = @event[4];
        $mouse_event    = @event[5];

        # Edge Detect Mouse Button Transitions
        if ( ( $mouse_button == 2) && ( $mouse_button_p1 == 0 ) )
         {
           $cur_y = $mouse_y;
           return $k_mouse_port_view; # Right Click
         }

        # Edge Detect Mouse Button Transitions
        if ( ( $mouse_button == 1) && ( $mouse_button_p1 == 0 ) )
         {
          # Check for Double-Click
          if ( ( $mouse_x_p1 == $mouse_x ) &&
               ( $mouse_y_p1 == $mouse_y )     )
            {
             return "double_click";
            }
          else
            {
             $cur_y = $mouse_y;
             $mouse_x_p1 = $mouse_x;
             $mouse_y_p1 = $mouse_y;
             return 0; # Just Move the cursor
            }
         }# if ( $mouse_button == 1 )
        elsif ( ( $mouse_button == 1) && ( $mouse_button_p1 == 1 ) )
         {
           $cur_y = $mouse_y;
          # Check for Scrolling Positions
          if ( ( $mouse_y  == $miny )     )
            {
             return $k_up; 
            }
          elsif ( ( $mouse_y  == $maxy )     )
            {
             return $k_dn; 
            }
          else
            {
             return 0; # Just Move the cursor
            }
         }# if ( $mouse_button == 1 )
       }# if ( @event[0] == 2 ) Mouse Event
      } # if ( $win32_mouse_enable == 1 )
     }# while ( (@event[0] != 1) || ($key_direction == 0) ||
   }# if unix

  return $key_val;
}# sub my_get_key() 

#########################################
# scroll_box
#########################################
sub scroll_box {
  my( $start_line, $width , @scroll_list ) = @_;
  if ( $en_trace == 1 ){print trace_file "scroll_box()\n";}

  $last_line = @scroll_list ; # Get Length of List

  # This Generates a scrollable list box.
  $rts = 0;
  $bye = 0;
  $str = "";
  $left_right = 0;
  $longest_line_len = 0;

  # Figure out how long the longest line is so we can calculate
  # the scroll bar position.  
  foreach $tmp_str ( @scroll_list )
   {
    if ( length ($tmp_str) > $longest_line_len )
     {
      $longest_line_len = length ($tmp_str);
     }# if ( length ($tmp_str) > $longest_line_len )
   }# foreach $tmp_str ( @scroll_list )
  $enable_horiz_scroll = 0;
  if ( ( $longest_line_len > $width ) && ( $horiz_scroll_bar_option == 1 ) )
    { $enable_horiz_scroll = 1 ; }

  # Stay in this loop until non scroll key is hit
  while ( $bye == 0 )
    {
      $str = "";
      
      $current_line = $start_line;

      for ( $tmp_i = 0 ; $tmp_i < $maxy-5;  )
       {
        $back = @scroll_list[$current_line++];
        ( $back =~ s/\n$//go ); # Replace ALL CRs with null  

        # This Scrolls LEft and Right Grab Section starting at left_right
        # of length width-2
         $str = $str . substr($back,$left_right,($width-2));
             
          $str = $str . "#"; 
          $tmp_i++;

       }# for ( $tmp_i = 0 ; $tmp_i < $maxy-5;  )
 
        ( $str =~ s/\n$//go ); # Replace ALL CRs with null  

      if ( $enable_horiz_scroll == 1 )
      {
        $horiz_scroll_pos = int(( $width * $left_right ) / $longest_line_len);
        $str = $str . "<"; 
        for ( $tmp_i = 0 ; $tmp_i < ($width-5) ; $tmp_i++ )
         {
          if ($tmp_i == $horiz_scroll_pos ) { $str = $str . "[]"; } 
          $str = $str . "-"; # This is really lame. Sue me.
         }
        $str = $str . ">"; 
       }# if ( $enable_horiz_scroll == 1 )
      else
       {
        for ( $tmp_i = 0 ; $tmp_i < ($width-1) ; $tmp_i++ )
         {
          $str = $str . " "; # This is really lame. Sue me.
         }
       }# if ( $enable_horiz_scroll == 1 )

       $rts_key = dialog_box(-1,$str,0,0,$hide_scroll_border);
       clear_screen();
       $redraw = 1;

       if    ( $k_nav_dn_hash{$rts_key}    == 1 ) {$start_line++;}
       elsif ( $k_pg_dn_hash {$rts_key}    == 1 ) {$start_line+=($maxy-6);} 
       elsif ( $k_nav_rt_hash{$rts_key}    == 1 ) {$left_right+=20;}
       elsif ( $k_nav_lf_hash{$rts_key}    == 1 ) {$left_right-=20;}
       elsif ( $k_nav_up_hash{$rts_key}    == 1 ) { $start_line--;}
       elsif ( $k_pg_up_hash {$rts_key}    == 1 ) {$start_line-=($maxy-6);} 
       elsif (  ( $k_search_dn_hash{$rts_key} == 1 ) ||
                ( $k_search_up_hash{$rts_key} == 1 )
             )
         {
           $rts = dialog_box(-2, "Search_For [NULL=$last_search]#:");
           if ( $rts[0] eq "" )  { $rts[0] = $last_search; }
           $last_search = $rts[0];
           $tmp_i = $start_line; $break_loop = 0;
           while ( 
                   ( $tmp_i < @scroll_list  ) && 
                   ( $tmp_i >= 0            ) && 
                   ( $break_loop == 0 ) 
                 )
            {
             if ($k_search_dn_hash{$rts_key}==1 ) {$tmp_i++;} else {$tmp_i--;}
               
             if ( @scroll_list[ $tmp_i ] =~ m/$last_search/g ) 
              {
               $start_line = $tmp_i-1; 
               $break_loop = 1;
              }# if ( @modname_array[ $tmp_i ] =~ m/$last_search[0]/g ) 
            }# while ( @scroll_list[$tmp_i++] ne "" )
          if ($break_loop==0){dialog_box(1,"NOTE: Cant find $last_search");}  
         }# elsif ( $k_search_dn_hash{$rts} == 1 )
       else                                 { $bye = 1; }
       if ( $start_line < 0 ) { $start_line = 0 ; }
       if ( $left_right < 0 ) { $left_right = 0 ; }
     } # while ( $bye == 0 )
  return ( $rts, $start_line );
} # scroll_box()

#########################################
# banner_message
#########################################
sub banner_message {
  my ( $banner_time ) = @_;
  if ( $en_trace == 1 ){print trace_file "banner_message()\n";}

@welcome_array[0] = "Mir dita  # to our Albanian users";
@welcome_array[1] = "Ahalan  # to our Arabic speaking users";
@welcome_array[2] = "Parev  # to our Armenian users";
@welcome_array[3] = "Zdravei / Zdrasti  # to our Bulgarian users";
@welcome_array[4] = "Nei Ho  # to our Cantonese speaking Chinese users";
@welcome_array[5] = "Dobr* den / Ahoj  # to our Czech users";
@welcome_array[6] = "Goddag  # to our Danish users";
@welcome_array[7] = "Goede dag, Hallo  # to our Dutch users";
@welcome_array[8] = "Hello  # to our English users";
@welcome_array[9] = "Saluton  # to our Esperanto speaking users";
@welcome_array[10] = "Hei  # to our Finnish users";
@welcome_array[11] = "Bonjour  # to our French users";
@welcome_array[12] = "Guten Tag  # to our German users";
@welcome_array[13] = "Gia'sou  # to our Greek users";
@welcome_array[14] = "Aloha  # to our Hawaiian users";
@welcome_array[15] = "Shalom  # to our Hebrew speaking users";
@welcome_array[16] = "Namaste  # to our Hindi speaking users";
@welcome_array[17] = "J* napot  # to our Hungarian users";
@welcome_array[18] = "Hall* / G**an daginn  # to our Icelandic users";
@welcome_array[19] = "Halo  # to our Indonesian users";
@welcome_array[20] = "Aksunai / Qanuipit?  # to our Inuit users";
@welcome_array[21] = "Dia dhuit  # to our Irish users";
@welcome_array[22] = "Salve / Ciao  # to our Italian users";
@welcome_array[23] = "Kon-nichiwa  # to our Japanese users";
@welcome_array[24] = "An-nyong Ha-se-yo  # to our Korean users";
@welcome_array[25] = "Salve / Salv te  # to our Latin/Roman users";
@welcome_array[26] = "Ni hao  # to our Mandarin speaking Chinese users";
@welcome_array[27] = "Hallo  # to our Norwegian users";
@welcome_array[28] = "Dzien' dobry  # to our Polish users";
@welcome_array[29] = "Ol*  # to our Portuguese users";
@welcome_array[30] = "Bun* ziua  # to our Romanian users";
@welcome_array[31] = "Zdravstvuyte  # to our Russian users";
@welcome_array[32] = "Hola  # to our Spanish speaking users";
@welcome_array[33] = "Jambo / Hujambo  # to our Swahili users";
@welcome_array[34] = "Hej  # to our Swedish users";
@welcome_array[35] = "Sa-wat-dee  # to our Thai users";
@welcome_array[36] = "Merhaba / Selam  # to our Turkish users";
@welcome_array[37] = "Vitayu  # to our Ukrainian users";
@welcome_array[38] = "Xin ch*o  # to our Vietnamese users";
@welcome_array[39] = "Hylo; Sut Mae?  # to our Welsh users";
@welcome_array[40] = "Sholem Aleychem  # to our Yiddish speaking users";
@welcome_array[41] = "Sawubona  # to our Zulu speaking users";
$greeting = int ( (rand(0) * 42 ));
($F1, $F2 ) = split ('#', @welcome_array[$greeting],2) ; #Parse

  $rts = dialog_box($banner_time ,"" .
     "#       _________                                                      ".
     "#      |         |         ChipVault   Version $version ".
     "#      |      o  |                                                     ".
     "#      |       \\ |         Copyright (C) 2013 Kevin M. Hubbard         ".
     "#       ---------                                                      ".
     "#        |     |                                                       ".
     "#                                                                      ".
     "#This is free software, and you are welcome to redistribute it under   ". 
     "#certain conditions.                                                   ".
     "#Disclaimer and Terms of Use:                                          ".
     "#ChipVault comes with ABSOLUTELY NO WARRANTY, without even the implied".
     "#warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.      ".
     "#It is provided 'AS IS'. You assume THE ENTIRE RISK as to the use,     ".
     "#quality and performance of this software and any circuitry generated. ".
     "#See the enclosed GNU General Public License for more details.".
      "#                                                                      ".
      "#        $F1 \( $F2 \)");
}# sub banner_message
#########################################
# banner_message
#########################################
sub new_version_message {
  my ( $banner_time ) = @_;
  if ( $en_trace == 1 ){print trace_file "new_version_message()\n";}

  $rts = dialog_box(-1 ,"" .
     "#                                                                      ".
     "#        Welcome to a new and improved version of ChipVault!           ".
     "#                                                                      ". 
     "#    Please read the Change Log at chipvault.sourceforge.net for       ".
     "#    specifics on bug fixes and new features.                          ".
     "#                                                                      ". 
     "# Important:                                                           ". 
     "#    Please Email the author after trying this update and provide some ".
     "#    feedback. Open-Source software is funded by feedback, so PLEASE   ".
     "#    take the time to Email. Thank you.                                ".
     "# <Press Any Key> " );
}# sub new_version_message {


##############################################################
# Get the terminal speed through the POSIX module and use that
# to initialize Term::Cap.
##############################################################
sub init {

 if ( $os eq "unix" )
  {
   if ( $x_mouse_enable == 1 ) { x_mouse_on(); }

    $| = 1;
    $delay = (shift() || 0) * 0.005;
   # print "delay  = $delay \n";
    my $termios = POSIX::Termios->new();
    $termios->getattr;
    my $ospeed = $termios->getospeed;
    $tcap = Term::Cap->Tgetent ({ TERM => undef, OSPEED => $ospeed });
#    $tcap->Trequire(qw(cl cm cd)); # Telnet to Solaris failed on 'cd'
    $tcap->Trequire(qw(cl cm ));
  }
 else
  {
   $STDIN  = new Win32::Console(STD_INPUT_HANDLE);
   $STDOUT = new Win32::Console(STD_OUTPUT_HANDLE);

   # Doesnt work vvv
   # $STDOUT->Window( 1, 0, 0, 80, 50 ); # SuperSize Me Baby.

   $STDOUT->Alloc();
   $STDIN ->Alloc();

   $STDOUT->Display();
   $STDOUT->Attr( $win32_color_scheme );
   $STDOUT->Cls( $win32_color_scheme );
   $STDOUT->Title("ChipVault $version");
#   $STDIN->Mode(ENABLE_MOUSE_INPUT | ENABLE_PROCESSED_INPUT);

   if ( $win32_mouse_enable == 1 )
    {
     $STDIN->Mode(ENABLE_PROCESSED_INPUT | ENABLE_LINE_INPUT | 
                ENABLE_ECHO_INPUT | ENABLE_MOUSE_INPUT );
    }
   else
    {
     $STDIN->Mode(ENABLE_PROCESSED_INPUT | ENABLE_LINE_INPUT | 
                  ENABLE_ECHO_INPUT );
    }
  }
}# sub init

# Clean up the screen.
sub finish {
  if ( $en_trace == 1 ){print trace_file "finish()\n";}
    gotoxy(0, $maxrow);
    clear_screen();
  #  clear_end();
}

# Dump Array .
sub dump {
  if ( $en_trace == 1 ){print trace_file "dump()\n";}
  # clear_end();
  gotoxy(0, 0 );
  for ( $i = 1 ; $i < $array_size; $i++ )    # Loop thru all entries
  { 
      $a = " $i " .   @filename_array[ $line ] ;
      $a = $a . " " . @level_array[ $line ];
      $a = $a . " " . @show_array[ $line ];
      $a = $a . " " . @flag_array[ $line ];
      $a = $a . " " . @y_loc_array[ $line ];
       print STDOUT " $a\n";
  }
}# sub dump

#################################################################
# issue_list : Keep track of issues               
#################################################################
sub issue_list_add {
  my($my_name, $mod_name, $file_name ) = @_;
  if ( $en_trace == 1 ){print trace_file "issue_list_add()\n";}
  $id       = 0; # Default in case issue file not found;
  $title    = "Flux Capacitor Problem";
  $reporter = $my_name;
  $assigned = $my_name;
  $state    = "open" ;
  $description = "yada yada yada";

  open( input_file , "<" . $issue_file );  #
  while ( $_ = <input_file> )
   {
     ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $_ ,5) ; #Parse
     if ( $F1 eq "[ISSUE_ID]" ) { $id = $F2 ; }
   }
  close input_file;

  $id = $id+1;
  $id_str = sprintf( "%06d", $id );

  $rts = dialog_box(-7,
         "Issue_List:    #                                        ".
         "# Please fill in the following fields to enter a new    ".
         "# issue, or just hit <ENTER> for a field to use default.".
         "# Module Name  ( $mod_name )".
         "# Reporter     ( $my_name ) ". 
         "# AssignedTo   ( $my_name ) ". 
         "# Title        (          ) ". 
         "# ID_Tag       ( $id_str  ) ". 
         "# State        ( $state   ) ". 
         "");
        clear_screen();

  if ( $rts[0] ne "" ) { $mod_name       = $rts[0] ; }
  if ( $rts[1] ne "" ) { $reporter       = $rts[1] ; }
  if ( $rts[2] ne "" ) { $assigned       = $rts[2] ; }
  if ( $rts[3] ne "" ) { $title          = $rts[3] ; }
  if ( $rts[4] ne "" ) { $id_str         = $rts[4] ; }
  if ( $rts[5] ne "" ) { $state          = $rts[5] ; }

  $rts = dialog_box(-2,
     "Description: Please type a detailed description of the issue.     ".
     "#:".
     "");
  if ( $rts[0] ne "" ) { $description    = $rts[0] ; }

  $my_time = localtime(time); # Create timestamp with no spaces.
  ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $my_time ,5) ; #Parse
  $my_time = $F2 . "_" . $F3; # "Jan 12"

  open( output_file , ">>" . $issue_file );  #
  $str = "";
  $str = $str .  "[ISSUE_ID]          $id_str\n";
  $str = $str .  "[ISSUE_TITLE]       $title\n";
  $str = $str .  "[ISSUE_MODULE]      $mod_name\n";
  $str = $str .  "[ISSUE_REPORTER]    $reporter\n";
  $str = $str .  "[ISSUE_ASSIGNED]    $assigned\n";
  $str = $str .  "[ISSUE_STATE]       $state\n";
  $str = $str .  "[ISSUE_DATE]        $my_time\n";
  $str = $str .  "[ISSUE_DESCRIPTION_START]\n";
  $str = $str .  "$description\n";
  $str = $str .  "[ISSUE_DESCRIPTION_STOP]\n";
  $str = $str .  "[ISSUE_END_TAG]\n\n";
  print output_file $str;
  close output_file ;

  if ( $os eq "unix" )
   {
    $send_email_question = dialog_box(-1,
         "Send Email:".
         "# Would you like me to send email of this new issue to " .
            $assigned . $email_domain . " ?".
         "# (y/n) :". 
         "");
    if ( $send_email_question == ord ("y" ) )
     {
      $to   = $assigned . $email_domain;
      $from = $reporter . $email_domain;
      send_email( $to, $from, $title, $str );
     }# if ( $send_email_question == ord ("y" ) )
   } # if os unix
  
}# sub issue_list_add

#################################################################
# send_email : Think about it
#################################################################
sub send_email {
  my( $to, $from, $subject, $body ) = @_;
  if ( $en_trace == 1 ){print trace_file "send_email()\n";}
  if ( $send_email_allowed != 1 ) { return ; }
# See Sheep Book (aka Perl Cookbook) Pg. 651
#      if ( (open( SENDMAIL  , ">" . "email.txt" )  ) == 0 )
      if ( (open ( SENDMAIL, "| sendmail $to ")) == 0 )
       {
        $perl_line = __LINE__; 
        dialog_box(5, "ERROR $perl_line:$bell# sendmail failed ");
       }
      else
       {
        $email_str = "";
        $email_str = $email_str . "From: $from\n";
        $email_str = $email_str . "To: $to\n";
        $email_str = $email_str . "Subject: $subject\n";
        $email_str = $email_str . "$body\n";
        $email_str = $email_str . ".\n";
        print SENDMAIL $email_str ;
        close SENDMAIL;
       }
}# sub send_email


#################################################################
# issue_list : Keep track of issues               
#################################################################
sub issue_list_view {
  my($my_name, $mod_name, $file_name, $batch_file, $batch_n ) = @_;
  if ( $en_trace == 1 ){print trace_file "issue_list_view()\n";}

  undef @batch_array;
  undef @str_array_sorted;
  
  open( input_file , "<" . $issue_file );  #
  while ( $_ = <input_file> )
   {
     chomp $_;
     ($F1, $F2, $ETC ) = split (' ', $_ ,3) ; #Parse
     if ( $F1 eq "[ISSUE_ID]"     )     
       { $id         = $F2 ; 
         $desc="";
         $desc_on = 0;
       }
     elsif ( $F1 eq "[ISSUE_TITLE]"  )      { $title      = "$F2 $ETC" ; }
     elsif ( $F1 eq "[ISSUE_MODULE]" )      { $mod_name   = $F2 ; }
     elsif ( $F1 eq "[ISSUE_REPORTER]")     { $reporter   = $F2 ; }
     elsif ( $F1 eq "[ISSUE_ASSIGNED]")     { $assigned   = $F2 ; }
     elsif ( $F1 eq "[ISSUE_STATE]" )       { $state      = $F2 ; }
     elsif ( $F1 eq "[ISSUE_DATE]"  )       { $datestamp  = $F2 ; }
     elsif ( $F1 eq "[ISSUE_DESCRIPTION_START]")  { $desc_on = 1 ; }
     elsif ( $F1 eq "[ISSUE_DESCRIPTION_STOP]" )  { $desc_on = 0 ; }
     elsif ( $desc_on == 1 ) { $desc = $desc . $_ . "\n"; }
     elsif ( $F1 eq "[ISSUE_END_TAG]")
      {
       ( $desc =~ s/\n//go ); # Replace CRs in Description with Null
       @issue_array_id       [ $id ] = $id ;
       @issue_array_title    [ $id ] = $title;
       @issue_array_module   [ $id ] = $mod_name;
       @issue_array_reporter [ $id ] = $reporter;
       @issue_array_assigned [ $id ] = $assigned;
       @issue_array_state    [ $id ] = $state   ;
       @issue_array_date     [ $id ] = $datestamp;
       @issue_array_desc     [ $id ] = $desc    ;
      }
   }
  close input_file;

  #Sort     <ENTER> to View",0,30) ;
## Note : Feel free to change to formatting here.
     $tt1 = "";
     $tt1 = $tt1 . " " . pack "A10", "<1>";
     $tt1 = $tt1 . " " . pack "A10", "<2>";
     $tt1 = $tt1 . " " . pack "A10", "<3>";
     $tt1 = $tt1 . " " . pack "A10", "<4>";
     $tt1 = $tt1 . " " . pack "A10", "<5>";
     $tt1 = $tt1 . " " . pack "A10", "<6>";
     $tt1 = $tt1 . " " . pack "A40", "<7>";
     $tt1 = $tt1 . " " . pack "A100", "<8>";

     $tt2 = "";
     $tt2 = $tt2 . " " . pack "A10", "ID";
     $tt2 = $tt2 . " " . pack "A10", "Reported";
     $tt2 = $tt2 . " " . pack "A10", "AssignTo";
     $tt2 = $tt2 . " " . pack "A10", "Module";
     $tt2 = $tt2 . " " . pack "A10", "State";
     $tt2 = $tt2 . " " . pack "A10", "Date";
     $tt2 = $tt2 . " " . pack "A40", "Title";
     $tt2 = $tt2 . " " . pack "A100", "Description";

  my @str_array = ();
  my @id_array = ();
  foreach $_ ( @issue_array_id ) 
   {
     if ( $_ ne "" ) 
     {
      ($id, $ETC ) = split (' ', $_ ,2) ; #Parse
      $str = "";
      $str = $str . " " . pack "A10", @issue_array_id[ $id ];
      $str = $str . " " . pack "A10", @issue_array_reporter[ $id ];
      $str = $str . " " . pack "A10", @issue_array_assigned[ $id ];
      $str = $str . " " . pack "A10", @issue_array_module[ $id ];
      $str = $str . " " . pack "A10", @issue_array_state[ $id ];
      $str = $str . " " . pack "A10", @issue_array_date[ $id ];
      $str = $str . " " . pack "A40", @issue_array_title[ $id ];
      # $str = $str . " " . pack "A100", @issue_array_desc[ $id ] ;
      $str = $str . " " . @issue_array_desc[ $id ] ;
      push @str_array, $str;
      push @id_array, $id;


  if ( $batch_file ne "" )
   {
      $n = $batch_n ;
      if    ( $n == 1 ) { $sorted_by = @issue_array_id[ $id ]; }
      elsif ( $n == 2 ) { $sorted_by = @issue_array_reporter[ $id ]; }
      elsif ( $n == 3 ) { $sorted_by = @issue_array_assigned[ $id ]; }
      elsif ( $n == 4 ) { $sorted_by = @issue_array_module  [ $id ]; }
      elsif ( $n == 5 ) { $sorted_by = @issue_array_state   [ $id ]; }
      elsif ( $n == 6 ) { $sorted_by = @issue_array_date    [ $id ]; }
      elsif ( $n == 7 ) { $sorted_by = @issue_array_title   [ $id ]; }
      $tmp_str = @issue_array_id[$id] . " " . $sorted_by . " " . @issue_array_title[$id] . "\n";
      push @batch_array, $tmp_str;
   }


     }# if ( $_ ne "" ) 
   }# foreach $_ ( @issue_array_id ) 


  if ( $batch_file eq "" )
   {
    $n = 1; # Start out sorting by ID#
    $loop_forever = 1;
   }
  else
   {
    $loop_forever = 0;
   }

  do 
  {
   if ( $batch_file eq "" )
     {
      @str_array_sorted = sort by_word_n @str_array;
     }
   else
     {
      $n =1; # Sort by the 2nd String (Requested Sort String)
      @str_array_sorted = sort by_word_n @batch_array;
     }
   
   my @display_str_array = ();
   if ( $batch_file eq "" )
    {
      push @display_str_array, "[ Issue View List ]    <1>..<9>=Sort <ENTER>=View Cursor=Scroll";
      push @display_str_array, " " ; # White Space
      push @display_str_array, $tt1; # Prepend Title Line
      push @display_str_array, $tt2; # Prepend Title Line
    }# if ( $batch_file eq "" )
   $my_line = 0;

   if ( $batch_file ne "" )
     {
        open( batch_output_file , ">" . $batch_file ); 
     }

   foreach $_ ( @str_array_sorted )
    {
     push @display_str_array, $_;  
     ($id, $ETC ) = split (' ', $_ , 2 ); #Parse
     @line_lookup[$my_line] = $id;
     $my_line++;
     if ( $batch_file ne "" )
      {
          chomp $_ ; # Remove CR
          print batch_output_file substr($_,0,140) . "\n";
      }# if ( $batch_file ne "" )
    }

      if ( $batch_file eq "" )
       {
        ($key_val, $line ) = scroll_box(0, ($maxx-4), @display_str_array );
         clear_screen();
       }
     else
       {
        $key_val = "";
        close batch_output_file;
       }


  # ERROR: This assumes a sequential list of IDs exist!
  if ( $k_enter_hash { $key_val } == 1 )
    {
     # dialog_box(1, "$line " . @id_array[$line-3]);
      $str = "";
      # $id = @id_array[$line-3];
      $id = @line_lookup [$line-3];
      $str = $str . "\n" . pack "A20", "[ISSUE_ID]";
      $str = $str . @issue_array_id[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_TITLE]";
      $str = $str . @issue_array_title[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_MODULE]";
      $str = $str . @issue_array_module[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_REPORTER]";
      $str = $str . @issue_array_reporter[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_ASSIGNED]";
      $str = $str . @issue_array_assigned[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_STATE]";
      $str = $str . @issue_array_state[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_DATE]";
      $str = $str . @issue_array_date[ $id ];
      $str = $str . "\n" . pack "A20", "[ISSUE_DESCRIPTION]";
      $str = $str . @issue_array_desc[ $id ] ;

     # $desc_str = @issue_array_desc[ @id_array[$line-3] ] ;
       $desc_str = $str;
     my @tmp_array = ();
     while ( ($tmp_str, $desc_str ) = split ('\n', $desc_str ,2) )
      {
       push @tmp_array, $tmp_str; 
      } 
        scroll_box(0,($maxx-4) ,@tmp_array );
        clear_screen();

    }# if ( $k_enter_hash { $key_val } == 1 )
  elsif ( ( $key_val >= $k_1 ) && ( $key_val <= $k_9 ) )
    {
      if ( $key_val == $k_1 ) { $n = 0 ; }
      elsif ( $key_val == $k_2 ) { $n = 1 ; }
      elsif ( $key_val == $k_3 ) { $n = 2 ; }
      elsif ( $key_val == $k_4 ) { $n = 3 ; }
      elsif ( $key_val == $k_5 ) { $n = 4 ; }
      elsif ( $key_val == $k_6 ) { $n = 5 ; }
      elsif ( $key_val == $k_7 ) { $n = 6 ; }
      elsif ( $key_val == $k_8 ) { $n = 7 ; }
      elsif ( $key_val == $k_9 ) { $n = 8 ; }
    }
  else
    {
      return;
    }
  } while ( $loop_forever == 1 )
}# sub issue_list_view()

####################
# Sort Array by Wordn 
####################
sub by_word_n
 {
   my $a1   = "";
   my $b1   = "";
   @a_word_array = split (' ', $a , 9); #Parse
   $a1 = @a_word_array[ $n ];
   @b_word_array = split (' ', $b , 9); #Parse
   ($F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $ETC ) = split (' ', $b , 9); #Parse
   $b1 = @b_word_array[ $n ];
   return $a1 cmp $b1;
}# sub by_word_n

  


#################################################################
# generate_rtl : Generate a RTL template. Warning - this is quite
#                the bastard subroutine.
#################################################################
sub generate_rtl {
  undef @port_list;

  my($select_file, $rtl_type ) = @_;
  if ( $en_trace == 1 ){print trace_file "generate_rtl()\n";}
         if ( $rtl_type eq "vhdl" )
          { $rtl_type_str = "# File Name    <ENTER> for (module).vhd :"; }
         else
          { $rtl_type_str = "# File Name    <ENTER> for (module).v   :"; }

       $rts = dialog_box(-4,
         "Generate_RTL: #                                         ".
         "# I will now create a VHDL/Verilog template for you.    ".
         "# Please specify the following information.             ".
         "# Module Name  (ie foo)                 :".
         $rtl_type_str.
         "# Architecture <ENTER> for rtl          :". 
         "");
        clear_screen();


        my $mod_name     = $rts[0] ;
        my $file_name    = $rts[1] ;
        my $arch_type    = $rts[2] ;
        my @new_lines    = ();
        my $child_mod    = "";
        if ( $arch_type  eq "" ) { $arch_type = "rtl" ; } # Default 


        $key_val_confirm = dialog_box(-1," Press <Y>es to Generate " .
            " a new file.# Press <N>o to just dump template to $slog_file");
        clear_screen();
        if ( $key_val_confirm == ord ("n") )
         {
          $file_name = $slog_file;
         }

        if ( ( $file_name  eq "" ) )
         { 
          if ( $rtl_type eq "vhdl" ) { $file_name  = $mod_name  . ".vhd" ; }
          else                       { $file_name  = $mod_name  . ".v"   ; }
         } # Default 

        if ( (substr($file_name [0],-2,2) eq ".v") )
          {$rtl_type = "verilog"; } 
        else
          {$rtl_type = "vhdl"; } 


     if ( $mod_name  eq "" ) { return ; }

      ## Check for pre-existance. If no, generate new file with substitutes
     if ( ( $file_name ne $slog_file ) && ( -e $file_name ) ) 
       {
        $perl_line = __LINE__; 
         dialog_box(2, "ERROR $perl_line:$bell#$file_name Already Exists! Aborting Generation");
         return ;
       }
     else
     {

       $instantiate_child = dialog_box(-1,
         "InstantiateChild:#                                            ".
         "# Would you like your new block to instantiate ". $select_file . " ?".
         "# (y/n) :". 
         "");
        clear_screen();

        # Figure out the module name
        if ( ($instantiate_child == ord ("y") ) )
          {
            $child_mod = hierarchy_solver( "#"     , $select_file, 0 ,-1 );
          }

       $this_is_vhdl = 0;
       $this_is_verilog = 0 ;
       if    ( substr($file_name ,-4,4) eq ".vhd") { $this_is_vhdl    = 1 ; }
       elsif ( substr($file_name ,-2,2) eq ".v")   { $this_is_verilog = 1 ; }
       else                                        { $this_is_vhdl    = 1 ; }

       $rts[0] = "anything";
       $net_width = "32   ";
       $net_dir   = "inout";
       @port_list = ();
       while ( $rts[0] ne "" )
        {
         $rts = dialog_box(-4,
           "Generate_Child:#                                              ".
           "# OK. Now list your nets. Press <ENTER> on Name to get out.   ".
           "#     Nulls for Width and Direction will repeat last type.    ".
           "# Net Name      (ie data_bus    )        :".
           "# Net Width     (ie 32          ) $net_width  :". 
             "# Net Direction (ie in,out,inout) $net_dir  :". 
           "");
          $net_name = $rts[0];
          if ( $rts[1] ne "" ) { $net_width = $rts[1] ; } 
          if ( $rts[2] ne "" ) { $net_dir   = $rts[2] ; } 
          $net_width =  pack "A6" , $net_width;  # For Pretty Formatting.
          $net_dir   =  pack "A6" , $net_dir;    # For Pretty Formatting.
          if ( $net_name ne "" )
           { push @port_list , ($net_name . ":" . $net_width . ":" . $net_dir) ;}
        }
        
        ## Read in the Template 
        open( input_file , "<" . $0 );  # This is me, ChipVault cv.pl
        $i = 0;
        while ( $_ = <input_file> ) 
        { 
          if ( ($this_is_vhdl == 1 ) && (m/\A#T/o) )
           {
            ( $_ =~ s/\A#T//go ); # Replace ALL '#T' with null
            chomp $_; # Remove CR;
            $new_lines[ $i++] = $_ ;
           }
          elsif ( ($this_is_verilog == 1 ) && (m/\A#V/o) )
           {
            ( $_ =~ s/\A#V//go ); # Replace ALL '#V' with null
            chomp $_; # Remove CR;
            $new_lines[ $i++] = $_ ;
           }
        }# while ( $_ = <input_file> ) 
        close input_file;

           open( output_file , ">" . $file_name  ); 
           $my_time = localtime(time); # Create timestamp .
           foreach $_ ( @new_lines )
             {
               ( $_ =~ s/#COMPANY_NAME#/$company_name/go ); # Fill in 
               ( $_ =~ s/#AUTHOR#/$my_name/go );          # Fill in blanks
               ( $_ =~ s/#FILENAME#/$file_name/go );      # Fill in blanks
               ( $_ =~ s/#DATE#/$my_time/go );            # Fill in blanks
               ( $_ =~ s/#MOD_NAME#/$mod_name/go );       # Fill in blanks
               ( $_ =~ s/#ARCH_TYPE#/$arch_type/go );     # Fill in blanks
               ( $_ =~ s/#DESCRIPTION#/$description/go ); # Fill in blanks
               ( $_ =~ s/#CHILD_NAME#/$child_mod/go );    # Fill in blanks

               if ( ($_ =~ m/#CHILD_LINE#/go) )
                 {
                  if ( ($instantiate_child == ord ("y") ) )
                   {
                    ( $_ =~ s/--#CHILD_LINE#//go ); # Strip Locators 
                   }
                  else
                   {
                    $_ = ""; # Strip Line
                   }
                 }# if ( ($_ =~ m/#CHILD_LINE#/go) )


               if ( ($_ =~ m/#LOCATION_/go) ) 
                {
                 if ( ($instantiate_child == ord ("y") ) )
                  {
                   if ( ($_ =~ m/INSTANTIATE_CHILDREN_LOCATION#/go) ) 
                    {
                     $mode = "map";
                    }
                   elsif ( ($_ =~ m/PORT_DECLARATION_LOCATION#/go) ) 
                    {
                     $mode = "port";
                    }
                   elsif (($_ =~ m/CHILDREN_COMPONENT_DECLARATION_LOCATION#/go))
                    {
                     $mode = "port";
                    }
                   elsif ( ($_ =~ m/SIGNAL_DECLARATION_LOCATION#/go) )
                    {
                     $mode = "signal";
                    }
                   else
                    {
                       $perl_line = __LINE__; 
                       dialog_box(-1 , "FATAL_ERROR $perl_line: VHDL/VERILOG Template $_".
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
                       exit(-15);
                    }
                    # dialog_box(-1, "$select_file $mode");
                    # Call port_map() with port,map or signal options
                    my @rts;
                    undef @rts;
                     if ( ($rtl_type eq "verilog" ) && ($mode eq "signal") )
                      {
                       @rts = port_map( $select_file, "port");
                       # Since Verilog needs directions for signal declares
                       # and port_map returns VHDL, call port_map with "port"
                       # option in order to get signal directions for Verilog
                      }
                     else
                      {
                       @rts = port_map( $select_file, $mode );
                      }

                    foreach $line ( @rts )
                     {
		       if ( $en_trace == 1 ){print trace_file "port_map rts : $line\n";}

                      # This is a Hack for Verilog Support using VHDL port_map()
                      # port_map returns  (VHDL)
                      # u_foo : foo
                      #  port map
                      #  (
                      #    data_in => data_in,
                      #  ); -- foo
                      #
                      # if this is going into a Verilog File, Modify format to
                      # foo u_foo 
                      #  (
                      #    .data_in( data_in ),
                      #  ); -- foo

                      if ( ($rtl_type eq "verilog" ) && ($mode eq "map") )
                       {
                        if (substr($line,0,2) eq "--") 
                         {
                          $line = "// " . substr($line,3);# Convert VHDL Comment
                         }
                        ($F1, $F2, $F3,$ETC ) = split (' ', $line , 4); 
                        if ( $F2 eq "=>" )
                         {
                          chop $F3; # Remove ,
                          # $line = "   .$F1( $F3 ),";
                          $line = "    " . pack "A35", ".$F1(";
                          $line = $line . pack "A35", $F3 ;
                          $line = $line . "),";
                         }
                        elsif ( $F2 eq ":" )
                         {
                          $line = "$F3 $F1";# Convert "u_foo : foo" to "foo u_foo"
                         }
                        elsif ( $F1 eq "port" )
                         {
                          $line = ""; # Swallow "port map"
                         }
                        elsif ( $F1 eq ");" )
                         {
                          $line = "); // $F3 "; 
                         }
                        else
                         {
                          $line = $line;
                         }
                       }# if ( ($rtl_type eq "verilog" ) && ($mode eq "map") )

                       # Now Morph Component Declration from VHDL:
                       #     data_in : in std_logic_vector ( 8 downto 0 );
                       # To Verilog:
                       #     data_in, 
                      if ( ($rtl_type eq "verilog" ) && ($mode eq "port") )
                       {
                        ($F1, $F2, $F3,$ETC ) = split (' ', $line , 4); 
                        $line = "        $F1,";
                       }
                      
                      if ( ($rtl_type eq "verilog" ) && ($mode eq "signal") )
                       {
                        # Solve for: foo : out std_logic_vector( 31 downto 0 );
                        #             1  2  3         4          5    6    7 8 
                        ($F1,$F2,$F3,$F4,$F5,$F6,$F7,$ETC )=split(' ',$line,8); 
                        if    ( $F3 eq "out" ) { $dir = "output"; }
                        elsif ( $F3 eq "in"  ) { $dir = "input";  }
                        else                   { $dir = "TBD";    }
                        if ( $F6 eq "downto" )
                          {
                           $line =          pack "A8" , "$dir"; 
                           $line =  $line . pack "A8" , "[$F5:$F7]";
                           $line =  $line .             "$F1";
                          }
                        else
                          {
                           $line =          pack "A8" , "$dir"; 
                           $line =  $line . pack "A8" , "         ";
                           $line =  $line .             "$F1";
                          }
                       }#if (($rtl_type eq "verilog") && ($mode eq "signal") )

                      $out_line = $line . "\n";
                      print output_file $out_line;

                     }# foreach $line ( @rts )
                     $mode = "";

                  }# if ( ($instantiate_child == ord ("y") ) )
                 else
                  {
                    $_ = ""; # Strip Line
                  }# if ( ($instantiate_child == ord ("y") ) )

                }#if ( ($_ =~ m/#LOCATION_/go) ) 

               elsif ( $_ =~ m/#SIG_/go ) # Look for Signal Stuff
                { 
                 foreach $net_info ( @port_list )
                  {
                   ($F1, $F2, $F3 ) = split (':', $net_info, 3); 
                   if ( $F1 ne "" )
                    {
                     # dialog_box(5,"#$net_info#$F1#$F2#$F3");
                     $sig_line = $_; # Dont touch the org
                      $F1 =  pack "A28" , $F1 ;    # For Pretty Formatting.
                     ( $sig_line =~ s/#SIG_NAME#/$F1/g ); # Fill in blanks
                     ( $sig_line =~ s/#SIG_DIR#/$F3/g ); # Fill in blanks
                     if ( $this_is_vhdl == 1 )
                     {
                      if ( $F2 > 1 ) 
                        { $sig_width = "std_logic_vector ( ". ($F2-1) . " downto 0 )"; }
                      else 
                        { $sig_width = "std_logic"; }
                     }
                     elsif ( $this_is_verilog == 1 )
                     {
                      if ( $F2 > 1 ) 
                        { $sig_width = "[". ($F2-1) . ":0]"; }
                      else
                        { $sig_width = ""; }
                     }# if ( $this_is_vhdl == 1 )

                      ( $sig_line =~ s/#SIG_WIDTH#/$sig_width/g ); # Fill in blanks
                      $out_line = $sig_line . "\n";
                      print output_file $out_line;
                    }# if ( $F1 ne "" )
                  }# foreach $net_info ( @port_list )
                }# if ( $_ =~ m/#SIG_#/go ) # Look for Signal Stuff
               else
                {
                 $out_line = $_ . "\n";
                 print output_file $out_line;
                }
             }          
           close output_file;
          }
  return ( $mod_name . " " . $file_name );
}# sub generate_rtl


#################################################################
# This function reads a report and generates a result to be displayed
# inplace of the filename of the report
#################################################################
sub report_analysis { 
 my( $filename, $report_func ) = @_;
 my $results = "";
  if ( $en_trace == 1 ){print trace_file "report_analysis()\n";}

 if ( $report_analysis_cache{"$filename $report_func"} ne "" )
  {
   # Analysis can take a while, so only do it once, then cache 
   # the results
   return $report_analysis_cache{"$filename $report_func"} ;
  }

 if ( -e $filename )
  {
   open( input_file , "<" . $filename );
   while ( $_ = <input_file> )
   {
     chomp $_;
     ($F1, $F2, $F3, $F4, $F5, $ETC ) = split (' ', $_ , 6); #Parse

     # KMH 03.28.2013 Mistake to open each file, so abort here for speed.
     close input_file; # Worst is 1st. Ignore the rest.

    if ( $report_func eq "gate_estimate" )
     {
      # Parse for "Total cell area:          186840.000"
      if ( $F1 eq "Total"    &&
           $F2 eq "cell"     &&
           $F3 eq "area:" 
         )
       {
        # $gates_per_cell_area = 40;
        $results = int( $F4 / $gates_per_cell_area ) ; # Crude Area Estimate
        if ( $results > 1000 ) 
         { 
          $results = int( $results / 1000 );
          $results = $results . "K";
         }# if ( $results > 1000 ) 
       }
     }# if ( $report_func eq "gate_estimate" )
    elsif ( $report_func eq "flop_count" )
     {
      # Parse for "push_reg : FD1AL port map(" in a Synopsys VHDL Netlist
      if ( $F2 eq ":"    &&
           $F4 eq "port"     
         )
       {
        # My Flip-Flop names always start with FD or FH
        if ( substr($F3,0,2) eq "FD" ||
             substr($F3,0,2) eq "FH"     )
         {
          $results++;
         }
       }
      }# elsif ( $report_func eq "flop_count" )
    elsif ( $report_func eq "worst_slack" )
     {
      # Parse for "slack (MET)  2593.96"
      if ( $F1 eq "slack"    &&
           $F2 eq "(MET)"    
         )
       {
        $results = int( $F3 ) . " pS"; 
        close input_file; # Worst is 1st. Ignore the rest.
       }
     }# if ( $report_func eq "gate_estimate" )
    elsif ( $report_func eq "time_stamp" )
     {
      if ( $os eq "unix" )
       {
        # Note: stat returns: dev,ino,mode,nlink,uid,gid,rdev, size,atime,mtime,
        $results = localtime( ( stat $filename  ) [ 9 ] ) ; # Get Modify Time
         ($F1, $F2, $F3, $F4, $ETC ) = split (' ', $results ,5) ; #Parse
        $my_time = localtime(time); # Now
         ($W1, $W2, $W3, $W4, $ETC ) = split (' ', $my_time ,5) ; #Parse
         # See if file was modified today
         if ( "$F2 $F3" eq "$W2 $W3" )
           {
            $results = "$F4"; # 04:53:32    Display Time
           }
         else
           {
            $results = "$F2 $F3"; # Jan 22  Display Day
           }
       }
      else
       {
        $results = "Win32ick"; # Although this function works on Windows, it
        # is incredibly slow. stat calls on win32 takes seconds to complete.
       }
     }#  elsif ( $report_func eq "time_stamp" )

   } # while
   close input_file;
  }# if ( -e $filename )
  $report_analysis_cache{"$filename $report_func"} = $results;
  return $results ;
}# sub report_analysis { 




#################################################################
# archive( $file_name ) : Create TAR Ball of a file. Unique
# filename is created via current time.
# ie
#   2 Calls to archive( foo.vhd ) will create:
# .archive.foo.vhd.tar.gz which contains
#    foo.vhd.Wed__Oct__10__10_20_51__2001
#    foo.vhd.Wed__Oct__12__11_23_21__2001
# Note: I decided to tar then gzip as this has the optimal 
#       Compression ratio. This disadvantage to this is that the
#       decompressed can be very large and must be gunzip'd then
#       Rezipped each time. This could become very long if a 
#       file is archived 100times. I'll try this for now.
#  Disks space is cheap, so maybe gzipping can just be disabled.
################################################################
sub archive {
  my( $filename ) = @_;
  if ( $en_trace == 1 ){print trace_file "archive()\n";}
  $tar_ball_name = solve_path($filename) . $tar_header . 
                   solve_file($filename) . ".tar" ; 


  # Create a copy of the file with date_time footer to it
     $my_time = localtime(time); # Create a unique name via time
     ( $my_time =~ s/ /__/go ); # Remove All ' ' with '__'
     ( $my_time =~ s/:/_/go ); # Remove All ':' with '_'

    $tobe_tard_filename = $filename . "." . $my_time ;
    $cmd = $cp_cmd . "$filename $tobe_tard_filename" ;
    @run_shell     = solve_slash("$cmd");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
    if ( $rc != 0 )
      {
        $perl_line = __LINE__; 
        dialog_box(-1, "ERROR $perl_line:$bell# Copy Failed : $cmd ". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
        exit  (10 );
      }

  # If TAR-Ball already exists, decompress it and append.
    if ( ( -e ( $tar_ball_name )) || ( -e ( $tar_ball_name . ".gz")) )
   {
    if ( -e ( $tar_ball_name . ".gz" ) ) # Check for File Existance
      {
       if ( $unix_gzip_en == 1 ) 
        {
         @run_shell     = solve_slash("$gunzip_cmd $tar_ball_name");
         if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
         $rc = 0xffff & system (@run_shell);
         if ( $rc != 0 )
          {
            $perl_line = __LINE__; 
            dialog_box(-1, "ERROR $perl_line:$bell# gunzip Failed : $cmd ". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
            exit  (10 );
          }
        }#if ( $unix_gzip_en == 1 ) 
       else
        {
         $perl_line = __LINE__; 
         dialog_box(-1, "ERROR $perl_line:$bell# GUNZIP not enabled!".
                    "# Your tar archive has been GZIPd but the variable ".
                    "# unix_gzip_en is not set. Usually this occurs when ".
                    "# using both UNIX and Win32 versions of ChipVault on ".
                    "# a design. ".
                    "# The workaround is to either install GZIP on Win32   ".
                    "# platform, or to disable GZIPping on UNIX for CV.  ".
                    "# Recommendation. From UNIX type:                   ".
                    "#   gunzip .arch*.gz                                ".
                    "# which will decompress your archives so that Win32 ".
                    "# can read them going forward.                      ".
                    "# Then modify cv.pl to disable unix_gzip_en variable".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit  (10 );
        }# if ( $unix_gzip_en == 1 ) 
      }# if ( -e ( $tar_ball_name . ".gz" ) ) # Check for File Existance
      $cmd = "tar -rvf " ; # Append to existing TAR file
     }# if ( ( -e ( $tar_ball_name )) || ( -e ( $tar_ball_name . ".gz")) )
    else
     {
      $cmd = "tar -cvf " ; # Create new TAR file
     } # If TAR-Ball already exists, decompress it.

   # Execute TAR (Create or Append)
     $cmd = $cmd . "$tar_ball_name ";    # Append to Existing TAR file
     $cmd = $cmd . " " . $tobe_tard_filename ; 
     $cmd = solve_slash($cmd);
     if ( $unix_tar_en == 1 ) 
      {
        @run_shell     = solve_slash("$cmd");
      }
     else
      {
        ($null,$option,$tarfile_name,$clearfile_name,$ETC)=split(' ',$cmd,5);
        @rts = tar_sub ( $option, $tarfile_name, $clearfile_name );
      }# if ( $unix_tar_en == 1 ) 

     if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
     $rc = 0xffff & system (@run_shell);

   # Generate a list of everything in the TAR-BALL
   $cmd = "tar -tf " . $tar_ball_name ;
   $cmd = $cmd . " > " . solve_path($filename) . $tar_list_header . 
                         solve_file($filename) . $tar_list_footer;
   $cmd = solve_slash($cmd);
     if ( $unix_tar_en == 1 ) 
      {
        @run_shell     = solve_slash("$cmd");
      }
     else
      {
        ($null,$option,$tarfile_name,$ETC)=split(' ',$cmd,4);
        @rts = tar_sub ( $option, $tarfile_name, "null" );
        open( output_file, ">" . solve_path($filename) . $tar_list_header . 
                                 solve_file($filename) . $tar_list_footer );
        foreach $_ ( @rts ) 
         {
          print output_file $_ . "\n";
         }
        close output_file;

      }# if ( $unix_tar_en == 1 ) 
   if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
   $rc = 0xffff & system (@run_shell);
# Note: Solaris and Linux cant agree on this (they fail), so just ignore error

  if ( $unix_gzip_en == 1 ) 
   {
    # Now GZIP the tar-ball back up. 
    @run_shell     = solve_slash("$gzip_cmd $tar_ball_name");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
     if ( $rc != 0 )
       {
         $perl_line = __LINE__; 
         dialog_box(-1, "ERROR $perl_line:$bell# Gzip Failed : $cmd ".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit  (10 );
       }
   }# if ( $unix_gzip_en == 1 ) 

  # Now Delete the VHDL file that was TARd           
    $cmd = $rm_cmd;
    @run_shell     = solve_slash("$cmd $tobe_tard_filename ");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
    if ( $rc != 0 )
      {
        $perl_line = __LINE__; 
        dialog_box(-1,"ERROR $perl_line:$bell# Unable to Delete: $cmd !". 
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
        exit  (10 );
      }
}# sub archive


#################################################################
# archive_restore( $file_name ) : Extract a singe file from an 
# archive and force it to become the current wip file.
################################################################
sub archive_restore {
  my( $filename , $wip_filename ) = @_;
  my @str_array;
  if ( $en_trace == 1 ){print trace_file "archive_restore()\n";}

  $tar_ball_name = solve_path($filename) . $tar_header . 
                   solve_file($filename) . ".tar" ; 

  # If TAR-Ball already exists, decompress it and append.
    if ( ( -e ( $tar_ball_name )) || ( -e ( $tar_ball_name . ".gz")) )
   {
    if ( -e ( $tar_ball_name . ".gz" ) ) # Check for File Existance
      {
       if ( $unix_gzip_en == 1 ) 
        {
         @run_shell     = solve_slash("$gunzip_cmd $tar_ball_name");
         if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
         $rc = 0xffff & system (@run_shell);
         if ( $rc != 0 )
          {
            $perl_line = __LINE__; 
            dialog_box(-1, "ERROR $perl_line:$bell# gunzip Failed : $cmd ". 
                      "# ChipVault will now Terminate this fatal condition.".
                      "# <Press Any Key> " );
            exit  (10 );
          }
        }#if ( $unix_gzip_en == 1 ) 
       else
        {
         $perl_line = __LINE__; 
         dialog_box(-1, "ERROR $perl_line:$bell# GUNZIP not enabled!".
                    "# Your tar archive has been GZIPd but the variable ".
                    "# unix_gzip_en is not set. Usually this occurs when ".
                    "# using both UNIX and Win32 versions of ChipVault on ".
                    "# a design. ".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit  (10 );
        }# if ( $unix_gzip_en == 1 ) 
      }# if ( -e ( $tar_ball_name . ".gz" ) ) # Check for File Existance
    }# if ( ( -e ( $tar_ball_name )) || ( -e ( $tar_ball_name . ".gz")) )

      $list_file =  solve_path($filename) . $tar_list_header . 
                    solve_file($filename) . $tar_list_footer;

      # Generate a Select Scroll Bar to determine which file to decompress
      push @str_array, "[ Scroll to Desired File and press <ENTER> ]";
      open( input_file , "<" . $list_file );
      while ( $_ = <input_file> )
       {
        chomp $_;
        push @str_array, $_;
       } # while ( $_ = <input_file )
      close input_file;
      ($key_val, $line ) = scroll_box(0, ($maxx-4), @str_array );
    if ( $key_val == $k_cr )
    {
      $line++; # Needed offset

      $cmd = solve_slash("tar -xvf ". $tar_ball_name ." ". @str_array[$line]);

      # Execute TAR (Create or Append)
      if ( $unix_tar_en == 1 ) 
      {
        @run_shell     = solve_slash("$cmd");
        $rc = 0xffff & system (@run_shell);
        $perl_line = __LINE__; 
        if ( $rc != 0 ) {dialog_box(-1,"ERROR $perl_line:$bell# TAR Failed!");exit(10);}
      }
     else
      {
        ($null,$option,$tarfile_name,$clearfile_name,$ETC)=split(' ',$cmd,5);
        @rts = tar_sub ( $option, $tarfile_name, $clearfile_name );
      }# if ( $unix_tar_en == 1 ) 

     @run_shell = solve_slash("$cp_cmd ".@str_array[$line]." ".$wip_filename); 
     $rc = 0xffff & system (@run_shell);
        $perl_line = __LINE__; 
     if ( $rc != 0 ) {dialog_box(-1,"ERROR $perl_line:$bell# Copy Failed!");exit(10);}

     @run_shell = solve_slash("$rm_cmd " .  @str_array[$line] );
     $rc = 0xffff & system (@run_shell);
        $perl_line = __LINE__; 
     if ( $rc != 0 ) {dialog_box(-1,"ERROR $perl_line:$bell# Delete Failed!");exit(10);}
    }# if ( $key_val == $k_cr )
   else
   {
     dialog_box(1,"ABORTED:# <ENTER> not pressed");
   }# if ( $key_val == $k_cr )

  if ( $unix_gzip_en == 1 ) 
   {
    # Now GZIP the tar-ball back up. 
    @run_shell     = solve_slash("$gzip_cmd $tar_ball_name");
    if ( $en_trace == 1 ){print trace_file "system(@run_shell)\n";}
    $rc = 0xffff & system (@run_shell);
     if ( $rc != 0 )
       {
        $perl_line = __LINE__; 
         dialog_box(-1, "ERROR $perl_line:$bell# Gzip Failed : $cmd ".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit  (10 );
       }
   }# if ( $unix_gzip_en == 1 ) 

}# sub archive_restore

sub port_solver {
 ($file_name, $mod_name ) = @_;
  my %verilog_port_hash = () ; # Erase Hash
  if ( $en_trace == 1 ){print trace_file "port_solver( $file_name )\n";}

  # Support for "MyLabel" in hlist with descriptions in comments.txt file
  # comments.txt file look like this:
  # "Foo"
  #  foo does the following.
  # "Bar"
  #  and bar does this...
# $_ = $file_name;
  $_ = $mod_name;
  if ( (/"/io ) )
  {
   ($F1, $F2, $ETC ) = split ('"', $_ , 3); #Parse
   if ( $F2 ne "" ) 
   {
    $my_label = $F2; $jk = 0;
    if ( $en_trace == 1 ){print trace_file "my_label is $my_label\n"; }
    open( input_file , "<" . $file_name     );
    my @rts_str = () ; # Erase Array 
    while ( $_ = <input_file> )
    {
     chomp $_;
     ($F1, $F2, $ETC ) = split ('"', $_ , 3); #Parse
     if ( $F2 ne $my_label && $F2 ne "" && $jk == 1 ) 
      { 
       close input_file;
      }
     elsif ( $F2 eq $my_label || $jk == 1 )             
      {
       $jk = 1; 
       push @rts_str, $_;
      }
    }
    if ( $jk == 1 )
    {
      return @rts_str;
    }
   }
  }


 open( input_file , "<" . $file_name );
  my @rts_str = () ; # Erase Array 
  my $i;
  my $y;
 $left_cnt = 0;
 $right_cnt = 0;
 undef @left_str;
 undef @right_str; 
 undef @rts_str;
 $this_is_vhdl = 0;
 $this_is_verilog = 0 ;
 $inside_wire_definition = 0;
 $inside_module_port_def = 0;
 $start_grabbing_port_names = 0;
 $dir = "";
 
  if ( substr($file_name,-4,4) eq ".vhd") { $this_is_vhdl = 1 ; }
  elsif ( substr($file_name,-2,2) eq ".v") { $this_is_verilog = 1 ; }
  else { return ; }

 while ( $_ = <input_file> )
 {
  chomp $_;
  $line = $_;
  if ( $this_is_verilog == 1) 
   {
    # Replace "put[" with "put [", in input[7:0] becomes input [7:0]
    ( $_  =~ s/put\[/put \[/go ); 
    # Remove the '//' delimiter and all comments after	
    ( $_ =~ s/\/\/.*$//o);
    # Remove the '/*' delimiter and all comments after	
    ( $_ =~ s/\/\*.*$//o);
   }

# REMOVED 06.08.06 ( $_    =~ s/\:/ \: /go ); # Replace ':' with ' : ' for 
  ($F1, $F2, $F3, $F4, $F5, $ETC ) = split (' ', $_ , 6); #Parse

  if ( ($this_is_vhdl == 1) && (substr($F1,0,2) ne "--") )
   {
     if ( lc ( $F1 ) eq "end" ) { close input_file ; }
     # Bug: The following line will not only accept the 'port' definitions
     #      but also the entity's 'generic' definitions.
     if ($line =~ /\:\s*(in|out|inout|buffer)\s/oi) 
      { 
       # The first port may be on the same line as the port definition construct
       # Or the construct may be split between this line and the one above
       ($line =~ s/^\s*(port\s+|)\(//oi);

       # Trim whitespace at beginning of line
       ($line =~ s/^\s*//o);

       # Remove the ';' delimiter and all comments after	
       ($line =~ s/;.*$//o);

       # Parse out the net(s)
       ($nets, $etc) = split(':', $line, 2);
       ($nets =~ s/,/ /go);
       @nets = split(' ', $nets);

       # Parse out the pin direction
       ($dir, $etc) = split(' ',  $etc, 2);
        $dir = lc($dir);

       # Look for willsie array type of "array_8x8"
       if ( substr(lc($etc),0,6) eq "array_" )
       {
        ($bit_info, $etc) = split(' ',  $etc, 2);
        $bit_info = "(" . substr($bit_info,6,,) . ")"; # ie "(8x8)"
       }
      else
      {
      # Assuming std_logic_vector or just std_logic then
      # Get the bit info (if exists)
      $bit_info = "";
      if ($etc =~ /\(.*\)/o)
       {
        ($vector, $pin_range, $etc) = split('[\(\)]', $etc, 3);
        ($bits_top, $etc, $bits_bot, $ETC ) = split(' ', $pin_range, 4);
        $bit_info = "(" . $bits_top . ":" . $bits_bot . ")"; # ie "(7:0)"
       }
      }
       

      foreach $net (@nets) 
      {
       # If _n of a _p,_n diff pair, don't display the _n, only display _p.
       if ( substr( $net, 0, -2 ) eq substr( $net_last, 0, -2 ) &&
            substr( $net, -2, 2 ) eq "_n"                           )
       {
       }
      else
      {
       $net_full = lc($net) . $bit_info;
       if ( $dir eq "in" ) 
        {
         $left_pack = 28;
         @left_str[$left_cnt] = $net_full;
         @left_str[$left_cnt] = pack "A$left_pack", @left_str[ $left_cnt];
         @left_str[$left_cnt] = @left_str[$left_cnt] . "->";
         ( @left_str[$left_cnt] =~ s/ /-/go ); # Replace ' ' with '-'
         $left_cnt++;
        } 
       elsif ( ( $dir eq "out" ) || ( $dir eq "buffer" ) ) 
       {
        @right_str[$right_cnt] = "--->" . $net_full;
        $right_cnt++;
       } 
       elsif ( $dir eq "inout" ) 
       {
        @right_str[$right_cnt] = "<-->" . $net_full;
        $right_cnt++;
       }
      } # if substr
      $net_last = $net;
     } # foreach
   } # if line is a port-definition line
 } # if vhdl
# elsif ( ( $this_is_verilog )  == 1 && (substr($F1,0,2) ne "//") )
elsif ( ( $this_is_verilog )  == 1 && (substr($F1,0,2) ne "//") 
                                   && (substr($F1,0,2) ne "--") 
      )
{
      if ( lc ( $F1 ) eq "endmodule" ) { close input_file ; }
      if ( lc ( $F1 ) eq "always" )    { close input_file ; } # New 05.31.06
      if ( lc ( $F1 ) eq "reg"    )    { close input_file ; } # New 04.20.11
      if ( lc ( $F1 ) eq "module" ) { $inside_module_port_def = 1 ; }
      if ( lc ( $F1 ) eq "input" )  { $dir = lc ( $F1 ); } 
      if ( lc ( $F1 ) eq "output" ) { $dir = lc ( $F1 ); } 
      if ( lc ( $F1 ) eq "wire" )   { $dir = lc ( $F1 ); } 

      $ETC = $_;
      ( $ETC =~ s/,/ /go ); # Toss all commas.
      ( $ETC =~ s/\(/ \( /go ); # Change '(' to ' ( ' for word parsing.
      ( $ETC =~ s/\;/ \; /go ); # Change ';' to ' ; ' for word parsing.
      ( $ETC =~ s/\)//go ); # Change ')' to '' for word parsing.
      # Verilog-2001 supports "input wire [1:0] net" so remove wire and reg
      ($F1, $F2, $foo ) = split (' ', $ETC , 3);  
      if ( ( lc( $F2 ) eq "wire" ) || ( lc( $F2 ) eq "reg" ) )
      {
       $ETC = $F1 . " ". $foo; # Remove 2nd word as its wire or reg
      }

      while ( ($F1, $ETC ) = split (' ', $ETC , 2) ) 
       {
          if ( ( $inside_module_port_def == 1 ) &&
               ( $F1 eq "(" )                     ) 
            {
             $start_grabbing_port_names = 1;
            }
          elsif ( $start_grabbing_port_names == 1 )
            {
             $verilog_port_hash{ $F1 } = "missing_entry";
            }

          if ( (lc ( $F1 ) eq "input"  ) ||
               (lc ( $F1 ) eq "output" ) ||
               (lc ( $F1 ) eq "wire"   )    )
           {
            $inside_wire_definition = 1;
            $bits_top = 0;  
            $bits_bot = 0;
           }
          elsif ( ($F1 =~ m/\;/go ) )
           {
            $inside_wire_definition = 0;
            $inside_module_port_def = 0;
            $start_grabbing_port_names = 0;
            $dir = "";
           }
          elsif ( $inside_wire_definition == 1 )
           {
             # print "Inside Wire Definition \n";
            if ( ($F1 =~ m/\:/go ) )
             {
              ( $F1 =~ s/\[//go ); # Remove All the [ and replace with nul
              ( $F1 =~ s/\]//go ); # Remove All the [ and replace with nul
              ( $F1 =~ s/\:/ /go ); # Remove All the : and replace with space
              ($a1, $a2, $a3, $a4, $a5, $a6, $a_ETC ) = split (' ', $F1 , 7);
                $bits_top = $a1;
                $bits_bot = $a2;
             }
            else
             {
              $net = $F1;
              if ( ($bits_top + $bits_bot) > 0 )
                {
                  $net = $net . "(" . $bits_top . ":" . $bits_bot . ")";
                 }
              
             if ( $verilog_port_hash{ $F1 } ne "" )
             {

              if ( $dir eq "input" || $dir eq "output" || $dir eq "wire" )
                {
                 if ( $dir eq "input" )
                   {
                    $left_pack = 28;
                    @left_str[$left_cnt] = $net;
                    @left_str[$left_cnt] = pack "A$left_pack", @left_str[ $left_cnt];
                    @left_str[$left_cnt] = @left_str[$left_cnt] . "->";
                    ( @left_str[$left_cnt] =~ s/ /-/go ); # Replace ' ' with '-'
                    $left_cnt++;
                    }
                elsif ( $dir eq "output" )
                 {
                  @right_str[$right_cnt] = "--->" . $net;
                  $right_cnt++;
                 }
                elsif ( $dir eq "wire" )
                 {
                  @right_str[$right_cnt] = "<-->" . $net;
                  $right_cnt++;
                 }
                else
                 {
                   my_print(" $dir is confusing!   |////");
                 }# if ( $dir eq "in" )
                }# if ( $dir eq "in" || $dir eq "out" || $dir eq "inout" )
             }# if ( $verilog_port_hash{ $F1 } ne "" )

              }# if ( ($F1 =~ m/\:/go ) )
           }#elsif ( $inside_wire_definition == 1 )
         } # while ( word loop )
      } # Verilog
     } # while ( line loop )



     if ( $right_cnt > $left_cnt )
        { $y = $right_cnt ; }
      else 
        { $y = $left_cnt ; } # Take the longest of the 2 sides

# Now make a box of things. Inputs on the left, outs on the Right
   $new_line = "";
   $new_line = pack "A$left_pack", $new_line;

   my $lcnt = 0;

   @rts_str[$lcnt++] = $new_line .  "    " .$file_name ;
   @rts_str[$lcnt++] = $new_line . "   ________________ ";


 for ( $i = 0 ; $i < $y ; $i++ )
  {
     if ( ( $right_cnt > $left_cnt ) && ( $i >= $left_cnt ))
      {
       @left_str[ $i ] = "  " . $new_line;
      }
   
   @rts_str[$lcnt++] = @left_str[$i] ."|                |". @right_str[$i] ;
  }
   @rts_str[$lcnt++] = $new_line . "   ---------------- ";

return @rts_str;

}# sub port_solver


################################################################
# rtl_analyzer() : Calculate number of flops, pins, etc of a module
################################################################
#  $power_flop_cap        = 0.07; # pF
#  $power_voltage         = 1.8;  # Volts
#  $power_freq            = 100;  # MHz
#  $power_activity        = 0.2;  # Toggle Rate
#  $power_clk_ratio       = 0.2;  # Clock Tree Power Relative to Flop Power
#  $power_combo_ratio     = 2.0;  # Combo Power Relative to Flop Power
#  $gate_density          = 40000;# Routed Gates per mm^2
#
#$file_name    = $ARGV[0]; 
#@rts = rtl_analyzer ( $file_name );
#foreach $line ( @rts )
# {
#  print $line . "\n";
# }
#exit;
sub rtl_analyzer {
 ($file_name ) = @_;

 open( input_file , "<" . $file_name );
  my @rts_str   = () ; # Erase Array 
  my @hash_list = () ; # Erase Array 
  my $i;
  my $y;

 $this_is_vhdl = 0;
 $this_is_verilog = 0 ;
 
  if ( substr($file_name,-4,4) eq ".vhd") { $this_is_vhdl = 1 ; }
  if ( substr($file_name,-2,2) eq ".v") { $this_is_verilog = 1 ; }

  $module_name = "";
  $flop_cnt = 0;
  $line_cnt = 0;
  $in_cnt   = 0;
  $out_cnt  = 0;
  $io_cnt   = 0;
  $inside_proc = 0;
  $inside_ent  = 0;
  $clkd_proc   = 0;

 while ( $_ = <input_file> )
   {
     chomp $_;
    ( $_ =~ s/\(/ \( /go ); # Change '(' to ' ( ' for word parsing.
    ( $_ =~ s/\)/ \) /go ); # Change ')' to ' ) ' for word parsing.
    ( $_ =~ s/\[/ \[ /go ); # Change '[' to ' [ ' for word parsing.
    ( $_ =~ s/\]/ \] /go ); # Change ']' to ' ] ' for word parsing.
    ( $_ =~ s/\'/ \' /go ); # Change ''' to ' ' ' for word parsing.
    ( $_ =~ s/\:/ \: /go ); # Change ':' to ' : ' for word parsing.
    ( $_ =~ s/\;/ \; /go ); # Change ';' to ' ; ' for word parsing.
    ( $_ =~ s/\,/ \, /go ); # Change ',' to ' , ' for word parsing.
     ($key, $ETC1 ) = split (' ', $_ , 2); #Parse to look for reg
     $key = lc( $key );
     ($F1,$F2,$F3,$F4,$F5, $ETC2 ) = split (' ', $ETC1, 6); 
     if ( ( $this_is_vhdl )  == 1 && (substr($_,0,2) ne "--") )
     {
      $line_cnt++;
      if ( $key eq "entity" )    { $module_name = $F1; $inside_ent = 1;}
      if ( $key eq "end"    )    {                     $inside_ent = 0;}
      if ( $key eq "process" || lc ( $F2) eq "process" )
      {
       $inside_proc = 1;# print "Inside Process\n";
       $clkd_proc   = 0;
      }
      if ( $key eq "end" && lc ( $F1) eq "process" )
      {
       $inside_proc = 1;# print "Outside Process\n";
      }
      if ( $inside_ent == 1 )
      {
       # c_out, bar  : out    std_logic_vector(7 downto 0)
       ($net_names,$net_type,$ETC2 ) = split (':', $_, 3); 
       ($F1,$F2,$F3,$F4,$F5,$F6,$F7,$ETC3 ) = split (' ', lc($net_type), 8); 
       if ( $F2 eq "std_logic_vector" )
       {
        $bit_size = $F4 - $F6;# ie ( 7 downto 0 ) = 8bits
        if ( $bit_size < 0 ) { $bit_size *= -1 ; }
        $bit_size++;
       }
       else { $bit_size = 1; }

       while ( ($Fa, $net_names ) = split (' ', $net_names, 2) )
       {
        if ( 
             ( $Fa ne "," ) &&
             ( $F1 eq "out" || $F1 eq "inout" || $F1 eq "in" )
           )
        {
#          print "NetName = $Fa $bit_size\n";
          if ( $F1 eq "in"    ) { $in_cnt  += $bit_size; }
          if ( $F1 eq "out"   ) { $out_cnt += $bit_size; }
          if ( $F1 eq "inout" ) { $io_cnt  += $bit_size; }
          if ( $F1 eq "out" || $F1 eq "inout" )
          {
           $hash_list{$Fa} = $bit_size; # Could be a Flop
          }
        }
       }
      }# if inside_ent

      if ( $key eq "signal" )
      {
       # foo_bar,bar_foo : std_logic_vector ( 7 downto 0 ) ;
       ($net_names,$net_type,$ETC2 ) = split (':', $ETC1, 3); 
       ($F1,$F2,$F3,$F4,$F5,$F6,$F7,$ETC3 ) = split (' ', $net_type, 8); 
       if ( lc($F1) eq "std_logic_vector" )
       {
        $bit_size = $F3 - $F5;# ie ( 7 downto 0 ) = 8bits
        if ( $bit_size < 0 ) { $bit_size *= -1 ; }
        $bit_size++;
       }
       else { $bit_size = 1; }

       while ( ($F1, $net_names ) = split (' ', $net_names, 2) )
       {
        if ( $F1 ne "," )
        {
#         print "NetName = $F1 $bit_size\n";
         $hash_list{$F1} = $bit_size;
        }
       }
      }# if signal 

      # If were inside a proc and come across the word event or rising_edge, 
      # assumed the process is clocked, otherwise assume combo 
      if ( $inside_proc == 1 )
      {
       if ( ( $_ =~ m/ event /go ) )       { $clkd_proc = 1; }
       if ( ( $_ =~ m/ rising_edge /go ) ) { $clkd_proc = 1; }
      }


      # If we're outside of a process, and one of our signal names is left of
      # a <=, then assume this signal is NOT a flop, and change its bit_size
      # to zero. Also do the same if inside a process, but we think its combo
      if ( ( $inside_proc == 0 ) || ( $clkd_proc == 0 ) )
      {
       $hash_list{$key} = 0;
      }
     }# if vhdl

     if ( ( $this_is_verilog )  == 1 && (substr($_,0,2) ne "//") )
     {
      $line_cnt++;
      if ( $key eq "endmodule" ) { close input_file ; }
      if ( $key eq "module" )    { $module_name = $F1;}
      if (
           ( $key eq "reg"    ) ||
           ( $key eq "input"  ) ||
           ( $key eq "output" ) ||
           ( $key eq "inout"  )
         )
      {
       if ( $F1 eq "[" )
       {
        $bit_size = 1 + $F2 - $F4;# ie [7:0] = 8bits
        if ( $bit_size < 0 ) { $bit_size *= -1 ; }
        $ETC3 = $ETC2; # Start with list of net names
       } 
       else
       {
        $bit_size = 1;
        $ETC3 = $ETC1; # Start with list of net names, not a bus
       }
       while ( ($F1, $ETC3 ) = split (' ', $ETC3 , 2) )
       {
        if ( ( $F1 ne "," ) && ( $F1 ne ";" ) )
        {
#          print "$F1 $bit_size\n";
          if ( $key eq "reg"      ) { $flop_cnt += $bit_size; }
          if ( $key eq "input"    ) { $in_cnt   += $bit_size; }
          if ( $key eq "output"   ) { $out_cnt  += $bit_size; }
          if ( $key eq "inout"    ) { $io_cnt   += $bit_size; }
        }
        if ( $F1 eq ";" ) { $ETC3 = ""; }
       }#while
      }# if "reg"
     }# if verilog
  }# while


 if ( $this_is_vhdl == 1 )
 {
  while ( ($key,$value) = each %hash_list )
  {
   $flop_cnt += $value;
  }
 }

  $gate_est = 20 * $flop_cnt; # Assumes 10 NANDs combo logic for every flop.

# This calculates a crude power number assuming that total power is 3x the
# flip-flop power ( ClockTree+Combo+Flop=Total ).
# $flop_cap is in pF, ie .07 pF, $freq is in MHz. Output units in mW
# $activity rate is like percentage of toggling, ie 0.2 = 20%
  $flop_power  =  ( $flop_cnt * $power_flop_cap *
                    $power_voltage * $power_voltage *
                    $power_freq / 1000 );
  $combo_power = $flop_power * $power_combo_ratio;
  $clk_power   = $flop_power * $power_clk_ratio;
                                                                                
  $power_est =  int( $clk_power +
                     $power_activity * ( $flop_power + $combo_power ) );

  $area_est = $gate_est / $gate_density;

  $pad = "";
  push @rts_str, "$pad [ RTL Analyzer Results        ] ";
  push @rts_str, "$pad -------------------------------------------------- ";
  push @rts_str, "$pad WARNING : Estimates are very crude and should ONLY ";
  push @rts_str, "$pad           be used for ballpark relative comparisons.";
  push @rts_str, "$pad -------------------------------------------------- ";
  push @rts_str, "$pad  File   Name       = " . solve_file( $file_name );
  push @rts_str, "$pad  Module Name       = $module_name";
  push @rts_str, "$pad  Line   Count      = $line_cnt";
  push @rts_str, "$pad  Input  Wire Cnt   = $in_cnt";
  push @rts_str, "$pad  Output Wire Cnt   = $out_cnt";
  push @rts_str, "$pad  InOut  Wire Cnt   = $io_cnt";
  push @rts_str, "$pad  Total  Wire Cnt   = ". ($in_cnt + $out_cnt + $io_cnt) ;
  push @rts_str, "$pad  Flop   Count      = $flop_cnt";
  push @rts_str, "$pad  Gate   CountEst   = $gate_est";
  push @rts_str, "$pad  Area   Estimate   = $area_est mm^2";
  push @rts_str, "$pad  Power  Estimate   = $power_est mW ". 
                       "( $power_voltage Volts @ $power_freq MHz )";

return @rts_str;

}# sub rtl_analyzer {





#############################################################################
# port_map( filename, mode ) : Read in a VHDL file and generate RTL which
#   instantiates the file.
#############################################################################
# $file_name    = $ARGV[0]; #IE top.vhd '#' then return 1st Module Name found
# $mode         = $ARGV[1]; # port, map or signal . null does all three.
# @rts = port_map ( $file_name, $mode );
# foreach $line ( @rts )
#  {
#   print $line . "\n";
#  }
# exit;


sub port_map {
my ($file_name, $mode ) = @_;
  if ( $en_trace == 1 ){print trace_file "port_map( $file_name, $mode )\n";}

my $port             = "port";
my $entity           = "entity";
my $port_stop        = "end\s*(.*)\s*;\n*"; # Funky LF supports DOS files
  if ( $en_trace == 1 ){print trace_file "port_map()\n";}

if ( substr($file_name ,-2,2) eq ".v" )
 {
  $this_is_verilog = 1 ;
 }

if ( $this_is_verilog == 1 )
 {
  $entity           = "module";
  $port             = "module";
  $port_stop        = ";";
 }



# Reset Flip-Flops Flags
my $flag = 0;
# Runtime assigned arrays
my $line = "";
my $F1 = ""; # Signal Name
my $F2 = ""; # :
my $ETC = ""; # Remainder of port map after parsing
my $LINE = 0;
my @rts_str = ();
my @signal_list = ();
my @signal_full_list = ();
my $signal_type_hash ;
my $signal_width_hash ;
my $flag = 0;
my $name = 0;
my $LINE = 0;
my $found_port_start = 0;


open( input_file , "<" . $file_name );


 $lcnt = 0;

# Now Open the file specified by @ARGV
while ( $_ = <input_file>) 
{
 chomp $_;
 $LINE++;

 # print "* $_";

 if ( $this_is_verilog == 1 )
 {
   #module mrisc_top(
   # clk, rst_in,
   # porta, portb, portc,
   # tcki,
   # wdt_en );

    $ETC = $_;
    ( $ETC =~ s/\(/ \( /go ); # Replace '(' with ' ( ' for parsing words
    ( $ETC =~ s/\)/ \) /go ); # Replace ')' with ' ) ' for parsing words
    ( $ETC =~ s/;/ ; /go );   # Replace ';' with ' ; ' for parsing words
    ( $ETC =~ s/,/ , /go );   # Replace ',' with ' , ' for parsing words
    ( $ETC =~ s/:/ : /go );   # Replace ':' with ' : ' for parsing words


    while ( ($F1, $ETC ) = split (' ', $ETC , 2) )
     {
       if ( $F1 eq "//") { $F1 = ""; $ETC = ""; } # Ignore Comments
       # PipeDelay of 4 words
        $F1_p5 = $F1_p4;
        $F1_p4 = $F1_p3;
        $F1_p3 = $F1_p2;
        $F1_p2 = $F1_p1;
        $F1_p1 = $F1 ;

        if ( $F1_p2 eq "module" ) 
          { 
           $name = $F1_p1;
           $flag = 1;
           #print "Found Module $name\n";
          }

        if( $flag == 1 )
          {
           if ( ($F1_p1 eq ";") ) 
             {
              #print "Found ; \n";
              $flag = 0;
              push @signal_list, $F1_p3;  # p2 is )
             }# if ( ($F1_p1 eq ";") ) 
           else
             {
              if ( $F1_p1 eq "," ) 
               {
                push @signal_list, $F1_p2;
                 #print "Found $F1_p2 \n";
               }
             }# if ( ($F1_p1 eq ";") ) 
          }# elsif( $flag == 1 )

# Solving for:
# output          foo; // 
# input    [3:0]  bar;

        if ( 
             ( $F1_p1 eq "input"  ) || 
             ( $F1_p1 eq "output" ) 
           ) 
          {
           $found_net_declare = 1;
           $net_type = $F1_p1;
           $net_top = "";
           $net_bot = "";
          }
        elsif ( $found_net_declare == 1 )
          {
           if ( $F1_p2 eq ":" )
            {
             $net_top = $F1_p3; # Solved for [7:0]
             $net_bot = $F1_p1;
             ( $net_top =~ s/\[//go ); # Replace '[' with null
             ( $net_bot =~ s/\]//go ); # Replace ']' with null
            }# if ( $F1_p2 eq ":" )

           if ( $F1_p1 eq ";" )
            {
             $net_name = $F1_p2;
             $signal_type_hash{$net_name}  = $net_type; 
             $signal_width_hash{$net_name} = "$net_top $net_bot";
             $found_net_declare = 0;
            }# if ( $F1_p1 eq ";" )
          } # if input or output

   }#while

 if ( $F1_p1 eq "endmodule" )
  {
   if ( ($mode eq "") || ($mode eq "port") )
      {
        foreach $signal ( @signal_list )
          {
           $net_type =  $signal_type_hash{ $signal };
           $net_width = $signal_width_hash{ $signal };
           ($net_top, $net_bot ) = split (' ', $net_width , 2) ;

           if ( ($net_top eq "") && ( $net_bot eq "" ) )
            {
             $type_desc = "std_logic";
            }
           else
            {
             $type_desc = "std_logic_vector( $net_top downto $net_bot )";
            }

           if    ( $net_type eq "input"  ) { $dir = "in   "; }
           elsif ( $net_type eq "output" ) { $dir = "out  "; }
           else                            { $dir = "-TBD-"; }

           $str = "    " . pack "A29" , $signal ;
           $str = $str . sprintf( ": %5s $type_desc ;", $dir ); # Component Dec
           @rts_str[$lcnt++] = $str ;

          }# foreach $signal ( @signal_list )
      }# if ( ($mode eq "") || ($mode eq "port") )

   if ( ($mode eq "") || ($mode eq "signal") )
      {
        foreach $signal ( @signal_list )
          {
           $net_type =  $signal_type_hash{ $signal };
           $net_width = $signal_width_hash{ $signal };
           ($net_top, $net_bot ) = split (' ', $net_width , 2) ;

           if ( ($net_top eq "") && ( $net_bot eq "" ) )
            {
             $type_desc = "std_logic";
            }
           else
            {
             $type_desc = "std_logic_vector( $net_top downto $net_bot )";
            }

           $str = sprintf( "-- signal %20s : %s ;", $signal, $type_desc );
           @rts_str[$lcnt++] = $str ;
          }# foreach $signal ( @signal_list )
      }# if ( ($mode eq "") || ($mode eq "signal") )

   if ( ($mode eq "") || ($mode eq "map") )
      {
        @rts_str[$lcnt++] = "u_" . $name . " : " . $name ;
        @rts_str[$lcnt++] = "  port map";
        @rts_str[$lcnt++] = "  (";
        foreach $signal ( @signal_list )
          {
            $footer = ",";
            $str = sprintf( "  %32s => %32s", $signal , $signal );
            @rts_str[$lcnt++] = $str . $footer;
          }
        @rts_str[$lcnt++] = "  );";
      }# if ( ($mode eq "") || ($mode eq "map") )
    return @rts_str;
  }# if ( $F1_p1 eq "endmodule" )
 }# if ( $mode eq "verilog" )

 else
 {
# Look for Strings in $_ 
if ( (/$entity/io) )
 {
  # print STDOUT "$LINE FOUND ENTITY\n";
   ($F1, $name , $ETC) = split (' ', $_ , 3);
   if ( $this_is_verilog == 1 )
    { 
      $name =~ ( s/\(//go ); # Strip ( from foo(
    } 
 }

# elsif ( (/$port/io) && ( $found_port_start != 1 ) )
if ( (/$port/io) )
 {
  # print STDOUT "$LINE FOUND PORT START \n";
  $flag = 1;   # Set Flag to Append all the lines that follow
  $found_port_start = 1;

   if ( $mode eq "" )
    {
     @rts_str[$lcnt++] = "component " . $name  ;
     @rts_str[$lcnt++] = " port";
     @rts_str[$lcnt++] = "    (";
    }
 }

elsif ( (/$port_stop/io) )
 {
  #print STDOUT "$LINE FOUND PORT STOP\n";
   if ( $mode eq "" )
    {
     @rts_str[$lcnt++] = "    );";
     @rts_str[$lcnt++] = "end component ; -- " . $name  ;
    }


   if ( ($mode eq "") || ($mode eq "map") )
    {
     @rts_str[$lcnt++] = "-------------------------------------------------------------------------------";
     @rts_str[$lcnt++] = "--";
     @rts_str[$lcnt++] = "-------------------------------------------------------------------------------";
  
     @rts_str[$lcnt++] = "u_" . $name . " : " . $name ;
     @rts_str[$lcnt++] = "  port map";
     @rts_str[$lcnt++] = "  (";
    }# if ( $mode eq "" )

   if ( ($mode eq "") || ($mode eq "map") )
    {
     foreach $signal ( @signal_list )
      {
       $footer = ",";
       $str = sprintf( "  %32s => %32s", $signal , $signal );
       @rts_str[$lcnt++] = $str . $footer;
      }
    }

   if ( ($mode eq "") || ($mode eq "map") )
    { 
     @rts_str[$lcnt++] = "  ); -- " .$name;
    } 

  if ( ($mode eq "") || ($mode eq "signal") )
   {
    foreach $signal ( @signal_full_list )
     {
      ($F1, $F2, $F3, $ETC) = split (' ', $signal , 4);
      $str = sprintf( "-- signal %20s : %s", $F1, $ETC );
      @rts_str[$lcnt++] = $str ;
     }
   } #if ( ($mode eq "") || ($mode eq "signal") )
     return @rts_str;
  }

elsif ( $flag == 1 ) 
 {
  # Create our string until PORT_STOP is found
  if ( (substr($_,0,2) ne "--") )
   {
    ($F1, $F2, $F3, $ETC) = split (' ', $_, 4);
    if ( ( $this_is_verilog == 1 ) || ( $F2 eq ":" ) ) 
      {
        if ( ( $this_is_verilog == 1 ) )
          {
           ( $F1 =~ s/,//go ); # Strip , from foo,
          }
        push @signal_list, $F1;
        chomp $_; 
        if ( (substr($_,-1,1) ne ";") )
         {
          $_ = $_ . ";"; # Last Signal, so add ;
         }
        else
         {
          $_ = $_ . ""; # Not the Last Signal, so ; already there
         }

        push @signal_full_list, $_ ;
        $str = "    " . pack "A29" , $F1 ;
        $str = $str . sprintf( ": %5s $ETC", $F3 ); # Component Dec

        if ( ($mode eq "") || ($mode eq "port") )
         {
          @rts_str[$lcnt++] = $str ;
         }# if ( ($mode eq "") || ($mode eq "port") )

      }# if ( $F2 eq ":" ) 
   }# if ( (substr($_,0,2) ne "--") )
 }# elsif ( $flag == 1 ) 
 }# if ( $mode eq "verilog" )
 }#while
}# sub port_map()

# ########################################################################
# I wrote this as Glob fails on my Slackware 7.0 machine for 
# some reason. This appears to be drop-in for perls glob.
sub my_glob {
  my $glob_name = "";
 ( $glob_name ) = @_;
  my $str = "";
  my @file_list = ();
  open STATUS, "ls $glob_name | " or die "Cant Fork: $!";
  while ( <STATUS> ) {$str = $str . $_ ;}
  close STATUS ;

  while ( ($F1, $str )=split(' ',$str,2) ) {push @file_list, $F1;}
  return @file_list;
}# sub my_glob

# ########################################################################
#  make_pdf( $ARGV[0], $ARGV[1], $ARGV[2] );

sub make_pdf {
 my ( $text_in_file, $pdf_out_file , $parse_mode ) = @_;

 my $cnt = 0;
 my $y_top = 792-40; # Top of Page
  my $y_bot = 40    ; # Bottom of Page
 my $y = $y_top;
 my $x = 60  ; # Left of Page
 my $line_cnt =0;
 my $text_size = 10;
 my $obj = 100; # This must be larger than last one used in footer
 my $kids = "";
  if ( $en_trace == 1 ){print trace_file "make_pdf()\n";}

 open( input_file,  "<" . $text_in_file ) or die "Error Opening!";
 open( pdf_file  ,  ">" . $pdf_out_file ) or die "Error Opening!";
 
 pdf_header();
 pdf_start_page( $obj );
 $y = $y_top;
 pdf_text_horizontal($x, $y, " ", $text_size);

 while ( $_ = <input_file> )
 {
  $line_cnt++;
  ($F1,$F2,$F3,$ETC)=split(' ',$_,4);
  if ($F2 eq "[pdf_off]" ) { $pdf_on = 0; }
  if ($F2 eq "[pdf_line_number]" ) { $_ = "Perl Source Line Number: $line_cnt\n"; }
  if ($F2 eq "[pdf_text_size]" ) 
   { 
    $text_size = $F3 ; 
    pdf_close_horizontal_cont();
    pdf_text_horizontal($x, $y, " ", $text_size);
    $_ = " ";
   }

  if (  ($parse_mode eq "") || ( $pdf_on == 1 ) )
  {
   if (  substr($_,0,1) eq "#" ) { $_ = substr( $_, 2 ); } # Remove #H etc


   chomp $_;
   if ( ($_ eq "[PAGE_BREAK]") || ($y < $y_bot ) || ($F2 eq "[pdf_break]") )
    {
     pdf_text_horizontal_cont(" ");
     pdf_close_horizontal_cont();
     pdf_finish_page( $obj );
     $kids = $kids . "$obj 0 R ";
     $obj+=3;
     $cnt++;
     pdf_start_page( $obj);
     $y = $y_top;
     pdf_text_horizontal($x, $y, " ", $text_size);
    }
   else
    {
     # ( $_ =~ s/\\/##/go ); # Remove All the leading \ and replace with \\ 
     ( $_ =~ s/\\/\\\\/go ); # Remove All the leading \ and replace with \\ 
     ( $_ =~ s/\)/\\\)/go ); # Remove All the trailing ) and replace with \)
     ( $_ =~ s/\(/\\\(/go ); # Remove All the leading ( and replace with \( 
     ( $_ =~ s/\}/\\\}/go ); # Remove All the trailing } and replace with \}
     ( $_ =~ s/\{/\\\{/go ); # Remove All the leading { and replace with \{ 
      if ( $_ eq "" ) { $_ = " " ; }
     pdf_text_horizontal_cont( $_ );
     # pdf_text_horizontal( $x, $y , $_ );
     $y-=$text_size;
    }
  }# if (  ($parse_mode eq "") || ( $pdf_on == 1 ) )

  if ($F2 eq "[pdf_on]" ) { $pdf_on = 1; }
 }

pdf_close_horizontal_cont();
pdf_finish_page($obj);
   $kids = $kids . "$obj 0 R ";
   $obj+=3;
   $cnt++;
pdf_footer($kids, $cnt);
close pdf_file;
return;

sub pdf_text_horizontal {
   my ($x,$y,$text, $text_size ) = @_;
   print pdf_file "%% Display Regular Text\n";
   print pdf_file "BT\n /F1 1 Tf\n";
#   print pdf_file "10 0 0 10 $x $y Tm\n";
   print pdf_file "$text_size 0 0 $text_size $x $y Tm\n";
   print pdf_file "0 g\n 0 Tc\n 0 Tw\n";
   print pdf_file "(".$text.")Tj\n";
   # Note: Don't forget to call pdf_close_horizontal_cont!
}

sub pdf_text_horizontal_cont {
   my ($text ) = @_;
   print pdf_file "0 -1 Td (".$text.") Tj\n";
}

sub pdf_close_horizontal_cont {
   print pdf_file "ET\n";
}

sub pdf_text_vertical {
   my ($x,$y,$text ) = @_;
   print pdf_file "%% Display Rotated Text\n";
   print pdf_file "BT\n";
   print pdf_file "0 -10 10 0 $x $y Tm\n";
   print pdf_file "($text)Tj\n";
#   print pdf_file "%% Offset\n";
#   print pdf_file "-0.779 1 TD\n";
#   print pdf_file "($_)Tj\n";
   print pdf_file "ET\n";
}

sub pdf_color_line {
   my ($x1,$y1,$x2,$y2, $red,$green,$blue ) = @_;
   print pdf_file "%% Select Color and Draw Line\n";
   print pdf_file "$red $green $blue RG\n";
   print pdf_file "$x1 $y1 m\n";
   print pdf_file "$x2 $y2 l\n";
   print pdf_file "S\n";
}

## PDF Header
sub pdf_header {
print pdf_file "%PDF-1.1\n";
}

sub pdf_start_page {
  my ( $obj ) = @_;
  #print pdf_file $obj . " 0 obj << /Type /Page /Parent 4 0 R /Resources 1 0 R /Contents ".($obj+1)." 0 R >> endobj\n";
  #print pdf_file ($obj+1) . " 0 obj << >>\n";
  #print pdf_file "stream 0 G 0 J 0 j 1.342 w 10 M []0 d BX /GS1 gs EX 1 i \n";

  print pdf_file ($obj)   . " 0 obj << /Type /Page /Parent 9 0 R /Resources " . 
               ($obj+1) . " 0 R /Contents " . ($obj+2) . " 0 R >> endobj\n";
#  print pdf_file ($obj+1) . " 0 obj << /ProcSet [/PDF /Text /ImageC /ImageI] /Font << /F1 4 0 R /F2 5 0 R >> /XObject << /Im1 6 0 R >> /ExtGState << /GS1 7 0 R >> /ColorSpace << /Cs9 8 0 R >> >> endobj\n";
  print pdf_file ($obj+1) . " 0 obj << /ProcSet [/PDF /Text ] /Font << /F1 4 0 R /F2 5 0 R >> /ExtGState << /GS1 7 0 R >> >> endobj\n";
  print pdf_file ($obj+2) . " 0 obj << >>\n stream\n";

} # start_page

sub pdf_finish_page {
  my ( $obj ) = @_;
   print pdf_file "endstream\n";
   print pdf_file "endobj\n";
   print pdf_file "\n";
#   $kids = $kids . "$obj 0 R ";
} # Finish Page


 ## PDF Footer Stuff
 sub pdf_footer {
  my ( $kids, $cnt ) = @_;
 $font = "Helvetica";
 $font = "Courier";
 print pdf_file " 9  0 obj << /Type /Pages /Kids [$kids] /Count " . $cnt . " /MediaBox [0 0 612 792] >> endobj\n";
 print pdf_file " 17 0 obj << /CreationDate (D:20011130130855) /Producer (ChipVault 2001.12 for Everyone) >> endobj \n";
 print pdf_file " 7  0 obj << /Type /ExtGState /SA false /SM 0.02 /TR /Identity >> endobj \n";
 print pdf_file " 16 0 obj << /Type /Catalog /Pages 9 0 R >> endobj \n";
 print pdf_file " 4  0 obj << /Type /Font /Subtype /Type1 /Encoding /WinAnsiEncoding /BaseFont /$font >> endobj \n";
 print pdf_file " 5  0 obj << /Type /Font /Subtype /Type1 /Encoding /WinAnsiEncoding /BaseFont /Courier-Bold >> endobj\n";
 print pdf_file " 15 0 obj << /Type /Font /Subtype /Type1 /Encoding /WinAnsiEncoding /BaseFont /Times-Roman >> endobj\n";

 print pdf_file "xref\n 0 10\n";
 print pdf_file "0000000000 65535 f\n 0000003464 00000 n\n 0000000017 00000 n\n 0000003060 00000 n\n 0000003376 00000 n\n";
 print pdf_file "0000003297 00000 n\n 0000003552 00000 n\n 0000003165 00000 n\n 0000003641 00000 n\n 0000003696 00000 n\n";
 print pdf_file "trailer << /Size 8 /Root 16 0 R /Info 17 0 R >>\n startxref\n 3802\n %%EOF\n";
 }# sub pdf_footer {
}# sub make_pdf



# Given "../foo/bar/foo.txt" return "../foo/bar/wip.foo.txt"
sub solve_wip_name {
 my ($org_path_and_file, $wip_header ) = @_;
  if ($en_trace==1){print trace_file "solve_wip_name() Time=".localtime(time)."\n";}

# if ( -e "./wip" )
 if ( substr($wip_header,0,2) eq "./" )
 {
  # "./wip/foo.v"; # This is for Icarus Verilog support ( support wip.foo.v )
  $wip_filename_tmp = solve_path( $org_path_and_file );
# $wip_filename_tmp = $wip_filename_tmp . substr($wip_header,2) . "/";
  $wip_filename_tmp = $wip_filename_tmp .        $wip_header    . "/";
  $wip_filename_tmp = $wip_filename_tmp .  solve_file( $org_path_and_file );
 }
 else
 {
  # "wip.foo.v";
  $wip_filename_tmp = solve_path( $org_path_and_file );
  $wip_filename_tmp = $wip_filename_tmp . $wip_header;
  $wip_filename_tmp = $wip_filename_tmp .  solve_file( $org_path_and_file );
 }
 return $wip_filename_tmp;
}

# Remove the WIP part of a filename
sub solve_remove_wip_from_name {
 my ($file, $wip_header ) = @_;
 if ( substr($wip_header,0,2) eq "./" ) { $wip_header .= "/"; }
 ( $file =~ s/$wip_header//go ); # Search and Replace
 return $file;
}


# Given "../foo/bar/foo.txt" return ".txt"
# NOTE: This is LAME!! Requires .three format!!! TODO FIX FIX FIX
sub solve_ext {
 my ($org_path_and_file ) = @_;
 return ( substr($org_path_and_file,-4,4) );
}

# Given "../foo/bar/foo.txt" return "foo.txt"
sub solve_file {
 my ($org_path_and_file ) = @_;
 my $path_tmp;
 my $file_tmp;
 my $F1_tmp;
 my $ETC_tmp;
 my $wip_filename_tmp;
  if ( $en_trace == 1 ){print trace_file "solve_file()\n";}

 # Strip Path from File
 $path_tmp = ""; $file_tmp ="";
 $ETC_tmp = $org_path_and_file;
 if ( $os ne "unix" ) 
  {
    ( $ETC_tmp =~ s/\\/\//go ); # Remove All the '\' and replace with '/'
  }
 while ( ($F1_tmp, $ETC_tmp ) = split ('/', $ETC_tmp, 2) )
 {
   if ( $ETC_tmp ne "" ) { $path_tmp = $path_tmp . $F1_tmp . $filecat ; }
   $file_tmp = $F1_tmp;
 }# while ( ($F1, $ETC ) = split ('/', $ETC, 2) )
 if ( $en_trace == 1 )
   {print trace_file "solve_file() $org_path_and_file -> $file_tmp\n";}
 return $file_tmp;
}

# Given "../foo/bar/foo.txt" return "../foo/bar/"
sub solve_path {
 my ($org_path_and_file ) = @_;
 my $path_tmp;
 my $file_tmp;
 my $F1_tmp;
 my $ETC_tmp;
 my $wip_filename_tmp;
  if ( $en_trace == 1 ){print trace_file "solve_path()\n";}

 # Strip Path from File
 $path_tmp = ""; $file_tmp ="";
 $ETC_tmp = $org_path_and_file;
 if ( $os ne "unix" ) 
  {
    ( $ETC_tmp =~ s/\\/\//go ); # Remove All the '\' and replace with '/'
  }
 while ( ($F1_tmp, $ETC_tmp ) = split ('/', $ETC_tmp, 2) )
 {
   if ( $ETC_tmp ne "" ) { $path_tmp = $path_tmp . $F1_tmp . $filecat ; }
   $file_tmp = $F1_tmp;
 }# while ( ($F1, $ETC ) = split ('/', $ETC, 2) )
 if ( $en_trace == 1 )
   {print trace_file "solve_path() $org_path_and_file -> $path_tmp\n";}
 return $path_tmp;
}

# Given "../foo/bar/foo.txt" return "..\foo\bar\foo.txt" on Win32
# also replace .. with .
sub solve_slash {
 my ($str ) = @_;
 if ( $os ne "unix" ) 
  {
    ( $str =~ s/\//\\/go ); # Remove All the '/' and replace with '\'
#    ( $str =~ s/\.\./\./go ); # Remove All the '..' and replace with '.'
  }
 if ( $en_trace == 1 )
   {print trace_file "solve_slash() @_ -> $str\n";}
 return $str;
}# sub solve_slash {



# $top_mod      = $ARGV[0]; #IE top. If '#' then return 1st Module Name found
# $glob_name    = $ARGV[1]; #Note: This MUST be in quotes, or UNIX will Glob!
# $noise_filter = $ARGV[2]; #IE 5 to toss children with less than 5 ports
# $debug        = $ARGV[3]; #ie "1", "-1" or null
#
# $rts = hierarchy_solver( $top_mod, $glob_name, $noise_filter, $debug );
# print "\n" ;
# print $rts . "\n";
# exit;

sub hierarchy_solver {
 ($top_mod, $glob_name, $noise_filter, $debug ) = @_;
  if ( $en_trace == 1 ){print trace_file "hierarchy_solver()\n";}

 if ( $debug eq "" )
  {
   select STDOUT; $| = 1 ; # Turn off STDOUT Buffering (Normally buffs lines)
  }

  undef $rts_str ; 
  my %list = () ; # Erase Hash
  my %parent_of = (); # Fixed stale Mod name used on 2nd rtl_gen()

  undef @file_list;

 @file_list = glob("$glob_name");
 foreach $file (@file_list)
 {
        $perl_line = __LINE__; 
   open( input_file , "<" . $file) or die "ERROR $perl_line: Can't Open $file!";
   $this_is_vhdl = 0;
   if ( substr($file,-4,4) eq ".vhd") { $this_is_vhdl = 1 ; }

   $line_cnt=0;
   $port_cnt=0;
   $found_module_name = 0;
   $looking_for_port = 1;
   $found_of = 0;
   $found_arch = 0;

   $looking_for_module = 1; 
   $looking_for_children = 0;
   $found_child          = 0;
   $ignore_rest_of_line  = 0;

   $mod_name        = "";
   $mod_name_prime  = "";
   $arch_name       = "";
   $child_name      = "";

   $F1_p5 = "";
   $F1_p4 = "";
   $F1_p3 = "";
   $F1_p2 = "";
   $F1_p1 = "";
   $F1_p1a = "";

   while ( $_ = <input_file>)
   {
   $line_cnt++;

##########################################################
# Verilog Section
#########################################################
if ( $this_is_vhdl == 0 ) 
 {
   ($F1, $ETC ) = split (' ', $_ , 2) ; # Check 1st word for "--"

   if ( (substr($F1,0,2) ne "//") )
   {
    $ETC = $_;
    ( $ETC =~ s/\./#DOT# /go); # Replace ".foo" with " #DOT# foo" 
    ( $ETC =~ s/\(/ \( /go ); # Replace '(' with ' ( ' for parsing words
    ( $ETC =~ s/\)/ \) /go ); # Replace ')' with ' ) ' for parsing words

    while ( ($F1, $ETC ) = split (' ', $ETC , 2) )
     {
        if ( $F1 eq "//") { $F1 = ""; $ETC = ""; } # Ignore Comments

       # PipeDelay of 4 words  
        $F1_p5 = $F1_p4; 
        $F1_p4 = $F1_p3; 
        $F1_p3 = $F1_p2; 
        $F1_p2 = $F1_p1;
        $F1_p1 = $F1 ;
 
        #  "flip_flop #( params,,, ) u14( .clk(clk, **** );"
        if ( $F1_p1 eq "#" ) { $word_before_params = $F1_p2 ; }

      if ( lc( $F1_p1 ) eq "endmodule" )
       {
        $looking_for_module   = 1; # End of File
        $looking_for_children = 0;
        $found_child          = 0;
       }

      if ( lc( $F1_p1 ) eq "module" )
       {
        if ( $debug eq "") { print ".";}
        if ( $debug == 1 )  { print "\nFound module $line_cnt ";}
        $looking_for_module   = 0; # Start of File
        $looking_for_children = 0;
        $found_child          = 0;
       }

      # Looking for "module foo(netname" 
      if ( ( $looking_for_module == 0 ) && ( lc($F1_p2) eq "module" ) )
       {
         ($mod_name , $null_str )=split ('\(', $F1_p1 , 2) ; # Solves "foo(bar"
         # if ( $top_mod eq "#" ) { return $mod_name ; } 
           # Check for any other modules of this exact name
           if ( $list{$mod_name} ne "" )
            {
             #print "Module Already exists once!\n";
             $mod_name_prime = $mod_name . "'"; # Uniquify via Prime ' symbol
             while ( $list{ $mod_name_prime } ne "" )
              {
               # Loop until I find a free listing for this alternate view
               $mod_name_prime = $mod_name_prime . "'"; 
              }
             $mod_name = $mod_name_prime;  

            }# if ( $list{$mod_name} ne "" )
          $list{$mod_name} = $file;
          if ( $debug == 1 ) { print "$mod_name : $file ";}
          $ignore_rest_of_line = 1;
          $looking_for_children = 1;
       }
        
      if ( $ignore_rest_of_line == 1 ) 
        { 
         $ETC = "" ; $_ = ""; $ignore_rest_of_line = 0;
        }  # Hack!


      # Looking for "flip_flop u14( .clk(clk, **** );"
      #  or         "flip_flop #( params ) u14( .clk(clk, **** );"
      # but dont confuse with "always @( clk"
        if ( ($looking_for_children == 1 ) && ( $found_child == 0 ) )
         { 
#          # This sucks. I think I have to look at the entire line for a "."
#          # to determine if a cell is being instantiated here. Verilog bites.
           if ( ($F1_p1 eq "#DOT#") && ($F1_p2 eq "(" ) )
            {
             $found_child = 1;
             $port_cnt = 0;

             # This is lame way to extract "flip_flop_ from
             #  "flip_flop #( params,,, ) u14( .clk(clk, **** );"
             if ( $F1_p4 ne ")" )
               {
                $child_name = $F1_p4;
               }
             else
               {
                $child_name = $word_before_params;
               }# if ( $F1_p3 ne "\)" 
             $ref_des    = $F1_p3;

             if ( $debug == 1 ) { print "\n  Found Child ";}
             if ( $debug == 1 ) { print "$child_name : $refdes $line_cnt";}
             # if ( $debug == 1 ) { print "\n $_";}
            }
         }   

      # Count the ports for each instantiation 
        if ( ($looking_for_children == 1 ) && ( $found_child == 1 ) )
         { 
           $connect = ",";
           $connect_done = ";";
           while ( ($F1_p1 =~ /$connect/go) )  { $port_cnt++ ; } # Count Ports
           if ( ( $F1_p1 =~ m/$connect_done/go ) ) 
             { 
              # Found the end of the port instantiation
              $found_child = 0;

              if ( ($noise_filter eq "" ) || 
                   ( ($noise_filter ne "" ) && ( $port_cnt > $noise_filter) ) )
               {
                if ( $child_name ne "" )
                 { 
                    # $list{$mod_name} = $list{$mod_name} . ":" . $child_name;
                    $list{$mod_name} = $list{$mod_name} . ":" . $child_name .
                    "=" . $ref_des;
                    $parent_of{$child_name} = $mod_name ; # For solving top
                 } 
               }
              else
               { 
                 $child_name = "";
                 $port_cnt = "";
               }
            }# if ( ( $F1_p1 =~ m/$connect_done/go ) ) 
          }# if ( ($looking_for_children == 1 ) && ( $found_child == 1 ) )

     }# while ( ($F1, $ETC ) = split (' ', $ETC , 2) )
   }# if ( (substr($_,0,2) ne "--") )
 } 

#########################################################
# VHDL Section
#########################################################
 else
 {
   ($F1, $ETC ) = split (' ', $_ , 2) ; # Check 1st word for "--"
   if ( (substr($F1,0,2) ne "--") )
   {
    $ETC = $_;
    ( $ETC =~ s/\:/ \: /go ); # Replace ":" with " : "
    if ( $ETC =~ m/--/g )
     {
      $ETC = substr($_, 0, ( pos $ETC ) - 2 ); # Strip After Comment
     }

    while ( ($F1, $ETC ) = split (' ', $ETC , 2) )
     {
       if ( $F1 eq "--") { $F1 = ""; $ETC = ""; } # Ignore Comments
       # fix parsing issues with thans like "map(" vs "map ("
       ( $F1 =~ s/\(//go ); # Remove All the '(' and replace with nul
       ( $F1 =~ s/\)//go ); # Remove All the ')' and replace with nul
       # PipeDelay of 4 words
        $F1_p5 = $F1_p4;
        $F1_p4 = $F1_p3;
        $F1_p3 = $F1_p2;
        $F1_p2 = $F1_p1;
        $F1_p1 = $F1 ;

      if ( $found_module_name == 0 )
      {

      # Looking for "architecture * of MOD_NAME is"
       if ( ($found_of == 1) && ($found_arch == 1) )
         {
           $found_module_name = 1;
           $mod_name = $F1_p1;
           if ( $debug == 1 ) { print "$file : $F1_p1 : $line_cnt\n"; }
           if ( $debug eq "") { print ".";}
           # Check for any other modules of this exact name
           if ( $list{$mod_name} ne "" )
            {
             # print "$mod_name Module Already exists once!\n";
             $mod_name_prime = $mod_name . "'"; # Uniquify via Prime ' symbol
             while ( $list{ $mod_name_prime } ne "" )
              {
               # Loop until I find a free listing for this alternate view
               $mod_name_prime = $mod_name_prime . "'"; 
               # print "$mod_name_prime";
              }
             $mod_name = $mod_name_prime;  

            }# if ( $list{$mod_name} ne "" )

           $list{$mod_name} = $file;
           $found_arch = 0;
           $found_of   = 0;
          # if ( $top_mod eq "#" ) { return $mod_name ; } # special case
         }

       # "architecture rtl of foo is"
       if ( ( lc ( $F1_p1 ) eq "architecture") &&
            ( $found_of == 0 )                      )
          { $found_arch = 1; }

       if ( ( lc ( $F1_p2 ) eq "architecture") &&
            ( $found_arch == 1 ) &&
            ( $found_of   == 0 )                     )
          { $arch_name = $F1_p1 } ; # ie "rtl"

       if ( (lc ( $F1_p1 ) eq "of" ) &&
            ( $found_arch == 1)  )
          { $found_of = 1; }

      }# if ( $found_module_name == 0 )

      elsif ( $found_child == 1 ) # In the middle of a child connection
      {
       $connect = "=>";
       $connect_done = ";";
       while ( ($F1_p1 =~ /$connect/go) )  { $port_cnt++ ; } # Count Ports
       if( ($F1_p1 =~ /$connect_done/o) )
       {
        if ( $debug == 1 ) { print "Nets = $port_cnt\n";}

        if ( ($noise_filter eq "" ) ||
             ( ($noise_filter ne "" ) && ( $port_cnt > $noise_filter) ) )
         {
          # $list{$mod_name} = $list{$mod_name} . ":" . $child_name;
          $list{$mod_name} = $list{$mod_name} . ":" . $child_name .
                    "=" . $ref_des;
          $parent_of{$child_name} = $mod_name ; # For solving top
         }
        $found_child = 0;
        $child_name  = "";
        $port_cnt = 0;
       }# if( ($F1_p1 =~ /$connect_done/o) )
      }# else # Looking for Children

      else
      {
        # Looking for "u_refdes : child_name port map(" or
        # Looking for "u_refdes : child_name generic map("
         if ( ( lc ($F1_p1 ) eq "map") && ( lc ($F1_p4 ) eq ":") )
         {
           $child_name = $F1_p3;
           $ref_des    = $F1_p5;
           if ( $debug == 1 ) { print " Child      : $child_name : $ref_des\n";}           $found_child = 1;
           $port_cnt = 0;
         }

       # Look for end of current module ie "end rtl;" Important for Netlists
       if ( lc ( $F1_p2 ) eq "end" )
         {
          $F1_p1a = $F1_p1;
          ( $F1_p1a =~ s/;//go ); # Remove any ';' and replace with nul
          if ( $F1_p1a eq $arch_name )
           {
            if ( $debug == 1 ) { print "Found end of architecture!"; }
            $found_module_name = 0; # Start looking again
           }
         }
      }

     }# while ( ($F1, $ETC ) = split (' ', $ETC , 2) )
   }# if ( (substr($_,0,2) ne "--") )

#########################################################
# End VHDL Section
#########################################################
 }# if ( $this_is_vhdl == 0 ) 
  }# while 
 close input_file;
}# for

 # print "$top_mod\n";
 if ( $top_mod ne "#" )
  {
   $rts_str = "";
   $rts_str = show_children (1, $top_mod,"","", %list); # Recursively figure out
   return $rts_str;
  }
 else
  {
   # Solve who's top
   # If the length of the %parent_of hash is 1, then only a single module
   # was read in and it has no children. In this case, just return the 
   # modules name.

   if ( length ( %parent_of ) == 1 )
     {
         return $mod_name;
     }
   else
     {
       #print "Length " . length ( %parent_of ) . " $parent_of \n";
       foreach $name (%parent_of)
        {
         #print "Looking for parent of $name\n";
         if ( $parent_of{$name} eq "" )
          {
            #print "Poor $name has no parent.\n";
            return $name;
          }
        }# foreach $name (%parent_of)
     }# if ( length ( %parent_of ) == 1 )
  }# if ( $top_mod ne "#" )
}# sub hierarchy_solver

#########################################################
# Recursively find childred for each block
# show_children ($depth, $name, $rts_in, %hash_list ) ;
#########################################################
sub show_children
 {
# Note: Must Declare these locally for recursive to work
  my $i = 0;
  my $str = "";
  my $depth = "";
  my $name = "";
  my $F1   = "";
  my $alt_F1   = "";
  my $ref_des = "";
  my $out_str = "";
  my $col2_pos = 40;  # This is where we place the file name normally
  my %hash_list = ();

  my $rts_in  = "";
  my $rts_out = "";

   ($depth, $name, $ref_des, $rts_in, %hash_list ) = @_;
  if ( $en_trace == 1 ){print trace_file "show_children()\n";}

  if ( $debug == 1 ){  print "Looking for all children for $name : $depth\n"; }
   $out_str = pack "A$depth", " "; # Pad width $depth spaces
   $out_str = $out_str . $name;

   if ( length ( $out_str ) >= $col2_pos )
     {
      $out_str = $out_str . " "; 
      # WARNING : $out_str is really long!\n";
     }
   else
     {
      $out_str = pack "A$col2_pos", $out_str; # Pad to right
     }

   $str = $hash_list{ $name };
   ( ($file_name, $str ) = split (':', $str , 2) );
   if ( $file_name eq "" ) { $file_name = "file_not_found"; }
   if ( length( $file_name ) < 20 )
    {
     $file_name_padded = pack "A20", $file_name; # Pad to right
    }
   else
    {
     $file_name_padded = $file_name; # too long to pad
    }
   $out_str = $out_str . " " . $file_name_padded . " " . $ref_des . "\n";;

   $rts_out = $rts_in . $out_str ;
   $rts_in  = $rts_out;

   while ( ($F1, $str ) = split (':', $str , 2) )
    {
      ($F1, $ref_des) = split ('=', $F1 , 2) ; # New 12-18
      $rts_out = show_children (($depth+1),$F1, $ref_des, $rts_in, %hash_list);
      $rts_in = $rts_out;
     # Also look for Multiple Views of this is a 1st Archi
     if( ($F1 =~ /'/go) )
      {
      }
     else
      {
        $alt_F1 = $F1 . "'";
        while ( $hash_list{ $alt_F1 } ne "" )
        {
          $rts_out  = show_children (($depth+1),$alt_F1,$ref_des, $rts_in, %hash_list);
          $rts_in   = $rts_out;
         $alt_F1 = $alt_F1 . "'";
        }# while ( $hash_list{ $alt_F1 } ne "" )
      }# if( ($F1 =~ /'/go) )
    }# while ( ($F1, $str ) = split (':', $str , 2) )
  return $rts_out;
}# sub show_children

#############################################################
# This Program is a Perl version of GNU TAR
# Reference: tar.h
# $option         = $ARGV[0]; # -cvf = Create, -rvf = Append
# $tarfile_name   = $ARGV[1];
# $clearfile_name = $ARGV[2];
# @rts = tar_sub ( $option, $tarfile_name, $clearfile_name );
# exit;
#############################################################
# tar_sub: subset of UNIX tar. Supports 5 operations only!
#   ARG0   ARGV1     ARGV2
#   -cvf   file.tar  foo   : Create file.tar containing foo
#   -rvf   file.tar  foo   : Append file.tar with foo
#   -xvf   file.tar  foo   : Extract foo from file.tar
#   -xvf   file.tar        : Extract all from file.tar
#   -tf    file.tar        : List all files within file.tar
#############################################################
sub tar_sub 
{
 my ( $option, $tarfile_name, $clearfile_name ) = @_;
 my $i = 0;
 my $a = "";
 my $b = "";
 my $size = 0;
 my @tmp_array;
 my @header_array;
 my @rts;

if    ($option eq "-cvf")
 {
  if ( open(output_file,">$tarfile_name") ) { }
  else
  {
        $perl_line = __LINE__; 
         $rts = dialog_box(-1, "ERROR $perl_line:# File-1 Open Failed $tarfile_name.".
                    "# ChipVault will now Terminate this fatal condition.".
                    "# <Press Any Key> ");
         exit ( 10 );
  }
  if ($os eq "win32"){binmode(output_file) };
 }
elsif ($option eq "-rvf")
 {
  # Need to open up the existing TAR file and remove the last null byte blocks.
  tar_walk_thru ( $tarfile_name, $tarfile_name , "strip" );
  open(output_file,">>$tarfile_name") ||die "File-2!\n"; # Append
  if ($os eq "win32"){binmode(output_file) };
 }
elsif ($option eq "-tf")
 {
  @rts = tar_walk_thru ( $tarfile_name, "null" , "list" );
  foreach $_ ( @rts )
   { 
    print STDOUT "$_\n";
   }# foreach $_ ( @rts )
 }
elsif ($option eq "-xvf")
 {
  @rts = tar_walk_thru ( $tarfile_name, $clearfile_name , "extract" );
 }
else 
 { 
  $perl_line = __LINE__;
  print STDOUT "ERROR $perl_line with $option!!\n"; 
 }


if ( ( $option eq "-cvf" ) || ( $option eq "-rvf" ) )
 {
  @header_array = tar_make_header  ( $clearfile_name );
  @header_array = tar_make_checksum( @header_array );

   foreach $a ( @header_array )
    {
     while ( ( ($b = substr( $a,0,1 )) ne "" ) )
     {
      $a = substr( $a,1 ); # Remainder
      if ( $b eq "#" ) { print output_file "\0"; }
       else            { print output_file $b; }
     } # while
    }# foreach $a ( @header_array )

  $i = 0;
  open ( input_file , "<$clearfile_name") || die "Can't open input file\n";
  if ($os eq "win32"){binmode(input_file) };
  while ( read ( input_file , $b, 1) != 0 )
   {
    $i++;
    if ($i == 10240 ) { $i = 0; }
    print output_file $b;
   } # while ( read ( input_file , $b, 1) != 0 )
  while ( $i < 10240-256-256 ) { print output_file "\0"; $i++; }
  close input_file;
  close output_file;
 } # if ( ( $option eq "-cvf" ) || ( $option eq "-rvf" ) )

 return @rts;

}# sub tar_sub


##########################################
# tar_walk_thru : This walks thru the TAR header structure and either:
#  strip   : Removes closing null blocks from a tar file ( for appending)
#  list    : Returns list of all files in the tar
#  extract : Extract the specified file
##########################################
sub tar_walk_thru 
{
 my ( $filein_name, $fileout_name, $option ) = @_;
 my $i = 0;
 my $j = 0;
 my $a = "";
 my $b = "";
 my $size = 0;
 my @tmp_array;
 my @rts = "";
 my $name = "";

  open(input_file,"<$filein_name")||die "File-3!\n";
  if ($os eq "win32"){binmode(input_file) };
  $i = 0; $j = 0; $size =0;
  while ( ( read(input_file,$b,1) != 0 )) { push @tmp_array, $b; $size++; }
  close input_file ;

  $i = 0; $j=0;$len = -1;
  while ( ( $i < $size ) && ( $len != 0 ) )
   {
     if ( ($option eq "list") || ($option eq "extract") )
     {
      $name = "";
      for ( $j = $i; $j < $i+100; $j++ )
       {
         if   ( ord( @tmp_array[$j] ) != 0 )
          { 
            $name = $name . @tmp_array[$j]; 
          }
       }# for ( $j = $i; $j < $i+512; $j++ )
      push @rts, $name;
     }#if ( $option eq "list" )

      $i += 100+8+8+8; # Position of Header length field
      $len = "";
      for ( $k = $i; $k < $i+11; $k++ ) { $len = $len . @tmp_array[$k]; } 
      $len = oct ( $len );
      if ( $len > 0 )
       {
        $i+=512-100-8-8-8; # Skip Past Header
        $j=0;
        if ( ( $option eq "extract" ) && 
             ( ( $name eq $fileout_name ) || ( $fileout_name eq "" ) ) )
         {
          open(output_file,">$name")||die "File-4!\n";
          if ($os eq "win32"){binmode(output_file) };
          push @rts, $name;
         }# if ( ( $option eq "extract" ) && ( $name eq $fileout_name ) )

        $k = 0;
        while ($j < $len)
         {
          if ( ( $option eq "extract" ) && 
             ( ( $name eq $fileout_name ) || ( $fileout_name eq "" ) ) )
           {
            print output_file @tmp_array[$i]; $j++;$i++;$k++;
            if ( $k == 512 ) { $k = 0 ; }
           }
          else
           {
            $i+=512;
            $j+=512;
           }
         }# while ($j < $len)

        if ( ( $option eq "extract" ) && 
             ( ( $name eq $fileout_name ) || ( $fileout_name eq "" ) ) )
         {
          while ( $k < 512 ) { $i++; $j++; $k++; }
          close output_file;
         }
       }# if ( $len > 0 )
      else
       {
         # Len==0 so this must be the end. 
        if ( $option eq "strip" )
        {
          $i -= 100+8+8+8; # Reposition to end of last file block
          open(output_file,">$fileout_name")||die "File-5!\n";
          if ($os eq "win32"){binmode(output_file) };
          for ( $j = 0; $j < $i; $j++ )
           {
            print output_file @tmp_array[$j];
           }# for ( $j = 0; $j < $i; $j++ )
          close output_file;
         }# if ( $option eq "strip" )
        elsif ( $option eq "extract" )
         {
         }
        else
         {
         }# if ( $option eq "strip" )
        return @rts;
       }# if ( $len > 0 )
   }# while ( ( $i < $size ) && ( $len != 0 ) )
}# sub tar_walk_thru 


##########################################
# Calculates the checksum of the Header.
##########################################
sub tar_make_checksum
{
 my ( @in_array ) = @_;
 my $i = 0;
 my $j = 0;
 my $checksum = 0;
 my $a = "";
 my $b = "";
 while ( $i < 512 )
  {
   $a = @in_array[$j];
   while ( ( ($b = substr( $a,0,1 )) ne "" ) )
    {
     $a = substr( $a,1 ); # Remainder
     if ( $b eq "#" ) { $b = "\0"; }
     if ( ($i < hex("094")) || ($i > hex ("09a")) ) { $checksum+= ord($b); }
      else { $checksum+= ord(" "); $mark = $j; }
     if ( $checksum >= 262144 ) { $checksum -= 262144; } # ?is this correct?
     $i++;
    } #while
   $j++;
  }# while ( $i < 512 )

 $checksum_str = sprintf( "%06o",($checksum)) . "#"; # Octal Digits
 @in_array[$mark] = $checksum_str;
 return @in_array; # 512 Bytes
}# sub tar_make_checksum


##########################################
# Generate a Header for a File Record 
##########################################
sub tar_make_header 
{
 my ($filein_name ) = @_;
 my $len = 0;
 my @out_array;

 push @out_array, $filein_name;
 $len = length ( $filein_name );
 while ( $len < 100 ) { push @out_array,"#"; $len++; }

 push @out_array, "0100666#"; # Mode
 push @out_array, "0000000#"; # UID 
 push @out_array, "0000000#"; # GID 

 # Note: stat returns: dev,ino,mode,nlink,uid,gid,rdev, size,atime,mtime,
 $size = ( ( stat $filein_name  ) [ 7 ] ) ; # Get Size
 $size_str = sprintf( "%011o",($size)); # Octal Digits
 push @out_array, $size_str . "#";
 push @out_array, "07541202636\0"; # mtime

 $checksum = 0;
 $checksum_str = sprintf( "%06o",($checksum)) . "#"; # Octal Digits
 push @out_array, "$checksum_str";
 push @out_array, " 0"; # TypeFlag

 $link_name ="";
 $len = length ( $link_name );
 while ( $len < 98 ) { push @out_array, "#"; $len++; }
 push @out_array, "##ustar";                 # Magic
 push @out_array, "  #";                     # Version,etc
 push @out_array, "cv_dsgnr";                # userid
 push @out_array, "########################";# etc
 push @out_array, "cv_group";                # groupid
 push @out_array, "#######################################";#etc
 $len = 0;
 while ( $len < 168 ) { push @out_array, "#"; $len++; }
 return @out_array; # 512 Bytes
}# sub tar_make_header

##########################################
# Generate a Win32 Win2K Binary Link file for starting ChipVault 
# with Console setup properly (no scrolling and full 80x60 screen).
##########################################
sub gen_win32_lnk
{
 push @lnk_array,"4C 00 00 00 01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46";
 push @lnk_array,"A3 00 00 00 20 00 00 00 00 10 A9 15 AD 6B C1 01 00 98 88 89";
 push @lnk_array,"F2 44 C2 01 00 10 A9 15 AD 6B C1 01 00 40 00 00 00 00 00 00";
 push @lnk_array,"01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C4 00 14 00";
 push @lnk_array,"1F 50 E0 4F D0 20 EA 3A 69 10 A2 D8 08 00 2B 30 30 9D 19 00";
 push @lnk_array,"23 43 3A 5C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";
 push @lnk_array,"00 29 86 14 00 31 00 00 00 00 00 38 2C F4 9E 10 00 61 70 70";
 push @lnk_array,"73 00 00 14 00 31 00 00 00 00 00 39 2C 40 A2 10 00 70 65 72";
 push @lnk_array,"6C 00 00 1F 00 31 00 00 00 00 00 39 2C 40 A2 10 00 35 2E 36";
 push @lnk_array,"2E 31 00 35 36 32 36 39 44 7E 31 2E 31 00 13 00 31 00 00 00";
 push @lnk_array,"00 00 39 2C 40 A2 10 00 62 69 6E 00 00 23 00 31 00 00 00 00";
 push @lnk_array,"00 39 2C 40 A2 10 00 4D 53 57 69 6E 33 32 2D 78 38 36 00 4D";
 push @lnk_array,"53 57 49 4E 33 7E 31 00 18 00 32 00 00 40 00 00 6C 2B C4 98";
 push @lnk_array,"20 00 70 65 72 6C 2E 65 78 65 00 00 00 00 5A 00 00 00 1C 00";
 push @lnk_array,"00 00 01 00 00 00 1C 00 00 00 2D 00 00 00 00 00 00 00 59 00";
 push @lnk_array,"00 00 11 00 00 00 03 00 00 00 72 36 73 36 10 00 00 00 00 43";
 push @lnk_array,"3A 5C 61 70 70 73 5C 70 65 72 6C 5C 35 2E 36 2E 31 5C 62 69";
 push @lnk_array,"6E 5C 4D 53 57 69 6E 33 32 2D 78 38 36 5C 70 65 72 6C 2E 65";
 push @lnk_array,"78 65 00 00 0B 00 63 00 76 00 5F 00 77 00 69 00 6E 00 33 00";
 push @lnk_array,"32 00 2E 00 70 00 6C 00 CC 00 00 00 02 00 00 A0 07 00 F5 00";
 push @lnk_array,"50 00 3C 00 50 00 3C 00 A8 00 74 00 00 00 00 00 00 00 00 00";
 push @lnk_array,"08 00 0C 00 30 00 00 00 90 01 00 00 54 00 65 00 72 00 6D 00";
 push @lnk_array,"69 00 6E 00 61 00 6C 00 00 00 00 00 00 00 00 00 00 00 00 00";
 push @lnk_array,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";
 push @lnk_array,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 19 00 00 00";
 push @lnk_array,"00 00 00 00 00 08 00 00 01 00 00 00 01 00 00 00 32 00 00 00";
 push @lnk_array,"04 00 00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80 00 00";
 push @lnk_array,"00 80 80 00 80 00 00 00 80 00 80 00 80 80 00 00 C0 C0 C0 00";
 push @lnk_array,"80 80 80 00 00 00 FF 00 00 FF 00 00 00 FF FF 00 FF 00 00 00";
 push @lnk_array,"FF 00 FF 00 FF FF 00 00 FF FF FF 00 00 00 00 00";

 open(output_file,">cv.lnk")||die "File-6!\n";
 if ($os eq "win32"){binmode(output_file) };
 foreach $a ( @lnk_array )
 {
  while ( ( ($b = substr( $a,0,3 )) ne "" ) )
   {
      $a = substr( $a,3 ); # Remainder
      $bin = sprintf("%c",hex($b) );
      print output_file $bin; 
   } # while
 }# foreach $a ( @header_array )
}# sub gen_win32_lnk

sub subdir_import 
{
 my ($hlist_file, $get_rtl_files_only ) = @_;
 local *output_file; # Allows recursion. Camel-pg.51
# This function imports a Subdirectory Structure and generates a
# ChipVault hlist.txt file. (ie for Renoir designs, etc)
#
 my $parent_subdir = ".";   # Current Directory
 # my $hlist_file = "hlist.txt";

 open( output_file , ">" . $hlist_file );
 print output_file format_hlist_str("hlist",$hlist_file,"",0,40) ;
 close output_file;
 recurse_subdirs( $hlist_file, $parent_subdir, 1, $get_rtl_files_only );
 return;
}# sub subdir_import 

sub recurse_subdirs 
{
 my( $hlist_file, $parent_subdir, $level, $get_rtl_files_only ) = @_;
 local *DIRECTORY;   # Allows recursion. Camel-pg.51
 local *output_file; # Allows recursion. Camel-pg.51
 my @all_files;   
 my $a;
 my $filecat       = "/" ; # UNIX

 if ( opendir DIRECTORY, $parent_subdir )
  {
   # Is a Directory.
   open( output_file , ">>" . $hlist_file );
   $parent_subdir_out = $parent_subdir;
   if ( substr($parent_subdir,0,2) eq "./" )
     {
       $parent_subdir_out = substr($parent_subdir,2); # Strip leading ./
     }
   print output_file format_hlist_str($parent_subdir_out,
                                      "file_not_found","",$level,40) ;
   close output_file;
   @all_files = readdir DIRECTORY;
   closedir DIRECTORY;
   foreach $a ( @all_files )
    {
     if ( ( $a ne ".." ) && ( $a ne "." ) )
     {
      recurse_subdirs( $hlist_file, $parent_subdir.$filecat.$a, ($level+1) ,
                       $get_rtl_files_only );
     } # if ( ( $a ne ".." ) && ( $a ne "." ) )
    }# foreach $a ( @all_files )
  }# if ( opendir DIRECTORY, $parent_subdir )
 else
  {
   # Not a Directory, just a file.
     if ( 
          ( substr($parent_subdir,-2,2) eq ".v"    ) ||
          ( substr($parent_subdir,-4,4) eq ".vhd"  ) ||
          ( $get_rtl_files_only == 0 )
        ) 
      {
       $parent_subdir_out = $parent_subdir;
       if ( substr($parent_subdir,0,2) eq "./" )
        {
         $parent_subdir_out = substr($parent_subdir,2); # Strip leading ./
        }
       open( output_file , ">>" . $hlist_file );
       print output_file format_hlist_str($parent_subdir_out,
                                          $parent_subdir_out, "",$level,40) ;
       close output_file;
      }
  }# if ( opendir DIRECTORY, $parent_subdir )
}# sub recurse_subdirs



sub format_hlist_str
{
 ( $mod_name, $file_name, $ref_des, $hier_pos,$col2_pos ) = @_;
 my $out_str="";
 my $file_name_padded="";

 $out_str = pack "A$hier_pos", " "; # Pad to right
 $out_str = $out_str . $mod_name;

 if ( length ( $out_str ) >= $col2_pos ) { $out_str = $out_str . " "; }
  else { $out_str = pack "A$col2_pos", $out_str; }

 if ( length( $file_name ) < 20 ) { $file_name_padded = pack "A20", $file_name; }
  else { $file_name_padded = $file_name; } # too long to pad
 $out_str = $out_str . " " . $file_name_padded . " " . $ref_des . "\n";;
 return $out_str;
}# sub format_hlist_str

# (eof_chipvault)
