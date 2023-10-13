CLASS lhc_FirstApp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES tt_FirstApp_update TYPE TABLE FOR UPDATE yi_first_app_dflc.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR FirstApp RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR firstapp RESULT result.

    METHODS set_status_completed FOR MODIFY
      IMPORTING keys FOR ACTION firstapp~acceptTravel RESULT result.

    METHODS CalculateTravelKey FOR DETERMINE ON MODIFY
      IMPORTING keys FOR firstapp~CalculateTravelKey.

    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR firstapp~validateagency.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR firstapp~validatecustomer.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR firstapp~validatedates.

ENDCLASS.

CLASS lhc_FirstApp IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    "%control-<fieldname> specifies which fields are read from the entities

    READ ENTITY yi_first_app_dflc FROM VALUE #( FOR keyval IN keys
                                                      (  %key                    = keyval-%key
                                                      "  %control-FirstApp_id      = if_abap_behv=>mk-on
                                                        %control-overall_status = if_abap_behv=>mk-on
                                                        ) )
                                RESULT DATA(lt_FirstApp_result).


    result = VALUE #( FOR ls_FirstApp IN lt_FirstApp_result
                      ( %key                           = ls_FirstApp-%key
                        %features-%action-acceptTravel = COND #( WHEN ls_FirstApp-overall_status = 'A'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

  METHOD set_status_completed.

    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF yi_first_app_dflc IN LOCAL MODE
           ENTITY FirstApp
              UPDATE FROM VALUE #( FOR key IN keys ( mykey = key-mykey
                                                     overall_status = 'A' " Accepted
                                                     %control-overall_status = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    " Read changed data for action result
    READ ENTITIES OF yi_first_app_dflc IN LOCAL MODE
         ENTITY FirstApp
         FROM VALUE #( FOR key IN keys (  mykey = key-mykey
                                          %control = VALUE #(
                                            agency_id       = if_abap_behv=>mk-on
                                            customer_id     = if_abap_behv=>mk-on
                                            begin_date      = if_abap_behv=>mk-on
                                            end_date        = if_abap_behv=>mk-on
                                            booking_fee     = if_abap_behv=>mk-on
                                            total_price     = if_abap_behv=>mk-on
                                            currency_code   = if_abap_behv=>mk-on
                                            overall_status  = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR travel IN lt_travel ( mykey = travel-mykey
                                                %param    = travel
                                              ) ).


  ENDMETHOD.

  METHOD CalculateTravelKey.

    READ ENTITIES OF yi_first_app_dflc IN LOCAL MODE
        ENTITY FirstApp
          FIELDS ( travel_id )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

    DELETE lt_travel WHERE travel_id IS NOT INITIAL.
    CHECK lt_travel IS NOT INITIAL.

    "Get max travelID
    SELECT SINGLE FROM ztravel_xxx FIELDS MAX( travel_id ) INTO @DATA(lv_max_travelid).

    "update involved instances
    MODIFY ENTITIES OF yi_first_app_dflc IN LOCAL MODE
      ENTITY FirstApp
        UPDATE FIELDS ( travel_id )
        WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO i (
                           %key      = ls_travel-%key
                           travel_id  = lv_max_travelid + i ) )
    REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD validateAgency.

    READ ENTITY yi_first_app_dflc\\FirstApp FROM VALUE #(
         FOR <root_key> IN keys ( %key-mykey     = <root_key>-mykey
                                 %control = VALUE #( agency_id = if_abap_behv=>mk-on ) ) )
         RESULT DATA(lt_FirstApp).

    DATA lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    lt_agency = CORRESPONDING #( lt_FirstApp DISCARDING DUPLICATES MAPPING agency_id = agency_id EXCEPT * ).
    DELETE lt_agency WHERE agency_id IS INITIAL.
    CHECK lt_agency IS NOT INITIAL.

    " Check if customer ID exist
    SELECT FROM /dmo/agency FIELDS agency_id
      FOR ALL ENTRIES IN @lt_agency
      WHERE agency_id = @lt_agency-agency_id
      INTO TABLE @DATA(lt_agency_db).

    " Raise msg for non existing customer id
    LOOP AT lt_FirstApp INTO DATA(ls_FirstApp).
      IF ls_FirstApp-agency_id IS NOT INITIAL AND NOT line_exists( lt_agency_db[ agency_id = ls_FirstApp-agency_id ] ).
        APPEND VALUE #(  mykey = ls_FirstApp-mykey ) TO failed-FirstApp.
        APPEND VALUE #(  mykey = ls_FirstApp-mykey
                        %msg      = new_message( id       = /dmo/cx_flight_legacy=>agency_unkown-msgid
                                                  number   = /dmo/cx_flight_legacy=>agency_unkown-msgno
                                                  v1       = ls_FirstApp-agency_id
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-agency_id = if_abap_behv=>mk-on ) TO reported-FirstApp.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITY yi_first_app_dflc\\FirstApp FROM VALUE #(
          FOR <root_key> IN keys ( %key-mykey     = <root_key>-mykey
                                   %control = VALUE #( customer_id = if_abap_behv=>mk-on ) ) )
          RESULT DATA(lt_FirstApp).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    lt_customer = CORRESPONDING #( lt_FirstApp DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.
    CHECK lt_customer IS NOT INITIAL.

    " Check if customer ID exist
    SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id = @lt_customer-customer_id
      INTO TABLE @DATA(lt_customer_db).

    " Raise msg for non existing customer id
    LOOP AT lt_FirstApp INTO DATA(ls_FirstApp).
      IF ls_FirstApp-customer_id IS NOT INITIAL AND NOT line_exists( lt_customer_db[ customer_id = ls_FirstApp-customer_id ] ).
        APPEND VALUE #(  mykey = ls_FirstApp-mykey ) TO failed-FirstApp.
        APPEND VALUE #(  mykey = ls_FirstApp-mykey
                         %msg      = new_message( id       = /dmo/cx_flight_legacy=>customer_unkown-msgid
                                                  number   = /dmo/cx_flight_legacy=>customer_unkown-msgno
                                                  v1       = ls_FirstApp-customer_id
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-customer_id = if_abap_behv=>mk-on ) TO reported-FirstApp.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY yi_first_app_dflc\\FirstApp FROM VALUE #(
        FOR <root_key> IN keys ( %key-mykey     = <root_key>-mykey
                                 %control = VALUE #( begin_date = if_abap_behv=>mk-on
                                                     end_date   = if_abap_behv=>mk-on ) ) )
        RESULT DATA(lt_FirstApp_result).

    LOOP AT lt_FirstApp_result INTO DATA(ls_FirstApp_result).

      IF ls_FirstApp_result-end_date < ls_FirstApp_result-begin_date.  "end_date before begin_date

        APPEND VALUE #( %key        = ls_FirstApp_result-%key
                        mykey   = ls_FirstApp_result-mykey ) TO failed-FirstApp.

        APPEND VALUE #( %key     = ls_FirstApp_result-%key
                        %msg     = new_message( id       = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
                                                number   = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
                                                v1       = ls_FirstApp_result-begin_date
                                                v2       = ls_FirstApp_result-end_date
                                                v3       = ls_FirstApp_result-travel_id
                                                severity = if_abap_behv_message=>severity-error )
                        %element-begin_date = if_abap_behv=>mk-on
                        %element-end_date   = if_abap_behv=>mk-on ) TO reported-FirstApp.

      ELSEIF ls_FirstApp_result-begin_date < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %key        = ls_FirstApp_result-%key
                        mykey   = ls_FirstApp_result-mykey ) TO failed-FirstApp.

        APPEND VALUE #( %key = ls_FirstApp_result-%key
                        %msg = new_message( id       = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                                            number   = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                                            severity = if_abap_behv_message=>severity-error )
                        %element-begin_date = if_abap_behv=>mk-on
                        %element-end_date   = if_abap_behv=>mk-on ) TO reported-FirstApp.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
