/* Get the title of the current song from the web site  */
/* of an internet radio station.                        */

/* User configuration */
FWall = @@FWall@@
/* End of user configuration */

/* Get parms */
Parse Arg RadioURL Verbose

/* Check if we're already running. If so create */
/* a station file, then exit; otherwise create  */
/* semaphore file.                              */
IsAlive = linein('.\gt_alive', 1, 1)
if IsAlive \= '' then do
    if RadioURL \= '' then do
        call lineout '.\RadioURL', RadioURL, 1
        call lineout '.\RadioURL'
    end
    return
end; else do
    call lineout '.\gt_alive', 'GetTitle is alive', 1
    call lineout '.\gt_alive'
end

/* Constants */
ClrYelw = '[01;33m'
ClrWhite = '[01;15m'
ClrCyan = '[01;36m'
ClrDarkRed = '[31m'
ClrRed = '[01;31m'
ResetClr = '[0m'
SaveCur = '[s'

signal on halt name TrapErr

/* Load RexxUtil */
rc = RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
if rc = 0 then call SysLoadFuncs

/* Load RxSock */
rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
if rc = 0 then call SockLoadFuncs

/* Check parameters */
if RadioURL = '' then call CorrectSyntax
if (Verbose \= '') & (Verbose \= '/V') then call CorrectSyntax

/* Show the logo */
if Verbose = '/V' then do
    Verbose = 1
    call ClearScrn
    say ClrWhite || ' +----------------------------------------+' || ResetClr
    say ClrWhite || ' |GetTitle script for Z! Controller.      |' || ResetClr
    say ClrWhite || ' |(C) Copyright Cristiano Guadagnino 2001.|' || ResetClr
    say ClrWhite || ' +----------------------------------------+' || ResetClr
    say
    say ClrYelw || '' || ResetClr || SaveCur
end; else do
    Verbose = 0
end

/* +++++ */
GTSetup:

/* Normalize parameters */
Parse Value RadioUrl With . '.' RadioStation '.' .
RadioURL = 'http://' || RadioURL

/* Get the constant to locate the title. */
OKString = linein(RadioStation, 1, 1)
LinesToSkip = linein(RadioStation)
TitleCode = linein(RadioStation)

if (OKString = '') | (LinesToSkip = '') then do
    if Verbose then say 'Error reading "' || RadioStation || '" setup.'
    signal TrapErr
end

/* Close the setup file */
rc = lineout(RadioStation)

/* Name the queue */
TheQ = 'GetTitleQ'

/* Delete the file if it exists */
frc = SysFileDelete('.\force-title.txt')

/* +++++ */
Looper:

/* Look if exists 'RadioURL' file */
TmpRadioURL = linein('.\RadioURL', 1, 1)
if TmpRadioURL \= '' then do
    RadioURL = TmpRadioURL
    call lineout '.\RadioURL'
    frc = SysFileDelete('.\RadioURL')
    signal GTSetup
end

/* Look if exists 'gt_kill' file */
DieFlag = linein('.\gt_kill', 1, 1)
if DieFlag \= '' then do
    call lineout '.\gt_kill'
    signal TrapErr
end

/* Delete the queue if it exists */
qrc = rxqueue('Delete', TheQ)

/* Create the queue and set it as current */
TheQ = rxqueue('Create', TheQ)
qrc = rxqueue('Set', TheQ)

if FWall = 1 then
    /* Exec wget and pipe the output to the queue */
    '@wget -q --cache=off -O- ' || RadioURL || ' | rxqueue ' || TheQ || ' /FIFO'
else
    /* Use RxSock to retrieve the web page, then queue it */
    call GetHttpTrack RadioURL

/* Get queued lines */
TheTitle = ''
do while Queued() > 0
    WebLine = LineIn('QUEUE:')

    if Abbrev(WebLine, OKString) = 1 then do
        do LinesToSkip
            WebLine = LineIn('QUEUE:')
        end
    TheTitle = strip(WebLine)
    if TitleCode \= '' then interpret TitleCode
    leave
    end
end /* while */

if TheTitle \= '' then do
    call LineOut '.\force-title.txt', TheTitle, 1
    call LineOut '.\force-title.txt'
    if Verbose then do
        rc = LineUp(3)
        rc = EraseLine()
        rc = RestoreCursor()
        rc = LineUp(2)
        say ClrYelw || TheTitle || ResetClr || SaveCur
    end
end; else do
    if Verbose then say 'Unable to retrieve title.'
end

frc = SysSleep(10)
signal Looper

return

/* -------------------------------------------------- */

CorrectSyntax: Procedure expose ClrWhite ResetClr
    say
    say ClrWhite || ' +----------------------------------------+' || ResetClr
    say ClrWhite || ' |GetTitle script for Z! Controller.      |' || ResetClr
    say ClrWhite || ' |(C) Copyright Cristiano Guadagnino 2001.|' || ResetClr
    say ClrWhite || ' +----------------------------------------+' || ResetClr
    say
    say '   Correct syntax is:'
    say
    say '      gettitle <radio_station_url> [/V]'
    say
    say '   The "V" parameter tells the program to be verbose,'
    say '   i.e. to display the title it retrieves.'
    say
    signal TrapErr
return

EraseLine: procedure
    say '[79D' /* move the cursor left 79 cols */
    say '[K'   /* erase to the end of line */
return ''

LineUp: procedure
    numolines = arg(1)
    say '[' || numolines || 'A'
return ''

RestoreCursor: procedure
    say '[u'
return ''

ClearScrn: procedure
    say '[2J'
return ''

GetHttpTrack: procedure
    RadioURL = delstr(arg(1), 1, 7)
    rc=SockInit()
    httpaddr.!family='AF_INET'
    httpaddr.!port=80
    socket=SockSocket('AF_INET', 'SOCK_STREAM',  0)
    rc=SockSetSockOpt(socket, SOL_SOCKET, SO_RCVTIMEO, 2)
    rc=SockGetHostByName(RadioURL, httpaddr.!)
    rc=SockConnect(socket, httpaddr.!)
    rc=SockSend(socket, 'GET / HTTP/1.0  ' || '0D0A0D0A'x)
    Response=''
    do forever
        BytesRcvd = SockRecv(Socket, 'RcvData', 1024)
        if BytesRcvd <= 0 then leave
        if length(Response) > 10000 then leave
        Response = Response || RcvData
    end
    rc=SockClose(socket)
    do forever
        crpos = pos('0D0A'x, Response)
        if crpos \= 0 then do
            queue left(Response, crpos - 1)
            Response = delstr(Response, 1, crpos - 1)
        end; else do
            if Response \= '' then queue Response
            leave
        end
    end
return ''

TrapErr:
    frc = SysFileDelete('.\force-title.txt')
    frc = SysFileDelete('.\gt_alive')
    frc = SysFileDelete('.\RadioURL')
    frc = SysFileDelete('.\gt_kill')
    if Verbose = 1 then say 'User break.'
    exit

