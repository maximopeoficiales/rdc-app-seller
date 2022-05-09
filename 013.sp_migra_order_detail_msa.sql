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
                type_product        character varying
            )
    language plpgsql
as
$$

declare

    r order%rowtype;

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

  |   - <descuento_boleta>                 :descuento boleta.

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

  |   - <time_of_purchase>             :fecha de compra.

  |   - <seller_id>             :id del vendedor.

  |   - <seller_name>             :nombre del vendedor.

  |   - <suborder>             :suborden.

  |   - <type_product>             :tipo de producto marketplace o ripley.

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
        select a.order_id as order_master_id,
               a.product_id                                                                as ean,

               a.operation_type_id                                                         as flag_cambio,

               a.quantity_products                                                         as cantidad,

               a.quantity_products_return                                                  as cantidad_return,

               a.monto                                                                     as precio,

               a.monto_affected                                                            as precio_affected,

               a.flag_offers                                                               as descuento_articulo,

               a.offers                                                                    as descuento_boleta,

               a.product,

               a.reason_operation_id,

               c.description                                                               as reason_operation,

               a.operation_type_id,

               b.description                                                               as operation_type,

               a.model                                                                        model,

               a.size                                                                         size_product,

               a.product_url                                                                  image,

               a.brand,

               a.price_by_unit,

               d.is_enchufable,

               d.is_transport,

               coalesce(a1.days_expiration, 60)                                            as days_expiration,

               to_char(ord.purchase_date + coalesce(a1.days_expiration, 60), 'yyyy-mm-dd') as expiration_date,

               a.price_by_unit_total,

               a.promotion,

               a.promotion_code,

               (case when (d.condition is null) then 'a' else d.condition end)             as condition,

               a1.color,

               a1.code_delivery,

               a1.mode_delivery,

               a1.time_of_purchase,

               a1.seller_id,

               a1.seller_name,

               a1.suborder,

               a1.type_product

        from order_detail a

                 inner join public."order" ord
                            on ord.order_id = a.order_id

                 inner join purchase_detail a1
                            on a1.product_id = a.product_id and
                               a1.purchase_id = ord.purchase_id

                 left join public.operation_type b
                           on b.operation_type_id = a.operation_type_id

                 left join public.reason_operation c
                           on c.reason_operation_id = a.reason_operation_id

                 left join public.classification_products d
                           on d.classification_products_id = a.classification_products_id

        where a.order_id >= ni_order_master_ini_id
          and a.order_id <= ni_order_master_fin_id;

end;

$$; 