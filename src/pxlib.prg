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

#include "inkey.ch"

//////////////////////////////////////////////////////////////////////////////
Function _TR(cStr)
Return (HB_UTF8TOSTR(cStr))
//////////////////////////////////////////////////////////////////////////////
Function _aTR(aArr)
    For J:=1 To Len(aArr)
        aArr[J]=_TR(aArr[J])
    Next
Return (aArr)
//////////////////////////////////////////////////////////////////////////////
Function _Alert(cMsg,cBut)
    bRet=Alert(_TR(cMsg),_aTR(cBut))
Return (bRet)
//////////////////////////////////////////////////////////////////////////////
Function TBosalt()
  Keyboard Chr(255)
  Inkey(0)
Return(0)
//////////////////////////////////////////////////////////////////////////////
FUNCTION _Win
Parameters Y1,X1,Y2,X2,Renk,Tip,Golge
SET COLOR TO &Renk
@ Y1,X1 clear to Y2,X2
   DO CASE
      CASE Tip=1  // TEK CIZGI
           @ Y1,X1 to Y2,X2 COLOR Renk
      CASE Tip=2  // CIFT CIZGI
           @ Y1,X1 to Y2,X2 double COLOR Renk
      CASE Tip=3  // ICI DOLU ZEMIN
//           cCER = REPLICATE(CHR(176),9)
//           @ Y1,X1,Y2,X2 BOX cCER COLOR Renk
           @ Y1,X1 to Y2,X2 COLOR Renk
      CASE Tip=4  // DOLU CERCEVE
//           cCER = REPLICATE(CHR(219),8)
//           @ Y1,X1,Y2,X2 BOX cCER COLOR Renk
           @ Y1,X1 to Y2,X2 COLOR Renk
   ENDCASE
SET COLOR TO
IF Golge=1
   ColorWin(Y2+1,X1+1,Y2+1,X2+1,"W/N")
   ColorWin(Y1+1,X2+1,Y2+1,X2+1,"W/N")
ENDIF
RETURN(0)
//////////////////////////////////////////////////////////////////////////////
FUNCTION _Box
Parameters X1,Y1,X2,Y2,Renk,Tip,Golge
nWin:={"ÚÄ¿³ÙÄÀ³","ÆÄ¹º»ÏØÓ","ÐÑÒÓÔÕÖ×","ÇÕµ×¶ÑÌÓ"}
SET COLOR TO &Renk
@ X1,Y1,X2,Y2 BOX nWin[Tip]
SET COLOR TO
IF Golge=1
   ColorWin(X2+1,Y1+1,X2+1,Y2+1,"W/N")
   ColorWin(X1+1,Y2+1,X2+1,Y2+1,"W/N")
ENDIF
RETURN(0)
//////////////////////////////////////////////////////////////////////////////
Function _TusYaz(X,Y,aYazi)
@ X,0 Say Replicate(" ",80) Color("W+/W")
For z=1 To Len(aYazi)
    nUz=Len(aYazi[z])
    nBas:=AT("~",aYazi[z])
    nSon:=RAT("~",aYazi[z])
    If nBas>1
       @ X,Y Say _TR(SubStr(aYazi[z],1,nBas-1)) Color("N/W")
       @ X,Y+nBas-1 Say _TR(SubStr(aYazi[z],nBas+1,(nSon-nBas)-1)) Color("R/W")
       @ X,Y+nSon-2 Say _TR(SubStr(aYazi[z],nSon+1,(nUz-nSon)+1)) Color("N/W")
    Else
       @ X,Y Say _TR(SubStr(aYazi[z],nBas+1,(nSon-nBas))) Color("R/W")
       @ X,Y+nSon-2 Say _TR(SubStr(aYazi[z],nSon+1,(nUz-nSon)+1)) Color("N/W")
    Endif
    Y=Y+nUz-1
Next
Return
//////////////////////////////////////////////////////////////////////////////
Function DosDuzen()
If RAPAYAR->SCR_SUR>0
   Set key 273 To
//   Trapanykey()
   Keysec()
