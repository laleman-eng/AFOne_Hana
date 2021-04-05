namespace AF_IFRS.ActivoObj;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  VisualD.untlog,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.MainObjBase,
  VisualD.vkBaseForm, 
  VisualD.vkFormInterface, 
  VisualD.MultiFunctions,
  Visuald.ReportWindowFr,
  System.Collections.Generic,
  System.IO,
  System.Xml;
  
type
  TActivo = public class(TMainObjBase)
  public
    method    AddMenus; override;
    method    DeleteMenus;
    method    MenuEventExt(oForms: List<object>; var pVal: MenuEvent; var BubbleEvent: boolean); override;
    method    ItemEventExt(oIvkForm: IvkFormInterface; oForms: List<object>; LstFrmUID, FormUID: String; var pVal: ItemEvent; var BubbleEvent: boolean): IvkFormInterface; override;
  end;

implementation

uses
  System.Globalization,
  AF_IFRS.Parametros,
  AF_IFRS.GrupoArticulos,
  AF_IFRS.UbicacionesActivos,
  AF_IFRS.TrasladoActivos,
  AF_IFRS.UsoActivos,
  AF_IFRS.Ciudades,
  AF_IFRS.Comunas,
  AF_IFRS.DarDeBaja,
  AF_IFRS.Activos,
  AF_IFRS.Adiciones,
  AF_IFRS.ProcesoAF,
  AF_IFRS.FiltroReportes,
  AF_IFRS.Items,
  AF_IFRS.FacturaCompra,
  AF_IFRS.GoodsIssue,
  AF_IFRS.ActivosIFRS,
  AF_IFRS.RevalorizacionIFRS,
  AF_IFRS.ActivosVentaIFRS,
  AF_IFRS.AgrupacionIFRS,
  AF_IFRS.DefSeriesParaLotes,
  VisualD.MenuConfFr,
  AF_IFRS.ActualizarProyectos,
  VisualD.ChooseFromListSubQuery
  ;

method TActivo.AddMenus;
var
   oXMLDoc    : System.XML.XmlDocument;
   StrAux     : WideString;
   Path       : Widestring;
   oRecordSet : SAPbobsCOM.Recordset;
   s          : string;
   oSql       : string;
