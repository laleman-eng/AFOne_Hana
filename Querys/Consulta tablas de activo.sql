select * from [@vid_afad] where code in ('1','10','28','29')
select * from [@vid_afas] where code in ('1','10','28','29')
select * from [@vid_afac] where code in ('1','10','28','29') order by code, u_year, u_periodo
select * from [@vid_afacR] where code in ('1','10','28','29') order by code, u_year, u_periodo
select * from [@vid_afsa] where code in ('1','10','28','29')
select sum(u_corracti) ca, sum(u_corrdepr)cd, sum(U_deprNom), sum(U_corrdepm) cdm, sum(U_deprecia) d, sum(U_corrdepm+U_deprecia) dt  
from [@vid_afac] where code in ('1') and u_periodo < 13

