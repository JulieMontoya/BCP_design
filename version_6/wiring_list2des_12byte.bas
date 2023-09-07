    1REM..THIS VERSION USES 12-BYTE..
    2REM..PARTS LIST RECORDS..
   10MODE4
   20HIMEM=&4400
   30*K.8*EXEC L.MINVARS|MG.200|M
   40*FX138,0,136
   50END
  200CLS
 2500VDU23,224,&EEEE;&EE;&EEEE;&EE;23,226,&7800;&7A0E;&7F02;&2;23,227,&200;&27F;&E7A;&78;
 2510*KEY1P.$cardbuf'STRI.refindex?1," ")"^"|M
 2520*KEY2P.~USRparse_card,?fprt,refindex?1|M
 2530*KEY3P.~USRpack_desr,refindex?1|M
 2540*KEY4P.~USRparse_pin,refindex?1,FNpeek(decnum)|M
 2550*KEY5P.~USRparse_extra,refindex?1|M
 2560*L.M.MTH13
 2570*L.M.DBM58
 2580GOTO3000
 3000VDU28,0,31,39,13,10
 3010REM F$ => MASTER FOOTPRINT FILENAME
 3020REM S% => START OF MEMORY TO USE
 3030F$="D.FTPRNT":S%=&5800
 3040REMFORI%=&5800TO&5DFF STEP4:!I%=0:NEXTI%
 3050PROCload_master(F$,S%)
 3060d_fpl%=&100
 3070d_pnl%=&100
 3080d_ssl%=&100
 3090pll%=&100
 3100wll%=&100
 3110rtl%=&100
 3120wpl%=&100
 3130PRINT"EDIT LINE 3000 OR SWITCH TO MODE 7 IF   SCROLLING TEXT INTRUDES INTO DATA."'
 3140PRINT"Enter wiring list filename (RETURN to"
 3150PRINT"use DATA from program) ";
 3160INPUT""W$
 3170PRINT"Enter amount of space to use for:"
 3180d_fpl%=FNinput("Footprint headers",d_fpl%)
 3190PRINT"    &";~d_fpl%
 3200d_pnl%=FNinput("Pin definitions",d_pnl%)
 3210PRINT"    &";~d_pnl%
 3220d_ssl%=FNinput("Silkscreen data",d_ssl%)
 3230PRINT"    &";~d_ssl%
 3240pll%=FNinput("Parts list data",pll%)
 3250PRINT"    &";~pll%
 3260wll%=FNinput("Wiring list data",wll%)
 3270PRINT"    &";~wll%
 3280rtl%=FNinput("Routed tracks",rtl%)
 3290PRINT"    &";~rtl%
 3300wpl%=FNinput("Track waypoints",wpl%)
 3310PRINT"    &";~wpl%
 3320PRINT"MASTER footprint headers &";~S%
 3330PRINT"Number of footprints:";m_nfp%
 3340PRINT"Pin data length &";~m_pnl%
 3350PRINT"Silkscreen data length &";~m_ssl%
 3360PRINT"Total length &";~m_fpl%+m_pnl%+m_ssl%
 3370PRINT"MASTER footprint base &";~m_fpb%
 3380PRINT"MASTER pin base &";~m_pnb%
 3390PRINT"MASTER silkscreen base &";~m_ssb%
 3400PRINT
 3410T%=S%+m_fpl%+m_pnl%+m_ssl%
 3420data%=T%
 3430d_fpb%=T%+3
 3440d_pnb%=T%+d_fpl%
 3450d_ssb%=T%+d_fpl%+d_pnl%
 3460PRINT"DESIGN database start &";~T%
 3470PRINT"DESIGN footprint base &";~d_fpb%
 3480PRINT"DESIGN pin base &";~d_pnb%
 3490PRINT"DESIGN silkscreen base &";~d_ssb%
 3500d_fpv%=d_fpb%
 3510d_pnv%=d_pnb%
 3520d_ssv%=d_ssb%
 3530d_nfp%=0
 3540REMPRINT
 3550U%=T%+d_fpl%+d_pnl%+d_ssl%
 3560plb%=U%
 3570wlb%=U%+pll%
 3580PRINT"DESIGN parts list &";~U%
 3590PRINT"DESIGN wiring list &";~wlb%
 3600plb_v%=plb%
 3610wlb_v%=wlb%
 3620V%=U%+pll%+wll%
 3630PRINT"Total length &";~V%-T%
 3640route%=wlb%+wll%
 3650wpbase%=route%+rtl%
 3660end%=wpbase%+wpl%
 3670PRINT
 3680IFW$>""OSCLI"EXEC "+W$ELSERESTORE20000
 3690PROCpoke(cbb,cardbuf)
 3700PROCdesign
 3710IFW$>""INPUT$cardbuf ELSEREAD$cardbuf
 3720REPEAT
 3730PROCpoke(wlb,wlb_v%)
 3740PROCpoke(plb,plb_v%)
 3750PRINT$cardbuf;CHR$255
 3760U%=USRparse_card
 3770PRINT~U%
 3780IFU%AND&1000000 E%=TRUE ELSEE%=FALSE
 3790IFNOTE%GOTO4100
 3800IFU%AND&80000000PRINT"Premature end of card":STOP
 3810PRINT"Footprint not in design! Trying master"
 3820PROCmaster
 3830REM..will need changing to something less brutal, just to search for footprint
 3840U%=USRparse_card
 3850PRINT~U%
 3860IFU%AND&1000000PRINT"Part not in master bundle":STOP
 3870PRINT"Copying footprint ";?fprt;" from master"
 3880PROCcopyfp(?fprt)
 3890PROCdesign
 3900U%=USRparse_card
 3910PRINT~U%
 3920IFU%AND&1000000PRINT"Copy went wrong":STOP
 3930PROCinfo
 4100PRINT"Checking for co_ordinates : ";
 4110PROCpoke(plb,plb_v%)
 4120!cenX=0:?pside=0:?pangle=0
 4130U%=USRparse_extra:PRINT;~U%
 4140IFU%AND&1000000PRINT"No co-ordinates"ELSEPRINT"X=";FNpeek(cenX);" Y=";FNpeek(cenY);" Side=";?pside;" Rot=";?pangle
 4150CALLpack_part
 4160PRINT"Packing designator :";
 4170U%=USRpack_desr:PRINT;U%
 4180IFU%AND&1000000PRINT"Error packing designator! (";U%;")":STOP
 4190PROCpoke(plb_v%,!desP)
 4200PROCpoke(plb_v%+2,wlb_v%-wlb%)
 4210PRINT$cardbuf'STRING$(refindex?1," ")"^"
 4220FORV%=1TO?pins
 4230U%=USRparse_pin
 4240IFU%AND&1000000PRINT"Run out of pins! (";U%;")":STOP
 4250PRINT"Pin ";V%;" goes to ";?decnum AND255
 4260?wlb_v%=?decnum:wlb_v%=wlb_v%+1
 4270NEXTV%
 4280PRINT$cardbuf'STRING$(refindex?1," ")"^"
 4290plb_v%=plb_v%+12
 4300PROCinfo
 4310IFW$>""INPUT$cardbuf ELSEREAD$cardbuf
 4320UNTIL$cardbuf=""
 4330d_fpl%=&100*((d_nfp%*23)DIV256+1)
 4340d_pnl%=&100*((d_pnv%-d_pnb%)DIV256+1)
 4350d_ssl%=&100*((d_ssv%-d_ssb%)DIV256+1)
 4360PRINT
 4370PRINT"DESIGN footprint headers &";~T%
 4380PRINT"Number of footprints:";d_nfp%
 4390PRINT"Pin data length &";~d_pnl%
 4400PRINT"Silkscreen data length &";~d_ssl%
 4410PRINT"Footprints length &";~d_fpl%+d_pnl%+d_ssl%
 4420d_pll%=&100*((plb_v%-plb%)DIV256+1)
 4430d_wll%=&100*((wlb_v%-wlb%)DIV256+1)
 4440PRINT"Parts list length &";~d_pll%
 4450PRINT"Wiring list length &";~d_wll%
 4460d_tl%=&100*((wlb_v%-T%)DIV256+1)
 4470PRINT"Total length &";~d_tl%
 4480?T%=d_nfp%
 4490T%?1=d_pnl%DIV&100+16*d_ssl%DIV&100
 4500T%?2=&11
 4510PROCpoke(plb_v%+2,wlb_v%-wlb%)
 4520PROCpoke(plb_v%+4,wlb%-plb%)
 4530PROCpoke(plb_v%+6,route%-plb%)
 4540PROCpoke(plb_v%+8,wpbase%-plb%)
 4550PROCpoke(plb_v%+10,wpbase%-plb%)
 4560PRINT'"Copy this command to save design file:"
 4570PRINT" *SAVE D.DESIGN ";~data%;" +";~end%-data%
 4580END
 4990END
 6180DEFFNpeek(P%)
 6190Q%=!P%AND&FFFF:IFQ%>32767Q%=Q%OR&FFFF0000
 6200=Q%
 6210DEFPROCpoke(P%,Q%)
 6220!P%=!P%AND&FFFF0000 ORQ%AND&FFFF
 6230ENDPROC
 6240DEFFNhex(A$)
 6250LOCALI%,C$,S%,D%,T%
 6260I%=1:D%=1:T%=0
 6270REPEAT
 6280C$=MID$(A$,I%,1)
 6290IFC$>="0"ANDC$<="9"T%=T%*16+ASCC$-48
 6300IFC$>="A"ANDC$<="F"T%=T%*16+ASCC$-55
 6310I%=I%+1
 6320UNTILI%>LENA$
 6330=T%
 8000DEFFNround(A$,D%)
 8010LOCALA%,B%
 8020REMIFLEFT$(A$,1)="&"A%=EVALA$ELSEA%=VALA$
 8030IFA$>""A%=EVALA$ELSEA%=D%
 8040B%=A%MOD256
 8050IFB%A%=A%+&100-B%
 8060=A%
 8070DEFFNinput(P$,D%)
 8080LOCALA$,A%
 8090PRINTP$;" (&";~D%;") ";:INPUT""A$
 8100A%=FNround(A$,D%)
 8110=A%
