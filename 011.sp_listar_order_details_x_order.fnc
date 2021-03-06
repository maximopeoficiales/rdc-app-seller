create or replace function public.sp_listar_order_details_x_order(ni_order_id integer)
    returns table
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
    language plpgsql
as
$$
begin
 /*************
      | * descripcion : public.sp_listar_order_details_x_order
      | * proposito   : listar registros de order detail por id de la orden.
      | * input parameters:
      |   - <ni_order_id>                        	  : numero de la orden.
      | * output parameters:
      |    - <order_detail>  : Instancia con todos registro de tipo order detail.
      |    - <order_master_id>      : Id de la orden.
      | * autor       : gianmarcos perez rojas.
      | * proyecto    : rq 4707 - cambios y devoluciones ???devuelve r
      | * responsable : cesar jimenez.
      | * rdc         : rq 4707
      |
      | * revisiones
      | * fecha            autor       motivo del cambio            rdc
      | ----------------------------------------------------------------------------
      | - 09/05/22    maximo apaza  modificacion de la funci??n     rq 4707
      ************/
    return query
        select c.*, c.order_id as order_master_id from order_detail as c where c.order_id = ni_order_id;
end;
$$;