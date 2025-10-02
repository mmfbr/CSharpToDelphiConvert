unit GoldERP.Diagnostic;

interface

uses
  System.Classes, System.SysUtils;

type
  TPrivacyHelper = class(TObject)
  public
    const m_RedactedText: String = "<redacted>";
    function IsPersonalOrRestrictedData(ADiagnosticParameter: TDiagnosticParameter): Boolean;
    function IsPersonalOrRestrictedData(AClassification: TPrivacyClassification): Boolean;
  end;


implementation

function TPrivacyHelper.IsPersonalOrRestrictedData(ADiagnosticParameter: TDiagnosticParameter): Boolean;
begin
  Result := IsPersonalOrRestrictedData(diagnosticParameter.Classification);
end;

function TPrivacyHelper.IsPersonalOrRestrictedData(AClassification: TPrivacyClassification): Boolean;
begin
  if classification >= TPrivacyClassification.OrganizationIdentifiableInformation then
  begin
    Result := classification = TPrivacyClassification.Invalid;
  end
  ;
  Result := true;
end;


end.
