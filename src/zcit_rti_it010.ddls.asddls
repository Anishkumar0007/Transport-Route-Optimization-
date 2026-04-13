@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Route Stops View'
define view entity ZCIT_RTI_IT010 
  as select from zcit_itm_it010
  association to parent ZCIT_RTH_IT010 as _Route on $projection.FreightId = _Route.FreightId
{
  key freightid as FreightId,
  key stop_id as StopId,
  location_name as LocationName,
  eta_time as EtaTime,
  traffic_lvl as TrafficLvl,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchgat as LocalLastChgAt,
  
  _Route
}
