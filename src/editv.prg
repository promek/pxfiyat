#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "memoedit.ch"

#define        GO_AHEAD            1
#define        ERASE_OK            0
#define        RENAME_OK           0
#xcommand      STABILIZE <x> =>    DISPBEGIN();;
                                   WHILE !(<x>:stabilize());;
                                   END;;
                                   DISPEND()
#xtranslate    .filename     =>    \[1\]
#xtranslate    .filesize     =>    \[2\]
#xtranslate    .filedate     =>    \[3\]
#xtranslate    .filetime     =>    \[4\]
#xtranslate    .fileattrib   =>    \[5\]

#xtranslate    .boxTitle     =>    \[1\]
#xtranslate    .boxMessage   =>    \[2\]
#xtranslate    .boxFileName  =>    \[3\]
#xtranslate    .boxFirstOpt  =>    \[4\]
#xtranslate    .boxSecondOpt =>    \[5\]

FUNCTION EditView()
   MEMVAR cWork
   LOCAL b, cVal
   LOCAL nTop, nLeft, nBottom, nRight
   LOCAL cColour, nCursor, lScore, cScr
   LOCAL nKey, column
   LOCAL nSubscript, aDir, nLen, k
   LOCAL lReconfigure, nMaxRow
   PRIVATE cWork,nSatir,nSutun

   IF EMPTY(GETENV("COMSPEC"))
      ALERT( "CRITICAL ERROR: COMSPEC environmental "+;
             "variable not set",;
            { "Quit" } )
      QUIT

   ENDIF

   lReconfigure := .F.
   nMaxRow      := MAXROW()

   SETBLINK(.F.)
   lScore  := SET(_SET_SCOREBOARD, .F.)
   nCursor := SETCURSOR(SC_NONE)
   cColour := SETCOLOR("BG+/B")
   cScr    := SAVESCREEN( 0, 0, nMaxRow, 79)

   nTop    :=  2
   nLeft   := 29
   nBottom := 22
   nRight  := 52


   PaintScr( nTop, nLeft,nBottom, nRight )

   nSubscript := 1
   k          := 0
   nLen       := 1

   aDir := MyDirec(@nLen)
   If Len(aDir)=0
      Alert("Teklif dosyasç bulunamadç!",{"Tamam"})
      SETCURSOR(nCursor)
      SETCOLOR(cColour)
      RESTSCREEN( 0, 0, nMaxRow, 79, cScr)
      Return(NIL)
   Endif
   b := TBrowseNew( nTop+2, nLeft+1, nBottom-2, nRight-1 )
   b:colSep    := CHR(179)
   b:colorSpec := "BG+/B,W+/BG,N,N,GR+/W"
   b:headSep:="ƒ"
   b:footSep:="ƒ"
   b:skipBlock := {|x| ;
                  k := IF(ABS(x) >= IF(x >= 0,;
                  nLen - nSubscript, nSubscript - 1),;
                  IF(x >= 0, nLen - nSubscript,1 ;
                  - nSubscript),;
                  x), nSubscript += k,;
                  k }
   b:goTopBlock    := {|| nSubscript := 1}
   b:goBottomBlock := {|| nSubscript := nLen}

   column := TBColumnNew(,{|| aDir[nSubscript,1]})
   column:width := 12
   b:addColumn(column)
   column := TBColumnNew(,{|| aDir[nSubscript,3]})
   column:width :=  9
   b:addColumn(column)

   b:freeze := 3
   WHILE .T.
      b:colorRect({b:rowPos, 1,;
                   b:rowPos, b:colCount}, {1, 1})

      STABILIZE b

      IF b:stable()
         b:colorRect({b:rowPos, 1,;
                    b:rowPos, b:colCount}, {2, 2})
         DISPBEGIN()
         @ nBottom-1,nLeft+1      SAY ;
                     EVAL((b:getColumn(1)):block)
         @ nBottom-1,nLeft+14 SAY ;
                     EVAL((b:getColumn(2)):block)
         DISPEND()

