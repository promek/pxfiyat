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

#include "Inkey.ch"
#include "Getexit.ch"
#define _GET_INSERT_ON   7     // "Ins"
#define _GET_INSERT_OFF  8     // "   "
#define _GET_INVD_DATE   9     // "Invalid Date"
#define _GET_RANGE_FROM  10    // "Range: "
#define _GET_RANGE_TO    11    // " - "
#define K_UNDO          K_CTRL_U
STATIC sbFormat
STATIC slUpdated := .F.
STATIC slKillRead
STATIC slBumpTop
STATIC slBumpBot
STATIC snLastExitState
STATIC snLastPos
STATIC soActiveGet
STATIC scReadProcName
STATIC snReadProcLine
STATIC ncKopya
#define GSV_KILLREAD       1
#define GSV_BUMPTOP        2
#define GSV_BUMPBOT        3
#define GSV_LASTEXIT       4
#define GSV_LASTPOS        5
#define GSV_ACTIVEGET      6
#define GSV_READVAR        7
#define GSV_READPROCNAME   8
#define GSV_READPROCLINE   9

#define GSV_COUNT          9
/***
*  ReadModal()
*/
FUNCTION ReadModal( GetList, nPos )

   LOCAL oGet
   LOCAL aSavGetSysVars

   IF ( EMPTY( GetList ) )

      // S'87 compatibility
      SETPOS( MAXROW() - 1, 0 )
      RETURN (.F.)                  // NOTE

   ENDIF

   // Preserve state variables
   aSavGetSysVars := ClearGetSysVars()

   // Set these for use in SET KEYs
   scReadProcName := PROCNAME( 1 )
   snReadProcLine := PROCLINE( 1 )

   // Set initial GET to be read
   IF !( VALTYPE( nPos ) == "N" .AND. nPos > 0 )
      nPos := Settle( Getlist, 0 )
   ENDIF

   WHILE !( nPos == 0 )

      // Get next GET from list and post it as the active GET
      PostActiveGet( oGet := GetList[ nPos ] )

      // Read the GET
      IF ( VALTYPE( oGet:reader ) == "B" )
         EVAL( oGet:reader, oGet )    // Use custom reader block
      ELSE
         GetReader( oGet )            // Use standard reader
      ENDIF

      // Move to next GET based on exit condition
      nPos := Settle( GetList, nPos )

   ENDDO


   // Restore state variables
   RestoreGetSysVars( aSavGetSysVars )

   // S'87 compatibility
   SETPOS( MAXROW() - 1, 0 )

   RETURN ( slUpdated )



/***
*  GetReader()
*/
PROCEDURE GetReader( oGet )
   PRIVATE nSAYI:=0
   PRIVATE lPara:=.F.
   PRIVATE nCount:=0
   PRIVATE nAdim:=2
   PRIVATE lKusurat:=.F.
   PRIVATE nKAdim:=1
   PRIVATE ncBuffer:=""
   // Read the GET if the WHEN condition is satisfied
   IF ( GetPreValidate( oGet ) )
      // Activate the GET for reading
      oGet:setFocus()

      WHILE ( oGet:exitState == GE_NOEXIT )

         // Check for initial typeout (no editable positions)
         IF ( oGet:typeOut )
            oGet:exitState := GE_ENTER
         ENDIF

         If oGet:Type=="C"
            ncBuffer:=Oget:Varget()
         ElseIf oGet:Type=="N"
            ncBuffer:=Str(Oget:Varget())
         ElseIf oGet:Type=="D"
            ncBuffer:=DTOC(Oget:Varget())
         Endif

         // Para Girii...
         IF ( oGet:Type == "N" )
            nSayi := oGet:VARGET()
//            nSayi := 0
            IF ( "," $ oGet:picture)
                lPara:=.T.
                oGet:End()  // sonda bekle
            ENDIF
         ENDIF
         IF ( oGet:Type == "C" )
            IF ( "~" $ oGet:picture)
               nCount:=NUMTOKEN(oGet:picture,"~",1)
            ENDIF
         Endif

         // Apply keystrokes until exit
         WHILE ( oGet:exitState == GE_NOEXIT )
            GetApplyKey( oGet, inkey( 0 ) )
         ENDDO

         // Disallow exit if the VALID condition is not satisfied
         IF ( !GetPostValidate( oGet ) )
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDDO

      // De-activate the GET
      oGet:killFocus()

   ENDIF

   RETURN

