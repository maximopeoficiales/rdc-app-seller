CREATE FUNCTION public.sp_listar_email_for_send_security() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_idd integer, category character varying, method_id integer, bar_code character varying, email_option character varying, state_email_option integer, person_first_name character varying, person_last_name character varying, person_identity_document character varying, name_client character varying, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Funcion para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		| * Output Parameters:

		|   - <order_master_id>            :Id order master.

		|   - <prospect_order>             :Prospecto de la orden.

		|   - <order_number>               :Número de orden.

		|   - <identity_document>          :Documento de identidad.

		|   - <email>                      :Correo de la persona que realizo la compra online..

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

		|   - <name_client>   			   :Nombre del cliente de compra online.

		|   - <created_at>                 :Fecha de la solicitud.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio                 RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez Listar de correos de seguridad    RQ 4657-14

	************/

	DECLARE

		n_flag_send_email_security integer := 0;



	BEGIN

		RETURN QUERY

			SELECT a.order_id as order_master_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				p.email_client as email,

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

				a.person_first_name,

				a.person_last_name,

				a.person_identity_document,

				p.name_client,

				a.created_at

		FROM "order" a

		join purchase p on p.purchase_id =a.purchase_id

		left join order_category b on b.order_category_id = a.category_id

		WHERE p.email_client is not null and p.email_client != '' and a.flag_send_email_security = n_flag_send_email_security and p.sucursal='000060' and p.caja='000120';

	END;

	$$;


