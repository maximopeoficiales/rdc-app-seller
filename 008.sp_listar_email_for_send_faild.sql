create or replace function public.sp_listar_email_for_send_faild() returns table(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_id integer, category character varying, method_id integer, bar_code character varying, person_first_name character varying, person_last_name character varying, person_identity_document character varying, created_at timestamp with time zone, email_client character varying, name_client character varying, intentos bigint)
    language plpgsql
    as $$

	/*************

		| * descripcion : function public.sp_listar_email_for_send_faild

		| * proposito   : función para listar correos reintento.

		| * input parameters:

		| * output parameters:

		|   - <order_master_id>            :id order master.

		|   - <prospect_order>             :prospecto de la orden.

		|   - <order_number>               :número de orden.

		|   - <identity_document>          :documento de identidad.

		|   - <email>                      :email.

		|   - <purchase_type_id>           :id de tipo de compra.

		|   - <purchase_date>              :fecha de compra.

		|   - <number_products>            :número de productos.

		|   - <number_products_unique>     :número de productos únicos.

		|   - <number_products_return>     :número de productos devueltos.

		|   - <number_products_change>     :número de productos cambiados.

		|   - <monto_total>                :monto total.

		|   - <monto_total_return>         :monto total devuelto.

		|   - <monto_total_change>         :monto total de cambio.

		|   - <estado_request>             :estado de la solicitud.

		|   - <flag_send_email>            :bandera de envio de correo.

		|   - <id_qr>                      :id de código de barras.

		|   - <category_id>                :id de categoria.

		|   - <category>                   :categoria.

		|   - <return_method_id>           :id de metodo de compra.

		|   - <bar_code>                   :código de barras.

		|   - <person_first_name>          :nombre de la persona devolución a terceros.

		|   - <person_last_name>           :apellidos de la persona devolución a terceros.

		|   - <person_identity_document>   :documento de identidad de la persona devolución a terceros.

		|   - <created_at>                 :fecha de la solicitud.

		|   - <email_client>               :correo del cliente de compra online.

		|   - <name_client>               :nombre del cliente de compra online.

		|   - <intentos>                   :número de intentos.

		| * autor       : gianmarcos perez rojas.

		| * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

		| * responsable : cesar jimenez.

		| * rdc         : rq-4657-14

		|

		| * revisiones

		| * fecha            autor       motivo del cambio            			rdc

		| ----------------------------------------------------------------------------

		| - 16/11/21    rulman ferro   listar correos que no se enviaron      rq 4657-14
		| - 09/05/21    maximo apaza     rq 4707

	************/

	declare

		n_solicitudes_pendientes integer := 5;

	begin



		update send_email set  status_code = 8 where status_code = 2;



		return query

			select a.order_id as order_master_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				c.destination_email as email,

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

				a.person_first_name ,

				a.person_last_name ,

				a.person_identity_document ,

				a.created_at,

				/*inicio cambio rq 4657-14*/

				p.email_client,

				p.name_client,

				/*fin cambio rq 4657-14*/

				count(distinct c.order_master_id) as intentos

		from "order" a

		left join order_category b

		on b.order_category_id = a.category_id

		inner join send_email c

		on c.order_master_id = a.order_id

		join purchase p on p.purchase_id = a.purchase_id

		where a.estado_request in (5,6) and c.status_code = 8 and a.flag_send_email_security = 0

		group by a.order_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				c.destination_email,

				a.purchase_type_id,

				a.purchase_date,

				a.number_products,

				a.number_products_unique,

				a.number_products_return,

				a.number_products_change,

				a.amount_total,

				a.amount_total_return,

				a.amount_total_change,

				a.estado_request,

				a.flag_send_email,

				a.id_qr,

				a.category_id,

				b.description,

				a.return_method_id,

				a.bar_code,

				a.person_first_name ,

				a.person_last_name ,

				a.person_identity_document ,

				a.created_at,

				/*inicio cambio rq 4657-14*/

				p.email_client,

				p.name_client

				/*fin cambio rq 4657-14*/

		having count(c.order_master_id) < 4;

	end;

	$$;


