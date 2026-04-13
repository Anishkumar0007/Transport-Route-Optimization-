@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Route Header Projection'
define root view entity ZCIT_CRH_IT010 
  provider contract transactional_query
  as projection on ZCIT_RTH_IT010
{
  key FreightId, SourceLoc, DestLoc, BestRoute, 
  TotalDist, DistUnit, TotalCost, Currency, AiStatus, LocalLastChgAt,
  
  _Stops : redirected to composition child ZCIT_CRI_IT010
}
