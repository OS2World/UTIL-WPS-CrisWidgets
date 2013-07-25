/* Cris' Widgets installation program */

/* List of files to install */
F2I.0 = 6
F2I.Docs = '.\docs'
F2I.GetTitle = '.\gettitle'
F2I.Icons = '.\icons\*.ico'
F2I.IconsZN = '.\icons\z_normal\*.ico'
F2I.IconsZW = '.\icons\z_wide\*.ico'
F2I.Widgets = '.\widgets'

/* Files to change */
F2C.0 = 6
F2C.1 = 'Clock'
F2C.2 = 'SwapMon'
F2C.3 = 'ZCtrl'
F2C.4 = 'ZCtrlWide1'
F2C.5 = 'ZCtrlWide2'
F2C.6 = 'ZMon'

/* Constants */
ClrYelw = '[01;33m'
ClrWhite = '[01;15m'
ClrCyan = '[01;36m'
ClrDarkRed = '[31m'
ClrRed = '[01;31m'
ResetClr = '[0m'
SaveCur = '[s'

/* Stems used by functions */
GSPVars = 'InstBootDrive InstSwapperDrive InstSwapperPath InstSwapMinFree InstSwapInit'
InstVars = 'InstZPath InstXWPDir InstScrollFactor ' || GSPVars

rc = RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
if rc = 0 then call SysLoadFuncs

call ClearScrn

say
say ClrYelw || ' Cris'' Widgets Installation Program' || ResetClr
say ClrYelw || ' ===================================' || ResetClr
say
say ClrWhite || ' The program will now ask you a few questions,' || ResetClr
say ClrWhite || ' and will then customize the widgets according' || ResetClr
say ClrWhite || ' to your answers.' || ResetClr
say
say ClrWhite || ' All the widgets will be customized, even if' || ResetClr
say ClrWhite || ' you want to use only some of them. Please' || ResetClr
say ClrWhite || ' answer all the questions. You can give bogus' || ResetClr
say ClrWhite || ' answers if you are not interested in a' || ResetClr
say ClrWhite || ' particular widget.' || ResetClr
say
say ClrCyan || ' Press a key to continue...' || ResetClr
pull .

rc = LineUp(4)
rc = EraseLine()
rc = LineUp(2)

/* Get XWP install dir */
InstXWPDir = SysIni('USER', 'XWorkplace', 'XFolderPath')
if (InstXWPDir = 'ERROR:') | (InstXWPDir = '') then do
    say
    say ClrRed || 'An error occurred getting XWP install' || ResetClr
    say ClrRed || 'directory. Aborting.' || ResetClr
    say
    call SysSleep 2
    return -1
end

/* Normalize directory */
InstXWPDir = Strip(InstXWPDir)
if Right(InstXWPDir, 1) = '00'x then InstXWPDir = Left(InstXWPDir, Length(InstXWPDir) - 1)
if Right(InstXWPDir, 1) \= '\' then InstXWPDir = InstXWPDir || '\'

say ClrYelw || ' Z! Controller/Monitor:' || ResetClr
say ClrYelw || ' ^^^^^^^^^^^^^^^^^^^^^^' || ResetClr
say
say ClrWhite || ' Enter the complete path of Z! [e.g. e:\myapps\z\]:' || ResetClr || SaveCur
pull InstZPath
if Right(InstZPath, 1) \= '\' then
    InstZPath = InstZPath || '\'

rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
say ClrDarkRed || InstZPath || ResetClr

say
say ClrWhite || ' Do you want the song title to scroll? [Y/n]:' || ResetClr || SaveCur
pull InstYesNo
if InstYesNo = '' then InstYesNo = 'Y'
rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
if (InstYesNo = 'Y') | (InstYesNo = 'YES') then do
    InstScrollFactor = 10
    say ClrDarkRed || 'Scroll' || ResetClr
end; else do
    InstScrollFactor = 999
    say ClrDarkRed || 'NoScroll' || ResetClr
end

say
say ClrCyan || ' Press a key to continue...' || ResetClr
pull .

