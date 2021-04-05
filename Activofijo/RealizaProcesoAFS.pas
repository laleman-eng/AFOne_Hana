namespace AF_IFRS.RealizaProcesoAFS;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  System.Runtime.InteropServices,
  System.Diagnostics,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.SBOGeneralService,
  Visuald.MultiFunctions,
  VisualD.untLog;

type
  TActividaMensual = class
      Year      : integer;
      Per       : integer;
      CorrAct   : double;
      CorrDep   : double;
      DeprMes   : double;
      DeprNoAct : double;
      CorDepM   : double;
      AdicVal   : double;
      AdicVid   : integer;
      PerDepre  : integer;
  end;

  TActivoAdicion = class
      PeriodoInicial       : Integer;
      PeriodosDerpreciados : Integer;
      ValorInicialActivo   : Double;    // Tambien representa una adicion
      ValorInicialDeprec   : Double;
      ValorCorregidoActivo : Double;
      ValorCorregidoDeprec : Double;
      VidaUtil             : Integer;
      AdicVida             : Integer;
  end;

  TIndice = array [0..12] of double;

  TRealizaProcesoAFS = class
  public
    method    ProcesarActivos(): string;
    method    ReversarProcesoActivos(): string;
    method    ReversarCentralizacion(): string;
    method    Centralizar(): string;
    constructor(oGlobalSettings: TGlobalVid; oFSBOf: CSBOFunctions; oFCmpny: SAPbobsCOM.Company; ooDSGrupo: String; oG_Year, oG_Periodo : Integer; var ProgBar: SAPbouiCOM.ProgressBar);
  private
    { Private Declarations }
    oLogMess   :  Boolean := false;
    oLogCode   :  String  := '18';
    oProcCant  :  Integer := 5000;
    oTasaFija  :  boolean := false;
    oPostSysCu :  boolean := false;

    oProgBar       : SAPbouiCOM.ProgressBar;
    GlobalSettings : TGlobalVid;
    FSBOf          : CSBOFunctions;
    FCmpny         : SAPbobsCOM.Company;    
    oLog           : TObjectWithLog;
    oDSGrupo       : String;
    G_Year         : Integer;
    G_Periodo      : Integer;
    Utils          : TUtils;

    method   GetIndice(oRecordAux1: SAPbobsCOM.Recordset; sIndice, sYear, sMonth: string; MarcaError: boolean): double;
    method   PeriodoAbierto(yr, mn: integer): boolean;
    method   ObtenerNxtYearNxtPeriod(vYear, vPeriod: integer; var nxYr, nxPr, IniYr, IniPr: integer);
    method   InitActivoAdicion(var a: TActivoAdicion);

    method    ActualizarRevalIFRS(vYear, vPeriod, day: integer; var oRecordSet: SAPbobsCOM.Recordset);
    method    ReversarRevalIFRS( vYear, vPeriod, day: integer; var oRecordSet: SAPbobsCOM.Recordset; oCode, oGroup: string; oByCode: boolean);
    method    ActualizarVentaIFRS();
               
    method    ProcesoFinanciero(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; Indices: TIndice; nxYr, nxPr: integer; var TopeLey33Bis: Double);
    method    ProcesoReferencial(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; Indices: TIndice; nxYr, nxPr: integer; var TopeLey33Bis: Double);
    method    ProcesoIFRS(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; nxYr, nxPr: integer);
    method    ReversarProcesoFinanciero(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; vyear, vperiod : integer);
    method    ReversarProcesoReferencial(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; vyear, vperiod : integer);
    method    ReversarProcesoIFRS(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordSet: SAPbobsCOM.RecordSet; vyear, vperiod : integer);

  public
 end;

implementation

uses
    AF_IFRS.Utils,
    System.Globalization;

constructor TRealizaProcesoAFS(oGlobalSettings: TGlobalVid; oFSBOf: CSBOFunctions; oFCmpny: SAPbobsCOM.Company; ooDSGrupo: String; oG_Year, oG_Periodo : Integer; var ProgBar: SAPbouiCOM.ProgressBar);
begin
      GlobalSettings := oGlobalSettings;
      FSBOf          := oFSBOf;
      FCmpny         := oFCmpny;
      oLog           := FSBOf.oLog;

      oDSGrupo       := ooDSGrupo;
      G_Year         := oG_Year;
      G_Periodo      := oG_Periodo;
      oProgbar       := Progbar;
  
      Utils          := new TUtils(oGlobalSettings, oFCmpny, oFSBOf);
end;

method  TRealizaProcesoAFS.PeriodoAbierto(yr, mn: integer): boolean;
var
   s: string;
   oRecordSet: SAPbobsCOM.RecordSet;
   oSql: string;
begin
   result := false;
   try
      oRecordSet     := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         // 2007 
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "SELECT count(*) cant from ofpr " +
                     " where month(f_refdate) <= {0}" + 
                     "   and year(f_refdate)   = {1}" + 
                     "   and month(t_refdate) >= {0}" + 
                     "   and year(t_refdate)   = {1}" + 
                     "   and PeriodStat <> 'Y'      ", 
                     'SELECT Count(*) "cant" from OFPR ' +
                     ' where month("F_RefDate") <= {0}' + 
                     '   and year("F_RefDate")   = {1}' + 
                     '   and month("T_RefDate") >= {0}' + 
                     '   and year("T_RefDate")   = {1}' + 
                     '   and "PeriodStat" <> ''Y''    ');
         oSql := string.Format(oSql, mn.ToString, yr.ToString);
         oRecordSet.DoQuery(oSql);
      if (system.int32(oRecordSet.Fields.Item('cant').value) > 0) then
         result := true;
   finally
      FSBOf._ReleaseCOMObject(oRecordSet);
   end;
end;

method TRealizaProcesoAFS.ObtenerNxtYearNxtPeriod(vYear, vPeriod: integer; var nxYr, nxPr, IniYr, IniPr: integer);
begin
   nxYr := vyear;
   nxPr := vperiod + 1;
   if (vperiod = 12) then begin
     nxYr := vyear + 1;
     nxPr := 1;
   end;

   IniYr := vyear;
   IniPr := vperiod - 1;
   if (vperiod = 1) then begin
     IniYr := vyear - 1;
     IniPr := 12;
   end;
end;

method TRealizaProcesoAFS.InitActivoAdicion(var a: TActivoAdicion);
begin
   a.PeriodoInicial := -1;
   a.PeriodosDerpreciados := 0;
   a.ValorInicialActivo   := 0;
   a.ValorInicialDeprec   := 0;
   a.ValorCorregidoActivo := 0;
   a.ValorCorregidoDeprec := 0;
   a.VidaUtil       := 0;
   a.AdicVida       := 0;
end;

method TRealizaProcesoAFS.ReversarProcesoActivos(): string;
var
   vyear, vperiod : integer;
   nxYr,  nxPr    : integer;
   IniYr, IniPr   : integer;
   s, w           : string;
   oCode          : String; 

   oParametros          : SAPbobsCOM.GeneralService;
   oParametrosData      : SAPbobsCOM.GeneralData;
   oParametrosParameter : SAPbobsCOM.GeneralDataParams;

   oActivos           : SAPbobsCOM.GeneralService;
   oActivosData       : SAPbobsCOM.GeneralData;
   oActivosParameter  : SAPbobsCOM.GeneralDataParams;

   oGrupos            : SAPbobsCOM.GeneralService;
   oGruposData        : SAPbobsCOM.GeneralData;
   oGruposParameter   : SAPbobsCOM.GeneralDataParams;

   oRecordActivos     : SAPbobsCOM.RecordSet;
   oRecordActividad   : SAPbobsCOM.RecordSet;
   oRS                : SAPbobsCOM.RecordSet;
   oProgBarVal        : integer;
   oProgBarCont       : integer;
   oSQl               : string;
begin
   result := "No terminado";
   try
      try
         oRecordActivos     := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividad   := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRS                := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
    
         vyear   := G_Year;
         vperiod := G_Periodo;
    
         ObtenerNxtYearNxtPeriod(vYear, vPeriod, var nxYr, var nxPr, var IniYr, var IniPr);
    
         if (not PeriodoAbierto(vyear, vperiod) ) then
            raise New Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_Cerrado]);
            
    
            // Traer parametros
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code from [@VID_AFPA] ", 
                     'Select "Code" from "@VID_AFPA" ');
         oRecordActividad.DoQuery(oSql);
         if (oRecordActividad.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros]);
    
         s           := System.String(oRecordActividad.Fields.Item('Code').Value);
         oParametros := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFPA'));
         oParametrosParameter := SAPbobsCOM.GeneralDataParams(oParametros.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oParametrosParameter.SetProperty('Code', s);
         oParametrosData := oParametros.GetByParams(oParametrosParameter);
    
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select code         " +
                     " from [@VID_AFAC]   " +
                     " where ( u_year > {0} or " +
                     "       ( u_year = {0} and u_Periodo > {1} ) ) " +
                     "   and u_year is not null ", 
                     'Select "Code" "code"         ' +
                     ' from "@VID_AFAC"            ' +
                     ' where ( "U_Year" > {0} or   ' +
                     '       ( "U_Year" = {0} and "U_Periodo" > {1} ) ) ' +
                     '   and "U_Year" is not null  ');
         oSql := string.Format(oSql, vyear.ToString, vperiod.ToString);
         oRecordActividad.DoQuery(oSql);
         oRecordActividad.MoveFirst;
         if (not oRecordActividad.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Per_Post_Actividad]);
    
         // Proceso por grupos de activos
         w := '';
         if (oDSGrupo <> '') then
            w := iif(GlobalSettings.RunningUnderSQLServer, " and a.U_ItmGrpCd = '{0}' ", ' and a."U_ItmGrpCd" = ''{0}'' ');
            w := string.Format(w, oDSGrupo);
    
         // Reversa actividad - tablas locales
         s := iif(GlobalSettings.RunningUnderSQLServer, "Select count(*) cant    " +
                                                        " from [@VID_AFAS] a     " +
                                                        " where u_nextyear = {0} " +
                                                        "   and u_nextper  = {1} " +
                                                        w,
                                                        'Select Count(*) "cant"    ' +
                                                        ' from "@VID_AFAS" a       ' +
                                                        ' where "U_NextYear" = {0} ' +
                                                        '   and "U_NextPer"  = {1} ' +
                                                        w );
         s := string.Format(s, nxYr.ToString, nxPr.ToString);
         oRecordActivos.DoQuery(s);

         oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);
             
         s := iif(GlobalSettings.RunningUnderSQLServer, "Select a.Code, a.U_ActCode, a.U_DeBaja,  isnull(U_ActTipo , 'N') U_ActTipo       " +
                                                        " from [@VID_AFAS] a inner join [@VID_AFAC] b on a.code      = b.code and         " +
                                                        "                                                b.U_Year    = case when a.u_nextper = 1 then a.u_nextyear - 1 else a.u_nextyear end and " +
                                                        "                                                b.U_Periodo = case when a.u_nextper = 1 then 12 else a.u_nextper - 1 end                " +
                                                        " where u_nextyear = {0} " + 
                                                        "   and u_nextper  = {1} " +
                                                        w +
                                                        " UNION " +
                                                        "Select a.Code, a.U_ActCode, a.U_DeBaja,  isnull(U_ActTipo , 'N') U_ActTipo      " +
                                                        " from [@VID_AFAS] a inner join [@VID_AFACR] b on a.code      = b.code and       " +
                                                        "                                                 b.U_Year    = case when a.u_nextper = 1 then a.u_nextyear - 1 else a.u_nextyear end and " +
                                                        "                                                 b.U_Periodo = case when a.u_nextper = 1 then 12 else a.u_nextper - 1 end                " +
                                                        " where u_nextyear = {0} " +
                                                        "   and u_nextper  = {1} " +
                                                        w,
                                                        'Select a."Code", a."U_ActCode", a."U_DeBaja",  IfNull("U_ActTipo" , ''N'') "U_ActTipo"   ' +
                                                        ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code"      = b."Code" and             ' +
                                                        '                                                b."U_Year"    = case when a."U_NextPer" = 1 then a."U_NextYear" - 1 else a."U_NextYear" end and ' +
                                                        '                                                b."U_Periodo" = case when a."U_NextPer" = 1 then 12 else a."U_NextPer" - 1 end                  ' +
                                                        ' where "U_NextYear" = {0} ' +
                                                        '   and "U_NextPer"  = {1} ' +
                                                        w +
                                                        ' UNION ' +
                                                        'Select a."Code", a."U_ActCode", a."U_DeBaja",  IfNull("U_ActTipo" , ''N'') "U_ActTipo"   ' +
                                                        ' from "@VID_AFAS" a inner join "@VID_AFACR" b on a."Code"      = b."Code" and            ' +
                                                        '                                                 b."U_Year"    = case when a."U_NextPer" = 1 then a."U_NextYear" - 1 else a."U_NextYear" end and ' +
                                                        '                                                 b."U_Periodo" = case when a."U_NextPer" = 1 then 12 else a."U_NextPer" - 1 end                  ' +
                                                        ' where "U_NextYear" = {0} ' +
                                                        '   and "U_NextPer"  = {1} ');
         s := string.Format(s, nxYr.ToString, nxPr.ToString);
         oRecordActivos.DoQuery(s);
         oRecordActivos.MoveFirst;
         if (oRecordActivos.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Sin_activos]);
        
         oActivos          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));
         oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

         oGrupos          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFGR'));
         oGruposParameter := SAPbobsCOM.GeneralDataParams(oGrupos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

         oProgBarCont      := 0;
         While (not oRecordActivos.Eof) do begin
            oCode := System.string(oRecordActivos.Fields.Item('Code').Value);
            oActivosParameter.SetProperty('Code', oCode);
            oActivosData := oActivos.GetByParams(oActivosParameter);
    
            oGruposParameter.SetProperty('Code', System.String(oActivosData.GetProperty('U_ItmGrpCd')));
            oGruposData := oGrupos.GetByParams(oGruposParameter);

            inc(oProgBarCont);
            var d1 : Double := oProgBarCont*100/oProgBarVal;
            oProgBar.Value := Convert.ToInt32(Math.Round(d1));
            oProgBar.text  := System.String(oRecordActivos.Fields.Item('U_ActCode').value);

            // Si ha sido dado de baja se mantine historia
            if (System.String(oRecordActivos.Fields.Item('U_DeBaja').value) = 'Y') then 
                raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Activos_en_baja_reversar]);
    
            s := System.string(oRecordActivos.Fields.Item('U_ActTipo').Value);
            FSBOf.Cmpny.StartTransaction;
            if (not GlobalSettings.IFRSNativo) then begin
               ReversarProcesoFinanciero(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod);
               ReversarProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod);
            end
            else if (s = 'N') then begin
               ReversarProcesoIFRS(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod);
               ReversarProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod);
            end
            else if (s = 'I') then 
               ReversarProcesoIFRS(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod)
            else if (s = 'T') then 
               ReversarProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRS, vyear, vperiod)
            else
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Activo_No_Clasificado]);
   
            oActivosData.SetProperty('U_NextYear',  vyear   );
            oActivosData.SetProperty('U_NextPer' ,  vperiod );

            oActivos.Update(oActivosData);
            oGrupos.Update(oGruposData);
            FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_Commit);
    
            oRecordActivos.MoveNext;
    
            // envio param para RemoveWindowMessage   ???
         end;

         Result := "";
      except
         on e:exception do begin
            FSBOf.SBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oLog.OutLog(e.Message + ' - ' + e.StackTrace);
            Result := e.Message;
            if (FSBOf.Cmpny.InTransaction) then
               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         end;
      end;
   finally   
      FSBOf._ReleaseCOMObject(oParametros);
      FSBOf._ReleaseCOMObject(oParametrosData);
      FSBOf._ReleaseCOMObject(oParametrosParameter);

      FSBOf._ReleaseCOMObject(oActivos);
      FSBOf._ReleaseCOMObject(oActivosData);
      FSBOf._ReleaseCOMObject(oActivosParameter);
      
      FSBOf._ReleaseCOMObject(oRecordActividad);
      FSBOf._ReleaseCOMObject(oRecordActivos);
   end;
end;

method  TRealizaProcesoAFS.GetIndice(oRecordAux1: SAPbobsCOM.Recordset; sIndice, sYear, sMonth: string; MarcaError: boolean): double;
var
   oSql : string;
begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select Rate from ORTT       " +
                  "  where currency = '{0}'    " +
                  "  and year(ratedate)  = {1} " +
                  "  and month(ratedate) = {2} ", 
                  'Select "Rate" from ORTT       ' +
                  '  where "Currency" = ''{0}''  ' +
                  '  and year("RateDate")  = {1} ' +
                  '  and month("RateDate") = {2} ');
      oSql := string.Format(oSql, sIndice, sYear, sMonth);
      oRecordAux1.DoQuery(oSql);
      if (oRecordAux1.Eof) and (MarcaError) then
         raise new exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Indices_no_definidos] + sYear + '/' + sMonth)
      else if (oRecordAux1.Eof) and (not MarcaError) then
         result := 0
      else
         result  := System.Double( oRecordAux1.Fields.Item('Rate').Value );
end;

method TRealizaProcesoAFS.ProcesarActivos(): string;
var
   TopeLey33BisR : double;
   TopeLey33BisF : double;
   UTM           : double;
   Indices       : TIndice;
   oCode         : String; 

   oActivos          : SAPbobsCOM.GeneralService;
   oActivosData      : SAPbobsCOM.GeneralData;
   oActivosParameter : SAPbobsCOM.GeneralDataParams;
   oActivosLines     : SAPbobsCOM.GeneralDataCollection;
   oActivosLinesData : SAPbobsCOM.GeneralData;

   oGrupos           : SAPbobsCOM.GeneralService;
   oGruposData       : SAPbobsCOM.GeneralData;
   oGruposParameter  : SAPbobsCOM.GeneralDataParams;

   oParametros          : SAPbobsCOM.GeneralService;
   oParametrosData      : SAPbobsCOM.GeneralData;
   oParametrosParameter : SAPbobsCOM.GeneralDataParams;

   s, w           : String;
   oSql           : string;
   nxYr   , nxPr  : Integer;

   oRecordAux:            SAPbobsCOM.RecordSet;
   oRecordIndices:        SAPbobsCOM.RecordSet;
   oRecordActividad:      SAPbobsCOM.Recordset;
   oRecordActivos:        SAPbobsCOM.RecordSet;
   oRecordActividadDel:   SAPbobsCOM.RecordSet;
   oProgBarVal          : integer;
   oProgBarCont         : integer;
begin
   try
      try
         Result := "No Terminado";
    
         oRecordAux            := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordIndices        := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividad      := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActivos        := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividadDel   := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
    
         // Traer parametros
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code from [@VID_AFPA]", 
                     'Select "Code" from "@VID_AFPA"');
         oRecordAux.DoQuery(oSql);
         if (oRecordAux.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros]);
         s := System.String(oRecordAux.Fields.Item('Code').Value);
    
         oParametros := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFPA'));
         oParametrosParameter := SAPbobsCOM.GeneralDataParams(oParametros.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oParametrosParameter.SetProperty('Code', s);
         oParametrosData := oParametros.GetByParams(oParametrosParameter);
    
         nxYr := G_Year;
         nxPr := G_Periodo;
         if (nxYr = 0) or (nxPr = 0) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_invalido]);
    
         // buscar error de activos sin actividad
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select U_ActCode  " +
                     " from [@VID_AFAS] " +
                     " where ( u_nextyear < {0} or " +
                     "       ( u_nextyear = {0} and u_nextper  < {1} ) ) " +
                     "   and isnull(u_debaja, 'N')  <> 'Y'               " +
                     "   and (U_pervidaR > u_pRrdepre or u_pervidau > u_perdepre) ", 
                     'Select "U_ActCode"  ' +
                     ' from "@VID_AFAS"   ' +
                     ' where ( "U_NextYear" < {0} or ' +
                     '       ( "U_NextYear" = {0} and "U_NextPer"  < {1} ) ) ' +
                     '   and IfNull("U_DeBaja", ''N'')  <> ''Y''             ' +
                     '   and ("U_PerVidaR" > "U_PRrDepre" or "U_PerVidaU" > "U_PerDepre") '); 
         oSql := string.Format(oSql, nxYr.ToString, nxPr.ToString);
         oRecordActividad.DoQuery(oSql);
         if (not oRecordActividad.Eof) then 
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Activo_sin_Actividad_posterior] +
                                   System.String(oRecordActividad.Fields.Item('U_ActCode').value));
    
         // buscar error de adiciones sin procesar
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.U_Adicion                                              " +
                     " from [@VID_AFAD] d inner join [@VID_AFAS] a on a.code = d.code " +
                     " where ( d.u_year < {0} or                                      " +
                     "       ( d.u_year = {0} and d.u_periodo  < {1} ) )              " +
                     "   and ( d.u_year    <> a.u_inityear)                           " +
                     "   and ( d.u_periodo <> a.u_initper)                            " +
                     "   and isnull(d.u_Procesad,'N')  <> 'Y'                         ", 
                     'Select d."U_Adicion"                                                ' +
                     ' from "@VID_AFAD" d inner join "@VID_AFAS" a on a."Code" = d."Code" ' +
                     ' where ( d."U_Year"     < {0} or                                    ' +
                     '       ( d."U_Year"     = {0} and d."U_Periodo"  < {1} ) )          ' +
                     '   and ( d."U_Year"    <> a."U_InitYear")                           ' +
                     '   and ( d."U_Periodo" <> a."U_InitPer")                            ' +
                     '   and IfNull(d."U_Procesad",''N'')  <> ''Y''                       ' ); 
         oSql := string.Format(oSql, nxYr.ToString, nxPr.ToString);
         oRecordActividad.DoQuery(oSql);
         if (not oRecordActividad.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Adicion_sin_Actividad_posterior] +
                                   System.String(oRecordActividad.Fields.Item('U_Adicion').value));
    
    
         // buscar error de activos con actividad ya procesada para el periodo
//         s := 'SELECT a.U_ActCode ' +
//              '  FROM [@VID_AFAC] d inner join [@VID_AFAS] a on a.code = d.code' +
//              ' Where d.u_year    = ' +  nxYr.ToString +
//              '   AND d.u_periodo = ' +  nxPr.ToString ;
//         oRecordActividad.DoQuery(s);
//         if (not oRecordActividad.Eof) then
//            raise new Exception('Activo con actividad para periodo: ' +  System.String(oRecordActividad.Fields.Item('U_ActCode').value));
    
         // obtener los posibles indices a utilizar
         Indices[0]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), TMultiFunctions.inttostr(nxYr-1), '12', false);
         Indices[1]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '1', false);
         Indices[2]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '2', false);
         Indices[3]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '3', false);
         Indices[4]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '4', false);
         Indices[5]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '5', false);
         Indices[6]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '6', false);
         Indices[7]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '7', false);
         Indices[8]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '8', false);
         Indices[9]   := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , '9', false);
         Indices[10]  := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  ,'10', false);
         Indices[11]  := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  ,'11', false);
         Indices[12]  := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  ,'12', false);
         indices[nxPr]:= GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_IPCInd')), nxYr.ToString  , nxPr.ToString, true);
    
         // Indice UTM recuperado para Ley Bis33.
         UTM           := 0.0;
         TopeLey33BisF := 0.0;
         TopeLey33BisR := 0.0;
         if (System.String(oParametrosData.GetProperty('U_Bis33Flg')) = 'Y') then
            UTM := GetIndice(oRecordIndices, System.String(oParametrosData.GetProperty('U_Bis33Ind')), nxYr.ToString, nxPr.ToString, true);
         if (System.String(oParametrosData.GetProperty('U_Bis33Fin')) = 'Y') then
            TopeLey33BisF := System.Double( oParametrosData.GetProperty('U_Bis33Top')) * UTM;
         if (System.String(oParametrosData.GetProperty('U_Bis33Ref')) = 'Y') then
            TopeLey33BisR := System.Double( oParametrosData.GetProperty('U_Bis33Top')) * UTM;
    
         // Borra lineas sin informacion
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Delete from [@VID_AFAC] where u_year is null  ",
                     'Delete from "@VID_AFAC" where "U_Year" is null');
         oRecordActividadDel.DoQuery(oSql);

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Delete from [@VID_AFACR] where u_year is null  ",
                     'Delete from "@VID_AFACR" where "U_Year" is null');
         oRecordActividadDel.DoQuery(oSql);
    
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Delete from [@VID_AFSA] where u_year is null  ",
                     'Delete from "@VID_AFSA" where "U_Year" is null');
         oRecordActividadDel.DoQuery(oSql);
    
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Delete from [@VID_AFSAR] where u_year is null  ",
                     'Delete from "@VID_AFSAR" where "U_Year" is null');
         oRecordActividadDel.DoQuery(oSql);
    
         // Proceso por grupos de activos
         w := '';
         if (oDSGrupo <> '') then begin
            w := iif(GlobalSettings.RunningUnderSQLServer, " and a.U_ItmGrpCd = '{0}' ",
                                                           ' and a."U_ItmGrpCd" = ''{0}'' '); 
            w := string.Format(w , oDSGrupo);
         end;
    
         s := iif(GlobalSettings.RunningUnderSQLServer, "Select count(*) cant    " +
                                                        " from [@VID_AFAS] a     " +
                                                        " where u_nextyear = {0} " +
                                                        "   and u_nextper  = {1} " +
                                                        w +
                                                        "   and isnull(U_DeBaja,'N')  <> 'Y' ",
                                                        'Select count(*) "cant"    ' +
                                                        ' from "@VID_AFAS" a       ' +
                                                        ' where "U_NextYear" = {0} ' +
                                                        '   and "U_NextPer"  = {1} ' +
                                                        w +
                                                        '   and IfNull("U_DeBaja",''N'')  <> ''Y'' '); 
         s := string.Format(s , nxYr.ToString, nxPr.ToString);
         oRecordActivos.DoQuery(s);
         oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);

         s := iif(GlobalSettings.RunningUnderSQLServer, "Select a.U_ActCode , a.Code , a.U_ActTipo    " +
                                                        " from [@VID_AFAS] a     " +
                                                        " where u_nextyear = {0} " +
                                                        "   and u_nextper  = {1} " +
                                                        w +
                                                        "   and isnull(U_DeBaja,'N')  <> 'Y' " +
                                                        " order by U_InDate                  " ,
                                                        'Select a."U_ActCode" , a."Code" , a."U_ActTipo" ' +
                                                        ' from "@VID_AFAS" a       ' +
                                                        ' where "U_NextYear" = {0} ' +
                                                        '   and "U_NextPer"  = {1} ' +
                                                        w +
                                                        '   and IfNull("U_DeBaja",''N'')  <> ''Y'' ' +
                                                        ' order by "U_InDate"                  '); 
         s := string.Format(s , nxYr.ToString, nxPr.ToString);
         oRecordActivos.DoQuery(s);
         if (oRecordActivos.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Sin_activo_a_procesar]);
        
         oActivos          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));
         oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

         oGrupos          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFGR'));
         oGruposParameter := SAPbobsCOM.GeneralDataParams(oGrupos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

         oProgBarCont      := 0;
         While (not oRecordActivos.Eof) do begin
            oCode := System.string(oRecordActivos.Fields.Item('Code').Value);
            oActivosParameter.SetProperty('Code', oCode);
            oActivosData := oActivos.GetByParams(oActivosParameter);

            oGruposParameter.SetProperty('Code', System.String(oActivosData.GetProperty('U_ItmGrpCd')));
            oGruposData := oGrupos.GetByParams(oGruposParameter);
           
            inc(oProgBarCont);
            var d1 : Double := oProgBarCont*100/oProgBarVal;
            oProgBar.Value := Convert.ToInt32(Math.Round(d1));
            oProgBar.text  := System.String(oActivosData.GetProperty('U_ActCode'));

//            FSBOf.SBOApp.StatusBar.SetText(i.ToString + '  ' + 'Procesando : ' + System.String(oRecordActivos.Fields.Item('U_ActCode').value) , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_warning);
          
            s := System.string(oRecordActivos.Fields.Item('U_ActTipo').Value);
            FCmpny.StartTransaction;
            if (not GlobalSettings.IFRSNativo) then begin
               ProcesoFinanciero(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, Indices, nxYr, nxPr, var TopeLey33BisF);
               ProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, Indices, nxYr, nxPr, var TopeLey33BisR);
            end
            else if (s = 'N') then begin
               ProcesoIFRS(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, nxYr, nxPr);
               ProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, Indices, nxYr, nxPr, var TopeLey33BisR);
            end
            else if (s = 'I') then 
               ProcesoIFRS(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, nxYr, nxPr)
            else if (s = 'T') then 
               ProcesoReferencial(var oActivosData, var oParametrosData, var oGruposData, var oRecordAux, Indices, nxYr, nxPr, var TopeLey33BisR)
            else
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Activo_No_Clasificado]);
          
            // oActivosData.ToXMLFile(FSBOf.oLog.LogFile + 'Activo_procesado.xml');
            oActivos.Update(oActivosData);
            oGrupos.Update(oGruposData);
            FCmpny.EndTransaction(BoWfTransOpt.wf_Commit);
    
            oRecordActivos.MoveNext;
         end;
         oProgBar.Value := 100;
         Result := "";
      except 
         on e:exception do begin
            if (FSBOf.Cmpny.InTransaction) then
               FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
            FSBOf.SBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oLog.OutLog(e.Message + ' - ' + e.StackTrace);
            Result := e.Message;
         end;
      end;
   finally
      if (FCmpny.InTransaction) then
         FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
   
      FSBOf._ReleaseCOMObject(oParametros);
      FSBOf._ReleaseCOMObject(oParametrosData);
      FSBOf._ReleaseCOMObject(oParametrosParameter);
      
      FSBOf._ReleaseCOMObject(oActivosParameter);
      FSBOf._ReleaseCOMObject(oActivosLinesData);
      FSBOf._ReleaseCOMObject(oActivosLines);
      FSBOf._ReleaseCOMObject(oActivosData);
      FSBOf._ReleaseCOMObject(oActivos);

      FSBOf._ReleaseCOMObject(oRecordAux);
      FSBOf._ReleaseCOMObject(oRecordIndices);
      FSBOf._ReleaseCOMObject(oRecordActividad);
      FSBOf._ReleaseCOMObject(oRecordActivos);
      FSBOf._ReleaseCOMObject(oRecordActividadDel);
   end;
