//////////////////////////////////////////////////////////////////////////
// pxFiyat - Fiyat Listeleri Takip Programı                             //
//                                                                      //
// Copyright (C) 2011 by ibrahim SEN <ibrahim@promek.net>               //
//                                                                      //
// http://pxfiyat.googlecode.com                                        //
//                                                                      //
// This program is free software: you can redistribute it and/or modify //
// it under the terms of the GNU General Public License as published by //
// the Free Software Foundation, either version 3 of the License, or    //
// (at your option) any later version.                                  //
//                                                                      //
// This program is distributed in the hope that it will be useful,      //
// but WITHOUT ANY WARRANTY; without even the implied warranty of       //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        //
// GNU General Public License for more details.                         //
//                                                                      //
// You should have received a copy of the GNU General Public License    //
// along with this program. If not, see <http://www.gnu.org/licenses/>. //
//////////////////////////////////////////////////////////////////////////

//MyBrowse(nTop,nLeft,nBottom,nRHight,Alanlar,Baslik,Picture,UserFunc
//      Kosul Alani,Kosul1,Kosul2,giris durumu,Arama Durumu,Sol Sut. kilit,Sag Sut. Kilit,Cerceve Durumu)
//MyBrowse(0,0,24,79,aAlan,aBasl,aPict,MyFunc,"Tarih",Ilktar,SonTar,.T.,.T.,0,0,.T.)

#include "Common.ch"
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Error.ch"
#define APP_MODE_ON( b )      ( b:cargo := TRUE  )
#define APP_MODE_OFF( b )     ( b:cargo := FALSE )
#define APP_MODE_ACTIVE( b )  ( b:cargo )
//MyBrowse////////////////////////////////////////////////////////////////////
Function Mybrowse
Parameters nTop, nLeft, nBottom, nRight, aAlan, aBasl, aPict, cUserFunc,;
           cAlan, cKosul1, cKosul2, lGetLock, lSearchLock, nLeftLock, nRightLock, lBoxDraw
   LOCAL cColorSave, nCursSave
   LOCAL lSavReadExit := READEXIT( .T. )  // Enable Up/Down as READ exit keys
   Private oB, nKey
   Private lAppend := .F.
   Private nLastKey := 0
   Private nLastRec := 0
   Private Anah := ""
   Public sFound
   Private lMore := TRUE

   If cKosul2=NIL
      cKosul2=cKosul1
   Endif
   If nLeftLock=NIL
      nLeftLock=0
   Endif
   If lGetLock=NIL
      lGetLock=.F.
   Endif

      cScrSave := saveScreen(nTop, nLeft, nBottom, nRight)
/*If lBoxDraw=.T.
   @ nTop, nLeft, nBottom, nRight box "ÚÄ¿³ÙÄÀ³ "
   @ nTop + 2, nLeft say "Ã"
   @ nTop + 2, nRight say "Ž"
Endif
   @ nTop + 1, nLeft + 1 say Space(nRight - nLeft - 1)
   oB := TBrowseDB(nTop + 1, nLeft + 1, nBottom - 1, nRight - 1)
If lBoxDraw=.T.
   oB:headSep := "Ä"   //ÄÂÄ
Endif
   oB:ColSep := "³"
*/

@ nTop + 1, nLeft + 1 say Space(nRight - nLeft - 1)
oB := TBrowseDB(nTop + 1, nLeft + 1, nBottom - 1, nRight - 1)
If lBoxDraw=.T.
      @ nTop, nLeft, nBottom, nRight box "ÚÄ¿³ÙÄÀ³ "
      ColorWin(nBottom+1,nLeft+1,nBottom+1,nRight+1,"W/N")
      ColorWin(nTop+1,nRight+1,nBottom+1,nRight+1,"W/N")
      @ nTop + 2, nLeft say "Ã"
      @ nBottom - 1, nLeft say "Ã"
      @ nTop + 2, nRight say "Ž"
      @ nBottom - 1, nRight say "Ž"
      oB:headSep := "Ä"
      oB:FootSep := "Ä"
