CREATE FUNCTION public.sp_migra_order_detail_msa(ni_order_master_ini_id integer, ni_order_master_fin_id integer)
    RETURNS TABLE
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
    LANGUAGE plpgsql
AS
$$

DECLARE

    r order%rowtype;

begin

    /*************

  | * Descripcion : FUNCTION public.sp_migra_order_detail_msa

  | * Proposito   : Funcion para traer el detalle de las ordenes

  | * Input Parameters:

  |   - <ni_order_master_ini_id> :Numero de ID ticket inicial.

  |   - <ni_order_master_fin_id> :Numero de ID ticket final.

  | * Output Parameters:

  |   - <order_master_id>      :Id de la orden detalle.

  |   - <ean>                   :Id producto.

  |   - <flag_cambio>                 :Estado de cambio

  |   - <cantidad>                :Cantidad

  |   - <cantidad_return>                :Cantidad a retornar

  |   - <precio>        :Precio

  |   - <precio_affected>             :Precio afectado.

  |   - <descuento_articulo>                :Descuento articulo.

  |   - <descuento_boleta>                 :Descuento boleta.

  |   - <reason_operation_id>               :Id motivo de devolucion.

  |   - <reason_operation>                 :Motivo de devolucion.

  |   - <operation_type_id>            :Tipo de operacion.

  |   - <model>                :Modelo.

  |   - <size_product>                :Tamano del producto.

  |   - <image>        :Imagen del producto.

  |   - <brand>         :Marca del producto.

  |   - <price_by_unit>      :Precio por unidad.

  |   - <is_enchufable>      :Tipo enchufable.

  |   - <is_transport>  :Producto transportable.

  |   - <days_expiration>             :Dias de expiracion.

  |   - <expiration_date>             :Fecha de expiracion.

  |   - <price_by_unit_total>             :Precio por unidad.

  |   - <promotion>             :Promocion.

  |   - <promotion_code>             :Codigo de promocion.

  |   - <condition>             :Condicion.

  |   - <color>             :Color.

  |   - <code_delivery>             :Codigo de delivery.

  |   - <mode_delivery>             :Modo de delivery.

  |   - <time_of_purchase>             :Fecha de compra.

  |   - <seller_id>             :ID del vendedor.

  |   - <seller_name>             :Nombre del vendedor.

  |   - <suborder>             :Suborden.

  |   - <type_product>             :Tipo de producto marketplace o ripley.

  | * Autor       : Paulo Carbajal.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-15

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio                 RDC

  | ----------------------------------------------------------------------------

  | - 30/03/22    Paulo Carbajal   Se agrega el seller id, nombre, suborden y tipo de producto             RQ 4707-4



************/

    RETURN QUERY
        SELECT a.order_id as order_master_id,
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

               c.description                                                               AS reason_operation,

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

               to_char(ord.purchase_date + coalesce(a1.days_expiration, 60), 'YYYY-MM-DD') as expiration_date,

               a.price_by_unit_total,

               a.promotion,

               a.promotion_code,

               (CASE WHEN (d.condition is null) THEN 'A' ELSE d.condition END)             as condition,

               a1.color,

               a1.code_delivery,

               a1.mode_delivery,

               a1.time_of_purchase,

               a1.seller_id,

               a1.seller_name,

               a1.suborder,

               a1.type_product

        FROM order_detail a

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

        WHERE a.order_id >= ni_order_master_ini_id
          and a.order_id <= ni_order_master_fin_id;

END;

$$; 