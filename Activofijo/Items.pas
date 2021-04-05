namespace AF_IFRS.Items;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.vkBaseForm, 
  VisualD.SBOGeneralService,
  VisualD.vkFormInterface,
  Visuald.MultiFunctions;

type
  TItems = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    oCompanyService: SAPbobsCOM.CompanyService;
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method TItems.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:   SAPbouiCOM.Form;
   oItm:    SAPbouiCOM.Item;
   oItmRef: SAPbouiCOM.Item;
   oSTx:    SAPbouiCOM.StaticText;
   oCombo:  SAPbouiCOM.ComboBox;
   oChk:    SAPbouiCOM.CheckBox;
   oTop:    Int32;
   oSql:    string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   try
      oForm   := FSBOApp.Forms.Item(uid);

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      oItmRef := FSBOf.getFormItem(oForm, '214');
      oTop    := oItmRef.Top;

      // Es Activo Fijo - SBO 9.0
      oCompanyService := company.GetCompanyService;
      if (oCompanyService.GetCompanyInfo.Version >= 900000) then begin
         oItmRef := FSBOf.getFormItem(oForm, '12');
 
         oItm    := oForm.Items.Add('VID_AFAF', BoFormItemTypes.it_CHECK_BOX);
         oItm.Visible := true;
         oItm.Left   := oItmRef.Left;
         oItm.Top    := oTop;
         oItm.Height := oItmRef.Height;
         oItm.Width  := oItmRef.Width;
         oChk := CheckBox(oItm.Specific);
         oChk.DataBind.SetBound(true, 'OITM', 'U_VID_AFAF');
         oChk.Caption := "Activo Fijo"; //GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Btn_Activo_Fijo];

         oItmRef := FSBOf.getFormItem(oForm, '34');
         oItm := FSBOf.getFormItem(oForm, 'VID_AFAF');
         oItm.Left := oItmRef.Left;
         oItm := FSBOf.getFormItem(oForm, '12');
         oItm.Left := oItmRef.Left;
         oItm := FSBOf.getFormItem(oForm, '13');
         oItm.Left := oItmRef.Left;
         oItm := FSBOf.getFormItem(oForm, '14');
         oItm.Left := oItmRef.Left;
         oItmRef := FSBOf.getFormItem(oForm, '107');

         // GrupoAF
         oItm    := oForm.Items.Add('VID_AFGr', BoFormItemTypes.it_COMBO_BOX);
         oItm.Visible := false;
         oItm.Left   := oItmRef.Left;
         oItm.Top    := oTop;
         oItm.Height := oItmRef.Height;
         oItm.Width  := oItmRef.Width;
         oItm.DisplayDesc := true;
         oItm.LinkTo := '107';
         oCombo := ComboBox(oItm.Specific);
         oCombo.DataBind.SetBound(true, 'OITM', 'U_VID_AFGr');

         oItmRef := FSBOf.getFormItem(oForm, '106');

         // Titulo
         oItm    := oForm.Items.Add('tx_GrupoAF', BoFormItemTypes.it_STATIC);
         oItm.Visible := false;
         oItm.Left   := oItmRef.Left;
         oItm.Top    := oTop;
         oItm.Height := oItmRef.Height;
         oItm.Width  := oItmRef.Width;
         oItm.LinkTo := 'VID_AFGr';
         oSTx := StaticText(oItm.Specific);
         if (FCmpny.language = BoSuppLangs.ln_English) then
            oSTx.Caption := 'Asset class'
         else
            oSTx.Caption := 'Grupo de AF';
      end
      else begin
         oItmRef := FSBOf.getFormItem(oForm, '34');

         // GrupoAF
         oItm    := oForm.Items.Add('VID_AFGr', BoFormItemTypes.it_COMBO_BOX);
         oItm.Visible := false;
         oItm.Left   := oItmRef.Left;
         oItm.Top    := oTop;
         oItm.Height := oItmRef.Height;
         oItm.Width  := oItmRef.Width;
         oItm.DisplayDesc := true;
         oCombo := ComboBox(oItm.Specific);
         oCombo.DataBind.SetBound(true, 'OITM', 'U_VID_AFGr');

         oItmRef := FSBOf.getFormItem(oForm, '52');

         // Titulo
         oItm    := oForm.Items.Add('tx_GrupoAF', BoFormItemTypes.it_STATIC);
         oItm.Visible := false;
         oItm.Left   := oItmRef.Left;
         oItm.Top    := oTop;
         oItm.Height := oItmRef.Height;
         oItm.Width  := oItmRef.Width;
         oItm.LinkTo := 'VID_AFGr';
         oSTx := StaticText(oItm.Specific);
         if (FCmpny.language = BoSuppLangs.ln_English) then
            oSTx.Caption := 'Asset class'
         else
            oSTx.Caption := 'Grupo de AF';
      end;

      // Grupos activos
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select code, name from [@VID_AFGR] order by name", 
                  'Select "Code" code, "Name" name from "@VID_AFGR" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('VID_AFGr').Specific), var oRecordSet, true);


   except
      on e:exception do begin
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;


