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


SETMODE(25,80)
#include "inkey.ch"
SetCancel(.F.)
SetBlink(.f.)
Set ScoreBoard Off
Set Deleted On
Set Wrap On
Set Date To British
Set Epoch To 1970
HB_CDPSELECT('TR857')
HB_SETTERMCP("TR857",.t.)
HB_LANGSELECT('TR857')

Cls
About()

PUBLIC Oldtime,Kes_sure,cBekScr,cClipBoard
SET DEFAULT TO data
USE RAPAYAR New

DispBegin()
SETCURSOR(1)
If RAPAYAR->SCR_SUR>0
   Keysec()
//   Trapanykey()
   Oldtime=Seconds()
   Kes_sure=RAPAYAR->SCR_SUR
//   Trapanykey("int_tus")
   Keysec(273,1,-1)
   Set key 273 to int_altw
Endif
_Win(1,0,23,79,"12/3",3,1) //1/8
@ 0,0 Say Replicate(" ",80) Color("W+/W")
@ 0,0 Say _TR(" pxFiyat v1.0 - Fiyat Listeleri Takip Programı") Color("N/W")
@ 22,2 Say Padc(Alltrim(RAPAYAR->FIR_ADI),76) Color("7/0")
@ 0,71 Say Date() Color "0/7"
DispEnd()
Set Key K_ALT_A To RaporAyar()
Set Key K_ALT_K To KurGir()
Set Key K_ALT_G To MakinaGir()
Set Key K_ALT_P To KasaIslem()
Set Key K_ALT_Y To Yardim()
If RAPAYAR->SIF_DR1="û"
   nGirisDur:=Sifre()
   If nGirisDur=0
      Set Color To
      KeySec()
//      Trapanykey()
      Cls
      QUIT
   Endif
Endif
If Alltrim(Upper(Dosparam()))="INDEX"
   DosDuzen()
Else
   USE FIYLIS INDEX FIYLISMX,FIYLISSX New
   USE GRUP INDEX GRUPX1,GRUPX2,GRUPX3 New
   USE PARA INDEX PARAX New
   USE PARAHRK INDEX PARAHBX,PARAHTX New
   USE ANAGRUP INDEX AGRUPX New
   USE FIRMA INDEX FIRMAX New
   USE MAKANA INDEX MAKANAX New
   USE MAKHRK INDEX MAKHRKX New
   Use KASAKART Index KSTAR New
   Use KASAHRK  Index KSHRK New
   Use KASAHSP Index KSKOD New
Endif
KurDurum()
Do While .T.
_TusYaz(24,1,{"~ALT+Y~-Yardım"})
Sec:=SecMenu("      ANA MENÜ     ",;
            {"Fiyat Toplamları   ",;
             "Fiyat Listeleri    ",;
             "Fiyat Girişleri    ",;
             "Kur İşlemleri      ",;
             "Firma İşlemleri    ",;
             "Teklif Düzenleme   ",;
             "Genel Parametreler ",;
             "Dosya Düzenleme    "})
If Lastkey()=27
   Cikis:=_Alert("Program sonlansın mı?",{"Hayır","Evet"})
   If Cikis=2
      Set Color To
      KeySec()
      //Trapanykey()
      !MODE 80
      Cls
      Exit
   Endif
Endif
Do Case
   Case Sec = 1
        FiyatTop()
   Case Sec = 2
        ListeRapor()
   Case Sec = 3
        FiyatGir()
   Case Sec = 4
        KurGir()
   Case Sec = 5
        FirmaGir()
   Case Sec = 6
        EditView()
   Case Sec = 7
        GenelParam()
   Case Sec = 8
        DosDuzen()

Endcase
Enddo
Return
//////////////////////////////////////////////////////////////////////////////
Function KurDurum()
 Select Para
 If P_TAR<DATE()
    Go Top
    Do While !Eof()
       If P_BIR!="TL"
          Sele PARAHRK
          Append Blank
          Repl PH_BIR With PARA->P_BIR,;
               PH_TAR With DATE(),;
               PH_KUR With PARA->P_KUR
          Sele PARA
          Repl P_TAR With Date()
       Endif
     Skip
    Enddo
  Kurgir()
 Endif
Return

//////////////////////////////////////////////////////////////////////////////
Function FiyatGir()
If RAPAYAR->SIF_DR2="û"
   nGirisDur:=Sifre()
   If nGirisDur!=2
      Return
   Endif
Endif
OldScr:=SaveScreen(0,0,24,79)
_TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
               "~F4~-Değiştir","~ESC~-Çıkış"})
Select ANAGRUP
GAlan:={"AGrup_Ad"}
GBasl:={"ANA GRUP"}
GPict:={"@K"}
SetColor("15/13,15/1,,,15/13")
MyBrowse(2,29,22,51,gAlan,gBasl,gPict,"GirFunc1","AGRUP_No",1,99,.T.,.T.,0,0,.T.)
SetColor()
RestScreen(0,0,24,79,OldScr)
Return
//////////////////////////////////////////////////////////////////////////////
Function GirFunc1()
Static XKey:=.F.
Local lRet:=.T.
Local nKay,dKay
Do Case
    Case ( nKey == K_ESC )
         lRet=.F.
    Case ( nKey == K_ENTER )
         _SaveScr(2,29,22,51,"GirScr2")
         GrupKod=AGrup_No
         Select GRUP
         _TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
                       "~F4~-Değiştir","~F7~-Açıkklama","~ESC~-Çık"})
         fAlan:={"Grup_Ad"}
         fBasl:={"ALT GRUP"}
         fPict:={"@K"}
         SetColor("15/13")
         MyBrowse(2,29,22,51,fAlan,fBasl,fPict,"GirFunc2","GRUP_KD",GrupKod,,.T.,.T.,0,0,.T.)
         SetColor()
         Select ANAGRUP
         _SaveScr(,,,,)
    Case ( nKey == K_F4 )
         If XKey=.F.
            nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
         Else
            nCho=2
         Endif
         If nCho=2
            Doget(oB,lAppend)
            XKey=.F.
         Endif
    Case ( nKey == K_F2 )
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            nKay=1
            Do While .T.
               Seek(nKay)
               If Found()
                  Skip
                  nKay+=1
                  Loop
               Else
                  SetCursor(1)
                  Append Blank
                  Repl AGRUP_NO With nKay
                  oB:REFRESHALL()
                  Keyboard Chr(K_CTRL_ENTER)
                  sFound=.T.
                  XKey=.T.
                  SetCursor(0)
                  Exit
               Endif
            Enddo
        Endif
    Case ( nKey == K_F3 )
         nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
             If nCho=2
                dKay=AGRUP_NO
                Delete
                Pack
                oB:REFRESHAll()
                Select GRUP
                Do While .T.
                  Seek(dKay)
                   If Found()
                      dKay1=GRUP_NO
                      DELETE
                      Pack
                      Select Fiylis
                      DELETE FOR MALNO=dKAY1
                      Pack
                      Select Grup
                   Else
                      Exit
                   Endif
                Enddo
                TBosalt()
                XKey=.F.
                SetCursor(0)
                Select ANAGRUP
             Endif
EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function GirFunc2()
Static XKey:=.F.
Local lRet:=.T.
Local nKay,dKay
Do Case
    Case ( nKey == K_ESC )
         _TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
                    "~F4~-Değiştir","~F7~-Açıklama","~ESC~-Çık"})
         lRet=.F.
    Case ( nKey == K_ENTER )
         _Savescr(2,29,22,51,"GirScr3")
         MalKod=Grup_No
         Select Grup
         Donhal=Grup_Ad
         Select Fiylis
         @ 1,0 Say Padc(Alltrim(DonHal)+"-"+"FİYAT GİRİŞ KARTI",80) Color("4/3")
         _TusYaz(24,1,{"~F2~-Ekle","~F3~-Sil","~F4~-Para Birimi",;
                       "~F5~-Kdv Oranı","~F6~-Firma","~F7~-Açıklama","~ESC~-Çıkış"})
         Alan:={"CINSI","ALFIY","KARYZ","SAFIY","SKARI","BIRIM","KDVOR","FIRMA"}
         Pict:={"@S18","999,999,999.99","999","999,999,999.99","999,999,999.99","@K","99","@K"}
         Basl:={"Malın Cinsi","Al.Fiy."," % ","Sat.Fiy.",;
                "Sat.Kr","  ","KDV","Fir"}
         SetColor("15/6")
         MyBrowse(2,0,22,79,Alan,Basl,Pict,"GirFunc3","MALNO",MalKod,,.T.,.F.,0,4,.T.)
         SetColor()
         Select Grup
         _Savescr(,,,,)
    Case ( nKey == K_F4 )
         If XKey=.F.
            nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
         Else
            nCho=2
         Endif
         If nCho=2
            Doget(oB,lAppend)
            XKey=.F.
         Endif

    Case ( nKey == K_F2 )
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            Set Order To 2
            nKay=1
            Do While .T.
               Seek(nKay)
               If Found()
                  Skip
                  nKay+=1
                  Loop
               Else
                  SetCursor(1)
                  Append Blank
                  Repl GRUP_NO With nKay
                  Repl GRUP_KD With GrupKod  //Gruplama kodu
                  oB:REFRESHALL()
                  sFound=.T.
                  XKey=.T.
                  Keyboard Chr(K_CTRL_ENTER)
                  SetCursor(0)
                  Exit
               Endif
            Enddo
          Set Order To 1
        Endif
    Case ( nKey == K_F3 )
         nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
             If nCho=2
                dKay=GRUP_NO
                Delete
                Pack
                Seek(GrupKod)
                sFound=Found()
                oB:REFRESHAll()
                Select Fiylis
                DELETE FOR MALNO=dKAY
                Pack
                Select Grup
                TBosalt()
                XKey=.F.
                SetCursor(0)
             Endif

    Case ( nKey == K_F7 )
      OldScr1:=SaveScreen(0,0,24,79)
      _TusYaz(24,1,{"~F2~-Kaydet ve Çık","~ESC~-Çıkış"})
      _Win(8,8,16,71,"14/5",1,0)
      SetColor("15/5,15/1,,,15/5")
      SetCursor(1)
      Replace GRUP_AC With MEMOEDIT(GRUP_AC,9,9,15,70,.T.,"MemUdf",80)
      Keyboard Chr(27)
      MEMOEDIT(GRUP_AC,9,9,15,70,.F.)
      SetCursor(0)
      SetColor()
      RestScreen(0,0,24,79,OldScr1)


EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function GirFunc3()
Local lRet:=.T.
Local nKay
Do Case
   case ( nKey == K_ESC )
         _TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
                    "~F4~-Değiştir","~F7~-Açıklama","~ESC~-Çık"})
        lRet=.F.

   case nKey == K_RETURN
      If sFound=.T. .And. lGetLock=.T. .And. oB:COLPOS<=4
         Doget(oB,lAppend)
         If oB:COLPOS>2
            KHesap()
         Endif
      Endif
   case ( nKey == K_F2 )
        nKay=1
        Set Order To 2
        Do While .T.
           Seek(nKay)
           If Found()
              Skip
              nKay+=1
              Loop
           Else
              Append Blank
              Repl MALNO With MalKod
              Repl SIRNO With nKay
              Repl BIRIM With "$"
              Repl KDVOR With 18
              Exit
           Endif
        Enddo
        Set Order To 1
        oB:REFRESHALL()
        Keyboard Chr(13)
        sFound=.T.

  case ( nKey == K_F3 )
    nSec:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
    If nSec=2
       delete
       Pack
       Seek(MalKod)
       sFound=Found()
       oB:REFRESHAll()
    Endif

   case ( nKey == K_F4 )
       ParaBir=""
       KurSec()
       Select FIYLIS
       If !Empty(ParaBir)
          Repl BIRIM With ParaBir
       Endif
       sFound=.T.
       oB:REFRESHALL()

   case ( nKey == K_F5 )
       OldColor1:=SetColor()
       SetCursor(1)
       nKdv=0
       MesScr:=SaveScreen(10,26,14,53)
       _Win(10,26,13,52," 15/ 5",1,1)
       @ 11,27 Say _TR("K.D.V. Oranını Giriniz :") Color(" 15/ 5")
       @ 12,37 Get nKdv Pict "99"
       Read
       If Lastkey()!=27 .And. nKdv!=0
          Repl KDVOR With nKdv
       Endif
       RestScreen(10,26,14,53,MesScr)
       SetColor(OldColor1)
       SetCursor(0)
       oB:REFRESHALL()
       sFound=.T.
   case ( nKey == K_F6 )
       FirmaKod=""
       FirmaSec()
       Select FIYLIS
       If !Empty(FirmaKod)
          Repl FIRMA With FirmaKod
       Endif
       sFound=.T.
       oB:REFRESHALL()

    Case ( nKey == K_F7 )
      OldScr1:=SaveScreen(0,0,24,79)
      _TusYaz(24,1,{"~F2~-Kaydet ve Çık","~ESC~-Çıkış"})
      _Win(8,8,16,71,"14/5",1,0)
      SetColor("15/5,15/1,,,15/5")
      SetCursor(1)
      Replace ACIKL With MEMOEDIT(ACIKL,9,9,15,70,.T.,"MemUdf",80)
      Keyboard Chr(27)
      MEMOEDIT(ACIKL,9,9,15,70,.F.)
      SetCursor(0)
      SetColor()
      RestScreen(0,0,24,79,OldScr1)
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function GirFunc4
Local lRet:=.T.
Do Case
    Case nKey=K_ESC
         lRet=.F.
    Case nKey=K_ENTER
         lRet=.F.
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function ListeRapor()
OldScr0:=SaveScreen(0,0,24,79)
_TusYaz(24,1,{"~F5~-Tek Sutun Rapor","~F6~-Çift Sutun Rapor","~F9~-Gurup Sırala","~ESC~-Çıkış"})
SETCURSOR(0)
nGrupNo=0
Select ANAGRUP
GAlan:={"AGrup_Ad"}
GBasl:={"ANA GRUP"}
GPict:={"@K"}
SetColor("15/13")
MyBrowse(2,29,22,51,gAlan,gBasl,gPict,"RapFunc1","AGRUP_No",1,99,.F.,.T.,0,0,.T.)
SetColor()
RestScreen(0,0,24,79,OldScr0)
Return
//////////////////////////////////////////////////////////////////////////////
Function RapFunc1()
Local lRet:=.T.
Do Case
    Case ( nKey == K_ESC )
         lRet=.F.
    Case ( nKey == K_F5 )
         nGrupNo=AGRUP_NO
         TBosalt()
         TekSutunRapor()
         Select ANAGRUP
    Case ( nKey == K_F6 )
         nGrupNo=AGRUP_NO
         TBosalt()
         CiftSutunRapor("S")
         Select ANAGRUP
    Case ( nKey == K_F9 )
         _TusYaz(24,1,{"~ENTER~-Giriş","~ESC~-Çıkış"})
         RapScr2:=SaveScreen(2,27,23,54)
         GrupKod=AGrup_No
         Select GRUP
         fAlan:={"Grup_Ad","Grup_Sr"}
         fBasl:={"ALT GRUP","Sıra"}
         fPict:={"@K","@!"}
         SetColor("15/5")
         MyBrowse(2,27,22,53,fAlan,fBasl,fPict,"RapFunc2","GRUP_KD",GrupKod,,.T.,.T.,1,2,.T.)
         SetColor()
         Select ANAGRUP
         RestScreen(2,27,23,54,RapScr2)
    Case ( nKey == K_F12 )
         nGrupNo=AGRUP_NO
         TBosalt()
         CiftSutunRapor("A")
         Select ANAGRUP
EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function RapFunc2()
Local lRet:=.T.
Local nKay,dKay
Do Case
    Case ( nKey == K_ESC )
         _TusYaz(24,1,{"~F5~-Tek Sıra Rapor","~F6~-Çift Sıra Rapor","~F9~-Sırala","~ESC~-Çıkış"})
         lRet=.F.
   case nKey == K_ENTER
      If sFound=.T. .And. lGetLock=.T. .And. oB:COLPOS=2
         Doget(oB,lAppend)
      Endif
EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function CiftSutunRapor(cFiyat)
BEGIN SEQUENCE
OldScr1:=SaveScreen(0,0,24,79)
Do While .T.
nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
If nCikis=0
   Break
Endif
If nCikis=3
   nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
   If nCho=1
      Dur=PRN_OFF()
      If Dur="Kapali"
         Break
      Endif
   Else
      Break
   Endif
Endif
cName=""
If nCikis=2
   cName := GetAlert("Dosya adını giriniz.",8,{"Tamam","Vazgeç"})
   If EMPTY(cName)
      Break
   Else
      cName := AllTrim(cName)+".txt"
   Endif
Endif
If nCikis=1 .Or. EMPTY(cName)
   cName := "gecici.txt"
Endif
If nCikis=2 .Or. nCikis=1
   Set Printer to &cName
Endif
Select Grup
Set Order To 3
aGrup:={}
Go Top
TGrup=0
Do While !Eof()
   If GRUP_KD=nGrupNo
      aAdd(aGrup,{Grup_No,Grup_AD})
      TGrup++
   Endif
   Skip
Enddo
Set Order To 1
Go Top
Select Fiylis
FiyGr0={};FiyGr1={}
FiyatRap:={}
dTar=Date()
Grupno:=1
Sutun :=0
Go Top
Do While .T.
   Seek(aGrup[Grupno,1])
   Isim="FiyGr"+Alltrim(Str(Sutun))
   aAdd(&Isim,Padc("®"+Alltrim(aGrup[Grupno,2])+"¯",39,"Ä"))
   Do While MALNO=aGrup[Grupno,1]
      If cFiyat="S"
         aAdd(&Isim,Padr(Left(CINSI,27)+Padl(Alltrim(Transform(SAFIY,"999,999,999.99")),9)+" "+;
         Alltrim(BIRIM),39))
      ElseIf cFiyat="A"
         aAdd(&Isim,Padr(Left(CINSI,27)+Padl(Alltrim(Transform(ALFIY,"999,999,999.99")),9)+" "+;
         Alltrim(BIRIM),39))
      Endif
     Skip
   Enddo
//   aAdd(&Isim,Replicate("Ä",39))
   If Grupno=TGrup
      exit
   endif
   If Sutun=0
      Sutun=1
   Elseif Sutun=1
      Sutun=0
   Endif
  Grupno+=1
Enddo
If Len(FiyGr0)>Len(FiyGr1)
    ASIZE(FiyGr1,Len(FiyGr0))
Else
    ASIZE(FiyGr0,Len(FiyGr1))
Endif
If cFiyat="S"
   aAdd(FiyatRap,Padl(dTar,79))
   aAdd(FiyatRap,Space(80))
   aAdd(FiyatRap,Padc(Alltrim(RAPAYAR->LIS_BAS),80))
   aAdd(FiyatRap,Space(80))
//   aAdd(FiyatRap,Replicate("Ä",80))
ElseIf cFiyat="A"
   aAdd(FiyatRap,Padl(dTar,79))
   aAdd(FiyatRap,Space(80))
   aAdd(FiyatRap,Padc("Maliyet Raporu",80))
   aAdd(FiyatRap,Space(80))
//   aAdd(FiyatRap,Replicate("Ä",80))
Endif
For E=1 To Len(fiyGr1)
    b1=FiyGr0[E];b2=FiyGr1[E]
    If b1=NIL
       b1=Space(39)
    Endif
    If b2=NIL
       b2=Space(39)
    Endif
    If E=1
       A=b1+"Ä"+b2
    Else
       A=b1+"³"+b2
    Endif
    aAdd(FiyatRap,A)
Next
aAdd(FiyatRap,Replicate("Ä",80))
   Set Device To Print
   For E=1 To Len(FiyatRap)
       @ Prow()+1,0 Say FiyatRap[E]
   Next
   Eject
   Set Device To Screen
   Set Printer To
   If nCikis=1 .Or. nCikis=2
//      _TEXTVIEW(cName,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
      __run("less --tilde --shift=3 data/gecici.txt")
   Endif
   RestScreen(0,0,24,79,OldScr1)
  Exit
Enddo
END
Return
//////////////////////////////////////////////////////////////////////////////
Function TekSutunRapor()
nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
OldScr1:=SaveScreen(0,0,24,79)
Select Fiylis
If nCikis=1
   ToplamRap1("E")
Elseif nCikis=2
   lRapor=.T.
   ToplamRap1("D")
Elseif nCikis=3
   nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
   If nCho=1
      Dur=PRN_OFF()
      If Dur<>"Kapali"
         ToplamRap1("Y")
      Endif
   Endif
Endif
TBosalt()
Select Grup
RestScreen(0,0,24,79,OldScr1)
Return
//////////////////////////////////////////////////////////////////////////////
Function ToplamRap1(cAygit)
 Local Kurlar
 Select Para
 aDolar:={}
 Go Top
 For J:=1 To Lastrec()
     If P_BIR!="TL"
        aAdd(aDolar,{P_BIR,0,0,0})
     Endif
     Skip
 Next
 Sele PARAHRK
 Set Order To 2
 dTar=Date()
 Seek(dTar)
 If Found()
    For J:=1 To Len(aDolar)
        aDolar[J,2]=PH_KUR
        Skip
    Next
 Endif
 aAdd(aDolar,{"TL",1,0,0}) ///
 aSatir={}
 aAdd(aSatir,Padl(dTar,79))
 aAdd(aSatir,Space(80))
 S=2
 Select GRUP
 Set Order To 1
 Seek(nGrupNo)
 If Found()
    Do While GRUP_KD=nGrupNo .And. !Eof()
       aAdd(aSatir,Repl("-",80))
       aAdd(aSatir,Padr(GRUP_AD,79))
       aAdd(aSatir,Repl("-",80))
       Select FIYLIS
       Seek(GRUP->GRUP_NO)
       Do While MALNO=GRUP->GRUP_NO .And. !Eof()
          S++
          If RAPAYAR->CEV_KUR!=BIRIM
             If RAPAYAR->CEV_KUR="TL"
                nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==BIRIM})
                nSafiy:=ROUND((aDolar[nDiziSira,2]*SAFIY)/10000,0)*10000
                //nTopfy:=ROUND((aDolar[nDiziSira,2]*TOPFY)/10000,0)*10000
                cBIRIM:="TL"
             Else
                nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==BIRIM})
                nSafiy:=aDolar[nDiziSira,2]*SAFIY
                //nTopfy:=aDolar[nDiziSira,2]*TOPFY
                nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==RAPAYAR->CEV_KUR})
                nSafiy:=ROUND(nSafiy/aDolar[nDiziSira,2],0)
                //nTopfy:=ROUND(nTopfy/aDolar[nDiziSira,2],0)
                cBIRIM:=RAPAYAR->CEV_KUR
             Endif
          Else
             nSafiy:=SAFIY
             //nTopfy:=TOPFY
             cBirim:=BIRIM
          Endif
          aAdd(aSatir,"þ "+CINSI+Space(19)+Transform(nSafiy,'999,999,999.99')+" "+cBirim)
          If !EMPTY(ACIKL) .And. EMPTY(GRUP->GRUP_AC)
             nLines:=MLCOUNT(ACIKL,80,1,.T.)
             For nLine=1 to nLines
                 aAdd(aSatir,"  "+MEMOLINE(ACIKL,80,nLine,1,.T.))
             Next
          Endif
         Skip
       Enddo
       If !EMPTY(GRUP->GRUP_AC)
          aAdd(aSatir,Repl("-",80))