Endif
SetCursor(0)
Bekle(.T.)
      Close All
      Use FIYLIS
      Pack
      Index On MALNO To FIYLISMX
      Index On SIRNO To FIYLISSX
      Close All
      Use GRUP
      Pack
      Index On GRUP_KD To GRUPX1
      Index On GRUP_NO To GRUPX2
      Index On GRUP_SR To GRUPX3
      Close All
      Use PARA
      Pack
      Index On P_BIR To PARAX
      Close All
      Use PARAHRK
      Pack
      Index On PH_BIR To PARAHBX
      Index On PH_TAR To PARAHTX
      Close All
      Use ANAGRUP
      Pack
      Index On AGRUP_NO To AGRUPX
      Close All
      Use FIRMA
      Pack
      Index On FIR_KOD To FIRMAX
      Close All
      Use MAKANA
      Pack
      Index On AMAK_KOD To MAKANAX
      Close All
      Use MAKHRK
      Pack
      Index On MAK_KOD To MAKHRKX
      Close All
      Use KASAKART
      Pack
      Index On TARIH To KSTAR
      Close All
      Use KASAHRK
      Pack
      Index On TARIH To KSHRK
      Close All
      Use KASAHSP
      Pack
      Index On KOD To KSKOD
      Close All
      USE FIYLIS INDEX FIYLISMX,FIYLISSX New
      USE GRUP INDEX GRUPX1,GRUPX2,GRUPX3 New
      USE PARA INDEX PARAX New
      USE PARAHRK INDEX PARAHBX,PARAHTX New
      USE RAPAYAR New
      USE ANAGRUP INDEX AGRUPX New
      USE FIRMA INDEX FIRMAX New
      USE MAKANA INDEX MAKANAX New
      USE MAKHRK INDEX MAKHRKX New
      USE KASAKART Index KSTAR New
      USE KASAHRK  Index KSHRK New
      USE KASAHSP Index KSKOD New
DosyaOnar()
Bekle(.F.)
If RAPAYAR->SCR_SUR>0
   Set key 273 to int_altw
//   Trapanykey("int_tus")
   Keysec(273,1,-1)
Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function DosyaOnar()
SetCursor(0)
Select KASAKART
Go Top
lTopRec:=.T.
Do While !EOF()
 nGirMik:=0;nCikMik:=0;nADevMik:=0;nBDevMik:=0
 dTarih:=TARIH
 Select KASAHRK
 Seek(dTarih)
 If Found()
    Do While TARIH=dTarih .And. !EOF()
       If Left(KOD,1)!="#"
          nGirMik:=nGirMik+GIRMIKTAR
          nCikMik:=nCikMik+CIKMIKTAR
       Endif
     Skip
    Enddo
 Endif
 Select KASAKART
 Replace GGIRMIKTAR With nGirMik,;
         GCIKMIKTAR With nCikMik
 If lTopRec=.T.
    Replace BDEVMIKTAR With nGirMik,;
            ADEVMIKTAR With nCikMik
 Endif
 nBDevMik:=BDEVMIKTAR;nADevMik:=ADEVMIKTAR
 Skip
 lTopRec:=.F.
    Replace BDEVMIKTAR With 0,;
            ADEVMIKTAR With 0
 If nGirMik+nBDevMik>nCikMik+nADevMik
    Replace BDEVMIKTAR With (nGirMik+nBDevMik)-(nCikMik+nADevMik)
 Elseif nGirMik+nBDevMik<nCikMik+nADevMik
    Replace ADEVMIKTAR With (nCikMik+nADevMik)-(nGirMik+nBDevMik)
 Else
    Replace BDEVMIKTAR With (nGirMik+nBDevMik)-(nCikMik+nADevMik)
    Replace ADEVMIKTAR With (nCikMik+nADevMik)-(nGirMik+nBDevMik)
 Endif
Enddo
Return
//////////////////////////////////////////////////////////////////////////////
Function KHesap()
  If oB:Colpos=3
     Repl SAFIY With (ALFIY+(ALFIY*KARYZ)/100)
     Repl SKARI With (SAFIY-ALFIY)
  ElseIf oB:Colpos=4
     nKar:=100*((SAFIY-ALFIY)/ALFIY)
     If Len(Alltrim(Str(nKar)))<=3
        Repl KARYZ With nKar
        Repl SKARI With (SAFIY-ALFIY)
     Endif
  Endif
