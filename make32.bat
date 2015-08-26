REM  make32.bat -  Batch file for assembling/linking 32-bit Assembly programs
REM  Revised: 11/15/01

@echo off
cls

REM The following three lines can be customized for your system:
REM ********************************************BEGIN customize
SET PATH=C:\dev\Masm615
SET INCLUDE=C:\dev\Masm615\INCLUDE
SET LIB=C:\dev\Masm615\LIB
REM ********************************************END customize

REM ML -Zi -c -Fl -coff %1.asm
ML -c -Fl -coff %1.asm

if errorlevel 1 goto terminate

REM add the /MAP option for a map file in the link command.

LINK32 %1.obj Irvine32.lib kernel32.lib user32.lib /SUBSYSTEM:CONSOLE /DEBUG
REM LINK32 %1.obj Irvine32.lib kernel32.lib C:\Dev\Masm615\LIB\User32.Lib /SUBSYSTEM:CONSOLE /DEBUG
if errorLevel 1 goto terminate

dir %1.*

:terminate
pause