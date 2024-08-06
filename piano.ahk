#Requires AutoHotkey v2
SendMode("Input")

; Q  2   W  3   E  R  5   T  6   Y  7   U  I  9   O  0   P  [  A   Z  S   X  D   C  V  G   B  H   N  M  K   ,  L   .  ;  
; 1C 1CS 1D 1DS 1E 1F 1FS 1G 1GS 1A 1AS 1B 2C 2CS 2D 2DS 2E 2F 2FS 2G 2GS 2A 2AS 2B 3C 3CS 3D 3DS 3E 3F 3FS 3G 3GS 3A 3AS

global FileObj, notes, NPS, KEYS, NOTES, Paused

KEYS := Map("1C", "q", "1CS", "2", "1D", "w", "1DS", "3", "1E", "e", "1F", "r", "1FS", "5", "1G", "t", "1GS", "6", "1A", "y", "1AS", "7", "1B", "u", "2C", "i", "2CS", "9", "2D", "o", "2DS", "0", "2E", "p", "2F", "[", "2FS", "a", "2G", "z", "2GS", "s", "2A", "x", "2AS", "d", "2B", "c", "3C", "v", "3CS", "g", "3D", "b", "3DS", "h", "3E", "n", "3F", "m", "3FS", "k", "3G", ",", "3GS", "l", "3A", ".", "3AS", ";", "3B", "/")


if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
    myGui := Constructor()
    myGui.Show("w150 h100")
}
    
Constructor()
{	
    global FileObj, notes, NPS, KEYS, NOTES, Paused
    myGui := Gui()
    WinSetAlwaysOnTop(1, MyGui)
    Edit1 := myGui.Add("Edit", "x8 y8 w90 h21")
    Edit2 := myGui.Add("Edit", "x98 y8 w30 h21")
    LoadFile := myGui.Add("Button", "x8 y30 w120 h23", "Load File")
    PlaySong := myGui.Add("Button", "x8 y53 w40 h23", "Play")
    StopSong := myGui.Add("Button", "x48 y53 w40 h23", "Stop")
    SongPause := myGui.Add("Button", "x88 y53 w40 h23", "Pause")
    Status := myGui.Add("Text", "x8 y87 w120 h11 +0x200", "Paused")
    SongLen := myGui.Add("Text", "x8 y76 w60 h11 +0x200", "0")
    SongTime := myGui.Add("Text", "x68 y76 w60 h11 +0x200", "0")
    Edit2.OnEvent("Change", NPSHandler)
    LoadFile.OnEvent("Click", LoadSong)
    PlaySong.OnEvent("Click", PlayKeys)
    StopSong.OnEvent("Click", StopMusic)
    SongPause.OnEvent("Click", PauseMusic)
    myGui.OnEvent('Close', (*) => ExitApp())
    myGui.Title := "Window"
    SetTimer TimerUpdate, 10
    Paused := false

    notes := []
    
    NPSHandler(*)
    {
        NPS := Edit2.Value
        if (notes.Length > 0){
            SongLen.Value := notes.Length
            ; Round((notes.Length/NPS), 2)
        }
    }

    StopMusic(*)
    {
        Status.Value := "Idle"
    }

    PauseMusic(*)
    {
        Paused := !Paused
    }

    TimerUpdate(*)
    {
        if (Status.Value = "Playing")
        {
            SongTime.Value += 0.01
            SongTime.Value := Round(SongTime.Value, 2)
        }
        if (Status.Value = "Waiting")
        {
            SongTime.Value := 0
        }
    }

    LoadSong(*)
    {
        Status.Value := "Loading"
        FileObj := FileOpen("Songs/" Edit1.Value, "r")
        NPS := Edit2.Value
        notes := []

        temp := true

        while temp
        {
            Line := FileObj.ReadLine()
            subline := SubStr(Line, 1, 1)
            if (subline != ";")
            {
                if (Line = "END")
                {
                    temp := false
                }
                else
                {
                        
                    if (subline = "%")
                    {
                        subline2 := SubStr(Line, 2, 1)
                        if (subline2 > 0){
                            Loop subline2
                                notes.Push "%"
                        }
                        else{
                            notes.Push "%"
                        }
                            
                    }
                    else
                    {
                        notes.Push KEYS[Line]
                    }
                }
            } 
        }
        SongLen.Value := notes.Length
        Status.Value := "Loaded"
    }

    PlayKeys(*)
    {
        Status.Value := "Waiting"
        Sleep(1000)
        Status.Value := "Playing"
        len := notes.Length
        tmp := 0
        Loop notes.Length{
            while (Paused)
            {
                Status.Value := "Paused"
                sleep(50)
            }
            if (Status.Value = "Idle")
            {
                break
            }
            Status.Value := "Playing"
            tmp += 1
            if (notes[tmp] = "%"){
                Sleep(1000/NPS)
            }
            else {
                if (notes[tmp] = "/"){
                    Send("{/}")
                    MouseClick
                    Sleep(1000/NPS)
                }
                else{
                    Send("{" notes[tmp] "}")
                    Sleep(1000/NPS)
                }
                
            }
        }
        Status.Value := "Idle"
    }
        
    return myGui
}

F3::{
    global Paused
    paused := !Paused
}