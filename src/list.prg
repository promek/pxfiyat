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

#include "Inkey.Ch"
//#define DEMO

Function _List(Dosya,Kosul,Alan,Baslik,Toplam,Aygit)
 Local nSat,J,K
 Private cRenk1,cRenk2,lColor,cAlan
 Private aAlan,aTopl,nTopl,cAlanTmp,KDown,KUp,nSut,nSatUz
 Private lDosyaSon,lDosyaBas,lToplama
 Dbcreate("Listtmp",{{"Str","C",255,0}})
//  Use &Dosya Alias RapDos New
 DosyaOff=.F.
 If Select(Dosya)=0
    DosyaOff=.T.
    Use &Dosya New
 Endif
  RapDos=Select()
  Select(RapDos)
  Use Listtmp New
 cRenk1="N/W" ; cRenk2="N/W*"
 cAlan=""     ; cAlanTmp="" ; UstYaz=""  ;AltYaz=""
 kDown=.F.    ; kUp=.F.     ; lColor=.T.
 nSat=0       ; nSut=0      ; nSatUz=0   ;nTop=0
 lDosyaBas=.T.; lDosyaSon=.F.
 UstAltCiz=""
 Declare aSatir[21]
 Declare aAlan[Len(Alan)]
 
 For J=1 To Len(Alan)
     aAlan[J]=Alan[J]
 Next

 If Toplam=NIL
    lToplama=.F.
 Else
    lToplama=.T.
    Declare aTopl[Len(Toplam)]
    Declare nTopl[Len(Toplam)]
    For J=1 To Len(Toplam)
        aTopl[J]=Toplam[J]
    Next
    For J=1 To Len(Toplam)
        nTopl[J]=0
    Next
 Endif

 Select(RapDos)
 Locate for &Kosul
  For S=1 to 21
         If !Eof()
            AlanDizi()
            Topla()
            aSatir[S]=cAlan+Space(80-Len(cAlan))
            Sele Listtmp
            Append Blank
            Repl Str With aSatir[S]
            Select(RapDos)
            nSat=nSat+1
         Else
            aSatir[S]=""
            If Len(aSatir[1])<1
               Alert("Koula uygun kayt bulunamad!")
               If DosyaOff=.T.
                  Select(RapDos)
                  Close
               Endif
               Sele Listtmp
               Close
               Return
            Endif
         Endif
    Continue
   Next
   For J=1 To Len(Baslik)
       cAlan=Alan[J]
       UstYaz=UstYaz+Padc(Baslik[J],Len(&cAlan))+" "
       UstAltCiz=UstAltCiz+Replicate("-",Len(&calan))+" "
       nSatUz=nSatUz+Len(&cAlan)+1
   Next
   If nSatUz<80
      nSatUz=80
   Endif
   Sele Listtmp
   Select(RapDos)
   SetCursor(0)
   Cls
   dGoster(nSut,0,80)

   If Len(aSatir[21])<1
      RecDown()
   Endif
   If Aygit="Y" .Or. Aygit="y"
      Yaziciya()
   Endif
 Do While .T.
 nKey:=Inkey(0)
 If nKey=K_UP
    RecUp()
 Elseif nKey=K_DOWN
    RecDown()
 Elseif nKey=K_PGUP
    DispBegin()
    For N=1 To 21
        RecUp()
    Next
    DispEnd()
 Elseif nKey=K_PGDN
    DispBegin()
    For N=1 To 21
        RecDown()
    Next
    DispEnd()
 Elseif nKey=K_END
    Sele Listtmp
    If Lastrec()>=21
       Bekle()
       DispBegin()
       Do While !Eof()
          RecDown()
       Enddo
       DispEnd()
    Endif
    RecDown()
    Select(RapDos)
    ToplamYaz()
 Elseif nKey=K_HOME
    Sele Listtmp
    If Lastrec()>=21
       DispBegin()
       Do While !Bof()
          RecUp()
       Enddo
       DispEnd()
    Endif
    Select(RapDos)
 Elseif nKey=K_ESC
    If DosyaOff=.T.
       Select(RapDos)
       Close
    Endif
    Sele Listtmp
    Close
    Exit
 Elseif nKey=K_LEFT
   If nSut>0
      nSut-=1
      Renkayar()
      dGoster(nSut+1,0,80)
   Endif
 Elseif nKey=K_RIGHT
   If nSut+80<nSatUz
      nSut+=1
      Renkayar()
      dGoster(nSut+1,0,80)
   Endif
 Elseif nKey=K_CTRL_LEFT
   If nSut>=5
      nSut-=5
      Renkayar()
      dGoster(nSut+5,0,80)
   Else
      nSut:=0
      Renkayar()
      dGoster(nSut,0,80)
   Endif
 Elseif nKey=K_CTRL_RIGHT
   If nSut+80<nSatUz
      nSut+=5
      Renkayar()
      dGoster(nSut,0,80)
   Else