//          aAdd(aSatir,Padr("Ortak zellikleri:",79))
          nLines:=MLCOUNT(GRUP->GRUP_AC,80,1,.T.)
          aAdd(aSatir,"Ortak Özellikleri:"+MEMOLINE(GRUP->GRUP_AC,80,1,1,.T.))
          For nLine=2 to nLines
              aAdd(aSatir,Space(18)+MEMOLINE(GRUP->GRUP_AC,80,nLine,1,.T.))
          Next
       Endif
      Select GRUP
      Skip
    Enddo
 Endif
  aAdd(aSatir,Repl("-",80))
  cName:=""
  If cAygit="D"
     cName := GetAlert("Dosya adını giriniz.",8,{"Tamam","Vazgeç"})
     If Empty(cName)
        Return
     Else
        cName :=Alltrim(cName)+".txt"
     Endif
  Endif

  If cAygit="E" .Or. Empty(cName)
     cName:="gecici.txt"
  Endif

  If cAygit="E" .Or. cAygit="D"
     Set Printer To &cName
  Endif

  For nItem:=1 To 6
      @ Prow()+1,0 Say ""
  Next

  Set Device To Print
  @ Prow()+2,0 Say ""
  For X=1 To Len(aSatir)
      @ Prow()+1,0 Say Padc(aSatir[X],80)
  Next
  @ Prow()+1,0 Say ""
  Eject
  Set Device To Screen
  Set Printer To
  If cAygit="E" .Or. cAygit="D"
//     _TEXTVIEW(cName,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
     __run("less --tilde --shift=3 data/gecici.txt")
  Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function FiyatTop()
OldScr0:=SaveScreen(0,0,24,79)
_TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
TBosalt()
MalKod=0
GrupKod=0
GrupDur=0
lRapor:=.T.
   Select ANAGRUP
   GAlan:={"AGrup_Ad"}
   GBasl:={"ANA GRUP"}
   GPict:={"@K"}
SetColor("15/13") //15/5
   MyBrowse(2,0,22,19,gAlan,gBasl,gPict,"TopFunc1","AGRUP_No",1,99,.F.,.T.,0,0,.T.)
SetColor()
Select Fiylis
Go Top
Replace All OKTOP With " ",;
            MIKTR With 0  ,;
            TOPFY With 0
Replace RAPAYAR->BAS_DUR With " "
RestScreen(0,0,24,79,OldScr0)
Return
//////////////////////////////////////////////////////////////////////////////
Function TopFunc1()
Local lRet:=.T.
Do Case
    Case ( nKey == K_ESC )
         If lRapor=.F.
            nCho:=_Alert("Seçilenler kaydedilmedi!;"+;
                        "devam edilsin mi?",{"Hayır","Evet"})
            If nCho=2
               lRet=.F.
            Endif
         Else
            lRet=.F.
         Endif
         GrpGeriAlAktar()
         Select ANAGRUP
         TBosalt()
         _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
    Case ( nKey == K_ENTER )
         _Savescr(2,0,22,19,"GrupScr1")
         _TusYaz(24,1,{"~ENTER/TAB~-Seçim","~F5~-Rapor","~F6~-Aktar","~F7~-Getir","~F8~-Sıfırla","~ESC~-Çıkış"})
         GrupKod=AGRUP_NO
         Select GRUP
         fAlan:={"Grup_Ad"}
         fBasl:={"ALT GRUP"}
         fPict:={"@K"}

         SetColor("15/13") //15/5
         oB:DEHILITE()
         MyBrowse(2,0,22,19,fAlan,fBasl,fPict,"TopFunc2","GRUP_KD",GrupKod,,.F.,.T.,0,0,.T.)
         SetColor()
         _Savescr(,,,,)
         Select ANAGRUP
         TBosalt()
         _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function TopFunc2()
Local lRet:=.T.
Do Case
    Case ( nKey == K_ESC )
         lRet=.F.
    Case ( nKey == K_ENTER ) .Or. ( nKey == K_TAB )
         _Savescr(2,0,22,19,"GrupScr2")
         MalKod=Grup_No
         Select Grup
         Donhal=Grup_Ad
         Select Fiylis
         @ 1,0 Say Padc(Alltrim(DonHal)+"-"+_TR(" Seçim Kartı"),80)  Color("4/3")
         _TusYaz(24,1,{"~SPACE~-İşaretle","~DEL~-İşareti Kaldır","~ESC/TAB~-Çıkış"})
         Alan:={"CINSI","SAFIY","BIRIM","MIKTR","OKTOP"}
         Picture:={"@S37","999,999,999.99","@K","99","@K"}
         Baslik:={"Açıklama","Fiyat","  ","Ad"," "}
         SetColor("15/6") //15/3
         oB:DEHILITE()
         MyBrowse(2,20,22,79,Alan,Baslik,Picture,"TopFunc3","MALNO",MalKod,,.F.,.F.,0,0,.T.)
         _Savescr(,,,,)
         SetColor()
         Select Grup
         TBosalt()
    Case (nKey == K_F5 )
         nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
         OldScr1:=SaveScreen(0,0,24,79)
         Select Fiylis
         If nCikis=1
            ToplamRap("E","S")
         Elseif nCikis=2
            lRapor=.T.
            ToplamRap("D","S")
         Elseif nCikis=3
            nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
            If nCho=1
               Dur=PRN_OFF()
               If Dur<>"Kapali"
                  ToplamRap("Y","S")
               Endif
            Endif
         Endif
         TBosalt()
         Select Fiylis
         SET RELATION TO
         Select Grup
         Seek(MalKod)
         oB:RefreshAll()
         Set Order To 1
         RestScreen(0,0,24,79,OldScr1)
    Case ( nKey == K_F6 )
         GrpAktar()
         lRapor=.T.
    Case ( nKey == K_F7 )
         GrpGetir()
         lRapor=.F.
    Case ( nKey == K_F8 )
         If lRapor=.F.
            nCho:=_Alert("Seçilenler iptal edilsin mi ?",{"Hayır","Evet"})
            If nCho=2
               Select Fiylis
               Go Top
               Replace All OKTOP With " ",;
                           MIKTR With 0  ,;
                           TOPFY With 0
               Replace RAPAYAR->BAS_DUR With " "
               Select Grup
               lRapor=.T.
             Keyboard Chr(13)+Chr(27)
            Endif
         Endif
    Case (nKey == K_F12 )
         nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
         OldScr1:=SaveScreen(0,0,24,79)
         Select Fiylis
         If nCikis=1
            ToplamRap("E","A")
         Elseif nCikis=2
            lRapor=.T.
            ToplamRap("D","A")
         Elseif nCikis=3
            nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
            If nCho=1
               Dur=PRN_OFF()
               If Dur<>"Kapali"
                  ToplamRap("Y","A")
               Endif
            Endif
         Endif
         TBosalt()
         Select Fiylis
         SET RELATION TO
         Select Grup
         Seek(MalKod)
         oB:RefreshAll()
         Set Order To 1
         RestScreen(0,0,24,79,OldScr1)
    Case ( nKey == K_ALT_A )
         RaporAyar()
    Case ( nKey == K_ALT_K )
         KurGir()
    Case ( nKey == K_ALT_G )
         MakinaGir()

EndCase
_TusYaz(24,1,{"~ENTER/TAB~-Seçim","~F5~-Rapor","~F6~-Aktar","~F7~-Getir","~F8~-Sıfırla","~ESC~-Çıkış"})
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function TopFunc3()
Local lRet:=.T.
Do Case
//   case nKey == K_RETURN
//      If sFound=.T. .And. lGetLock=.T. .And. oB:COLPOS<=4
//         Doget(oB,lAppend)
//         If oB:COLPOS>2
//            KHesap()
//         Endif
//      Endif

   case ( nKey == K_SPACE )
      lRapor=.F.
      nMIKTR=MIKTR
      If nMIKTR<99
        nMIKTR++
        Repl MIKTR With nMIKTR
//        Repl TOPFY With (SAFIY*MIKTR)
          If MIKTR>0
             Repl OKTOP With "û"
          Else
             Repl OKTOP With " "
          Endif
        oB:REFRESHALL()
        sFound=.T.
      Endif
   case ( nKey == K_DEL )
      nMIKTR=MIKTR
If nMIKTR>0
      nMIKTR--
      Repl MIKTR With nMIKTR
//      Repl TOPFY With (SAFIY*MIKTR)
        If MIKTR>0
           Repl OKTOP With "û"
        Else
           Repl OKTOP With " "
        Endif
      oB:REFRESHALL()
      sFound=.T.
