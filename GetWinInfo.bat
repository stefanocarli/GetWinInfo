::============================================================
::Write a bat file that can gather all kinds of information
::on Windows OS, for example:
:: - User accounts
:: - Directory lists
:: - Application installed
:: - and so on.
::============================================================

@ECHO OFF
setlocal EnableDelayedExpansion

TITLE Get Windows OS info

REM Ask the user if she wants to proceed
:choice
echo This batch script will gather information of your Windows system and will generate the following files in the current directory:
echo - directories.txt
echo - useraccounts.txt
echo - networking.txt
SET /P ANSWER=Do you want to proceed? (Y/N)
if /I {%ANSWER%}=={Y} (goto :checkOS)
if /I {%ANSWER%}=={N} (goto :END)
REM If the choice is neither Y nor N, then ask again
goto :choice

:checkOS
REM Check the OS
if %os%==Windows_NT goto WINNT
goto NOWIN

:WINNT
echo .Using a Windows NT based system
echo ..%computername%

echo Getting data [Computer: %computername%]...
echo Please Wait....

REM set variables
set "volume=C:"
set folder=tester

REM Create directory if it doesn't exist
IF NOT EXIST %folder% md %folder%

REM List down all the directories 
echo [*] Getting directories...
SET file="%folder%/directories.txt"
REM Simplified Directory listing
echo -------------------------------------------- > %file%
echo DIRECTORY LISTING (Simplified) >> %file%
echo -------------------------------------------- >> %file%
dir %volume%\ /b /a:d >> %file%
echo [+] A SIMPLIFIED directory list has been written in the file %file%
REM List all the directories
echo -------------------------------------------- >> %file%
echo DIRECTORY LISTING (Full)>> %file%
echo -------------------------------------------- >> %file%
dir %volume%\ /b /s /a:d >> %file%
echo [+] A FULL directory list has been written in the file %file%

REM Get Networking information
echo [*] Getting network info
SET file="%folder%/network.txt"
echo [+] Interfaces
echo -------------------------------------------- > %file%
echo INTERFACES >> %file%
echo -------------------------------------------- >> %file%
ipconfig /all >> %file% 
echo -------------------------------------------- >> %file%
echo [+] Routes
echo ROUTE >> %file%
echo -------------------------------------------- >> %file%
route print >> %file% 
echo -------------------------------------------- >> %file%
echo [+] ARP table
echo ARP TABLE >> %file%
echo -------------------------------------------- >> %file%
arp -a >> %file% 
echo -------------------------------------------- >> %file%
echo [+]NETWORK CONNETIONS >> %file%
echo -------------------------------------------- >> %file%
netstat -ano >> %file% 
echo [+] Networking information have been written in the file %file%

REM Get Tasklist 
echo [*] Getting tasklist
SET file="%folder%/tasklist.txt"
echo -------------------------------------------- > %file%
echo TASKLIST >> %file%
echo -------------------------------------------- >> %file%
tasklist /V >> %file%
echo -------------------------------------------- >> %file%
echo [+] Tasklist information have been written in the file %file%

REM Getting registry info
echo [*] Getting registry info
reg export HKEY_CLASSES_ROOT "%folder%\reg-HKEY_CLASSES_ROOT.txt" /y
echo [+] HKEY_CLASSES_ROOT information has been written in the file "%folder%\reg-HKEY_CLASSES_ROOT.txt"
reg export HKEY_CURRENT_USER "%folder%\reg--HKEY_CURRENT_USER.txt" /y
reg export HKEY_LOCAL_MACHINE "%folder%\reg-HKEY_LOCAL_MACHINE.txt" /y
reg export HKEY_USERS "%folder%\reg-HKEY_USERS.txt" /y
reg export HKEY_CURRENT_CONFIG "%folder%\reg-HKEY_CURRENT_CONFIG.txt" /y

REM Getting antivirus
echo [*] Getting installed antivirus
SET file="%folder%\antivirus.txt"
echo -------------------------------------------- > %file%
echo ANTIVIRUS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% /namespace:\\root\securitycenter2 path antivirusproduct >> nul

REM Getting usernames
echo [*] Getting usernames
SET file="%~dp0%folder%\users.txt"
echo -------------------------------------------- > %file%
echo USERS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% UserAccount where "LocalAccount=True" >> nul

REM Getting hotfixes and service packs
echo [*] Getting hotfixes and service packs. It may take a while...
SET file="%~dp0%folder%\hotfixes.txt"
echo -------------------------------------------- > %file%
echo HOTFIXES AND SERVICE PACKS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% qfe >> nul

REM Getting startup list
echo [*] Getting startup list
SET file="%~dp0%folder%\startup.txt"
echo -------------------------------------------- > %file%
echo STARTUP LIST >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% startup list full >> nul

REM Getting current environment variable settings
echo [*] Getting environment variables
SET file="%~dp0%folder%\enviromen.txt"
echo -------------------------------------------- > %file%
echo environment VARIABLE SETTINGS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
set >> %file%

::====================================================

goto END

:NOWIN
echo Error...This is not Windows...
goto END

:END