//      nSut+=0
      Renkayar()
      dGoster(nSut,0,80)
   Endif
 Endif
 Enddo
Return
//////////////////////////////////////////////////////////////////////////////
Function dGoster
Parameter cX,nKor,nDur
Local nX
//    @ 0,0 Say Substr(UstYaz,nSut+1,80) Color("W/N")
//    @ 1, 0 Say Substr(UstAltCiz,nSut+1,80) Color("W/N")
    @ 0,0 Say Substr(UstYaz,cX,80) Color("W/N")
    @ 1, 0 Say Substr(UstAltCiz,cX,80) Color("W/N")
For nX=1 To 21
    Renkayar()
    @ nX+1,nKor Say Substr(aSatir[nX],nKor+cX,nDur)
Next
//    @ 23,0 Say Substr(UstAltCiz,nSut+1,80) Color("W/N")
    @ 23,0 Say Substr(UstAltCiz,cX,80) Color("W/N")
    If lDosyaSon=.T. .And. lToplama=.T.
//       @ 24,3 Say Substr(AltYaz,nSut+1,80) Color("W/N")
       @ 24,3 Say Substr(AltYaz,cX,80) Color("W/N")
    Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function Topla()
 If lToplama=.T.
   nTop=0
   For K=1 To Len(aTopl)
       nTop=nTopl[K]
       cTmpTop=aTopl[K]
       nTop+=&cTmpTop
       nTopl[K]=nTop
   Next
 Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function ToplamYaz()
If lToplama=.T.
   For J=1 To Len(aAlan)
       nTDiz=0
       cAlan=aAlan[J]
       For K=1 To Len(aTopl)
           nTmpTop:=aTopl[K]
           nEsit:=At(nTmpTop,cAlan)
       If nEsit !=0
          nTDiz=K
       Endif
       Next
       If nTDiz != 0
          cPict:="999,999,999,999.99"
          cTopl:=nTopl[nTdiz]
          nPictUz:=Len(Alltrim(Str(nTopl[nTdiz])))
          IF nPictUz>12
             nPictUz+=4
          Elseif nPictUz>9
             nPictUz+=3
          Elseif nPictUz>6
             nPictUz+=2
          Elseif nPictUz>3
             nPictUz+=1
          Endif
          AltYaz=AltYaz+Padl(TransForm(nTopl[nTDiz],right(cPict,nPictUz)),Len(&cAlan))+" "
//          AltYaz=AltYaz+TransForm(nTopl[nTDiz],right(cPict,nPictUz))+" "
       Else
          AltYaz=AltYaz+Space(Len(&cAlan))
       Endif
   Next
    @ 24,3 Say Substr(AltYaz,nSut+1,80) Color("W/N")
//      @ 24,3 Say AltYaz Color("W/N")
Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function Yaziciya()
BEGIN SEQUENCE
nCho:=Alert("Yazcy hazrlayp ENTER tuuna basnz.",{"Tamam","Vazge"})
If nCho=1
   Dur=PRN_OFF()
   If Dur="Kapali"
      Break
   Endif