end;

method TRealizaProcesoAFS.Centralizar(): string;
var
   vyear, vperiod : integer;
   s, s1, w, w1   : string;
   Bis33Fin       : Boolean;
   Des_JoCorAct   : string;
   Des_JoDepAct   : string;
   Des_JoCorDep   : string;
   errMsg         : string;
   dia            : integer;

   sCuentasCont   : String;
   sOrderCtas     : String;
   sGroupCtas     : String;

   // Para contabilizar Bis33
   lstCtaBis33    : List<String>;
   lstCtaDepAc    : List<String>;
   lstMtoBis33    : List<Double>; 
   lstMtoBis33Sys : List<Double>; 
   lstProfitC1    : List<String>; 
   lstProfitC2    : List<String>; 
   lstProfitC3    : List<String>; 
   lstProfitC4    : List<String>; 
   lstProfitC5    : List<String>; 
   lstProject     : List<String>; 
   TotBis33       : Double;
   TotBis33Sys    : Double;
   i, j, last_i   : Integer;
   U_TasaCnMS_Ope : String; 

   oParametros          : SAPbobsCOM.GeneralService;
   oParametrosData      : SAPbobsCOM.GeneralData;
   oParametrosParameter : SAPbobsCOM.GeneralDataParams;

   oJEntries           : SAPbobsCOM.JournalEntries;
   oRecordActivos      : SAPbobsCOM.RecordSet;
   oRecordActividad    : SAPbobsCOM.RecordSet;
   oRecordActividadUpd : SAPbobsCOM.RecordSet;
   Repomo              : Boolean;
   oProgBarVal         : integer;
   oProgBarCont        : integer;
   aux_primeravez      : boolean;
   oSql                : string;
   orst       : SAPbobsCOM.Recordset;

begin
   try
      try
         Result        := "No terminado";
         oRecordActivos     := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividad   := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividadUpd:= RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
   
         vyear   := G_Year;
         vperiod := G_Periodo;
   
         oTasaFija  := Utils.oTasaFija;
         oPostSysCu := Utils.oPostSysCu;

         if (not PeriodoAbierto(vyear, vperiod) ) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_Cerrado]);
   
         // Traer parametros
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code, " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoCorAct) Des_JoCorAct , " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoDepAct) Des_JoDepAct , " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoCorDep) Des_JoCorDep   " +
                     " from [@VID_AFPA] p ",
                     'Select "Code", ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoCorAct") "Des_JoCorAct" , ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoDepAct") "Des_JoDepAct" , ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoCorDep") "Des_JoCorDep"   ' +
                     ' from "@VID_AFPA" p ');
         oRecordActividad.DoQuery(oSql);
         if (oRecordActividad.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros]);
         Des_JoCorAct := System.String(oRecordActividad.Fields.Item('Des_JoCorAct').Value);
         Des_JoDepAct := System.String(oRecordActividad.Fields.Item('Des_JoDepAct').Value);
         Des_JoCorDep := System.String(oRecordActividad.Fields.Item('Des_JoCorDep').Value);
         s            := System.String(oRecordActividad.Fields.Item('Code').Value);
   
   
         oParametros := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFPA'));
         oParametrosParameter := SAPbobsCOM.GeneralDataParams(oParametros.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oParametrosParameter.SetProperty('Code', s);
         oParametrosData := oParametros.GetByParams(oParametrosParameter);
   
         // Actividad
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select code               " +
                     " from [@VID_AFAC]         " +
                     " where ( u_year < {0}  or " +
                     "       ( u_year = {0}  and u_Periodo  < {1} ) ) " +
                     "   and u_year is not null " +
                     "   and u_postflag = 'N' ", 
                     'Select "Code"             ' +
                     ' from "@VID_AFAC"         ' +
                     ' where ( "U_Year" < {0}  or ' +
                     '       ( "U_Year" = {0}  and "U_Periodo"  < {1} ) ) ' +
                     '   and "U_Year" is not null ' +
                     '   and "U_PostFlag" = ''N'' ');
         oSql := string.Format(oSql, vyear.ToString, vperiod.ToString);
         oRecordActividad.DoQuery(oSql);
         oRecordActividad.MoveFirst;
         if (not oRecordActividad.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_anterior_con_actividad]);
   
         dia := system.Int32( oParametrosData.GetProperty('U_DiaConta') );
         case vperiod of
            2:               dia := Math.Min(dia, 28);
            1,3,5,7,8,10,12: dia := Math.Min(dia, 31);
            4,6,9,11:        dia := Math.Min(dia, 30);
         end;
   
         Repomo := false;
         if (System.String(oParametrosData.GetProperty('U_Repomo')).Trim = 'Y') then
            Repomo := true;
   
         Bis33Fin := false; 
         if (System.String(oParametrosData.GetProperty('U_Bis33Fin')) = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Flg')) = 'Y') and (not GlobalSettings.IFRSNativo) then
            Bis33Fin := true;
         if (vperiod <> 12) then
            Bis33Fin := false;
   
         w1 := '';
         if (Bis33Fin) then begin
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer, " a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, a.u_ctabis33 ",
                                                                      ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", a."U_CtaBis33" '); 
            sOrderCtas   := iif(GlobalSettings.RunningUnderSQLServer, " order by a.U_Project, a.u_ctabis33, a.u_ctagasde ",
                                                                      ' order by a."U_Project", a."U_CtaBis33", a."U_CtaGasDe" ');
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer, " a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, a.u_ctabis33 ",
                                                                      ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", a."U_CtaBis33" '); 
   
            lstCtaBis33    := new List<String>;
            lstCtaDepAc    := new List<String>;
            lstMtoBis33    := new List<Double>; 
            lstMtoBis33Sys := new List<Double>; 
            lstProfitC1    := new List<String>;
            lstProfitC2    := new List<String>;
            lstProfitC3    := new List<String>;
            lstProfitC4    := new List<String>;
            lstProfitC5    := new List<String>;
            lstProject     := new List<String>;
         end
         else if (GlobalSettings.IFRSNativo) then begin
            w1           := iif(GlobalSettings.RunningUnderSQLServer," and isnull(a.U_ActTipo , 'N') <> 'T' ",
                                                                     ' and ifnull(a."U_ActTipo" , ''N'') <> ''T'' ');
            // no se utilizan u_ctacoraf,  u_ctacorda
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctadepac,  a.u_ctagasde, '' u_ctabis33 ",
                                                                     '  a."U_CtaActFi",  a."U_CtaDepAc",  a."U_CtaGasDe", '''' "U_CtaBis33" ');
            sOrderCtas   := " ";
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctadepac,  a.u_ctagasde ",
                                                                     ' a."U_CtaActFi",  a."U_CtaDepAc",  a."U_CtaGasDe" ');
         end
         else begin
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, '' u_ctabis33 ",
                                                                     ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", '''' "U_CtaBis33" ');
            sOrderCtas   := " ";
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde ",
                                                                     ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe" ');
         end;
   
         // Proceso por grupos de activos
         w := '';
         if (oDSGrupo <> '') then begin
            w := iif(GlobalSettings.RunningUnderSQLServer," and a.U_ItmGrpCd = '{0}' ",
                                                          ' and a."U_ItmGrpCd" = ''{0}'' ');
            w := string.Format(w, oDSGrupo);
         end;
   
         // tasa de cambio
         if (not oPostSysCu) then 
            U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                  " / CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                  ' / CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ')
         else
            U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                  " * CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                  ' * CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ');
         // la consulta de actividad es por item o por grupos de items
         if (system.String( oParametrosData.GetProperty('U_ActbyLoc') ) = 'N') then begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select count(*) cant " +
                     " from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        " +
                     " where b.u_year     = {0} " +
                     "   and b.u_periodo  = {1} " +
                     w + w1 +
                     "   and b.u_postflag = 'N' ",
                     'Select count(*) "cant" ' +
                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +
                     ' where b."U_Year"     = {0} ' +
                     '   and b."U_Periodo"  = {1} ' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''N'' ');
            s := string.Format(s, vyear.ToString, vperiod.ToString);
            oRecordActivos.DoQuery(s);
            oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);
   
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select a.U_ActCode ref, a.code, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5,  " +
                     sCuentasCont +
                     "      ,b.u_corracti, b.u_corrdepr, b.u_deprecia, b.u_corrdepm, b.u_deprnom, " +
                     "       z.Bis33, " +
                     "       case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end + " +
                     "       case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end residual, " +
   
                     "       b.u_corracti" + U_TasaCnMS_Ope + " u_corractiSys, " +
                     "       b.u_corrdepr" + U_TasaCnMS_Ope + " u_corrdeprSys, " + 
                     "       b.u_deprecia" + U_TasaCnMS_Ope + " u_depreciaSys, " +
                     "       b.u_corrdepm" + U_TasaCnMS_Ope + " u_corrdepmSys, " +
                     "       b.u_deprnom " + U_TasaCnMS_Ope + " u_deprnomSys , " +
                     "       z.Bis33     " + U_TasaCnMS_Ope + "      Bis33Sys, " +
                     '       case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end ' + U_TasaCnMS_Ope + ' + ' +
                     '       case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end' + U_TasaCnMS_Ope + ' residualsys ' +

                     ' from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        ' +

                     '                    inner join (select  code, sum(U_PerDepre) TotPerDepre ' +
                     '                                  from [@vid_afac] ' +
                     "                                 where (U_Year < {0} ) or (u_year = {0} and u_periodo <= {1}) " +
                     '                                 group by code ' +
                     '                                ) Y on a.code = Y.code ' +
   
                     '               left outer join (select code, sum(isnull(U_Bis33,0)) Bis33 ' +
                     '                                  from [@VID_AFSA] sa  ' +
                     '                                  where U_Year = {0}   ' +
                     '                                  group by code        ' +
                     '                                ) Z on a.Code = Z.Code ' +
   
                     ' where b.u_year     = {0}' +
                     '   and b.u_periodo  = {1}' +
                     w + w1 +
                     '   and b.u_postflag = ''N'' ' +
                     sOrderCtas ,

                     'Select a."U_ActCode" "ref", a."Code", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",  ' +
                     sCuentasCont + ',' +
                     '       b."U_CorrActi", b."U_CorrDepr", b."U_Deprecia", b."U_CorrDepM", b."U_DeprNom", ' +
                     '       z."Bis33", ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end + ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end "residual", ' +
   
                     '       b."U_CorrActi"' + U_TasaCnMS_Ope + ' "U_CorrActiSys", ' +
                     '       b."U_CorrDepr"' + U_TasaCnMS_Ope + ' "U_CorrDeprSys", ' + 
                     '       b."U_Deprecia"' + U_TasaCnMS_Ope + ' "U_DepreciaSys", ' +
                     '       b."U_CorrDepM"' + U_TasaCnMS_Ope + ' "U_CorrDepmSys", ' +
                     '       b."U_DeprNom" ' + U_TasaCnMS_Ope + ' "U_DeprNomSys" , ' +
                     '       z."Bis33"     ' + U_TasaCnMS_Ope + '      "Bis33Sys", ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end ' + U_TasaCnMS_Ope + ' + ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end' + U_TasaCnMS_Ope + ' "residualsys" ' +

                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +

                     '                    inner join (Select  "Code", sum("U_PerDepre") "TotPerDepre" ' +
                     '                                  from "@VID_AFAC"         ' +
                     '                                 where ("U_Year" < {0}) or ("U_Yea" = {0} and "U_Periodo" <= {1}) ' +
                     '                                 group by "Code"           ' +
                     '                                ) Y on a."Code" = Y."Code" ' +
   
                     '               left outer join (select "Code", sum(ifnull("U_Bis33",0)) "Bis33" ' +
                     '                                  from "@VID_AFSA" sa      ' +
                     '                                  where "U_Year" = {0}     ' +
                     '                                  group by "Code"          ' +
                     '                                ) Z on a."Code" = Z."Code" ' +
   
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag = ''N'' ' +
                     sOrderCtas );
            s := string.Format(s, vyear.ToString, vperiod.ToString);

            errMsg := 'activo';
         end
         else begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select count(*) cant from ( " +
                     "Select a.U_ItmGrpCd ref,  a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5,      " +
                     sCuentasCont + ',' +
                     "       sum(b.u_corracti) u_corracti, sum(b.u_corrdepr) u_corrdepr, sum(b.u_deprecia) u_deprecia, sum(b.u_corrdepm) u_corrdepm, sum(b.u_deprnom) u_deprnom " +
                     " from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code " +
                     " where b.u_year     = {0}" +
                     "   and b.u_periodo  = {1}" +
                     w + w1 +
                     "   and b.u_postflag = 'N' " +
                     " group by a.U_ItmGrpCd, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, " + sGroupCtas +
                     ") T0 ",
                     'Select count(*) "cant" from ( ' +
                     'Select a."U_ItmGrpCd" "ref",  a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",      ' +
                     sCuentasCont + ',' +
                     '       sum(b."U_CorrActi") "U_corracti", sum(b."U_CorrDepr") "U_corrdepr", sum(b."U_Deprecia") "U_deprecia", sum(b."U_CorrDepM") "U_corrdepm", sum(b."U_DeprNom") "U_deprnom" ' +
                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code" ' +
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''N'' ' +
                     ' group by a."U_ItmGrpCd", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5", ' + sGroupCtas +
                     ') T0 ');
            s := string.Format(s, vyear.ToString, vperiod.ToString);
            oRecordActivos.DoQuery(s);
            oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select a.U_ItmGrpCd ref, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, " +
                     sCuentasCont +
                     "      ,sum(b.u_corracti) u_corracti, sum(b.u_corrdepr) u_corrdepr, sum(b.u_deprecia) u_deprecia, sum(b.u_corrdepm) u_corrdepm, sum(b.u_deprnom) u_deprnom, " +
                     "       sum(z.Bis33) Bis33, " +
                     "       sum(case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end) + " +
                     "       sum(case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end) residual, " +
   
                     "       sum(b.u_corracti" + U_TasaCnMS_Ope + ") u_corractiSys, " +
                     "       sum(b.u_corrdepr" + U_TasaCnMS_Ope + ") u_corrdeprSys, " + 
                     "       sum(b.u_deprecia" + U_TasaCnMS_Ope + ") u_depreciaSys, " +
                     "       sum(b.u_corrdepm" + U_TasaCnMS_Ope + ") u_corrdepmSys, " +
                     "       sum(b.u_deprnom " + U_TasaCnMS_Ope + ") u_deprnomSys , " +
                     "       sum(z.Bis33     " + U_TasaCnMS_Ope + ")      Bis33Sys, " +
                     '       sum(case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end ' + U_TasaCnMS_Ope + ') + ' +
                     '       sum(case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end' + U_TasaCnMS_Ope + ') residualsys ' +

                     ' from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        ' +

                     '                    inner join (select  code, sum(U_PerDepre) TotPerDepre ' +
                     '                                  from [@vid_afac] ' +
                     "                                 where (U_Year < {0} ) or (u_year = {0} and u_periodo <= {1}) " +
                     '                                 group by code ' +
                     '                                ) Y on a.code = Y.code ' +
   
                     '               left outer join (select code, sum(isnull(U_Bis33,0)) Bis33 ' +
                     '                                  from [@VID_AFSA] sa  ' +
                     '                                  where U_Year = {0}   ' +
                     '                                  group by code        ' +
                     '                                ) Z on a.Code = Z.Code ' +
   
                     ' where b.u_year     = {0}' +
                     '   and b.u_periodo  = {1}' +
                     w + w1 +
                     '   and b.u_postflag = ''N'' ' +
                     ' group by a.U_ItmGrpCd, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, ' + sGroupCtas +
                     sOrderCtas ,

                     'Select a."U_ItmGrpCd" "ref", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5", ' +
                     sCuentasCont + ',' +
                     '       sum(b."U_CorrActi") "U_CorrActi", sum(b."U_CorrDepr") "U_CorrDepr", sum(b."U_Deprecia") "U_Deprecia", sum(b."U_CorrDepM") "U_CorrDepm", sum(b."U_DeprNom") "U_DeprNom", ' +
                     '       sum(z."Bis33") "Bis33", ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end) + ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end) "residual", ' +
   
                     '       sum(b."U_CorrActi"' + U_TasaCnMS_Ope + ') "U_CorrActiSys", ' +
                     '       sum(b."U_CorrDepr"' + U_TasaCnMS_Ope + ') "U_CorrDeprSys", ' + 
                     '       sum(b."U_Deprecia"' + U_TasaCnMS_Ope + ') "U_DepreciaSys", ' +
                     '       sum(b."U_CorrDepM"' + U_TasaCnMS_Ope + ') "U_CorrDepmSys", ' +
                     '       sum(b."U_DeprNom" ' + U_TasaCnMS_Ope + ') "U_DeprNomSys" , ' +
                     '       sum(z."Bis33"     ' + U_TasaCnMS_Ope + ')      "Bis33Sys", ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end ' + U_TasaCnMS_Ope + ') + ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end' + U_TasaCnMS_Ope + ') "residualsys" ' +

                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +

                     '                    inner join (Select  "Code", sum("U_PerDepre") "TotPerDepre" ' +
                     '                                  from "@VID_AFAC" ' +
                     '                                 where ("U_Year" < {0}) or ("U_Year" = {0} and "U_Periodo" <= {1}) ' +
                     '                                 group by "Code" ' +
                     '                                ) Y on a."Code" = Y."Code" ' +
   
                     '               left outer join (select "Code", sum(ifnull("U_Bis33",0)) "Bis33" ' +
                     '                                  from "@VID_AFSA" sa      ' +
                     '                                  where "U_Year" = {0}     ' +
                     '                                  group by "Code"          ' +
                     '                                ) Z on a."Code" = Z."Code" ' +
   
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''N'' ' +
                     ' group by a."U_ItmGrpCd", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5", ' + sGroupCtas +
                     sOrderCtas );
            s := string.Format(s, vyear.ToString, vperiod.ToString);
   
            errMsg := 'grupo';
         end;
         oRecordActivos.DoQuery(s);
   
         oRecordActivos.MoveFirst;
         if (oRecordActivos.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Sin_activos_a_contabilizar])
         else 
         begin
             if (oDSGrupo = '') then
             begin
                 s := iif(GlobalSettings.RunningUnderSQLServer,
                         "SELECT COUNT(*) 'Cant'
                            FROM [@VID_AFAS] T0
                            JOIN [@VID_AFAC] T1 ON T1.Code = T0.Code
                           WHERE 1= 1
                             AND T1.U_Year = {0}
                             AND T1.U_Periodo = {1}
                             AND ISNULL(T1.U_PostFlag,'N') = 'Y'",

                         'SELECT COUNT(*) "Cant" ' +
                         '   FROM "@VID_AFAS" T0 ' +
                         '   JOIN "@VID_AFAC" T1 ON T1."Code" = T0."Code" ' +
                         '  WHERE 1= 1 ' +
                         '    AND T1."U_Year" = {0} ' +
                         '    AND T1."U_Periodo" = {1} ' +
                         '    AND IFNULL(T1."U_PostFlag",''N'') = ''Y'' ' );
                 s := string.Format(s, vyear.ToString, vperiod.ToString);
                 orst.DoQuery(s);
                 if system.Int32(orst.Fields.Item('Cant').Value) > 0 then
                   raise new Exception ("Existen activos contabilizados en el periodo, para utilizar la opción Todos no debe tener procesos contabilizados por grupo"); 
             end;
         end;

   
         oProgBarCont := 0;
         FCmpny.StartTransaction;
         while (not oRecordActivos.Eof) do begin
            inc(oProgBarCont);
            var d1 : Double := oProgBarCont*100/oProgBarVal;
            oProgBar.Value := Convert.ToInt32(Math.Round(d1));
            oProgBar.text  := System.String(oRecordActivos.Fields.Item('ref').value);
   
            if (system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_ActFij] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (not GlobalSettings.IFRSNativo) then begin
               if (system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ) = '') then
                  raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrActFij] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
               if (system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ) = '') then
                  raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrDepr] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            end;
            if (system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_DepAcum] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_GasDep] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (system.String( oRecordActivos.Fields.Item('u_ctabis33').Value ) = '') and (Bis33Fin) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_Bis33] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
   
            if (GlobalSettings.IFRSNativo) then begin
                  // depreciacion acumulada contra gastos de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual').Value )  , 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys').Value )  , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
            end;
   
            if (not GlobalSettings.IFRSNativo) then begin
               // activo fijo contra correccion de activos (Repomo)
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
   
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                             system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                             system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                             system.String( oParametrosData.GetProperty('U_JoCorAct') ),
                                             Des_JoCorAct );
   
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                              system.Double( oRecordActivos.Fields.Item('u_corracti').Value ), 
                                              system.Double( oRecordActivos.Fields.Item('u_corractiSys').Value ), 
                                              system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                              system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ),
                                              system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ) );
   
               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
   
               if (not repomo) then begin
                  // depreciacion acumulada contra correccion de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoCorDep') ),
                                                Des_JoCorDep );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepr').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdeprSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end
               else begin
                  // depreciacion acumulada contra correccion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                 Utils. ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoCorDep') ),
                                                Des_JoCorDep );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepr').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdeprSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end;
          
               if (not repomo) then begin
                  // depreciacion acumulada contra gastos de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepm').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual').Value )  , 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepmSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys').Value )  , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end
               else begin
                  // depreciacion con repomo
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'AF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );

                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, // esto es no por uso; en este caso la depreciacion no nominal es cero -> ver siguiente ingreso a asiento.
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnom').Value ) , 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnomSys').Value ) , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) );
          
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, // esto es depreciaicon por uso; en este caso la depreciacion nominal es 0
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepm').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual'  ).Value ) -
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnom').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepmSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys'  ).Value ) -
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnomSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end;
            end;
   
            if (Bis33Fin) then begin
               // Bis33  contra gastos de depreciacion            
               lstCtaBis33.add( system.String( oRecordActivos.Fields.Item('u_ctabis33').Value ));
//               lstCtaDepAc.add( system.String( oRecordActivos.Fields.Item('u_ctadepac').Value )); // Se cambio cuenta DepAcum por ActFijo
               lstCtaDepAc.add( system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ));
               lstMtoBis33.add( Utils.AjustarDecimalesSUM(system.Double( oRecordActivos.Fields.Item('Bis33').Value )));
               lstMtoBis33Sys.add( Utils.AjustarDecimalesSUM(system.Double( oRecordActivos.Fields.Item('Bis33Sys').Value )));
               lstProfitC1.add( system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ));
               lstProfitC2.add( system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ));
               lstProfitC3.add( system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ));
               lstProfitC4.add( system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ));
               lstProfitC5.add( system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ));
               lstProject.add(  system.String( oRecordActivos.Fields.Item('U_Project' ).Value ));
            end;
   
            if (system.String( oParametrosData.GetProperty('U_ActbyLoc') ) = 'N') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        "Update [@VID_AFAC] set " +
                        "   U_PostFlag = 'Y'    " +
                        " where code = '{0}'    " + 
                        "   and U_Year    = {1} " + 
                        "   and U_Periodo = {2} ",
                        'Update "@VID_AFAC" set  ' +
                        '   "U_PostFlag" = ''Y'' ' +
                        ' where "Code" = ''{0}'' ' + 
                        '   and "U_Year"    = {1}' + 
                        '   and "U_Periodo" = {2}');
                s := string.Format(s , System.String(oRecordActivos.Fields.Item('code').value), vyear.ToString, vperiod.ToString);
            end
            else begin
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        'Update [@VID_AFAC] set ' +
                        "   U_PostFlag = 'Y'    " +
                        " where code in (select code from [@vid_afas] where u_ItmGrpCd = '{0}' " +
                        '   and U_Year    = {1} ' +
                        '   and U_Periodo = {2} )', 
                        'Update "@VID_AFAC" set  ' +
                        '   "U_PostFlag" = ''Y'' ' +
                        ' where "Code" in (select "Code" from "@VID_AFAS" where "U_ItmGrpCd" = ''{0}'' ' +
                        '   and "U_Year"    = {1} ' +
                        '   and "U_Periodo" = {2} )');
                s := string.Format(s , System.String(oRecordActivos.Fields.Item('ref').value), vyear.ToString, vperiod.ToString);
            end;
   
            oRecordActividadUpd.DoQuery(s);
   
            oRecordActivos.MoveNext;
         end;
   
         if (Bis33Fin) then begin        
            aux_primeravez := true;
            s  := '';
            s1 := '';

            for i:=0 to lstMtoBis33.count-1 do begin
               if (Double(lstMtoBis33[i]) = 0) then
                  continue;
   
               if (aux_primeravez) then begin
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'B33-', 'Bis33', String(lstProject[i]).Trim, '', 'Bis33' );
                  aux_primeravez := false;
               end;

               if (s1 <> String(lstCtaBis33[i]).Trim) or (s <> String(lstProject[i]).Trim) then begin
                  if (s1 <> '') then begin
                     //ingresar cuenta bis33 a voucher
                     if (oJEntries.Lines.Count = 1) then begin
                        oJEntries.Lines.SetCurrentLine(0);
                        if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                           oJEntries.Lines.Add;
                     end
                     else 
                        oJEntries.Lines.Add;
                     j := oJEntries.Lines.Count-1;
   
                     oJEntries.Lines.SetCurrentLine(j);
                     oJEntries.Lines.AccountCode := String(lstCtaBis33[last_i]);
                     oJEntries.Lines.ProjectCode := String(lstProject[last_i]);
                     s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                          'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                    s := String.Format(s, String(lstCtaBis33[last_i])); 
                    orst.DoQuery(s);
                    s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                    if (s = 'I') or (s = 'E') then
                    begin
                        oJEntries.Lines.CostingCode  := String(lstProfitC1[last_i]);
                        oJEntries.Lines.CostingCode2 := String(lstProfitC2[last_i]);
                        oJEntries.Lines.CostingCode3 := String(lstProfitC3[last_i]);
                        oJEntries.Lines.CostingCode4 := String(lstProfitC4[last_i]);
                        oJEntries.Lines.CostingCode5 := String(lstProfitC5[last_i]);
                     end;

                    if (not oPostSysCu) then begin
                       if (TotBis33 > 0) then
                          oJEntries.Lines.Debit   := Double(TotBis33)
                       else
                          oJEntries.Lines.Credit  := Double(TotBis33) * (-1);

                       if (oTasaFija) then begin
                          if (TotBis33Sys > 0) then
                             oJEntries.Lines.DebitSys := Double(TotBis33Sys)
                          else
                             oJEntries.Lines.CreditSys  := Double(TotBis33Sys) * (-1);
                       end;
                    end
                    else begin
                       oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                       if (TotBis33 > 0) then
                          oJEntries.Lines.FCDebit   := Double(TotBis33)
                       else
                          oJEntries.Lines.FCCredit  := Double(TotBis33) * (-1);

                       if (oTasaFija) then begin
                          if (TotBis33Sys > 0) then
                             oJEntries.Lines.Debit   := Double(TotBis33Sys)
                          else
                             oJEntries.Lines.Credit  := Double(TotBis33Sys) * (-1);

                          if (TotBis33 > 0) then
                             oJEntries.Lines.DebitSys   := Double(TotBis33)
                          else
                             oJEntries.Lines.CreditSys  := Double(TotBis33) * (-1);
                       end;
                    end;
                  end;
   
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);

                  TotBis33    := 0;
                  TotBis33Sys := 0;
                  s1 := String(lstCtaBis33[i]).Trim;
                  s  := String(lstProject[i]).Trim;

                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'B33-', 'Bis33', String(lstProject[i]).Trim, '', 'Bis33' );
               end;
   
               TotBis33    := TotBis33    + Double(lstMtoBis33[i]);
               TotBis33Sys := TotBis33Sys + Double(lstMtoBis33Sys[i]);
               last_i   := i;
   
               // ingresar a cuenta depac
               if (oJEntries.Lines.Count = 1) then begin
                  oJEntries.Lines.SetCurrentLine(0);
                  if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                     oJEntries.Lines.Add;
               end
               else 
                  oJEntries.Lines.Add;
               j := oJEntries.Lines.Count-1;
   
               oJEntries.Lines.SetCurrentLine(j);
               oJEntries.Lines.AccountCode := String(lstCtaDepAc[i]);
               oJEntries.Lines.ProjectCode := String(lstProject[i]);
               s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
              s := String.Format(s, String(lstCtaDepAc[i])); 
              orst.DoQuery(s);
              s := System.String(orst.Fields.Item('ActType').value).Trim();
   
              if (s = 'I') or (s = 'E') then
              begin
                  oJEntries.Lines.CostingCode  := String(lstProfitC1[i]);
                  oJEntries.Lines.CostingCode2 := String(lstProfitC2[i]);
                  oJEntries.Lines.CostingCode3 := String(lstProfitC3[i]);
                  oJEntries.Lines.CostingCode4 := String(lstProfitC4[i]);
                  oJEntries.Lines.CostingCode5 := String(lstProfitC5[i]);
               end;

               if (not oPostSysCu) then begin
                  if (Double(lstMtoBis33[i]) > 0) then
                     oJEntries.Lines.Credit   := Double(lstMtoBis33[i])
                  else
                     oJEntries.Lines.debit    := Double(lstMtoBis33[i]) * (-1);

                  if (oTasaFija) then begin
                     if (Double(lstMtoBis33Sys[i]) > 0) then
                        oJEntries.Lines.CreditSys := Double(lstMtoBis33Sys[i])
                     else
                        oJEntries.Lines.DebitSys  := Double(lstMtoBis33Sys[i]) * (-1);
                  end;   
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (Double(lstMtoBis33[i]) > 0) then
                     oJEntries.Lines.FCCredit   := Double(lstMtoBis33[i])
                  else
                     oJEntries.Lines.FCDebit  := Double(lstMtoBis33[i]) * (-1);

                  if (oTasaFija) then begin
                     if (Double(lstMtoBis33Sys[i]) > 0) then
                        oJEntries.Lines.Credit   := Double(lstMtoBis33Sys[i])
                     else
                        oJEntries.Lines.Debit  := Double(lstMtoBis33Sys[i]) * (-1);

                     if (Double(lstMtoBis33[i]) > 0) then
                        oJEntries.Lines.CreditSys   := Double(lstMtoBis33[i])
                     else
                        oJEntries.Lines.DebitSys  := Double(lstMtoBis33[i]) * (-1);
                  end;
               end;
            end;
   
            if (s1 <> '') then begin
               //ingresar cuenta bis33 a voucher
               if (oJEntries.Lines.Count = 1) then begin
                  oJEntries.Lines.SetCurrentLine(0);
                  if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                     oJEntries.Lines.Add;
               end
               else 
                  oJEntries.Lines.Add;
               j := oJEntries.Lines.Count-1;
   
               oJEntries.Lines.SetCurrentLine(j);
               oJEntries.Lines.AccountCode := String(lstCtaBis33[last_i]);
               oJEntries.Lines.ProjectCode := String(lstProject[last_i]);
               s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
              s := String.Format(s, String(lstCtaBis33[last_i])); 
              orst.DoQuery(s);
              s := System.String(orst.Fields.Item('ActType').value).Trim();
   
              if (s = 'I') or (s = 'E') then
              begin
                  oJEntries.Lines.CostingCode  := String(lstProfitC1[last_i]);
                  oJEntries.Lines.CostingCode2 := String(lstProfitC2[last_i]);
                  oJEntries.Lines.CostingCode3 := String(lstProfitC3[last_i]);
                  oJEntries.Lines.CostingCode4 := String(lstProfitC4[last_i]);
                  oJEntries.Lines.CostingCode5 := String(lstProfitC5[last_i]);
               end;

               if (not oPostSysCu) then begin
                  if (TotBis33 > 0) then
                     oJEntries.Lines.Debit   := Double(TotBis33)
                  else
                     oJEntries.Lines.Credit  := Double(TotBis33) * (-1);

                  if (oTasaFija) then begin
                     if (TotBis33Sys > 0) then
                        oJEntries.Lines.DebitSys  := Double(TotBis33Sys)
                     else
                        oJEntries.Lines.CreditSys := Double(TotBis33Sys) * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (TotBis33 > 0) then
                     oJEntries.Lines.FCDebit   := Double(TotBis33)
                  else
                     oJEntries.Lines.FCCredit  := Double(TotBis33) * (-1);

                  if (oTasaFija) then begin
                     if (Double(TotBis33Sys) > 0) then
                        oJEntries.Lines.Debit   := Double(TotBis33Sys)
                     else
                        oJEntries.Lines.Credit  := Double(TotBis33Sys) * (-1);

                     if (Double(TotBis33) > 0) then
                        oJEntries.Lines.DebitSys   := Double(TotBis33)
                     else
                        oJEntries.Lines.CreditSys  := Double(TotBis33) * (-1);
                  end;
               end;

               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
            end;   
         end;
   
         // Revalorizacion IFRS
         if (GlobalSettings.IFRSNativo) then 
            ActualizarRevalIFRS( vYear, vPeriod, Dia, var oRecordActivos );

         FCmpny.EndTransaction(BoWfTransOpt.wf_Commit);
         oProgBar.Value := 100;
         Result := "";
      except
         on e:exception do begin
            if (FCmpny.InTransaction) then
               FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
            FSBOf.SBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oLog.OutLog(e.Message + ' - ' + e.StackTrace);
            Result := e.Message;
         end;
      end;
   finally
      FSBOf._ReleaseCOMObject(oRecordActivos     );
      FSBOf._ReleaseCOMObject(oRecordActividad   );
      FSBOf._ReleaseCOMObject(oRecordActividadUpd);
   end;
