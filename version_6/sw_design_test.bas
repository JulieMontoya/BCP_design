   10*KEY8*EX.L.BVARS|MG.100|M
   20*FX138,0,136
   30END
  100MODE1
  110HIMEM=&2E00
  120*|SRLOAD R.BCP_SW 8000 4
  130DIMdata%2048
  140PROCpoke(design,data%):PROCpoke(design+2,data%+&800)
  150D$="D.JSI0B"
  160PROCpoke(cbb,cardbuf)
  170*K.1|LG.11010|M
  180$&900="L "+D$:*PARSE
  190VDU23,224,&EEEE;&EE;&EEEE;&EE;23,226,&7800;&7A0E;&7F02;&2;23,227,&200;&27F;&E7A;&78;
  200VDU23,228,&3E1F;&FF7C;&4422;&00F8;23,229,&3C00;&7E7E;&7E7E;&003C;23,230,&1010;&3F38;&1038;&0010;23,231,&3E77;&3E7F;&3E7F;&7F;
  210M%=?&355 AND7
  220IFM%=4 H%=4:!palette=&11010101
  230IFM%=5 H%=8:!palette=&1020301
  240IFM%=1 H%=4:!palette=&1020301
  250IFM%=2 H%=8:!palette=&1030705:palette!8=&7060402
11000VDU26,12
11010VDU28,0,7,160/H%-1,0
11020REPEAT
11030PRINTTAB(0,0);"          ";TAB(0,0);
11040INPUT$cardbuf:*PARSE
11050IFU%AND&1000000PRINT"** BAD COMMAND **":END
11090UNTILFALSE
11990END
13000DEFFNpeek(P%)
13010Q%=!P%AND&FFFF:IFQ%>32767Q%=Q%OR&FFFF0000
13020=Q%
13030DEFPROCpoke(P%,Q%)
13040!P%=!P%AND&FFFF0000 ORQ%AND&FFFF
13050ENDPROC
14000DEFPROCR(Z%)
14010LOCALA%,U%:A%=Z%:U%=USRsrch_rt
14015PRINT~U%
14020IF(U%AND&1000000)=0VDU7:STOP
14025REPEAT
14030A%=plotbuf?25:CALLera_rt:CALLpenc_rt
14040Y$=GET$
14050IFY$="N"CALL&57FA:?&7D=2:U%=USRsr_res:IF(U%AND&1000000)=0VDU7
14055UNTILY$<>"N"
14060ENDPROC
14070DEFFNusr(M%)
14080PROCpoke(sw_addr,M%):=USRgo_sw