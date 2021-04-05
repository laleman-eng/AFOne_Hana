namespace AF_IFRS.Utils;

interface

uses
  SAPbobsCOM, 
  System.Collections.Generic,
  System.Linq,
  System.Text,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  Visuald.MultiFunctions;

type
  TUtils = public class
  private
      FTasaFija       : boolean := false;
      FPostSysCu      : boolean := false;
      FGlobalSettings : TGlobalVid;
      FCmpny          : SAPbobsCOM.Company;
      FSBOf           : CSBOFunctions;
      oRecordSet      : SAPbobsCOM.Recordset;
      oFactDec        : integer;
      oRndType        : string;
      aux_debug       : Integer := 0;
      FDebug          : boolean := true;
  protected
  public
      constructor(oGlobalSettings  : TGlobalVid; oCmpny : SAPbobsCOM.Company; oFSBOf : CSBOFunctions );
      method    SetTasaFija();
      method    SetAjusteDecimales(var pFactDec: integer; var pRndType: string);
      method    AjustarDecimales(Valor: double): double;
      method    AjustarDecimalesSUM(Valor: double): double;
      method    AjustarDecimalesSUMSys(Valor: double): double;
      method    ContabilizarEnSBOCrearAsiento(var oJE: SAPbobsCOM.JournalEntries; Year, Period, Day: Integer; ref, ref2, Project, TranCode, Memo: String);
      method    ContabilizarEnSBOInsertarValor(var oJE: SAPbobsCOM.JournalEntries; oValor, oValorSys: Double; CtoCost1, CtoCost2, CtoCost3, CtoCost4, CtoCost5, CtaDebit, CtaCredit: String);
      method    ContabilizarEnSBOCerrarAsiento(var oJE: SAPbobsCOM.JournalEntries);
      property  oTasaFija  : boolean read FTasaFija  Write FTasaFija;
      property  oPostSysCu : boolean read FPostSysCu Write FPostSysCu;
      property  oDebug : boolean read FDebug write FDebug;
  end;

implementation

constructor TUtils(oGlobalSettings : TGlobalVid; oCmpny : SAPbobsCOM.Company; oFSBOf : CSBOFunctions );
begin
  FGlobalSettings := oGlobalSettings;
  FCmpny          := oCmpny;
  FSBOf           := oFSBOf;  
  oRecordset      := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

  SetTasaFija;
  SetAjusteDecimales(var oFactDec, var oRndType);
end;

method TUtils.SetTasaFija;
var 
    oSql      : string;
begin
   FTasaFija  := false;
   FPostSysCu := false;
   oSql := iif(FGlobalSettings.RunningUnderSQLServer, 
               "Select U_ConMSCFi, U_PostSysCu  from [@VID_AFPA]",
               'Select "U_ConMSCFi", "U_PostSysCu" from "@VID_AFPA"');
   oRecordset.DoQuery(oSql);
   if (not oRecordset.EoF) then begin
      if (System.String(oRecordset.Fields.Item('U_ConMSCFi').Value) = 'Y') then 
         FTasaFija := true;
      if (System.String(oRecordset.Fields.Item('U_PostSysCu').Value) = 'Y') then begin
         FPostSysCu := true;
      end;
   end;

   if (FTasaFija) then begin
      oSql := iif(FGlobalSettings.RunningUnderSQLServer, 
                  "Select COUNT(*) cant from [@VID_AFAS] where isnull(U_TasaCnMS,0) = 0",
                  'Select COUNT(*) "cant" from "@VID_AFAS" where ifnull("U_TasaCnMS", 0) = 0');
      oRecordset.DoQuery(oSql);
      if (System.Int32(oRecordset.Fields.Item('cant').Value) > 0) then 
         raise new Exception("Tasa de cambio fija no definida en Activo Fijo, revise valores.");
   end;
end;

method TUtils.SetAjusteDecimales(var pFactDec: integer; var pRndType: string);
var
    oSql : string;
