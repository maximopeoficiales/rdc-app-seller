create or replace function public.sp_listar_order_x_tikect(vi_tikect character varying)
    returns table
            (
                order_id                 bigint,
                prospect_order           bigint,
                order_number             varchar,
                identity_document        varchar,
                email                    varchar,
                purchase_type_id         integer,
                purchase_date            date,
                number_products          integer,
                number_products_unique   integer,
                number_products_return   integer,
                number_products_change   integer,
                amount_total             numeric,
                amount_total_return      numeric,
                amount_total_change      numeric,
                estado_request           integer,
                flag_send_email          integer,
                id_qr                    varchar,
                created_at               timestamp with time zone,
                date_id                  date,
                coordinates              varchar,
                category_id              integer,
                type_return_id           integer,
                return_method_id         integer,
                bar_code                 varchar,
                ip_address               varchar,
                purchase_id              bigint,
                email_option             varchar,
                state_email_option       integer,
                person_return            integer,
                person_first_name        varchar,
                person_last_name         varchar,
                person_identity_document varchar,
                flag_send_email_security integer,
                type_order               varchar,
                phone                    varchar,
                order_master_id          bigint,
                monto_total              numeric,
                monto_total_return       numeric,
                monto_total_change       numeric
            )
as
$$
begin
 /*************
      | * descripcion : public.sp_listar_order_x_tikect
      | * proposito   : listar ordernes por numero de ticket.
      | * input parameters:
      |   - <vi_tikect>                        	  : numero de ticket.
      | * output parameters:
      |    - <order>  : Instancia con todos registro de la tabla order.
      |    - <order_master_id>      : Id de la orden.
      |    - <monto_total>          : Monto total.
      |    - <monto_total_return>      : Monto Total Retornado.
      |    - <monto_total_change>      : Monto total cambiado.
      | * autor       : gianmarcos perez rojas.
      | * proyecto    : rq 4707 - cambios y devoluciones ???devuelve r
      | * responsable : cesar jimenez.
      | * rdc         : rq 4707
      |
      | * revisiones
      | * fecha            autor       motivo del cambio            rdc
      | ----------------------------------------------------------------------------
      | - 09/05/22    maximo apaza  modificacion de la funci??n     rq 4707
      ************/
    return query
        select *,
               c.order_id            as order_master_id,
               c.amount_total        as monto_total,
               c.amount_total_return as monto_total_return,
               c.amount_total_change as monto_total_change
        from public."order" as c
        where c.order_number = vi_tikect;
end;
$$
    language plpgsql;