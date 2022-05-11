create function fnt_retrieve_seller(_param jsonb DEFAULT '{}'::jsonb) returns jsonb
    language plpgsql
as
$$
    /*************
     | * descripcion : public.fnt_find_sucursal_x_ticket
     | * proposito   : buscar sucurusal por ticket.
     | * input parameters:
     |   - <id>                      	    :id del seller.
     |   - <id_seller_mirakl>              :id_seller_mirakl.
     |   - <name>                        :nombre del seller.
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
            data jsonb = '{}';
			error jsonb = '{}';

        begin
            select coalesce(jsonb_agg(sellers), data)
            from (
                select * from seller
                where (
                    case
                        when _param->'id' is not null
                        then id = cast(_param->>'id' as bigint)
                        else true
                    end
                )
                and (
                    case
                        when _param->'id_seller_mirakl' is not null
                        then (
                            case
                                when _param->>'id_seller_mirakl' is null
                                then id_seller_mirakl is null
                                else id_seller_mirakl = _param->>'id_seller_mirakl'
                            end
                        )
                        else true
                    end
                )
                and (
                    case
                        when _param->'name' is not null
                        then (
                            case
                                when _param->>'name' is null
                                then name is null
                                else lower(name) = lower(_param->>'name')
                            end
                        )
                        else true
                    end
                )
            ) as sellers into data;
            return jsonb_build_object('data', data, 'error', error);

        exception
            when others then
            get stacked diagnostics context = pg_exception_context;
           	select jsonb_build_object('code', sqlstate, 'name', sqlerrm, 'context', context) into error;
            return jsonb_build_object('data', data, 'error', error);

        end;
$$;


