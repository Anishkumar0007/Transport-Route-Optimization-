@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Route Header Root View'
define root view entity ZCIT_RTH_IT010 
  as select from zcit_hdr_it010
  composition [0..*] of ZCIT_RTI_IT010 as _Stops
{
  key freightid as FreightId,
  source_loc as SourceLoc,
  dest_loc as DestLoc,
  best_route as BestRoute,
  @Semantics.quantity.unitOfMeasure: 'DistUnit'
  total_dist as TotalDist,
  dist_unit as DistUnit,
  @Semantics.amount.currencyCode: 'Currency'
  total_cost as TotalCost,
  currency as Currency,
  ai_status as AiStatus,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchgat as LocalLastChgAt,
  
  _Stops
}
