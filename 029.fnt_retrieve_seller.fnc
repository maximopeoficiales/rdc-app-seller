create function fnt_retrieve_seller(id_p bigint DEFAULT null, id_seller_mirakl_p varchar default null,
                                    name_p varchar default null) returns jsonb
    language plpgsql
as
$$
    /*************
     | * descripcion : public.fnt_find_sucursal_x_ticket
     | * proposito   : buscar sucurusal por ticket.
     | * input parameters:
     |   - <id>                      	    :id del seller.
     |   - <id_seller_mirakl_p>              :id_seller_mirakl.
     |   - <name_p>                        :nombre del seller.
      -- Output Parameters: < jsonb - objeto (Seller[]) >
     | * autor       : gianmarcos perez rojas.
     | * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
     | * responsable : cesar jimenez.
     | * rdc         : rq 4707
     |
     | * revisiones
     | * fecha            autor       motivo del cambio            rdc
     | ----------------------------------------------------------------------------
     | - 09/05/22    maximo apaza  creación de la función     rq 4707
     ************/
declare
    context text;
    data    jsonb = '{}';
    error   jsonb = '{}';

begin
    select coalesce(jsonb_agg(sellers), data)
    from (select *
          from seller
          where (
              case
                  when id_p is not null
                      then id = id_p
                  else true
                  end
              )
            and (
              case
                  when id_seller_mirakl_p is not null
                      then (
                      case
                          when id_seller_mirakl_p is null
                              then id_seller_mirakl is null
                          else id_seller_mirakl = id_seller_mirakl_p
                          end
                      )
                  else true
                  end
              )
            and (
              case
                  when name_p is not null
                      then (
                      case
                          when name_p is null
                              then name is null
                          else name = name_p
                          end
                      )
                  else true
                  end)) as sellers
    group by data
    into data;
    return jsonb_build_object('data', data, 'error', error);

exception
    when others then
        get stacked diagnostics context = pg_exception_context;
        select jsonb_build_object('code', sqlstate, 'name', sqlerrm, 'context', context) into error;
        return jsonb_build_object('data', data, 'error', error);

end;
$$;