end;
    
method TRealizaProcesoAFS.ReversarCentralizacion(): string;
var
   vyear, vperiod : integer;
   nxYr,  nxPr    : integer;
   IniYr, IniPr   : integer;
   s, s1, w, w1   : string;
   Bis33Fin       : Boolean;
   Des_JoCorAct   : string;
   Des_JoDepAct   : string;
   Des_JoCorDep   : string;
   dia            : integer;

   oParametros          : SAPbobsCOM.GeneralService;
   oParametrosData      : SAPbobsCOM.GeneralData;
   oParametrosParameter : SAPbobsCOM.GeneralDataParams;

   sCuentasCont   : String;
   sOrderCtas     : String;
   sGroupCtas     : String;

   // Para contabilizar Bis33
   lstCtaBis33    : List<String>;
   lstCtaDepAc    : List<String>;
   lstMtoBis33    : List<Double>; 
   lstMtoBis33Sys : List<Double>; 
   lstProfitC1    : List<String>; 
   lstProfitC2    : List<String>; 
   lstProfitC3    : List<String>; 
   lstProfitC4    : List<String>; 
   lstProfitC5    : List<String>; 
   lstProject     : List<String>; 
   TotBis33       : Double;
   TotBis33Sys    : Double;
   i, j, last_i   : Integer;
   U_TasaCnMS_Ope : String; 

   oJEntries           : SAPbobsCOM.JournalEntries;
   oRecordActivos      : SAPbobsCOM.RecordSet;
   oRecordActividad    : SAPbobsCOM.RecordSet;
   oRecordActividadUpd : SAPbobsCOM.RecordSet;

   errMsg              : string;
   Repomo              : boolean;
   oProgBarVal         : integer;
   oProgBarCont        : integer;
   aux_primeravez      : boolean;

   oBool   : boolean;
   oStr1   : string;
   oStr2   : string;
   oSql    : string;
   orst       : SAPbobsCOM.Recordset;
begin
   try
      try
         result := "No terminado";

         oRecordActivos      := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividad    := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordActividadUpd := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

         vyear   := G_Year;
         vperiod := G_Periodo;


         ObtenerNxtYearNxtPeriod(vYear, vPeriod, var nxYr, var nxPr, var IniYr, var IniPr);

         if (not PeriodoAbierto(vyear, vperiod) ) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_Cerrado]);

         // Traer parametros
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code, " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoCorAct) Des_JoCorAct , " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoDepAct) Des_JoDepAct , " +
                     "       (Select TrnsCodDsc from OTRC where TrnsCode = p.U_JoCorDep) Des_JoCorDep   " +
                     " from [@VID_AFPA] p ",
                     'Select "Code", ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoCorAct") "Des_JoCorAct" , ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoDepAct") "Des_JoDepAct" , ' +
                     '       (Select "TrnsCodDsc" from OTRC where "TrnsCode" = p."U_JoCorDep") "Des_JoCorDep"   ' +
                     ' from "@VID_AFPA" p ');
         oRecordActividad.DoQuery(oSql);
         if (oRecordActividad.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros]);
         Des_JoCorAct := System.String(oRecordActividad.Fields.Item('Des_JoCorAct').Value);
         Des_JoDepAct := System.String(oRecordActividad.Fields.Item('Des_JoDepAct').Value);
         Des_JoCorDep := System.String(oRecordActividad.Fields.Item('Des_JoCorDep').Value);
         s            := System.String(oRecordActividad.Fields.Item('Code').Value);

         oParametros := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFPA'));
         oParametrosParameter := SAPbobsCOM.GeneralDataParams(oParametros.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oParametrosParameter.SetProperty('Code', s);
         oParametrosData := oParametros.GetByParams(oParametrosParameter);

         // Actividad
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select code               " +
                     " from [@VID_AFAC]         " +
                     " where ( u_year > {0}  or " +
                     "       ( u_year = {0}  and u_Periodo  > {1} ) ) " +
                     "   and u_year is not null ",
                     'Select "Code"             ' +
                     ' from "@VID_AFAC"         ' +
                     ' where ( "U_Year" > {0}  or ' +
                     '       ( "U_Year" = {0}  and "U_Periodo"  > {1} ) ) ' +
                     '   and "U_Year" is not null ');
         oSql := string.Format(oSql, vyear.ToString, vperiod.ToString);
         oRecordActividad.DoQuery(oSql);
         oRecordActividad.MoveFirst;
         if (not oRecordActividad.Eof) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Per_Post_Actividad]);

         // Reversa actividad contabilizada - Voucher de reversa
         dia := system.Int32( oParametrosData.GetProperty('U_DiaConta') );
         case vperiod of
            2:               dia := Math.Min(dia, 28);
            1,3,5,7,8,10,12: dia := Math.Min(dia, 31);
            4,6,9,11:        dia := Math.Min(dia, 30);
         end;

         Repomo := false;
         if (System.String(oParametrosData.GetProperty('U_Repomo')).Trim = 'Y') then
            Repomo := true;

         w1 := '';
         Bis33Fin := false; 
         if (System.String(oParametrosData.GetProperty('U_Bis33Fin')) = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Flg')) = 'Y') and (not GlobalSettings.IFRSNativo) then
            Bis33Fin := true;
         if (vperiod <> 12) then
            Bis33Fin := false;

         if (Bis33Fin) then begin
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer, " a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, a.u_ctabis33 ",
                                                                      ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", a."U_CtaBis33" '); 
            sOrderCtas   := iif(GlobalSettings.RunningUnderSQLServer, " order by a.U_Project, a.u_ctabis33, a.u_ctagasde ",
                                                                      ' order by a."U_Project", a."U_CtaBis33", a."U_CtaGasDe" ');
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer, " a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, a.u_ctabis33 ",
                                                                      ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", a."U_CtaBis33" '); 

            lstCtaBis33    := new List<String>;
            lstCtaDepAc    := new List<String>;
            lstMtoBis33    := new List<Double>; 
            lstMtoBis33Sys := new List<Double>; 
            lstProfitC1    := new List<String>;
            lstProfitC2    := new List<String>;
            lstProfitC3    := new List<String>;
            lstProfitC4    := new List<String>;
            lstProfitC5    := new List<String>;
            lstProject     := new List<String>;
         end
         else if (GlobalSettings.IFRSNativo) then begin
            w1           := iif(GlobalSettings.RunningUnderSQLServer," and isnull(a.U_ActTipo , 'N') <> 'T' ",
                                                                     ' and ifnull(a."U_ActTipo" , ''N'') <> ''T'' ');
            // no se utilizan u_ctacoraf,  u_ctacorda
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctadepac,  a.u_ctagasde, '' u_ctabis33 ",
                                                                     '  a."U_CtaActFi",  a."U_CtaDepAc",  a."U_CtaGasDe", '''' "U_CtaBis33" ');
            sOrderCtas   := " ";
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctadepac,  a.u_ctagasde ",
                                                                     ' a."U_CtaActFi",  a."U_CtaDepAc",  a."U_CtaGasDe" ');
         end
         else begin
            sCuentasCont := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde, '' u_ctabis33 ",
                                                                     ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe", '''' "U_CtaBis33" ');
            sOrderCtas   := " ";
            sGroupCtas   := iif(GlobalSettings.RunningUnderSQLServer," a.u_ctaactfi,  a.u_ctacoraf,  a.u_ctacorda,  a.u_ctadepac,  a.u_ctagasde ",
                                                                     ' a."U_CtaActFi",  a."U_CtaCorAF",  a."U_CtaCorDA",  a."U_CtaDepAc",  a."U_CtaGasDe" ');
         end;

         // Proceso por grupos de activos
         w := '';
         if (oDSGrupo <> '') then begin
            w := iif(GlobalSettings.RunningUnderSQLServer," and a.U_ItmGrpCd = '{0}' ",
                                                          ' and a."U_ItmGrpCd" = ''{0}'' ');
            w := string.Format(w, oDSGrupo);
         end;

         // tasa de cambio
         U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                               " * CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                               ' * CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ');
         U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                               " / CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                               ' / CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ');
         // la consulta de actividad es por item o por grupos de items
         if (system.String( oParametrosData.GetProperty('U_ActbyLoc') ) = 'N') then begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select count(*) cant " +
                     " from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        " +
                     " where b.u_year     = {0} " +
                     "   and b.u_periodo  = {1} " +
                     w + w1 +
                     "   and b.u_postflag = 'Y' ",
                     'Select count(*) "cant" ' +
                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +
                     ' where b."U_Year"     = {0} ' +
                     '   and b."U_Periodo"  = {1} ' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''Y'' ');
            s := string.Format(s, vyear.ToString, vperiod.ToString);
            oRecordActivos.DoQuery(s);

            oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select a.U_ActCode ref, a.code, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5,  " +
                     sCuentasCont +
                     "      ,b.u_corracti, b.u_corrdepr, b.u_deprecia, b.u_corrdepm, b.u_deprnom, " +
                     "       z.Bis33, " +
                     "       case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end + " +
                     "       case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end residual, " +
   
                     "       b.u_corracti" + U_TasaCnMS_Ope + " u_corractiSys, " +
                     "       b.u_corrdepr" + U_TasaCnMS_Ope + " u_corrdeprSys, " + 
                     "       b.u_deprecia" + U_TasaCnMS_Ope + " u_depreciaSys, " +
                     "       b.u_corrdepm" + U_TasaCnMS_Ope + " u_corrdepmSys, " +
                     "       b.u_deprnom " + U_TasaCnMS_Ope + " u_deprnomSys , " +
                     "       z.Bis33     " + U_TasaCnMS_Ope + "      Bis33Sys, " +
                     '       case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end ' + U_TasaCnMS_Ope + ' + ' +
                     '       case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end' + U_TasaCnMS_Ope + ' residualsys ' +

                     ' from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        ' +

                     '                    inner join (select  code, sum(U_PerDepre) TotPerDepre ' +
                     '                                  from [@vid_afac] ' +
                     "                                 where (U_Year < {0} ) or (u_year = {0} and u_periodo <= {1}) " +
                     '                                 group by code ' +
                     '                                ) Y on a.code = Y.code ' +
   
                     '               left outer join (select code, sum(isnull(U_Bis33,0)) Bis33 ' +
                     '                                  from [@VID_AFSA] sa  ' +
                     '                                  where U_Year = {0}   ' +
                     '                                  group by code        ' +
                     '                                ) Z on a.Code = Z.Code ' +
   
                     ' where b.u_year     = {0}' +
                     '   and b.u_periodo  = {1}' +
                     w + w1 +
                     '   and b.u_postflag = ''Y'' ' +
                     sOrderCtas ,

                     'Select a."U_ActCode" "ref", a."Code", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5", ' +
                     sCuentasCont + ',' +
                     '       b."U_CorrActi", b."U_CorrDepr", b."U_Deprecia", b."U_CorrDepm", b."U_DeprNom", ' +
                     '       z."Bis33", ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end + ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end "residual", ' +
   
                     '       b."U_CorrActi"' + U_TasaCnMS_Ope + ' "U_CorrActiSys", ' +
                     '       b."U_CorrDepr"' + U_TasaCnMS_Ope + ' "U_CorrDeprSys", ' + 
                     '       b."U_Deprecia"' + U_TasaCnMS_Ope + ' "U_DepreciaSys", ' +
                     '       b."U_CorrDepm"' + U_TasaCnMS_Ope + ' "U_CorrDepmSys", ' +
                     '       b."U_DeprNom" ' + U_TasaCnMS_Ope + ' "U_DeprNomSys" , ' +
                     '       z."Bis33"     ' + U_TasaCnMS_Ope + '      "Bis33Sys", ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end ' + U_TasaCnMS_Ope + ' + ' +
                     '       case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end' + U_TasaCnMS_Ope + ' "residualsys" ' +

                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +

                     '                    inner join (Select  "Code", sum("U_PerDepre") "TotPerDepre" ' +
                     '                                  from "@VID_AFAC"         ' +
                     '                                 where ("U_Year" < {0}) or ("U_Year" = {0} and "U_Periodo" <= {1}) ' +
                     '                                 group by "Code"           ' +
                     '                                ) Y on a."Code" = Y."Code" ' +
   
                     '               left outer join (select "Code", sum(ifnull("U_Bis33",0)) "Bis33" ' +
                     '                                  from "@VID_AFSA" sa      ' +
                     '                                  where "U_Year" = {0}     ' +
                     '                                  group by "Code"          ' +
                     '                                ) Z on a."Code" = Z."Code" ' +
   
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''Y'' ' +
                     sOrderCtas );
            s := string.Format(s, vyear.ToString, vperiod.ToString);

            errMsg := 'activo';
         end
         else begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select count(*) cant from ( " +
                     "Select a.U_ItmGrpCd ref,  a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5,      " +
                     sCuentasCont + ',' +
                     "       sum(b.u_corracti) u_corracti, sum(b.u_corrdepr) u_corrdepr, sum(b.u_deprecia) u_deprecia, sum(b.u_corrdepm) u_corrdepm, sum(b.u_deprnom) u_deprnom " +
                     " from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code " +
                     " where b.u_year     = {0}" +
                     "   and b.u_periodo  = {1}" +
                     w + w1 +
                     "   and b.u_postflag = 'Y' " +
                     " group by a.U_ItmGrpCd, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, " + sGroupCtas +
                     ") T0 ",
                     'Select count(*) "cant" from ( ' +
                     'Select a."U_ItmGrpCd" "ref",  a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",      ' +
                     sCuentasCont + ',' +
                     '       sum(b."U_CorrActi") "U_corracti", sum(b."U_CorrDepr") "U_corrdepr", sum(b."U_Deprecia") "U_deprecia", sum(b."U_CorrDepM") "U_corrdepm", sum(b."U_DeprNom") "U_deprnom" ' +
                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code" ' +
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''Y'' ' +
                     ' group by a."U_ItmGrpCd", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5", ' + sGroupCtas +
                     ') T0 ');
            s := string.Format(s, vyear.ToString, vperiod.ToString);
            oRecordActivos.DoQuery(s);
            oProgBarVal := System.Int32(oRecordActivos.Fields.Item('cant').Value);

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select a.U_ItmGrpCd ref, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, " +
                     sCuentasCont +
                     "      ,sum(b.u_corracti) u_corracti, sum(b.u_corrdepr) u_corrdepr, sum(b.u_deprecia) u_deprecia, sum(b.u_corrdepm) u_corrdepm, sum(b.u_deprnom) u_deprnom, " +
                     "       sum(z.Bis33) Bis33, " +
                     "       sum(case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end) + " +
                     "       sum(case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end) residual, " +
   
                     "       sum(b.u_corracti" + U_TasaCnMS_Ope + ") u_corractiSys, " +
                     "       sum(b.u_corrdepr" + U_TasaCnMS_Ope + ") u_corrdeprSys, " + 
                     "       sum(b.u_deprecia" + U_TasaCnMS_Ope + ") u_depreciaSys, " +
                     "       sum(b.u_corrdepm" + U_TasaCnMS_Ope + ") u_corrdepmSys, " +
                     "       sum(b.u_deprnom " + U_TasaCnMS_Ope + ") u_deprnomSys , " +
                     "       sum(z.Bis33     " + U_TasaCnMS_Ope + ")      Bis33Sys, " +
                     '       sum(case when a.u_pervidau - a.u_oriperdp = TotPerDepre and b.u_perdepre = 1 and b.u_pervidut = 0 then a.U_ValResid else 0 end ' + U_TasaCnMS_Ope + ') + ' +
                     '       sum(case when a.u_pervidau - a.u_oriperdp - TotPerDepre + 1 = b.u_pervidut and b.u_pervidut > 1 then -1*a.U_ValResid else 0 end' + U_TasaCnMS_Ope + ') residualsys ' +

                     ' from [@VID_AFAS] a inner join [@vid_afac] b on a.code = b.code        ' +

                     '                    inner join (select  code, sum(U_PerDepre) TotPerDepre ' +
                     '                                  from [@vid_afac] ' +
                     "                                 where (U_Year < {0} ) or (u_year = {0} and u_periodo <= {1}) " +
                     '                                 group by code ' +
                     '                                ) Y on a.code = Y.code ' +
   
                     '               left outer join (select code, sum(isnull(U_Bis33,0)) Bis33 ' +
                     '                                  from [@VID_AFSA] sa  ' +
                     '                                  where U_Year = {0}   ' +
                     '                                  group by code        ' +
                     '                                ) Z on a.Code = Z.Code ' +
   
                     ' where b.u_year     = {0}' +
                     '   and b.u_periodo  = {1}' +
                     w + w1 +
                     '   and b.u_postflag = ''Y'' ' +
                     ' group by a.U_ItmGrpCd, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, ' + sGroupCtas +
                     sOrderCtas ,

                     'Select a."U_ItmGrpCd" "ref", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",  ' +
                     sCuentasCont + ',' +
                     '       sum(b."U_CorrActi") "U_CorrActi", sum(b."U_CorrDepr") "U_CorrDepr", sum(b."U_Deprecia") "U_Deprecia", sum(b."U_CorrDepM") "U_CorrDepm", sum(b."U_DeprNom") "U_DeprNom", ' +
                     '       sum(z."Bis33") "Bis33", ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end) + ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end) "residual", ' +
   
                     '       sum(b."U_CorrActi"' + U_TasaCnMS_Ope + ') "U_CorrActiSys", ' +
                     '       sum(b."U_CorrDepr"' + U_TasaCnMS_Ope + ') "U_CorrDeprSys", ' + 
                     '       sum(b."U_Deprecia"' + U_TasaCnMS_Ope + ') "U_DepreciaSys", ' +
                     '       sum(b."U_CorrDepM"' + U_TasaCnMS_Ope + ') "U_CorrDepmSys", ' +
                     '       sum(b."U_DeprNom" ' + U_TasaCnMS_Ope + ') "U_DeprNomSys" , ' +
                     '       sum(z."Bis33"     ' + U_TasaCnMS_Ope + ')      "Bis33Sys", ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" = "TotPerDepre" and b."U_PerDepre" = 1 and b."U_PerVidUt" = 0 then a."U_ValResid" else 0 end ' + U_TasaCnMS_Ope + ') + ' +
                     '       sum(case when a."U_PerVidaU" - a."U_OriPerDp" - "TotPerDepre" + 1 = b."U_PerVidUt" and b."U_PerVidUt" > 1 then -1*a."U_ValResid" else 0 end' + U_TasaCnMS_Ope + ') "residualsys" ' +

                     ' from "@VID_AFAS" a inner join "@VID_AFAC" b on a."Code" = b."Code"        ' +

                     '                    inner join (Select  "Code", sum("U_PerDepre") "TotPerDepre" ' +
                     '                                  from "@VID_AFAC" ' +
                     '                                 where ("U_Year" < {0}) or ("U_Year" = {0} and "U_Periodo" <= {1}) ' +
                     '                                 group by "Code" ' +
                     '                                ) Y on a."Code" = Y."Code" ' +
   
                     '               left outer join (select "Code", sum(ifnull("U_Bis33",0)) "Bis33" ' +
                     '                                  from "@VID_AFSA" sa      ' +
                     '                                  where "U_Year" = {0}     ' +
                     '                                  group by "Code"          ' +
                     '                                ) Z on a."Code" = Z."Code" ' +
   
                     ' where b."U_Year"     = {0}' +
                     '   and b."U_Periodo"  = {1}' +
                     w + w1 +
                     '   and b."U_PostFlag" = ''Y'' ' +
                     ' group by a."U_ItmGrpCd", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",  ' + sGroupCtas +
                     sOrderCtas );
            s := string.Format(s, vyear.ToString, vperiod.ToString);

            errMsg := 'grupo';
         end;

         oRecordActivos.DoQuery(s);
         oRecordActivos.MoveFirst;

         oProgBarCont := 0;
         while (not oRecordActivos.Eof) do begin
            inc(oProgBarCont);
            var d1 : Double := oProgBarCont*100/oProgBarVal;
            oProgBar.Value := Convert.ToInt32(Math.Round(d1));
            oProgBar.text  := System.String(oRecordActivos.Fields.Item('ref').value);

            if (system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_ActFij] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (not GlobalSettings.IFRSNativo) then begin
               if (system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ) = '') then
                  raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrActFij] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
               if (system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ) = '') then
                  raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrDepr] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            end;
            if (system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_DepAcum] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_GasDep] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));
            if (system.String( oRecordActivos.Fields.Item('u_ctabis33').Value ) = '') and (Bis33Fin) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_Bis33] + errMsg + ': ' + system.String( oRecordActivos.Fields.Item('ref').Value ));

            if (GlobalSettings.IFRSNativo) then begin
                  // depreciacion acumulada contra gastos de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual').Value )  , 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys').Value )  , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
            end;
        
            if (not GlobalSettings.IFRSNativo) then begin
               // activo fijo contra correccion de activos (Repomo)
          
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
          
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                             system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                             system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                             system.String( oParametrosData.GetProperty('U_JoCorAct') ),
                                             Des_JoCorAct );
          
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                              system.Double( oRecordActivos.Fields.Item('u_corracti').Value ), 
                                              system.Double( oRecordActivos.Fields.Item('u_corractiSys').Value ), 
                                              system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                              system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                              system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ),
                                              system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ) );
          
               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
          
               if (not repomo) then begin
                  // depreciacion acumulada contra correccion de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoCorDep') ),
                                                Des_JoCorDep );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepr').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdeprSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end
               else begin
                  // depreciacion acumulada contra correccion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoCorDep') ),
                                                Des_JoCorDep );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepr').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdeprSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacorda').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctacoraf').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end;
          
               if (not repomo) then begin
                  // depreciacion acumulada contra gastos de depreciacion
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepm').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys').Value )  , 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepmSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual').Value )  , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end
               else begin
                  // depreciacion con repomo
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
              
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RAF-',
                                                system.String( oRecordActivos.Fields.Item('ref'       ).Value ),
                                                system.String( oRecordActivos.Fields.Item('U_Project' ).Value ),
                                                system.String( oParametrosData.GetProperty('U_JoDepAct') ),
                                                Des_JoDepAct );
              
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, // esto es no por uso; en este caso la depreciacion no nominal es cero -> ver siguiente ingreso a asiento.
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnom').Value ) , 
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnomSys').Value ) , 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) );
          
                  Utils.ContabilizarEnSBOInsertarValor(var oJEntries, // esto es depreciaicon por uso; en este caso la depreciacion nominal es 0
                                                 system.Double( oRecordActivos.Fields.Item('u_deprecia').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepm').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residual'  ).Value ) -
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnom').Value ), 
                                                 system.Double( oRecordActivos.Fields.Item('u_depreciaSys').Value ) + 
                                                 system.Double( oRecordActivos.Fields.Item('u_corrdepmSys').Value ) - 
                                                 system.Double( oRecordActivos.Fields.Item('residualSys'  ).Value ) -
                                                 system.Double( oRecordActivos.Fields.Item('u_deprnomSys').Value ), 
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ),
                                                 system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctadepac').Value ),
                                                 system.String( oRecordActivos.Fields.Item('u_ctagasde').Value ) );
              
                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
               end;
            end;
  
            if (Bis33Fin) then begin
               // Bis33  contra gastos de depreciacion
               lstCtaBis33.add( system.String( oRecordActivos.Fields.Item('u_ctabis33').Value ));
               // lstCtaDepAc.add( system.String( oRecordActivos.Fields.Item('u_ctadepac').Value )); // SE cambio cuenta DepAcum por ActFijo
               lstCtaDepAc.add( system.String( oRecordActivos.Fields.Item('u_ctaactfi').Value ));
               lstMtoBis33.add( Utils.AjustarDecimalesSUM(system.Double( oRecordActivos.Fields.Item('Bis33').Value )));
               lstMtoBis33Sys.add( Utils.AjustarDecimalesSUM(system.Double( oRecordActivos.Fields.Item('Bis33Sys').Value )));
               lstProfitC1.add( system.String( oRecordActivos.Fields.Item('U_ProfitCt').Value ));
               lstProfitC2.add( system.String( oRecordActivos.Fields.Item('U_ProfitC2').Value ));
               lstProfitC3.add( system.String( oRecordActivos.Fields.Item('U_ProfitC3').Value ));
               lstProfitC4.add( system.String( oRecordActivos.Fields.Item('U_ProfitC4').Value ));
               lstProfitC5.add( system.String( oRecordActivos.Fields.Item('U_ProfitC5').Value ));
               lstProject.add(  system.String( oRecordActivos.Fields.Item('U_Project' ).Value ));
            end;

            // Revalorizacion IFRS
            if (GlobalSettings.IFRSNativo) then begin
               oStr1 := "";
               oStr2 := "";
               if (system.String( oParametrosData.GetProperty('U_ActbyLoc') ) = 'N') then begin
                  oBool := true;
                  oStr1 := System.String(oRecordActivos.Fields.Item('code').value);
               end
               else begin
                  oBool := false;
                  oStr2 := System.String(oRecordActivos.Fields.Item('ref').value);
               end;
               ReversarRevalIFRS( vYear, vPeriod, dia, var oRecordActividadUpd, oStr1, oStr2, oBool);
            end;

            if (system.String( oParametrosData.GetProperty('U_ActbyLoc') ) = 'N') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        "Update [@VID_AFAC] set " +
                        "   U_PostFlag = 'N'    " +
                        " where code = '{0}'    " + 
                        "   and U_Year    = {1} " + 
                        "   and U_Periodo = {2} ",
                        'Update "@VID_AFAC" set  ' +
                        '   "U_PostFlag" = ''N'' ' +
                        ' where "Code" = ''{0}'' ' + 
                        '   and "U_Year"    = {1}' + 
                        '   and "U_Periodo" = {2}');
                s := string.Format(s , System.String(oRecordActivos.Fields.Item('code').value), vyear.ToString, vperiod.ToString);
            end
            else begin
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        'Update [@VID_AFAC] set ' +
                        "   U_PostFlag = 'N'    " +
                        " where code in (select code from [@vid_afas] where u_ItmGrpCd = '{0}' " +
                        '   and U_Year    = {1} ' +
                        '   and U_Periodo = {2}) ', 
                        'Update "@VID_AFAC" set  ' +
                        '   "U_PostFlag" = ''N'' ' +
                        ' where "Code" in (select "Code" from "@VID_AFAS" where "U_ItmGrpCd" = ''{0}'' ' +
                        '   and "U_Year"    = {1} ' +
                        '   and "U_Periodo" = {2}) ');
                s := string.Format(s , System.String(oRecordActivos.Fields.Item('ref').value), vyear.ToString, vperiod.ToString);
            end;

            oRecordActividadUpd.DoQuery(s);

            oRecordActivos.MoveNext;
         end;

         if (Bis33Fin) then begin        
            aux_primeravez := true;
            s  := nil;
            s1 := '';

            for i:=0 to lstMtoBis33.count-1 do begin
               if (Double(lstMtoBis33[i]) = 0) then
                  continue;

               if (aux_primeravez) then begin
                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RB33-', 'Bis33 - Reversa', String(lstProject[i]).Trim, '', 'Bis33 - Reversa' );
                  aux_primeravez := false;
               end;

               if (s1 <> String(lstCtaBis33[i]).Trim) or (s <> String(lstProject[i]).Trim) then begin
                  if (s1 <> '') then begin
                     //ingresar cuenta bis33 a voucher
                     if (oJEntries.Lines.Count = 1) then begin
                        oJEntries.Lines.SetCurrentLine(0);
                        if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                           oJEntries.Lines.Add;
                     end
                     else 
                        oJEntries.Lines.Add;
                     j := oJEntries.Lines.Count-1;

                     oJEntries.Lines.SetCurrentLine(j);
                     oJEntries.Lines.AccountCode := String(lstCtaBis33[last_i]);
                     oJEntries.Lines.ProjectCode := String(lstProject[last_i]);
                     s := iif(GlobalSettings.RunningUnderSQLServer, 
                    "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                    'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                    s := String.Format(s, String(lstCtaBis33[last_i])); 
                    orst.DoQuery(s);
                    s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                    if (s = 'I') or (s = 'E') then
                    begin
                        oJEntries.Lines.CostingCode  := String(lstProfitC1[last_i]);
                        oJEntries.Lines.CostingCode2 := String(lstProfitC2[last_i]);
                        oJEntries.Lines.CostingCode3 := String(lstProfitC3[last_i]);
                        oJEntries.Lines.CostingCode4 := String(lstProfitC4[last_i]);
                        oJEntries.Lines.CostingCode5 := String(lstProfitC5[last_i]);
                     end;

                     if (not oPostSysCu) then begin
                        if (TotBis33 > 0) then
                           oJEntries.Lines.Credit := Double(TotBis33)
                        else
                           oJEntries.Lines.Debit  := Double(TotBis33) * (-1);

                        if (oTasaFija) then begin
                           if (TotBis33Sys > 0) then
                              oJEntries.Lines.CreditSys := Double(TotBis33Sys)
                           else
                              oJEntries.Lines.DebitSys  := Double(TotBis33Sys) * (-1);
                        end
                     end
                     else begin
                        oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                        if (TotBis33 > 0) then
                           oJEntries.Lines.FCCredit := Double(TotBis33)
                        else
                           oJEntries.Lines.FCDebit  := Double(TotBis33) * (-1);

                        if (oTasaFija) then begin
                           if (TotBis33Sys > 0) then
                              oJEntries.Lines.Credit := TotBis33Sys
                           else
                              oJEntries.Lines.DEbit  := TotBis33Sys * (-1);

                           if (TotBis33 > 0) then
                              oJEntries.Lines.CreditSys   := TotBis33
                           else
                              oJEntries.Lines.DebitSys  := TotBis33 * (-1);
                        end;
                     end;
                  end;

                  Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);

                  TotBis33    := 0;
                  TotBis33Sys := 0;
                  s1 := String(lstCtaBis33[i]).Trim;
                  s  := String(lstProject[i]).Trim;

                  oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
                  Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, vYear, vPeriod, dia, 'RB33-', 'Bis33 - Reversa', String(lstProject[i]).Trim, '', 'Bis33 - Reversa' );
               end;

               TotBis33    := TotBis33    + Double(lstMtoBis33[i]);
               TotBis33Sys := TotBis33Sys + Double(lstMtoBis33Sys[i]);
               last_i   := i;

               // ingresar a cuenta depac
               if (oJEntries.Lines.Count = 1) then begin
                  oJEntries.Lines.SetCurrentLine(0);
                  if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                     oJEntries.Lines.Add;
               end
               else 
                  oJEntries.Lines.Add;
               j := oJEntries.Lines.Count-1;

               oJEntries.Lines.SetCurrentLine(j);
               oJEntries.Lines.AccountCode := String(lstCtaDepAc[i]);
               oJEntries.Lines.ProjectCode := String(lstProject[i]);
               s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
               s := String.Format(s, String(lstCtaDepAc[i])); 
               orst.DoQuery(s);
               s := System.String(orst.Fields.Item('ActType').value).Trim();
   
               if (s = 'I') or (s = 'E') then
               begin
                  oJEntries.Lines.CostingCode  := String(lstProfitC1[i]);
                  oJEntries.Lines.CostingCode2 := String(lstProfitC2[i]);
                  oJEntries.Lines.CostingCode3 := String(lstProfitC3[i]);
                  oJEntries.Lines.CostingCode4 := String(lstProfitC4[i]);
                  oJEntries.Lines.CostingCode5 := String(lstProfitC5[i]);
               end;
     
               if (not oPostSysCu) then begin
                  if (Double(lstMtoBis33[i]) > 0) then
                     oJEntries.Lines.Debit   := Double(lstMtoBis33[i])
                  else
                     oJEntries.Lines.Credit    := Double(lstMtoBis33[i]) * (-1);

                  if (oTasaFija) then begin
                     if (Double(lstMtoBis33Sys[i]) > 0) then
                        oJEntries.Lines.DebitSys := Double(lstMtoBis33Sys[i])
                     else
                        oJEntries.Lines.CreditSys  := Double(lstMtoBis33Sys[i]) * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (Double(lstMtoBis33[i]) > 0) then
                     oJEntries.Lines.FCDebit   := Double(lstMtoBis33[i])
                  else
                     oJEntries.Lines.FCCredit  := Double(lstMtoBis33[i]) * (-1);

                  if (oTasaFija) then begin
                     if (Double(lstMtoBis33Sys[i]) > 0) then
                        oJEntries.Lines.Debit   := Double(lstMtoBis33Sys[i])
                     else
                        oJEntries.Lines.Credit  := Double(lstMtoBis33Sys[i]) * (-1);

                     if (Double(lstMtoBis33[i]) > 0) then
                        oJEntries.Lines.DebitSys   := Double(lstMtoBis33[i])
                     else
                        oJEntries.Lines.CreditSys  := Double(lstMtoBis33[i]) * (-1);
                  end;
               end;
            end;

            if (s1 <> '') then begin
               //ingresar cuenta bis33 a voucher
               if (oJEntries.Lines.Count = 1) then begin
                  oJEntries.Lines.SetCurrentLine(0);
                  if (oJEntries.Lines.AccountCode.Trim <> '') and (oJEntries.Lines.AccountCode <> nil) then
                     oJEntries.Lines.Add;
               end
               else 
                  oJEntries.Lines.Add;
               j := oJEntries.Lines.Count-1;

               oJEntries.Lines.SetCurrentLine(j);
               oJEntries.Lines.AccountCode := String(lstCtaBis33[last_i]);
               oJEntries.Lines.ProjectCode := String(lstProject[last_i]);
               oJEntries.Lines.CostingCode  := String(lstProfitC1[last_i]);
               s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
               s := String.Format(s, String(lstCtaBis33[last_i])); 
               orst.DoQuery(s);
               s := System.String(orst.Fields.Item('ActType').value).Trim();
   
               if (s = 'I') or (s = 'E') then
               begin
                  oJEntries.Lines.CostingCode2 := String(lstProfitC2[last_i]);
                  oJEntries.Lines.CostingCode3 := String(lstProfitC3[last_i]);
                  oJEntries.Lines.CostingCode4 := String(lstProfitC4[last_i]);
                  oJEntries.Lines.CostingCode5 := String(lstProfitC5[last_i]);
               end;

               if (not oPostSysCu) then begin
                  if (TotBis33 > 0) then
                     oJEntries.Lines.Credit   := Double(TotBis33)
                  else
                     oJEntries.Lines.Debit  := Double(TotBis33) * (-1);
                  
                  if (oTasaFija) then begin
                     if (TotBis33Sys > 0) then
                        oJEntries.Lines.CreditSys := Double(TotBis33Sys)
                     else
                        oJEntries.Lines.DebitSys  := Double(TotBis33Sys) * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (TotBis33 > 0) then
                     oJEntries.Lines.FCCredit   := Double(TotBis33)
                  else
                     oJEntries.Lines.FCDebit  := Double(TotBis33) * (-1);

                  if (oTasaFija) then begin
                     if (Double(TotBis33Sys) > 0) then
                        oJEntries.Lines.Credit   := Double(TotBis33Sys)
                     else
                        oJEntries.Lines.Debit  := Double(TotBis33Sys) * (-1);

                     if (Double(TotBis33) > 0) then
                        oJEntries.Lines.CreditSys   := Double(TotBis33)
                     else
                        oJEntries.Lines.DebitSys  := Double(TotBis33) * (-1);
                  end;
               end;
            end;

            if (s <> nil) then 
               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
         end;
      
         oProgBar.Value := 100;
         result := "";
      except
         on e:exception do begin
            if (FCmpny.InTransaction) then
               FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
            FSBOf.SBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oLog.OutLog(e.Message + ' - ' + e.StackTrace);
            Result := e.Message;
         end;
      end;
   finally
      FSBOf._ReleaseCOMObject(oRecordActivos     );
      FSBOf._ReleaseCOMObject(oRecordActividad   );
      FSBOf._ReleaseCOMObject(oRecordActividadUpd);
   end;
