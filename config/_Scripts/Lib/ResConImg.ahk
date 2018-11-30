/*  ResConImg
 *    By kon
 *    Updated November 2, 2015
 *    http://ahkscript.org/boards/viewtopic.php?f=6&t=2505&p=13640#p13640
 *
 *  Resize and convert images. png, bmp, jpg, tiff, or gif.
 *
 *  Requires Gdip.ahk in your Lib folder or #Included. Gdip.ahk is available at:
 *      http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
 *     
 *  ResConImg( OriginalFile             ;- Path of the file to convert
 *           , NewWidth                 ;- Pixels (Blank = Original Width)
 *           , NewHeight                ;- Pixels (Blank = Original Height)
 *           , NewName                  ;- New file name (Blank = "Resized_" . OriginalFileName)
 *           , NewExt                   ;- New file extension can be png, bmp, jpg, tiff, or gif (Blank = Original extension)
 *           , NewDir                   ;- New directory (Blank = Original directory)
 *           , PreserveAspectRatio      ;- True/false (Blank = true)
 *           , BitDepth)                ;- 24/32 only applicable to bmp file extension (Blank = 24)
 */
ResConImg(OriginalFile, NewWidth:="", NewHeight:="", NewName:="", NewExt:="", NewDir:="", PreserveAspectRatio:=true, BitDepth:=24) {
    SplitPath, OriginalFile, SplitFileName, SplitDir, SplitExtension, SplitNameNoExt, SplitDrive
    pBitmapFile := Gdip_CreateBitmapFromFile(OriginalFile)                  ; Get the bitmap of the original file
    Width := Gdip_GetImageWidth(pBitmapFile)                                ; Original width
    Height := Gdip_GetImageHeight(pBitmapFile)                              ; Original height
    NewWidth := NewWidth ? NewWidth : Width
    NewHeight := NewHeight ? NewHeight : Height
    NewExt := NewExt ? NewExt : SplitExtension
    if SubStr(NewExt, 1, 1) != "."                                          ; Add the "." to the extension if required
        NewExt := "." NewExt
    NewPath := ((NewDir != "") ? NewDir : SplitDir)                         ; NewPath := Directory
            . "\" ((NewName != "") ? NewName : "Resized_" SplitNameNoExt)       ; \File name
            . NewExt                                                            ; .Extension
    if (PreserveAspectRatio) {                                              ; Recalcultate NewWidth/NewHeight if required
        if ((r1 := Width / NewWidth) > (r2 := Height / NewHeight))          ; NewWidth/NewHeight will be treated as max width/height
            NewHeight := Height / r1
        else
            NewWidth := Width / r2
    }
    pBitmap := Gdip_CreateBitmap(NewWidth, NewHeight                        ; Create a new bitmap
    , (SubStr(NewExt, -2) = "bmp" && BitDepth = 24) ? 0x21808 : 0x26200A)   ; .bmp files use a bit depth of 24 by default
    G := Gdip_GraphicsFromImage(pBitmap)                                    ; Get a pointer to the graphics of the bitmap
    Gdip_SetSmoothingMode(G, 4)                                             ; Quality settings
    Gdip_SetInterpolationMode(G, 7)
    Gdip_DrawImage(G, pBitmapFile, 0, 0, NewWidth, NewHeight)               ; Draw the original image onto the new bitmap
    Gdip_DisposeImage(pBitmapFile)                                          ; Delete the bitmap of the original image
    Gdip_SaveBitmapToFile(pBitmap, NewPath)                                 ; Save the new bitmap to file
    Gdip_DisposeImage(pBitmap)                                              ; Delete the new bitmap
    Gdip_DeleteGraphics(G)                                                  ; The graphics may now be deleted
}

#include %A_LineFile%\..\Gdip_All.ahk
