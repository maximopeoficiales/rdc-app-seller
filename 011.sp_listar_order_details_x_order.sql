CREATE OR REPLACE FUNCTION public.sp_listar_order_details_x_order(ni_order_id integer)
    RETURNS TABLE
            (
                order_detail_id               bigint,
                order_id                      bigint,
                product_type_id               bigint,
                product_id                    character varying,
                quantity_products             integer,
                quantity_products_return      integer,
                monto                         numeric,
                monto_affected                numeric,
                operation_type_id             integer,
                reason_operation_id           integer,
                product_url                   character varying,
                flag_offers                   integer,
                offers                        character varying,
                product                       character varying,
                classification_products_id    bigint,
                model                         character varying,
                size                          character varying,
                image                         character varying,
                brand                         character varying,
                quantity_products_return_real integer,
                monto_affected_real           numeric,
                flag_return                   integer,
                price_by_unit                 numeric,
                days_expiration               integer,
                expiration_date               date,
                price_by_unit_total           numeric,
                promotion_code                character varying,
                promotion                     character varying,
                cupon_number                  character varying,
                promotion_discount_amount     numeric,
                itemn_number                  integer,
                color                         character varying,
                suborder                      character varying,
                type_product                  character varying,
                seller_name                   character varying,
                seller_id                     character varying,
                order_master_id               bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT c.*, c.order_id as order_master_id FROM order_detail as c WHERE c.order_id = ni_order_id;
END;
$$;