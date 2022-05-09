create or replace function sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying, vi_phone character varying)
    returns table(order_master_id bigint, tikect text, identity_document character varying, email character varying, phone character varying)
    language plpgsql
as
$$
    /*************

        | * descripcion : function public.sp_save_order

        | * proposito   : función para guardar orden de compra.

        | * input parameters:

        |   - <ni_prospectorder>               :prospecto de la orden.

        |   - <ni_purchasetypeid>              :id de tipo de compra.

        |   - <vi_numberorder>                 :número de orden.

        |   - <vi_sucursal>                    :código de sucursal.

        |   - <vi_caja>                        :código de caja.

        |   - <vi_purchasedate>                :fecha de compra.

        |   - <vi_identitdocument>             :documento de identidad.

        |   - <vi_transacsion>                 :número de transacción.

        |   - <vi_email>                       :correo.

        |   - <ni_numberproducts>              :número de productos.

        |   - <ni_numberproductsreturn>        :número de productos devueltos.

        |   - <ni_montototal>                  :monto total.

        |   - <ni_montototalchange>            :monto total de cambio.

        |   - <ni_estadorequest>               :estado de la solicitud.

        |   - <vi_coordinates>                 :coordenadas.

        |   - <ni_return_method_id>            :id metodo de devolución.

        |   - <vi_ip>                          :ip.

        |   - <ni_purchase_id>                 :id de compra.

        |   - <vi_person_return>               :bandera de devolución a terceros.

        |   - <vi_person_first_name>           :nombre de devolución a terceros.

        |   - <vi_person_last_name>            :apellidos de devolución a terceros.

        |   - <vi_person_identity_document>    :documento de identidad devolución a terceros.

        |   = <vi_type_order>                  : si es una orden de marketplace o ripley.
        |	- <vi_phone>					   :telefono de usuario

        | * output parameters:

        |   - <order_master_id>                 :id order master.

        |   - <tikect>             				:número de ticket.

        |   - <identity_document>               :documento de identidad.

        |   - <email>          					:correo.
        |	- <phone>							:telefono

        | * autor       : gianmarcos perez rojas.

        | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

        | * responsable : cesar jimenez.

        | * rdc         : rq-4657-14

        |

        | * revisiones

        | * fecha            autor       motivo del cambio            rdc

        | ----------------------------------------------------------------------------

        | - 16/11/21    gianmarcos perez guardar orde de compra    rq 4657-14

    ************/

	declare

		reg record;

		n_seq      bigint := nextval('order_master_seq');

		n_seq_mov  bigint := nextval('order_movements_seq');

		v_tikect   text; 

		n_status_movemnts  integer :=2;

		v_email_client  text := null;

	begin 

		v_tikect := cast(n_seq as varchar) ;

		v_tikect := lpad(v_tikect,6,'0');

		v_tikect := 't-'||v_tikect;

		insert into order_movements(

		order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

		values (n_seq_mov, n_seq, current_timestamp, n_status_movemnts, 'tess'); 

		insert into "order"(

			order_id, prospect_order, order_number, identity_document, email, purchase_type_id,  

			purchase_date, number_products, number_products_unique, number_products_return, 

			number_products_change, amount_total, amount_total_return, amount_total_change, estado_request, 

			flag_send_email, id_qr,  coordinates, type_return_id, return_method_id, ip_address, purchase_id,

			/*inicio cambio rq 4657-14*/

			person_return, person_first_name, person_last_name, person_identity_document, type_order,phone)

			/*fin cambio rq 4657-14*/

		values (n_seq, ni_prospectorder, v_tikect, vi_identitdocument, vi_email, ni_purchasetypeid, 

		

				to_date(vi_purchasedate,'yyyy-mm-dd'), ni_numberproducts, 0, ni_numberproductsreturn, 

				0, ni_montototal, 0, ni_montototalchange, n_status_movemnts, 

				0, 

				'https://chart.googleapis.com/chart?cht=qr&chs=350x350&chld=h&choe=utf-8&chl=%7b%0a%22clientdni%22+%3a+%22vi_identitdocument%22%2c%0a%22ticketnumber%22%3a+%22v_tikect%22%0a%7d',  

				vi_coordinates, ni_return_method_id, ni_return_method_id, vi_ip, ni_purchase_id,

				/*inicio cambio rq 4657-14*/

				vi_person_return,

				vi_person_first_name,

				vi_person_last_name,

				vi_person_identity_document,

			    vi_type_order,
			   	vi_phone);

			/*inicio cambio rq 4657-14*/

		update purchase set email= vi_email where  purchase_id= ni_purchase_id;

		case 

			when ni_purchasetypeid = 1 then /*internet*/ 

				insert into order_purchase_internet(

				order_master_id, number_order)

				values (n_seq, vi_numberorder);

			when ni_purchasetypeid = 2 then /*tienda*/

				insert into order_purchase_store(

				order_master_id, sucursal, caja, purchase_date, transaccion)

				values (n_seq, vi_sucursal, vi_caja, vi_purchasedate, vi_transacsion);

			end case;

		return query  

		select n_seq as order_master_id , v_tikect tikect, vi_identitdocument as identity_document,

		vi_email as email, vi_phone as phone;  

	end

$$;


