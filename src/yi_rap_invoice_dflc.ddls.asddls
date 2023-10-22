@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS de interface'
define root view entity YI_RAP_INVOICE_DFLC
  as select from ytbrap_invc_dflc
{
  key uuid               as Guid,
      invoice            as Invoice,
      comments           as Comments,
      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'Filename',
                                contentDispositionPreference: #INLINE }
      attachment         as Attachment,
      @Semantics.mimeType: true
      mimetype           as MimeType,
      filename           as Filename,
      @Semantics.user.createdBy: true
      createdby          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      createdat          as CreatedAt,
      @Semantics.user.lastChangedBy: true
      lastchangedby      as LastChangedBy,
      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangeddat     as LastChangedAt,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as LocalLastChangedAt

}