method   TItems.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm     : SAPbouiCOM.Form;
   oDS       : SAPbouiCOm.DBDataSource;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   oForm := FSBOApp.Forms.Item(pVal.FormUID);
   oDS   := oForm.DataSources.DBDataSources.Item('OITM');

   if (oCompanyService.GetCompanyInfo.Version >= 900000) then begin
      if (oForm.Mode = BoFormMode.fm_FIND_MODE) then
         oForm.Items.Item('VID_AFAF').Enabled := false
      else
         oForm.Items.Item('VID_AFAF').Enabled := true;
   end;

   try
      if (oCompanyService.GetCompanyInfo.Version >= 900000) then begin
         if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) and (pVal.ActionSuccess) then begin
            if (oDS.GetValue('U_VID_AFAF', 0) = 'Y') then begin
               oForm.Items.Item('VID_AFGr'  ).Visible := True;
               oForm.Items.Item('tx_GrupoAF').Visible := True;
            end
            else begin
               oForm.Items.Item('VID_AFGr'  ).Visible := false;
               oForm.Items.Item('tx_GrupoAF').Visible := false;
            end;
         end;
      end
      else begin
         if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) and (pVal.ActionSuccess) then begin
            if (oDS.GetValue('AssetItem', 0) = 'Y') then begin
               oForm.Items.Item('VID_AFGr'  ).Visible := True;
               oForm.Items.Item('tx_GrupoAF').Visible := True;
            end
            else begin
               oForm.Items.Item('VID_AFGr'  ).Visible := false;
               oForm.Items.Item('tx_GrupoAF').Visible := false;
            end;
         end;
      end
   except
      on e: exception do begin
         if (FCmpny.InTransaction) then
            FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TItems.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm     : SAPbouiCOM.Form;
   oDS       : SAPbouiCOm.DBDataSource;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);
   try
      oForm := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);
      if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (BusinessObjectInfo.BeforeAction = false) and (BusinessObjectInfo.ActionSuccess) then begin
         // Show-Hide, grupo activo fijo
         if (oCompanyService.GetCompanyInfo.Version >= 900000) then begin
            oDS := oForm.DataSources.DBDataSources.Item('OITM');
            if (oDS.GetValue('U_VID_AFAF', 0) = 'Y') then begin
               oForm.Items.Item('VID_AFGr'  ).Visible := True;
               oForm.Items.Item('tx_GrupoAF').Visible := True;
            end
            else begin
               oForm.Items.Item('VID_AFGr'  ).Visible := false;
               oForm.Items.Item('tx_GrupoAF').Visible := false;
            end;
         end
         else begin
            oDS := oForm.DataSources.DBDataSources.Item('OITM');
            if (oDS.GetValue('AssetItem', 0) = 'Y') then begin
               oForm.Items.Item('VID_AFGr'  ).Visible := True;
               oForm.Items.Item('tx_GrupoAF').Visible := True;
            end
            else begin
               oForm.Items.Item('VID_AFGr'  ).Visible := false;
               oForm.Items.Item('tx_GrupoAF').Visible := false;
            end;
         end;
      end;
   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormDataEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

end.
