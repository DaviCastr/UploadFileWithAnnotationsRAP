@EndUserText.label: 'Projeção para primeiro APP'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity YC_FIRST_APP_DFLC
  provider contract transactional_query
  as projection on YI_FIRST_APP_DFLC
{
  key mykey              as TravelUUID,
      @Search.defaultSearchElement: true
      travel_id          as TravelID,
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID'  } }]
      @ObjectModel.text.element: ['AgencyName'] ----meaning?
      @Search.defaultSearchElement: true
      agency_id as AgencyID,
      _Agency.Name       as AgencyName,
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      customer_id        as CustomerID,
      _Customer.LastName as CustomerName,
      begin_date         as BeginDate,
      end_date           as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      currency_code      as CurrencyCode,
      overall_status     as TravelStatus,
      description        as Description,
      last_changed_at    as LastChangedAt
}