end;
                       

method TRealizaProcesoAFS.ProcesoFinanciero(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; Indices: TIndice; nxYr, nxPr: integer; var TopeLey33Bis: Double);
var
   indiceOri    : double;
   FactorIpc    : double;
   FactorBis33  : double;
   Corrige_Flag : boolean;
   Bis33_flag   : boolean;

   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;

   ActYear           : array [0..12] of TActividaMensual;
   LstActivoAdicion  : List<TActivoAdicion>;
   ActivoAdicion     : TActivoAdicion;
   i, j              : integer;

   U_NextYear : integer;
   U_NextPer  : integer;
   U_NxYrDepr : integer;
   U_NxPrDepr : integer;
   U_NxYrCorr : integer;
   U_NxPrCorr : integer;
   U_InitYear : integer;
   U_InitPer  : integer;
   U_Bis33Fin : double;
   U_Orifec   : DateTime;
   U_PorResid : double;

   U_OriValCo : double;
   U_OriDepre : Double;
   U_CurVal   : double;
   U_DepAcum  : double;
   U_DepAcumN : double;
   U_CorAnuAc : double;
   U_CorAnuDe : double;
   U_DepreAnu : double;
   U_PerDepre : integer;
   U_PerDepYr : integer;
   U_PerVidaU : integer;
   U_AdicAnuC : double;

   VALOR_RESIDUAL      : double;
   ADICIONES_TOTALES   : double;
   ADICIONES_ANUALES   : double;

   ACT_VALOR_NOMINAL   : double;
   ACT_VALOR_CORREGIDO : double;
   ACT_DEPRE_CORREGIDA : double;
   DEPREC_NOMINAL      : double;
   DEPREC_ANUAL_TOTAL  : double;
   DEPREC_PERIODO      : double;
   DEPREC_ANUAL_NOM    : double;
   PERIODOS_DEPREC     : integer;
   VIDA_UTIL           : integer;
   UNID_DEPREC         : Integer;

   USO_VIDA_UTIL_NEW   : Integer := 0;
   USO_VIDA_UTIL_OLD   : Integer := 0;

   Bis33Dct_Flag        : boolean;
   NvoValActivo         : double;
   CorrActi             : double;
   CorrDepr             : double;
   CorrDeprM            : double;
   PerDep               : integer;
   Deprecia_Flag        : boolean;
   inicioActiv          : integer;

   Ley33Bis           : double;
   s:                 string;
   nxYrIns, nxPrIns:  integer;
begin
   try
      LstActivoAdicion := New List<TActivoAdicion>;
            // valores actuales del activo
        
            U_NextYear := System.Int32(oActivosData.GetProperty('U_NextYear'));
            U_NextPer  := System.Int32(oActivosData.GetProperty('U_NextPer' ));
            U_NxYrDepr := System.Int32(oActivosData.GetProperty('U_NxYrDepr'));
            U_NxPrDepr := System.Int32(oActivosData.GetProperty('U_NxPrDepr'));
            U_InitYear := System.Int32(oActivosData.GetProperty('U_InitYear'));
            U_InitPer  := System.Int32(oActivosData.GetProperty('U_InitPer' ));
            U_Bis33Fin := System.Double(oActivosData.GetProperty('U_Bis33Fin'));
            U_OriFec   := System.DateTime(oActivosData.GetProperty('U_OriFec'));
            U_PorResid := 1-System.Double(oActivosData.GetProperty('U_PorResid'))/100;

            U_NxYrCorr := System.Int32(oActivosData.GetProperty('U_NxYrCorr'));
            U_NxPrCorr := System.Int32(oActivosData.GetProperty('U_NxPrCorr'));
                
            U_OriValCo := System.Double(oActivosData.GetProperty('U_OriValCo'));    //  ANT_VALOR_ORIGINAL
            U_OriDepre := System.Double(oActivosData.GetProperty('U_OriDepre'));    //  ANT_DEPRECIACION_ORIGINAL
            U_CurVal   := System.Double(oActivosData.GetProperty('U_CurVal'  ));    //  ANT_VALOR_ACTUAL
            U_DepAcum  := System.Double(oActivosData.GetProperty('U_DepAcum' ));    //  ANT_DEPRACUMULADA
            U_DepAcumN := System.Double(oActivosData.GetProperty('U_DepAcumN'));    //
            U_CorAnuAc := System.Double(oActivosData.GetProperty('U_CorAnuAc'));    //  ANT_CORRANUALACTIVO
            U_CorAnuDe := System.Double(oActivosData.GetProperty('U_CorAnuDe'));    //  ANT_CORRANUALDEPR
            U_DepreAnu := System.Double(oActivosData.GetProperty('U_DepreAnu'));    //  ANT_DEPRANUAL
            U_PerDepre := System.Int32(oActivosData.GetProperty ('U_PerDepre'));    //  ANT_PERDEPRECIADOS
            U_PerDepYr := System.Int32(oActivosData.GetProperty ('U_PerDepYr'));    //  ANT_PERDEPRECYEAR
            U_PerVidaU := System.Int32(oActivosData.GetProperty ('U_PerVidaU'));    //  ANT_VIDAUTIL
            U_AdicAnuC := System.double(oActivosData.GetProperty('U_AdicAnuC'));    //  ANT_ADIC_ANUCORR
                       
            Bis33Dct_Flag := false;
            if (System.String(oParametrosData.GetProperty('U_Bis33Dct')) = 'Y') then 
               Bis33Dct_Flag := true;

            // Actualiza VID_AFAS
            if (nxPr = 1) then begin
//        Se cambio y se descuenta del valor del activo el bis33
//               U_CurVal   := U_CurVal  + U_CorAnuAc + U_AdicAnuC - U_Bis33Fin; 
//               U_DepAcum  := U_DepAcum + U_CorAnuDe + U_DepreAnu;              
               if (Bis33Dct_Flag) then begin
                  U_CurVal   := U_CurVal  + U_CorAnuAc + U_AdicAnuC - U_Bis33Fin;
                  U_DepAcum  := U_DepAcum + U_CorAnuDe + U_DepreAnu;
               end
               else begin
                  U_CurVal   := U_CurVal  + U_CorAnuAc + U_AdicAnuC;
                  U_DepAcum  := U_DepAcum + U_CorAnuDe + U_DepreAnu + U_Bis33Fin;
               end;
               U_CorAnuAc := 0;
               U_DepreAnu := 0;
               U_AdicAnuC := 0;
               U_CorAnuDe := 0;
               U_PerDepYr := 0;
        
               oActivosData.SetProperty('U_CurVal'  , U_CurVal   );
               oActivosData.SetProperty('U_DepAcum' , U_DepAcum  );
               oActivosData.SetProperty('U_CorAnuAc', U_CorAnuAc );
               oActivosData.SetProperty('U_DepreAnu', U_DepreAnu );
               oActivosData.SetProperty('U_AdicAnuC', U_AdicAnuC );
               oActivosData.SetProperty('U_CorAnuDe', U_CorAnuDe );
               oActivosData.SetProperty('U_PerDepYr', U_PerDepYr );
            end;
        
            //... Finanaciera ... llenar actividad anual
            for j:=0 to 12 do begin
               ActYear[j] := new TActividaMensual;
               if (j=0) then begin
                  ActYear[j].Year      := nxYr-1;
                  ActYear[j].Per       := 12;
               end
               else begin
                  ActYear[j].Year      := nxYr;
                  ActYear[j].Per       := j;
               end;
               ActYear[j].CorrAct   := 0;
               ActYear[j].CorrDep   := 0;
               ActYear[j].DeprMes   := 0;
               ActYear[j].DeprNoAct := 0;
               ActYear[j].CorDepM   := 0;
               ActYear[j].AdicVal   := 0;
               ActYear[j].AdicVid   := 0;
               ActYear[j].PerDepre  := 0;
            end;
        
            if (U_InitYear <> nxYr) then
               inicioActiv := 0
            else
               inicioActiv := U_InitPer;
                
            // insertar adiciones de la misma fecha de ingreso del activo
            //... Marcar ... VID_AFAD para el periodo como procesado
            ADICIONES_TOTALES := 0;
            ADICIONES_ANUALES := 0;

            oActivosLines     := oActivosData.Child('VID_AFAD');
            for i:=0 to oActivosLines.Count - 1 do begin
               oActivosLinesData := oActivosLines.Item(i);
               if (System.String(oActivosLinesData.GetProperty('U_Procesad')) = 'Y') then begin
                  ADICIONES_TOTALES := ADICIONES_TOTALES + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  if (System.Int32(oActivosLinesData.GetProperty('U_Year')) = nxYr) then
                     ADICIONES_ANUALES := ADICIONES_ANUALES + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
               end;

               if (System.Int32(oActivosLinesData.GetProperty('U_Year')) <> nxYr) or (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) <> nxPr) then
                  Continue
               else begin
                  s := 'Y';
                  oActivosLinesData.SetProperty('U_Procesad', s);
                  ADICIONES_TOTALES := ADICIONES_TOTALES + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  ADICIONES_ANUALES := ADICIONES_ANUALES + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
        
                  ActYear[nxPr].AdicVal  := ActYear[nxPr].AdicVal + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  if (System.String(oParametrosData.GetProperty('U_AdicVdUt')).Trim = 'Y') then
                     ActYear[nxPr].AdicVid  := ActYear[nxPr].AdicVid + System.Int32(oActivosLinesData.GetProperty('U_PerVidUt'));
               end;
            end;
        
            // Determinar si debe depreciarse o solo corregirse
        
            Deprecia_Flag  := False;
            Corrige_Flag   := False;
            if (System.String(oActivosData.GetProperty('U_ConDepre')) = 'Y') and ((nxYr > U_NxYrDepr) or ((nxYr = U_NxYrDepr) and (nxPr >= U_NxPrDepr))) then 
               Deprecia_Flag  := true;
            if (System.String(oActivosData.GetProperty('U_ConCorre')) = 'Y') and ((nxYr > U_NxYrCorr) or ((nxYr = U_NxYrCorr) and (nxPr >= U_NxPrCorr))) then 
               Corrige_Flag  := true;
        
            // Financiero
        
            UNID_DEPREC := 1;
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ISNULL(d.U_Uso,0) Uso, ISNULL(U_ActCode, '') ActCode, ISNULL(U_GrpCode, '') GrpCode, ISNULL(d.U_SVidaAct,0) SVidaAct, " +
                        "       ISNULL(d.U_SVidaNew,0) SVidaNew, ISNULL(d.U_RVidaAct,0) RVidaAct, ISNULL(d.U_RVidaNew,0) RVidaNew " +
                        "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                        " where h.U_Year    = {0} " + 
                        "   and h.U_Periodo = {1} " + 
                        "   and (d.U_ActCode = '{2}'  or d.U_GrpCode = '{3}' )" + 
                        " order by 3",
                        'Select IFNULL(d."U_Uso",0) "Uso", IFNULL("U_ActCode", '') "ActCode", IFNULL("U_GrpCode", '') "GrpCode", IFNULL(d."U_SVidaAct",0) "SVidaAct", ' +
                        '       IFNULL(d."U_SVidaNew",0) "SVidaNew", IFNULL(d."U_RVidaAct",0) "RVidaAct", IFNULL(d."U_RVidaNew",0) "RVidaNew" ' +
                        '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                        ' where h."U_Year"    = {0} ' + 
                        '   and h."U_Periodo" = {1} ' + 
                        '   and (d."U_ActCode" = ''{2}''  or d."U_GrpCode" = ''{3}'' )' + 
                        ' order by 3');
               s := string.Format(s, nxYr.ToString, nxPr.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
                oRecordActividad.DoQuery(s);
                if (not oRecordActividad.EoF) then begin
                   UNID_DEPREC := System.Int32(oRecordActividad.Fields.Item('Uso').Value);
                   s := System.String(oRecordActividad.Fields.Item('GrpCode').Value);
                   if (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then
                      if (System.Int32(oRecordActividad.Fields.Item('SVidaNew').Value) <> System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value)) then begin
                         USO_VIDA_UTIL_NEW := System.Int32(oRecordActividad.Fields.Item('SVidaNew').Value);
                         USO_VIDA_UTIL_OLD := System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value);
                         ActYear[nxPr].AdicVid  := 0;
                         if (System.String(oRecordActividad.Fields.Item('GrpCode').Value) <> '') then begin
                            oGruposData.SetProperty('U_VidaUtil', USO_VIDA_UTIL_NEW);
                         end;
                      end;
                end;
             end;

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select U_Year, U_Periodo, U_CorrActi, U_CorrDepr, U_Deprecia, U_CorrDepM, U_Adicion, U_DeprNom, U_PerVidUt, U_PerDepre " + // incorpora uso mensual, se corrige y se divide por uso sumado anual
                     "  from [@VID_AFAC]    " +
                     " where Code   = '{0}' " + 
                     "   and U_Year =  {1}  " +
                     " order by U_Periodo   ",
                     'Select "U_Year", "U_Periodo", "U_CorrActi", "U_CorrDepr", "U_Deprecia", "U_CorrDepM", "U_Adicion", "U_DeprNom", "U_PerVidUt", "U_PerDepre" ' + // incorpora uso mensual, se corrige y se divide por uso sumado anual
                     '  from "@VID_AFAC"        ' +
                     ' where "Code"   = ''{0}'' ' +
                     '   and "U_Year" =   {1}   ' +
                     ' order by "U_Periodo"     ');
            s := string.Format(s, System.String(oActivosData.GetProperty('Code')), nxYr.ToString);
            oRecordActividad.DoQuery(s);
        
            LstActivoAdicion.Clear;        
            ActivoAdicion := new TActivoAdicion;
            InitActivoAdicion(var ActivoAdicion);
            LstActivoAdicion.Add(ActivoAdicion);
        
            ActivoAdicion.PeriodoInicial       := inicioActiv;
            if (inicioActiv = 0) then begin
               ActivoAdicion.ValorInicialActivo   := U_CurVal;
               ActivoAdicion.ValorInicialDeprec   := U_DepAcum;
               ActivoAdicion.ValorCorregidoActivo := U_CurVal;
               ActivoAdicion.ValorCorregidoDeprec := U_DepAcum;
            end
            else begin
               ActivoAdicion.ValorInicialActivo   := U_CurVal + ActYear[inicioActiv].AdicVal;
               ActivoAdicion.ValorInicialDeprec   := U_DepAcum;
               ActivoAdicion.ValorCorregidoActivo := U_CurVal + ActYear[inicioActiv].AdicVal;
               ActivoAdicion.ValorCorregidoDeprec := U_DepAcum;
            end;
        
            // Solo activos con actvidad mensual
            i := System.Int32 (oRecordActividad.Fields.Item('U_Periodo' ).value);
            while (not oRecordActividad.EoF)  do begin
               ActYear[i].Year      := nxYr;
               ActYear[i].Per       := System.Int32 (oRecordActividad.Fields.Item('U_Periodo' ).value);
               ActYear[i].CorrAct   := System.Double(oRecordActividad.Fields.Item('U_CorrActi').value);
               ActYear[i].CorrDep   := System.Double(oRecordActividad.Fields.Item('U_CorrDepr').value);
               ActYear[i].DeprMes   := System.Double(oRecordActividad.Fields.Item('U_Deprecia').value);
               ActYear[i].DeprNoAct := System.Double(oRecordActividad.Fields.Item('U_DeprNom' ).value);
               ActYear[i].CorDepM   := System.Double(oRecordActividad.Fields.Item('U_CorrDepM').value);
               ActYear[i].AdicVal   := System.Double(oRecordActividad.Fields.Item('U_Adicion' ).value);
               ActYear[i].AdicVid   := System.Int32(oRecordActividad.Fields.Item('U_PerVidUt').value);
               ActYear[i].PerDepre  := System.Int32(oRecordActividad.Fields.Item('U_PerDepre').value);
        
               if (ActYear[i].AdicVal > 0) then begin
                  if (i = inicioActiv) then
                     ActivoAdicion.ValorInicialActivo := U_CurVal  + ActYear[i].AdicVal
                  else begin
                     ActivoAdicion := new TActivoAdicion;
                     InitActivoAdicion(var ActivoAdicion);
                     LstActivoAdicion.Add(ActivoAdicion);
        
                     ActivoAdicion.PeriodoInicial := i;
                     ActivoAdicion.ValorInicialActivo   := ActYear[i].AdicVal;
                  end;
               end;
        
               inc(i);
               oRecordActividad.MoveNext;
            end;
            if (ActYear[nxPr].AdicVal > 0) and (nxPr <> inicioActiv) then begin
               ActivoAdicion := new TActivoAdicion;
               InitActivoAdicion(var ActivoAdicion);
               LstActivoAdicion.Add(ActivoAdicion);
        
               ActivoAdicion.PeriodoInicial := nxPr;
               ActivoAdicion.ValorInicialActivo   := ActYear[nxPr].AdicVal;
            end;
                
            // Primero se corrige luego se deprecia, para cada adicion y valor inicial del activo
            // al existir  AdicVid, se aumenta la vida util y en es periodo se produce un quiebre.
            // Las depreciaciones anteriores se calculan hasta el periodo de quiebre (n) y se corrigen para llevar al periodos futuros (equivale depacum anual)
            // Las correcciones de los activos se llevan al periodo de quiebre
            // ActYear[i].PerDepre -> indica la catidad de periodos depreciados entre quiebres
            // ActYear[i].Periodos -> indica la catidad de periodos por corregis entre quiebres
        
            // Calculos de valores de adiciones
            VIDA_UTIL       := System.int32(oActivosData.GetProperty('U_VidaUtil'));
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               if (USO_VIDA_UTIL_NEW <> 0) then 
                  VIDA_UTIL := USO_VIDA_UTIL_NEW;
            end;
            if (UNID_DEPREC > VIDA_UTIL) then
               UNID_DEPREC := VIDA_UTIL;
            PERIODOS_DEPREC := UNID_DEPREC;

            j := LstActivoAdicion.Count-1;
            ActivoAdicion := TActivoAdicion(LstActivoAdicion[j]);
            for i:=nxPr downto inicioActiv do begin
               if (ActYear[i].AdicVid > 0) and (i = nxPr) then begin   
                  ActivoAdicion.VidaUtil   := VIDA_UTIL + ActYear[i].AdicVid;
                  ActivoAdicion.AdicVida   := ActYear[i].AdicVid;
                  if (Deprecia_Flag) then
                     ActivoAdicion.PeriodosDerpreciados := PERIODOS_DEPREC
                  else
                     ActivoAdicion.PeriodosDerpreciados := 0;

                  PERIODOS_DEPREC := 0;
                  VIDA_UTIL       := System.int32(oActivosData.GetProperty('U_VidaUtil'));

                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicion[j]);
                  end;
               end
               else if (ActYear[i].AdicVid > 0) and (i <> nxPr) and (i > inicioActiv) then begin
                  PERIODOS_DEPREC := PERIODOS_DEPREC + ActYear[i].PerDepre;
                  VIDA_UTIL       := VIDA_UTIL       + ActYear[i].PerDepre;

                  ActivoAdicion.VidaUtil             := VIDA_UTIL;
                  ActivoAdicion.PeriodosDerpreciados := PERIODOS_DEPREC;
                  ActivoAdicion.AdicVida             := ActYear[i].AdicVid;

                  PERIODOS_DEPREC := 0;
                  VIDA_UTIL       := VIDA_UTIL - ActYear[i].AdicVid;
                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicion[j]);
                  end;
               end
               else if (i = ActivoAdicion.PeriodoInicial) then begin
                  if (i <> nxPr) then begin
                     PERIODOS_DEPREC := PERIODOS_DEPREC + ActYear[i].PerDepre;
                     VIDA_UTIL       := VIDA_UTIL       + ActYear[i].PerDepre;
                  end;

                  ActivoAdicion.VidaUtil             := VIDA_UTIL;
                  ActivoAdicion.PeriodosDerpreciados := PERIODOS_DEPREC;
                  ActivoAdicion.AdicVida             := ActYear[i].AdicVid;

                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicion[j]);
                  end;
               end
               else if (ActYear[i].DeprMes > 0) then begin
                  if (i <> nxPr) then begin
                     PERIODOS_DEPREC := PERIODOS_DEPREC + ActYear[i].PerDepre;
                     VIDA_UTIL       := VIDA_UTIL       + ActYear[i].PerDepre;
                  end;
               end;
            end;
        