/***
*  GetApplyKey()
*/
PROCEDURE GetApplyKey( oGet, nKey )

   LOCAL cKey
   LOCAL bKeyBlock,nTmp,cSayi
   IF !( ( bKeyBlock := setkey( nKey ) ) == NIL )
      GetDoSetKey( bKeyBlock, oGet )
      RETURN                           // NOTE
   ENDIF

   DO CASE
   CASE ( nKey == K_UP )
      oGet:exitState := GE_UP

   CASE ( nKey == K_SH_TAB ) .And. lPara=.F.
      oGet:exitState := GE_UP

   CASE ( nKey == K_DOWN )
      oGet:exitState := GE_DOWN

   CASE ( nKey == K_TAB )
      If lPara=.T. .And. lKusurat=.F.
         nTMP:=nSAYI*1000
         cSAYI:=transform(nTMP,oget:picture)
         If RIGHT(cSAYI,1)<>"*"
            nSAYI:=nTMP
            oget:buffer=cSAYI
            oget:display()
            OGET:CHANGED:=.T.
         Endif
      Else
         oGet:exitState := GE_DOWN
      Endif
   CASE ( nKey == K_ENTER )
      oGet:exitState := GE_ENTER

   CASE ( nKey == K_ALT_C )
        ncKopya:=ncBuffer

   CASE ( nKey == K_ALT_V )
      If oGet:Type=="C"
         oGet:varput(LEFT(ncKopya,Len(oGet:Varget)))
      ElseIf oGet:Type=="N"
         oGet:varput(VAL(ncKopya))
      ElseIf oGet:Type=="D"
         oGet:varput(CTOD(ncKopya))
      Endif
      oGet:updatebuffer()
      oget:display()
      OGET:CHANGED:=.T.

   CASE ( nKey == K_ESC )
      IF ( SET       ( _SET_ESCAPE ) )
         oGet:undo()
         oGet:exitState := GE_ESCAPE
      ENDIF

   CASE ( nKey == K_PGUP )
      oGet:exitState := GE_WRITE

   CASE ( nKey == K_PGDN )
      oGet:exitState := GE_WRITE

   CASE ( nKey == K_CTRL_HOME )
      oGet:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

   // Both ^W and ^End go to the last GET
   CASE ( nKey == K_CTRL_END )
      oGet:exitState := GE_BOTTOM

#else

   // Both ^W and ^End terminate the READ (the default)
   CASE ( nKey == K_CTRL_W )
      oGet:exitState := GE_WRITE

#endif


   CASE ( nKey == K_INS )
      SET( _SET_INSERT, !SET( _SET_INSERT ) )
      ShowScoreboard()

   CASE ( nKey == K_UNDO )
      oGet:undo()

   CASE ( nKey == K_HOME )  .And. lPara=.F.
      oGet:home()

   CASE ( nKey == K_END )   .And. lPara=.F.
      oGet:end()

   CASE ( nKey == K_RIGHT )  .And. lPara=.F.
      oGet:right()

   CASE ( nKey == K_LEFT )  .And. lPara=.F.
      oGet:left()

   CASE ( nKey == K_CTRL_RIGHT )  .And. lPara=.F.
      oGet:wordRight()

   CASE ( nKey == K_CTRL_LEFT )  .And. lPara=.F.
      oGet:wordLeft()

   CASE ( nKey == K_BS )
      If nSayi-Int(nSayi)!=0
         lKusurat:=.T.
      Endif
      If lPara=.T.
         If lKusurat=.F.
            nTMP:=INT(nSAYI/10)
         Else
            nTMP:=INT(nSAYI)
            lKusurat=.F.
            nKAdim:=1
         Endif
         cSAYI:=transform(nTMP,oget:picture)
         nSAYI:=nTMP
         oget:buffer=cSAYI
         oget:display()
         OGET:CHANGED:=.T.
      Else
         oGet:backSpace()
      Endif

   CASE ( nKey == K_DEL )
      If lPara=.T.
         nSAYI:=0
         cSAYI:=transform(nSAYI,oget:picture)
         oget:buffer=cSAYI
         oget:display()
         OGET:CHANGED:=.T.
      Else
         oGet:delete()
      Endif

   CASE ( nKey == K_CTRL_T )  .And. lPara=.F.
      oGet:delWordRight()

   CASE ( nKey == K_CTRL_Y )  .And. lPara=.F.
      oGet:delEnd()

   CASE ( nKey == K_CTRL_BS )   .And. lPara=.F.
      oGet:delWordLeft()

   CASE ( nKey == K_SPACE ) .And. lPara=.F. .And. ("~" $ oGet:picture)
     If ("~" $ oGet:picture)
        If TOKEN(oGet:picture,"~",nAdim,1)=oGet:VARGET()
           nAdim++
        Endif
        oGet:varput(TOKEN(oGet:picture,"~",nAdim,1))
        nAdim++
        If nAdim>nCount
           nAdim:=2
        Endif
       oGet:updatebuffer()
     Endif

   CASE ( nKey == 304 )  //ALT-B : BUGN
        IF (oGet:type == "D")
           oGet:varput(date())
           oGet:updatebuffer()
        Endif
   OTHERWISE
   If !("~" $ oGet:picture)
    If lPara=.T.
      IF ( nKey >= 42 .AND. nKey <= 57 )
         cKey := CHR( nKey )
         If lKusurat=.T.
            If nKAdim==3
               nTMP:=nSAYI
            ElseIf nKAdim==2
               nTMP:=(nSAYI*100 + VAL(ckey))/100
               nKAdim:=3
            ElseIf nKAdim==1
               nTMP:=(nSAYI*10 + VAL(ckey))/10
               nKAdim:=2
            Endif
         Else
            nTMP:=nSAYI*10 + VAL(ckey)
         Endif
         IF ( cKey == "." .OR. cKey == "," )
            lKusurat:=.T.
         Else
            cSAYI:=transform(nTMP,oget:picture)
            IF RIGHT(cSAYI,1)<>"*"
               nSAYI:=nTMP
               oget:buffer=cSAYI
               oget:display()
               OGET:CHANGED:=.T.
            ENDIF
         Endif
      ENDIF
    Else
      IF ( nKey >= 32 .AND. nKey <= 255 )
         cKey := CHR( nKey )
         IF ( oGet:type == "N" .AND. ( cKey == "." .OR. cKey == "," ) )
            oGet:toDecPos()
         ELSE
            IF ( SET( _SET_INSERT ) )
               oGet:insert( cKey )
            ELSE
               oGet:overstrike( cKey )
            ENDIF
            IF ( oGet:typeOut )
               IF ( SET( _SET_BELL ) )
                  ?? CHR(7)
               ENDIF
               IF ( !SET( _SET_CONFIRM ) )
                  oGet:exitState := GE_ENTER
               ENDIF
            ENDIF
         ENDIF
      ENDIF
    Endif
   Endif
   ENDCASE

   RETURN