Endif
   case (nKey == K_RETURN) .OR. (nKey == K_ESC ) .OR. ( nKey == K_TAB )
       lRet=.F.
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function ToplamRap(cAygit,cFiyat)
 Local Kurlar
 Select Para
 aDolar:={}
 Go Top
 For J:=1 To Lastrec()
     If P_BIR!="TL"
        aAdd(aDolar,{P_BIR,0,0,0})
     Endif
     Skip
 Next
 Sele PARAHRK
 Set Order To 2
 dTar=Date()
 Seek(dTar)
 If Found()
    For J:=1 To Len(aDolar)
        aDolar[J,2]=PH_KUR
        Skip
    Next
 Endif
 aAdd(aDolar,{"TL",1,0,0}) ///
 aSatir={}
 Select Grup
 Set Order To 2
 Sele Fiylis
 SET RELATION TO MALNO INTO GRUP
 Locate for OKTOP='û'
  If !Found()
     _Alert("Kayıt seçimi yapılmamış!")
     Return
  Endif
  aAdd(aSatir,Padl(dTar,79))
  aAdd(aSatir,Space(80))
  If cFiyat="A"
     aAdd(aSatir,Padc("Maliyet Raporu",80))
     aAdd(aSatir,Padc("--------------",80))
     aAdd(aSatir,Space(80))
  Endif
  aAdd(aSatir,Space(80))
  aAdd(aSatir,Padc("Açıklama",43)+" "+Padc("Mik",3)+" "+Padc("Fiyat",14)+" "+;
                Padc("Tutar",14)+" "+Padc("  ",2))
  aAdd(aSatir,Repl("-",43)+" "+Repl("-",3)+" "+Repl("-",14)+" "+;
                Repl("-",14)+" "+Repl("-",2))
  S=2
  Do While Found()
     If cFiyat="S"
        Repl TOPFY With (SAFIY*MIKTR)
     ElseIf cFiyat="A"
        Repl TOPFY With (ALFIY*MIKTR)
     Endif
     S++
     If RAPAYAR->CEV_KUR!=BIRIM
        If RAPAYAR->CEV_KUR="TL"
           nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==BIRIM})
           If cFiyat="S"
              nSafiy:=ROUND((aDolar[nDiziSira,2]*SAFIY)/10000,0)*10000
           ElseIf cFiyat="A"
              nSafiy:=ROUND((aDolar[nDiziSira,2]*ALFIY)/10000,0)*10000
           Endif
           nTopfy:=ROUND((aDolar[nDiziSira,2]*TOPFY)/10000,0)*10000
           cBIRIM:="TL"
        Else
           nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==BIRIM})
           If cFiyat="S"
              nSafiy:=aDolar[nDiziSira,2]*SAFIY
           ElseIf cFiyat="A"
              nSafiy:=aDolar[nDiziSira,2]*ALFIY
           Endif
           nTopfy:=aDolar[nDiziSira,2]*TOPFY
           nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==RAPAYAR->CEV_KUR})
           nSafiy:=ROUND(nSafiy/aDolar[nDiziSira,2],0)
           nTopfy:=ROUND(nTopfy/aDolar[nDiziSira,2],0)
           cBIRIM:=RAPAYAR->CEV_KUR
        Endif
     Else
        If cFiyat="S"
           nSafiy:=SAFIY
        ElseIf cFiyat="A"
           nSafiy:=ALFIY
        Endif
        nTopfy:=TOPFY
        cBirim:=BIRIM
     Endif
     aAdd(aSatir,PADL(CINSI,43)+" "+Padc(MIKTR,3)+" "+Transform(nSafiy,'999,999,999.99')+" "+;
                    Transform(nTopfy,'999,999,999.99')+" "+cBirim)
     If !EMPTY(FIYLIS->ACIKL)
        nLines:=MLCOUNT(FIYLIS->ACIKL,80,1,.T.)
        For nLine=1 to nLines
            aAdd(aSatir,"  "+MEMOLINE(FIYLIS->ACIKL,80,nLine,1,.T.))
        Next
     ElseIf !EMPTY(GRUP->GRUP_AC)
        nLines:=MLCOUNT(GRUP->GRUP_AC,80,1,.T.)
        For nLine=1 to nLines
            aAdd(aSatir,"  "+MEMOLINE(GRUP->GRUP_AC,80,nLine,1,.T.))
        Next
     Endif
     DiziTopla()
    Continue
  Enddo
  aAdd(aSatir,Repl("-",43)+" "+Repl("-",3)+" "+Repl("-",14)+" "+;
                 Repl("-",14)+" "+Repl("-",2))
  nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==RAPAYAR->CEV_KUR})
  aAdd(aSatir,Space(55)+"Toplam: "+Transform(aDolar[nDiziSira,3],"999,999,999.99")+Space(1)+aDolar[nDiziSira,1])
  If RAPAYAR->KDV_DUR $ "û"
     aAdd(aSatir,Space(55)+"   Kdv: "+Transform(aDolar[nDiziSira,4],"999,999,999.99")+Space(1)+aDolar[nDiziSira,1])
  Endif
  nGenTop:=aDolar[nDiziSira,3]+aDolar[nDiziSira,4]

  If RAPAYAR->GTP_DUR $ "û"
     aAdd(aSatir,Space(63)+Repl("-",14)+" "+Repl("-",2))
     aAdd(aSatir,Space(49)+"Genel Toplam: "+Transform(nGenTop,"999,999,999.99")+Space(1)+RAPAYAR->CEV_KUR)
  Endif

  cName:=""
  If cAygit="D"
     cName := GetAlert("Dosya adını giriniz.",8,{"Tamam","Vazgeç"})
     If Empty(cName)
        Return
     Else
        cName :=Alltrim(cName)+".txt"
     Endif
  Endif

  If cAygit="E" .Or. Empty(cName)
     cName:="gecici.txt"
  Endif

  If cAygit="E" .Or. cAygit="D"
     Set Printer To &cName
  Endif

  For nItem:=1 To 6
      @ Prow()+1,0 Say ""
  Next

  If RAPAYAR->BAS_DUR $ "û" .And. cFiyat="S"
     aSatir[1]:=Space(80)
     Set Device To Print
     @ Prow()+1,0 Say Padl(dTar,79)
     @ Prow()+1,0 Say ""
     @ Prow()+1,0 Say ""
     nLines:=MLCOUNT(RAPAYAR->BAS_NOT,80,1,.T.)
     For nLine=1 to nLines
         @ Prow()+1,0 Say MEMOLINE(RAPAYAR->BAS_NOT,80,nLine,1,.T.)
     Next
     Set Device To Screen
  Endif

  Set Device To Print
  @ Prow()+2,0 Say ""
  For X=1 To Len(aSatir)
      @ Prow()+1,0 Say Padc(aSatir[X],80)
  Next
  @ Prow()+1,0 Say ""

  If RAPAYAR->NOT_DUR $ "û" .And. cFiyat="S"
     If RAPAYAR->NT1_DUR $ "û"
        @ Prow()+1,0 Say Padr(RAPAYAR->DIP_NT1,80)
     Endif
     If RAPAYAR->NT2_DUR $ "û"
        @ Prow()+1,0 Say Padr(RAPAYAR->DIP_NT2,80)
     Endif
     If RAPAYAR->NT3_DUR $ "û"
        @ Prow()+1,0 Say Padr(RAPAYAR->DIP_NT3,80)
     Endif
     If RAPAYAR->NT4_DUR $ "û"
        @ Prow()+1,0 Say Padr(RAPAYAR->DIP_NT4,80)
     Endif
     If RAPAYAR->NT5_DUR $ "û"
        @ Prow()+1,0 Say Padr(RAPAYAR->DIP_NT5,80)
     Endif
  Endif
  If RAPAYAR->KUR_DUR $ "û"
     Kurlar:="Bugünkü kurlar="
     For J=1 To Len(aDolar)
         If aDolar[J,1]!="TL"
            Kurlar:=Kurlar+aDolar[J,1]+":"+;
                    Alltrim(Transform(aDolar[J,2],"9,999,999.99"))+"TL. "
         Endif
     Next
     @ Prow()+1,0 Say Padr(Kurlar,80)
  Endif
  @ Prow()+1,0 Say ""
  Eject
  Set Device To Screen
  Set Printer To
  If cAygit="E" .Or. cAygit="D"
//     _TEXTVIEW(cName,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
    __run("less --tilde --shift=3 data/gecici.txt")
  Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function GrpGeriAlAktar()
Select MAKANA
Seek(1)
If !Found()
   Append Blank
   Replace AMAK_KOD With 1,;
           AMAK_ADI With "Geri Al",;
           AMAK_DUR With "û"
Endif
Sele Fiylis
Locate All for OKTOP='û'
If !Found()
   Select Grup
   Return
Else
   Select MAKHRK
   Delete All For MAK_KOD=1
   Pack
   Select FIYLIS
Endif
Do While Found()
   GrpKod=SIRNO
   GrpMik=MIKTR
   Select MAKHRK
   Append Blank
   Replace MAK_KOD With 1,;
           GRP_KOD With GrpKod,;
           GRP_MIK With GrpMik
  Select Fiylis
 Continue
Enddo
Select Grup
Return
//////////////////////////////////////////////////////////////////////////////
Function GrpAktar()
   AktScr:=SaveScreen(5,27,20,53)
   _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
   gAlan:={"AMAK_ADI","AMAK_DUR"}
   gBasl:={"Grup Adı"," "}
   gPict:={"@K","@K"}
   MakKod=0
   Select MAKANA
   SetColor("15/5,15/1,,,15/5")
   MyBrowse(5,27,19,52,gAlan,gBasl,gPict,"GirFunc4","AMAK_KOD",1,99,.F.,.T.,0,0,.T.)
   SetColor()
   If !Lastkey()=K_ESC
      If AMAK_KOD=1
         _Alert("Bu kayıt üzerine aktarma yapılamaz!")
         nCho=2
      Else
         If AMAK_DUR="û"
            cMsj:="`"+Alltrim(AMAK_ADI)+"'"+" gurubunda kayıt var;"+;
                  "işaretlenen kayıtlar üzerine aktarılsın mı?"
         Else
            cMsj:="İşaretlenen kayıtlar "+"`"+Alltrim(AMAK_ADI)+"';"+;
                   " gurubuna aktarılsın mı?"
         Endif
         nCho:=_Alert(cMsj,{"Evet","Hayır"})
         If nCho=1
            MakKod=AMAK_KOD
            Repl AMAK_DUR With "û"
         Endif
      Endif
   Else
      RestScreen(5,27,20,53,AktScr)
      Select Grup
      Return
   Endif
   RestScreen(5,27,20,53,AktScr)
 Sele Fiylis
 Locate All for OKTOP='û'
  If !Found()
     If nCho=1
        _Alert("Kayıt seçimi yapılmamış!")
     Endif
     Select Grup
     Return
  Else
     Select MAKHRK
     Delete All For MAK_KOD=MakKod
     Pack
     Select FIYLIS
  Endif
  Do While Found()
     GrpKod=SIRNO
     GrpMik=MIKTR
     Select MAKHRK
     Append Blank
     Repl MAK_KOD With MakKod
     Repl GRP_KOD With GrpKod
     Repl GRP_MIK With GrpMik
     Select Fiylis
   Continue
  Enddo
Select Grup
Return
//////////////////////////////////////////////////////////////////////////////
Function GrpGetir()
   AktScr:=SaveScreen(5,27,20,53)
   _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
   gAlan:={"AMAK_ADI","AMAK_DUR"}
   gBasl:={"Grup Adı"," "}
   gPict:={"@K","@K"}
   MakKod=0
   Select MAKANA
   SetColor("15/5,15/1,,,15/5")
   MyBrowse(5,27,19,52,gAlan,gBasl,gPict,"GirFunc4","AMAK_KOD",1,99,.F.,.T.,0,0,.T.)
   SetColor()
   If !Lastkey()=K_ESC
      If AMAK_DUR=" "
         _Alert("`"+Alltrim(AMAK_ADI)+"'"+" gurubunda;"+;
               "kayıt yok!",{"Tamam"})
         RestScreen(5,27,20,53,AktScr)
         Select Grup
         Return
      Else
         nCho:=_Alert("`"+Alltrim(AMAK_ADI)+"'"+" gurubundaki;"+;
                     "kayıtlar aktarılsın mı?",{"Evet","Hayır"})
         If nCho=1
            MakKod=AMAK_KOD
         Endif
      Endif
   Else
      RestScreen(5,27,20,53,AktScr)
      Select Grup
      Return
   Endif
   RestScreen(5,27,20,53,AktScr)
 Select MAKHRK
 Locate All for MAK_KOD=MakKod
  If !Found()
     If nCho=1
        _Alert("Koşula uygun kayıt bulunamadı!")
     Endif
     Select Grup
     Return
  Endif
  Do While Found()
     GrpKod=GRP_KOD
     GrpMik=GRP_MIK
     Select FIYLIS
     Set Order To 2
     Seek(GrpKod)
     Do While SIRNO=GrpKod
        Repl OKTOP With "û"
        Repl MIKTR With MIKTR+GrpMik
        Repl TOPFY With (SAFIY*MIKTR)
      Skip
     Enddo
     Select MAKHRK
   Continue
  Enddo
Select FIYLIS
Set Order To 1
Select Grup
Keyboard Chr(13)+Chr(27)
Return
//////////////////////////////////////////////////////////////////////////////
Function DiziTopla()
 nDiziSira:=aScan(aDolar,{|aVal| aVal[1]==RAPAYAR->CEV_KUR})
 nFiyTop=nTopfy+aDolar[nDiziSira,3]
 nKdvTop=((nTopfy*KDVOR)/100)+aDolar[nDiziSira,4]
 aDolar[nDiziSira,3]=nFiyTop
 aDolar[nDiziSira,4]=nKdvTop
Return
//////////////////////////////////////////////////////////////////////////////
Function KurGir()
Set Key K_ALT_A To
Set Key K_ALT_K To
Set Key K_ALT_G To
Set Key K_ALT_P To
  OldKurSel=Select()
  dTar:=Date()
  OldColor:=SetColor()
  KurScr:=SaveScreen(0,0,24,79)
 Select Para
 aDol={}
 Go Top
 For J:=1 To Lastrec()
     If P_BIR!="TL"
        aAdd(Adol,P_BIR)
     Endif
     Skip
 Next