// DEBUG
if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
   oLog.OutLog(' ');
   oLog.OutLog(' ');
   for i:=0 to LstActivoAdicion.Count-1 do begin
      ActivoAdicion := TActivoAdicion(LstActivoAdicion[i]);
      oLog.OutLog('i : ' + i.ToString);
      oLog.OutLog('VidaUtil             : ' + ActivoAdicion.VidaUtil.ToString);
      oLog.OutLog('PeriodosDerpreciados : ' + ActivoAdicion.PeriodosDerpreciados.ToString);
      oLog.OutLog('AdicVida             : ' + ActivoAdicion.AdicVida.ToString);
   end;
end;

            // Factor periodo inicial
            if (nxYr = U_InitYear) then
               indiceOri := Indices[U_InitPer]
            else begin
               indiceOri := Indices[0]; //indice año anterior
               if (indiceOri = 0) then
                  raise new exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Indices_no_definidos] + nxYr.ToString + '/' + nxPr.ToString)
            end;
        
            ACT_VALOR_NOMINAL   := ADICIONES_TOTALES + U_OriValCo - U_OriDepre;
            DEPREC_ANUAL_NOM    := 0;
            DEPREC_PERIODO      := 0;
            DEPREC_NOMINAL      := 0;
            ACT_VALOR_CORREGIDO := 0;
            ACT_DEPRE_CORREGIDA := 0;
            DEPREC_ANUAL_TOTAL  := 0;
        
            for i:=inicioActiv to nxPr do begin
               DEPREC_ANUAL_NOM := DEPREC_ANUAL_NOM + ActYear[i].DeprMes + ActYear[i].CorDepM;
            end;
        
            for i:=0 to LstActivoAdicion.Count-1 do begin
               ActivoAdicion := TActivoAdicion(LstActivoAdicion[i]);
        
               FactorIpc := Utils.AjustarDecimales(indices[nxPr] / indices[ActivoAdicion.PeriodoInicial]);
               if (FactorIpc < 1) and (System.String(oParametrosData.GetProperty('U_CorPosit')).Trim = 'Y') then // and (nxPr = 12)
                  FactorIpc := 1;
        
               if (i = 0) then begin
                  ActivoAdicion.ValorCorregidoDeprec := ActivoAdicion.ValorInicialDeprec * FactorIpc;
                  ACT_DEPRE_CORREGIDA                := ActivoAdicion.ValorCorregidoDeprec
               end;
        
               ActivoAdicion.ValorCorregidoActivo  := ActivoAdicion.ValorInicialActivo * FactorIpc;
               ACT_VALOR_CORREGIDO                 := ACT_VALOR_CORREGIDO + ActivoAdicion.ValorCorregidoActivo;

               // deprecia hasta adicion de vida util (de acuerdo a ingreso de adiciones de vida
   { el periodo 0, aparecn perdiodos depreciados = 2, debiese ser 1
     se debe restar al total o sumar revisar calculo
   }
               if (ActivoAdicion.VidaUtil > 0) then begin //IO

if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
      oLog.OutLog('i : ' + i.ToString);
      oLog.OutLog('VidaUtil             : ' + ActivoAdicion.VidaUtil.ToString);
      oLog.OutLog('PeriodosDerpreciados : ' + ActivoAdicion.PeriodosDerpreciados.ToString);
      oLog.OutLog('ValorCorregidoActivo : ' + ActivoAdicion.ValorCorregidoActivo.ToString);
      oLog.OutLog('ValorCorregidoDeprec : ' + ActivoAdicion.ValorCorregidoDeprec.ToString);

      oLog.OutLog('');
      oLog.OutLog('ActivoAdicion');
      oLog.OutLog('ActivoAdicion AdicVida  ' + ActivoAdicion.AdicVida);
      oLog.OutLog('ActivoAdicion PeriodoInicial  ' + ActivoAdicion.PeriodoInicial);
      oLog.OutLog('ActivoAdicion PeriodosDerpreciados  ' + ActivoAdicion.PeriodosDerpreciados);
      oLog.OutLog('ActivoAdicion ValorCorregidoActivo  ' + ActivoAdicion.ValorCorregidoActivo);
      oLog.OutLog('ActivoAdicion ValorCorregidoDeprec  ' + ActivoAdicion.ValorCorregidoDeprec);
      oLog.OutLog('ActivoAdicion ValorInicialActivo  ' + ActivoAdicion.ValorInicialActivo);
      oLog.OutLog('ActivoAdicion ValorInicialDeprec  ' + ActivoAdicion.ValorInicialDeprec);
      oLog.OutLog('ActivoAdicion VidaUtil  ' + ActivoAdicion.VidaUtil);
      oLog.OutLog('');
end;

                  if (ActivoAdicion.AdicVida > 0) then begin
                     DEPREC_PERIODO     := (ACT_VALOR_CORREGIDO * U_PorResid - ACT_DEPRE_CORREGIDA - DEPREC_ANUAL_TOTAL) * UNID_DEPREC/ ActivoAdicion.VidaUtil;
                     DEPREC_ANUAL_TOTAL := DEPREC_ANUAL_TOTAL + (ACT_VALOR_CORREGIDO * U_PorResid - ACT_DEPRE_CORREGIDA - DEPREC_ANUAL_TOTAL) * ActivoAdicion.PeriodosDerpreciados / ActivoAdicion.VidaUtil;
                  end
                  else begin
                     if (ActivoAdicion.PeriodosDerpreciados > 0) then
                        DEPREC_PERIODO     := DEPREC_PERIODO + (ActivoAdicion.ValorCorregidoActivo * U_PorResid - ActivoAdicion.ValorCorregidoDeprec) * UNID_DEPREC / ActivoAdicion.VidaUtil;
                     DEPREC_ANUAL_TOTAL := DEPREC_ANUAL_TOTAL + (ActivoAdicion.ValorCorregidoActivo * U_PorResid - ActivoAdicion.ValorCorregidoDeprec) * ActivoAdicion.PeriodosDerpreciados / ActivoAdicion.VidaUtil;
                  end;
if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
      oLog.OutLog('RDEPREC_ANUAL_TOTAL  : ' + DEPREC_ANUAL_TOTAL.ToString);
      oLog.OutLog('RDEPREC_PERIODO      : ' + DEPREC_PERIODO.ToString);
      oLog.OutLog('RACT_VALOR_CORREGIDO : ' + ACT_VALOR_CORREGIDO.ToString);
end;
               end;
            end;

            ActivoAdicion     := TActivoAdicion(LstActivoAdicion[0]);
        
            ACT_VALOR_NOMINAL := ADICIONES_TOTALES + U_OriValCo - U_OriDepre;
            VIDA_UTIL         := System.int32(oActivosData.GetProperty('U_VidaUtil'));
            if (VIDA_UTIL > 0) and (DEPREC_PERIODO > 0) then
               DEPREC_NOMINAL := (ACT_VALOR_NOMINAL * U_PorResid - U_DepAcumN) * UNID_DEPREC / VIDA_UTIL;
        
            CorrActi     := ACT_VALOR_CORREGIDO - U_CurVal - U_CorAnuAc - ADICIONES_ANUALES;
            CorrDepr     := ActivoAdicion.ValorCorregidoDeprec - U_DepAcum - U_CorAnuDe;
            NvoValActivo := ACT_VALOR_CORREGIDO;
            CorrDeprM    := DEPREC_ANUAL_TOTAL - DEPREC_PERIODO - DEPREC_ANUAL_NOM;
        
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               if (USO_VIDA_UTIL_NEW <> 0) then begin 
                  VIDA_UTIL := USO_VIDA_UTIL_NEW;
               end;
               if (VIDA_UTIL > 0) then
                  DEPREC_PERIODO := (ACT_VALOR_CORREGIDO - ActivoAdicion.ValorCorregidoDeprec - U_DepreAnu)* UNID_DEPREC / VIDA_UTIL;
               CorrDeprM        := 0;
               DEPREC_NOMINAL   := 0;
//               DEPREC_ANUAL_NOM := ACT_DEPRE_CORREGIDA;
               ActYear[nxPr].AdicVid := 0;
            end;

            // Depreciacion del mes
            perDep    := 0;
            if (Deprecia_Flag) then begin
               if (VIDA_UTIL > 0) then
                  perDep   := UNID_DEPREC
               else begin
                  DEPREC_PERIODO := 0;
                  DEPREC_NOMINAL := 0;
               end;
            end
            else begin
               DEPREC_PERIODO := 0;
               DEPREC_NOMINAL := 0;
            end;
        
            if (not Corrige_Flag) then begin
               CorrActi  := 0;
               CorrDepr  := 0;
               CorrDeprM := 0;
            end;

            VALOR_RESIDUAL := 0;
            if (U_PerVidaU + ActYear[nxPr].AdicVid <= U_PerDepre) or (U_PerVidaU <= 0) then begin
               //Detener correcciones
               if (System.String(oParametrosData.GetProperty('U_CorActDe')).Trim <> 'Y') then begin
                  CorrActi  := 0;
                  CorrDepr  := 0;
                  CorrDeprM := 0;
               end;
        
               if (U_PorResid = 0) then
                  VALOR_RESIDUAL := System.Double(oParametrosData.GetProperty('U_ValResid'));
            end;
                
            s := 'N';
            oActivosLines     := oActivosData.Child('VID_AFAC');
            oActivosLinesData := oActivosLines.Add;
            oActivosLinesData.SetProperty('U_Year'    , nxYr);
            oActivosLinesData.SetProperty('U_Periodo' , nxPr);
            oActivosLinesData.SetProperty('U_CorrActi', CorrActi);
            oActivosLinesData.SetProperty('U_CorrDepr', CorrDepr);
            oActivosLinesData.SetProperty('U_Deprecia', DEPREC_PERIODO);
            oActivosLinesData.SetProperty('U_CorrDepM', CorrDeprM);
            oActivosLinesData.SetProperty('U_DeprNom' , DEPREC_NOMINAL);
            oActivosLinesData.SetProperty('U_Adicion' , ActYear[nxPr].AdicVal);
            oActivosLinesData.SetProperty('U_PerVidUt', ActYear[nxPr].AdicVid);
            oActivosLinesData.SetProperty('U_PerDepre', perDep);
            oActivosLinesData.SetProperty('U_PostFlag', s);

            //............. Anual..........
        
            if (nxPr = 12) then begin
               nxYrIns := nxYr + 1;
               nxPrIns := 1;
            end
            else begin
               nxYrIns := nxYr;
               nxPrIns := nxPr + 1;
            end;
        
            U_CorAnuAc := CorrActi + U_CorAnuAc;
            U_CorAnuDe := CorrDepr + U_CorAnuDe;
            if (nxPrIns = 1) then begin
               // actualizo información anual

               // Determinar uso de Bis33
               Bis33_flag := false;
               if (System.String(oActivosData.GetProperty('U_Bis33Flg')) = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Flg'))  = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Fin'))  = 'Y') then
                  Bis33_flag := true;
        
               // Solo a fin de año de calcula Bis33
               Ley33Bis := 0;
               if (nxPr = 12) and (nxYr = U_OriFec.Year)  and (Bis33_flag) and (TopeLey33Bis  > 0) then begin
                  Ley33Bis     := NvoValActivo * ( System.Double( oParametrosData.GetProperty('U_Bis33Per')) / 100);
                  if (Ley33Bis > TopeLey33Bis) then begin
                     Ley33Bis := TopeLey33Bis;
                     TopeLey33Bis := 0;
                  end
                  else 
                     TopeLey33Bis := TopeLey33Bis - Ley33Bis;
                  if (System.String(oParametrosData.GetProperty('U_Bis33Aju')) = 'Y') then begin
                     FactorBis33 := Ley33Bis / NvoValActivo;
                     DEPREC_PERIODO := DEPREC_PERIODO - (DEPREC_PERIODO + DEPREC_ANUAL_NOM + CorrDeprM)*FactorBis33;
                  end;
               end;
               
               // Ajuste Bis 33
               oActivosLinesData.SetProperty('U_Deprecia', DEPREC_PERIODO);

               oActivosLines     := oActivosData.Child('VID_AFSA');
               oActivosLinesData := oActivosLines.Add;
               oActivosLinesData.SetProperty('U_Year'     , nxYr);
               oActivosLinesData.SetProperty('U_CurVal'   , U_CurVal);
               oActivosLinesData.SetProperty('U_CorAnuAc' , U_CorAnuAc);
               oActivosLinesData.SetProperty('U_DepAcum'  , U_DepAcum);
               oActivosLinesData.SetProperty('U_DepAnual' , DEPREC_PERIODO + DEPREC_ANUAL_NOM + CorrDeprM);
               oActivosLinesData.SetProperty('U_DepAcumN' , DEPREC_NOMINAL + U_DepAcumN );
               oActivosLinesData.SetProperty('U_CorAnuDe' , U_CorAnuDe);
               oActivosLinesData.SetProperty('U_Adicion'  , ADICIONES_ANUALES);
               oActivosLinesData.SetProperty('U_Bis33'    , Ley33Bis);
            end;
        

            oActivosData.SetProperty('U_CorAnuAc',  U_CorAnuAc );
            oActivosData.SetProperty('U_DepreAnu',  System.Double( oActivosData.GetProperty('U_DepreAnu')) + DEPREC_PERIODO + CorrDeprM );
            oActivosData.SetProperty('U_DepAcumN',  System.Double( oActivosData.GetProperty('U_DepAcumN')) + DEPREC_NOMINAL);
            oActivosData.SetProperty('U_AdicAnuC',  ADICIONES_ANUALES);
            oActivosData.SetProperty('U_CorAnuDe',  U_CorAnuDe );
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') and
               (USO_VIDA_UTIL_NEW <> 0) then begin
                  oActivosData.SetProperty('U_VidaUtil',  USO_VIDA_UTIL_NEW - perDep );
                  oActivosData.SetProperty('U_PerVidaU',  USO_VIDA_UTIL_NEW );
            end
            else begin
              oActivosData.SetProperty('U_VidaUtil',  System.Int32( oActivosData.GetProperty('U_VidaUtil')) - perDep + ActYear[nxPr].AdicVid );
              oActivosData.SetProperty('U_PerVidaU',  System.Int32( oActivosData.GetProperty('U_PerVidaU')) + ActYear[nxPr].AdicVid );
            end;
            oActivosData.SetProperty('U_PerDepre',  System.Int32( oActivosData.GetProperty('U_PerDepre')) + perDep );
            oActivosData.SetProperty('U_PerDepYr',  System.Int32( oActivosData.GetProperty('U_PerDepYr')) + perDep );
            oActivosData.SetProperty('U_Bis33Fin',  Ley33Bis );

            oActivosData.SetProperty('U_NextYear',  nxYrIns );
            oActivosData.SetProperty('U_NextPer' ,  nxPrIns );
            oActivosData.SetProperty('U_ValResid',  VALOR_RESIDUAL );
   finally
   end;
end;

method TRealizaProcesoAFS.ProcesoReferencial(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; Indices: TIndice; nxYr, nxPr: integer; var TopeLey33Bis: Double);
var
   indiceOri    : double;
   FactorIpc    : double;
   FactorBis33  : double;
   Corrige_Flag : boolean;
   Bis33_flag   : boolean;

   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;

   ActYearR          : array [0..12] of TActividaMensual;
   LstActivoAdicionR : List<TActivoAdicion>;
   ActivoAdicion     : TActivoAdicion;
   i, j              : integer;

   U_NextYear : integer;
   U_NextPer  : integer;
   U_NxYrDepr : integer;
   U_NxPrDepr : integer;
   U_NxYrCorr : integer;
   U_NxPrCorr : integer;
   U_InitYear : integer;
   U_InitPer  : integer;
   U_Bis33    : double;
   U_Orifec   : DateTime;
   U_PorResiR : double;

   U_OriValCR : double;
   U_OriDeprR : Double;
   U_CurValR  : double;
   U_DepAcuR  : double;
   U_DepAcuRN : double;
   U_CorAnuAR : double;
   U_CorAnuDR : double;
   U_DepreAnR : double;
   U_PRrDepre : integer;
   U_PRrDepYr : integer;
   U_PerVidaR : integer;
   U_AdicAnuR : double;

   Bis33Dct_Flag       : boolean;

   VALOR_RESIDUAL      : double;
   ADICIONES_TOTALES   : double;
   ADICIONES_ANUALES   : double;

   USO_VIDA_UTIL_NEW   : Integer := 0;
   USO_VIDA_UTIL_OLD   : Integer := 0;

   RACT_VALOR_NOMINAL   : double;
   RACT_VALOR_CORREGIDO : double;
   RACT_DEPRE_CORREGIDA : double;
   RDEPREC_NOMINAL      : double;
   RDEPREC_ANUAL_TOTAL  : double;
   RDEPREC_PERIODO      : double;
   RDEPREC_ANUAL_NOM    : double;
   RPERIODOS_DEPREC     : integer;
   RVIDA_UTIL           : integer;
   RUNID_DEPREC         : Integer;

   RNvoValActivo        : double;
   RCorrActi            : double;
   RCorrDepr            : double;
   RCorrDeprM           : double;
   RPerDep              : integer;
   RDeprecia_Flag       : boolean;
   RinicioActiv         : integer;

   Ley33Bis           : double;

   s:                 string;
   nxYrIns, nxPrIns:  integer;
begin
   try
      LstActivoAdicionR := New List<TActivoAdicion>;

            U_NextYear := System.Int32(oActivosData.GetProperty('U_NextYear'));
            U_NextPer  := System.Int32(oActivosData.GetProperty('U_NextPer' ));
            U_NxYrDepr := System.Int32(oActivosData.GetProperty('U_NxYrDepr'));
            U_NxPrDepr := System.Int32(oActivosData.GetProperty('U_NxPrDepr'));
            U_InitYear := System.Int32(oActivosData.GetProperty('U_InitYear'));
            U_InitPer  := System.Int32(oActivosData.GetProperty('U_InitPer' ));
            U_Bis33    := System.Double(oActivosData.GetProperty('U_Bis33'   ));
            U_OriFec   := System.DateTime(oActivosData.GetProperty('U_OriFec'));
            U_PorResiR := 1-System.Double(oActivosData.GetProperty('U_PorResiR'))/100;
        
            U_OriValCR := System.Double(oActivosData.GetProperty('U_OriValCR'));    //  ANT_VALOR_ORIGINAL
            U_OriDeprR := System.Double(oActivosData.GetProperty('U_OriDeprR'));    //  ANT_DEPRECIACION_ORIGINAL
            U_CurValR  := System.Double(oActivosData.GetProperty('U_CurValR' ));    //  ANT_VALOR_ACTUAL
            U_DepAcuR  := System.Double(oActivosData.GetProperty('U_DepAcuR' ));    //  ANT_DEPRACUMULADA
            U_DepAcuRN := System.Double(oActivosData.GetProperty('U_DepAcuRN'));    //
            U_CorAnuAR := System.Double(oActivosData.GetProperty('U_CorAnuAR'));    //  ANT_CORRANUALACTIVO
            U_CorAnuDR := System.Double(oActivosData.GetProperty('U_CorAnuDR'));    //  ANT_CORRANUALDEPR
            U_DepreAnR := System.Double(oActivosData.GetProperty('U_DepreAnR'));    //  ANT_DEPRANUAL
            U_PRrDepre := System.Int32(oActivosData.GetProperty ('U_PRrDepre'));    //  ANT_PERDEPRECIADOS
            U_PRrDepYr := System.Int32(oActivosData.GetProperty ('U_PRrDepYr'));    //  ANT_PERDEPRECYEAR
            U_PerVidaR := System.Int32(oActivosData.GetProperty ('U_PerVidaR'));    //  ANT_VIDAUTIL
            U_AdicAnuR := System.double(oActivosData.GetProperty('U_AdicAnuR'));    //  ANT_ADIC_ANUCORR
        
            U_NxYrCorr := System.Int32(oActivosData.GetProperty('U_NxYrCorr'));
            U_NxPrCorr := System.Int32(oActivosData.GetProperty('U_NxPrCorr'));

            Bis33Dct_Flag := false;
            if (System.String(oParametrosData.GetProperty('U_Bis33Dct')) = 'Y') then 
               Bis33Dct_Flag := true;

            // Actualiza VID_AFAS
            if (nxPr = 1) then begin
               if (Bis33Dct_Flag) then begin
                  U_CurValR  := U_CurValR + U_CorAnuAR + U_AdicAnuR - U_Bis33;
                  U_DepAcuR  := U_DepAcuR + U_CorAnuDR + U_DepreAnR;
               end
               else begin
                  U_CurValR  := U_CurValR + U_CorAnuAR + U_AdicAnuR;
                  U_DepAcuR  := U_DepAcuR + U_CorAnuDR + U_DepreAnR + U_Bis33;
               end;
               U_CorAnuAR := 0;
               U_DepreAnR := 0;
               U_AdicAnuR := 0;
               U_CorAnuDR := 0;
               U_PRrDepYr := 0;
        
               oActivosData.SetProperty('U_PRrDepYr', U_PRrDepYr );
               oActivosData.SetProperty('U_CurValR' , U_CurValR  );
               oActivosData.SetProperty('U_DepAcuR' , U_DepAcuR  );
               oActivosData.SetProperty('U_CorAnuAR', U_CorAnuAR );
               oActivosData.SetProperty('U_DepreAnR', U_DepreAnR );
               oActivosData.SetProperty('U_AdicAnuR', U_AdicAnuR );
               oActivosData.SetProperty('U_CorAnuDR', U_CorAnuDR );
            end;
        
            for j:=0 to 12 do begin
               ActYearR[j] := new TActividaMensual;
               if (j=0) then begin
                  ActYearR[j].Year      := nxYr-1;
                  ActYearR[j].Per       := 12;
               end
               else begin
                  ActYearR[j].Year      := nxYr;
                  ActYearR[j].Per       := j;
               end;
               ActYearR[j].CorrAct   := 0;
               ActYearR[j].CorrDep   := 0;
               ActYearR[j].DeprMes   := 0;
               ActYearR[j].DeprNoAct := 0;
               ActYearR[j].CorDepM   := 0;
               ActYearR[j].AdicVal   := 0;
               ActYearR[j].AdicVid   := 0;
               ActYearR[j].PerDepre  := 0;
            end;
        
            if (U_InitYear <> nxYr) then
               RinicioActiv := 0
            else
               RinicioActiv := U_InitPer;
        
            // insertar adiciones de la misma fecha de ingreso del activo
            //... Marcar ... VID_AFAD para el periodo como procesado
            ADICIONES_TOTALES := 0;
            ADICIONES_ANUALES := 0;
            oActivosLines     := oActivosData.Child('VID_AFAD');
            for i:=0 to oActivosLines.Count - 1 do begin
               oActivosLinesData := oActivosLines.Item(i);
                  // si U_Procesad esta en 'Y' de proceso normal, continuar
               if ((System.Int32(oActivosLinesData.GetProperty('U_Year')) <> nxYr) or (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) <> nxPr)) and (System.String(oActivosLinesData.GetProperty('U_Procesad')) = 'Y') then begin
                  ADICIONES_TOTALES := ADICIONES_TOTALES + System.Double(oActivosLinesData.GetProperty('U_ValorAct'));
                  if (System.Int32(oActivosLinesData.GetProperty('U_Year')) = nxYr) then
                     ADICIONES_ANUALES := ADICIONES_ANUALES + System.Double(oActivosLinesData.GetProperty('U_ValorAct'));
               end;

               if (System.Int32(oActivosLinesData.GetProperty('U_Year')) <> nxYr) or (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) <> nxPr) then
                  Continue
               else begin
                  s := 'Y';
                  oActivosLinesData.SetProperty('U_Procesad', s);
                  ADICIONES_TOTALES := ADICIONES_TOTALES + System.Double(oActivosLinesData.GetProperty('U_ValorAct'));
                  ADICIONES_ANUALES := ADICIONES_ANUALES + System.Double(oActivosLinesData.GetProperty('U_ValorAct'));
        
                  ActYearR[nxPr].AdicVal := ActYearR[nxPr].AdicVal + System.Double(oActivosLinesData.GetProperty('U_ValorAct'));
                  if (System.String(oParametrosData.GetProperty('U_AdicVdUt')).Trim = 'Y') then
                     ActYearR[nxPr].AdicVid := ActYearR[nxPr].AdicVid + System.Int32(oActivosLinesData.GetProperty('U_PerVidUt'));
               end;
            end;
                
            // Determinar si debe depreciarse o solo corregirse
        
            RDeprecia_Flag := False;
            Corrige_Flag   := False;
            if (System.String(oActivosData.GetProperty('U_ConDepre')) = 'Y') and ((nxYr > U_NxYrDepr) or ((nxYr = U_NxYrDepr) and (nxPr >= U_NxPrDepr))) then 
               RDeprecia_Flag := true;
            if (System.String(oActivosData.GetProperty('U_ConCorre')) = 'Y') and ((nxYr > U_NxYrCorr) or ((nxYr = U_NxYrCorr) and (nxPr >= U_NxPrCorr))) then 
               Corrige_Flag  := true;
        
            RUNID_DEPREC := 1;
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ISNULL(d.U_Uso,0) Uso, ISNULL(U_ActCode, '') ActCode, ISNULL(U_GrpCode, '') GrpCode, ISNULL(d.U_SVidaAct,0) SVidaAct, " +
                        "       ISNULL(d.U_SVidaNew,0) SVidaNew, ISNULL(d.U_RVidaAct,0) RVidaAct, ISNULL(d.U_RVidaNew,0) RVidaNew " +
                        "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                        " where h.U_Year    = {0} " + 
                        "   and h.U_Periodo = {1} " + 
                        "   and (d.U_ActCode = '{2}'  or d.U_GrpCode = '{3}' )" + 
                        " order by 3",
                        'Select IFNULL(d."U_Uso",0) "Uso", IFNULL("U_ActCode", '') "ActCode", IFNULL("U_GrpCode", '') "GrpCode", IFNULL(d."U_SVidaAct",0) "SVidaAct", ' +
                        '       IFNULL(d."U_SVidaNew",0) "SVidaNew", IFNULL(d."U_RVidaAct",0) "RVidaAct", IFNULL(d."U_RVidaNew",0) "RVidaNew" ' +
                        '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                        ' where h."U_Year"    = {0} ' + 
                        '   and h."U_Periodo" = {1} ' + 
                        '   and (d."U_ActCode" = ''{2}''  or d."U_GrpCode" = ''{3}'' )' + 
                        ' order by 3');
               s := string.Format(s, nxYr.ToString, nxPr.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
oLog.outlog('3310 - ' + s); 
                oRecordActividad.DoQuery(s);
                if (not oRecordActividad.EoF) then begin
                   RUNID_DEPREC := System.Int32(oRecordActividad.Fields.Item('Uso').Value);
                   s := System.String(oRecordActividad.Fields.Item('GrpCode').Value);
                   if (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then
                      if (System.Int32(oRecordActividad.Fields.Item('RVidaNew').Value) <> System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value)) then begin
                         USO_VIDA_UTIL_NEW := System.Int32(oRecordActividad.Fields.Item('RVidaNew').Value);
                         USO_VIDA_UTIL_OLD := System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value);
                         ActYearR[nxPr].AdicVid  := 0;
                         if (System.String(oRecordActividad.Fields.Item('GrpCode').Value) <> '') then begin
                            oGruposData.SetProperty('U_VidaUtiR', USO_VIDA_UTIL_NEW);
                         end;
                      end;
                end;
             end;

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select U_Year, U_Periodo, U_CorrActi, U_CorrDepr, U_Deprecia, U_CorrDepM, U_Adicion, U_DeprNom, U_PerVidUt, U_PerDepre " + // incorpora uso mensual, se corrige y se divide por uso sumado anual
                     "  from [@VID_AFACR]    " +
                     " where Code   = '{0}' " + 
                     "   and U_Year =  {1}  " +
                     " order by U_Periodo   ",
                     'Select "U_Year", "U_Periodo", "U_CorrActi", "U_CorrDepr", "U_Deprecia", "U_CorrDepM", "U_Adicion", "U_DeprNom", "U_PerVidUt", "U_PerDepre" ' + // incorpora uso mensual, se corrige y se divide por uso sumado anual
                     '  from "@VID_AFACR"        ' +
                     ' where "Code"   = ''{0}'' ' +
                     '   and "U_Year" =   {1}   ' +
                     ' order by "U_Periodo"     ');
            s := string.Format(s, System.String(oActivosData.GetProperty('Code')), nxYr.ToString);