call ClearScrn
say ClrYelw || ' Z! Controller/Monitor:' || ResetClr
say ClrYelw || ' ^^^^^^^^^^^^^^^^^^^^^^' || ResetClr
say
say ClrWhite || ' Do you want the "normal" or the "wide" widget version? [N/w]:' || ResetClr || SaveCur
pull InstNormWide
rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
if InstNormWide \= 'W' then do
    InstNormWide = 'N'
    say ClrDarkRed || 'Normal' || ResetClr
end; else
    say ClrDarkRed || 'Wide' || ResetClr

say
say ClrWhite || ' If you''re behind a firewall, the script will use WGet' || ResetClr
say ClrWhite || ' to retrieve song titles for internet radio stations.' || ResetClr
say ClrWhite || ' In this case WGet must be installed and configured to' || ResetClr
say ClrWhite || ' go through your firewall. Also, it must be reachable' || ResetClr
say ClrWhite || ' on the PATH. If you have free access to the internet,' || ResetClr
say ClrWhite || ' the script will use the RxSock library for the above task.' || ResetClr
say
say ClrWhite || ' Are you behind a restrictive firewall? [y/N]:' || ResetClr || SaveCur
pull InstFWall
rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
if (InstFWall = 'Y') | (InstFWall = 'YES') then do
    InstFWall = 1
    say ClrDarkRed || 'The script will use WGet' || ResetClr
end; else do
    InstFWall = 0
    say ClrDarkRed || 'The script will use RxSock' || ResetClr
end

say
say ClrCyan || ' Press a key to continue...' || ResetClr
pull .

call ClearScrn
say
say ClrYelw || ' Swapper Monitor:' || ResetClr
say ClrYelw || ' ^^^^^^^^^^^^^^^^' || ResetClr
say
say ClrWhite || ' Enter OS/2 boot drive [e.g. e:]:' || ResetClr || SaveCur
pull InstBootDrive
if Right(InstBootDrive, 1) \= ':' then
    InstBootDrive = InstBootDrive || ':'

rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
say ClrDarkRed || InstBootDrive || ResetClr

rc = GetSwapParms()
if rc \= '0' then do
    say
    say ClrRed || 'An error occurred parsing config.sys. Aborting.' || ResetClr
    say
    call SysSleep 2
    return -1
end

say
say ClrYelw || ' SECOND PART' || ResetClr
say ClrYelw || ' ^^^^^^^^^^^' || ResetClr
say
say ClrWhite || ' Customizing widgets...' || ResetClr || SaveCur
say

rc = CustomizeWgts()
if rc \= '0' then do
    say
    say ClrRed || 'An error occurred customizing widgets code.' || ResetClr
    say ClrRed || 'Either retry installation, or try to customize' || ResetClr
    say ClrRed || 'the widgets manually. Aborting.' || ResetClr
    say
    call SysSleep 2
    return -1
end

rc = CustomizeGT()
if rc \= '0' then do
    say
    say ClrRed || 'An error occurred customizing widgets code.' || ResetClr
    say ClrRed || 'Either retry installation, or try to customize' || ResetClr
    say ClrRed || 'the widgets manually. Aborting.' || ResetClr
    say
    call SysSleep 2
    return -1
end

rc = LineUp(3)
rc = EraseLine()
rc = RestoreCursor()
say ClrDarkRed || 'Done.' || ResetClr

say
say ClrCyan || ' Press a key to continue...' || ResetClr
pull .

call ClearScrn
say ClrYelw || ' THIRD PART' || ResetClr
say ClrYelw || ' ^^^^^^^^^^' || ResetClr
say
say ClrWhite || ' Now I will start copying the files to the Z!' || ResetClr
say ClrWhite || ' directory and to the XWorkplace directory.' || ResetClr
say ClrWhite || ' Is it OK? [Y/n]:' || ResetClr || SaveCur
pull CopyYesNo

if ((CopyYesNo \= 'Y') & (CopyYesNo \= 'YES') & (CopyYesNo \= '')) then do
    rc = LineUp(3)
    rc = EraseLine()
    rc = RestoreCursor()
    say ClrRed || 'Installation aborted.' || ResetClr
    say
    call SysSleep 2
    return -1