Else
   Break
Endif
Select(RapDos)
dGoster(nSut,0,80)
Set Device To Print
#ifdef DEMO
 @ Prow()+1,0 SAY "Bu program bir deneme kopyasdr, Ticari amala kullanlamaz..."
#Endif
@ Prow()+1,0 Say Chr(15)
@ Prow()+1,0 Say UstYaz
@ Prow()+1,0 Say UstAltCiz
For J=1 To 21
    If !Empty(aSatir[J])
       @ Prow()+1,0 Say aSatir[J]
    Endif
Next
Do While !Eof()
   Set Device To Screen
   RecDown()
   Set Device To Print
   @  Prow()+1,0 Say aSatir[21]
Enddo
Set Device To Screen
RecDown()
Set Device To Print
@ Prow()+1,0 Say UstAltCiz
@ Prow()+1,3 Say AltYaz
@ Prow()+1,0 Say Chr(18)
Set Device To Screen
END
Return
//////////////////////////////////////////////////////////////////////////////
Function Renkayar
  If lColor=.T.
     Set color to &cRenk1
     lColor=.F.
  Else
     Set color to &cRenk2
     lColor=.T.
  Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function AlanDizi()
  cAlan=""
  For J=1 To Len(aAlan)
      cAlanTmp=aAlan[J]
      cAlan=cAlan+&cAlanTmp+" "
  Next
Return
//////////////////////////////////////////////////////////////////////////////
Function RecUp()
 If lDosyaBas=.F.
   If kDown=.T.
      Sele Listtmp
      If Lastrec()>=21
         Skip -21
         Ains(aSatir,1)
         aSatir[1]=Str
         Scroll(2,0,22,79,-1)
         Renkayar()
         @  2,0 Say Substr(aSatir[1],nSut+1,80)
         kDown=.F.
      Endif
   Else
      Sele Listtmp
      If Lastrec()>=21
         Skip -1
         If !Bof()
            Ains(aSatir,1)
            aSatir[1]=Str
            Scroll(2,0,22,79,-1)
            Renkayar()
            @  2,0 Say Substr(aSatir[1],nSut+1,80)
         Else
            lDosyaBas=.T.
         Endif
      Endif
    Endif
  kUp=.T.
Endif
Return(0)
//////////////////////////////////////////////////////////////////////////////
Function RecDown()
   If kUp=.T.
      Sele Listtmp
      If Lastrec()>=21
         Skip 21
         Adel(aSatir,1)
         aSatir[21]=Str
         Scroll(2,0,22,79,1)
         Renkayar()
         @  22,0 Say Substr(aSatir[21],nSut+1,80)
         kUp=.F.
      Endif
   Else
      Sele Listtmp
         Skip
         If !Eof()
            Adel(aSatir,1)
            aSatir[21]=Str
            Scroll(2,0,22,79,1)
            Renkayar()
            @  22,0 Say Substr(aSatir[21],nSut+1,80)
         Else
            Select(RapDos)
            If lDosyaSon<>.T.
               If Found() .And. !Eof()
                  Adel(aSatir,1)
                  AlanDizi()
                  Topla()
                  aSatir[21]=cAlan+Space(80-Len(cAlan))
                  Sele Listtmp
                  Append Blank
                  Repl Str With aSatir[21]
                  Scroll(2,0,22,79,1)
                  Renkayar()
                  @  22,0 Say Substr(aSatir[21],nSut+1,80)
                  Select(RapDos)
                  Continue
               Else
                  Sele Listtmp
                  lDosyaSon=.T.
                  Skip -1
                  Select(RapDos)
                  ToplamYaz()
               Endif
            Else
                  Sele Listtmp
                  Skip -1
                  Select(RapDos)
            Endif
         Endif
   Endif
   kDown=.T.
   lDosyaBas=.F.
Return(0)
//////////////////////////////////////////////////////////////////////////////


