CREATE FUNCTION public.sp_listar_detail_email_for_send(ni_order_master_id integer) RETURNS TABLE(order_detail_id bigint, order_master_id bigint, product_type_id bigint, product_id character varying, quantity_products integer, quantity_products_return integer, monto numeric, monto_affected numeric, operation_type_id integer, reason_operation_id integer, product_url character varying, flag_offers integer, offers character varying, product character varying, classification_products_id bigint, model character varying, size character varying, image character varying, brand character varying, quantity_products_return_real integer, monto_affected_real numeric, flag_return integer, price_by_unit numeric, days_expiration integer, expiration_date date, seller_name character varying)
    LANGUAGE plpgsql
    AS $$

 /*************

  | * Descripcion : FUNCTION public.sp_listar_detail_email_for_send

  | * Proposito   : Funcion para obtener el detalle de los correos.

  | * Input Parameters:

  | * Output Parameters:

  |   - <order_detail_id>                   :ID del detalle de la orden.

  |   - <order_master_id>                    :ID de la orden creada en el formulario.

  |   - <product_type_id>                      :Tipo del producto.

  |   - <product_id>                 :Identificador del producto.

  |   - <quantity_products>                 			:Cantidad de productos.

  |   - <quantity_products_return>                  :Cantidad de productos a retornar.

  |   - <monto>                     :Monto.

  |   - <monto_affected>                   :Monto afectado.

  |   - <operation_type_id>            :Tipo de operacion.

  |   - <reason_operation_id>            :Motivo de devolucion.

  |   - <product_url>            :Url del producto.

  |   - <flag_offers>                       :Estado de la oferta.

  |   - <offers>                :Oferta.

  |   - <product>                :Nombre del producto.

  |   - <classification_products_id>                    :ID clasificacion del producto.

  |   - <model>                   :Modelo del producto.

  |   - <size>                             :Talla del producto.

  |   - <image>                       :Imagen del producto.

  |   - <brand>                   		:Marca del producto.

  |   - <quantity_products_return_real>                  :Cantidad del productos.

  |   - <monto_affected_real>                          :Monto afectado.

  |   - <flag_return>                      :Estado de retorno.

  |   - <price_by_unit_total>                :Precio total.

  |   - <days_expiration>                :Dias de expiracion.

  |   - <expiration_date>                :Fecha de expiracion.

  |   - <seller_name>                :Nombre del vendedor.

  | * Autor       : Gianmarcos Perez Rojas.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-8

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio            RDC

  | ----------------------------------------------------------------------------

  | - 14/09/21    Gianmarcos Perez Se agrega sucursal y trx     RQ 4657-8

  | - 30/03/22    Paulo Carbajal Nombre del vendedor            RQ 4707-4

  ************/

DECLARE

    r order_detail%rowtype;

    d_purchase_date  date;

    n_purchase_id    int8;

BEGIN

	select a.purchase_date, a.purchase_id into d_purchase_date, n_purchase_id

	from order a

	left join purchase b

	on b.purchase_id = a.purchase_id

    where a.order_id = ni_order_master_id;



   RETURN QUERY

        SELECT a.order_detail_id, a.order_id, a.product_type_id, a.product_id, a.quantity_products,

         a.quantity_products_return, a.monto, a.monto_affected, a.operation_type_id, a.reason_operation_id,

         a.product_url, a.flag_offers, a.offers, a.product, a.classification_products_id, a.model, a.size, a.image,

         a.brand, a.quantity_products_return_real, a.monto_affected_real, a.flag_return, a.price_by_unit_total,

         coalesce(pd.days_expiration, 60) as days_expiration, d_purchase_date + coalesce(pd.days_expiration, 60) expiration_date,

         a.seller_name

        FROM order_detail a

        LEFT JOIN purchase_detail pd

        ON pd.product_id = a.product_id and

           pd.purchase_id  = n_purchase_id and
           pd.suborder = pd.suborder

        WHERE a.order_id = ni_order_master_id AND

		a.quantity_products_return > 0;

END;

$$;