end

say ClrWhite || ' Copying...' || ResetClr || SaveCur
'@copy ' || F2I.GetTitle || '\* ' || InstZPath
'@copy ' || F2I.Icons || ' ' || InstXWPDir || 'plugins\xcenter\'
if InstNormWide = 'N' then
    '@copy ' || F2I.IconsZN || ' ' || InstZPath
else
    '@copy ' || F2I.IconsZW || ' ' || InstZPath

say
say ClrCyan || ' Press a key to continue...' || ResetClr
pull .

call ClearScrn
CurrDir = directory()
DocsDir = CurrDir || strip(F2I.Docs, 'L', '.')
rc = SysOpenObject(DocsDir, 'DEFAULT', TRUE)
if rc \= 1 then say ClrRed || 'Unable to open WPS view of the '|| DocsDir || ' folder' || ResetClr
WgtsDir = CurrDir || strip(F2I.Widgets, 'L', '.')
rc = SysOpenObject(WgtsDir, 'DEFAULT', TRUE)
if rc \= 1 then say ClrRed || 'Unable to open WPS view of the ' || WgtsDir ||' folder' || ResetClr

say
say ClrWhite || ' Installation has ended. Now ctrl+drag the widget icons' || ResetClr
say ClrWhite || ' on an open space on the XCenter and you''re done.' || ResetClr
say ClrWhite || ' If you want you can read the docs by double-clicking' || ResetClr
say ClrWhite || ' the related icons. Once you''ve read the docs and' || ResetClr
say ClrWhite || ' the widgets have been dragged, you can safely delete' || ResetClr
say ClrWhite || ' the installation directory.' || ResetClr
call SysSleep 3
say
say ClrWhite || ' Press a key to close the installer.' || ResetClr || SaveCur
pull .

return 0
exit

/************* SubRoutines *************/

ClearScrn: procedure
    say '[2J'
    return ''

SaveCursor: procedure
    say '[s'
    return ''

RestoreCursor: procedure
    say '[u'
    return ''

EraseLine: procedure
    say '[79D' /* move the cursor left 79 cols */
    say '[K'   /* erase to the end of line */
    return ''

LineUp: procedure
    numolines = arg(1)
    say '[' || numolines || 'A'
    return ''

GetSwapParms: procedure expose (GSPVars)

    ClrWhite = '[01;15m'
    ClrDarkRed = '[31m'
    ResetClr = '[0m'

    say
    say ClrWhite || ' Parsing config.sys...' || ResetClr
    say

    InstSwapperDrive = ''
    CfgFile = InstBootDrive||'\config.sys'

    rc = linein(CfgFile,1,0)
    if lines(CfgFile) = 0 then return -1
    do while lines(CfgFile)
        CfgLine = linein(CfgFile)
        if abbrev(translate(CfgLine), 'SWAPPATH=') then do
            parse value CfgLine with . '=' InstSwapperDrive ':' InstSwapperPath ' ' InstSwapMinFree ' ' InstSwapInit
            leave
        end
    end

    if InstSwapperDrive = '' then
        return -1
    else
        InstSwapperDrive = InstSwapperDrive || ':'

    say ClrWhite || ' Swapper drive: ' || ResetClr || ClrDarkRed || InstSwapperDrive || ResetClr
    say ClrWhite || ' Swapper path: ' || ResetClr || ClrDarkRed || InstSwapperPath || ResetClr
    say ClrWhite || ' Swapper minimum free space: ' || ResetClr || ClrDarkRed || InstSwapMinFree || ResetClr
    say ClrWhite || ' Swapper initial size: ' || ResetClr || ClrDarkRed || InstSwapInit || ResetClr

    return 0