Select ParaHrk
Go Top
Set Order To 1
   For I=1 To Len(aDol)
       Seek(aDol[I])
       If !Found()
          Append Blank
          Repl PH_TAR With dTar
          Repl PH_BIR With aDol[I]
          Repl PH_KUR With 1
       Endif
   Next
Set Order To 2
Go Top
Seek(dTar)
If !Found()
   For I=1 To Len(aDol)
       Append Blank
       Repl PH_TAR With dTar
       Repl PH_BIR With aDol[I]
       Repl PH_KUR With 1
   Next
Endif
_TusYaz(24,1,{"~ENTER~-Değiştir","~F4~-Para Birimi","~F5~-Rapor","~ESC~-Çıkış"})
@ 6,29 Say _TR("Bugünkü Kuru Giriniz!") Color "15/2"
Alan:={"PH_BIR","PH_KUR"}
Picture:={"@K","999,999.99"}
Baslik:={"Para Birimi","Kur"}
SetColor("15/5,15/1,,,15/5")
MyBrowse(7,26,16,52,Alan,Baslik,Picture,"KurFunc1","PH_TAR",dTar,,.T.,.T.,1,2,.T.)
SetColor()
RestScreen(0,0,24,79,KurScr)
Select &OldKurSel
SetColor(OldColor)
Set Key K_ALT_A To RaporAyar()
Set Key K_ALT_K To KurGir()
Set Key K_ALT_G To MakinaGir()
Set Key K_ALT_P To KasaIslem()
Return
//////////////////////////////////////////////////////////////////////////////
Function KurFunc1()
Local lRet:=.T.
Do Case
   case ( nKey == K_ENTER )
        nOldKur:=PH_KUR
        Doget(oB,lAppend)
        oCol := oB:getColumn(2)

//        If Eval(oCol:block)<2

//           Keyboard Chr(13)
//        Else
//           TBosalt()
//        Endif
        If PH_KUR!=nOldKur
           Select Para
           Go Top
           Do While !Eof()
              If P_BIR=ParaHrk->PH_BIR
                 Repl P_TAR With Date(),;
                      P_KUR With ParaHrk->PH_KUR
              Endif
            Skip
           Enddo
        Endif
        Select ParaHrk
   case ( nKey == K_F4 )
        ParaGir()
        Select ParaHrk
        Seek(dTar)
        sFound=Found()
        oB:REFRESHAll()
   case ( nKey == K_F5 )
        OldScr:=SaveScreen(0,0,24,79)
        KurRapor()
        RestScreen(0,0,24,79,OldScr)
        TBosalt()
        Seek(dTar)
        sFound=Found()
        oB:REFRESHAll()
   case ( nKey == K_ESC )
        lRet=.F.
        TBosalt()
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function KurRapor()
dIlkTar:=Ctod("")
dSonTar:=CTod("")
_Win(11,27,14,51,"15/13",1,1)
SETCURSOR(1)
SetColor("15/13,15/1,,,15/13")
@ 12,29 Say _TR("İlk Tarih  :") Get dIlkTar Pict "99/99/99"
@ 13,29 Say _TR("Son Tarih  :") Get dSonTar Pict "99/99/99"
Read
SETCURSOR(0)
If Lastkey()=K_ESC
   Return(0)
Endif

nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
If nCikis=1
   cAygit:="E"
Elseif nCikis=2
   cAygit:="D"
Elseif nCikis=3
   nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
   If nCho=1
      Dur=PRN_OFF()
      If Dur<>"Kapali"
         cAygit:="Y"
      Endif
   Endif
Elseif nCikis=0
   Return(0)
Endif

 cName:=""
 If cAygit="D"
    cName := GetAlert("Dosya adını giriniz.",8,{"Tamam","Vazgeç"})
    If Empty(cName)
       Return
    Else
       cName :=Alltrim(cName)+".txt"
    Endif
 Endif

 If cAygit="E" .Or. Empty(cName)
    cName:="gecici.txt"
 Endif

 If cAygit="E" .Or. cAygit="D"
    Set Printer To &cName
 Endif
 Set Device To Print
 Select Para
 aDolar:={}
 Go Top
 For J:=1 To Lastrec()
     If P_BIR!="TL"
        aAdd(aDolar,{P_BIR,P_ACK})
     Endif
     Skip
 Next
cSatir:=Padc("Tarih",8)
cCizgi:=Replicate("-",8)
For J:=1 To Len(aDolar)
    cSatir:=cSatir+" "+Padc(Alltrim(aDolar[J,1])+" ("+Alltrim(aDolar[J,2])+")",11)
    cCizgi:=cCizgi+" "+Replicate("-",11)
Next
@ Prow()+1,0 Say cSatir
@ Prow()+1,0 Say cCizgi
Select ParaHrk
Set Order To 2
If Empty(dSontar)
   dSonTar:=Date()
Endif
Go Top
DbSeek(dIlkTar,.T.)
 Do While .T.
    If PH_TAR<=dSonTar .And. !Eof()
       cSatir:=Padc(PH_TAR,8)
       For J:=1 To Len(aDolar)
           If PH_BIR=aDolar[J,1]
              cSatir:=cSatir+" "+Padc(Transform(PH_KUR,"9,999,999.99"),12)
              Skip
           Endif
       Next
         @ Prow()+1,0 Say cSatir
    Else
       Exit
    Endif
 Enddo
 @ Prow()+1,0 Say ""
 Eject
 Set Device To Screen
 Set Printer To
 If cAygit="E" .Or. cAygit="D"
//    _TEXTVIEW(cName,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
    __run("less --tilde --shift=3 data/gecici.txt")
 Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function ParaGir()
Select Para
ParScr:=SaveScreen(0,0,24,79)
_TusYaz(24,1,{"~F2~-Ekle","~F3~-Sil",;
              "~F4~-Değiştir","~ESC~-Çıkış"})

@ 6,29 Say " Takip Edilen Kurlar " Color "15/2"
gAlan:={"P_BIR","P_ACK"}
gBasl:={"Br.","Açıklama"}
gPict:={"@K","@K"}
SetColor("15/5")
MyBrowse(7,26,16,52,gAlan,gBasl,gPict,"ParaFunc","P_BIR","",,.T.,.T.,0,2,.T.)
SetColor()
RestScreen(0,0,24,79,ParScr)
Return
//////////////////////////////////////////////////////////////////////////////
Function ParaFunc()
Static XKey:=.F.
Local lRet:=.T.
Do Case
   Case nKey=K_ESC
        lRet=.F.
   Case nKey=K_F4
         If XKey=.F.
            nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
         Else
            nCho=2
         Endif
         cOldBir:=P_BIR
         If nCho=2 .And. cOldBir!="TL"
             Doget(oB,lAppend)
            If oB:ColPos<2
               oB:refreshCurrent()
               KEYBOARD CHR(K_RIGHT)+CHR(K_CTRL_RETURN)
               If Empty(P_BIR)
                  Delete
                  Pack
                  Select PARAHRK
                  Replace All PH_BIR With " " For PH_BIR=cOldBir
                  Select FIYLIS
                  Replace All BIRIM With " " For BIRIM=cOldBir
                  Select PARA
                  oB:REFRESHALL()
                  TBosalt()
               Elseif P_BIR!=cOldBir
                  Select PARAHRK
                  Replace All PH_BIR With PARA->P_BIR For PH_BIR=cOldBir
                  Select FIYLIS
                  Replace All BIRIM With PARA->P_BIR For BIRIM=cOldBir
                  Select PARA
               Endif
              XKey=.T.
            Else
            oB:REFRESHALL()
               XKey=.F.
            Endif
            sFound=.T.
         Endif
         lRet=.T.
   Case nKey=K_F2
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            Append Blank
            Replace P_BIR With "ÿ"
            oB:REFRESHALL()
            XKey=.T.
            Keyboard Chr(K_CTRL_ENTER)
            sFound=.T.
         Endif
         lRet=.T.
   Case nKey=K_F3
         nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
         cOldBir=P_BIR
         If nCho=2 .And. cOldBir!="TL"
            Delete
            Pack
            Select PARAHRK
            Delete All For PH_BIR=cOldBir
            Pack
            Select FIYLIS
            Replace All BIRIM With " " For BIRIM=cOldBir
            TBosalt()
            SetCursor(0)
            Select PARA
            oB:REFRESHALL()
         Endif
         lRet=.T.
         XKey=.F.
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function KurSec()
   KurScr:=SaveScreen(7,33,18,46)
   KurTus:=SaveScreen(24,0,24,79)
   _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
   gAlan:={"P_ACK"}
   gBasl:={"Para Birimi"}
   gPict:={"@K"}
   ParaBir=""
   Select PARA
   SetColor("15/5,15/1,,,15/5")
   MyBrowse(7,33,17,45,gAlan,gBasl,gPict,"GirFunc4","P_BIR","",,.F.,.T.,0,0,.T.)
   SetColor()
   If !Lastkey()=K_ESC
      ParaBir=P_BIR
   Endif
   RestScreen(7,33,18,46,KurScr)
   RestScreen(24,0,24,79,KurTus)
Return
//////////////////////////////////////////////////////////////////////////////
Function FirmaSec()
   FirScr:=SaveScreen(7,33,18,46)
   FirTus:=SaveScreen(24,0,24,79)
   _TusYaz(24,1,{"~ENTER~-Seçim","~ESC~-Çıkış"})
   gAlan:={"FIR_ADI"}
   gBasl:={"Firma Ad"}
   gPict:={"@K"}
   FirmaKod=""
   Select FIRMA
   SetColor("15/5,15/1,,,15/5")
   MyBrowse(7,33,17,45,gAlan,gBasl,gPict,"GirFunc4","FIR_KOD","",,.F.,.T.,0,0,.T.)
   SetColor()
   If !Lastkey()=K_ESC
      FirmaKod=FIR_KOD
   Endif
   RestScreen(7,33,18,46,FirScr)
   RestScreen(24,0,24,79,FirTus)
Return
//////////////////////////////////////////////////////////////////////////////
Function FirmaGir()
Select Firma
FirScr:=SaveScreen(0,0,24,79)
_TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
              "~F4~-Değiştir","~F5~-Rapor","~ESC~-Çık"})
