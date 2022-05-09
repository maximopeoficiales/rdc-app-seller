CREATE FUNCTION public.sp_listar_email_for_send_faild() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_id integer, category character varying, method_id integer, bar_code character varying, person_first_name character varying, person_last_name character varying, person_identity_document character varying, created_at timestamp with time zone, email_client character varying, name_client character varying, intentos bigint)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_listar_email_for_send_faild

		| * Proposito   : Función para listar correos reintento.

		| * Input Parameters:

		| * Output Parameters:

		|   - <order_master_id>            :Id order master.

		|   - <prospect_order>             :Prospecto de la orden.

		|   - <order_number>               :Número de orden.

		|   - <identity_document>          :Documento de identidad.

		|   - <email>                      :Email.

		|   - <purchase_type_id>           :Id de tipo de compra.

		|   - <purchase_date>              :Fecha de compra.

		|   - <number_products>            :Número de productos.

		|   - <number_products_unique>     :Número de productos únicos.

		|   - <number_products_return>     :Número de productos devueltos.

		|   - <number_products_change>     :Número de productos cambiados.

		|   - <monto_total>                :Monto total.

		|   - <monto_total_return>         :Monto total devuelto.

		|   - <monto_total_change>         :Monto total de cambio.

		|   - <estado_request>             :Estado de la solicitud.

		|   - <flag_send_email>            :Bandera de envio de correo.

		|   - <id_qr>                      :Id de código de barras.

		|   - <category_id>                :Id de categoria.

		|   - <category>                   :Categoria.

		|   - <return_method_id>           :Id de metodo de compra.

		|   - <bar_code>                   :Código de barras.

		|   - <person_first_name>          :Nombre de la persona devolución a terceros.

		|   - <person_last_name>           :Apellidos de la persona devolución a terceros.

		|   - <person_identity_document>   :Documento de identidad de la persona devolución a terceros.

		|   - <created_at>                 :Fecha de la solicitud.

		|   - <email_client>               :Correo del cliente de compra online.

		|   - <name_client>               :Nombre del cliente de compra online.

		|   - <intentos>                   :Número de intentos.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            			RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Rulman Ferro   Listar correos que no se enviaron      RQ 4657-14

	************/

	DECLARE

		n_solicitudes_pendientes integer := 5;

	BEGIN



		update send_email set  status_code = 8 where status_code = 2;



		RETURN QUERY

			SELECT a.order_id as order_master_id,

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

				/*INICIO CAMBIO RQ 4657-14*/

				p.email_client,

				p.name_client,

				/*FIN CAMBIO RQ 4657-14*/

				count(distinct c.order_master_id) as intentos

		FROM "order" a

		left join order_category b

		on b.order_category_id = a.category_id

		inner JOIN send_email c

		ON c.order_master_id = a.order_id

		join purchase p ON p.purchase_id = a.purchase_id

		WHERE a.estado_request in (5,6) and c.status_code = 8 and a.flag_send_email_security = 0

		GROUP BY a.order_id,

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

				/*INICIO CAMBIO RQ 4657-14*/

				p.email_client,

				p.name_client

				/*FIN CAMBIO RQ 4657-14*/

		HAVING count(c.order_master_id) < 4;

	END;

	$$;