/*         nKey := WhatKey( , {|| DEVPOS( nTop - 2, ;
                                nRight - 7 ),;
                                DEVOUT( TIME(), "N/BG" ) } )*/
         nKey := Inkey(0)
         IF !TBMoveCursor(nKey, b)
            IF nKey == K_ESC .OR. nKey == K_F10 .OR.;
               nKey == K_ALT_F4 .OR. nKey == K_ALT_X
                  SETCURSOR(nCursor)
                  SETCOLOR(cColour)
                  RESTSCREEN( 0, 0, nMaxRow, 79, cScr)
                  EXIT

            ELSEIF nKey == K_F3 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(1)):block))
               cVal := UnPad( b )
               TxtScr:=SaveScreen(0,0,24,79)
               _TEXTVIEW(cVal,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
               RestScreen(0,0,24,79,TxtScr)
            ELSEIF nKey == K_F4 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(1)):block))
               ShowIt( UnPad( b ), .T.)

            ELSEIF nKey == K_F5 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(1)):block))
               lReconfigure := CopyOK( UnPad( b ) )

            ELSEIF nKey == K_F6 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(1)):block))
               cVal := UnPad( b )
               IF !("main.exe" $ cVal)
                  lReconfigure := RenameOK( UnPad( b ) )
               ENDIF

            ELSEIF nKey == K_F8 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(1)):block))
               lReconfigure := DeleteOK( UnPad( b ) )

            ENDIF

         ENDIF
         IF lReconfigure
            lReconfigure := .F.
            aDir := MyDirec(@nLen)
            If Len(aDir)=0
               Alert("Teklif dosyasç bulunamadç!",{"Tamam"})
               SETCURSOR(nCursor)
               SETCOLOR(cColour)
               RESTSCREEN( 0, 0, nMaxRow, 79, cScr)
               Return(NIL)
            Endif
            b:goTop()
            b:configure()
            b:refreshAll()
         ENDIF

      ENDIF

   END
   RETURN (NIL)
//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION PadIt(aArray, nArrlen)
   LOCAL nPos, i, nALen, nNewALen
   LOCAL cTemp

   i := 1
   WHILE i <= LEN(aArray)
      IF ("D" $ aArray[i].fileattrib)
         IF (aArray[i].filename == ".")
            ADEL(aArray, i)
            aArray := ASIZE(aArray, LEN(aArray) - 1)
            LOOP

         ELSEIF (aArray[i].filename == "..")
            aArray[i].filename := PADR(aArray[i].filename, 12)
            aArray[i].filesize := CHR(16) + "UP--DIR" +;
                                  CHR(17)

         ELSE
            aArray[i].filesize := CHR(16) + "SUB-DIR" +;
                                  CHR(17)
            nPos := AT(".",aArray[i].filename)
            IF nPos != 0
               aArray[i].filename := ;
                       PADR(SUBSTR(aArray[i].filename,;
                             1, nPos - 1), 9) +;
                       PADR(SUBSTR(aArray[i].filename,;
                             nPos + 1, 3), 3)
            ELSE
               aArray[i].filename := PADR(aArray[i].filename, 12)

            ENDIF

         ENDIF

      ELSE
         nPos := AT(".",aArray[i].filename)
         IF nPos != 0
            aArray[i].filename := ;
                    PADR(SUBSTR(aArray[i].filename,;
                          1, nPos - 1), 9) +;
                    PADR(SUBSTR(aArray[i].filename,;
                          nPos + 1, 3), 3)
         ELSE
            aArray[i].filename := PADR(aArray[i].filename, 12)

         ENDIF
         aArray[i].filename := LOWER(aArray[i].filename)
         aArray[i].filesize := STR(aArray[i].filesize, 9)

      ENDIF
      aArray[i].filetime := SUBSTR(aArray[i].filetime, 1, 5)
      cTemp := VAL(SUBSTR(aArray[i].filetime, 1, 2))
      aArray[i].filetime += IF(cTemp >= 12 .AND. cTemp <= 23,;
                             "p", "a")
      cTemp := IF(cTemp > 12, cTemp % 12, cTemp)
      cTemp := STR(cTemp, 2, 0)
      aArray[i].filetime := cTemp +;
                          SUBSTR(aArray[i].filetime, 3, 4)
      i++
   END
   nArrLen := LEN(aArray)
   RETURN (NIL)

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION MyDirec(nLen)
   LOCAL nStartAt := 1
   LOCAL aDir

   aDir := DIRECTORY("*.txt", "HSD")
   nLen := LEN(aDir)

   ASORT(aDir,,, {|x,y| x.fileattrib == "D"})

   AEVAL(aDir, {|x,i| nStartAt := ;
               IF("D" $ x.fileattrib, i, nStartAt)})

   ASORT(aDir,1, nStartAt, {|x,y| x.filename < y.filename})
   nStartAt++

   ASORT(aDir, nStartAt,, {|x,y| x.filename < y.filename})

   PadIt(aDir, @nLen)
   RETURN (aDir)

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION PaintScr( nTop, nLeft,nBottom, nRight )
   LOCAL nMaxRow := MAXROW()

   _Win(nTop,nLeft,nBottom,nRight,"15/1",1,1)
   @ nTop+1,nLeft+1 SAY "Dosya Adç"   COLOR "GR+/B"
   @ nTop+1,nLeft+14 SAY "Kayçt T."   COLOR "GR+/B"

 _TusYaz(24,1,{"~F3~-òncele","~F4~-DÅzenle",;
               "~F5~-Kopyala","~F6~-Deßiütir","~F8~-Sil","~ESC~-Äçkçü"})
   RETURN (NIL)