Return
//////////////////////////////////////////////////////////////////////////////
//Return:=SecMenu("Baslik",{"1","2","3"})
Function SecMenu(aBasArr,aSecArr)
Local X1,Y1,X2,Y2,OldScr
SETCURSOR(0)
X1:=(79-Len(aSecarr[1]))/2
X2:=X1+Len(aSecArr[1])
Y1:=(23-Len(aSecArr))/2
Y2:=Y1+Len(aSecArr)+1
OldScr:=SaveScreen(Y1-1,X1,Y2+1,X2+1)
_Win(Y1,X1,Y2,X2,"14/13",3,1)
@ Y1-1,X1+(((X2-X1)-Len(aBasArr))/2)+1 Say _TR(aBasArr) Color("11/8")
SetColor("15/13,15/1,,,15/13")
DonArr:=Achoice(Y1+1,X1+1,Y2-1,X2-1,_aTR(aSecArr),.T.,"cMenuFunc")
SetColor()
RestScreen(Y1-1,X1,Y2+1,X2+1,OldScr)
Return(DonArr)
//////////////////////////////////////////////////////////////////////////////
FUNCTION cMenuFunc( nMode, nCurElement, nRowPos )
  LOCAL nRetVal := 2
  LOCAL nKey := LASTKEY()
  DO CASE
     CASE nMode == 0
     nRetVal := 2
     CASE nMode == 1
            KeyBoard Chr(K_PGDN)
     CASE nMode == 2
            KeyBoard Chr(K_PGUP)
     CASE nMode == 3
          DO CASE
             CASE nKey == K_RETURN
                  nRetVal := 1
             CASE nKey == K_ESC
                  nRetVal := 0
             OTHERWISE
                  nRetVal := 3
          ENDCASE
  ENDCASE
RETURN nRetVal
Function Prn_Off
Do While .T.
IF Isprinter()=.F.
   Tone(200,10)
   nPrn=Alert("DKKAT! Yazc hazr de§il,;tekrar gnderilsin mi ? ",{"Hayr","Evet"})
   If nPrn=2
      Durum="Kapali"
      Loop
   Else
      Durum="Kapali"
      Exit
   Endif
Else
 Durum="Acik"
 Exit
Endif
Enddo
Return(Durum)
//////////////////////////////////////////////////////////////////////////////
Function _SaveScr(X1,Y1,X2,Y2,cScrName)
Static aScrArr:={}
If X1!=NIL .And. Y1!=NIL .And. X2!=NIL .And. Y2!=NIL .And. cScrName!=NIL
   cScr0=cScrName ; cScr1=cScrName+"1" ; cScr2=cScrName+"2"
   cScr0:=SaveScreen(X1,Y1,X2,Y2)
//   cScr1:=SaveScreen(X2+1,Y1+1,X2+1,Y2+1)
//   cScr2:=SaveScreen(X1+1,Y2+1,X2+1,Y2+1)
   aAdd(aScrArr,{X1,Y1,X2,Y2,cScr0})
//   aAdd(aScrArr,{X2+1,Y1+1,X2+1,Y2+1,cScr1})
//   aAdd(aScrArr,{X1+1,Y2+1,X2+1,Y2+1,cScr2})
Else
   nSonElm:=Len(aScrArr)