Endif
      oB:ColSep := "³"

      If cKosul1!=NIL
         Seek (cKosul1)
         sFound=Found()
         lBof={|a,b,c|Bof() .Or. a<b}
         lEof={|a,b,c|Eof() .Or. a>c}
      Else
         sFound=.T.
         lBof={|a,b,c|Bof()}
         lEof={|a,b,c|Eof()}
      Endif
      For J=1 To Len(aAlan)
          aAlanl=aAlan[J]
          If aBasl!=NIL
             aBaslk=aBasl[J]
             If lGetLock=.T.
                oB:addColumn( TBColumnNew(aBaslk, FieldBlock(aAlanl) ))
             Else
                oB:addColumn( TBColumnNew(aBaslk, &("{||"+aAlanl+"}") ))
             Endif
          Else
             If lGetLock=.T.
                oB:addColumn( TBColumnNew("",FieldBlock(aAlanl) ))
             Else
                oB:addColumn( TBColumnNew("", &("{||"+aAlanl+"}") ))
             Endif
          Endif
      Next
   APP_MODE_OFF( oB )
   oB:skipBlock := { |x| Skipper( x, oB ) }

   FormatColumns( oB )
   AddRecno(oB)
   dispbegin()
   cColorSave := setcolor( "N/N" )
   setcolor( "W/W" )
   dispend()
   setcolor( cColorSave )
   nCursSave := setcursor( SC_NONE )
   while lMore
      if ( oB:colPos <= oB:freeze )
         oB:colPos := ( oB:freeze + nLeftLock )
      endif
      oB:forceStable()

      if ( oB:hitTop .or. oB:hitBottom )
         tone( 125, 0 )
      Endif
      nKey := inkey( 0 )
      applyKey( oB, nKey )
   enddo
   setcursor( nCursSave )
   READEXIT( lSavReadExit )
   oB:DEHILITE()
   RETURN

//Skipper/////////////////////////////////////////////////////////////////////
STATIC FUNCTION Skipper( nSkip, oB )

   LOCAL lAppend := APP_MODE_ACTIVE( oB )
   LOCAL i       := 0
   do case
   case ( nSkip == 0 .or. lastrec() == 0 )
      dbSkip( 0 )
   case ( nSkip > 0 .and. !Eval(lEof,&cAlan,cKosul1,cKosul2) )
      while ( i < nSkip )           // Skip Foward
         dbskip( 1 )
          If Eval(lEof,&cAlan,cKosul1,cKosul2)
             iif( lAppend, i++, dbskip( -1 ) )
             exit
          end
         i++
      enddo
   case ( nSkip < 0 )
      while ( i > nSkip )           // Skip backward
         dbskip( -1 )
          If Eval(lBof,&cAlan,cKosul1,cKosul2)
             if !bof()
                skip
             endif
            exit
          end
         i--
      enddo
   endcase
   RETURN i
//ApplyKey////////////////////////////////////////////////////////////////////
STATIC Function ApplyKey( oB, nKey )
   do case

   case nKey == K_ALT_S
        ScrSaver()

   case nKey == K_DOWN
      If sFound=.T.
         APP_MODE_OFF( oB )
         If !Eval(lEof,&cAlan,cKosul1,cKosul2)
            oB:down()
         Endif
      Endif

   case nKey == K_UP
      If sFound=.T.
         If !Eval(lBof,&cAlan,cKosul1,cKosul2)
            oB:up()
         Endif
         if APP_MODE_ACTIVE( oB )
            APP_MODE_OFF( oB )
            oB:refreshAll()
         Endif
      Endif

   case nKey == K_PGDN
      If sFound=.T.
         oB:pageDown()
      Endif
   case nKey == K_PGUP
      If sFound=.T.
         oB:pageUp()
         if APP_MODE_ACTIVE( oB )
            APP_MODE_OFF( oB )
            oB:refreshAll()
         endif
      Endif
   case nKey == K_END //K_CTRL_PGDN
      If sFound=.T.
         APP_MODE_OFF( oB )
         Do While .T.
            Skip +1
            If Eval(lEof,&cAlan,cKosul1,cKosul2)
               Skip -1
               oB:REFRESHALL()
               Exit
           Endif
         Enddo
     Endif
   case nKey == K_HOME //K_CTRL_PGUP
      If sFound=.T.
         APP_MODE_OFF( oB )
         If cKosul1!=NIL
            Seek(cKosul1)
         Else
            Go Top
         Endif
         oB:REFRESHALL()
         oB:PAGEUP()
      Endif

   case nKey == K_RIGHT
      If oB:COLPOS<nRightLock
         oB:right()
      Endif

   case nKey == K_LEFT
         oB:left()

   case nKey == K_CTRL_HOME
      oB:Home()

   case nKey == K_CTRL_END
      oB:End()