begin
   oSql := iif(FGlobalSettings.RunningUnderSQLServer, 
               "SELECT isnull(U_FactDec,99) factdec, isnull(U_DecRound,'R') decround  FROM [@VID_AFPA]", 
               'SELECT IfNull("U_FactDec", 99) "factdec", IfNull("U_DecRound",''R'') "decround"  FROM "@VID_AFPA"');
   oRecordset.DoQuery(oSql);
   pFactDec := System.int32(oRecordset.Fields.Item('factdec').value);
   if (pFactDec < 1) or (pFactDec > 9) then
      pFactDec := 10;

   pRndType := '';
   pRndType := System.String(oRecordset.Fields.Item('decround').value);
end;

method TUtils.AjustarDecimales(Valor: double): double;
var
   aux: double;
begin
   if (oFactDec >= 10) then
      result := Valor   
   else if (oRndType = 'R') then
      result := Math.Round(Valor, oFactDec, MidpointRounding.AwayFromZero )
   else if (oRndType = 'M') then begin
      aux := Math.Pow(10.0, oFactDec+1);
      result := Math.Truncate(Valor * aux);
      result := result / aux;
      result := Math.Round(result, oFactDec, MidpointRounding.AwayFromZero )
   end
   else begin
      aux := Math.Pow(10.0, oFactDec);
      result := Math.Truncate(Valor * aux);
      result := result / aux;
   end;
end;

method TUtils.AjustarDecimalesSUM(Valor: double): double;
begin
   result := Math.Round(Valor, FGlobalSettings.LocalCurr_Dec, MidpointRounding.AwayFromZero );
end;

method TUtils.AjustarDecimalesSUMSys(Valor: double): double;
begin
   result := Math.Round(Valor, FGlobalSettings.SysCurr_Dec, MidpointRounding.AwayFromZero );
end;

method TUtils.ContabilizarEnSBOCrearAsiento(var oJE: SAPbobsCOM.JournalEntries; Year, Period, Day: Integer; ref, ref2, Project, TranCode, Memo: String);
begin
   oJE.ReferenceDate   := TMultiFunctions.EncodeDate(Year, Period, Day);
   oJE.TaxDate         := TMultiFunctions.EncodeDate(Year, Period, Day);
   oJE.DueDate         := TMultiFunctions.EncodeDate(Year, Period, Day);
   oJE.Reference       := ref + Year.ToString + '-' + Period.ToString;
   oJE.Reference2      := ref2;
   oJE.TransactionCode := TranCode;
   oJE.Memo            := Memo;
   oJE.ProjectCode     := Project;
end;

method TUtils.ContabilizarEnSBOInsertarValor(var oJE: SAPbobsCOM.JournalEntries; oValor, oValorSys: Double; CtoCost1, CtoCost2, CtoCost3, CtoCost4, CtoCost5, CtaDebit, CtaCredit: String);
var
   i : Integer;
   s : String;