gAlan:={"FIR_KOD","FIR_ADI"}
gBasl:={"Kod","Açıklama"}
gPict:={"@K","@K"}
SetColor("15/5")
MyBrowse(7,19,16,59,gAlan,gBasl,gPict,"FirFunc","FIR_KOD","",,.T.,.T.,0,2,.T.)
SetColor()
RestScreen(0,0,24,79,FirScr)
Return
//////////////////////////////////////////////////////////////////////////////
Function FirFunc()
Static XKey:=.F.
Local lRet:=.T.
Do Case
   Case nKey=K_ESC
        lRet=.F.
   Case nKey=K_F4
        If XKey=.F.
           nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
        Else
           nCho=2
        Endif
        cOldFir:=FIR_KOD
        If nCho=2
            Doget(oB,lAppend)
           If oB:ColPos<2
              oB:refreshCurrent()
              KEYBOARD CHR(K_RIGHT)+CHR(K_CTRL_RETURN)
              If Empty(FIR_KOD)
                 Delete
                 Pack
                 Select FIYLIS
                 Replace All FIRMA With " " For FIRMA=cOldFir
                 Select FIRMA
                 oB:REFRESHALL()
                 TBosalt()
              Elseif FIR_KOD!=cOldFir
                 Select FIYLIS
                 Replace All FIRMA With FIRMA->FIR_KOD For FIRMA=cOldFir
                 Select FIRMA
              Endif
              XKey=.T.
           Else
              oB:REFRESHALL()
              XKey=.F.
           Endif
           sFound=.T.
        Endif
        lRet=.T.
   Case nKey=K_F2
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            Append Blank
            Replace FIR_KOD With "ÿ"
            oB:REFRESHALL()
            XKey=.T.
            Keyboard Chr(K_CTRL_ENTER)
            sFound=.T.
         Endif
         lRet=.T.
   Case nKey=K_F3
         nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
         If nCho=2
            cOldFir=FIR_KOD
            Delete
            Pack
            Select FIYLIS
            Replace All FIRMA With " " For FIRMA=cOldFir
            TBosalt()
            SetCursor(0)
            Select FIRMA
            oB:REFRESHALL()
         Endif
         lRet=.T.
         XKey=.F.
   Case nKey=K_F5
        cFirmaKod:=FIR_KOD
        cFirmaAdi:=FIR_ADI
        OldScr1:=SaveScreen(0,0,24,79)
        FirmaRap()
        Select Firma
        RestScreen(0,0,24,79,OldScr1)
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function FirmaRap()
 nCikis:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Dosya","Yazıcı"})
 If nCikis=0
    Return
 Endif
 If nCikis=3
    nCho:=_Alert("Yazıcıyı hazırlayıp ENTER tuşuna basınız.",{"Tamam","Vazgeç"})
    If nCho=1
       Dur=PRN_OFF()
       If Dur="Kapali"
          Return
       Endif
    Else
       Return
    Endif
  Endif
 aSatir={}
 Select Fiylis
 Locate for FIRMA=cFirmaKod
  If !Found()
     _Alert("Koşula uygun kayıt bulunamadı!")
     Return
  Endif
  aAdd(aSatir,Padc(Alltrim(cFirmaAdi)+" - Fiyat Listesi",79))
  aAdd(aSatir,"")
  aAdd(aSatir,Padc("Açıklama",41)+" "+Padc("Alış Fiyatı",14)+" "+;
               Padc("  ",2)+" "+Padc("Satış Fiyatı",14)+" "+Padc("  ",2))
  aAdd(aSatir,Repl("-",41)+" "+Repl("-",14)+" "+;
               Repl("-",2)+" "+Repl("-",14)+" "+Repl("-",2))
  S=3
  Do While Found()
     S++
     aAdd(aSatir,Padc(CINSI,41)+" "+Transform(ALFIY,'999,999,999.99')+" "+;
                    BIRIM+" "+Transform(SAFIY,'999,999,999.99')+" "+BIRIM)
     Continue
  Enddo
  aAdd(aSatir,Repl("-",41)+" "+Repl("-",14)+" "+;
                 Repl("-",2)+" "+Repl("-",14)+" "+Repl("-",2))
  cName:=""
  If nCikis=2
     cName := GetAlert("Dosya adını giriniz.",8,{"Tamam","Vazgeç"})
     If Empty(cName)
        Return
     Else
        cName :=Alltrim(cName)+".txt"
     Endif
  Endif

  If nCikis=1 .Or. Empty(cName)
     cName:="gecici.txt"
  Endif

  If nCikis=1 .Or. nCikis=2
     Set Printer To &cName
  Endif

  Set Device To Print
  @ Prow()+2,0 Say ""
  For X=1 To Len(aSatir)
      @ Prow()+1,0 Say Padc(aSatir[X],80)
  Next
  @ Prow()+1,0 Say ""
  Eject
  Set Device To Screen
  Set Printer To
  If nCikis=1 .Or. nCikis=2
  SetCursor(0)
//     _TEXTVIEW(cName,0,0,24,79,1,7,0,"AABB",.T.,1,132,4096)
  __run("less --tilde --shift=3 data/gecici.txt")
  Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function MakinaGir()
Set Key K_ALT_A To
Set Key K_ALT_K To
Set Key K_ALT_G To
Set Key K_ALT_P To
OldMakSel=Select()
OldColor:=SetColor()
MakScr:=SaveScreen(0,0,24,79)
Select MAKANA
_TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
              "~F4~-Değiştir","~ESC~-Çık"})
gAlan:={"AMAK_ADI"}
gBasl:={"Grup Adı"}
gPict:={"@K"}
SetColor("15/5")
MyBrowse(5,29,19,50,gAlan,gBasl,gPict,"MakFunc","AMAK_KOD",1,99,.T.,.T.,0,0,.T.)
SetColor()
RestScreen(0,0,24,79,MakScr)
Select &OldMakSel
SetColor(OldColor)
Set Key K_ALT_A To RaporAyar()
Set Key K_ALT_K To KurGir()
Set Key K_ALT_G To MakinaGir()
Set Key K_ALT_P To KasaIslem()
Return
//////////////////////////////////////////////////////////////////////////////
Function MakFunc()
Static XKey:=.F.
Local lRet:=.T.
Do Case
    Case ( nKey == K_ESC )
         lRet=.F.
    Case ( nKey == K_F4 )
         If AMAK_KOD=1
            _Alert("Bu kayıt üzerinde değişiklik yapılamaz!")
         Else
            If XKey=.F.
               nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
            Else
               nCho=2
            Endif
            If nCho=2
               Doget(oB,lAppend)
               XKey=.F.
            Endif
         Endif
    Case ( nKey == K_F2 )
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            nKay=1
            Do While .T.
               Seek(nKay)
               If Found()
                  Skip
                  nKay+=1
                  Loop
               Else
                  SetCursor(1)
                  Append Blank
                  Repl AMAK_KOD With nKay
                  oB:REFRESHALL()
                  Keyboard Chr(K_CTRL_ENTER)
                  sFound=.T.
                  XKey=.T.
                  SetCursor(0)
                  Exit
               Endif
            Enddo
        Endif
    Case ( nKey == K_F3 )
        If AMAK_KOD=1
           _Alert("Bu kayıt silinemez!")
        Else
           nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
           If nCho=2
              dKay=AMAK_KOD
              Delete
              Pack
              oB:REFRESHAll()
              Select MAKHRK
              DELETE FOR MAK_KOD=dKay
              TBosalt()
              XKey=.F.
              SetCursor(0)
              Select MAKANA
           Endif
        Endif
EndCase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function RaporAyar()
OldRapSel=Select()
OldColor:=SetColor()
If RAPAYAR->SCR_SUR>0
   Keysec()
//   Trapanykey()
   Set key 273 to
Endif
Set Key K_ALT_A To
Set Key K_ALT_K To
Set Key K_ALT_G To
Set Key K_ALT_P To
Set Key K_F10 To GetSec()
Sele RapAyar
AyarScr:=SaveScreen(1,0,23,79)
AyarTus:=SaveScreen(24,0,24,79)
_TusYaz(24,1,{"~SPACE~-İşaretle","~F10~-Seçim","~ESC~-Çıkış"})
_Win(1,1,8,78,"7/6",1,1)
Keyboard Chr(27)
SetColor("7/6,16/6,,,7/6")
MEMOEDIT(BAS_NOT,2,2,7,77,.F.)
_Win( 9,23,15,55,"14/5",1,1)
_Win(16,1,22,78,"7/6",1,1)
@ 17,2 Say "[" + NT1_DUR + "] " + Left(DIP_NT1,70) Color("7/6")
@ 18,2 Say "[" + NT2_DUR + "] " + Left(DIP_NT2,70) Color("7/6")
@ 19,2 Say "[" + NT3_DUR + "] " + Left(DIP_NT3,70) Color("7/6")
@ 20,2 Say "[" + NT4_DUR + "] " + Left(DIP_NT4,70) Color("7/6")
@ 21,2 Say "[" + NT5_DUR + "] " + Left(DIP_NT5,70) Color("7/6")
SetCursor(1)
Do While .T.
SetColor("15/5,14/5,,,15/5")
   @ 10,25 Say "K.D.V.          :" Get KDV_DUR Pict"9~û~ "
   @ 11,25 Say "G.Toplam        :" Get GTP_DUR Pict"9~û~ "
   @ 11,48 Say "Kur: "+CEV_KUR Color("15/6")
   @ 12,25 Say "Günün Kurları   :" Get KUR_DUR Pict"9~û~ "
   @ 13,25 Say "Başlık          :" Get BAS_DUR Pict"9~û~ "
   @ 14,25 Say "Dip not         :" Get NOT_DUR Pict"9~û~ "
   Read
   If Lastkey()=27
      Exit
   Endif
Enddo
If RAPAYAR->SCR_SUR>0
   Set key 273 to int_altw
//   Trapanykey("int_tus")
   Keysec(273,1,-1)
Endif
SetColor(OldColor)
RestScreen(1,0,23,79,AyarScr)
RestScreen(24,0,24,79,AyarTus)
SetCursor(0)
Select &OldRapSel
TBosalt()
Set Key K_ALT_A To RaporAyar()
Set Key K_ALT_K To KurGir()
Set Key K_ALT_G To MakinaGir()
Set Key K_ALT_P To KasaIslem()
Set Key K_F10 To
Return
//////////////////////////////////////////////////////////////////////////////
Function GetSec()
Set Key K_F10 To GetSec1()
cGelGet:=Readvar()
If cGelGet="GTP_DUR"
   If GTP_DUR $ "û"
      ParaBir=""
      KurSec()
      Select RapAyar
      If !Empty(ParaBir)
         Repl CEV_KUR With ParaBir
      Endif
      @ 11,48 Say "Kur: "+CEV_KUR Color("15/6")
   Endif
Endif
If cGelGet="BAS_DUR"
   If BAS_DUR $ "û"
      _TusYaz(24,1,{"~F2~-Kayıt","~ESC~-Çıkış"})
      _Win(1,1,8,78,"14/6",1,0)
      SetColor("15/6,14/6,,,15/6")
      Replace BAS_NOT With MEMOEDIT(BAS_NOT,2,2,7,77,.T.,"MemUdf",80)
      _Box(1,1,8,78,"7/6",1,0)
      _Box(9,23,15,55,"14/5",1,0)
      _Box(16,1,22,78,"7/6",1,0)
      Keyboard Chr(27)
      SetColor("7/6,16/6,,,7/6")
      MEMOEDIT(BAS_NOT,2,2,7,77,.F.)
   Endif
Endif
If cGelGet="NOT_DUR"
   If NOT_DUR $ "û"
      _TusYaz(24,1,{"~SPACE~-İşaretle","~ESC~-Çıkış"})
      _Win(16,1,22,78,"14/6",1,0)
      @ 17,2 Say "[" + NT1_DUR + "] " + Left(DIP_NT1,70) Color("7/6")
      @ 18,2 Say "[" + NT2_DUR + "] " + Left(DIP_NT2,70) Color("7/6")
      @ 19,2 Say "[" + NT3_DUR + "] " + Left(DIP_NT3,70) Color("7/6")
      @ 20,2 Say "[" + NT4_DUR + "] " + Left(DIP_NT4,70) Color("7/6")
      @ 21,2 Say "[" + NT5_DUR + "] " + Left(DIP_NT5,70) Color("7/6")
      SetColor("15/6,14/6,,,15/6")
      Clear Gets
      @ 17,2 Say "[ ]"
      @ 17,3 Get NT1_DUR Pict "9~û~ "
      @ 18,2 Say "[ ]"
      @ 18,3 Get NT2_DUR Pict "9~û~ "
      @ 19,2 Say "[ ]"
      @ 19,3 Get NT3_DUR Pict "9~û~ "
      @ 20,2 Say "[ ]"
      @ 20,3 Get NT4_DUR Pict "9~û~ "
      @ 21,2 Say "[ ]"
      @ 21,3 Get NT5_DUR Pict "9~û~ "
      Read
      SetColor("7/6,7/6,,,7/6")
      @ 17,2 Say "[" + NT1_DUR + "] " + Left(DIP_NT1,70)
      @ 18,2 Say "[" + NT2_DUR + "] " + Left(DIP_NT2,70)
      @ 19,2 Say "[" + NT3_DUR + "] " + Left(DIP_NT3,70)

      @ 20,2 Say "[" + NT4_DUR + "] " + Left(DIP_NT4,70)
      @ 21,2 Say "[" + NT5_DUR + "] " + Left(DIP_NT5,70)
      _Box(1,1,8,78,"7/6",1,0)
      _Box(9,23,15,55,"14/5",1,0)
      _Box(16,1,22,78,"7/6",1,0)
   Endif
