create or replace function sp_save_send_email_security(ni_order_master_id integer, ni_send_success integer,
                                            vi_asunto character varying, vi_destination_email character varying,
                                            vi_emails_cc character varying, out vo_ind integer,
                                            out vo_msn character varying) returns record
    language plpgsql
as
$$
    /*************

        | * descripcion : function public.sp_save_send_email_security

        | * proposito   : funcion para insertar movimientos de la orden.

        | * input parameters:

        |   - <ni_order_master_id>              	:id de orden de compra.

        |   - <ni_send_success>              		:estado del correo.

        |   - <vi_asunto>                 			:asunto de correo.

        |   - <vi_destination_email>                :destino del correo.

        |   - <vi_emails_cc>                        :copia del correo.

        | * output parameters:

        |   - <vo_ind>             				    :número de estado.

        |   - <vo_msn>               				:mensaje de respuesta.

        | * autor       : gianmarcos perez rojas.

        | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

        | * responsable : cesar jimenez.

        | * rdc         : rq-4657-14

        |

        | * revisiones

        | * fecha            autor        motivo del cambio                  rdc

        | ----------------------------------------------------------------------------

        | - 16/11/21    gianmarcos perez  guardar estado correo seguridad    rq 4657-14

      | - 09/05/22    maximo apaza  modificacion de la función     rq 4707

    ************/

declare

    reg      record;
    n_seq    bigint := nextval('order_movements_seq');
    v_tikect text;

begin

    vo_ind := 0;

    vo_msn := 'se registro correctamente!!';


    if ni_send_success = 1 then

        update send_email set status_code = 9 where order_master_id = ni_order_master_id and status_code = 8;

        update "order" set flag_send_email_security = 1 where order_id = ni_order_master_id;

    end if;


    insert into order_movements(order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

    values (n_seq, ni_order_master_id, current_timestamp, 6, 'tess');

    insert into send_email(request_movements_id, order_master_id,
                           affair, destination_email, emails_cc, state_code_send, send_success, status_code)

    values (n_seq, ni_order_master_id, vi_asunto, vi_destination_email, vi_emails_cc, 6, ni_send_success,
            ni_send_success);


end

$$;


