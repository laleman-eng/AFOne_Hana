update [@VID_AFAS] 
   set u_adicanuc = 0, 
       u_Adicanur = 0, 
       u_nextyear = u_inityear, 
       u_nextper  = u_initper,

       u_curval   = u_orivalco,
       u_depacum  = u_oridepre,
       u_perdepre = U_OriPerDp,
       u_vidautil = u_pervidau - U_OriPerDp,
       u_depacumn = 0,
       u_depreanu = 0,
       u_coranuac = 0,
       u_coranude = 0,
       U_PerDepYr = 0,

       u_curvalR  = u_orivalcR,
       u_depacuR  = u_orideprR,
       u_pRrdepre = U_OriPerDR,
       u_vidautiR = u_pervidaR - U_OriPerDR,
       u_depacuRn = 0,
       u_depreanR = 0,
       u_coranuaR = 0,
       u_coranudR = 0,
       U_PRrDepYr = 0

update [@VID_AFAS] 
   set u_nextyear = 2007, 
       u_nextper  = 1
 where code = '----'

update [@VID_AFAD] Set u_Procesad = 'N'

delete from [@VID_AFAC]
delete from [@VID_AFSA]
delete from [@VID_AFACR]
delete from [@VID_AFSAR]