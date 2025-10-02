unit GoldERP.Diagnostic;

interface

uses
  System.Classes, System.SysUtils;

type
  TDiagnosticParameter = class(TObject)
  public
    constructor Create(AContent: TObject; AClassification: TPrivacyClassification);
    function CustomerContent(AContent: TObject): TDiagnosticParameter;
    function SystemMetadata(AContent: TObject): TDiagnosticParameter;
    property Content: TObject read GetContent write SetContent;
    property Classification: TPrivacyClassification read GetClassification write SetClassification;
  end;


implementation

constructor TDiagnosticParameter.Create(AContent: TObject; AClassification: TPrivacyClassification);
begin
  Content := AContent;
  Classification := AClassification;
end;

function TDiagnosticParameter.CustomerContent(AContent: TObject): TDiagnosticParameter;
begin
  Result := TDiagnosticParameter.Create(AContent, TPrivacyClassification.CustomerContent);
end;

function TDiagnosticParameter.SystemMetadata(AContent: TObject): TDiagnosticParameter;
begin
  Result := TDiagnosticParameter.Create(AContent, TPrivacyClassification.SystemMetadata);
end;


end.