oLog.outlog('3339 - ' + s);
            oRecordActividad.DoQuery(s);
        
            LstActivoAdicionR.Clear;
            ActivoAdicion := new  TActivoAdicion;
            InitActivoAdicion(var ActivoAdicion);
            LstActivoAdicionR.Add(ActivoAdicion);
        
            //ActivoAdicion del periodo 0 o periodo de ingreso del activo
            ActivoAdicion.PeriodoInicial       := RinicioActiv;
            if (RinicioActiv = 0) then begin
               ActivoAdicion.ValorInicialActivo   := U_CurValR;
               ActivoAdicion.ValorInicialDeprec   := U_DepAcuR;
               ActivoAdicion.ValorCorregidoActivo := U_CurValR;
               ActivoAdicion.ValorCorregidoDeprec := U_DepAcuR;
            end
            else begin
               ActivoAdicion.ValorInicialActivo   := U_CurValR + ActYearR[RinicioActiv].AdicVal;
               ActivoAdicion.ValorInicialDeprec   := U_DepAcuR;
               ActivoAdicion.ValorCorregidoActivo := U_CurValR + ActYearR[RinicioActiv].AdicVal;
               ActivoAdicion.ValorCorregidoDeprec := U_DepAcuR;
            end;
        
            // Los activos con actvidad mensual
            if (System.String(oActivosData.GetProperty('Code')).Trim() = '3254') then
                oLog.OutLog('xx'); 
            i := System.Int32 (oRecordActividad.Fields.Item('U_Periodo' ).value);
            while (not oRecordActividad.EoF)  do begin
               ActYearR[i].Year      := nxYr;
               ActYearR[i].Per       := System.Int32 (oRecordActividad.Fields.Item('U_Periodo' ).value);
               ActYearR[i].CorrAct   := System.Double(oRecordActividad.Fields.Item('U_CorrActi').value);
               ActYearR[i].CorrDep   := System.Double(oRecordActividad.Fields.Item('U_CorrDepr').value);
               ActYearR[i].DeprMes   := System.Double(oRecordActividad.Fields.Item('U_Deprecia').value);
               ActYearR[i].DeprNoAct := System.Double(oRecordActividad.Fields.Item('U_DeprNom' ).value);
               ActYearR[i].CorDepM   := System.Double(oRecordActividad.Fields.Item('U_CorrDepM').value);
               ActYearR[i].AdicVal   := System.Double(oRecordActividad.Fields.Item('U_Adicion' ).value);
               ActYearR[i].AdicVid   := System.Int32(oRecordActividad.Fields.Item('U_PerVidUt').value);
               ActYearR[i].PerDepre  := System.Int32(oRecordActividad.Fields.Item('U_PerDepre').value);
        
               // Ingreso de adiciones si existen
               if (ActYearR[i].AdicVal > 0) then begin
                  if (i = RinicioActiv) then
                     ActivoAdicion.ValorInicialActivo := U_CurValR  + ActYearR[i].AdicVal
                  else begin
                     ActivoAdicion := new TActivoAdicion;
                     InitActivoAdicion(var ActivoAdicion);
                     LstActivoAdicionR.Add(ActivoAdicion);
        
                     ActivoAdicion.PeriodoInicial := i;
                     ActivoAdicion.ValorInicialActivo   := ActYearR[i].AdicVal;
                  end;
               end;
        
               inc(i);
               oRecordActividad.MoveNext;
            end;

            // ingreso adiciones del periodo en proceso
            if (ActYearR[nxPr].AdicVal > 0) and (nxPr <> RinicioActiv) then begin
               ActivoAdicion := new TActivoAdicion;
               InitActivoAdicion(var ActivoAdicion);
               LstActivoAdicionR.Add(ActivoAdicion);
        
               ActivoAdicion.PeriodoInicial := nxPr;
               ActivoAdicion.ValorInicialActivo   := ActYearR[nxPr].AdicVal;
            end;
        
            // Calculos de valores de adiciones
            RVIDA_UTIL       := System.int32(oActivosData.GetProperty('U_VidaUtiR'));
            if (System.String(oActivosData.GetProperty('U_TipoDepR')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               if (USO_VIDA_UTIL_NEW <> 0) then 
                  RVIDA_UTIL := USO_VIDA_UTIL_NEW;
            end;
            if (RUNID_DEPREC > RVIDA_UTIL) then
               RUNID_DEPREC := RVIDA_UTIL;
            RPERIODOS_DEPREC := RUNID_DEPREC;

            j := LstActivoAdicionR.Count-1;
            ActivoAdicion := TActivoAdicion(LstActivoAdicionR[j]);
            for i:=nxPr downto RinicioActiv do begin
               if (ActYearR[i].AdicVid > 0) and (i = nxPr) then begin   
                  ActivoAdicion.VidaUtil   := RVIDA_UTIL + ActYearR[i].AdicVid;
                  ActivoAdicion.AdicVida   := ActYearR[i].AdicVid;
                  if (RDeprecia_Flag) then
                     ActivoAdicion.PeriodosDerpreciados := RPERIODOS_DEPREC
                  else
                     ActivoAdicion.PeriodosDerpreciados := 0;

                  RPERIODOS_DEPREC := 0;
                  RVIDA_UTIL       := System.int32(oActivosData.GetProperty('U_VidaUtiR'));

                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicionR[j]);
                  end;
               end
               else if (ActYearR[i].AdicVid > 0) and (i <> nxPr) and (i > RinicioActiv) then begin
                  RPERIODOS_DEPREC := RPERIODOS_DEPREC + ActYearR[i].PerDepre;
                  RVIDA_UTIL       := RVIDA_UTIL       + ActYearR[i].PerDepre;

                  ActivoAdicion.VidaUtil             := RVIDA_UTIL;
                  ActivoAdicion.PeriodosDerpreciados := RPERIODOS_DEPREC;
                  ActivoAdicion.AdicVida             := ActYearR[i].AdicVid;

                  RPERIODOS_DEPREC := 0;
                  RVIDA_UTIL       := RVIDA_UTIL - ActYearR[i].AdicVid;
                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicionR[j]);
                  end;
               end
               else if (i = ActivoAdicion.PeriodoInicial) then begin
                  if (i <> nxPr) then begin
                     RPERIODOS_DEPREC := RPERIODOS_DEPREC + ActYearR[i].PerDepre;
                     RVIDA_UTIL       := RVIDA_UTIL       + ActYearR[i].PerDepre;
                  end;

                  ActivoAdicion.VidaUtil             := RVIDA_UTIL;
                  ActivoAdicion.PeriodosDerpreciados := RPERIODOS_DEPREC;
                  ActivoAdicion.AdicVida             := ActYearR[i].AdicVid;

                  if (j > 0) then begin
                     dec(j);
                     ActivoAdicion := TActivoAdicion(LstActivoAdicionR[j]);
                  end;
               end
               else if (ActYearR[i].DeprMes > 0) then begin
                  if (i <> nxPr) then begin
                     RPERIODOS_DEPREC := RPERIODOS_DEPREC + ActYearR[i].PerDepre;
                     RVIDA_UTIL       := RVIDA_UTIL       + ActYearR[i].PerDepre;
                  end;
               end;
            end;
        
// DEBUG
if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
   oLog.OutLog(' ');
   oLog.OutLog(' ');
   for i:=0 to LstActivoAdicionR.Count-1 do begin
      ActivoAdicion := TActivoAdicion(LstActivoAdicionR[i]);
      oLog.OutLog('i : ' + i.ToString);
      oLog.OutLog('VidaUtil             : ' + ActivoAdicion.VidaUtil.ToString);
      oLog.OutLog('PeriodosDerpreciados : ' + ActivoAdicion.PeriodosDerpreciados.ToString);
      oLog.OutLog('AdicVida             : ' + ActivoAdicion.AdicVida.ToString);
   end;
end;

            // Factor periodo inicial
            if (nxYr = U_InitYear) then
               indiceOri := Indices[U_InitPer]
            else begin
               indiceOri := Indices[0]; //indice año anterior
               if (indiceOri = 0) then
                  raise new exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Indices_no_definidos] + nxYr.ToString + '/' + nxPr.ToString)
            end;
        
            RACT_VALOR_NOMINAL   := ADICIONES_TOTALES + U_OriValCR - U_OriDeprR;
            RDEPREC_ANUAL_NOM    := 0;
            RDEPREC_PERIODO      := 0;
            RDEPREC_NOMINAL      := 0;
            RACT_VALOR_CORREGIDO := 0;
            RACT_DEPRE_CORREGIDA := 0;
            RDEPREC_ANUAL_TOTAL  := 0;
        
            for i:=RinicioActiv to nxPr do begin
               RDEPREC_ANUAL_NOM := RDEPREC_ANUAL_NOM + ActYearR[i].DeprMes + ActYearR[i].CorDepM;
            end;
        
            for i:=0 to LstActivoAdicionR.Count-1 do begin
               ActivoAdicion := TActivoAdicion(LstActivoAdicionR[i]);
        
               FactorIpc := Utils.AjustarDecimales(indices[nxPr] / indices[ActivoAdicion.PeriodoInicial]);
               if (FactorIpc < 1) and (System.String(oParametrosData.GetProperty('U_CorPosit')).Trim = 'Y') then  // (nxPr = 12)
                  FactorIpc := 1;
        
               if (i = 0) then begin
                  ActivoAdicion.ValorCorregidoDeprec := ActivoAdicion.ValorInicialDeprec * FactorIpc;
                  RACT_DEPRE_CORREGIDA               := ActivoAdicion.ValorCorregidoDeprec
               end;
        
               ActivoAdicion.ValorCorregidoActivo  := ActivoAdicion.ValorInicialActivo * FactorIpc;
               RACT_VALOR_CORREGIDO                := RACT_VALOR_CORREGIDO + ActivoAdicion.ValorCorregidoActivo;

               // deprecia hasta adicion de vida util (de acuerdo a ingreso de adiciones de vida
   { el periodo 0, aparecn perdiodos depreciados = 2, debiese ser 1
     se debe restar al total o sumar revisar calculo
   }
               if (ActivoAdicion.VidaUtil > 0) then begin //IO

if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
      oLog.OutLog('i : ' + i.ToString);
      oLog.OutLog('VidaUtil             : ' + ActivoAdicion.VidaUtil.ToString);
      oLog.OutLog('PeriodosDerpreciados : ' + ActivoAdicion.PeriodosDerpreciados.ToString);
      oLog.OutLog('ValorCorregidoActivo : ' + ActivoAdicion.ValorCorregidoActivo.ToString);
      oLog.OutLog('ValorCorregidoDeprec : ' + ActivoAdicion.ValorCorregidoDeprec.ToString);
end;

                  if (ActivoAdicion.AdicVida > 0) then begin
                     RDEPREC_PERIODO     := (RACT_VALOR_CORREGIDO * U_PorResiR - RACT_DEPRE_CORREGIDA - RDEPREC_ANUAL_TOTAL) * RUNID_DEPREC / ActivoAdicion.VidaUtil;
                     RDEPREC_ANUAL_TOTAL := RDEPREC_ANUAL_TOTAL + (RACT_VALOR_CORREGIDO * U_PorResiR - RACT_DEPRE_CORREGIDA - RDEPREC_ANUAL_TOTAL) * ActivoAdicion.PeriodosDerpreciados / ActivoAdicion.VidaUtil;
                  end
                  else begin
                     if (ActivoAdicion.PeriodosDerpreciados > 0) then
                        RDEPREC_PERIODO     := RDEPREC_PERIODO + (ActivoAdicion.ValorCorregidoActivo * U_PorResiR - ActivoAdicion.ValorCorregidoDeprec) * RUNID_DEPREC / ActivoAdicion.VidaUtil;
                     RDEPREC_ANUAL_TOTAL := RDEPREC_ANUAL_TOTAL + (ActivoAdicion.ValorCorregidoActivo * U_PorResiR - ActivoAdicion.ValorCorregidoDeprec) * ActivoAdicion.PeriodosDerpreciados / ActivoAdicion.VidaUtil;
                  end;
if (System.String(oActivosData.GetProperty('Code')) = oLogCode) and (oLogMess) then begin
      oLog.OutLog('RDEPREC_ANUAL_TOTAL  : ' + RDEPREC_ANUAL_TOTAL.ToString);
      oLog.OutLog('RDEPREC_PERIODO      : ' + RDEPREC_PERIODO.ToString);
      oLog.OutLog('RACT_VALOR_CORREGIDO : ' + RACT_VALOR_CORREGIDO.ToString);
end;
               end;
            end;
        
            ActivoAdicion := TActivoAdicion(LstActivoAdicionR[0]);
            
            RACT_VALOR_NOMINAL   := ADICIONES_TOTALES + U_OriValCR - U_OriDeprR;
            RVIDA_UTIL := System.int32(oActivosData.GetProperty('U_VidaUtiR'));
            if (RVIDA_UTIL > 0) and (RDEPREC_PERIODO > 0) then
               RDEPREC_NOMINAL := (RACT_VALOR_NOMINAL * U_PorResiR - U_DepAcuRN) * RUNID_DEPREC / RVIDA_UTIL;
        
            RCorrActi     := RACT_VALOR_CORREGIDO - U_CurValR - U_CorAnuAR - ADICIONES_ANUALES;
            //RCorrActi := iif(RCorrActi < 0, 0, RCorrActi); 
            RCorrDepr     := ActivoAdicion.ValorCorregidoDeprec - U_DepAcuR - U_CorAnuDR;
            //RCorrDepr := iif(RCorrDepr < 0, 0, RCorrDepr);
            RNvoValActivo := RACT_VALOR_CORREGIDO;
            //RNvoValActivo := iif(RNvoValActivo < 0, 0, RNvoValActivo);
            RCorrDeprM    := RDEPREC_ANUAL_TOTAL - RDEPREC_PERIODO - RDEPREC_ANUAL_NOM;
            //RCorrDeprM := iif(RCorrDeprM < 0, 0, RCorrDeprM);
        
            if (System.String(oActivosData.GetProperty('U_TipoDepR')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               if (USO_VIDA_UTIL_NEW <> 0) then  
                  RVIDA_UTIL := USO_VIDA_UTIL_NEW;
               if (RVIDA_UTIL > 0) then
                  RDEPREC_PERIODO := (RACT_VALOR_CORREGIDO - ActivoAdicion.ValorCorregidoDeprec - U_DepreAnR)* RUNID_DEPREC / RVIDA_UTIL;
               RCorrDeprM        := 0;
               RDEPREC_NOMINAL   := 0;
//               RDEPREC_ANUAL_NOM := RACT_DEPRE_CORREGIDA;
               ActYearR[nxPr].AdicVid := 0;
            end;

            // Depreciacion del mes
            RperDep    := 0;
            if (RDeprecia_Flag) then begin
               if (RVIDA_UTIL > 0) then
                  RperDep   := RUNID_DEPREC
               else begin
                  RDEPREC_PERIODO := 0;
                  RDEPREC_NOMINAL := 0;
               end;
            end
            else begin
               RDEPREC_PERIODO := 0;
               RDEPREC_NOMINAL := 0;
            end;
        
            if (not Corrige_Flag) then begin
               RCorrActi  := 0;
               RCorrDepr  := 0;
               RCorrDeprM := 0;
            end;

            VALOR_RESIDUAL := 0;
            if (U_PerVidaR + ActYearR[nxPr].AdicVid <= U_PRrDepre) or (U_PerVidaR <= 0) then begin
               //Detener correcciones
               if (System.String(oParametrosData.GetProperty('U_CorActDe')).Trim <> 'Y') then begin
                  RCorrActi  := 0;
                  RCorrDepr  := 0;
                  RCorrDeprM := 0;
               end;
            end;
        
            s := 'N';
            oActivosLines     := oActivosData.Child('VID_AFACR');
            oActivosLinesData := oActivosLines.Add;
            oActivosLinesData.SetProperty('U_Year'    , nxYr);
            oActivosLinesData.SetProperty('U_Periodo' , nxPr);
            oActivosLinesData.SetProperty('U_CorrActi', RCorrActi);
            oActivosLinesData.SetProperty('U_CorrDepr', RCorrDepr);
            oActivosLinesData.SetProperty('U_Deprecia', RDEPREC_PERIODO);
            oActivosLinesData.SetProperty('U_CorrDepM', RCorrDeprM);
            oActivosLinesData.SetProperty('U_DeprNom' , RDEPREC_NOMINAL);
            oActivosLinesData.SetProperty('U_Adicion' , ActYearR[nxPr].AdicVal);
            oActivosLinesData.SetProperty('U_PerVidUt', ActYearR[nxPr].AdicVid);
            oActivosLinesData.SetProperty('U_PerDepre', RperDep);
            oActivosLinesData.SetProperty('U_PostFlag', s);
        
            //............. Anual..........
        
            if (nxPr = 12) then begin
               nxYrIns := nxYr + 1;
               nxPrIns := 1;
            end
            else begin
               nxYrIns := nxYr;
               nxPrIns := nxPr + 1;
            end;
                
            U_CorAnuAR := RCorrActi + U_CorAnuAR;
            U_CorAnuDR := RCorrDepr + U_CorAnuDR;
        
            if (nxPrIns = 1) then begin
               // actualizo información anual
        
               // Determinar uso de Bis33
               Bis33_flag := false;
               if (System.String(oActivosData.GetProperty('U_Bis33Flg')) = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Flg'))  = 'Y') and (System.String(oParametrosData.GetProperty('U_Bis33Ref'))  = 'Y') then
                  Bis33_flag := true;
        
               // Solo a fin de año de calcula Bis33
               Ley33Bis := 0;
               if (nxPr = 12) and (nxYr = U_OriFec.Year)  and (Bis33_flag) and (TopeLey33Bis  > 0) then begin
                  Ley33Bis     := RNvoValActivo * ( System.Double( oParametrosData.GetProperty('U_Bis33Per')) / 100);
                  if (Ley33Bis > TopeLey33Bis) then begin
                     Ley33Bis := TopeLey33Bis;
                     TopeLey33Bis := 0;
                  end
                  else 
                     TopeLey33Bis := TopeLey33Bis - Ley33Bis;
                  if (System.String(oParametrosData.GetProperty('U_Bis33Aju')) = 'Y') then begin
                     FactorBis33 := Ley33Bis / RNvoValActivo;
                     RDEPREC_PERIODO := RDEPREC_PERIODO - (RDEPREC_PERIODO + RDEPREC_ANUAL_NOM + RCorrDeprM)*FactorBis33;
                  end;
               end;
        
               // Ajuste Bis 33
               oActivosLinesData.SetProperty('U_Deprecia', RDEPREC_PERIODO);

               oActivosLines     := oActivosData.Child('VID_AFSAR');
               oActivosLinesData := oActivosLines.Add;
               oActivosLinesData.SetProperty('U_Year'     , nxYr);
               oActivosLinesData.SetProperty('U_CurVal'   , U_CurValR);
               oActivosLinesData.SetProperty('U_CorAnuAc' , U_CorAnuAR);
               oActivosLinesData.SetProperty('U_DepAcum'  , U_DepAcuR);
               oActivosLinesData.SetProperty('U_DepAnual' , RDEPREC_PERIODO + RDEPREC_ANUAL_NOM + RCorrDeprM);
               oActivosLinesData.SetProperty('U_DepAcumN' , RDEPREC_NOMINAL + U_DepAcuRN );
               oActivosLinesData.SetProperty('U_CorAnuDe' , U_CorAnuDR);
               oActivosLinesData.SetProperty('U_Adicion'  , ADICIONES_ANUALES);
               oActivosLinesData.SetProperty('U_Bis33'    , Ley33Bis);
            end;
        
            oActivosData.SetProperty('U_CorAnuAR',  U_CorAnuAR );
            oActivosData.SetProperty('U_DepreAnR',  System.Double( oActivosData.GetProperty('U_DepreAnR')) + RDEPREC_PERIODO + RCorrDeprM );
            oActivosData.SetProperty('U_DepAcuRN',  System.Double( oActivosData.GetProperty('U_DepAcuRN')) + RDEPREC_NOMINAL );
            oActivosData.SetProperty('U_AdicAnuR',  ADICIONES_ANUALES);
            oActivosData.SetProperty('U_CorAnuDR',  U_CorAnuDR );
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') and
               (USO_VIDA_UTIL_NEW <> 0) then begin
                  oActivosData.SetProperty('U_VidaUtiR',  USO_VIDA_UTIL_NEW - RperDep );
                  oActivosData.SetProperty('U_PerVidaR',  USO_VIDA_UTIL_NEW );
            end
            else begin
              oActivosData.SetProperty('U_VidaUtiR',  System.Int32( oActivosData.GetProperty('U_VidaUtiR')) - RperDep + ActYearR[nxPr].AdicVid );
              oActivosData.SetProperty('U_PerVidaR',  System.Int32( oActivosData.GetProperty('U_PerVidaR')) + ActYearR[nxPr].AdicVid );
            end;
            oActivosData.SetProperty('U_PRrDepre',  System.Int32( oActivosData.GetProperty('U_PRrDepre')) + RperDep );
            oActivosData.SetProperty('U_PRrDepYr',  System.Int32( oActivosData.GetProperty('U_PRrDepYr')) + RperDep );
            oActivosData.SetProperty('U_Bis33'   ,  Ley33Bis );

            oActivosData.SetProperty('U_NextYear',  nxYrIns );
            oActivosData.SetProperty('U_NextPer' ,  nxPrIns );
            oActivosData.SetProperty('U_ValResid',  VALOR_RESIDUAL );

   finally
   end;        
end;

method TRealizaProcesoAFS.ProcesoIFRS(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; nxYr, nxPr: integer);
var
   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;

   U_NextYear : integer;
   U_NextPer  : integer;
   U_NxYrDepr : integer;
   U_NxPrDepr : integer;
   U_InitYear : integer;
   U_InitPer  : integer;
   U_Orifec   : DateTime;
   U_PorResid : double;

   U_OriDepre : Double;
   U_CurVal   : double;
   U_CorAnuAc : Double; // Mantiene el valor de la revalorización - equivale al reinicializar U_CurVal - Se utilza si valor > 0
   U_DepAcum  : double;
   U_DepreAnu : double;
   U_PerDepre : integer;
   U_PerDepYr : integer;
   U_PerVidaU : integer;
   U_AdicAnuc : Double;

   Revalorizado      : boolean := false;
   RevalorizadoAntes : boolean := false;
   U_RvNewVal        : Double;
   U_RvOldVal        : Double;
   DepDesdeReval     : Double;
   VIDA_UTIL_Ant     : Integer;
   oPerPorDp         : Integer;

   ADICIONES_ANUALES   : double;
   ADICIONES_ANUALES_Finan : double;
   ADICION_PERIODO     : Double;
   ADICION_PERIODO_FINAN : Double;
   ADIC_VUT_PERIODO    : Integer;
   ValAux              : Double;

   USO_VIDA_UTIL_NEW   : Integer := 0;
   USO_VIDA_UTIL_OLD   : Integer := 0;

   DEPREC_PERIODO      : double;
   VIDA_UTIL           : integer;
   UNID_DEPREC         : Integer;

   PerDep               : integer;
   Deprecia_Flag        : boolean;

   s                : String;
   nxYrIns, nxPrIns : Integer;
   minYrRv, minPrRv : Integer;
   i                : integer;
begin
   try
            // valores actuales del activo
        
            U_NextYear := System.Int32(oActivosData.GetProperty('U_NextYear'));
            U_NextPer  := System.Int32(oActivosData.GetProperty('U_NextPer' ));
            U_NxYrDepr := System.Int32(oActivosData.GetProperty('U_NxYrDepr'));
            U_NxPrDepr := System.Int32(oActivosData.GetProperty('U_NxPrDepr'));
            U_InitYear := System.Int32(oActivosData.GetProperty('U_InitYear'));
            U_InitPer  := System.Int32(oActivosData.GetProperty('U_InitPer' ));
            U_OriFec   := System.DateTime(oActivosData.GetProperty('U_OriFec'));
            U_PorResid := 1-System.Double(oActivosData.GetProperty('U_PorResid'))/100;
            VIDA_UTIL  := System.int32(oActivosData.GetProperty('U_VidaUtil'));
                
            U_OriDepre := System.Double(oActivosData.GetProperty('U_OriDepre'));    //  ANT_DEPRECIACION_ORIGINAL
            U_CurVal   := System.Double(oActivosData.GetProperty('U_CurVal'  ));    //  ANT_VALOR_ACTUAL
            U_CorAnuAc := System.Double(oActivosData.GetProperty('U_CorAnuAc'));    //  se utiliza si existe revalorizacion - reemplaza a U_CurVal cuando U_CorAnuAc > 0
            U_DepAcum  := System.Double(oActivosData.GetProperty('U_DepAcum' ));    //  ANT_DEPRACUMULADA
            U_DepreAnu := System.Double(oActivosData.GetProperty('U_DepreAnu'));    //  ANT_DEPRANUAL
            U_PerDepre := System.Int32(oActivosData.GetProperty ('U_PerDepre'));    //  ANT_PERDEPRECIADOS
            U_PerDepYr := System.Int32(oActivosData.GetProperty ('U_PerDepYr'));    //  ANT_PERDEPRECYEAR
            U_PerVidaU := System.Int32(oActivosData.GetProperty ('U_PerVidaU'));    //  ANT_VIDAUTIL
            U_AdicAnuc := System.double(oActivosData.GetProperty('U_AdicAnuC'));    //  ANT_ADIC_ANUAL
                       
            // Usado en reval
            DepDesdeReval     := 0;
            VIDA_UTIL_Ant     := VIDA_UTIL;
            ADIC_VUT_PERIODO  := 0;
            ADICION_PERIODO   := 0;
            ADICION_PERIODO_FINAN := 0;

            if (U_CorAnuac = 0) then
               U_CorAnuac := U_CurVal;
        
            // Actualiza VID_AFAS
            if (nxPr = 1) then begin
               //U_CurValR  := U_CurValR + U_CorAnuAR + U_AdicAnuR;
               //U_DepAcuR  := U_DepAcuR + U_CorAnuDR + U_DepreAnR + U_Bis33;
               U_DepAcum  := U_DepAcum + U_DepreAnu;
               U_CorAnuAc := U_CorAnuAc + U_AdicAnuc;
               U_Curval := U_CorAnuac;
               //U_Curval   := U_Curval + U_AdicAnuc; // Revisar si suma o no adiciones
               U_DepreAnu := 0;
               U_PerDepYr := 0;
               U_AdicAnuc := 0;
        
               var d : Double := 0.0;
               oActivosData.SetProperty('U_CurVal'  , U_CurVal   );
               oActivosData.SetProperty('U_CorAnuAc', U_CorAnuAc);
               oActivosData.SetProperty('U_DepAcum' , U_DepAcum  );
               oActivosData.SetProperty('U_DepreAnu', U_DepreAnu );
               oActivosData.SetProperty('U_PerDepYr', U_PerDepYr );
               oActivosData.SetProperty('U_AdicAnuC', U_AdicAnuc );
               oActivosData.SetProperty('U_CorAnuDe', d );
            end;

            UNID_DEPREC := 1;
            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ISNULL(d.U_Uso,0) Uso, ISNULL(U_ActCode, '') ActCode, ISNULL(U_GrpCode, '') GrpCode, ISNULL(d.U_SVidaAct,0) SVidaAct, " +
                        "       ISNULL(d.U_SVidaNew,0) SVidaNew, ISNULL(d.U_RVidaAct,0) RVidaAct, ISNULL(d.U_RVidaNew,0) RVidaNew " +
                        "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                        " where h.U_Year    = {0} " + 
                        "   and h.U_Periodo = {1} " + 
                        "   and (d.U_ActCode = '{2}'  or d.U_GrpCode = '{3}' )" + 
                        " order by 3",
                        'Select IFNULL(d."U_Uso",0) "Uso", IFNULL("U_ActCode", '') "ActCode", IFNULL("U_GrpCode", '') "GrpCode", IFNULL(d."U_SVidaAct",0) "SVidaAct", ' +
                        '       IFNULL(d."U_SVidaNew",0) "SVidaNew", IFNULL(d."U_RVidaAct",0) "RVidaAct", IFNULL(d."U_RVidaNew",0) "RVidaNew" ' +
                        '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                        ' where h."U_Year"    = {0} ' + 
                        '   and h."U_Periodo" = {1} ' + 
                        '   and (d."U_ActCode" = ''{2}''  or d."U_GrpCode" = ''{3}'' )' + 
                        ' order by 3');
               s := string.Format(s, nxYr.ToString, nxPr.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
                oRecordActividad.DoQuery(s);
                oLog.outlog("3827 - " + s);
                if (not oRecordActividad.EoF) then begin
                   UNID_DEPREC := System.Int32(oRecordActividad.Fields.Item('Uso').Value);
                   s := System.String(oRecordActividad.Fields.Item('GrpCode').Value);
                   if (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then
                      if (System.Int32(oRecordActividad.Fields.Item('SVidaNew').Value) <> System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value)) then begin
                         USO_VIDA_UTIL_NEW := System.Int32(oRecordActividad.Fields.Item('SVidaNew').Value);
                         USO_VIDA_UTIL_OLD := System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value);
                         if (System.String(oRecordActividad.Fields.Item('GrpCode').Value) <> '') then begin
                            oGruposData.SetProperty('U_VidaUtil', USO_VIDA_UTIL_NEW);
                         end;
                      end;
                end;
            end;

            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select d.U_NewVal, d.U_ValAnt, h.DocEntry                                    " +
                     " from [@VID_AFREV] h inner join [@VID_AFREVD] d on h.DocEntry = d.DocEntry   " +
                     "                     inner join [@VID_AFAS] a  on d.U_ActCode = a.U_ActCode  " +
                     " where h.U_Year    =  {0}   " + 
                     "   and h.U_Periodo =  {1}   " + 
                     "   and a.Code      =  '{2}' ", 
                     'Select d."U_NewVal", d."U_ValAnt", h."DocEntry"                                  ' +
                     ' from "@VID_AFREV" h inner join "@VID_AFREVD" d on h."DocEntry" = d."DocEntry"   ' +
                     '                     inner join "@VID_AFAS" a  on d."U_ActCode" = a."U_ActCode"  ' +
                     ' where h."U_Year"    =   {0}   ' + 
                     '   and h."U_Periodo" =   {1}   ' + 
                     '   and a."Code"      = ''{2}'' ');
            s := string.Format(s, nxYr.ToString ,nxPr.ToString, System.String(oActivosData.GetProperty('Code')));
            oLog.outlog("3855 - " + s);
            oRecordActividad.DoQuery(s);
            if (not oRecordActividad.EoF) then begin
               Revalorizado   := true;
               U_RvNewVal := System.Double(oRecordActividad.Fields.Item('U_NewVal').Value);
               U_RvOldVal := U_CorAnuAc;
            end;

            // Seleccionar ultima revalorizacion
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select Month(max(h.U_Fecha)) Mes, Year(max(h.U_Fecha)) Year, count(*) cant   " +
                     "   from [@VID_AFREVD] d inner join [@VID_AFREV] h on h.DocEntry = d.DocEntry " +
                     "  where ((h.U_Year = {0} and h.U_Periodo <= {1}) or (h.U_Year < {0}))        " +
                     "    and d.U_ActCode = '{2}' ", 
                     'Select Month(max(h."U_Fecha")) "Mes", Year(max(h."U_Fecha")) "Year", count(*) "cant" ' +
                     '   from "@VID_AFREVD" d inner join "@VID_AFREV" h on h."DocEntry" = d."DocEntry"     ' +
                     '  where ((h."U_Year" = {0} and h."U_Periodo" <= {1}) or (h."U_Year" < {0}))          ' +
                     '    and d."U_ActCode" = ''{2}'' ');
            s := string.Format(s, nxYr.ToString ,nxPr.ToString, System.String(oActivosData.GetProperty('U_ActCode')));
            oLog.outlog("3874 - " + s);
            oRecordActividad.DoQuery(s);
            minYrRv := 0;
            minPrRv := 0;
            if (System.Int32(oRecordActividad.Fields.Item('cant').Value) > 0) and (not Revalorizado) then begin
               minYrRv := System.Int32(oRecordActividad.Fields.Item('Year').Value);
               minPrRv := System.Int32(oRecordActividad.Fields.Item('Mes').Value);
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        "Select sum(U_Deprecia) Depreciacion  " +
                        "  from [@VID_AFAC]                   " +
                        " where Code = '{0}'                  " + 
                        "   and ((U_Year > {1}) or (U_Year = {1} and U_Periodo >= {2}))", 
                        'Select sum("U_Deprecia") "Depreciacion"  ' +
                        '  from "@VID_AFAC"                       ' +
                        ' where "Code" = ''{0}''                  ' + 
                        '   and (("U_Year" > {1}) or ("U_Year" = {1} and "U_Periodo" >= {2}))'); 
               s := string.Format(s, System.String(oActivosData.GetProperty('Code')), minYrRv.ToString ,minPrRv.ToString);
               oLog.outlog("3891 - " + s);
               oRecordActividad.DoQuery(s);
               DepDesdeReval := System.Double(oRecordActividad.Fields.Item('Depreciacion').Value);
               RevalorizadoAntes := true;
            end;

            //... Marcar ... VID_AFAD para el periodo como procesado
            ADICIONES_ANUALES := 0;
            ADICIONES_ANUALES_FINAN := 0;
            oActivosLines     := oActivosData.Child('VID_AFAD'); 
            for i:=0 to oActivosLines.Count - 1 do begin
               oActivosLinesData := oActivosLines.Item(i);

               // Excluye adiciones posteriores
               if (System.Int32(oActivosLinesData.GetProperty('U_Year')) > nxYr) or 
                  ((System.Int32(oActivosLinesData.GetProperty('U_Year')) = nxYr) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) > nxPr)) then
                  continue;

               // Excluye adiciones anteriores a revalorizacion
               if (System.Int32(oActivosLinesData.GetProperty('U_Year')) < minYrRv) or 
                  ((System.Int32(oActivosLinesData.GetProperty('U_Year')) = minYrRv) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < minPrRv)) then
                  continue;

               if (System.int32(oActivosLinesData.GetProperty('U_Year')) = nxYr) then begin 
                  ADICIONES_ANUALES := ADICIONES_ANUALES + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  ADICIONES_ANUALES_FINAN := ADICIONES_ANUALES_FINAN + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
               end;

               if (System.int32(oActivosLinesData.GetProperty('U_Year')) = nxYr) and (System.int32(oActivosLinesData.GetProperty('U_Periodo')) = nxPr) then begin
                  s := 'Y';
                  oActivosLinesData.SetProperty('U_Procesad', s);
                  ADICION_PERIODO := ADICION_PERIODO + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  ADICION_PERIODO_FINAN := ADICION_PERIODO_FINAN + System.Double(oActivosLinesData.GetProperty('U_Valor'));//**U_ValorAct
                  if (System.String(oParametrosData.GetProperty('U_AdicVdUt')).Trim = 'Y') then
                     ADIC_VUT_PERIODO := System.Int32(oActivosLinesData.GetProperty('U_PerVidUt'));
               end;
            end;
        
            // Determinar si debe depreciarse o no        
            Deprecia_Flag  := False;
            if (System.String(oActivosData.GetProperty('U_ConDepre')) = 'Y') and ((nxYr > U_NxYrDepr) or ((nxYr = U_NxYrDepr) and (nxPr >= U_NxPrDepr))) then 
               Deprecia_Flag := true;
            if (VIDA_UTIL <= 0) then
               Deprecia_Flag := False;

            if (System.String(oParametrosData.GetProperty('U_AdicVdUt')).Trim = 'Y') and (ADIC_VUT_PERIODO > 0) then
              VIDA_UTIL := VIDA_UTIL + ADIC_VUT_PERIODO;
           
            // Depreciar
            DEPREC_PERIODO      := 0;
                                
            if (Revalorizado) then begin
               U_CorAnuAc := U_RvNewVal;
            end;

            if (VIDA_UTIL > 0) and (Deprecia_Flag) then begin
               if (GlobalSettings.IFRSNativo) then begin //se usa financiero
                   if (Revalorizado) then
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES_FINAN) * U_PorResid) * UNID_DEPREC / VIDA_UTIL
                   else if (RevalorizadoAntes) then
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES_FINAN) * U_PorResid - DepDesdeReval) * UNID_DEPREC / VIDA_UTIL
                   else
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES_FINAN) * U_PorResid - U_DepAcum - U_DepreAnu) * UNID_DEPREC / VIDA_UTIL;
                end
                else begin
                   if (Revalorizado) then
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES) * U_PorResid) * UNID_DEPREC / VIDA_UTIL
                   else if (RevalorizadoAntes) then
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES) * U_PorResid - DepDesdeReval) * UNID_DEPREC / VIDA_UTIL
                   else
                      DEPREC_PERIODO := ((U_CorAnuAc + ADICIONES_ANUALES) * U_PorResid - U_DepAcum - U_DepreAnu) * UNID_DEPREC / VIDA_UTIL;
                end;
            end;
                
            // Depreciacion del mes
            perDep    := 0;
            if (Deprecia_Flag) then begin
               if (VIDA_UTIL > 0) then
                  perDep   := UNID_DEPREC
               else 
                  DEPREC_PERIODO := 0;
            end
            else 
               DEPREC_PERIODO := 0;
                
            s := 'N';
            oActivosLines     := oActivosData.Child('VID_AFAC');
            oActivosLinesData := oActivosLines.Add;

            //Obtener de consulta de activos, pasar como parametros
            if (Revalorizado) then begin
               oActivosData.SetProperty('U_CorAnuAc'  , U_CorAnuAc   );

               //ADICION_PERIODO   := 0;
               //ADIC_VUT_PERIODO  := 0;
               //ADICIONES_ANUALES := 0;

               oActivosLinesData.SetProperty('U_RvNewVUt'  , VIDA_UTIL   );
               oActivosLinesData.SetProperty('U_RvOldVUt'  , VIDA_UTIL_Ant   );
               oActivosLinesData.SetProperty('U_RvNewVal'  , U_RvNewVal   );
               oActivosLinesData.SetProperty('U_RvOldVal'  , U_RvOldVal   );
            end;

            var d : Double := 0.0;
            oActivosLinesData.SetProperty('U_Year'    , nxYr);
            oActivosLinesData.SetProperty('U_Periodo' , nxPr);
            oActivosLinesData.SetProperty('U_Deprecia', DEPREC_PERIODO);
            oActivosLinesData.SetProperty('U_DeprNom' , DEPREC_PERIODO);
            //oActivosLinesData.SetProperty('U_Adicion' , ADICION_PERIODO);//se cambio para guardar valor en Dolares en la Adicion y este valor es de Financiero
            oActivosLinesData.SetProperty('U_Adicion', ADICION_PERIODO_FINAN); 
            oActivosLinesData.SetProperty('U_PerVidUt', ADIC_VUT_PERIODO);
            oActivosLinesData.SetProperty('U_PerDepre', perDep);
            oActivosLinesData.SetProperty('U_PostFlag', s);
            oActivosLinesData.SetProperty('U_CorrActi', d);
            oActivosLinesData.SetProperty('U_CorrDepr', d);
            oActivosLinesData.SetProperty('U_CorrDepM', d);
        
            //............. Anual..........
        
            if (nxPr = 12) then begin
               nxYrIns := nxYr + 1;
               nxPrIns := 1;
            end
            else begin
               nxYrIns := nxYr;
               nxPrIns := nxPr + 1;
            end;
        
            if (nxPrIns = 1) then begin
               // actualizo información anual
               s := iif(GlobalSettings.RunningUnderSQLServer,
                        "Select isnull(sum(U_Deprecia),0) DeprYear " +
                        "  from [@VID_AFAC]                        " +
                        " where code = '{0}'                       " +
                        "   and U_Year = {1}                       ",
                        'Select ifnull(sum("U_Deprecia"),0) "DeprYear" ' +
                        '  from "@VID_AFAC"                            ' +
                        ' where "Code"   = ''{0}''                     ' + 
                        '   and "U_Year" =   {1}                       '); 
               s := string.Format(s, System.String(oActivosData.GetProperty('Code')), nxYr.ToString );
              oLog.OutLog('4032 - ' + s);
               oRecordActividad.DoQuery(s);
               if (oRecordActividad.EoF) then 
                  ValAux := 0
               else 
                  ValAux := System.Double(oRecordActividad.Fields.Item('DeprYear').Value);

               oActivosLines     := oActivosData.Child('VID_AFSA');
               oActivosLinesData := oActivosLines.Add;
               oActivosLinesData.SetProperty('U_Year'     , nxYr);
               oActivosLinesData.SetProperty('U_CurVal'   , U_CurVal);
               oActivosLinesData.SetProperty('U_DepAcum'  , U_DepAcum);
               oActivosLinesData.SetProperty('U_DepAnual' , DEPREC_PERIODO + ValAux);
               oActivosLinesData.SetProperty('U_DepAcumN' , DEPREC_PERIODO + ValAux);
               oActivosLinesData.SetProperty('U_Adicion'  , ADICIONES_ANUALES);
               oActivosLinesData.SetProperty('U_CorAnuAc' , U_CorAnuAc);
               oActivosLinesData.SetProperty('U_CorAnuDe' , d);
               oActivosLinesData.SetProperty('U_Bis33'    , d);
            end;
        
            oActivosData.SetProperty('U_DepreAnu',  System.Double( oActivosData.GetProperty('U_DepreAnu')) + DEPREC_PERIODO);
            oActivosData.SetProperty('U_DepAcumN',  System.Double( oActivosData.GetProperty('U_DepAcumN')) + DEPREC_PERIODO);
            oActivosData.SetProperty('U_AdicAnuC',  ADICIONES_ANUALES_FINAN);
            oActivosData.SetProperty('U_PerVidaU',  System.Int32( oActivosData.GetProperty('U_PerVidaU')) + ADIC_VUT_PERIODO );
            oActivosData.SetProperty('U_VidaUtil',  System.Int32( oActivosData.GetProperty('U_VidaUtil')) - perDep + ADIC_VUT_PERIODO);
            oActivosData.SetProperty('U_PerDepre',  System.Int32( oActivosData.GetProperty('U_PerDepre')) + perDep );
            oActivosData.SetProperty('U_PerDepYr',  System.Int32( oActivosData.GetProperty('U_PerDepYr')) + perDep );
            oActivosData.SetProperty('U_NextYear',  nxYrIns );
            oActivosData.SetProperty('U_NextPer' ,  nxPrIns );
            oActivosData.SetProperty('U_CorAnuAc',  U_CorAnuAc );
            oActivosData.SetProperty('U_CorAnuDe',  d );
            oActivosData.SetProperty('U_Bis33Fin',  d );
            oActivosData.SetProperty('U_ValResid',  d );
   finally
   end;
