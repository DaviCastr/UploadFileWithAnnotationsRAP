@EndUserText.label: 'CDS de consumo/projeção'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity YC_RAP_INVOICE_DFLC
  provider contract transactional_query
  as projection on YI_RAP_INVOICE_DFLC
{
  key Guid,
      Invoice,
      Comments,
      Attachment,
      MimeType,
      Filename,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