//   case nKey == K_HOME
//      oB:home()

//   case nKey == K_END
//      oB:end()

//   case nKey == K_CTRL_LEFT
//      oB:panLeft()

//   case nKey == K_CTRL_RIGHT
//      oB:panRight()

//   case nKey == K_CTRL_HOME
//      oB:panHome()

//   case nKey == K_CTRL_END
//      oB:panEnd()

     case nKey == K_BS
        If lGetLock=.F.
           TArama()
           oB:RefreshAll()
        Endif
//     Case lSearchLock==.T. .And. ((nKey>=32 .And. nKey<=90) .Or. (nKey>=97 .And. nKey<=168)) //122
     Case lSearchLock==.T. .And. (nKey>=32 .And. nKey<=168) //122
 //    Case (nKey>=48 .And. nKey<=90) .Or. (nKey>=97 .And. nKey<=122)
          oCol := oB:getColumn(oB:colPos)
        If VALTYPE(Eval(oCol:Block))="C"
          nLastrec=Recno()
          If nKey=nLastKey
             continue
          Else
             Locate For (Left(Eval(oCol:block),1)=Chr(nKey) .Or. ;
                        Left(Eval(oCol:block),1)=UPPER(Chr(nKey))) .And. IdxKosul()
          Endif
          If Found()
             nLastKey=nKey
             nLastrec=Recno()
          Else
             nLastKey=0
             Go nLastrec
             Go Top
 //            Continue
          Endif
          oB:REFRESHALL()
        Endif
   otherwise
         cDummyFunc := ( cUserFunc + "()" )
         lMore := &cDummyFunc
   endcase

   RETURN
//InsToggle///////////////////////////////////////////////////////////////////
STATIC Function InsToggle()

   if readinsert()
      readinsert( FALSE )
      setcursor( SC_NORMAL )
   else
      readinsert( TRUE )
      setcursor( SC_INSERT )
   endif

   RETURN

//FormatColumn////////////////////////////////////////////////////////////////
STATIC Function FormatColumn( oB )
   LOCAL n
   Local oColumn
   Local xValue


   for n := 1 to oB:colCount
      oColumn := oB:getColumn( n )
      xValue := eval( oColumn:block )

      do case
      case ISNUM( xValue )
          oColumn:picture    := aPict[n]

      case ISCHAR( xValue )
         oColumn:picture    := aPict[n]
//         oColumn:picture  := repl( "!", len( xValue ) )
      case ISDATE( xValue )
         oColumn:picture  := aPict[n]
      otherwise

      endcase

   next

   RETURN

//AddRecno////////////////////////////////////////////////////////////////////
STATIC Function AddRecno( oB )
   LOCAL oColumn
   oB:freeze := nLeftLock
RETURN

//DoGet///////////////////////////////////////////////////////////////////////
//static func DoGet( oB, lAppend )
function DoGet( oB, lAppend )