10000CLS
10010PRINT"Parts in library:"
10020FORJ%=0TO(?nfp)-1
10030M%=FNpeek(fpbase)+23*J%
10040N$=""
10050FORI%=0TO6
10060N$=N$+CHR$(M%?I%)
10070NEXTI%
10080C%=M%?7
10090PRINTN$;C%
10100NEXTJ%
10110END
10200CLS
10210REPEAT
10220INPUT"X :"X%
10230!cenX=!cenX AND&FFFF0000 ORX%
10240INPUT"Y :"Y%
10250!cenY=!cenY AND&FFFF0000 ORY%
10260PRINT~USRtimes5
10270X%=!cenX AND&FFFF
10280PRINT"X=";X%,X%OR&FFFF0000
10290Y%=!cenY AND&FFFF
10300PRINT"Y=";Y%,Y%OR&FFFF0000
10310UNTILFALSE
11000REMCLS
11010REPEAT
11020INPUT"Footprint to find :"S$
11030IFLENS$>7S$=LEFT$(S$,7)
11040$schstr=S$
11050U%=USRfind_fp
11060PRINT~U%
11070IF(U%AND&1000000)PRINT"** NO MATCH **"ELSEPRINT"Matched ";(U%AND&FF00)DIV256
11080UNTILS$=""
11090END
12000$cardbuf="R1 1 0 1K * RQ4X1"
12010PRINT$cardbuf;CHR$255
12020U%=USRparse_card
12030PRINT~U%
12040PRINT"refindex:&";~!refindex AND&FFFF
12050PRINT"fpb:&";~!fpb AND&FFFF
12060END
14000CLS
14010FORJ%=0TO?nparts-1
14020M%=wiring%+12*J%
14030N%=!M%AND&3FF:L%=M%?1DIV4
14040A$=FNdesr(L%)+STR$N%
14050PRINTLEFT$(A$+"        ",8);
14060IFJ%MOD4=3PRINT
14070NEXTJ%
14080PRINT
14090REPEAT
14100INPUT"Select part :"$cardbuf
14110U%=USRpack_desr:PRINT~U%,~!desP AND&FFFF
14120IFU%AND&1000000PRINT"** NONSENSE DESIGNATOR **":END
14130U%=USRfind_part:PRINT~U%,?part
14140IFU%AND&1000000PRINT"** NO SUCH PART **":END
14150A%=?part:CALLselect_part
14160PRINT"wlb=&";~!wlb
14170PRINT"Footprint ";?fprt
14180PRINT"Side ";?pside;" Angle ";?pangle
14190X%=!cenX AND&FFFF:IFX%AND&8000 X%=X%OR&FFFF0000
14200Y%=!cenY AND&FFFF:IFY%AND&8000 Y%=Y%OR&FFFF0000
14210PRINT"X=";X%;",Y=";Y%
14220UNTILFALSE
14400CLS
14499END
14999END
18000DEFPROCcopyfp(I%)
18010M%=FNpeek(fpbase)+23*I%
18020FORJ%=0TO22
18030C%=135
18040IFJ%=18ORJ%=19C%=130
18050IFJ%=21ORJ%=22C%=131
18060IFJ%=129PRINT
18070IFJ%=0ORJ%=12PRINTFNhex4(M%+J%);
18080VDUC%:PRINTRIGHT$("00"+STR$~(M%?J%),2);
18090d_fpv%?J%=M%?J%
18100NEXT
18110PRINT
18120N%=FNpeek(ssbase)+FNpeek(M%+18)
18130FORK%=0TO(M%?20)-1
18140PRINTFNhex4(N%+3*K%);
18150FORJ%=0TO2
18160VDU32:PRINTRIGHT$("00"+STR$~?(N%+3*K%+J%),2);
18170?(d_ssv%+3*K%+J%)=?(N%+3*K%+J%)
18180NEXTJ%
18190PRINT
18200NEXTK%
18210N%=FNpeek(pnbase)+FNpeek(M%+21)
18220FORK%=0TO(M%?7)-1
18230PRINTFNhex4(N%+5*K%);
18240FORJ%=0TO4
18250VDU32:PRINTRIGHT$("00"+STR$~?(N%+5*K%+J%),2);
18260?(d_pnv%+5*K%+J%)=?(N%+5*K%+J%)
18270NEXTJ%
18280PRINT
18290NEXTK%
18300PROCpoke(d_fpv%+18,d_ssv%-d_ssb%)
18310PROCpoke(d_fpv%+21,d_pnv%-d_pnb%)
18320d_ssv%=d_ssv%+3*?(d_fpv%+20)
18330d_pnv%=d_pnv%+5*?(d_fpv%+7)
18340d_fpv%=d_fpv%+23
18350d_nfp%=d_nfp%+1
18360ENDPROC
18370DEFPROCwipemem(L%)
18380FORI%=0TOL%-4STEP4
18390I%!&5800=0
18400NEXTI%
18410ENDPROC
18420DEFPROCcopymaster
18430FORI%=0TOT%-S%-4STEP4
18440I%!T%=I%!S%
18450NEXTI%
18460ENDPROC
18470DEFPROCmaster
18480PROCpoke(fpbase,m_fpb%)
18490PROCpoke(pnbase,m_pnb%)
18500PROCpoke(ssbase,m_ssb%)
18510?nfp=m_nfp%
18520ENDPROC
18530DEFPROCdesign
18540PROCpoke(fpbase,d_fpb%)
18550PROCpoke(pnbase,d_pnb%)
18560PROCpoke(ssbase,d_ssb%)
18570?nfp=d_nfp%
18580ENDPROC
18590DEFPROCload_master(F$,S%)
18600PROCwipemem(&500)
18610OSCLI"LOAD "+F$+" "+STR$~S%
18620REMFORI%=&5800TO&5AFF STEP4:I%!&300=!I%:NEXTI%
18630m_nfp%=?S%
18640V%=S%?1:m_ssl%=(V%MOD16)*256:m_pnl%=(V%DIV16)*256
18650m_fpb%=S%+3
18660m_fpl%=&100*((m_nfp%*23)DIV256+1)
18670m_pnb%=S%+m_fpl%
18680m_ssb%=m_pnb%+m_pnl%
18690ENDPROC
18700DEFPROCinfo
18710PRINT"          Fprt Pins Silk PrtL WirL"
18720PRINT"Master    ";FNhex4(m_fpb%);" ";FNhex4(m_pnb%);" ";FNhex4(m_ssb%)
18730PRINT"Design    ";FNhex4(d_fpb%);" ";FNhex4(d_pnb%);" ";FNhex4(d_ssb%);
18740PRINT" ";FNhex4(plb%);" ";FNhex4(wlb%)
18750PRINT"Vacancy   ";FNhex4(d_fpv%);" ";FNhex4(d_pnv%);" ";FNhex4(d_ssv%);
18760PRINT" ";FNhex4(plb_v%);" ";FNhex4(wlb_v%)
18770ENDPROC
18780DEFFNhex4(M%)=RIGHT$("0000"+STR$~M%,4)
18790DEFFNdesr(L%)
18800IFL%<32N$=CHR$(L%+64)ELSEN$=MID$("BRBZCHCNCPCRCVDZFSICJKJPLDLPLSMEMTPLPTRLRPRTRVSKTHTPTRVCVRVTZD",(L%-32)*2+1,2)
18810=N$
19500ONERROROSCLI"SP.":REPORT:PRINT" at line ";ERL:END
19510RESTORE
19520IFW$>""OSCLI"SP."+W$
19530REPEAT
19540READA$
19550PRINTA$
19560UNTILA$=""
19570*SP.
19580END
20000DATA"CN1 11 0 MOLEX2X.1 * HM2X1"
20010DATA"D1 11 9 1N4007 * D1A4X1"
20020DATA"D2 10 11 1N4007 * D1A4X1"
20030DATA"C1 9 0 100U * CE5X1"
20040DATA"C2 0 10 100U * CE5X1"
20050DATA"R1 9 8 100 * RQ4X1"
20060DATA"R2 4 10 100 * RQ4X1"
20070DATA"ZD1 0 8 BZV84C6V8 * D1A4X1"
20080DATA"ZD2 4 0 BZV84C6V8 * D1A4X1"
20090DATA"C3 8 0 100N * CP2X1"
20100DATA"C4 0 4 100N * CP4X1"
20110DATA"IC1 1 2 3 4 5 6 7 8 LM2904 * DIP8"
20120DATA"CN2 12 0 MOLEX2X.1 * HM2X1"
20130DATA"R3 1 2 1M * RQ4X1"
20140DATA"R4 2 0 100K * RQ4X1"
20150DATA"R5 12 3 100K * RQ4X1"
20160DATA"C6 1 13 10N * CP2X1"
20170DATA"CN3 13 0 MOLEX2X.1 * HM2X1"
20180DATA"R6 5 0 100K * RQ4X1"
20190DATA"R7 6 0 100K * RQ4X1"
20200DATA""