Endif
_TusYaz(24,1,{"~SPACE~-İşaretle","~F10~-Seçim","~ESC~-Çıkış"})
TBosalt()
Set Key K_F10 To GetSec()
Return
//////////////////////////////////////////////////////////////////////////////
Function GetSec1()
cGelGet1:=Readvar()
Clear Gets
SetColor("15/6,15/6,,,15/6")
If cGelGet1="NT1_DUR"
  @ 17,6 Get DIP_NT1 Pict "@S70" When NT1_DUR $ "û"
  Read
Elseif cGelGet1="NT2_DUR"
  @ 18,6 Get DIP_NT2 Pict "@S70" When NT2_DUR $ "û"
  Read
Elseif cGelGet1="NT3_DUR"
  @ 19,6 Get DIP_NT3 Pict "@S70" When NT3_DUR $ "û"
  Read
Elseif cGelGet1="NT4_DUR"
  @ 20,6 Get DIP_NT4 Pict "@S70" When NT4_DUR $ "û"
  Read
Elseif cGelGet1="NT5_DUR"
  @ 21,6 Get DIP_NT5 Pict "@S70" When NT5_DUR $ "û"
  Read
Endif
Return
//////////////////////////////////////////////////////////////////////////////
Function MemUdf
nKey1:=Lastkey()
lTus:=.T.
Do Case
   Case nKey1=K_F2
        KeyBoard Chr(K_CTRL_W)
        lTus=.F.
   Case Lastkey()=K_ESC
        If lTus=.T.
           nCho:=_Alert("Kaydetmeden Çıkılsın mı?",{"Hayır","Evet"})
           If nCho=2
              Return
           Else
              TBosalt()
              Return(32)
           Endif
        Else
           Return
        Endif
   Case Lastkey()=K_ALT_C
        MEMOWRIT("Clipbrd.tmp",&(FIELDNAME(FCOUNT())))
   Case Lastkey()=K_ALT_V
//        KEYSEND(CHARMIX(STRTRAN(MEMOREAD("Clipbrd.tmp"),CHR(10),"") ," "))
        TBosalt()
EndCase
Return
//////////////////////////////////////////////////////////////////////////////
Function KasaIslem()
OldColor:=SetColor()
If RAPAYAR->SIF_DR2="û"
   nGirisDur:=Sifre()
   If nGirisDur!=2
      Return
   Endif
Endif
KSETCAPS(.T.)
KasaScr:=SaveScreen(0,0,24,79)
_TusYaz(24,0,{"~F2~-Ekle","~F3~-Sil","~F5~-Rapor","~ALT+H~-Hesaplar","~ALT+T~-Tarih","~ESC~-Çıkış"})
Select KASAKART
HrkTarih:=Date()
lTarihmi:=.F.
Do While .T.
nGirMik:=0;nCikMik:=0;nBorcDevir:=0;nAlacDevir:=0;nTGirMik:=0;nTCikMik:=0
SetCursor(1)
@  0,71 Get HrkTarih Pict "99/99/99" Color("15/6")
Read
@  0,71 Say HrkTarih Color("15/6")
SetCursor(0)
If Lastkey()=27
   Exit
Endif
Seek(HrkTarih)
lFound=Found()
If !lFound
   Append Blank
   Replace TARIH With HrkTarih
   Skip -1
   If !Bof()
      nEskiGir:=GGIRMIKTAR+BDEVMIKTAR
      nEskiCik:=GCIKMIKTAR+ADEVMIKTAR
      Skip
      If nEskiGir>nEskiCik
         Replace BDEVMIKTAR With nEskiGir-nEskiCik
      Else
         Replace ADEVMIKTAR With nEskiCik-nEskiGir
      Endif
   Endif
   nEskiGir:=GGIRMIKTAR
   nEskiCik:=GCIKMIKTAR
   KasaGir()
   If lTarihmi=.F. .And. (GGIRMIKTAR!=nEskiGir .Or. GCIKMIKTAR!=nEskiCik)
         DevirHes(HrkTarih,NIL)
   Endif
Else
   nEskiGir:=GGIRMIKTAR
   nEskiCik:=GCIKMIKTAR
   KasaGir()
   If lTarihmi=.F. .And. (GGIRMIKTAR!=nEskiGir .Or. GCIKMIKTAR!=nEskiCik)
      DevirHes(HrkTarih,NIL)
   Endif
Endif
lTarihmi=.F.
Enddo
SetColor(OldColor)
RestScreen(0,0,24,79,KasaScr)
Return
//////////////////////////////////////////////////////////////////////////////
Function KasaGir()
KSETCAPS(.T.)
Select KASAHRK
Alan:={"TARIH","KOD","ACIKLAMA","GIRMIKTAR","CIKMIKTAR"}
Basl:={"Tarih","Hesap Kodu","Açıklama","Giriş","Çık"}
Pict:={"99/99/99","@!","@!S28","999,999,999.99","999,999,999.99"}
KasaMenu()
nGirMik:=KASAKART->GGIRMIKTAR
nCikMik:=KASAKART->GCIKMIKTAR
nBorcDevir:=KASAKART->BDEVMIKTAR
nAlacDevir:=KASAKART->ADEVMIKTAR
nTGirMik:=nGirMik+nBorcDevir
nTCikMik:=nCikMik+nAlacDevir
@ 20,50 Say nGirMik Color("15/5") Pict"999,999,999.99"
@ 20,65 Say nCikMik Color("15/5") Pict"999,999,999.99"
@ 21,50 Say nBorcDevir Color("15/5") Pict"999,999,999.99"
@ 21,65 Say nAlacDevir Color("15/5") Pict"999,999,999.99"
@ 22,50 Say nTGirMik Color("15/5") Pict"999,999,999.99"
@ 22,65 Say nTCikMik Color("15/5") Pict"999,999,999.99"
SetColor("15/5,15/1,,,15/5")
MyBrowse(3,0,19,79,Alan,,Pict,"KasaFunc","TARIH",HrkTarih,,.T.,.F.,1,5,.F.)
SetColor()
Select KASAKART
Return
//////////////////////////////////////////////////////////////////////////////
Function KasaFunc()
Local lRet:=.T.
Local nKay
Do Case
   case ( nKey == K_ESC )
        lRet=.F.
   case nKey == K_RETURN
        If sFound=.T. .And. oB:Colpos>2 .And. Left(KOD,1)!="#"
           nGirMik=nGirMik-GIRMIKTAR
           nCikMik=nCikMik-CIKMIKTAR
           Doget(oB,lAppend)
           nGirMik=nGirMik+GIRMIKTAR
           nCikMik=nCikMik+CIKMIKTAR
           Replace KASAKART->GGIRMIKTAR With nGirMik,;
                   KASAKART->GCIKMIKTAR With nCikMik
        ElseIf sFound=.T. .And. oB:Colpos>2 .And. Left(KOD,1)="#"
           Doget(oB,lAppend)
        Endif
        If oB:Colpos=3
           If KASAHSP->HESYON="C"
              KEYBOARD CHR(K_RIGHT)+CHR(K_RIGHT)+CHR(K_RETURN)
           Else
              KEYBOARD CHR(K_RIGHT)+CHR(K_RETURN)
           Endif
        Endif
        If KASAHSP->HESYON!="G" .And. oB:Colpos=5
           oB:Home()
        ElseIf KASAHSP->HESYON="G" .And. oB:Colpos=4
           oB:Home()
           KEYBOARD CHR(K_RETURN)
        Endif
   case ( nKey == K_F2 )
     #ifdef DEMO
      If Lastrec()<50
     #Endif
        Append Blank
        Replace TARIH With HrkTarih
        HesapKodu=""
        HesapSec()
        Select KASAHRK
        If !Empty(HesapKodu)
           Replace KOD With HesapKodu
        Endif
        sFound=.T.
        oB:REFRESHALL()
        KEYBOARD CHR(K_RIGHT)+CHR(K_RETURN)
     #ifdef DEMO
      Endif
     #Endif
  case ( nKey == K_F3 )
    nSec:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
    If nSec=2
       If Left(KOD,1)!="#"
          nGirMik=nGirMik-GIRMIKTAR
          nCikMik=nCikMik-CIKMIKTAR
          Replace KASAKART->GGIRMIKTAR With nGirMik,;
                  KASAKART->GCIKMIKTAR With nCikMik
       Endif
       Delete
       Seek(HrkTarih)
       sFound=Found()
       oB:REFRESHAll()
    Endif

   case ( nKey == K_F5 )
        KasaRapor()
        Seek(HrkTarih)
        sFound=Found()
        oB:REFRESHAll()
   case ( nKey == K_F3 )
   case ( nKey == K_ALT_H )
        HesapGir()
        Seek(HrkTarih)
        sFound=.T.
        oB:REFRESHALL()

   case ( nKey == K_ALT_T )
           SetCursor(1)
           dEskiTarih:=TARIH
           nGirMiktar:=GIRMIKTAR
           nCikMiktar:=CIKMIKTAR
           @ Row(),1 Get Tarih Pict "99/99/99"
           Read
           dYeniTarih:=TARIH
           SetCursor(0)

           If TARIH!=dEskiTarih .And. Left(KOD,1)!="#"
              Select KASAKART
              nOldRec1:=Recno()
              Seek(dEskiTarih)
              If Found()
                 Replace GGIRMIKTAR With GGIRMIKTAR-nGirMiktar
                 Replace GCIKMIKTAR With GCIKMIKTAR-nCikMiktar
              Endif
              Seek(dYeniTarih)
              If Found()
                 Replace GGIRMIKTAR With GGIRMIKTAR+nGirMiktar
                 Replace GCIKMIKTAR With GCIKMIKTAR+nCikMiktar
              Else
                 Append Blank
                 Replace TARIH With dYeniTarih,;
                         GGIRMIKTAR With nGirMiktar,;
                         GCIKMIKTAR With nCikMiktar
              Endif
              If dEskiTarih>dYeniTarih
                 DevirHes(dYeniTarih,dEskiTarih)
              Else
                 DevirHes(dEskiTarih,dYeniTarih)
              Endif
              Go nOldRec1
              Select KASAHRK
              lTarihmi=.T.
           Endif

           Seek(HrkTarih)
           sFound=.T.
           oB:REFRESHALL()

   Case ( nKey == K_F10 )
        If oB:ColPos=2
           HesapKodu=""
           HesapSec()
           Select KASAHRK
           If !Empty(HesapKodu)
              Replace KOD With HesapKodu
           Endif
           sFound=.T.
           oB:REFRESHALL()
        Endif
        KEYBOARD CHR(K_RIGHT)+CHR(K_RETURN)
