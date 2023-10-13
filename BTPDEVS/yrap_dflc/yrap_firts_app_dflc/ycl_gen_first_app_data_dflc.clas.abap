CLASS ycl_gen_first_app_data_dflc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_gen_first_app_data_dflc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA itab TYPE TABLE OF ztravel_xxx.

    " fill internal travel table (itab)
    itab = VALUE #( ( mykey           = '02D5290E594C1EDA93815057FD946624'
                      travel_id       = '00000022'
                      agency_id       = '070001'
                      customer_id     = '000077'
                      begin_date      = '20190624'
                      end_date        = '20190628'
                      booking_fee     = '60.00'
                      total_price     = '750.00'
                      currency_code   = 'USD'
                      description     = 'mv'
                      overall_status  = 'A'
                      created_by      = 'MUSTERMANN'
                      created_at      = '20190612133945.5960060'
                      last_changed_by = 'MUSTERFRAU'
                      last_changed_at = '20190702105400.3647680' )
                    ( mykey           = '02D5290E594C1EDA93815C50CD7AE62A'
                      travel_id       = '00000106'
                      agency_id       = '070005'
                      customer_id     = '000005'
                      begin_date      = '20190613'
                      end_date        = '20190716'
                      booking_fee     = '17.00'
                      total_price     = '650.00'
                      currency_code   = 'AFN'
                      description     = 'Enter your comments here'
                      overall_status  = 'A'
                      created_by      = 'MUSTERMANN'
                      created_at      = '20190613111129.2391370'
                      last_changed_by = 'MUSTERMANN'
                      last_changed_at = '20190711140753.1472620' )
                    ( mykey           = '02D5290E594C1EDA93858EED2DA2EB0B'
                      travel_id       = '00000103'
                      agency_id       = '070010'
                      customer_id     = '000011'
                      begin_date      = '20190610'
                      end_date        = '20190714'
                      booking_fee     = '17.00'
                      total_price     = '800.00'
                      currency_code   = 'AFN'
                      description     = 'Enter your comments here'
                      overall_status  = 'X'
                      created_by      = 'MUSTERFRAU'
                      created_at      = '20190613105654.4296640'
                      last_changed_by = 'MUSTERFRAU'
                      last_changed_at = '20190613111041.2251330' ) ).

    " delete existing entries in the database table
    DELETE FROM YTFIRST_APP_DFLC.

    " insert the new table entries
    INSERT YTFIRST_APP_DFLC FROM TABLE @itab.

    " output the result as a console message
    out->write( |{ sy-dbcnt } travel entries inserted successfully!| ).

  ENDMETHOD.

ENDCLASS.