/***
*  GetPreValidate()
*/
FUNCTION GetPreValidate( oGet )

   LOCAL lSavUpdated
   LOCAL lWhen := .T.

   IF !( oGet:preBlock == NIL )

      lSavUpdated := slUpdated

      lWhen := EVAL( oGet:preBlock, oGet )

      oGet:display()

      ShowScoreBoard()
      slUpdated := lSavUpdated

   ENDIF

   IF ( slKillRead )

      lWhen := .F.
      oGet:exitState := GE_ESCAPE       // Provokes ReadModal() exit

   ELSEIF ( !lWhen )

      oGet:exitState := GE_WHEN         // Indicates failure

   ELSE

      oGet:exitState := GE_NOEXIT       // Prepares for editing

   END

   RETURN ( lWhen )



/***
*  GetPostValidate()
*/
FUNCTION GetPostValidate( oGet )

   LOCAL lSavUpdated
   LOCAL lValid := .T.


   IF ( oGet:exitState == GE_ESCAPE )
      RETURN ( .T. )                   // NOTE
   ENDIF

   IF ( oGet:badDate() )
      oGet:home()
      DateMsg()
      ShowScoreboard()
      RETURN ( .F. )                   // NOTE
   ENDIF
   IF ( oGet:changed )
      oGet:assign()
      slUpdated := .T.
   ENDIF
   oGet:reset()
   IF !( oGet:postBlock == NIL )

      lSavUpdated := slUpdated
      // S'87 compatibility
      SETPOS( oGet:row, oGet:col + LEN( oGet:buffer ) )
      lValid := EVAL( oGet:postBlock, oGet )
      // Reset S'87 compatibility cursor position
      SETPOS( oGet:row, oGet:col )
      ShowScoreBoard()
      oGet:updateBuffer()

      slUpdated := lSavUpdated

      IF ( slKillRead )
         oGet:exitState := GE_ESCAPE      // Provokes ReadModal() exit
         lValid := .T.

      ENDIF
   ENDIF

   RETURN ( lValid )



/***
*  GetDoSetKey()
*/
PROCEDURE GetDoSetKey( keyBlock, oGet )

   LOCAL lSavUpdated

   // If editing has occurred, assign variable
   IF ( oGet:changed )
      oGet:assign()
      slUpdated := .T.
   ENDIF

   lSavUpdated := slUpdated

   EVAL( keyBlock, scReadProcName, snReadProcLine, ReadVar() )

   ShowScoreboard()
   oGet:updateBuffer()

   slUpdated := lSavUpdated

   IF ( slKillRead )
      oGet:exitState := GE_ESCAPE      // provokes ReadModal() exit
   ENDIF

   RETURN
