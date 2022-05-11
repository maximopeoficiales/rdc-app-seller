create or replace function public.sp_migra_order_detail_msa(ni_order_master_ini_id integer, ni_order_master_fin_id integer)
    returns table
            (
                order_master_id     bigint,
                ean                 character varying,
                flag_cambio         integer,
                cantidad            integer,
                cantidad_return     integer,
                precio              numeric,
                precio_affected     numeric,
                descuento_articulo  integer,
                descuento_boleta    character varying,
                product             character varying,
                reason_operation_id integer,
                reason_operation    character varying,
                operation_type_id   integer,
                operation_type      character varying,
                model               character varying,
                size_product        character varying,
                image               character varying,
                brand               character varying,
                price_by_unit       numeric,
                is_enchufable       integer,
                is_transport        integer,
                days_expiration     integer,
                expiration_date     text,
                price_by_unit_total numeric,
                promotion           character varying,
                promotion_code      character varying,
                condition           character varying,
                color               character varying,
                code_delivery       character varying,
                mode_delivery       character varying,
                time_of_purchase    character varying,
                seller_id           character varying,
                seller_name         character varying,
                suborder            character varying,
                type_product        character varying,
                reason_text         varchar,
                id_seller           bigint
            )
    language plpgsql
as
$$
begin

    /*************

  | * descripcion : function public.sp_migra_order_detail_msa

  | * proposito   : funcion para traer el detalle de las ordenes

  | * input parameters:

  |   - <ni_order_master_ini_id> :numero de id ticket inicial.

  |   - <ni_order_master_fin_id> :numero de id ticket final.

  | * output parameters:

  |   - <order_master_id>      :id de la orden detalle.

  |   - <ean>                   :id producto.

  |   - <flag_cambio>                 :estado de cambio

  |   - <cantidad>                :cantidad

  |   - <cantidad_return>                :cantidad a retornar

  |   - <precio>        :precio

  |   - <precio_affected>             :precio afectado.

  |   - <descuento_articulo>                :descuento articulo.

  |   - <descuento_boleta>                 :descuento boletod.

  |   - <reason_operation_id>               :id motivo de devolucion.

  |   - <reason_operation>                 :motivo de devolucion.

  |   - <operation_type_id>            :tipo de operacion.

  |   - <model>                :modelo.

  |   - <size_product>                :tamano del producto.

  |   - <image>        :imagen del producto.

  |   - <brand>         :marca del producto.

  |   - <price_by_unit>      :precio por unidad.

  |   - <is_enchufable>      :tipo enchufable.

  |   - <is_transport>  :producto transportable.

  |   - <days_expiration>             :dias de expiracion.

  |   - <expiration_date>             :fecha de expiracion.

  |   - <price_by_unit_total>             :precio por unidad.

  |   - <promotion>             :promocion.

  |   - <promotion_code>             :codigo de promocion.

  |   - <condition>             :condicion.

  |   - <color>             :color.

  |   - <code_delivery>             :codigo de delivery.

  |   - <mode_delivery>             :modo de delivery.

  |   - <time_of_purchase>             :fecha de comprod.

  |   - <seller_id>             :id del vendedor.

  |   - <seller_name>             :nombre del vendedor.

  |   - <suborder>             :suborden.

  |   - <type_product>             :tipo de producto marketplace o ripley.
  |   - <reason_Text>             :Razon.
  |   - <id_seller>             :Identificador de la tabla seller.

  | * autor       : paulo carbajal.

  | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

  | * responsable : cesar jimenez.

  | * rdc         : rq-4657-15

  |

  | * revisiones

  | * fecha            autor       motivo del cambio                 rdc

  | ----------------------------------------------------------------------------

  | - 30/03/22    paulo carbajal   se agrega el seller id, nombre, suborden y tipo de producto             rq 4707-4
      | - 09/05/22    maximo apaza  modificacion de la función     rq 4707



************/

    return query
        select od.order_id                                                                 as order_master_id,
               od.product_id                                                               as ean,

               od.operation_type_id                                                        as flag_cambio,

               od.quantity_products                                                        as cantidad,

               od.quantity_products_return                                                 as cantidad_return,

               od.monto                                                                    as precio,

               od.monto_affected                                                           as precio_affected,

               od.flag_offers                                                              as descuento_articulo,

               od.offers                                                                   as descuento_boleta,

               od.product,

               od.reason_operation_id,

               rp.description                                                              as reason_operation,

               od.operation_type_id,

               op.description                                                              as operation_type,

               od.model                                                                       model,

               od.size                                                                        size_product,

               od.product_url                                                                 image,

               od.brand,

               od.price_by_unit,

               cp.is_enchufable,

               cp.is_transport,

               coalesce(pd.days_expiration, 60)                                            as days_expiration,

               to_char(ord.purchase_date + coalesce(pd.days_expiration, 60), 'yyyy-mm-dd') as expiration_date,

               od.price_by_unit_total,

               od.promotion,

               od.promotion_code,

               (case when (cp.condition is null) then 'a' else cp.condition end)           as condition,

               pd.color,

               pd.code_delivery,

               pd.mode_delivery,

               pd.time_of_purchase,

               pd.seller_id,

               pd.seller_name,

               pd.suborder,

               pd.type_product,
               od.reason_text,
               od.id_seller

        from order_detail od

                 inner join public."order" ord
                            on ord.order_id = od.order_id

                 inner join purchase_detail pd
                            on pd.product_id = od.product_id and
                               pd.purchase_id = ord.purchase_id

                 left join public.operation_type op
                           on op.operation_type_id = od.operation_type_id

                 left join public.reason_operation rp
                           on rp.reason_operation_id = od.reason_operation_id

                 left join public.classification_products cp
                           on cp.classification_products_id = od.classification_products_id

        where od.order_id >= ni_order_master_ini_id
          and od.order_id <= ni_order_master_fin_id;

end;

$$;