//////////////////////////////////////////////////////////////////////////////
FUNCTION DeleteOk(cFileName)
   LOCAL nOpt, lStatus := .F.
   nOpt := Alert(cFileName+" Dosyasç silinsin mi?",{"Hayçr","Evet"})
   IF nOpt == 2
      lStatus := (FERASE(cFileName) == ERASE_OK)
   ENDIF
RETURN (lStatus)
//////////////////////////////////////////////////////////////////////////////
FUNCTION RenameOK(cFileName)
   LOCAL cNew, lStatus := .F.
   cNew := GetAlert(cFileName+" Dosya adç deßiüsin mi?",8,{"Tamam","Vazgeá"})

   IF !EMPTY(cNew)
      cNew:=cNew+".TXT"
      lStatus := (FRENAME(cFileName, cNew) == RENAME_OK)

   ENDIF
RETURN (lStatus)
//////////////////////////////////////////////////////////////////////////////
FUNCTION CopyOK(cFileName)
   LOCAL cName, lRet := .T.

   cName := GetAlert(cFileName+" Dosyasç kopyalansçn mç?",8,{"Tamam","Vazgeá"})

   IF !EMPTY(cName)
      cName := cName+".TXT"
      COPY FILE (cFileName) TO (cName)
      RETURN (lRet)

   ENDIF
RETURN (!lRet)
//////////////////////////////////////////////////////////////////////////////
FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aKeys :=;
      {  K_DOWN     , {|b| b:down()}     ,;
         K_UP        , {|b| b:up()}       ,;
         K_PGDN      , {|b| b:pageDown()} ,;
         K_PGUP      , {|b| b:pageUp()}   ,;
         K_CTRL_PGUP , {|b| b:goTop()}    ,;
         K_CTRL_PGDN , {|b| b:goBottom()} ,;
         K_RIGHT     , {|b| b:right()}    ,;
         K_LEFT      , {|b| b:left()}     ,;
         K_HOME      , {|b| b:home()}     ,;
         K_END       , {|b| b:end()}      ,;
         K_CTRL_LEFT , {|b| b:panLeft()}  ,;
         K_CTRL_RIGHT, {|b| b:panRight()} ,;
         K_CTRL_HOME , {|b| b:panHome()}  ,;
         K_CTRL_END  , {|b| b:panEnd()}    }

   nFound := ASCAN(aKeys, nKey)
   IF (nFound != 0)
      EVAL(aKeys[++nFound], oObj)
   ENDIF
   RETURN (nFound != 0)     // .T. or .F.
//////////////////////////////////////////////////////////////////////////////
FUNCTION CentreIt(cString, nLine, nCol1, nCol2)
   LOCAL nCalc

   nCalc := nCol1 + INT(((nCol2 - nCol1) -;
            LEN(cString)) / 2) + 1
   @ nLine,nCalc SAY cString

   RETURN (NIL)
//////////////////////////////////////////////////////////////////////////////
FUNCTION UnPad( bObj )
   LOCAL cVal, cExt
   cVal := EVAL((bObj:getColumn(1)):block)
   cExt := ALLTRIM(SUBSTR(cVal, 10, 3))
   cVal := ALLTRIM(SUBSTR(cVal, 1, 8)) +;
         IF(EMPTY(cExt), "", "." + cExt)
   RETURN (cVal)

