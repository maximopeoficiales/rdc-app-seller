CREATE FUNCTION public.sp_listar_email_for_send() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_idd integer, category character varying, method_id integer, bar_code character varying, email_option character varying, state_email_option integer, forma_pago character varying)
    LANGUAGE plpgsql
    AS $$

  /*************

  | * Descripcion : FUNCTION public.sp_listar_email_for_send

  | * Proposito   : Funcion para listart los correos que faltan enviar.

  | * Input Parameters:

  | * Output Parameters:

  |   - <order_master_id>                   :ID del detalle de la orden.

  |   - <prospect_order>                    :ID de la orden creada en el formulario.

  |   - <order_number>                      :Número de orden.

  |   - <identity_document>                 :Documento de indentidad.

  |   - <email>                 			:Email.

  |   - <purchase_type_id>                  :Id tipo de compra.

  |   - <purchase_date>                     :Fecha de compra.

  |   - <number_products>                   :Número de productos.

  |   - <number_products_unique>            :Número de productos únicos.

  |   - <number_products_return>            :Número de productos devuelos.

  |   - <number_products_change>            :Número de productos cambiados.

  |   - <monto_total>                       :Monto total.

  |   - <monto_total_return>                :Monto total devuelto.

  |   - <monto_total_change>                :Monto total de cambio.

  |   - <estado_request>                    :Estado de la solicitud.

  |   - <flag_send_email>                   :Bandera de correo enviado.

  |   - <id_qr>                             :ID del qr.

  |   - <category_id>                       :ID de categoria.

  |   - <category>                   		:Categoria.

  |   - <return_method_id>                  :ID de metodo de devolución.

  |   - <bar_code>                          :Código de barra.

  |   - <email_option>                      :Correo opcional.

  |   - <state_email_option>                :Estado del correo opcional.

  | * Autor       : Gianmarcos Perez Rojas.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-8

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio            RDC

  | ----------------------------------------------------------------------------

  | - 14/09/21    Gianmarcos Perez Se agrega sucursal y trx     RQ 4657-8

  ************/

DECLARE

	n_solicitudes_pendientes integer := 2;



BEGIN



    update order x set category_id =

	  (select max(case when b.division_id = 'G02' then 9

	            when a.reason_operation_id = 4 then 7

	            else 3

	           end

	          )

	    from order_detail a

	    inner join purchase_detail  b

	    on b.product_id  = a.product_id

	    and b.purchase_id = x.purchase_id

	    left join classification_products c

	    on c.classification_products_id = a.classification_products_id

	  where a.order_id = x.order_id  AND

		a.quantity_products_return > 0)

     where x.estado_request = n_solicitudes_pendientes ;

    --Actualizamos electro de 9 a 2

    update order x set category_id = 2 where category_id = 9;

    --Actualizamos fallado de 7 a 1

	update order x set category_id = 1 where category_id = 7;

	RETURN QUERY

        SELECT a.order_id as order_master_id,

			a.prospect_order,

			a.order_number,

			a.identity_document,

			a.email,

			a.purchase_type_id,

			a.purchase_date,

			a.number_products,

			a.number_products_unique,

			a.number_products_return,

			a.number_products_change,

			a.amount_total as monto_total,

			a.amount_total_return as monto_total_return,

			a.amount_total_change as monto_total_change,

			a.estado_request,

			a.flag_send_email,

			a.id_qr,

			a.category_id,

			b.description as category,

			a.return_method_id,

			a.bar_code,

			a.email_option,

			a.state_email_option,

			p.forma_pago

	FROM order a

	join purchase p on p.purchase_id = a.purchase_id

	left join order_category b

	on b.order_category_id = a.category_id

	WHERE a.estado_request = n_solicitudes_pendientes  ;

END;

$$;