Begin
   try
      oXMLDoc   := new System.XML.XmlDocument;
      oRecordSet:=RecordSet(SBOCompany.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      oSql := iif(GlobalSettings.RunningUnderSQLServer, "Select U_PlanIFRS from [@VID_AFPA]", 'Select "U_PlanIFRS" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      try
         GlobalSettings.IFRSNativo := false;

         if (GlobalSettings.IFRSActivo) then begin
            if ((System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim = '') or (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim = nil)) then begin
               GlobalSettings.IFRSActivo := False;
               if (SBOCompany.language = BoSuppLangs.ln_English) then
                  GlobalSettings.MenuFile := '\MenuR_EN.xml'
               else
                  GlobalSettings.MenuFile := '\MenuR.xml';
            end
            else if (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim = 'Nativo') or (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim = 'Native') then begin
               if (SBOCompany.language = BoSuppLangs.ln_English) then
                  GlobalSettings.MenuFile := '\MenuE_EN.xml'
               else
                  GlobalSettings.MenuFile := '\MenuE.xml';
               GlobalSettings.IFRSNativo := True
            end
            else begin
               if (SBOCompany.language = BoSuppLangs.ln_English) then
                   GlobalSettings.MenuFile := '\Menu_EN.xml'
               else
                   GlobalSettings.MenuFile := '\Menu.xml';
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select Code, Name from [@VID_OACTH] where Code = '{0}'", 
                           'Select "Code", "Name" from "@VID_OACTH" where "Code" = ''{0}''');
               oSql := string.Format(oSql, System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim);
               oRecordSet.DoQuery(oSql);
               GlobalSettings.IFRS_Plan_Code := System.String(oRecordSet.Fields.Item('Code').Value).Trim;
               GlobalSettings.IFRS_Plan_Name := System.String(oRecordSet.Fields.Item('Name').Value).Trim;
            end;
         end
         else begin
            if (SBOCompany.language = BoSuppLangs.ln_English) then
               GlobalSettings.MenuFile := '\MenuR_EN.xml'
            else
               GlobalSettings.MenuFile := '\MenuR.xml';
         end;

         if (SBOCompany.language = BoSuppLangs.ln_English) then
            GlobalSettings.APP_Message_Arr := 1
         else
            GlobalSettings.APP_Message_Arr := 0;

         Path := System.Environment.CurrentDirectory + '\Menus';


         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select U_Srvr, U_Usr, U_Pw, U_UsrAdm, U_AppPath from [@VID_MENUSU]", 
                     'Select "U_Srvr", "U_Usr", "U_Pw", "U_UsrAdm", "U_AppPath" from "@VID_MENUSU"');
         oRecordSet.DoQuery(oSql);

         s := System.String(oRecordSet.Fields.Item('U_AppPath').Value);
         if (s.Trim <> '') then begin
            s := s + 'Menus';
            if (System.IO.File.Exists(s + GlobalSettings.MenuFile)) then
               Path := s;
         end;

          oXMLDoc.Load(Path + GlobalSettings.MenuFile);
          StrAux    := oXMLDoc.InnerXml;
          StrAux    := StrAux.Replace('sImagePath', Path  );
          SBOApplication.LoadBatchActions(var StrAux);
      except
         on  e: exception do
             oLog.OutLog('Add Menus err: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   finally
       SBOfunctions._ReleaseCOMObject(oRecordSet);
   end;
End;

method TActivo.DeleteMenus;
var
   oXMLDoc  : System.XML.XmlDocument;
   XMLList  : System.XML.XmlNodeList;
   StrAux   : WideString;
   Path     : Widestring;
Begin
      oXMLDoc := new System.XML.XmlDocument;

      try
         Path := System.Environment.CurrentDirectory + '\Menus';
         oXMLDoc.Load(Path + GlobalSettings.MenuFile);
         XMLList := oXMLDoc.GetElementsByTagName("Menu");

         for node: XmlNode in XMLList do begin
            node.Attributes.RemoveNamedItem("Checked");
            node.Attributes.RemoveNamedItem("Enabled");
            node.Attributes.RemoveNamedItem("Position");
            node.Attributes.RemoveNamedItem("FatherUID");
            node.Attributes.RemoveNamedItem("String");
            node.Attributes.RemoveNamedItem("Type");
            node.Attributes.RemoveNamedItem("Image");
         end;

         StrAux    := oXMLDoc.InnerXml;
         StrAux    := StrAux.Replace('action type="add"','action type="remove"');
         StrAux    := StrAux.Replace('/>','></Menu>');
         SBOApplication.LoadBatchActions(var StrAux);
      except
         on  e: exception do
             oLog.OutLog('Delete Menus err: ' + e.Message + ' ** Trace: ' + e.StackTrace)
      end;
End;

// Se definen las formas, y se agragan a la coleccion de formas global
// o se llama alguna accion especifica asociada al menu
method TActivo.MenuEventExt(oForms: List<object>; var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm: IvkFormInterface;
   ReportPath : String; 
begin
   try
      
      if GlobalSettings.RunningUnderSQLServer then
       ReportPath := Path.GetDirectoryName(TMultiFunctions.ParamStr(0)) +'\Reports\'
      else
       ReportPath := Path.GetDirectoryName(TMultiFunctions.ParamStr(0)) +'\Reports HANA\';

      oForm := nil;
      if (not pVal.BeforeAction) then begin

         if (pVal.MenuUID ='VID_AFPA_1') then begin
            oForm := IvkFormInterface(new TParametros);
            TParametros(oForm).oActivoObj := self;
         end
         else if (pVal.MenuUID ='VID_AFPA_2') then begin
            oForm := IvkFormInterface(new TGrupoArticulos);
         end
         else if (pVal.MenuUID ='VID_AFPA_4') then begin
            oForm := IvkFormInterface(new TUbicacionesActivos);
            TUbicacionesActivos(oForm).LocCode := '';
         end
         else if (pVal.MenuUID ='VID_AFPA_5') then begin
            oForm := IvkFormInterface(new TCiudades);
         end
         else if (pVal.MenuUID ='VID_AFPA_6') then begin
            oForm := IvkFormInterface(new TComunas);
         end
         else if (pVal.MenuUID ='VID_AFPA_7') then begin
            oForm := IvkFormInterface(new TDefSeriesParaLotes);
         end

         else if (pVal.MenuUID = 'VID_AFAC_1') then begin
            oForm := IvkFormInterface(new TActivos);
            TActivos(oForm).ooForms := oForms;
         end
         else if (pVal.MenuUID = 'VID_AFAC_2') then begin
            oForm := IvkFormInterface(new TActivosIFRS);
            TActivosIFRS(oForm).ooForms := oForms;
         end

         else if (pVal.MenuUID ='VID_AFPR_1') then begin
            oForm := IvkFormInterface(new TProcesoAF);
            end
         else if (pVal.MenuUID ='VID_AFPR_2') then begin
            oForm := IvkFormInterface(new TAdiciones);
            end
         else if (pVal.MenuUID ='VID_AFPR_3') then begin
            oForm := IvkFormInterface(new TDarDeBaja);
            end
         else if (pVal.MenuUID ='VID_AFPR_4') then begin
            oForm := IvkFormInterface(New TTrasladoActivos);
            TTrasladoActivos(oForm).ooForms := oForms;
         end
         else if (pVal.MenuUID ='VID_AFPR_5') then begin
            oForm := IvkFormInterface(New TUsoActivos);
            TUsoActivos(oForm).ooForms := oForms;
         end
         else if (pVal.MenuUID ='VID_AFPR_6') then begin
            oForm := IvkFormInterface(New TActualizarProyectos);
            TActualizarProyectos(oForm).ooForms := oForms;
         end

//         else if (pVal.MenuUID ='VID_AFPR_1_1') then begin
//            oForm := IvkFormInterface(new TProcesoAFIFRS);
//            end
         else if (pVal.MenuUID ='VID_AFPR_5_1') then begin
            oForm := IvkFormInterface(New TRevalorizacionIFRS);
            TRevalorizacionIFRS(oForm).ooForms := oForms;
         end
         else if (pVal.MenuUID ='VID_AFPR_7') then begin
            oForm := IvkFormInterface(New TAgrupacionIFRS);
            TAgrupacionIFRS(oForm).ooForms := oForms;
         end

         else if (pVal.MenuUID ='VID_AFRE_1') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptListadoGeneral.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 1;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_2') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptDepreciacionMensualRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 2;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_9') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptDepreciacionMensualFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 2;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_3') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptResumenDepreciacionRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 3;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_10') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptResumenDepreciacionFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 3;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_4') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptCuentasdeActivosRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 4;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_11') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptCuentasdeActivosFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 4;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_5') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptAnalisisdeActivosRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 5;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_12') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptAnalisisdeActivosFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 5;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_6') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptNotasContables.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 6;
            TFiltroReportes(oForm).ooForms := oForms;
            }
            end
         else if (pVal.MenuUID ='VID_AFRE_7') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptDepreciacionFuturaRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 7;
            TFiltroReportes(oForm).ooForms := oForms;
            }
         end
         else if (pVal.MenuUID ='VID_AFRE_13') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptDepreciacionFuturaFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 7;
            TFiltroReportes(oForm).ooForms := oForms;
            }
         end
         else if (pVal.MenuUID ='VID_AFRE_8') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptHistorialTraslados.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
            { SQL original
            oForm := IvkFormInterface(New TFiltroReportes);
            TFiltroReportes(oForm).Report  := 8;
            TFiltroReportes(oForm).ooForms := oForms;
            }
         end
         else if (pVal.MenuUID ='VID_AFRE_14') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptAnalisisdeActivos_AñoFin.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
         end
         else if (pVal.MenuUID ='VID_AFRE_15') then begin
            GlobalSettings.CrystalReportFileName:=ReportPath+'RptAnalisisdeActivos_AñoRef.rpt';                
            try 
                SBOApplication.Menus.Item('4873').Activate; 
            except 
            //on e: Exception do oLog.OutLog("SBO_App.Menus.Item('4873').Activate " + e.Message + ' ** Trace: ' + e.StackTrace);
            end;
         end

         else if (pVal.MenuUID = 'VID__ExtMenu_001_2') then begin
            oForm := IvkFormInterface(New TMenuConfFr);
            end
         ;
         if(oForm <> nil) then begin
           Var App   : SAPbouiCOM.Application:=SBOApplication;
           Var Cmpny : SAPbobsCOM.Company:=SBOCompany;
           Var SboF  : VisualD.SBOFunctions.CSBOFunctions := SBOFunctions;
           Var Glob  : VisualD.GlobalVid.TGlobalVid:=GlobalSettings;
           if (oForm.InitForm( SBOFunctions.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\',var App,var Cmpny,var SboF,var Glob)) then
              oForms.Add(oForm)
           else 
           begin
              SBOApplication.Forms.Item(oForm.getFormId).Close;
              oForm := nil;
           end;
         end;
      end;
   except
      on e: exception do begin
            oLog.OutLog('MenuEventExt: ' + e.Message + ' ** Trace: ' + e.StackTrace);
            SBOApplication.MessageBox(e.message, 1, 'Ok','','');  // Captura errores no manejados
     end;
   end;
end;

method TActivo.ItemEventExt(oIvkForm: IvkFormInterface; oForms: List<object>; LstFrmUID, FormUID: String; var pVal: ItemEvent; var BubbleEvent: boolean): IvkFormInterface;
var
   i     : integer;
   oForm : SAPbouiCOM.Form;
begin
   result:= inherited ItemEventExt(oIvkForm,oForms,LstFrmUID, FormUID, var pVal, var BubbleEvent);   

   try
      if (result <> nil) then
         exit
      else if (oIvkForm <> nil) then begin
         result := oIvkForm;
         exit;
      end;


      // CFL Extendido (Enmascara el CFL estandar)
      if (pVal.BeforeAction) and (pVal.EventType = BoEventTypes.et_FORM_LOAD) and (LstFrmUID <> '') then
      begin
         try
            oForm := SBOApplication.Forms.Item(LstFrmUID);
         except
            oForm := nil;
         end;
      end;

      if (oForm <> nil) then
         if ((SAPbouiCOM.Form(SBOApplication.Forms.Item(LstFrmUID)).TypeEx = 'VID_mAFREV')) and (oIvkForm = nil) then
            if (pVal.FormTypeEx='10170') or (pVal.FormTypeEx='9999') then 
            begin
               for i:=0 to (oForms.Count-1) do
               begin
                  if (IvkFormInterface(oForms[i]).manageId(LstFrmUID)) and (TvkBaseForm(oForms[i]).CFLExtendido) then
                  begin
                     Result := IvkFormInterface(New TChooseFromListSubQuery);
                     TChooseFromListSubQuery(result).Query :=  TRevalorizacionIFRS(IvkFormInterface(oForms[i])).QueryCFL;
                     TChooseFromListSubQuery(result).MultiSelect := false;
                     TChooseFromListSubQuery(result).LevelGroup  := 0;
                     TChooseFromListSubQuery(result).Titulo      := 'Seleccionar activos a revalorizar';
                     break;
                  end;
               end;
            end;

      // llamar a formas del sistema SBO

      // Items
      if (not pVal.BeforeAction) and (pVal.EventType = BoEventTypes.et_FORM_LOAD) then begin
         if (pVal.FormTypeEx = '150') and (oIvkForm = nil) then begin
            result := IvkFormInterface(New TItems);
            TItems(result).ooForms := oForms;
         end;
      end;
      // Factura de compra
      if (not pVal.BeforeAction) and (pVal.EventType = BoEventTypes.et_FORM_LOAD) then begin
         if (pVal.FormTypeEx = '141') and (oIvkForm = nil) then begin
            result := IvkFormInterface(New TFacturaCompra);
            TFacturaCompra(result).ooForms := oForms;
         end;
      end;
      // Salida de mercaderia
      if (not pVal.BeforeAction) and (pVal.EventType = BoEventTypes.et_FORM_LOAD) then begin
         if (pVal.FormTypeEx = '720') and (oIvkForm = nil) then begin
            result := IvkFormInterface(New TGoodsIssue);
            TGoodsIssue(result).ooForms := oForms;
         end;
      end;

      if (result <> nil) then begin      
        Var App   : SAPbouiCOM.Application:=SBOApplication;
        Var Cmpny : SAPbobsCOM.Company:=SBOCompany;
        Var SboF  : VisualD.SBOFunctions.CSBOFunctions := SBOFunctions;
        Var Glob  : VisualD.GlobalVid.TGlobalVid:=GlobalSettings;
        if (result.InitForm( pVal.FormUID, 'forms\',var App,var Cmpny,var SboF,var Glob)) then
          oForms.Add(result)
        else begin
          SBOApplication.Forms.Item(result.getFormId).Close;
          result := nil;
        end;
      end;

   except
      on e: exception do begin
            result := nil;
            oLog.OutLog('ItemEventExt: ' + e.Message + ' ** Trace: ' + e.StackTrace);
            SBOApplication.MessageBox(e.message, 1, 'Ok','','');  // Captura errores no manejados
     end;
   end;
end;

end.
