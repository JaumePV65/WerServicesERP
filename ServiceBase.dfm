object WebServiceERP: TWebServiceERP
  OldCreateOrder = False
  DisplayName = 'Servei Web ERP'
  ServiceStartName = 'WebServiceERP'
  OnContinue = ServiceContinue
  OnExecute = ServiceExecute
  OnPause = ServicePause
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