local bInsSave, lScoreSave, lExitSave
local oCol, oGet, nKey, cExpr, xEval
local lFresh, nCursSave, mGetVar
local cForCond

      oB:hitTop := .f.
      while ( !oB:stabilize() ) ; end
      lScoreSave := Set(_SET_SCOREBOARD, .f.)
      lExitSave := Set(_SET_EXIT, .t.)
      bInsSave := setkey( K_INS, { || InsToggle() } )
        nCursSave := SetCursor( if(ReadInsert(), SC_INSERT, SC_NORMAL) )
        cExpr := IndexKey(0)
        if ( !Empty(cExpr) )
                xEval := &cExpr
        end
        oCol := oB:getColumn(oB:colPos)
        mGetVar := Eval(oCol:block)
        oGet := GetNew(Row(), Col(),                                                                    ;
                                   {|x| if(PCount() == 0, mGetVar, mGetVar := x)},      ;
                                   "mGetVar",ocol:picture, oB:colorSpec)
        lFresh := .f.
             if ( ReadModal( {oGet} ) )
                Eval(oCol:block, mGetVar)
      if ( !lAppend .AND. !empty( cForCond := ordFor( IndexOrd() )))
         if !( &( cForCond ))
            dbGoTop()
         endif
      endif
      if ( !lAppend .and. !Empty(cExpr) )
         if ( xEval != &cExpr )
            lFresh := .t.
         end
      end
        end
        if ( lFresh )
                nKey := 0
        else
             oB:refreshCurrent()
             nKey := ExitKey(lAppend,oB)
         end
        if ( lAppend )
                oB:colorRect({oB:rowPos,1,oB:rowPos,oB:colCount}, {2,2})
        end
        SetCursor(nCursSave)
        Set(_SET_SCOREBOARD, lScoreSave)
        Set(_SET_EXIT, lExitSave)
        SetKey(K_INS, bInsSave)
return (nKey)

//ExitKey/////////////////////////////////////////////////////////////////////
static func ExitKey(lAppend,oB)

local nKey

        nKey := LastKey()
        if ( nKey == K_PGDN )
                if ( lAppend )
                        nKey := 0
                else
                        nKey := K_DOWN
                end

        elseif ( nKey == K_PGUP )
                if ( lAppend )
                        nKey := 0
                else
                        nKey := K_UP
                end

        elseif ( nKey == K_RETURN .or. (nKey >= 32 .and. nKey <= 255) )
                //nKey := K_RIGHT
                  nKEY := 0
                  IF oB:COLPOS != oB:COLCOUNT()
                     IF oB:COLPOS < nRightLock
                        KEYBOARD CHR(K_RIGHT)+CHR(K_RETURN)
                     Else
                        KEYBOARD CHR(K_CTRL_HOME)
//                        KEYBOARD CHR(K_HOME)+CHR(K_DOWN)
                     Endif
                  ENDIF

        elseif ( nKey != K_UP .and. nKey != K_DOWN )
                nKey := 0
        end

return (nKey)
//IdxKosul////////////////////////////////////////////////////////////////////
Function IdxKosul()
If &cAlan=cKosul1
   lDur=.T.
Else
   lDur=.F.
Endif
Return(lDur)
//Arama///////////////////////////////////////////////////////////////////////
Function Arama(SHarf)
 Karak=Chr(SHarf)
 Karak=_Upper(Karak)
 @ nBottom,nLeft+2 Say Anah
 nOldRec:=Recno()
 Seek(Anah+Karak)
 If Found()
    Anah=Anah+Karak
 Else
    Go nOldRec
 Endif
 @ nBottom,nLeft+2 Say Anah
 oB:RefreshAll()
Return(Anah)
//////////////////////////////////////////////////////////////////////////////
Function TArama
//Kar=Right(Anah,2)
Anah=Left(Anah,Len(Anah)-1)
If Len(Anah)=0
   Go Top
Else
   Seek Anah
Endif
@ nBottom,nLeft+2 Say Replicate("Ä",nRight-nLeft-2)
@ nBottom,nLeft+2 Say Anah
oB:RefreshAll()
Return
//////////////////////////////////////////////////////////////////////////////
Function _Upper( cStr )
LOCAL cRet
cRet := cStr
cRet := STRTRAN( cRet, "i", "" )
cRet := UPPER( cRet )
cRet := STRTRAN( cRet, "", "" )
cRet := STRTRAN( cRet, "", "" )
cRet := STRTRAN( cRet, "§", "Š" )
cRet := STRTRAN( cRet, "", "" )
cRet := STRTRAN( cRet, "", "I" )
cRet := STRTRAN( cRet, "", "" )
RETURN( cRet )
//////////////////////////////////////////////////////////////////////////////