//////////////////////////////////////////////////////////////////////////////
/*
FUNCTION WhatKey( nWait, bBlock)
   LOCAL nKey
   nWait  := IF(nWait == NIL, .1, nWait)
   bBlock := IF(bBlock == NIL, {|| .F.}, bBlock)

   WHILE ((nKey := INKEY(nWait)) == 0)
      EVAL(bBlock)
   END
   RETURN (nKey)
*/
//////////////////////////////////////////////////////////////////////////////
FUNCTION ShowIt(cFileName, lEditMode)
   LOCAL cContents
   LOCAL cScr, cClr, nCurs
   Private lTus

   cContents := MEMOREAD(cFileName)
   cScr  := SAVESCREEN( 0, 0, MAXROW(), 79)
   cClr  := SETCOLOR("BG+/B")
   lTus=.F.

   IF lEditMode
      nCurs := SETCURSOR(SC_NORMAL)
   ENDIF
   @  0, 0 SAY SPACE(80) COLOUR "N/W"
   @  0, 0 SAY IF(lEditMode, "Dosya: ", "Dosya: ") +;
               cFileName COLOUR "N/W" //"N/BG"
   @  0,60 SAY "Satçr:" COLOUR "N/W"  //"N/BG"
   @  0,71 SAY "Sutun:" COLOUR "N/W"  //"N/BG"
   _TusYaz(24,1,{"~F2~-Kaydet","~F5~-Yazdçr","~ESC~-Äçkçü"})
   Do While .T.
      cMemo:=MEMOEDIT( cContents, 1, 0, MAXROW() - 1, 79,;
                       lEditMode, "memovew", 250 )
   Do Case
      Case Lastkey()=K_F5
           nCho:=Alert("Yazçcçyç hazçrlayçp ENTER tuüuna basçnçz.",{"Tamam","Vazgeá"})
           If nCho=1
              Dur=PRN_OFF()
              If Dur="Kapali"
                 Loop
              Endif
              Set Device To Print
              nLines:=MLCOUNT(cMemo,80,1,.T.)
              For nLine=1 to nLines
                  @ Prow()+1,0 Say MEMOLINE(cMemo,80,nLine,1,.T.)
              Next
              Eject
              Set Device To Screen
           Endif
      Case Lastkey()=K_F2
           cContents=cMemo
           MemoWrit(cFilename,cMemo)
           lTus=.F.
      Case Lastkey()=K_ESC
           If lTus=.T.
              nCho:=Alert("Kaydetmeden áçkçlsçn mç?",{"Hayçr","Evet"})
              If nCho=2
                 Exit
              Else
                 cContents=cMemo
              Endif
           Else
              Exit
           Endif
      Case Lastkey()=K_ALT_C
           MEMOWRIT("Clipbrd.tmp",cMemo)
      Case Lastkey()=K_ALT_V
           nPosition:=MLCTOPOS(cMemo,250,nSatir,nSutun)
           cContents:=STUFF(cMemo,nPosition,0,MEMOREAD("Clipbrd.tmp"))
           nLines:=MLCOUNT(cMemo,250,1,.T.)
           For nLine=1 to nLines
               Keyboard Chr(K_DOWN)
           Next

           lTus:=.T.
   EndCase
   Enddo
   RESTSCREEN( 0, 0, MAXROW(), 79, cScr)
   SETCOLOR(cClr)
   IF lEditMode
      SETCURSOR(nCurs)
   ENDIF
   RETURN (NIL)
//////////////////////////////////////////////////////////////////////////////
FUNCTION MemoVew( nMode, nLin, nCol )
   LOCAL nKey, nRet

   nRet := ME_DEFAULT
   nKey := LASTKEY()

   IF nMode == ME_IDLE
      @  0,66 SAY nLin PICTURE "9999" COLOUR "N/W"
      @  0,77 SAY nCol PICTURE "999"  COLOUR "N/W"
      nSatir:=nLin
      nSutun:=nCol
      IF (nKey >= 7 .And. nKey <= 9) .Or. (nKey >=32 .And. nKey <= 255)
         lTus=.T.
      Endif
   ELSEIF nMode == ME_UNKEY .OR. nMode == ME_UNKEYX
      IF nKey == K_F2
         nRet:=23
      ENDIF
      If nKey == K_ESC
         nRet:=23
      Endif
      IF nKey == K_F5
         nRet:=23
      Endif
      IF nKey == K_ALT_C
         nRet:=23
      ENDIF
      IF nKey == K_ALT_V
         nRet:=23
      ENDIF

   ENDIF

   RETURN (nRet)
//////////////////////////////////////////////////////////////////////////////