begin
   if (not oPostSysCu) then begin
      oValor    := AjustarDecimalesSUM(oValor);
      oValorSys := AjustarDecimalesSUM(oValorSys);
   end
   else
   begin
      oValor    := AjustarDecimalesSUMSys(oValor);
      oValorSys := AjustarDecimalesSUMSys(oValorSys);
   end;

   if (oValor = 0) then
      exit;

   if (oJE.Lines.Count = 1) then begin
      oJE.Lines.SetCurrentLine(0);
      if (oJE.Lines.AccountCode.Trim <> '') and (oJE.Lines.AccountCode <> nil) then
         oJE.Lines.Add;
   end
   else 
      oJE.Lines.Add;
   i := oJE.Lines.Count-1;

   oJE.Lines.SetCurrentLine(i);
   oJE.Lines.AccountCode := CtaDebit;
   oJE.Lines.ProjectCode := oJE.ProjectCode;

   s := iif(FGlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
   s := String.Format(s, CtaDebit); 
   oRecordset.DoQuery(s);
   s := System.String(oRecordset.Fields.Item('ActType').value).Trim();
   
   if (s = 'I') or (s = 'E') then
   begin
      oJE.Lines.CostingCode  := CtoCost1;
      oJE.Lines.CostingCode2 := CtoCost2;
      oJE.Lines.CostingCode3 := CtoCost3;
      oJE.Lines.CostingCode4 := CtoCost4;
      oJE.Lines.CostingCode5 := CtoCost5;
   end;
   
   if (not oPostSysCu) then begin
      if (oValor > 0) then
         oJE.Lines.Debit   := oValor
      else
         oJE.Lines.Credit  := oValor * (-1);

      if (oTasaFija) then begin
         if (oValorSys > 0) then
            oJE.Lines.DebitSys   := oValorSys
         else
            oJE.Lines.CreditSys  := oValorSys * (-1);
      end;
   end
   else begin
      oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
      if (oValor > 0) then
         oJE.Lines.FCDebit   := oValor
      else
         oJE.Lines.FCCredit  := oValor * (-1);

      if (oTasaFija) then begin
         if (oValorSys > 0) then
            oJE.Lines.Debit   := oValorSys
         else
            oJE.Lines.Credit  := oValorSys * (-1);

         if (oValor > 0) then
            oJE.Lines.DebitSys   := oValor
         else
            oJE.Lines.CreditSys  := oValor * (-1);
      end;
   end;

   oJE.Lines.Add;
   inc(i);

   oJE.Lines.SetCurrentLine(i);
   oJE.Lines.AccountCode := CtaCredit;
   oJE.Lines.ProjectCode := oJE.ProjectCode;

   s := iif(FGlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
   s := String.Format(s, CtaCredit); 
   oRecordset.DoQuery(s);
   s := System.String(oRecordset.Fields.Item('ActType').value).Trim();
   
   if (s = 'I') or (s = 'E') then
   begin
      oJE.Lines.CostingCode  := CtoCost1;
      oJE.Lines.CostingCode2 := CtoCost2;
      oJE.Lines.CostingCode3 := CtoCost3;
      oJE.Lines.CostingCode4 := CtoCost4;
      oJE.Lines.CostingCode5 := CtoCost5;
   end;

   if (not oPostSysCu) then begin
      if (oValor > 0) then
         oJE.Lines.Credit   := oValor
      else
         oJE.Lines.Debit  := oValor * (-1);

      if (oTasaFija) then begin
         if (oValorSys > 0) then
            oJE.Lines.CreditSys   := oValorSys
         else
            oJE.Lines.DebitSys  := oValorSys * (-1);
      end;
   end
   else begin
      oJE.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
      if (oValor > 0) then
         oJE.Lines.FCCredit   := oValor
      else
         oJE.Lines.FCDebit  := oValor * (-1);

      if (oTasaFija) then begin
         if (oValorSys > 0) then
            oJE.Lines.Credit   := oValorSys
         else
            oJE.Lines.Debit  := oValorSys * (-1);

         if (oValor > 0) then
            oJE.Lines.CreditSys   := oValor
         else
            oJE.Lines.DebitSys  := oValor * (-1);
      end;
   end;
end;

method TUtils.ContabilizarEnSBOCerrarAsiento(var oJE: SAPbobsCOM.JournalEntries);
var
   errCode : int32;
   errMsg  : String;
begin
   try
      if (oJE.Lines.Count < 2) then
         exit;

      if (oDebug) then begin
         var oFile   : String;
         oFile := System.IO.Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath) + "oJE_" +  aux_debug + ".xml";
         //oFile := 'C:\Users\IOP\Documents\SBO\AFOne dll\bin\Debug\oJE_' +  aux_debug + '.xml';
         //oJE.SaveToFile("oJE_1.xml");
         oJE.SaveXML(var oFile);
         inc(aux_debug);
      end;

      errCode := oJE.Add;
      if (errCode <> 0) then begin
         FCmpny.GetLastError(out errCode, out errMsg);
         raise new Exception(FGlobalSettings.APP_MESSAGE[FGlobalSettings.APP_Message_Arr, FGlobalSettings.APP_Message_id.Error_contabilzacion] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
      end;
   finally
      FSBOF._ReleaseCOMObject(oJE);
   end;
end;

end.
