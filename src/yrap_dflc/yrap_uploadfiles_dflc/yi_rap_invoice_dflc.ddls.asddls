@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS de interface'
define root view entity YI_RAP_INVOICE_DFLC
  as select from ytbrap_invc_dflc
{
  key invoice               as Invoice,
      comments              as Comments,
      attachment            as Attachment,
      mimetype              as Mimetype,
      filename              as Filename,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