Endcase
@ 20,50 Say KASAKART->GGIRMIKTAR Color("15/5") Pict"999,999,999.99"
@ 20,65 Say KASAKART->GCIKMIKTAR Color("15/5") Pict"999,999,999.99"
@ 21,50 Say KASAKART->BDEVMIKTAR Color("15/5") Pict"999,999,999.99"
@ 21,65 Say KASAKART->ADEVMIKTAR Color("15/5") Pict"999,999,999.99"
@ 22,50 Say KASAKART->GGIRMIKTAR+KASAKART->BDEVMIKTAR Color("15/5") Pict"999,999,999.99"
@ 22,65 Say KASAKART->GCIKMIKTAR+KASAKART->ADEVMIKTAR Color("15/5") Pict"999,999,999.99"
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function DevirHes
Parameters dIlkTarih,dSonTarih
Local nOldRec,Kosul
nOldRec:=Recno()
Kosul:="TARIH>=dIlkTarih"
If dSonTarih!=NIL
   Kosul:=Kosul+".And. TARIH<=dSonTarih"
Endif
   Select KASAKART
   Seek(dIlkTarih)
    If Found()
      Do While &Kosul
         nBDevMik2:=BDEVMIKTAR
         nADevMik2:=ADEVMIKTAR
         nGirMik2:=GGIRMIKTAR
         nCikMik2:=GCIKMIKTAR
         Skip
         Replace BDEVMIKTAR With 0,;
                 ADEVMIKTAR With 0
         If nGirMik2+nBDevMik2>nCikMik2+nADevMik2
            Replace BDEVMIKTAR With (nGirMik2+nBDevMik2)-(nCikMik2+nADevMik2)
         Else
            Replace ADEVMIKTAR With (nCikMik2+nADevMik2)-(nGirMik2+nBDevMik2)
         Endif
      Enddo
    Endif
Go nOldrec
Return
//////////////////////////////////////////////////////////////////////////////
Function HesapSec()
KSETCAPS(.T.)
   HesapScr:=SaveScreen(0,0,24,79)
   _TusYaz(24,0,{"~ENTER~-Seçim","~ESC~-Hepsi"})
   gAlan:={"KOD"}
   gBasl:={"Hesap Kodu"}
   gPict:={"@!"}
   HesapKodu=""
   Select KASAHSP
   //_GOLGE(2,34,22,46)
   SetColor("15/5,15/1,,,15/5")
   MyBrowse(2,34,22,46,gAlan,gBasl,gPict,"HesFunc","KOD","",,.F.,.T.,0,1,.T.)
   SetColor()
   If !Lastkey()=K_ESC
      HesapKodu=KOD
   Endif
   RestScreen(0,0,24,79,HesapScr)
Select KASAHRK
Return
//////////////////////////////////////////////////////////////////////////////
Function HesFunc()
Local lRet:=.T.
Do Case
   Case nKey=K_ESC
        lRet=.F.
   Case nKey=K_ENTER
        lRet=.F.
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function HesapGir()
KSETCAPS(.T.)
Select KASAHSP
HesScr:=SaveScreen(6,21,17,68)
gAlan:={"KOD","ACIKLAMA","HESYON"}
gBasl:={"Hesap Kodu","Açıklama","Yön"}
gPict:={"@!","@!","@!"}
_TusYaz(24,1,{"~ENTER~-Seçim","~F2~-Ekle","~F3~-Sil",;
              "~F4~-Değiştir","~ESC~-Çık"})
SetColor("15/13,15/1,,,15/13")
MyBrowse(6,21,16,67,gAlan,gBasl,gPict,"HesFunc1","KOD","",,.T.,.F.,0,3,.T.)
SetColor()
RestScreen(6,21,17,68,HesScr)
_TusYaz(24,0,{"~F2~-Ekle","~F3~-Sil","~F5~-Rapor","~ALT+H~-Hesaplar","~ALT+T~-Tarih","~ESC~-Çıkış"})
Select KASAHRK
Return
//////////////////////////////////////////////////////////////////////////////
Function HesFunc1()
Static XKey:=.F.
Local lRet:=.T.
Do Case
   Case nKey=K_ESC
        lRet=.F.
   Case nKey=K_F4
         If XKey=.F.
            nCho:=_Alert("Kayıt değiştirilsin mi?",{"Hayır","Evet"})
         Else
            nCho=2
         Endif
         cOldHes:=KOD
         If nCho=2
             Doget(oB,lAppend)
            If oB:ColPos<3
               oB:refreshCurrent()
               KEYBOARD CHR(K_RIGHT)+CHR(K_CTRL_RETURN)
               If Empty(KOD)
                  Delete
                  oB:REFRESHALL()
                  TBosalt()
               Elseif KOD!=cOldHes
                  Select KASAHRK
                  Replace All KOD With KASAHSP->KOD For KOD=cOldHes
                  Select KASAHSP
               Endif
               XKey=.T.
            Else
               oB:REFRESHALL()
               XKey=.F.
            Endif
            sFound=.T.
         Endif
         lRet=.T.
   Case nKey=K_F2
         nCho:=_Alert("Yeni kayıt eklensin mi?",{"Hayır","Evet"})
         If nCho=2
            Append Blank
            Replace KOD With "ÿ"
            oB:REFRESHALL()
            XKey=.T.
            Keyboard Chr(K_CTRL_ENTER)
            sFound=.T.
         Endif
         lRet=.T.
   Case nKey=K_F3
        nCho:=_Alert("Kayıt silinsin mi?",{"Hayır","Evet"})
        If nCho=2
           cOldHes:=KOD
           Select KASAHRK
           Locate For KOD=cOldHes
           If Found()
              _Alert("Bu kayıt silinemez!",{"Tamam"})
              Select KASAHSP
           Else
              Select KASAHSP
              Delete
              oB:REFRESHALL()
           Endif
        Endif
Endcase
Return(lRet)
//////////////////////////////////////////////////////////////////////////////
Function KasaRapor()
OdeIlk:=Ctod("")
OdeSon:=CTod("")
OldScr:=SaveScreen(0,0,24,79)
_Win(10,26,14,49,"15/13",1,1)
SETCURSOR(1)
SetColor("15/13,15/1,,,15/13")
@ 11,27 Say "İlk Tarih  :" Get OdeIlk Pict "99/99/99"
@ 12,27 Say "Son Tarih  :" Get OdeSon Pict "99/99/99"
@ 13,27 Say "Hesap Kodu :"
Read
If Lastkey()=K_ESC
   SETCURSOR(0)
   SetColor("15/5,15/1,,,15/5")
   RestScreen(0,0,24,79,OldScr)
   Return(0)
Endif
HesapKodu=""
HesapSec()
Select KASAHRK
Go Top
SETCURSOR(0)
Kosul=".T."
If !EMPTY(HesapKodu)
   Kosul:=Kosul+".And. KOD=HesapKodu"
Else
   Kosul:=Kosul+".And. KOD=HesapKodu .And. Left(KOD,1)!='#'"
Endif

If EMPTY(Odeson)
   OdeSon=date()
Endif
If !EMPTY(OdeIlk)
   Kosul:=Kosul+" .And. TARIH>=OdeIlk .And. TARIH<=OdeSon"
Else
   Kosul:=Kosul+" .And. TARIH<=OdeSon"
Endif
Alanlar:={"Dtoc(TARIH)","KOD","ACIKLAMA","TransForm(GIRMIKTAR,'999,999,999.99')","TransForm(CIKMIKTAR,'999,999,999.99')"}
Baslik:={"Tarih","Hesap Kodu","Açıklama","Giriş","Çık"}
Toplam:={"GIRMIKTAR","CIKMIKTAR"}
nAygit:=_Alert("Rapor aygıtını seçiniz.",{"Ekran","Yazıcı"})
If nAygit=1
   Bekle()
   _List("KASAHRK",Kosul,Alanlar,Baslik,Toplam,"E")
Elseif nAygit=2
   Bekle()
   _List("KASAHRK",Kosul,Alanlar,Baslik,Toplam,"Y")
Endif
Select KASAHRK
RestScreen(0,0,24,79,OldScr)
SetColor("15/5,15/1,,,15/5")
Return
//////////////////////////////////////////////////////////////////////////////
Function Yardim()
YarColor:=SETCOLOR()
YarCursor:=SETCURSOR()
YarScr:=SaveScreen(0,0,24,79)
SETCURSOR(0)
_Win(1,1,23,51,"14/5",3,1)
SetColor("7/5,7/1,,,7/5")
@ 01,22 Say _TR(" Yardım ") Color"15/1"
@ 02,02 Say _TR("ALT+A: Rapor ayarları")
@ 03,02 Say _TR("---------------------")
@ 04,02 Say _TR("  G.Toplam - F10: Rapor kuru seçimi")
@ 05,02 Say _TR("  Başlık   - F10: Teklif başlığı oluşturma")
@ 06,02 Say _TR("  Dipnot   - F10: Dipnot seçimi")
@ 07,02 Say _TR("")
@ 08,02 Say _TR("ALT+P: Kasa işlemleri       *F10:Dipnot Oluşturma")
@ 09,02 Say _TR("---------------------")
@ 10,02 Say _TR("  #KOD: TL. giriş/çıkış toplamlarını etkilemeyen")
@ 11,02 Say _TR("        Özel hesap kodları (Örnek: #DOLAR, #ÇEK)")
@ 12,02 Say _TR("  Yön : Kasa kodu hesap yönü (G:Giriş, Ç:Çıkış)")
@ 13,02 Say _TR("        (Her iki yön için boş bırakılmalı)")
@ 15,02 Say _TR("ALT+G            : Parçalara gurup oluşturma")
@ 16,02 Say _TR("ALT+K            : Kur işlemleri")
//@ 17,02 Say "ALT+S            : Ekran koruyucuyu altrma"
@ 18,02 Say _TR("ALT+C            : Kopyala")
@ 19,02 Say _TR("ALT+V            : Yapıştır")
@ 20,02 Say _TR("Girişte Şifre    : Program giriş şifresi")
@ 21,02 Say _TR("Güvenlik Şifre   : Kasa, fiyat girişleri ve")
@ 22,02 Say _TR("                   genel parametreler şifresi")
Inkey(0)
SetColor(YarColor)
SetCursor(YarCursor)
RestScreen(0,0,24,79,YarScr)
Return
//////////////////////////////////////////////////////////////////////////////
Function KasaMenu()
SetColor("15/5,15/1,,,15/5")
@ 01,00 Say "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
@ 02,00 Say "³ Tarih   Hesap Kodu Aklama                          Giri         k     ³"
@ 03,00 Say "ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄŽ"
@ 04,00 Say "³        ³          ³                            ³              ³              ³"
@ 05,00 Say "³        ³          ³                            ³              ³              ³"
@ 06,00 Say "³        ³          ³                            ³              ³              ³"
@ 07,00 Say "³        ³          ³                            ³              ³              ³"
@ 08,00 Say "³        ³          ³                            ³              ³              ³"
@ 09,00 Say "³        ³          ³                            ³              ³              ³"
@ 10,00 Say "³        ³          ³                            ³              ³              ³"
@ 11,00 Say "³        ³          ³                            ³              ³              ³"
@ 12,00 Say "³        ³          ³                            ³              ³              ³"
@ 13,00 Say "³        ³          ³                            ³              ³              ³"
@ 14,00 Say "³        ³          ³                            ³              ³              ³"
@ 15,00 Say "³        ³          ³                            ³              ³              ³"
@ 16,00 Say "³        ³          ³                            ³              ³              ³"
@ 17,00 Say "³        ³          ³                            ³              ³              ³"
@ 18,00 Say "³        ³          ³                            ³              ³              ³"
@ 19,00 Say "ÃÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄŽ"
@ 20,00 Say "³                                          Toplam³                             ³"
@ 21,00 Say "³                              Dnk Kasa Mevcudu³                             ³"
@ 22,00 Say "³                                    Genel Toplam³                             ³"
@ 23,00 Say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
Return
//////////////////////////////////////////////////////////////////////////////