end;

method TRealizaProcesoAFS.ReversarProcesoFinanciero(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; vyear, vperiod : integer);
var
   s           : string;
   i           : Integer := 0;
   j           : Integer := 0;

   oActivosLines      : SAPbobsCOM.GeneralDataCollection;
   oActivosLinesData  : SAPbobsCOM.GeneralData;
   oActivosLines2     : SAPbobsCOM.GeneralDataCollection;
   oActivosLines2Data : SAPbobsCOM.GeneralData;
   
   oYearCambio        : integer := 9999;
   oPerCambio         : integer := 99;
   oPerDepYear        : integer := 0;
   oUsoDeVidaUtil     : integer := 0;
   oValor             : Double  := 0;
   oValor_residual    : double  := 0;
   oLineaEncontrada   : integer := -1;
begin
   try
         // Calculo para reversa en depreciacion por uso
         if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') then begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select top 1 h.U_Year, U_Periodo " +
                     "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                     " where (h.U_Year < {0} or (h.U_Year = {0} and h.U_Periodo < {1}))         " +
                     "   and (d.U_ActCode = '{2}' or d.U_GrpCode = '{3}')                       " + 
                     "   and (d.U_SVidaAct <> d.U_SVidaNew) " +
                     " order by U_YearPer desc              ",
                     'Select top 1 h."U_Year", "U_Periodo" ' +
                     '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                     ' where (h."U_Year" < {0} or (h."U_Year" = {0} and h."U_Periodo" < {1}))       ' +
                     '   and (d."U_ActCode" = ''{2}'' or d."U_GrpCode" = ''{3}'')                   ' + 
                     '   and (d."U_SVidaAct" <> d."U_SVidaNew") ' +
                     ' order by "U_YearPer" desc              ');
            s := string.Format(s, vyear.ToString, vperiod.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
             oRecordActividad.DoQuery(s);
             if (not oRecordActividad.EoF) then begin
                oYearCambio := System.Int32(oRecordActividad.Fields.Item("U_Year").Value);
                oPerCambio  := System.Int32(oRecordActividad.Fields.Item("U_Periodo").Value);
             end;
         end;

         oActivosLines     := oActivosData.Child('VID_AFAC');
         while i <= oActivosLines.Count - 1 do  begin
            oActivosLinesData := oActivosLines.Item(i);
            if ((System.Int32(oActivosLinesData.GetProperty('U_Year')) < vyear) or
                (System.Int32(oActivosLinesData.GetProperty('U_Year')) = vyear) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < vperiod))
               and
               ((System.Int32(oActivosLinesData.GetProperty('U_Year')) > oYearCambio) or
                (System.Int32(oActivosLinesData.GetProperty('U_Year')) = oYearCambio) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) >= oPerCambio)) 
            then begin
               oUsoDeVidaUtil := oUsoDeVidaUtil + System.Int32(oActivosLinesData.GetProperty('U_PerDepre'));
            end;
            if (vperiod = 1) and (System.Int32(oActivosLinesData.GetProperty('U_Year')) = vyear-1) then
               oPerDepYear := oPerDepYear + System.int32(oActivosLinesData.GetProperty('U_PerDepre'));

            if (System.Int32(oActivosLinesData.GetProperty('U_Year')) <> vyear) then begin
                inc(i);
                Continue;
            end
            else if (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < vperiod) then begin
               oValor      := oValor + System.Double(oActivosLinesData.GetProperty('U_Adicion'));
               oPerDepYear := oPerDepYear + System.int32(oActivosLinesData.GetProperty('U_PerDepre'));
               inc(i);
               Continue;
            end;
            oLineaEncontrada := i;
            inc(i);
         end;

         if (oLineaEncontrada > -1) then begin
             oActivosLinesData := oActivosLines.Item(oLineaEncontrada);

             oActivosData.SetProperty('U_CorAnuAc',  System.Double( oActivosData.GetProperty('U_CorAnuAc')) - System.Double(oActivosLinesData.GetProperty('U_CorrActi')) );
             oActivosData.SetProperty('U_DepreAnu',  System.Double( oActivosData.GetProperty('U_DepreAnu')) - System.Double(oActivosLinesData.GetProperty('U_Deprecia'))
                                                                                                            - System.Double(oActivosLinesData.GetProperty('U_CorrDepM')) );
             oActivosData.SetProperty('U_DepAcumN',  System.Double( oActivosData.GetProperty('U_DepAcumN')) - System.Double(oActivosLinesData.GetProperty('U_DeprNom' )) );
             oActivosData.SetProperty('U_CorAnuDe',  System.Double( oActivosData.GetProperty('U_CorAnuDe')) - System.Double(oActivosLinesData.GetProperty('U_CorrDepr')) );

             oActivosData.SetProperty('U_PerVidaU',  System.Int32 ( oActivosData.GetProperty('U_PerVidaU')) - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             oActivosData.SetProperty('U_VidaUtil',  System.Int32 ( oActivosData.GetProperty('U_VidaUtil')) + System.Int32(oActivosLinesData.GetProperty('U_PerDepre'))
                                                                                                            - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             oActivosData.SetProperty('U_PerDepre',  System.Int32 ( oActivosData.GetProperty('U_PerDepre')) - System.Int32(oActivosLinesData.GetProperty('U_PerDepre')) );
             oActivosData.SetProperty('U_PerDepYr',  oPerDepYear );

             oActivosData.SetProperty('U_AdicAnuC',  oValor );

             oValor_residual := 0;
             if (System.Int32 ( oActivosData.GetProperty('U_VidaUtil') )  <= 0) then
                oValor_residual := System.Double(oParametrosData.GetProperty('U_ValResid'));
             oActivosData.SetProperty('U_ValResid',  oValor_residual );

             oActivosLines.Remove(oLineaEncontrada);

             oActivosLines2     := oActivosData.Child('VID_AFAD');
             for j := 0 to oActivosLines2.Count - 1 do  begin
                oActivosLines2Data := oActivosLines2.Item(j);
                if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) or (System.Int32(oactivosLines2Data.GetProperty('U_Periodo')) <> vperiod) then
                   Continue;

                s := 'N';
                oActivosLines2Data.SetProperty('U_Procesad', s);
             end;

            if (vperiod = 1) then begin
                oActivosLines2 := oActivosData.Child('VID_AFSA');

               for j := 0 to oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear-1) then
                     Continue;

                  oActivosData.SetProperty('U_CurVal'   ,  System.Double( oActivosLines2Data.GetProperty('U_CurVal'  )) );
                  oActivosData.SetProperty('U_DepAcum'  ,  System.Double( oActivosLines2Data.GetProperty('U_DepAcum' )) );
                  oActivosData.SetProperty('U_CorAnuAc' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuAc')) );
                  oActivosData.SetProperty('U_DepreAnu' ,  System.Double( oActivosLines2Data.GetProperty('U_DepAnual')) );
                  oActivosData.SetProperty('U_AdicAnuC' ,  System.Double( oActivosLines2Data.GetProperty('U_Adicion' )) );//financiero
                  oActivosData.SetProperty('U_Bis33Fin' ,  System.Double( oActivosLines2Data.GetProperty('U_Bis33'   )) );
                  oActivosData.SetProperty('U_CorAnuDe' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuDe')) );
                  oActivosData.SetProperty('U_PerDepYr' ,  oPerDepYear);
               end;
            end
            else begin
               oValor := 0;
               oActivosData.SetProperty('U_Bis33Fin' ,  oValor );
            end;

            if (vperiod = 12) then begin
                oActivosLines2     := oActivosData.Child('VID_AFSA');

               j := 0;
               while j <= oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) then begin
                     inc(j);
                     Continue;
                  end;

                   oActivosLines2.Remove(j);
               end;
            end;

            if (System.String(oActivosData.GetProperty('U_TipoDep')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ISNULL(d.U_Uso,0) Uso, ISNULL(U_ActCode, '') ActCode, ISNULL(U_GrpCode, '') GrpCode, ISNULL(d.U_SVidaAct,0) SVidaAct, " +
                        "       ISNULL(d.U_SVidaNew,0) SVidaNew, ISNULL(d.U_RVidaAct,0) RVidaAct, ISNULL(d.U_RVidaNew,0) RVidaNew " +
                        "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                        " where h.U_Year    = {0} " + 
                        "   and h.U_Periodo = {1} " + 
                        "   and (d.U_ActCode = '{2}'  or d.U_GrpCode = '{3}' )" + 
                        " order by 3",
                        'Select IFNULL(d."U_Uso",0) "Uso", IFNULL("U_ActCode", '') "ActCode", IFNULL("U_GrpCode", '') "GrpCode", IFNULL(d."U_SVidaAct",0) "SVidaAct", ' +
                        '       IFNULL(d."U_SVidaNew",0) "SVidaNew", IFNULL(d."U_RVidaAct",0) "RVidaAct", IFNULL(d."U_RVidaNew",0) "RVidaNew" ' +
                        '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                        ' where h."U_Year"    = {0} ' + 
                        '   and h."U_Periodo" = {1} ' + 
                        '   and (d."U_ActCode" = ''{2}''  or d."U_GrpCode" = ''{3}'' )' + 
                        ' order by 3');
               s := string.Format(s, vyear.ToString, vperiod.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
               oRecordActividad.DoQuery(s);
               if (not oRecordActividad.EoF) then begin
                   s := System.String(oRecordActividad.Fields.Item('GrpCode').Value);
                   if (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then
                      if (System.Int32(oRecordActividad.Fields.Item('SVidaNew').Value) <> System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value)) then begin
                         if (System.String(oRecordActividad.Fields.Item('GrpCode').Value) <> '') then begin
                            oGruposData.SetProperty('U_VidaUtil', System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value));
                         end;
                         oActivosData.SetProperty('U_VidaUtil', System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value) - oUsoDeVidaUtil);
                         oActivosData.SetProperty('U_PerVidaU', System.Int32(oRecordActividad.Fields.Item('SVidaAct').Value));
                      end;
               end;
            end;
         end;
   finally
   end;
end;

method TRealizaProcesoAFS.ReversarProcesoReferencial(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordActividad: SAPbobsCOM.RecordSet; vyear, vperiod : integer);
var
   s           : string;
   i           : Integer := 0;
   j           : Integer := 0;
   
   oActivosLines      : SAPbobsCOM.GeneralDataCollection;
   oActivosLinesData  : SAPbobsCOM.GeneralData;
   oActivosLines2     : SAPbobsCOM.GeneralDataCollection;
   oActivosLines2Data : SAPbobsCOM.GeneralData;
   oRst               : SAPbobsCOM.RecordSet;

   oYearCambio        : integer := 9999;
   oPerCambio         : integer := 99;
   oPerDepYear        : integer := 0;
   oUsoDeVidaUtil     : integer := 0;
   oValor             : Double  := 0;
   oLineaEncontrada   : integer := -1;
begin
   try
        oRst   := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         // Calculo para reversa en depreciacion por uso
         if (System.String(oActivosData.GetProperty('U_TipoDepR')) = 'U') then begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                     "Select top 1 h.U_Year, U_Periodo " +
                     "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                     " where (h.U_Year < {0} or (h.U_Year = {0} and h.U_Periodo < {1}))         " +
                     "   and (d.U_ActCode = '{2}' or d.U_GrpCode = '{3}')                       " + 
                     "   and (d.U_RVidaAct <> d.U_RVidaNew) " +
                     " order by U_YearPer desc              ",
                     'Select top 1 h."U_Year", "U_Periodo" ' +
                     '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                     ' where (h."U_Year" < {0} or (h."U_Year" = {0} and h."U_Periodo" < {1}))       ' +
                     '   and (d."U_ActCode" = ''{2}'' or d."U_GrpCode" = ''{3}'')                   ' + 
                     '   and (d."U_RVidaAct" <> d."U_RVidaNew") ' +
                     ' order by "U_YearPer" desc              ');
            s := string.Format(s, vyear.ToString, vperiod.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
             oRecordActividad.DoQuery(s);
             if (not oRecordActividad.EoF) then begin
                oYearCambio := System.Int32(oRecordActividad.Fields.Item("U_Year").Value);
                oPerCambio  := System.Int32(oRecordActividad.Fields.Item("U_Periodo").Value);
             end;
         end;

         oActivosLines     := oActivosData.Child('VID_AFACR');
         while i <= oActivosLines.Count - 1 do  begin
            oActivosLinesData := oActivosLines.Item(i);
            if ((System.Int32(oActivosLinesData.GetProperty('U_Year')) < vyear) or
                (System.Int32(oActivosLinesData.GetProperty('U_Year')) = vyear) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < vperiod))
               and
               ((System.Int32(oActivosLinesData.GetProperty('U_Year')) > oYearCambio) or
                (System.Int32(oActivosLinesData.GetProperty('U_Year')) = oYearCambio) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) >= oPerCambio)) 
            then begin
               oUsoDeVidaUtil := oUsoDeVidaUtil + System.Int32(oActivosLinesData.GetProperty('U_PerDepre'));
            end;
            if (vperiod = 1) and (System.Int32(oActivosLinesData.GetProperty('U_Year')) = vyear-1) then
               oPerDepYear := oPerDepYear + System.int32(oActivosLinesData.GetProperty('U_PerDepre'));

            if (System.Int32(oActivosLinesData.GetProperty('U_Year')) <> vyear) then begin
                inc(i);
                Continue;
            end
            else if (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < vperiod) then begin
               oValor      := oValor + System.Double(oActivosLinesData.GetProperty('U_Adicion'));
               oPerDepYear := oPerDepYear + System.int32(oActivosLinesData.GetProperty('U_PerDepre'));
               inc(i);
               Continue;
            end;
            oLineaEncontrada := i;
            inc(i);
         end;

         if (oLineaEncontrada > -1) then begin
             oActivosLinesData := oActivosLines.Item(oLineaEncontrada);

             oActivosData.SetProperty('U_CorAnuAR',  System.Double( oActivosData.GetProperty('U_CorAnuAR')) - System.Double(oActivosLinesData.GetProperty('U_CorrActi')) );
             oActivosData.SetProperty('U_DepreAnR',  System.Double( oActivosData.GetProperty('U_DepreAnR')) - System.Double(oActivosLinesData.GetProperty('U_Deprecia'))
                                                                                                            - System.Double(oActivosLinesData.GetProperty('U_CorrDepM')) );
             oActivosData.SetProperty('U_DepAcuRN',  System.Double( oActivosData.GetProperty('U_DepAcuRN')) - System.Double(oActivosLinesData.GetProperty('U_DeprNom' )) );
             oActivosData.SetProperty('U_AdicAnuR',  System.Double( oActivosData.GetProperty('U_AdicAnuR')) - System.Double(oActivosLinesData.GetProperty('U_Adicion' )) );//**

             s := iif(GlobalSettings.RunningUnderSQLServer,
                        "SELECT ISNULL(U_Adicion,0.0) 'Adicion'
                          FROM [@VID_AFAC]
                         WHERE Code = '{0}'
                           AND U_Year = {1}
                           ANd U_Periodo = {2}",
                        'SELECT IFNULL("U_Adicion",0.0) "Adicion" ' +
                        '  FROM "@VID_AFAC" '+
                        ' WHERE "Code" = ''{0}'' '+
                        '   AND "U_Year" = {1} ' +
                        '   ANd "U_Periodo" = {2}'); 
             s := String.Format(s, System.String(oActivosData.GetProperty('Code')), vyear, vperiod); 
             oRst.DoQuery(s);
             var ValorFinan := 0.0;
             if oRst.RecordCount > 0 Then
                 ValorFinan := System.Double(oRst.Fields.Item('Adicion').Value); 
             
             ValorFinan := System.Double( oActivosData.GetProperty('U_AdicAnuC')) - ValorFinan;
             if vperiod > 1 then
                oActivosData.SetProperty('U_AdicAnuC',  ValorFinan);

             oActivosData.SetProperty('U_CorAnuDR',  System.Double( oActivosData.GetProperty('U_CorAnuDR')) - System.Double(oActivosLinesData.GetProperty('U_CorrDepr')) );

             oActivosData.SetProperty('U_PerVidaR',  System.Int32 ( oActivosData.GetProperty('U_PerVidaR')) - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             oActivosData.SetProperty('U_VidaUtiR',  System.Int32 ( oActivosData.GetProperty('U_VidaUtiR')) + System.Int32(oActivosLinesData.GetProperty('U_PerDepre'))
                                                                                                            - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             oActivosData.SetProperty('U_PRrDepre',  System.Int32 ( oActivosData.GetProperty('U_PRrDepre')) - System.Int32(oActivosLinesData.GetProperty('U_PerDepre')) );
             oActivosData.SetProperty('U_PRrDepYr',  oPerDepYear );

             oActivosData.SetProperty('U_AdicAnuR',  oValor );
   
            if (System.Int32 ( oActivosData.GetProperty('U_VidaUtiR')) <= 0) then 
               oActivosData.SetProperty('U_ValResid', System.Double(oParametrosData.GetProperty('U_ValResid')));

             oActivosLines.Remove(oLineaEncontrada);

             oActivosLines2     := oActivosData.Child('VID_AFAD');
             for j := 0 to oActivosLines2.Count - 1 do  begin
                oActivosLines2Data := oActivosLines2.Item(j);
                if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) or (System.Int32(oactivosLines2Data.GetProperty('U_Periodo')) <> vperiod) then
                   Continue;

                s := 'N';
                oActivosLines2Data.SetProperty('U_Procesad', s);
             end;



            if (System.String(oActivosData.GetProperty('U_TipoDepR')) = 'U') and (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then begin
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ISNULL(d.U_Uso,0) Uso, ISNULL(U_ActCode, '') ActCode, ISNULL(U_GrpCode, '') GrpCode, ISNULL(d.U_SVidaAct,0) SVidaAct, " +
                        "       ISNULL(d.U_SVidaNew,0) SVidaNew, ISNULL(d.U_RVidaAct,0) RVidaAct, ISNULL(d.U_RVidaNew,0) RVidaNew " +
                        "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                        " where h.U_Year    = {0} " + 
                        "   and h.U_Periodo = {1} " + 
                        "   and (d.U_ActCode = '{2}'  or d.U_GrpCode = '{3}' )" + 
                        " order by 3",
                        'Select IFNULL(d."U_Uso",0) "Uso", IFNULL("U_ActCode", '') "ActCode", IFNULL("U_GrpCode", '') "GrpCode", IFNULL(d."U_SVidaAct",0) "SVidaAct", ' +
                        '       IFNULL(d."U_SVidaNew",0) "SVidaNew", IFNULL(d."U_RVidaAct",0) "RVidaAct", IFNULL(d."U_RVidaNew",0) "RVidaNew" ' +
                        '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                        ' where h."U_Year"    = {0} ' + 
                        '   and h."U_Periodo" = {1} ' + 
                        '   and (d."U_ActCode" = ''{2}''  or d."U_GrpCode" = ''{3}'' )' + 
                        ' order by 3');
               s := string.Format(s, vyear.ToString, vperiod.ToString, System.String(oActivosData.GetProperty('U_ActCode')), System.String(oActivosData.GetProperty('U_ItmGrpCd')) );
                oRecordActividad.DoQuery(s);
                if (not oRecordActividad.EoF) then begin
                   s := System.String(oRecordActividad.Fields.Item('GrpCode').Value);
                   if (System.String(oParametrosData.GetProperty('U_DepUsoAc')) = 'Y') then
                      if (System.Int32(oRecordActividad.Fields.Item('RVidaNew').Value) <> System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value)) then begin
                         if (System.String(oRecordActividad.Fields.Item('GrpCode').Value) <> '') then begin
                            oGruposData.SetProperty('U_VidaUtiR', System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value));
                         end;
                         oActivosData.SetProperty('U_VidaUtiR', System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value) - oUsoDeVidaUtil);
                         oActivosData.SetProperty('U_PerVidaR', System.Int32(oRecordActividad.Fields.Item('RVidaAct').Value));
                      end;
                end;
             end;

            if (vperiod = 1) then begin
                oActivosLines2     := oActivosData.Child('VID_AFSAR');

               for j := 0 to oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear-1) then
                     Continue;

                  oActivosData.SetProperty('U_CurValR'  ,  System.Double( oActivosLines2Data.GetProperty('U_CurVal'  )) );
                  oActivosData.SetProperty('U_DepAcuR'  ,  System.Double( oActivosLines2Data.GetProperty('U_DepAcum' )) );
                  oActivosData.SetProperty('U_CorAnuAR' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuAc')) );
                  oActivosData.SetProperty('U_DepreAnR' ,  System.Double( oActivosLines2Data.GetProperty('U_DepAnual')) );
                  oActivosData.SetProperty('U_AdicAnuR' ,  System.Double( oActivosLines2Data.GetProperty('U_Adicion' )) );
                  oActivosData.SetProperty('U_Bis33'    ,  System.Double( oActivosLines2Data.GetProperty('U_Bis33'   )) );
                  oActivosData.SetProperty('U_CorAnuDR' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuDe')) );
                  oActivosData.SetProperty('U_PRrDepYr' ,  oPerDepYear);
               end;
            end
            else begin
               oValor := 0;
               oActivosData.SetProperty('U_Bis33' ,  oValor );
            end;

            if (vperiod = 12) then begin
                oActivosLines2     := oActivosData.Child('VID_AFSAR');

               j := 0;
               while j <= oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) then begin
                     inc(j);
                     Continue;
                  end;

                   oActivosLines2.Remove(j);
               end;
            end;
         end;
   finally
   end;
end;

method TRealizaProcesoAFS.ReversarProcesoIFRS(var oActivosData, oParametrosData, oGruposData: SAPbobsCOM.GeneralData; var oRecordSet: SAPbobsCOM.RecordSet; vyear, vperiod : integer);
var
   oActivosLines      : SAPbobsCOM.GeneralDataCollection;
   oActivosLinesData  : SAPbobsCOM.GeneralData;
   oActivosLines2     : SAPbobsCOM.GeneralDataCollection;
   oActivosLines2Data : SAPbobsCOM.GeneralData;
   oRst               : SAPbobsCOM.RecordSet;
   oValor             : Double;
   oNewVal            : Double;
   oNewVidUt          : Integer;
   i, j               : integer;
   s : String;
begin
   try
         oRst   := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oActivosLines     := oActivosData.Child('VID_AFAC');
         s := System.String(oActivosData.GetProperty('Code'));
         i        := 0;
         oValor := 0;
         while i <= oActivosLines.Count - 1 do  begin
            oActivosLinesData := oActivosLines.Item(i);
            if (System.Int32(oActivosLinesData.GetProperty('U_Year')) <> vyear) or (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) <> vperiod) then begin