CustomizeWgts: procedure expose (InstVars) F2C.
    rc = directory('.\widgets')
    do FIndex = 1 to F2C.0
        TheFile =  '.\'||F2C.FIndex
        rc = linein(TheFile, 1, 0)
        if lines(TheFile) = 0 then return -1
        TheLine = linein(TheFile)
        if TheLine = 'RexxGauge' then do
            TheLine = linein(TheFile)
            WgtType = 'RexxGauge'

            do 2
                rc = WordPos('@@ZPath@@', TheLine)
                if rc \= 0 then do
                    Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1) || "'"
                    Part2 = "'" || Substr(TheLine, WordIndex(TheLine, rc) + 9)
                    TheLine = Part1 || InstZPath || Part2
                end
            end
        end; else do
            TheLine = linein(TheFile)
            WgtType = 'RexxButton'

            rc = WordPos('@@ZPath@@', TheLine)
            if rc \= 0 then do
                Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1) || "'"
                Part2 = "'" || Substr(TheLine, WordIndex(TheLine, rc) + 9)
                TheLine = Part1 || InstZPath || Part2
            end

            rc = WordPos('@@IconPath@@', TheLine)
            if rc \= 0 then do
                Part1 = Left(TheLine, WordIndex(TheLine, rc) - 2) || "'"
                Part2 = "'" || Substr(TheLine, WordIndex(TheLine, rc) + 13)
                select
                    when F2C.FIndex = 'ZCtrl' then
                        InstIconPath = InstXWPDir || 'zctrl.ico'
                    when F2C.FIndex = 'ZCtrlWide1' then
                        InstIconPath = InstXWPDir || 'zctrl1.ico'
                    when F2C.FIndex = 'ZCtrlWide2' then
                        InstIconPath = InstXWPDir || 'zctrl2.ico'
                    otherwise
                        InstIconPath = ''
                end
                TheLine = Part1 || InstIconPath || Part2
            end
        end

        rc = WordPos('@@ScrollFactor@@', TheLine)
        if rc \= 0 then do
            Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1)
            Part2 = Substr(TheLine, WordIndex(TheLine, rc) + 16)
            TheLine = Part1 || InstScrollFactor || Part2
        end

        rc = WordPos('@@SwapperDrive@@', TheLine)
        if rc \= 0 then do
            Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1) || "'"
            Part2 = "'" || Substr(TheLine, WordIndex(TheLine, rc) + 16)
            TheLine = Part1 || InstSwapperDrive || Part2
        end

        rc = WordPos('@@SwapperPath@@', TheLine)
        if rc \= 0 then do
            Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1) || "'"
            Part2 = "'" || Substr(TheLine, WordIndex(TheLine, rc) + 15)
            TheLine = Part1 || InstSwapperPath || Part2
        end

        rc = WordPos('@@SwapMinFree@@', TheLine)
        if rc \= 0 then do
            Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1)
            Part2 = Substr(TheLine, WordIndex(TheLine, rc) + 15)
            TheLine = Part1 || InstSwapMinFree || Part2
        end

        rc = WordPos('@@SwapInit@@', TheLine)
        if rc \= 0 then do
            Part1 = Left(TheLine, WordIndex(TheLine, rc) - 1)
            Part2 = Substr(TheLine, WordIndex(TheLine, rc) + 12)
            TheLine = Part1 || InstSwapInit || Part2
        end
        rc = lineout(TheFile)
        rc = SysFileDelete(TheFile)
        rc = lineout(TheFile, WgtType)
        rc = lineout(TheFile, TheLine)
        rc = lineout(TheFile)
    end
    rc = directory('..')
    return 0

CustomizeGT: procedure expose F2I. InstFWall
    TheFile = F2I.GetTitle || '\gettitle.cmd'
    TheFile2 = F2I.GetTitle || '\gettitle.new'
    rc = linein(TheFile, 1, 0)
    if lines(TheFile) = 0 then return -1
    do while lines(TheFile)
        TheLine = linein(TheFile)
        FWallPos = pos('@@FWall@@', TheLine)
        if FWallPos \= 0 then do
            rc = lineout(TheFile2, 'FWall = ' || InstFWall)
        end; else do
            rc = lineout(TheFile2, TheLine)
        end
    end
    rc = lineout(TheFile)
    rc = lineout(TheFile2)
    rc = SysFileDelete(TheFile)
    if rc \= 0 then return -1
    '@rename ' || TheFile2 || ' gettitle.cmd'
    return 0