//   For nItem=nSonElm To (nSonElm-2) Step -1
   nItem=nSonElm
       RestScreen(aScrArr[nItem,1],aScrArr[nItem,2],aScrArr[nItem,3],;
                  aScrArr[nItem,4],aScrArr[nItem,5])
   ColorWin(aScrArr[nItem,3]+1,aScrArr[nItem,2]+1,aScrArr[nItem,3]+1,aScrArr[nItem,4]+1,"W/N")
   ColorWin(aScrArr[nItem,1]+1,aScrArr[nItem,4]+1,aScrArr[nItem,3]+1,aScrArr[nItem,4]+1,"W/N")
       Adel(aScrArr,nItem)
       aSize(aScrArr,nItem-1)
Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function GetAlert(cBaslik,nGet,aSec)
   LOCAL nTop,nLeft,nBottom,nRight,cScr,cGet,nSec,nPos1,nPos2,nPos3
   LOCAL GetList[1]
   nTop  :=9;nBottom:=15
   nLeft :=Int((80-Len(cBaslik))/2)
   nRight:=nLeft+Len(cBaslik)+1
   nPos1 :=nLeft + ((nRight - nLeft) / 2) - LEN(aSec[1]) - 1
   nPos2 :=nPos1 + LEN(aSec[2]) + 2
   nPos3 :=nLeft + Int((((nRight-nLeft)-nGet)/2))-1
   cScr := SAVESCREEN(nTop,nLeft,nBottom+1,nRight+1)
   _Win(nTop,nLeft,nBottom,nRight,"15/13",1,1)
   SetColor("15/13,15/1,,,15/13")
   @ nTop+1,nLeft+1 Say _TR(cBaslik)
   @ nTop+3,nPos3+nGet+1 Say ".TXT"
   @ nTop+5,nPos1 SAY _TR(aSec[1])
   @ nTop+5,nPos2 SAY _TR(aSec[2])

   cGet := SPACE(nGet)
   SETCURSOR(1)
   GetList[1] := GetNew( nTop + 3, nPos3, {|x| IF(x == NIL, cGet,;
                       cGet := x)}, "cGet" ,"@K")
   ReadModal( GetList,0 )
   SETCURSOR(0)
   IF LASTKEY() == K_ESC .OR. !UPDATED()
      nSec := 2
   ENDIF
   @ nTop + 5,nPos1 PROMPT aSec[1]
   @ nTop + 5,nPos2 PROMPT aSec[2]
   MENU TO nSec
   SetColor()
   RESTSCREEN(nTop,nLeft,nBottom+1,nRight+1,cScr)
Return(IF(nSec == 1, cGet, NIL))
//////////////////////////////////////////////////////////////////////////////
FUNCTION cUserFunction( nMode, nCurElement, nRowPos )
  LOCAL nRetVal := 2     // Default, Continue
  LOCAL nKey := LASTKEY()
  DO CASE
     CASE nMode == 0
     nRetVal := 2
     CASE nMode == 1
            KeyBoard Chr(K_PGDN)
     CASE nMode == 2
            KeyBoard Chr(K_PGUP)
     CASE nMode == 3
          DO CASE
             CASE nKey == K_RETURN         // If RETURN key, select
                  nRetVal := 1
             CASE nKey == K_ESC            // If ESCAPE key, abort
                  nRetVal := 0
             OTHERWISE
                  nRetVal := 3      // Otherwise, go to item
          ENDCASE
  ENDCASE
RETURN nRetVal
//////////////////////////////////////////////////////////////////////////////
FUNCTION ABOUT
    LOCAL mrenk,mcrsr,absat,aekran,cOLDFNT
    SETCURSOR(0)
    DispBegin()
    _Win(6,16,18,64,"R/7",2,1)

    @ 07,17 SAY _TR("                 pxFiyat v1.0                  ") COLOR "B/W"
    @ 08,17 SAY _TR("         Fiyat Listeleri Takip Programı        ") COLOR "B/W"
    @ 10,17 SAY _TR(" pxFiyat için HİÇ BİR GARANTİ verilmemektedir. ") COLOR "N/W"
    @ 11,17 SAY _TR(" Bu bir SERBEST yazılımdır.                    ") COLOR "N/W"
    @ 12,17 SAY _TR(" Belli koşullar altında yeniden dağıtılabilir. ") COLOR "N/W"
    @ 13,17 SAY _TR(" Detaylar için : <http://www.gnu.org/licenses> ") COLOR "N/W"
    @ 15,17 SAY _TR("               <http://pxfiyat.googlecode.com> ") COLOR "R/W"
    @ 16,17 SAY _TR("               Telif Hakkı (c)2011,ibrahim ŞEN ") COLOR "N/W"
    @ 17,17 SAY _TR("                          <ibrahim@promek.net> ") COLOR "N/W"

    mcrsr=setcursor()
    DispEnd()
    inkey(0)
    setcursor(mcrsr)
RETURN NIL
//////////////////////////////////////////////////////////////////////////////
procedure int_altw
LOCAL INT_EKRAN
PRIVATE cOLDSET:=SET(_SET_DEFAULT)
set key 273 to
  ara=(Seconds()-Oldtime)
  if (ara>=kes_sure) .or. (kes_sure!=0)
     SET DEFAULT TO
//     ScrSaver()
     Oldtime=Seconds()
     SET DEFAULT TO (cOLDSET)
  endif
