CREATE OR REPLACE FUNCTION sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying)
    returns TABLE(order_master_id bigint, tikect text, identity_document character varying, email character varying)
    language plpgsql
as
$$
    /*************

        | * Descripcion : FUNCTION public.sp_save_order

        | * Proposito   : Función para guardar orden de compra.

        | * Input Parameters:

        |   - <ni_prospectorder>               :Prospecto de la orden.

        |   - <ni_purchasetypeid>              :Id de tipo de compra.

        |   - <vi_numberorder>                 :Número de orden.

        |   - <vi_sucursal>                    :Código de sucursal.

        |   - <vi_caja>                        :Código de caja.

        |   - <vi_purchasedate>                :Fecha de compra.

        |   - <vi_identitdocument>             :Documento de identidad.

        |   - <vi_transacsion>                 :Número de transacción.

        |   - <vi_email>                       :Correo.

        |   - <ni_numberproducts>              :Número de productos.

        |   - <ni_numberproductsreturn>        :Número de productos devueltos.

        |   - <ni_montototal>                  :Monto total.

        |   - <ni_montototalchange>            :Monto total de cambio.

        |   - <ni_estadorequest>               :Estado de la solicitud.

        |   - <vi_coordinates>                 :Coordenadas.

        |   - <ni_return_method_id>            :Id metodo de devolución.

        |   - <vi_ip>                          :Ip.

        |   - <ni_purchase_id>                 :Id de compra.

        |   - <vi_person_return>               :Bandera de devolución a terceros.

        |   - <vi_person_first_name>           :Nombre de devolución a terceros.

        |   - <vi_person_last_name>            :Apellidos de devolución a terceros.

        |   - <vi_person_identity_document>    :Documento de identidad devolución a terceros.

        |   = <vi_type_order>                  : Si es una orden de marketplace o ripley.

        | * Output Parameters:

        |   - <order_master_id>                 :Id order master.

        |   - <tikect>             				:Número de ticket.

        |   - <identity_document>               :Documento de identidad.

        |   - <email>          					:Correo.

        | * Autor       : Gianmarcos Perez Rojas.

        | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

        | * Responsable : Cesar Jimenez.

        | * RDC         : RQ-4657-14

        |

        | * Revisiones

        | * Fecha            Autor       Motivo del cambio            RDC

        | ----------------------------------------------------------------------------

        | - 16/11/21    Gianmarcos Perez Guardar orde de compra    RQ 4657-14

    ************/

	DECLARE

		reg RECORD;

		n_seq      bigint := nextval('order_master_seq');

		n_seq_mov  bigint := nextval('order_movements_seq');

		v_tikect   text; 

		n_status_movemnts  integer :=2;

		v_email_client  text := null;

	BEGIN 

		v_tikect := cast(n_seq as varchar) ;

		v_tikect := lpad(v_tikect,6,'0');

		v_tikect := 'T-'||v_tikect;

		INSERT INTO order_movements(

		order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

		VALUES (n_seq_mov, n_seq, CURRENT_TIMESTAMP, n_status_movemnts, 'TESS'); 

		INSERT INTO "order"(

			order_id, prospect_order, order_number, identity_document, email, purchase_type_id,

			purchase_date, number_products, number_products_unique, number_products_return, 

			number_products_change, amount_total, amount_total_return, amount_total_change, estado_request,

			flag_send_email, id_qr,  coordinates, type_return_id, return_method_id, ip_address, purchase_id,

			/*INICIO CAMBIO RQ 4657-14*/

			person_return, person_first_name, person_last_name, person_identity_document, type_order)

			/*FIN CAMBIO RQ 4657-14*/

		VALUES (n_seq, ni_prospectorder, v_tikect, vi_identitdocument, vi_email, ni_purchasetypeid, 

		

				TO_DATE(vi_purchasedate,'YYYY-MM-DD'), ni_numberproducts, 0, ni_numberproductsreturn, 

				0, ni_montototal, 0, ni_montototalchange, n_status_movemnts, 

				0, 

				'https://chart.googleapis.com/chart?cht=qr&chs=350x350&chld=H&choe=UTF-8&chl=%7B%0A%22clientDni%22+%3A+%22vi_identitdocument%22%2C%0A%22ticketNumber%22%3A+%22v_tikect%22%0A%7D',  

				vi_coordinates, ni_return_method_id, ni_return_method_id, vi_ip, ni_purchase_id,

				/*INICIO CAMBIO RQ 4657-14*/

				vi_person_return,

				vi_person_first_name,

				vi_person_last_name,

				vi_person_identity_document,

			    vi_type_order);

			/*INICIO CAMBIO RQ 4657-14*/

		update purchase set email= vi_email where  purchase_id= ni_purchase_id;

		case 

			when ni_purchasetypeid = 1 then /*Internet*/ 

				INSERT INTO order_purchase_internet(

				order_master_id, number_order)

				VALUES (n_seq, vi_numberorder);

			when ni_purchasetypeid = 2 then /*Tienda*/

				INSERT INTO order_purchase_store(

				order_master_id, sucursal, caja, purchase_date, transaccion)

				VALUES (n_seq, vi_sucursal, vi_caja, vi_purchasedate, vi_transacsion);

			end case;

		RETURN QUERY  

		SELECT n_seq as order_master_id , v_tikect tikect, vi_identitdocument as identity_document,

		vi_email as email;  

	END

$$;