/***
*              READ services
*/
/***
*  Settle()
*/
STATIC FUNCTION Settle( GetList, nPos )

   LOCAL nExitState

   IF ( nPos == 0 )
      nExitState := GE_DOWN
   ELSE
      nExitState := GetList[ nPos ]:exitState
   ENDIF

   IF ( nExitState == GE_ESCAPE .or. nExitState == GE_WRITE )
      RETURN ( 0 )               // NOTE
   ENDIF

   IF !( nExitState == GE_WHEN )
      // Reset state info
      snLastPos := nPos
      slBumpTop := .F.
      slBumpBot := .F.
   ELSE
      // Re-use last exitState, do not disturb state info
      nExitState := snLastExitState
   ENDIF
   // Move
   DO CASE
   CASE ( nExitState == GE_UP )
      nPos--

   CASE ( nExitState == GE_DOWN )
      nPos++

   CASE ( nExitState == GE_TOP )
      nPos       := 1
      slBumpTop  := .T.
      nExitState := GE_DOWN

   CASE ( nExitState == GE_BOTTOM )
      nPos       := LEN( GetList )
      slBumpBot  := .T.
      nExitState := GE_UP

   CASE ( nExitState == GE_ENTER )
      nPos++

   ENDCASE
   // Bounce
   IF ( nPos == 0 )                       // Bumped top
      IF ( !ReadExit() .and. !slBumpBot )
         slBumpTop  := .T.
         nPos       := snLastPos
         nExitState := GE_DOWN
      ENDIF

   ELSEIF ( nPos == len( GetList ) + 1 )  // Bumped bottom
      IF ( !ReadExit() .and. !( nExitState == GE_ENTER ) .and. !slBumpTop )
         slBumpBot  := .T.
         nPos       := snLastPos
         nExitState := GE_UP
      ELSE
         nPos := 0
      ENDIF
   ENDIF

   // Record exit state
   snLastExitState := nExitState

   IF !( nPos == 0 )
      GetList[ nPos ]:exitState := nExitState
   ENDIF

   RETURN ( nPos )
/***
*  PostActiveGet()
*/
STATIC PROCEDURE PostActiveGet( oGet )

   GetActive( oGet )
   ReadVar( GetReadVar( oGet ) )

   ShowScoreBoard()

   RETURN
/***
*  ClearGetSysVars()
*/
STATIC FUNCTION ClearGetSysVars()

   LOCAL aSavSysVars[ GSV_COUNT ]
   // Save current sys vars
   aSavSysVars[ GSV_KILLREAD ]     := slKillRead
   aSavSysVars[ GSV_BUMPTOP ]      := slBumpTop
   aSavSysVars[ GSV_BUMPBOT ]      := slBumpBot
   aSavSysVars[ GSV_LASTEXIT ]     := snLastExitState
   aSavSysVars[ GSV_LASTPOS ]      := snLastPos
   aSavSysVars[ GSV_ACTIVEGET ]    := GetActive( NIL )
   aSavSysVars[ GSV_READVAR ]      := ReadVar( "" )
   aSavSysVars[ GSV_READPROCNAME ] := scReadProcName
   aSavSysVars[ GSV_READPROCLINE ] := snReadProcLine
   // Re-init old ones
   slKillRead      := .F.
   slBumpTop       := .F.
   slBumpBot       := .F.
   snLastExitState := 0
   snLastPos       := 0
   scReadProcName  := ""
   snReadProcLine  := 0
   slUpdated       := .F.

   RETURN ( aSavSysVars )
/***
*  RestoreGetSysVars()
*/
STATIC PROCEDURE RestoreGetSysVars( aSavSysVars )

   slKillRead      := aSavSysVars[ GSV_KILLREAD ]
   slBumpTop       := aSavSysVars[ GSV_BUMPTOP ]
   slBumpBot       := aSavSysVars[ GSV_BUMPBOT ]
   snLastExitState := aSavSysVars[ GSV_LASTEXIT ]
   snLastPos       := aSavSysVars[ GSV_LASTPOS ]

   GetActive( aSavSysVars[ GSV_ACTIVEGET ] )

   ReadVar( aSavSysVars[ GSV_READVAR ] )

   scReadProcName  := aSavSysVars[ GSV_READPROCNAME ]
   snReadProcLine  := aSavSysVars[ GSV_READPROCLINE ]

   RETURN