set key 273 to int_altw
return
***************************************************************************
procedure int_tus(ntus)
LOCAL ARA
  ara=(Seconds()-Oldtime)
  if ntus<>4352
     Oldtime=Seconds()
     if (ara<kes_sure)
//        keysend(i2bin(ntus),.t.)
     endif
  else
     if (ara>=kes_sure)
        DO int_altw
     endif
  endif
return
//////////////////////////////////////////////////////////////////////////////
Function Bekle(lDurum)
If lDurum=.F.
   RestScreen(9,26,12,52,cBekScr)
Else
   If !lDurum=NIL
      If lDurum=.T.
         cBekScr:=SaveScreen(9,26,12,52)
      Endif
   Endif
   Set Cursor Off
   _Win(9,26,11,51,"15/4",1,1)
   @ 10,29 Say  "Ltfen Bekleyiniz" Color("15/4")
   @ 10,47 Say "ÊË" Color("15/4")
Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function INPUT(cAlan,cTip,nUzunluk)
Local nLeft,nRight,nRet,Oldscr,OldColor,OldCursor
OldColor:=SETCOLOR()
OldCursor:=SETCURSOR()
SETCURSOR(1)
nLeft :=Int((80-(Len(cAlan)+nUzunluk+4))/2)
nRight:=nLeft+Len(cAlan)+nUzunluk+4
OldScr:=SaveScreen(9,nLeft,12,nRight+1)
_Win(9,nLeft,11,nRight,"14/13",1,1)
SetColor("15/13,15/1,,,15/13")
If cTip="N"
   nRet:=0
   cPicture:=Replicate("9",nUzunluk)
Elseif cTip="C"
   nRet:=Space(nUzunluk)
   cPicture:="@!"
ElseIf cTip="D"
   nRet:=CTOD("  /  /  ")
Endif
@ 10,nLeft+2 Say cAlan Get nRet Pict cPicture
Read
SETCOLOR(OldColor)
SETCURSOR(OldCursor)
RestScreen(9,nLeft,12,nRight+1,OldScr)
Return(nRet)
//////////////////////////////////////////////////////////////////////////////
Function Sifre()
cSifScr:=SaveScreen(0,0,24,79)
_Win(11,31,13,47,"4/7",3,1)
cSifre:=Space(5)
nGirSay:=0
nReturn:=0
Do While .T.
   SetColor("1/7")
   @ 12,33 Say "ifre : " Color("1/7")
   SetColor("1/7")
   @ 12,41 Get cSifre Color("7/7") Pict"@K"
   Read
//   cSifre:=GETINPUT(cSifre)
   If cSifre=Crypt(RAPAYAR->SIF_RE1,"IBOSEN")
      nReturn:=1
      Exit
   ElseIf cSifre=Crypt(RAPAYAR->SIF_RE2,"IBOSEN")
      nReturn:=2
      Exit
   Else
      Tone(600,3)
      nGirSay+=1
      If nGirSay=3
         Alert("Yanl ifre!",{"Tamam"})
         Exit
      Endif
   Endif
Enddo
RestScreen(0,0,24,79,cSifScr)
Return(nReturn)
//////////////////////////////////////////////////////////////////////////////
Function GenelParam()
If RAPAYAR->SIF_DR2="û"
   nGirisDur:=Sifre()
   If nGirisDur!=2
      Return
   Endif
