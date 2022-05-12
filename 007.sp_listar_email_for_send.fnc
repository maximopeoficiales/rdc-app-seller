create or replace function public.sp_listar_email_for_send() returns table(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_idd integer, category character varying, method_id integer, bar_code character varying, email_option character varying, state_email_option integer, forma_pago character varying)
    language plpgsql
    as $$

  /*************

  | * descripcion : function public.sp_listar_email_for_send

  | * proposito   : funcion para listart los correos que faltan enviar.

  | * input parameters:

  | * output parameters:

  |   - <order_master_id>                   :id del detalle de la orden.

  |   - <prospect_order>                    :id de la orden creada en el formulario.

  |   - <order_number>                      :número de orden.

  |   - <identity_document>                 :documento de indentidad.

  |   - <email>                 			:email.

  |   - <purchase_type_id>                  :id tipo de compra.

  |   - <purchase_date>                     :fecha de compra.

  |   - <number_products>                   :número de productos.

  |   - <number_products_unique>            :número de productos únicos.

  |   - <number_products_return>            :número de productos devuelos.

  |   - <number_products_change>            :número de productos cambiados.

  |   - <monto_total>                       :monto total.

  |   - <monto_total_return>                :monto total devuelto.

  |   - <monto_total_change>                :monto total de cambio.

  |   - <estado_request>                    :estado de la solicitud.

  |   - <flag_send_email>                   :bandera de correo enviado.

  |   - <id_qr>                             :id del qr.

  |   - <category_id>                       :id de categoria.

  |   - <category>                   		:categoria.

  |   - <return_method_id>                  :id de metodo de devolución.

  |   - <bar_code>                          :código de barra.

  |   - <email_option>                      :correo opcional.

  |   - <state_email_option>                :estado del correo opcional.

  | * autor       : gianmarcos perez rojas.

  | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

  | * responsable : cesar jimenez.

  | * rdc         : rq-4657-8

  |

  | * revisiones

  | * fecha            autor       motivo del cambio            rdc

  | ----------------------------------------------------------------------------

  | - 14/09/21    gianmarcos perez se agrega sucursal y trx     rq 4657-8
  | - 09/05/21    maximo apaza     rq 4707

  ************/

declare

	n_solicitudes_pendientes integer := 2;



begin



    update order x set category_id =

	  (select max(case when b.division_id = 'g02' then 9

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

	  where a.order_id = x.order_id  and

		a.quantity_products_return > 0)

     where x.estado_request = n_solicitudes_pendientes ;

    --actualizamos electro de 9 a 2

    update order x set category_id = 2 where category_id = 9;

    --actualizamos fallado de 7 a 1

	update order x set category_id = 1 where category_id = 7;

	return query

        select a.order_id as order_master_id,

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

	from "order" a

	join purchase p on p.purchase_id = a.purchase_id

	left join order_category b

	on b.order_category_id = a.category_id

	where a.estado_request = n_solicitudes_pendientes  ;

end;

$$;