/***
*  GetReadVar()
*/
STATIC FUNCTION GetReadVar( oGet )

   LOCAL cName := UPPER( oGet:name )
   LOCAL i
   IF !( oGet:subscript == NIL )
      FOR i := 1 TO LEN( oGet:subscript )
         cName += "[" + LTRIM( STR( oGet:subscript[i] ) ) + "]"
      NEXT
   END

   RETURN ( cName )
/***
*              System Services
*/
/***
*  __SetFormat()
*/
PROCEDURE __SetFormat( b )
   sbFormat := IF( VALTYPE( b ) == "B", b, NIL )
   RETURN
/***
*  __KillRead()
*/
PROCEDURE __KillRead()
   slKillRead := .T.
   RETURN
/***
*  GetActive()
*/
FUNCTION GetActive( g )

   LOCAL oldActive := soActiveGet

   IF ( PCOUNT() > 0 )
      soActiveGet := g
   ENDIF

   RETURN ( oldActive )
/***
*  Updated()
*/
FUNCTION Updated()
   RETURN slUpdated
/***
*  ReadExit()
*/
FUNCTION ReadExit( lNew )
   RETURN ( SET( _SET_EXIT, lNew ) )
/***
*  ReadInsert()
*/
FUNCTION ReadInsert( lNew )
   RETURN ( SET( _SET_INSERT, lNew ) )
/***
*              Wacky Compatibility Services
*/
// Display coordinates for SCOREBOARD
#define SCORE_ROW      0
#define SCORE_COL      60
/***
*  ShowScoreboard()
*/
STATIC PROCEDURE ShowScoreboard()

   LOCAL nRow
   LOCAL nCol

   IF ( SET( _SET_SCOREBOARD ) )
      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( IF( SET( _SET_INSERT ), NationMsg(_GET_INSERT_ON),;
                                   NationMsg(_GET_INSERT_OFF)) )
      SETPOS( nRow, nCol )
   ENDIF

   RETURN
/***
*  DateMsg()
*/
STATIC PROCEDURE DateMsg()

   LOCAL nRow
   LOCAL nCol

   IF ( SET( _SET_SCOREBOARD ) )

      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( NationMsg(_GET_INVD_DATE) )
      SETPOS( nRow, nCol )

      WHILE ( NEXTKEY() == 0 )
      END

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( SPACE( LEN( NationMsg(_GET_INVD_DATE) ) ) )
      SETPOS( nRow, nCol )

   ENDIF

   RETURN
/***
*  RangeCheck()
*/
FUNCTION RangeCheck( oGet, junk, lo, hi )

   LOCAL cMsg, nRow, nCol
   LOCAL xValue

   IF ( !oGet:changed )
      RETURN ( .T. )          // NOTE
   ENDIF

   xValue := oGet:varGet()

   IF ( xValue >= lo .and. xValue <= hi )
      RETURN ( .T. )          // NOTE
   ENDIF

   IF ( SET(_SET_SCOREBOARD) )

      cMsg := NationMsg(_GET_RANGE_FROM) + LTRIM( TRANSFORM( lo, "" ) ) + ;
              NationMsg(_GET_RANGE_TO) + LTRIM( TRANSFORM( hi, "" ) )

      IF ( LEN( cMsg ) > MAXCOL() )
         cMsg := SUBSTR( cMsg, 1, MAXCOL() )
      ENDIF

      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, MIN( 60, MAXCOL() - LEN( cMsg ) ) )
      DISPOUT( cMsg )
      SETPOS( nRow, nCol )

      WHILE ( NEXTKEY() == 0 )
      END

      SETPOS( SCORE_ROW, MIN( 60, MAXCOL() - LEN( cMsg ) ) )
      DISPOUT( SPACE( LEN( cMsg ) ) )
      SETPOS( nRow, nCol )

   ENDIF

   RETURN ( .F. )
/***
*  ReadKill()
*/
FUNCTION ReadKill( lKill )

   LOCAL lSavKill := slKillRead

   IF ( PCOUNT() > 0 )
      slKillRead := lKill
   ENDIF

   RETURN ( lSavKill )
/***
*  ReadUpdated()
*/
FUNCTION ReadUpdated( lUpdated )

   LOCAL lSavUpdated := slUpdated

   IF ( PCOUNT() > 0 )
      slUpdated := lUpdated
   ENDIF

   RETURN ( lSavUpdated )
/***
*  ReadFormat()
*/
FUNCTION ReadFormat( b )

   LOCAL bSavFormat := sbFormat

   IF ( PCOUNT() > 0 )
      sbFormat := b
   ENDIF

   RETURN ( bSavFormat )