//                if (System.String(oActivosData.GetProperty('U_ActTipo')) = 'I') then
//                begin
//                    if (System.Int32(oActivosLinesData.GetProperty('U_Year')) = vyear) and (System.Int32(oactivosLinesData.GetProperty('U_Periodo')) < vperiod) then 
//				              oValor := oValor + System.Double(oActivosLinesData.GetProperty('U_Adicion'));
//                
//                    oActivosData.SetProperty('U_AdicAnuC',  oValor);
//                end;
                inc(i);
                Continue;
            end;

            oNewVal   := System.Double(oActivosLinesData.GetProperty('U_RvNewVal'));
            oNewVidUt := System.Int32(oActivosLinesData.GetProperty('U_RvNewVUt'));

             if (oNewVal <> 0) then begin
                oActivosData.SetProperty('U_CorAnuAc', System.Double ( oActivosLinesData.GetProperty('U_RvOldVal')));
             end;
             if (oNewVidUt <> 0) then begin
                oActivosData.SetProperty('U_VidaUtil', System.Int32 ( oActivosLinesData.GetProperty('U_RvOldVUt')));
             end;
             if (oNewVidUt = 0) then begin
                oActivosData.SetProperty('U_VidaUtil',  System.Int32 ( oActivosData.GetProperty('U_VidaUtil')) + System.Int32(oActivosLinesData.GetProperty('U_PerDepre'))
                                                                                                               - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             end;

             oActivosData.SetProperty('U_PerVidaU',  System.Int32 ( oActivosData.GetProperty('U_PerVidaU')) - System.Int32(oActivosLinesData.GetProperty('U_PerVidUt')) );
             oActivosData.SetProperty('U_PerDepre',  System.Int32 ( oActivosData.GetProperty('U_PerDepre')) - System.Int32(oActivosLinesData.GetProperty('U_PerDepre')) );
             oActivosData.SetProperty('U_PerDepYr',  System.Int32 ( oActivosData.GetProperty('U_PerDepYr')) - System.Int32(oActivosLinesData.GetProperty('U_PerDepre')) );

             oActivosData.SetProperty('U_DepreAnu',  System.Double( oActivosData.GetProperty('U_DepreAnu')) - System.Double(oActivosLinesData.GetProperty('U_Deprecia')) );
             oActivosData.SetProperty('U_DepAcumN',  System.Double( oActivosData.GetProperty('U_DepAcumN')) - System.Double(oActivosLinesData.GetProperty('U_DeprNom' )) );

             oActivosLines.Remove(i);

             oActivosLines2     := oActivosData.Child('VID_AFAD');
             for j := 0 to oActivosLines2.Count - 1 do  begin
                oActivosLines2Data := oActivosLines2.Item(j);
                if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) or (System.Int32(oactivosLines2Data.GetProperty('U_Periodo')) <> vperiod) then
                   Continue;

                s := 'N';
                oActivosLines2Data.SetProperty('U_Procesad', s);
             end;

             if (vperiod = 1) then begin
                oActivosLines2 := oActivosData.Child('VID_AFSA');

                for j := 0 to oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear-1) then
                     Continue;

                  oActivosData.SetProperty('U_CurVal'   ,  System.Double( oActivosLines2Data.GetProperty('U_CurVal'  )) );
                  oActivosData.SetProperty('U_DepAcum'  ,  System.Double( oActivosLines2Data.GetProperty('U_DepAcum' )) );
                  oActivosData.SetProperty('U_DepAcumN' ,  System.Double( oActivosLines2Data.GetProperty('U_DepAcumN')) );
                  oActivosData.SetProperty('U_CorAnuAc' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuAc')) );
                  oActivosData.SetProperty('U_DepreAnu' ,  System.Double( oActivosLines2Data.GetProperty('U_DepAnual')) );
//                  if (System.String(oActivosData.GetProperty('U_ActTipo')) = 'I') then
//                    oActivosData.SetProperty('U_AdicAnuC' ,  0)
//                  else
                    oActivosData.SetProperty('U_AdicAnuC' ,  System.Double( oActivosLines2Data.GetProperty('U_Adicion' )) );
                  oActivosData.SetProperty('U_CorAnuDe' ,  System.Double( oActivosLines2Data.GetProperty('U_CorAnuDe')) );
                  oActivosData.SetProperty('U_PerDepYr' ,  System.Int32 ( 0 ));
               end;
             end;

            if (vperiod = 12) then begin
                oActivosLines2     := oActivosData.Child('VID_AFSA');

               j := 0;
               while j <= oActivosLines2.Count - 1 do  begin
                  oActivosLines2Data := oActivosLines2.Item(j);
                  if (System.Int32(oActivosLines2Data.GetProperty('U_Year')) <> vyear) then begin
                     inc(j);
                     Continue;
                  end;

                   oActivosLines2.Remove(j);
               end;
            end;
         end;
/////////*
        if (System.String(oActivosData.GetProperty('U_ActTipo')) = 'I') then
        begin
            s := iif(GlobalSettings.RunningUnderSQLServer,
                        "SELECT ISNULL(U_Adicion,0.0) 'Adicion'
                          FROM [@VID_AFAC]
                         WHERE Code = '{0}'
                           AND U_Year = {1}
                           ANd U_Periodo = {2}",
                        'SELECT IFNULL("U_Adicion",0.0) "Adicion" ' +
                        '  FROM "@VID_AFAC" '+
                        ' WHERE "Code" = ''{0}'' '+
                        '   AND "U_Year" = {1} ' +
                        '   ANd "U_Periodo" = {2}'); 
             s := String.Format(s, System.String(oActivosData.GetProperty('Code')), vyear, vperiod); 
             oRst.DoQuery(s);
             var ValorFinan := 0.0;
             if oRst.RecordCount > 0 Then
                 ValorFinan := System.Double(oRst.Fields.Item('Adicion').Value); 
             ValorFinan := System.Double( oActivosData.GetProperty('U_AdicAnuC')) - ValorFinan;
             oActivosData.SetProperty('U_AdicAnuC',  ValorFinan);
        end;
//////-----------
         if (oActivosLines.Count = 0) then 
            oActivosData.SetProperty('U_CorAnuAc' ,  0.0 );
/////////*
   finally
   end;
end;

method TRealizaProcesoAFS.ActualizarRevalIFRS( vYear, vPeriod, day: integer; var oRecordSet: SAPbobsCOM.Recordset);
var
   oSql       : string;
   oJE        : SAPbobsCOM.JournalEntries;
   oValor     : double;
   oValorSys  : double;
   errCode    : integer;
   errMsg     : string;
   s          : string;
   orst       : SAPbobsCOM.Recordset;
   U_TasaCnMS_Ope: String;
   oPostSysCu : Boolean;
   oTasaFija  : Boolean;
begin
  oTasaFija  := Utils.oTasaFija;
  oPostSysCu := Utils.oPostSysCu;
  // tasa de cambio
  if (not oPostSysCu) then 
      U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                  " / CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                  ' / CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ')
  else
      U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                  " * CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                  ' * CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ');

   orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               " Select Case when rd.U_NewVal > rd.U_ValAnt then 'Rea' else 'Det' end Tipo,
                        Case when rd.U_NewVal > rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end CtaIFRS,  
                        a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, 
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end) Monto,
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end " + U_TasaCnMS_Ope + ") MontoSys
                   from [@VID_AFAS] a inner join [@VID_AFREVD] rd on a.U_ActCode = rd.U_ActCode
                                      inner join [@VID_AFREV]  rh on rh.DocEntry = rd.DocEntry
                                      inner join [@VID_AFAC]   ac on ac.Code = a.Code and ac.U_Year = {0} and ac.U_Periodo = {1}
                  where rh.U_Year = {2} and rh.U_Periodo = {3} 
                  group by  Case when rd.U_NewVal> rd.U_ValAnt then 'Rea' else 'Det' end,
                            Case when rd.U_NewVal> rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end,  
                            a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5 ",
               ' Select Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end "Tipo",                  ' +
               '        Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end "CtaIFRS", ' +
               '        a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",              ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end) "Monto", ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end  ' + U_TasaCnMS_Ope +  ') "MontoSys" ' +
               '   from "@VID_AFAS" a inner join "@VID_AFREVD" rd on a."U_ActCode" = rd."U_ActCode"              ' + 
               '                      inner join "@VID_AFREV"  rh on rh."DocEntry" = rd."DocEntry"               ' +
               '                      inner join "@VID_AFAC"   ac on ac."Code" = a."Code" and ac."U_Year" = {0} and ac."U_Periodo" = {1} ' +
               '  where rh."U_Year" = {2} and rh."U_Periodo" = {3}       ' +
               '  group by  Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end,               ' +   
               '            Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end, ' +
               '            a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5" ');
   oSql := String.Format(oSql, vYear.ToString(), vPeriod.ToString(), vYear.ToString(), vPeriod.ToString());
   oRecordset.DoQuery(oSql);

   while (not oRecordSet.EoF) do begin
      try
         oJE := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
         oJE.ReferenceDate   := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.TaxDate         := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.DueDate         := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.Reference       := "Rval " + vYear.ToString + '-' + vPeriod.ToString;
         oJE.Reference2      := "Rval - IFRS";
         oJE.Memo            := "Rval - IFRS";
         oJE.ProjectCode     := system.String( oRecordset.Fields.Item('U_Project' ).Value );
                               
         oValor := system.Double( oRecordset.Fields.Item('Monto' ).Value );
         if (not oPostSysCu) then
            oValor    := Utils.AjustarDecimalesSUM(oValor)
         else
            oValor    := Utils.AjustarDecimalesSUMSys(oValor);

         oValorSys := system.Double( oRecordset.Fields.Item('MontoSys' ).Value );

         if (oValor = 0) then begin
            oRecordSet.MoveNext();
            exit;
         end;
         oJE.Lines.SetCurrentLine(0);

         oJE.Lines.AccountCode := system.String( oRecordset.Fields.Item('U_CtaActFi' ).Value );

         oJE.Lines.ProjectCode := oJE.ProjectCode;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, system.String( oRecordset.Fields.Item('U_CtaActFi' ).Value )); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJE.Lines.CostingCode  := system.String( oRecordset.Fields.Item('U_ProfitCt' ).Value );
            oJE.Lines.CostingCode2 := system.String( oRecordset.Fields.Item('U_ProfitC2' ).Value );
            oJE.Lines.CostingCode3 := system.String( oRecordset.Fields.Item('U_ProfitC3' ).Value );
            oJE.Lines.CostingCode4 := system.String( oRecordset.Fields.Item('U_ProfitC4' ).Value );
            oJE.Lines.CostingCode5 := system.String( oRecordset.Fields.Item('U_ProfitC5' ).Value );
         end;

         if (not oPostSysCu) then 
         begin    
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.Debit   := oValor
                else
                   oJE.Lines.Credit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.Credit   := oValor
                else
                   oJE.Lines.Debit  := oValor * (-1);
             end;
             if (oTasaFija) then
             begin
                 if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.Creditsys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.DebitSys  := oValorSys * (-1);
                 end;
             end;
         end
         else begin
            oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
            if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.FCDebit   := oValor
                else
                   oJE.Lines.FCCredit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.FCCredit   := oValor
                else
                   oJE.Lines.FCDebit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                 if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.Creditsys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.Debitsys  := oValorSys * (-1);
                 end;
             end;
         end;
         oJE.Lines.Add;
         oJE.Lines.SetCurrentLine(1);
                 
         oJE.Lines.AccountCode := system.String( oRecordset.Fields.Item('CtaIFRS' ).Value );

         oJE.Lines.ProjectCode := oJE.ProjectCode;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, system.String( oRecordset.Fields.Item('CtaIFRS' ).Value )); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJE.Lines.CostingCode  := system.String( oRecordset.Fields.Item('U_ProfitCt' ).Value );
            oJE.Lines.CostingCode2 := system.String( oRecordset.Fields.Item('U_ProfitC2' ).Value );
            oJE.Lines.CostingCode3 := system.String( oRecordset.Fields.Item('U_ProfitC3' ).Value );
            oJE.Lines.CostingCode4 := system.String( oRecordset.Fields.Item('U_ProfitC4' ).Value );
            oJE.Lines.CostingCode5 := system.String( oRecordset.Fields.Item('U_ProfitC5' ).Value );
         end;
         
         if (not oPostSysCu) then begin
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.Credit   := oValor
                else
                   oJE.Lines.Debit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.Debit   := oValor
                else
                   oJE.Lines.Credit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                 if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.Debitsys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorsys
                    else
                       oJE.Lines.DebitSys  := oValorSys * (-1);
                 end;
             end;
         end
         else begin
             oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.FCCredit   := oValor
                else
                   oJE.Lines.FCDebit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.FCDebit   := oValor
                else
                   oJE.Lines.FCCredit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                 if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValor > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.Creditsys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorsys
                    else
                       oJE.Lines.Debitsys  := oValorSys * (-1);
                 end;
             end;
         end;

         if (oJE.Lines.Count < 2) then
            exit;

         errCode := oJE.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_contabilzacion] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;

      finally
         FSBOF._ReleaseCOMObject(oJE);
      end;

      oRecordSet.MoveNext();
   end;
end;

method TRealizaProcesoAFS.ReversarRevalIFRS( vYear, vPeriod, day: integer; var oRecordSet: SAPbobsCOM.Recordset; oCode, oGroup: string; oByCode: boolean);
var
   oSql       : string;
   s          : string;
   oJE        : SAPbobsCOM.JournalEntries;
   oValor     : double;
   oValorSys  : Double;
   errCode    : integer;
   errMsg     : string;
   orst       : SAPbobsCOM.Recordset;
   U_TasaCnMS_Ope: String;
   oPostSysCu : Boolean;
   oTasaFija  : Boolean;
begin
   orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset)); 

   oTasaFija  := Utils.oTasaFija;
    oPostSysCu := Utils.oPostSysCu;
    // tasa de cambio
    if (not oPostSysCu) then 
        U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                    " / CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                    ' / CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ')
    else
        U_TasaCnMS_Ope := iif(GlobalSettings.RunningUnderSQLServer, 
                                    " * CASE WHEN isnull(a.U_TasaCnMS,0) = 0 THEN 1 ELSE a.U_TasaCnMS END ",
                                    ' * CASE WHEN ifnull(a."U_TasaCnMS",0) = 0 THEN 1 ELSE a."U_TasaCnMS" END ');

   if (oByCode) then begin
      s := iif(GlobalSettings.RunningUnderSQLServer, " and Code = '{0}' ", ' and "Code" = ''{0}'' ');
      s := string.Format(s, oCode);
   end
   else begin
      s := iif(GlobalSettings.RunningUnderSQLServer, 
               " and a.code in (select code from [@vid_afas] where u_ItmGrpCd = '{0}') ", 
               ' and a."Code" in (select "Code" from "@VID_AFAS" where "U_ItmGrpCd" = ''{0}'') '); 
      s := string.Format(s, oGroup);
   end;

   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               " Select Case when rd.U_NewVal > rd.U_ValAnt then 'Rea' else 'Det' end Tipo,
                        Case when rd.U_NewVal > rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end CtaIFRS,  
                        a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5,
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end) Monto,
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end " + U_TasaCnMS_Ope + ") MontoSys
                   from [@VID_AFAS] a inner join [@VID_AFREVD] rd on a.U_ActCode = rd.U_ActCode
                                      inner join [@VID_AFREV]  rh on rh.DocEntry = rd.DocEntry
                                      inner join [@VID_AFAC]   ac on ac.Code = a.Code and ac.U_Year = {0} and ac.U_Periodo = {1}
                  where rh.U_Year = {2} and rh.U_Periodo = {3} 
                    and ac.u_postflag = 'Y' " +
                s +
               "   group by  Case when rd.U_NewVal> rd.U_ValAnt then 'Rea' else 'Det' end,
                            Case when rd.U_NewVal> rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end,  
                            a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5 "                ,
               ' Select Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end "Tipo",                  ' +
               '        Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end "CtaIFRS", ' +
               '        a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",                 ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end) "Monto", ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end ' + U_TasaCnMS_Ope + ') "MontoSys" ' +
               '   from "@VID_AFAS" a inner join "@VID_AFREVD" rd on a."U_ActCode" = rd."U_ActCode"              ' + 
               '                      inner join "@VID_AFREV"  rh on rh."DocEntry" = rd."DocEntry"               ' +
               '                      inner join "@VID_AFAC"   ac on ac."Code" = a."Code" and ac."U_Year" = {0} and ac."U_Periodo" = {1} ' +
               '  where rh."U_Year" = {2} and rh."U_Periodo" = {3}                                               ' +
               '    and ac."U_PostFlag" = ''Y''                                                                    ' +
                s +
               '  group by  Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end,               ' +   
               '            Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end, ' +
               '            a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5" ');
   oSql := String.Format(oSql, vYear.ToString(), vPeriod.ToString(), vYear.ToString(), vPeriod.ToString());
   oRecordset.DoQuery(oSql);

   while (not oRecordSet.EoF) do begin
      try
         oJE := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
         oJE.ReferenceDate   := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.TaxDate         := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.DueDate         := TMultiFunctions.EncodeDate(vYear, vPeriod, Day);
         oJE.Reference       := "RRval " + vYear.ToString + '-' + vPeriod.ToString;
         oJE.Reference2      := "RRval - IFRS";
         oJE.Memo            := "RRval - IFRS";
         oJE.ProjectCode     := system.String( oRecordset.Fields.Item('U_Project' ).Value );
                               
         oValor := system.Double( oRecordset.Fields.Item('Monto' ).Value );
         if (not oPostSysCu) then
            oValor    := Utils.AjustarDecimalesSUM(oValor)
         else
            oValor    := Utils.AjustarDecimalesSUMSys(oValor);
         oValorSys := system.Double( oRecordset.Fields.Item('MontoSys' ).Value );

         if (oValor = 0) then begin
            oRecordSet.MoveNext();
            exit;
         end;
         oJE.Lines.SetCurrentLine(0);

         oJE.Lines.AccountCode := system.String( oRecordset.Fields.Item('CtaIFRS' ).Value );

         oJE.Lines.ProjectCode := oJE.ProjectCode;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, system.String( oRecordset.Fields.Item('CtaIFRS' ).Value )); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJE.Lines.CostingCode  := system.String( oRecordset.Fields.Item('U_ProfitCt' ).Value );
            oJE.Lines.CostingCode2 := system.String( oRecordset.Fields.Item('U_ProfitC2' ).Value );
            oJE.Lines.CostingCode3 := system.String( oRecordset.Fields.Item('U_ProfitC3' ).Value );
            oJE.Lines.CostingCode4 := system.String( oRecordset.Fields.Item('U_ProfitC4' ).Value );
            oJE.Lines.CostingCode5 := system.String( oRecordset.Fields.Item('U_ProfitC5' ).Value );
         end;
         
         if (not oPostSysCu) then begin
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.Debit   := oValor
                else
                   oJE.Lines.Credit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.Credit   := oValor
                else
                   oJE.Lines.Debit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.CreditSys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.DebitSys  := oValorSys * (-1);
                 end;
             end;
         end
         else 
         begin
           oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
           if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then 
           begin
                if (oValor > 0) then
                   oJE.Lines.FCDebit   := oValor
                else
                   oJE.Lines.FCCredit  := oValor * (-1);
             end
             else 
             begin
                if (oValor > 0) then
                   oJE.Lines.FCCredit   := oValor
                else
                   oJE.Lines.FCDebit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then 
                 begin
                      if (oValorSys > 0) then
                         oJE.Lines.DebitSys   := oValorSys
                      else
                         oJE.Lines.CreditSys  := oValorSys * (-1);
                   end
                   else 
                   begin
                      if (oValorSys > 0) then
                         oJE.Lines.CreditSys   := oValorSys
                      else
                         oJE.Lines.DebitSys  := oValorSys * (-1);
                   end;
             end;
         end;

         oJE.Lines.Add;
         oJE.Lines.SetCurrentLine(1);
                 
         oJE.Lines.AccountCode := system.String( oRecordset.Fields.Item('U_CtaActFi' ).Value );

         oJE.Lines.ProjectCode := oJE.ProjectCode;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, system.String( oRecordset.Fields.Item('U_CtaActFi' ).Value )); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJE.Lines.CostingCode  := system.String( oRecordset.Fields.Item('U_ProfitCt' ).Value );
            oJE.Lines.CostingCode2 := system.String( oRecordset.Fields.Item('U_ProfitC2' ).Value );
            oJE.Lines.CostingCode3 := system.String( oRecordset.Fields.Item('U_ProfitC3' ).Value );
            oJE.Lines.CostingCode4 := system.String( oRecordset.Fields.Item('U_ProfitC4' ).Value );
            oJE.Lines.CostingCode5 := system.String( oRecordset.Fields.Item('U_ProfitC5' ).Value );
         end;
         
         if (not oPostSysCu) then 
         begin
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.Credit   := oValor
                else
                   oJE.Lines.Debit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.Debit   := oValor
                else
                   oJE.Lines.Credit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.DebitSys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.CreditSys  := oValorSys * (-1);
                 end;
             end;
         end
         else begin
             oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
             if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                if (oValor > 0) then
                   oJE.Lines.FCCredit   := oValor
                else
                   oJE.Lines.FCDebit  := oValor * (-1);
             end
             else begin
                if (oValor > 0) then
                   oJE.Lines.FCDebit   := oValor
                else
                   oJE.Lines.FCCredit  := oValor * (-1);
             end;

             if (oTasaFija) then
             begin
                if (system.String( oRecordset.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                    if (oValorSys > 0) then
                       oJE.Lines.CreditSys   := oValorSys
                    else
                       oJE.Lines.DebitSys  := oValorSys * (-1);
                 end
                 else begin
                    if (oValorSys > 0) then
                       oJE.Lines.DebitSys   := oValorSys
                    else
                       oJE.Lines.CreditSys  := oValorSys * (-1);
                 end;
             end;
         end;

         if (oJE.Lines.Count < 2) then
            exit;

         errCode := oJE.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_contabilzacion] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;

      finally
         FSBOF._ReleaseCOMObject(oJE);
      end;

      oRecordSet.MoveNext();
   end;
end;

method TRealizaProcesoAFS.ActualizarVentaIFRS();
begin

end;

end.