Endif
OldScr:=SaveScreen(0,0,24,79)
SETCURSOR(1)
Set key 273 To
//Trapanykey()
Keysec()
OldColor:=SetColor()
cSifreG1:=Space(5)
cSifreG2:=Space(5)
cSifreO1:=Space(5)
cSifreO2:=Space(5)
Select RAPAYAR
_Win( 5, 0,18,79,"15/6",1,1)
SetColor("15/6,15/1,,,15/6")
@  5,29 Say "Firma Parametreleri"
@  7,01 Say "Firma Ad : " Get FIR_ADI Pict"@!"
@  8,01 Say "Yetkilisi : " Get FIR_YET Pict"@!"
@  9,01 Say "Adres1    : " Get FIR_ADR1 Pict"@!"
@ 10,01 Say "Adres2    : " Get FIR_ADR2 Pict"@!"
@ 11,01 Say "l/le   : " Get FIR_ILI Pict"@!"
@ 11,30 Say "Telefon : " Get FIR_TEL Pict"@!"
@ 11,57 Say "Fax : " Get FIR_FAX Pict"@!"
@ 13,00 Say "Ã"+Replicate("Ä",78)+"Ž"
@ 13,28 Say "Program Parametreleri"
@ 14,01 Say "Liste Bal§ :" Get LIS_BAS Pict"@S61"
@ 15,01 Say "[ ] Ekran Koruyucu Aktif"
@ 15,02 Get SCR_DUR Pict"9~û~ "
@ 15,31 Say "Sresi : " Get SCR_SUR Pict"@!" WHEN(SCR_DUR="û")
//@ 15,52 Say "[ ] Ondalk"
//@ 15,53 Get OND_DUR Pict"9~û~ "
@ 16,01 Say "[ ] Girite ifre"
@ 16,02 Say SIF_DR1 Pict"9~û~ "
@ 17,01 Say "[ ] Gvenlik ifre"
@ 17,02 Say SIF_DR2 Pict"9~û~ "
Read
If SCR_DUR!="û"
   Replace SCR_SUR With 0
Endif
If SCR_SUR=0
   Replace SCR_DUR With ""
Endif
cSifDur:=SIF_DR1
@ 16,01 Say "[ ] Girite ifre"
@ 16,02 Get SIF_DR1 Pict"9~û~ "
Read
If cSifDur=" " .And. SIF_DR1="û"
   Do While .T.
      @ 16,25 Say "ifre Giriniz  : "
      @ 16,42 Get cSifreG1 Color("1/1") Pict"@K"
      Read
//      cSifreG1:=GETINPUT(cSifreG1)
      If Empty(cSifreG1)
         Replace SIF_DR1 With ""
         Exit
      Endif
      @ 16,55 Say "Tekrar Giriniz : "
      @ 16,72 Get cSifreG2 Color("1/1") Pict"@K"
      Read
//      cSifreG2:=GETINPUT(cSifreG2)
      If cSifreG1=cSifreG2
         Replace SIF_RE1 With Crypt(cSifreG1,"IBOSEN")
         If cSifreG1=Crypt(SIF_RE2,"IBOSEN")
            Alert("Giri ifresi, gvenlik ifresiyle ayn olmamal",{"Tamam"})
            Loop
         Endif
         Exit
      Else
         Alert("Hatal giri!",{"Tamam"})
         Loop
      Endif
   Enddo
Elseif cSifDur="û" .And. SIF_DR1=" "
   Replace SIF_RE1 With ""
Endif
cSifDur:=SIF_DR2
@ 17,01 Say "[ ] Gvenlik ifre"
@ 17,02 Get SIF_DR2 Pict"9~û~ "
Read
If cSifDur=" " .And. SIF_DR2="û"
   Do While .T.
      @ 17,25 Say "ifre Giriniz  : "
      @ 17,42 Get cSifreO1 Color("1/1") Pict"@K"
      Read
//      cSifreO1:=GETINPUT(cSifreO1)
      If Empty(cSifreO1)
         Replace SIF_DR2 With ""
         Exit
      Endif
      @ 17,55 Say "Tekrar Giriniz : "
      @ 17,72 Get cSifreO2 Color("1/1") Pict"@K"
      Read
//      cSifreO2:=GETINPUT(cSifreO2)
      If cSifreO1=cSifreO2
         Replace SIF_RE2 With Crypt(cSifreO1,"IBOSEN")
         If cSifreO1=Crypt(SIF_RE1,"IBOSEN")
            Alert("Gvenlik ifresi, giri ifresiyle ayn olmamal!",{"Tamam"})
            Loop
         Endif
         Exit
      Else
         Alert("Hatal giri!",{"Tamam"})
         Loop
      Endif
   Enddo
Elseif cSifDur="û" .And. SIF_DR2=" "
   Replace SIF_RE2 With ""
Endif
If RAPAYAR->SCR_SUR>0
   Oldtime=Seconds()
   Kes_sure=RAPAYAR->SCR_SUR
   Set key 273 to int_altw
//   Trapanykey("int_tus")
   Keysec(273,1,-1)
Endif
SetColor(OldColor)
SETCURSOR(0)
RestScreen(0,0,24,79,OldScr)
Return
//////////////////////////////////////////////////////////////////////////////



