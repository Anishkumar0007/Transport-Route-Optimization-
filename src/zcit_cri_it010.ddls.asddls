@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Route Item Projection'
define view entity ZCIT_CRI_IT010 
  as projection on ZCIT_RTI_IT010
{
  key FreightId,
  key StopId,
  LocationName,
  EtaTime,
  TrafficLvl,
  LocalLastChgAt,
  
  /* Associations */
  // Redirecting the association to the Header Consumption View
  _Route : redirected to parent ZCIT_CRH_IT010
}
