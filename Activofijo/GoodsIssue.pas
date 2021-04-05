namespace AF_IFRS.GoodsIssue;

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
  TGoodsIssue = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    method   SetFormAdquision(oDocEntry: string);
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization,
  AF_IFRS.AdquisicionActivos;

method TGoodsIssue.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:   SAPbouiCOM.Form;
   oItm:    SAPbouiCOM.Item;
   oItmRef: SAPbouiCOM.Item;
   oBtn:    SAPbouiCOM.Button;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   try
      oForm   := FSBOApp.Forms.Item(uid);

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      oItmRef := FSBOf.getFormItem(oForm, '2');

      // Flete
      oItm    := oForm.Items.Add('btn_AF', BoFormItemTypes.it_BUTTON);
      oItm.Visible := false;
      oItm.Left   := oItmRef.Left + oItmRef.Width + oItmRef.Width + 5;
      oItm.Top    := oItmRef.Top;
      oItm.Height := oItmRef.Height;
      oItm.Width  := oItmRef.Width;
      oBtn := Button(oItm.Specific);
      oBtn.Caption := GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Btn_Activo_Fijo];

   except
      on e:exception do begin
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;


method   TGoodsIssue.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm     : SAPbouiCOM.Form;
   oSql      : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   oForm  := FSBOApp.Forms.Item(pVal.FormUID);
   try

      if (oForm.Mode <> BoFormMode.fm_ADD_MODE) and (not oForm.Items.Item('btn_AF').Visible) then
         oForm.Items.Item('btn_AF').Visible := true;

      if (oForm.Mode = BoFormMode.fm_ADD_MODE) and (oForm.Items.Item('btn_AF').Visible) then
         oForm.Items.Item('btn_AF').Visible := false;

      if (oForm.Mode <> BoFormMode.fm_ADD_MODE) and (oForm.Mode <> BoFormMode.fm_FIND_MODE) and (oForm.Mode <> BoFormMode.fm_VIEW_MODE) then begin
         if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.ItemUID = 'btn_AF') and (pVal.BeforeAction = false) then begin
            // POPUP ventana de adquisicion
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select DocEntry from OIGE where docnum = {0}", 
                        'Select "DocEntry" from OIGE where "DocNum" = {0}');
            oSql := string.Format(oSql, EditText(FSBOf.getFormItem(oForm, '7').Specific).Value);
            oRecordSet.DoQuery(oSql);
            SetFormAdquision(System.Int32(oRecordSet.Fields.Item('DocEntry').Value).ToString);
         end;
      end;

   except
      on e: exception do begin
         if (FCmpny.InTransaction) then
            FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TGoodsIssue.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   DocEntry  : string;
   i,f       : integer;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);
   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_ADD) and (BusinessObjectInfo.BeforeAction = false) and (BusinessObjectInfo.ActionSuccess) then begin
      // POPUP ventana de adquisicion

      DocEntry := BusinessObjectInfo.ObjectKey;
      i := DocEntry.LastIndexOf('<DocEntry>') + 10;
      f := DocEntry.LastIndexOf('</DocEntry>');
      DocEntry := DocEntry.Substring(i, f-i);

      SetFormAdquision(DocEntry);
   end;
end;

method  TGoodsIssue.SetFormAdquision(oDocEntry: string);
var
   oFormIvk  : IvkFormInterface;
   oFormAux  : SAPbouiCOM.Form;
   i         : Integer;
   s         : String;
begin
      for i:=0 to self.ooForms.Count-1 do begin
         oFormIvk := IvkFormInterface(ooForms[i]);
         s := oFormIvk.getFormId;
         try
            oFormAux := FSBOApp.Forms.Item(s);
         except
            continue;
         end;
         if (oFormAux.TypeEx = 'VID_AFADQ') then 
            if (TAdquisicionActivos(oFormIvk).Tipodoc =  'S')  and (TAdquisicionActivos(oFormIvk).DocEntry  = oDocEntry) then
               exit; 
      end;

      oFormIvk := IvkFormInterface(New TAdquisicionActivos);

      if(oFormIvk<>nil) then begin
         TAdquisicionActivos(oFormIvk).Tipodoc   := 'S';
         TAdquisicionActivos(oFormIvk).DocEntry  := oDocEntry;
         TAdquisicionActivos(oFormIvk).ooForms   := ooForms;
         if (oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings)) then
            ooForms.Add(oFormIvk)
         else begin
            try
               FSBOApp.Forms.Item(oFormIvk.getFormId).Close;
               oFormIvk := nil;
            except
               ;
            end;
         end;
      end;

end;

end.
