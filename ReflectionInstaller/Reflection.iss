[Setup]
#define VerDate "Patch 0.2.1"; 
#define AppDonateURL "https://www.donationalerts.com/r/reflectionproject"
#define AppName "."; 
AppID={{E89E8EF6-EBA6-4D66-99E4-3512AF8208JD}
AppName={#AppName}
AppVersion={#VerDate}
AppVerName=Reflection
AppCopyright=Reflection 
AppPublisher=Reflection
AppPublisherURL="https://discord.gg/QpPDGBz8zc"
WindowVisible=no
WindowShowCaption=yes
BackColor=$0C0305
BackSolid=yes


// Directory setup
SourceDir=. 
OutputDir=.\Build
DefaultDirName=\
OutputBaseFilename=Reflection {#VerDate}

// Compression
Compression=lzma2/ultra64
InternalCompressLevel=ultra
CompressionThreads=4
SolidCompression=yes

// Images & Icons
WizardImageFile=Images\Logo200.bmp
WizardSmallImageFile=Images\Logo150.bmp
WizardSizePercent=150,130
SetupIconFile=Icon.ico

// Options
AppendDefaultDirName=no
DirExistsWarning=no
Uninstallable=false
AllowRootDirectory=yes

// Disable pages
DisableWelcomePage=no
DisableProgramGroupPage=yes
DisableReadyPage=yes

// Information page
InfoBeforeFile=Information.rtf
 
[Languages] 
Name: ru; MessagesFile: "compiler:Languages\Russian.isl"

[Types]
Name: custom; Description: Custom installation; Flags: iscustom;

[Components]
Name: Reflection; Description: Установить Reflection Patch версии {#VerDate}; Types: custom; Flags: fixed;

[Files]
Source: SourceFiles\*; DestDir: {app}; Flags: ignoreversion createallsubdirs recursesubdirs; Components: Reflection; 
Source: ISSkin.dll; DestDir: {app}; Flags: dontcopy;
Source: ISSkinU.dll; DestDir: {app}; Flags: dontcopy;
Source: skin.cjstyles; DestDir: {tmp}; Flags: dontcopy;

Source: isgsg.dll; DestDir: {tmp}; Flags: ignoreversion dontcopy nocompression;
Source: splash.png; DestDir: {tmp}; Flags: ignoreversion dontcopy nocompression;
Source: splash.gif; DestDir: {tmp}; Flags: ignoreversion dontcopy nocompression;

Source: "back.bmp"; Flags: dontcopy;

//Source: "MyCursor.cur"; Flags: dontcopy



[Messages]
ClickNext=Reflection %nVersion:{#VerDate}
WelcomeLabel1=Добро пожаловать в программу установки патча к сборке Reflection!
WelcomeLabel2=Патч содержит в себе набор исправлений ошибок ранее скомпилированной сборки, а также материалы промежуточных обновлений. При накоплении достаточного количества материала всё содержимое данного файла формата .exe будет слито с основной сборкой.

[CustomMessages]
ru.GameExist=В указанной директории игра не обнаружена, проверьте правильность пути!
ru.GameNotFound=Steam или GOG версия игры не обнаружена, укажите путь вручную
ru.SteamGameFound=Обнаружена Steam-версия игры, путь установки выбран автоматически
ru.GogGameFound=Обнаружена GOG-версия игры, путь установки выбран автоматически
ru.Information=Внимательно изучите информацию о представленных модификациях
ru.ModsOptions=Выберите опции, которые хотите установить; снимите флажки с опций, устанавливать которые не требуется.%n%nНажмите «Установить», когда будете готовы.
ru.InstallButton=Установить
ru.InstallComplete=Установка успешна
ru.InstallFinish=Комплект модификаций {#SetupSetting("AppVerName")} успешно установлен!
ru.Discord=Discord сервер
ru.Donate=Поддержка разработки
 
[Code]

var 
  c:char;
  i:longint;
  Style: LongInt;
  Hidden: Boolean;

const
  OCR_NORMAL = 32512;
  GWL_STYLE = -16; 
  WS_VISIBLE = $10000000;




var
  OriginalCursor: LongWord;
  FullPath: string;
  GOGFlag: boolean;
  WasHidden: Boolean;
  Cursor: LongWord;


function SetSystemCursor(hcur: LongWord; id: DWORD): BOOL;
  external 'SetSystemCursor@user32.dll stdcall';
function LoadCursorFromFile(lpFileName: string): LongWord;
  external 'LoadCursorFromFileW@user32.dll stdcall';
function CopyIcon(hIcon: LongWord): LongWord;
  external 'CopyIcon@user32.dll stdcall';
function LoadCursor(hInstance: LongWord; lpCursorName: LongWord): LongWord;
  external 'LoadCursorA@user32.dll stdcall';



function GetSteamLibs(FileName: string; var Paths: TArrayOfString): Boolean;
var
  Lines: TArrayOfString;
  i: Integer;
  Line: string;
  p: Integer;
  Key: string;
  Value: string;
  Count: Integer;
  InstallFolderKey: string;
begin
  InstallFolderKey := 'path';
  Result := LoadStringsFromFile(FileName, Lines);
  Count := 0;
  for i := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Trim(Lines[i]);
    if Copy(Line, 1, 1) = '"' then
    begin
      Delete(Line, 1, 1);
      p := Pos('"', Line);
      if p > 0 then
      begin
        Key := Trim(Copy(Line, 1, p - 1));
        Delete(Line, 1, p);
        Line := Trim(Line);
        if (CompareText(Copy(Key, 1, Length(InstallFolderKey)), InstallFolderKey) = 0) and (Line[1] = '"') then
        begin
          Delete(Line, 1, 1);
          p := Pos('"', Line);
          if p > 0 then
          begin
            Value := Trim(Copy(Line, 1, p - 1));
            StringChange(Value, '\\', '\');
            Count := Count + 1;
            SetArrayLength(Paths, Count);
            Paths[Count - 1] := Value;
          end;
        end;
      end;
    end;
  end;
end;

procedure ShowSplashScreen(p1:HWND;p2:AnsiString;p3,p4,p5,p6,p7:integer;p8:boolean;p9:Cardinal;p10:integer);
external 'ShowSplashScreen@files:isgsg.dll stdcall delayload';

function GetWindowLong(hWnd: THandle; nIndex: Integer): LongInt;
  external 'GetWindowLongA@User32.dll stdcall';
function SetTimer(
  hWnd: longword; nIDEvent, uElapse: LongWord; lpTimerFunc: LongWord): LongWord;
  external 'SetTimer@user32.dll stdcall';

function GetGamePath(): string;
var          
  InstallPath: string;
  SteamPath: string;
  SteamConfigFileArray: TArrayOfString;
  SteamLibs: TArrayOfString;
  SteamConfigFilePath: string;
  i: integer;
begin
  // Steam path
  SteamPath := ExpandConstant('{reg:HKLM\Software\Valve\Steam,InstallPath}');
  if SteamPath <> '' then SteamPath := ExpandConstant('{reg:HKLM\Software\Wow6432Node\Valve\Steam,InstallPath}');
  if SteamPath <> '' then SteamPath := ExpandConstant('{pf}\Steam');
  if SteamPath <> '' then SteamConfigFilePath := SteamPath + '\steamapps\libraryfolders.vdf';
  // Default game path
  if FileExists(SteamPath + '\steamapps\common\Space Rangers HD A War Apart\Rangers.exe') then Result := SteamPath + '\steamapps\common\Space Rangers HD A War Apart'
  // Parse Steam libs - sharedconfig.vdf  
  else if FileExists(SteamConfigFilePath) then 
  begin
    if LoadStringsFromFile(SteamConfigFilePath, SteamConfigFileArray) then
    begin
      GetSteamLibs(SteamConfigFilePath, SteamLibs);
      for i := 0 to GetArrayLength(SteamLibs) - 1 do
      begin
        if FileExists(SteamLibs[i] + '\steamapps\common\Space Rangers HD A War Apart\Rangers.exe') then
        begin
          Result := SteamLibs[i] + '\steamapps\common\Space Rangers HD A War Apart';
          break;
        end;
      end;
    end;
  end;
  // Parse GOG
  if (RegQueryStringValue(HKLM, 'Software\GOG.com\Games\1207667113','path', InstallPath)) and (Result = '') and ((FileExists(InstallPath + '\Rangers.exe'))) then 
  begin Result := InstallPath; GOGFlag := true; end
  else if (RegQueryStringValue(HKLM, 'Software\Wow6432Node\GOG.com\Games\1207667113','path', InstallPath)) and (Result = '') and ((FileExists(InstallPath + '\Rangers.exe'))) then
  begin Result := InstallPath; GOGFlag := true; end;

end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if WizardIsComponentSelected('DeleteMods') then
  begin
    ForceDirectories(ExpandConstant('{app}\TempStorageFolder'));
    if not WizardIsComponentSelected('InstallModCFG') then RenameFile(ExpandConstant('{app}\Mods\ModCFG.txt'), ExpandConstant('{app}\TempStorageFolder\ModCFG.txt'));
    RenameFile(ExpandConstant('{app}\Mods\Tweaks\German'), ExpandConstant('{app}\TempStorageFolder\German'));
    RenameFile(ExpandConstant('{app}\Mods\Tweaks\LeoDomikShipsUpdate15'), ExpandConstant('{app}\TempStorageFolder\LeoDomikShipsUpdate15'));
    RenameFile(ExpandConstant('{app}\Mods\Tweaks\LeoDomikShipsUpdate30'), ExpandConstant('{app}\TempStorageFolder\LeoDomikShipsUpdate30'));
    RenameFile(ExpandConstant('{app}\Mods\Tweaks\SR2LoadingScreen'), ExpandConstant('{app}\TempStorageFolder\SR2LoadingScreen'));
    RenameFile(ExpandConstant('{app}\Mods\Tweaks\SR2PQuestStyle'), ExpandConstant('{app}\TempStorageFolder\SR2PQuestStyle'));
    DelTree(ExpandConstant('{app}\Mods\*'), false, true, true);
    ForceDirectories(ExpandConstant('{app}\Mods\Tweaks'));
    if not WizardIsComponentSelected('InstallModCFG') then RenameFile(ExpandConstant('{app}\TempStorageFolder\ModCFG.txt'), ExpandConstant('{app}\Mods\ModCFG.txt'));
    RenameFile(ExpandConstant('{app}\TempStorageFolder\German'), ExpandConstant('{app}\Mods\Tweaks\German'));
    RenameFile(ExpandConstant('{app}\TempStorageFolder\LeoDomikShipsUpdate15'), ExpandConstant('{app}\Mods\Tweaks\LeoDomikShipsUpdate15'));
    RenameFile(ExpandConstant('{app}\TempStorageFolder\LeoDomikShipsUpdate30'), ExpandConstant('{app}\Mods\Tweaks\LeoDomikShipsUpdate30'));
    RenameFile(ExpandConstant('{app}\TempStorageFolder\SR2LoadingScreen'), ExpandConstant('{app}\Mods\Tweaks\SR2LoadingScreen'));
    RenameFile(ExpandConstant('{app}\TempStorageFolder\SR2PQuestStyle'), ExpandConstant('{app}\Mods\Tweaks\SR2PQuestStyle'));
    RemoveDir(ExpandConstant('{app}\TempStorageFolder'));
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean; 
begin 
  Result := True; 
  if CurPageID = wpSelectDir then 
  begin 
    if (FileSearch('Rangers.exe', ExpandConstant('{app}')) = '') then  
    begin 
      SuppressibleMsgBox(ExpandConstant('{cm:GameExist}'), mbCriticalError, MB_OK, MB_OK); 
      Result := False; 
    end else Result := True; 
  end; 
end;

// Importing LoadSkin API from ISSkin.DLL
procedure LoadSkin(lpszPath: String; lpszIniFileName: String);
external 'LoadSkin@files:isskinu.dll stdcall';

// Importing UnloadSkin API from ISSkin.DLL
procedure UnloadSkin();
external 'UnloadSkin@files:isskinu.dll stdcall';

// Importing ShowWindow Windows API from User32.DLL
function ShowWindow(hWnd: Integer; uType: Integer): Integer;
external 'ShowWindow@user32.dll stdcall';

function InitializeSetup(): Boolean;
begin
  ExtractTemporaryFile('skin.cjstyles');
  LoadSkin(ExpandConstant('{tmp}\skin.cjstyles'), '');
  Result := True;
end; 




procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
  Style: LongInt;
  Hidden: Boolean;
begin
  Style := GetWindowLong(WizardForm.Handle, GWL_STYLE);
  Hidden := (Style and WS_VISIBLE) = 0;
  SetSystemCursor(OriginalCursor, OCR_NORMAL);
  OriginalCursor := CopyIcon(LoadCursor(0, OCR_NORMAL));
  
  WasHidden := Hidden;
  ShellExec('open', '{#SetupSetting("AppPublisherURL")}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure URLDonateOnClick(Sender: TObject);
var
  ErrorCode: Integer;
  Style: LongInt;
  Hidden: Boolean;
begin
  Style := GetWindowLong(WizardForm.NextButton.Handle, GWL_STYLE);
  Hidden := (Style and WS_VISIBLE) = 0;
  SetSystemCursor(OriginalCursor, OCR_NORMAL);
  OriginalCursor := CopyIcon(LoadCursor(0, OCR_NORMAL));
  WasHidden := Hidden;
  ShellExec('open', '{#AppDonateURL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure ShiftDown(Control: TControl; DeltaY: Integer);
begin
  Control.Top := Control.Top + DeltaY;
end;

procedure ShiftRight(Control: TControl; DeltaX: Integer);
begin
  Control.Left := Control.Left + DeltaX;
end;

procedure ShiftDownAndRight(Control: TControl; DeltaX, DeltaY: Integer);
begin
  ShiftDown(Control, DeltaY);
  ShiftRight(Control, DeltaX);
end;

procedure GrowDown(Control: TControl; DeltaY: Integer);
begin
  Control.Height := Control.Height + DeltaY;
end;

procedure GrowRight(Control: TControl; DeltaX: Integer);
begin
  Control.Width := Control.Width + DeltaX;
end;

procedure GrowRightAndDown(Control: TControl; DeltaX, DeltaY: Integer);
begin
  GrowRight(Control, DeltaX);
  GrowDown(Control, DeltaY);
end;

procedure GrowRightAndShiftDown(Control: TControl; DeltaX, DeltaY: Integer);
begin
  GrowRight(Control, DeltaX);
  ShiftDown(Control, DeltaY);
end;

procedure GrowWizard(DeltaX, DeltaY: Integer);
begin
  GrowRightAndDown(WizardForm, DeltaX, DeltaY);

  with WizardForm do
  begin
    GrowRightAndShiftDown(Bevel, DeltaX, DeltaY);
    ShiftDownAndRight(CancelButton, DeltaX, DeltaY);
    ShiftDownAndRight(NextButton, DeltaX, DeltaY);
    ShiftDownAndRight(BackButton, DeltaX, DeltaY);
    GrowRightAndDown(OuterNotebook, DeltaX, DeltaY);
    GrowRight(BeveledLabel, DeltaX);

    { WelcomePage }
    GrowDown(WizardBitmapImage, DeltaY);
    GrowRight(WelcomeLabel2, DeltaX);
    GrowRight(WelcomeLabel1, DeltaX);

    { InnerPage }
    GrowRight(Bevel1, DeltaX);
    GrowRightAndDown(InnerNotebook, DeltaX, DeltaY);

    { LicensePage }
    ShiftDown(LicenseNotAcceptedRadio, DeltaY);
    ShiftDown(LicenseAcceptedRadio, DeltaY);
    GrowRightAndDown(LicenseMemo, DeltaX, DeltaY);
    GrowRight(LicenseLabel1, DeltaX);

    { SelectDirPage }
    GrowRightAndShiftDown(DiskSpaceLabel, DeltaX, DeltaY);
    ShiftRight(DirBrowseButton, DeltaX);
    GrowRight(DirEdit, DeltaX);
    GrowRight(SelectDirBrowseLabel, DeltaX);
    GrowRight(SelectDirLabel, DeltaX);

    { SelectComponentsPage }
    GrowRightAndShiftDown(ComponentsDiskSpaceLabel, DeltaX, DeltaY);
    GrowRightAndDown(ComponentsList, DeltaX, DeltaY);
    GrowRight(TypesCombo, DeltaX);
    GrowRight(SelectComponentsLabel, DeltaX);

    { SelectTasksPage }
    GrowRightAndDown(TasksList, DeltaX, DeltaY);
    GrowRight(SelectTasksLabel, DeltaX);

    { ReadyPage }
    GrowRightAndDown(ReadyMemo, DeltaX, DeltaY);
    GrowRight(ReadyLabel, DeltaX);

    { InstallingPage }
    GrowRight(FilenameLabel, DeltaX);
    GrowRight(StatusLabel, DeltaX);
    GrowRight(ProgressGauge, DeltaX);

    { MainPanel }
    GrowRight(MainPanel, DeltaX);
    ShiftRight(WizardSmallBitmapImage, DeltaX);
    GrowRight(PageDescriptionLabel, DeltaX);
    GrowRight(PageNameLabel, DeltaX);

    { FinishedPage }
    GrowDown(WizardBitmapImage2, DeltaY);
    GrowRight(RunList, DeltaX);
    GrowRight(FinishedLabel, DeltaX);
    GrowRight(FinishedHeadingLabel, DeltaX);
  end;
end;

{
procedure HiddenTimerProc(H: LongWord; Msg: LongWord; IdEvent: LongWord; Time: LongWord);
var
  Hidden: Boolean;
  Style: LongInt;
  PathToCursorFile: string;
begin
  Style := GetWindowLong(WizardForm.Handle, GWL_STYLE);
  Hidden := (Style and WS_VISIBLE) = 0;
  if Hidden and not WasHidden then
  begin
    SetSystemCursor(OriginalCursor, OCR_NORMAL);
    OriginalCursor := CopyIcon(LoadCursor(0, OCR_NORMAL));
  end
    else
  if not Hidden and WasHidden then
  begin
  }
  {
    ExtractTemporaryFile('MyCursor.cur')
    PathToCursorFile := ExpandConstant('{tmp}{\MyCursor.cur');
    Cursor := LoadCursorFromFile(PathToCursorFile);
    SetSystemCursor(Cursor, OCR_NORMAL);
  end;
  WasHidden := Hidden;
end;
}

procedure InitializeWizard;
var
  URLLabel: TNewStaticText;
  BackgroundImage: TBitmapImage;
  PathToCursorFile: string;
begin
  // Remember the original custom
  OriginalCursor := CopyIcon(LoadCursor(0, OCR_NORMAL));

  // Load our cursor
  //ExtractTemporaryFile('MyCursor.cur')
  //PathToCursorFile := ExpandConstant('{tmp}\MyCursor.cur');
  //Cursor := LoadCursorFromFile(PathToCursorFile);
  //SetSystemCursor(Cursor, OCR_NORMAL);

  //WasHidden := False;
  //SetTimer(0, 0, 500, CreateCallback(@HiddenTimerProc));

  URLLabel := TNewStaticText.Create(WizardForm);
  URLLabel.Caption := ExpandConstant('{cm:Donate}');
  URLLabel.Cursor := crHand;
  URLLabel.OnClick := @URLDonateOnClick;
  URLLabel.Parent := WizardForm;
  URLLabel.Font.Style := URLLabel.Font.Style + [fsBold];
  URLLabel.Font.Color := clGray;
  URLLabel.Top := WizardForm.ClientHeight - URLLabel.Height - ScaleY(-92);
  URLLabel.Left := ScaleX(20);

  URLLabel := TNewStaticText.Create(WizardForm);
  URLLabel.Caption := ExpandConstant('{cm:Discord}');
  URLLabel.Cursor := crHand;
  URLLabel.OnClick := @URLLabelOnClick;
  URLLabel.Parent := WizardForm;
  URLLabel.Font.Style := URLLabel.Font.Style + [fsBold];
  URLLabel.Font.Color := clGray;
  URLLabel.Top := WizardForm.ClientHeight - URLLabel.Height - ScaleY(-92);
  URLLabel.Left := ScaleX(190);
  

  
  

  


  with WizardForm.InfoBeforeMemo do
  begin
    Color := clBlack;
  end;

  with WizardForm.InfoBeforeClickLabel do
  begin
    Caption := ExpandConstant('{cm:Information}');
  end;

  with WizardForm.SelectDirLabel do
  begin
    Font.Style := [fsBold];
  end;

  

  with WizardForm.FinishedHeadingLabel do
  begin
    Caption := ExpandConstant('{cm:InstallComplete}');
  end;

  with WizardForm.WizardSmallBitmapImage do
  begin
    Left := ScaleX(-300);
    Width := ScaleX(800);
    Height := ScaleY(100);
  end;

  with WizardForm.PageNameLabel do
  begin
    Visible := False;
  end;

  with WizardForm.PageDescriptionLabel do
  begin
    Visible := False;
  end;

end;
 
procedure CurPageChanged(CurPageID: Integer);
begin

  if CurPageID = wpWelcome then
  begin
    FullPath := GetGamePath();
    if (FullPath = '') then 
    begin
      WizardForm.DirEdit.Text := 'C:\'; 
      WizardForm.SelectDirLabel.Caption := ExpandConstant('{cm:GameNotFound}'); 
    end 
    else if (FullPath <> '') and (GOGFlag = false) then 
    begin
      WizardForm.DirEdit.Text := FullPath; 
      WizardForm.SelectDirLabel.Caption := ExpandConstant('{cm:SteamGameFound}');
    end 
    else if (FullPath <> '') and (GOGFlag = true) then 
    begin
      WizardForm.DirEdit.Text := FullPath;
      WizardForm.SelectDirLabel.Caption := ExpandConstant('{cm:GogGameFound}');
    end;
  end;

  if CurPageID = wpSelectComponents then 
  begin 
    WizardForm.NextButton.Caption := ExpandConstant('{cm:InstallButton}');
    WizardForm.ComponentsList.Checked[0] := True;
  end;
  
  if CurPageID = wpFinished then 
  begin
    WizardForm.FinishedLabel.Caption := ExpandConstant('{cm:InstallFinish}');
  end;
    
end;

procedure DeinitializeSetup();
begin
  SetSystemCursor(OriginalCursor, OCR_NORMAL);

  // Hide Window before unloading skin so user does not get
  // a glimpse of an unskinned window before it is closed.
  
  ShowWindow(StrToInt(ExpandConstant('{wizardhwnd}')), 0);
  UnloadSkin();
end; 
