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

REM set variables
set "volume=C:"
set folder=%~dp0tester\
set file=

REM Ask the user if she wants to proceed
:choice
echo This batch script will gather information of your Windows system and will generate the following files in %folder%:
echo - general.txt
echo - software.txt
echo - directories.txt
echo - tasklist.txt
echo - network.txt
echo - reg-(registry type).txt
echo - antivirus.txt
echo - users.txt
echo - hotfixes.txt

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

REM Create directory if it doesn't exist
echo | set /p="[*] Creating folder %folder%... "
IF NOT EXIST %folder% md %folder%
echo done

REM Get general OS info
echo [*] Getting general OS info...
SET file="%folder%general.txt"

REM Get Computer Name
echo - Computer name
FOR /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do (
	echo Computer Name: %%A > %file%
)

REM Get Computer Manufacturer
echo - Computer manufacturer
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do (
	echo Computer Manufacturer: %%A >> %file%
)

REM Get Computer Model
echo - Computer model
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do (
	echo Computer Model: %%A >> %file%
)

REM Get Computer Serial Number
echo - Computer serial number
FOR /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do (
	echo Computer serial number: %%A >> %file%
)

REM Get Computer OS
echo - Computer OS
FOR /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do (
	echo Computer OS: %%A >> %file%
)

REM Get Computer OS SP
echo - Computer service pack
FOR /F "tokens=2 delims='='" %%A in ('wmic os get ServicePackMajorVersion /value') do (
	echo Computer Service Pack: %%A >> %file%
)

REM Get Memory
echo - Memory
FOR /F "tokens=4" %%a in ('systeminfo ^| findstr Physical') do if defined totalMem (set availableMem=%%a) else (set totalMem=%%a)
set totalMem=%totalMem:,=%
set availableMem=%availableMem:,=%
set /a usedMem=totalMem-availableMem
echo Total Memory: %totalMem% >> %file%
echo Used  Memory: %usedMem% >> %file%

FOR /f "tokens=1*delims=:" %%i IN ('fsutil volume diskfree %volume%') DO (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)
FOR /f "tokens=1,2" %%i IN ("%disktotal% %diskavail%") DO SET "disktotal=%%i"& SET "diskavail=%%j"
echo C:\ Total: %disktotal:~0,-9% GB >> %file%
echo C:\ Avail: %diskavail:~0,-9% GB >> %file%
echo done

REM list installed programs
echo | set /p="[*] Getting installed programs... "
SET file="%folder%software.txt"
echo -------------------------------------------- > %file%
echo INSTALLED PROGRAMS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file%  product get name >> nul
echo done

REM list installed programs
FOR /F "tokens=2 delims='='" %%A in ('wmic product get name /value') do SET app=%%A



REM List down all the directories 
echo [*] Getting directories...
SET file="%folder%directories.txt"
REM Simplified Directory listing
echo -------------------------------------------- > %file%
echo DIRECTORY LISTING >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
echo DIRECTORY LISTING (Simplified) >> %file%
echo -------------------------------------------- >> %file%
dir %volume%\ /b /a:d >> %file%
echo - Simplified list
REM List all the directories
echo -------------------------------------------- >> %file%
echo DIRECTORY LISTING (Full)>> %file%
echo -------------------------------------------- >> %file%
dir %volume%\ /b /s /a:d >> %file%
echo - Full list
echo done

REM Get Networking information
echo [*] Getting network info...
SET file="%folder%network.txt"
echo - Interfaces
echo -------------------------------------------- > %file%
echo NETWORKING INFO >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- > %file%
echo INTERFACES >> %file%
echo -------------------------------------------- >> %file%
ipconfig /all >> %file% 
echo -------------------------------------------- >> %file%
echo - Routes
echo ROUTE >> %file%
echo -------------------------------------------- >> %file%
route print >> %file% 
echo -------------------------------------------- >> %file%
echo - ARP table
echo ARP TABLE >> %file%
echo -------------------------------------------- >> %file%
arp -a >> %file% 
echo -------------------------------------------- >> %file%
echo - Network connections
echo [+]NETWORK CONNETIONS >> %file%
echo -------------------------------------------- >> %file%
netstat -ano >> %file% 
echo done

REM Get Tasklist 
echo | set /p="[*] Getting tasklist... "
SET file="%folder%tasklist.txt"
echo -------------------------------------------- > %file%
echo TASKLIST >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
tasklist /V >> %file%
echo done

REM Getting registry info
echo [*] Getting registry info. Please be patient...
reg export HKEY_CLASSES_ROOT "%folder%reg-HKEY_CLASSES_ROOT.txt" /y >> nul
echo - HKEY_CLASSES_ROOT
reg export HKEY_CURRENT_USER "%folder%reg--HKEY_CURRENT_USER.txt" /y >> nul
echo - HKEY_CURRENT_USER
reg export HKEY_LOCAL_MACHINE "%folder%reg-HKEY_LOCAL_MACHINE.txt" /y >> nul
echo - HKEY_LOCAL_MACHINE
reg export HKEY_USERS "%folder%reg-HKEY_USERS.txt" /y >> nul
echo - HKEY_USERS
reg export HKEY_CURRENT_CONFIG "%folder%reg-HKEY_CURRENT_CONFIG.txt" /y >> nul
echo - HKEY_CURRENT_CONFIG
echo done

REM Getting antivirus
echo | set /p="[*] Getting installed antivirus... "
SET file="%folder%antivirus.txt"
echo -------------------------------------------- > %file%
echo ANTIVIRUS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% /namespace:\\root\securitycenter2 path antivirusproduct >> nul
echo done

REM Getting usernames
echo | set /p="[*] Getting local usernames... "
SET file="%folder%users.txt"
echo -------------------------------------------- > %file%
echo USERS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% UserAccount where "LocalAccount=True" >> nul
echo done

REM Getting hotfixes and service packs
echo | set /p="[*] Getting hotfixes and service packs. It may take a while... "
SET file="%folder%hotfixes.txt"
echo -------------------------------------------- > %file%
echo HOTFIXES AND SERVICE PACKS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% qfe >> nul
echo done

REM Getting startup list
echo | set /p="[*] Getting startup list... "
SET file="%folder%startup.txt"
echo -------------------------------------------- > %file%
echo STARTUP LIST >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
wmic /APPEND:%file% startup list full >> nul
echo done

REM Getting current environment variable settings
echo | set /p="[*] Getting environment variables... "
SET file="%folder%environment.txt"
echo -------------------------------------------- > %file%
echo environment VARIABLE SETTINGS >> %file%
echo on Computer: %COMPUTERNAME% >> %file%
echo Current Date and Time: %DATE% %TIME% >> %file%
echo -------------------------------------------- >> %file%
set >> %file%
echo done

::====================================================

goto END

:NOWIN
echo Error...This is not Windows! How could this even be possible?
goto END

:END